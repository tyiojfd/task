﻿﻿ # 大学生海报设计竞赛系统

> Web课程设计项目 - 5人团队协作文档  
> 项目启动时间：2026年7月4日  
> 截止时间：2026年7月19日 23:30

---

## 项目概述

### 项目目标
开发一套完整的线上竞赛管理系统，实现竞赛发布、报名、作品提交、评审、获奖公布的全流程数字化管理。

### 技术栈
- **前端**：JSP + JavaScript + Bootstrap
- **Landing 进入页**：React 18 + Vite 5 + GSAP（独立 SPA）
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
- ✅ 数据库清理：删除15个调试[target](target)产生的测试账号（ID 8-22），删除用户 jdff（236319889@qq.com）
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

**已完成：模块5-新闻发布功能（完成人：葛至洲）**
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

**已完成：用户头像功能（完成人：杨祥博）**
- ✅ 数据库：user表新增avatar VARCHAR(500)字段（schema.sql）
- ✅ Model层：User.java新增avatar属性+getter/setter
- ✅ DAO层：UserDAOImpl的insert/update/extractUser全部加上avatar处理
- ✅ Service层：UserService.register()签名增加avatar参数，UserServiceImpl.register()写入avatar字段
- ✅ Controller层：RegisterServlet加@MultipartConfig注解（maxFileSize=10MB），处理可选头像上传（校验JPG/PNG、≤2MB），存储到uploads/avatars/
- ✅ Controller层：ProfileServlet加@MultipartConfig注解，新增uploadAvatar action（校验→保存→更新用户→删旧文件）
- ✅ 前端页面：register.jsp新增头像上传区（相机图标→选择文件→实时预览），form加enctype="multipart/form-data"
- ✅ 前端页面：profile.jsp显示真实头像或首字母回退+右下角相机按钮换头像+Font Awesome引入
- ✅ 前端页面：team_detail.jsp成员头像优先显示真实照片（mu.getAvatar()），无头像回退首字母
- ✅ 前端页面：team_list.jsp成员头像叠层优先显示真实照片，TeamServlet.listMyTeams传userAvatars数据
- ✅ 头像逻辑：全系统统一（有avatar路径→显示img，无→首字母渐变圆底），头像文件存储到/uploads/avatars/
- ✅ 注册角色修复：UserServiceImpl.register()中findByName("学生")→findByName("队员")，解决新用户注册后无角色分配的bug
- ⚠️ 数据库迁移：需执行 ALTER TABLE user ADD COLUMN avatar VARCHAR(500) DEFAULT NULL COMMENT '头像文件路径'; 否则注册功能报错
- **代码量：** 10个文件（1个Model + 1个DAO + 1个Service接口 + 1个Service实现 + 2个Controller + 2个JSP + 1个SQL + 1个列表页更新）
- **编译状态：** BUILD SUCCESS

**已完成：注册登录问题修复（完成人：杨祥博）**
- ✅ 问题定位：Jetty 9.4.58对@MultipartConfig的multipart/form-data请求处理不兼容，导致RegisterServlet中request.getParameter()返回null
- ✅ 修复方案：RegisterServlet去掉@MultipartConfig注解，回到普通Form提交（头像通过个人中心ProfileServlet上传）
- ✅ register.jsp：去掉enctype="multipart/form-data"和头像上传区，避免Jetty multipart兼容性问题
- ✅ 角色分配修复：UserServiceImpl.register()中findByName("学生")→findByName("队员")，数据库角色表只有「队员」无「学生」
- ✅ 模糊搜索增强：UserDAOImpl.searchByRealName()从只搜real_name改为同时搜real_name和username（LIKE %keyword% OR username LIKE %keyword%）
- ⚠️ 数据库迁移：必须执行 ALTER TABLE user ADD COLUMN avatar VARCHAR(500) DEFAULT NULL; 否则UserDAOImpl.insert()中avatar列不存在导致INSERT失败→注册失败
- ✅ 我的队伍修复：TeamServlet.listMyTeams()增加查询用户作为队员加入的队伍（teamMemberDAO.findByUserId），队伍卡片显示角色标签（队长/队员）
- ✅ 统计卡片更新：team_list.jsp统计改为4栏（全部/我创建的/我加入的/队员总数）
- ✅ 下一步引导：team_detail.jsp右侧"下一步做什么"根据队伍状态动态显示（组建中→报名→提交作品→等待评分）
- **编译状态：** BUILD SUCCESS

### 2026-07-07

