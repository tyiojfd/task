package com.poster.service.impl;

import com.poster.dao.InvitationDAO;
import com.poster.dao.TeamDAO;
import com.poster.dao.TeamMemberDAO;
import com.poster.dao.CompetitionDAO;
import com.poster.dao.UserRoleDAO;
import com.poster.dao.impl.InvitationDAOImpl;
import com.poster.dao.impl.TeamDAOImpl;
import com.poster.dao.impl.TeamMemberDAOImpl;
import com.poster.dao.impl.CompetitionDAOImpl;
import com.poster.dao.impl.UserRoleDAOImpl;
import com.poster.model.Invitation;
import com.poster.model.Team;
import com.poster.model.TeamMember;
import com.poster.model.Competition;
import com.poster.model.Role;
import com.poster.service.InvitationService;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 邀请服务实现类
 * @author 杨祥博
 * @date 2026-07-06
 */
public class InvitationServiceImpl implements InvitationService {

    private InvitationDAO invitationDAO = new InvitationDAOImpl();
    private TeamDAO teamDAO = new TeamDAOImpl();
    private TeamMemberDAO teamMemberDAO = new TeamMemberDAOImpl();
    private CompetitionDAO competitionDAO = new CompetitionDAOImpl();
    private UserRoleDAO userRoleDAO = new UserRoleDAOImpl();

    @Override
    public List<Invitation> getInvitationsForUser(Integer userId) {
        if (userId == null) {
            return null;
        }
        return invitationDAO.findByInviteeId(userId);
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
    public boolean acceptInvitation(Integer invitationId, Integer userId) {
        // 1. 参数校验
        if (invitationId == null || userId == null) {
            return false;
        }

        // 2. 获取邀请记录
        Invitation invitation = invitationDAO.findById(invitationId);
        if (invitation == null) {
            return false;
        }

        // 3. 验证邀请状态为"待处理"
        if (invitation.getStatus() == null || invitation.getStatus() != 0) {
            return false;
        }

        // 4. 验证被邀请人与当前用户一致
        if (!invitation.getInviteeId().equals(userId)) {
            return false;
        }

        // 5. 被邀请人必须仍是参赛方账号，防止历史脏邀请让管理员/评委加入队伍。
        if (!isInviteEligibleParticipant(userId)) {
            return false;
        }

        // 6. 检查队伍是否存在且状态正常
        Team team = teamDAO.findById(invitation.getTeamId());
        if (team == null || team.getStatus() == null || team.getStatus() == 0) {
            return false;
        }

        // 6. 检查队伍人数上限（使用竞赛配置的maxTeamSize）
        int memberCount = teamMemberDAO.countByTeamId(invitation.getTeamId());
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

        // 7. 检查是否已是队伍成员
        List<TeamMember> members = teamMemberDAO.findByTeamId(invitation.getTeamId());
        for (TeamMember member : members) {
            if (member.getUserId().equals(userId)) {
                return false;
            }
        }

        // 8. 检查是否已在同竞赛其他队伍中
        List<TeamMember> myMemberships = teamMemberDAO.findByUserId(userId);
        if (myMemberships != null) {
            for (TeamMember membership : myMemberships) {
                Team joinedTeam = teamDAO.findById(membership.getTeamId());
                if (joinedTeam != null && joinedTeam.getCompetitionId() != null
                        && joinedTeam.getCompetitionId().equals(team.getCompetitionId())
                        && !joinedTeam.getTeamId().equals(team.getTeamId())
                        && joinedTeam.getStatus() != null && joinedTeam.getStatus() != 0) {
                    return false;
                }
            }
        }

        // 8. 添加到队伍成员
        TeamMember newMember = new TeamMember();
        newMember.setTeamId(invitation.getTeamId());
        newMember.setUserId(userId);
        newMember.setRole(2); // 2=队员
        newMember.setJoinTime(LocalDateTime.now());
        int insertResult = teamMemberDAO.insert(newMember);

        if (insertResult <= 0) {
            return false;
        }

        // 9. 更新邀请状态为"已接受"
        invitation.setStatus(1);
        invitation.setResponseTime(LocalDateTime.now());
        invitationDAO.update(invitation);

        return true;
    }

    @Override
    public boolean rejectInvitation(Integer invitationId, Integer userId) {
        // 1. 参数校验
        if (invitationId == null || userId == null) {
            return false;
        }

        // 2. 获取邀请记录
        Invitation invitation = invitationDAO.findById(invitationId);
        if (invitation == null) {
            return false;
        }

        // 3. 验证邀请状态为"待处理"
        if (invitation.getStatus() == null || invitation.getStatus() != 0) {
            return false;
        }

        // 4. 验证被邀请人与当前用户一致
        if (!invitation.getInviteeId().equals(userId)) {
            return false;
        }

        // 5. 更新邀请状态为"已拒绝"
        invitation.setStatus(2);
        invitation.setResponseTime(LocalDateTime.now());
        invitationDAO.update(invitation);

        return true;
    }
}
