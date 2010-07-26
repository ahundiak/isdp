#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRdispchr.C */
extern IGRint GRdisplay_chars __((IGRlong *msg, IGRuchar *text_string, IGRshort *text_length, IGRint display_from, IGRint display_to, IGRshort *cc_index, IGRshort *display_index, IGRshort *chars_eol, IGRint font_flags, short unsigned flags, IGRdouble kern_value, struct IGResintx *text_info));

#if defined(__cplusplus)
}
#endif


#undef __
