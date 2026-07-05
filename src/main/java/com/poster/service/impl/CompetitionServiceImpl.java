package com.poster.service.impl;

import com.poster.dao.CompetitionDAO;
import com.poster.dao.impl.CompetitionDAOImpl;
import com.poster.model.Competition;
import com.poster.service.CompetitionService;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 竞赛服务实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class CompetitionServiceImpl implements CompetitionService {

    private CompetitionDAO competitionDAO = new CompetitionDAOImpl();

    @Override
    public boolean createCompetition(Competition competition) {
        // 验证必填字段
        if (competition.getName() == null || competition.getName().trim().isEmpty()) {
            return false;
        }
        if (competition.getYear() == null || competition.getSubmitDeadline() == null) {
            return false;
        }

        // 设置默认值
        if (competition.getStatus() == null) {
            competition.setStatus(1); // 默认状态：报名中
        }
        if (competition.getMaxTeamSize() == null) {
            competition.setMaxTeamSize(5); // 默认最大队伍人数
        }
        competition.setCreateTime(LocalDateTime.now());

        // 调用DAO插入
        return competitionDAO.insert(competition) > 0;
    }

    @Override
    public boolean updateCompetition(Competition competition) {
        // 验证必填字段
        if (competition.getCompetitionId() == null) {
            return false;
        }
        if (competition.getName() == null || competition.getName().trim().isEmpty()) {
            return false;
        }

        // 调用DAO更新
        return competitionDAO.update(competition) > 0;
    }

    @Override
    public boolean deleteCompetition(Integer competitionId) {
        if (competitionId == null) {
            return false;
        }

        // 调用DAO删除
        return competitionDAO.deleteById(competitionId) > 0;
    }

    @Override
    public Competition getCompetitionById(Integer competitionId) {
        if (competitionId == null) {
            return null;
        }
        return competitionDAO.findById(competitionId);
    }

    @Override
    public List<Competition> getAllCompetitions() {
        return competitionDAO.findAll();
    }

    @Override
    public List<Competition> getCompetitionsByYear(Integer year) {
        if (year == null) {
            return null;
        }
        return competitionDAO.findByYear(year);
    }

    @Override
    public List<Competition> getCompetitionsByStatus(Integer status) {
        if (status == null) {
            return null;
        }
        return competitionDAO.findByStatus(status);
    }

    @Override
    public boolean updateCompetitionStatus(Integer competitionId, Integer status) {
        if (competitionId == null || status == null) {
            return false;
        }

        Competition competition = competitionDAO.findById(competitionId);
        if (competition == null) {
            return false;
        }

        competition.setStatus(status);
        return competitionDAO.update(competition) > 0;
    }
}
