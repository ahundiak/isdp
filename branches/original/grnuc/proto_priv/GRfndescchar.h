#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRfndescchar.C */
extern IGRshort GRfind_esc_char __((IGRlong *msg, IGRuchar *text_string, IGRshort text_length, IGRint flags, IGRshort *num_chars));

#if defined(__cplusplus)
}
#endif


#undef __
