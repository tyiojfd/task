package com.poster.model;

/**
 * 角色实体类
 * @author 团队共建
 * @date 2026-07-04
 */
public class Role {
    private Integer roleId;
    private String roleName;
    private String roleDesc;

    public Role() {}

    public Integer getRoleId() {
        return roleId;
    }

    public void setRoleId(Integer roleId) {
        this.roleId = roleId;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getRoleDesc() {
        return roleDesc;
    }

    public void setRoleDesc(String roleDesc) {
        this.roleDesc = roleDesc;
    }
}
