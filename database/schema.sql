-- ========================================
-- 大学生海报设计竞赛系统 - 完整数据库脚本
-- 创建时间：2026-07-04
-- 数据库版本：MySQL 8.0
-- 字符集：UTF8MB4
-- 包含：17张数据表完整结构
-- ========================================

-- 设置SQL模式（避免ONLY_FULL_GROUP_BY错误）
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

-- 创建数据库
DROP DATABASE IF EXISTS poster_competition;
CREATE DATABASE poster_competition DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE poster_competition;

-- ========================================
-- 第一部分：用户相关表（3张）
-- ========================================

-- 1. 用户基本信息表
DROP TABLE IF EXISTS user;
CREATE TABLE user (
    user_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(100) NOT NULL COMMENT '密码（加密）',
    real_name VARCHAR(50) NOT NULL COMMENT '真实姓名',
    email VARCHAR(100) NOT NULL COMMENT '邮箱',
    phone VARCHAR(20) DEFAULT NULL COMMENT '手机号',
    status TINYINT DEFAULT 1 COMMENT '状态：1-正常，0-禁用',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户基本信息表';

-- 2. 角色信息表
DROP TABLE IF EXISTS role;
CREATE TABLE role (
    role_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '角色ID',
    role_name VARCHAR(50) NOT NULL COMMENT '角色名称',
    role_desc VARCHAR(200) DEFAULT NULL COMMENT '角色描述',
    INDEX idx_role_name (role_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色信息表';

-- 3. 用户角色关联表
DROP TABLE IF EXISTS user_role;
CREATE TABLE user_role (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '关联ID',
    user_id INT NOT NULL COMMENT '用户ID',
    role_id INT NOT NULL COMMENT '角色ID',
    assign_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '分配时间',
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES role(role_id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_role (user_id, role_id),
    INDEX idx_user_id (user_id),
    INDEX idx_role_id (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户角色关联表';

-- ========================================
-- 第二部分：竞赛相关表（2张）
-- ========================================

-- 4. 竞赛信息表
DROP TABLE IF EXISTS competition;
CREATE TABLE competition (
    competition_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '竞赛ID',
    year INT NOT NULL COMMENT '竞赛年度',
    name VARCHAR(100) NOT NULL COMMENT '竞赛名称',
    theme VARCHAR(200) NOT NULL COMMENT '海报主题',
    description TEXT DEFAULT NULL COMMENT '竞赛简介',
    submit_deadline DATETIME NOT NULL COMMENT '截止时间',
    max_team_size INT DEFAULT 5 COMMENT '人数上限',
    status TINYINT DEFAULT 1 COMMENT '状态：1-报名中，2-进行中，3-已结束，0-已取消',
    creator_id INT NOT NULL COMMENT '创建人ID',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (creator_id) REFERENCES user(user_id),
    INDEX idx_year (year),
    INDEX idx_status (status),
    INDEX idx_creator_id (creator_id),
    INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='竞赛信息表';

-- 5. 竞赛子类表
DROP TABLE IF EXISTS competition_category;
CREATE TABLE competition_category (
    category_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '子类ID',
    competition_id INT NOT NULL COMMENT '竞赛ID',
    category_name VARCHAR(50) NOT NULL COMMENT '子类名称',
    category_desc VARCHAR(200) DEFAULT NULL COMMENT '子类描述',
    FOREIGN KEY (competition_id) REFERENCES competition(competition_id) ON DELETE CASCADE,
    INDEX idx_competition_id (competition_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='竞赛子类表';

-- ========================================
-- 第三部分：队伍相关表（3张）
-- ========================================

-- 6. 队伍信息表
DROP TABLE IF EXISTS team;
CREATE TABLE team (
    team_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '队伍ID',
    team_name VARCHAR(100) NOT NULL COMMENT '队伍名称',
    competition_id INT NOT NULL COMMENT '竞赛ID',
    category_id INT NOT NULL COMMENT '子类ID',
    leader_id INT NOT NULL COMMENT '队长ID',
    team_desc VARCHAR(500) DEFAULT NULL COMMENT '队伍简介',
    status TINYINT DEFAULT 1 COMMENT '状态：1-正常，2-已取消，0-禁用',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (competition_id) REFERENCES competition(competition_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES competition_category(category_id),
    FOREIGN KEY (leader_id) REFERENCES user(user_id),
    INDEX idx_competition_id (competition_id),
    INDEX idx_leader_id (leader_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='队伍信息表';

-- 7. 队伍成员表
DROP TABLE IF EXISTS team_member;
CREATE TABLE team_member (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    team_id INT NOT NULL COMMENT '队伍ID',
    user_id INT NOT NULL COMMENT '成员ID',
    is_leader TINYINT DEFAULT 0 COMMENT '是否队长：1-是，0-否',
    join_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
    FOREIGN KEY (team_id) REFERENCES team(team_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    UNIQUE KEY uk_team_user (team_id, user_id),
    INDEX idx_team_id (team_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='队伍成员表';

-- 8. 邀请记录表
DROP TABLE IF EXISTS invitation;
CREATE TABLE invitation (
    invitation_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '邀请ID',
    team_id INT NOT NULL COMMENT '队伍ID',
    inviter_id INT NOT NULL COMMENT '邀请人ID',
    invitee_id INT NOT NULL COMMENT '被邀请人ID',
    status TINYINT DEFAULT 0 COMMENT '状态：0-待响应，1-已接受，2-已拒绝',
    invite_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '邀请时间',
    response_time DATETIME DEFAULT NULL COMMENT '响应时间',
    FOREIGN KEY (team_id) REFERENCES team(team_id) ON DELETE CASCADE,
    FOREIGN KEY (inviter_id) REFERENCES user(user_id),
    FOREIGN KEY (invitee_id) REFERENCES user(user_id),
    INDEX idx_team_id (team_id),
    INDEX idx_invitee_id (invitee_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='邀请记录表';

-- ========================================
-- 第四部分：作品相关表（2张）
-- ========================================

-- 9. 作品信息表
CREATE TABLE work (
    work_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '作品ID',
    team_id INT NOT NULL COMMENT '队伍ID',
    competition_id INT NOT NULL COMMENT '竞赛ID',
    category_id INT DEFAULT NULL COMMENT '子类ID',
    work_title VARCHAR(200) NOT NULL COMMENT '作品标题',
    work_desc TEXT DEFAULT NULL COMMENT '作品描述',
    image_path VARCHAR(500) DEFAULT NULL COMMENT '海报图片路径',
    file_size INT DEFAULT NULL COMMENT '文件大小（字节）',
    version INT DEFAULT 1 COMMENT '版本号',
    status TINYINT DEFAULT 1 COMMENT '状态：1-草稿，2-已提交，3-已评分',
    submit_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
    update_time DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (team_id) REFERENCES team(team_id) ON DELETE CASCADE,
    FOREIGN KEY (competition_id) REFERENCES competition(competition_id),
    FOREIGN KEY (category_id) REFERENCES competition_category(category_id),
    INDEX idx_team_id (team_id),
    INDEX idx_competition_id (competition_id),
    INDEX idx_category_id (category_id),
    INDEX idx_status (status),
    INDEX idx_submit_time (submit_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='作品信息表';
-- 10. 作品文件表
DROP TABLE IF EXISTS work_file;
CREATE TABLE work_file (
    file_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '文件ID',
    work_id INT NOT NULL COMMENT '作品ID',
    file_name VARCHAR(200) NOT NULL COMMENT '文件名',
    file_path VARCHAR(500) NOT NULL COMMENT '存储路径',
    file_type VARCHAR(50) DEFAULT NULL COMMENT '文件类型',
    upload_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
    FOREIGN KEY (work_id) REFERENCES work(work_id) ON DELETE CASCADE,
    INDEX idx_work_id (work_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='作品文件表';

-- ========================================
-- 第五部分：评分与获奖表（4张）
-- ========================================

-- 11. 评分记录表
DROP TABLE IF EXISTS score;
CREATE TABLE score (
    score_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '评分ID',
    work_id INT NOT NULL COMMENT '作品ID',
    judge_id INT NOT NULL COMMENT '评委ID',
    score DECIMAL(5,2) NOT NULL COMMENT '分数（0-100）',
    score_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '评分时间',
    FOREIGN KEY (work_id) REFERENCES work(work_id) ON DELETE CASCADE,
    FOREIGN KEY (judge_id) REFERENCES user(user_id),
    UNIQUE KEY uk_work_judge (work_id, judge_id),
    INDEX idx_work_id (work_id),
    INDEX idx_judge_id (judge_id),
    CHECK (score >= 0 AND score <= 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评分记录表';

-- 12. 评语表
DROP TABLE IF EXISTS comment;
CREATE TABLE comment (
    comment_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '评语ID',
    work_id INT NOT NULL COMMENT '作品ID',
    judge_id INT NOT NULL COMMENT '评委ID',
    comment_text TEXT NOT NULL COMMENT '评语内容',
    comment_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '评语时间',
    FOREIGN KEY (work_id) REFERENCES work(work_id) ON DELETE CASCADE,
    FOREIGN KEY (judge_id) REFERENCES user(user_id),
    INDEX idx_work_id (work_id),
    INDEX idx_judge_id (judge_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评语表';

-- 13. 获奖信息表
DROP TABLE IF EXISTS award;
CREATE TABLE award (
    award_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '获奖ID',
    work_id INT NOT NULL COMMENT '作品ID',
    competition_id INT NOT NULL COMMENT '竞赛ID',
    award_level VARCHAR(50) NOT NULL COMMENT '获奖等级：一等奖、二等奖、三等奖',
    final_score DECIMAL(5,2) NOT NULL COMMENT '最终得分',
    award_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '获奖时间',
    issuer_id INT NOT NULL COMMENT '颁发人ID',
    FOREIGN KEY (work_id) REFERENCES work(work_id) ON DELETE CASCADE,
    FOREIGN KEY (competition_id) REFERENCES competition(competition_id),
    FOREIGN KEY (issuer_id) REFERENCES user(user_id),
    INDEX idx_work_id (work_id),
    INDEX idx_competition_id (competition_id),
    INDEX idx_award_level (award_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='获奖信息表';

-- 14. 奖状信息表
DROP TABLE IF EXISTS certificate;
CREATE TABLE certificate (
    certificate_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '奖状ID',
    award_id INT NOT NULL COMMENT '获奖ID',
    certificate_no VARCHAR(100) NOT NULL UNIQUE COMMENT '奖状编号',
    file_path VARCHAR(500) NOT NULL COMMENT '奖状文件路径',
    generate_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '生成时间',
    FOREIGN KEY (award_id) REFERENCES award(award_id) ON DELETE CASCADE,
    INDEX idx_award_id (award_id),
    INDEX idx_certificate_no (certificate_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='奖状信息表';

-- ========================================
-- 第六部分：互动与新闻表（3张）
-- ========================================

-- 15. 新闻公告表
DROP TABLE IF EXISTS news;
CREATE TABLE news (
    news_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '新闻ID',
    title VARCHAR(200) NOT NULL COMMENT '新闻标题',
    content TEXT NOT NULL COMMENT '新闻内容',
    competition_id INT DEFAULT NULL COMMENT '竞赛ID（可选）',
    author_id INT NOT NULL COMMENT '发布者ID',
    status TINYINT DEFAULT 1 COMMENT '状态：1-已发布，0-已撤回',
    publish_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
    FOREIGN KEY (competition_id) REFERENCES competition(competition_id) ON DELETE SET NULL,
    FOREIGN KEY (author_id) REFERENCES user(user_id),
    INDEX idx_competition_id (competition_id),
    INDEX idx_author_id (author_id),
    INDEX idx_status (status),
    INDEX idx_publish_time (publish_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='新闻公告表';

-- 16. 作品点赞表
DROP TABLE IF EXISTS work_like;
CREATE TABLE work_like (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    work_id INT NOT NULL COMMENT '作品ID',
    user_id INT NOT NULL COMMENT '用户ID',
    like_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
    FOREIGN KEY (work_id) REFERENCES work(work_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    UNIQUE KEY uk_work_user (work_id, user_id),
    INDEX idx_work_id (work_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='作品点赞表';

-- 17. 作品分享表
DROP TABLE IF EXISTS work_share;
CREATE TABLE work_share (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    work_id INT NOT NULL COMMENT '作品ID',
    user_id INT NOT NULL COMMENT '用户ID',
    share_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '分享时间',
    FOREIGN KEY (work_id) REFERENCES work(work_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    INDEX idx_work_id (work_id),
    INDEX idx_user_id (user_id),
    INDEX idx_share_time (share_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='作品分享表';

-- ========================================
-- 数据库结构创建完成
-- 共17张表，涵盖用户、竞赛、队伍、作品、评分、获奖、互动等功能
-- ========================================
