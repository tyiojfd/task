package com.poster.dao;

import com.poster.model.Certificate;
import java.util.List;

/**
 * 电子奖状DAO接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface CertificateDAO {

    /**
     * 插入电子奖状
     */
    int insert(Certificate certificate);

    /**
     * 根据ID删除奖状
     */
    int deleteById(Integer certificateId);

    /**
     * 更新奖状信息
     */
    int update(Certificate certificate);

    /**
     * 根据ID查询奖状
     */
    Certificate findById(Integer certificateId);

    /**
     * 根据获奖ID查询奖状
     */
    Certificate findByAwardId(Integer awardId);

    /**
     * 根据队伍ID查询奖状
     */
    List<Certificate> findByTeamId(Integer teamId);

    /**
     * 查询所有奖状
     */
    List<Certificate> findAll();
}
