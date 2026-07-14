package com.poster.service.impl;

import com.poster.dao.RoleDAO;
import com.poster.dao.UserDAO;
import com.poster.dao.UserRoleDAO;
import com.poster.model.Role;
import com.poster.model.User;
import com.poster.util.PasswordUtil;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class UserServiceImplTest {

    @Test
    void registrationRollsBackWhenDefaultRoleIsMissing() {
        RecordingUserDAO userDAO = new RecordingUserDAO();
        UserServiceImpl service = new UserServiceImpl(
                userDAO,
                new FixedRoleDAO(null),
                new FixedUserRoleDAO(true)
        );

        assertFalse(service.register("new-user", "password", "New User", "new@example.com", null));
        assertEquals(Integer.valueOf(1), userDAO.deletedUserId);
    }

    @Test
    void registrationRollsBackWhenDefaultRoleAssignmentFails() {
        RecordingUserDAO userDAO = new RecordingUserDAO();
        Role memberRole = role(3, "队员");
        UserServiceImpl service = new UserServiceImpl(
                userDAO,
                new FixedRoleDAO(memberRole),
                new FixedUserRoleDAO(false)
        );

        assertFalse(service.register("new-user", "password", "New User", "new@example.com", null));
        assertEquals(Integer.valueOf(1), userDAO.deletedUserId);
    }

    @Test
    void registrationSucceedsOnlyAfterDefaultRoleAssignment() {
        RecordingUserDAO userDAO = new RecordingUserDAO();
        Role memberRole = role(3, "队员");
        FixedUserRoleDAO userRoleDAO = new FixedUserRoleDAO(true);
        UserServiceImpl service = new UserServiceImpl(
                userDAO,
                new FixedRoleDAO(memberRole),
                userRoleDAO
        );

        assertTrue(service.register("new-user", "password", "New User", "new@example.com", null));
        assertEquals(Integer.valueOf(1), userRoleDAO.assignedUserId);
        assertEquals(Integer.valueOf(3), userRoleDAO.assignedRoleId);
        assertEquals(null, userDAO.deletedUserId);
    }

    @Test
    void participantCanUseCommonLoginWhenAlsoAssignedAsJudge() {
        RecordingUserDAO userDAO = new RecordingUserDAO();
        User existingUser = new User();
        existingUser.setUserId(8);
        existingUser.setUsername("multi-role");
        existingUser.setPassword(PasswordUtil.encrypt("password"));
        existingUser.setStatus(1);
        userDAO.userForLookup = existingUser;

        UserServiceImpl service = new UserServiceImpl(
                userDAO,
                new FixedRoleDAO(null),
                new FixedUserRoleDAO(true, Arrays.asList(role(2, "队员"), role(3, "评委")))
        );

        assertNotNull(service.login("multi-role", "password", "普通用户"));
    }

    private static Role role(int id, String name) {
        Role role = new Role();
        role.setRoleId(id);
        role.setRoleName(name);
        return role;
    }

    private static class RecordingUserDAO implements UserDAO {
        private Integer deletedUserId;
        private User userForLookup;

        @Override
        public int insert(User user) {
            user.setUserId(1);
            return 1;
        }

        @Override
        public int deleteById(Integer userId) {
            deletedUserId = userId;
            return 1;
        }

        @Override
        public int update(User user) {
            return 1;
        }

        @Override
        public User findById(Integer userId) {
            return null;
        }

        @Override
        public User findByUsername(String username) {
            return userForLookup;
        }

        @Override
        public List<User> findAll() {
            return Collections.emptyList();
        }

        @Override
        public User findByEmail(String email) {
            return null;
        }

        @Override
        public List<User> searchByRealName(String keyword) {
            return Collections.emptyList();
        }

        @Override
        public List<User> searchInviteEligibleUsers(String keyword) {
            return Collections.emptyList();
        }

        @Override
        public int count() {
            return 0;
        }

        @Override
        public int updatePassword(Integer userId, String password) {
            return 1;
        }

        @Override
        public List<User> search(String keyword) {
            return Collections.emptyList();
        }

        @Override
        public List<User> findAllWithLimit(int offset, int limit) {
            return Collections.emptyList();
        }

        @Override
        public List<User> searchWithLimit(String keyword, int offset, int limit) {
            return Collections.emptyList();
        }
    }

    private static class FixedRoleDAO implements RoleDAO {
        private final Role defaultRole;

        private FixedRoleDAO(Role defaultRole) {
            this.defaultRole = defaultRole;
        }

        @Override
        public int insert(Role role) {
            return 1;
        }

        @Override
        public int deleteById(Integer roleId) {
            return 1;
        }

        @Override
        public int update(Role role) {
            return 1;
        }

        @Override
        public Role findById(Integer roleId) {
            return defaultRole;
        }

        @Override
        public Role findByName(String roleName) {
            return defaultRole;
        }

        @Override
        public List<Role> findAll() {
            return defaultRole == null ? Collections.emptyList() : Collections.singletonList(defaultRole);
        }
    }

    private static class FixedUserRoleDAO implements UserRoleDAO {
        private final boolean assignmentResult;
        private final List<Role> roles;
        private Integer assignedUserId;
        private Integer assignedRoleId;

        private FixedUserRoleDAO(boolean assignmentResult) {
            this(assignmentResult, Collections.emptyList());
        }

        private FixedUserRoleDAO(boolean assignmentResult, List<Role> roles) {
            this.assignmentResult = assignmentResult;
            this.roles = roles;
        }

        @Override
        public boolean assignRole(Integer userId, Integer roleId) {
            assignedUserId = userId;
            assignedRoleId = roleId;
            return assignmentResult;
        }

        @Override
        public boolean removeRole(Integer userId, Integer roleId) {
            return true;
        }

        @Override
        public List<Role> findRolesByUserId(Integer userId) {
            return roles;
        }

        @Override
        public boolean deleteByUserId(Integer userId) {
            return true;
        }
    }
}
