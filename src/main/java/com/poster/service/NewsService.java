package com.poster.service;

import com.poster.model.News;
import java.util.List;

/**
 * 新闻服务接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface NewsService {

    /**
     * 发布新闻
     */
    boolean publishNews(News news);

    /**
     * 更新新闻
     */
    boolean updateNews(News news);

    /**
     * 删除新闻
     */
    boolean deleteNews(Integer newsId);

    /**
     * 根据ID查询新闻
     */
    News getNewsById(Integer newsId);

    /**
     * 查询已发布的新闻列表
     */
    List<News> getPublishedNews();

    /**
     * 查询所有新闻
     */
    List<News> getAllNews();
}
