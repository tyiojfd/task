package com.poster.dao;

import com.poster.model.Competition;
import java.util.List;

/**
 * 竞赛DAO接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface CompetitionDAO {

    /**
     * 插入竞赛
     */
    int insert(Competition competition);

    /**
     * 根据ID删除竞赛
     */
    int deleteById(Integer competitionId);

    /**
     * 更新竞赛信息
     */
    int update(Competition competition);

    /**
     * 根据ID查询竞赛
     */
    Competition findById(Integer competitionId);

    /**
     * 查询所有竞赛
     */
    List<Competition> findAll();

    /**
     * 根据年度查询竞赛
     */
    List<Competition> findByYear(Integer year);

    /**
     * 根据状态查询竞赛
     */
    List<Competition> findByStatus(Integer status);

    /**
     * 根据创建人查询竞赛
     */
    List<Competition> findByCreatorId(Integer creatorId);

    /**
     * 统计竞赛总数
     */
    int count();
}
