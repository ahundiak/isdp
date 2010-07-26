#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRchrposinfo.C */
extern IGRint GRchar_pos_info __((IGRlong *msg, IGRuchar *text_string, IGRshort index, IGRint info_flag, struct IGRestx *text_attr, struct vfont_entry *font_info, struct IGRdisplay *disp_attr, struct GRcc_info *cc_info));

#if defined(__cplusplus)
}
#endif


#undef __