**已完成：模块5-评委评分功能（完成人：葛至洲）**
- ✅ 背景：ScoreDAOImpl、ScoreServiceImpl、ScoreServlet 三个核心类仅有TODO骨架（15个空方法），无法支持评委评分业务流程
- ✅ DAO层：ScoreDAOImpl 从空壳补全为完整 JDBC 实现（共8个方法，使用 PreparedStatement 防 SQL 注入）
  - insert(Score)：INSERT INTO score，返回自增主键 score_id
  - deleteById(Integer)：DELETE FROM score WHERE score_id = ?
  - update(Score)：UPDATE score SET score=? WHERE score_id=?
  - findById(Integer)：SELECT * FROM score WHERE score_id = ?，含 ResultSet→Score 映射
  - findByWorkId(Integer)：SELECT * FROM score WHERE work_id = ? ORDER BY score_time DESC，返回某作品所有评分
  - findByJudgeId(Integer)：SELECT * FROM score WHERE judge_id = ? ORDER BY score_time DESC，返回评委所有评分
  - getAverageScoreByWorkId(Integer)：SELECT AVG(score) FROM score WHERE work_id = ?，返回作品平均分（无记录时返回0.0）
  - findAll()：SELECT * FROM score ORDER BY score_time DESC，全量查询
  - 新增私有辅助方法 extractScoreFromResultSet()：Timestamp→LocalDateTime 转换、null 安全处理
- ✅ Service层：ScoreServiceImpl 从空壳补全为完整业务逻辑（共6个方法）
  - addScore(Score)：三重校验 — ①评分范围 0-100 ②workId/judgeId 非空 ③hasScored() 防重检查 → 调用 DAO 插入
  - updateScore(Score)：校验评分范围+scoreId非空 → 调用 DAO 更新
  - getScoresByWorkId(Integer)：null 安全 → 委托 DAO
  - getScoresByJudgeId(Integer)：null 安全 → 委托 DAO
  - getAverageScore(Integer)：null 安全 → 委托 DAO
  - hasScored(Integer workId, Integer judgeId)：遍历 findByWorkId() 结果，逐一匹配 judgeId（利用 DB UNIQUE(work_id, judge_id) 约束做双层防重）
- ✅ Controller层：ScoreServlet 从空壳补全为完整请求处理（共6个私有方法 + doGet/doPost 路由）
  - doGet 路由：action=list（评分工作台）、input（指定作品评分）、myScores（我的评分记录）、workScores（作品评分详情）
  - doPost 路由：action=submit（提交评分）、update（更新评分），request.setCharacterEncoding("UTF-8") 防乱码
  - showScoringWorkspace()：获取全部已提交作品（status=2）+ 当前评委已有评分 → 前端区分「已评/未评」
  - showScoreInput()：加载目标作品+队伍信息+当前评委已有评分 → 支持「新评分」与「修改评分」双模式
  - showMyScores()：从 Session 获取当前用户 → 查询该评委所有评分 → 注入 workDAO+teamService 供前端展示作品名和队伍名
  - showWorkScores()：查询作品所有评分 + 平均分 + 作品/队伍信息
  - submitScore()：用户身份校验 → 参数解析 → new Score() → scoreService.addScore() → 成功跳转/失败回显错误
  - updateScore()：用户身份校验 → scoreId+score 参数解析 → scoreService.updateScore()
  - 引入 WorkDAO + TeamService 依赖，实现评分工作台展示作品名称、队伍信息、提交时间
- ✅ 前端页面：新建2个JSP页面（score_input.jsp, score_list.jsp，均采用 Bootstrap 5 + Font Awesome 6.4.0 + 自定义CSS变量配色方案）
  - score_input.jsp（评分工作台，约200行）：
    - 统计概览栏：待评作品总数 / 我已评分 / 尚未评分 三列彩色卡片
    - 作品卡片列表（双栏网格）：每张卡片显示作品标题、队伍ID、提交时间、描述摘要，左侧色条区分「已评(绿)/未评(粉)」，点击进入评分
    - 评分表单区（左右分栏）：左侧作品信息面板（名称/描述/队伍/时间/图片预览点击放大），右侧评分操作面板
    - 滑块+数字输入双模式：range 滑块（渐变色：红→黄→绿）+ 同步数字输入框，实时大字体显示当前分值
    - 已评分状态：info 提示框显示上次评分分值和时间 + 表单自动切换为更新模式
    - 空状态引导：无待评作品时显示 inbox 图标 + 提示文字
  - score_list.jsp（评分记录，约220行）：
    - 双视图合一：「我的评分记录」视图 + 「作品评分详情」视图，根据 Servlet 传入数据自动切换
    - 我的评分记录：表格展示（序号/作品名称/所属队伍/我的评分/评分时间/操作按钮），评分用三色徽章（≥80绿/≥60黄/<60红），操作栏含「修改评分」「查看所有评分」两个按钮
    - 作品评分详情：渐变横幅（作品名+队伍名+提交时间）+ 平均分圆形白色徽章 + 统计卡片行（已评人数/最高分/最低分）+ 评分列表表格
    - 空状态引导：无评分记录时显示大图标 + 「去评分」CTA按钮
