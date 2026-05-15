# All the following R methods are wrappers for the Rcpp implementations

#' @title Approval Voting
#'
#' @description
#' **Approval Voting** (AV) ranks candidates based on the number of voters approving them.
#'
#' This function uses an internal C++ implementation for efficient computation.
#' For equal weights, a faster R implementation is used.
#'
#' @template param_voters
#' @template param_candidates
#' @template param_weights
#' @template param_committee_size
#' @template param_borda_score
#' @template param_check
#'
#' @return A `data.frame` with columns:
#' - `"candidate"`: Candidate names.
#' - `"score"`: Approval scores.
#' - `"norm_score"`: Normalized scores, scaled to the range \eqn{[0,1]}.
#' - `"borda_score"`: Borda scores for method-agnostic comparison, ranging in
#' \eqn{[0,1]}, where the top candidate receives a score of 1 and the lowest-ranked
#' candidate receives a score of 0, based on the total number of candidates.
#'
#' Candidates are ordered by decreasing `"score"`.
#' @family voting methods
#' @export
av = function(
  voters,
  candidates,
  weights = NULL,
  committee_size = NULL,
  borda_score = TRUE,
  check = FALSE
) {
  assert_inputs(voters, candidates, weights, committee_size, borda_score, check)

  if (is.null(weights)) {
    # Assign equal weights to all voters
    weights = rep(1, length(voters))
  }

  if (check) {
    check_voters(voters, candidates)
  }

  # faster R version in case of equal weights
  if (all(weights == 1)) {
    count_tbl = sort(table(unlist(voters)), decreasing = TRUE)
    candidates_selected = names(count_tbl)
    candidates_not_selected = setdiff(candidates, candidates_selected)
    approval_counts = as.vector(count_tbl)

    res_sel = data.frame(
      candidate = candidates_selected,
      score = approval_counts,
      norm_score = approval_counts / length(voters),
      stringsAsFactors = FALSE
    )

    # candidates not selected at all get a score of 0
    res_not_sel = if (length(candidates_not_selected) == 0) {
      data.frame(
        candidate = character(0),
        score = numeric(0),
        norm_score = numeric(0),
        stringsAsFactors = FALSE
      )
    } else {
      data.frame(
        candidate = candidates_not_selected,
        score = 0,
        norm_score = 0,
        stringsAsFactors = FALSE
      )
    }

    res = rbind(res_sel, res_not_sel)
  } else {
    # returns AV scores so needs ordering
    res = data.frame(av_rcpp(voters, candidates, weights), stringsAsFactors = FALSE)
    res = res[order(res$score, decreasing = TRUE), ]
    rownames(res) = NULL
  }

  # subset to top N rows
  if (!is.null(committee_size)) res = res[1:committee_size, ]

  # add borda scores
  if (borda_score) add_borda_score(res, n = length(candidates)) else res
}

#' @title Satisfaction Approval Voting
#'
#' @description
#' **Satisfaction Approval Voting** (SAV) ranks candidates by normalizing
#' approval scores based on the size of each voter's approval set. Voters who
#' approve more candidates contribute a lesser score to the individual approved
#' candidates.
#'
#' This function uses an internal C++ implementation for efficient computation.
#'
#' @template param_voters
#' @template param_candidates
#' @template param_weights
#' @template param_committee_size
#' @template param_borda_score
#' @template param_check
#'
#' @return A `data.frame` with columns:
#' - `"candidate"`: Candidate names.
#' - `"score"`: Satisfaction scores.
#' - `"norm_score"`: Normalized scores, scaled to the range \eqn{[0,1]}.
#' - `"borda_score"`: Borda scores for method-agnostic comparison, ranging in
#' \eqn{[0,1]}, where the top candidate receives a score of 1 and the lowest-ranked
#' candidate receives a score of 0, based on the total number of candidates.
#'
#' Candidates are ordered by decreasing `"score"`.
#' @family voting methods
#' @export
sav = function(
  voters,
  candidates,
  weights = NULL,
  committee_size = NULL,
  borda_score = TRUE,
  check = FALSE
) {
  assert_inputs(voters, candidates, weights, committee_size, borda_score, check)

  if (is.null(weights)) {
    # Assign equal weights to all voters
    weights = rep(1, length(voters))
  }

  if (check) {
    check_voters(voters, candidates)
  }

  # returns SAV scores so needs ordering
  res = data.frame(sav_rcpp(voters, candidates, weights), stringsAsFactors = FALSE)
  res = res[order(res$score, decreasing = TRUE), ]
  rownames(res) = NULL

  # subset to top N rows
  if (!is.null(committee_size)) res = res[1:committee_size, ]

  # add borda scores
  if (borda_score) add_borda_score(res, n = length(candidates)) else res
}

