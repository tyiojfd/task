package com.poster.util;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/** Validates the small set of share channels exposed by the application. */
public final class SharePolicy {

    private static final Set<String> SUPPORTED = new HashSet<>(Arrays.asList(
            "link", "web", "wechat", "qq", "weibo"
    ));

    private SharePolicy() {
    }

    public static String normalizePlatform(String platform) {
        if (platform == null || platform.trim().isEmpty()) {
            return "link";
        }
        String normalized = platform.trim().toLowerCase(java.util.Locale.ROOT);
        return SUPPORTED.contains(normalized) ? normalized : null;
    }
}
