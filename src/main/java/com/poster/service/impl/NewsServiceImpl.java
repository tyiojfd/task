package com.poster.service.impl;

import com.poster.dao.NewsDAO;
import com.poster.dao.impl.NewsDAOImpl;
import com.poster.model.News;
import com.poster.service.NewsService;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 新闻服务实现类
 * @author 队员C
 * @date 2026-07-06
 */
public class NewsServiceImpl implements NewsService {

    private NewsDAO newsDAO = new NewsDAOImpl();

    @Override
    public boolean publishNews(News news) {
        // 1. 输入验证
        if (news.getTitle() == null || news.getTitle().trim().isEmpty()) {
            return false;
        }
        if (news.getContent() == null || news.getContent().trim().isEmpty()) {
            return false;
        }
        if (news.getAuthorId() == null) {
            return false;
        }

        // 2. 设置状态为已发布
        news.setStatus(1);

        // 3. 调用DAO插入数据库
        return newsDAO.insert(news) > 0;
    }

    @Override
    public boolean updateNews(News news) {
        // 1. 输入验证
        if (news.getNewsId() == null) {
            return false;
        }
        if (news.getTitle() == null || news.getTitle().trim().isEmpty()) {
            return false;
        }
        if (news.getContent() == null || news.getContent().trim().isEmpty()) {
            return false;
        }

        // 2. 调用DAO更新数据库
        return newsDAO.update(news) > 0;
    }

    @Override
    public boolean deleteNews(Integer newsId) {
        if (newsId == null) {
            return false;
        }
        return newsDAO.deleteById(newsId) > 0;
    }

    @Override
    public News getNewsById(Integer newsId) {
        if (newsId == null) {
            return null;
        }
        return newsDAO.findById(newsId);
    }

    @Override
    public List<News> getPublishedNews() {
        // 查询状态为1（已发布）的新闻
        return newsDAO.findByStatus(1);
    }

    @Override
    public List<News> getAllNews() {
        return newsDAO.findAll();
    }
}
