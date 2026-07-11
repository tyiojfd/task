package com.poster.service;

import com.poster.model.Score;
import java.util.List;

/**
 * 评分服务接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface ScoreService {

    /**
     * 评委评分
     */
    boolean addScore(Score score);

    /**
     * 更新评分（仅允许评分所属评委修改）
     */
    boolean updateScore(Score score, Integer judgeId);

    /**
     * 根据评分ID查询评分
     */
    Score getScoreById(Integer scoreId);

    /**
     * 根据作品ID查询所有评分
     */
    List<Score> getScoresByWorkId(Integer workId);

    /**
     * 根据评委ID查询所有评分
     */
    List<Score> getScoresByJudgeId(Integer judgeId);

    /**
     * 获取作品平均分
     */
    Double getAverageScore(Integer workId);

    /**
     * 检查评委是否已评分
     */
    boolean hasScored(Integer workId, Integer judgeId);
}
