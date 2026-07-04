package com.poster.model;

import java.time.LocalDateTime;

/**
 * 用户角色关联实体类
 * @author 团队共建
 * @date 2026-07-04
 */
public class UserRole {
    private Integer id;
    private Integer userId;
    private Integer roleId;
    private LocalDateTime assignTime;

    public UserRole() {}

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getRoleId() {
        return roleId;
    }

    public void setRoleId(Integer roleId) {
        this.roleId = roleId;
    }

    public LocalDateTime getAssignTime() {
        return assignTime;
    }

    public void setAssignTime(LocalDateTime assignTime) {
        this.assignTime = assignTime;
    }
}
