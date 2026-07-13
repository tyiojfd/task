package com.poster.util;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class AvatarStorageTest {

    @TempDir
    Path tempDir;

    @Test
    void savesAvatarOutsideTheWebappAndReturnsStablePublicPath() throws Exception {
        AvatarStorage storage = new AvatarStorage(tempDir);
        byte[] content = "avatar".getBytes(StandardCharsets.UTF_8);

        String publicPath = storage.save(
                new ByteArrayInputStream(content),
                "portrait.png",
                "image/png",
                content.length
        );

        assertTrue(publicPath.startsWith("/uploads/avatars/avatar_"));
        assertTrue(publicPath.endsWith(".png"));
        Path storedPath = storage.resolvePublicPath(publicPath);
        assertTrue(storedPath.startsWith(tempDir.resolve("avatars")));
        assertEquals(content.length, Files.size(storedPath));
    }

    @Test
    void rejectsUnsupportedTypeExtensionAndOversizedFile() {
        AvatarStorage storage = new AvatarStorage(tempDir);

        assertThrows(IOException.class, () -> storage.save(
                new ByteArrayInputStream(new byte[]{1}), "portrait.gif", "image/gif", 1
        ));
        assertThrows(IOException.class, () -> storage.save(
                new ByteArrayInputStream(new byte[]{1}), "portrait.txt", "image/png", 1
        ));
        assertThrows(IOException.class, () -> storage.save(
                new ByteArrayInputStream(new byte[]{1}), "portrait.png", "image/png", 2 * 1024 * 1024L + 1
        ));
    }

    @Test
    void rejectsAvatarPathTraversalAndDeletesStoredFile() throws Exception {
        AvatarStorage storage = new AvatarStorage(tempDir);
        String publicPath = storage.save(
                new ByteArrayInputStream(new byte[]{1, 2, 3}),
                "portrait.jpg",
                "image/jpeg",
                3
        );

        assertTrue(storage.delete(publicPath));
        assertFalse(Files.exists(storage.resolvePublicPath(publicPath)));
        assertThrows(IllegalArgumentException.class,
                () -> storage.resolvePublicPath("/uploads/avatars/../secret.txt"));
        assertThrows(IllegalArgumentException.class,
                () -> storage.resolvePublicPath("/uploads/other/portrait.jpg"));
    }
}
