# 大学生海报设计竞赛系统

> Web课程设计项目 - 5人团队协作文档  
> 项目启动时间：2026年7月4日  
> 截止时间：2026年7月19日 23:30

---

## 项目概述

### 项目目标
开发一套完整的线上竞赛管理系统，实现竞赛发布、报名、作品提交、评审、获奖公布的全流程数字化管理。

### 技术栈
- **前端**：JSP + JavaScript + Bootstrap
- **后端**：Servlet + JSP
- **数据库**：MySQL 8.0
- **服务器**：Apache Tomcat 9.0（使用Java EE规范）
- **架构模式**：MVC分层架构

### 系统角色
1. 管理员：发布竞赛、设置获奖、发布新闻、数据统计
2. 评委：查看作品、评分、添加评语
3. 队长：创建队伍、邀请队员、提交作品、查看奖状
4. 队员：注册登录、接受邀请、查看作品、点赞分享

---

## 项目进展记录

### 2026-07-04

**已完成：数据库设计与脚本编写（完成人：洪振博）**
- 完成17张数据表结构设计
- 编写完整SQL脚本：`database/schema.sql`
- 数据库可直接运行创建使用

**已完成：完整MVC框架搭建（完成人：洪振博）**
- ✅ Maven依赖配置完成（MySQL驱动、JSTL、文件上传、JSON处理）
- ✅ Model层：17个实体类（对应17张数据表）
- ✅ DAO层：32个文件（16个接口 + 16个实现类）
- ✅ Service层：14个文件（7个接口 + 7个实现类）
- ✅ Controller层：12个Servlet（覆盖所有功能模块）
- ✅ 工具类：DBUtil、PasswordUtil、EncodingFilter
- ✅ 项目清理：删除系统示例文件（HelloServlet、index.jsp等）
- **框架状态：** 100%完备，78个Java文件，可直接开始业务开发

### 2026-07-05

**已完成：模块1-用户认证模块（完成人：程建锋）**
- ✅ Controller层：LoginServlet、RegisterServlet、ProfileServlet、IndexServlet完善
- ✅ DAO层：UserDAOImpl、RoleDAOImpl、UserRoleDAOImpl实现（使用PreparedStatement防SQL注入）
- ✅ Service层：UserServiceImpl完善（密码加密、登录验证、角色分配）
- ✅ Filter层：AuthFilter权限过滤器（Session验证、公开资源白名单）
- ✅ 前端页面：login.jsp、register.jsp、profile.jsp、index.jsp
- ✅ 安全特性：密码加密存储、SQL注入防护、权限控制
- **代码量：** 16个文件，+1109行，-48行
- **提交ID：** c4d5313

### 2026-07-06

**已完成：注册功能修复与页面优化（完成人：程建锋）**
- ✅ 修复 POST /register 挂起问题：恢复 RegisterServlet 正式注册逻辑，完善参数 trim 处理和错误反馈
- ✅ 注册页面全新设计（register.jsp）：左右分栏布局、动态渐变背景、Bootstrap Icons 图标、密码强度实时检测、确认密码校验、响应式适配
- ✅ EncodingFilter 注释更新，避免双重注册说明
- ✅ 数据库清理：删除15个调试产生的测试账号（ID 8-22），删除用户 jdff（236319889@qq.com）
- **服务器环境：** Jetty 9.4.58 + Java 21，运行端口 8080

⚠️ **待优化项：**
- 前端XSS防护：需将JSP中的`<%= %>`改为`<c:out>`标签
- Git提交规范：需使用`feat: 功能描述`格式

**已完成：Tomcat 9.0适配（完成人：洪振博）**
- ✅ pom.xml：Servlet API依赖（jakarta → javax）
- ✅ pom.xml：JSTL依赖（jakarta → javax）
- ✅ web.xml：命名空间（Jakarta EE 6.0 → Java EE 4.0）
- ✅ 批量修改：16个Java文件的import语句（48处 jakarta → javax）
- **原因：** 团队统一使用Tomcat 9.0，需适配Java EE规范
- **修改范围：** 14个Controller + 2个Filter

**已完成：模块2-竞赛管理模块（完成人：洪振博）**
- ✅ DAO层：CompetitionDAOImpl、CategoryDAOImpl完整实现（8+6个方法，PreparedStatement防SQL注入）
- ✅ Service层：CompetitionServiceImpl业务逻辑（8个方法，输入验证、默认值设置）
- ✅ Controller层：CompetitionServlet请求处理（支持list/detail/add/edit/create/update/delete）
- ✅ 前端页面：4个JSP页面（competition_list.jsp, competition_add.jsp, competition_edit.jsp, competition_detail.jsp）
- ✅ 数据库：初始数据脚本（init_data.sql，包含角色和测试账号）
- ✅ 核心功能：竞赛列表查询、竞赛发布、竞赛详情、竞赛编辑、竞赛删除
- ✅ 安全特性：SQL注入防护、输入验证、状态管理
- **代码量：** 8个文件，约1200行代码
- **测试状态：** 已测试，功能正常