- ✅ 安全特性：PreparedStatement 防 SQL 注入、评分范围 0-100 输入验证、双重防重（DB UNIQUE 约束 + Service 层检查）、Session 登录验证、参数 NumberFormatException 容错
- **代码量：** 5个文件（3个Java从空壳补全 + 2个JSP新建），原空壳约80行 → 改后约730行，净增约650行
- **编译状态：** BUILD SUCCESS，86个Java源文件零错误

**已完成：全局导航栏统一修复（完成人：葛至洲）**
- ✅ 问题诊断：全站JSP页面导航栏碎片化，品牌名/样式/链接集合各不相同，用户反馈两个具体问题：
  - 「我的队伍」页面导航栏与首页不统一，普通用户可通过竞赛列表页面看到「发布竞赛」按钮（无权限校验）
  - 「个人中心」页面导航栏只有2个链接（个人中心+退出），无法跳转到其他页面
- ✅ 修复方案探索：尝试了 JSP 静态include（`<%@ include %>`）和动态include（`<jsp:include>`）两种全局组件方案，但静态include存在变量作用域冲突/重复page指令/注解兼容性等问题，动态include存在路径解析差异，均导致 HTTP 500 错误。最终采用**精准逐个修复**策略——保留各页面独立导航栏，将不一致的页面逐一替换为 index.jsp 标准版本
- ✅ 修复清单（8个页面）：
  - profile.jsp：新增 Role 导入 + isAdmin/isJudge 判断，2链接导航栏 → 完整导航栏（竞赛大厅/我的队伍/我的作品/新闻公告/角色感知菜单/用户下拉）
  - team_list.jsp：新增角色判断，品牌统一为 🎨 海报竞赛系统，补齐 bg-dark sticky-top 和汉堡菜单
  - team_detail.jsp：同上
  - team_create.jsp：同上 + 补齐缺失的「邀请通知」链接
  - invitation_list.jsp：同上
  - competition_list.jsp：导航栏替换为完整版本 +「发布竞赛」按钮新增管理员权限检查（`<% if (isAdmin) { %>`）
  - score_input.jsp：新建页面，补齐完整导航栏（含角色判断）
  - score_list.jsp：新建页面，补齐完整导航栏（含角色判断）
- ✅ 安全修复：competition_list.jsp「发布竞赛」按钮和空状态「立即发布」链接新增管理员权限检查，解决普通用户可见管理功能的安全漏洞
- **代码量：** 8个JSP页面修改，每个页面约+50行（角色判断+完整导航栏），约+400行
- **编译状态：** BUILD SUCCESS，86个Java源文件零错误

### 2026-07-08

**已完成：模块5-评语管理功能（完成人：葛至洲）**
- ✅ DAO层：CommentDAOImpl 从7个空壳方法补全为完整 JDBC 实现（insert/deleteById/update/findById/findByWorkId/findByJudgeId/findAll，使用 PreparedStatement 防 SQL 注入）
- ✅ Service层：新建 CommentService 接口 + CommentServiceImpl 实现类（7个方法：addComment/updateComment/deleteComment/getCommentById/getCommentsByWorkId/getCommentsByJudgeId/getAllComments，含输入验证）
- ✅ Controller层：新建 CommentServlet（GET: list/myComments；POST: add/update/delete，Session 登录集成，评委可对自己的评语进行增删改）
- ✅ 前端集成：score_input.jsp 评分页面新增评语区域（添加/编辑/删除表单 + 所有评语列表展示，当前用户评语高亮标识）
- ✅ 前端集成：submission_detail.jsp 新增「评委评语」Tab，展示所有评委对作品的评语
- ✅ 安全特性：PreparedStatement 防 SQL 注入、输入验证、Session 登录验证、评委只能编辑自己的评语
- **代码量：** 4个文件（1个DAO补全 + 2个Service新建 + 1个Servlet新建），约350行 Java 代码

**已完成：模块5-获奖设置功能（完成人：葛至洲）**
- ✅ DAO层：AwardDAOImpl 从7个空壳方法补全为完整 JDBC 实现（insert/deleteById/update/findById/findByCompetitionId/findByWorkId/findAll）
- ✅ Service层：AwardServiceImpl 从5个空壳方法补全为完整业务逻辑
  - setAward：三重校验（获奖等级/必要字段/防重检查）→ 插入获奖记录 → 自动生成电子奖状
  - getAwardsByCompetitionId/getAwardByWorkId：null 安全委托 DAO
  - generateCertificate：查询获奖信息 → 生成唯一编号 CERT-YYYYMMDD-XXXX → 保存奖状记录
  - publishAwardAnnouncement：查询竞赛所有获奖 → 构建公告内容 → 创建新闻记录（NewsDAO）
