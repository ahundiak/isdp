#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRformdvpris.I */
extern int GRformdvprism __((IGRlong *msg, struct GRmd_env *env, IGRmatrix wld_to_view_matrix, struct GRid *ref_id));

#if defined(__cplusplus)
}
#endif


#undef __