**已完成：模块3-队伍管理模块-创建队伍功能（完成人：杨祥博）**
- ✅ Model层：Team模型完善（新增teamDesc字段，匹配数据库schema）
- ✅ DAO层：TeamDAOImpl完整实现（9个方法，使用PreparedStatement防SQL注入）
- ✅ DAO层：TeamMemberDAOImpl完整实现（8个方法，is_leader与role字段映射）
- ✅ Service层：TeamServiceImpl完整实现（9个方法：创建队伍+自动添加队长到team_member、更新/解散队伍(队长验证)、邀请队员(人数检查)、移除队员、报名竞赛）
- ✅ Controller层：TeamServlet完整实现（GET: create/detail/myTeams; POST: create/update/delete/invite/remove）
- ✅ 详情页增强：加载队员列表(含头像首字母、队长标识)、竞赛名称、子类名称、队长姓名（不再显示裸ID）
- ✅ 前端升级：重写3个JSP页面，引入Font Awesome图标库，自定义配色方案，全面提升视觉品质
  - team_create.jsp：步骤指示器 + 竞赛卡片选择(带hover动画和选中态) + 字数统计 + 组队贴士
  - team_list.jsp：统计概览栏(队伍数/活跃数/总人数) + 彩色封面卡片 + 成员头像叠层 + 搜索过滤 + 空状态插画
  - team_detail.jsp：渐变封面横幅 + Tab切换(概览/成员/作品) + 成员头像网格(队长皇冠标识) + 彩色操作按钮 + 步骤引导
- ✅ 首页集成：index.jsp中"队伍管理"卡片添加跳转链接
- ✅ 安全特性：Session登录验证、队长权限校验、SQL注入防护、输入验证
- **代码量：** 9个文件（4个Java + 3个JSP + 1个Model修改 + 1个首页修改），约1700行代码
- **设计参考：** 赛氪/阿里云天池等竞赛平台UI风格，Bootstrap 5 + Font Awesome + CSS自定义变量

### 2026-07-06

**已完成：模块5-新闻发布功能（完成人：队员C）**
- ✅ Model层：修正News、Score、Comment、Award、Certificate共5个实体类字段，与数据库schema完全对齐
  - News: publisherId→authorId, 新增competitionId, 移除updateTime
  - Score: score字段 Integer→Double（匹配DB DECIMAL(5,2)）
  - Comment: content→commentText（匹配DB comment_text）
  - Award: 新增finalScore、issuerId字段
  - Certificate: 移除teamId, certificatePath→filePath
- ✅ DAO层：NewsDAOImpl完整实现（8个方法：insert/deleteById/update/findById/findByStatus/findByPublisherId/findAll/count，使用PreparedStatement防SQL注入）
- ✅ Service层：NewsServiceImpl完整实现（6个方法：publishNews/updateNews/deleteNews/getNewsById/getPublishedNews/getAllNews，含输入验证）
- ✅ Controller层：NewsServlet完整实现
  - GET: list（新闻列表）、detail（新闻详情）、publish（发布页）、edit（编辑页）、manage（管理页）
  - POST: publish（发布）、update（更新）、delete（删除）
  - Session登录集成，获取当前用户作为发布者
- ✅ 前端页面：5个JSP页面
  - news_list.jsp：渐变标题栏 + 新闻卡片列表 + hover动画 + 空状态插画
  - news_detail.jsp：详情展示 + 关联竞赛信息 + 状态标签 + 管理操作入口
  - news_add.jsp：发布表单（标题/关联竞赛ID/内容）
  - news_edit.jsp：编辑表单 + 状态切换（已发布/已撤回）
  - news_manage.jsp：管理表格（ID/标题/状态/竞赛ID/发布时间/操作按钮）+ 删除确认弹窗
- ✅ 首页集成：index.jsp中"新闻公告"卡片添加跳转链接
- ✅ 权限控制：AuthFilter添加/news路径为公开资源（新闻列表和详情无需登录即可查看）
- ✅ 安全特性：SQL注入防护、输入验证、Session登录验证
- **代码量：** 14个文件（5个Model修改 + 3个Java + 5个JSP + 1个Filter修改），+491行，-91行
- **编译状态：** BUILD SUCCESS，83个Java源文件零错误

**已完成：首页角色差异化显示功能（完成人：洪振博）**
- ✅ 前端页面：index.jsp重大改造，实现基于用户角色的差异化内容展示
- ✅ 角色检测：从Session获取用户角色列表，检测管理员和评委身份
- ✅ 管理员视图：统计面板（竞赛数/队伍数/作品数/用户数）+ 管理功能卡片（竞赛管理/用户管理/新闻管理/数据统计）
- ✅ 评委视图：评分工作台 + 待评作品列表 + 评分记录查询
- ✅ 队员视图：竞赛卡片列表 + 悬停动画 + 快速报名入口
- ✅ 导航栏优化：基于角色的下拉菜单（管理员/评委/队员看到不同选项）
- ✅ Controller层：IndexServlet新增CompetitionService，加载竞赛列表数据
- **修改文件：** 2个文件（index.jsp + IndexServlet.java）
- **代码变更：** 约+150行
- **用户体验：** 不同角色登录后看到符合其职责的专属首页

