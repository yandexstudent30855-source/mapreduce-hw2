#!/usr/bin/env python3
import sys, json

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        obj = json.loads(line)
    except Exception:
        continue

    uid = obj.get("user_id")
    if not uid:
        continue

    if "review_id" in obj:
        useful = obj.get("useful", 0)
        try:
            useful = int(useful)
        except Exception:
            useful = 0
        print(f"{uid}\tR\t{useful}")
    else:
        friends = obj.get("friends") or ""
        if friends == "None" or friends.strip() == "":
            cnt = 0
        else:
            cnt = len([x for x in friends.split(",") if x.strip()])
        print(f"{uid}\tU\t{cnt}")
