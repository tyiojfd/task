package com.poster.util;

import com.poster.model.Competition;
import com.poster.model.Team;
import com.poster.model.User;
import com.poster.model.Work;

/**
 * Object-level authorization rule for work attachments.
 */
public final class UploadAccessPolicy {

    private UploadAccessPolicy() {
    }

    public static boolean canUpload(User user, Team team, Work work,
                                    Competition competition, boolean administrator,
                                    boolean beforeDeadline) {
        if (user == null || team == null || work == null || competition == null
                || !beforeDeadline) {
            return false;
        }
        if (!Integer.valueOf(2).equals(team.getStatus())
                || !Integer.valueOf(2).equals(competition.getStatus())) {
            return false;
        }
        if (team.getTeamId() == null || team.getCompetitionId() == null
                || work.getTeamId() == null || work.getCompetitionId() == null
                || competition.getCompetitionId() == null
                || !team.getTeamId().equals(work.getTeamId())
                || !team.getCompetitionId().equals(work.getCompetitionId())
                || !competition.getCompetitionId().equals(team.getCompetitionId())) {
            return false;
        }
        return administrator || (user.getUserId() != null
                && user.getUserId().equals(team.getLeaderId()));
    }
}
