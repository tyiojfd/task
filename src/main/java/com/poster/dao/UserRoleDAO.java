package com.poster.dao;

import com.poster.model.Role;
import java.util.List;

/**
 * 用户角色关联DAO接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface UserRoleDAO {

    /**
     * 为用户分配角色
     */
    boolean assignRole(Integer userId, Integer roleId);

    /**
     * 移除用户角色
     */
    boolean removeRole(Integer userId, Integer roleId);

    /**
     * 获取用户的所有角色
     */
    List<Role> findRolesByUserId(Integer userId);

    /**
     * 清空用户所有角色
     */
    boolean deleteByUserId(Integer userId);
}
