package com.poster.service.impl;

import com.poster.dao.CompetitionDAO;
import com.poster.dao.TeamApplicationDAO;
import com.poster.dao.TeamDAO;
import com.poster.dao.TeamMemberDAO;
import com.poster.dao.UserRoleDAO;
import com.poster.model.Competition;
import com.poster.model.Role;
import com.poster.model.Team;
import com.poster.model.TeamApplication;
import com.poster.model.TeamMember;
import org.junit.jupiter.api.Test;

import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

class TeamApplicationServiceImplTest {

    @Test
    void approvalWithMissingLeaderIdIsRejectedWithoutThrowing() {
        TeamApplication application = new TeamApplication();
        application.setApplicationId(10);
        application.setTeamId(7);
        application.setApplicantId(9);
        application.setStatus(0);

        Team team = new Team();
        team.setTeamId(7);
        team.setLeaderId(3);

        TeamApplicationServiceImpl service = new TeamApplicationServiceImpl(
                new FixedApplicationDAO(application),
                new FixedTeamDAO(team),
                new FixedTeamMemberDAO(),
                new FixedCompetitionDAO(),
                new FixedUserRoleDAO()
        );

        assertFalse(service.approveApplication(10, null));
    }

    @Test
    void approvalCleansUpTheInsertedMemberWhenApplicationUpdateFails() {
        TeamApplication application = new TeamApplication();
        application.setApplicationId(10);
        application.setTeamId(7);
        application.setApplicantId(9);
        application.setStatus(0);

        Team team = new Team();
        team.setTeamId(7);
        team.setLeaderId(3);
        team.setCompetitionId(4);
        team.setStatus(1);

        Competition competition = new Competition();
        competition.setCompetitionId(4);
        competition.setStatus(1);
        competition.setMaxTeamSize(5);

        FixedApplicationDAO applicationDAO = new FixedApplicationDAO(application);
        applicationDAO.updateResult = 0;
        FixedTeamMemberDAO memberDAO = new FixedTeamMemberDAO();

        TeamApplicationServiceImpl service = new TeamApplicationServiceImpl(
                applicationDAO,
                new FixedTeamDAO(team),
                memberDAO,
                new FixedCompetitionDAO(competition),
                new FixedUserRoleDAO(Collections.singletonList(role("队员")))
        );

        assertFalse(service.approveApplication(10, 3));
        assertEquals(Integer.valueOf(7), memberDAO.deletedTeamId);
        assertEquals(Integer.valueOf(9), memberDAO.deletedUserId);
    }

    private static Role role(String name) {
        Role role = new Role();
        role.setRoleName(name);
        return role;
    }

    private static class FixedApplicationDAO implements TeamApplicationDAO {
        private final TeamApplication application;
        private int updateResult = 1;

        private FixedApplicationDAO(TeamApplication application) {
            this.application = application;
        }

        @Override
        public int insert(TeamApplication application) {
            return 1;
        }

        @Override
        public int update(TeamApplication application) {
            return updateResult;
        }

        @Override
        public TeamApplication findById(Integer applicationId) {
            return application;
        }

        @Override
        public List<TeamApplication> findByTeamId(Integer teamId) {
            return Collections.emptyList();
        }

        @Override
        public List<TeamApplication> findByApplicantId(Integer applicantId) {
            return Collections.emptyList();
        }

        @Override
        public List<TeamApplication> findPendingByTeamId(Integer teamId) {
            return Collections.emptyList();
        }

        @Override
        public TeamApplication findPendingByTeamIdAndApplicantId(Integer teamId, Integer applicantId) {
            return null;
        }
    }

    private static class FixedTeamDAO implements TeamDAO {
        private final Team team;

        private FixedTeamDAO(Team team) {
            this.team = team;
        }

        @Override
        public int insert(Team team) {
            return 1;
        }

        @Override
        public int deleteById(Integer teamId) {
            return 1;
        }

        @Override
        public int update(Team team) {
            return 1;
        }

        @Override
        public Team findById(Integer teamId) {
            return team;
        }

        @Override
        public List<Team> findAll() {
            return Collections.emptyList();
        }

        @Override
        public List<Team> findByLeaderId(Integer leaderId) {
            return Collections.emptyList();
        }

        @Override
        public List<Team> findByCompetitionId(Integer competitionId) {
            return Collections.emptyList();
        }

        @Override
        public List<Team> findByStatus(Integer status) {
            return Collections.emptyList();
        }

        @Override
        public List<Team> searchByTeamName(String keyword) {
            return Collections.emptyList();
        }

        @Override
        public int count() {
            return 0;
        }
    }

    private static class FixedTeamMemberDAO implements TeamMemberDAO {
        private Integer deletedTeamId;
        private Integer deletedUserId;

        @Override
        public int insert(TeamMember teamMember) {
            return 1;
        }

        @Override
        public int deleteById(Integer id) {
            return 1;
        }

        @Override
        public int deleteByTeamIdAndUserId(Integer teamId, Integer userId) {
            deletedTeamId = teamId;
            deletedUserId = userId;
            return 1;
        }

        @Override
        public int update(TeamMember teamMember) {
            return 1;
        }

        @Override
        public TeamMember findById(Integer id) {
            return null;
        }

        @Override
        public List<TeamMember> findByTeamId(Integer teamId) {
            return Collections.emptyList();
        }

        @Override
        public List<TeamMember> findByUserId(Integer userId) {
            return Collections.emptyList();
        }

        @Override
        public int countByTeamId(Integer teamId) {
            return 0;
        }
    }

    private static class FixedCompetitionDAO implements CompetitionDAO {
        private final Competition competition;

        private FixedCompetitionDAO() {
            this(null);
        }

        private FixedCompetitionDAO(Competition competition) {
            this.competition = competition;
        }

        @Override
        public int insert(Competition competition) {
            return 1;
        }

        @Override
        public int deleteById(Integer competitionId) {
            return 1;
        }

        @Override
        public int update(Competition competition) {
            return 1;
        }

        @Override
        public Competition findById(Integer competitionId) {
            return competition;
        }

        @Override
        public List<Competition> findAll() {
            return Collections.emptyList();
        }

        @Override
        public List<Competition> findByYear(Integer year) {
            return Collections.emptyList();
        }

        @Override
        public List<Competition> findByStatus(Integer status) {
            return Collections.emptyList();
        }

        @Override
        public List<Competition> findByCreatorId(Integer creatorId) {
            return Collections.emptyList();
        }

        @Override
        public int count() {
            return 0;
        }

        @Override
        public List<Competition> search(String keyword) {
            return Collections.emptyList();
        }

        @Override
        public List<Competition> findByFilters(String keyword, Integer year, Integer status) {
            return Collections.emptyList();
        }
    }

    private static class FixedUserRoleDAO implements UserRoleDAO {
        private final List<Role> roles;

        private FixedUserRoleDAO() {
            this(Collections.emptyList());
        }

        private FixedUserRoleDAO(List<Role> roles) {
            this.roles = roles;
        }

        @Override
        public boolean assignRole(Integer userId, Integer roleId) {
            return true;
        }

        @Override
        public boolean removeRole(Integer userId, Integer roleId) {
            return true;
        }

        @Override
        public List<Role> findRolesByUserId(Integer userId) {
            return roles;
        }

        @Override
        public boolean deleteByUserId(Integer userId) {
            return true;
        }
    }
}
