package com.poster.dao;

import com.poster.model.WorkLike;
import java.util.List;

/**
 * 作品点赞DAO接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface WorkLikeDAO {

    /**
     * 插入点赞记录
     */
    int insert(WorkLike workLike);

    /**
     * 根据ID删除点赞记录
     */
    int deleteById(Integer id);

    /**
     * 取消点赞（根据作品ID和用户ID）
     */
    int deleteByWorkIdAndUserId(Integer workId, Integer userId);

    /**
     * 根据作品ID查询所有点赞
     */
    List<WorkLike> findByWorkId(Integer workId);

    /**
     * 根据用户ID查询所有点赞
     */
    List<WorkLike> findByUserId(Integer userId);

    /**
     * 检查用户是否已点赞
     */
    boolean isLiked(Integer workId, Integer userId);

    /**
     * 统计作品点赞数
     */
    int countByWorkId(Integer workId);
}