**已完成：竞赛详情页参赛状态动态显示（完成人：洪振博）**
- ✅ 前端页面：competition_detail.jsp新增参赛状态区域
- ✅ Controller层：CompetitionServlet添加TeamService，检测用户是否已参加当前竞赛
- ✅ 未登录状态：显示登录提示 + "立即登录"按钮
- ✅ 已参加状态：显示"✓ 您已参加此竞赛" + 队伍名称 + "查看队伍"和"管理作品"按钮
- ✅ 未参加状态：显示"参加此竞赛"提示 + "创建队伍"和"加入队伍"按钮
- ✅ 业务逻辑：查询用户作为队长的所有队伍，判断是否有队伍参加当前竞赛
- **修改文件：** 2个文件（competition_detail.jsp + CompetitionServlet.java）
- **代码变更：** 约+30行
- **用户体验：** 根据参赛状态显示不同操作选项，引导用户完成报名流程

**已完成：竞赛详情页权限控制优化（完成人：洪振博）**
- ✅ 前端页面：competition_detail.jsp权限控制增强
- ✅ 权限检查：新增管理员角色检测逻辑（isAdmin变量）
- ✅ 按钮控制：编辑竞赛和删除竞赛按钮仅对管理员可见
- ✅ 导入优化：新增Role和List导入以支持角色检查
- ✅ 安全特性：基于角色的访问控制（RBAC），防止普通用户访问管理功能
- **修改文件：** 1个JSP文件
- **代码变更：** +18行，-3行
- **问题修复：** 解决普通用户可见竞赛管理按钮的权限漏洞

**已完成：模块4-作品管理模块-完整功能（完成人：田继青）**
- ✅ Model层：Work、WorkFile、WorkLike、WorkShare四个实体类字段确认（与数据库schema对齐）
- ✅ DAO层：WorkDAOImpl完整实现（8个方法：insert/deleteById/update/findById/findAll/findByTeamId/findByCompetitionId/findByStatus/count/findByTeamIdAndCompetitionId/countByCompetitionId，使用PreparedStatement防SQL注入）
- ✅ DAO层：WorkFileDAOImpl完整实现（6个方法：insert/deleteById/deleteByWorkId/update/findById/findByWorkId/findAll）
- ✅ DAO层：WorkLikeDAOImpl完整实现（7个方法：insert/deleteById/deleteByWorkIdAndUserId/findByWorkId/findByUserId/isLiked/countByWorkId）
- ✅ DAO层：WorkShareDAOImpl完整实现（5个方法：insert/deleteById/findByWorkId/findByUserId/countByWorkId/findAll）
- ✅ Service层：WorkServiceImpl完整实现（11个方法：submitWork/updateWork/deleteWork/getWorkById/getWorksByTeamId/getWorksByCompetitionId/getWorksByUserId/likeWork/unlikeWork/shareWork/getLikeCount/isWorkLikedByUser，含输入验证和业务校验）
- ✅ Controller层：WorkServlet完整实现
  - GET: myWorks（我的作品列表）、add（提交页）、edit（编辑页）、detail（详情页）、delete（删除）
  - POST: submit（提交）、update（更新）、delete（删除）、like（点赞）、unlike（取消点赞）
  - Session登录集成，队长权限校验（仅队长可删改），截止日期后禁用删除
- ✅ Controller层：FileUploadServlet（通用JSON接口上传图片，校验文件类型/大小/扩展名）
- ✅ 工具类：FileUploadUtil（文件类型校验JPG/PNG、大小限制10MB、唯一文件名生成、按竞赛目录分组存储、文件删除）
- ✅ 前端页面：3个JSP页面
  - submission_add.jsp：双模合一（新建/编辑共用），图片拖拽上传+预览、缩略图占位、字数实时统计（500字上限）、截止日期提示、表单前端校验
  - submission_list.jsp：统计概览栏（总作品数/已提交/草稿）+ 封面卡片网格（缩略图/标题/队伍/竞赛/时间/状态标签）+ 图片预览弹窗（Bootstrap Modal）+ 空状态引导（创建队伍/提交作品）
  - submission_detail.jsp：左右分栏布局（大图展示+信息面板）、队伍/竞赛/提交时间/更新时间信息、大图新窗口打开
- ✅ 首页集成：index.jsp导航栏添加“我的作品”链接
- ✅ 核心功能：作品提交、作品修改、作品删除（含截止日期后禁用）、作品详情查看、作品列表查看、作品图片上传、作品点赞/取消点赞、作品分享记录
- ✅ 安全特性：PreparedStatement防SQL注入、文件类型/大小/扩展名三重校验、队长权限校验、截止日期后禁用删除、Session登录验证
- **代码量：** 12个文件（4个DAO实现 + 1个Service接口 + 1个Service实现 + 2个Controller + 1个工具类 + 3个JSP），约1500行代码
- **编译状态：** 编译通过

