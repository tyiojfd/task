package com.poster.service;

import com.poster.model.Comment;
import java.util.List;

/**
 * 评语服务接口
 * @author 队员C
 * @date 2026-07-08
 */
public interface CommentService {

    /**
     * 添加评语
     */
    boolean addComment(Comment comment);

    /**
     * 更新评语
     */
    boolean updateComment(Comment comment);

    /**
     * 删除评语
     */
    boolean deleteComment(Integer commentId);

    /**
     * 根据ID查询评语
     */
    Comment getCommentById(Integer commentId);

    /**
     * 根据作品ID查询所有评语
     */
    List<Comment> getCommentsByWorkId(Integer workId);

    /**
     * 根据评委ID查询所有评语
     */
    List<Comment> getCommentsByJudgeId(Integer judgeId);

    /**
     * 查询所有评语
     */
    List<Comment> getAllComments();
}
