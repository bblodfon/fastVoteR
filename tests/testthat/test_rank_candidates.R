# see `helper.R` for example inputs (`vot2`, `cand2`, `w2` )

test_that("rank candidates", {
  # input checks
  expect_error(rank_candidates(voters = vot2, candidates = c("V1", "V3")))
  expect_error(rank_candidates(voters = vot2, candidates = NULL))
  expect_error(rank_candidates(voters = vot2, candidates = cand2, method = "XYZ"))
  expect_error(rank_candidates(voters = list(), candidates = cand2))
  expect_error(rank_candidates(voters = vot2, candidates = cand2, borda_score = "yes"))
  expect_error(rank_candidates(voters = vot2, candidates = cand2, shuffle_candidates = NULL))

  # different methods work (equal weights)
  expect_data_table(rank_candidates(vot2, cand2, method = "av"),
                    nrows = length(cand2), ncols = 4, any.missing = FALSE)
  expect_data_table(rank_candidates(vot2, cand2, method = "sav"),
                    nrows = length(cand2), ncols = 4, any.missing = FALSE)
  expect_data_table(rank_candidates(vot2, cand2, method = "seq_pav"),
                    nrows = length(cand2), ncols = 2, any.missing = FALSE)
  expect_data_table(rank_candidates(vot2, cand2, method = "seq_phragmen"),
                    nrows = length(cand2), ncols = 2, any.missing = FALSE)

  # different methods work (unequal weights)
  expect_data_table(rank_candidates(vot2, cand2, w2, method = "av"),
                    nrows = length(cand2), ncols = 4, any.missing = FALSE)
  expect_data_table(rank_candidates(vot2, cand2, w2, method = "sav"),
                    nrows = length(cand2), ncols = 4, any.missing = FALSE)
  expect_data_table(rank_candidates(vot2, cand2, w2, method = "seq_pav"),
                    nrows = length(cand2), ncols = 2, any.missing = FALSE)
  expect_data_table(rank_candidates(vot2, cand2, w2, method = "seq_phragmen"),
                    nrows = length(cand2), ncols = 2, any.missing = FALSE)
})
