# see `helper.R` for example inputs (`vot2`, `cand2`, `w2` ) and `test_*` functions

test_that("satisfaction approval voting", {
  test_large_example(sav)
  test_borda_score(sav)
  test_equal_votes(sav)

  # small data example
  res = sav(vot2, cand2, w2) # different weights
  expect_equal(res$candidate, c("V3", "V1", "V4", "V2", "V5"))
  expect_equal(res[candidate == "V3", norm_score], 1) # voted by all
  expect_equal(res[candidate == "V5", norm_score], 0) # never voted

  res2 = sav(vot2, cand2, we2) # equal weights
  expect_equal(res2$candidate, c("V3", "V1", "V4", "V2", "V5"))
})
