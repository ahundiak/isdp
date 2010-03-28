#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRlnusrpos.I */
extern IGRint GRline_user_position __((IGRlong *msg, IGRuchar *text_string, IGRshort text_length, IGRint before, IGRshort start_line_num, IGRshort start_user_pos, IGRshort start_index, IGRint init_font_flags, IGRint font_flags, IGRshort prev_font, IGRshort current_font, IGRshort *line_num, IGRshort *user_pos, IGRshort *cursor_index));

#if defined(__cplusplus)
}
#endif


#undef __
