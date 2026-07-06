package com.poster.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * 数据库连接工具类
 * @author 团队共建
 * @date 2026-07-04
 */
public class DBUtil {
    private static final String URL = "jdbc:mysql://143.110.133.32:3306/poster_competition?useSSL=false&serverTimezone=UTC&characterEncoding=utf8&connectTimeout=5000&socketTimeout=10000";
    private static final String USER = "dev";//账号
    private static final String PASSWORD = "24136112";//密码

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            throw new RuntimeException("MySQL驱动加载失败", e);
        }
    }

    /**
     * 获取数据库连接
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    /**
     * 关闭数据库连接
     */
    public static void close(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
