package com.poster.util;

import com.poster.model.Competition;
import com.poster.model.Work;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class AwardEligibilityPolicyTest {

    @Test
    void submittedScoredWorkInEndedCompetitionIsEligible() {
        Competition competition = new Competition();
        competition.setCompetitionId(4);
        competition.setStatus(3);

        Work work = new Work();
        work.setWorkId(8);
        work.setCompetitionId(4);
        work.setStatus(2);

        assertTrue(AwardEligibilityPolicy.isEligible(competition, work, true));
    }

    @Test
    void workInRunningCompetitionIsNotEligible() {
        Competition competition = new Competition();
        competition.setCompetitionId(4);
        competition.setStatus(2);

        Work work = new Work();
        work.setCompetitionId(4);
        work.setStatus(2);

        assertFalse(AwardEligibilityPolicy.isEligible(competition, work, true));
    }

    @Test
    void unscoredWorkIsNotEligible() {
        Competition competition = new Competition();
        competition.setCompetitionId(4);
        competition.setStatus(3);

        Work work = new Work();
        work.setCompetitionId(4);
        work.setStatus(2);

        assertFalse(AwardEligibilityPolicy.isEligible(competition, work, false));
    }
}
