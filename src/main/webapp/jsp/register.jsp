<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>注册 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --p1: #6C5CE7;
            --p2: #A29BFE;
            --p3: #4834D4;
            --accent: #FD79A8;
            --accent2: #FDCB6E;
            --bg: #f0f2fd;
            --card-bg: #ffffff;
            --text: #2D3436;
            --text2: #636E72;
            --border: #E2E6F0;
            --input-bg: #F7F8FC;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', 'Segoe UI', system-ui, -apple-system, sans-serif;
            min-height: 100vh;
            background: var(--bg);
            display: flex;
            align-items: center;
            justify-content: center;
            overflow-x: hidden;
            position: relative;
        }

        /* ==================== 动态背景 ==================== */
        .bg-animated {
            position: fixed;
            inset: 0;
            pointer-events: none;
            z-index: 0;
            overflow: hidden;
        }
        .bg-orb {
            position: absolute;
            border-radius: 50%;
            filter: blur(80px);
            opacity: 0.5;
            animation: orbFloat 20s ease-in-out infinite;
        }
        .bg-orb:nth-child(1) {
            width: 500px; height: 500px;
            background: #A29BFE;
            top: -150px; right: -100px;
            animation-delay: 0s;
        }
        .bg-orb:nth-child(2) {
            width: 400px; height: 400px;
            background: #FD79A8;
            bottom: -120px; left: -80px;
            animation-delay: -7s;
        }
        .bg-orb:nth-child(3) {
            width: 300px; height: 300px;
            background: #FDCB6E;
            top: 40%; left: 55%;
            animation-delay: -14s;
            opacity: 0.35;
        }
        .bg-orb:nth-child(4) {
            width: 250px; height: 250px;
            background: #6C5CE7;
            top: 10%; left: 10%;
            animation-delay: -5s;
            opacity: 0.3;
        }
        @keyframes orbFloat {
            0%, 100% { transform: translate(0, 0) scale(1); }
            25% { transform: translate(30px, -40px) scale(1.1); }
            50% { transform: translate(-20px, 20px) scale(0.9); }
            75% { transform: translate(15px, 30px) scale(1.05); }
        }

        /* 网格纹理 */
        .bg-grid {
            position: fixed;
            inset: 0;
            pointer-events: none;
            z-index: 0;
            background-image:
                linear-gradient(rgba(108,92,231,0.03) 1px, transparent 1px),
                linear-gradient(90deg, rgba(108,92,231,0.03) 1px, transparent 1px);
            background-size: 60px 60px;
        }

        /* ==================== 主卡片 ==================== */
        .register-card {
            position: relative;
            z-index: 1;
            display: flex;
            width: 1000px;
            min-height: 640px;
            background: var(--card-bg);
            border-radius: 28px;
            box-shadow:
                0 24px 80px rgba(108,92,231,0.12),
                0 8px 24px rgba(0,0,0,0.04),
                0 0 0 1px rgba(108,92,231,0.06);
            overflow: hidden;
            margin: 20px;
        }

        /* ==================== 左侧视觉区 ==================== */
        .visual-panel {
            width: 420px;
            background: linear-gradient(165deg, #2D1B69 0%, #4834D4 40%, #6C5CE7 100%);
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 60px 44px;
            color: #fff;
            overflow: hidden;
            flex-shrink: 0;
        }

        /* 装饰几何图形 */
        .visual-panel .geo-shapes {
            position: absolute;
            inset: 0;
            pointer-events: none;
        }
        .visual-panel .geo-shapes div {
            position: absolute;
            border-radius: 24px;
            opacity: 0.06;
            background: #fff;
        }
        .geo-s1 { width: 180px; height: 180px; top: -40px; right: -40px; transform: rotate(25deg); }
        .geo-s2 { width: 140px; height: 140px; bottom: 60px; left: -30px; transform: rotate(-15deg); border-radius: 50% !important; }
        .geo-s3 { width: 100px; height: 100px; top: 45%; right: 20px; border-radius: 12px !important; transform: rotate(45deg); }
        .geo-s4 { width: 60px; height: 60px; bottom: 120px; right: 50px; border-radius: 50% !important; opacity: 0.1 !important; }

        /* 内容区 */
        .visual-content { position: relative; z-index: 2; }

        .logo-mark {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 52px; height: 52px;
            background: rgba(255,255,255,0.18);
            backdrop-filter: blur(10px);
            border-radius: 16px;
            font-size: 26px;
            margin-bottom: 28px;
            border: 1px solid rgba(255,255,255,0.1);
        }

        .visual-content h1 {
            font-size: 30px;
            font-weight: 800;
            letter-spacing: -0.5px;
            line-height: 1.3;
            margin-bottom: 8px;
        }
        .visual-content h1 span {
            background: linear-gradient(135deg, #FDCB6E, #FD79A8);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .visual-content .tagline {
            font-size: 13px;
            opacity: 0.6;
            letter-spacing: 3px;
            text-transform: uppercase;
            margin-bottom: 48px;
        }

        .feature-list {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 28px;
        }
        .feature-list li {
            display: flex;
            gap: 16px;
            align-items: flex-start;
            font-size: 14px;
            line-height: 1.6;
            opacity: 0.85;
            transition: opacity 0.3s;
        }
        .feature-list li:hover { opacity: 1; }
        .feature-list .feat-icon {
            width: 40px; height: 40px;
            background: rgba(255,255,255,0.1);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            flex-shrink: 0;
            backdrop-filter: blur(4px);
            border: 1px solid rgba(255,255,255,0.08);
        }
        .feature-list strong {
            display: block;
            font-size: 15px;
            margin-bottom: 2px;
            opacity: 1;
        }

        /* ==================== 右侧表单区 ==================== */
        .form-panel {
            flex: 1;
            padding: 56px 52px;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
        }
        .form-panel .section-header {
            margin-bottom: 36px;
        }
        .form-panel .section-header h2 {
            font-size: 26px;
            font-weight: 700;
            color: #1a1a2e;
            margin: 0 0 6px;
            letter-spacing: -0.3px;
        }
        .form-panel .section-header p {
            font-size: 14px;
            color: #888;
            margin: 0;
        }
        .form-panel .section-header p a {
            color: var(--p1);
            font-weight: 600;
            text-decoration: none;
            transition: color 0.2s;
        }
        .form-panel .section-header p a:hover { color: var(--p3); }

        /* ==================== 表单字段 ==================== */
        .field-group {
            margin-bottom: 20px;
        }
        .field-label {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
            font-weight: 600;
            color: #444;
            margin-bottom: 6px;
        }
        .field-label .required-dot {
            width: 5px; height: 5px;
            background: var(--accent);
            border-radius: 50%;
        }
        .field-input-wrap {
            position: relative;
        }
        .field-input-wrap .field-icon {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 17px;
            color: #B0B8C1;
            transition: color 0.25s;
            pointer-events: none;
        }
        .field-input-wrap input {
            width: 100%;
            padding: 14px 16px 14px 46px;
            border: 2px solid var(--border);
            border-radius: 14px;
            font-size: 14px;
            color: #2D3436;
            background: var(--input-bg);
            outline: none;
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            font-family: inherit;
        }
        .field-input-wrap input:hover { border-color: #cdd3e0; background: #fff; }
        .field-input-wrap input:focus {
            border-color: var(--p1);
            background: #fff;
            box-shadow: 0 0 0 4px rgba(108,92,231,0.08);
        }
        .field-input-wrap input:focus + .field-icon,
        .field-input-wrap input:focus ~ .field-icon {
            color: var(--p1);
        }
        .field-input-wrap input::placeholder { color: #BCC3CD; }

        .field-row {
            display: flex;
            gap: 16px;
        }
        .field-row .field-group { flex: 1; }

        /* ==================== 密码强度 ==================== */
        .strength-meter {
            display: flex;
            align-items: center;
            gap: 6px;
            margin-top: 10px;
        }
        .strength-bar {
            flex: 1;
            height: 4px;
            background: #E8ECF1;
            border-radius: 4px;
            overflow: hidden;
        }
        .strength-bar .fill {
            height: 100%;
            border-radius: 4px;
            transition: width 0.4s, background 0.4s;
        }
        .strength-text {
            font-size: 11px;
            font-weight: 600;
            min-width: 36px;
            text-align: right;
        }
        .strength-text.weak { color: #e74c3c; }
        .strength-text.medium { color: #f39c12; }
        .strength-text.strong { color: #27ae60; }

        /* ==================== 确认密码状态 ==================== */
        .match-indicator {
            font-size: 12px;
            font-weight: 600;
            margin-top: 6px;
            display: none;
            align-items: center;
            gap: 4px;
        }
        .match-indicator.show { display: flex; }
        .match-indicator.match { color: #27ae60; }
        .match-indicator.mismatch { color: #e74c3c; }

        /* ==================== 提交按钮 ==================== */
        .btn-submit {
            width: 100%;
            padding: 15px;
            margin-top: 28px;
            font-size: 15px;
            font-weight: 700;
            color: #fff;
            background: linear-gradient(135deg, #6C5CE7 0%, #4834D4 100%);
            border: none;
            border-radius: 14px;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 6px 24px rgba(108,92,231,0.3);
            letter-spacing: 0.3px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 32px rgba(108,92,231,0.4);
            background: linear-gradient(135deg, #7C6FF7 0%, #5848E4 100%);
        }
        .btn-submit:active { transform: translateY(0) scale(0.98); }

        /* ==================== 错误提示 ==================== */
        .alert-box {
            padding: 14px 18px;
            border-radius: 12px;
            font-size: 13px;
            font-weight: 500;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
            animation: alertIn 0.35s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .alert-error {
            background: #FFF0F0;
            color: #c0392b;
            border: 1px solid #FDD;
        }
        @keyframes alertIn {
            from { opacity: 0; transform: translateY(-10px) scale(0.96); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }

        /* ==================== 响应式 ==================== */
        @media (max-width: 850px) {
            .register-card {
                flex-direction: column;
                width: 100%;
                max-width: 420px;
                min-height: auto;
                border-radius: 24px;
                margin: 12px;
            }
            .visual-panel {
                width: 100%;
                padding: 36px 28px;
            }
            .visual-content h1 { font-size: 24px; }
            .visual-content .tagline { margin-bottom: 24px; }
            .feature-list { gap: 18px; }
            .form-panel { padding: 36px 28px; }
            .field-row { flex-direction: column; gap: 0; }
        }

        /* ==================== 滚动条美化 ==================== */
        .form-panel::-webkit-scrollbar { width: 4px; }
        .form-panel::-webkit-scrollbar-track { background: transparent; }
        .form-panel::-webkit-scrollbar-thumb { background: #ddd; border-radius: 4px; }
    </style>
</head>
<body>
    <!-- 动态背景 -->
    <div class="bg-animated">
        <div class="bg-orb"></div>
        <div class="bg-orb"></div>
        <div class="bg-orb"></div>
        <div class="bg-orb"></div>
    </div>
    <div class="bg-grid"></div>

    <!-- 注册卡片 -->
    <div class="register-card">
        <!-- 左侧视觉区 -->
        <div class="visual-panel">
            <div class="geo-shapes">
                <div class="geo-s1"></div>
                <div class="geo-s2"></div>
                <div class="geo-s3"></div>
                <div class="geo-s4"></div>
            </div>
            <div class="visual-content">
                <div class="logo-mark"><i class="bi bi-palette2"></i></div>
                <h1>加入<span>创意</span>竞技场</h1>
                <p class="tagline">Poster Design Competition</p>
                <ul class="feature-list">
                    <li>
                        <div class="feat-icon"><i class="bi bi-lightbulb"></i></div>
                        <span><strong>释放灵感</strong>将你的创意呈现为精彩海报，让世界看到你的才华</span>
                    </li>
                    <li>
                        <div class="feat-icon"><i class="bi bi-rocket-takeoff"></i></div>
                        <span><strong>组队参赛</strong>邀请同学组建战队，协作设计更有竞争力的作品</span>
                    </li>
                    <li>
                        <div class="feat-icon"><i class="bi bi-award"></i></div>
                        <span><strong>赢取荣誉</strong>由专家评审团评定，获得证书与丰厚奖励</span>
                    </li>
                </ul>
            </div>
        </div>

        <!-- 右侧表单区 -->
        <div class="form-panel">
            <div class="section-header">
                <h2>创建你的账号</h2>
                <p>已有账号？<a href="${pageContext.request.contextPath}/login">立即登录</a></p>
            </div>

            <c:if test="${not empty error}">
                <div class="alert-box alert-error">
                    <i class="bi bi-exclamation-triangle-fill"></i> <c:out value="${error}"/>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/register" method="post" id="regForm">

                <div class="field-group">
                    <div class="field-label"><span class="required-dot"></span> 用户名</div>
                    <div class="field-input-wrap">
                        <i class="bi bi-person field-icon"></i>
                        <input type="text" name="username" id="username" placeholder="3-20位字符" required minlength="3" maxlength="20" autocomplete="username">
                    </div>
                </div>

                <div class="field-row">
                    <div class="field-group">
                        <div class="field-label"><span class="required-dot"></span> 真实姓名</div>
                        <div class="field-input-wrap">
                            <i class="bi bi-person-vcard field-icon"></i>
                            <input type="text" name="realName" id="realName" placeholder="你的真实姓名" required autocomplete="name">
                        </div>
                    </div>
                    <div class="field-group">
                        <div class="field-label"><span class="required-dot"></span> 电子邮箱</div>
                        <div class="field-input-wrap">
                            <i class="bi bi-envelope-at field-icon"></i>
                            <input type="email" name="email" id="email" placeholder="example@mail.com" required autocomplete="email">
                        </div>
                    </div>
                </div>

                <div class="field-group">
                    <div class="field-label"><span class="required-dot"></span> 设置密码</div>
                    <div class="field-input-wrap">
                        <i class="bi bi-shield-lock field-icon"></i>
                        <input type="password" name="password" id="password" placeholder="不少于6位字符" required minlength="6" autocomplete="new-password">
                    </div>
                    <div class="strength-meter">
                        <div class="strength-bar"><div class="fill" id="strengthFill" style="width:0"></div></div>
                        <span class="strength-text" id="strengthLabel"></span>
                    </div>
                </div>

                <div class="field-group">
                    <div class="field-label"><span class="required-dot"></span> 确认密码</div>
                    <div class="field-input-wrap">
                        <i class="bi bi-shield-check field-icon"></i>
                        <input type="password" name="confirmPassword" id="confirmPassword" placeholder="再次输入密码" required autocomplete="new-password">
                    </div>
                    <div class="match-indicator" id="matchHint"></div>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="bi bi-person-plus-fill"></i> 注册加入竞赛
                </button>
            </form>
        </div>
    </div>

    <script>
    (function() {
        var pw = document.getElementById('password');
        var cpw = document.getElementById('confirmPassword');
        var fill = document.getElementById('strengthFill');
        var label = document.getElementById('strengthLabel');
        var hint = document.getElementById('matchHint');

        function calcStrength(v) {
            if (!v) return { score: 0, pct: 0, level: '', cls: '' };
            var s = 0;
            if (v.length >= 6) s++;
            if (v.length >= 10) s++;
            if (/[a-z]/.test(v) && /[A-Z]/.test(v)) s++;
            if (/\d/.test(v)) s++;
            if (/[^A-Za-z0-9]/.test(v)) s++;
            var pct = Math.min(100, s * 20);
            if (s <= 2) return { score: s, pct: pct, level: '弱', cls: 'weak' };
            if (s <= 3) return { score: s, pct: pct, level: '中等', cls: 'medium' };
            return { score: s, pct: pct, level: '强', cls: 'strong' };
        }

        function checkMatch() {
            if (!cpw.value) { hint.className = 'match-indicator'; return; }
            hint.className = 'match-indicator show';
            if (cpw.value === pw.value) {
                hint.className = 'match-indicator show match';
                hint.innerHTML = '<i class="bi bi-check-circle-fill"></i> 密码一致';
                cpw.style.borderColor = '';
            } else {
                hint.className = 'match-indicator show mismatch';
                hint.innerHTML = '<i class="bi bi-x-circle-fill"></i> 两次密码不一致';
                cpw.style.borderColor = '#e74c3c';
            }
        }

        pw.addEventListener('input', function() {
            var r = calcStrength(this.value);
            fill.style.width = r.pct + '%';
            fill.style.background = r.score <= 2 ? '#e74c3c' : (r.score <= 3 ? '#f39c12' : '#27ae60');
            label.textContent = r.level;
            label.className = 'strength-text ' + r.cls;
            if (cpw.value) checkMatch();
        });

        cpw.addEventListener('input', checkMatch);
    })();
    </script>
</body>
</html>
