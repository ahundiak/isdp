#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRparescseq.C */
extern IGRboolean GRparse_escape_sequence __((IGRlong *msg, IGRuchar *text_string, IGRshort *text_length, IGRshort font, IGRshort prev_font, struct vfont_entry *font_info, IGRshort start_index, IGRshort *finish_index));

#if defined(__cplusplus)
}
#endif


#undef __
