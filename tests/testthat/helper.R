# Create some example inputs for testing

# large data example
set.seed(42)

n_candidates = 800
n_voters = 200

cand = paste0("V", seq_len(n_candidates))
vot = lapply(1:n_voters, function(x) sample(cand, size = sample(2:30, 1)))
w = runif(n_voters)
we = rep(1, n_voters) # equal weights

# small data example
cand2 = paste0("V", seq_len(5))
# "V3" candidate in all sets, "V1" in half, "V2", "V4" once, "V5" nowhere!
vot2 = list(
  c("V3", "V1", "V2"),
  c("V3", "V1"),
  c("V3", "V4"),
  c("V3")
)
w2 = c(0.27, 0.23, 0.4, 0.5)
we2 = rep(1, length(vot2))

# edge case: all voters voted the same candidates, "V4" and "V5" are nowhere!
# equal/same votes
vot_equal = list(
  c("V3", "V1", "V2"),
  c("V3", "V1", "V2"),
  c("V3", "V1", "V2"),
  c("V3", "V1", "V2")
)

test_large_example = function(method_fun, committee_size = NULL) {
  # unequal weights
  res = method_fun(vot, cand, w, committee_size)
  size = ifelse(is.null(committee_size), length(cand), committee_size)

  expect_data_table(res, nrows = size, min.cols = 2, max.cols = 4)
  expect_contains(colnames(res), c("candidate", "borda_score"))

  # committee candidates are included in the candidates
  if (is.null(committee_size)) {
    expect_set_equal(res$candidate, cand)
  } else {
    expect_in(res$candidate, cand)
  }

  # scores must be positive
  if (!is.null(res$score)) {
    expect_true(all(res$score >= 0))
  }

  # normalized scores behave like probabilities
  if (!is.null(res$norm_score)) {
    expect_true(all(res$norm_score >= 0 & res$norm_score <= 1))
  }

  # house monotonicy check: ordering remains the same with less committee members
  res_less = method_fun(vot, cand, w, committee_size = 3)
  expect_equal(res_less$candidate, res$candidate[1:3])

  # equal weights
  res_equal = method_fun(vot, cand, we, committee_size)

  expect_data_table(res_equal, nrows = size, min.cols = 2, max.cols = 4)
  expect_contains(colnames(res_equal), c("candidate", "borda_score"))

  # committee candidates are included in the candidates
  if (is.null(committee_size)) {
    expect_set_equal(res_equal$candidate, cand)
  } else {
    expect_in(res_equal$candidate, cand)
  }

  # scores must be positive
  if (!is.null(res_equal$score)) {
    expect_true(all(res_equal$score >= 0))
  }

  # normalized scores behave like probabilities
  if (!is.null(res_equal$norm_score)) {
    expect_true(all(res_equal$norm_score >= 0 & res_equal$norm_score <= 1))
  }

  # house monotonicy check: ordering remains the same with less committee members
  res_equal_less = method_fun(vot, cand, we, committee_size = 3)
  expect_equal(res_equal_less$candidate, res_equal$candidate[1:3])

  # using different weights, candidate rankings should be different
  expect_false(identical(res$candidate, res_equal$candidate))
}

test_borda_score = function(method_fun) {
  # uses small data example
  # no borda score in the output result
  res = method_fun(vot2, cand2, w2, borda_score = FALSE)
  expect_error(expect_in("borda_score", colnames(res)))

  # borda score in the output result
  res = method_fun(vot2, cand2, w2, borda_score = TRUE)
  expect_in("borda_score", colnames(res))
  # borda scores make sense
  expect_equal(res$borda_score[1], 1) # top candidate
  expect_equal(res$borda_score[length(cand2)], 0) # lowest-ranked candidate

  # borda score takes into account the total number of candidates, so last score is not 0
  # when committee_size < #candidates
  res = method_fun(vot2, cand2, w2, committee_size = 2, borda_score = TRUE)
  expect_gt(res$borda_score[2] , 0)
}

test_equal_votes = function(method_fun) {
  res = method_fun(vot_equal, cand2, w2)
  expect_contains(res$candidate[1:3], c("V1", "V2", "V3"))
  expect_contains(res$candidate[4:5], c("V4", "V5")) # V4, V5 were never voted

  # if scores are present, V1, V2 and V3 should have the same positive scores,
  # V4 and V5 zero
  if (!is.null(res$score)) {
    expect_true(length(unique(res$score[1:3])) == 1) # all scores the same
    expect_true(all(res$score[1:3] > 0))
    expect_equal(res$score[4:5], c(0, 0))
  }
}
