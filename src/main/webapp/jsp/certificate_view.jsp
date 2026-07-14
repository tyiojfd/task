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

    String level = award.getAwardLevel();
    String levelColor = "#C41E3A";
    if ("二等奖".equals(level)) levelColor = "#B8860B";
    else if ("三等奖".equals(level)) levelColor = "#2E4057";
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
        /* ====== Google Fonts — 楷书 + 宋体 ====== */
        @import url('https://fonts.googleapis.com/css2?family=Noto+Serif+SC:wght@400;700;900&family=Ma+Shan+Zheng&family=ZCOOL+XiaoWei&display=swap');

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
            padding: 2rem 1rem;
            /* 纸色渐变背景 */
            background:
                radial-gradient(ellipse at 50% 0%, rgba(212,168,67,0.08) 0%, transparent 70%),
                linear-gradient(180deg, #f7f2e9 0%, #fdf8f0 30%, #faf3e5 60%, #f5ead8 100%);
            font-family: 'Noto Serif SC', 'STSong', 'SimSun', 'KaiTi', '楷体', serif;
        }
        /* 纸纹叠加 */
        body::before {
            content: '';
            position: fixed; inset: 0;
            background:
                repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(139,90,43,0.015) 2px, rgba(139,90,43,0.015) 4px),
                repeating-linear-gradient(90deg, transparent, transparent 3px, rgba(139,90,43,0.01) 3px, rgba(139,90,43,0.01) 6px);
            pointer-events: none; z-index: 0;
        }

        /* ====== 证书容器 ====== */
        .cert-wrapper { position: relative; z-index: 1; width: 820px; max-width: 100%; }

        /* 外框 — 红色粗框 + 金色内线 */
        .certificate {
            position: relative;
            background:
                linear-gradient(180deg, #fffef9 0%, #fffef5 20%, #fffdf2 50%, #fffdf5 80%, #fffef8 100%);
            border: 6px solid #8B1A1A;
            outline: 2px solid #D4A843;
            outline-offset: -14px;
            padding: 3.5rem 3rem 2.5rem;
            box-shadow:
                0 0 0 4px #8B1A1A,
                0 0 0 8px #D4A843,
                0 0 0 10px #8B1A1A,
                0 8px 40px rgba(80,20,20,0.25);
        }
        /* 内层细线装饰 */
        .certificate::before {
            content: '';
            position: absolute;
            top: 20px; left: 20px; right: 20px; bottom: 20px;
            border: 1px solid rgba(212,168,67,0.35);
            pointer-events: none;
        }

        /* ====== 顶部绶带标题 ====== */
        .cert-banner {
            text-align: center;
            margin-bottom: 2.2rem;
            position: relative;
            padding: 1.2rem 0 0.8rem;
            background: linear-gradient(180deg,
                rgba(196,30,58,0.06) 0%,
                rgba(196,30,58,0.02) 100%);
            border-bottom: 2px solid rgba(212,168,67,0.4);
        }
        .cert-banner .title-cn {
            font-family: 'ZCOOL XiaoWei', 'STKaiti', 'KaiTi', '楷体', serif;
            font-size: 3.2rem;
            font-weight: 900;
            color: #8B0000;
            letter-spacing: 14px;
            text-shadow: 1px 1px 2px rgba(139,0,0,0.15);
            margin-bottom: 0.3rem;
        }
        .cert-banner .title-en {
            font-family: 'Georgia', 'Times New Roman', serif;
            font-size: 1rem;
            color: #B8860B;
            letter-spacing: 6px;
            text-transform: uppercase;
        }

        /* ====== 顶部装饰星 ====== */
        .cert-stars {
            display: flex; justify-content: center; gap: 1.5rem;
            margin-bottom: 1.8rem;
        }
        .cert-stars i {
            font-size: 1.3rem;
            color: #D4A843;
            filter: drop-shadow(0 1px 1px rgba(180,140,50,0.4));
        }

        /* ====== 正文区 ====== */
        .cert-body {
            text-align: center;
            line-height: 2.7;
            padding: 0.5rem 2rem;
        }
        .cert-body .line { display: block; }
        .cert-body .line-intro {
            font-size: 1.05rem;
            color: #5D4037;
            letter-spacing: 1px;
        }
        .cert-body .line-competition {
            font-size: 1.15rem;
            color: #8B0000;
            font-weight: 700;
            letter-spacing: 1px;
        }
        .cert-body .line-team {
            font-size: 1.25rem;
            font-weight: 700;
            color: #3E2723;
            letter-spacing: 2px;
            margin: 0.3rem 0;
            padding: 0.25rem 1rem;
            display: inline-block;
            border-bottom: 1px dashed rgba(212,168,67,0.5);
        }
        .cert-body .line-work {
            font-size: 1.1rem;
            color: #4E342E;
            font-style: italic;
        }
        .cert-body .line-work strong {
            color: #6D4C41;
            font-style: normal;
        }
        .cert-body .line-gap { height: 0.6rem; }

        /* 获奖等级 — 金色大字 */
        .cert-body .line-level {
            font-family: 'ZCOOL XiaoWei', 'STKaiti', 'KaiTi', '楷体', serif;
            font-size: 3.5rem;
            font-weight: 900;
            color: <%= levelColor %>;
            letter-spacing: 10px;
            margin: 0.8rem 0;
            text-shadow:
                0 2px 4px rgba(0,0,0,0.08),
                0 0 20px rgba(212,168,67,0.25);
            position: relative;
            display: inline-block;
            padding: 0 1.5rem;
        }
        .cert-body .line-level::before,
        .cert-body .line-level::after {
            content: '✦';
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            font-size: 1rem;
            color: #D4A843;
        }
        .cert-body .line-level::before { left: -0.2rem; }
        .cert-body .line-level::after { right: -0.2rem; }

        .cert-body .line-score {
            font-size: 1rem;
            color: #5D4037;
            letter-spacing: 1px;
        }
        .cert-body .line-score strong {
            font-size: 1.3rem;
            color: #C41E3A;
        }

        /* ====== 证书编号 ====== */
        .cert-body .cert-no {
            display: inline-block;
            margin-top: 1.2rem;
            padding: 0.25rem 1.2rem;
            font-size: 0.8rem;
            color: #999;
            letter-spacing: 1px;
            border: 1px solid rgba(180,180,180,0.4);
            border-radius: 2px;
            background: rgba(255,255,255,0.5);
        }

        /* ====== 底部 ====== */
        .cert-footer {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            margin-top: 3rem;
            padding: 0 1rem;
        }
        .cert-footer .issuer {
            font-size: 1rem;
            color: #5D4037;
            letter-spacing: 2px;
            font-weight: 700;
        }
        .cert-footer .date {
            font-size: 0.95rem;
            color: #6D4C41;
            letter-spacing: 1px;
        }

        /* ====== 公章 ====== */
        .cert-stamp {
            position: absolute;
            bottom: 60px; right: 70px;
            width: 115px; height: 115px;
            border: 4px solid #C41E3A;
            border-radius: 50%;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            color: #C41E3A;
            font-weight: 900;
            font-family: 'Ma Shan Zheng', 'STKaiti', 'KaiTi', '楷体', cursive;
            font-size: 1.1rem;
            letter-spacing: 3px;
            line-height: 1.4;
            transform: rotate(-18deg);
            opacity: 0.78;
            text-align: center;
            /* 印章纹理 */
            box-shadow:
                inset 0 0 8px rgba(196,30,58,0.2),
                0 0 4px rgba(196,30,58,0.15);
            user-select: none;
            pointer-events: none;
        }
        .cert-stamp .stamp-star {
            font-size: 1.4rem;
            line-height: 1;
        }
        .cert-stamp .stamp-text {
            font-size: 0.72rem;
            letter-spacing: 2px;
        }

        /* ====== 四角装饰 ====== */
        .cert-corner {
            position: absolute;
            font-size: 2.2rem;
            opacity: 0.18;
            color: #D4A843;
        }
        .corner-tl { top: 28px; left: 38px; }
        .corner-tr { top: 28px; right: 38px; }
        .corner-bl { bottom: 28px; left: 38px; }
        .corner-br { bottom: 28px; right: 38px; }
        .corner-tl i, .corner-tr i, .corner-bl i, .corner-br i {
            filter: drop-shadow(0 0 3px rgba(212,168,67,0.3));
        }

        /* ====== 打印按钮 ====== */
        .no-print { }
        .btn-print {
            position: fixed; top: 20px; right: 20px; z-index: 999;
            padding: 0.5rem 1.2rem;
            border-radius: 8px;
            background: #8B0000;
            border: none;
            color: #fff;
            font-weight: 600;
            letter-spacing: 1px;
            box-shadow: 0 2px 12px rgba(139,0,0,0.3);
            transition: all 0.2s;
        }
        .btn-print:hover {
            background: #A00000;
            transform: translateY(-1px);
            box-shadow: 0 4px 18px rgba(139,0,0,0.4);
        }
        .btn-download {
            position: fixed; top: 20px; right: 150px; z-index: 999;
            padding: 0.5rem 1.2rem;
            border-radius: 8px;
            background: #fff;
            border: 1px solid #D4A843;
            color: #8B0000;
            font-weight: 600;
            letter-spacing: 1px;
            text-decoration: none;
            transition: all 0.2s;
        }
        .btn-download:hover {
            background: #FFF8E1;
            color: #8B0000;
        }

        /* ====== 打印适配 ====== */
        @media print {
            @page { size: A4 landscape; margin: 12mm; }
            body {
                background: white !important;
                padding: 0;
            }
            body::before { display: none !important; }
            .no-print { display: none !important; }
            .certificate {
                box-shadow: none;
                border: 6px solid #8B1A1A;
                outline: 2px solid #D4A843;
                outline-offset: -14px;
                width: 100%;
                max-width: 100%;
                padding: 2.5rem 2rem 2rem;
                page-break-inside: avoid;
            }
            .cert-stamp {
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }
        }

        @media (max-width: 640px) {
            .certificate { padding: 2rem 1rem 1.5rem; }
            .cert-banner .title-cn { font-size: 2rem; letter-spacing: 6px; }
            .cert-body .line-level { font-size: 2.2rem; letter-spacing: 4px; }
            .cert-stamp { width: 80px; height: 80px; font-size: 0.7rem; bottom: 30px; right: 20px; }
            .cert-body { padding: 0; }
        }
    </style>
</head>
<body>

<!-- 操作按钮 -->
<button class="btn-print no-print" onclick="window.print()">
    <i class="fas fa-print"></i> 打印奖状
</button>
<a class="btn-download no-print"
   href="<%= request.getContextPath() %>/certificate?action=download&awardId=<%= award.getAwardId() %>">
    <i class="fas fa-download"></i> 下载奖状
</a>

<!-- ====== 证书本体 ====== -->
<div class="cert-wrapper">
    <div class="certificate">

        <!-- 四角装饰 -->
        <div class="cert-corner corner-tl"><i class="fas fa-fan"></i></div>
        <div class="cert-corner corner-tr"><i class="fas fa-fan"></i></div>
        <div class="cert-corner corner-bl"><i class="fas fa-fan"></i></div>
        <div class="cert-corner corner-br"><i class="fas fa-fan"></i></div>

        <!-- 顶部绶带 -->
        <div class="cert-banner">
            <div class="title-cn">获 奖 证 书</div>
            <div class="title-en">C E R T I F I C A T E &nbsp; O F &nbsp; A W A R D</div>
        </div>

        <!-- 装饰星列 -->
        <div class="cert-stars">
            <i class="fas fa-star"></i>
            <i class="fas fa-certificate"></i>
            <i class="fas fa-star"></i>
            <i class="fas fa-certificate"></i>
            <i class="fas fa-star"></i>
        </div>

        <!-- 正文 -->
        <div class="cert-body">
            <span class="line line-intro">兹证明</span>

            <span class="line line-team">
                <%= HtmlEscaper.escape(team != null ? team.getTeamName() : "优秀团队") %>
            </span>
            <span class="line line-intro">
                <% if (leader != null) { %>
                （队长：<%= HtmlEscaper.escape(leader.getRealName() != null ? leader.getRealName() : leader.getUsername()) %>
                <% if (members != null) { %>，队员 <%= members.size() %> 人<% } %>）
                <% } %>
            </span>

            <span class="line line-intro">在</span>

            <span class="line line-competition">
                <%= HtmlEscaper.escape(competition != null ? competition.getName() : "大学生海报设计竞赛") %>
            </span>

            <span class="line line-intro">中，提交作品</span>

            <span class="line line-work">
                《<strong><%= HtmlEscaper.escape(work != null ? work.getTitle() : "优秀作品") %></strong>》
            </span>

            <span class="line line-intro">经评审委员会评定，荣获</span>

            <span class="line line-level"><%= HtmlEscaper.escape(level) %></span>

            <span class="line line-score">
                最终得分 <strong><%= String.format("%.1f", award.getFinalScore()) %></strong> 分
            </span>

            <% if (certificate != null) { %>
            <span class="line">
                <span class="cert-no">证书编号 <%= HtmlEscaper.escape(certificate.getCertificateNo()) %></span>
            </span>
            <% } %>
        </div>

        <!-- 底部 -->
        <div class="cert-footer">
            <div class="issuer">大学生海报设计竞赛组委会</div>
            <div class="date"><%= award.getAwardTime() != null ? award.getAwardTime().format(dtf) : "" %></div>
        </div>

        <!-- 公章 -->
        <div class="cert-stamp">
            <span class="stamp-star">★</span>
            <span class="stamp-text">组委会<br>专用章</span>
        </div>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
