package com.poster.service.impl;

import com.poster.dao.*;
import com.poster.dao.impl.*;
import com.poster.model.*;
import com.poster.service.WorkService;
import com.poster.util.SharePolicy;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 作品服务实现�?
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
        if (work.getTeamId() == null || work.getCompetitionId() == null) {
            return false;
        }
        if (work.getTitle() == null || work.getTitle().trim().isEmpty()) {
            return false;
        }
        if (work.getImagePath() == null || work.getImagePath().trim().isEmpty()) {
            return false;
        }

        work.setStatus(2);
        work.setSubmitTime(LocalDateTime.now());

        return workDAO.insert(work) > 0;
    }

    @Override
    public boolean updateWork(Work work) {
        if (work.getWorkId() == null) {
            return false;
        }
        if (work.getTitle() == null || work.getTitle().trim().isEmpty()) {
            return false;
        }

        Work existing = workDAO.findById(work.getWorkId());
        if (existing == null) {
            return false;
        }

        if (work.getImagePath() == null || work.getImagePath().trim().isEmpty()) {
            work.setImagePath(existing.getImagePath());
        }

        if (work.getStatus() == null) {
            work.setStatus(existing.getStatus());
        }

        return workDAO.update(work) > 0;
    }

    @Override
    public boolean deleteWork(Integer workId, Integer teamId) {
        if (workId == null || teamId == null) {
            return false;
        }

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
    public List<Work> getWorksByTeamIdAndCompetitionId(Integer teamId, Integer competitionId) {
        if (teamId == null || competitionId == null) {
            return new ArrayList<>();
        }
        return workDAO.findByTeamIdAndCompetitionId(teamId, competitionId);
    }

    @Override
    public boolean likeWork(Integer workId, Integer userId) {
        if (workId == null || userId == null) {
            return false;
        }

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

        if (workDAO.findById(workId) == null) {
            return false;
        }
        String normalizedPlatform = SharePolicy.normalizePlatform(platform);
        if (normalizedPlatform == null) {
            return false;
        }

        WorkShare workShare = new WorkShare();
        workShare.setWorkId(workId);
        workShare.setUserId(userId);
        workShare.setPlatform(normalizedPlatform);

        return workShareDAO.insert(workShare) > 0;
    }

    @Override
    public List<Work> getWorksByUserId(Integer userId) {
        if (userId == null) {
            return new ArrayList<>();
        }

        List<TeamMember> memberships = teamMemberDAO.findByUserId(userId);
        if (memberships.isEmpty()) {
            return new ArrayList<>();
        }

        List<Integer> teamIds = memberships.stream()
                .map(TeamMember::getTeamId)
                .collect(Collectors.toList());

        List<Work> allWorks = new ArrayList<>();
        for (Integer teamId : teamIds) {
            allWorks.addAll(workDAO.findByTeamId(teamId));
        }

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
    public int getShareCount(Integer workId) {
        if (workId == null) {
            return 0;
        }
        return workShareDAO.countByWorkId(workId);
    }

    @Override
    public boolean isWorkLikedByUser(Integer workId, Integer userId) {
        if (workId == null || userId == null) return false;
        return workLikeDAO.isLiked(workId, userId);
    }

    @Override
    public List<Work> searchWorksByUserTeams(Integer userId, String keyword) {
        if (userId == null) {
            return new ArrayList<>();
        }

        List<TeamMember> memberships = teamMemberDAO.findByUserId(userId);
        if (memberships.isEmpty()) {
            return new ArrayList<>();
        }

        List<Integer> teamIds = memberships.stream()
                .map(TeamMember::getTeamId)
                .collect(Collectors.toList());

        return workDAO.findByTeamIdsAndKeyword(teamIds, keyword);
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
