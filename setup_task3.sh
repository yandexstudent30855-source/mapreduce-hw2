#!/usr/bin/env bash
set -euo pipefail

cat > mapreduce/task3/step1_mapper.py <<'PY'
#!/usr/bin/env python3
import sys, json

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        obj = json.loads(line)
    except Exception:
        continue

    # review record
    if "review_id" in obj and "user_id" in obj and "useful" in obj:
        uid = obj.get("user_id")
        try:
            useful = int(obj.get("useful", 0))
        except Exception:
            useful = 0
        print(f"{uid}\tR\t{useful}")
        continue

    # user record
    if "user_id" in obj and "friends" in obj:
        uid = obj.get("user_id")
        friends = obj.get("friends") or ""
        cnt = 0
        if isinstance(friends, str):
            friends = friends.strip()
            if friends and friends != "None":
                cnt = len([x for x in friends.split(",") if x.strip()])
        elif isinstance(friends, list):
            cnt = len(friends)
        print(f"{uid}\tU\t{cnt}")
PY

cat > mapreduce/task3/step1_reducer.py <<'PY'
#!/usr/bin/env python3
import sys, heapq

def flush(uid, heap5, friends_cnt):
    print(f"{uid}\t{sum(heap5)}\t{friends_cnt}")

cur = None
friends_cnt = 0
heap5 = []

for line in sys.stdin:
    line = line.rstrip("\n")
    if not line:
        continue
    uid, tag, val = line.split("\t", 2)

    if cur is None:
        cur = uid

    if uid != cur:
        flush(cur, heap5, friends_cnt)
        cur = uid
        friends_cnt = 0
        heap5 = []

    if tag == "U":
        try:
            friends_cnt = int(val)
        except Exception:
            friends_cnt = 0
    elif tag == "R":
        try:
            useful = int(val)
        except Exception:
            useful = 0
        if len(heap5) < 5:
            heapq.heappush(heap5, useful)
        else:
            if useful > heap5[0]:
                heapq.heapreplace(heap5, useful)

if cur is not None:
    flush(cur, heap5, friends_cnt)
PY

cat > mapreduce/task3/step2_mapper.py <<'PY'
#!/usr/bin/env python3
import sys

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    parts = line.split("\t")
    if len(parts) != 3:
        continue
    uid, s, f = parts
    print(f"{uid}\t{s}\t{f}")
PY

cat > mapreduce/task3/step2_reducer.py <<'PY'
#!/usr/bin/env python3
import sys

rows = []
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    uid, s, f = line.split("\t", 2)
    try:
        score = int(s)
    except Exception:
        continue
    rows.append((score, uid, f))

rows.sort(key=lambda x: (-x[0], x[1]))

for score, uid, f in rows[:10]:
    print(f"{uid}\t{score}\t{f}")
PY

cat > mapreduce/task3/run3.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail

OUT="${1:?Usage: ./run3.sh <output_folder_in_hdfs>}"
REVIEW="/data/yelp/review"
USER="/data/yelp/user"
TMP="/user/$USER/yelp_task3_tmp"

STREAMING_JAR="$(ls /usr/lib/hadoop-mapreduce/hadoop-streaming*.jar 2>/dev/null | head -1 || true)"
if [[ -z "${STREAMING_JAR}" ]]; then
  STREAMING_JAR="$(ls /usr/lib/hadoop/hadoop-streaming*.jar 2>/dev/null | head -1 || true)"
fi
if [[ -z "${STREAMING_JAR}" ]]; then
  echo "ERROR: hadoop-streaming jar not found" >&2
  exit 1
fi

hdfs dfs -rm -r -f "$TMP" >/dev/null 2>&1 || true
hdfs dfs -rm -r -f "$OUT" >/dev/null 2>&1 || true

hadoop jar "$STREAMING_JAR" \
  -D mapreduce.job.name="yelp_task3_step1_user_stats" \
  -files step1_mapper.py,step1_reducer.py \
  -mapper "python3 step1_mapper.py" \
  -reducer "python3 step1_reducer.py" \
  -input "$REVIEW" \
  -input "$USER" \
  -output "$TMP"

hadoop jar "$STREAMING_JAR" \
  -D mapreduce.job.name="yelp_task3_step2_top10_users" \
  -D mapreduce.job.reduces=1 \
  -files step2_mapper.py,step2_reducer.py \
  -mapper "python3 step2_mapper.py" \
  -reducer "python3 step2_reducer.py" \
  -input "$TMP" \
  -output "$OUT"
SH

chmod +x mapreduce/task3/run3.sh
echo "OK: task3 files created"
