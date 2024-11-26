#' @title Rank candidates based on voter preferences
#'
#' @description
#' Calculates a ranking of candidates based on voters' preferences.
#' Approval-Based Committe (ABC) rules are based on Lackner et al. (2023).
#'
#' @details
#' This method implements several consensus-based ranking methods, where voters express preferences for candidates.
#' The input framework considers:
#' - **Voters**: A list where each element represents the preferences (subsets of candidates) of a single voter.
#' - **Candidates**: A vector of all possible candidates. This vector is shuffled before processing to enforce random tie-breaking across methods.
#' - **Weights**: A numeric vector specifying the *influence* of each voter. Equal weights indicate all voters contribute equally; different weights can reflect varying voter importance.
#'
#' The following methods are supported for ranking candidates:
#' - `"av"`: **Approval Voting (AV)** ranks candidates based on the number of voters approving them.
#' - `"sav"`: **Satisfaction Approval Voting (SAV)** ranks candidates by normalizing approval scores based on the size of each voter's approval set.
#' Voters who approve more candidates contribute a lesser score to the individual approved candidates.
#' - `"seq_pav"`: **Sequential Proportional Approval Voting (PAV)** builds a committee by iteratively maximizing a proportionality-based satisfaction score.
#' The **PAV score** is a metric that calculates the weighted sum of harmonic numbers corresponding to the number of elected candidates supported by each voter, reflecting the overall satisfaction of voters in a committee selection process.
#' - `"seq_phragmen"`: **Sequential Phragmen's Rule** selects candidates to balance voter representation by distributing "loads" evenly.
#' The rule iteratively selects the candidate that results in the smallest increase in voter load.
#' This approach is suitable for scenarios where a balanced representation is desired, as it seeks to evenly distribute the "burden" of representation among all voters.
#'
#' All methods have weighted versions which consider voter weights.
#'
#' To allow for method-agnostic comparisons of rankings, we calculate the **borda scores** for each method as:
#' \deqn{s_{borda} = (p - i) / (p - 1)}
#' where \eqn{p} is the total number of candidates, and \eqn{i} is the candidate's rank.
#'
#' @param voters (`list`) \cr
#'   A list of subsets, where each subset contains the candidates approved or selected by a voter.
#' @param candidates (`character`) \cr
#'   A vector of all candidates to be ranked.
#' @param weights (`numeric`) \cr
#'   A numeric vector of weights representing each voter's influence.
#'   Larger weight, higher influence.
#'   Must have the same length as `voters`.
#'   If `NULL` (default), all voters are assigned equal weights of 1, representing equal influence.
#' @param committee_size (`integer(1)`)\cr
#'   Number of top candidates to include in the ranking. Default (`NULL`) includes all candidates.
#'   For sequential methods such as `"seq_pav"` and `"seq_phragmen"`, this parameter can speed up computation by limiting the selection process to only the top N candidates, instead of generating a complete ranking.
#'   In other methods (e.g., `"sav"` or `"av"`), this parameter simply filters the final output to include only the top N candidates from the complete ranking.
#' @param method (`character(1)`) \cr
#'   The ranking voting method to use. Must be one of: `"av"`, `"sav"`, `"seq_pav"`, `"seq_phragmen"`.
#'   See Details.
#' @param borda_score (`logical(1)`) \cr
#'   Whether to calculate and include Borda scores in the output. See Details.
#'   Default is `TRUE`.
#' @param shuffle_candidates (`logical(1)`) \cr
#'   Whether to shuffle the candidates randomly before computing the ranking.
#'   Shuffling ensures consistent random tie-breaking across methods and prevents
#'   deterministic biases when candidates with equal scores are encountered.
#'   Default is `TRUE`. Set to `FALSE` if deterministic ordering of candidates is preferred.
#'
#' @return A [data.table::data.table] with columns:
#' - `"candidate"`: Candidate names.
#' - `"score"`: Scores assigned to each candidate based on the selected method (if applicable).
#' - `"norm_score"`: Normalized scores (if applicable), scaled to the range \eqn{[0,1]}, which can be loosely interpreted as **selection probabilities** (see Meinshausen et al. (2010) for an example in Machine Learning research where the goal is to perform stable feature selection).
#' - `"borda_score"`: Borda scores for method-agnostic comparison, ranging in \eqn{[0,1]}, where the top candidate receives a score of 1 and the lowest-ranked candidate receives a score of 0.
#'
#' Candidates are ordered by decreasing `"score"`, or by `"borda_score"` if the method returns only rankings.
#'
#' @references
#' `r mlr3misc::format_bib("meinshausen2010", "lackner2023")`
#'``
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
    shuffle_candidates = TRUE)
  {
  # input checks
  assert_choice(method, choices = c("av", "sav", "seq_pav", "seq_phragmen"))
  assert_list(voters, min.len = 1, types = "character", null.ok = FALSE, any.missing = FALSE)
  assert_character(candidates, min.len = 1, null.ok = FALSE, any.missing = FALSE)
  assert_int(committee_size, lower = 1, null.ok = TRUE)
  assert_flag(borda_score)
  assert_flag(shuffle_candidates)

  # check that all voted candidates are in the candidates list
  assert_subset(unique(unlist(voters)), choices = candidates)

  if (is.null(weights)) {
    # Assign equal weights to all voters
    weights = rep(1, length(voters))
  } else {
    # check: one weight per voter
    weights = assert_numeric(weights, len = length(voters))
  }

  # Shuffle candidates for consistent tie-breaking
  if (shuffle_candidates) {
    candidates = sample(candidates)
  }

  # Call the appropriate ranking method
  if (method == "av") {
    res = av(voters, candidates, weights, committee_size, borda_score)
  } else if (method == "sav") {
    res = sav(voters, candidates, weights, committee_size, borda_score)
  } else if (method == "seq_pav") {
    res = seq_pav(voters, candidates, weights, committee_size, borda_score)
  } else if (method == "seq_phragmen") {
    res = seq_phragmen(voters, candidates, weights, committee_size, borda_score)
  }

  res
}
