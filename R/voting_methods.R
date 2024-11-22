# these R methods are proxies to the Rcpp implementations
# We perform some homogenization in terms of outputs

av = function(voters, candidates, weights, committee_size = NULL, borda_score = TRUE) {
  # faster R version in case of equal weights
  if (all(weights == 1)) {
    count_tbl = sort(table(unlist(voters)), decreasing = TRUE)
    candidates_selected = names(count_tbl)
    candidates_not_selected = setdiff(candidates, candidates_selected)
    approval_counts = as.vector(count_tbl)

    res_sel = data.table(
      candidate = candidates_selected,
      score = approval_counts,
      norm_score = approval_counts / length(voters)
    )

    # candidates not selected at all get a score of 0
    res_not_sel = data.table(
      candidate = candidates_not_selected,
      score = 0,
      norm_score = 0
    )

    res = rbindlist(list(res_sel, res_not_sel))
  } else {
    # returns AV scores so needs ordering
    res = as.data.table(av_rcpp(voters, candidates, weights))
    setorderv(res, cols = "score", order = -1)
  }

  # filter: top N rows
  if (!is.null(committee_size)) {
    res = res[1:committee_size]
  }

  if (borda_score) {
    add_borda_score(res, n = length(candidates))
  }

  res
}

sav = function(voters, candidates, weights, committee_size = NULL, borda_score = TRUE) {
  # returns SAV scores so needs ordering
  res = as.data.table(sav_rcpp(voters, candidates, weights))
  setorderv(res, cols = "score", order = -1)

  # filter: top N rows
  if (!is.null(committee_size)) {
    res = res[1:committee_size]
  }

  if (borda_score) {
    add_borda_score(res, n = length(candidates))
  }

  res
}

seq_pav = function(voters, candidates, weights, committee_size = NULL, borda_score = TRUE) {
  if (is.null(committee_size)) {
    committee_size = length(candidates)
  }

  # returns ranked candidates from best to worst (up to committee_size)
  res = as.data.table(seq_pav_rcpp(voters, candidates, weights, committee_size))

  if (borda_score) {
    add_borda_score(res, n = length(candidates))
  }

  res
}

seq_phragmen = function(voters, candidates, weights, committee_size = NULL, borda_score = TRUE) {
  if (is.null(committee_size)) {
    committee_size = length(candidates)
  }

  # returns ranked candidates from best to worst (up to committee_size)
  res = as.data.table(seq_phragmen_rcpp(voters, candidates, weights, committee_size))

  if (borda_score) {
    add_borda_score(res, n = length(candidates))
  }

  res
}

# add normalized borda scores
# `n` needs to be the total number of candidates (irrespective of committee size)
add_borda_score = function(dt, n = NULL) {
  if (is.null(n)) n = nrow(dt)
  borda_score = NULL # silence data.table note: "no visible global binding"
  dt[, borda_score := if (nrow(dt) == 1) 1 else (n - .I) / (n - 1)][]
}
