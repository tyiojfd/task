package com.poster.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

class SharePolicyTest {

    @Test
    void normalizesSupportedPlatform() {
        assertEquals("link", SharePolicy.normalizePlatform(" LINK "));
        assertEquals("wechat", SharePolicy.normalizePlatform("wechat"));
    }

    @Test
    void rejectsUnknownPlatform() {
        assertNull(SharePolicy.normalizePlatform("script"));
    }
}