**已完成：模块3-队伍管理模块-邀请报名编辑功能（完成人：杨祥博）**
- ✅ DAO层：InvitationDAOImpl全部8个方法完整实现（参考TeamMemberDAOImpl模式，JDBC+PreparedStatement）
- ✅ DAO层：UserDAO/UserDAOImpl新增searchByRealName模糊搜索方法（LIKE %keyword% LIMIT 20）
- ✅ Service层：新建InvitationService/InvitationServiceImpl（acceptInvitation：校验→人数检查→插入TeamMember→更新邀请状态；rejectInvitation：校验→更新状态为已拒绝；getInvitationsForUser）
- ✅ Controller层：InvitationServlet完整实现（doGet邀请列表+关联数据加载；doPost accept/reject操作）
- ✅ Controller层：TeamServlet新增registerCompetition（报名参赛，队长验证，status 1→2）和searchUserForInvite（JSON返回用户搜索）方法，inviteMember支持ajax=true参数返回JSON
- ✅ 前端页面：新建invitation_list.jsp（待处理/已处理Tab切换、接受拒绝按钮+确认弹窗、队伍名/邀请人姓名显示、空状态引导）
- ✅ 前端页面：team_detail.jsp重大改造（三个操作按钮全部启用+移除"即将开放"标签）：
  - 编辑队伍信息 → Bootstrap Modal表单（预填队伍名/竞赛/子类/简介，POST更新）
  - 邀请队员 → Bootstrap Modal（搜索用户姓名模糊匹配 → AJAX获取结果 → 点击邀请 → Toast通知）
  - 报名参赛 → 仅status=1时可用 → POST注册 → status变为2 → 按钮变灰显示"已报名参赛"
- ✅ 前端页面：index.jsp添加"邀请通知"功能卡片入口
- ✅ 前端页面：team_list.jsp导航栏添加"邀请通知"链接
- ✅ 前端页面：team_detail.jsp导航栏添加"邀请通知"链接、预加载竞赛/子类列表供编辑弹窗使用
- ✅ 修复：team_create.jsp子类下拉框空列表判断bug（!= null → && !isEmpty()）、竞赛子类option添加data-comp-id实现切换竞赛过滤
- ✅ 修复：competition_add.jsp新增竞赛子类动态输入区域（可增删行，至少一个，校验）
- ✅ 修复：competition_edit.jsp已有子类展示+逐个删除+新子类动态添加
- ✅ 修复：CompetitionServlet同步处理子类数据增删，新增saveCategories辅助方法
- ✅ 数据库脚本：init_data.sql和data.sql新增竞赛和子类初始数据
- **代码量：** 11个文件（3个新建 + 6个修改 + 2个SQL补充），约1800行代码
- **编译状态：** BUILD SUCCESS，85个Java源文件零错误

### 2026-07-07

**已完成：模块5-评委评分功能（完成人：队员C）**
- ✅ DAO层：ScoreDAOImpl完整实现（8个方法：insert/deleteById/update/findById/findByWorkId/findByJudgeId/getAverageScoreByWorkId/findAll，使用PreparedStatement防SQL注入）
- ✅ Service层：ScoreServiceImpl完整实现（6个方法：addScore/updateScore/getScoresByWorkId/getScoresByJudgeId/getAverageScore/hasScored，含评分范围验证0-100、重复评分检查）
- ✅ Controller层：ScoreServlet完整实现
  - GET: list（评分工作台展示待评作品）、input（指定作品评分输入）、myScores（我的评分记录）、workScores（作品评分详情）
  - POST: submit（提交评分）、update（更新评分）
  - Session登录集成，评委权限校验，重复评分防重（UNIQUE约束+Service层双重检查）
- ✅ 前端页面：2个JSP页面
  - score_input.jsp：统计概览栏（待评作品数/已评数/未评数）+ 作品卡片列表（已评/未评状态标签 + 点击进入评分）+ 评分表单（滑块+数字输入双模式、实时分数显示、已评分提示与修改入口）+ 空状态引导
  - score_list.jsp：双视图合一 —「我的评分记录」视图（作品名/队伍/评分/时间/操作）+「作品评分详情」视图（平均分圆形徽章/最高分/最低分统计卡片 + 评分列表）
- ✅ 安全特性：PreparedStatement防SQL注入、评分范围验证（0-100）、重复评分防重、Session登录验证
- **代码量：** 5个文件（1个DAO实现修改 + 1个Service实现修改 + 1个Controller修改 + 2个JSP新建），约650行代码
- **编译状态：** BUILD SUCCESS，86个Java源文件零错误

---

## 团队组织结构

### 分工模式：垂直功能模块分工

> **重要说明：** 采用垂直分工方式，每个人负责一个完整的功能模块（前端+后端+数据库），确保每个人都能独立开发和测试自己的模块，降低集成风险。

