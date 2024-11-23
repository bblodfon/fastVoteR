# see `helper.R` for example inputs (`vot2`, `cand2`, `w2` ) and `test_*` functions

test_that("sequential Phragmen's rule", {
  test_large_example(seq_phragmen, committee_size = 5)
  test_borda_score(seq_phragmen)
  test_equal_votes(seq_phragmen)

  # small data example
  res = seq_phragmen(vot2, cand2, w2) # different weights
  expect_equal(res$candidate, c("V3", "V1", "V4", "V2", "V5"))

  res2 = sav(vot2, cand2, we2) # equal weights
  expect_equal(res2$candidate, c("V3", "V1", "V4", "V2", "V5"))

  # Example 2.9 from Lackner's "Multi-Winner Voting with Approval Preferences"
  cand3 = paste0("V", 1:7)
  vot3 = list(
    c("V1", "V2"),
    c("V1", "V2"),
    c("V1", "V2"),
    c("V1", "V3"),
    c("V1", "V3"),
    c("V1", "V3"),
    c("V1", "V4"),
    c("V1", "V4"),
    c("V2", "V3", "V6"),
    "V5", "V6", "V7"
  )
  we3 = rep(1, length(vot3)) # equal weights

  # output committee should be:
  # - V1
  # - {V2, V3} => tied
  # - V4
  # - V6
  # - {V5, V7} => tied
  #
  # Rankings after resampling the candidates should respect the above ordering
  res = lapply(1:10, function(i) {
    sp = seq_phragmen(vot3, sample(cand3), we3)
    sp$candidate
  })

  for (i in 1:10) {
    committee = res[[i]]
    expect_equal(committee[1], "V1")
    expect_contains(committee[2:3], c("V2", "V3"))
    expect_equal(committee[4:5], c("V4", "V6"))
    expect_contains(committee[6:7], c("V5", "V7"))
  }
})
