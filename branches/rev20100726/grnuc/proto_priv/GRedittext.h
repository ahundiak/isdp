#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRedittext.I */
extern IGRboolean GRedit_text __((IGRlong *msg, IGRint init_edit, IGRuchar *keyin, IGRint keyin_nbytes, IGRuchar **text_string, struct IGRestx *tx_attr, IGRshort *text_buf_size, struct vfont_entry *font_info, struct IGRdisplay *disp_attr, IGRshort *num_lines, struct GRcc_info *cc_info, struct IGResintx *text_info, struct DPele_header *ele_header, enum GRdpmode erase_mode, enum GRdpmode display_mode, IGRint view_ind));

#if defined(__cplusplus)
}
#endif


#undef __
