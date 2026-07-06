-- =============================================
-- 完整初始化脚本（清理+导入）
-- 大学生海报设计竞赛系统
-- =============================================

USE poster_competition;

-- 步骤1：清理所有数据（注意顺序）
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE user_role;
TRUNCATE TABLE user;
TRUNCATE TABLE role;
SET FOREIGN_KEY_CHECKS = 1;

-- 步骤2：插入角色数据
INSERT INTO role (role_name, role_desc) VALUES
('管理员', '系统管理员，可以发布竞赛、设置获奖、发布新闻、查看统计数据'),
('评委', '竞赛评委，可以查看作品、评分、添加评语'),
('队长', '队伍队长，可以创建队伍、邀请队员、提交作品、查看奖状'),
('队员', '队伍成员，可以接受邀请、查看作品、点赞分享');

-- 步骤3：插入用户数据
INSERT INTO user (username, password, real_name, email, phone, status) VALUES
('admin', '60c35b0dc3b79db1939e6a89b6d44d4e', '系统管理员', 'admin@poster.com', '13800000000', 1),
('judge01', '6280bb198be5fc4fd75283ed1bd2d824', '评委张三', 'judge01@poster.com', '13800000001', 1),
('leader01', '6280bb198be5fc4fd75283ed1bd2d824', '队长李四', 'leader01@poster.com', '13800000002', 1),
('member01', '6280bb198be5fc4fd75283ed1bd2d824', '队员王五', 'member01@poster.com', '13800000003', 1);

-- 步骤4：关联用户角色（使用动态查询）
INSERT INTO user_role (user_id, role_id)
SELECT u.user_id, r.role_id
FROM user u, role r
WHERE u.username = 'admin' AND r.role_name = '管理员';

INSERT INTO user_role (user_id, role_id)
SELECT u.user_id, r.role_id
FROM user u, role r
WHERE u.username = 'judge01' AND r.role_name = '评委';

INSERT INTO user_role (user_id, role_id)
SELECT u.user_id, r.role_id
FROM user u, role r
WHERE u.username = 'leader01' AND r.role_name = '队长';

INSERT INTO user_role (user_id, role_id)
SELECT u.user_id, r.role_id
FROM user u, role r
WHERE u.username = 'member01' AND r.role_name = '队员';

-- 步骤5：插入竞赛数据
INSERT INTO competition (year, name, theme, description, submit_deadline, max_team_size, status, creator_id) VALUES
(2026, '全国大学生海报设计大赛', '绿色地球', '以"绿色地球"为主题，征集环保主题海报设计作品', '2026-12-31 23:59:59', 5, 1,
 (SELECT user_id FROM user WHERE username = 'admin'));

-- 步骤6：插入竞赛子类数据
INSERT INTO competition_category (competition_id, category_name, category_desc) VALUES
((SELECT competition_id FROM competition WHERE name = '全国大学生海报设计大赛'), '海报设计类', '传统海报设计，包括公益海报、商业海报等'),
((SELECT competition_id FROM competition WHERE name = '全国大学生海报设计大赛'), '插画设计类', '原创插画设计，包括手绘插画、数字插画等'),
((SELECT competition_id FROM competition WHERE name = '全国大学生海报设计大赛'), '数字艺术类', '数字媒体艺术，包括动态海报、交互设计等');

-- 验证数据
SELECT '=== 角色数据 ===' as '';
SELECT * FROM role;

SELECT '=== 用户数据 ===' as '';
SELECT user_id, username, real_name, email FROM user;

SELECT '=== 用户角色关联 ===' as '';
SELECT ur.id, u.username, r.role_name
FROM user_role ur
JOIN user u ON ur.user_id = u.user_id
JOIN role r ON ur.role_id = r.role_id;

SELECT '=== 竞赛数据 ===' as '';
SELECT competition_id, name, theme, status FROM competition;

SELECT '=== 竞赛子类数据 ===' as '';
SELECT * FROM competition_category;

-- =============================================
-- 初始账号信息
-- =============================================
-- 管理员：admin / admin123
-- 评委：judge01 / 123456
-- 队长：leader01 / 123456
-- 队员：member01 / 123456
-- =============================================
