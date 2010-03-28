#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRfwdcurpos.I */
extern IGRint GRfwd_cursor_position __((IGRlong *msg, IGRuchar *text_string, IGRshort text_length, IGRshort start_index, IGRshort *prev_font, IGRshort *current_font, IGRint *font_flags, IGRshort *cursor_index));

#if defined(__cplusplus)
}
#endif


#undef __
