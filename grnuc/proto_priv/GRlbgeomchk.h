#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRlbgeomchk.C */
extern int GRlbgeomchk __((IGRlong *msg, struct GRlc_cvl *cvl, struct IGRlbsys *lbsys, IGRint *eligible_flag, struct GRlc_path *path, IGRint *path_position));

#if defined(__cplusplus)
}
#endif


#undef __
