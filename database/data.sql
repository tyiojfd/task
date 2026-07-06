-- =============================================
-- 初始数据脚本
-- 大学生海报设计竞赛系统
-- 创建时间：2026-07-05
-- =============================================

USE poster_competition;

-- 1. 插入角色数据
INSERT INTO role (role_name, role_desc) VALUES
('管理员', '系统管理员，可以发布竞赛、设置获奖、发布新闻、查看统计数据'),
('评委', '竞赛评委，可以查看作品、评分、添加评语'),
('队长', '队伍队长，可以创建队伍、邀请队员、提交作品、查看奖状'),
('队员', '队伍成员，可以接受邀请、查看作品、点赞分享');

-- 2. 插入管理员用户（密码：admin123）
-- 注意：密码使用MD5+盐值加密，实际密码为 admin123
INSERT INTO user (username, password, real_name, email, phone, status) VALUES
('admin', '60c35b0dc3b79db1939e6a89b6d44d4e', '系统管理员', 'admin@poster.com', '13800000000', 1);

-- 3. 插入测试用户（密码：123456）
INSERT INTO user (username, password, real_name, email, phone, status) VALUES
('judge01', '6280bb198be5fc4fd75283ed1bd2d824', '评委张三', 'judge01@poster.com', '13800000001', 1),
('leader01', '6280bb198be5fc4fd75283ed1bd2d824', '队长李四', 'leader01@poster.com', '13800000002', 1),
('member01', '6280bb198be5fc4fd75283ed1bd2d824', '队员王五', 'member01@poster.com', '13800000003', 1);

-- 4. 关联用户角色
-- 管理员角色
INSERT INTO user_role (user_id, role_id)
SELECT user_id, 1 FROM user WHERE username = 'admin';

-- 评委角色
INSERT INTO user_role (user_id, role_id)
SELECT user_id, 2 FROM user WHERE username = 'judge01';

-- 队长角色
INSERT INTO user_role (user_id, role_id)
SELECT user_id, 3 FROM user WHERE username = 'leader01';

-- 队员角色
INSERT INTO user_role (user_id, role_id)
SELECT user_id, 4 FROM user WHERE username = 'member01';

-- 5. 插入竞赛数据
INSERT INTO competition (year, name, theme, description, submit_deadline, max_team_size, status, creator_id) VALUES
(2026, '全国大学生海报设计大赛', '绿色地球', '以"绿色地球"为主题，征集环保主题海报设计作品', '2026-12-31 23:59:59', 5, 1,
 (SELECT user_id FROM user WHERE username = 'admin'));

-- 6. 插入竞赛子类数据
INSERT INTO competition_category (competition_id, category_name, category_desc) VALUES
((SELECT competition_id FROM competition WHERE name = '全国大学生海报设计大赛'), '海报设计类', '传统海报设计，包括公益海报、商业海报等'),
((SELECT competition_id FROM competition WHERE name = '全国大学生海报设计大赛'), '插画设计类', '原创插画设计，包括手绘插画、数字插画等'),
((SELECT competition_id FROM competition WHERE name = '全国大学生海报设计大赛'), '数字艺术类', '数字媒体艺术，包括动态海报、交互设计等');

-- =============================================
-- 初始账号信息
-- =============================================
-- 管理员账号：
--   用户名：admin
--   密码：admin123
--
-- 评委账号：
--   用户名：judge01
--   密码：123456
--
-- 队长账号：
--   用户名：leader01
--   密码：123456
--
-- 队员账号：
--   用户名：member01
--   密码：123456
-- =============================================