- ✅ Controller层：AwardServlet 从空壳补全为完整实现
  - GET: list（获奖名单公开查看）、manage（管理员获奖管理，含权限检查）、detail（获奖详情）
  - POST: set（设置获奖）、delete（撤销获奖）、publishAnnouncement（发布获奖公告）
  - 管理页加载竞赛作品列表+平均分+队伍信息，支持按竞赛筛选
- ✅ 前端页面：新建3个JSP页面
  - award_manage.jsp（约280行）：竞赛选择器 + 左侧作品列表（含均分、已/未获奖状态）+ 右侧已获奖列表 + 设置获奖Modal弹窗（等级选择+得分输入）+ 发布公告按钮
  - award_list.jsp（约220行）：渐变标题栏 + 获奖卡片排名展示（金银铜配色）+ 队伍/作品信息 + 查看奖状按钮 + 空状态引导
  - award_detail.jsp（约150行）：获奖详情 + 作品/队伍/竞赛信息 + 证书编号 + 查看奖状/查看作品按钮
- ✅ 安全特性：管理员权限校验（manage/set/delete 操作）、获奖等级校验（仅一/二/三等奖）、防重复获奖检查
- **代码量：** 6个文件（1个DAO补全 + 1个Service补全 + 1个Servlet补全 + 3个JSP新建），约1100行

**已完成：模块5-电子奖状功能（完成人：葛至洲）**
- ✅ DAO层：CertificateDAOImpl 从7个空壳方法补全为完整 JDBC 实现（insert/deleteById/update/findById/findByAwardId/findByTeamId/findAll，含 JOIN 查询）
- ✅ Service层：新建 CertificateService 接口 + CertificateServiceImpl 实现类（5个方法：generateCertificate/getCertificateById/getCertificateByAwardId/getCertificatesByTeamId/getAllCertificates，含防重复生成）
- ✅ Controller层：CertificateServlet 从空壳补全为完整实现
  - GET: view（奖状查看，加载获奖/作品/队伍/竞赛/成员信息）、myCertificates（队员查看自己队伍的所有奖状，跨队伍聚合）、list（管理员查看所有奖状）
- ✅ 前端页面：新建2个JSP页面
  - certificate_view.jsp（约160行）：复古证书风格设计（双线边框+装饰图标+公章旋转元素），显示竞赛名称/队伍/队长/作品/获奖等级/最终得分/证书编号/颁发日期，支持浏览器打印（@media print 优化）
  - certificate_list.jsp（约180行）：渐变标题栏 + 奖状卡片列表（含获奖等级/竞赛名/作品名/队伍名/得分/证书编号）+ 查看奖状按钮 + 空状态引导
- ✅ 导航集成：index.jsp 新增「获奖名单」公开链接（所有用户可见）和「我的奖状」用户菜单项
- ✅ 权限控制：AuthFilter 新增 /award 和 /certificate 为公开资源（查看奖状无需登录）
- **代码量：** 5个文件（1个DAO补全 + 2个Service新建 + 1个Servlet补全 + 2个JSP新建），约700行

**已完成：作品详情页增强（完成人：葛至洲）**
- ✅ WorkServlet.showDetail() 新增评分/评语/获奖数据加载（ScoreService + CommentService + AwardService + CertificateService）
- ✅ submission_detail.jsp 重大升级：
  - 导航栏升级为完整版本（含角色判断、竞赛大厅/我的队伍/我的作品/评分工作台/管理中心）
  - 获奖信息横幅（金色渐变背景 + 奖杯图标 + 获奖等级 + 查看奖状按钮）
  - 平均评分展示（紫色圆角卡片）
  - Tab切换：评分记录（各评委打分+时间）+ 评委评语（评语卡片+我的评语高亮）
  - 状态标签/队伍名/竞赛名/时间信息完善
- ✅ ScoreServlet.showScoreInput() 新增评语数据加载，评分页面可同步查看和编辑评语
- **修改文件：** 4个文件（2个Servlet + 1个JSP全面改版 + 1个JSP功能增强），约+150行

