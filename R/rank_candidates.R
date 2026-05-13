#' @title Rank candidates based on voter preferences
#'
#' @description
#' Calculates a ranking of candidates based on voters' preferences.
#' Approval-Based Committe (ABC) rules are based on Lackner et al. (2023).
#' For an example use in Machine Learning for ensemble feature selection,
#' see Zobolas et al. (2026).
#'
#' @details
#' We implement several consensus-based ranking methods, where voters express
#' preferences for candidates.
#' The framework has three components:
#' - **Voters**: A list where each element is the set of approved candidates for
#'   a single voter.
#' - **Candidates**: A character vector of all possible candidates. This vector
#'   can be shuffled to randomize tie-breaking across methods.
#' - **Weights**: A numeric vector giving each voter’s influence. Equal weights
#'   mean equal influence; differing weights reflect varying importance.
#'
#' This function is a thin wrapper that dispatches to method-specific implementations.
#' Supported methods include:
#'
#' 1. Approval Voting (`method = "av"`), calls [av()]
#' 2. Satisfaction Approval Voting (`method = "sav"`), calls [sav()]
#' 3. Sequential Proportional Approval Voting (`method = "seq_pav"`), calls [seq_pav()]
#' 4. Sequential Phragmen’s Rule (`method = "seq_phragmen"`), calls [seq_phragmen()]
#'
#' All methods support voter weights.
#'
#' For method-agnostic comparisons, we compute **borda scores**, which map each
#' candidate’s rank to a normalized scale across methods that may otherwise
#' return different score scales or only ordinal rankings.
#'
#' For sequential methods such as `"seq_pav"` and `"seq_phragmen"`, the
#' `committee_size` parameter can speed up computation by selecting only the top
#' \eqn{N} candidates instead of producing a full ranking. For non-sequential methods
#' (e.g., `"sav"` or `"av"`), it simply truncates the final ranking to the top
#' \eqn{N} candidates.
#'
#' @template param_voters
#' @template param_candidates
#' @template param_weights
#' @template param_committee_size
#' @template param_borda_score
#' @template param_check
#' @param method (`character(1)`) \cr
#'  The ranking voting method to use. Must be one of: `"av"`, `"sav"`, `"seq_pav"`,
#'  `"seq_phragmen"`. See Details.
#' @param shuffle_candidates (`logical(1)`) \cr
#'  Whether to randomly shuffle candidates before ranking.
#'  This provides random tie-breaking and avoids deterministic bias when scores
#'  are equal. Default is `TRUE`.
#'
#' @return A `data.frame` with columns:
#' - `"candidate"`: Candidate names.
#' - `"score"`: Scores assigned to each candidate based on the selected method
#' (if applicable).
#' - `"norm_score"`: Normalized scores (if applicable), scaled to the range
#' \eqn{[0,1]}, which can be loosely interpreted as **selection probabilities**
#' (see Meinshausen et al. (2010) for an example in Machine Learning research
#' where the goal is to perform stable feature selection).
#' - `"borda_score"`: Borda scores for method-agnostic comparison, ranging in
#' \eqn{[0,1]}, where the top candidate receives a score of 1 and the lowest-ranked
#' candidate receives a score of 0.
#'
#' Candidates are ordered by decreasing `"score"`, or by `"borda_score"` if the
#' method returns only rankings.
#'
#' @references
#' Lackner M, Skowron P (2023). *Multi-Winner Voting with Approval Preferences*.
#' Springer Nature, 121 p. \doi{10.1007/978-3-031-09016-5}.
#'
#' Zobolas J, George A, Lopez A, Fischer S, Becker M, Aittokallio T (2026).
#' "Prognostic biomarker discovery in pancreatic cancer through hybrid ensemble
#' feature selection and multi-omics data." *BioData Mining*. \doi{10.1186/s13040-026-00546-0}.
#'
#' Meinshausen N, Buhlmann P (2010). "Stability Selection." *Journal of the Royal
#' Statistical Society Series B: Statistical Methodology*, 72(4), 417-473.
#' \doi{10.1111/J.1467-9868.2010.00740.X}.
#'
#' @examples
#' # 5 candidates
#' candidates = paste0("V", seq_len(5))
#'
#' # 4 voters
#' voters = list(
#'   c("V3", "V1", "V4"),
#'   c("V3", "V1"),
#'   c("V3", "V2"),
#'   c("V2", "V4")
#' )
#'
#' # voter weights
#' weights = c(1.1, 2.5, 0.8, 0.9)
#'
#' # Approval voting (all voters equal)
#' rank_candidates(voters, candidates)
#'
#' # Approval voting (voters unequal)
#' rank_candidates(voters, candidates, weights)
#'
#' # Satisfaction Approval voting (voters unequal, no borda score)
#' rank_candidates(voters, candidates, weights, method = "sav", borda_score = FALSE)
#'
#' # Sequential Proportional Approval voting (voters equal, no borda score)
#' rank_candidates(voters, candidates, method = "seq_pav", borda_score = FALSE)
#'
#' # Sequential Phragmen's Rule (voters equal)
#' rank_candidates(voters, candidates, method = "seq_phragmen", borda_score = FALSE)
#'
#' @export
rank_candidates = function(
    voters,
    candidates,
    weights = NULL,
    committee_size = NULL,
    method = "av",
    borda_score = TRUE,
    shuffle_candidates = TRUE,
    check = FALSE)
  {
  assert_choice(method, choices = c("av", "sav", "seq_pav", "seq_phragmen"))
  assert_flag(shuffle_candidates)

  # Shuffle candidates for consistent tie-breaking
  if (shuffle_candidates) {
    candidates = sample(candidates)
  }

  # Call the appropriate ranking method
  if (method == "av") {
    res = av(voters, candidates, weights, committee_size, borda_score, check)
  } else if (method == "sav") {
    res = sav(voters, candidates, weights, committee_size, borda_score, check)
  } else if (method == "seq_pav") {
    res = seq_pav(voters, candidates, weights, committee_size, borda_score, check)
  } else if (method == "seq_phragmen") {
    res = seq_phragmen(voters, candidates, weights, committee_size, borda_score, check)
  }

  res
}
