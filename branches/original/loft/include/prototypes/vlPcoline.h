#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VLallMethod.I */
void VLdispObj __((struct GRid *obj, struct GRmd_env *module, enum GRdpmode *mode, int code));
int VLconvertCoord __((struct GRmd_env *module, IGRdouble *vect, IGRdouble *wld, int type));
int VLgetName __((struct GRid *obj, char *pt_name));
int VLnameTest __((struct GRid *obj, char *str, struct GRid *cs, char *form_ptr));
int VLname2Test __((struct GRid *obj, struct GRid *cs, struct GRmd_env *module, char *str, char *form_ptr));
int VLtestExp __((struct GRid *obj, char *array, struct GRmd_env *module));
int VLgetVector __((struct GRid *point, struct GRid *point1, IGRdouble *pt, IGRdouble *pt1, struct GRmd_env *mod_info, struct GRid *obj_res));

/* VLbutMethod.I */
int VLseekFields __((struct ACrg_coll *list, int nb, char *array));
int VLreadDirect __((struct GRid *direct, int gadget, char *form_ptr, struct GRmd_env *module, enum GRdpmode *mode, int *point2, GRobjid *objid));
int VLmodifyList __((int old_nb, struct GRid *old_list, int nb, struct GRid *list));
int VLfindDirectName __((struct GRid *cs, char *name, struct GRmd_env *module, int type));

/* VLseaMethod.I */

#if defined(__cplusplus)
}
#endif

