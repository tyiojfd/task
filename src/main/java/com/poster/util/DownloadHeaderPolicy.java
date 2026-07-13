package com.poster.util;

/**
 * 构造安全的附件下载响应头。
 */
public final class DownloadHeaderPolicy {

    private DownloadHeaderPolicy() {
    }

    public static String attachment(String fileName) {
        String safeName = fileName == null ? "download" : fileName.trim();
        int slash = Math.max(safeName.lastIndexOf('/'), safeName.lastIndexOf('\\'));
        if (slash >= 0) {
            safeName = safeName.substring(slash + 1);
        }
        safeName = safeName.replace("\r", "_")
                .replace("\n", "_")
                .replace("\"", "_");
        if (safeName.isEmpty() || ".".equals(safeName) || "..".equals(safeName)) {
            safeName = "download";
        }
        return "attachment; filename=\"" + safeName + "\"";
    }
}
