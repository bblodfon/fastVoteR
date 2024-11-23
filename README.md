
# fastVoteR

<!-- badges: start -->

[![R-CMD-check](https://github.com/bblodfon/fastVoteR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bblodfon/fastVoteR/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/bblodfon/fastVoteR/graph/badge.svg)](https://app.codecov.io/gh/bblodfon/fastVoteR)
<!-- badges: end -->

`fastVoteR` is an R package (still under development) with Efficient
[Rcpp](https://github.com/rcppcore/rcpp) Voting Methods for Committee
Selection in R.

Still **under development**.

## Installation

Development version:

``` r
# install.packages("pak")
pak::pak("bblodfon/fastVoteR")
```

## Example

``` r
library(fastVoteR)

# 5 candidates
candidates = paste0("V", seq_len(5))
candidates
#> [1] "V1" "V2" "V3" "V4" "V5"

# 4 voters
# "V3" candidate voted by all, "V1" by half, "V2", "V4" once, "V5" was not voted at all
voters = list(
  c("V3", "V1", "V4"),
  c("V3", "V1"),
  c("V3", "V2"),
  c("V2", "V4")
)
voters
#> [[1]]
#> [1] "V3" "V1" "V4"
#> 
#> [[2]]
#> [1] "V3" "V1"
#> 
#> [[3]]
#> [1] "V3" "V2"
#> 
#> [[4]]
#> [1] "V2" "V4"

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

# Satisfaction Approval voting (voters unequal)
rank_candidates(voters, candidates, weights, method = "sav")
#>    candidate     score norm_score borda_score
#>       <char>     <num>      <num>       <num>
#> 1:        V3 2.0166667  0.8175676        1.00
#> 2:        V1 1.6166667  0.6554054        0.75
#> 3:        V2 0.8500000  0.3445946        0.50
#> 4:        V4 0.8166667  0.3310811        0.25
#> 5:        V5 0.0000000  0.0000000        0.00

# Sequential Proportional Approval voting (voters equal)
rank_candidates(voters, candidates, method = "seq_pav")
#>    candidate borda_score
#>       <char>       <num>
#> 1:        V3        1.00
#> 2:        V4        0.75
#> 3:        V2        0.50
#> 4:        V1        0.25
#> 5:        V5        0.00
```
