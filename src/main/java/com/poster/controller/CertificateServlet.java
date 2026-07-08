package com.poster.controller;

import com.poster.dao.AwardDAO;
import com.poster.dao.CompetitionDAO;
import com.poster.dao.TeamDAO;
import com.poster.dao.UserDAO;
import com.poster.dao.WorkDAO;
import com.poster.dao.impl.AwardDAOImpl;
import com.poster.dao.impl.CompetitionDAOImpl;
import com.poster.dao.impl.TeamDAOImpl;
import com.poster.dao.impl.UserDAOImpl;
import com.poster.dao.impl.WorkDAOImpl;
import com.poster.model.*;
import com.poster.service.CertificateService;
import com.poster.service.impl.CertificateServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

/**
 * 奖状Servlet
 * @author 队员C
 * @date 2026-07-08
 */
@WebServlet("/certificate")
public class CertificateServlet extends HttpServlet {

    private CertificateService certificateService = new CertificateServiceImpl();
    private AwardDAO awardDAO = new AwardDAOImpl();
    private WorkDAO workDAO = new WorkDAOImpl();
    private TeamDAO teamDAO = new TeamDAOImpl();
    private CompetitionDAO competitionDAO = new CompetitionDAOImpl();
    private UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("view".equals(action)) {
            // 查看奖状
            showCertificate(request, response);
        } else if ("myCertificates".equals(action)) {
            // 我的奖状
            showMyCertificates(request, response);
        } else if ("list".equals(action)) {
            // 所有奖状列表（管理员）
            showCertificateList(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/index");
        }
    }

    /**
     * 查看奖状详情
     */
    private void showCertificate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String awardIdStr = request.getParameter("awardId");
        String certIdStr = request.getParameter("certId");

        Certificate certificate = null;
        Award award = null;

        try {
            if (certIdStr != null && !certIdStr.isEmpty()) {
                Integer certId = Integer.parseInt(certIdStr);
                certificate = certificateService.getCertificateById(certId);
                if (certificate != null) {
                    award = awardDAO.findById(certificate.getAwardId());
                }
            } else if (awardIdStr != null && !awardIdStr.isEmpty()) {
                Integer awardId = Integer.parseInt(awardIdStr);
                certificate = certificateService.getCertificateByAwardId(awardId);
                award = awardDAO.findById(awardId);
            }

            if (award == null) {
                response.sendRedirect(request.getContextPath() + "/index");
                return;
            }

            // 加载关联数据
            Work work = workDAO.findById(award.getWorkId());
            Team team = work != null ? teamDAO.findById(work.getTeamId()) : null;
            Competition competition = competitionDAO.findById(award.getCompetitionId());

            // 获取队伍成员
            request.setAttribute("certificate", certificate);
            request.setAttribute("award", award);
            request.setAttribute("work", work);
            request.setAttribute("team", team);
            request.setAttribute("competition", competition);

            // 获取队长信息（用于显示获奖者）
            if (team != null) {
                List<TeamMember> members = new com.poster.dao.impl.TeamMemberDAOImpl().findByTeamId(team.getTeamId());
                for (TeamMember tm : members) {
                    if (tm.getRole() != null && tm.getRole() == 1) {
                        User leader = userDAO.findById(tm.getUserId());
                        request.setAttribute("leader", leader);
                        break;
                    }
                }
                request.setAttribute("members", members);
            }

            request.getRequestDispatcher("/jsp/certificate_view.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/index");
        }
    }

    /**
     * 我的奖状（队员查看自己队伍的奖状）
     */
    private void showMyCertificates(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        // 查询用户所在的所有队伍（作为队长或队员）
        com.poster.dao.TeamMemberDAO tmDAO = new com.poster.dao.impl.TeamMemberDAOImpl();
        List<TeamMember> myMemberships = tmDAO.findByUserId(user.getUserId());

        // 收集这些队伍的所有奖状
        java.util.Set<Integer> seenCertIds = new java.util.HashSet<>();
        java.util.List<Certificate> allCertificates = new java.util.ArrayList<>();
        java.util.Map<Integer, Award> awardMap = new java.util.HashMap<>();
        java.util.Map<Integer, Work> workMap = new java.util.HashMap<>();
        java.util.Map<Integer, String> teamNameMap = new java.util.HashMap<>();
        java.util.Map<Integer, String> competitionNameMap = new java.util.HashMap<>();

        for (TeamMember tm : myMemberships) {
            List<Certificate> certs = certificateService.getCertificatesByTeamId(tm.getTeamId());
            if (certs != null) {
                for (Certificate cert : certs) {
                    if (!seenCertIds.contains(cert.getCertificateId())) {
                        seenCertIds.add(cert.getCertificateId());
                        allCertificates.add(cert);

                        Award award = awardDAO.findById(cert.getAwardId());
                        if (award != null) {
                            awardMap.put(cert.getCertificateId(), award);
                            Work work = workDAO.findById(award.getWorkId());
                            if (work != null) {
                                workMap.put(cert.getCertificateId(), work);
                            }
                            Competition comp = competitionDAO.findById(award.getCompetitionId());
                            if (comp != null) {
                                competitionNameMap.put(cert.getCertificateId(), comp.getName());
                            }
                        }

                        Team team = teamDAO.findById(tm.getTeamId());
                        if (team != null) {
                            teamNameMap.put(cert.getCertificateId(), team.getTeamName());
                        }
                    }
                }
            }
        }

        request.setAttribute("certificates", allCertificates);
        request.setAttribute("awardMap", awardMap);
        request.setAttribute("workMap", workMap);
        request.setAttribute("teamNameMap", teamNameMap);
        request.setAttribute("competitionNameMap", competitionNameMap);

        request.getRequestDispatcher("/jsp/certificate_list.jsp").forward(request, response);
    }

    /**
     * 所有奖状列表（管理员查看）
     */
    private void showCertificateList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Certificate> certificates = certificateService.getAllCertificates();

        java.util.Map<Integer, Award> awardMap = new java.util.HashMap<>();
        java.util.Map<Integer, Work> workMap = new java.util.HashMap<>();

        for (Certificate cert : certificates) {
            Award award = awardDAO.findById(cert.getAwardId());
            if (award != null) {
                awardMap.put(cert.getCertificateId(), award);
                Work work = workDAO.findById(award.getWorkId());
                if (work != null) {
                    workMap.put(cert.getCertificateId(), work);
                }
            }
        }

        request.setAttribute("certificates", certificates);
        request.setAttribute("awardMap", awardMap);
        request.setAttribute("workMap", workMap);

        request.getRequestDispatcher("/jsp/certificate_list.jsp").forward(request, response);
    }
}
