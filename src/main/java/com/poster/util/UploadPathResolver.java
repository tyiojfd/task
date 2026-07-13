package com.poster.util;

import java.nio.file.Path;

/** Resolves a public upload path without allowing it to escape its upload root. */
public final class UploadPathResolver {

    private UploadPathResolver() {
    }

    /**
     * @return a normalized path below {@code root}, or {@code null} for an
     * invalid/traversal path
     */
    public static Path resolve(Path root, String publicSubPath) {
        if (root == null || publicSubPath == null) {
            return null;
        }

        String relative = publicSubPath.trim().replace('\\', '/');
        while (relative.startsWith("/")) {
            relative = relative.substring(1);
        }
        if (relative.isEmpty() || relative.indexOf('\0') >= 0
                || relative.matches("^[A-Za-z]:.*")) {
            return null;
        }

        try {
            Path normalizedRoot = root.toAbsolutePath().normalize();
            Path resolved = normalizedRoot.resolve(relative).normalize();
            return resolved.startsWith(normalizedRoot) ? resolved : null;
        } catch (RuntimeException e) {
            return null;
        }
    }
}
