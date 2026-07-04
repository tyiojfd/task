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

### 角色分工

**队长（Team Leader）**
- 负责：项目整体规划、进度管理、代码审查
- 主要模块：用户管理模块、权限控制
- 文档职责：组织会议记录、协调团队总结

**副队长（Vice Leader）**
- 负责：技术架构设计、数据库管理、代码质量
- 主要模块：数据库设计与实现、DAO层开发
- 文档职责：编写技术总结、项目实现报告

**队员A（Frontend Developer）**
- 负责：前端页面开发、用户界面设计
- 主要模块：竞赛管理界面、作品展示界面
- 技术重点：JSP页面、Bootstrap样式、JavaScript交互

**队员B（Backend Developer）**
- 负责：业务逻辑开发、Servlet控制器
- 主要模块：竞赛流程、评分系统、获奖管理
- 技术重点：Servlet、JavaBean、业务逻辑层

**队员C（Integration Tester）**
- 负责：系统集成、功能测试、bug修复
- 主要模块：作品互动、新闻发布、文件上传
- 测试职责：编写测试用例、功能验证、性能测试

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

### 第一阶段（7月4-7日）：需求分析与设计
- [x] 完成需求分析
- [x] 完成数据库设计
- [ ] 完成界面原型设计
- [ ] 搭建项目框架
- [ ] 完成项目设计报告

**负责人分工：**
- 队长：项目框架搭建
- 副队长：数据库脚本编写
- 队员A：界面原型设计
- 队员B：业务流程梳理
- 队员C：测试用例设计

### 第二阶段（7月8-11日）：核心功能开发
- [ ] 用户管理模块（注册、登录、权限）
- [ ] 竞赛管理模块（发布、修改、查询）
- [ ] 队伍管理模块（创建、邀请、加入）
- [ ] 作品管理模块（提交、修改、展示）

**负责人分工：**
- 队长：用户管理+权限控制
- 副队长：数据库集成+DAO层
- 队员A：前端页面开发
- 队员B：竞赛+队伍业务逻辑
- 队员C：作品管理+文件上传

### 第三阶段（7月12-15日）：功能完善
- [ ] 评分系统（评委评分、查看评语）
- [ ] 获奖管理（设置获奖、生成奖状）
- [ ] 新闻发布（公告、动态）
- [ ] 作品互动（点赞、分享）
- [ ] 数据统计（报表、分析）

**负责人分工：**
- 队长：获奖管理+奖状生成
- 副队长：数据统计功能
- 队员A：新闻发布界面
- 队员B：评分系统逻辑
- 队员C：作品互动功能

### 第四阶段（7月16-18日）：测试与优化
- [ ] 功能测试
- [ ] 性能优化
- [ ] Bug修复
- [ ] 完成实现报告
- [ ] 制作演示视频

**负责人分工：**
- 队长：整体测试+视频制作
- 副队长：性能优化+实现报告
- 队员A：界面美化
- 队员B：业务逻辑测试
- 队员C：集成测试+Bug修复

### 第五阶段（7月19日）：答辩准备
- [ ] 准备答辩PPT
- [ ] 项目演示练习
- [ ] 完成项目总结
- [ ] 提交所有材料

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
