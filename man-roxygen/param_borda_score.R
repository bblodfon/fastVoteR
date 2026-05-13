#' @param borda_score (`logical(1)`) \cr
#'  Whether to include a `borda_score` column in the output, which provides a
#'  normalized score based on the candidate's rank.
#'  If `TRUE` (default), the `borda_score` is calculated as \eqn{(p - i) / (p - 1)},
#'  where \eqn{p} is the total number of candidates and \eqn{i} is the candidate's rank.
