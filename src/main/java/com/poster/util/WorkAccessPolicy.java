package com.poster.util;

/**
 * Centralizes the object-level visibility rule for submitted works.
 */
public final class WorkAccessPolicy {

    private WorkAccessPolicy() {
    }

    public static boolean canView(boolean administrator, boolean judge,
                                  boolean teamMember, boolean competitionEnded,
                                  boolean participantInCompetition) {
        if (administrator || judge || teamMember) {
            return true;
        }
        // 竞赛结束后，所有登录用户均可查看作品
        return competitionEnded;
    }
}
