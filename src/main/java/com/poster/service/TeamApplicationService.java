package com.poster.service;

import com.poster.model.TeamApplication;
import java.util.List;

/**
 * 入队申请服务接口
 * @author Claude
 * @date 2026-07-12
 */
public interface TeamApplicationService {
    boolean applyToTeam(Integer teamId, Integer applicantId, String message);
    boolean approveApplication(Integer applicationId, Integer leaderId);
    boolean rejectApplication(Integer applicationId, Integer leaderId);
    boolean cancelApplication(Integer applicationId, Integer applicantId);
    List<TeamApplication> getApplicationsByApplicantId(Integer applicantId);
    List<TeamApplication> getApplicationsByTeamId(Integer teamId);
    List<TeamApplication> getPendingApplicationsByTeamId(Integer teamId);
    TeamApplication getPendingApplication(Integer teamId, Integer applicantId);
}
