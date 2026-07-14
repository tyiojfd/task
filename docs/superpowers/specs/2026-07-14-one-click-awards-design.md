# 一键获奖功能设计

**日期：** 2026-07-14  
**项目：** 大学生海报设计竞赛系统  
**范围：** 管理员获奖管理页的一键获奖生成功能

## 1. 背景与目标

当前系统已支持管理员在获奖管理页手动为作品设置一等奖、二等奖、三等奖，并自动生成电子奖状。新增“一键获奖”功能后，管理员可在已结束竞赛的获奖管理页基于评委评分均分自动生成获奖名单：

- 前 10%：一等奖
- 一等奖之后 15%：二等奖
- 二等奖之后 20%：三等奖

该功能采用现有获奖管理页集成方案，不新增独立预览页。执行时会覆盖当前竞赛已有获奖记录并重新生成奖状。

## 2. 已确认规则

### 2.1 入口位置

在现有 `/award?action=manage&competitionId=...` 获奖管理页增加“一键生成获奖名单”按钮。

按钮仅对管理员可见，且只在选择了已结束竞赛时显示。

### 2.2 排名依据

按作品评委均分排序。均分来源为 `score` 表中对应 `work_id` 的平均分。

排序规则：

1. 均分从高到低；
2. 若均分相同，不扩大获奖名额；
3. 同分时使用稳定兜底排序，建议按提交时间更早优先，再按 `work_id` 升序。

### 2.3 参与范围

候选作品必须满足：

- 属于当前竞赛；
- 作品状态为已提交或已评审，即 `status=2` 或 `status=3`；
- 至少存在一条评分记录。

获奖管理页面仍可显示未评分作品，但未评分作品必须标记为“暂无评分”，且不参与一键获奖排名和比例计算。

因此，一键获奖生成的总获奖作品数不会超过页面当前竞赛作品列表中可参与排名的已评分作品数，也不会超过页面显示作品总数。

### 2.4 名额计算

以“已评分候选作品数”为基数计算名额：

- 一等奖数量：`ceil(候选作品数 * 10%)`
- 二等奖数量：`ceil(候选作品数 * 15%)`
- 三等奖数量：`ceil(候选作品数 * 20%)`

个位数作品也按以上百分比向上取整，不另设特殊限制。例如 9 件已评分候选作品：

- 一等奖：`ceil(9 * 10%) = 1`
- 二等奖：`ceil(9 * 15%) = 2`
- 三等奖：`ceil(9 * 20%) = 2`

若计算出的总名额超过候选作品数，则按一等奖、二等奖、三等奖顺序截断，保证不会给不存在的作品分奖。

### 2.5 覆盖策略

点击“一键生成获奖名单”后采用“先撤销再重算”策略：

1. 删除该竞赛已有获奖记录对应的电子奖状；
2. 删除该竞赛已有获奖记录；
3. 按最新均分排名重新生成获奖记录；
4. 为新生成的每条获奖记录生成电子奖状。

覆盖前页面必须通过确认弹窗提示管理员：该操作会撤销当前竞赛已有获奖记录并重新生成奖状。

## 3. 推荐实现方案

采用方案 A：在现有获奖管理页增加“一键获奖”按钮，并新增后端批量生成 action。

### 3.1 Controller 设计

在 `AwardServlet` 中新增 POST 分支：

```java
if ("autoGenerate".equals(action)) {
    autoGenerateAwards(request, response);
}
```

新增 `autoGenerateAwards(HttpServletRequest request, HttpServletResponse response)`：

- 检查登录状态；
- 检查管理员权限；
- 解析 `competitionId`；
- 从 session 获取当前管理员 `userId` 作为 `issuerId`；
- 调用 `awardService.autoGenerateAwards(competitionId, issuerId)`；
- 根据返回结果设置 session message 或 error；
- 重定向回 `/award?action=manage&competitionId=...`。

Servlet 只负责权限、参数、跳转和提示，不承载排名和名额计算逻辑。

### 3.2 Service 设计

在 `AwardService` 增加方法：

```java
AutoAwardResult autoGenerateAwards(Integer competitionId, Integer issuerId);
```

建议新增轻量结果对象 `AutoAwardResult`，用于向 Servlet 返回：

- `success`：是否成功；
- `message`：失败或成功提示；
- `candidateCount`：已评分候选作品数；
- `skippedUnscoredCount`：跳过的未评分作品数；
- `firstPrizeCount`：一等奖数量；
- `secondPrizeCount`：二等奖数量；
- `thirdPrizeCount`：三等奖数量。

服务层流程：

1. 校验 `competitionId` 和 `issuerId` 非空；
2. 查询竞赛，必须存在且 `status=3`；
3. 查询当前竞赛作品，筛选 `status=2` 或 `status=3`；
4. 对每个作品查询评分记录和均分：
   - 有评分：加入候选列表；
   - 无评分：计入跳过数量；
5. 若候选列表为空，不删除旧奖项，直接返回失败提示；
6. 对候选列表按均分降序、提交时间、`work_id` 排序；
7. 按 10% / 15% / 20% 向上取整计算名额，并以候选作品数为上限截断；
8. 删除该竞赛旧证书和旧获奖记录；
9. 按排名批量创建 `Award`：
   - `competitionId` 为当前竞赛；
   - `workId` 为候选作品 ID；
   - `awardLevel` 为对应奖项；
   - `finalScore` 为当前作品均分；
   - `issuerId` 为当前管理员 ID；
