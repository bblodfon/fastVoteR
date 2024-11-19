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
# edge case: all voters voted the same candidates, "V4" and "V5" are nowhere!
# e = equal/same votes
vote = list(
  c("V3", "V1", "V2"),
  c("V3", "V1", "V2"),
  c("V3", "V1", "V2"),
  c("V3", "V1", "V2")
)
w2 = runif(length(vot2))
we2 = rep(1, length(vot2))
