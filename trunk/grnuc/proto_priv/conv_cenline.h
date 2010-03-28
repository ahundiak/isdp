#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_conv/conv_cenline.I */
extern IGRint DMconv_cenline __((IGRint *msg, struct GRid cenline, struct GRmd_env *md_env, struct GRid *p_new));

#if defined(__cplusplus)
}
#endif


#undef __
