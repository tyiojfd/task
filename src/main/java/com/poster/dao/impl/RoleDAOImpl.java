package com.poster.dao.impl;

import com.poster.dao.RoleDAO;
import com.poster.model.Role;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 角色DAO实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class RoleDAOImpl implements RoleDAO {

    @Override
    public int insert(Role role) {
        // TODO: 实现角色插入
        String sql = "INSERT INTO role (role_name, role_desc) VALUES (?, ?)";
        return 0;
    }

    @Override
    public int deleteById(Integer roleId) {
        // TODO: 实现根据ID删除角色
        String sql = "DELETE FROM role WHERE role_id = ?";
        return 0;
    }

    @Override
    public int update(Role role) {
        // TODO: 实现角色更新
        String sql = "UPDATE role SET role_name=?, role_desc=? WHERE role_id=?";
        return 0;
    }

    @Override
    public Role findById(Integer roleId) {
        // TODO: 实现根据ID查询角色
        String sql = "SELECT * FROM role WHERE role_id = ?";
        return null;
    }

    @Override
    public Role findByName(String roleName) {
        // TODO: 实现根据角色名查询
        String sql = "SELECT * FROM role WHERE role_name = ?";
        return null;
    }

    @Override
    public List<Role> findAll() {
        // TODO: 实现查询所有角色
        String sql = "SELECT * FROM role";
        return new ArrayList<>();
    }
}