**模块5完成总结：**
- ✅ 评分功能（Score）— 7月7日已完成
- ✅ 新闻发布（News）— 7月6日已完成
- ✅ 评语管理（Comment）— 7月8日完成
- ✅ 获奖设置（Award）— 7月8日完成
- ✅ 奖状生成（Certificate）— 7月8日完成
- ✅ 获奖公告发布 — 7月8日完成
- ✅ 评分统计与排名 — 7月8日完成
- **模块5状态：** 100%完成，所有功能可用
- **总代码量：** 15个文件（6个新建 + 9个补全/增强），约2300行 Java + JSP
- **编译状态：** BUILD SUCCESS，91个Java源文件零错误
**已完成：队伍详情页作品Tab功能修复（完成人：洪振博 / Claude 协助）**
- ✅ TeamServlet：添加WorkService实例化，showTeamDetail方法中查询队伍作品列表并传递给JSP
- ✅ team_detail.jsp：重写作品Tab，支持作品列表展示（图片+标题+描述+状态）和"提交作品"按钮（队长权限）
- ✅ 修复：添加Work类导入，修正方法名（getWorkTitle→getTitle, getWorkDesc→getDescription）
- **问题修复：** 队伍详情页作品Tab从空提示改为完整功能

**已完成：图片存储数据库BLOB方案实现（完成人：洪振博 / Claude 协助）**
- ✅ 数据库：work表添加image_data(MEDIUMBLOB)和image_content_type(VARCHAR)字段
- ✅ schema.sql：添加BLOB字段定义
- ✅ Work.java：添加imageData和imageContentType字段及getter/setter
- ✅ WorkDAOImpl：insert/update/extractWorkFromResultSet方法支持BLOB字段读写
- ✅ WorkServlet：submitWork和updateWork方法读取图片二进制数据并保存到数据库
- ✅ ImageDataServlet（新建）：从数据库读取BLOB并返回图片（映射/image-data）
- ✅ 4个JSP页面：修改图片src为`/image-data?workId=X`（score_input.jsp, team_detail.jsp, submission_list.jsp, submission_detail.jsp）
- **代码量：** 13个文件（1个新建Servlet + 8个Java修改 + 4个JSP修改），约+800行

**遇到的问题：数据库BLOB方案性能问题**
- ⚠️ 图片上传慢：需要同时写文件系统和数据库BLOB
- ⚠️ Navicat查看work表慢：加载所有BLOB数据导致查询缓慢
- ⚠️ 应用查询慢：每次SELECT都加载完整BLOB数据
- **待决策：** 是否回退到文件系统方案（修复田继青的ImageServlet路径问题）或优化BLOB方案（只在需要时查询）

**模块二剩余：**
- [ ] 竞赛列表每张卡片分别显示各自的队伍数/作品数（可优化项）

### 2026-07-08（续）

**已完成：取消报名 + 队伍详情页作品展示（完成人：杨祥博 / Claude 协助）**
- ✅ Service层：`TeamService` / `TeamServiceImpl` 新增 `cancelRegistration()` 方法（队长验证、状态检查、status 2→1）
- ✅ Controller层：`TeamServlet` 新增 `cancel` action 路由 + `cancelRegistration()` 处理（队长权限校验）
- ✅ Controller层：`TeamServlet.showTeamDetail()` 新增作品加载（`WorkService.getWorksByTeamId()`）、点赞统计（`WorkLikeDAO.countByWorkId()`）、汇总数据（作品数/总赞数）
- ✅ 前端页面：`team_detail.jsp` 概览Tab统计卡片从硬编码 `0` 改为真实数据（提交作品数/获得点赞数）
- ✅ 前端页面：`team_detail.jsp` 作品Tab从静态占位符改为真实作品网格（缩略图/标题/描述摘要/时间/点赞数/状态标签）+ hover悬浮动画 + 空状态引导（已报名队伍显示提交作品按钮）
- ✅ 前端页面：`team_detail.jsp` 已报名状态新增"取消报名"按钮（确认弹窗 → POST cancel → 队伍恢复组建中）
- **代码量：** 4个文件，+167行，-7行
- **编译状态：** BUILD SUCCESS

**已完成：同一用户同一竞赛重复建队限制（完成人：杨祥博 / Claude 协助）**
- ✅ Service层：`TeamServiceImpl.createTeam()` 新增重复建队校验（调用 `getUserTeamInCompetition()`，已在该竞赛有有效队伍则拒绝创建）
- ✅ Controller层：`TeamServlet.createTeam()` 错误提示更新（明确告知"同一竞赛只能加入一支队伍"）
- **代码量：** 2个文件，+5行，-1行
- **编译状态：** BUILD SUCCESS

