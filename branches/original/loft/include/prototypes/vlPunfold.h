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

/* VLdBoundFunk.I */
IGRlong VLcreBoundaries __((struct mise_a_plat *dev, struct GRvg_construct *cst, IGRboolean DisOpt, IGRboolean *WantGraGrp, IGRint *NumObj, struct GRobj_env **ObjRet));
IGRlong VLmatchEdgeWithAtt __((IGRshort checkOpt, struct mise_a_plat *dev, IGRint numAtt, struct GRid *attIds, IGRint numEdge, struct EdgeMatch *edgeIds, IGRlong *suc));
IGRlong VLedgeMatch __((struct mise_a_plat *dev, IGRint *NumLoops, IGRint **LoopIndex, IGRint *NumEdges, struct EdgeMatch **EdgeList, IGRlong *suc));
IGRint VLcheck3DCrv __((struct IGRbsp_curve *xyzCvAtt, struct IGRbsp_curve *crv));
IGRlong VLisOffNeeded __((double *OfVal, IGRint fromIndex, IGRint toIndex, IGRint *OuiNon));
IGRlong VLbuildUnwrapEdge __((struct mise_a_plat *dev, struct GRid *uvEdgeId, IGRdouble activCht, IGRdouble cht, struct GRvg_construct *cst, struct GRobj_env *UnwrapEdgeId, IGRlong *suc));
IGRlong VLretMaxOfVal __((int NumEdges, struct EdgeMatch *EdgeList, struct GRmd_env *mod_env, IGRdouble *MaxOfVal, IGRlong *suc));
IGRlong VLretOfVal __((struct GRid *EdgeMac, IGRdouble *OfVal, IGRlong *suc));
IGRlong VLdropCompCrv __((struct GRobj_env *CompId, IGRint numComp, struct GRid *ListIds, IGRint *index, IGRlong *suc));
IGRlong test_angle __((struct IGRbsp_curve *cv1, struct IGRbsp_curve *cv2, IGRdouble angle));
IGRlong VLcreBoundWithOff __((struct mise_a_plat *dev, struct GRvg_construct *cst, IGRboolean DisOpt, IGRint *NumObj, struct GRobj_env **ObjRet, IGRint **LoopIndex, IGRint *NumEdges, struct EdgeMatch **EdgeList, int *surf_type, struct GRid *line, int *nb_old_crvs, struct GRid **old_crvs,IGRlong *suc));

/* VLdFeaFunk.I */
IGRlong VLprecontTria __((struct mise_a_plat *dev, IGRint *indices));
IGRlong VLprecontRec __((struct mise_a_plat *dev, IGRint *indices));
IGRlong VLcalculPrecont __((struct mise_a_plat *dev));
IGRlong VLecritEntreeMef __((struct mise_a_plat *dev, IGRchar *filename));
IGRlong VLlitSortieMef __((struct mise_a_plat *dev, char *filename, IGRint efforts));

/* VLdFemFunk.I */
IGRlong VLdrawRec __((IGRdouble *pts, IGRint numU, IGRint i0, IGRint j0, IGRint i1, IGRint j1, IGRint i2, IGRint j2, IGRint i3, IGRint j3, IGRint creOpt, struct GRid *rectId));
IGRlong VLinitDev __((struct mise_a_plat *dev));
IGRlong VLfreeDev __((struct mise_a_plat *dev));
IGRint VLindex __((struct mise_a_plat *dev, IGRint u, IGRint v, IGRint corg));
IGRlong VLcreUnfoldSrfStr __((struct mise_a_plat *devel));
IGRlong VLcreUnfoldSrfStrOrig __((struct mise_a_plat *devel));
IGRlong VLgetPtsNorms __((struct mise_a_plat *devel, IGRshort opt, IGRdouble MeshTol));
IGRlong VLmaplatTria __((struct mise_a_plat *dev, IGRint i, IGRint j, IGRint i0, IGRint j0, IGRint i1, IGRint j1));
IGRlong VLmaplatRec __((struct mise_a_plat *dev, IGRint i, IGRint j, IGRint i0, IGRint j0, IGRint i1, IGRint j1, IGRint i2, IGRint j2));
IGRlong VLnewMaplatRec __((struct mise_a_plat *dev, IGRint i, IGRint j, IGRint i0, IGRint j0, IGRint i1, IGRint j1, IGRint i2, IGRint j2));
IGRlong VLmaplatQuad __((struct mise_a_plat *dev, IGRint i0, IGRint j0, IGRint I, IGRint J));
IGRlong VLmaplatDevel __((struct mise_a_plat *dev));
IGRlong VLmaplatNDevel __((struct mise_a_plat *dev));
IGRlong VLdrawTria __((IGRdouble *pts, IGRint numU, IGRint i0, IGRint j0, IGRint i1, IGRint j1, IGRint i2, IGRint j2, IGRint creOpt, struct GRid *triaId));

