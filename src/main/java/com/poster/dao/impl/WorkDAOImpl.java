package com.poster.dao.impl;

import com.poster.dao.WorkDAO;
import com.poster.model.Work;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 作品DAO实现�?
 * @author 队员B
 * @date 2026-07-06
 */
public class WorkDAOImpl implements WorkDAO {

    @Override
    public int insert(Work work) {
        String sql = "INSERT INTO work (team_id, competition_id, category_id, work_title, work_desc, image_path, image_data, image_content_type, thumbnail_data, thumbnail_content_type, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, work.getTeamId());
            pstmt.setInt(2, work.getCompetitionId());
            if (work.getCategoryId() != null) {
                pstmt.setInt(3, work.getCategoryId());
            } else {
                pstmt.setNull(3, Types.INTEGER);
            }
            pstmt.setString(4, work.getTitle());
            pstmt.setString(5, work.getDescription());
            pstmt.setString(6, work.getImagePath());
            pstmt.setBytes(7, work.getImageData());
            pstmt.setString(8, work.getImageContentType());
            pstmt.setBytes(9, work.getThumbnailData());
            pstmt.setString(10, work.getThumbnailContentType());
            pstmt.setInt(11, work.getStatus() != null ? work.getStatus() : 2);

            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        work.setWorkId(rs.getInt(1));
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
    public int deleteById(Integer workId) {
        String sql = "DELETE FROM work WHERE work_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, workId);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public int update(Work work) {
        String sql = "UPDATE work SET work_title=?, work_desc=?, image_path=?, image_data=?, image_content_type=?, thumbnail_data=?, thumbnail_content_type=?, status=?, category_id=? WHERE work_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, work.getTitle());
            pstmt.setString(2, work.getDescription());
            pstmt.setString(3, work.getImagePath());
            pstmt.setBytes(4, work.getImageData());
            pstmt.setString(5, work.getImageContentType());
            pstmt.setBytes(6, work.getThumbnailData());
            pstmt.setString(7, work.getThumbnailContentType());
            pstmt.setInt(8, work.getStatus() != null ? work.getStatus() : 2);
            if (work.getCategoryId() != null) {
                pstmt.setInt(9, work.getCategoryId());
            } else {
                pstmt.setNull(9, Types.INTEGER);
            }
            pstmt.setInt(10, work.getWorkId());

            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public Work findById(Integer workId) {
        String sql = "SELECT * FROM work WHERE work_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, workId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractWorkFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Work> findAll() {
        String sql = "SELECT * FROM work ORDER BY submit_time DESC";
        List<Work> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                list.add(extractWorkFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Work> findByTeamId(Integer teamId) {
        String sql = "SELECT * FROM work WHERE team_id = ? ORDER BY submit_time DESC";
        List<Work> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, teamId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(extractWorkFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Work> findByCompetitionId(Integer competitionId) {
        String sql = "SELECT * FROM work WHERE competition_id = ? ORDER BY submit_time DESC";
        List<Work> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, competitionId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(extractWorkFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Work> findByStatus(Integer status) {
        String sql = "SELECT * FROM work WHERE status = ? ORDER BY submit_time DESC";
        List<Work> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, status);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(extractWorkFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public int count() {
        String sql = "SELECT COUNT(*) FROM work";
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

    @Override
    public List<Work> findByTeamIdAndCompetitionId(Integer teamId, Integer competitionId) {
        String sql = "SELECT * FROM work WHERE team_id = ? AND competition_id = ? ORDER BY submit_time DESC";
        List<Work> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, teamId);
            pstmt.setInt(2, competitionId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(extractWorkFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public int countByCompetitionId(Integer competitionId) {
        String sql = "SELECT COUNT(*) FROM work WHERE competition_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, competitionId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public List<Work> findByTeamIdsAndKeyword(List<Integer> teamIds, String keyword) {
        if (teamIds == null || teamIds.isEmpty()) {
            return new ArrayList<>();
        }

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT DISTINCT w.* FROM work w LEFT JOIN team t ON w.team_id = t.team_id WHERE w.team_id IN (");
        for (int i = 0; i < teamIds.size(); i++) {
            sql.append(i > 0 ? ",?" : "?");
        }
        sql.append(")");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (w.work_title LIKE ? OR t.team_name LIKE ?)");
        }
        sql.append(" ORDER BY w.submit_time DESC");

        List<Work> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {

            int index = 1;
            for (Integer teamId : teamIds) {
                pstmt.setInt(index++, teamId);
            }

            if (keyword != null && !keyword.trim().isEmpty()) {
                String likePattern = "%" + keyword.trim() + "%";
                pstmt.setString(index++, likePattern);
                pstmt.setString(index++, likePattern);
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(extractWorkFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * 从ResultSet提取Work对象
     */
    private Work extractWorkFromResultSet(ResultSet rs) throws SQLException {
        Work work = new Work();
        work.setWorkId(rs.getInt("work_id"));
        work.setTeamId(rs.getInt("team_id"));

        int competitionId = rs.getInt("competition_id");
        if (!rs.wasNull()) {
            work.setCompetitionId(competitionId);
        }

        int categoryId = rs.getInt("category_id");
        if (!rs.wasNull()) {
            work.setCategoryId(categoryId);
        }

        work.setTitle(rs.getString("work_title"));
        work.setDescription(rs.getString("work_desc"));
        work.setImagePath(rs.getString("image_path"));
        work.setImageData(rs.getBytes("image_data"));
        work.setImageContentType(rs.getString("image_content_type"));
        work.setThumbnailData(rs.getBytes("thumbnail_data"));
        work.setThumbnailContentType(rs.getString("thumbnail_content_type"));

        int status = rs.getInt("status");
        work.setStatus(rs.wasNull() ? 1 : status);

        Timestamp submitTime = rs.getTimestamp("submit_time");
        if (submitTime != null) {
            work.setSubmitTime(submitTime.toLocalDateTime());
        }

        Timestamp updateTime = rs.getTimestamp("update_time");
        if (updateTime != null) {
            work.setUpdateTime(updateTime.toLocalDateTime());
        }

        return work;
    }
}
