#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/AStext/ASfieldpti.I */
extern int AStext_pt_eval __((struct IGRestx *p_text_attr, IGRdouble *p_dx, IGRdouble *p_dy, IGRshort justif, struct ret_struct *p_textdef, IGRdouble *abs_point));
extern int ASfield_pt_eval __((struct just_pts *p_justif_pts, struct IGRestx *p_text_attr, IGRdouble *p_dx, IGRdouble *p_dy, struct extents *p_extent, IGRshort justif, struct ret_struct *p_textdef, IGRdouble *abs_point));

#if defined(__cplusplus)
}
#endif


#undef __
