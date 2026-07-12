package com.poster.dao;

import com.poster.model.Team;
import java.util.List;

/**
 * 队伍DAO接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface TeamDAO {

    /**
     * 插入队伍
     */
    int insert(Team team);

    /**
     * 根据ID删除队伍
     */
    int deleteById(Integer teamId);

    /**
     * 更新队伍信息
     */
    int update(Team team);

    /**
     * 根据ID查询队伍
     */
    Team findById(Integer teamId);

    /**
     * 查询所有队伍
     */
    List<Team> findAll();

    /**
     * 根据队长ID查询队伍
     */
    List<Team> findByLeaderId(Integer leaderId);

    /**
     * 根据竞赛ID查询队伍
     */
    List<Team> findByCompetitionId(Integer competitionId);

    /**
     * 根据状态查询队伍
     */
    List<Team> findByStatus(Integer status);

    /**
     * 根据队名模糊搜索队伍
     */
    List<Team> searchByTeamName(String keyword);

    /**
     * 统计队伍总数
     */
    int count();
}
