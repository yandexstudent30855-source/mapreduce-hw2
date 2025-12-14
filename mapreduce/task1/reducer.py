#!/usr/bin/env python3
import sys

current = None
value = None

for line in sys.stdin:
    line = line.rstrip("\n")
    if not line:
        continue
    k, v = line.split("\t", 1)
    if current is None:
        current, value = k, v
    elif k != current:
        print(f"{current}\t{value}")
        current, value = k, v

if current is not None:
    print(f"{current}\t{value}")
