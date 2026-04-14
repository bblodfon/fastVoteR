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
  shuffle_candidates = TRUE
)
```

## Arguments

- voters:

  (`list`)  
  A list of subsets, where each subset contains the candidates approved
  or selected by a voter.

- candidates:

  (`character`)  
  A vector of all candidates to be ranked.

- weights:

  (`numeric`)  
  A numeric vector of weights representing each voter's influence.
  Larger weight, higher influence. Must have the same length as
  `voters`. If `NULL` (default), all voters are assigned equal weights
  of 1, representing equal influence.

- committee_size:

  (`integer(1)`)  
  Number of top candidates to include in the ranking. Default (`NULL`)
  includes all candidates. For sequential methods such as `"seq_pav"`
  and `"seq_phragmen"`, this parameter can speed up computation by
  limiting the selection process to only the top N candidates, instead
  of generating a complete ranking. In other methods (e.g., `"sav"` or
  `"av"`), this parameter simply filters the final output to include
  only the top N candidates from the complete ranking.

- method:

  (`character(1)`)  
  The ranking voting method to use. Must be one of: `"av"`, `"sav"`,
  `"seq_pav"`, `"seq_phragmen"`. See Details.

- borda_score:

  (`logical(1)`)  
  Whether to calculate and include Borda scores in the output. See
  Details. Default is `TRUE`.

- shuffle_candidates:

  (`logical(1)`)  
  Whether to shuffle the candidates randomly before computing the
  ranking. Shuffling ensures consistent random tie-breaking across
  methods and prevents deterministic biases when candidates with equal
  scores are encountered. Default is `TRUE`. Set to `FALSE` if
  deterministic ordering of candidates is preferred.

## Value

A
[data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html)
with columns:

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

This method implements several consensus-based ranking methods, where
voters express preferences for candidates. The input framework
considers:

- **Voters**: A list where each element represents the preferences
  (subsets of candidates) of a single voter.

- **Candidates**: A vector of all possible candidates. This vector is
  shuffled before processing to enforce random tie-breaking across
  methods.

- **Weights**: A numeric vector specifying the *influence* of each
  voter. Equal weights indicate all voters contribute equally; different
  weights can reflect varying voter importance.

The following methods are supported for ranking candidates:

- `"av"`: **Approval Voting (AV)** ranks candidates based on the number
  of voters approving them.

- `"sav"`: **Satisfaction Approval Voting (SAV)** ranks candidates by
  normalizing approval scores based on the size of each voter's approval
  set. Voters who approve more candidates contribute a lesser score to
  the individual approved candidates.

- `"seq_pav"`: **Sequential Proportional Approval Voting (PAV)** builds
  a committee by iteratively maximizing a proportionality-based
  satisfaction score. The **PAV score** is a metric that calculates the
  weighted sum of harmonic numbers corresponding to the number of
  elected candidates supported by each voter, reflecting the overall
  satisfaction of voters in a committee selection process.

- `"seq_phragmen"`: **Sequential Phragmen's Rule** selects candidates to
  balance voter representation by distributing "loads" evenly. The rule
  iteratively selects the candidate that results in the smallest
  increase in voter load. This approach is suitable for scenarios where
  a balanced representation is desired, as it seeks to evenly distribute
  the "burden" of representation among all voters.

All methods have weighted versions which consider voter weights.

To allow for method-agnostic comparisons of rankings, we calculate the
**borda scores** for each method as: \$\$s\_{borda} = (p - i) / (p -
1)\$\$ where \\p\\ is the total number of candidates, and \\i\\ is the
candidate's rank.

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
#>    candidate score norm_score borda_score
#>       <char> <num>      <num>       <num>
#> 1:        V3     3       0.75        1.00
#> 2:        V1     2       0.50        0.75
#> 3:        V2     2       0.50        0.50
#> 4:        V4     2       0.50        0.25
#> 5:        V5     0       0.00        0.00

# Approval voting (voters unequal)
rank_candidates(voters, candidates, weights)
#>    candidate score norm_score borda_score
#>       <char> <num>      <num>       <num>
#> 1:        V3   4.4  0.8301887        1.00
#> 2:        V1   3.6  0.6792453        0.75
#> 3:        V4   2.0  0.3773585        0.50
#> 4:        V2   1.7  0.3207547        0.25
#> 5:        V5   0.0  0.0000000        0.00

# Satisfaction Approval voting (voters unequal, no borda score)
rank_candidates(voters, candidates, weights, method = "sav", borda_score = FALSE)
#>    candidate     score norm_score
#>       <char>     <num>      <num>
#> 1:        V3 2.0166667  0.8175676
#> 2:        V1 1.6166667  0.6554054
#> 3:        V2 0.8500000  0.3445946
#> 4:        V4 0.8166667  0.3310811
#> 5:        V5 0.0000000  0.0000000

# Sequential Proportional Approval voting (voters equal, no borda score)
rank_candidates(voters, candidates, method = "seq_pav", borda_score = FALSE)
#>    candidate
#>       <char>
#> 1:        V3
#> 2:        V4
#> 3:        V2
#> 4:        V1
#> 5:        V5

# Sequential Phragmen's Rule (voters equal)
rank_candidates(voters, candidates, method = "seq_phragmen", borda_score = FALSE)
#>    candidate
#>       <char>
#> 1:        V3
#> 2:        V2
#> 3:        V1
#> 4:        V4
#> 5:        V5
```
