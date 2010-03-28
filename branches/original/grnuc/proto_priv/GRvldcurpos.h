#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRvldcurpos.C */
extern IGRint GRvalid_cursor_position __((int msg, IGRuchar *text_string, IGRshort text_length, IGRshort prev_font, IGRshort current_font, IGRint font_flags, IGRshort target_index, IGRshort *cursor_index));

#if defined(__cplusplus)
}
#endif


#undef __
