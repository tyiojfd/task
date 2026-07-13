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
        return competitionEnded && participantInCompetition;
    }
}
