package com.poster.service.impl;

import com.poster.dao.*;
import com.poster.dao.impl.*;
import com.poster.model.*;
import com.poster.service.CompetitionService;
import com.poster.util.DBUtil;
import com.poster.util.CompetitionStatusPolicy;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
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
        if (competition == null || competition.getName() == null
                || competition.getName().trim().isEmpty()) {
            return false;
        }
        if (competition.getYear() == null || competition.getYear() < 2000
                || competition.getSubmitDeadline() == null
                || competition.getTheme() == null || competition.getTheme().trim().isEmpty()
                || competition.getCreatorId() == null) {
            return false;
        }

        // 设置默认值
        if (competition.getStatus() == null) {
            competition.setStatus(1); // 默认状态：报名中
        }
        if (competition.getMaxTeamSize() == null) {
            competition.setMaxTeamSize(5); // 默认最大队伍人数
        }
        if (competition.getMaxTeamSize() <= 0 || competition.getMaxTeamSize() > 100
                || !CompetitionStatusPolicy.canTransition(competition.getStatus(), competition.getStatus())) {
            return false;
        }
        if ((competition.getStatus() == 1 || competition.getStatus() == 2)
                && competition.getSubmitDeadline().isBefore(LocalDateTime.now())) {
            return false;
        }
        competition.setCreateTime(LocalDateTime.now());

        // 调用DAO插入
        return competitionDAO.insert(competition) > 0;
    }

    @Override
    public boolean updateCompetition(Competition competition) {
        if (competition == null || competition.getCompetitionId() == null) {
            return false;
        }
        Competition existing = competitionDAO.findById(competition.getCompetitionId());
        if (existing == null) {
            return false;
        }
        if (competition.getYear() == null) competition.setYear(existing.getYear());
        if (competition.getTheme() == null) competition.setTheme(existing.getTheme());
        if (competition.getDescription() == null) competition.setDescription(existing.getDescription());
        if (competition.getSubmitDeadline() == null) competition.setSubmitDeadline(existing.getSubmitDeadline());
        if (competition.getMaxTeamSize() == null) competition.setMaxTeamSize(existing.getMaxTeamSize());
        if (competition.getStatus() == null) competition.setStatus(existing.getStatus());
        if (competition.getName() == null || competition.getName().trim().isEmpty()) {
            return false;
        }
        if (competition.getYear() == null || competition.getYear() < 2000
                || competition.getTheme() == null || competition.getTheme().trim().isEmpty()
                || competition.getSubmitDeadline() == null
                || competition.getMaxTeamSize() == null || competition.getMaxTeamSize() <= 0
                || competition.getMaxTeamSize() > 100
                || !CompetitionStatusPolicy.canTransition(existing.getStatus(), competition.getStatus())) {
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

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. 删除该竞赛下所有队伍的作品文件 → work_file
            List<Work> works = workDAO.findByCompetitionId(competitionId);
            if (works != null) {
                for (Work w : works) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM work_file WHERE work_id = ?")) {
                        ps.setInt(1, w.getWorkId());
                        ps.executeUpdate();
                    }
                    // 删除点赞
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM work_like WHERE work_id = ?")) {
                        ps.setInt(1, w.getWorkId());
                        ps.executeUpdate();
                    }
                    // 删除分享
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM work_share WHERE work_id = ?")) {
                        ps.setInt(1, w.getWorkId());
                        ps.executeUpdate();
                    }
                    // 删除作品
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM work WHERE work_id = ?")) {
                        ps.setInt(1, w.getWorkId());
                        ps.executeUpdate();
                    }
                }
            }

            // 2. 删除该竞赛下的队伍成员 + 队伍
            List<Team> teams = teamDAO.findByCompetitionId(competitionId);
            if (teams != null) {
                for (Team t : teams) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM team_member WHERE team_id = ?")) {
                        ps.setInt(1, t.getTeamId());
                        ps.executeUpdate();
                    }
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM invitation WHERE team_id = ?")) {
                        ps.setInt(1, t.getTeamId());
                        ps.executeUpdate();
                    }
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM team WHERE team_id = ?")) {
                        ps.setInt(1, t.getTeamId());
                        ps.executeUpdate();
                    }
                }
            }

            // 3. 删除竞赛子类
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM competition_category WHERE competition_id = ?")) {
                ps.setInt(1, competitionId);
                ps.executeUpdate();
            }

            // 4. 删除竞赛
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM competition WHERE competition_id = ?")) {
                ps.setInt(1, competitionId);
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    conn.commit();
                    return true;
                }
            }

            conn.rollback();
            return false;
        } catch (SQLException e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (SQLException ignored) {}
            return false;
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } }
            catch (SQLException ignored) {}
        }
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

        if (!CompetitionStatusPolicy.canTransition(competition.getStatus(), status)) {
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
    public List<Competition> searchCompetitionsPaginated(String keyword, Integer year,
                                                          Integer status, int page, int pageSize) {
        int offset = (page - 1) * pageSize;
        if ((keyword == null || keyword.trim().isEmpty()) && year == null && status == null) {
            return competitionDAO.findAllWithLimit(offset, pageSize);
        }
        return competitionDAO.findByFiltersWithLimit(keyword, year, status, offset, pageSize);
    }

    @Override
    public int getCompetitionCount() {
        return competitionDAO.count();
    }

    @Override
    public int countByFilters(String keyword, Integer year, Integer status) {
        if ((keyword == null || keyword.trim().isEmpty()) && year == null && status == null) {
            return competitionDAO.count();
        }
        List<Competition> all = competitionDAO.findByFilters(keyword, year, status);
        return all != null ? all.size() : 0;
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
        int registeredTeamCount = 0;
        if (teams != null) {
            for (Team team : teams) {
                if (team.getStatus() != null && team.getStatus() == 2) {
                    registeredTeamCount++;
                }
            }
        }
        stats.put("teamCount", registeredTeamCount);

        List<Work> works = workDAO.findByCompetitionId(competitionId);
        int submittedWorkCount = 0;
        if (works != null) {
            for (Work work : works) {
                if (work.getStatus() != null && (work.getStatus() == 2 || work.getStatus() == 3)) {
                    submittedWorkCount++;
                }
            }
        }
        stats.put("workCount", submittedWorkCount);

        return stats;
    }
}
