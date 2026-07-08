package com.poster.service.impl;

import com.poster.dao.AwardDAO;
import com.poster.dao.CertificateDAO;
import com.poster.dao.impl.AwardDAOImpl;
import com.poster.dao.impl.CertificateDAOImpl;
import com.poster.model.Award;
import com.poster.model.Certificate;
import com.poster.service.CertificateService;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;

/**
 * 电子奖状服务实现类
 * @author 队员C
 * @date 2026-07-08
 */
public class CertificateServiceImpl implements CertificateService {

    private CertificateDAO certificateDAO = new CertificateDAOImpl();
    private AwardDAO awardDAO = new AwardDAOImpl();

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
            return true; // 已存在奖状，不重复生成
        }

        // 3. 生成唯一奖状编号: CERT-YYYYMMDD-XXXX
        String dateStr = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String uniqueId = UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        String certificateNo = "CERT-" + dateStr + "-" + uniqueId;

        // 4. 奖状查看路径
        String filePath = "/certificate?action=view&awardId=" + awardId;

        // 5. 保存奖状记录
        Certificate certificate = new Certificate();
        certificate.setAwardId(awardId);
        certificate.setCertificateNo(certificateNo);
        certificate.setFilePath(filePath);

        return certificateDAO.insert(certificate) > 0;
    }

    @Override
    public Certificate getCertificateById(Integer certificateId) {
        if (certificateId == null) {
            return null;
        }
        return certificateDAO.findById(certificateId);
    }

    @Override
    public Certificate getCertificateByAwardId(Integer awardId) {
        if (awardId == null) {
            return null;
        }
        return certificateDAO.findByAwardId(awardId);
    }

    @Override
    public List<Certificate> getCertificatesByTeamId(Integer teamId) {
        if (teamId == null) {
            return null;
        }
        return certificateDAO.findByTeamId(teamId);
    }

    @Override
    public List<Certificate> getAllCertificates() {
        return certificateDAO.findAll();
    }
}
