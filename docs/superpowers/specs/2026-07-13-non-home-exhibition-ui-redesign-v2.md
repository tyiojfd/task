# 非首页视觉升级 V2 — 从"老鼠屎镶金边"到内外兼修

## 背景

当前项目存在严重的视觉断层：
- **React Landing 进入页** — 高级电影感，3D 卡片，玻璃态，动画丰富（"金边"）
- **队员/管理员/评委首页** — 玻璃导航，Hero 轮播，阴影层次，质感好（"金边"）
- **竞赛列表、作品列表、详情页、登录页等所有非首页** — 扁平白卡片 + 1px 边框，无阴影无层次，像 2015 年的后台管理系统（"老鼠屎"）

本次升级目标：让非首页与首页拥有同一水准的视觉品质，消除断层。

## 保护范围（绝不修改）

- `src/main/webapp/jsp/index.jsp` — 队员首页
- `src/main/webapp/css/home.css` — 队员首页样式
- `src/main/webapp/jsp/admin_home.jsp` — 管理员首页
- `src/main/webapp/jsp/judge_home.jsp` — 评委首页
- `src/main/webapp/css/role-home.css` — 角色首页样式
- 所有后端代码（Servlet / Service / DAO / Model）
- 所有 URL、表单字段、权限判断

## 设计系统

### 色彩

保持现有色板（已与首页统一），但调整使用方式：

```
墨蓝    #153247  — 导航栏、Hero 区底色、深色面板
墨蓝软  #40586a  — 二级文字、标签
海蓝    #1769aa  — 主按钮、链接、强调色
海蓝深  #0c4e82  — 按钮悬停、激活态
青绿    #078e9f  — 状态标签（进行中）、统计数字
薄荷    #cdeee3  — 状态标签背景（报名中）
黄      #efc65c  — 导航底部装饰线、金奖
粉      #f3c9d5  — 状态标签背景（已取消）
纸白    #f4f7f8  — 页面背景
纯白    #ffffff  — 卡片表面
```

**禁止：** 紫色（`#6C5CE7`、`#A29BFE`、`#667eea`、`#764ba2`）、渐变文字、多层装饰渐变背景。

### 阴影系统（核心新特性）

替代当前的纯 `1px border` 扁平风格：

```css
--shadow-xs:  0 1px 2px rgba(21, 50, 71, 0.04);   /* 微妙分隔，替代浅边框 */
--shadow-sm:  0 2px 8px rgba(21, 50, 71, 0.06);    /* 卡片常态 */
--shadow-md:  0 4px 16px rgba(21, 50, 71, 0.08);   /* 卡片悬停 */
--shadow-lg:  0 8px 32px rgba(21, 50, 71, 0.11);   /* Modal、下拉菜单 */
--shadow-xl:  0 16px 48px rgba(21, 50, 71, 0.14);  /* 大弹窗 */
```

卡片 = 白色表面 + `shadow-sm` + `1px solid rgba(21,50,71,0.06)` 极细边框（在亮背景上防止边界消失）。

悬停 = `shadow-md` + `translateY(-2px)`。

### 玻璃态（核心新特性）

**导航栏：**
```css
background: rgba(21, 50, 71, 0.92);
backdrop-filter: blur(16px) saturate(1.1);
border-bottom: 1px solid rgba(255, 255, 255, 0.08);
```
保留底部黄色 3px 装饰线。

**页面标题 Hero 区：**
```css
background: linear-gradient(135deg, var(--app-ink) 0%, #1a4058 100%);
/* 或 */
background: rgba(255, 255, 255, 0.7);
backdrop-filter: blur(12px);
```
根据页面类型二选一。

### 页面 Hero 区设计

每个主要列表/详情页顶部新增轻量 Hero，与首页 Hero 形成"同一家族"：

- **目录页**（竞赛/作品/新闻列表）→ 深色紧凑 Hero（`padding: 32px 0`），左侧标题+Kicker+描述，右侧统计数
- **详情页** → 浅色玻璃 Hero 或融入页面布局
- **表单/工作台页** → 保持工作台分区结构，不加 Hero

### 竞赛卡片重设计

**核心改变：去掉随机硬编码图片。**

当前问题：
```jsp
String[] posterSamples = {"poster-1.png", ..., "poster-6.png"};
int posterIndex = Math.abs(comp.getCompetitionId()) % posterSamples.length;
```
这些图片与竞赛内容无关，只是从首页借来的装饰图，用户一眼能看出"假的"。

新设计：
- **纯排版竞赛卡片** — 左侧色条（状态色）+ 右侧信息区
- 报名中 = 薄荷绿左侧竖条，进行中 = 海蓝，已结束 = 灰色
- 标题大字，主题/截止日期作为元信息，状态用小圆点+Capsule标签
- 悬停：卡片上浮 + 阴影加深 + 左侧色条变宽
- 管理员可见编辑/删除快捷操作

不显示任何与竞赛数据无关的图片。如果竞赛本身有封面图字段（当前没有），才展示。

### 登录/注册页重做

从"白卡片套白背景"改为：

