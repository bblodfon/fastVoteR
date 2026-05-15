# Sequential Proportional Approval Voting

**Sequential Proportional Approval Voting** (SeqPAV) is a multi-winner
method that builds a committee by iteratively maximizing a
proportionality-based satisfaction score. After each selection, the
weights of voters who approved the chosen candidate are reduced, which
promotes proportional representation. The **PAV score** is computed as
the weighted sum of harmonic numbers based on how many elected
candidates each voter supports. The process continues until the
specified committee size is reached or all candidates are ranked.

This function uses an internal C++ implementation for efficient
computation.

## Usage

``` r
seq_pav(
  voters,
  candidates,
  weights = NULL,
  committee_size = NULL,
  borda_score = TRUE,
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
  Number of top-ranked candidates to return. Default (`NULL`) returns
  all candidates.

- borda_score:

  (`logical(1)`)  
  Whether to include a `borda_score` column in the output, which
  provides a normalized score based on the candidate's rank. If `TRUE`
  (default), the `borda_score` is calculated as \\(p - i) / (p - 1)\\,
  where \\p\\ is the total number of candidates and \\i\\ is the
  candidate's rank.

- check:

  (`logical(1)`)  
  Whether to run additional voter-integrity checks. When `TRUE`, each
  voter must approve at least one candidate, approvals must be unique
  per voter, and all approved candidates must appear in `candidates`.
  Use `FALSE` to skip these checks when inputs are known to be valid.

## Value

A `data.frame` with columns:

- `"candidate"`: Candidate names.

- `"borda_score"`: Borda scores for method-agnostic comparison, ranging
  in \\\[0,1\]\\, where the top candidate receives a score of 1 and the
  lowest-ranked candidate receives a score of 0, based on the total
  number of candidates.

Candidates are ordered by the sequence in which they were selected.

## See also

Other voting methods:
[`av()`](https://bblodfon.github.io/fastVoteR/reference/av.md),
[`sav()`](https://bblodfon.github.io/fastVoteR/reference/sav.md),
[`seq_phragmen()`](https://bblodfon.github.io/fastVoteR/reference/seq_phragmen.md)
