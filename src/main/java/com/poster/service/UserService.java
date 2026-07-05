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
    boolean register(String username, String password, String realName, String email);

    /**
     * 用户登录
     */
    User login(String username, String password);

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
}
