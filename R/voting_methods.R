# these R methods are wrappers for the Rcpp implementations
# We homogenize a bit the outputs here as well

#' @noRd
#' @keywords internal
av = function(voters, candidates, weights, committee_size = NULL, borda_score = TRUE) {
  # faster R version in case of equal weights
  if (all(weights == 1)) {
    count_tbl = sort(table(unlist(voters)), decreasing = TRUE)
    candidates_selected = names(count_tbl)
    candidates_not_selected = setdiff(candidates, candidates_selected)
    approval_counts = as.vector(count_tbl)

    res_sel = data.frame(
      candidate = candidates_selected,
      score = approval_counts,
      norm_score = approval_counts / length(voters)
    )

    # candidates not selected at all get a score of 0
    res_not_sel = data.frame(
      candidate = candidates_not_selected,
      score = 0,
      norm_score = 0
    )

    res = rbind(res_sel, res_not_sel)
  } else {
    # returns AV scores so needs ordering
    res = data.frame(av_rcpp(voters, candidates, weights))
    res = res[order(res$score, decreasing = TRUE), ]
    rownames(res) = NULL
  }

  # subset to top N rows if committee_size is specified
  if (!is.null(committee_size)) res = head(res, committee_size)

  # add borda scores
  if (borda_score) add_borda_score(res, n = length(candidates)) else res
}

#' @noRd
#' @keywords internal
sav = function(voters, candidates, weights, committee_size = NULL, borda_score = TRUE) {
  # returns SAV scores so needs ordering
  res = data.frame(sav_rcpp(voters, candidates, weights))
  res = res[order(res$score, decreasing = TRUE), ]
  rownames(res) = NULL

  # subset to top N rows if committee_size is specified
  if (!is.null(committee_size)) res = head(res, committee_size)

  # add borda scores
  if (borda_score) add_borda_score(res, n = length(candidates)) else res
}

#' @noRd
#' @keywords internal
seq_pav = function(voters, candidates, weights, committee_size = NULL, borda_score = TRUE) {
  if (is.null(committee_size)) committee_size = length(candidates)

  # returns ranked candidates from best to worst (up to committee_size)
  res = data.frame(seq_pav_rcpp(voters, candidates, weights, committee_size))

  # add borda scores
  if (borda_score) add_borda_score(res, n = length(candidates)) else res
}

#' @noRd
#' @keywords internal
seq_phragmen = function(voters, candidates, weights, committee_size = NULL, borda_score = TRUE) {
  if (is.null(committee_size)) committee_size = length(candidates)

  # returns ranked candidates from best to worst (up to committee_size)
  res = data.frame(seq_phragmen_rcpp(voters, candidates, weights, committee_size))

  # add borda scores
  if (borda_score) add_borda_score(res, n = length(candidates)) else res
}

#' @title Adds normalized borda scores
#' `n` needs to be the total number of candidates (irrespective of committee size)
#' @noRd
#' @keywords internal
add_borda_score = function(df, n) {
  assert_number(n, null.ok = FALSE, lower = 1)

  n_rows = nrow(df)
  if (n_rows == 1) {
    df$borda_score = 1
  } else {
    df$borda_score = (n - seq_len(n_rows)) / (n - 1)
  }

  df
}
