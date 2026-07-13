package com.poster.dao.impl;

import com.poster.dao.WorkFileDAO;
import com.poster.model.WorkFile;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 作品文件DAO实现类
 * @author 队员B
 * @date 2026-07-06
 */
public class WorkFileDAOImpl implements WorkFileDAO {

    @Override
    public int insert(WorkFile workFile) {
        String sql = "INSERT INTO work_file (work_id, file_name, file_path, file_type, file_size) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, workFile.getWorkId());
            pstmt.setString(2, workFile.getFileName());
            pstmt.setString(3, workFile.getFilePath());
            pstmt.setString(4, workFile.getFileType());
            pstmt.setLong(5, workFile.getFileSize() != null ? workFile.getFileSize() : 0);

            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        workFile.setFileId(rs.getInt(1));
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
    public int deleteById(Integer fileId) {
        String sql = "DELETE FROM work_file WHERE file_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, fileId);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public int deleteByWorkId(Integer workId) {
        String sql = "DELETE FROM work_file WHERE work_id = ?";
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
    public int update(WorkFile workFile) {
        String sql = "UPDATE work_file SET file_name=?, file_path=?, file_type=?, file_size=? WHERE file_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, workFile.getFileName());
            pstmt.setString(2, workFile.getFilePath());
            pstmt.setString(3, workFile.getFileType());
            pstmt.setLong(4, workFile.getFileSize() != null ? workFile.getFileSize() : 0);
            pstmt.setInt(5, workFile.getFileId());

            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public WorkFile findById(Integer fileId) {
        String sql = "SELECT * FROM work_file WHERE file_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, fileId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractWorkFileFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public WorkFile findByFilePath(String filePath) {
        if (filePath == null || filePath.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT * FROM work_file WHERE file_path = ? LIMIT 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, filePath);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractWorkFileFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<WorkFile> findByWorkId(Integer workId) {
        String sql = "SELECT * FROM work_file WHERE work_id = ?";
        List<WorkFile> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, workId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(extractWorkFileFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<WorkFile> findAll() {
        String sql = "SELECT * FROM work_file ORDER BY upload_time DESC";
        List<WorkFile> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                list.add(extractWorkFileFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private WorkFile extractWorkFileFromResultSet(ResultSet rs) throws SQLException {
        WorkFile wf = new WorkFile();
        wf.setFileId(rs.getInt("file_id"));
        wf.setWorkId(rs.getInt("work_id"));
        wf.setFileName(rs.getString("file_name"));
        wf.setFilePath(rs.getString("file_path"));
        wf.setFileType(rs.getString("file_type"));
        wf.setFileSize(rs.getLong("file_size"));
        Timestamp uploadTime = rs.getTimestamp("upload_time");
        if (uploadTime != null) {
            wf.setUploadTime(uploadTime.toLocalDateTime());
        }
        return wf;
    }
}
