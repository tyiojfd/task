package com.poster.service;

import com.poster.model.Role;
import com.poster.model.User;
import java.util.List;

/**
 * 用户服务接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface UserService {

    /**
     * 用户注册
     */
    boolean register(String username, String password, String realName, String email, String avatar);

    /**
     * 用户登录
     */
    User login(String username, String password);

    /**
     * 按指定角色登录
     */
    User login(String username, String password, String expectedRole);

    /**
     * 根据ID查询用户
     */
    User getUserById(Integer userId);

    /**
     * 根据用户名查询用户
     */
    User getUserByUsername(String username);

    /**
     * 更新用户信息
     */
    boolean updateUser(User user);

    /**
     * 修改密码
     */
    boolean changePassword(Integer userId, String oldPassword, String newPassword);

    /**
     * 启用/禁用用户
     */
    boolean updateUserStatus(Integer userId, Integer status);

    /**
     * 获取所有用户
     */
    List<User> getAllUsers();

    /**
     * 获取用户角色列表
     */
    List<Role> getUserRoles(Integer userId);

    /**
     * 找回密码（验证用户名+邮箱匹配后重置）
     */
    boolean resetPassword(String username, String email, String newPassword);

    /**
     * 搜索用户（管理员功能）
     */
    List<User> searchUsers(String keyword);

    /**
     * 获取所有角色
     */
    List<Role> getAllRoles();

    /**
     * 更新用户角色（管理员功能）
     */
    boolean updateUserRoles(Integer userId, String[] roleIds);
}
