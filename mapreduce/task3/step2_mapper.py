#!/usr/bin/env python3
import sys

for line in sys.stdin:
    line = line.rstrip("\n")
    if not line:
        continue
    parts = line.split("\t")
    if len(parts) != 3:
        continue
    uid, s, fr = parts
    try:
        s = int(float(s))
    except Exception:
        s = 0
    try:
        fr = int(float(fr))
    except Exception:
        fr = 0
    print(f"K\t{uid}\t{s}\t{fr}")
