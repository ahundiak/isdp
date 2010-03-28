#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/event/COgenmxpts.C */
extern IGRlong CO_ni_matrix_of_pts_by_row_col_delta __((IGRlong *sts, struct GRevent *events[]));

#if defined(__cplusplus)
}
#endif


#undef __
