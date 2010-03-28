#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/detailco/GRdvidmatrix.C */
extern IGRint GRdvid_matrix __((IGRlong *msg, IGRmatrix matrix, IGRchar string[], OMuword osnum));

#if defined(__cplusplus)
}
#endif


#undef __
