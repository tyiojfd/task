-- =============================================
-- 作品管理模块 - 数据库迁移脚本
-- 为 work 表添加必要字段
-- =============================================

USE poster_competition;

-- 添加 competition_id 字段（关联竞赛）
ALTER TABLE work ADD COLUMN competition_id INT NOT NULL AFTER team_id,
    ADD INDEX idx_competition_id (competition_id);
ALTER TABLE work ADD CONSTRAINT fk_work_competition FOREIGN KEY (competition_id) REFERENCES competition(competition_id);

-- 添加 image_path 字段（存储海报图片路径）
ALTER TABLE work ADD COLUMN image_path VARCHAR(500) DEFAULT NULL AFTER work_desc;

-- 添加 update_time 字段（最后更新时间）
ALTER TABLE work ADD COLUMN update_time DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP AFTER submit_time;

-- 添加 category_id 字段（关联子类，可选）
ALTER TABLE work ADD COLUMN category_id INT DEFAULT NULL AFTER competition_id,
    ADD INDEX idx_category_id (category_id);
ALTER TABLE work ADD CONSTRAINT fk_work_category FOREIGN KEY (category_id) REFERENCES competition_category(category_id);

-- 修改 status 注释以匹配系统定义
ALTER TABLE work MODIFY COLUMN status TINYINT DEFAULT 1 COMMENT '状态：1-草稿，2-已提交，3-已评分';

-- 确认修改结果
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'poster_competition' AND TABLE_NAME = 'work'
ORDER BY ORDINAL_POSITION;

-- =============================================
-- 更新竞赛截止时间
-- =============================================
-- 将所有截止时间为 2026-07-06 10:10 的竞赛改为 2026-07-20 10:00
UPDATE competition SET submit_deadline = '2026-07-20 10:00:00'
WHERE submit_deadline = '2026-07-06 10:10:00';

-- 如果不存在竞赛数据，插入一条测试竞赛（如需使用）
-- INSERT INTO competition (year, name, theme, description, submit_deadline, max_team_size, status, creator_id)
-- VALUES (2026, '第1届海报设计大赛', '青春·梦想', '展现大学生青春风采', '2026-07-20 10:00:00', 5, 1, 1);
