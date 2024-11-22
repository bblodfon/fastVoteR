# see `helper.R` for example inputs (`vot2`, `cand2`, `w2` ) and `test_*` functions

test_that("approval voting", {
  test_large_example(av)
  test_borda_score(av)
  test_equal_votes(av)

  # small data example
  res = av(vot2, cand2, w2) # different weights
  expect_equal(res$candidate, c("V3", "V1", "V4", "V2", "V5"))
  expect_equal(res[candidate == "V3", norm_score], 1) # voted by all
  expect_equal(res[candidate == "V5", norm_score], 0) # never voted

  res2 = av(vot2, cand2, we2) # equal weights
  expect_equal(res2$candidate[1:2], c("V3", "V1"))
  # due to equal scores better check the following:
  expect_set_equal(res2$candidate[3:4], c("V2", "V4"))
  expect_equal(res2$candidate[5], "V5")
  expect_equal(res2$score, c(4, 2, 1, 1, 0)) # approval counts
  expect_equal(res2$norm_score, c(1, 0.5, 0.25, 0.25, 0))
})
