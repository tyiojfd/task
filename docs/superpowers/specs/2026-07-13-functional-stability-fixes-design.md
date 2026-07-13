# 功能稳定性修复设计

## 目标

修复竞赛系统中已确认的功能问题：头像上传后无法稳定访问、成员入队申请无法被队伍负责人查询，以及部署后登录入口偶发 404。保留现有“队长主动邀请”和“成员申请入队”两套业务流程，不改变已有路由语义。项目中“队长/队员”没有严格的全局角色边界，真正的队长身份以 `team.leader_id` 和 `team_member.role=1` 为准。

## 已确认的根因

1. 实际 `poster_competition` 数据库缺少 `team_application` 表。现有 `TeamApplicationDAOImpl` 在查询异常时返回空列表，因此成员申请不会正常保存，队长页面看起来像“没有申请”。
2. 数据库中的角色与队伍负责人字段存在测试数据交叉：`leader01` 被用户明确设置为“评委”，而部分测试队伍的 `leader_id` 仍指向它。该账号的评委身份是有意配置，不能由修复脚本擅自删除；实际审核应使用一个具备参与者权限、且 `team.leader_id` 指向自己的账号。
3. `ProfileServlet` 使用 `ServletContext.getRealPath("/uploads/avatars")` 保存头像。该目录属于 Tomcat 部署目录，重新打包或重新部署后文件可能丢失；数据库中的头像路径仍然存在，最终表现为 `/uploads/avatars/...` 返回 404。
4. 当前 8080 实例的日志显示 `LoginServlet` 因热部署期间缺少 `UserServiceImpl` 而被 Tomcat 标记为不可用；重新启动并部署完整 WAR 后，新的 WAR 中 `/login` 可正常返回 200。这是部署状态问题，不需要通过改路由掩盖。

## 设计方案

### 1. 头像存储

头像继续在数据库中保存相对 URL `/uploads/avatars/<generated-name>`，但文件改为保存到 `FileUploadUtil.getStorageBasePath()/avatars`。`ImageServlet` 已支持从该外部存储根目录读取 `/uploads/*`，因此不需要改变页面 URL。

上传流程如下：

1. 校验 multipart 部件、MIME 类型、扩展名和 2MB 大小限制。
2. 创建外部头像目录并使用随机文件名保存文件。
3. 更新用户头像路径和 Session 用户对象。
4. 只有数据库更新成功后才清理旧文件；旧部署目录中的头像仍保留兼容读取。

如果保存或数据库更新失败，返回明确错误，不覆盖原头像路径。

### 2. 入队申请

继续使用现有 `/application` Servlet 和 `team_application` 表：

```text
成员 POST /application?action=apply
  -> TeamApplicationService 校验比赛、队伍、角色、人数和重复申请
  -> team_application 插入待处理记录
  -> 队长打开 /application?action=teamApplications&teamId=ID
  -> 队长 approve/reject
  -> 通过时加入 team_member 并更新申请状态
```

数据库迁移由用户在 Navicat 执行，代码不自动执行 SQL。新建数据库的 `database/schema.sql` 已包含该表；现有数据库使用已提供的 `database/migrations/V5__team_application.sql`。

服务层保留队伍负责人身份校验，不仅依赖页面按钮；通过申请时要确保重复提交不会创建重复成员，申请状态更新失败不能静默报告成功。全局“队长”角色不是判断某个队伍负责人的唯一依据。

### 3. 角色和注册一致性

不自动修改已有角色数据。代码侧增强注册流程：默认“队员”角色不存在或分配失败时，注册不报告成功，避免产生登录后无法访问队伍功能的无角色账号。

角色修复后用户需要重新登录，使 Session 中的 `roles` 与数据库一致。管理员修改角色后也应重新登录验证。

### 4. 部署验证

不修改 Servlet 映射来规避热部署问题。每次验证使用完整 WAR：

```text
target/task-1.0-SNAPSHOT
```

停止旧 Tomcat 后重新部署并启动，再检查 `/login`、`/register`、`/profile`、`/team` 和 `/application`。避免在 Tomcat 运行期间执行会清空 `target` 的 Maven clean/package。

## 错误处理

- 缺少必填参数、无权限、队伍不存在、队伍已满、比赛状态不允许时返回现有页面错误提示或重定向参数。
- 数据库表未迁移时不伪造“暂无申请”；日志保留异常，页面显示初始化提示。
- 文件写入失败时不更新数据库中的头像路径。
- 头像 URL 无对应文件时由页面保留首字母占位，避免破坏布局。

## 验收标准

1. 新用户注册后拥有“队员”角色，访问队伍和申请页面不被错误拦截。
2. 成员申请入队后，队长在申请审核页面看到申请人和留言，并可通过或拒绝。
3. 具有参与者权限的真实队伍负责人（例如 `member01` 所负责的队伍）重新登录后可访问队伍详情和入队申请审核页面；被设置为评委的 `leader01` 不被自动改成队长。
4. 上传 JPG/PNG 头像后，刷新页面、重启 Tomcat、重新访问头像 URL 均可显示。
5. `/login`、`/register`、`/profile` 不再因当前 WAR 的类加载状态返回 404/500。
6. Maven 构建通过，新增回归测试通过，现有源码未执行数据库写操作。
