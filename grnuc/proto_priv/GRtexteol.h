#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRtexteol.C */
extern IGRboolean GRtext_eol __((IGRlong *msg, IGRuchar *text_string, IGRshort *text_length, IGRshort *start_position, IGRshort *num_chars));

#if defined(__cplusplus)
}
#endif


#undef __
