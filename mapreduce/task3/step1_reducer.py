#!/usr/bin/env python3
import sys

cur = None
usefuls = []
friends = 0

def flush(u, vals, fr):
    vals.sort(reverse=True)
    s = sum(vals[:5])
    print(f"{u}\t{s}\t{fr}")

for line in sys.stdin:
    line = line.rstrip("\n")
    if not line:
        continue
    uid, tag, val = line.split("\t", 2)

    if cur is None:
        cur = uid

    if uid != cur:
        flush(cur, usefuls, friends)
        cur = uid
        usefuls = []
        friends = 0

    if tag == "R":
        try:
            usefuls.append(int(val))
        except Exception:
            usefuls.append(0)
    elif tag == "U":
        try:
            friends = int(val)
        except Exception:
            friends = 0

if cur is not None:
    flush(cur, usefuls, friends)
