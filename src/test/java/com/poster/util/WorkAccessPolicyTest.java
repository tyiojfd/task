package com.poster.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class WorkAccessPolicyTest {

    @Test
    void unrelatedParticipantCannotViewWorkBeforeCompetitionEnds() {
        assertFalse(WorkAccessPolicy.canView(false, false, false, false, false));
    }

    @Test
    void teamMemberCanViewOwnWorkBeforeCompetitionEnds() {
        assertTrue(WorkAccessPolicy.canView(false, false, true, false, false));
    }

    @Test
    void participantInSameCompetitionCanViewAfterCompetitionEnds() {
        assertTrue(WorkAccessPolicy.canView(false, false, false, true, true));
    }

    @Test
    void administratorAndJudgeCanViewAnyWork() {
        assertTrue(WorkAccessPolicy.canView(true, false, false, false, false));
        assertTrue(WorkAccessPolicy.canView(false, true, false, false, false));
    }
}
