package com.poster.dao.impl;

import com.poster.dao.WorkLikeDAO;
import com.poster.model.WorkLike;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 作品点赞DAO实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class WorkLikeDAOImpl implements WorkLikeDAO {

    @Override
    public int insert(WorkLike workLike) {
        // TODO: 实现点赞记录插入
        String sql = "INSERT INTO work_like (work_id, user_id) VALUES (?, ?)";
        return 0;
    }

    @Override
    public int deleteById(Integer id) {
        // TODO: 实现根据ID删除点赞记录
        String sql = "DELETE FROM work_like WHERE id = ?";
        return 0;
    }

    @Override
    public int deleteByWorkIdAndUserId(Integer workId, Integer userId) {
        // TODO: 实现取消点赞
        String sql = "DELETE FROM work_like WHERE work_id = ? AND user_id = ?";
        return 0;
    }

    @Override
    public List<WorkLike> findByWorkId(Integer workId) {
        // TODO: 实现根据作品ID查询所有点赞
        String sql = "SELECT * FROM work_like WHERE work_id = ?";
        return new ArrayList<>();
    }

    @Override
    public List<WorkLike> findByUserId(Integer userId) {
        // TODO: 实现根据用户ID查询所有点赞
        String sql = "SELECT * FROM work_like WHERE user_id = ?";
        return new ArrayList<>();
    }

    @Override
    public boolean isLiked(Integer workId, Integer userId) {
        // TODO: 实现检查用户是否已点赞
        String sql = "SELECT COUNT(*) FROM work_like WHERE work_id = ? AND user_id = ?";
        return false;
    }

    @Override
    public int countByWorkId(Integer workId) {
        // TODO: 实现统计作品点赞数
        String sql = "SELECT COUNT(*) FROM work_like WHERE work_id = ?";
        return 0;
    }
}
