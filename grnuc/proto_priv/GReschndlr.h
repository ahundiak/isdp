#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GReschndlr.I */
extern IGRboolean GResc_handler __((IGRlong *msg, IGRuchar *text_string, IGRint esc_seq_index, struct IGRestx *text_attr, IGRdouble wk_origin[2 ], IGRdouble *base_line, struct vfont_entry *font_info, IGRshort *prev_font, struct IGRdisplay *disp_attr, struct just_info *just_info, struct extents *extents, IGRshort *esc_seq_size));

#if defined(__cplusplus)
}
#endif


#undef __
