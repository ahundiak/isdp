#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRpostrtrans.c */
extern IGRlong GRpostrtransutil __((IGRlong *msg, struct GRmd_env *md_env, int post_info, IGRlong *num_points, IGRboolean *rational, IGRdouble *weights, IGRdouble points[], GRrange range));

#if defined(__cplusplus)
}
#endif


#undef __
