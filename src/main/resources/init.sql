-- ============================================================
-- 作品管理模块 - 数据库初始化脚本
-- 运行前请先确认 poster_competition 数据库已存在
-- ============================================================

-- 作品表 (如果已存在则跳过创建)
-- 如果 work 表已存在且有旧结构（不含 image_path、category_id），
-- 请先执行：DROP TABLE IF EXISTS work;
-- 然后重新创建
CREATE TABLE IF NOT EXISTS work (
    work_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '作品ID',
    team_id INT NOT NULL COMMENT '队伍ID',
    competition_id INT NOT NULL COMMENT '竞赛ID',
    category_id INT DEFAULT NULL COMMENT '分类ID',
    title VARCHAR(100) NOT NULL COMMENT '作品标题',
    description VARCHAR(500) DEFAULT '' COMMENT '作品描述',
    image_path VARCHAR(255) DEFAULT NULL COMMENT '图片路径（相对路径，如 /uploads/competition_1/team_3_20260705.jpg）',
    status INT DEFAULT 1 COMMENT '状态：1-草稿，2-已提交，3-已评分',
    submit_time DATETIME DEFAULT NULL COMMENT '提交时间',
    update_time DATETIME DEFAULT NULL COMMENT '最后更新时间',
    INDEX idx_team_id (team_id),
    INDEX idx_competition_id (competition_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='作品表';
