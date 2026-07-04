package com.poster.model;

import java.time.LocalDateTime;

/**
 * 获奖设置实体类
 * @author 团队共建
 * @date 2026-07-04
 */
public class Award {
    private Integer awardId;
    private Integer competitionId;
    private Integer workId;
    private String awardLevel; // 一等奖、二等奖、三等奖
    private LocalDateTime awardTime;

    public Award()

    public Integer getAwardId() {
        return awardId;
    }

    public void setAwardId(Integer awardId) {
        this.awardId = awardId;
    }

    public Integer getCompetitionId() {
        return competitionId;
    }

    public void setCompetitionId(Integer competitionId) {
        this.competitionId = competitionId;
    }

    public Integer getWorkId() {
        return workId;
    }

    public void setWorkId(Integer workId) {
        this.workId = workId;
    }

    public String getAwardLevel() {
        return awardLevel;
    }

    public void setAwardLevel(String awardLevel) {
        this.awardLevel = awardLevel;
    }

    public LocalDateTime getAwardTime() {
        return awardTime;
    }

    public void setAwardTime(LocalDateTime awardTime) {
        this.awardTime = awardTime;
    }
}