**已完成：队伍人数上限改用竞赛配置maxTeamSize（完成人：杨祥博 / Claude 协助）**
- ✅ Service层：`TeamServiceImpl.inviteMember()` 人数上限从硬编码 `5` 改为读取 `Competition.maxTeamSize`（新增 `CompetitionDAO` 依赖，null/0 时回退默认值 5）
- ✅ Service层：`InvitationServiceImpl.acceptInvitation()` 同上（新增 `CompetitionDAO` 依赖）
- ✅ Controller层：`TeamServlet.showTeamDetail()` 将 `maxTeamSize` 传递给 JSP
- ✅ 前端页面：`team_detail.jsp` 步骤指示器 `memberCount >= 5` 改为 `memberCount >= maxTeamSize`
- **代码量：** 4个文件，+27行，-5行
- **编译状态：** BUILD SUCCESS

**已完成：Bug修复 - 获奖名单导航栏 + 获奖管理500错误（完成人：葛至洲 / Claude 协助）**
- ✅ 问题1：获奖名单页面导航栏偏左 → `award_list.jsp` 中 `me-auto` 改为 `ms-auto`（与其他页面统一右对齐）
- ✅ 问题2：获奖管理页面500错误 → `award_manage.jsp` 中 `selectedCompetition.getTitle()` 改为 `getName()`（Competition实体类无getTitle方法）
- **修改文件：** 2个JSP

**已完成：Bug修复 - 队伍详情页500错误（完成人：葛至洲 / Claude 协助）**
- ✅ 问题：`team_detail.jsp` 作品Tab中 `List<Work> works` 变量重复声明（第48行和第567行），JSP编译为Servlet时Java不允许同名变量 → 500错误
- ✅ 修复：删除第566-622行冗余的作品展示代码块（上方已有完整实现）
- **修改文件：** 1个JSP，-57行

**已完成：安全修复 - 截止日期后禁止修改作品（完成人：葛至洲 / Claude 协助）**
- ✅ 问题：`WorkServlet.updateWork()` 缺少竞赛截止日期检查，选手在比赛结束后仍可修改作品（`submitWork`和`deleteWork`均有此检查，属于遗漏）
- ✅ 修复：`updateWork()` 队长权限校验后新增截止日期判断，截止后返回 `deadline_passed` 错误
- **修改文件：** 1个Java，+7行

**已完成：安全修复 - 新闻操作添加管理员权限校验（完成人：葛至洲 / Claude 协助）**
- ✅ 问题：`NewsServlet` 的 `publishNews`/`updateNews`/`deleteNews`/`showEditPage`/`manageNews` 共5个方法均无管理员权限检查，普通用户可直接操作新闻
- ✅ 修复：新增 `isAdmin()` 辅助方法（从Session角色列表判断），在上述5个方法入口添加管理员权限校验，非管理员重定向到首页
- **修改文件：** 1个Java，+30行

**已完成：数据库连接配置更新（完成人：洪振博 / Claude 协助）**
- ✅ DBUtil.java：更新远程数据库连接信息
  - 主机地址：143.110.133.32 → **120.26.46.0**
  - 端口：3306（保持不变）
  - 用户名：dev → **navicat_user**
  - 密码：已更新为新密码
- ✅ 数据库环境：切换到新的远程MySQL服务器（MySQL 8.0.46）
- ✅ 配置验证：确认连接参数（useSSL=false、serverTimezone=UTC、characterEncoding=utf8、超时设置）
- **修改文件：** 1个文件（DBUtil.java），第13-15行
- **下一步：** 需在新数据库上执行schema.sql和init_data.sql完成数据初始化

**已完成：数据库schema完整性确认（完成人：洪振博 / Claude 协助）**
- ✅ user表字段确认：包含avatar字段（用户头像功能，2026-07-06添加）
- ✅ work表字段确认：包含image_data(MEDIUMBLOB)和image_content_type字段（数据库BLOB方案，2026-07-08添加）
- ✅ TeamServlet代码确认：作品加载代码已存在且位置正确（第233-234行加载works，第260行设置attribute）
- **结论：** schema.sql已包含所有开发过程中添加的字段，可直接用于新数据库初始化，无需额外迁移脚本

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
- **功能范围：** 竞赛发布、修改、查询、子类管理、搜索筛选、状态管理、竞赛取消、数据统计
- **前端页面：** competition_list.jsp（含搜索/筛选/统计）, competition_add.jsp, competition_edit.jsp, competition_detail.jsp（含统计/取消）
- **后端代码：** CompetitionServlet（list/detail/add/edit/create/update/delete/cancel）, CompetitionService（创建/更新/删除/取消/搜索/统计）, IndexServlet（全局统计）
- **数据访问：** CompetitionDAO（含search/findByFilters）, CategoryDAO, TeamDAO, WorkDAO
- **涉及数据表：** competition, competition_category（2张表，统计关联team/work）
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

