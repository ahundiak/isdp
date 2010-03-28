#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRtxfldbox.C */
extern IGRint GRtext_fieldbox __((IGRlong *msg, IGRuchar *text_string, struct IGRestx *text_attr, struct vfont_entry *font_info, struct IGRdisplay *disp_attr, IGRshort *begin_field, enum GRdpmode *draw_mode, struct IGRlbsys *lbs_geom, IGRint view_ind));

#if defined(__cplusplus)
}
#endif


#undef __
