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
        // TODO: 实现竞赛子类插入
        String sql = "INSERT INTO competition_category (competition_id, category_name, category_desc) VALUES (?, ?, ?)";
        return 0;
    }

    @Override
    public int deleteById(Integer categoryId) {
        // TODO: 实现根据ID删除竞赛子类
        String sql = "DELETE FROM competition_category WHERE category_id = ?";
        return 0;
    }

    @Override
    public int update(CompetitionCategory category) {
        // TODO: 实现竞赛子类更新
        String sql = "UPDATE competition_category SET category_name=?, category_desc=? WHERE category_id=?";
        return 0;
    }

    @Override
    public CompetitionCategory findById(Integer categoryId) {
        // TODO: 实现根据ID查询竞赛子类
        String sql = "SELECT * FROM competition_category WHERE category_id = ?";
        return null;
    }

    @Override
    public List<CompetitionCategory> findByCompetitionId(Integer competitionId) {
        // TODO: 实现根据竞赛ID查询所有子类
        String sql = "SELECT * FROM competition_category WHERE competition_id = ?";
        return new ArrayList<>();
    }

    @Override
    public List<CompetitionCategory> findAll() {
        // TODO: 实现查询所有竞赛子类
        String sql = "SELECT * FROM competition_category";
        return new ArrayList<>();
    }
}