/* VLdTool1Funk.I */
int VLconvert_coord __((IGRdouble *vect, IGRdouble *wld, struct GRid *cs));
IGRlong VLcreOrd2Srf __((IGRdouble *poles, IGRint Nu, IGRint Nv, IGRdouble *KtsU, IGRdouble *KtsV, IGRshort constOpt, struct GRvg_construct *cst, IGRboolean display, struct GRobj_env *ObjSrf, struct IGRbsp_surface **sf, IGRlong *msg));
IGRlong VLcre3dCvFromParams __((IGRshort dim, struct IGRbsp_surface *devSrf, IGRint numUV, IGRdouble *uv, struct GRvg_construct *cst, struct GRobj_env *obj, IGRlong *msg));
int VLlongHorzOrTrans __((struct GRobj_env *SurfObj, IGRint *type));
int VLget_side_w_more_mrkln __((struct GRobj_env *plate, char *side_name));
IGRlong VLgetNumMrkLns __((struct GRobj_env *plate, IGRint *num_hor_ln, IGRint *num_ver_ln));
int VLcompute_expansion_factors __((struct GRobj_env *plate, double length, double width, double x_expansion, double y_expansion, int type_expansion, struct GRmd_env *cur_env, double *mat, double *new_length, double *new_width));
IGRlong VLfilterCntLn __((int Mgr_count, struct GRobj_env *cntrl, struct GRobj_env *tp_manager, int count, struct GRobj_env *list, int *ln_to_add));
IGRlong VLcreWinRef __((IGRdouble *orig, struct GRid winObj, IGRboolean creOpt, struct GRvg_construct *cst, IGRboolean disOpt, IGRdouble *refMat, struct GRobj_env *refGRid, IGRlong *rc));
int VLcreFromMat __((struct GRid RNG, struct GRmd_env *mod_env, IGRdouble *fromMat, IGRlong *ret));
int VLnewCreFromMat1 __((struct GRid RNG, struct GRmd_env *mod_env, IGRdouble *fromMat, IGRlong *ret));
int VLnewCreFromMat __((struct GRid RNG, struct GRmd_env *mod_env, struct mise_a_plat *dev, IGRdouble *fromMat, IGRlong *ret));
IGRlong VLapplyTransf __((struct GRid *Obj, IGRint NumObj, struct GRmd_env *mod_env, IGRdouble *FromMat, IGRdouble *ToMat, IGRdouble *trfMat, IGRshort *trfMatType, IGRlong *msg));
void __DBGpr_bscv __((IGRchar *txt, struct IGRbsp_curve *bsp, IGRlong *rc));

/* VLdToolsFunk.I */
int VLfindOrientation __((struct GRobj_env *surf, struct GRid *edgeC, struct GRid *edgeF, struct GRid *edgeD, int *surf_type));
int VLget_mac_names __((struct GRid *ln, int orient, double length, double width, struct GRid *cs, struct GRmd_env *ln_env, struct GRmd_env *cur_env, char *symbo));
IGRint VLget_lines __((struct mise_a_plat *dev,struct GRobj_env *plate, int opt,struct GRmd_env *mod_env, int *count, struct GRobj_env **list));
IGRlong VLgetCrvsConToSrf __((struct mise_a_plat *dev, struct GRobj_env *plate, struct GRvg_construct *cst, IGRint opt, IGRint *contour_index, IGRint *numChild, IGRint *numCrvs, struct GRobj_env *Crvs, IGRint numOldCrvs, struct GRid *OldCrvs,IGRlong *sts));
IGRlong VLgetCutMarkLns __((struct mise_a_plat *dev, struct GRobj_env *plate, struct GRvg_construct *cst, int *NumEdges, struct EdgeMatch **EdgeList, struct GRid *min_rec, int *num_out_ids, struct GRid *out_ids, int *Cut_index, int *contour_index, struct GRid *line, int *surf_type, double *Length, double *Width));
IGRlong VLplace_symbols __((struct GRobj_env *surf, int surf_type, struct GRid *cs, struct GRvg_construct *cst, double x1, double y1, double x2, double y2, struct GRid *line, double length, double width, struct GRid *type_symb, struct GRid *orient_symb));

/* VLunwMethod.I */
int VLfind_max_edge __((struct GRobj_env *surf, IGRint nb, struct GRmd_env *modenv, IGRdouble *len));

/* VLunwrapCmdi.I */

#if defined(__cplusplus)
}
#endif

