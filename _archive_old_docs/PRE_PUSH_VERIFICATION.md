# Pre-Push Verification Checklist

Run this checklist **before** pushing changes to GitHub to avoid breaking the build or introducing errors.

---

## Quick Checklist (5 minutes)

```bash
# 1. Test render
cd nushagak-wqx
quarto render --to html 2>&1 | tail -20

# 2. Check for broken references
grep -r "TODO\|FIXME\|XXX\|undefined" chapters/ --include="*.qmd"

# 3. Verify Git status
git status
```

If all three pass without errors, you're good to push.

---

## Detailed Pre-Push Checklist

### Step 1: Verify Your Changes Render
```bash
quarto render --to html
```
**Expected output**: `Output created: _book\index.html` (last line)

**If render fails**:
- Check R console for error messages
- Look for missing packages: `install.packages(...)`
- Check for YAML syntax errors in `_quarto.yml`
- Verify all chapter files referenced in `_quarto.yml` exist

### Step 2: Check for Incomplete Content
```bash
grep -r "TODO\|FIXME\|XXX\|HACK\|PLACEHOLDER\|undefined" chapters/ --include="*.qmd"
```
**Expected output**: Empty (no matches)

**If found**:
- Complete the todo item or mark as intentional
- Document any known gaps in the chapter text itself
- Do NOT commit incomplete sections

### Step 3: Verify No Stale HUC8 References
```bash
# Check for "five HUC" or references to HUC 19030305 (Togiak)
grep -r "five HUC\|19030305\|Togiak" chapters/ --include="*.qmd" | grep -v "excluded\|drains separately"
```
**Expected output**: Empty or only mentions in exclusion explanations

**If found**:
- Update prose to reflect four Nushagak HUCs only
- Add explanatory note if referring to Togiak exclusion

### Step 4: Check Git Status
```bash
git status
```
**Look for**:
- ✓ Your intended file changes
- ✓ No accidentally deleted files (unless intentional)
- ✓ No build artifacts committed (`.knit.md`, `.docx`, `_book/`)

**If you see unexpected changes**:
- Review with `git diff filename.qmd`
- Revert if unintended: `git checkout filename.qmd`

### Step 5: Verify gitignore Works
```bash
git check-ignore -v _book/index.html
git check-ignore -v *.docx
git check-ignore -v .RData
```
**Expected output**: Each file should be listed with its gitignore rule

**If not ignored**:
- Files were already tracked before gitignore was added
- Remove with: `git rm --cached filename`
- Re-add to `.gitignore`

### Step 6: Review Your Commit Message
```bash
# Before committing, prepare a descriptive message:
# git commit -m "Update Chapter 06: Add zinc summary by form"
```

**Good commit messages**:
- ✓ "Update Chapter 05: Add temperature summary table"
- ✓ "Fix Chapter 03: Correct HUC code in text"
- ✓ "Add COLLABORATOR_QUICK_START.md guide"

**Poor commit messages**:
- ✗ "fix stuff"
- ✗ "update"
- ✗ "changes" (no context)

### Step 7: Test Collaborator Render
If you've made major structural changes:
```bash
# Simulate a fresh clone
cd /tmp
git clone https://github.com/Rivulet-Research/nushagak-wqx.git nushagak-test
cd nushagak-test
quarto render --to html
```
**Expected**: Full render without errors

---

## Common Issues to Watch For

### Issue: "Functions that produce HTML output found in document targeting docx output"
**Likely cause**: Interactive map (Leaflet) in Chapter 03 when rendering DOCX  
**Solution**: Already fixed with `prefer-html: true` in `_quarto.yml`; no action needed  
**Test**: `quarto render --to docx` should complete without errors

### Issue: "Unknown directive or role: ..."
**Likely cause**: Markdown syntax error or unsupported Quarto directive  
**Solution**: Check for unmatched backticks, incorrect callout syntax, or misspelled directives  
**Example fix**: `:::{.callout-note}` (correct) vs `:::{.note}` (incorrect)

### Issue: "Could not find file: chapters/xyz.qmd"
**Likely cause**: Broken path in `_quarto.yml` or file deleted  
**Solution**: Verify chapter exists and path is correct  
**Test**: `ls chapters/xyz.qmd`

### Issue: "`ggplot2` not found" error during render
**Likely cause**: Package not installed in collaborator's R environment  
**Solution**: Add to GitHub Actions workflow (already done for `dataRetrieval`, `dplyr`, `ggplot2`)  
**Test locally**: `install.packages("ggplot2")`

### Issue: Git shows 1000+ files as modified
**Likely cause**: Line ending conversion (CRLF vs LF)  
**Solution**: `git config core.autocrlf true` before cloning  
**Recovery**: `git checkout -- .` to reset, then reconfigure

---

## Final Checks Before git push

```bash
# 1. Stage your changes
git add chapters/
git add README.md
git add COLLABORATOR_QUICK_START.md
git add GITHUB_PUBLISH_CHECKLIST.md
# (or: git add -A  for all changes)

# 2. Review what you're committing
git status

# 3. Commit with a message
git commit -m "Update Chapter X: [specific change]"

# 4. Verify the commit
git log --oneline -5

# 5. BEFORE pushing, run render one more time
quarto render --to html

# 6. If render successful, push
git push origin main
```

---

## After Pushing

1. **Wait 1–2 minutes** for GitHub Actions workflow to complete
2. **Check workflow status**: https://github.com/Rivulet-Research/nushagak-wqx/actions
3. **Verify deployment**: https://rivulet-research.github.io/nushagak-wqx/ (should reflect your changes)
4. **Test DOCX download**: Click "Download DOCX" in sidebar (should be recent)

**If workflow fails**:
- Click the failed workflow run to see error logs
- Fix the issue locally: `quarto render --to html`
- Push a corrective commit

---

## Safety Net: Reverting a Bad Push

If you accidentally push broken code:

```bash
# Option 1: Revert the last commit (keeps history)
git revert HEAD
git push origin main

# Option 2: Reset to previous commit (destructive—use with caution)
git reset --hard HEAD~1
git push -f origin main  # Force push (only if no one else has pulled yet)
```

**Better to prevent than revert**: Use this checklist before every push!

---

## Template for Regular Contributors

Copy this into a shell script for easy access:

```bash
#!/bin/bash
# pre-push-check.sh
cd "$(git rev-parse --show-toplevel)"

echo "🔍 Running pre-push verification..."
echo

echo "1️⃣  Testing render..."
quarto render --to html > /tmp/render.log 2>&1
if [ $? -eq 0 ]; then
  echo "   ✅ Render successful"
else
  echo "   ❌ Render failed"
  tail /tmp/render.log
  exit 1
fi

echo "2️⃣  Checking for TODO/FIXME..."
if grep -r "TODO\|FIXME\|XXX" chapters/ --include="*.qmd" > /dev/null; then
  echo "   ⚠️  Found TODO/FIXME comments"
else
  echo "   ✅ No incomplete markers"
fi

echo "3️⃣  Checking Git status..."
echo "   $(git status --short | wc -l) files modified"

echo
echo "✅ Pre-push verification complete. Ready to commit and push!"
```

**To use**:
```bash
chmod +x pre-push-check.sh
./pre-push-check.sh
```

---

**Last updated**: October 3, 2026  
**Maintained by**: Benjamin Meyer
