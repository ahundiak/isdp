#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRtxcursor.I */
extern IGRint GRtext_cursor __((IGRlong *msg, IGRuchar *text_string, struct GRcc_info *cc_info, struct IGRestx *text_attr, struct IGRlbsys *lbs_geom, enum GRdpmode *draw_mode, IGRshort *line_mode, IGRint view_ind));

#if defined(__cplusplus)
}
#endif


#undef __
