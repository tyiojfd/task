package com.poster.service;

import com.poster.model.Team;
import java.util.List;

/**
 * 队伍服务接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface TeamService {

    /**
     * 创建队伍
     */
    boolean createTeam(Team team, Integer leaderId);

    /**
     * 更新队伍信息
     */
    boolean updateTeam(Team team);

    /**
     * 解散队伍
     */
    boolean deleteTeam(Integer teamId, Integer leaderId);

    /**
     * 根据ID查询队伍
     */
    Team getTeamById(Integer teamId);

    /**
     * 根据队长ID查询队伍
     */
    List<Team> getTeamsByLeaderId(Integer leaderId);

    /**
     * 根据竞赛ID查询队伍
     */
    List<Team> getTeamsByCompetitionId(Integer competitionId);

    /**
     * 获取用户参与的所有队伍（含队长和队员身份）
     */
    List<Team> getTeamsByUserId(Integer userId);

    /**
     * 获取用户在某竞赛中的队伍（含队长和队员身份）
     */
    Team getUserTeamInCompetition(Integer userId, Integer competitionId);

    /**
     * 判断用户是否为某队伍队长
     */
    boolean isUserLeaderOfTeam(Integer userId, Integer teamId);

    /**
     * 判断用户是否属于某队伍成员
     */
    boolean isUserMemberOfTeam(Integer userId, Integer teamId);

    /**
     * 邀请队员
     */
    boolean inviteMember(Integer teamId, Integer inviterId, Integer inviteeId);

    /**
     * 移除队员
     */
    boolean removeMember(Integer teamId, Integer leaderId, Integer memberId);

    /**
     * 报名竞赛
     */
    boolean registerCompetition(Integer teamId, Integer competitionId, Integer categoryId);
}
