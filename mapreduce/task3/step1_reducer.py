#!/usr/bin/env python3
import sys, heapq

def flush(uid, heap5, friends_cnt):
    print(f"{uid}\t{sum(heap5)}\t{friends_cnt}")

cur = None
friends_cnt = 0
heap5 = []

for line in sys.stdin:
    line = line.rstrip("\n")
    if not line:
        continue
    uid, tag, val = line.split("\t", 2)

    if cur is None:
        cur = uid

    if uid != cur:
        flush(cur, heap5, friends_cnt)
        cur = uid
        friends_cnt = 0
        heap5 = []

    if tag == "U":
        try:
            friends_cnt = int(val)
        except Exception:
            friends_cnt = 0
    elif tag == "R":
        try:
            useful = int(val)
        except Exception:
            useful = 0
        if len(heap5) < 5:
            heapq.heappush(heap5, useful)
        else:
            if useful > heap5[0]:
                heapq.heapreplace(heap5, useful)

if cur is not None:
    flush(cur, heap5, friends_cnt)
