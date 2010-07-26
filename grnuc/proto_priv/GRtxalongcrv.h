#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRtxalongcrv.C */
extern IGRint GRtext_along_curve __((IGRlong *msg, struct IGRbsp_curve *curve, IGRpoint start_pt, IGRpoint side_pt, IGRint preferred_dir, IGRmatrix view_matrix, IGRuchar *text_string, struct vfont_entry *font_info, IGRdouble text_width, IGRdouble text_height, IGRdouble char_spacing, IGRdouble line_spacing, IGRshort *text_length, IGRint *num_pts, IGRpoint *origin, IGRmatrix *orient_matrix, IGRint *out_flags));

#if defined(__cplusplus)
}
#endif


#undef __
