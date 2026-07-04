package com.poster.model;

import java.time.LocalDateTime;

/**
 * 竞赛实体类
 * @author 团队共建
 * @date 2026-07-04
 */
public class Competition {
    private Integer competitionId;
    private Integer year;
    private String name;
    private String theme;
    private String description;
    private LocalDateTime submitDeadline;
    private Integer maxTeamSize;
    private Integer status; // 1-报名中，2-进行中，3-已结束，0-已取消
    private Integer creatorId;
    private LocalDateTime createTime;

    public Competition() {}

    public Integer getCompetitionId() {
        return competitionId;
    }

    public void setCompetitionId(Integer competitionId) {
        this.competitionId = competitionId;
    }

    public Integer getYear() {
        return year;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getTheme() {
        return theme;
    }

    public void setTheme(String theme) {
        this.theme = theme;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public LocalDateTime getSubmitDeadline() {
        return submitDeadline;
    }

    public void setSubmitDeadline(LocalDateTime submitDeadline) {
        this.submitDeadline = submitDeadline;
    }

    public Integer getMaxTeamSize() {
        return maxTeamSize;
    }

    public void setMaxTeamSize(Integer maxTeamSize) {
        this.maxTeamSize = maxTeamSize;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public Integer getCreatorId() {
        return creatorId;
    }

    public void setCreatorId(Integer creatorId) {
        this.creatorId = creatorId;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }
}
