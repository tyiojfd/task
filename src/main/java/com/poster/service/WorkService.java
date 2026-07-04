package com.poster.service;

import com.poster.model.Work;
import java.util.List;

/**
 * 作品服务接口
 * @author 团队共建
 * @date 2026-07-04
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
}
