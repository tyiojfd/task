package com.poster.dao.impl;

import com.poster.dao.NewsDAO;
import com.poster.model.News;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 新闻公告DAO实现类
 * @author 队员C
 * @date 2026-07-06
 */
public class NewsDAOImpl implements NewsDAO {

    @Override
    public int insert(News news) {
        String sql = "INSERT INTO news (title, content, competition_id, author_id, status) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, news.getTitle());
            pstmt.setString(2, news.getContent());
            if (news.getCompetitionId() != null) {
                pstmt.setInt(3, news.getCompetitionId());
            } else {
                pstmt.setNull(3, Types.INTEGER);
            }
            pstmt.setInt(4, news.getAuthorId());
            pstmt.setInt(5, news.getStatus() != null ? news.getStatus() : 1);

            int rows = pstmt.executeUpdate();

            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        news.setNewsId(rs.getInt(1));
                    }
                }
            }

            return rows;
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public int deleteById(Integer newsId) {
        String sql = "DELETE FROM news WHERE news_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, newsId);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public int update(News news) {
        String sql = "UPDATE news SET title=?, content=?, competition_id=?, status=? WHERE news_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, news.getTitle());
            pstmt.setString(2, news.getContent());
            if (news.getCompetitionId() != null) {
                pstmt.setInt(3, news.getCompetitionId());
            } else {
                pstmt.setNull(3, Types.INTEGER);
            }
            pstmt.setInt(4, news.getStatus());
            pstmt.setInt(5, news.getNewsId());

            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public News findById(Integer newsId) {
        String sql = "SELECT * FROM news WHERE news_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, newsId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractNewsFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<News> findByStatus(Integer status) {
        String sql = "SELECT * FROM news WHERE status = ? ORDER BY publish_time DESC";
        List<News> newsList = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, status);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    newsList.add(extractNewsFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return newsList;
    }

    @Override
    public List<News> findByPublisherId(Integer publisherId) {
        String sql = "SELECT * FROM news WHERE author_id = ? ORDER BY publish_time DESC";
        List<News> newsList = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, publisherId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    newsList.add(extractNewsFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return newsList;
    }

    @Override
    public List<News> findAll() {
        String sql = "SELECT * FROM news ORDER BY publish_time DESC";
        List<News> newsList = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                newsList.add(extractNewsFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return newsList;
    }

    @Override
    public int count() {
        String sql = "SELECT COUNT(*) FROM news";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * 从ResultSet中提取News对象
     */
    private News extractNewsFromResultSet(ResultSet rs) throws SQLException {
        News news = new News();
        news.setNewsId(rs.getInt("news_id"));
        news.setTitle(rs.getString("title"));
        news.setContent(rs.getString("content"));

        int competitionId = rs.getInt("competition_id");
        if (!rs.wasNull()) {
            news.setCompetitionId(competitionId);
        }

        news.setAuthorId(rs.getInt("author_id"));
        news.setStatus(rs.getInt("status"));

        Timestamp publishTime = rs.getTimestamp("publish_time");
        if (publishTime != null) {
            news.setPublishTime(publishTime.toLocalDateTime());
        }

        return news;
    }
}
