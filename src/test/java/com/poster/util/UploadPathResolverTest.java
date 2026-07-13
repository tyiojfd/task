package com.poster.util;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

class UploadPathResolverTest {

    @TempDir
    Path tempDir;

    @Test
    void resolvesOnlyPathsInsideUploadRoot() {
        Path root = tempDir.resolve("uploads");

        assertEquals(root.resolve("avatars/avatar.png").toAbsolutePath().normalize(),
                UploadPathResolver.resolve(root, "/avatars/avatar.png"));
        assertNull(UploadPathResolver.resolve(root, "/../secret.txt"));
        assertNull(UploadPathResolver.resolve(root, "\\..\\secret.txt"));
        assertNull(UploadPathResolver.resolve(root, "C:/secret.txt"));
    }
}
