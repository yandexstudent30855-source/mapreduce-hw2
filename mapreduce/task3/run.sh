#!/usr/bin/env bash
set -euo pipefail

OUT="${1:?Usage: ./run.sh <output_folder>}"
REVIEW_PATH="/data/yelp/review"
USER_PATH="/data/yelp/user"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP="/tmp/$(whoami)_yelp_task3_tmp"

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
  -D mapreduce.job.name="yelp_task3_step1" \
  -files "$DIR/step1_mapper.py,$DIR/step1_reducer.py" \
  -mapper "python3 step1_mapper.py" \
  -reducer "python3 step1_reducer.py" \
  -input "$REVIEW_PATH" \
  -input "$USER_PATH" \
  -output "$TMP"

hadoop jar "$STREAMING_JAR" \
  -D mapreduce.job.name="yelp_task3_step2_top10" \
  -D mapreduce.job.reduces=1 \
  -files "$DIR/step2_mapper.py,$DIR/step2_reducer.py" \
  -mapper "python3 step2_mapper.py" \
  -reducer "python3 step2_reducer.py" \
  -input "$TMP" \
  -output "$OUT"
