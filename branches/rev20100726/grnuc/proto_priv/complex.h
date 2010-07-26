#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/complex.I */
extern IGRint DMupdate_complex __((IGRint *msg, struct GRid dim_grid, struct GRmd_env *md_env));
extern IGRint DMmerge_complex __((IGRint *msg, IGRint cpx_type, struct GRid *cpx_hdr1, struct GRid *cpx_hdr2, struct GRmd_env *md_env));

#if defined(__cplusplus)
}
#endif


#undef __
