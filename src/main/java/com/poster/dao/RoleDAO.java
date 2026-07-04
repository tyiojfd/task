package com.poster.dao;

import com.poster.model.Role;
import java.util.List;

/**
 * 角色DAO接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface RoleDAO {

    /**
     * 插入角色
     */
    int insert(Role role);

    /**
     * 根据ID删除角色
     */
    int deleteById(Integer roleId);

    /**
     * 更新角色信息
     */
    int update(Role role);

    /**
     * 根据ID查询角色
     */
    Role findById(Integer roleId);

    /**
     * 根据角色名查询
     */
    Role findByName(String roleName);

    /**
     * 查询所有角色
     */
    List<Role> findAll();
}