### 模块分工详情

**模块1：用户认证模块（队长负责）**
- **功能范围：** 用户注册、登录、权限验证、个人信息管理
- **前端页面：** login.jsp, register.jsp, profile.jsp
- **后端代码：** LoginServlet, RegisterServlet, LogoutServlet, UserService
- **数据访问：** UserDAO, RoleDAO
- **涉及数据表：** user, role, user_role（3张表）
- **附加职责：** 项目整体协调、进度管理、代码审查、会议记录

**模块2：竞赛管理模块（副队长负责）**
- **功能范围：** 竞赛发布、修改、查询、子类管理
- **前端页面：** competition_list.jsp, competition_add.jsp, competition_edit.jsp, competition_detail.jsp
- **后端代码：** CompetitionServlet, CompetitionService, CategoryService
- **数据访问：** CompetitionDAO, CategoryDAO
- **涉及数据表：** competition, competition_category（2张表）
- **附加职责：** 技术架构设计、基础工具类开发、项目实现报告

**模块3：队伍管理模块（杨祥博负责）**
- **功能范围：** 创建队伍、邀请队员、接受/拒绝邀请、队伍报名、成员管理
- **前端页面：** team_create.jsp, team_manage.jsp, team_member.jsp, invitation_list.jsp
- **后端代码：** TeamServlet, InvitationServlet, TeamService
- **数据访问：** TeamDAO, TeamMemberDAO, InvitationDAO
- **涉及数据表：** team, team_member, invitation（3张表）
- **附加职责：** 前端样式统一、UI/UX优化

**模块4：作品管理模块（队员B负责）**
- **功能范围：** 作品提交、修改、删除、展示、文件上传、点赞、分享
- **前端页面：** work_submit.jsp, work_list.jsp, work_detail.jsp, work_edit.jsp
- **后端代码：** WorkServlet, WorkService, FileUploadServlet
- **数据访问：** WorkDAO, WorkFileDAO, WorkLikeDAO, WorkShareDAO
- **涉及数据表：** work, work_file, work_like, work_share（4张表）
- **附加职责：** 文件上传功能实现、图片处理工具类

**模块5：评分与获奖模块（队员C负责）**
- **功能范围：** 评委评分、评语管理、获奖设置、奖状生成、新闻发布
- **前端页面：** score_input.jsp, score_list.jsp, award_manage.jsp, certificate_view.jsp, news_list.jsp
- **后端代码：** ScoreServlet, AwardServlet, CertificateServlet, NewsServlet, ScoreService
- **数据访问：** ScoreDAO, CommentDAO, AwardDAO, CertificateDAO, NewsDAO
- **涉及数据表：** score, comment, award, certificate, news（5张表）
- **附加职责：** 系统集成测试、功能验证、Bug修复

---

## 开发规范

### 代码规范

**命名约定**
```java

// 类名：大驼峰命名
public class UserService { }

// 方法名：小驼峰命名
public void createUser() { }

// 变量名：小驼峰命名
private String userName;

// 常量：全大写+下划线
public static final int MAX_TEAM_SIZE = 5;

// 数据库表名：小写+下划线
user_role, competition_category
```

**包结构规范**
```
src/
├── com.poster.controller/    # Servlet控制器
├── com.poster.service/        # 业务逻辑层
├── com.poster.dao/            # 数据访问层
├── com.poster.model/          # 实体类
├── com.poster.util/           # 工具类
└── com.poster.filter/         # 过滤器
```

**注释规范**
```java
/**
 * 用户服务类
 * @author 队员姓名
 * @date 2026-07-04
 */
public class UserService {
    /**
     * 创建新用户
     * @param user 用户对象
     * @return 是否创建成功
     */
    public boolean createUser(User user) {
        // 实现代码
    }
}
```

### Git协作规范

**分支策略**
```
main          # 主分支，稳定版本
├── dev       # 开发分支，日常开发
├── feature/xxx  # 功能分支
└── hotfix/xxx   # 紧急修复分支
```

**提交信息规范**
```
feat: 添加用户注册功能
fix: 修复评分提交失败的bug
docs: 更新数据库设计文档
style: 调整登录页面样式
refactor: 重构队伍管理模块
test: 添加作品提交测试用例
```

**协作流程**
1. 从dev分支创建功能分支
2. 完成开发后提交到功能分支
3. 发起Pull Request到dev分支
4. 至少1人代码审查通过后合并
5. 测试通过后合并到main分支

---

## 开发计划

### 第一阶段（7月4-7日）：基础架构共建
> **重要：** 本阶段所有人协作完成基础架构，确保每个人都能独立开发和测试

- [x] 完成需求分析
- [x] 完成数据库设计
- [x] 添加Maven依赖（MySQL、JSTL、文件上传、JSON等）
- [x] 创建所有实体类（17个Model类）
- [x] 创建数据库工具类（DBUtil）
- [x] 创建基础工具类（PasswordUtil、FileUtil、DateUtil）
- [x] 创建基础过滤器（EncodingFilter）
- [x] 创建完整MVC三层架构（DAO、Service、Controller）
- [ ] 统一开发环境（数据库、Tomcat配置）
- [ ] 完成项目设计报告

