package com.poster.model;

import java.time.LocalDateTime;

/**
 * 电子奖状实体类
 * @author 团队共建
 * @date 2026-07-04
 */
public class Certificate {
    private Integer certificateId;
    private Integer awardId;
    private String certificateNo;
    private String filePath;
    private LocalDateTime generateTime;

    public Certificate() {}

    public Integer getCertificateId() {
        return certificateId;
    }

    public void setCertificateId(Integer certificateId) {
        this.certificateId = certificateId;
    }

    public Integer getAwardId() {
        return awardId;
    }

    public void setAwardId(Integer awardId) {
        this.awardId = awardId;
    }

    public String getCertificateNo() {
        return certificateNo;
    }

    public void setCertificateNo(String certificateNo) {
        this.certificateNo = certificateNo;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public LocalDateTime getGenerateTime() {
        return generateTime;
    }

    public void setGenerateTime(LocalDateTime generateTime) {
        this.generateTime = generateTime;
    }
}
