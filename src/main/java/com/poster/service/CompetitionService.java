package com.poster.service;

import com.poster.model.Competition;
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
}
