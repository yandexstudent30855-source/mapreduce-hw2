#!/usr/bin/env bash
set -euo pipefail

cat > mapreduce/task1/mapper.py <<'PY'
#!/usr/bin/env python3
import sys, json

DAYS = ("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")

def to_minutes(hhmm: str) -> int:
    h, m = hhmm.split(":")
    return int(h) * 60 + int(m)

def interval_minutes(s: str) -> int:
    start, end = s.split("-")
    if start == "0:0" and end == "0:0":
        return 0
    a = to_minutes(start)
    b = to_minutes(end)
    if b < a:
        b += 24 * 60
    return max(0, b - a)

def fmt_hours(total_minutes: int) -> str:
    h = total_minutes / 60.0
    if abs(h - round(h)) < 1e-9:
        return str(int(round(h)))
    return f"{h:.2f}".rstrip("0").rstrip(".")

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        obj = json.loads(line)
    except Exception:
        continue

    bid = obj.get("business_id")
    if not bid:
        continue

    cats = obj.get("categories") or ""
    if "Restaurants" not in cats:
        continue

    if obj.get("is_open", 1) == 0:
        print(f"{bid}\t0")
        continue

    hours = obj.get("hours") or {}
    total = 0
    for d in DAYS:
        s = hours.get(d)
        if s:
            total += interval_minutes(s)

    print(f"{bid}\t{fmt_hours(total)}")
PY

cat > mapreduce/task1/reducer.py <<'PY'
#!/usr/bin/env python3
import sys

current = None
value = None

for line in sys.stdin:
    line = line.rstrip("\n")
    if not line:
        continue
    k, v = line.split("\t", 1)
    if current is None:
        current, value = k, v
    elif k != current:
        print(f"{current}\t{value}")
        current, value = k, v

if current is not None:
    print(f"{current}\t{value}")
PY

cat > mapreduce/task1/run1.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail

OUT="${1:?Usage: ./run1.sh <output_folder_in_hdfs>}"
INPUT="/data/yelp/business"

STREAMING_JAR="$(ls /usr/lib/hadoop-mapreduce/hadoop-streaming*.jar 2>/dev/null | head -1 || true)"
if [[ -z "${STREAMING_JAR}" ]]; then
  STREAMING_JAR="$(ls /usr/lib/hadoop/hadoop-streaming*.jar 2>/dev/null | head -1 || true)"
fi
if [[ -z "${STREAMING_JAR}" ]]; then
  echo "ERROR: hadoop-streaming jar not found" >&2
  exit 1
fi

hdfs dfs -rm -r -f "$OUT" >/dev/null 2>&1 || true

hadoop jar "$STREAMING_JAR" \
  -D mapreduce.job.name="yelp_task1_weekly_open_hours" \
  -files mapper.py,reducer.py \
  -mapper "python3 mapper.py" \
  -reducer "python3 reducer.py" \
  -input "$INPUT" \
  -output "$OUT"
SH

chmod +x mapreduce/task1/run1.sh
echo "OK: task1 files created"
