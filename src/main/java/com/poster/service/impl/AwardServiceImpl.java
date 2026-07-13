package com.poster.service.impl;

import com.poster.dao.AwardDAO;
import com.poster.dao.CertificateDAO;
import com.poster.dao.CompetitionDAO;
import com.poster.dao.NewsDAO;
import com.poster.dao.ScoreDAO;
import com.poster.dao.WorkDAO;
import com.poster.dao.impl.AwardDAOImpl;
import com.poster.dao.impl.CertificateDAOImpl;
import com.poster.dao.impl.CompetitionDAOImpl;
import com.poster.dao.impl.NewsDAOImpl;
import com.poster.dao.impl.ScoreDAOImpl;
import com.poster.dao.impl.WorkDAOImpl;
import com.poster.model.Competition;
import com.poster.model.Award;
import com.poster.model.Certificate;
import com.poster.model.News;
import com.poster.model.Work;
import com.poster.service.AwardService;
import com.poster.util.AwardEligibilityPolicy;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;

/**
 * 获奖服务实现类
 * @author 队员C
 * @date 2026-07-08
 */
public class AwardServiceImpl implements AwardService {

    private AwardDAO awardDAO = new AwardDAOImpl();
    private CertificateDAO certificateDAO = new CertificateDAOImpl();
    private NewsDAO newsDAO = new NewsDAOImpl();
    private WorkDAO workDAO = new WorkDAOImpl();
    private CompetitionDAO competitionDAO = new CompetitionDAOImpl();
    private ScoreDAO scoreDAO = new ScoreDAOImpl();

    @Override
    public boolean setAward(Award award) {
        if (award == null) {
            return false;
        }
        // 1. 验证获奖等级
        if (award.getAwardLevel() == null || award.getAwardLevel().trim().isEmpty()) {
            return false;
        }
        String level = award.getAwardLevel().trim();
        if (!level.equals("一等奖") && !level.equals("二等奖") && !level.equals("三等奖")) {
            return false;
        }

        // 2. 验证必要字段
        if (award.getCompetitionId() == null || award.getWorkId() == null
                || award.getFinalScore() == null || award.getIssuerId() == null) {
            return false;
        }

        // 3. 验证最终得分范围
        if (award.getFinalScore().isNaN() || award.getFinalScore().isInfinite()
                || award.getFinalScore() < 0 || award.getFinalScore() > 100) {
            return false;
        }

        // 4. 验证竞赛已结束、作品已提交且至少存在一条评分
        Work work = workDAO.findById(award.getWorkId());
        Competition competition = competitionDAO.findById(award.getCompetitionId());
        List<com.poster.model.Score> scores = scoreDAO.findByWorkId(award.getWorkId());
        boolean hasScore = scores != null && !scores.isEmpty();
        if (!AwardEligibilityPolicy.isEligible(competition, work, hasScore)) {
            return false;
        }

        // 5. 检查该作品是否已获奖（一个作品只能获奖一次）
        Award existing = awardDAO.findByWorkId(award.getWorkId());
        if (existing != null) {
            return false;
        }

        // 6. 插入获奖记录
        boolean success = awardDAO.insert(award) > 0;

        // 7. 自动生成电子奖状
        if (success && !generateCertificate(award.getAwardId())) {
            awardDAO.deleteById(award.getAwardId());
            return false;
        }

        return success;
    }

    @Override
    public List<Award> getAwardsByCompetitionId(Integer competitionId) {
        if (competitionId == null) {
            return null;
        }
        return awardDAO.findByCompetitionId(competitionId);
    }

    @Override
    public Award getAwardByWorkId(Integer workId) {
        if (workId == null) {
            return null;
        }
        return awardDAO.findByWorkId(workId);
    }

    @Override
    public boolean generateCertificate(Integer awardId) {
        if (awardId == null) {
            return false;
        }

        // 1. 查询获奖信息
        Award award = awardDAO.findById(awardId);
        if (award == null) {
            return false;
        }

        // 2. 检查是否已生成奖状
        Certificate existing = certificateDAO.findByAwardId(awardId);
        if (existing != null) {
            return true; // 已存在奖状
        }

        // 3. 生成唯一奖状编号: CERT-YYYYMMDD-XXXX
        String dateStr = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String uniqueId = UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        String certificateNo = "CERT-" + dateStr + "-" + uniqueId;

        // 4. 奖状文件路径（JSP查看页面，不是实际文件）
        String filePath = "/certificate?action=view&awardId=" + awardId;

        // 5. 保存奖状记录
        Certificate certificate = new Certificate();
        certificate.setAwardId(awardId);
        certificate.setCertificateNo(certificateNo);
        certificate.setFilePath(filePath);

        return certificateDAO.insert(certificate) > 0;
    }

    @Override
    public boolean publishAwardAnnouncement(Integer competitionId) {
        if (competitionId == null) {
            return false;
        }

        // 1. 查询该竞赛的所有获奖记录
        List<Award> awards = awardDAO.findByCompetitionId(competitionId);
        if (awards == null || awards.isEmpty()) {
            return false;
        }

        String title = "竞赛获奖公告 - 竞赛ID:" + competitionId;
        List<News> existingNews = newsDAO.findAll();
        if (existingNews != null) {
            for (News existing : existingNews) {
                if (title.equals(existing.getTitle())
                        && competitionId.equals(existing.getCompetitionId())) {
                    return true;
                }
            }
        }

        // 2. 构建获奖公告内容
        StringBuilder content = new StringBuilder();
        content.append("本次竞赛获奖名单如下：\n\n");
        for (Award award : awards) {
            content.append("作品ID：").append(award.getWorkId())
                   .append("，获奖等级：").append(award.getAwardLevel())
                   .append("，最终得分：").append(award.getFinalScore())
                   .append("分\n");
        }
        content.append("\n恭喜以上获奖队伍！");

        // 3. 创建新闻公告（使用第一个获奖记录的issuerId作为发布者）
        News news = new News();
        news.setTitle(title);
        news.setContent(content.toString());
        news.setCompetitionId(competitionId);
        news.setAuthorId(awards.get(0).getIssuerId());
        news.setStatus(1); // 已发布

        return newsDAO.insert(news) > 0;
    }
}
