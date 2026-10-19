## Opt 3.4 (unreleased)

- Correct derivative bounds handling, exponent validation, dimensions and export preflight.
- Bound shared table cache storage and process polynomial products in chunks.
- Add `rolmip_begin` / `[time,V,L] = rolmip_end(LMIs)` for construction timing and model statistics.
- Add regression, memory and timer tests, with documented database validation and benchmarks.
- Preserve the validated combinatorial monomial indexing and public coefficient representation.

- [Version 3.3:](https://github.com/rolmip/rolmip/releases/tag/3.3) Compact polytope verification in diff; refactor of simplex representation in diff.
- [Version 3.2:](https://github.com/rolmip/rolmip/releases/tag/3.2) Bug corrections.
- [Version 3.1:](https://github.com/rolmip/rolmip/releases/tag/3.1) Bug corrections; Compatibility with Octave.
- [Version 3.0:](https://github.com/rolmip/rolmip/releases/tag/3.0) Bug corrections; Manual update.
- [Version 3.0a:](https://github.com/rolmip/rolmip/releases/tag/3.0a) Insertion of the rolmipvar variable, which brings new functionalities; Bug corrections.
- [Version 2.3:](https://github.com/rolmip/rolmip/releases/tag/2.3) Bug corrections.
- [Version 2.2:](https://github.com/rolmip/rolmip/releases/tag/2.2) Bug corrections.
- [Version 2.1:](https://github.com/rolmip/rolmip/releases/tag/2.1) Easier definitions for constant matrices using poly_struct; Adaptation of the LMI definitions to the newest YALMIP version (thanks to Hugo Tadashi); Bug corrections.
- [Version 2.0:](https://github.com/rolmip/rolmip/releases/tag/2.0) Implementation of the multi-simplex structure; Insertion of the procedure affine2poly.m, to convert an affinely parameter-dependent polynomial into the multi-simplex structure.
- [Version 1.1:](https://github.com/rolmip/rolmip/releases/tag/1.1) Insertion of the syntax to choose, in the polynomial structure definition, to which monomial each matrix is related.
- [Version 1.0:](https://github.com/rolmip/rolmip/releases/tag/1.0) First release.
