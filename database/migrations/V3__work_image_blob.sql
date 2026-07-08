-- =============================================
-- 作品管理模块 - 数据库迁移脚本 V3
-- 用途：添加image_data MEDIUMBLOB字段用于数据库存储图片
-- =============================================

USE poster_competition;

-- 添加 image_data 字段（MEDIUMBLOB 支持最大16MB图片）
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'work' AND COLUMN_NAME = 'image_data'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE work ADD COLUMN image_data MEDIUMBLOB DEFAULT NULL COMMENT ''海报图片二进制数据'' AFTER image_path',
    'SELECT ''work.image_data already exists''');
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 添加 image_content_type 字段
SET @col_exists = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'work' AND COLUMN_NAME = 'image_content_type'
);
SET @sql_stmt = IF(@col_exists = 0,
    'ALTER TABLE work ADD COLUMN image_content_type VARCHAR(50) DEFAULT NULL COMMENT ''图片MIME类型（image/jpeg, image/png）'' AFTER image_data',
    'SELECT ''work.image_content_type already exists''');
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 确认修改结果
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'work'
ORDER BY ORDINAL_POSITION;
