#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRfldendchr.C */
extern IGRint GRfield_end_char __((IGRlong *msg, IGRuchar *text_string, IGRshort text_length, IGRshort field_index, IGRshort *prev_font, IGRshort *current_font, struct vfont_entry *font_info, IGRshort *char_index));

#if defined(__cplusplus)
}
#endif


#undef __
