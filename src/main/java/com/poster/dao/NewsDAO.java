package com.poster.dao;

import com.poster.model.News;
import java.util.List;

/**
 * 新闻公告DAO接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface NewsDAO {

    /**
     * 插入新闻
     */
    int insert(News news);

    /**
     * 根据ID删除新闻
     */
    int deleteById(Integer newsId);

    /**
     * 更新新闻信息
     */
    int update(News news);

    /**
     * 根据ID查询新闻
     */
    News findById(Integer newsId);

    /**
     * 根据状态查询新闻
     */
    List<News> findByStatus(Integer status);

    /**
     * 根据发布人查询新闻
     */
    List<News> findByPublisherId(Integer publisherId);

    /**
     * 查询所有新闻（按发布时间倒序）
     */
    List<News> findAll();

    /**
     * 统计新闻总数
     */
    int count();
}
