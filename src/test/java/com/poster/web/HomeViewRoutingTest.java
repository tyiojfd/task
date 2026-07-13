package com.poster.web;

import com.poster.controller.IndexServlet;
import com.poster.model.Role;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Method;
import java.util.Arrays;

import static org.junit.jupiter.api.Assertions.assertEquals;

class HomeViewRoutingTest {

    @Test
    void administratorUsesTheAdministratorHome() throws Exception {
        assertEquals("/jsp/admin_home.jsp", resolve(role("管理员")));
    }

    @Test
    void judgeUsesTheJudgeHome() throws Exception {
        assertEquals("/jsp/judge_home.jsp", resolve(role("评委")));
    }

    @Test
    void participantAndAnonymousUsersKeepTheExistingHome() throws Exception {
        assertEquals("/jsp/index.jsp", resolve(role("队员")));
        assertEquals("/jsp/index.jsp", resolve());
    }

    @Test
    void administratorWinsWhenAnAccountHasMultipleRoles() throws Exception {
        assertEquals("/jsp/admin_home.jsp", resolve(role("队员"), role("管理员")));
    }

    private static String resolve(Role... roles) throws Exception {
        Method method = IndexServlet.class.getDeclaredMethod("resolveHomeView", java.util.List.class);
        method.setAccessible(true);
        return (String) method.invoke(new IndexServlet(), Arrays.asList(roles));
    }

    private static Role role(String name) {
        Role role = new Role();
        role.setRoleName(name);
        return role;
    }
}
