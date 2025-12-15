#!/usr/bin/env python3
import sys

arr = []
for line in sys.stdin:
    line = line.rstrip("\n")
    if not line:
        continue
    _, uid, s, fr = line.split("\t", 3)
    try:
        s = int(s)
    except Exception:
        s = 0
    try:
        fr = int(fr)
    except Exception:
        fr = 0
    arr.append((uid, s, fr))

arr.sort(key=lambda x: (-x[1], x[0]))

for uid, s, fr in arr[:10]:
    print(f"{uid}\t{s}\t{fr}")
