#' @param check (`logical(1)`) \cr
#'  Whether to run additional voter-integrity checks. When `TRUE`, each voter
#'  must approve at least one candidate, approvals must be unique per voter, and
#'  all approved candidates must appear in `candidates`. Use `FALSE` to skip
#'  these checks when inputs are known to be valid.
