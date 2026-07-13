package com.poster.util;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

/**
 * Stores user avatars outside the deployed web application directory.
 *
 * <p>The database keeps the public URL returned by {@link #save}. The actual
 * file is stored below the configured persistent upload directory so a fresh
 * Tomcat deployment does not remove existing avatars.</p>
 */
public class AvatarStorage {

    private static final String PUBLIC_PREFIX = "/uploads/avatars/";
    private static final long MAX_FILE_SIZE = 2 * 1024 * 1024L;

    private final Path storageRoot;

    /** Uses FileUploadUtil's persistent upload directory. */
    public AvatarStorage() {
        this(Paths.get(FileUploadUtil.getStorageBasePath()));
    }

    /** Visible for focused tests and for callers that need a custom root. */
    public AvatarStorage(Path storageRoot) {
        if (storageRoot == null) {
            throw new IllegalArgumentException("storage root cannot be null");
        }
        this.storageRoot = storageRoot.toAbsolutePath().normalize();
    }

    /**
     * Saves an avatar and returns its stable public URL.
     */
    public String save(InputStream input, String originalName, String contentType, long size)
            throws IOException {
        validateUpload(input, originalName, contentType, size);

        String extension = extensionOf(originalName);
        Path avatarDirectory = storageRoot.resolve("avatars").normalize();
        Files.createDirectories(avatarDirectory);

        String fileName = "avatar_" + UUID.randomUUID().toString().replace("-", "") + extension;
        Path target = avatarDirectory.resolve(fileName).normalize();
        if (!target.startsWith(avatarDirectory)) {
            throw new IOException("invalid avatar storage path");
        }

        Files.copy(input, target, StandardCopyOption.REPLACE_EXISTING);
        return PUBLIC_PREFIX + fileName;
    }

    /** Resolves a stored public URL after validating its fixed avatar scope. */
    public Path resolvePublicPath(String publicPath) {
        if (publicPath == null || !publicPath.startsWith(PUBLIC_PREFIX)) {
            throw new IllegalArgumentException("invalid avatar path");
        }

        String fileName = publicPath.substring(PUBLIC_PREFIX.length());
        if (!isSimpleFileName(fileName)) {
            throw new IllegalArgumentException("invalid avatar file name");
        }

        Path avatarDirectory = storageRoot.resolve("avatars").normalize();
        Path resolved = avatarDirectory.resolve(fileName).normalize();
        if (!resolved.startsWith(avatarDirectory)) {
            throw new IllegalArgumentException("invalid avatar path");
        }
        return resolved;
    }

    /** Deletes a stored avatar, returning whether a file was actually removed. */
    public boolean delete(String publicPath) throws IOException {
        return Files.deleteIfExists(resolvePublicPath(publicPath));
    }

    private void validateUpload(InputStream input, String originalName, String contentType, long size)
            throws IOException {
        if (input == null) {
            throw new IOException("avatar content is missing");
        }
        if (!isAllowedType(contentType)) {
            throw new IOException("only JPG and PNG avatars are supported");
        }
        if (!isAllowedExtension(originalName)) {
            throw new IOException("only .jpg, .jpeg and .png avatars are supported");
        }
        if (size <= 0 || size > MAX_FILE_SIZE) {
            throw new IOException("avatar size must be between 1 byte and 2MB");
        }
    }

    private boolean isAllowedType(String contentType) {
        return "image/jpeg".equalsIgnoreCase(contentType)
                || "image/png".equalsIgnoreCase(contentType);
    }

    private boolean isAllowedExtension(String fileName) {
        String extension = extensionOf(fileName);
        return ".jpg".equals(extension) || ".jpeg".equals(extension) || ".png".equals(extension);
    }

    private String extensionOf(String fileName) {
        if (fileName == null || fileName.trim().isEmpty()
                || fileName.contains("/") || fileName.contains("\\")) {
            throw new IllegalArgumentException("invalid avatar file name");
        }
        int dot = fileName.lastIndexOf('.');
        if (dot < 0 || dot == fileName.length() - 1) {
            throw new IllegalArgumentException("avatar file extension is missing");
        }
        return fileName.substring(dot).toLowerCase();
    }

    private boolean isSimpleFileName(String fileName) {
        return fileName != null
                && !fileName.isEmpty()
                && !".".equals(fileName)
                && !"..".equals(fileName)
                && fileName.indexOf('/') < 0
                && fileName.indexOf('\\') < 0;
    }
}
