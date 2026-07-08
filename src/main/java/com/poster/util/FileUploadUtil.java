package com.poster.util;

import javax.servlet.http.Part;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

/**
 * 文件上传工具类
 * @author 队员B
 * @date 2026-07-06
 */
public class FileUploadUtil {

    private static final String[] ALLOWED_TYPES = {"image/jpeg", "image/png"};
    private static final String[] ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png"};
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024L; // 10MB

    /**
     * 持久化存储相对路径（相对于webapp根目录）
     * 文件保存在此目录下可避免项目重建时丢失
     */
    public static final String STORAGE_DIR = "storage" + java.io.File.separator + "uploads";

    /**
     * 校验文件类型是否允许
     */
    public static boolean isAllowedType(String contentType) {
        if (contentType == null) return false;
        for (String type : ALLOWED_TYPES) {
            if (type.equals(contentType)) return true;
        }
        return false;
    }

    /**
     * 校验文件扩展名是否允许
     */
    public static boolean isAllowedExtension(String fileName) {
        if (fileName == null || fileName.isEmpty()) return false;
        String lowerName = fileName.toLowerCase();
        for (String ext : ALLOWED_EXTENSIONS) {
            if (lowerName.endsWith(ext)) return true;
        }
        return false;
    }

    /**
     * 校验文件大小是否允许
     */
    public static boolean isAllowedSize(long size) {
        return size > 0 && size <= MAX_FILE_SIZE;
    }

    /**
     * 生成唯一文件名
     */
    public static String generateFileName(Integer teamId, String originalFileName) {
        String datePart = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String uuidPart = UUID.randomUUID().toString().substring(0, 8);
        String ext = "";
        if (originalFileName != null && originalFileName.contains(".")) {
            ext = originalFileName.substring(originalFileName.lastIndexOf("."));
        }
        return "team_" + teamId + "_" + datePart + "_" + uuidPart + ext;
    }

    /**
     * 保存上传文件到指定目录
     * @param part 上传的文件part
     * @param uploadBasePath 上传根目录
     * @param competitionId 竞赛ID（用于目录分组）
     * @param teamId 队伍ID（用于文件名）
     * @return 存储的相对路径（如 /competition_1/team_3_20260705.jpg）
     */
    public static String saveFile(Part part, String uploadBasePath, Integer competitionId, Integer teamId)
            throws IOException {

        // 1. 校验文件
        String contentType = part.getContentType();
        String submittedFileName = part.getSubmittedFileName();
        long fileSize = part.getSize();

        if (!isAllowedType(contentType)) {
            throw new IOException("不支持的文件类型：" + contentType + "，仅支持 JPG/PNG");
        }
        if (!isAllowedExtension(submittedFileName)) {
            throw new IOException("不支持的文件扩展名，仅支持 .jpg/.jpeg/.png");
        }
        if (!isAllowedSize(fileSize)) {
            throw new IOException("文件大小超过限制（最大 10MB）");
        }

        // 2. 创建存储目录: uploadBasePath/competition_<id>/
        String compDir = "competition_" + competitionId;
        String relativeDir = "/" + compDir;
        Path uploadPath = Paths.get(uploadBasePath, compDir);

        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // 3. 生成唯一文件名
        String fileName = generateFileName(teamId, submittedFileName);
        String relativePath = relativeDir + "/" + fileName;

        // 4. 保存文件
        Path filePath = uploadPath.resolve(fileName);
        part.write(filePath.toString());

        return relativePath;
    }

    /**
     * 删除文件
     * @param uploadBasePath 上传根目录
     * @param relativePath 相对路径（如 /competition_1/team_3_file.jpg）
     */
    public static boolean deleteFile(String uploadBasePath, String relativePath) {
        if (relativePath == null || relativePath.isEmpty()) {
            return false;
        }
        try {
            Path filePath = Paths.get(uploadBasePath, relativePath);
            return Files.deleteIfExists(filePath);
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 获取文件扩展名
     */
    public static String getExtension(String fileName) {
        if (fileName == null || !fileName.contains(".")) {
            return "";
        }
        return fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
    }
}
