package com.poster.model;

import java.time.LocalDateTime;

/**
 * 作品分享实体类
 * @author 团队共建
 * @date 2026-07-04
 */
public class WorkShare {
    private Integer id;
    private Integer workId;
    private Integer userId;
    private String platform;
    private LocalDateTime shareTime;

    public WorkShare() {}

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getWorkId() {
        return workId;
    }

    public void setWorkId(Integer workId) {
        this.workId = workId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getPlatform() {
        return platform;
    }

    public void setPlatform(String platform) {
        this.platform = platform;
    }

    public LocalDateTime getShareTime() {
        return shareTime;
    }

    public void setShareTime(LocalDateTime shareTime) {
        this.shareTime = shareTime;
    }
}
