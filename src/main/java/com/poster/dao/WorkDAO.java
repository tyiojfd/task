package com.poster.dao;

import com.poster.model.Work;
import java.util.List;

/**
 * 作品DAO接口
 * @author 队员B
 * @date 2026-07-06
 */
public interface WorkDAO {

    /**
     * 插入作品
     */
    int insert(Work work);

    /**
     * 根据ID删除作品
     */
    int deleteById(Integer workId);

    /**
     * 更新作品信息
     */
    int update(Work work);

    /**
     * 根据ID查询作品
     */
    Work findById(Integer workId);

    /**
     * 查询所有作品
     */
    List<Work> findAll();

    /**
     * 根据队伍ID查询作品
     */
    List<Work> findByTeamId(Integer teamId);

    /**
     * 根据竞赛ID查询作品
     */
    List<Work> findByCompetitionId(Integer competitionId);

    /**
     * 根据状态查询作品
     */
    List<Work> findByStatus(Integer status);

    /**
     * 统计作品总数
     */
    int count();

    /**
     * 根据队伍ID和竞赛ID查询作品
     */
    List<Work> findByTeamIdAndCompetitionId(Integer teamId, Integer competitionId);

    /**
     * 统计指定竞赛的作品数
     */
    int countByCompetitionId(Integer competitionId);
}
