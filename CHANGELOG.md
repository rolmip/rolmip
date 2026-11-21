## Opt 3.4 (unreleased)

- Add `coeffs(P,'cell')` and `coefs(P,'cell')` for coefficient and exponent cells independent of monomial count.
- Warn with `ROLMIP:TrivialLMI` when ROLMIP constructs a constant coefficient inequality without decision variables.

- Let `discshift` use the cddmex binary directly without MPT3, with a MATLAB fallback for a two-vertex simplex and one step.

- Prune the internal enumeration of rate vertices in `diff` and handle fixed rates and single-vertex simplexes.

- Add `rolmip_volume` for volume, coordinate projections and central cuts of quadratic regions, with optional 2D and 3D plots.
- Support polynomial matrices on two-vertex simplexes in `rolmip_volume` for full regions and central cuts.

- Extend `rolmip_verify` to inspect complete YALMIP constraint sets, including SDP, elementwise and equality residuals, with explicit unsupported/unevaluable results.

- Add opt-in diagnostic sessions (`rolmip_check_begin`, `rolmip_check_report`, `rolmip_check_end`) with grouped issues and source locations; preserve constraint semantics.

- Add optional polynomial diagnostics, coefficient LMI provenance and numerical certificate verification (`rolmip_check`, `rolmip_lmi`, `rolmip_verify`).

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
