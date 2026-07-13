package com.poster.service.impl;

import com.poster.dao.ScoreDAO;
import com.poster.dao.CommentDAO;
import com.poster.dao.impl.ScoreDAOImpl;
import com.poster.dao.impl.CommentDAOImpl;
import com.poster.dao.WorkDAO;
import com.poster.dao.impl.WorkDAOImpl;
import com.poster.model.Score;
import com.poster.model.Work;
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
    private WorkDAO workDAO = new WorkDAOImpl();

    @Override
    public boolean addScore(Score score) {
        if (score == null) {
            return false;
        }
        // 1. 验证评分范围（0-100）
        if (score.getScore() == null || score.getScore().isNaN() || score.getScore().isInfinite()
                || score.getScore() < 0 || score.getScore() > 100) {
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

        // 4. 插入评分并同步作品状态，避免作品永远停留在“已提交”。
        if (scoreDAO.insert(score) <= 0) {
            return false;
        }
        if (!markWorkAsScored(score.getWorkId())) {
            if (score.getScoreId() != null) {
                scoreDAO.deleteById(score.getScoreId());
            }
            return false;
        }
        return true;
    }

    @Override
    public boolean updateScore(Score score, Integer judgeId) {
        // 1. 验证评分范围（0-100）
        if (score.getScore() == null || score.getScore().isNaN() || score.getScore().isInfinite()
                || score.getScore() < 0 || score.getScore() > 100) {
            return false;
        }

        // 2. 验证必要字段
        if (score.getScoreId() == null || judgeId == null) {
            return false;
        }

        // 3. 仅允许评分所属评委更新
        Score existing = scoreDAO.findById(score.getScoreId());
        if (existing == null || !judgeId.equals(existing.getJudgeId())) {
            return false;
        }
        score.setWorkId(existing.getWorkId());
        score.setJudgeId(judgeId);
        if (scoreDAO.update(score) <= 0) {
            return false;
        }
        return markWorkAsScored(score.getWorkId());
    }

    @Override
    public Score getScoreById(Integer scoreId) {
        if (scoreId == null) {
            return null;
        }
        return scoreDAO.findById(scoreId);
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
        if (scores == null) {
            return false;
        }
        for (Score s : scores) {
            if (s != null && judgeId.equals(s.getJudgeId())) {
                return true;
            }
        }
        return false;
    }

    private boolean markWorkAsScored(Integer workId) {
        Work work = workDAO.findById(workId);
        if (work == null) {
            return false;
        }
        if (Integer.valueOf(3).equals(work.getStatus())) {
            return true;
        }
        work.setStatus(3);
        return workDAO.update(work) > 0;
    }
}
