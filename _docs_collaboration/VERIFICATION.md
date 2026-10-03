# Pre-Push Verification

Run these checks before pushing to GitHub.

## Quick Checks (5 min)

```bash
# Test render
quarto render --to html

# Check for incomplete content
grep -r "TODO\|FIXME\|XXX" chapters/

# Verify git status
git status
```

If all three pass without errors, you're ready to push.

## Detailed Steps

### 1. Test render
```bash
quarto render --to html
```
Expected: Last line is `Output created: _book\index.html`

If render fails:
- Check R console for errors
- Verify package installation: `install.packages(c("dataRetrieval", "dplyr", "ggplot2"))`
- Check YAML syntax in `_quarto.yml`

### 2. Check for incomplete content
```bash
grep -r "TODO\|FIXME\|XXX" chapters/
```
Expected: Empty (no matches)

If found:
- Complete the item or document the gap in chapter text
- Do not commit incomplete sections

### 3. Verify HUC8 consistency
```bash
grep -r "five HUC\|19030305" chapters/ | grep -v excluded
```
Expected: Empty

If found:
- Update prose to reflect four Nushagak HUCs only
- Document Togiak exclusion if mentioned

### 4. Review git status
```bash
git status
```
Check that only intended files are modified. No accidentally deleted files.

### 5. Commit with descriptive message
```bash
git commit -m "Update Chapter X: specific change"
```

Good messages: "Update Chapter 05: Add temperature summary table"  
Poor messages: "fix stuff", "update"

### 6. Final render test
```bash
quarto render --to html
```

### 7. Push
```bash
git push origin main
```

---

## Common Issues & Fixes

**"Could not find package 'dataRetrieval'"**  
→ `install.packages("dataRetrieval")`

**"Unknown directive or role: ..."**  
→ Check for unmatched backticks, incorrect callout syntax

**"Functions that produce HTML output found in document targeting docx output"**  
→ Expected for interactive maps; no action needed

**"Could not find file: chapters/xyz.qmd"**  
→ Verify file exists (`ls chapters/xyz.qmd`) and path in `_quarto.yml` is correct

**All files show as modified after clone**  
→ Line ending issue: `git config core.autocrlf true`

---

## After Pushing

GitHub Actions will render automatically. Check status at:  
https://github.com/Rivulet-Research/nushagak-wqx/actions

Site updates at:  
https://rivulet-research.github.io/nushagak-wqx/

Typically live within 2–3 minutes.
