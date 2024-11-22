// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// av_rcpp
List av_rcpp(List voters, CharacterVector candidates, NumericVector weights);
RcppExport SEXP _fastVoteR_av_rcpp(SEXP votersSEXP, SEXP candidatesSEXP, SEXP weightsSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type voters(votersSEXP);
    Rcpp::traits::input_parameter< CharacterVector >::type candidates(candidatesSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type weights(weightsSEXP);
    rcpp_result_gen = Rcpp::wrap(av_rcpp(voters, candidates, weights));
    return rcpp_result_gen;
END_RCPP
}
// seq_pav_rcpp
List seq_pav_rcpp(List voters, CharacterVector candidates, NumericVector weights, int committee_size);
RcppExport SEXP _fastVoteR_seq_pav_rcpp(SEXP votersSEXP, SEXP candidatesSEXP, SEXP weightsSEXP, SEXP committee_sizeSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type voters(votersSEXP);
    Rcpp::traits::input_parameter< CharacterVector >::type candidates(candidatesSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type weights(weightsSEXP);
    Rcpp::traits::input_parameter< int >::type committee_size(committee_sizeSEXP);
    rcpp_result_gen = Rcpp::wrap(seq_pav_rcpp(voters, candidates, weights, committee_size));
    return rcpp_result_gen;
END_RCPP
}
// seq_phragmen_rcpp
List seq_phragmen_rcpp(List voters, CharacterVector candidates, NumericVector weights, int committee_size);
RcppExport SEXP _fastVoteR_seq_phragmen_rcpp(SEXP votersSEXP, SEXP candidatesSEXP, SEXP weightsSEXP, SEXP committee_sizeSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type voters(votersSEXP);
    Rcpp::traits::input_parameter< CharacterVector >::type candidates(candidatesSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type weights(weightsSEXP);
    Rcpp::traits::input_parameter< int >::type committee_size(committee_sizeSEXP);
    rcpp_result_gen = Rcpp::wrap(seq_phragmen_rcpp(voters, candidates, weights, committee_size));
    return rcpp_result_gen;
END_RCPP
}
// sav_rcpp
List sav_rcpp(List voters, CharacterVector candidates, NumericVector weights);
RcppExport SEXP _fastVoteR_sav_rcpp(SEXP votersSEXP, SEXP candidatesSEXP, SEXP weightsSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type voters(votersSEXP);
    Rcpp::traits::input_parameter< CharacterVector >::type candidates(candidatesSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type weights(weightsSEXP);
    rcpp_result_gen = Rcpp::wrap(sav_rcpp(voters, candidates, weights));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_fastVoteR_av_rcpp", (DL_FUNC) &_fastVoteR_av_rcpp, 3},
    {"_fastVoteR_seq_pav_rcpp", (DL_FUNC) &_fastVoteR_seq_pav_rcpp, 4},
    {"_fastVoteR_seq_phragmen_rcpp", (DL_FUNC) &_fastVoteR_seq_phragmen_rcpp, 4},
    {"_fastVoteR_sav_rcpp", (DL_FUNC) &_fastVoteR_sav_rcpp, 3},
    {NULL, NULL, 0}
};

RcppExport void R_init_fastVoteR(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
