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
 * @author 队员C
 * @date 2026-07-07
 */
public class ScoreServiceImpl implements ScoreService {

    private ScoreDAO scoreDAO = new ScoreDAOImpl();
    private CommentDAO commentDAO = new CommentDAOImpl();

    @Override
    public boolean addScore(Score score) {
        // 1. 验证评分范围（0-100）
        if (score.getScore() == null || score.getScore() < 0 || score.getScore() > 100) {
            return false;
        }

        // 2. 验证必要字段
        if (score.getWorkId() == null || score.getJudgeId() == null) {
            return false;
        }

        // 3. 检查是否已评分（一个评委对一个作品只能评一次）
        if (hasScored(score.getWorkId(), score.getJudgeId())) {
            return false;
        }

        // 4. 调用DAO插入数据库
        return scoreDAO.insert(score) > 0;
    }

    @Override
    public boolean updateScore(Score score) {
        // 1. 验证评分范围（0-100）
        if (score.getScore() == null || score.getScore() < 0 || score.getScore() > 100) {
            return false;
        }

        // 2. 验证必要字段
        if (score.getScoreId() == null) {
            return false;
        }

        // 3. 调用DAO更新数据库
        return scoreDAO.update(score) > 0;
    }

    @Override
    public List<Score> getScoresByWorkId(Integer workId) {
        if (workId == null) {
            return null;
        }
        return scoreDAO.findByWorkId(workId);
    }

    @Override
    public List<Score> getScoresByJudgeId(Integer judgeId) {
        if (judgeId == null) {
            return null;
        }
        return scoreDAO.findByJudgeId(judgeId);
    }

    @Override
    public Double getAverageScore(Integer workId) {
        if (workId == null) {
            return null;
        }
        return scoreDAO.getAverageScoreByWorkId(workId);
    }

    @Override
    public boolean hasScored(Integer workId, Integer judgeId) {
        if (workId == null || judgeId == null) {
            return false;
        }
        // 查询该作品的所有评分，检查是否有当前评委的评分记录
        List<Score> scores = scoreDAO.findByWorkId(workId);
        for (Score s : scores) {
            if (s.getJudgeId().equals(judgeId)) {
                return true;
            }
        }
        return false;
    }
}
