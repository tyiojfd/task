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

    /**
     * 根据队伍ID列表和关键词搜索作品（关键词匹配作品标题）
     */
    List<Work> findByTeamIdsAndKeyword(List<Integer> teamIds, String keyword);

    /**
     * 分页查询所有作品
     */
    List<Work> findAllWithLimit(int offset, int limit);

    /**
     * 分页查询指定竞赛作品
     */
    List<Work> findByCompetitionIdWithLimit(Integer competitionId, int offset, int limit);

    /**
     * 统计指定队伍ID列表的作品数
     */
    int countByTeamIds(List<Integer> teamIds);

    /**
     * 分页查询指定队伍ID列表的作品（按提交时间倒序）
     */
    List<Work> findByTeamIdsWithLimit(List<Integer> teamIds, int offset, int limit);

    /**
     * 分页搜索：根据队伍ID列表和关键词搜索作品
     */
    List<Work> findByTeamIdsAndKeywordWithLimit(List<Integer> teamIds, String keyword, int offset, int limit);

    /**
     * 统计：根据队伍ID列表和关键词统计作品数
     */
    int countByTeamIdsAndKeyword(List<Integer> teamIds, String keyword);
}
