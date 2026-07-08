-- =============================================
-- 数据库一致性修复脚本
-- 大学生海报设计竞赛系统
--
-- 用途：用于已经创建过的旧数据库，在 Navicat 中直接运行。
-- 全新初始化请直接执行：
--   1. database/schema.sql
--   2. database/data.sql
--
-- 修复内容：
--   1. 统一 team.status 状态含义注释
--   2. 补齐 work_share.platform 分享平台字段
--   3. 兼容旧库补齐 user.avatar 字段
--   4. 兼容旧库补齐 work 表作品模块字段
--   5. 兼容旧库补齐 work_file.file_size 字段
-- =============================================

USE poster_competition;

-- Navicat 在开启 ONLY_FULL_GROUP_BY 时，可能因为内部 PROFILING 查询报 1055 错误。
-- 这里与 schema.sql 保持一致，先移除当前会话的 ONLY_FULL_GROUP_BY。
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

-- =============================================
-- 1. 统一 team.status 状态含义
-- 代码当前使用：0-已取消，1-组建中，2-已报名
-- =============================================
ALTER TABLE team
MODIFY COLUMN status TINYINT DEFAULT 1 COMMENT '状态：0-已取消，1-组建中，2-已报名';

-- =============================================
-- 2. 补齐 work_share.platform 字段
-- WorkShare 模型和 WorkService.shareWork() 已有 platform 参数，数据库需要保存该字段。
-- =============================================
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'work_share'
      AND COLUMN_NAME = 'platform'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE work_share ADD COLUMN platform VARCHAR(50) DEFAULT NULL COMMENT ''分享平台'' AFTER user_id',
    'ALTER TABLE work_share MODIFY COLUMN platform VARCHAR(50) DEFAULT NULL COMMENT ''分享平台'''
);
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =============================================
-- 3. 兼容旧库：补齐 user.avatar 字段
-- =============================================
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'user'
      AND COLUMN_NAME = 'avatar'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE user ADD COLUMN avatar VARCHAR(500) DEFAULT NULL COMMENT ''头像文件路径'' AFTER phone',
    'ALTER TABLE user MODIFY COLUMN avatar VARCHAR(500) DEFAULT NULL COMMENT ''头像文件路径'''
);
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =============================================
-- 4. 兼容旧库：补齐 work 表作品模块字段
-- =============================================

-- competition_id
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'work'
      AND COLUMN_NAME = 'competition_id'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE work ADD COLUMN competition_id INT NULL COMMENT ''竞赛ID'' AFTER team_id',
    'SELECT ''work.competition_id already exists'''
);
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- category_id
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'work'
      AND COLUMN_NAME = 'category_id'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE work ADD COLUMN category_id INT DEFAULT NULL COMMENT ''子类ID'' AFTER competition_id',
    'SELECT ''work.category_id already exists'''
);
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- image_path
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'work'
      AND COLUMN_NAME = 'image_path'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE work ADD COLUMN image_path VARCHAR(500) DEFAULT NULL COMMENT ''海报图片路径'' AFTER work_desc',
    'ALTER TABLE work MODIFY COLUMN image_path VARCHAR(500) DEFAULT NULL COMMENT ''海报图片路径'''
);
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- file_path：兼容旧版字段，避免旧库 NOT NULL 导致 WorkDAOImpl.insert 失败
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'work'
      AND COLUMN_NAME = 'file_path'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE work ADD COLUMN file_path VARCHAR(500) DEFAULT NULL COMMENT ''文件路径（兼容旧版字段，作品主图使用image_path）'' AFTER image_path',
    'ALTER TABLE work MODIFY COLUMN file_path VARCHAR(500) DEFAULT NULL COMMENT ''文件路径（兼容旧版字段，作品主图使用image_path）'''
);
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- file_size：兼容旧版字段
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'work'
      AND COLUMN_NAME = 'file_size'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE work ADD COLUMN file_size INT DEFAULT NULL COMMENT ''文件大小（字节，兼容旧版字段）'' AFTER file_path',
    'ALTER TABLE work MODIFY COLUMN file_size INT DEFAULT NULL COMMENT ''文件大小（字节，兼容旧版字段）'''
);
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- version：兼容旧版字段
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'work'
      AND COLUMN_NAME = 'version'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE work ADD COLUMN version INT DEFAULT 1 COMMENT ''版本号（兼容旧版字段）'' AFTER file_size',
    'ALTER TABLE work MODIFY COLUMN version INT DEFAULT 1 COMMENT ''版本号（兼容旧版字段）'''
);
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- update_time
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'work'
      AND COLUMN_NAME = 'update_time'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE work ADD COLUMN update_time DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT ''更新时间'' AFTER submit_time',
    'ALTER TABLE work MODIFY COLUMN update_time DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT ''更新时间'''
);
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 统一 work.status 注释
ALTER TABLE work
MODIFY COLUMN status TINYINT DEFAULT 1 COMMENT '状态：1-草稿，2-已提交，3-已评分';

-- 旧作品从 team 表回填 competition_id/category_id
UPDATE work w
JOIN team t ON w.team_id = t.team_id
SET w.competition_id = COALESCE(w.competition_id, t.competition_id),
    w.category_id = COALESCE(w.category_id, t.category_id)
WHERE w.competition_id IS NULL
   OR w.category_id IS NULL;

-- 如果已无空 competition_id，则改为 NOT NULL，和 schema.sql 保持一致；否则保留 NULL 并在结果中提示。
SET @null_work_competition_count = (
    SELECT COUNT(*) FROM work WHERE competition_id IS NULL
);
SET @sql_stmt = IF(@null_work_competition_count = 0,
    'ALTER TABLE work MODIFY COLUMN competition_id INT NOT NULL COMMENT ''竞赛ID''',
    'SELECT ''WARNING: work.competition_id 仍存在 NULL，未改为 NOT NULL，请先检查旧作品数据'' AS warning_message'
);
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- work 表索引
SET @idx_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'work'
      AND INDEX_NAME = 'idx_competition_id'
);
SET @sql_stmt = IF(@idx_exists = 0,
    'ALTER TABLE work ADD INDEX idx_competition_id (competition_id)',
    'SELECT ''idx_competition_id already exists'''
);
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'work'
      AND INDEX_NAME = 'idx_category_id'
);
SET @sql_stmt = IF(@idx_exists = 0,
    'ALTER TABLE work ADD INDEX idx_category_id (category_id)',
    'SELECT ''idx_category_id already exists'''
);
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =============================================
-- 5. 兼容旧库：补齐 work_file.file_size 字段
-- =============================================
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'work_file'
      AND COLUMN_NAME = 'file_size'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE work_file ADD COLUMN file_size BIGINT DEFAULT 0 COMMENT ''文件大小（字节）'' AFTER file_type',
    'ALTER TABLE work_file MODIFY COLUMN file_size BIGINT DEFAULT 0 COMMENT ''文件大小（字节）'''
);
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =============================================
-- 6. 检查修复结果
-- =============================================
SELECT '=== team.status ===' AS check_item;
SELECT COLUMN_NAME, COLUMN_TYPE, COLUMN_DEFAULT, COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'team'
  AND COLUMN_NAME = 'status';

SELECT '=== work_share columns ===' AS check_item;
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'work_share'
ORDER BY ORDINAL_POSITION;

SELECT '=== user.avatar ===' AS check_item;
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'user'
  AND COLUMN_NAME = 'avatar';

SELECT '=== work columns ===' AS check_item;
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'work'
ORDER BY ORDINAL_POSITION;

SELECT '=== work_file columns ===' AS check_item;
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'work_file'
ORDER BY ORDINAL_POSITION;
