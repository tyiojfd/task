package com.poster.web;

import org.junit.jupiter.api.Test;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

import static org.junit.jupiter.api.Assertions.assertFalse;

class CertificateViewTemplateTest {

    @Test
    void certificateViewDoesNotRenderHistoryBackButton() throws Exception {
        String template = new String(Files.readAllBytes(
                Paths.get("src/main/webapp/jsp/certificate_view.jsp")), StandardCharsets.UTF_8);

        assertFalse(template.contains("history.back()"));
    }
}
