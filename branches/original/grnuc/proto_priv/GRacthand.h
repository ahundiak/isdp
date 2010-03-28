#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRacthand.C */
extern int GRacthand __((IGRlong *msg, struct GRlc_cvl *cvl, struct GRlc_path *path, IGRint *path_position, IGRint *eligible_flag));

#if defined(__cplusplus)
}
#endif


#undef __
