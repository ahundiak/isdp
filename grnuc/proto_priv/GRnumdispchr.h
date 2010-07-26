#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRnumdispchr.C */
extern IGRboolean GRnum_disp_char __((IGRlong *msg, IGRuchar *text_string, IGRshort *text_length, IGRshort current_font, IGRint font_flags, IGRshort *num_disp_char));

#if defined(__cplusplus)
}
#endif


#undef __
