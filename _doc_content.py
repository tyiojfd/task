# -*- coding: utf-8 -*-
# Content for the implementation report, extracted from the real project source.

COVER_TEAM = None  # 团队名保留模板占位，不改动
COVER_MEMBERS = ["程建锋、洪振博、杨祥博", "田继青、葛至洲"]

OVERVIEW = (
    "本系统为“大学生海报设计竞赛系统”，采用 JSP + Servlet + MySQL 的 MVC 三层架构："
    "前端使用 Bootstrap 5 + Font Awesome，后端使用原生 JDBC（PreparedStatement 防 SQL 注入）。"
    "系统包含管理员、评委、队长、队员四类角色，覆盖竞赛发布、报名组队、作品提交、评委评分、"
    "获奖公布的完整业务流程。下文按模块与功能说明关键实现，每个功能均给出模型代码、"
    "控制器代码与视图代码的精选片段。"
)

MODULES = [
    # ===================== 模块1 用户认证 =====================
    {
        "title": "1.1 用户认证模块",
        "intro": "负责用户注册、登录、退出及会话与权限控制。密码采用 MD5+盐值加密存储，"
                 "AuthFilter 统一拦截未登录请求并基于角色做最小权限校验。",
        "functions": [
            {
                "title": "1.1.1 用户注册",
                "desc": "用户提供用户名、密码、确认密码、真实姓名与邮箱完成注册；系统校验输入合法性、"
                        "查重用户名与邮箱，使用 MD5+盐值加密密码后写入 user 表，并自动分配「队员」默认角色。"
                        "注册成功后跳转至登录页。",
                "model": (
"// UserDAOImpl.insert —— 写入 user 表（PreparedStatement 防注入）\n"
"public int insert(User user) {\n"
"    String sql = \"INSERT INTO user (username, password, real_name, email, phone, avatar, status) VALUES (?, ?, ?, ?, ?, ?, ?)\";\n"
"    try (Connection conn = DBUtil.getConnection();\n"
"         PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {\n"
"        ps.setString(1, user.getUsername());\n"
"        ps.setString(2, user.getPassword());\n"
"        ps.setString(3, user.getRealName());\n"
"        ps.setString(4, user.getEmail());\n"
"        ps.setString(5, user.getPhone());\n"
"        ps.setString(6, user.getAvatar());\n"
"        ps.setInt(7, user.getStatus() != null ? user.getStatus() : 1);\n"
"        int rows = ps.executeUpdate();\n"
"        if (rows > 0) {\n"
"            ResultSet rs = ps.getGeneratedKeys();\n"
"            if (rs.next()) return rs.getInt(1);\n"
"        }\n"
"    } catch (SQLException e) { e.printStackTrace(); }\n"
"    return 0;\n"
"}\n\n"
"// PasswordUtil.encrypt —— MD5 + 固定盐值加密\n"
"public static String encrypt(String password) {\n"
"    String saltedPassword = password + SALT; // SALT = \"poster_competition_2026\"\n"
"    MessageDigest md = MessageDigest.getInstance(\"MD5\");\n"
"    byte[] bytes = md.digest(saltedPassword.getBytes());\n"
"    StringBuilder sb = new StringBuilder();\n"
"    for (byte b : bytes) sb.append(String.format(\"%02x\", b));\n"
"    return sb.toString();\n"
"}\n\n"
"// UserServiceImpl.register —— 查重 + 加密 + 分配默认角色（任一步失败回滚）\n"
"public boolean register(String username, String password, String realName, String email, String avatar) {\n"
"    if (userDAO.findByUsername(username) != null) return false; // 用户名已存在\n"
"    if (userDAO.findByEmail(email) != null) return false;       // 邮箱已存在\n"
"    String encryptedPassword = PasswordUtil.encrypt(password);\n"
"    User user = new User();\n"
"    user.setUsername(username); user.setPassword(encryptedPassword);\n"
"    user.setRealName(realName); user.setEmail(email); user.setStatus(1);\n"
"    int userId = userDAO.insert(user);\n"
"    if (userId > 0) {\n"
"        Role defaultRole = roleDAO.findByName(\"队员\");\n"
"        if (defaultRole == null || !userRoleDAO.assignRole(userId, defaultRole.getRoleId())) {\n"
"            userDAO.deleteById(userId); // 角色分配失败则删除半成品账号\n"
"            return false;\n"
"        }\n"
"        return true;\n"
"    }\n"
"    return false;\n"
"}"
                ),
                "test": (
"// 代表性单元测试（JUnit 5 + Mockito 思路）\n"
"@Test\n"
"void testRegisterSuccessAndFindByUsername() {\n"
"    when(userDAO.findByUsername(\"alice\")).thenReturn(null);\n"
"    when(userDAO.findByEmail(\"alice@test.com\")).thenReturn(null);\n"
"    when(userDAO.insert(any(User.class))).thenReturn(10);\n"
"    when(roleDAO.findByName(\"队员\")).thenReturn(new Role(1, \"队员\"));\n"
"    when(userRoleDAO.assignRole(eq(10), eq(1))).thenReturn(true);\n"
"    assertTrue(service.register(\"alice\", \"secret123\", \"爱丽丝\", \"alice@test.com\", null));\n"
"    ArgumentCaptor<User> cap = ArgumentCaptor.forClass(User.class);\n"
"    verify(userDAO).insert(cap.capture());\n"
"    assertEquals(PasswordUtil.encrypt(\"secret123\"), cap.getValue().getPassword()); // 密码已加密\n"
"}"
                ),
                "ctrl": (
"// RegisterServlet.doPost —— 参数校验后调用 Service 注册\n"
"protected void doPost(HttpServletRequest request, HttpServletResponse response) ... {\n"
"    String username = request.getParameter(\"username\");\n"
"    String password = request.getParameter(\"password\");\n"
"    String confirmPassword = request.getParameter(\"confirmPassword\");\n"
"    String realName = request.getParameter(\"realName\");\n"
"    String email = request.getParameter(\"email\");\n"
"    // 非空、密码长度>=6、两次密码一致、邮箱格式校验 ...\n"
"    if (!password.equals(confirmPassword)) { /* 转发回 register.jsp 报错 */ }\n"
"    try {\n"
"        boolean success = userService.register(username, password, realName, email, null);\n"
"        if (success) {\n"
"            request.setAttribute(\"success\", \"注册成功，请登录\");\n"
"            request.getRequestDispatcher(\"/jsp/login.jsp\").forward(request, response);\n"
"        } else {\n"
"            request.setAttribute(\"error\", \"用户名或邮箱已被注册\");\n"
"            request.getRequestDispatcher(\"/jsp/register.jsp\").forward(request, response);\n"
"        }\n"
"    } catch (Exception e) { /* 服务器错误 */ }\n"
"}"
                ),
                "view": (
"<!-- register.jsp 注册表单（含前后端校验提示） -->\n"
"<form action=\"${pageContext.request.contextPath}/register\" method=\"post\" id=\"regForm\">\n"
"  <div class=\"mb-3\">\n"
"    <label class=\"form-label\">用户名</label>\n"
"    <input type=\"text\" class=\"form-control\" name=\"username\" id=\"username\"\n"
"           placeholder=\"3-20位字符\" required minlength=\"3\" maxlength=\"20\" autocomplete=\"username\">\n"
"  </div>\n"
"  <div class=\"mb-3\">\n"
"    <label class=\"form-label\">设置密码</label>\n"
"    <input type=\"password\" class=\"form-control\" name=\"password\" id=\"password\"\n"
"           placeholder=\"不少于6位字符\" required minlength=\"6\" autocomplete=\"new-password\">\n"
"  </div>\n"
"  <div class=\"mb-3\">\n"
"    <label class=\"form-label\">确认密码</label>\n"
"    <input type=\"password\" class=\"form-control\" name=\"confirmPassword\" id=\"confirmPassword\" required>\n"
"  </div>\n"
"  <button type=\"submit\" class=\"btn btn-primary\">注册加入竞赛</button>\n"
"</form>"
                ),
                "sql": (
"INSERT INTO user (username, password, real_name, email, phone, avatar, status)\n"
"VALUES (?, ?, ?, ?, ?, ?, ?);"
                ),
                "effect": "注册页以左右分栏、动态渐变背景呈现；提交后若用户名/邮箱已存在则在同页提示，"
                          "否则写入已加密的账号并自动分配「队员」角色，跳转登录页。",
            },
            {
                "title": "1.1.2 用户登录",
                "desc": "用户输入用户名与密码，系统按登录入口角色（普通用户/评委/管理员）校验账号归属，"
                        "验证 MD5+盐值加密的密码与会话状态后，将用户对象与角色列表写入 Session 并重定向至首页；"
                        "未登录用户访问受保护资源时由 AuthFilter 拦截跳转至登录页。",
                "model": (
"// UserServiceImpl.login —— 按登录入口角色校验 + 密码校验\n"
"public User login(String username, String password, String expectedRole) {\n"
"    User user = userDAO.findByUsername(username);\n"
"    if (user == null) return null;                         // 用户不存在\n"
"    if (!PasswordUtil.verify(password, user.getPassword())) return null; // 密码错误\n"
"    if (user.getStatus() == null || user.getStatus() == 0) return null;   // 已禁用\n"
"    if (expectedRole != null && !expectedRole.trim().isEmpty()) {\n"
"        List<Role> roles = userRoleDAO.findRolesByUserId(user.getUserId());\n"
"        boolean isAdmin=false, isJudge=false, isParticipant=false, exact=false;\n"
"        for (Role role : roles) {\n"
"            if (\"管理员\".equals(role.getRoleName())) isAdmin = true;\n"
"            if (\"评委\".equals(role.getRoleName())) isJudge = true;\n"
"            if (\"队员\".equals(role.getRoleName()) || \"队长\".equals(role.getRoleName())) isParticipant = true;\n"
"            if (expectedRole.equals(role.getRoleName())) exact = true;\n"
"        }\n"
"        boolean matched = \"普通用户\".equals(expectedRole) ? (isParticipant && !isAdmin) : exact;\n"
"        if (!matched) return null; // 入口与角色不匹配\n"
"    }\n"
"    return user;\n"
"}\n\n"
"// UserDAOImpl.findByUsername\n"
"public User findByUsername(String username) {\n"
"    String sql = \"SELECT * FROM user WHERE username = ?\";\n"
"    // PreparedStatement 查询并映射为 User 对象\n"
"}"
                ),
                "test": (
"@Test\n"
"void testLoginSuccess() {\n"
"    User u = new User(); u.setUserId(1); u.setUsername(\"alice\");\n"
"    u.setPassword(PasswordUtil.encrypt(\"secret123\")); u.setStatus(1);\n"
"    when(userDAO.findByUsername(\"alice\")).thenReturn(u);\n"
"    when(userRoleDAO.findRolesByUserId(1)).thenReturn(List.of(new Role(2, \"队员\")));\n"
"    assertNotNull(service.login(\"alice\", \"secret123\"));            // 登录成功\n"
"    assertNull(service.login(\"alice\", \"wrongpass\"));              // 密码错误\n"
"    assertNull(service.login(\"alice\", \"secret123\", \"管理员\"));     // 角色不匹配\n"
"}"
                ),
                "ctrl": (
"// LoginServlet.doPost —— 写入 Session 并重定向首页\n"
"protected void doPost(HttpServletRequest request, HttpServletResponse response) ... {\n"
"    String username = request.getParameter(\"username\");\n"
"    String password = request.getParameter(\"password\");\n"
"    HttpSession entrySession = request.getSession(false);\n"
"    String loginRole = normalizeRole((String) entrySession.getAttribute(\"loginEntryRole\"));\n"
"    String expectedRole = loginRole == null ? \"普通用户\" : loginRole;\n"
"    User user = userService.login(username.trim(), password, expectedRole);\n"
"    if (user != null) {\n"
"        HttpSession session = request.getSession();\n"
"        session.setAttribute(\"user\", user);\n"
"        List<Role> roles = userService.getUserRoles(user.getUserId());\n"
"        session.setAttribute(\"roles\", roles);          // 角色列表写入 Session\n"
"        session.removeAttribute(\"loginEntryRole\");\n"
"        response.sendRedirect(request.getContextPath() + \"/index\");\n"
"    } else {\n"
"        request.setAttribute(\"error\", \"该账号不属于当前登录入口，或用户名/密码错误\");\n"
"        forwardByRole(request, response, loginRole);     // 回到对应登录页\n"
"    }\n"
"}"
                ),
                "view": (
"<!-- login.jsp 登录表单 -->\n"
"<form action=\"${pageContext.request.contextPath}/login\" method=\"post\">\n"
"  <div class=\"mb-3\">\n"
"    <label class=\"form-label\">用户名</label>\n"
"    <input type=\"text\" class=\"form-control\" id=\"username\" name=\"username\" placeholder=\"请输入用户名\" required>\n"
"  </div>\n"
"  <div class=\"mb-3\">\n"
"    <label class=\"form-label\">密码</label>\n"
"    <input type=\"password\" class=\"form-control\" id=\"password\" name=\"password\" placeholder=\"请输入密码\" required>\n"
"  </div>\n"
"  <button type=\"submit\" class=\"btn btn-primary\">登录</button>\n"
"</form>"
                ),
                "sql": (
"SELECT * FROM user WHERE username = ?;"
                ),
                "effect": "系统提供普通用户、评委、管理员三类登录入口；登录成功后根据用户角色加载首页"
                          "（队员看竞赛大厅、评委看评分工作台、管理员看统计面板），AuthFilter 守护所有受保护路径。",
            },
        ],
    },

    # ===================== 模块2 竞赛管理 =====================
    {
        "title": "1.2 竞赛管理模块",
        "intro": "管理员发布竞赛并维护竞赛子类（参赛方向），任何用户可浏览竞赛列表与详情。"
                "详情页根据登录状态与角色动态展示参赛入口与管理按钮。",
        "functions": [
            {
                "title": "1.2.1 竞赛发布",
                "desc": "管理员在竞赛发布页面填写年度、名称、主题、描述、提交截止时间、最大队伍人数、竞赛状态"
                        "及至少一个竞赛子类（参赛方向）后提交；系统校验必填项、设置默认值并将竞赛主表记录与"
                        "子类记录写入数据库。发布成功后自动跳转到竞赛列表页。",
                "model": (
"// CompetitionDAOImpl.insert —— 插入竞赛主表并返回自增ID\n"
"public int insert(Competition competition) {\n"
"    String sql = \"INSERT INTO competition (year, name, theme, description, submit_deadline,\"\n"
"            + \" max_team_size, status, creator_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)\";\n"
"    try (Connection conn = DBUtil.getConnection();\n"
"         PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {\n"
"        pstmt.setInt(1, competition.getYear());\n"
"        pstmt.setString(2, competition.getName());\n"
"        pstmt.setString(3, competition.getTheme());\n"
"        pstmt.setString(4, competition.getDescription());\n"
"        pstmt.setTimestamp(5, Timestamp.valueOf(competition.getSubmitDeadline()));\n"
"        pstmt.setInt(6, competition.getMaxTeamSize());\n"
"        pstmt.setInt(7, competition.getStatus());\n"
"        pstmt.setInt(8, competition.getCreatorId());\n"
"        int rows = pstmt.executeUpdate();\n"
"        if (rows > 0) { /* 回填 competitionId */ }\n"
"        return rows;\n"
"    } catch (SQLException e) { e.printStackTrace(); return 0; }\n"
"}\n\n"
"// CompetitionServiceImpl.createCompetition —— 必填校验 + 默认值\n"
"public boolean createCompetition(Competition competition) {\n"
"    if (competition == null || competition.getName() == null || competition.getName().trim().isEmpty()) return false;\n"
"    if (competition.getYear() == null || competition.getYear() < 2000\n"
"            || competition.getSubmitDeadline() == null || competition.getTheme() == null\n"
"            || competition.getTheme().trim().isEmpty() || competition.getCreatorId() == null) return false;\n"
"    if (competition.getStatus() == null) competition.setStatus(1);      // 默认报名中\n"
"    if (competition.getMaxTeamSize() == null) competition.setMaxTeamSize(5);\n"
"    if (competition.getMaxTeamSize() <= 0 || competition.getMaxTeamSize() > 100) return false;\n"
"    competition.setCreateTime(LocalDateTime.now());\n"
"    return competitionDAO.insert(competition) > 0;\n"
"}"
                ),
                "test": (
"// 代表性测试：构造对象 -> 插入 -> 回读\n"
"Competition c = new Competition();\n"
"c.setYear(2026); c.setName(\"2026校园文化海报设计大赛\"); c.setTheme(\"青春·校园\");\n"
"c.setSubmitDeadline(LocalDateTime.of(2026,9,1,23,59)); c.setMaxTeamSize(5);\n"
"c.setStatus(1); c.setCreatorId(1);\n"
"assertTrue(competitionService.createCompetition(c));\n"
"assertNotNull(c.getCompetitionId()); // 自增主键回填\n"
"Competition fetched = competitionService.getCompetitionById(c.getCompetitionId());\n"
"assertEquals(\"2026校园文化海报设计大赛\", fetched.getName());"
                ),
                "ctrl": (
"// CompetitionServlet.createCompetition —— 写入主表 + 批量写入子类\n"
"private void createCompetition(HttpServletRequest request, HttpServletResponse response) ... {\n"
"    Competition competition = extractCompetitionFromRequest(request);\n"
"    HttpSession session = request.getSession(false);\n"
"    if (session != null && session.getAttribute(\"user\") != null) {\n"
"        User user = (User) session.getAttribute(\"user\");\n"
"        competition.setCreatorId(user.getUserId());\n"
"    }\n"
"    boolean success = competitionService.createCompetition(competition);\n"
"    if (success && saveCategories(request, competition.getCompetitionId())) {\n"
"        response.sendRedirect(request.getContextPath() + \"/competition?action=list\");\n"
"    } else {\n"
"        request.setAttribute(\"error\", success ? \"竞赛已创建，但子类保存失败\" : \"创建竞赛失败\");\n"
"        request.getRequestDispatcher(\"/jsp/competition_add.jsp\").forward(request, response);\n"
"    }\n"
"}\n\n"
"// saveCategories —— 从请求中读取子类并逐条插入\n"
"private boolean saveCategories(HttpServletRequest request, Integer competitionId) {\n"
"    String[] names = request.getParameterValues(\"categoryName\");\n"
"    String[] descs = request.getParameterValues(\"categoryDesc\");\n"
"    if (names != null && competitionId != null) {\n"
"        for (int i = 0; i < names.length; i++) {\n"
"            String name = names[i].trim();\n"
"            if (!name.isEmpty()) {\n"
"                CompetitionCategory cat = new CompetitionCategory();\n"
"                cat.setCompetitionId(competitionId); cat.setCategoryName(name);\n"
"                if (descs != null && i < descs.length && descs[i] != null)\n"
"                    cat.setCategoryDesc(descs[i].trim());\n"
"                if (categoryDAO.insert(cat) <= 0) return false;\n"
"            }\n"
"        }\n"
"    }\n"
"    return true;\n"
"}"
                ),
                "view": (
"<!-- competition_add.jsp 表单与子类动态行（节选） -->\n"
"<form action=\"${pageContext.request.contextPath}/competition?action=create\" method=\"post\">\n"
"  <div class=\"mb-3\"><label class=\"form-label\">竞赛名称 *</label>\n"
"    <input type=\"text\" class=\"form-control\" name=\"name\" required></div>\n"
"  <div class=\"mb-3\"><label class=\"form-label\">提交截止时间 *</label>\n"
"    <input type=\"datetime-local\" class=\"form-control\" name=\"submitDeadline\" required></div>\n"
"  <div class=\"mb-3\"><label class=\"form-label\">最大队伍人数 *</label>\n"
"    <input type=\"number\" class=\"form-control\" name=\"maxTeamSize\" min=\"1\" max=\"10\" value=\"5\" required></div>\n"
"  <div class=\"mb-3\"><label class=\"form-label\">竞赛状态 *</label>\n"
"    <select class=\"form-select\" name=\"status\" required>\n"
"      <option value=\"1\" selected>报名中</option><option value=\"2\">进行中</option><option value=\"3\">已结束</option>\n"
"    </select></div>\n"
"  <div id=\"categoriesContainer\">\n"
"    <div class=\"row g-2 mb-2 category-row\">\n"
"      <div class=\"col-md-5\"><input type=\"text\" class=\"form-control\" name=\"categoryName\" placeholder=\"子类名称\" required></div>\n"
"      <div class=\"col-md-5\"><input type=\"text\" class=\"form-control\" name=\"categoryDesc\" placeholder=\"子类描述（可选）\"></div>\n"
"    </div>\n"
"  </div>\n"
"  <button type=\"button\" class=\"btn btn-outline-primary btn-sm mt-2\" id=\"addCategoryBtn\">+ 添加子类</button>\n"
"  <button type=\"submit\" class=\"btn btn-primary\">发布竞赛</button>\n"
"</form>"
                ),
                "sql": (
"INSERT INTO competition (year, name, theme, description, submit_deadline,\n"
"                         max_team_size, status, creator_id)\n"
"VALUES (?, ?, ?, ?, ?, ?, ?, ?);"
                ),
                "effect": "竞赛发布页支持动态增删竞赛子类行（至少一项），提交后主表与子类表一并写入，"
                          "成功后自动跳转竞赛列表；校验失败时回显具体错误。",
            },
            {
                "title": "1.2.2 竞赛详情",
                "desc": "根据竞赛 ID 查询单个竞赛的完整信息（含竞赛方向子类、参赛统计、可加入队伍列表），"
                        "并在详情页根据登录状态与角色显示参赛状态（未登录提示登录 / 已参加显示队伍 / "
                        "未参加显示创建或加入队伍入口）；管理员可见编辑/取消/删除按钮。",
                "model": (
"// CompetitionDAOImpl.findById\n"
"public Competition findById(Integer competitionId) {\n"
"    if (competitionId == null) return null;\n"
"    String sql = \"SELECT * FROM competition WHERE competition_id = ?\";\n"
"    try (Connection conn = DBUtil.getConnection();\n"
"         PreparedStatement pstmt = conn.prepareStatement(sql)) {\n"
"        pstmt.setInt(1, competitionId);\n"
"        try (ResultSet rs = pstmt.executeQuery()) {\n"
"            if (rs.next()) return extractCompetitionFromResultSet(rs);\n"
"        }\n"
"    } catch (SQLException e) { e.printStackTrace(); }\n"
"    return null;\n"
"}\n\n"
"// CompetitionServiceImpl.getCompetitionById\n"
"public Competition getCompetitionById(Integer competitionId) {\n"
"    if (competitionId == null) return null;\n"
"    return competitionDAO.findById(competitionId);\n"
"}"
                ),
                "test": (
"Competition c = competitionService.getCompetitionById(3);\n"
"assertNotNull(c);\n"
"assertEquals(Integer.valueOf(3), c.getCompetitionId());\n"
"assertNull(competitionService.getCompetitionById(99999)); // 不存在返回 null\n"
"assertNull(competitionService.getCompetitionById(null));"
                ),
                "ctrl": (
"// CompetitionServlet.showCompetitionDetail —— 判定用户是否已参加该竞赛\n"
"private void showCompetitionDetail(HttpServletRequest request, HttpServletResponse response) ... {\n"
"    Integer competitionId = Integer.parseInt(request.getParameter(\"id\"));\n"
"    Competition competition = competitionService.getCompetitionById(competitionId);\n"
"    if (competition == null) { response.sendRedirect(...+\"&error=not_found\"); return; }\n"
"    HttpSession session = request.getSession(false);\n"
"    User user = (session != null) ? (User) session.getAttribute(\"user\") : null;\n"
"    boolean hasJoined = false; Team userTeam = null;\n"
"    if (user != null) {\n"
"        userTeam = teamService.getUserTeamInCompetition(user.getUserId(), competitionId);\n"
"        hasJoined = (userTeam != null);\n"
"    }\n"
"    Map<String, Integer> stats = competitionService.getCompetitionStats(competitionId);\n"
"    List<CompetitionCategory> categories = categoryDAO.findByCompetitionId(competitionId);\n"
"    request.setAttribute(\"competition\", competition);\n"
"    request.setAttribute(\"hasJoined\", hasJoined);\n"
"    request.setAttribute(\"userTeam\", userTeam);\n"
"    request.getRequestDispatcher(\"/jsp/competition_detail.jsp\").forward(request, response);\n"
"}"
                ),
                "view": (
"<!-- competition_detail.jsp 角色判定、参赛状态区与管理按钮（节选） -->\n"
"<% User sessionUser = (User) session.getAttribute(\"user\");\n"
"   boolean isAdmin=false, isJudge=false;\n"
"   if (sessionUser != null) { for (Role role : (List<Role>) session.getAttribute(\"roles\")) {\n"
"       if (\"管理员\".equals(role.getRoleName())) isAdmin = true;\n"
"       if (\"评委\".equals(role.getRoleName())) isJudge = true; } }\n"
"   boolean canParticipate = sessionUser != null && !isAdmin && !isJudge; %>\n"
"\n"
"<div class=\"app-detail-section\"><h3>参赛状态</h3>\n"
"  <% if (sessionUser == null) { %>\n"
"    <a href=\"${pageContext.request.contextPath}/login\" class=\"btn btn-primary\">立即登录</a>\n"
"  <% } else if (hasJoined) { %>\n"
"    <p>✓ 您已参加此竞赛：<%= userTeam.getTeamName() %></p>\n"
"  <% } else if (canParticipate) { %>\n"
"    <a href=\".../team?action=create&competitionId=<%= competition.getCompetitionId() %>\" class=\"btn btn-primary\">创建队伍</a>\n"
"  <% } %>\n"
"</div>\n"
"\n"
"<% if (isAdmin) { %>\n"
"  <a href=\".../competition?action=edit&id=<%= competition.getCompetitionId() %>\" class=\"btn btn-primary\">编辑竞赛</a>\n"
"  <button onclick=\"deleteCompetition(<%= competition.getCompetitionId() %>)\">删除竞赛</button>\n"
"<% } %>"
                ),
                "sql": (
"SELECT * FROM competition WHERE competition_id = ?;\n"
"-- 竞赛子类：SELECT * FROM competition_category WHERE competition_id = ?;"
                ),
                "effect": "详情页顶部根据角色显示不同操作入口：未登录提示登录、已参加显示队伍与作品、"
                          "可参赛用户显示创建/加入队伍按钮；仅管理员可见编辑/删除等管理按钮。",
            },
        ],
    },

    # ===================== 模块3 队伍管理 =====================
    {
        "title": "1.3 队伍管理模块",
        "intro": "队长在报名中的竞赛下创建队伍、邀请队员、报名参赛与成员管理。"
                "系统约束“同一用户同一竞赛只能加入一支队伍”，人数上限读取竞赛的 maxTeamSize。",
        "functions": [
            {
                "title": "1.3.1 创建队伍",
                "desc": "队长在报名中的竞赛下创建队伍，系统自动将队长本人写入 team_member 表（role=1）"
                        "并校验同一用户在同一个竞赛不得重复建队；队伍与队长成员记录必须成对存在，否则回滚孤儿队伍。",
                "model": (
"// TeamServiceImpl.createTeam —— 成对写入队伍与队长成员\n"
"public boolean createTeam(Team team, Integer leaderId) {\n"
"    if (team == null || leaderId == null) return false;\n"
"    if (team.getTeamName() == null || team.getTeamName().trim().isEmpty()) return false;\n"
"    if (team.getCompetitionId() == null || team.getCategoryId() == null) return false;\n"
"    Competition competition = competitionDAO.findById(team.getCompetitionId());\n"
"    if (competition == null || competition.getStatus() == null || competition.getStatus() != 1) return false; // 需报名中\n"
"    // 同一竞赛不得重复建队\n"
"    if (getUserTeamInCompetition(leaderId, team.getCompetitionId()) != null) return false;\n"
"    team.setLeaderId(leaderId);\n"
"    if (team.getStatus() == null) team.setStatus(1); // 默认组建中\n"
"    team.setCreateTime(LocalDateTime.now());\n"
"    int result = teamDAO.insert(team);\n"
"    if (result <= 0) return false;\n"
"    TeamMember leaderMember = new TeamMember();\n"
"    leaderMember.setTeamId(team.getTeamId()); leaderMember.setUserId(leaderId);\n"
"    leaderMember.setRole(1); // 队长\n"
"    if (teamMemberDAO.insert(leaderMember) > 0) return true;\n"
"    teamDAO.deleteById(team.getTeamId()); // 成员写入失败则删除孤儿队伍\n"
"    return false;\n"
"}\n\n"
"// TeamDAOImpl.insert\n"
"public int insert(Team team) {\n"
"    String sql = \"INSERT INTO team (team_name, competition_id, category_id, leader_id, team_desc, status) VALUES (?, ?, ?, ?, ?, ?)\";\n"
"    // PreparedStatement 设置参数并执行，回填 teamId\n"
"}"
                ),
                "test": (
"TeamService service = new TeamServiceImpl();\n"
"Team t1 = new Team(); t1.setTeamName(\"甲队\"); t1.setCompetitionId(1); t1.setCategoryId(1);\n"
"assertTrue(service.createTeam(t1, 1001));        // 首次创建成功\n"
"Team t2 = new Team(); t2.setTeamName(\"乙队\"); t2.setCompetitionId(1); t2.setCategoryId(1);\n"
"assertFalse(service.createTeam(t2, 1001));       // 同竞赛重复建队被拒"
                ),
                "ctrl": (
"// TeamServlet.createTeam\n"
"private void createTeam(HttpServletRequest request, HttpServletResponse response) ... {\n"
"    HttpSession session = request.getSession(false);\n"
"    if (session == null || session.getAttribute(\"user\") == null) { response.sendRedirect(...+\"/login\"); return; }\n"
"    User user = (User) session.getAttribute(\"user\");\n"
"    Team team = extractTeamFromRequest(request);\n"
"    boolean success = teamService.createTeam(team, user.getUserId());\n"
"    if (success) response.sendRedirect(request.getContextPath() + \"/team?action=myTeams\");\n"
"    else { request.setAttribute(\"error\", \"创建失败：同一竞赛只能加入一支队伍\");\n"
"           request.getRequestDispatcher(\"/jsp/team_create.jsp\").forward(request, response); }\n"
"}"
                ),
                "view": (
"<!-- team_create.jsp 表单（节选） -->\n"
"<form action=\"${pageContext.request.contextPath}/team?action=create\" method=\"post\" id=\"createTeamForm\">\n"
"  <div class=\"form-card mb-4\"><div class=\"card-header\"><h5>选择参赛竞赛</h5></div>\n"
"    <div class=\"row g-3\">\n"
"      <c:forEach items=\"${competitions}\" var=\"comp\">\n"
"        <div class=\"col-md-6\">\n"
"          <label class=\"comp-select-card\">\n"
"            <input type=\"radio\" name=\"competitionId\" value=\"${comp.competitionId}\" onchange=\"selectCompetition(this)\">\n"
"            <span class=\"badge bg-success\">报名中</span>\n"
"            <h6>${comp.name}</h6><p>${comp.year}年度 · 最多${comp.maxTeamSize}人/队</p>\n"
"          </label>\n"
"        </div>\n"
"      </c:forEach>\n"
"    </div>\n"
"  </div>\n"
"  <div class=\"col-md-7\"><input type=\"text\" class=\"form-control\" name=\"teamName\" placeholder=\"队伍名称\" required></div>\n"
"  <div class=\"col-md-5\"><select class=\"form-select\" name=\"categoryId\" required>\n"
"    <option value=\"\">选择参赛方向</option>\n"
"    <c:forEach items=\"${categories}\" var=\"cat\"><option value=\"${cat.categoryId}\">${cat.categoryName}</option></c:forEach>\n"
"  </select></div>\n"
"  <button type=\"submit\" class=\"btn-primary-action\">创建队伍</button>\n"
"</form>"
                ),
                "sql": (
"INSERT INTO team (team_name, competition_id, category_id, leader_id, team_desc, status) VALUES (?, ?, ?, ?, ?, ?);\n"
"INSERT INTO team_member (team_id, user_id, is_leader) VALUES (?, ?, ?);"
                ),
                "effect": "创建队伍页以竞赛卡片选择 + 参赛方向下拉呈现；提交后队长自动成为 1 号成员，"
                          "若同一竞赛已有队伍则拒绝并提示。",
            },
            {
                "title": "1.3.2 邀请队员",
                "desc": "队长搜索并邀请可参赛用户（队员/队长账号），系统写入 invitation 记录（status=0）；"
                        "被邀请人接受后，将成员插入 team_member（role=2），并按竞赛配置 maxTeamSize 校验"
                        "队伍人数上限，同时防止重复加入与跨队冲突。",
                "model": (
"// InvitationServiceImpl.acceptInvitation —— 校验 -> 插入成员 -> 更新邀请状态\n"
"public boolean acceptInvitation(Integer invitationId, Integer userId) {\n"
"    Invitation invitation = invitationDAO.findById(invitationId);\n"
"    if (invitation == null) return false;\n"
"    if (invitation.getStatus() == null || invitation.getStatus() != 0) return false; // 仅待处理\n"
"    if (invitation.getInviteeId() == null || !invitation.getInviteeId().equals(userId)) return false;\n"
"    if (!isInviteEligibleParticipant(userId)) return false; // 仅队员/队长可加入\n"
"    Team team = teamDAO.findById(invitation.getTeamId());\n"
"    if (team == null || team.getStatus() == null || team.getStatus() != 1) return false; // 需组建中\n"
"    // 人数上限取竞赛 maxTeamSize\n"
"    int memberCount = teamMemberDAO.countByTeamId(invitation.getTeamId());\n"
"    int maxTeamSize = ...; // competition.getMaxTeamSize()，默认5\n"
"    if (memberCount >= maxTeamSize) return false;\n"
"    TeamMember newMember = new TeamMember();\n"
"    newMember.setTeamId(invitation.getTeamId()); newMember.setUserId(userId); newMember.setRole(2);\n"
"    int insertResult = teamMemberDAO.insert(newMember);\n"
"    if (insertResult <= 0) return false;\n"
"    invitation.setStatus(1); invitation.setResponseTime(LocalDateTime.now());\n"
"    if (invitationDAO.update(invitation) <= 0) { teamMemberDAO.deleteByTeamIdAndUserId(...); return false; }\n"
"    return true;\n"
"}\n\n"
"// TeamServiceImpl.inviteMember —— 队长发起邀请（含人数/跨队校验）\n"
"public boolean inviteMember(Integer teamId, Integer inviterId, Integer inviteeId) {\n"
"    if (!isUserLeaderOfTeam(inviterId, teamId)) return false;     // 必须是队长\n"
"    if (!isInviteEligibleParticipant(inviteeId)) return false;     // 被邀请人须为参赛方\n"
"    Team team = teamDAO.findById(teamId);\n"
"    if (team == null || team.getStatus() != 1) return false;      // 队伍须组建中\n"
"    int maxTeamSize = ...; // 取竞赛 maxTeamSize\n"
"    if (teamMemberDAO.countByTeamId(teamId) >= maxTeamSize) return false; // 满员\n"
"    if (getUserTeamInCompetition(inviteeId, team.getCompetitionId()) != null) return false; // 已在同竞赛其他队\n"
"    Invitation invitation = new Invitation();\n"
"    invitation.setTeamId(teamId); invitation.setInviterId(inviterId);\n"
"    invitation.setInviteeId(inviteeId); invitation.setStatus(0);\n"
"    return invitationDAO.insert(invitation) > 0;\n"
"}"
                ),
                "test": (
"InvitationService invService = new InvitationServiceImpl();\n"
"TeamService teamService = new TeamServiceImpl();\n"
"assertTrue(teamService.inviteMember(teamId, 1001, 2002)); // 队长邀请用户2002\n"
"Integer invitationId = invitationDAO.findByInviteeId(2002).get(0).getInvitationId();\n"
"assertTrue(invService.acceptInvitation(invitationId, 2002)); // 接受邀请\n"
"assertTrue(teamService.isUserMemberOfTeam(2002, teamId));    // 已成为队员"
                ),
                "ctrl": (
"// TeamServlet.searchUserForInvite —— AJAX 模糊搜索可邀请用户\n"
"private void searchUserForInvite(HttpServletRequest request, HttpServletResponse response) ... {\n"
"    String keyword = request.getParameter(\"keyword\");\n"
"    response.setContentType(\"application/json;charset=UTF-8\");\n"
"    List<User> users = userDAO.searchInviteEligibleUsers(keyword.trim());\n"
"    StringBuilder json = new StringBuilder(\"[\");\n"
"    for (User u : users) { /* 拼装 {userId,realName,username} */ }\n"
"    json.append(\"]\"); response.getWriter().write(json.toString());\n"
"}\n\n"
"// InvitationServlet.doPost —— 接受/拒绝邀请\n"
"if (\"accept\".equals(action)) {\n"
"    Integer invitationId = Integer.parseInt(request.getParameter(\"invitationId\"));\n"
"    boolean success = invitationService.acceptInvitation(invitationId, user.getUserId());\n"
"    response.sendRedirect(success ? \"/invitation?msg=accept_success\" : \"/invitation?error=accept_failed\");\n"
"}"
                ),
                "view": (
"<!-- team_detail.jsp 邀请队员 Modal（节选） -->\n"
"<div class=\"modal fade\" id=\"inviteMemberModal\" tabindex=\"-1\">\n"
"  <div class=\"modal-body\">\n"
"    <label class=\"form-label fw-bold\">搜索用户</label>\n"
"    <div class=\"input-group\">\n"
"      <span class=\"input-group-text\"><i class=\"fas fa-search\"></i></span>\n"
"      <input type=\"text\" class=\"form-control\" id=\"userSearchInput\" oninput=\"searchUsers()\"\n"
"             placeholder=\"输入姓名或用户名搜索可邀请用户...\">\n"
"    </div>\n"
"    <div id=\"userSearchResults\" class=\"mt-3\"></div>\n"
"  </div>\n"
"</div>\n"
"<script>\n"
"function searchUsers() {\n"
"  fetch('${pageContext.request.contextPath}/team?action=searchUser&keyword=' + encodeURIComponent(keyword), {method:'POST'})\n"
"    .then(res => res.json()).then(users => { /* 渲染结果 + 邀请按钮 */ });\n"
"}\n"
"function inviteUser(userId, realName, btn) {\n"
"  var fd = new URLSearchParams(); fd.append('action','invite'); fd.append('teamId','${team.teamId}'); fd.append('inviteeId', userId); fd.append('ajax','true');\n"
"  fetch('${pageContext.request.contextPath}/team', {method:'POST', body: fd}).then(r=>r.json())\n"
"    .then(data => { if (data.success) showToast('已发送邀请'); });\n"
"}\n"
"</script>"
                ),
                "sql": (
"INSERT INTO invitation (team_id, inviter_id, invitee_id, status, invite_time) VALUES (?, ?, ?, ?, ?);\n"
"INSERT INTO team_member (team_id, user_id, is_leader) VALUES (?, ?, ?);\n"
"UPDATE invitation SET status=?, response_time=? WHERE invitation_id=?;\n"
"SELECT * FROM invitation WHERE invitee_id = ? ORDER BY invite_time DESC;"
                ),
                "effect": "队伍详情页“邀请队员”弹窗可输入姓名/用户名实时 AJAX 搜索可邀请用户并发起邀请；"
                          "被邀请人在邀请通知页接受后自动成为队员，全程受人数上限与跨队冲突约束。",
                "shot": r"C:/Users/31815/IdeaProjects/task1/docs/verify-join-team-modal.png",
                "shot_w": 5.4,
                "shot_caption": "图 邀请队员弹窗（实时搜索并发送邀请）运行效果",
            },
        ],
    },

    # ===================== 模块4 作品管理 =====================
    {
        "title": "1.4 作品管理模块",
        "intro": "队长代表已报名队伍提交海报作品，图片以二进制（BLOB）存入数据库并自动生成缩略图；"
                "支持作品列表、详情查看、点赞与分享。",
        "functions": [
            {
                "title": "1.4.1 作品提交",
                "desc": "队长在队伍已报名（status=2）、竞赛处于进行中（status=2）且未过提交截止日期的前提下，"
                        "代表队伍提交一张海报作品；提交时服务端读取图片二进制数据并连同原图 BLOB、缩略图 BLOB "
                        "一并写入 work 表，作品状态置为已提交（2）。",
                "model": (
"// WorkServiceImpl.submitWork —— 必填校验 + 状态落库\n"
"public boolean submitWork(Work work) {\n"
"    if (work.getTeamId() == null || work.getCompetitionId() == null) return false;\n"
"    if (work.getTitle() == null || work.getTitle().trim().isEmpty()) return false;\n"
"    if (work.getImagePath() == null || work.getImagePath().trim().isEmpty()) return false;\n"
"    work.setStatus(2);                 // 已提交\n"
"    work.setSubmitTime(LocalDateTime.now());\n"
"    return workDAO.insert(work) > 0;\n"
"}\n\n"
"// WorkDAOImpl.insert —— 写入原图/缩略图 BLOB\n"
"public int insert(Work work) {\n"
"    String sql = \"INSERT INTO work (team_id, competition_id, category_id, work_title, work_desc,\"\n"
"            + \" image_path, image_data, image_content_type, thumbnail_data, thumbnail_content_type, status)\"\n"
"            + \" VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)\";\n"
"    try (Connection conn = DBUtil.getConnection();\n"
"         PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {\n"
"        pstmt.setInt(1, work.getTeamId()); pstmt.setInt(2, work.getCompetitionId());\n"
"        if (work.getCategoryId() != null) pstmt.setInt(3, work.getCategoryId()); else pstmt.setNull(3, Types.INTEGER);\n"
"        pstmt.setString(4, work.getTitle()); pstmt.setString(5, work.getDescription());\n"
"        pstmt.setString(6, work.getImagePath());\n"
"        pstmt.setBytes(7, work.getImageData());           // 原图 MEDIUMBLOB\n"
"        pstmt.setString(8, work.getImageContentType());\n"
"        pstmt.setBytes(9, work.getThumbnailData());       // 缩略图 MEDIUMBLOB\n"
"        pstmt.setString(10, work.getThumbnailContentType());\n"
"        pstmt.setInt(11, work.getStatus() != null ? work.getStatus() : 2);\n"
"        int rows = pstmt.executeUpdate();\n"
"        if (rows > 0) { /* 回填 workId */ }\n"
"        return rows;\n"
"    } catch (SQLException e) { e.printStackTrace(); return 0; }\n"
"}"
                ),
                "test": (
"Work w = new Work();\n"
"w.setTeamId(3); w.setCompetitionId(1);\n"
"w.setTitle(\"\"); assertFalse(workService.submitWork(w));           // 标题为空\n"
"w.setTitle(\"绿色地球\"); w.setImagePath(null); assertFalse(workService.submitWork(w)); // 图片为空\n"
"w.setImagePath(\"/competition_1/team_3.jpg\"); w.setImageData(new byte[]{1,2,3});\n"
"w.setThumbnailData(new byte[]{4,5,6}); w.setImageContentType(\"image/jpeg\");\n"
"assertTrue(workService.submitWork(w));                            // 校验通过\n"
"assertEquals(Integer.valueOf(2), w.getStatus());                  // 状态=已提交"
                ),
                "ctrl": (
"// WorkServlet.submitWork —— 队长权限 + 竞赛/截止日期校验 + 图片处理\n"
"private void submitWork(HttpServletRequest request, HttpServletResponse response) ... {\n"
"    Team team = teamDAO.findById(teamId);\n"
"    if (!team.getLeaderId().equals(user.getUserId())) { ...; return; }      // 仅队长\n"
"    if (team.getStatus() == null || team.getStatus() != 2) { ...; return; } // 队伍须已报名\n"
"    if (!isCompetitionRunningAndOpen(competition)) { ...; return; }         // 竞赛进行中且未截止\n"
"    if (existingWorks != null && !existingWorks.isEmpty()) { ...; return; } // 不可重复提交\n"
"    // 读取上传图片 -> 生成缩略图 -> 写入 work\n"
"    imageData = readPartBytes(filePart);\n"
"    thumbnailData = createThumbnail(imageData);  // ImageIO 生成 300px JPEG 0.75\n"
"    Work work = new Work(); work.setTeamId(teamId); work.setCompetitionId(team.getCompetitionId());\n"
"    work.setCategoryId(team.getCategoryId()); work.setTitle(title.trim());\n"
"    work.setImagePath(imagePath); work.setImageData(imageData); work.setImageContentType(imageContentType);\n"
"    work.setThumbnailData(thumbnailData); work.setThumbnailContentType(THUMBNAIL_CONTENT_TYPE);\n"
"    boolean success = workService.submitWork(work);\n"
"    if (success) response.sendRedirect(request.getContextPath() + \"/work?msg=submit_success\");\n"
"    else { FileUploadUtil.deleteFile(uploadRealPath, imagePath); ... }\n"
"}"
                ),
                "view": (
"<!-- submission_add.jsp 海报图片上传区 + 预览（节选） -->\n"
"<form action=\"${pageContext.request.contextPath}/work\" method=\"post\" enctype=\"multipart/form-data\" id=\"submitForm\">\n"
"  <input type=\"hidden\" name=\"action\" value=\"submit\">\n"
"  <div class=\"upload-area\" id=\"uploadArea\" onclick=\"document.getElementById('imageFile').click()\">\n"
"    <input type=\"file\" id=\"imageFile\" name=\"imageFile\" accept=\"image/jpeg,image/png\">\n"
"    <div id=\"uploadPlaceholder\"><i class=\"fas fa-cloud-upload-alt\"></i><p>点击上传海报图片</p>\n"
"      <small class=\"text-muted\">支持 JPG/PNG，最大 10MB</small></div>\n"
"    <div id=\"previewContainer\" class=\"preview-container d-none\">\n"
"      <img id=\"previewImage\" src=\"\" alt=\"预览\"></div>\n"
"  </div>\n"
"  <input type=\"text\" name=\"title\" placeholder=\"作品名称\" required>\n"
"  <textarea name=\"description\" maxlength=\"500\" placeholder=\"作品描述（500字内）\"></textarea>\n"
"  <button type=\"submit\" class=\"btn btn-primary\">提交作品</button>\n"
"</form>"
                ),
                "sql": (
"INSERT INTO work (team_id, competition_id, category_id, work_title, work_desc,\n"
"                  image_path, image_data, image_content_type,\n"
"                  thumbnail_data, thumbnail_content_type, status)\n"
"VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
                ),
                "effect": "作品提交页支持图片点击/拖拽上传与即时预览、描述 500 字上限；"
                          "提交受队长身份、队伍报名状态、竞赛进行中与截止日期多重校验。",
            },
            {
                "title": "1.4.2 作品图片上传与展示",
                "desc": "海报图片以二进制形式存储于数据库 work 表的 image_data（原图 MEDIUMBLOB）与 "
                        "thumbnail_data（缩略图 MEDIUMBLOB）字段；提交/更新时由 WorkServlet 借助 ImageIO "
                        "生成最大宽 300px、JPEG 质量 0.75 的缩略图；展示时由 ImageDataServlet（/image-data）"
                        "按 workId 与 type=thumb|original 从数据库读取 BLOB 并输出，列表页用缩略图、详情页用原图。",
                "model": (
"// FileUploadUtil —— 文件类型/扩展名/大小三重校验\n"
"private static final String[] ALLOWED_TYPES = {\"image/jpeg\", \"image/png\"};\n"
"private static final long MAX_FILE_SIZE = 10 * 1024 * 1024L; // 10MB\n"
"public static boolean isAllowedType(String contentType) { ... }\n"
"public static boolean isAllowedSize(long size) { return size > 0 && size <= MAX_FILE_SIZE; }\n\n"
"// WorkServlet.createThumbnail —— ImageIO 生成缩略图\n"
"private byte[] createThumbnail(byte[] imageData) throws IOException {\n"
"    BufferedImage source = ImageIO.read(new ByteArrayInputStream(imageData));\n"
"    int targetWidth = Math.min(source.getWidth(), THUMBNAIL_MAX_WIDTH); // 300\n"
"    int targetHeight = (int) Math.round(source.getHeight() * (targetWidth / (double) source.getWidth()));\n"
"    BufferedImage thumbnail = new BufferedImage(targetWidth, targetHeight, BufferedImage.TYPE_INT_RGB);\n"
"    Graphics2D g = thumbnail.createGraphics();\n"
"    g.drawImage(source, 0, 0, targetWidth, targetHeight, Color.WHITE, null); g.dispose();\n"
"    // ImageWriter 以 JPEG 质量 0.75 写出\n"
"    return output.toByteArray();\n"
"}"
                ),
                "test": (
"// 集成测试思路：提交一张图后 work 表 image_data/thumbnail_data 非空\n"
"Work w = workService.getWorkById(1);\n"
"assertNotNull(w.getImageData()); assertNotNull(w.getThumbnailData());\n"
"assertEquals(\"image/jpeg\", w.getThumbnailContentType());\n"
"// GET /image-data?workId=1&type=thumb 返回缩略图；type=original 返回原图；越权返回 403"
                ),
                "ctrl": (
"// ImageDataServlet.doGet —— 按 type 返回 原图 / 缩略图\n"
"protected void doGet(HttpServletRequest request, HttpServletResponse response) ... {\n"
"    Integer workId = Integer.parseInt(request.getParameter(\"workId\"));\n"
"    Work work = workService.getWorkById(workId);\n"
"    if (work == null) { response.sendError(404, \"作品不存在\"); return; }\n"
"    User user = ...; if (user == null || !canViewWork(request, user, work)) { response.sendError(403); return; }\n"
"    String type = request.getParameter(\"type\");\n"
"    byte[] imageData; String contentType;\n"
"    if (\"thumb\".equalsIgnoreCase(type)) {\n"
"        imageData = work.getThumbnailData(); contentType = work.getThumbnailContentType();\n"
"        if (imageData == null || imageData.length == 0) { imageData = work.getImageData(); contentType = work.getImageContentType(); } // 回退原图\n"
"    } else { imageData = work.getImageData(); contentType = work.getImageContentType(); }\n"
"    response.setContentType(contentType != null ? contentType : \"image/jpeg\");\n"
"    response.setContentLength(imageData.length);\n"
"    try (OutputStream out = response.getOutputStream()) { out.write(imageData); out.flush(); }\n"
"}"
                ),
                "view": (
"<!-- submission_list.jsp 卡片缩略图使用 /image-data?workId=..&type=thumb -->\n"
"<% String imgUrl = request.getContextPath() + \"/image-data?workId=\" + work.getWorkId() + \"&type=thumb\"; %>\n"
"<article class=\"work-card app-art-card\">\n"
"  <a class=\"app-art-media\" href=\"${pageContext.request.contextPath}/work?action=detail&id=<%= work.getWorkId() %>\">\n"
"    <img src=\"<%= imgUrl %>\" alt=\"<%= work.getTitle() %>\">\n"
"  </a>\n"
"</article>"
                ),
                "sql": (
"SELECT * FROM work WHERE work_id = ?;  -- 含 image_data / thumbnail_data (MEDIUMBLOB)"
                ),
                "effect": "列表/卡片页使用缩略图接口减轻加载压力，详情/评分页使用原图；图片集中存于数据库，"
                          "避免分散在各终端导致无法显示，越权访问返回 403。",
            },
        ],
    },

    # ===================== 模块5 评分与获奖 =====================
    {
        "title": "1.5 评分与获奖模块",
        "intro": "评委对已提交作品评分；管理员为已结束竞赛的作品设置获奖等级并自动生成电子奖状。"
                "评分带 0–100 范围校验与“同一评委同一作品仅评一次”双重防重。",
        "functions": [
            {
                "title": "1.5.1 评委评分",
                "desc": "评委对已提交（status=2/3）的作品进行 0–100 分评分；Service 层对分数范围与"
                        "同一评委对同一作品只能评一次（数据库 UNIQUE(work_id, judge_id) 双重防重）进行校验，"
                        "插入评分后自动将作品状态推进为已评分（status=3）。",
                "model": (
"// ScoreServiceImpl.addScore —— 范围校验 + 防重 + 落库\n"
"public boolean addScore(Score score) {\n"
"    if (score == null) return false;\n"
"    // 1. 分数范围 0-100\n"
"    if (score.getScore() == null || score.getScore() < 0 || score.getScore() > 100) return false;\n"
"    if (score.getWorkId() == null || score.getJudgeId() == null) return false;\n"
"    // 2. 同一评委同一作品只能评一次\n"
"    if (hasScored(score.getWorkId(), score.getJudgeId())) return false;\n"
"    if (scoreDAO.insert(score) <= 0) return false;\n"
"    if (!markWorkAsScored(score.getWorkId())) { scoreDAO.deleteById(score.getScoreId()); return false; }\n"
"    return true;\n"
"}\n"
"public boolean hasScored(Integer workId, Integer judgeId) {\n"
"    List<Score> scores = scoreDAO.findByWorkId(workId);\n"
"    for (Score s : scores) if (judgeId.equals(s.getJudgeId())) return true;\n"
"    return false;\n"
"}\n\n"
"// ScoreDAOImpl.insert —— 返回自增 scoreId\n"
"public int insert(Score score) {\n"
"    String sql = \"INSERT INTO score (work_id, judge_id, score) VALUES (?, ?, ?)\";\n"
"    // PreparedStatement 设置参数并执行，回填 scoreId\n"
"}\n"
"// 平均分：SELECT AVG(score) FROM score WHERE work_id = ?  （无记录返回 0.0）"
                ),
                "test": (
"ScoreService service = new ScoreServiceImpl();\n"
"Score s1 = new Score(); s1.setWorkId(10); s1.setJudgeId(3); s1.setScore(88.0);\n"
"assertTrue(service.addScore(s1));                       // 正常评分\n"
"Score s2 = new Score(); s2.setWorkId(10); s2.setJudgeId(4); s2.setScore(120.0);\n"
"assertFalse(service.addScore(s2));                      // 超范围\n"
"Score s3 = new Score(); s3.setWorkId(10); s3.setJudgeId(3); s3.setScore(90.0);\n"
"assertFalse(service.addScore(s3));                      // 重复评分被拒\n"
"assertEquals(88.0, service.getAverageScore(10));"
                ),
                "ctrl": (
"// ScoreServlet.doPost + submitScore\n"
"protected void doPost(HttpServletRequest request, HttpServletResponse response) ... {\n"
"    if (!isJudge(request)) { response.sendError(403, \"仅评委可提交评分\"); return; }\n"
"    String action = request.getParameter(\"action\");\n"
"    if (\"submit\".equals(action)) submitScore(request, response);\n"
"    else if (\"update\".equals(action)) updateScore(request, response);\n"
"}\n\n"
"private void submitScore(HttpServletRequest request, HttpServletResponse response) ... {\n"
"    User user = (User) session.getAttribute(\"user\");\n"
"    Integer workId = Integer.parseInt(request.getParameter(\"workId\"));\n"
"    Double scoreValue = Double.parseDouble(request.getParameter(\"score\"));\n"
"    Work work = workDAO.findById(workId);\n"
"    if (!isSubmittedOrScored(work) || !isCompetitionRunning(work)) { ...; return; }\n"
"    Score score = new Score(); score.setWorkId(workId); score.setJudgeId(user.getUserId()); score.setScore(scoreValue);\n"
"    boolean success = scoreService.addScore(score);\n"
"    if (success) response.sendRedirect(...+\"/score?action=list&competitionId=\"+competitionId);\n"
"    else { request.setAttribute(\"error\", \"评分失败：分数范围0-100或已评分\"); ... }\n"
"}"
                ),
                "view": (
"<!-- score_input.jsp 评分表单（滑块 + 数字输入双模式，节选） -->\n"
"<form action=\"${pageContext.request.contextPath}/score\" method=\"post\" onsubmit=\"return validateScore()\">\n"
"  <input type=\"hidden\" name=\"action\" value=\"<%= hasScored ? \"update\" : \"submit\" %>\">\n"
"  <input type=\"hidden\" name=\"workId\" value=\"<%= targetWork.getWorkId() %>\">\n"
"  <label class=\"form-label fw-bold\">评分（0-100分）</label>\n"
"  <input type=\"range\" class=\"score-slider\" id=\"scoreSlider\" name=\"score\" min=\"0\" max=\"100\" step=\"0.5\"\n"
"         value=\"50\" oninput=\"updateScoreDisplay(this.value)\">\n"
"  <input type=\"number\" class=\"form-control\" id=\"scoreInput\" min=\"0\" max=\"100\" step=\"0.5\"\n"
"         oninput=\"syncSlider(this.value)\">\n"
"  <button type=\"submit\" class=\"btn btn-primary\">提交评分</button>\n"
"</form>\n"
"<script>\n"
"function validateScore(){ var s=document.getElementById('scoreSlider').value; if(s<0||s>100){alert('分数必须在0-100之间');return false;} return true; }\n"
"</script>"
                ),
                "sql": (
"INSERT INTO score (work_id, judge_id, score) VALUES (?, ?, ?);\n"
"-- 双重防重：数据库 UNIQUE(work_id, judge_id)\n"
"SELECT AVG(score) FROM score WHERE work_id = ?;"
                ),
                "effect": "评委在评分工作台按竞赛查看待评作品，滑块与数字输入框实时同步；"
                          "提交后作品状态推进为已评分，重复评分被 Service 与数据库约束双重拦截。",
            },
            {
                "title": "1.5.2 获奖设置与电子奖状",
                "desc": "管理员为已结束竞赛（status=3）中已提交且有评分记录的作品设置获奖等级（一/二/三等奖）"
                        "与最终得分，系统插入获奖记录的同时自动生成唯一编号 CERT-YYYYMMDD-XXXX 的电子奖状；"
                        "certificate_view.jsp 以复古证书样式展示并可打印/下载。",
                "model": (
"// AwardServiceImpl.setAward —— 等级/必填/防重校验 + 自动生成奖状\n"
"public boolean setAward(Award award) {\n"
"    if (award.getAwardLevel() == null || award.getAwardLevel().trim().isEmpty()) return false;\n"
"    String level = award.getAwardLevel().trim();\n"
"    if (!level.equals(\"一等奖\") && !level.equals(\"二等奖\") && !level.equals(\"三等奖\")) return false;\n"
"    if (award.getCompetitionId() == null || award.getWorkId() == null\n"
"            || award.getFinalScore() == null || award.getIssuerId() == null) return false;\n"
"    if (award.getFinalScore() < 0 || award.getFinalScore() > 100) return false;\n"
"    Work work = workDAO.findById(award.getWorkId());\n"
"    Competition competition = competitionDAO.findById(award.getCompetitionId());\n"
"    List<Score> scores = scoreDAO.findByWorkId(award.getWorkId());\n"
"    if (!AwardEligibilityPolicy.isEligible(competition, work, !scores.isEmpty())) return false; // 须已结束+已评分\n"
"    if (awardDAO.findByWorkId(award.getWorkId()) != null) return false; // 一个作品只能获奖一次\n"
"    boolean success = awardDAO.insert(award) > 0;\n"
"    if (success && !generateCertificate(award.getAwardId())) { awardDAO.deleteById(award.getAwardId()); return false; }\n"
"    return success;\n"
"}\n\n"
"// generateCertificate —— 唯一编号 CERT-YYYYMMDD-XXXX\n"
"String dateStr = LocalDateTime.now().format(DateTimeFormatter.ofPattern(\"yyyyMMdd\"));\n"
"String uniqueId = UUID.randomUUID().toString().substring(0, 8).toUpperCase();\n"
"String certificateNo = \"CERT-\" + dateStr + \"-\" + uniqueId;\n"
"Certificate certificate = new Certificate();\n"
"certificate.setAwardId(awardId); certificate.setCertificateNo(certificateNo);\n"
"certificate.setFilePath(\"/certificate?action=view&awardId=\" + awardId);\n"
"return certificateDAO.insert(certificate) > 0;"
                ),
                "test": (
"AwardService awardService = new AwardServiceImpl();\n"
"Award award = new Award(); award.setCompetitionId(2); award.setWorkId(10);\n"
"award.setAwardLevel(\"一等奖\"); award.setFinalScore(95.5); award.setIssuerId(1);\n"
"assertTrue(awardService.setAward(award));  // 成功且自动生成奖状\n"
"Award dup = new Award(); dup.setCompetitionId(2); dup.setWorkId(10); dup.setAwardLevel(\"二等奖\");\n"
"assertFalse(awardService.setAward(dup));   // 重复获奖被拒\n"
"Certificate cert = certService.getCertificateByAwardId(award.getAwardId());\n"
"assertTrue(cert.getCertificateNo().matches(\"CERT-\\\\d{8}-[0-9A-F]{8}\"));"
                ),
                "ctrl": (
"// AwardServlet.setAward —— 仅管理员可操作\n"
"private void setAward(HttpServletRequest request, HttpServletResponse response) ... {\n"
"    if (session == null || session.getAttribute(\"user\") == null) { response.sendRedirect(...+\"/login\"); return; }\n"
"    if (!isAdmin(request)) { response.sendRedirect(...+\"/index\"); return; }\n"
"    User user = (User) session.getAttribute(\"user\");\n"
"    Integer competitionId = Integer.parseInt(request.getParameter(\"competitionId\"));\n"
"    Integer workId = Integer.parseInt(request.getParameter(\"workId\"));\n"
"    String awardLevel = request.getParameter(\"awardLevel\");\n"
"    Double finalScore = Double.parseDouble(request.getParameter(\"finalScore\"));\n"
"    Award award = new Award(); award.setCompetitionId(competitionId); award.setWorkId(workId);\n"
"    award.setAwardLevel(awardLevel); award.setFinalScore(finalScore); award.setIssuerId(user.getUserId());\n"
"    boolean success = awardService.setAward(award);\n"
"    request.getSession().setAttribute(success ? \"message\" : \"error\", success ? \"获奖设置成功！奖状已自动生成。\" : \"获奖设置失败\");\n"
"    response.sendRedirect(...+\"/award?action=manage&competitionId=\" + competitionId);\n"
"}"
                ),
                "view": (
"<!-- award_manage.jsp 设置获奖 Modal（节选） -->\n"
"<form method=\"post\" action=\"${pageContext.request.contextPath}/award\">\n"
"  <input type=\"hidden\" name=\"action\" value=\"set\">\n"
"  <input type=\"hidden\" name=\"competitionId\" value=\"${selectedCompetition.competitionId}\">\n"
"  <input type=\"hidden\" name=\"workId\" value=\"${w.workId}\">\n"
"  <select class=\"form-select\" name=\"awardLevel\" required>\n"
"    <option value=\"\">请选择获奖等级</option>\n"
"    <option value=\"一等奖\">一等奖</option><option value=\"二等奖\">二等奖</option><option value=\"三等奖\">三等奖</option>\n"
"  </select>\n"
"  <input type=\"number\" class=\"form-control\" name=\"finalScore\" step=\"0.1\" min=\"0\" max=\"100\" required>\n"
"  <button type=\"submit\" class=\"btn btn-primary\">确认设置</button>\n"
"</form>\n\n"
"<!-- certificate_view.jsp 复古证书（节选） -->\n"
"<div class=\"certificate-container\">\n"
"  <div class=\"cert-header\"><div class=\"cert-title\">获 奖 证 书</div></div>\n"
"  <div class=\"recipient\"><strong>${team.teamName}</strong>（队长：${leader.realName}）</div>\n"
"  <div>作品《${work.title}》荣获 <span class=\"award-level\">${award.awardLevel}</span></div>\n"
"  <div>最终得分：${award.finalScore} 分</div>\n"
"  <div class=\"cert-no\">证书编号：${certificate.certificateNo}</div>\n"
"</div>"
                ),
                "sql": (
"INSERT INTO award (competition_id, work_id, award_level, final_score, issuer_id) VALUES (?, ?, ?, ?, ?);\n"
"INSERT INTO certificate (award_id, certificate_no, file_path) VALUES (?, ?, ?);\n"
"SELECT * FROM award WHERE work_id = ?;  -- 防重复获奖"
                ),
                "effect": "管理员在获奖管理页按竞赛筛选作品、设置等级与最终得分，系统同步生成带唯一编号的"
                          "电子奖状；奖状页以复古证书样式呈现，支持打印与下载。",
                "shot": r"C:/Users/31815/IdeaProjects/task1/docs/verify-award-list.png",
                "shot_w": 5.4,
                "shot_caption": "图 往届获奖名单运行效果",
            },
        ],
    },
]
