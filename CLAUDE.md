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
- **服务器**：Apache Tomcat 10
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

**模块3：队伍管理模块（队员A负责）**
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
- [ ] 添加Maven依赖（MySQL、JSTL、文件上传、JSON等）
- [ ] 创建所有实体类（17个Model类）
- [ ] 创建数据库工具类（DBUtil）
- [ ] 创建基础工具类（PasswordUtil、FileUtil、DateUtil）
- [ ] 创建基础过滤器（EncodingFilter）
- [ ] 统一开发环境（数据库、Tomcat配置）
- [ ] 完成项目设计报告

**第一阶段分工（所有人参与基础架构）：**
- **7月4日上午（集中会议）：** 统一开发环境、讨论技术规范
- **7月4日下午（结对编程）：**
  - 队长+副队长：添加Maven依赖、创建DBUtil
  - 队员A+队员B：创建实体类（User、Competition、Team、Work等）
  - 队员C：创建工具类（PasswordUtil、FileUtil）
- **7月5日（验证测试）：** 所有人本地测试数据库连接，创建自己的功能分支
- **7月6-7日（原型开发）：** 每个人开发自己模块的核心功能原型

### 第二阶段（7月8-11日）：核心功能并行开发
> **独立开发阶段：** 每个人在自己的功能分支上独立开发完整模块

**模块1 - 用户认证（队长）：**
- [ ] 用户注册功能（RegisterServlet + register.jsp）
- [ ] 用户登录功能（LoginServlet + login.jsp）
- [ ] 权限验证过滤器（AuthFilter）
- [ ] 个人信息管理（ProfileServlet + profile.jsp）
- [ ] Session管理和退出登录

**模块2 - 竞赛管理（副队长）：**
- [ ] 竞赛列表查询（competition_list.jsp）
- [ ] 竞赛发布功能（CompetitionServlet + competition_add.jsp）
- [ ] 竞赛详情展示（competition_detail.jsp）
- [ ] 竞赛修改功能（competition_edit.jsp）
- [ ] 竞赛子类管理

**模块3 - 队伍管理（队员A）：**
- [ ] 创建队伍功能（TeamServlet + team_create.jsp）
- [ ] 邀请队员功能（InvitationServlet + invitation_list.jsp）
- [ ] 队伍成员管理（team_manage.jsp）
- [ ] 接受/拒绝邀请功能
- [ ] 队伍报名竞赛

**模块4 - 作品管理（队员B）：**
- [ ] 作品提交功能（WorkServlet + work_submit.jsp）
- [ ] 文件上传功能（FileUploadServlet）
- [ ] 作品列表展示（work_list.jsp）
- [ ] 作品详情页面（work_detail.jsp）
- [ ] 作品修改/删除功能

**模块5 - 评分与获奖（队员C）：**
- [ ] 评委评分功能（ScoreServlet + score_input.jsp）
- [ ] 评分记录查询（score_list.jsp）
- [ ] 评语管理功能（comment功能）
- [ ] 获奖设置功能（AwardServlet + award_manage.jsp）
- [ ] 新闻发布功能（NewsServlet + news_list.jsp）

**每日集成：** 每天晚上10点，队长负责合并所有分支到dev分支

### 第三阶段（7月12-15日）：功能完善与优化
> **继续垂直开发：** 每个人在自己的模块内完善高级功能

**模块1 - 用户认证（队长）：**
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

**模块3 - 队伍管理（队员A）：**
- [ ] 队伍信息展示优化
- [ ] 队员移除功能
- [ ] 取消报名功能
- [ ] 队伍搜索功能
- [ ] 队伍统计（我的队伍、我参与的队伍）

**模块4 - 作品管理（队员B）：**
- [ ] 作品点赞功能（work_like表）
- [ ] 作品分享功能（work_share表）
- [ ] 作品搜索和筛选
- [ ] 作品统计（浏览量、点赞数）
- [ ] 图片预览和下载

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
- **队员A（队伍管理模块）：** 测试队伍创建、邀请、报名、成员管理
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
- 队员A/B/C：各自演示负责的功能模块

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
**参会人员：** 队长、副队长、队员A、队员B、队员C  
**会议照片：** [照片链接]

## 昨日完成情况
- 队长：完成项目框架搭建
- 副队长：完成数据库脚本编写
- 队员A：完成登录页面
- 队员B：完成用户注册逻辑
- 队员C：编写测试用例10个

## 今日工作计划
- 队长：实现用户权限控制
- 副队长：优化数据库索引
- 队员A：开发竞赛列表页面
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
- 队员A：[姓名] - [QQ/微信] - [邮箱]
- 队员B：[姓名] - [QQ/微信] - [邮箱]
- 队员C：[姓名] - [QQ/微信] - [邮箱]

### 紧急联系
如遇紧急问题或blocking issue，请立即在团队群通知队长和副队长。

---

**最后更新时间：** 2026年7月4日  
**更新人：** Claude AI助手  
**版本：** v1.0
