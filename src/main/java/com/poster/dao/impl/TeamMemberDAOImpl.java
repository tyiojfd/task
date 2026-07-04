package com.poster.dao.impl;

import com.poster.dao.TeamMemberDAO;
import com.poster.model.TeamMember;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 队伍成员DAO实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class TeamMemberDAOImpl implements TeamMemberDAO {

    @Override
    public int insert(TeamMember teamMember) {
        // TODO: 实现队伍成员插入
        String sql = "INSERT INTO team_member (team_id, user_id, role) VALUES (?, ?, ?)";
        return 0;
    }

    @Override
    public int deleteById(Integer id) {
        // TODO: 实现根据ID删除队伍成员
        String sql = "DELETE FROM team_member WHERE id = ?";
        return 0;
    }

    @Override
    public int deleteByTeamIdAndUserId(Integer teamId, Integer userId) {
        // TODO: 实现根据队伍ID和用户ID删除成员
        String sql = "DELETE FROM team_member WHERE team_id = ? AND user_id = ?";
        return 0;
    }

    @Override
    public int update(TeamMember teamMember) {
        // TODO: 实现更新成员角色
        String sql = "UPDATE team_member SET role=? WHERE id=?";
        return 0;
    }

    @Override
    public TeamMember findById(Integer id) {
        // TODO: 实现根据ID查询队伍成员
        String sql = "SELECT * FROM team_member WHERE id = ?";
        return null;
    }

    @Override
    public List<TeamMember> findByTeamId(Integer teamId) {
        // TODO: 实现根据队伍ID查询所有成员
        String sql = "SELECT * FROM team_member WHERE team_id = ?";
        return new ArrayList<>();
    }

    @Override
    public List<TeamMember> findByUserId(Integer userId) {
        // TODO: 实现根据用户ID查询所有参与的队伍
        String sql = "SELECT * FROM team_member WHERE user_id = ?";
        return new ArrayList<>();
    }

    @Override
    public int countByTeamId(Integer teamId) {
        // TODO: 实现统计队伍成员数量
        String sql = "SELECT COUNT(*) FROM team_member WHERE team_id = ?";
        return 0;
    }
}
