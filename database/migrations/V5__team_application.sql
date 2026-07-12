-- 入队申请表
CREATE TABLE IF NOT EXISTS team_application (
    application_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '申请ID',
    team_id INT NOT NULL COMMENT '队伍ID',
    applicant_id INT NOT NULL COMMENT '申请人ID',
    message VARCHAR(500) DEFAULT NULL COMMENT '申请留言',
    status TINYINT DEFAULT 0 COMMENT '状态：0-待处理，1-已通过，2-已拒绝，3-已取消',
    apply_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
    response_time DATETIME DEFAULT NULL COMMENT '处理时间',
    FOREIGN KEY (team_id) REFERENCES team(team_id) ON DELETE CASCADE,
    FOREIGN KEY (applicant_id) REFERENCES user(user_id) ON DELETE CASCADE,
    INDEX idx_team_id (team_id),
    INDEX idx_applicant_id (applicant_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='入队申请表';
