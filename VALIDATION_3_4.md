# Opt 3.4: validation and review notes

This is a development revision for review, not a release certification.
The validated combinatorial indexing and public matrix-coefficient representation
are unchanged. Corrections and memory work share the multiplication kernel and
are committed together; construction timing and validation are separate changes.

## Run the final checks

Use a fresh MATLAB process with only this ROLMIP implementation on the path.
Add YALMIP and SeDuMi first, then, from the repository root:

```matlab
addpath('validation');
run_release_tests;
```

The runner requires both dependencies; it does not silently skip the generated
SDP solve. It runs the 21 supplied checks, regression tests (including export
with `codegen=on` and solving the generated `min P, P>=2` example), cache/chunk
checks, and construction timer tests. Tests clear YALMIP state/cache and must
not be run during an existing export or while preserving an interactive model.
The memory test explicitly selects the random generator so it also works after
SeDuMi activates MATLAB's legacy random generator. Timer tests use the caller's
configured paths rather than a private installation path.

Final local check environment: MATLAB R2023b Update 5, YALMIP 20250626, SeDuMi.
The suites passed on 19 October 2026, including both codegen modes, the actual
exported SDP solve, and the timer's V/L statistics. Strict-inequality warnings
are expected and checked by the regression suite.

## Database campaign

160 quadratic-stable systems: continuous/discrete time, orders and vertex
counts 2 through 5, five systems per combination. There are 420 H2/H-infinity
conditions, including affine Lyapunov matrices, bounded parameter variation
and a small Polya subset. Continuous H2 uses an explicitly identified D=0
variant in memory; its bounds do not apply to the original nonzero-D plants.

All 420 complete affine constraint models agree with the local reference,
including V/L. Direct solver results: 417 accepted without warning, two feasible
with solver warnings, and one rejected by residual checks. For the latter,
a certificate from its bounded-rate condition also passes the frozen-condition
checks. Thus all 420 have numerically accepted feasible bounds, but the warning
and transferred-certificate cases do not establish optimality. The checks use
floating-point residuals, not interval proofs.

Reference: `fe03260f79b10dc5383b3af0a9a58e3fcf867583`, with the deliberately
selected local `diff.m` rounding/bounds behavior. This is not an unmodified
checkout of that commit. Opt starting point: `e34630436e7700e2e3c0a61af359461a701c1b58`.

## Parser performance

Warm caches, two warmups and seven timed samples per case; report median times.
Reference and Opt run in separate processes; Opt uses `codegen=off`, reference
retains opcode construction. No solver time is included. The 420-case timing
campaign shared the machine with another MATLAB session; small differences
should not be overinterpreted. These figures compare configurations, not just
one isolated algorithm.

| Campaign | Reference | Opt | Reference / Opt |
| --- | ---: | ---: | ---: |
| 420 models, sum of case medians | 12.421116 s | 7.332600 s | 1.694 |
| Degree study, 320 main models, degrees 0–4 | 29.034367 s | 12.150623 s | 2.390 |
| Multiplication, mean of 160 case medians | 6.025244 ms | 2.614844 ms | 2.304 |
| Homogenization, mean of 160 case medians | 2.183633 ms | 0.310010 ms | 7.044 |
| Constraint construction, mean of 320 case medians | 13.588384 ms | 7.933300 ms | 1.713 |
| Direct YALMIP control, same grouping/order | 7.486006 ms | 7.421797 ms | 1.009 |

The degree campaign includes 32 additional robustness cases (352 total), all
faster with Opt. Aggregate speedup grows from 1.97 at degree 0 to 2.59 at degree
4 in the main study. Maximum relative affine-model difference is 2.961e-16;
bitwise identity is not universal. In the isolated multiplication study, five
small degree-zero cases are 5–20 microseconds slower. Degree-zero homogenization
is a no-elevation control. The operation workloads overlap and must not be
added to estimate total parser time. The direct YALMIP control has no consistent
speed advantage attributable to ROLMIP.

## Reproducibility and remaining limits

- Standalone checks above need no private system database.
- `validation/` also preserves the research campaign scripts. They expect the
  original workspace layout (`ROLMIP_opt_34`, `ROLMIP_github`, `output` and the
  two MAT databases) and include local dependency paths to be adapted. Report
  scripts expect saved campaign manifests/certificates and are not generic
  one-command benchmarks from a fresh clone. See the three validation READMEs.
- Databases, full MAT results, logs and PDF reports remain in the local workspace;
  they are not part of this change. Compact aggregate results are included under
  `validation/results/` as evidence for the figures above.
- `codegen=on` must be enabled before rebuilding expressions for export; enabling
  it afterwards cannot restore discarded opcodes. All manual exports were not
  tested. The new timer reports wall time and SDP rows, not exclusive kernel time
  or all scalar inequalities; see the API documentation.
- Cache payload limits do not cap total MATLAB memory. Direct product-table
  requests and lifting still allocate complete maps. Very large integer ranks,
  all legacy operators, Octave and other MATLAB versions remain outside the
  current validation scope. Historical Octave/R2026a claims in the original
  Opt notes are not fresh certification of this revision.
