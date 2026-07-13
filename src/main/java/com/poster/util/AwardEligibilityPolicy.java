package com.poster.util;

import com.poster.model.Competition;
import com.poster.model.Work;

/**
 * Validates the cross-entity conditions required before an award can be set.
 */
public final class AwardEligibilityPolicy {

    private AwardEligibilityPolicy() {
    }

    public static boolean isEligible(Competition competition, Work work, boolean hasScore) {
        if (competition == null || work == null || !hasScore) {
            return false;
        }
        if (!Integer.valueOf(3).equals(competition.getStatus())) {
            return false;
        }
        if (work.getCompetitionId() == null
                || !work.getCompetitionId().equals(competition.getCompetitionId())) {
            return false;
        }
        return Integer.valueOf(2).equals(work.getStatus())
                || Integer.valueOf(3).equals(work.getStatus());
    }
}
