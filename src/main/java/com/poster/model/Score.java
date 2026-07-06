package com.poster.model;

import java.time.LocalDateTime;

/**
 * 评分记录实体类
 * @author 团队共建
 * @date 2026-07-04
 */
public class Score {
    private Integer scoreId;
    private Integer workId;
    private Integer judgeId;
    private Double score;
    private LocalDateTime scoreTime;

    public Score() {}

    public Integer getScoreId() {
        return scoreId;
    }

    public void setScoreId(Integer scoreId) {
        this.scoreId = scoreId;
    }

    public Integer getWorkId() {
        return workId;
    }

    public void setWorkId(Integer workId) {
        this.workId = workId;
    }

    public Integer getJudgeId() {
        return judgeId;
    }

    public void setJudgeId(Integer judgeId) {
        this.judgeId = judgeId;
    }

    public Double getScore() {
        return score;
    }

    public void setScore(Double score) {
        this.score = score;
    }

    public LocalDateTime getScoreTime() {
        return scoreTime;
    }

    public void setScoreTime(LocalDateTime scoreTime) {
        this.scoreTime = scoreTime;
    }
}
