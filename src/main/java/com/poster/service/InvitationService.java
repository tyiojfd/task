package com.poster.service;

import com.poster.model.Invitation;
import java.util.List;

/**
 * 邀请服务接口
 * @author 杨祥博
 * @date 2026-07-06
 */
public interface InvitationService {

    /**
     * 获取用户收到的所有邀请
     * @param userId 用户ID
     * @return 邀请列表（按邀请时间倒序）
     */
    List<Invitation> getInvitationsForUser(Integer userId);

    /**
     * 接受邀请
     * @param invitationId 邀请ID
     * @param userId 当前用户ID（必须与被邀请人一致）
     * @return 是否成功
     */
    boolean acceptInvitation(Integer invitationId, Integer userId);

    /**
     * 拒绝邀请
     * @param invitationId 邀请ID
     * @param userId 当前用户ID（必须与被邀请人一致）
     * @return 是否成功
     */
    boolean rejectInvitation(Integer invitationId, Integer userId);
}
