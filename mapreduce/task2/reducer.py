#!/usr/bin/env python3
import sys

rows = []
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    bid, h = line.split("\t", 1)
    try:
        hours = float(h)
    except Exception:
        continue
    rows.append((hours, bid))

# hours desc, business_id asc
rows.sort(key=lambda x: (-x[0], x[1]))

for hours, bid in rows[:10]:
    if abs(hours - round(hours)) < 1e-9:
        out_h = str(int(round(hours)))
    else:
        out_h = f"{hours:.2f}".rstrip("0").rstrip(".")
    print(f"{bid}\t{out_h}")
