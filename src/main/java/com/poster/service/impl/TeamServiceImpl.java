package com.poster.service.impl;

import com.poster.dao.TeamDAO;
import com.poster.dao.TeamMemberDAO;
import com.poster.dao.InvitationDAO;
import com.poster.dao.CompetitionDAO;
import com.poster.dao.UserRoleDAO;
import com.poster.dao.impl.TeamDAOImpl;
import com.poster.dao.impl.TeamMemberDAOImpl;
import com.poster.dao.impl.InvitationDAOImpl;
import com.poster.dao.impl.CompetitionDAOImpl;
import com.poster.dao.impl.UserRoleDAOImpl;
import com.poster.model.Team;
import com.poster.model.TeamMember;
import com.poster.model.Invitation;
import com.poster.model.Competition;
import com.poster.model.Role;
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
    private CompetitionDAO competitionDAO = new CompetitionDAOImpl();
    private UserRoleDAO userRoleDAO = new UserRoleDAOImpl();

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

        // 检查用户是否已在该竞赛中有队伍（含队长和队员身份）
        Team existingTeam = getUserTeamInCompetition(leaderId, team.getCompetitionId());
        if (existingTeam != null) {
            return false; // 同一用户同一竞赛不得重复建队
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
    public List<Team> getTeamsByUserId(Integer userId) {
        if (userId == null) {
            return null;
        }
        List<TeamMember> memberships = teamMemberDAO.findByUserId(userId);
        java.util.ArrayList<Team> teams = new java.util.ArrayList<>();
        if (memberships != null) {
            for (TeamMember member : memberships) {
                Team team = teamDAO.findById(member.getTeamId());
                if (team != null) {
                    teams.add(team);
                }
            }
        }
        return teams;
    }

    @Override
    public Team getUserTeamInCompetition(Integer userId, Integer competitionId) {
        if (userId == null || competitionId == null) {
            return null;
        }
        List<Team> teams = getTeamsByUserId(userId);
        if (teams == null) {
            return null;
        }
        for (Team team : teams) {
            if (competitionId.equals(team.getCompetitionId()) && team.getStatus() != null && team.getStatus() != 0) {
                return team;
            }
        }
        return null;
    }

    @Override
    public boolean isUserLeaderOfTeam(Integer userId, Integer teamId) {
        if (userId == null || teamId == null) {
            return false;
        }
        Team team = teamDAO.findById(teamId);
        return team != null && userId.equals(team.getLeaderId());
    }

    @Override
    public boolean isUserMemberOfTeam(Integer userId, Integer teamId) {
        if (userId == null || teamId == null) {
            return false;
        }
        List<TeamMember> members = teamMemberDAO.findByTeamId(teamId);
        if (members == null) {
            return false;
        }
        for (TeamMember member : members) {
            if (userId.equals(member.getUserId())) {
                return true;
            }
        }
        return false;
    }

    private boolean isInviteEligibleParticipant(Integer userId) {
        if (userId == null) return false;
        List<Role> roles = userRoleDAO.findRolesByUserId(userId);
        boolean isAdmin = false;
        boolean isJudge = false;
        boolean isParticipant = false;
        if (roles != null) {
            for (Role role : roles) {
                if ("管理员".equals(role.getRoleName())) isAdmin = true;
                if ("评委".equals(role.getRoleName())) isJudge = true;
                if ("队员".equals(role.getRoleName()) || "队长".equals(role.getRoleName())) isParticipant = true;
            }
        }
        return isParticipant && !isAdmin && !isJudge;
    }

    @Override
    public boolean inviteMember(Integer teamId, Integer inviterId, Integer inviteeId) {
        if (teamId == null || inviterId == null || inviteeId == null) {
            return false;
        }

        // 检查邀请人必须是该队队长
        if (!isUserLeaderOfTeam(inviterId, teamId)) {
            return false;
        }

        if (inviterId.equals(inviteeId)) {
            return false;
        }

        // 被邀请人必须是参赛方账号（队员/队长），不能邀请管理员或评委。
        if (!isInviteEligibleParticipant(inviteeId)) {
            return false;
        }

        // 检查队伍是否存在
        Team team = teamDAO.findById(teamId);
        if (team == null) {
            return false;
        }

        // 检查队伍人数是否已满（使用竞赛配置的maxTeamSize）
        int memberCount = teamMemberDAO.countByTeamId(teamId);
        int maxTeamSize = 5; // 默认值
        if (team.getCompetitionId() != null) {
            Competition comp = competitionDAO.findById(team.getCompetitionId());
            if (comp != null && comp.getMaxTeamSize() != null && comp.getMaxTeamSize() > 0) {
                maxTeamSize = comp.getMaxTeamSize();
            }
        }
        if (memberCount >= maxTeamSize) {
            return false;
        }

        // 检查是否已是队伍成员
        List<TeamMember> members = teamMemberDAO.findByTeamId(teamId);
        for (TeamMember member : members) {
            if (member.getUserId().equals(inviteeId)) {
                return false; // 已是队伍成员
            }
        }

        // 检查被邀请人是否已在同竞赛的其他队伍中
        Team joinedTeam = getUserTeamInCompetition(inviteeId, team.getCompetitionId());
        if (joinedTeam != null) {
            return false;
        }

        // 避免重复待处理邀请
        List<Invitation> invitations = invitationDAO.findByTeamId(teamId);
        if (invitations != null) {
            for (Invitation inv : invitations) {
                if (inviteeId.equals(inv.getInviteeId()) && inv.getStatus() != null && inv.getStatus() == 0) {
                    return false;
                }
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

    @Override
    public boolean cancelRegistration(Integer teamId, Integer leaderId) {
        if (teamId == null || leaderId == null) {
            return false;
        }

        // 验证是否为队长
        Team team = teamDAO.findById(teamId);
        if (team == null || !team.getLeaderId().equals(leaderId)) {
            return false;
        }

        // 只有已报名状态（status=2）才能取消报名
        if (team.getStatus() == null || team.getStatus() != 2) {
            return false;
        }

        // 恢复为组建中状态
        team.setStatus(1);
        return teamDAO.update(team) > 0;
    }
}
