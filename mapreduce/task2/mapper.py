#!/usr/bin/env python3
import sys, json

DAYS = ("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")

def to_minutes(s: str) -> int:
    h, m = s.split(":")
    return int(h) * 60 + int(m)

def interval_minutes(s: str) -> int:
    start, end = s.split("-")
    if start == "0:0" and end == "0:0":
        return 0
    a = to_minutes(start)
    b = to_minutes(end)
    if b < a:
        b += 24 * 60
    return max(0, b - a)

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        obj = json.loads(line)
    except Exception:
        continue

    bid = obj.get("business_id")
    if not bid:
        continue

    if obj.get("is_open", 1) == 0:
        total = 0
    else:
        hours = obj.get("hours") or {}
        total = 0
        for d in DAYS:
            s = hours.get(d)
            if s:
                total += interval_minutes(s)

    print(f"{bid}\t{total}")
