# Database Image Thumbnail Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Store original work images and generated thumbnails in MySQL so all users see the same images while list pages load small thumbnails.

**Architecture:** Keep original images in `work.image_data`; add thumbnail fields already added to `database/schema.sql`. Generate a 300px-wide JPEG thumbnail during submit/update, store it in `thumbnail_data`, and serve images through `/image-data?workId=...&type=thumb|original`.

**Tech Stack:** Java Servlet/JSP, MySQL MEDIUMBLOB, Java AWT/ImageIO, Maven Java 8 target.

## Global Constraints

- Do not execute database SQL from code or tools.
- Do not modify live database; user runs Navicat SQL manually.
- Thumbnail width: 300px maximum, proportional height.
- Thumbnail format: JPEG.
- JPEG quality: 0.75.
- Java code must be compatible with Maven target Java 8.
- Existing `/uploads/*` fallback can remain, but work display pages should use `/image-data`.

---

### Task 1: Extend Work model and DAO

**Files:**
- Modify: `src/main/java/com/poster/model/Work.java`
- Modify: `src/main/java/com/poster/dao/impl/WorkDAOImpl.java`

**Interfaces:**
- Produces: `Work#getThumbnailData()`, `Work#setThumbnailData(byte[])`, `Work#getThumbnailContentType()`, `Work#setThumbnailContentType(String)`.

- [ ] Add thumbnail fields and getters/setters to `Work`.
- [ ] Add `thumbnail_data` and `thumbnail_content_type` to DAO insert/update SQL.
- [ ] Bind thumbnail values in prepared statements.
- [ ] Extract thumbnail fields from `ResultSet`.
- [ ] Build with `JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -DskipTests package`.

### Task 2: Generate thumbnails on upload

**Files:**
- Modify: `src/main/java/com/poster/controller/WorkServlet.java`

**Interfaces:**
- Consumes: `Work#setThumbnailData(byte[])`, `Work#setThumbnailContentType(String)`.
- Produces: private `createThumbnail(byte[] imageData): byte[]`.

- [ ] Add Java 8-compatible thumbnail generation using `ImageIO` and `ImageWriter`.
- [ ] On submit, after reading original bytes, generate thumbnail bytes and set `thumbnailContentType` to `image/jpeg`.
- [ ] On update with a new image, regenerate thumbnail bytes.
- [ ] Build with Maven wrapper.

### Task 3: Serve original or thumbnail from database

**Files:**
- Modify: `src/main/java/com/poster/controller/ImageDataServlet.java`

**Interfaces:**
- Consumes: `type` request parameter with values `thumb` or `original`.
- Produces: image response from thumbnail or original data.

- [ ] If `type=thumb`, serve `thumbnail_data` first.
- [ ] If thumbnail is missing, fall back to original image.
- [ ] If `type=original` or absent, serve original image.
- [ ] Keep cache headers.
- [ ] Build with Maven wrapper.

### Task 4: Switch JSP image URLs to database endpoints

**Files:**
- Modify: `src/main/webapp/jsp/submission_list.jsp`
- Modify: `src/main/webapp/jsp/team_detail.jsp`
- Modify: `src/main/webapp/jsp/competition_works.jsp`
- Modify: `src/main/webapp/jsp/submission_detail.jsp`
- Modify: `src/main/webapp/jsp/submission_add.jsp`

**Interfaces:**
- Consumes: `/image-data?workId=<id>&type=thumb` for list cards.
- Consumes: `/image-data?workId=<id>&type=original` for detail/edit previews.

- [ ] Replace list/card images with `type=thumb` endpoint.
- [ ] Replace detail/download/modal images with `type=original` endpoint.
- [ ] Keep existing fallback icon behavior.
- [ ] Build with Maven wrapper.

### Task 5: Verify final behavior

**Files:**
- All modified files.

- [ ] Run static regression checks for thumbnail fields, endpoint URLs, and Java 8 compatibility.
- [ ] Run `JAVA_HOME="C:/Program Files/Java/jdk-21" ./mvnw -q -DskipTests package`.
- [ ] Report changed files and remind user to run Navicat SQL if not already applied.
