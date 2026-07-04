package com.poster.dao.impl;

import com.poster.dao.WorkShareDAO;
import com.poster.model.WorkShare;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 作品分享DAO实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class WorkShareDAOImpl implements WorkShareDAO {

    @Override
    public int insert(WorkShare workShare) {
        // TODO: 实现分享记录插入
        String sql = "INSERT INTO work_share (work_id, user_id, platform) VALUES (?, ?, ?)";
        return 0;
    }

    @Override
    public int deleteById(Integer id) {
        // TODO: 实现根据ID删除分享记录
        String sql = "DELETE FROM work_share WHERE id = ?";
        return 0;
    }

    @Override
    public List<WorkShare> findByWorkId(Integer workId) {
        // TODO: 实现根据作品ID查询所有分享记录
        String sql = "SELECT * FROM work_share WHERE work_id = ?";
        return new ArrayList<>();
    }

    @Override
    public List<WorkShare> findByUserId(Integer userId) {
        // TODO: 实现根据用户ID查询所有分享记录
        String sql = "SELECT * FROM work_share WHERE user_id = ?";
        return new ArrayList<>();
    }

    @Override
    public int countByWorkId(Integer workId) {
        // TODO: 实现统计作品分享数
        String sql = "SELECT COUNT(*) FROM work_share WHERE work_id = ?";
        return 0;
    }

    @Override
    public List<WorkShare> findAll() {
        // TODO: 实现查询所有分享记录
        String sql = "SELECT * FROM work_share ORDER BY share_time DESC";
        return new ArrayList<>();
    }
}
