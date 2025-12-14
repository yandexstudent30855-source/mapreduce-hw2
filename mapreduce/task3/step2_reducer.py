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
