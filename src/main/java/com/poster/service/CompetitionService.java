package com.poster.service;

import com.poster.model.Competition;
import com.poster.model.PageInfo;
import java.util.List;

/**
 * 竞赛服务接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface CompetitionService {

    /**
     * 创建竞赛
     */
    boolean createCompetition(Competition competition);

    /**
     * 更新竞赛信息
     */
    boolean updateCompetition(Competition competition);

    /**
     * 删除竞赛
     */
    boolean deleteCompetition(Integer competitionId);

    /**
     * 根据ID查询竞赛
     */
    Competition getCompetitionById(Integer competitionId);

    /**
     * 查询所有竞赛
     */
    List<Competition> getAllCompetitions();

    /**
     * 根据年度查询竞赛
     */
    List<Competition> getCompetitionsByYear(Integer year);

    /**
     * 根据状态查询竞赛
     */
    List<Competition> getCompetitionsByStatus(Integer status);

    /**
     * 更新竞赛状态
     */
    boolean updateCompetitionStatus(Integer competitionId, Integer status);

    /**
     * 取消竞赛
     */
    boolean cancelCompetition(Integer competitionId);

    /**
     * 多条件搜索竞赛
     */
    List<Competition> searchCompetitions(String keyword, Integer year, Integer status);

    /**
     * 分页多条件搜索竞赛
     */
    List<Competition> searchCompetitionsPaginated(String keyword, Integer year, Integer status,
                                                   int page, int pageSize);

    /**
     * 统计所有竞赛
     */
    int getCompetitionCount();

    /**
     * 按条件统计竞赛数
     */
    int countByFilters(String keyword, Integer year, Integer status);

    /**
     * 获取竞赛统计信息
     */
    java.util.Map<String, Integer> getCompetitionStats(Integer competitionId);
}
