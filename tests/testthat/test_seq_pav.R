# see `helper.R` for example inputs (`vot2`, `cand2`, `w2` ) and `test_*` functions

test_that("sequential proportional approval voting", {
  test_large_example(seq_pav, committee_size = 5)
  test_borda_score(seq_pav)
  test_equal_votes(seq_pav)

  # small data example
  res = seq_pav(vot2, cand2, w2) # different weights
  expect_equal(res$candidate, c("V3", "V1", "V4", "V2", "V5"))

  res2 = seq_pav(vot2, cand2, we2) # equal weights
  expect_equal(res2$candidate, c("V3", "V1", "V4", "V2", "V5"))
})