#' @title Sequential Proportional Approval Voting
#'
#' @description
#' **Sequential Proportional Approval Voting** (SeqPAV) is a multi-winner method
#' that builds a committee by iteratively maximizing a proportionality-based
#' satisfaction score. After each selection, the weights of voters who approved
#' the chosen candidate are reduced, which promotes proportional representation.
#' The **PAV score** is computed as the weighted sum of harmonic numbers based on
#' how many elected candidates each voter supports. The process continues until
#' the specified committee size is reached or all candidates are ranked.
#'
#' This function uses an internal C++ implementation for efficient computation.
#'
#' @template param_voters
#' @template param_candidates
#' @template param_weights
#' @template param_committee_size
#' @template param_borda_score
#' @template param_check
#'
#' @return A `data.frame` with columns:
#' - `"candidate"`: Candidate names.
#' - `"borda_score"`: Borda scores for method-agnostic comparison, ranging in \eqn{[0,1]}, where the top candidate receives a score of 1 and the lowest-ranked candidate receives a score of 0, based on the total number of candidates.
#'
#' Candidates are ordered by the sequence in which they were selected.
#' @family voting methods
#' @export
seq_pav = function(
  voters,
  candidates,
  weights = NULL,
  committee_size = NULL,
  borda_score = TRUE,
  check = FALSE
) {
  assert_inputs(voters, candidates, weights, committee_size, borda_score, check)

  if (is.null(weights)) {
    # Assign equal weights to all voters
    weights = rep(1, length(voters))
  }

  if (check) {
    check_voters(voters, candidates)
  }

  # set committee_size to total number of candidates if not specified
  if (is.null(committee_size)) committee_size = length(candidates)

  # returns ranked candidates from best to worst (up to committee_size)
  res = data.frame(seq_pav_rcpp(voters, candidates, weights, committee_size),
                   stringsAsFactors = FALSE)

  # add borda scores
  if (borda_score) add_borda_score(res, n = length(candidates)) else res
}

#' @title Sequential Phragmen's Rule
#'
#' @description
#' **Sequential Phragmen's Rule** is a multi-winner method that builds a committee
#' by distributing representation *loads* across voters as evenly as possible.
#' At each step, it selects the candidate that yields the smallest increase in
#' voter load, then updates loads for voters who approved the chosen candidate.
#' The process continues until the committee is filled or all candidates are ranked.
#'
#' This function uses an internal C++ implementation for efficient computation.
#'
#' @template param_voters
#' @template param_candidates
#' @template param_weights
#' @template param_committee_size
#' @template param_borda_score
#' @template param_check
#'
#' @return A `data.frame` with columns:
#' - `"candidate"`: Candidate names.
#' - `"borda_score"`: Borda scores for method-agnostic comparison, ranging in \eqn{[0,1]}, where the top candidate receives a score of 1 and the lowest-ranked candidate receives a score of 0, based on the total number of candidates.
#'
#' Candidates are ordered by the sequence in which they were selected.
#' @family voting methods
#' @export
seq_phragmen = function(
  voters,
  candidates,
  weights = NULL,
  committee_size = NULL,
  borda_score = TRUE,
  check = FALSE
) {
  assert_inputs(voters, candidates, weights, committee_size, borda_score, check)

  if (is.null(weights)) {
    # Assign equal weights to all voters
    weights = rep(1, length(voters))
  }

  if (check) {
    check_voters(voters, candidates)
  }

  # set committee_size to total number of candidates if not specified
  if (is.null(committee_size)) committee_size = length(candidates)

  # returns ranked candidates from best to worst (up to committee_size)
  res = data.frame(seq_phragmen_rcpp(voters, candidates, weights, committee_size))

  # add borda scores
  if (borda_score) add_borda_score(res, n = length(candidates)) else res
}

#' @title Adds normalized borda scores
#' @note `n` needs to be the total number of candidates (irrespective of committee size)
#' @noRd
#' @keywords internal
add_borda_score = function(df, n) {
  assert_number(n, null.ok = FALSE, lower = 1)

  n_rows = nrow(df)
  df$borda_score = if (n_rows == 1) 1 else (n - seq_len(n_rows)) / (n - 1)

  df
}

#' @title Check voter approvals
#' @description
#' Validates the approval ballots in `voters`.
#' Ensures:
#' - Each voter approves at least one candidate.
#' - No voter lists the same candidate more than once.
#' - Every approved candidate appears in `candidates`.
#' @noRd
#' @keywords internal
check_voters = function(voters, candidates) {
  voter_lengths = lengths(voters)

  if (any(voter_lengths == 0L)) {
    stop("all voters must approve at least one candidate", call. = FALSE)
  }

  voted_candidates = unique(unlist(voters, use.names = FALSE))
  candidate_matches = match(voted_candidates, candidates, nomatch = NA_integer_)
  if (anyNA(candidate_matches)) {
    stop("all voted candidates must be present in the 'candidates' vector", call. = FALSE)
  }

  if (any(vapply(voters, anyDuplicated, integer(1)) > 0L)) {
    stop("voters must not contain duplicated candidates", call. = FALSE)
  }
}

#' @noRd
#' @keywords internal
assert_inputs = function(voters, candidates, weights, committee_size, borda_score, check) {
  # input checks
  assert_list(voters, min.len = 1, types = "character", null.ok = FALSE, any.missing = FALSE)
  assert_character(candidates, min.len = 1, null.ok = FALSE, any.missing = FALSE)
  # each voter's weight must be non-negative
  assert_numeric(weights, len = length(voters), lower = 0, any.missing = FALSE, null.ok = TRUE)
  # at least one positive weight is required (if weights are provided)
  if (!is.null(weights)) assert_true(sum(weights) > 0)
  assert_int(committee_size, lower = 1, null.ok = TRUE)
  assert_flag(borda_score)
  assert_flag(check)
}
