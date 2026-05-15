# Changelog

## fastVoteR 0.0.3

- Remove the `data.table` dependency
- Improve
  [`rank_candidates()`](https://bblodfon.github.io/fastVoteR/reference/rank_candidates.md)
  documentation
- Export internal R functions that wrap C++ code for easier reuse
- Add extra `check` parameter to all voting functions and
  [`rank_candidates()`](https://bblodfon.github.io/fastVoteR/reference/rank_candidates.md)

## fastVoteR 0.0.2

CRAN release: 2026-04-14

- Add contributing guidelines
- Change license to MIT
- Small internal doc updates/fixes
- Remove `mlr3misc` dependency
- Add sections in `pkgdown` website
- Refine `README`

## fastVoteR 0.0.1

CRAN release: 2024-11-27

- Initial CRAN submission.
- Add
  [`rank_candidates()`](https://bblodfon.github.io/fastVoteR/reference/rank_candidates.md)
  with support for 4 ranking methods: AV, SAV, sequential PAV and
  sequential Phragmen.
