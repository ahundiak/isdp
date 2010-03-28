#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRbwddispchr.C */
extern IGRboolean GRbwd_disp_char __((IGRlong *msg, IGRuchar *text_string, IGRshort *end_index, IGRshort *font, struct vfont_entry *font_info, IGRshort *prev_font, IGRshort *char_index));

#if defined(__cplusplus)
}
#endif


#undef __
