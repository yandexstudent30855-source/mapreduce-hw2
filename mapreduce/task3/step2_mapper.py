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
