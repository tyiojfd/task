-- =============================================
-- 用户头像字段 - 数据库迁移脚本
-- 用途：仅用于已经执行旧版 schema.sql 的数据库升级。
-- 全新初始化请直接执行 database/schema.sql，再执行 database/data.sql。
-- =============================================

USE poster_competition;

SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'user' AND COLUMN_NAME = 'avatar'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE user ADD COLUMN avatar VARCHAR(500) DEFAULT NULL COMMENT ''头像文件路径'' AFTER phone',
    'SELECT ''user.avatar already exists''');
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'user'
ORDER BY ORDINAL_POSITION;
