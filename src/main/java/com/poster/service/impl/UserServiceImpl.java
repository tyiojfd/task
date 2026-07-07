package com.poster.service.impl;

import com.poster.dao.RoleDAO;
import com.poster.dao.UserDAO;
import com.poster.dao.UserRoleDAO;
import com.poster.dao.impl.RoleDAOImpl;
import com.poster.dao.impl.UserDAOImpl;
import com.poster.dao.impl.UserRoleDAOImpl;
import com.poster.model.Role;
import com.poster.model.User;
import com.poster.service.UserService;
import com.poster.util.PasswordUtil;

import java.util.List;

/**
 * 用户服务实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class UserServiceImpl implements UserService {

    private UserDAO userDAO = new UserDAOImpl();
    private RoleDAO roleDAO = new RoleDAOImpl();
    private UserRoleDAO userRoleDAO = new UserRoleDAOImpl();

    @Override
    public boolean register(String username, String password, String realName, String email, String avatar) {
        // 1. 检查用户名是否已存在
        if (userDAO.findByUsername(username) != null) {
            return false; // 用户名已存在
        }

        // 2. 检查邮箱是否已存在
        if (userDAO.findByEmail(email) != null) {
            return false; // 邮箱已存在
        }

        // 3. 加密密码
        String encryptedPassword = PasswordUtil.encrypt(password);

        // 4. 创建用户对象
        User user = new User();
        user.setUsername(username);
        user.setPassword(encryptedPassword);
        user.setRealName(realName);
        user.setEmail(email);
        user.setAvatar(avatar);
        user.setStatus(1);

        // 5. 插入数据库
        int userId = userDAO.insert(user);
        if (userId > 0) {
            // 6. 分配默认角色（队员，role_name='队员'）
            Role defaultRole = roleDAO.findByName("队员");
            if (defaultRole != null) {
                userRoleDAO.assignRole(userId, defaultRole.getRoleId());
            }
            return true;
        }
        return false;
    }

    @Override
    public User login(String username, String password) {
        return login(username, password, null);
    }

    @Override
    public User login(String username, String password, String expectedRole) {
        // 1. 根据用户名查询用户
        User user = userDAO.findByUsername(username);
        if (user == null) {
            return null; // 用户不存在
        }

        // 2. 验证密码
        if (!PasswordUtil.verify(password, user.getPassword())) {
            return null; // 密码错误
        }

        // 3. 检查用户状态
        if (user.getStatus() == null || user.getStatus() == 0) {
            return null; // 用户已禁用
        }

        // 4. 如指定登录角色，则校验用户是否拥有该角色
        if (expectedRole != null && !expectedRole.trim().isEmpty()) {
            List<Role> roles = userRoleDAO.findRolesByUserId(user.getUserId());
            boolean matched = false;
            if (roles != null) {
                for (Role role : roles) {
                    if (expectedRole.equals(role.getRoleName())) {
                        matched = true;
                        break;
                    }
                }
            }
            if (!matched) {
                return null;
            }
        }

        return user;
    }

    @Override
    public User getUserById(Integer userId) {
        return userDAO.findById(userId);
    }

    @Override
    public User getUserByUsername(String username) {
        return userDAO.findByUsername(username);
    }

    @Override
    public boolean updateUser(User user) {
        return userDAO.update(user) > 0;
    }

    @Override
    public boolean changePassword(Integer userId, String oldPassword, String newPassword) {
        User user = userDAO.findById(userId);
        if (user == null) {
            return false;
        }
        // 验证旧密码
        if (!PasswordUtil.verify(oldPassword, user.getPassword())) {
            return false;
        }
        // 加密新密码并更新
        user.setPassword(PasswordUtil.encrypt(newPassword));
        return userDAO.update(user) > 0;
    }

    @Override
    public boolean updateUserStatus(Integer userId, Integer status) {
        User user = userDAO.findById(userId);
        if (user == null) {
            return false;
        }
        user.setStatus(status);
        return userDAO.update(user) > 0;
    }

    @Override
    public List<User> getAllUsers() {
        return userDAO.findAll();
    }

    @Override
    public List<Role> getUserRoles(Integer userId) {
        return userRoleDAO.findRolesByUserId(userId);
    }
}
