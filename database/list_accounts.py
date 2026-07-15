import re, os

os.chdir(os.path.dirname(os.path.abspath(__file__)))
with open("demo_data.sql", encoding="utf-8") as f:
    sql = f.read()

lines = []
lines.append("=== 管理员 ===")
lines.append("admin / 123456")
lines.append("")

lines.append("=== 12位评委 (密码: 123456) ===")
for m in re.finditer(r"INSERT INTO user.*?VALUES \((\d+),'(judge\d+)','[^']+','([^']+)'", sql):
    uid, uname, name = m.groups()
    lines.append(f"  judge{int(uid)-1:<6} {name}")

lines.append("")
lines.append("=== 队长账号（密码: 123456）===")
teams = re.findall(r"INSERT INTO team.*?VALUES \((\d+),'([^']+)',(\d+),\d+,(\d+)", sql)
for tid, tname, cid, lid in teams:
    m = re.search(rf"INSERT INTO user.*?VALUES \([^,]+, *'player{lid}','[^']+','([^']+)'", sql)
    name = m.group(1) if m else "?"
    lines.append(f"  player{lid:<6} {name:<6}  队伍: {tname}  (竞赛#{cid})")

lines.append("")
lines.append("=== 大赛（竞赛#1, 32队）全部队员（密码: 123456）===")
team1 = re.findall(r"INSERT INTO team_member.*?VALUES \(\d+,1,(\d+),", sql)
for uid in team1:
    m = re.search(rf"INSERT INTO user.*?VALUES \([^,]+, *'player{uid}','[^']+','([^']+)'", sql)
    name = m.group(1) if m else "?"
    lines.append(f"  player{uid:<6} {name}")

with open("accounts.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(lines))
print("Written to accounts.txt")
