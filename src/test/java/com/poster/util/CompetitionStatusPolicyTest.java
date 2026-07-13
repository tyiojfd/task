package com.poster.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class CompetitionStatusPolicyTest {

    @Test
    void allowsForwardLifecycleTransitions() {
        assertTrue(CompetitionStatusPolicy.canTransition(1, 2));
        assertTrue(CompetitionStatusPolicy.canTransition(2, 3));
        assertTrue(CompetitionStatusPolicy.canTransition(1, 0));
    }

    @Test
    void rejectsReopeningFinishedOrCancelledCompetition() {
        assertFalse(CompetitionStatusPolicy.canTransition(3, 1));
        assertFalse(CompetitionStatusPolicy.canTransition(0, 1));
        assertFalse(CompetitionStatusPolicy.canTransition(2, 1));
    }
}