**登录页：**
- 页面背景：`var(--app-paper)` 浅蓝灰
- 居中玻璃卡片（白色半透明 + backdrop-blur + 阴影）
- 卡片左侧或顶部：品牌区（墨蓝底 + 系统名称 + 简短描述）
- 卡片右侧或底部：表单区（干净输入框 + 主按钮）
- 底部：注册/忘记密码链接

**注册页同理。**

**管理员/评委登录页：**
- 与队员登录同一结构，但品牌区文字不同（"管理员登录"/"评委登录"）
- 角色标识色：管理员用黄点缀，评委用青绿点缀

### 微交互规范

所有交互遵守 `prefers-reduced-motion`：

- 卡片悬停：`transform: translateY(-2px)` + `box-shadow` 过渡 200ms
- 按钮悬停：`translateY(-1px)` + 亮度变化 180ms
- 表格行悬停：背景色 150ms
- 导航链接：底部指示条或背景色变化 180ms
- 页面加载：无自动动画，静态呈现

不使用：弹跳、旋转、脉冲、彩虹渐变、打字机效果。

## 页面改造清单

### CSS 层改动

| 文件 | 改动 |
|------|------|
| `app-shell.css` | 新增阴影 CSS 变量；导航栏改玻璃态；卡片/按钮/表单统一加阴影；表格行加悬停态 |
| `app-pages.css` | 新增 Hero 区组件样式；重写竞赛卡片（去掉图，改用排版）；升级目录/画廊/详情/工作台页面家族样式；清理所有 bridge rules 中的临时方案 |

### JSP 页面改动

| 页面 | 改动 | 优先级 |
|------|------|--------|
| `competition_list.jsp` | 去掉随机图数组 `posterSamples`；竞赛卡片改为纯排版；加刷新按钮 | P0 |
| `login.jsp` | 玻璃卡片重做 | P0 |
| `login_admin.jsp` | 玻璃卡片重做 | P0 |
| `login_judge.jsp` | 玻璃卡片重做 | P0 |
| `register.jsp` | 玻璃卡片重做 | P0 |
| `forgot_password.jsp` | 玻璃卡片重做 | P0 |
| `award_list.jsp` | 去掉嵌入式紫色 `<style>`；加 catalog family class | P0 |
| `news_list.jsp` | 去掉嵌入式紫色 `<style>`；加 catalog family class | P0 |
| `competition_detail.jsp` | 使用 detail layout 重构 | P1 |
| `submission_list.jsp` | 优化作品卡片，图片优先 | P1 |
| `submission_detail.jsp` | 使用 detail layout | P1 |
| `team_list.jsp` | 队伍卡片加阴影，统一风格 | P1 |
| `team_detail.jsp` | 优化 detail layout | P1 |
| `team_create.jsp` | 表单分区加阴影 | P1 |
| `profile.jsp` | 表单卡片加阴影 | P1 |
| `news_detail.jsp` | 使用 detail layout | P2 |
| `news_add.jsp` / `news_edit.jsp` | 表单分区加阴影 | P2 |
| `competition_add.jsp` / `competition_edit.jsp` | 表单分区加阴影 | P2 |
| `score_input.jsp` | 评分区加阴影层次 | P2 |
| `score_list.jsp` | 表格/卡片加阴影 | P2 |
| `award_detail.jsp` | 使用 detail layout | P2 |
| `award_manage.jsp` | 管理面板加阴影 | P2 |
| `certificate_view.jsp` | 证书展示加阴影 | P2 |
| `certificate_list.jsp` | 证书卡片加阴影 | P2 |
| `user_manage.jsp` | 表格加阴影 | P2 |
| `invitation_list.jsp` | 邀请卡片加阴影 | P2 |
| `submission_add.jsp` | 上传区加阴影 | P2 |
| `news_manage.jsp` | 表格加阴影 | P2 |
| `application_list.jsp` | 申请卡片加阴影 | P2 |
| `competition_works.jsp` | 作品墙加阴影 | P2 |

### 不动文件清单（确认）

```
index.jsp                  — 队员首页
home.css                   — 队员首页样式
admin_home.jsp             — 管理员首页
judge_home.jsp             — 评委首页
role-home.css              — 角色首页样式
navbar.jspf                — 导航栏结构不变（app-shell.css 改样式）
app-shell-assets.jspf      — 引用不变（CSS 文件内容改）
```

## 验收标准

1. `index.jsp` / `home.css` / `admin_home.jsp` / `judge_home.jsp` / `role-home.css` Git diff 为空
2. 非首页不再有嵌入式紫色 `<style>` 块
3. 非首页不再使用 `poster-1~6.png` 随机硬编码图片作为竞赛封面
4. 导航栏呈现玻璃态（半透明 + blur）
5. 卡片使用阴影而非纯边框，有明显前后纵深
6. 登录/注册页为玻璃卡片布局
7. 竞赛列表页卡片为纯排版设计（无无关图片）
8. 所有页面悬停交互一致（卡片上浮、阴影加深）
9. `prefers-reduced-motion` 正确停止所有动画
10. Maven 编译通过，WAR 可打包

## 设计参考

不做：AI 感（过度渐变、紫色系、Dashboard 模板、随机装饰图、彩虹色）
要做：编辑设计感（清晰层级、克制配色、真实内容优先、留白得当、阴影表达纵深）
