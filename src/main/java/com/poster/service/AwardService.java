package com.poster.service;

import com.poster.model.AutoAwardResult;
import com.poster.model.Award;
import java.util.List;

/**
 * 获奖服务接口
 * @author 团队共建
 * @date 2026-07-04
 */
public interface AwardService {

    /**
     * 设置获奖
     */
    boolean setAward(Award award);

    /**
     * 一键生成获奖名单
     */
    AutoAwardResult autoGenerateAwards(Integer competitionId, Integer issuerId);

    /**
     * 根据竞赛ID查询获奖列表
     */
    List<Award> getAwardsByCompetitionId(Integer competitionId);

    /**
     * 根据作品ID查询获奖信息
     */
    Award getAwardByWorkId(Integer workId);

    /**
     * 生成电子奖状
     */
    boolean generateCertificate(Integer awardId);

    /**
     * 发布获奖公告
     */
    boolean publishAwardAnnouncement(Integer competitionId);
}
