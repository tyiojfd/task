package com.poster.util;

/**
 * Calculates automatic award quotas for a competition.
 *
 * @author OneClickAwards
 * @date 2026-07-14
 */
public final class AutoAwardPolicy {

    private AutoAwardPolicy() {
    }

    /**
     * Calculates prize counts by percentage with truncation by prize order.
     * Uses Math.ceil for each tier, then truncates first/second/third in order
     * when the sum exceeds candidateCount.
     *
     * @param candidateCount number of scored candidates
     * @return prize counts that never exceed candidateCount
     */
    public static PrizeCounts calculatePrizeCounts(int candidateCount) {
        if (candidateCount <= 0) {
            return new PrizeCounts(0, 0, 0);
        }

        int first  = (int) Math.ceil(candidateCount * 0.10);
        int second = (int) Math.ceil(candidateCount * 0.15);
        int third  = (int) Math.ceil(candidateCount * 0.20);

        int remaining = candidateCount;
        int finalFirst  = Math.min(first, remaining);
        remaining -= finalFirst;

        int finalSecond = Math.min(second, remaining);
        remaining -= finalSecond;

        int finalThird  = Math.min(third, remaining);

        return new PrizeCounts(finalFirst, finalSecond, finalThird);
    }

    /* ---------------------------------------------------------------- *
     * Value class
     * ---------------------------------------------------------------- */

    public static final class PrizeCounts {
        private final int firstPrizeCount;
        private final int secondPrizeCount;
        private final int thirdPrizeCount;

        public PrizeCounts(int firstPrizeCount, int secondPrizeCount, int thirdPrizeCount) {
            this.firstPrizeCount  = firstPrizeCount;
            this.secondPrizeCount = secondPrizeCount;
            this.thirdPrizeCount  = thirdPrizeCount;
        }

        public int getFirstPrizeCount()  { return firstPrizeCount; }
        public int getSecondPrizeCount() { return secondPrizeCount; }
        public int getThirdPrizeCount()  { return thirdPrizeCount; }
        public int getTotalCount()       { return firstPrizeCount + secondPrizeCount + thirdPrizeCount; }
    }
}
