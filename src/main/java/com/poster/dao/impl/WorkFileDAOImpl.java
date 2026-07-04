package com.poster.dao.impl;

import com.poster.dao.WorkFileDAO;
import com.poster.model.WorkFile;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 作品文件DAO实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class WorkFileDAOImpl implements WorkFileDAO {

    @Override
    public int insert(WorkFile workFile) {
        // TODO: 实现作品文件插入
        String sql = "INSERT INTO work_file (work_id, file_name, file_path, file_size, file_type) VALUES (?, ?, ?, ?, ?)";
        return 0;
    }

    @Override
    public int deleteById(Integer fileId) {
        // TODO: 实现根据ID删除作品文件
        String sql = "DELETE FROM work_file WHERE file_id = ?";
        return 0;
    }

    @Override
    public int deleteByWorkId(Integer workId) {
        // TODO: 实现根据作品ID删除所有文件
        String sql = "DELETE FROM work_file WHERE work_id = ?";
        return 0;
    }

    @Override
    public int update(WorkFile workFile) {
        // TODO: 实现文件信息更新
        String sql = "UPDATE work_file SET file_name=?, file_path=? WHERE file_id=?";
        return 0;
    }

    @Override
    public WorkFile findById(Integer fileId) {
        // TODO: 实现根据ID查询文件
        String sql = "SELECT * FROM work_file WHERE file_id = ?";
        return null;
    }

    @Override
    public List<WorkFile> findByWorkId(Integer workId) {
        // TODO: 实现根据作品ID查询所有文件
        String sql = "SELECT * FROM work_file WHERE work_id = ?";
        return new ArrayList<>();
    }

    @Override
    public List<WorkFile> findAll() {
        // TODO: 实现查询所有文件
        String sql = "SELECT * FROM work_file ORDER BY upload_time DESC";
        return new ArrayList<>();
    }
}
