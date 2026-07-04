package com.poster.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * 密码加密工具类
 * @author 团队共建
 * @date 2026-07-04
 */
public class PasswordUtil {
    private static final String SALT = "poster_competition_2026";

    /**
     * MD5加密（加盐）
     */
    public static String encrypt(String password) {
        try {
            String saltedPassword = password + SALT;
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] bytes = md.digest(saltedPassword.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("密码加密失败", e);
        }
    }

    /**
     * 验证密码
     */
    public static boolean verify(String inputPassword, String encryptedPassword) {
        return encrypt(inputPassword).equals(encryptedPassword);
    }
}
