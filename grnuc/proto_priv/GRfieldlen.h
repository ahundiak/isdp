#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRfieldlen.C */
extern IGRboolean GRget_field_len __((IGRlong *msg, IGRuchar *text_string, IGRshort *text_length, IGRshort *beg_field, IGRshort prev_font, IGRshort current_font, IGRint font_flags, IGRshort *field_length));

#if defined(__cplusplus)
}
#endif


#undef __
