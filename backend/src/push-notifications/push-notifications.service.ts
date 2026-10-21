import { BadRequestException, Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import * as fs from 'fs';
import * as path from 'path';
import * as https from 'https';
import * as webpush from 'web-push';

/**
 * Force IPv4 + keep-alive for outbound push. The server has no working IPv6
 * route, so Node's "happy eyeballs" wastes time on unreachable IPv6 addresses
 * (ENETUNREACH) before falling back to IPv4 — and some Apple push IPs time out
 * intermittently. Pinning IPv4 and reusing connections makes delivery to
 * web.push.apple.com (iOS) and FCM (Android) fast and reliable.
 */
const pushAgent = new https.Agent({
  keepAlive: true,
  family: 4,
  maxSockets: 20,
  timeout: 8000,
});

const SUBSCRIPTIONS_DIR =
  process.env.PUSH_SUBSCRIPTIONS_DIR || path.join(process.cwd(), 'data');
const SUBSCRIPTIONS_FILE = path.join(
  SUBSCRIPTIONS_DIR,
  'push-subscriptions.json',
);

export interface PushSubscriptionRecord {
  employeeID: number;
  subscription: webpush.PushSubscription;
}

function decodeBase64Url(value: string): Buffer {
  const padding = '='.repeat((4 - (value.length % 4)) % 4);
  const base64 = (value + padding).replace(/-/g, '+').replace(/_/g, '/');
  return Buffer.from(base64, 'base64');
}

/** Browser push keys must decode to 65-byte p256dh and 16-byte auth secrets. */
export function isValidPushSubscription(
  subscription: webpush.PushSubscription | null | undefined,
): boolean {
  if (
    !subscription?.endpoint ||
    !subscription?.keys?.p256dh ||
    !subscription?.keys?.auth
  ) {
    return false;
  }
  try {
    const p256dh = decodeBase64Url(subscription.keys.p256dh);
    const auth = decodeBase64Url(subscription.keys.auth);
    return p256dh.length === 65 && auth.length === 16;
  } catch {
    return false;
  }
}

@Injectable()
export class PushNotificationsService {
  private readonly logger = new Logger(PushNotificationsService.name);

  constructor(private readonly prisma: PrismaService) {
    const vapidPublicKey = process.env.VAPID_PUBLIC_KEY;
    const vapidPrivateKey = process.env.VAPID_PRIVATE_KEY;
    const vapidEmail = process.env.VAPID_EMAIL || 'mailto:admin@openhrm.com';

    if (vapidPublicKey && vapidPrivateKey) {
      webpush.setVapidDetails(vapidEmail, vapidPublicKey, vapidPrivateKey);
    } else {
      this.logger.warn(
        'VAPID keys not configured. Push notifications will not work.',
      );
    }
  }

  getVapidPublicKey(): string {
    return process.env.VAPID_PUBLIC_KEY || '';
  }

  hasSubscription(employeeID: number): boolean {
    const empId = this.normalizeEmployeeId(employeeID);
    const records = this.readSubscriptions();
    const record = records.find((r) => Number(r.employeeID) === empId);
    return !!record && isValidPushSubscription(record.subscription);
  }

  private ensureSubscriptionsDir(): void {
    if (!fs.existsSync(SUBSCRIPTIONS_DIR)) {
      fs.mkdirSync(SUBSCRIPTIONS_DIR, { recursive: true });
    }
  }

  private normalizeEmployeeId(employeeID: number): number {
    const id = Number(employeeID);
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error(`Invalid employeeID: ${employeeID}`);
    }
    return id;
  }

  private readSubscriptions(): PushSubscriptionRecord[] {
    try {
      if (!fs.existsSync(SUBSCRIPTIONS_FILE)) return [];
      const data = fs.readFileSync(SUBSCRIPTIONS_FILE, 'utf-8');
      return JSON.parse(data) as PushSubscriptionRecord[];
    } catch {
      return [];
    }
  }

  private writeSubscriptions(records: PushSubscriptionRecord[]): void {
    try {
      this.ensureSubscriptionsDir();
      fs.writeFileSync(
        SUBSCRIPTIONS_FILE,
        JSON.stringify(records, null, 2),
        'utf-8',
      );
    } catch (err) {
      this.logger.error('Failed to write subscriptions file', err);
    }
  }

  saveSubscription(
    employeeID: number,
    subscription: webpush.PushSubscription,
  ): void {
    const empId = this.normalizeEmployeeId(employeeID);
    if (!isValidPushSubscription(subscription)) {
      throw new Error(
        'Invalid push subscription (missing endpoint or malformed keys)',
      );
    }
    const records = this.readSubscriptions();
    // Multi-device: keep one record per (employee, endpoint). A given physical
    // device endpoint can only belong to one employee, so drop that endpoint
    // from any other employee, but keep this employee's OTHER devices intact.
    const endpoint = subscription.endpoint;
    const filtered = records.filter(
      (r) => r.subscription?.endpoint !== endpoint,
    );
    filtered.push({ employeeID: empId, subscription });
    this.writeSubscriptions(filtered);
    this.logger.log(
      `Saved push subscription for employee ${empId} → ${SUBSCRIPTIONS_FILE}`,
    );
  }

  async registerMobilePushToken(
    employeeID: number,
    expoPushToken: string,
    platform: string,
  ) {
    const empId = this.normalizeEmployeeId(employeeID);
    const token = expoPushToken?.trim();

    if (
      !token ||
      token.length > 255 ||
      !/^(Expo|Exponent)PushToken\[[^\]]+\]$/.test(token)
    ) {
      throw new BadRequestException('Invalid Expo push token.');
    }

    if (platform !== 'android' && platform !== 'ios') {
      throw new BadRequestException('Platform must be android or ios.');
    }

    const now = new Date();

    return this.prisma.mobilePushToken.upsert({
      where: {
        expoPushToken: token,
      },
      create: {
        employeeID: empId,
        expoPushToken: token,
        platform,
        lastSeenAt: now,
      },
      update: {
        employeeID: empId,
        platform,
        lastSeenAt: now,
      },
      select: {
        id: true,
        employeeID: true,
        platform: true,
        lastSeenAt: true,
      },
    });
  }
  /** Notify employee and their linked managers (manager copy uses team-member wording). */
  async sendToEmployeeAndManagers(
    employeeID: number,
    title: string,
    body: string,
    data?: Record<string, any>,
  ): Promise<void> {
    const empId = this.normalizeEmployeeId(employeeID);
    const baseData = { ...(data || {}), subjectEmployeeId: empId };
    await this.sendToEmployee(empId, title, body, baseData);

    const emp = await this.prisma.manageEmployee.findUnique({
      where: { id: empId },
      select: {
        employeeFirstName: true,
        employeeLastName: true,
        employeeID: true,
      },
    });
    const name =
      [emp?.employeeFirstName, emp?.employeeLastName]
        .filter(Boolean)
        .join(' ')
        .trim() ||
      emp?.employeeID ||
      `Employee #${empId}`;

    const managerBody = body
      .replace(/^Your /i, `${name}'s `)
      .replace(/^You have been /i, `${name} has been `)
      .replace(/^You have /i, `${name} has `)
      .replace(/^You were /i, `${name} was `);

    const links = await this.prisma.employeeLink.findMany({
      where: { employeeId: empId },
      select: { linkedEmployeeId: true },
    });

    for (const link of links) {
      await this.sendToEmployee(
        link.linkedEmployeeId,
        `${name}: ${title}`,
        managerBody,
        { ...baseData, isTeamNotification: true },
      );
    }
  }

  async sendDailyBirthdayReminders(): Promise<{
    date: string;
    birthdayEmployees: number;
    pushAttempts: number;
    alreadyProcessed?: boolean;
  }> {
    const dateParts = new Intl.DateTimeFormat('en-CA', {
      timeZone: 'Asia/Kolkata',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).formatToParts(new Date());

    const part = (type: string) =>
      dateParts.find((item) => item.type === type)?.value ?? '';

    const year = Number(part('year'));
    const month = Number(part('month'));
    const day = Number(part('day'));
    const dateKey = `${part('year')}-${part('month')}-${part('day')}`;
    const eventKey = `birthday-push:${dateKey}`;

    const previous = await this.prisma.auditLog.findFirst({
      where: {
        module: 'PUSH_NOTIFICATIONS',
        action: 'DAILY_BIRTHDAY_PUSH',
        entityName: eventKey,
      },
      select: { id: true },
    });

    if (previous) {
      return {
        date: dateKey,
        birthdayEmployees: 0,
        pushAttempts: 0,
        alreadyProcessed: true,
      };
    }

    const employees = await this.prisma.manageEmployee.findMany({
      where: {
        isDeleted: false,
        lifecycleStatus: 'ACTIVE',
        employmentStatus: { not: 'Terminated' },
        companyID: { not: null },
        dateOfBirth: { not: null },
      },
      select: {
        id: true,
        companyID: true,
        employeeFirstName: true,
        employeeLastName: true,
        dateOfBirth: true,
      },
    });

    const getBirthday = (dob: string | null) => {
      if (!dob) return null;

      const value = dob.trim();
      const iso = value.match(/^(\d{4})-(\d{2})-(\d{2})/);

      if (iso) {
        return { month: Number(iso[2]), day: Number(iso[3]) };
      }

      const slash = value.match(/^(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})/);

      if (slash) {
        return { month: Number(slash[2]), day: Number(slash[1]) };
      }

      return null;
    };

    const birthdays = employees.filter((employee) => {
      const birthday = getBirthday(employee.dateOfBirth);
      if (!birthday) return false;

      // Match the existing feed's behavior for February 29 birthdays.
      const normalized = new Date(
        Date.UTC(year, birthday.month - 1, birthday.day),
      );

      return (
        normalized.getUTCMonth() + 1 === month &&
        normalized.getUTCDate() === day
      );
    });

    const jobs: Array<() => Promise<void>> = [];

    for (const birthdayEmployee of birthdays) {
      const name =
        [birthdayEmployee.employeeFirstName, birthdayEmployee.employeeLastName]
          .filter(Boolean)
          .join(' ')
          .trim() || 'Employee';

      const recipients = employees.filter(
        (employee) => employee.companyID === birthdayEmployee.companyID,
      );

      for (const recipient of recipients) {
        const isSelf = recipient.id === birthdayEmployee.id;
        jobs.push(() =>
          this.sendToEmployee(
            recipient.id,
            isSelf ? 'Happy Birthday!' : `${name}'s birthday today`,
            isSelf
              ? 'Wishing you a wonderful birthday from your company family.'
              : `Don't forget to wish ${name} a happy birthday.`,
            {
              url: '/notifications',
              kind: 'birthday',
              event: `birthday-${dateKey}-${birthdayEmployee.id}`,
              birthdayEmployeeId: birthdayEmployee.id,
            },
          ),
        );
      }
    }

    // Limit concurrent push operations.
    for (let i = 0; i < jobs.length; i += 20) {
      await Promise.allSettled(jobs.slice(i, i + 20).map((send) => send()));
    }

    await this.prisma.auditLog.create({
      data: {
        module: 'PUSH_NOTIFICATIONS',
        action: 'DAILY_BIRTHDAY_PUSH',
        entityName: eventKey,
        entityId: dateKey,
        success: true,
        oldData: JSON.stringify({
          birthdayEmployees: birthdays.length,
          pushAttempts: jobs.length,
          status: 'attempted',
        }),
      },
    });

    this.logger.log(
      `Daily birthday push processed for ${dateKey}: ${birthdays.length} birthdays, ${jobs.length} push attempts`,
    );

    return {
      date: dateKey,
      birthdayEmployees: birthdays.length,
      pushAttempts: jobs.length,
    };
  }
  private async sendMobilePushToEmployee(
    employeeID: number,
    title: string,
    body: string,
    data?: Record<string, any>,
  ): Promise<void> {
    const tokens = await this.prisma.mobilePushToken.findMany({
      where: { employeeID },
      select: { expoPushToken: true },
    });

    if (tokens.length === 0) {
      this.logger.log(`No mobile push token for employee ${employeeID}`);
      return;
    }

    const accessToken = process.env.EXPO_ACCESS_TOKEN?.trim();

    // Expo accepts at most 100 messages per request.
    for (let start = 0; start < tokens.length; start += 100) {
      const batch = tokens.slice(start, start + 100);

      const messages = batch.map((token) => ({
        to: token.expoPushToken,
        sound: 'default',
        title,
        body,
        data: data ?? {},
        priority: 'high',
        channelId: 'default',
      }));

      try {
        const response = await fetch('https://exp.host/--/api/v2/push/send', {
          method: 'POST',
          headers: {
            Accept: 'application/json',
            'Content-Type': 'application/json',
            ...(accessToken ? { Authorization: `Bearer ${accessToken}` } : {}),
          },
          body: JSON.stringify(messages),
        });

        const result = (await response.json().catch(() => null)) as {
          data?: Array<{
            status?: string;
            id?: string;
            message?: string;
            details?: { error?: string };
          }>;
          errors?: unknown[];
        } | null;

        if (!response.ok || !Array.isArray(result?.data)) {
          this.logger.error(
            `Expo push request failed for employee ${employeeID}: HTTP ${response.status}; ${JSON.stringify(result)}`,
          );
          continue;
        }

        for (let index = 0; index < batch.length; index++) {
          const ticket = result.data[index];
          const token = batch[index].expoPushToken;

          if (ticket?.status === 'ok') {
            this.logger.log(
              `Expo accepted push for employee ${employeeID}; ticket=${ticket.id ?? 'unknown'}`,
            );
            continue;
          }

          if (ticket?.details?.error === 'DeviceNotRegistered') {
            await this.prisma.mobilePushToken.deleteMany({
              where: { expoPushToken: token },
            });

            this.logger.warn(
              `Removed unregistered mobile push token for employee ${employeeID}`,
            );
            continue;
          }

          this.logger.error(
            `Expo rejected mobile push for employee ${employeeID}: ${ticket?.message ?? JSON.stringify(ticket)}`,
          );
        }
      } catch (error) {
        this.logger.error(
          `Expo push request failed for employee ${employeeID}: ${
            error instanceof Error ? error.message : String(error)
          }`,
        );
      }
    }
  }

  async sendToEmployee(
    employeeID: number,
    title: string,
    body: string,
    data?: Record<string, any>,
  ): Promise<void> {
    const empId = this.normalizeEmployeeId(employeeID);

    // Send to native Android/iOS devices independently of VAPID.
    await this.sendMobilePushToEmployee(empId, title, body, data);

    // Browser Web Push still uses VAPID credentials.
    if (!process.env.VAPID_PUBLIC_KEY || !process.env.VAPID_PRIVATE_KEY) {
      this.logger.warn(
        'VAPID keys not configured — skipping browser Web Push only',
      );
      return;
    }

    const records = this.readSubscriptions();
    // Deliver to ALL of the employee's registered devices.
    const mine = records.filter((r) => Number(r.employeeID) === empId);
    if (mine.length === 0) {
      this.logger.log(`No push subscription for employee ${empId}`);
      return;
    }

    const payload = JSON.stringify({ title, body, data: data || {} });
    // urgency:high + short TTL tells the push service to deliver promptly and
    // not sit on the message — this fixes the 20–30s delivery delays.
    // agent pins IPv4 (see pushAgent above) so Apple/iOS endpoints connect.
    const options: webpush.RequestOptions = {
      TTL: 60,
      urgency: 'high',
      agent: pushAgent,
    };

    const deadEndpoints = new Set<string>();
    await Promise.all(
      mine.map(async (record) => {
        if (!isValidPushSubscription(record.subscription)) {
          deadEndpoints.add(record.subscription?.endpoint);
          return;
        }
        try {
          await this.sendWithRetry(record.subscription, payload, options);
          this.logger.log(`Push sent to employee ${empId}: ${title}`);
        } catch (err: any) {
          const status = err?.statusCode;
          const remove =
            status === 410 ||
            status === 404 ||
            (typeof err?.message === 'string' &&
              (err.message.includes('p256dh') || err.message.includes('auth')));
          if (remove) {
            deadEndpoints.add(record.subscription.endpoint);
            this.logger.warn(
              `Removing dead subscription for employee ${empId} (status ${status})`,
            );
          } else {
            this.logger.error(
              `Failed to send push to employee ${empId}: ${err?.code || err?.statusCode || err?.message}`,
            );
          }
        }
      }),
    );

    if (deadEndpoints.size > 0) {
      const fresh = this.readSubscriptions().filter(
        (r) => !deadEndpoints.has(r.subscription?.endpoint),
      );
      this.writeSubscriptions(fresh);
    }
  }

  /**
   * Send with up to 2 retries on transient network errors (ETIMEDOUT /
   * ECONNRESET / EAI_AGAIN). Apple's push IPs are flaky from this host, so a
   * retry typically lands on a reachable IP. HTTP 4xx (e.g. 410/404) are NOT
   * retried — they are surfaced so the dead subscription gets pruned.
   */
  private async sendWithRetry(
    subscription: webpush.PushSubscription,
    payload: string,
    options: webpush.RequestOptions,
    attempts = 3,
  ): Promise<void> {
    let lastErr: any;
    for (let i = 0; i < attempts; i++) {
      try {
        await webpush.sendNotification(subscription, payload, options);
        return;
      } catch (err: any) {
        lastErr = err;
        // HTTP status present => server responded; don't retry (let caller prune).
        if (err?.statusCode) throw err;
        const code = err?.code || err?.errors?.[0]?.code;
        const transient =
          code === 'ETIMEDOUT' ||
          code === 'ECONNRESET' ||
          code === 'EAI_AGAIN' ||
          code === 'ECONNREFUSED';
        if (!transient || i === attempts - 1) throw err;
        await new Promise((r) => setTimeout(r, 400 * (i + 1)));
      }
    }
    throw lastErr;
  }

  removeSubscription(employeeID: number): void {
    const empId = this.normalizeEmployeeId(employeeID);
    const records = this.readSubscriptions();
    this.writeSubscriptions(
      records.filter((r) => Number(r.employeeID) !== empId),
    );
  }
}
