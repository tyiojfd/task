package com.poster.model;

/**
 * 竞赛子类实体类
 * @author 团队共建
 * @date 2026-07-04
 */
public class CompetitionCategory {
    private Integer categoryId;
    private Integer competitionId;
    private String categoryName;
    private String categoryDesc;

    public CompetitionCategory() {}

    public Integer getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Integer categoryId) {
        this.categoryId = categoryId;
    }

    public Integer getCompetitionId() {
        return competitionId;
    }

    public void setCompetitionId(Integer competitionId) {
        this.competitionId = competitionId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getCategoryDesc() {
        return categoryDesc;
    }

    public void setCategoryDesc(String categoryDesc) {
        this.categoryDesc = categoryDesc;
    }
}
