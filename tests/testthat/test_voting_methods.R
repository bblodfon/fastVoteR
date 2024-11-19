# see `helper.R` for example inputs, eg `vot`, `cand`, `vot2`, etc.
test_that("approval voting", {
  # large data
  av1 = av(vot, cand, w)
  expect_data_table(av1, nrows = length(cand), ncols = 4)
  expect_setequal(colnames(av1), c("feature", "score", "norm_score", "borda_score"))
  expect_setequal(av1$feature, cand) # all features are there
  expect_true(all(av1$score >= 0)) # positive scores
  expect_true(all(av1$norm_score >= 0 & av1$norm_score <= 1)) # behave like probs
  expect_equal(av1$borda_score[1], 1)
  expect_equal(av1$borda_score[length(cand)], 0)

  # `committee_size` just filters top candidates
  avf1 = av(vot, cand, w, committee_size = 13)
  expect_equal(avf1$feature, av1$feature[1:13])

  ave1 = av(vot, cand, we) # e = equal weights
  expect_data_table(ave1, nrows = length(cand), ncols = 4)
  expect_true(all(ave1$score >= 0)) # positive scores
  expect_true(all(ave1$norm_score >= 0 & ave1$norm_score <= 1)) # behave like probs
  expect_equal(ave1$borda_score[1], 1)
  expect_equal(ave1$borda_score[length(cand)], 0)
  # using unequal weights, feature rankings should be different
  expect_false(identical(av1$feature, ave1$feature))
  # `committee_size` just filters top candidates
  avef1 = av(vot, cand, we, committee_size = 13)
  expect_equal(avef1$feature, ave1$feature[1:13])

  # small data
  av2 = av(vot2, cand2, w2)
  expect_equal(av2$feature[1:2], c("V3", "V1"))
  expect_equal(av2$feature[5], "V5")
  expect_equal(av2[feature == "V3", norm_score], 1) # always present
  expect_equal(av2[feature == "V5", norm_score], 0) # never present

  ave2 = av(vot2, cand2, we2)
  expect_equal(ave2$feature[1:2], c("V3", "V1"))
  expect_equal(ave2$feature[5], "V5")
  expect_equal(ave2$score, c(4, 2, 1, 1, 0))
  expect_equal(ave2$norm_score, c(1, 0.5, 0.25, 0.25, 0))

  # tie breaking
  av_tied = av(vote, cand2, w2)
  expect_contains(av_tied$feature[1:3], c("V1", "V2", "V3"))
  expect_true(length(unique(av_tied$score[1:3])) == 1) # all scores the same
  expect_contains(av_tied$feature[4:5], c("V4", "V5"))
})

test_that("satisfaction approval voting", {
  # large data
  sav = sav(vot, cand, w)
  expect_data_table(sav, nrows = length(cand), ncols = 4)
  expect_setequal(colnames(sav), c("feature", "score", "norm_score", "borda_score"))
  expect_setequal(sav$feature, cand) # all features are there
  expect_true(all(sav$score >= 0)) # positive scores
  expect_true(all(sav$norm_score >= 0 & sav$norm_score <= 1)) # behave like probs
  expect_equal(sav$borda_score[1], 1)
  expect_equal(sav$borda_score[length(cand)], 0)

  sav_equalw = sav(vot, cand, we)
  expect_data_table(sav_equalw, nrows = length(cand), ncols = 4)
  expect_true(all(sav_equalw$score >= 0)) # positive scores
  expect_true(all(sav_equalw$norm_score >= 0 & sav_equalw$norm_score <= 1)) # behave like probs
  expect_equal(sav_equalw$borda_score[1], 1)
  expect_equal(sav_equalw$borda_score[length(cand)], 0)
  # using unequal weights, feature rankings should be different
  expect_false(identical(sav$feature, sav_equalw$feature))

  # small data
  sav2 = sav(vot2, cand2, w2)
  expect_equal(sav2$feature[1:2], c("V3", "V1"))
  expect_equal(sav2$feature[5], "V5")
  expect_equal(sav2[feature == "V3", norm_score], 1) # always present
  expect_equal(sav2[feature == "V5", norm_score], 0) # never present

  sav2_equalw = sav(vot2, cand2, w2_equal)
  expect_equal(sav2_equalw$feature, c("V3", "V1", "V4", "V2", "V5"))

  # tie breaking
  sav3 = sav(vot3, cand2, w2)
  expect_contains(sav3$feature[1:3], c("V1", "V2", "V3"))
  expect_true(length(unique(sav3$score[1:3])) == 1) # all scores the same
  expect_contains(sav3$feature[4:5], c("V4", "V5"))
})

