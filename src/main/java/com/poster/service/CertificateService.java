package com.poster.service;

import com.poster.model.Certificate;
import java.util.List;

/**
 * 电子奖状服务接口
 * @author 队员C
 * @date 2026-07-08
 */
public interface CertificateService {

    /**
     * 生成电子奖状
     */
    boolean generateCertificate(Integer awardId);

    /**
     * 根据ID查询奖状
     */
    Certificate getCertificateById(Integer certificateId);

    /**
     * 根据获奖ID查询奖状
     */
    Certificate getCertificateByAwardId(Integer awardId);

    /**
     * 根据队伍ID查询所有奖状
     */
    List<Certificate> getCertificatesByTeamId(Integer teamId);

    /**
     * 查询所有奖状
     */
    List<Certificate> getAllCertificates();
}
