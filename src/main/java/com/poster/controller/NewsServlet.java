package com.poster.controller;

import com.poster.model.News;
import com.poster.model.Role;
import com.poster.model.User;
import com.poster.service.NewsService;
import com.poster.service.impl.NewsServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

/**
 * 新闻Servlet
 * @author 队员C
 * @date 2026-07-06
 */
@WebServlet("/news")
public class NewsServlet extends HttpServlet {

    private NewsService newsService = new NewsServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if (action == null || "list".equals(action)) {
            // 新闻列表（已发布的新闻）
            listNews(request, response);
        } else if ("detail".equals(action)) {
            // 新闻详情
            showNewsDetail(request, response);
        } else if ("publish".equals(action)) {
            // 跳转到发布页面
            request.getRequestDispatcher("/jsp/news_add.jsp").forward(request, response);
        } else if ("edit".equals(action)) {
            // 跳转到编辑页面
            showEditPage(request, response);
        } else if ("manage".equals(action)) {
            // 新闻管理（管理员查看所有新闻）
            manageNews(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/news?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("publish".equals(action)) {
            // 发布新闻
            publishNews(request, response);
        } else if ("update".equals(action)) {
            // 更新新闻
            updateNews(request, response);
        } else if ("delete".equals(action)) {
            // 删除新闻
            deleteNews(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/news?action=list");
        }
    }

    /**
     * 显示新闻列表（已发布的新闻）
     */
    private void listNews(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<News> newsList = newsService.getPublishedNews();
        request.setAttribute("newsList", newsList);
        request.getRequestDispatcher("/jsp/news_list.jsp").forward(request, response);
    }

    /**
     * 显示新闻详情
     */
    private void showNewsDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                Integer id = Integer.parseInt(idStr);
                News news = newsService.getNewsById(id);
                if (news != null) {
                    request.setAttribute("news", news);
                    request.getRequestDispatcher("/jsp/news_detail.jsp").forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/news?action=list");
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/news?action=list");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/news?action=list");
        }
    }

    /**
     * 显示编辑页面
     */
    private void showEditPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 管理员权限检查
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/index");
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                Integer id = Integer.parseInt(idStr);
                News news = newsService.getNewsById(id);
                if (news != null) {
                    request.setAttribute("news", news);
                    request.getRequestDispatcher("/jsp/news_edit.jsp").forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/news?action=manage");
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/news?action=manage");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/news?action=manage");
        }
    }

    /**
     * 新闻管理（查看所有新闻，包括草稿）
     */
    private void manageNews(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 管理员权限检查
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/index");
            return;
        }

        List<News> newsList = newsService.getAllNews();
        request.setAttribute("newsList", newsList);
        request.getRequestDispatcher("/jsp/news_manage.jsp").forward(request, response);
    }

    /**
     * 发布新闻
     */
    private void publishNews(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 管理员权限检查
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/index");
            return;
        }

        try {
            News news = new News();
            news.setTitle(request.getParameter("title"));
            news.setContent(request.getParameter("content"));

            String competitionIdStr = request.getParameter("competitionId");
            if (competitionIdStr != null && !competitionIdStr.isEmpty()) {
                news.setCompetitionId(Integer.parseInt(competitionIdStr));
            }

            // 获取当前登录用户ID
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("user") != null) {
                User user = (User) session.getAttribute("user");
                news.setAuthorId(user.getUserId());
            } else {
                request.setAttribute("error", "请先登录");
                request.getRequestDispatcher("/jsp/news_add.jsp").forward(request, response);
                return;
            }

            boolean success = newsService.publishNews(news);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/news?action=detail&id=" + news.getNewsId());
            } else {
                request.setAttribute("error", "发布新闻失败，请检查输入信息");
                request.getRequestDispatcher("/jsp/news_add.jsp").forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "发布新闻时发生错误: " + e.getMessage());
            request.getRequestDispatcher("/jsp/news_add.jsp").forward(request, response);
        }
    }

    /**
     * 更新新闻
     */
    private void updateNews(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 管理员权限检查
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/index");
            return;
        }

        try {
            String idStr = request.getParameter("newsId");
            if (idStr == null || idStr.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/news?action=manage");
                return;
            }

            Integer newsId = Integer.parseInt(idStr);
            News news = newsService.getNewsById(newsId);
            if (news == null) {
                response.sendRedirect(request.getContextPath() + "/news?action=manage");
                return;
            }

            news.setTitle(request.getParameter("title"));
            news.setContent(request.getParameter("content"));

            String competitionIdStr = request.getParameter("competitionId");
            if (competitionIdStr != null && !competitionIdStr.isEmpty()) {
                news.setCompetitionId(Integer.parseInt(competitionIdStr));
            } else {
                news.setCompetitionId(null);
            }

            String statusStr = request.getParameter("status");
            if (statusStr != null && !statusStr.isEmpty()) {
                news.setStatus(Integer.parseInt(statusStr));
            }

            boolean success = newsService.updateNews(news);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/news?action=detail&id=" + newsId);
            } else {
                request.setAttribute("error", "更新新闻失败");
                request.setAttribute("news", news);
                request.getRequestDispatcher("/jsp/news_edit.jsp").forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "更新新闻时发生错误: " + e.getMessage());
            request.getRequestDispatcher("/jsp/news_edit.jsp").forward(request, response);
        }
    }

    /**
     * 检查当前用户是否为管理员
     */
    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        @SuppressWarnings("unchecked")
        List<Role> roles = (List<Role>) session.getAttribute("roles");
        if (roles != null) {
            for (Role role : roles) {
                if ("管理员".equals(role.getRoleName())) return true;
            }
        }
        return false;
    }

    /**
     * 删除新闻
     */
    private void deleteNews(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 管理员权限检查
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/index");
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                Integer id = Integer.parseInt(idStr);
                newsService.deleteNews(id);
            } catch (NumberFormatException e) {
                // 忽略无效ID
            }
        }
        response.sendRedirect(request.getContextPath() + "/news?action=manage");
    }
}
