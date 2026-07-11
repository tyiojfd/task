package com.poster.dao;

import com.poster.model.User;
import java.util.List;

/**
 * 用户DAO接口
 * @author 队长模块
 * @date 2026-07-04
 */
public interface UserDAO {

    /**
     * 插入用户
     */
    int insert(User user);

    /**
     * 根据ID删除用户
     */
    int deleteById(Integer userId);

    /**
     * 更新用户信息
     */
    int update(User user);

    /**
     * 根据ID查询用户
     */
    User findById(Integer userId);

    /**
     * 根据用户名查询用户
     */
    User findByUsername(String username);

    /**
     * 查询所有用户
     */
    List<User> findAll();

    /**
     * 根据邮箱查询用户
     */
    User findByEmail(String email);

    /**
     * 根据真实姓名模糊搜索用户
     * @param keyword 搜索关键字
     * @return 匹配的用户列表（最多20条）
     */
    List<User> searchByRealName(String keyword);

    /**
     * 搜索可邀请的参赛用户（队员/队长，排除管理员/评委）
     */
    List<User> searchInviteEligibleUsers(String keyword);

    /**
     * 统计用户总数
     */
    int count();

    /**
     * 更新用户密码
     */
    int updatePassword(Integer userId, String password);

    /**
     * 搜索用户（按用户名/姓名/邮箱模糊匹配）
     */
    List<User> search(String keyword);
}
