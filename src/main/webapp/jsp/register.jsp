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
        .app-auth-glass .strength-meter {
            display: flex;
            align-items: center;
            gap: 6px;
            margin-top: 8px;
        }
        .app-auth-glass .strength-bar {
            flex: 1;
            height: 4px;
            background: #E8ECF1;
            border-radius: 4px;
            overflow: hidden;
        }
        .app-auth-glass .strength-bar .fill {
            height: 100%;
            border-radius: 4px;
            transition: width 0.4s, background 0.4s;
        }
        .app-auth-glass .strength-text {
            font-size: 11px;
            font-weight: 600;
            min-width: 36px;
            text-align: right;
        }
        .app-auth-glass .strength-text.weak { color: #e74c3c; }
        .app-auth-glass .strength-text.medium { color: #f39c12; }
        .app-auth-glass .strength-text.strong { color: #27ae60; }
        .app-auth-glass .match-indicator {
            font-size: 12px;
            font-weight: 600;
            margin-top: 6px;
            display: none;
            align-items: center;
            gap: 4px;
        }
        .app-auth-glass .match-indicator.show { display: flex; }
        .app-auth-glass .match-indicator.match { color: #27ae60; }
        .app-auth-glass .match-indicator.mismatch { color: #e74c3c; }
        .app-auth-glass .field-row {
            display: flex;
            gap: 16px;
        }
        .app-auth-glass .field-row .mb-3 { flex: 1; }
        @media (max-width: 720px) {
            .app-auth-glass .field-row { flex-direction: column; gap: 0; }
        }
    </style>
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body class="app-page app-page-auth">
<div class="container">
    <div class="app-auth-glass">
        <div class="app-auth-brand">
            <h1>加入我们</h1>
            <p>创建你的账号，加入大学生海报设计竞赛平台。组队参赛、提交作品、赢取荣誉。</p>
        </div>
        <div class="app-auth-form">
            <h2>创建账号</h2>

            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <c:out value="${error}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/register" method="post" id="regForm">

                <div class="mb-3">
                    <label for="username" class="form-label">用户名</label>
                    <input type="text" class="form-control" name="username" id="username"
                           placeholder="3-20位字符" required minlength="3" maxlength="20" autocomplete="username">
                </div>

                <div class="field-row">
                    <div class="mb-3">
                        <label for="realName" class="form-label">真实姓名</label>
                        <input type="text" class="form-control" name="realName" id="realName"
                               placeholder="你的真实姓名" required autocomplete="name">
                    </div>
                    <div class="mb-3">
                        <label for="email" class="form-label">电子邮箱</label>
                        <input type="email" class="form-control" name="email" id="email"
                               placeholder="example@mail.com" required autocomplete="email">
                    </div>
                </div>

                <div class="mb-3">
                    <label for="password" class="form-label">设置密码</label>
                    <input type="password" class="form-control" name="password" id="password"
                           placeholder="不少于6位字符" required minlength="6" autocomplete="new-password">
                    <div class="strength-meter">
                        <div class="strength-bar"><div class="fill" id="strengthFill" style="width:0"></div></div>
                        <span class="strength-text" id="strengthLabel"></span>
                    </div>
                </div>

                <div class="mb-3">
                    <label for="confirmPassword" class="form-label">确认密码</label>
                    <input type="password" class="form-control" name="confirmPassword" id="confirmPassword"
                           placeholder="再次输入密码" required autocomplete="new-password">
                    <div class="match-indicator" id="matchHint"></div>
                </div>

                <button type="submit" class="btn btn-primary">
                    <i class="bi bi-person-plus-fill"></i> 注册加入竞赛
                </button>
            </form>

            <div class="app-auth-links">
                <span></span>
                <span>已有账号？<a href="${pageContext.request.contextPath}/login">立即登录</a></span>
            </div>
        </div>
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
