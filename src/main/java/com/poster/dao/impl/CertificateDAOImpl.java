package com.poster.dao.impl;

import com.poster.dao.CertificateDAO;
import com.poster.model.Certificate;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 电子奖状DAO实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class CertificateDAOImpl implements CertificateDAO {

    @Override
    public int insert(Certificate certificate) {
        // TODO: 实现电子奖状插入
        String sql = "INSERT INTO certificate (award_id, team_id, certificate_no, certificate_path) VALUES (?, ?, ?, ?)";
        return 0;
    }

    @Override
    public int deleteById(Integer certificateId) {
        // TODO: 实现根据ID删除奖状
        String sql = "DELETE FROM certificate WHERE certificate_id = ?";
        return 0;
    }

    @Override
    public int update(Certificate certificate) {
        // TODO: 实现更新奖状信息
        String sql = "UPDATE certificate SET certificate_path=? WHERE certificate_id=?";
        return 0;
    }

    @Override
    public Certificate findById(Integer certificateId) {
        // TODO: 实现根据ID查询奖状
        String sql = "SELECT * FROM certificate WHERE certificate_id = ?";
        return null;
    }

    @Override
    public Certificate findByAwardId(Integer awardId) {
        // TODO: 实现根据获奖ID查询奖状
        String sql = "SELECT * FROM certificate WHERE award_id = ?";
        return null;
    }

    @Override
    public List<Certificate> findByTeamId(Integer teamId) {
        // TODO: 实现根据队伍ID查询奖状
        String sql = "SELECT * FROM certificate WHERE team_id = ?";
        return new ArrayList<>();
    }

    @Override
    public List<Certificate> findAll() {
        // TODO: 实现查询所有奖状
        String sql = "SELECT * FROM certificate ORDER BY generate_time DESC";
        return new ArrayList<>();
    }
}
