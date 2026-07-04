package com.poster.dao;

import com.poster.model.Invitation;
import java.util.List;

/**
 * 邀请记录DAO接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface InvitationDAO {

    /**
     * 插入邀请记录
     */
    int insert(Invitation invitation);

    /**
     * 根据ID删除邀请记录
     */
    int deleteById(Integer invitationId);

    /**
     * 更新邀请状态
     */
    int update(Invitation invitation);

    /**
     * 根据ID查询邀请记录
     */
    Invitation findById(Integer invitationId);

    /**
     * 根据被邀请人ID查询邀请
     */
    List<Invitation> findByInviteeId(Integer inviteeId);

    /**
     * 根据队伍ID查询邀请
     */
    List<Invitation> findByTeamId(Integer teamId);

    /**
     * 根据状态查询邀请
     */
    List<Invitation> findByStatus(Integer status);

    /**
     * 查询所有邀请记录
     */
    List<Invitation> findAll();
}
