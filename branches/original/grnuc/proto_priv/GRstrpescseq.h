#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRstrpescseq.C */
extern IGRint GRstrip_esc_sequences __((IGRlong *msg, IGRshort prev_font, IGRshort current_font, IGRint font_flags, IGRuchar *text_string, IGRshort *text_length));

#if defined(__cplusplus)
}
#endif


#undef __
