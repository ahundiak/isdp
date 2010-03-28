#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/so/DEmac.I */
extern int DEplace_so __((long *msg, int type, struct IGRdisplay *symb, double u1, double u2, struct GRid *go, struct GRid *window, struct GRmd_env *module, int inter));
extern int DEdelete_soo_in_view __((long *msg, struct GRid *go, struct GRid *window, struct GRmd_env *module));
extern int DEdelete_so __((long *msg, int type, struct IGRdisplay *symb, double u1, double u2, struct GRid *go, struct GRid *window, struct GRmd_env *module));
extern int DEdelete_by_objid __((long *msg, uword osnum, GRobjid objid));
extern int DEcreate_soo __((long *msg, OM_S_OBJID *p_objid, ushort osnum));
extern int DEchange_so __((long *msg, int old_type, struct IGRdisplay *old_symbology, double old_u1, double old_u2, struct GRid *old_window, struct GRmd_env *old_md_env, int type, struct IGRdisplay *symbology, double u1, double u2, struct GRid *go, struct GRid *window, struct GRmd_env *md_env, int interference));
extern int DEretrieve_so __((long *msg, int *p_type, struct IGRdisplay *symb, double *p_u1, double *p_u2, struct GRid *go, double u, struct GRid *window, struct GRmd_env *module));
extern int DEnext_so __((long *msg, int *p_type, struct IGRdisplay *symb, double *p_u1, double *p_u2));
extern int DEcopy_soo __((long *msg, struct GRid *from_window, struct GRid *to_window));
extern int DEobjid_changed __((long *msg, struct GRid *old_id, struct GRid *new_id));

#if defined(__cplusplus)
}
#endif


#undef __
