# 团队总结文档 Implementation Plan

> **For agentic workers:** Execute the steps inline in this session. Do not create a Git commit because the user explicitly requested no Git submission.

**Goal:** Preserve the supplied Word template's first-page cover and generate a complete, editable team-summary document on the Windows desktop.

**Architecture:** Use the supplied `.docx` as the source document, retain all cover paragraphs, the cover image, section settings, and the cover-to-body page break, then remove only the template's empty body placeholders and append the four completed summary sections. Generate first in the workspace for validation, then copy the verified file to the desktop.

**Tech Stack:** Python 3.12, `python-docx` 1.1.2, PowerShell file copy, Word `.docx`.

---

### Task 1: Create the document generator

**Files:**
- Create: `C:\Users\Lenovo\Desktop\java\task\generate_team_summary.py`

- [ ] **Step 1: Define source discovery and output arguments**

  Use an exact source path to `D:\qiyeweixin\WXWork\1688854684669597\Cache\File\2026-07\团队总结.docx`, accept an optional workspace output path, and keep the output path separate from the desktop copy so validation happens before external delivery.

- [ ] **Step 2: Preserve the cover and replace only the body**

  Load the source with `python-docx`, locate the existing page-break paragraph immediately before `一、技术总结`, retain every body element through that page break, remove later placeholder paragraphs, and append new paragraphs without touching the cover text, logo image, margins, or footer.

- [ ] **Step 3: Add the approved content**

  Append these sections:

  ```text
  一、技术总结
  二、团队合作总结
  三、团队合影
  四、个人总结
  ```

  Use the project records and the deployed project identity at `http://120.26.46.0:8080/task/` as context. Describe completed work as completed and planned work as planned. Keep the team photo section as an editable centered insertion area instead of inventing an image. Use role labels where real member names are not present.

- [ ] **Step 4: Save the workspace artifact**

  Save the generated document as `C:\Users\Lenovo\Desktop\java\task\团队总结-已生成.docx` and print the source, output, paragraph count, and image count.

### Task 2: Validate and deliver the Word file

**Files:**
- Read: `C:\Users\Lenovo\Desktop\java\task\团队总结-已生成.docx`
- Deliver: `C:\Users\Lenovo\Desktop\团队总结.docx`

- [ ] **Step 1: Validate the workspace artifact**

  Reopen it with `python-docx` and verify that the first-page cover paragraphs still contain the original placeholders, the cover image count is unchanged, the body contains all four headings, and the output has no empty section content except the photo insertion area.

- [ ] **Step 2: Copy the verified artifact to the desktop**

  Use PowerShell `Copy-Item -LiteralPath` to copy the verified workspace file to `C:\Users\Lenovo\Desktop\团队总结.docx`.

- [ ] **Step 3: Verify the delivered file**

  Reopen the desktop copy with `python-docx`, verify its size is non-zero, confirm the first-page and four-section checks again, and report the absolute file path.
