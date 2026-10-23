const UPLOAD_URL = `${process.env.NEXT_PUBLIC_BACKEND_URL || "https://hrms-api-test.onrender.com"}/files/upload`;

export function resolveAttachmentUrl(path: string | null | undefined): string {
  if (!path) return "";
  if (path.startsWith("http://") || path.startsWith("https://")) return path;
  if (path.startsWith("https://hrms-api-test.onrender.com")) return path;
  if (path.startsWith("/uploads/"))
    return `https://hrms-api-test.onrender.com${path}`;
  return path;
}

export async function uploadAttachmentFile(file: File): Promise<string> {
  const fd = new FormData();
  fd.append("file", file);
  const token =
    typeof window !== "undefined"
      ? localStorage.getItem("token") ||
        localStorage.getItem("accessToken") ||
        ""
      : "";
  const res = await fetch(UPLOAD_URL, {
    method: "POST",
    headers: token ? { Authorization: `Bearer ${token}` } : {},
    body: fd,
  });
  if (!res.ok) throw new Error("File upload failed");
  const data = await res.json();
  return resolveAttachmentUrl(data.url as string);
}
