#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRposttransu.c */
extern IGRlong GRposttransutil __((IGRlong *msg, struct GRmd_env *md_env, int post_info, IGRlong *num_points, IGRdouble points[], GRrange range));

#if defined(__cplusplus)
}
#endif


#undef __
