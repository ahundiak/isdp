#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRjuststr.C */
extern IGRboolean GRjust_string __((IGRlong *msg, IGRuchar **text_string, IGRshort *text_length, IGRshort *text_buf_size, struct vfont_entry *font_info, struct IGRdisplay *disp_attr, struct GRdpb_text_symb *text_symb, IGRint num_positions, IGRshort *positions[], struct extents *text_extents));

#if defined(__cplusplus)
}
#endif


#undef __
