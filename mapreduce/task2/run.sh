#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -eq 1 ]]; then
  IN="/user/${USER}/yelp_task1_out"
  OUT="$1"
elif [[ $# -ge 2 ]]; then
  IN="$1"
  OUT="$2"
else
  echo "Usage: ./run.sh <task2_output_folder_in_hdfs>  OR  ./run.sh <task1_output_folder_in_hdfs> <task2_output_folder_in_hdfs>" >&2
  exit 1
fi

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
  -files "$DIR/mapper.py,$DIR/reducer.py" \
  -mapper "python3 mapper.py" \
  -reducer "python3 reducer.py" \
  -input "$IN" \
  -output "$OUT"
