# Cut a release (version dance)

Never pick the number alone: decide it first.

1. On `devel`, everything merged and green.
2. Squash `devel` into `main`:
       git switch main && git merge --squash devel
       git commit -m "release: vX.Y.Z"
3. Tag and push:
       git tag vX.Y.Z && git push origin main vX.Y.Z
4. Bring `main` back into `devel`:
       git switch devel && git merge main && git push

Julia binding with a `_jll`? Release the core first, then the jll
(`build_tarballs.jl`, `jll-vX.Y.Z` tag).
