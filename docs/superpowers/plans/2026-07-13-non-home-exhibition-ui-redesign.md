# Non-Home Exhibition UI Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign every JSP outside the protected participant homepage as a distinctive poster-competition catalog and workbench while preserving all existing URLs, form fields, permissions, and business behavior.

**Architecture:** Keep `home.css` and `index.jsp` isolated. Extend the existing shared JSP asset include with a neutral shell and page-family stylesheet, add semantic body classes for catalog/gallery/detail/workbench pages, and make focused markup improvements to the highest-visibility list and work pages. Existing Bootstrap markup remains the functional base; new CSS supplies the visual system and page-family rhythm.

**Tech Stack:** JSP, Bootstrap 5, Font Awesome 6, CSS custom properties, existing local poster assets, Maven/JUnit static template tests.

---

### Task 1: Add regression coverage for the protected homepage and page-family system

**Files:**
- Modify: `src/test/java/com/poster/web/UnifiedFrontendTemplateTest.java`
- Create: `src/test/java/com/poster/web/ExhibitionUiTemplateTest.java`

- [ ] **Step 1: Write failing assertions for the new page-family contract**

Assert that `app-pages.css` is linked by the shared include, that the protected homepage does not contain the new include, and that representative JSPs declare the expected family classes: catalog (`competition_list.jsp`), gallery (`submission_list.jsp`), detail (`competition_detail.jsp`), and workbench (`score_input.jsp`). Also assert that the new CSS does not contain purple tokens, gradient text, repeating stripes, or side-stripe borders.

- [ ] **Step 2: Run the focused test and verify it fails**

Run:

```powershell
$env:JAVA_HOME='C:\Program Files\Java\jdk-21'; & 'C:\Users\Lenovo\.m2\wrapper\dists\apache-maven-3.9.6-bin\439sdfsg2nbdob9ciift5h5nse\apache-maven-3.9.6\bin\mvn.cmd' '-Dtest=ExhibitionUiTemplateTest' test
```

Expected: FAIL because the page-family stylesheet and classes do not yet exist.

- [ ] **Step 3: Keep the existing participant-home protection assertions**

The test must continue checking that `src/main/webapp/jsp/index.jsp` and `src/main/webapp/css/home.css` remain untouched and that every other JSP receives the shared shell include.

### Task 2: Replace the generic inner-page shell

**Files:**
- Modify: `src/main/webapp/jsp/includes/app-shell-assets.jspf`
- Modify: `src/main/webapp/css/app-shell.css`
- Create: `src/main/webapp/css/app-pages.css`

- [ ] **Step 1: Define the inner-page visual tokens**

Use deep ink, sea blue, cyan, mint, and signal yellow as named roles. Keep the body surface mostly flat and light; use one defined border or one restrained shadow per surface. Do not introduce purple, gradient text, decorative grid backgrounds, or repeating gradients.

- [ ] **Step 2: Build the shared shell rules**

Style the existing navbar, container, form controls, buttons, alerts, tables, badges, and pagination so they share typography, focus states, spacing, and compact radii. The shell must only target `body:not(.home-page)` so the participant homepage remains unaffected.

- [ ] **Step 3: Add page-family primitives**

Implement `.app-page-head`, `.app-page-kicker`, `.app-toolbar`, `.app-surface`, `.app-catalog-grid`, `.app-catalog-item`, `.app-art-grid`, `.app-art-card`, `.app-detail-layout`, `.app-detail-rail`, `.app-form-section`, `.app-workbench`, and `.app-empty` in `app-pages.css`. These primitives deliberately vary composition instead of forcing every page into the same card grid.

- [ ] **Step 4: Link the stylesheet and rerun structural tests**

Add the page-family stylesheet link to the shared include and run `ExhibitionUiTemplateTest`. Expected: the link/token assertions pass while the page-class assertions remain failing until Task 3.

### Task 3: Add semantic page-family classes and improve the highest-visibility pages

