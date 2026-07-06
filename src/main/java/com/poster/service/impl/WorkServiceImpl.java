package com.poster.service.impl;

import com.poster.dao.*;
import com.poster.dao.impl.*;
import com.poster.model.*;
import com.poster.service.WorkService;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 作品服务实现类
 * @author 队员B
 * @date 2026-07-06
 */
public class WorkServiceImpl implements WorkService {

    private WorkDAO workDAO = new WorkDAOImpl();
    private WorkLikeDAO workLikeDAO = new WorkLikeDAOImpl();
    private WorkShareDAO workShareDAO = new WorkShareDAOImpl();
    private TeamMemberDAO teamMemberDAO = new TeamMemberDAOImpl();
    private TeamDAO teamDAO = new TeamDAOImpl();

    @Override
    public boolean submitWork(Work work) {
        // 1. 输入验证
        if (work.getTeamId() == null || work.getCompetitionId() == null) {
            return false;
        }
        if (work.getTitle() == null || work.getTitle().trim().isEmpty()) {
            return false;
        }
        if (work.getImagePath() == null || work.getImagePath().trim().isEmpty()) {
            return false;
        }

        // 2. 设置提交时间和状态（2-已提交）
        work.setStatus(2);
        work.setSubmitTime(LocalDateTime.now());

        // 3. 调用DAO插入数据库
        return workDAO.insert(work) > 0;
    }

    @Override
    public boolean updateWork(Work work) {
        // 1. 输入验证
        if (work.getWorkId() == null) {
            return false;
        }
        if (work.getTitle() == null || work.getTitle().trim().isEmpty()) {
            return false;
        }

        // 2. 保留原始提交时间
        Work existing = workDAO.findById(work.getWorkId());
        if (existing == null) {
            return false;
        }

        // 3. 保留原有图片路径（如果没上传新图）
        if (work.getImagePath() == null || work.getImagePath().trim().isEmpty()) {
            work.setImagePath(existing.getImagePath());
        }

        // 4. 保留原有状态（不要降级）
        if (work.getStatus() == null) {
            work.setStatus(existing.getStatus());
        }

        // 5. 调用DAO更新
        return workDAO.update(work) > 0;
    }

    @Override
    public boolean deleteWork(Integer workId, Integer teamId) {
        if (workId == null || teamId == null) {
            return false;
        }

        // 验证作品属于该队伍
        Work work = workDAO.findById(workId);
        if (work == null || !work.getTeamId().equals(teamId)) {
            return false;
        }

        return workDAO.deleteById(workId) > 0;
    }

    @Override
    public Work getWorkById(Integer workId) {
        if (workId == null) {
            return null;
        }
        return workDAO.findById(workId);
    }

    @Override
    public List<Work> getWorksByTeamId(Integer teamId) {
        if (teamId == null) {
            return new ArrayList<>();
        }
        return workDAO.findByTeamId(teamId);
    }

    @Override
    public List<Work> getWorksByCompetitionId(Integer competitionId) {
        if (competitionId == null) {
            return new ArrayList<>();
        }
        return workDAO.findByCompetitionId(competitionId);
    }

    @Override
    public boolean likeWork(Integer workId, Integer userId) {
        if (workId == null || userId == null) {
            return false;
        }

        // 检查是否已点赞
        if (workLikeDAO.isLiked(workId, userId)) {
            return false;
        }

        WorkLike workLike = new WorkLike();
        workLike.setWorkId(workId);
        workLike.setUserId(userId);

        return workLikeDAO.insert(workLike) > 0;
    }

    @Override
    public boolean unlikeWork(Integer workId, Integer userId) {
        if (workId == null || userId == null) {
            return false;
        }
        return workLikeDAO.deleteByWorkIdAndUserId(workId, userId) > 0;
    }

    @Override
    public boolean shareWork(Integer workId, Integer userId, String platform) {
        if (workId == null || userId == null) {
            return false;
        }

        WorkShare workShare = new WorkShare();
        workShare.setWorkId(workId);
        workShare.setUserId(userId);
        workShare.setPlatform(platform);

        return workShareDAO.insert(workShare) > 0;
    }

    @Override
    public List<Work> getWorksByUserId(Integer userId) {
        if (userId == null) {
            return new ArrayList<>();
        }

        // 获取用户所在的所有队伍ID
        List<TeamMember> memberships = teamMemberDAO.findByUserId(userId);
        if (memberships.isEmpty()) {
            return new ArrayList<>();
        }

        List<Integer> teamIds = memberships.stream()
                .map(TeamMember::getTeamId)
                .collect(Collectors.toList());

        // 查询这些队伍的所有作品
        List<Work> allWorks = new ArrayList<>();
        for (Integer teamId : teamIds) {
            allWorks.addAll(workDAO.findByTeamId(teamId));
        }

        // 按提交时间降序排列
        allWorks.sort((a, b) -> {
            if (a.getSubmitTime() == null && b.getSubmitTime() == null) return 0;
            if (a.getSubmitTime() == null) return 1;
            if (b.getSubmitTime() == null) return -1;
            return b.getSubmitTime().compareTo(a.getSubmitTime());
        });

        return allWorks;
    }

    @Override
    public int getLikeCount(Integer workId) {
        if (workId == null) return 0;
        return workLikeDAO.countByWorkId(workId);
    }

    @Override
    public boolean isWorkLikedByUser(Integer workId, Integer userId) {
        if (workId == null || userId == null) return false;
        return workLikeDAO.isLiked(workId, userId);
    }

    /**
     * 校验提交时间是否在竞赛截止日期前
     */
    public boolean isBeforeDeadline(LocalDateTime submitDeadline) {
        if (submitDeadline == null) {
            return true;
        }
        return LocalDateTime.now().isBefore(submitDeadline);
    }
}