test_that("sequential proportional approval voting", {
  # large data
  size = 5 # get top 5 ranked features
  sp = seq_proportional_approval_voting(vot, cand, w, size)
  expect_data_table(sp, nrows = size, ncols = 2)
  expect_setequal(colnames(sp), c("feature", "borda_score"))
  sp1 = seq_proportional_approval_voting(vot, cand, w, committee_size = 3)
  expect_equal(sp$feature[1:3], sp1$feature[1:3]) # house monotonicity

  spe = seq_proportional_approval_voting(vot, cand, we, size)
  expect_data_table(spe, nrows = size, ncols = 2)
  # using unequal weights, feature rankings should be different
  expect_false(identical(spe$feature, sp$feature))

  # small data
  seq_pav2 = seq_proportional_approval_voting(vot2, cand2, w2)
  expect_data_table(seq_pav2, nrows = length(cand2), ncols = 2)
  expect_setequal(colnames(seq_pav2), c("feature", "borda_score"))
  expect_equal(seq_pav2$borda_score[1], 1)
  expect_equal(seq_pav2$borda_score[length(cand2)], 0)

  seq_pav2_equal = seq_proportional_approval_voting(vot2, cand2, w2_equal)
  expect_data_table(seq_pav2_equal, nrows = length(cand2), ncols = 2)
  expect_setequal(colnames(seq_pav2_equal), c("feature", "borda_score"))
  expect_equal(seq_pav2_equal$borda_score[1], 1)
  expect_equal(seq_pav2_equal$borda_score[length(cand2)], 0)

  # tie breaking
  seq_pav3 = seq_proportional_approval_voting(vot3, cand2, w2)
  expect_contains(seq_pav3$feature[1:3], c("V1", "V2", "V3"))
  expect_contains(seq_pav3$feature[4:5], c("V4", "V5"))
})

test_that("sequential Phragmen's rule", {
  # large data
  size = 5 # get top 5 ranked features
  spr = seq_phragmen_rule(vot, cand, w, size)
  expect_data_table(spr, nrows = size, ncols = 2)
  expect_setequal(colnames(spr), c("feature", "borda_score"))
  spr1 = seq_phragmen_rule(vot, cand, w, committee_size = 3)
  expect_equal(spr$feature[1:3], spr1$feature[1:3]) # house monotonicity

  spre = seq_phragmen_rule(vot, cand, we, size)
  expect_data_table(spre, nrows = size, ncols = 2)
  # using unequal weights, feature rankings should be different
  expect_false(identical(spre$feature, spr$feature))

  # small data
  spr2 = seq_phragmen_rule(vot2, cand2, w2)
  expect_data_table(spr2, nrows = length(cand2), ncols = 2)
  expect_setequal(colnames(spr2), c("feature", "borda_score"))
  expect_equal(spr2$borda_score[1], 1)
  expect_equal(spr2$borda_score[length(cand2)], 0)

  spr2e = seq_phragmen_rule(vot2, cand2, w2e)
  expect_data_table(spr2e, nrows = length(cand2), ncols = 2)
  expect_setequal(colnames(spr2e), c("feature", "borda_score"))
  expect_equal(spr2e$borda_score[1], 1)
  expect_equal(spr2e$borda_score[length(cand2)], 0)

  # tie breaking
  spr3 = seq_phragmen_rule(vot3, cand2, w2)
  expect_contains(spr3$feature[1:3], c("V1", "V2", "V3"))
  expect_contains(spr3$feature[4:5], c("V4", "V5"))

  # Example 2.9 from Lackner's "Multi-Winner Voting with Approval Preferences"
  cand4 = paste0("V", 1:7)
  vot4 = list(
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
  w4_equal = rep(1, length(vot4))
  # output committee should be: V1, {V2, V3} => tied, V4, V6, {V5, V7} => tied
  # sampling candidates should respect the above ordering
  res = lapply(1:10, function(i) {
    spr = seq_phragmen_rule(vot4, sample(cand4), w4_equal)
    spr$feature
  })

  for (i in 1:10) {
    committee = res[[i]]
    expect_equal(committee[1], "V1")
    expect_contains(committee[2:3], c("V2", "V3"))
    expect_equal(committee[4:5], c("V4", "V6"))
    expect_contains(committee[6:7], c("V5", "V7"))
  }
})
