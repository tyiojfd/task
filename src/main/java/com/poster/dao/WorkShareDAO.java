package com.poster.dao;

import com.poster.model.WorkShare;
import java.util.List;

/**
 * 作品分享DAO接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface WorkShareDAO {

    /**
     * 插入分享记录
     */
    int insert(WorkShare workShare);

    /**
     * 根据ID删除分享记录
     */
    int deleteById(Integer id);

    /**
     * 根据作品ID查询所有分享记录
     */
    List<WorkShare> findByWorkId(Integer workId);

    /**
     * 根据用户ID查询所有分享记录
     */
    List<WorkShare> findByUserId(Integer userId);

    /**
     * 统计作品分享数
     */
    int countByWorkId(Integer workId);

    /**
     * 查询所有分享记录
     */
    List<WorkShare> findAll();
}
