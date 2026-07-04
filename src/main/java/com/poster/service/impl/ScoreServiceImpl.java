package com.poster.service.impl;

import com.poster.dao.ScoreDAO;
import com.poster.dao.CommentDAO;
import com.poster.dao.impl.ScoreDAOImpl;
import com.poster.dao.impl.CommentDAOImpl;
import com.poster.model.Score;
import com.poster.service.ScoreService;

import java.util.List;

/**
 * 评分服务实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class ScoreServiceImpl implements ScoreService {

    private ScoreDAO scoreDAO = new ScoreDAOImpl();
    private CommentDAO commentDAO = new CommentDAOImpl();

    @Override
    public boolean addScore(Score score) {
        // TODO: 实现评分逻辑
        // 1. 验证评分范围（0-100）
        // 2. 检查是否已评分
        // 3. 调用DAO插入数据库
        return false;
    }

    @Override
    public boolean updateScore(Score score) {
        // TODO: 实现更新评分逻辑
        return false;
    }

    @Override
    public List<Score> getScoresByWorkId(Integer workId) {
        // TODO: 实现根据作品ID查询所有评分
        return null;
    }

    @Override
    public List<Score> getScoresByJudgeId(Integer judgeId) {
        // TODO: 实现根据评委ID查询所有评分
        return null;
    }

    @Override
    public Double getAverageScore(Integer workId) {
        // TODO: 实现获取作品平均分
        return null;
    }

    @Override
    public boolean hasScored(Integer workId, Integer judgeId) {
        // TODO: 实现检查评委是否已评分
        return false;
    }
}
