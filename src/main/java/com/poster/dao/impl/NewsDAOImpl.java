package com.poster.dao.impl;

import com.poster.dao.NewsDAO;
import com.poster.model.News;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 新闻公告DAO实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class NewsDAOImpl implements NewsDAO {

    @Override
    public int insert(News news) {
        // TODO: 实现新闻插入
        String sql = "INSERT INTO news (title, content, publisher_id, status) VALUES (?, ?, ?, ?)";
        return 0;
    }

    @Override
    public int deleteById(Integer newsId) {
        // TODO: 实现根据ID删除新闻
        String sql = "DELETE FROM news WHERE news_id = ?";
        return 0;
    }

    @Override
    public int update(News news) {
        // TODO: 实现更新新闻信息
        String sql = "UPDATE news SET title=?, content=?, status=? WHERE news_id=?";
        return 0;
    }

    @Override
    public News findById(Integer newsId) {
        // TODO: 实现根据ID查询新闻
        String sql = "SELECT * FROM news WHERE news_id = ?";
        return null;
    }

    @Override
    public List<News> findByStatus(Integer status) {
        // TODO: 实现根据状态查询新闻
        String sql = "SELECT * FROM news WHERE status = ? ORDER BY publish_time DESC";
        return new ArrayList<>();
    }

    @Override
    public List<News> findByPublisherId(Integer publisherId) {
        // TODO: 实现根据发布人查询新闻
        String sql = "SELECT * FROM news WHERE publisher_id = ?";
        return new ArrayList<>();
    }

    @Override
    public List<News> findAll() {
        // TODO: 实现查询所有新闻
        String sql = "SELECT * FROM news ORDER BY publish_time DESC";
        return new ArrayList<>();
    }

    @Override
    public int count() {
        // TODO: 实现统计新闻总数
        String sql = "SELECT COUNT(*) FROM news";
        return 0;
    }
}
