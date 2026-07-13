package com.poster.service.impl;

import com.poster.dao.*;
import com.poster.dao.impl.*;
import com.poster.model.*;
import com.poster.service.TeamApplicationService;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;

/**
 * 入队申请服务实现类
 * @author Claude
 * @date 2026-07-12
 */
public class TeamApplicationServiceImpl implements TeamApplicationService {
    private final TeamApplicationDAO applicationDAO;
    private final TeamDAO teamDAO;
    private final TeamMemberDAO teamMemberDAO;
    private final CompetitionDAO competitionDAO;
    private final UserRoleDAO userRoleDAO;

    public TeamApplicationServiceImpl() {
        this(new TeamApplicationDAOImpl(), new TeamDAOImpl(), new TeamMemberDAOImpl(),
                new CompetitionDAOImpl(), new UserRoleDAOImpl());
    }

    public TeamApplicationServiceImpl(TeamApplicationDAO applicationDAO, TeamDAO teamDAO,
                                      TeamMemberDAO teamMemberDAO, CompetitionDAO competitionDAO,
                                      UserRoleDAO userRoleDAO) {
        this.applicationDAO = Objects.requireNonNull(applicationDAO, "applicationDAO");
        this.teamDAO = Objects.requireNonNull(teamDAO, "teamDAO");
        this.teamMemberDAO = Objects.requireNonNull(teamMemberDAO, "teamMemberDAO");
        this.competitionDAO = Objects.requireNonNull(competitionDAO, "competitionDAO");
        this.userRoleDAO = Objects.requireNonNull(userRoleDAO, "userRoleDAO");
    }

    @Override
    public boolean applyToTeam(Integer teamId, Integer applicantId, String message) {
        if (teamId == null || applicantId == null) return false;
        Team team = teamDAO.findById(teamId);
        if (!canApply(team, applicantId)) return false;
        if (applicationDAO.findPendingByTeamIdAndApplicantId(teamId, applicantId) != null) return false;

        TeamApplication application = new TeamApplication();
        application.setTeamId(teamId);
        application.setApplicantId(applicantId);
        application.setMessage(message != null ? message.trim() : null);
        application.setStatus(0);
        return applicationDAO.insert(application) > 0;
    }

    @Override
    public boolean approveApplication(Integer applicationId, Integer leaderId) {
        if (applicationId == null || leaderId == null) return false;
        TeamApplication application = applicationDAO.findById(applicationId);
        if (application == null || application.getStatus() == null || application.getStatus() != 0) return false;
        Team team = teamDAO.findById(application.getTeamId());
        if (team == null || !leaderId.equals(team.getLeaderId())) return false;
        if (!canApply(team, application.getApplicantId())) return false;

        TeamMember member = new TeamMember();
        member.setTeamId(team.getTeamId());
        member.setUserId(application.getApplicantId());
        member.setRole(2);
        member.setJoinTime(LocalDateTime.now());
        if (teamMemberDAO.insert(member) <= 0) return false;

        application.setStatus(1);
        application.setResponseTime(LocalDateTime.now());
        if (applicationDAO.update(application) > 0) {
            return true;
        }

        // 申请状态更新失败时撤销刚插入的成员，避免页面报失败但队员已进入队伍。
        teamMemberDAO.deleteByTeamIdAndUserId(team.getTeamId(), application.getApplicantId());
        return false;
    }

    @Override
    public boolean rejectApplication(Integer applicationId, Integer leaderId) {
        if (applicationId == null || leaderId == null) return false;
        TeamApplication application = applicationDAO.findById(applicationId);
        if (application == null || application.getStatus() == null || application.getStatus() != 0) return false;
        Team team = teamDAO.findById(application.getTeamId());
        if (team == null || !leaderId.equals(team.getLeaderId())) return false;
        application.setStatus(2);
        application.setResponseTime(LocalDateTime.now());
        return applicationDAO.update(application) > 0;
    }

    @Override
    public boolean cancelApplication(Integer applicationId, Integer applicantId) {
        if (applicationId == null || applicantId == null) return false;
        TeamApplication application = applicationDAO.findById(applicationId);
        if (application == null || application.getStatus() == null || application.getStatus() != 0) return false;
        if (!applicantId.equals(application.getApplicantId())) return false;
        application.setStatus(3);
        application.setResponseTime(LocalDateTime.now());
        return applicationDAO.update(application) > 0;
    }

    @Override
    public List<TeamApplication> getApplicationsByApplicantId(Integer applicantId) {
        return applicationDAO.findByApplicantId(applicantId);
    }

    @Override
    public List<TeamApplication> getApplicationsByTeamId(Integer teamId) {
        return applicationDAO.findByTeamId(teamId);
    }

    @Override
    public List<TeamApplication> getPendingApplicationsByTeamId(Integer teamId) {
        return applicationDAO.findPendingByTeamId(teamId);
    }

    @Override
    public TeamApplication getPendingApplication(Integer teamId, Integer applicantId) {
        return applicationDAO.findPendingByTeamIdAndApplicantId(teamId, applicantId);
    }

    private boolean canApply(Team team, Integer applicantId) {
        if (team == null || applicantId == null) return false;
        if (team.getStatus() == null || team.getStatus() != 1) return false;
        Competition competition = competitionDAO.findById(team.getCompetitionId());
        if (competition == null || competition.getStatus() == null || competition.getStatus() != 1) return false;
        if (!isParticipant(applicantId)) return false;
        if (isUserMemberOfTeam(applicantId, team.getTeamId())) return false;
        if (getUserTeamInCompetition(applicantId, team.getCompetitionId()) != null) return false;
        int maxTeamSize = competition.getMaxTeamSize() != null && competition.getMaxTeamSize() > 0 ? competition.getMaxTeamSize() : 5;
        return teamMemberDAO.countByTeamId(team.getTeamId()) < maxTeamSize;
    }

    private boolean isParticipant(Integer userId) {
        List<Role> roles = userRoleDAO.findRolesByUserId(userId);
        boolean participant = false;
        boolean adminOrJudge = false;
        if (roles != null) {
            for (Role role : roles) {
                if ("队员".equals(role.getRoleName()) || "队长".equals(role.getRoleName())) participant = true;
                if ("管理员".equals(role.getRoleName()) || "评委".equals(role.getRoleName())) adminOrJudge = true;
            }
        }
        return participant && !adminOrJudge;
    }

    private boolean isUserMemberOfTeam(Integer userId, Integer teamId) {
        List<TeamMember> members = teamMemberDAO.findByTeamId(teamId);
        for (TeamMember member : members) {
            if (userId.equals(member.getUserId())) return true;
        }
        return false;
    }

    private Team getUserTeamInCompetition(Integer userId, Integer competitionId) {
        List<TeamMember> memberships = teamMemberDAO.findByUserId(userId);
        for (TeamMember member : memberships) {
            Team team = teamDAO.findById(member.getTeamId());
            if (team != null && competitionId.equals(team.getCompetitionId())
                    && team.getStatus() != null && team.getStatus() != 0) {
                return team;
            }
        }
        return null;
    }
}
