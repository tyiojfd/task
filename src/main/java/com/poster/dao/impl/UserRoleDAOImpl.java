package com.poster.dao.impl;

import com.poster.dao.UserRoleDAO;
import com.poster.model.Role;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 用户角色关联DAO实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class UserRoleDAOImpl implements UserRoleDAO {

    @Override
    public boolean assignRole(Integer userId, Integer roleId) {
        String sql = "INSERT INTO user_role (user_id, role_id) VALUES (?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, roleId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean removeRole(Integer userId, Integer roleId) {
        String sql = "DELETE FROM user_role WHERE user_id = ? AND role_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, roleId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public List<Role> findRolesByUserId(Integer userId) {
        String sql = "SELECT r.* FROM role r INNER JOIN user_role ur ON r.role_id = ur.role_id WHERE ur.user_id = ?";
        List<Role> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Role role = new Role();
                role.setRoleId(rs.getInt("role_id"));
                role.setRoleName(rs.getString("role_name"));
                role.setRoleDesc(rs.getString("role_desc"));
                list.add(role);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean deleteByUserId(Integer userId) {
        String sql = "DELETE FROM user_role WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
