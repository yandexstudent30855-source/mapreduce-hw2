#!/usr/bin/env bash
set -euo pipefail

OUT="${1:?Usage: ./run3.sh <output_folder_in_hdfs>}"
REVIEW_PATH="/data/yelp/review"
USER_PATH="/data/yelp/user"

USERNAME="$(whoami)"
TMP="/user/${USERNAME}/yelp_task3_tmp"

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
  -input "$REVIEW_PATH" \
  -input "$USER_PATH" \
  -output "$TMP"

hadoop jar "$STREAMING_JAR" \
  -D mapreduce.job.name="yelp_task3_step2_top10_users" \
  -D mapreduce.job.reduces=1 \
  -files step2_mapper.py,step2_reducer.py \
  -mapper "python3 step2_mapper.py" \
  -reducer "python3 step2_reducer.py" \
  -input "$TMP" \
  -output "$OUT"