10. 每创建一条获奖记录后调用现有 `generateCertificate(awardId)` 自动生成奖状；
11. 返回成功结果。

### 3.3 DAO 与事务建议

现有 DAO 多为单方法自建连接。为了降低改动范围，第一版可在 `AwardServiceImpl` 中使用现有 DAO 方法循环完成：

- `awardDAO.findByCompetitionId(competitionId)` 查询旧奖项；
- 对每条旧奖项先删除对应证书，再删除 award；
- 调用现有 `awardDAO.insert(award)` 插入新奖项；
- 调用现有 `generateCertificate(awardId)` 生成证书。

如果 `CertificateDAO` 没有按 awardId 删除证书的接口，可新增最小方法，或通过 `findByAwardId(awardId)` 后调用 `deleteById(certificateId)`。

更稳妥的后续优化是为批量重算引入事务，保证“删除旧奖项 + 新增新奖项 + 生成证书”全部成功或全部回滚。但考虑当前代码风格，第一版应先完成校验和候选计算，确认可生成后再删除旧记录，降低半成品风险。

### 3.4 JSP 页面设计

在 `award_manage.jsp` 中，当 `selectedCompetition != null` 时增加按钮：

- 文案：`一键生成获奖名单`
- 说明：`按已评分作品均分排名：前10%一等奖、后15%二等奖、后20%三等奖。执行后会撤销当前竞赛已有获奖记录并重新生成奖状。`
- 表单：`POST ${contextPath}/award`
- hidden 字段：
  - `action=autoGenerate`
  - `competitionId=<当前竞赛ID>`
- `onsubmit` 确认文案：
  - `确定要一键生成获奖名单吗？此操作会撤销当前竞赛已有获奖记录并重新生成奖状。`

在作品列表中建议增强未评分展示：

- 有评分作品：显示 `均分: xx.x`；
- 无评分作品：显示 `暂无评分，不参与一键获奖`。

## 4. 错误处理

需要覆盖以下场景：

1. 未登录：跳转登录页；
2. 非管理员：跳转首页；
3. `competitionId` 非法或缺失：提示“请选择有效竞赛”；
4. 竞赛不存在：提示“竞赛不存在”；
5. 竞赛未结束：提示“仅已结束竞赛可一键生成获奖名单”；
6. 当前竞赛没有作品：提示“该竞赛暂无作品，无法生成获奖名单”；
7. 当前竞赛有作品但没有已评分作品：提示“当前没有已评分作品，无法生成获奖名单”；
8. 批量生成过程中某条奖项或证书生成失败：提示“生成失败，请稍后重试或手动设置”；
9. 成功：提示“已按均分生成获奖名单：一等奖 X 名、二等奖 Y 名、三等奖 Z 名；跳过未评分作品 N 件”。

无已评分候选作品时不删除旧获奖记录，避免管理员误操作导致已有结果丢失。

## 5. 测试计划

### 5.1 功能验证

1. 管理员进入已结束竞赛的获奖管理页，可以看到“一键生成获奖名单”按钮；
2. 非管理员无法访问获奖管理页，也无法直接 POST `action=autoGenerate` 生效；
3. 已评分作品按均分从高到低生成奖项；
4. `award.final_score` 等于当前作品均分；
5. 9 件已评分作品时生成 1 名一等奖、2 名二等奖、2 名三等奖；
6. 未评分作品显示在列表中，但不参与一键获奖；
7. 已有获奖记录时，重新点击一键生成会覆盖旧获奖结果并重新生成证书；
8. 没有已评分作品时不会删除旧获奖记录，并显示错误提示；
9. 成功生成后，获奖名单页和证书查看页能正常显示。

### 5.2 编译验证

运行 Maven 构建：

```bash
JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -DskipTests package
```

### 5.3 手动数据验证

建议准备一组已结束竞赛测试数据：

- 至少 9 件已评分作品；
- 至少 1 件未评分作品；
- 至少 1 条已有旧获奖记录；
- 每件作品有不同均分，另准备两件同分作品验证稳定排序。

## 6. 非目标

本次不实现：

- 独立的一键获奖预览页；
- 手动拖拽排名；
- 边界同分自动扩大奖项名额；
- 按评委人数限制获奖数量；
- 自动发布获奖公告。公告仍使用现有“发布获奖公告”按钮。

## 7. 影响范围

预计涉及文件：

- `src/main/java/com/poster/controller/AwardServlet.java`
- `src/main/java/com/poster/service/AwardService.java`
- `src/main/java/com/poster/service/impl/AwardServiceImpl.java`
- `src/main/java/com/poster/model/AutoAwardResult.java`（新增，或放入 service result 包）
- `src/main/webapp/jsp/award_manage.jsp`
- 必要时：`src/main/java/com/poster/dao/CertificateDAO.java`
- 必要时：`src/main/java/com/poster/dao/impl/CertificateDAOImpl.java`

## 8. 用户确认记录

- 方案选择：采用现有获奖管理页新增按钮的方案 A；
- 排名依据：评委均分；
- 小数名额：向上取整；
- 个位数作品：仍按百分比向上取整；
- 覆盖策略：先撤销再重算；
- 边界同分：不扩大名额；
- 获奖总量约束：以获奖管理页面当前竞赛中可参与排名的已评分作品为基数，未评分作品不参与一键获奖。
