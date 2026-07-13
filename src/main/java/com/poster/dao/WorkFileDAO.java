package com.poster.dao;

import com.poster.model.WorkFile;
import java.util.List;

/**
 * 作品文件DAO接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface WorkFileDAO {

    /**
     * 插入作品文件
     */
    int insert(WorkFile workFile);

    /**
     * 根据ID删除作品文件
     */
    int deleteById(Integer fileId);

    /**
     * 根据作品ID删除所有文件
     */
    int deleteByWorkId(Integer workId);

    /**
     * 更新文件信息
     */
    int update(WorkFile workFile);

    /**
     * 根据ID查询文件
     */
    WorkFile findById(Integer fileId);

    /**
     * 根据存储路径查询文件，供下载接口进行对象权限校验。
     */
    WorkFile findByFilePath(String filePath);

    /**
     * 根据作品ID查询所有文件
     */
    List<WorkFile> findByWorkId(Integer workId);

    /**
     * 查询所有文件
     */
    List<WorkFile> findAll();
}
