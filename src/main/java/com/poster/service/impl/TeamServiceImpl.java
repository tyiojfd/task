package com.poster.service.impl;

import com.poster.dao.TeamDAO;
import com.poster.dao.TeamMemberDAO;
import com.poster.dao.InvitationDAO;
import com.poster.dao.impl.TeamDAOImpl;
import com.poster.dao.impl.TeamMemberDAOImpl;
import com.poster.dao.impl.InvitationDAOImpl;
import com.poster.model.Team;
import com.poster.model.TeamMember;
import com.poster.model.Invitation;
import com.poster.service.TeamService;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 队伍服务实现类
 * @author 杨祥博
 * @date 2026-07-05
 */
public class TeamServiceImpl implements TeamService {

    private TeamDAO teamDAO = new TeamDAOImpl();
    private TeamMemberDAO teamMemberDAO = new TeamMemberDAOImpl();
    private InvitationDAO invitationDAO = new InvitationDAOImpl();

    @Override
    public boolean createTeam(Team team, Integer leaderId) {
        // 验证必填字段
        if (team.getTeamName() == null || team.getTeamName().trim().isEmpty()) {
            return false;
        }
        if (team.getCompetitionId() == null) {
            return false;
        }
        if (team.getCategoryId() == null) {
            return false;
        }

        // 设置队伍信息
        team.setLeaderId(leaderId);
        if (team.getStatus() == null) {
            team.setStatus(1); // 默认状态：组建中
        }
        team.setCreateTime(LocalDateTime.now());

        // 插入队伍记录
        int result = teamDAO.insert(team);
        if (result <= 0) {
            return false;
        }

        // 将队长加入team_member表
        TeamMember leaderMember = new TeamMember();
        leaderMember.setTeamId(team.getTeamId());
        leaderMember.setUserId(leaderId);
        leaderMember.setRole(1); // 1-队长
        leaderMember.setJoinTime(LocalDateTime.now());

        return teamMemberDAO.insert(leaderMember) > 0;
    }

    @Override
    public boolean updateTeam(Team team) {
        if (team.getTeamId() == null) {
            return false;
        }
        if (team.getTeamName() == null || team.getTeamName().trim().isEmpty()) {
            return false;
        }
        return teamDAO.update(team) > 0;
    }

    @Override
    public boolean deleteTeam(Integer teamId, Integer leaderId) {
        if (teamId == null || leaderId == null) {
            return false;
        }

        // 验证是否为队长
        Team team = teamDAO.findById(teamId);
        if (team == null || !team.getLeaderId().equals(leaderId)) {
            return false;
        }

        return teamDAO.deleteById(teamId) > 0;
    }

    @Override
    public Team getTeamById(Integer teamId) {
        if (teamId == null) {
            return null;
        }
        return teamDAO.findById(teamId);
    }

    @Override
    public List<Team> getTeamsByLeaderId(Integer leaderId) {
        if (leaderId == null) {
            return null;
        }
        return teamDAO.findByLeaderId(leaderId);
    }

    @Override
    public List<Team> getTeamsByCompetitionId(Integer competitionId) {
        if (competitionId == null) {
            return null;
        }
        return teamDAO.findByCompetitionId(competitionId);
    }

    @Override
    public boolean inviteMember(Integer teamId, Integer inviterId, Integer inviteeId) {
        if (teamId == null || inviterId == null || inviteeId == null) {
            return false;
        }

        // 检查队伍是否存在
        Team team = teamDAO.findById(teamId);
        if (team == null) {
            return false;
        }

        // 检查队伍人数是否已满（默认最大5人）
        int memberCount = teamMemberDAO.countByTeamId(teamId);
        if (memberCount >= 5) {
            return false;
        }

        // 检查是否已是队伍成员
        List<TeamMember> members = teamMemberDAO.findByTeamId(teamId);
        for (TeamMember member : members) {
            if (member.getUserId().equals(inviteeId)) {
                return false; // 已是队伍成员
            }
        }

        // 创建邀请记录
        Invitation invitation = new Invitation();
        invitation.setTeamId(teamId);
        invitation.setInviterId(inviterId);
        invitation.setInviteeId(inviteeId);
        invitation.setStatus(0); // 0-待处理
        invitation.setInviteTime(LocalDateTime.now());

        return invitationDAO.insert(invitation) > 0;
    }

    @Override
    public boolean removeMember(Integer teamId, Integer leaderId, Integer memberId) {
        if (teamId == null || leaderId == null || memberId == null) {
            return false;
        }

        // 验证是否为队长
        Team team = teamDAO.findById(teamId);
        if (team == null || !team.getLeaderId().equals(leaderId)) {
            return false;
        }

        // 不能移除队长自己
        if (leaderId.equals(memberId)) {
            return false;
        }

        return teamMemberDAO.deleteByTeamIdAndUserId(teamId, memberId) > 0;
    }

    @Override
    public boolean registerCompetition(Integer teamId, Integer competitionId, Integer categoryId) {
        if (teamId == null || competitionId == null || categoryId == null) {
            return false;
        }

        Team team = teamDAO.findById(teamId);
        if (team == null) {
            return false;
        }

        team.setCompetitionId(competitionId);
        team.setCategoryId(categoryId);
        team.setStatus(2); // 2-已报名

        return teamDAO.update(team) > 0;
    }
}