**模块5：评分与获奖模块（葛至洲负责）**
- **功能范围：** 评委评分、评语管理、获奖设置、奖状生成、新闻发布
- **前端页面：** score_input.jsp, score_list.jsp, award_manage.jsp, certificate_view.jsp, news_list.jsp
- **后端代码：** ScoreServlet, AwardServlet, CertificateServlet, NewsServlet, ScoreService
- **数据访问：** ScoreDAO, CommentDAO, AwardDAO, CertificateDAO, NewsDAO
- **涉及数据表：** score, comment, award, certificate, news（5张表）
- **附加职责：** 系统集成测试、功能验证、Bug修复

### 2026-07-09

**已完成：Landing 进入页重设计（完成人：洪振博 / Claude 协助）**
- ✅ 全新独立 React Landing Page 替换旧 6 屏滚动叙事
- ✅ 视觉风格：亮色主题 Creative Portfolio Hero，参考 motionsites.ai
- ✅ 核心组件（本地实现，零新依赖）：
  - `AnimatedText` — 标题逐字进入动画
  - `MagneticLink` — CTA 按钮磁吸鼠标效果
  - `SpotlightCard` — 卡片光标光斑效果
  - `CinematicHero` — 主 Hero：视频卡片 + 滚动驱动视频播放 + 3D 卡片视角变换
- ✅ 动效系统（仅使用现有 GSAP 3.12.5）：
  - 滚动驱动视频进度（ScrollTrigger scrub）
  - 卡片 3D 旋转 + 缩放（中段峰值 scale 1.45，模拟飞机穿出视角）
  - 鼠标移动视差（卡片 tilt、标题位移、CTA 磁吸、spotlight 光斑）
  - 飞行线条 + 坐标点装饰
- ✅ CSS 亮色主题：`#f5f5f7` 浅灰白背景，与 JSP 系统白色页面统一
- ✅ 响应式适配：920px / 560px 断点
- ✅ `prefers-reduced-motion` 全停动画
- ✅ 语义化 HTML：`<main>`、`<section>`、`<header>`、`<nav>` + ARIA labels
- ✅ 视频：H.264 编码 MP4，`aria-hidden="true"`，预加载
- ✅ AuthFilter 放行 `/js/`、`/css/`、`/assets/` 路径
- ✅ CTX 路径对接 JSP 系统：/index、/login、/register、/competition、/award
- ✅ 清理：删除旧 GlassNav.jsx、ScrubPage.jsx，删除旧构建缓存

**新增文件：**
- `frontend/src/components/AnimatedText.jsx`
- `frontend/src/components/MagneticLink.jsx`
- `frontend/src/components/SpotlightCard.jsx`
- `frontend/src/components/CinematicHero.jsx`
- `frontend/src/LandingApp.jsx`（重写）
- `frontend/src/styles/landing.css`（重写）
- `frontend/src/styles/portfolio-overrides.css`（重写）
- `src/main/webapp/js/landing/`
- `src/main/webapp/css/landing/`
- `src/main/webapp/assets/landing/video/portfolio-hero.mp4`（替换为飞机视频）

**编译状态：** BUILD SUCCESS（Vite 5.2.0）

### 2026-07-12

**已完成：Bug修复 - 获奖名单改为往届获奖记录（完成人：洪振博 / Claude 协助）**
- ✅ AwardServlet.showAwardList() 重写：只加载已结束竞赛（status=3）的获奖数据
- ✅ 前端 award_list.jsp 全面改版：标题改为"往届获奖记录"，顶部增加竞赛选择下拉框
- ✅ 所有导航/链接"获奖名单"→"往届获奖"统一更名（navbar.jspf, index.jsp）
- **修改文件：** 4个文件（AwardServlet.java + award_list.jsp + navbar.jspf + index.jsp）

**已完成：Bug修复 - 入队申请403错误（完成人：洪振博 / Claude 协助）**
- ✅ AuthFilter.java：/application、/team、/invitation、/work 路径开放管理员访问（`isParticipant || isAdmin`）
- ✅ 管理员不再因角色检查被拦截在这些路径外
- **修改文件：** 2个文件（AuthFilter.java + navbar.jspf）

**已完成：Bug修复 - 已结束比赛仍显示可提交作品（完成人：洪振博 / Claude 协助）**
- ✅ TeamServlet.showTeamDetail()：新增传递 Competition 对象到 JSP
- ✅ team_detail.jsp：根据竞赛状态（isCompetitionEnded）控制"提交作品"按钮显示
  - 已结束竞赛 → 按钮替换为"竞赛已结束，作品提交已关闭"提示
  - 已取消竞赛 → 隐藏按钮
- ✅ team_detail.jsp 步骤指示器：步骤3显示"作品提交已截止（竞赛已结束）"
- ✅ 服务端 WorkServlet.submitWork() 已有正确的截止日期+竞赛状态双重校验
- **修改文件：** 2个文件（TeamServlet.java + team_detail.jsp）

