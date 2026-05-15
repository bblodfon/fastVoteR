# Rank candidates based on voter preferences

Calculates a ranking of candidates based on voters' preferences.
Approval-Based Committe (ABC) rules are based on Lackner et al. (2023).
For an example use in Machine Learning for ensemble feature selection,
see Zobolas et al. (2026).

## Usage

``` r
rank_candidates(
  voters,
  candidates,
  weights = NULL,
  committee_size = NULL,
  method = "av",
  borda_score = TRUE,
  shuffle_candidates = TRUE,
  check = FALSE
)
```

## Arguments

- voters:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  A list of subsets (`character` vectors), where each subset contains
  the candidates approved or selected by a voter.

- candidates:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  A vector of all candidates to be ranked.

- weights:

  (`numeric()|NULL`)  
  A numeric vector of non-negative weights representing each voter's
  influence. Larger weight, higher influence. Must have the same length
  as `voters`. If `NULL` (default), all voters are assigned equal
  weights of 1, representing equal influence.

- committee_size:

  (`integer(1)|NULL`)  
  Number of top candidates to include in the ranking. Default (`NULL`)
  includes all candidates.

- method:

  (`character(1)`)  
  The ranking voting method to use. Must be one of: `"av"`, `"sav"`,
  `"seq_pav"`, `"seq_phragmen"`. See Details.

- borda_score:

  (`logical(1)`)  
  Whether to include a `borda_score` column in the output, which
  provides a normalized score based on the candidate's rank. If `TRUE`
  (default), the `borda_score` is calculated as \\(p - i) / (p - 1)\\,
  where \\p\\ is the total number of candidates and \\i\\ is the
  candidate's rank.

- shuffle_candidates:

  (`logical(1)`)  
  Whether to randomly shuffle candidates before ranking. This provides
  random tie-breaking and avoids deterministic bias when scores are
  equal. Default is `TRUE`.

- check:

  (`logical(1)`)  
  Whether to run additional voter-integrity checks. When `TRUE`, each
  voter must approve at least one candidate, approvals must be unique
  per voter, and all approved candidates must appear in `candidates`.
  Use `FALSE` to skip these checks when inputs are known to be valid.

## Value

A `data.frame` with columns:

- `"candidate"`: Candidate names.

- `"score"`: Scores assigned to each candidate based on the selected
  method (if applicable).

- `"norm_score"`: Normalized scores (if applicable), scaled to the range
  \\\[0,1\]\\, which can be loosely interpreted as **selection
  probabilities** (see Meinshausen et al. (2010) for an example in
  Machine Learning research where the goal is to perform stable feature
  selection).

- `"borda_score"`: Borda scores for method-agnostic comparison, ranging
  in \\\[0,1\]\\, where the top candidate receives a score of 1 and the
  lowest-ranked candidate receives a score of 0.

Candidates are ordered by decreasing `"score"`, or by `"borda_score"` if
the method returns only rankings.

## Details

We implement several consensus-based ranking methods, where voters
express preferences for candidates. The framework has three components:

- **Voters**: A list where each element is the set of approved
  candidates for a single voter.

- **Candidates**: A character vector of all possible candidates. This
  vector can be shuffled to randomize tie-breaking across methods.

- **Weights**: A numeric vector giving each voter’s influence. Equal
  weights mean equal influence; differing weights reflect varying
  importance.

This function is a thin wrapper that dispatches to method-specific
implementations. Supported methods include:

1.  Approval Voting (`method = "av"`), calls
    [`av()`](https://bblodfon.github.io/fastVoteR/reference/av.md)

2.  Satisfaction Approval Voting (`method = "sav"`), calls
    [`sav()`](https://bblodfon.github.io/fastVoteR/reference/sav.md)

3.  Sequential Proportional Approval Voting (`method = "seq_pav"`),
    calls
    [`seq_pav()`](https://bblodfon.github.io/fastVoteR/reference/seq_pav.md)

4.  Sequential Phragmen’s Rule (`method = "seq_phragmen"`), calls
    [`seq_phragmen()`](https://bblodfon.github.io/fastVoteR/reference/seq_phragmen.md)

All methods support voter weights.

For method-agnostic comparisons, we compute **borda scores**, which map
each candidate’s rank to a normalized scale across methods that may
otherwise return different score scales or only ordinal rankings.

For sequential methods such as `"seq_pav"` and `"seq_phragmen"`, the
`committee_size` parameter can speed up computation by selecting only
the top \\N\\ candidates instead of producing a full ranking. For
non-sequential methods (e.g., `"sav"` or `"av"`), it simply truncates
the final ranking to the top \\N\\ candidates.

## References

Lackner M, Skowron P (2023). *Multi-Winner Voting with Approval
Preferences*. Springer Nature, 121 p.
[doi:10.1007/978-3-031-09016-5](https://doi.org/10.1007/978-3-031-09016-5)
.

Zobolas J, George A, Lopez A, Fischer S, Becker M, Aittokallio T (2026).
"Prognostic biomarker discovery in pancreatic cancer through hybrid
ensemble feature selection and multi-omics data." *BioData Mining*.
[doi:10.1186/s13040-026-00546-0](https://doi.org/10.1186/s13040-026-00546-0)
.

Meinshausen N, Buhlmann P (2010). "Stability Selection." *Journal of the
Royal Statistical Society Series B: Statistical Methodology*, 72(4),
417-473.
[doi:10.1111/J.1467-9868.2010.00740.X](https://doi.org/10.1111/J.1467-9868.2010.00740.X)
.

## Examples

``` r
# 5 candidates
candidates = paste0("V", seq_len(5))

# 4 voters
voters = list(
  c("V3", "V1", "V4"),
  c("V3", "V1"),
  c("V3", "V2"),
  c("V2", "V4")
)

# voter weights
weights = c(1.1, 2.5, 0.8, 0.9)

# Approval voting (all voters equal)
rank_candidates(voters, candidates)
#>   candidate score norm_score borda_score
#> 1        V3     3       0.75        1.00
#> 2        V1     2       0.50        0.75
#> 3        V2     2       0.50        0.50
#> 4        V4     2       0.50        0.25
#> 5        V5     0       0.00        0.00

# Approval voting (voters unequal)
rank_candidates(voters, candidates, weights)
#>   candidate score norm_score borda_score
#> 1        V3   4.4  0.8301887        1.00
#> 2        V1   3.6  0.6792453        0.75
#> 3        V4   2.0  0.3773585        0.50
#> 4        V2   1.7  0.3207547        0.25
#> 5        V5   0.0  0.0000000        0.00

# Satisfaction Approval voting (voters unequal, no borda score)
rank_candidates(voters, candidates, weights, method = "sav", borda_score = FALSE)
#>   candidate     score norm_score
#> 1        V3 2.0166667  0.8175676
#> 2        V1 1.6166667  0.6554054
#> 3        V2 0.8500000  0.3445946
#> 4        V4 0.8166667  0.3310811
#> 5        V5 0.0000000  0.0000000

# Sequential Proportional Approval voting (voters equal, no borda score)
rank_candidates(voters, candidates, method = "seq_pav", borda_score = FALSE)
#>   candidate
#> 1        V3
#> 2        V4
#> 3        V2
#> 4        V1
#> 5        V5

# Sequential Phragmen's Rule (voters equal)
rank_candidates(voters, candidates, method = "seq_phragmen", borda_score = FALSE)
#>   candidate
#> 1        V3
#> 2        V2
#> 3        V1
#> 4        V4
#> 5        V5
```
