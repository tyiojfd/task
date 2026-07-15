#!/usr/bin/env python3
"""Demo data: users, competitions, teams (no works/scores/awards — those are manual)."""

import hashlib, random, os
from datetime import datetime

random.seed(42)
SALT = "poster_competition_2026"
PWD  = hashlib.md5(("123456" + SALT).encode()).hexdigest()

SURNAMES = "王李张刘陈杨赵黄周吴徐孙胡朱高林何郭马罗梁宋郑谢韩唐冯于董萧程曹袁邓许傅沈曾彭吕苏卢蒋蔡贾丁魏薛叶阎余潘杜戴夏钟汪田任姜范方石姚谭廖邹熊金陆郝孔白崔康毛邱秦江史顾侯邵孟龙万段雷钱汤尹易常武乔贺赖龚文"
MALE   = ["伟","强","磊","涛","斌","勇","军","杰","鹏","浩","明","宇","飞","洋","亮","超","平","刚","健","辉","毅","俊","峰","波","宁","龙","威","旭","凯","博","睿","晨","铭","宇轩","子涵","浩然","天佑","思远","逸飞","云飞","志强","文博","明哲","俊杰","嘉禾","家乐","景辉"]
FEMALE = ["芳","敏","静","丽","婷","雪","琳","娜","娟","霞","秀英","桂英","美玲","秀兰","玉兰","晓红","雪梅","海燕","海霞","梦瑶","诗涵","欣怡","雨桐","若曦","艺琳","语嫣","梓涵","思颖","雪婷","晓萌","雨萱","雅静"]
NAMES  = [random.choice(SURNAMES) + random.choice(MALE + FEMALE) for _ in range(600)]

JUDGES = ["陈丹青","刘小东","张晓刚","方力钧","岳敏君","徐冰","蔡国强","曾梵志","王广义","周春芽","冷军","何多苓"]

COMPLETED = [
    ("第6届创意无限海报设计大赛","青春飞扬","以青春活力为主题，展现当代大学生朝气蓬勃的精神风貌",32),  # big
    ("第6届设计之星海报设计大赛","科技强国","聚焦科技创新，用设计语言描绘科技改变生活",1),
    ("第6届视觉盛宴海报设计大赛","绿色家园","倡导绿色环保理念，表现人与自然和谐共生",1),
    ("第6届灵感碰撞海报设计大赛","文化传承","弘扬中华优秀传统文化，展现非遗与现代设计融合",1),
    ("第6届美学探索海报设计大赛","梦想启航","描绘青春梦想，激励大学生勇敢追逐人生理想",1),
    ("第6届意境之美海报设计大赛","城市印记","记录城市变迁，展现城市发展与人文情怀的交织",1),
    ("第6届新锐力量海报设计大赛","书香致远","以阅读与知识为灵感，设计书香校园主题海报",1),
    ("第6届色彩革命海报设计大赛","匠心独运","致敬工匠精神，用创意海报展现精益求精",1),
    ("第6届设计力场海报设计大赛","未来已来","探索人工智能与未来科技，畅想智慧生活",1),
    ("第6届灵感之光海报设计大赛","乡村振兴","关注乡村发展，用设计的力量为美丽乡村代言",1),
    ("第6届创意先锋海报设计大赛","体育精神","弘扬拼搏进取的体育精神，展现竞技之美",1),
    ("第6届艺术新声海报设计大赛","一带一路","以丝路文化为背景，展现文明互鉴与美好合作",1),
]

ONGOING = [
    ("2026梦想绘卷海报设计大赛","百年风华","庆祝建党百年，展现时代变迁与辉煌成就",12),   # big
    ("2026视界无边海报设计大赛","反诈先锋","以校园反诈为主题，提升大学生安全防范意识",1),
    ("2026设计浪潮海报设计大赛","心理健康","关注大学生心理健康，传递积极向上",1),
    ("2026青春画卷海报设计大赛","数字生活","展现数字经济时代大学生的新生活方式",1),
    ("2026创意集市海报设计大赛","海洋保护","关注海洋生态保护，唤醒公众环保意识",1),
    ("2026美学之约海报设计大赛","志愿同行","以志愿服务为主题，弘扬奉献友爱互助进步精神",1),
]

TEAM_NAMES = ["破晓","星辰","极光","逐梦","凌云","曙光","烈焰","墨韵","光影","拾光","青橙","像素","创视","视界","绘梦","笔尖","灵感","火花","锋芒","匠心","远航","锐意","先锋","启明","共鸣","丹青","千寻","万象","无界","新生","华彩","意象","蔚蓝","炽热","流萤","踏浪","奔雷","追风","揽月","织梦","拾色","观澜"]

OUT = []
def w(s): OUT.append(s + "\n")
def q(v):
    if v is None: return "NULL"
    return "'" + str(v).replace("\\","\\\\").replace("'","\\'") + "'"

