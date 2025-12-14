#!/usr/bin/env bash
set -euo pipefail

OUT="${1:?Usage: ./run.sh <output_folder_in_hdfs>}"
INPUT="/data/yelp/business"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
  -files "$DIR/mapper.py,$DIR/reducer.py" \
  -mapper "python3 mapper.py" \
  -reducer "python3 reducer.py" \
  -input "$INPUT" \
  -output "$OUT"
