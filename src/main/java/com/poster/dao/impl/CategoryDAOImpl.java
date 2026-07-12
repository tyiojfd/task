package com.poster.dao.impl;

import com.poster.dao.CategoryDAO;
import com.poster.model.CompetitionCategory;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 竞赛子类DAO实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class CategoryDAOImpl implements CategoryDAO {

    @Override
    public int insert(CompetitionCategory category) {
        String sql = "INSERT INTO competition_category (competition_id, category_name, category_desc) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, category.getCompetitionId());
            pstmt.setString(2, category.getCategoryName());
            pstmt.setString(3, category.getCategoryDesc());

            int rows = pstmt.executeUpdate();

            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        category.setCategoryId(rs.getInt(1));
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
    public int deleteById(Integer categoryId) {
        String sql = "DELETE FROM competition_category WHERE category_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, categoryId);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public int update(CompetitionCategory category) {
        String sql = "UPDATE competition_category SET category_name=?, category_desc=? WHERE category_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, category.getCategoryName());
            pstmt.setString(2, category.getCategoryDesc());
            pstmt.setInt(3, category.getCategoryId());

            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public CompetitionCategory findById(Integer categoryId) {
        String sql = "SELECT * FROM competition_category WHERE category_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            if (categoryId == null) return null;
            pstmt.setInt(1, categoryId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractCategoryFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<CompetitionCategory> findByCompetitionId(Integer competitionId) {
        String sql = "SELECT * FROM competition_category WHERE competition_id = ?";
        List<CompetitionCategory> categories = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, competitionId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    categories.add(extractCategoryFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return categories;
    }

    @Override
    public List<CompetitionCategory> findAll() {
        String sql = "SELECT * FROM competition_category";
        List<CompetitionCategory> categories = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                categories.add(extractCategoryFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return categories;
    }

    /**
     * 从ResultSet中提取CompetitionCategory对象
     */
    private CompetitionCategory extractCategoryFromResultSet(ResultSet rs) throws SQLException {
        CompetitionCategory category = new CompetitionCategory();
        category.setCategoryId(rs.getInt("category_id"));
        category.setCompetitionId(rs.getInt("competition_id"));
        category.setCategoryName(rs.getString("category_name"));
        category.setCategoryDesc(rs.getString("category_desc"));
        return category;
    }
}