**第一阶段完成情况（2026-07-04更新）：**
- ✅ 7月4日：数据库设计完成（洪振博）
- ✅ 7月4日：完整MVC框架搭建完成（洪振博）
  - Model层（17个实体类）
  - DAO层（32个文件：16接口+16实现）
  - Service层（14个文件：7接口+7实现）
  - Controller层（12个Servlet）
  - 工具类（DBUtil、PasswordUtil、EncodingFilter）
  - Maven依赖配置完成
- **下一步：** 各团队成员配置本地开发环境，开始模块开发

**第一阶段分工（所有人参与基础架构）：**
- **7月4日上午（集中会议）：** 统一开发环境、讨论技术规范
- **7月4日下午（结对编程）：**
  - 队长+副队长：添加Maven依赖、创建DBUtil
  - 杨祥博+队员B：创建实体类（User、Competition、Team、Work等）
  - 队员C：创建工具类（PasswordUtil、FileUtil）
- **7月5日（验证测试）：** 所有人本地测试数据库连接，创建自己的功能分支
- **7月6-7日（原型开发）：** 每个人开发自己模块的核心功能原型

### 第二阶段（7月8-11日）：核心功能并行开发
> **独立开发阶段：** 每个人在自己的功能分支上独立开发完整模块

**模块1 - 用户认证（队长：程建锋）：**
- [x] 用户注册功能（RegisterServlet + register.jsp）
- [x] 用户登录功能（LoginServlet + login.jsp）
- [x] 权限验证过滤器（AuthFilter）
- [x] 个人信息管理（ProfileServlet + profile.jsp）
- [x] Session管理和退出登录

**模块2 - 竞赛管理（副队长）：**
- [x] 竞赛列表查询（competition_list.jsp）
- [x] 竞赛发布功能（CompetitionServlet + competition_add.jsp）
- [x] 竞赛详情展示（competition_detail.jsp）
- [x] 竞赛修改功能（competition_edit.jsp）
- [x] 竞赛子类管理

**模块3 - 队伍管理（杨祥博）：**
- [x] 创建队伍功能（TeamServlet + team_create.jsp）
- [x] 邀请队员功能（TeamServiceImpl.inviteMember + 前端Modal搜索 + AJAX发送）
- [x] 队伍信息展示优化（team_detail.jsp 含 Tab 切换、成员头像网格、队长皇冠标识）
- [x] 队员移除功能（TeamServlet.removeMember + TeamServiceImpl.removeMember）
- [x] 队伍搜索功能（team_list.jsp 含前端搜索过滤）
- [x] 队伍统计概览（team_list.jsp 含创建数/活跃数/队员总数统计卡片）
- [x] 邀请列表前端（invitation_list.jsp 含待处理/已处理Tab）✅ 2026-07-06
- [x] 接受/拒绝邀请功能（InvitationServlet + InvitationService）✅ 2026-07-06
- [x] 队伍报名竞赛（team_detail.jsp前端按钮已启用，status 1→2）✅ 2026-07-06

**模块4 - 作品管理（队员B）：**
- [x] 作品提交功能（WorkServlet + submission_add.jsp）✅ 2026-07-06
- [x] 文件上传功能（FileUploadServlet + FileUploadUtil）✅ 2026-07-06
- [x] 作品列表展示（submission_list.jsp）✅ 2026-07-06
- [x] 作品详情页面（submission_detail.jsp）✅ 2026-07-06
- [x] 作品修改/删除功能 ✅ 2026-07-06

**模块5 - 评分与获奖（队员C）：**
- [x] 新闻发布功能（NewsServlet + news_list.jsp + news_detail.jsp + news_add.jsp + news_edit.jsp + news_manage.jsp）✅ 2026-07-06
- [x] Model层字段修复（News/Score/Comment/Award/Certificate与数据库对齐）✅ 2026-07-06
- [x] 评委评分功能（ScoreServlet + score_input.jsp）✅ 2026-07-07
- [x] 评分记录查询（score_list.jsp）✅ 2026-07-07
- [ ] 评语管理功能（comment功能）
- [ ] 获奖设置功能（AwardServlet + award_manage.jsp）

**每日集成：** 每天晚上10点，队长负责合并所有分支到dev分支

### 第三阶段（7月12-15日）：功能完善与优化
> **继续垂直开发：** 每个人在自己的模块内完善高级功能

**模块1 - 用户认证（队长：程建锋）：**
- [ ] 用户角色管理界面
- [ ] 密码修改功能
- [ ] 找回密码功能
- [ ] 用户状态管理（启用/禁用）
- [ ] 用户列表查询（管理员功能）

**模块2 - 竞赛管理（副队长）：**
- [ ] 竞赛状态管理（报名中/进行中/已结束）
- [ ] 竞赛统计功能（报名队伍数、作品数）
- [ ] 竞赛搜索和筛选
- [ ] 竞赛取消功能
- [ ] 数据报表生成

