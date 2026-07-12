package com.poster.dao;

import com.poster.model.TeamApplication;
import java.util.List;

/**
 * 入队申请DAO接口
 * @author Claude
 * @date 2026-07-12
 */
public interface TeamApplicationDAO {
    int insert(TeamApplication application);
    int update(TeamApplication application);
    TeamApplication findById(Integer applicationId);
    List<TeamApplication> findByTeamId(Integer teamId);
    List<TeamApplication> findByApplicantId(Integer applicantId);
    List<TeamApplication> findPendingByTeamId(Integer teamId);
    TeamApplication findPendingByTeamIdAndApplicantId(Integer teamId, Integer applicantId);
}
