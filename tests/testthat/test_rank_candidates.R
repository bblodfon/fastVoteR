# see `helper.R` for example inputs (`vot2`, `cand2`, `w2` )

test_that("rank candidates", {
  # invalid method
  expect_error(rank_candidates(voters = vot2, candidates = cand2, method = "XYZ"))
  # invalid shuffle_candidates
  expect_error(rank_candidates(voters = vot2, candidates = cand2, shuffle_candidates = NULL))

  # verify each method returns a data frame with expected dimensions (equal weights)
  expect_data_frame(rank_candidates(vot2, cand2, method = "av"),
                    nrows = length(cand2), ncols = 4, any.missing = FALSE)
  expect_data_frame(rank_candidates(vot2, cand2, method = "sav"),
                    nrows = length(cand2), ncols = 4, any.missing = FALSE)
  expect_data_frame(rank_candidates(vot2, cand2, method = "seq_pav"),
                    nrows = length(cand2), ncols = 2, any.missing = FALSE)
  expect_data_frame(rank_candidates(vot2, cand2, method = "seq_phragmen"),
                    nrows = length(cand2), ncols = 2, any.missing = FALSE)

  # verify each method returns a data frame with expected dimensions (unequal weights)
  expect_data_frame(rank_candidates(vot2, cand2, w2, method = "av"),
                    nrows = length(cand2), ncols = 4, any.missing = FALSE)
  expect_data_frame(rank_candidates(vot2, cand2, w2, method = "sav"),
                    nrows = length(cand2), ncols = 4, any.missing = FALSE)
  expect_data_frame(rank_candidates(vot2, cand2, w2, method = "seq_pav"),
                    nrows = length(cand2), ncols = 2, any.missing = FALSE)
  expect_data_frame(rank_candidates(vot2, cand2, w2, method = "seq_phragmen"),
                    nrows = length(cand2), ncols = 2, any.missing = FALSE)
})
