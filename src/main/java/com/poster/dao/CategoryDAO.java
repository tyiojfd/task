package com.poster.dao;

import com.poster.model.CompetitionCategory;
import java.util.List;

/**
 * 竞赛子类DAO接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface CategoryDAO {

    /**
     * 插入竞赛子类
     */
    int insert(CompetitionCategory category);

    /**
     * 根据ID删除竞赛子类
     */
    int deleteById(Integer categoryId);

    /**
     * 更新竞赛子类信息
     */
    int update(CompetitionCategory category);

    /**
     * 根据ID查询竞赛子类
     */
    CompetitionCategory findById(Integer categoryId);

    /**
     * 根据竞赛ID查询所有子类
     */
    List<CompetitionCategory> findByCompetitionId(Integer competitionId);

    /**
     * 查询所有竞赛子类
     */
    List<CompetitionCategory> findAll();
}
