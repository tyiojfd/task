package com.poster.model;

import java.time.LocalDateTime;

/**
 * 作品点赞实体类
 * @author 团队共建
 * @date 2026-07-04
 */
public class WorkLike {
    private Integer id;
    private Integer workId;
    private Integer userId;
    private LocalDateTime likeTime;

    public WorkLike() {}

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

    public LocalDateTime getLikeTime() {
        return likeTime;
    }

    public void setLikeTime(LocalDateTime likeTime) {
        this.likeTime = likeTime;
    }
}
