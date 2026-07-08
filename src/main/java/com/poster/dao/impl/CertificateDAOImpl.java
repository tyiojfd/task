package com.poster.dao.impl;

import com.poster.dao.CertificateDAO;
import com.poster.model.Certificate;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 电子奖状DAO实现类
 * @author 队员C
 * @date 2026-07-08
 */
public class CertificateDAOImpl implements CertificateDAO {

    @Override
    public int insert(Certificate certificate) {
        String sql = "INSERT INTO certificate (award_id, certificate_no, file_path) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, certificate.getAwardId());
            pstmt.setString(2, certificate.getCertificateNo());
            pstmt.setString(3, certificate.getFilePath());

            int rows = pstmt.executeUpdate();

            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        certificate.setCertificateId(rs.getInt(1));
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
    public int deleteById(Integer certificateId) {
        String sql = "DELETE FROM certificate WHERE certificate_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, certificateId);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public int update(Certificate certificate) {
        String sql = "UPDATE certificate SET file_path=? WHERE certificate_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, certificate.getFilePath());
            pstmt.setInt(2, certificate.getCertificateId());

            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public Certificate findById(Integer certificateId) {
        String sql = "SELECT * FROM certificate WHERE certificate_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, certificateId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractCertificateFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public Certificate findByAwardId(Integer awardId) {
        String sql = "SELECT * FROM certificate WHERE award_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, awardId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractCertificateFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Certificate> findByTeamId(Integer teamId) {
        String sql = "SELECT c.* FROM certificate c " +
                     "JOIN award a ON c.award_id = a.award_id " +
                     "JOIN work w ON a.work_id = w.work_id " +
                     "WHERE w.team_id = ? " +
                     "ORDER BY c.generate_time DESC";
        List<Certificate> certificateList = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, teamId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    certificateList.add(extractCertificateFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return certificateList;
    }

    @Override
    public List<Certificate> findAll() {
        String sql = "SELECT * FROM certificate ORDER BY generate_time DESC";
        List<Certificate> certificateList = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                certificateList.add(extractCertificateFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return certificateList;
    }

    /**
     * 从ResultSet中提取Certificate对象
     */
    private Certificate extractCertificateFromResultSet(ResultSet rs) throws SQLException {
        Certificate certificate = new Certificate();
        certificate.setCertificateId(rs.getInt("certificate_id"));
        certificate.setAwardId(rs.getInt("award_id"));
        certificate.setCertificateNo(rs.getString("certificate_no"));
        certificate.setFilePath(rs.getString("file_path"));

        Timestamp generateTime = rs.getTimestamp("generate_time");
        if (generateTime != null) {
            certificate.setGenerateTime(generateTime.toLocalDateTime());
        }

        return certificate;
    }
}