used_names = set()
_name_pool = list(NAMES)
def fresh_name():
    if _name_pool:
        n = _name_pool.pop()
    else:
        # generate on the fly when pool exhausted
        while True:
            n = random.choice(SURNAMES) + random.choice(MALE + FEMALE)
            if n not in used_names: break
    used_names.add(n)
    return n

# ═══════════════════════════════════════════════
w("USE poster_competition;")
w("")
w("-- Roles")
w("INSERT INTO role (role_id, role_name, role_desc) VALUES (1,'管理员','系统管理员');")
w("INSERT INTO role (role_id, role_name, role_desc) VALUES (2,'评委','竞赛评委');")
w("INSERT INTO role (role_id, role_name, role_desc) VALUES (3,'队员','参赛队员');")
w("INSERT INTO role (role_id, role_name, role_desc) VALUES (4,'队长','参赛队长');")
w("")

# Admin
uid = 1
w(f"-- Admin (id=1)")
w(f"INSERT INTO user (user_id,username,password,real_name,email,phone,status) VALUES (1,'admin',{q(PWD)},'系统管理员','admin@poster.cn','13800000001',1);")
w("INSERT INTO user_role (user_id,role_id) VALUES (1,1);")
w("")

# Judges (2-13)
uid = 2
w("-- Judges (12)")
for name in JUDGES:
    w(f"INSERT INTO user (user_id,username,password,real_name,email,phone,status) VALUES ({uid},'judge{uid-1}',{q(PWD)},{q(name)},'judge{uid-1}@poster.cn','139{uid:07d}',1);")
    w(f"INSERT INTO user_role (user_id,role_id) VALUES ({uid},2);")
    uid += 1
w("")

# ── Helpers ───────────────────────────────────
tid = 1  # team id
cid = 1  # competition id

def make_team(comp_id, cat_id):
    global uid, tid
    count = random.randint(3, 5)
    leader = uid
    members = []
    for _ in range(count):
        name = fresh_name()
        w(f"INSERT INTO user (user_id,username,password,real_name,email,phone,status) VALUES ({uid},'player{uid}',{q(PWD)},{q(name)},'player{uid}@poster.cn','138{uid:08d}',1);")
        w(f"INSERT INTO user_role (user_id,role_id) VALUES ({uid},3);")
        w(f"INSERT INTO user_role (user_id,role_id) VALUES ({uid},4);")
        members.append(uid)
        uid += 1

    tname = TEAM_NAMES[tid % len(TEAM_NAMES)] + TEAM_NAMES[(tid+5) % len(TEAM_NAMES)]
    tname += random.choice(["队","组","团","工作室","设计局","工坊"])

    month = random.randint(1, 6)
    day   = random.randint(1, 28)
    w(f"INSERT INTO team (team_id,team_name,competition_id,category_id,leader_id,team_desc,status,create_time) VALUES ({tid},{q(tname)},{comp_id},{cat_id},{leader},{q('一支充满创意与激情的设计团队')},2,'2026-{month:02d}-{day:02d} 10:00:00');")

    for i, muid in enumerate(members):
        w(f"INSERT INTO team_member (team_id,user_id,is_leader,join_time) VALUES ({tid},{muid},{1 if muid == leader else 0},'2026-{month:02d}-{day:02d} 10:00:00');")

    tid += 1
    return tid - 1

# ═══════════════════════════════════════════════
# All competitions (status=1 报名中)
# ═══════════════════════════════════════════════
w("-- === All competitions (status=1, 报名中) ===")
for comp_name, theme, desc, tcount in COMPLETED + ONGOING:
    year = 2025 if "第6届" in comp_name else 2026
    w(f"-- {comp_name}  ({tcount} teams)")
    dl_month = random.randint(9, 12)
    w(f"INSERT INTO competition (competition_id,year,name,theme,description,submit_deadline,max_team_size,status,creator_id,create_time) VALUES ({cid},{year},{q(comp_name)},{q(theme+'——'+desc)},{q(desc)},'2026-{dl_month:02d}-15 23:59:59',5,1,1,'2026-07-14 10:00:00');")
    cat1 = cid * 2 - 1
    cat2 = cid * 2
    w(f"INSERT INTO competition_category (category_id,competition_id,category_name,category_desc) VALUES ({cat1},{cid},'平面海报','以平面设计为主的海报作品');")
    w(f"INSERT INTO competition_category (category_id,competition_id,category_name,category_desc) VALUES ({cat2},{cid},'数字插画','以数字绘画为主的插画作品');")
    for _ in range(tcount):
        make_team(cid, cat1 if random.random() < 0.5 else cat2)
    cid += 1
    w("")

w("-- Works, scores, comments, awards: submitted manually via the app.")

# === Write ===
path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "demo_data.sql")
with open(path, "w", encoding="utf-8") as f:
    f.write("".join(OUT))
print(f"Done → {path}")
print(f"Users: {uid-1}  |  Teams: {tid-1}  |  Competitions: {cid-1}")