**已完成：新功能 - 搜索队伍并申请加入（完成人：洪振博 / Claude 协助）**
- ✅ 仿照邀请队员的搜索模式实现反向流程：队员搜索队伍 → 申请加入
- ✅ TeamDAO/TeamDAOImpl：新增 `searchByTeamName(String keyword)` 模糊搜索（`LIKE %keyword% LIMIT 20`）
- ✅ TeamService/TeamServiceImpl：新增 `searchTeams(String keyword)` 方法
- ✅ TeamServlet：新增 `searchTeam` action，返回 JSON（队名、竞赛名、成员数/上限、队长ID）
- ✅ competition_detail.jsp：
  - "创建队伍"旁新增"搜索并加入队伍"按钮
  - Bootstrap Modal：搜索输入框 → AJAX 模糊搜索 → 结果列表 → "申请加入"按钮
  - 仅在竞赛状态=1（报名中）且用户未参赛时显示
- **修改文件：** 6个文件（3个Java后端 + 3个JSP/前端）
- **编译状态：** BUILD SUCCESS，91个Java源文件零错误

### 2026-07-13

**已完成：Bug修复 - 首页轮播第二屏链接无法点击（完成人：葛至洲 / Claude 协助）**
- ✅ 问题定位：首页 Hero 轮播 3 张幻灯片使用 `position: absolute; inset: 0;` 叠放，无 `z-index` 管理且无 `pointer-events: none`，导致 DOM 中最后的幻灯片 3 始终在最上层拦截点击事件
- ✅ 幻灯片 2 的"查看作品入口"和"往届获奖"链接被幻灯片 3 的 `::after` 伪元素覆盖 → 点击被拦截 → 链接失效
- ✅ 幻灯片 1 的链接位置恰好与幻灯片 3 链接重叠 → 点击穿透到幻灯片 3 的不可见链接 → 看似可用但跳转地址可能错误
- ✅ 修复方案：`.hero-slide` 添加 `pointer-events: none`，`.hero-slide.is-active` 添加 `pointer-events: auto`，确保仅当前活跃幻灯片可接收点击
- **修改文件：** 1个文件（home.css），+2行
- **教训：** 轮播组件使用 absolute 定位叠放幻灯片时，必须用 `pointer-events` 控制非活跃幻灯片的交互，否则会产生难以排查的链接失效或跳转错误问题

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
private String userName;[init.sql](src%2Fmain%2Fresources%2Finit.sql)

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
  - 葛至洲：创建工具类（PasswordUtil、FileUtil）
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

**模块5 - 评分与获奖（葛至洲）：**
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
- [x] 用户角色管理界面（✅ 提前完成，user_manage.jsp模态框）
- [x] 密码修改功能（✅ ProfileServlet中已实现）
- [x] 找回密码功能（✅ ForgotPasswordServlet + forgot_password.jsp）
- [x] 用户状态管理（启用/禁用）（✅ user_manage.jsp一键切换）
- [x] 用户列表查询（管理员功能）（✅ UserManageServlet + 模糊搜索）

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

**模块5 - 评分与获奖（葛至洲）：**
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
- **葛至洲（评分与获奖模块）：** 测试评分、获奖设置、奖状生成、新闻发布

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
**参会人员：** 队长、副队长、杨祥博、队员B、葛至洲  
**会议照片：** [照片链接]

## 昨日完成情况
- 队长：完成项目框架搭建
- 副队长：完成数据库脚本编写
- 杨祥博：完成登录页面
- 队员B：完成用户注册逻辑
- 葛至洲：编写测试用例10个

## 今日工作计划
- 队长：实现用户权限控制
- 副队长：优化数据库索引
- 杨祥博：开发竞赛列表页面
- 队员B：实现竞赛发布功能
- 葛至洲：测试用户模块

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
├── frontend/                       # React Landing 进入页（独立 SPA）
│   ├── src/
│   │   ├── main.jsx
│   │   ├── LandingApp.jsx
│   │   ├── context.js
│   │   ├── components/
│   │   │   ├── AnimatedText.jsx
│   │   │   ├── CinematicHero.jsx
│   │   │   ├── MagneticLink.jsx
│   │   │   └── SpotlightCard.jsx
│   │   └── styles/
│   │       ├── landing.css
│   │       └── portfolio-overrides.css
│   ├── index.html
│   ├── package.json
│   └── vite.config.js
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
- 葛至洲：[姓名] - [QQ/微信] - [邮箱]

### 紧急联系
如遇紧急问题或blocking issue，请立即在团队群通知队长和副队长。

---

**最后更新时间：** 2026年7月12日
**更新人：** 洪振博 / Claude
**版本：** v1.12
