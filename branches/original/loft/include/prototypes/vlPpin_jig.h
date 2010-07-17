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

/* VLbalCmdi.I */

/* VLbalLstCmdi.I */

/* VLevalCmdi.I */

/* VLgrdFunk.I */
IGRlong VLevalFromMat __((struct GRobj_env *LocObj, IGRint NumObj, IGRchar *side, IGRdouble offset, IGRint Jigtype, struct IGRplane *Normal, struct GRmd_env *Env, IGRdouble *FromMat, IGRlong *msg));
IGRlong VLappFromMat __((struct GRobj_env *Obj, IGRint nobj, struct GRobj_env *GndRef, struct GRvg_construct *cst, IGRdouble *FromMat, IGRboolean CopyFlag, IGRboolean display, struct GRobj_env *Copy, IGRlong *msg));
IGRlong VLevalAvNor __((struct GRobj_env *Obj, IGRint Nobj, IGRdouble *AvgPnt, IGRdouble *AvgNrm, IGRlong *msg));
IGRlong VLdirectorCosine __((IGRdouble *matrix, IGRdouble *angle));
IGRlong VLeulerCS __((IGRlong *msg, struct GRobj_env *gcs, IGRdouble *ang, struct GRmd_env *Env, struct GRobj_env *bcs));

/* VLklPlace.I */
IGRlong VSklGetPlateSeams __((IGRlong *msg, IGRint *count, struct GRobj_env **list));
IGRlong VLcreateKLJunction __((IGRlong *msg, struct GRid *line, struct GRmd_env *env, IGRchar *name, struct GRid *junction));
IGRlong VLklGetIntersectionLines __((IGRlong *msg, struct GRobj_env *plate, struct GRobj_env *mold_srf, struct GRid *key_lines, IGRint *count, struct GRid *pt_list));
IGRlong VLklGetDiagonalChordDim __((IGRlong *msg, struct GRobj_env *surf, struct GRid *key_lines, struct GRid *list));
IGRlong VLklGetKeyLines __((IGRlong *msg, struct GRobj_env *surface, struct GRobj_env *frame, struct GRid *key_lines));
IGRlong VLklGetGirthDims __((IGRlong *msg, struct GRobj_env *plate_key));

/* VLklStrLines.I */
IGRlong VLklGetStructuralLines __((IGRlong *msg, struct GRobj_env *plate, IGRint *count, struct GRid **lines));

/* VLmodMapCmdi.I */

/* VLpinAlgo.I */
IGRint VLfourCornersAlgo __((IGRint cnt, VLpinJigPanel *pnt));
IGRlong VLpanelCornerPoints __((IGRlong *msg, struct GRid *balanceId, struct GRmd_env *Env, IGRint *npnl, IGRpoint **panelP));
IGRlong VLpinCorners __((IGRlong *msg, struct GRobj_env *pinjig, IGRint npin, IGRint *ncrn, VLpinCorn **corner, IGRint *npnl, VLpinCorn **panelC));
void VLorder4corners __((IGRdouble *pts, VLpinCorn *crn));
void EulerAngleToMatrix __((IGRpoint Ang, IGRmatrix Mat));
IGRlong VLbasePoints __((IGRlong *msg, struct GRobj_env *Bal, VLbalBasePts *Bas));
IGRint VLget3Dtranslation __((IGRlong *msg, struct GRobj_env *Bal, IGRmatrix *T3d));

/* VLpinFunk.I */
//#define TRACE 1 IGRlong VLmatrixPoints __((IGRlong *msg, struct GRobj_env *Contour, IGRint column, IGRint line, IGRdouble *Ipts, IGRint *npts, struct VLpinJig *Opts));
IGRboolean VLjigDecode __((IGRint idx, IGRint *flag));
IGRint VLsortByYpt __((IGRdouble *a, IGRdouble *b));
IGRboolean VLjigEncode __((IGRint *idx, IGRint *flag));
IGRlong VLintersectColumn __((IGRlong *msg, IGRint col, IGRint lin, IGRint idx, IGRchar *oobject, struct GRid *Macro, struct GRmd_env *Env, IGRint *num, struct VLpinJig *pin));
IGRlong VLseamsPoints __((IGRlong *msg, IGRint plt, IGRint col, IGRint idx, struct GRid *Balance, struct GRid *Layout, struct GRmd_env *Env, IGRint *num, struct VLpinJig *pin));
IGRlong VLbetweenPoints __((IGRlong *msg, IGRint nseam, IGRint inter, struct VLpinJig *pin, IGRint *num));
IGRlong VLeliminatePoints __((IGRlong *msg, IGRint npin, struct VLpinJig *pin, IGRdouble zone, IGRint *num));
IGRlong VLgetVSplatePrjPoint __((IGRlong *msg, struct GRobj_env *Plate, IGRchar *name, IGRpoint Point, IGRvector Axis, IGRpoint *Proj));
IGRlong VLpinHeightAngle __((IGRlong *msg, struct GRid *Balance, struct GRmd_env *Env, IGRint nmax, struct VLpinJig *pin));
IGRint VLsortPJcolYpt __((struct VLpinJig *a, struct VLpinJig *b));
IGRlong VLgetPinAttributes __((IGRlong *msg, struct GRid *PinJig, IGRint idx, struct ACrg_coll *elem));
void VLnamePJcollection __((struct ACrg_coll *attr, IGRint *idx));
void VLfillPJcollection __((struct ACrg_coll *elem, struct ACrg_coll *attr));

/* VLpinLstCmdi.I */

/* VLsbPlace.I */
void VLrmDupObjsInList __((IGRint count, struct GRobj_env *list, IGRint *newcount));
long VLgetListeningPretends __((long *msg, const struct GRid *notifier, int *count, struct GRid **list));
IGRlong VLgetPlatesThroughPretends __((IGRlong *msg, struct GRobj_env *object, IGRint *count, struct GRobj_env **list));
IGRlong VSsbGetAllActivePlatesOnPlate __((IGRlong *msg, struct GRobj_env *inp_plate, IGRint *nb_plates, struct GRobj_env **plates));
IGRlong VSsbGetAllActivePlates __((IGRlong *msg, struct GRobj_env *inp_surface, struct GRobj_env *inp_plate, IGRint *nb_plates, struct GRobj_env **plates));
IGRlong VSsbGetEJEdgeIndex __((IGRlong *msg, IGRint nb_edges, struct IGRbsp_curve **edges, IGRdouble *vector, IGRint *index));
IGRlong VSsbGetCornerAndEdge __((IGRlong *msg, struct GRobj_env *surf, struct GRid *sb_mac, IGRint dir, IGRint pt_dir, struct GRid *edgeId, struct GRid *pt_id));
IGRlong VLsbGetMoldSurface __((IGRlong *msg, struct GRobj_env *plate, enum GRdpmode mode, struct GRobj_env *surface));
IGRlong VSsbGetMoldLines __((IGRlong *msg, struct GRobj_env *surf, struct GRobj_env *srfEdge, struct GRid *start_pt, IGRint ej_dir, IGRint flow_dir, IGRint wat_val, IGRint mark_val, IGRint *pt_count, struct GRid *pt_list));
IGRlong VSsbGetBndSrfObjs __((IGRlong *msg, IGRint *count, struct GRobj_env **list));

#if defined(__cplusplus)
}
#endif

