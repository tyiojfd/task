package com.poster.service.impl;

import com.poster.dao.CompetitionDAO;
import com.poster.dao.TeamDAO;
import com.poster.dao.WorkDAO;
import com.poster.dao.impl.CompetitionDAOImpl;
import com.poster.dao.impl.TeamDAOImpl;
import com.poster.dao.impl.WorkDAOImpl;
import com.poster.model.Competition;
import com.poster.model.Team;
import com.poster.model.Work;
import com.poster.service.CompetitionService;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 竞赛服务实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class CompetitionServiceImpl implements CompetitionService {

    private CompetitionDAO competitionDAO = new CompetitionDAOImpl();
    private TeamDAO teamDAO = new TeamDAOImpl();
    private WorkDAO workDAO = new WorkDAOImpl();

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

    @Override
    public boolean cancelCompetition(Integer competitionId) {
        return updateCompetitionStatus(competitionId, 0);
    }

    @Override
    public List<Competition> searchCompetitions(String keyword, Integer year, Integer status) {
        if ((keyword == null || keyword.trim().isEmpty()) && year == null && status == null) {
            return competitionDAO.findAll();
        }
        return competitionDAO.findByFilters(keyword, year, status);
    }

    @Override
    public Map<String, Integer> getCompetitionStats(Integer competitionId) {
        Map<String, Integer> stats = new HashMap<>();
        if (competitionId == null) {
            stats.put("teamCount", 0);
            stats.put("workCount", 0);
            return stats;
        }

        List<Team> teams = teamDAO.findByCompetitionId(competitionId);
        stats.put("teamCount", teams != null ? teams.size() : 0);

        int workCount = workDAO.countByCompetitionId(competitionId);
        stats.put("workCount", workCount);

        return stats;
    }
}
