package com.poster.dao;

import com.poster.model.Comment;
import java.util.List;

/**
 * 评语记录DAO接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface CommentDAO {

    /**
     * 插入评语记录
     */
    int insert(Comment comment);

    /**
     * 根据ID删除评语记录
     */
    int deleteById(Integer commentId);

    /**
     * 更新评语
     */
    int update(Comment comment);

    /**
     * 根据ID查询评语记录
     */
    Comment findById(Integer commentId);

    /**
     * 根据作品ID查询所有评语
     */
    List<Comment> findByWorkId(Integer workId);

    /**
     * 根据评委ID查询所有评语
     */
    List<Comment> findByJudgeId(Integer judgeId);

    /**
     * 查询所有评语记录
     */
    List<Comment> findAll();
}
