#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRfldrefpt.C */
extern IGRboolean GRfld_ref_pt __((IGRlong *msg, IGRuchar *text_string, IGRshort *text_length, IGRuchar *field_num, struct vfont_entry *font_info, struct IGRdisplay *disp_attr, IGRdouble *line_space, IGRdouble *char_space, IGRdouble *th, IGRdouble *tw, IGRshort *font, IGRchar *just, IGRdouble *h_move, IGRdouble *v_move));

#if defined(__cplusplus)
}
#endif


#undef __
