package com.poster.dao;

import com.poster.model.Award;
import java.util.List;

/**
 * 获奖设置DAO接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface AwardDAO {

    /**
     * 插入获奖记录
     */
    int insert(Award award);

    /**
     * 根据ID删除获奖记录
     */
    int deleteById(Integer awardId);

    /**
     * 更新获奖信息
     */
    int update(Award award);

    /**
     * 根据ID查询获奖记录
     */
    Award findById(Integer awardId);

    /**
     * 根据竞赛ID查询所有获奖记录
     */
    List<Award> findByCompetitionId(Integer competitionId);

    /**
     * 根据作品ID查询获奖记录
     */
    Award findByWorkId(Integer workId);

    /**
     * 查询所有获奖记录
     */
    List<Award> findAll();
}
