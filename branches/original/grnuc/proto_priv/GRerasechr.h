#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRerasechr.C */
extern IGRint GRerase_chars __((IGRlong *msg, IGRuchar *text_string, struct IGRestx *tx_attr, struct vfont_entry *font_info, struct IGRdisplay *disp_attr, IGRint action, IGRint lf_mask, IGRint field_type, IGRshort *del_char_index, struct GRcc_info *cc_info, struct IGResintx *text_info, struct IGRdisplay *cur_disp_attr, IGRint *erase_from, IGRint *erase_to, IGRshort *erase_index, IGRshort *chars_eol, short unsigned *flags, IGRdouble *kern_value));

#if defined(__cplusplus)
}
#endif


#undef __
