#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRconvstr.I */
extern IGRint GRconv_string __((IGRlong *msg, IGRuchar *text_string, IGRshort text_length, struct GRmd_env *target_env));

#if defined(__cplusplus)
}
#endif


#undef __
