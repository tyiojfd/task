package com.poster.util;

import com.poster.model.Competition;
import com.poster.model.Team;
import com.poster.model.User;
import com.poster.model.Work;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class UploadAccessPolicyTest {

    @Test
    void teamLeaderCanAttachFileToOwnWorkDuringSubmissionWindow() {
        User user = user(10);
        Team team = team(7, 10, 4, 2);
        Work work = work(8, 7, 4);
        Competition competition = competition(4, 2);

        assertTrue(UploadAccessPolicy.canUpload(user, team, work, competition, false, true));
    }

    @Test
    void unrelatedParticipantCannotAttachFileToAnotherTeamWork() {
        User user = user(11);
        Team team = team(7, 10, 4, 2);
        Work work = work(8, 7, 4);
        Competition competition = competition(4, 2);

        assertFalse(UploadAccessPolicy.canUpload(user, team, work, competition, false, true));
    }

    @Test
    void uploadIsRejectedAfterCompetitionDeadline() {
        User user = user(10);
        Team team = team(7, 10, 4, 2);
        Work work = work(8, 7, 4);
        Competition competition = competition(4, 2);

        assertFalse(UploadAccessPolicy.canUpload(user, team, work, competition, true, false));
    }

    private static User user(Integer id) {
        User user = new User();
        user.setUserId(id);
        return user;
    }

    private static Team team(Integer id, Integer leaderId, Integer competitionId, Integer status) {
        Team team = new Team();
        team.setTeamId(id);
        team.setLeaderId(leaderId);
        team.setCompetitionId(competitionId);
        team.setStatus(status);
        return team;
    }

    private static Work work(Integer id, Integer teamId, Integer competitionId) {
        Work work = new Work();
        work.setWorkId(id);
        work.setTeamId(teamId);
        work.setCompetitionId(competitionId);
        return work;
    }

    private static Competition competition(Integer id, Integer status) {
        Competition competition = new Competition();
        competition.setCompetitionId(id);
        competition.setStatus(status);
        return competition;
    }
}
