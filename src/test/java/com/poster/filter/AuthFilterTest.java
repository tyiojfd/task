package com.poster.filter;

import com.poster.model.Role;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class AuthFilterTest {

    @Test
    void participantPermissionIsNotRemovedByAnAdditionalJudgeRole() throws Exception {
        Method permission = AuthFilter.class.getDeclaredMethod(
                "hasPermission", String.class, String.class, List.class
        );
        permission.setAccessible(true);

        List<Role> participantAndJudge = Arrays.asList(role("队员"), role("评委"));
        List<Role> judgeOnly = Collections.singletonList(role("评委"));

        assertTrue((Boolean) permission.invoke(new AuthFilter(), "/application", "teamApplications", participantAndJudge));
        assertFalse((Boolean) permission.invoke(new AuthFilter(), "/application", "teamApplications", judgeOnly));
    }

    @Test
    void onlyKnownPublicUploadKindsBypassAuthentication() throws Exception {
        Method publicResource = AuthFilter.class.getDeclaredMethod(
                "isPublicResource", String.class, String.class
        );
        publicResource.setAccessible(true);

        AuthFilter filter = new AuthFilter();
        assertTrue((Boolean) publicResource.invoke(filter, "/uploads/avatars/avatar.png", null));
        assertTrue((Boolean) publicResource.invoke(filter, "/uploads/competition_4/cover.jpg", null));
        assertFalse((Boolean) publicResource.invoke(filter, "/uploads/competition_4/team_8_secret.png", null));
    }

    @Test
    void objectAwareImageAndUploadEndpointsReachTheirOwnAuthorizationChecks() throws Exception {
        Method permission = AuthFilter.class.getDeclaredMethod(
                "hasPermission", String.class, String.class, List.class
        );
        permission.setAccessible(true);

        List<Role> participant = Collections.singletonList(role("队员"));
        assertTrue((Boolean) permission.invoke(new AuthFilter(), "/image-data", null, participant));
        assertTrue((Boolean) permission.invoke(new AuthFilter(), "/upload", null, participant));
        assertTrue((Boolean) permission.invoke(new AuthFilter(), "/uploads/competition_1/file.png", null, participant));
    }

    private static Role role(String name) {
        Role role = new Role();
        role.setRoleName(name);
        return role;
    }
}
