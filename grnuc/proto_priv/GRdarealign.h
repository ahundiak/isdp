#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/detailgo/GRdarealign.I */
extern IGRint GRis_matrix_equal __((IGRlong *msg, IGRmatrix a, IGRmatrix b));

#if defined(__cplusplus)
}
#endif


#undef __
