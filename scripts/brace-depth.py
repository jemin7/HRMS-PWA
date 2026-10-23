import re, sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
path = sys.argv[1]
s = open(path, encoding="utf-8").read()
s = re.sub(r"//[^\n]*", "", s)
s = re.sub(r"/\*.*?\*/", "", s, flags=re.S)
s = re.sub(r"'(?:\\.|[^'\\\n])*'", "''", s)
s = re.sub(r'"(?:\\.|[^"\\\n])*"', '""', s)
s = re.sub(r"`(?:\\.|[^`\\])*`", "``", s)

lines = s.split("\n")
depth = 0
neg_seen = False
start = int(sys.argv[2]) if len(sys.argv) > 2 else 1
end = int(sys.argv[3]) if len(sys.argv) > 3 else len(lines)

for i, l in enumerate(lines, 1):
    for ch in l:
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
    if depth < 0 and not neg_seen:
        print("NEGATIVE depth at line", i)
        neg_seen = True
    if start <= i <= end:
        print(i, depth, l.strip()[:76])
    if len(sys.argv) > 2 and not (start <= i <= end):
        # still need member checkpoint mode compat: print declaration depths
        pass
if len(sys.argv) > 2 and sys.argv[1] == "--markers":
    depth = 0
    for i, l in enumerate(lines, 1):
        for ch in l:
            if ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
        if re.match(r"^  (async |private |get |readonly |@)", l):
            print(i, depth, l.strip()[:70])
    print("final", depth)
