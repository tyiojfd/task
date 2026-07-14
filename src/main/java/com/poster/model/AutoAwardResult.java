package com.poster.model;

import com.poster.util.AutoAwardPolicy;

/**
 * Result returned after automatic award generation.
 *
 * @author OneClickAwards
 * @date 2026-07-14
 */
public class AutoAwardResult {

    private final boolean success;
    private final String  message;
    private final int candidateCount;
    private final int skippedUnscoredCount;
    private final int firstPrizeCount;
    private final int secondPrizeCount;
    private final int thirdPrizeCount;

    private AutoAwardResult(boolean success, String message, int candidateCount,
                            int skippedUnscoredCount, int firstPrizeCount,
                            int secondPrizeCount, int thirdPrizeCount) {
        this.success             = success;
        this.message             = message;
        this.candidateCount      = candidateCount;
        this.skippedUnscoredCount = skippedUnscoredCount;
        this.firstPrizeCount     = firstPrizeCount;
        this.secondPrizeCount    = secondPrizeCount;
        this.thirdPrizeCount     = thirdPrizeCount;
    }

    public static AutoAwardResult success(int candidateCount, int skippedUnscoredCount,
                                          AutoAwardPolicy.PrizeCounts prizeCounts) {
        String msg = "已按均分生成获奖名单：一等奖 " + prizeCounts.getFirstPrizeCount()
                + " 名、二等奖 " + prizeCounts.getSecondPrizeCount()
                + " 名、三等奖 " + prizeCounts.getThirdPrizeCount()
                + " 名；跳过未评分作品 " + skippedUnscoredCount + " 件";
        return new AutoAwardResult(true, msg, candidateCount, skippedUnscoredCount,
                prizeCounts.getFirstPrizeCount(),
                prizeCounts.getSecondPrizeCount(),
                prizeCounts.getThirdPrizeCount());
    }

    public static AutoAwardResult failure(String message) {
        return new AutoAwardResult(false, message, 0, 0, 0, 0, 0);
    }

    public boolean isSuccess()           { return success; }
    public String  getMessage()          { return message; }
    public int     getCandidateCount()   { return candidateCount; }
    public int     getSkippedUnscoredCount() { return skippedUnscoredCount; }
    public int     getFirstPrizeCount()  { return firstPrizeCount; }
    public int     getSecondPrizeCount() { return secondPrizeCount; }
    public int     getThirdPrizeCount()  { return thirdPrizeCount; }
    public int     getTotalPrizeCount()  { return firstPrizeCount + secondPrizeCount + thirdPrizeCount; }
}
