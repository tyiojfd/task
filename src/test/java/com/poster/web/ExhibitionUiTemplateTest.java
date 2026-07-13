package com.poster.web;

import org.junit.jupiter.api.Test;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.LinkedHashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ExhibitionUiTemplateTest {

    private static final Path JSP_ROOT = Paths.get("src", "main", "webapp", "jsp");
    private static final Path CSS_ROOT = Paths.get("src", "main", "webapp", "css");

    @Test
    void sharedIncludeLoadsTheInnerPageStylesheet() throws Exception {
        String include = read(JSP_ROOT.resolve("includes/app-shell-assets.jspf"));
        assertTrue(include.contains("css/app-shell.css"));
        assertTrue(include.contains("css/app-pages.css"));
    }

    @Test
    void protectedParticipantHomeDoesNotLoadInnerPageSkin() throws Exception {
        String index = read(JSP_ROOT.resolve("index.jsp"));
        String homeCss = read(CSS_ROOT.resolve("home.css"));
        assertFalse(index.contains("app-shell-assets.jspf"));
        assertFalse(homeCss.contains("app-pages.css"));
    }

    @Test
    void representativePagesDeclareTheirVisualFamily() throws Exception {
        Map<String, String> pages = new LinkedHashMap<>();
        pages.put("competition_list.jsp", "app-page-catalog");
        pages.put("submission_list.jsp", "app-page-gallery");
        pages.put("competition_detail.jsp", "app-page-detail");
        pages.put("score_input.jsp", "app-page-workbench");

        pages.forEach((file, family) -> {
            try {
                assertTrue(read(JSP_ROOT.resolve(file)).contains(family),
                        file + " is missing " + family);
            } catch (Exception error) {
                throw new AssertionError(error);
            }
        });
    }

    @Test
    void innerPageStylesAvoidKnownTemplateSlop() throws Exception {
        String styles = read(CSS_ROOT.resolve("app-shell.css"))
                + read(CSS_ROOT.resolve("app-pages.css"));
        assertFalse(styles.contains("#6C5CE7"));
        assertFalse(styles.contains("#A29BFE"));
        assertFalse(styles.toLowerCase().contains("background-clip: text"));
        assertFalse(styles.contains("repeating-linear-gradient"));
        assertFalse(styles.contains("border-left: 4px"));
        assertFalse(styles.contains("border-right: 4px"));
    }

    private static String read(Path path) throws Exception {
        return new String(Files.readAllBytes(path), StandardCharsets.UTF_8);
    }
}