**模块3 - 队伍管理（杨祥博）：**
- [x] 队伍信息展示优化（team_detail.jsp已包含）
- [x] 队员移除功能（TeamServlet.removeMember）
- [ ] 取消报名功能
- [x] 队伍搜索功能（team_list.jsp 前端搜索过滤）
- [x] 队伍统计（我的队伍、我参与的队伍）
- [x] 编辑队伍信息功能（Modal弹窗 + 支持修改名称/竞赛/子类/简介）✅ 2026-07-06

**模块4 - 作品管理（队员B）：**
- [x] 作品点赞功能（work_like表）✅ 2026-07-06
- [x] 作品分享功能（work_share表）✅ 2026-07-06
- [ ] 作品搜索和筛选
- [ ] 作品统计（浏览量、点赞数）
- [x] 图片预览和下载 ✅ 2026-07-06

**模块5 - 评分与获奖（队员C）：**
- [ ] 电子奖状生成功能（CertificateServlet）
- [ ] 奖状查看和下载（certificate_view.jsp）
- [ ] 获奖公告发布
- [ ] 评分统计和排名
- [ ] 新闻管理（编辑、删除）

### 第四阶段（7月16-18日）：测试与优化
> **模块测试阶段：** 每个人测试自己的模块，然后进行集成测试

**各模块测试与优化：**
- **队长（用户认证模块）：** 测试注册、登录、权限验证、Session管理
- **副队长（竞赛管理模块）：** 测试竞赛发布、修改、查询、统计功能
- **杨祥博（队伍管理模块）：** 测试队伍创建、邀请、报名、成员管理
- **队员B（作品管理模块）：** 测试作品提交、文件上传、点赞、分享
- **队员C（评分与获奖模块）：** 测试评分、获奖设置、奖状生成、新闻发布

**集成测试（所有人）：**
- [ ] 完整流程测试（注册→报名→提交作品→评分→获奖）
- [ ] 跨模块功能测试
- [ ] 性能优化和Bug修复
- [ ] 界面美化和用户体验优化

**文档准备：**
- [ ] 副队长：完成项目实现报告
- [ ] 队长：制作演示视频（< 150MB）

### 第五阶段（7月19日）：答辩准备
> **最后冲刺：** 准备答辩材料，确保所有提交物完整

**所有人共同完成：**
- [ ] 准备答辩PPT（队长主导，所有人贡献）
- [ ] 项目演示练习（每个人演示自己的模块）
- [ ] 完成项目总结文档
- [ ] 检查所有提交材料（代码、文档、视频）
- [ ] 压缩源代码（< 100MB）
- [ ] 23:30前提交所有材料

**答辩分工：**
- 队长：项目介绍、技术架构、团队协作
- 副队长：数据库设计、系统实现
- 杨祥博/B/C：各自演示负责的功能模块

---

## 每日工作流程

### 晨会制度（每天10:00）
1. 每人汇报昨日完成情况
2. 每人说明今日工作计划
3. 提出遇到的问题和需要的协助
4. 队长分配任务和协调资源

### 会议记录格式
```markdown
# 团队编号-会议记录-X

**会议时间：** 2026-07-XX 10:00-10:30  
**会议地点：** 线上/教室  
**参会人员：** 队长、副队长、杨祥博、队员B、队员C  
**会议照片：** [照片链接]

## 昨日完成情况
- 队长：完成项目框架搭建
- 副队长：完成数据库脚本编写
- 杨祥博：完成登录页面
- 队员B：完成用户注册逻辑
- 队员C：编写测试用例10个

## 今日工作计划
- 队长：实现用户权限控制
- 副队长：优化数据库索引
- 杨祥博：开发竞赛列表页面
- 队员B：实现竞赛发布功能
- 队员C：测试用户模块

## 问题与讨论
- 问题1：文件上传大小限制设置为多少？
  - 决策：10MB
- 问题2：密码加密使用什么算法？
  - 决策：MD5+盐值

## 下次会议时间
2026-07-XX 10:00
```

---

## 技术要点

### 数据库连接配置
```java
public class DBUtil {
    private static final String URL = "jdbc:mysql://localhost:3306/poster_competition?useSSL=false&serverTimezone=UTC&characterEncoding=utf8";
    private static final String USER = "root";
    private static final String PASSWORD = "your_password";
    
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
```

### 密码加密
```java
public class PasswordUtil {
    public static String encrypt(String password) {
        // 使用MD5+盐值加密
        String salt = "poster_competition_2026";
        return MD5(password + salt);
    }
}
```

### 文件上传限制
```java
// web.xml配置
<multipart-config>
    <max-file-size>10485760</max-file-size>  <!-- 10MB -->
    <max-request-size>20971520</max-request-size>
</multipart-config>
```

