package com.poster.model;

import java.time.LocalDateTime;

/**
 * 评语记录实体类
 * @author 团队共建
 * @date 2026-07-04
 */
public class Comment {
    private Integer commentId;
    private Integer workId;
    private Integer judgeId;
    private String content;
    private LocalDateTime commentTime;

    public Comment() {}

    public Integer getCommentId() {
        return commentId;
    }

    public void setCommentId(Integer commentId) {
        this.commentId = commentId;
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

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public LocalDateTime getCommentTime() {
        return commentTime;
    }

    public void setCommentTime(LocalDateTime commentTime) {
        this.commentTime = commentTime;
    }
}
