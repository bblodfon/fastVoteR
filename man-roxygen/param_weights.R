#' @param weights (`numeric()|NULL`) \cr
#'  A numeric vector of non-negative weights representing each voter's influence.
#'  Larger weight, higher influence.
#'  Must have the same length as `voters`.
#'  If `NULL` (default), all voters are assigned equal weights of 1, representing
#'  equal influence.