**Files:**
- Modify: `src/main/webapp/jsp/competition_list.jsp`
- Modify: `src/main/webapp/jsp/submission_list.jsp`
- Modify: `src/main/webapp/jsp/award_list.jsp`
- Modify: `src/main/webapp/jsp/news_list.jsp`
- Modify: `src/main/webapp/jsp/competition_detail.jsp`
- Modify: `src/main/webapp/jsp/submission_detail.jsp`
- Modify: `src/main/webapp/jsp/score_input.jsp`
- Modify: `src/main/webapp/jsp/score_list.jsp`

- [ ] **Step 1: Add family classes without changing business actions**

Use `app-page app-page-catalog`, `app-page app-page-gallery`, `app-page app-page-detail`, and `app-page app-page-workbench` on the corresponding `<body>` tags. Preserve all form action names, hidden fields, request attributes, and permission branches.

- [ ] **Step 2: Recompose the competition catalog**

Replace the three equal statistic cards and plain two-column cards with a title/summary block, compact filter toolbar, and competition entries that show an existing local poster sample, status, theme, deadline, and a clear details action. Use the competition id to select one of the existing home poster samples as a visual fallback only; do not add or alter competition data.

- [ ] **Step 3: Recompose the work list and score queue**

Keep the existing `image-data` thumbnail endpoint, but make the image the primary element, move metadata into a compact caption area, and group like/share/edit/score actions into an accessible action row. Remove purple inline styling from the visible work-list actions.

- [ ] **Step 4: Recompose representative detail and score pages**

Use a visual-main/content-rail layout for work and competition details. On score input, keep the scoring form fields and submission endpoint intact while placing the work preview and scoring controls into separate sections with a clear completion action.

### Task 4: Apply the page-family language to all remaining JSP pages

**Files:**
- Modify: all existing non-home JSPs under `src/main/webapp/jsp/`, including admin/judge homes

- [ ] **Step 1: Classify remaining pages**

Assign each page to catalog, gallery, detail, or workbench and add the matching body class. Login/register pages use `app-page-auth`; team/application/invitation pages use `app-page-workbench` or `app-page-catalog` according to their primary task.

- [ ] **Step 2: Remove conflicting page-local purple defaults**

Replace visible `#6C5CE7`, `#A29BFE`, and purple gradient declarations in non-home pages with the shared sea-blue/cyan/mint roles. Do not edit `home.css` or `index.jsp`.

- [ ] **Step 3: Normalize forms, modals, tables, and empty states**

Use the shared primitives for form sections, modal headers, table rows, empty states, and action groups. Keep modal IDs, JavaScript function names, request parameters, and redirects unchanged.

- [ ] **Step 4: Verify all non-home JSPs use both shared stylesheets**

Run a PowerShell scan over `src/main/webapp/jsp/*.jsp` excluding `index.jsp`; expected output is that every file contains `app-shell-assets.jspf`, and the shared include contains both CSS links.

### Task 5: Run tests, package, and local smoke checks

**Files:**
- Verify: all changed JSP/CSS/Java/test files

- [ ] **Step 1: Run focused and full Maven tests**

Run the focused visual-template tests, then `mvn test`; expected output is 0 failures and 0 errors.

- [ ] **Step 2: Build the WAR**

Run `mvn package -DskipTests`; expected output is `target/task-1.0-SNAPSHOT.war` and `BUILD SUCCESS`.

- [ ] **Step 3: Run HTTP smoke checks against the supplied Tomcat URL**

Check participant `/index`, judge `/index` after judge login, admin `/index` after admin login, `/competition?action=list`, `/work?action=myWorks`, `/score?action=list`, `/award?action=list`, and `/news?action=list`; expect HTTP 200, correct title/content markers, and both shared stylesheets.

- [ ] **Step 4: Run the final protected-file and anti-slop checks**

Confirm the Git diff for `index.jsp` and `home.css` is empty, and scan new styles for purple, gradient text, repeating gradients, side-stripe borders, and oversized card radii.

- [ ] **Step 5: Commit only the redesign implementation**

Stage the new/modified non-home UI files and tests while leaving `.claude/` and unrelated documents unstaged. Commit with:

```powershell
git add src/main/webapp/css/app-shell.css src/main/webapp/css/app-pages.css src/main/webapp/jsp src/test/java/com/poster/web
git commit -m "feat: refine non-home exhibition interface"
```
