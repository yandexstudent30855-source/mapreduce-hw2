#!/usr/bin/env bash
set -euo pipefail

cat > mapreduce/task2/mapper.py <<'PY'
#!/usr/bin/env python3
import sys

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    parts = line.split("\t")
    if len(parts) != 2:
        continue
    bid, hours = parts
    print(f"{bid}\t{hours}")
PY

cat > mapreduce/task2/reducer.py <<'PY'
#!/usr/bin/env python3
import sys

rows = []
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    bid, h = line.split("\t", 1)
    try:
        hours = float(h)
    except Exception:
        continue
    rows.append((hours, bid))

# hours desc, business_id asc
rows.sort(key=lambda x: (-x[0], x[1]))

for hours, bid in rows[:10]:
    if abs(hours - round(hours)) < 1e-9:
        out_h = str(int(round(hours)))
    else:
        out_h = f"{hours:.2f}".rstrip("0").rstrip(".")
    print(f"{bid}\t{out_h}")
PY

cat > mapreduce/task2/run2.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail

IN="${1:?Usage: ./run2.sh <task1_output_folder_in_hdfs> [task2_output_folder_in_hdfs]}"
OUT="${2:-/user/$USER/yelp_task2_out}"

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
  -D mapreduce.job.name="yelp_task2_top10_weekly_hours" \
  -D mapreduce.job.reduces=1 \
  -files mapper.py,reducer.py \
  -mapper "python3 mapper.py" \
  -reducer "python3 reducer.py" \
  -input "$IN" \
  -output "$OUT"
SH

chmod +x mapreduce/task2/run2.sh
echo "OK: task2 files created"