### 权限过滤器
```java
@WebFilter("/*")
public class AuthFilter implements Filter {
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        
        // 判断用户权限
        if (user == null && !isPublicResource(req.getRequestURI())) {
            // 跳转到登录页
        }
        chain.doFilter(request, response);
    }
}
```

---

## 测试规范

### 功能测试清单

**用户管理模块**
- [ ] 用户注册（正常、重复用户名、非法输入）
- [ ] 用户登录（正常、错误密码、不存在用户）
- [ ] 修改个人信息
- [ ] 角色权限验证

**竞赛管理模块**
- [ ] 发布竞赛（完整信息、缺少字段）
- [ ] 修改竞赛信息
- [ ] 查询竞赛列表
- [ ] 竞赛状态管理

**队伍管理模块**
- [ ] 创建队伍（正常、重复名称）
- [ ] 邀请队员（系统内用户、不存在用户）
- [ ] 接受/拒绝邀请
- [ ] 移除队员
- [ ] 取消报名

**作品管理模块**
- [ ] 提交作品（支持格式、超大文件）
- [ ] 修改作品
- [ ] 删除作品
- [ ] 查看作品详情
- [ ] 作品点赞/分享

**评分系统**
- [ ] 评委评分（0-100分、重复评分）
- [ ] 添加评语
- [ ] 查看评分记录

**获奖管理**
- [ ] 设置获奖等级
- [ ] 生成电子奖状
- [ ] 下载奖状
- [ ] 发布获奖公告

---

## 提交物清单

### 文档要求

| 序号 | 文档名称 | 负责人 | 截止时间 | 状态 |
|------|----------|--------|----------|------|
| 1 | 会议记录 | 队长 | 每日 | 进行中 |
| 2 | 项目设计报告 | 全员 | 7月7日 | 待完成 |
| 3 | 项目实现报告 | 副队长 | 7月18日 | 待完成 |
| 4 | 演示视频 | 队长 | 7月18日 | 待完成 |
| 5 | 源代码 | 全员 | 7月18日 | 进行中 |
| 6 | 项目总结 | 全员 | 7月19日 | 待完成 |

### 文件命名规范
```
团队编号-会议记录-1.docx
团队编号-项目设计报告.docx
团队编号-项目实现报告.docx
团队编号-演示视频.mp4 (< 150MB)
团队编号-源代码.zip (< 100MB)
团队编号-总结.docx
```

---

## 常见问题FAQ

### Q1: 如何运行项目？
A: 
1. 导入MySQL数据库脚本
2. 修改DBUtil中的数据库连接信息
3. 部署到Tomcat服务器
4. 访问 http://localhost:8080/项目名

### Q2: 遇到编译错误怎么办？
A: 
1. 检查JDK版本（建议1.8+）
2. 检查Tomcat版本（建议10.0+）
3. 清理项目：Project -> Clean
4. 重新构建项目

### Q3: 数据库连接失败？
A:
1. 确认MySQL服务已启动
2. 检查数据库名、用户名、密码
3. 检查端口号（默认3306）
4. 确认JDBC驱动已添加到lib

### Q4: 文件上传失败？
A:
1. 检查文件大小（限制10MB）
2. 检查文件类型是否支持
3. 检查上传目录是否有写权限
4. 检查multipart-config配置

### Q5: 如何解决Git冲突？
A:
1. 先pull最新代码
2. 本地解决冲突
3. 测试通过后再push
4. 严重冲突联系队长协调

---

## 项目文件结构

```
poster-competition-system/
├── src/
│   └── com/
│       └── poster/
│           ├── controller/      # Servlet控制器
│           ├── service/         # 业务逻辑层
│           ├── dao/             # 数据访问层
│           ├── model/           # 实体类
│           ├── util/            # 工具类
│           └── filter/          # 过滤器
├── WebContent/
│   ├── WEB-INF/
│   │   ├── web.xml             # Web配置
│   │   └── lib/                # 依赖库
│   ├── jsp/                    # JSP页面
│   │   ├── admin/              # 管理员页面
│   │   ├── judge/              # 评委页面
│   │   ├── leader/             # 队长页面
│   │   └── member/             # 队员页面
│   ├── css/                    # 样式文件
│   ├── js/                     # JavaScript文件
│   ├── images/                 # 图片资源
│   └── uploads/                # 上传文件
├── database/
│   ├── schema.sql              # 数据库结构
│   └── data.sql                # 初始数据
└── docs/
    ├── 会议记录/
    ├── 设计报告/
    └── 实现报告/
```

---

## 联系方式

### 团队成员
- 队长：[姓名] - [QQ/微信] - [邮箱]
- 副队长：[姓名] - [QQ/微信] - [邮箱]
- 队员A：杨祥博 - [QQ/微信] - [邮箱]
- 队员B：[姓名] - [QQ/微信] - [邮箱]
- 队员C：[姓名] - [QQ/微信] - [邮箱]

### 紧急联系
如遇紧急问题或blocking issue，请立即在团队群通知队长和副队长。

---

**最后更新时间：** 2026年7月7日
**更新人：** 队员C
**版本：** v1.5
