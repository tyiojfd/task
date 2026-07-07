-- =============================================
-- 作品管理模块 - 数据库迁移脚本（更新版）
-- 用途：仅用于已经执行旧版 schema.sql 的数据库升级。
-- 全新初始化请直接执行 database/schema.sql，再执行 database/data.sql。
-- =============================================

USE poster_competition;

-- =============================================
-- 第一步：处理原有 file_path 列（代码中改用 image_path）
-- 原 file_path 为 NOT NULL 且未被 WorkDAOImpl.insert 引用，会导致插入失败；
-- 若旧库已按更新版 schema 创建且不存在 file_path，则补一个可空兼容字段。
-- =============================================
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'work' AND COLUMN_NAME = 'file_path'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE work ADD COLUMN file_path VARCHAR(500) DEFAULT NULL COMMENT ''文件路径（兼容旧版字段，作品主图使用image_path）'' AFTER image_path',
    'ALTER TABLE work MODIFY COLUMN file_path VARCHAR(500) DEFAULT NULL COMMENT ''文件路径（兼容旧版字段，作品主图使用image_path）''');
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =============================================
-- 第二步：添加 work 表缺失字段（兼容重复执行）
-- =============================================

-- 添加 competition_id 字段
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'work' AND COLUMN_NAME = 'competition_id'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE work ADD COLUMN competition_id INT NULL COMMENT ''竞赛ID'' AFTER team_id',
    'SELECT ''work.competition_id already exists''');
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 添加 category_id 字段
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'work' AND COLUMN_NAME = 'category_id'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE work ADD COLUMN category_id INT DEFAULT NULL COMMENT ''子类ID'' AFTER competition_id',
    'SELECT ''work.category_id already exists''');
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 添加 image_path 字段
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'work' AND COLUMN_NAME = 'image_path'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE work ADD COLUMN image_path VARCHAR(500) DEFAULT NULL COMMENT ''海报图片路径'' AFTER work_desc',
    'SELECT ''work.image_path already exists''');
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 添加 update_time 字段
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'work' AND COLUMN_NAME = 'update_time'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE work ADD COLUMN update_time DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT ''更新时间'' AFTER submit_time',
    'SELECT ''work.update_time already exists''');
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 修改 status 注释
ALTER TABLE work MODIFY COLUMN status TINYINT DEFAULT 1 COMMENT '状态：1-草稿，2-已提交，3-已评分';

-- 旧数据如果已经有队伍，可从 team 表回填 competition_id/category_id。
UPDATE work w
JOIN team t ON w.team_id = t.team_id
SET w.competition_id = COALESCE(w.competition_id, t.competition_id),
    w.category_id = COALESCE(w.category_id, t.category_id)
WHERE w.competition_id IS NULL;

-- =============================================
-- 第三步：补充索引和外键（兼容重复执行）
-- =============================================

SET @idx_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'work' AND INDEX_NAME = 'idx_competition_id'
);
SET @sql_stmt = IF(@idx_exists = 0,
    'ALTER TABLE work ADD INDEX idx_competition_id (competition_id)',
    'SELECT ''idx_competition_id already exists''');
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'work' AND INDEX_NAME = 'idx_category_id'
);
SET @sql_stmt = IF(@idx_exists = 0,
    'ALTER TABLE work ADD INDEX idx_category_id (category_id)',
    'SELECT ''idx_category_id already exists''');
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @fk_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'work' AND CONSTRAINT_NAME = 'fk_work_competition'
);
SET @sql_stmt = IF(@fk_exists = 0,
    'ALTER TABLE work ADD CONSTRAINT fk_work_competition FOREIGN KEY (competition_id) REFERENCES competition(competition_id)',
    'SELECT ''fk_work_competition already exists''');
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @fk_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'work' AND CONSTRAINT_NAME = 'fk_work_category'
);
SET @sql_stmt = IF(@fk_exists = 0,
    'ALTER TABLE work ADD CONSTRAINT fk_work_category FOREIGN KEY (category_id) REFERENCES competition_category(category_id)',
    'SELECT ''fk_work_category already exists''');
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =============================================
-- 第四步：补充 work_file 表缺失字段
-- =============================================
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'work_file' AND COLUMN_NAME = 'file_size'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE work_file ADD COLUMN file_size BIGINT DEFAULT 0 COMMENT ''文件大小（字节）'' AFTER file_type',
    'SELECT ''work_file.file_size already exists''');
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =============================================
-- 第五步：更新竞赛截止时间（确保测试数据可用）
-- =============================================
UPDATE competition SET submit_deadline = '2026-07-20 10:00:00'
WHERE submit_deadline = '2026-07-06 10:10:00';

-- =============================================
-- 第六步：确认修改结果
-- =============================================
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'work'
ORDER BY ORDINAL_POSITION;

SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'work_file'
ORDER BY ORDINAL_POSITION;
