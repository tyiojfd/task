package com.poster.model;

import java.time.LocalDateTime;

/**
 * 邀请记录实体类
 * @author 团队共建
 * @date 2026-07-04
 */
public class Invitation {
    private Integer invitationId;
    private Integer teamId;
    private Integer inviterId;
    private Integer inviteeId;
    private Integer status; // 0-待处理，1-已接受，2-已拒绝.
    private LocalDateTime inviteTime;
    private LocalDateTime responseTime;

    public Invitation() {}

    public Integer getInvitationId() {
        return invitationId;
    }

    public void setInvitationId(Integer invitationId) {
        this.invitationId = invitationId;
    }

    public Integer getTeamId() {
        return teamId;
    }

    public void setTeamId(Integer teamId) {
        this.teamId = teamId;
    }

    public Integer getInviterId() {
        return inviterId;
    }

    public void setInviterId(Integer inviterId) {
        this.inviterId = inviterId;
    }

    public Integer getInviteeId() {
        return inviteeId;
    }

    public void setInviteeId(Integer inviteeId) {
        this.inviteeId = inviteeId;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public LocalDateTime getInviteTime() {
        return inviteTime;
    }

    public void setInviteTime(LocalDateTime inviteTime) {
        this.inviteTime = inviteTime;
    }

    public LocalDateTime getResponseTime() {
        return responseTime;
    }

    public void setResponseTime(LocalDateTime responseTime) {
        this.responseTime = responseTime;
    }
}
