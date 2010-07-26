#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/AStext/ASsrctexti.I */
extern int AStext_alloc __((IGRint size));
extern int AStext_store __((IGRchar *text, IGRint len));
extern int ASget_ext __((struct IGResintx *tx_attr, struct IGRdisplay *disp_attr, struct extents *ext));
static void ASget_lbsys __((struct GRid ref, struct GRid point, struct GRid supp, IGRdouble *real_origin, IGRdouble *target, IGRdouble *trans, struct ret_struct *suppdef, struct extents *ext, IGRint in_flag, struct IGRlbsys *lbs_geom, IGRint *orient, IGRint *flipped, struct GRmd_env *md_env, IGRint cn_type));

#if defined(__cplusplus)
}
#endif


#undef __
