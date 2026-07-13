<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.poster.util.HtmlEscaper" %>
<%
    User sessionUser = (User) session.getAttribute("user");

    Certificate certificate = (Certificate) request.getAttribute("certificate");
    Award award = (Award) request.getAttribute("award");
    Work work = (Work) request.getAttribute("work");
    Team team = (Team) request.getAttribute("team");
    Competition competition = (Competition) request.getAttribute("competition");
    User leader = (User) request.getAttribute("leader");

    @SuppressWarnings("unchecked")
    List<TeamMember> members = (List<TeamMember>) request.getAttribute("members");

    if (award == null) {
        response.sendRedirect(request.getContextPath() + "/index");
        return;
    }

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy年MM月dd日");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>电子奖状 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary: #6C5CE7; --primary-light: #A29BFE; --gold: #D4A843;
            --dark: #2D3436; --gray: #636E72;
        }
        body {
            background: #f0ebe3;
            min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
            font-family: 'STSong', 'SimSun', 'Noto Serif SC', 'KaiTi', '楷体', serif;
            padding: 2rem 1rem;
        }

        .certificate-container {
            width: 900px;
            max-width: 100%;
            background: #fffef7;
            border: 8px double #D4A843;
            padding: 3rem 4rem;
            position: relative;
            box-shadow: 0 4px 30px rgba(0,0,0,0.12);
        }
        .certificate-container::before {
            content: '';
            position: absolute;
            top: 12px; left: 12px; right: 12px; bottom: 12px;
            border: 2px solid rgba(212, 168, 67, 0.3);
            pointer-events: none;
        }

        .cert-header { text-align: center; margin-bottom: 2rem; }
        .cert-header .cert-title {
            font-size: 2.5rem; font-weight: 900; color: #8B0000;
            letter-spacing: 8px;
        }
        .cert-header .cert-subtitle {
            font-size: 1.1rem; color: var(--gray); margin-top: 0.5rem;
            letter-spacing: 4px;
        }

        .cert-body { text-align: center; margin: 2.5rem 0; line-height: 2.5; }
        .cert-body .award-level {
            font-size: 3rem; font-weight: 900; color: #D4A843;
            margin: 1.5rem 0;
            letter-spacing: 6px;
        }
        .cert-body .recipient { font-size: 1.5rem; color: var(--dark); }
        .cert-body .work-title { font-size: 1.3rem; color: var(--primary); font-weight: 600; }
        .cert-body .competition-name { font-size: 1.1rem; color: var(--gray); }
        .cert-body .cert-no { font-size: 0.85rem; color: #999; margin-top: 1rem; }

        .cert-footer { margin-top: 3rem; text-align: right; }
        .cert-footer .issuer { font-size: 1rem; color: var(--gray); }
        .cert-footer .date { font-size: 0.95rem; color: var(--gray); margin-top: 0.5rem; }

        .cert-stamp {
            position: absolute;
            bottom: 100px;
            right: 80px;
            width: 100px;
            height: 100px;
            border: 3px solid #C41E3A;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #C41E3A;
            font-weight: 900;
            font-size: 0.9rem;
            transform: rotate(-15deg);
            opacity: 0.7;
        }

        .cert-decor {
            position: absolute;
            font-size: 5rem;
            opacity: 0.05;
            color: var(--gold);
        }
        .decor-tl { top: 30px; left: 50px; }
        .decor-tr { top: 30px; right: 50px; }
        .decor-bl { bottom: 30px; left: 50px; }
        .decor-br { bottom: 30px; right: 50px; }

        .btn-print {
            position: fixed; top: 20px; right: 20px; z-index: 999;
        }

        @media print {
            body { background: white; padding: 0; }
            .btn-print, .no-print { display: none !important; }
            .certificate-container {
                box-shadow: none; border: 8px double #D4A843;
                width: 100%; max-width: 100%; padding: 2rem;
            }
        }
    </style>
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body>

<button class="btn btn-primary btn-print no-print" onclick="window.print()">
    <i class="fas fa-print"></i> 打印奖状
</button>
<a class="btn btn-success no-print" style="position:fixed;top:20px;right:140px;z-index:999;"
   href="<%= request.getContextPath() %>/certificate?action=download&awardId=<%= award.getAwardId() %>">
    <i class="fas fa-download"></i> 下载奖状
</a>

<div class="certificate-container">
    <i class="fas fa-trophy cert-decor decor-tl"></i>
    <i class="fas fa-star cert-decor decor-tr"></i>
    <i class="fas fa-medal cert-decor decor-bl"></i>
    <i class="fas fa-crown cert-decor decor-br"></i>

    <div class="cert-header">
        <div class="cert-title">获 奖 证 书</div>
        <div class="cert-subtitle">CERTIFICATE OF AWARD</div>
    </div>

    <div class="cert-body">
        <div class="competition-name">
            在「<%= HtmlEscaper.escape(competition != null ? competition.getName() : "大学生海报设计竞赛") %>」中
        </div>

        <div class="recipient">
            <strong><%= HtmlEscaper.escape(team != null ? team.getTeamName() : "优秀团队") %></strong>
            <% if (leader != null) { %>
            （队长：<%= HtmlEscaper.escape(leader.getRealName() != null ? leader.getRealName() : leader.getUsername()) %>）
            <% } %>
        </div>

        <div>
            提交的作品
            <span class="work-title">《<%= HtmlEscaper.escape(work != null ? work.getTitle() : "优秀作品") %>》</span>
        </div>

        <div>荣获</div>

        <div class="award-level">
            <%= HtmlEscaper.escape(award.getAwardLevel()) %>
        </div>

        <div>最终得分：<strong><%= String.format("%.1f", award.getFinalScore()) %></strong> 分</div>

        <% if (certificate != null) { %>
            <div class="cert-no">证书编号：<%= HtmlEscaper.escape(certificate.getCertificateNo()) %></div>
        <% } %>
    </div>

    <div class="cert-footer">
        <div class="issuer">大学生海报设计竞赛组委会</div>
        <div class="date">
            <%= award.getAwardTime() != null ? award.getAwardTime().format(dtf) : "" %>
        </div>
    </div>

    <div class="cert-stamp">证书专用章</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
