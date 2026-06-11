# Release Checklist

## Versioning

This project follows [Semantic Versioning](https://semver.org):
- **Patch** (0.1.x) — bug fixes
- **Minor** (0.x.0) — new features, backward compatible
- **Major** (x.0.0) — breaking changes

## Branching

- `master` is always releasable
- Use short-lived branches for features and hotfixes, then merge into master
- Tags mark releases

```bash
git checkout -b feature/my-feature
# ... work ...
git checkout master
git merge feature/my-feature
```

## Steps to Release

1. Update `VERSION` in `fisk`
2. Update `CHANGELOG.md` — add a new section at the top for the new version
3. Commit and tag:
   ```bash
   git add .
   git commit -m "Release v0.x.x"
   git tag -a v0.x.x -m "v0.x.x"
   git push origin master --tags
   ```
4. Create a GitHub release:
   ```bash
   gh release create v0.x.x --notes-from-tag --title "v0.x.x"
   ```
