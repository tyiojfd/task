-- =============================================
-- 作品管理模块 - 数据库迁移脚本（更新版）
-- 为 work 表添加必要字段，修复 file_path 不匹配问题
-- =============================================

USE poster_competition;

-- =============================================
-- 第一步：处理原有 file_path 列（代码中改用 image_path）
-- 原 file_path 为 NOT NULL 且未被 INSERT 引用，会导致插入失败
-- =============================================
-- 将原有的 file_path 改为可空，因为已被 image_path 替代
ALTER TABLE work MODIFY COLUMN file_path VARCHAR(500) DEFAULT NULL COMMENT '文件路径（已弃用，改用image_path）';

-- =============================================
-- 第二步：添加缺失的字段（兼容已运行过V2的情况）
-- =============================================

-- 添加 competition_id 字段
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'poster_competition' AND TABLE_NAME = 'work' AND COLUMN_NAME = 'competition_id');
SET @sql_add_competition_id = 'ALTER TABLE work ADD COLUMN competition_id INT NOT NULL AFTER team_id, ADD INDEX idx_competition_id (competition_id)';
SET @sql_add_fk_competition = 'ALTER TABLE work ADD CONSTRAINT fk_work_competition FOREIGN KEY (competition_id) REFERENCES competition(competition_id)';
SELECT IF(@col_exists = 0, @sql_add_competition_id, 'SELECT 1') INTO @stmt1;
PREPARE stmt1 FROM @stmt1; EXECUTE stmt1; DEALLOCATE PREPARE stmt1;

-- 添加 image_path 字段
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'poster_competition' AND TABLE_NAME = 'work' AND COLUMN_NAME = 'image_path');
SET @sql_add_image_path = "ALTER TABLE work ADD COLUMN image_path VARCHAR(500) DEFAULT NULL COMMENT '海报图片路径' AFTER work_desc";
SELECT IF(@col_exists = 0, @sql_add_image_path, 'SELECT 1') INTO @stmt2;
PREPARE stmt2 FROM @stmt2; EXECUTE stmt2; DEALLOCATE PREPARE stmt2;

-- 添加 category_id 字段
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'poster_competition' AND TABLE_NAME = 'work' AND COLUMN_NAME = 'category_id');
SET @sql_add_category_id = "ALTER TABLE work ADD COLUMN category_id INT DEFAULT NULL COMMENT '子类ID' AFTER competition_id, ADD INDEX idx_category_id (category_id)";
SELECT IF(@col_exists = 0, @sql_add_category_id, 'SELECT 1') INTO @stmt3;
PREPARE stmt3 FROM @stmt3; EXECUTE stmt3; DEALLOCATE PREPARE stmt3;

-- 添加 category_id 外键约束
SET @fk_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA = 'poster_competition' AND TABLE_NAME = 'work' AND CONSTRAINT_NAME = 'fk_work_category');
SET @sql_add_fk_category = 'ALTER TABLE work ADD CONSTRAINT fk_work_category FOREIGN KEY (category_id) REFERENCES competition_category(category_id)';
SELECT IF(@fk_exists = 0, @sql_add_fk_category, 'SELECT 1') INTO @stmt4;
PREPARE stmt4 FROM @stmt4; EXECUTE stmt4; DEALLOCATE PREPARE stmt4;

-- 添加 update_time 字段
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'poster_competition' AND TABLE_NAME = 'work' AND COLUMN_NAME = 'update_time');
SET @sql_add_update_time = "ALTER TABLE work ADD COLUMN update_time DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间' AFTER submit_time";
SELECT IF(@col_exists = 0, @sql_add_update_time, 'SELECT 1') INTO @stmt5;
PREPARE stmt5 FROM @stmt5; EXECUTE stmt5; DEALLOCATE PREPARE stmt5;

-- 修改 status 注释
ALTER TABLE work MODIFY COLUMN status TINYINT DEFAULT 1 COMMENT '状态：1-草稿，2-已提交，3-已评分';

-- =============================================
-- 第三步：确认修改结果
-- =============================================
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'poster_competition' AND TABLE_NAME = 'work'
ORDER BY ORDINAL_POSITION;

-- =============================================
-- 第四步：更新竞赛截止时间（确保测试数据可用）
-- =============================================
UPDATE competition SET submit_deadline = '2026-07-20 10:00:00'
WHERE submit_deadline = '2026-07-06 10:10:00';
