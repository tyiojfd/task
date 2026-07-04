package com.poster.model;

import java.time.LocalDateTime;

/**
 * 队伍成员实体类
 * @author 团队共建
 * @date 2026-07-04
 */
public class TeamMember {
    private Integer id;
    private Integer teamId;
    private Integer userId;
    private Integer role; // 1-队长，2-队员
    private LocalDateTime joinTime;

    public TeamMember() {}

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getTeamId() {
        return teamId;
    }

    public void setTeamId(Integer teamId) {
        this.teamId = teamId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getRole() {
        return role;
    }

    public void setRole(Integer role) {
        this.role = role;
    }

    public LocalDateTime getJoinTime() {
        return joinTime;
    }

    public void setJoinTime(LocalDateTime joinTime) {
        this.joinTime = joinTime;
    }
}
