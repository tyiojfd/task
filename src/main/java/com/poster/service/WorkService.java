package com.poster.service;

import com.poster.model.Work;
import java.util.List;

/**
 * 作品服务接口
 * @author 队员B
 * @date 2026-07-06
 */
public interface WorkService {

    /**
     * 提交作品
     */
    boolean submitWork(Work work);

    /**
     * 更新作品信息
     */
    boolean updateWork(Work work);

    /**
     * 删除作品
     */
    boolean deleteWork(Integer workId, Integer teamId);

    /**
     * 根据ID查询作品
     */
    Work getWorkById(Integer workId);

    /**
     * 根据队伍ID查询作品
     */
    List<Work> getWorksByTeamId(Integer teamId);

    /**
     * 根据竞赛ID查询作品
     */
    List<Work> getWorksByCompetitionId(Integer competitionId);

    /**
     * 根据用户ID查询作品（用户所在队伍的所有作品）
     */
    List<Work> getWorksByUserId(Integer userId);

    /**
     * 作品点赞
     */
    boolean likeWork(Integer workId, Integer userId);

    /**
     * 取消点赞
     */
    boolean unlikeWork(Integer workId, Integer userId);

    /**
     * 分享作品
     */
    boolean shareWork(Integer workId, Integer userId, String platform);

    /**
     * 获取作品点赞数
     */
    int getLikeCount(Integer workId);

    /**
     * 检查用户是否已点赞
     */
    boolean isWorkLikedByUser(Integer workId, Integer userId);
}
