package com.poster.web;

import org.junit.jupiter.api.Test;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertTrue;

class UnifiedFrontendTemplateTest {

    private static final Path JSP_ROOT = Paths.get("src", "main", "webapp", "jsp");

    @Test
    void everyNonParticipantJspLoadsTheSharedShell() throws Exception {
        try (Stream<Path> files = Files.list(JSP_ROOT)) {
            files.filter(path -> path.getFileName().toString().endsWith(".jsp"))
                    .filter(path -> !path.getFileName().toString().equals("index.jsp"))
                    .forEach(path -> {
                        try {
                            String source = new String(Files.readAllBytes(path), StandardCharsets.UTF_8);
                            assertTrue(source.contains("includes/app-shell-assets.jspf"),
                                    path.getFileName() + " is missing the shared app shell");
                        } catch (Exception error) {
                            throw new AssertionError(error);
                        }
                    });
        }
    }

    @Test
    void roleHomesExposeTheirPrimaryWorkflowLinks() throws Exception {
        String judge = read("judge_home.jsp");
        String admin = read("admin_home.jsp");
        assertTrue(judge.contains("/score?action=list"));
        assertTrue(judge.contains("/score?action=myScores"));
        assertTrue(admin.contains("/competition?action=add"));
        assertTrue(admin.contains("/admin/users"));
    }

    private static String read(String name) throws Exception {
        return new String(Files.readAllBytes(JSP_ROOT.resolve(name)), StandardCharsets.UTF_8);
    }
}
