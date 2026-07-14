package com.poster.util;

/** Validates the one-way lifecycle of a competition. */
public final class CompetitionStatusPolicy {

    private CompetitionStatusPolicy() {
    }

    public static boolean canTransition(Integer currentStatus, Integer nextStatus) {
        if (currentStatus == null || nextStatus == null
                || currentStatus < 0 || currentStatus > 3
                || nextStatus < 0 || nextStatus > 3) {
            return false;
        }
        if (currentStatus.equals(nextStatus)) {
            return true;
        }
        return (currentStatus == 1 && (nextStatus == 2 || nextStatus == 0))
                || (currentStatus == 2 && (nextStatus == 3 || nextStatus == 1 || nextStatus == 0));
    }
}
