package com.poster.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class AutoAwardPolicyTest {

    @Test
    void nineCandidatesUseCeilingPercentages() {
        AutoAwardPolicy.PrizeCounts counts = AutoAwardPolicy.calculatePrizeCounts(9);
        assertEquals(1, counts.getFirstPrizeCount());
        assertEquals(2, counts.getSecondPrizeCount());
        assertEquals(2, counts.getThirdPrizeCount());
        assertEquals(5, counts.getTotalCount());
    }

    @Test
    void oneCandidateNeverProducesMoreThanOneAward() {
        AutoAwardPolicy.PrizeCounts counts = AutoAwardPolicy.calculatePrizeCounts(1);
        assertEquals(1, counts.getFirstPrizeCount());
        assertEquals(0, counts.getSecondPrizeCount());
        assertEquals(0, counts.getThirdPrizeCount());
        assertEquals(1, counts.getTotalCount());
    }

    @Test
    void zeroCandidatesProduceNoAwards() {
        AutoAwardPolicy.PrizeCounts counts = AutoAwardPolicy.calculatePrizeCounts(0);
        assertEquals(0, counts.getFirstPrizeCount());
        assertEquals(0, counts.getSecondPrizeCount());
        assertEquals(0, counts.getThirdPrizeCount());
        assertEquals(0, counts.getTotalCount());
    }

    @Test
    void twoCandidatesTruncateByPrizeOrder() {
        AutoAwardPolicy.PrizeCounts counts = AutoAwardPolicy.calculatePrizeCounts(2);
        assertEquals(1, counts.getFirstPrizeCount());
        assertEquals(1, counts.getSecondPrizeCount());
        assertEquals(0, counts.getThirdPrizeCount());
        assertEquals(2, counts.getTotalCount());
    }

    @Test
    void tenCandidatesFollowTenFifteenTwentyPercentCeiling() {
        AutoAwardPolicy.PrizeCounts counts = AutoAwardPolicy.calculatePrizeCounts(10);
        assertEquals(1, counts.getFirstPrizeCount());
        assertEquals(2, counts.getSecondPrizeCount());
        assertEquals(2, counts.getThirdPrizeCount());
        assertEquals(5, counts.getTotalCount());
    }
}
