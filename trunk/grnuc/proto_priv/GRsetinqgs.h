#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/fenceco/GRsetinqgs.C */
extern IGRint GRset_inq_gs_flag __((IGRlong *msg, IGRint set_flag, IGRint *gs_flag));

#if defined(__cplusplus)
}
#endif


#undef __
