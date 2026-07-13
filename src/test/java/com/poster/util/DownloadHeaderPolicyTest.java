package com.poster.util;

import org.junit.jupiter.api.Test;

import java.lang.reflect.Method;

import static org.junit.jupiter.api.Assertions.assertEquals;

class DownloadHeaderPolicyTest {

    @Test
    void buildsAttachmentHeaderForWorkImageDownload() throws Exception {
        Class<?> policyClass = Class.forName("com.poster.util.DownloadHeaderPolicy");
        Method method = policyClass.getMethod("attachment", String.class);

        String header = (String) method.invoke(null, "team_8_poster.jpg");

        assertEquals("attachment; filename=\"team_8_poster.jpg\"", header);
    }

    @Test
    void removesPathAndHeaderBreakingCharactersFromFileName() throws Exception {
        Class<?> policyClass = Class.forName("com.poster.util.DownloadHeaderPolicy");
        Method method = policyClass.getMethod("attachment", String.class);

        String header = (String) method.invoke(null, "..\\\\secret\"\r\n.jpg");

        assertEquals("attachment; filename=\"secret___.jpg\"", header);
    }
}
