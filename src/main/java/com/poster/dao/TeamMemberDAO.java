package com.poster.dao;

import com.poster.model.TeamMember;
import java.util.List;

/**
 * 队伍成员DAO接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface TeamMemberDAO {

    /**
     * 插入队伍成员
     */
    int insert(TeamMember teamMember);

    /**
     * 根据ID删除队伍成员
     */
    int deleteById(Integer id);

    /**
     * 根据队伍ID和用户ID删除成员
     */
    int deleteByTeamIdAndUserId(Integer teamId, Integer userId);

    /**
     * 更新成员角色
     */
    int update(TeamMember teamMember);

    /**
     * 根据ID查询队伍成员
     */
    TeamMember findById(Integer id);

    /**
     * 根据队伍ID查询所有成员
     */
    List<TeamMember> findByTeamId(Integer teamId);

    /**
     * 根据用户ID查询所有参与的队伍
     */
    List<TeamMember> findByUserId(Integer userId);

    /**
     * 统计队伍成员数量
     */
    int countByTeamId(Integer teamId);
}
