#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRtxextents.C */
extern IGRboolean GRtx_extents __((IGRlong *msg, IGRuchar *text_string, IGRshort *text_length, struct vfont_entry *font_info, struct IGRdisplay *disp_attr, IGRdouble char_spacing, IGRdouble line_spacing, IGRdouble text_width, IGRdouble text_height, IGRshort font, IGRshort start_char, IGRshort end_char, struct extents *text_extents));

#if defined(__cplusplus)
}
#endif


#undef __
