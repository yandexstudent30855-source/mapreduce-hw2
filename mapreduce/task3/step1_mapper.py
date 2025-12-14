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

    # review record
    if "review_id" in obj and "user_id" in obj and "useful" in obj:
        uid = obj.get("user_id")
        try:
            useful = int(obj.get("useful", 0))
        except Exception:
            useful = 0
        print(f"{uid}\tR\t{useful}")
        continue

    # user record
    if "user_id" in obj and "friends" in obj:
        uid = obj.get("user_id")
        friends = obj.get("friends") or ""
        cnt = 0
        if isinstance(friends, str):
            friends = friends.strip()
            if friends and friends != "None":
                cnt = len([x for x in friends.split(",") if x.strip()])
        elif isinstance(friends, list):
            cnt = len(friends)
        print(f"{uid}\tU\t{cnt}")
