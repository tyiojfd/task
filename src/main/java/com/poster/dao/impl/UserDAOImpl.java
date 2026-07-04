package com.poster.dao.impl;

import com.poster.dao.UserDAO;
import com.poster.model.User;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 用户DAO实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class UserDAOImpl implements UserDAO {

    @Override
    public int insert(User user) {
        // TODO: 实现用户插入
        String sql = "INSERT INTO user (username, password, real_name, email, phone, status) VALUES (?, ?, ?, ?, ?, ?)";
        return 0;
    }

    @Override
    public int deleteById(Integer userId) {
        // TODO: 实现根据ID删除用户
        String sql = "DELETE FROM user WHERE user_id = ?";
        return 0;
    }

    @Override
    public int update(User user) {
        // TODO: 实现用户更新
        String sql = "UPDATE user SET username=?, real_name=?, email=?, phone=?, status=? WHERE user_id=?";
        return 0;
    }

    @Override
    public User findById(Integer userId) {
        // TODO: 实现根据ID查询用户
        String sql = "SELECT * FROM user WHERE user_id = ?";
        return null;
    }

    @Override
    public User findByUsername(String username) {
        // TODO: 实现根据用户名查询用户
        String sql = "SELECT * FROM user WHERE username = ?";
        return null;
    }

    @Override
    public List<User> findAll() {
        // TODO: 实现查询所有用户
        String sql = "SELECT * FROM user";
        return new ArrayList<>();
    }

    @Override
    public User findByEmail(String email) {
        // TODO: 实现根据邮箱查询用户
        String sql = "SELECT * FROM user WHERE email = ?";
        return null;
    }

    @Override
    public int count() {
        // TODO: 实现统计用户总数
        String sql = "SELECT COUNT(*) FROM user";
        return 0;
    }
}
