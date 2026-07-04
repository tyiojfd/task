package com.poster.dao;

import com.poster.model.Score;
import java.util.List;

/**
 * 评分记录DAO接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface ScoreDAO {

    /**
     * 插入评分记录
     */
    int insert(Score score);

    /**
     * 根据ID删除评分记录
     */
    int deleteById(Integer scoreId);

    /**
     * 更新评分
     */
    int update(Score score);

    /**
     * 根据ID查询评分记录
     */
    Score findById(Integer scoreId);

    /**
     * 根据作品ID查询所有评分
     */
    List<Score> findByWorkId(Integer workId);

    /**
     * 根据评委ID查询所有评分
     */
    List<Score> findByJudgeId(Integer judgeId);

    /**
     * 查询作品的平均分
     */
    Double getAverageScoreByWorkId(Integer workId);

    /**
     * 查询所有评分记录
     */
    List<Score> findAll();
}
