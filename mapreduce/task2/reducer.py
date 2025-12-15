#!/usr/bin/env python3
import sys

arr = []
for line in sys.stdin:
    line = line.rstrip("\n")
    if not line:
        continue
    bid, m = line.split("\t", 1)
    try:
        m = int(float(m))
    except Exception:
        m = 0
    arr.append((bid, m))

arr.sort(key=lambda x: (-x[1], x[0]))

for bid, m in arr[:10]:
    print(f"{bid}\t{m}")
