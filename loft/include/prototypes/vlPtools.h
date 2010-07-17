/* $Id: vlPtools.h,v 1.1.1.1 2001/01/04 21:11:13 cvs Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	VLinteg/include/prototypes / vlPtools.h
 *
 * Description:	prototypes of src/tools functions.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vlPtools.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:11:13  cvs
 *	Initial import to CVS
 *	
 * Revision 1.2  2000/02/10  21:54:36  pinnacle
 * (No comment)
 *
 * Revision 1.1  1998/04/30  10:32:50  pinnacle
 * LOFT 2.5.1
 *
 * Revision 1.1  1997/05/08  14:05:56  pinnacle
 * Loft 250
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	04/07/97   mf		header creation.
 *	04/08/97   mf		Bug in VLexternalContour() prototype.
 *      02/10/00   RR           Added Range argument in VLcheckStiffOnPlate()
 *************************************************************************/
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

/* VLcheckFunk.I */
long VLinterCvSf __((struct GRobj_env *cv, struct GRobj_env *sf, short trimSf, struct GRmd_env *locEnv, int *count, struct GRid **inter));
long VLcheckAngle __((struct GRobj_env *cv1, struct GRobj_env *cv2, double par1));
long VLcheckGenLine __((struct GRobj_env *plate, struct GRobj_env *genLine, struct GRmd_env *locEnv));
long VLcheckStiffMac __((struct GRobj_env *mac, struct GRobj_env *stiff));
long VLgetOperName __((char *macName, struct GRid *macId, char *selector, char *operName));
long VLcheckBorderLine __((struct GRobj_env *plate, struct GRobj_env *genLine, struct GRmd_env *locEnv));
long VLcheckStiffOnPlate __((struct GRobj_env *plate, GRrange range, struct GRobj_env *Stiff, struct GRmd_env *locEnv));

/* VLcontAlgo.I */
IGRdouble VLtol __((IGRint idx));
IGRlong VLdotProduct __((IGRlong *msg, IGRvector ve1, struct GRobj_env *cv1, IGRpoint sp1, IGRdouble sw1, IGRpoint ep1, IGRdouble ew1, IGRint nm1, IGRvector ve2, struct GRobj_env *cv2, IGRpoint sp2, IGRdouble sw2, IGRpoint ep2, IGRdouble ew2, IGRint nm2, IGRdouble *dot));
IGRdouble VLdistance __((IGRpoint p1, IGRpoint p2));
void VLalgoNodeEdge __((VLalgoNode *Nod, VLalgoEdge *Edg, IGRpoint *spt, IGRpoint *ept, IGRint *nod));
IGRlong VLfindExternal __((IGRlong *msg, IGRint nEdg, struct GRid *Edg, struct GRmd_env *Env, IGRint *nCnt, struct GRobj_env **Cnt));
IGRlong VLgetSupportSurfaces __((IGRlong *msg, IGRint num, struct GRobj_env *srf, struct GRobj_env *plt, IGRchar *side, struct GRmd_env *Env, struct GRobj_env **sup, struct IGRbsp_surface ***sur));
IGRlong VLexternalContour __((IGRlong *msg, IGRint num, struct GRobj_env *srf, struct GRobj_env *plt, IGRchar *side, struct GRmd_env *Env, IGRint *cnt, struct GRobj_env **edg, struct IGRbsp_curve ***crv, struct GRobj_env *Cnt, struct IGRbsp_surface ***sur, struct IGRplane *nrm));
IGRlong VLfourEdgesContour __((IGRlong *msg, IGRint num, struct GRobj_env *srf, struct GRobj_env *plt, IGRchar *side, struct GRmd_env *Env, IGRint *cnt, struct GRobj_env **edg, struct IGRbsp_curve ***crv, struct GRobj_env *Cnt, struct IGRbsp_surface ***sur, struct IGRplane *nrm));
IGRlong VLcontrolLine __((IGRlong *msg, IGRint num, struct GRobj_env *srf, struct GRobj_env *plt, IGRchar *side, struct GRmd_env *Env, IGRvector *axe, IGRvector *avn, struct BendingLineInfo *Info, struct GRobj_env *Curv));

/* VLcontFunk.I */
void VLdel __((struct IGRbsp_curve *bsp));
void VLdel_mem __((int nb_plates, int *num, struct IGRbsp_curve ***tab));
int VLsame_pole __((IGRdouble *pt1, IGRdouble *pt2));
int VLsame_point __((IGRdouble *pt1, IGRdouble *pt2, IGRdouble tol));
int VLprod __((IGRdouble *pt1, IGRdouble *pt2));
int VLmore_of_mem __((struct IGRbsp_curve *cv1, struct IGRbsp_curve *cv2, struct IGRbsp_curve *cvv));
int VLfind_distances __((struct IGRbsp_curve *cv1, struct IGRbsp_curve *cv2, IGRdouble *disp1cv1, IGRdouble *disp2cv1, IGRdouble *disp1cv2, IGRdouble *disp2cv2, IGRdouble *parmp1cv1, IGRdouble *parmp2cv1, IGRdouble *parmp1cv2, IGRdouble *parmp2cv2));
int VLone_in_other __((struct IGRbsp_curve *cv1, struct IGRbsp_curve *cv2, IGRdouble disp1cv1, IGRdouble disp2cv1, IGRdouble disp1cv2, IGRdouble disp2cv2, IGRdouble parmp1cv1, IGRdouble parmp2cv1, IGRdouble parmp1cv2, IGRdouble parmp2cv2));
int VLadjacence __((struct IGRbsp_curve *cv1, struct IGRbsp_curve *cv2));
int VLmerged __((struct IGRbsp_curve *cv1, struct IGRbsp_curve *cv2, IGRdouble disp1cv1, IGRdouble disp2cv1, IGRdouble disp1cv2, IGRdouble disp2cv2, IGRdouble parmp1cv1, IGRdouble parmp2cv1, IGRdouble parmp1cv2, IGRdouble parmp2cv2));
int VLdelete_common_edges __((int num1, struct IGRbsp_curve **bsp1, int num2, struct IGRbsp_curve **bsp2, int *stop));
IGRlong VLFindEdges __((struct GRobj_env *SurfObj, struct IGRbsp_curve ***bspcv, int *num, IGRlong *msg));
int VLn_edges_to_4_edges __((int nb_edge, struct IGRbsp_curve **cv_contour));
IGRlong VLmakeContour __((int *msg, int nb_plates, struct GRobj_env *plates, IGRchar *name, int *nb_edge, struct GRobj_env *contour_id, struct IGRbsp_curve **cv_contour, struct GRmd_env *modenv, int four, struct IGRbsp_curve ***tab_cv, IGRint *Num_Edges));
IGRlong VLsimpleClLine __((IGRint *msg, struct IGRbsp_curve **contour, IGRdouble *ShipAxis, struct BendingLineInfo *controlLine, IGRint nb_surf));
IGRlong VLfindClLine __((IGRint *msg, IGRint nb_plates, struct GRobj_env *plates, IGRchar *name, struct GRmd_env *mod_env, IGRdouble *ShipAxis, IGRdouble *normal, struct BendingLineInfo *controlLine, struct GRobj_env *ControlObj));
IGRlong VLget_ext_contour __((IGRlong *msg, IGRint nb_surf, struct GRobj_env *surf_list, struct GRvg_construct *cst, struct GRid *ext_contour));
IGRlong VLgetContour __((int *msg, int nb_plates, struct GRobj_env *plates, IGRchar *name, struct GRid *contour_id, struct GRvg_construct *cnst_list));

/* VLdbgFunk.I */
int VLhiliteObj __((GRobjid id, short os, int mode));
int VLcpObj __((GRobjid id, short os));

/* VLdevFunk.I */
int VLdevExtLoop __((struct GRid *SF, struct GRmd_env *SF_ENV, struct GRid *RDV, struct GRmd_env *RDV_ENV));
IGRlong VLextractSurface __((IGRlong *msg, struct GRid *in_sf, struct GRmd_env *in_env, IGRint nb_cv, struct GRid *cv, struct GRmd_env *cv_env, IGRdouble *area, struct GRid *out_sf, struct GRmd_env *out_env));
IGRlong VLplPt __((IGRlong *msg, IGRdouble *pt, struct GRid *pt_id, struct GRmd_env *md_env));
IGRlong VLgetPtCoord __((IGRlong *msg, struct GRid pt_id, struct GRmd_env *loc_env, IGRdouble *coord));
IGRlong VLgetPtOnCvInInter __((IGRlong *msg, struct GRid *cv_base, struct GRmd_env *b_env, struct GRid *cv_1, struct GRmd_env *env_1, struct GRid *cv_2, struct GRmd_env *env_2, IGRshort int_way, struct GRmd_env *out_env, IGRdouble par_in_int, IGRdouble *pt_on));
IGRlong VLgetPtsOnPartAtPars __((IGRlong *msg, struct GRid *cv_base, struct GRmd_env *b_env, struct GRid *cv_1, struct GRmd_env *env_1, struct GRid *cv_2, struct GRmd_env *env_2, IGRshort int_way, struct GRmd_env *out_env, IGRdouble nb_par, IGRdouble *pars, IGRdouble *pt_on, IGRdouble *tang));
IGRlong VLgetPtsOnPartAtParsLen __((IGRlong *msg, struct GRid *cv_base, struct GRmd_env *b_env, struct GRid *cv_1, struct GRmd_env *env_1, struct GRid *cv_2, struct GRmd_env *env_2, IGRshort int_way, struct GRmd_env *out_env, IGRint nb_par, IGRdouble *pars, IGRdouble *pt_on, IGRdouble *tang));

/* VLedgeFunk.I */
IGRlong VLextractSurfaceEdge __((IGRlong *msg, struct GRobj_env *Sf, IGRdouble u, IGRdouble v, IGRdouble *n, struct GRmd_env *Env, struct GRvg_construct *Cst, struct GRid *Line, struct GRid *Plan, IGRchar *Name));
IGRlong VLsplitAtTurns __((struct IGRbsp_curve *Icrv, struct IGRbsp_curve **Ocrv, IGRint *cnt, IGRlong *msg));
IGRlong VLextractUvEdges __((IGRlong *msg, struct GRobj_env *Sf, IGRint *Nedg, IGRint *Onum, struct IGRbsp_curve **Ocrv));
void VLevalUvGridFrom4Cv __((IGRint opt, IGRint Unum, IGRint Vnum, struct IGRbsp_curve **curv, struct IGRbsp_surface **grid, BSrc *rc));
void VLevalUvGridFrom3Cv __((IGRint num, struct IGRbsp_curve **curv, struct IGRbsp_surface **grid, BSrc *rc));
void VLevalUvGridFromPnt __((IGRint Unum, IGRint Vnum, struct IGRbsp_surface *geom, struct IGRbsp_surface **grid, BSrc *rc));

/* VLevalFunk.I */
IGRlong VLevalSrfAveragePlane __((struct GRobj_env *Srf, IGRint Nsrf, IGRpoint AvgPnt, IGRvector AvgNrm, IGRlong *msg));
IGRlong VLevalPltElevation __((struct GRobj_env *Plt, IGRint Nplt, IGRint Cnorm, IGRint Inorm, IGRchar *side, IGRdouble *Elev, IGRlong *msg));
IGRlong VLevalUvGridFromPlane __((struct GRobj_env *Plane, IGRint Unpt, IGRint Vnpt, struct IGRbsp_surface **Geom, struct IGRbsp_surface **Grid, IGRlong *msg));
IGRlong VLevalSrfGeometry __((struct GRobj_env *Srf, IGRint Nsrf, IGRdouble *Avp, IGRdouble *Avn, IGRint *Npnt, IGRdouble **Pnt, IGRlong *msg));
IGRint VLtmpSort __((VLstfTpl *a, VLstfTpl *b));
IGRlong VLdistanceAlongNormal __((VLstfTpl *Pnt, IGRint Npnt, IGRdouble *Avp, IGRdouble *Avn, IGRdouble *Dist, IGRlong *msg));
IGRlong VLevalPltCenterNormalDistance __((struct GRobj_env *Plt, IGRint Nplt, IGRchar *side, IGRint Cnorm, IGRint Inorm, IGRboolean optimiz, IGRdouble *Avp, IGRdouble *Avn, IGRdouble *dist, IGRlong *msg));

/* VLfilterFunk.I */
void VLswapObjEnv __((struct GRobj_env list[], int fromA, int toA));
void VLfilterClass __((int length, struct GRobj_env list[], int *count, GRclassid cid));
void VLfilterLevel __((int length, struct GRobj_env list[], int *count, short level));
void VLfilterProps __((int length, struct GRobj_env list[], int *count, short mask));
void VLfilterDef __((int length, struct GRobj_env list[], int *count, char *defName));
void VLfilterName __((int length, struct GRobj_env list[], int *count, char *name));
void VLfilterAttr __((int length, struct GRobj_env list[], int *count, struct ACrg_coll *attr));
void VLfilterDefAttrName __((int length, struct GRobj_env list[], int *count, char *attrName));
void VLfilterDefAttrValue __((int length, struct GRobj_env list[], int *count, char *attrName, char *attrVal));
void VLfilterGeometry __((int length, struct GRobj_env *list, int *count, long (*fctCheck )(), char *p_args));
void VLfilterFootName __((IGRint length, struct GRobj_env list[], IGRint *count, IGRchar *footname));

/* VLgeomFunk.I */
IGRint VLgetGeometry __((struct GRobj_env *GraObj, IGRboolean EdgeFlag, OM_S_OBJID MyStupidId, IGRchar **Geometry, IGRlong *msg));
IGRlong VLgetExGeometry __((struct GRobj_env *GraObj, OM_S_OBJID MyStupidId, IGRchar **ReturnedGeometry, IGRlong *msg));

/* VLhandlerVS.I */
IGRint VLfeatureType __((struct GRid *feature, IGRulong *r_type, IGRlong *msg));
IGRint VLfeatureAH __((IGRulong *type, struct GRlc_info *entry, struct LC_action_args *args, enum GRlocate_action *action));
IGRint VLfeaturePF __((struct GRobj_env *object, VSfenceArgs *args));
IGRint VLstrechVActHand __((char *type, struct GRlc_info *entry, struct LC_action_args *args, enum GRlocate_action *action));
int VLhilitePlateAH __((char *type, struct GRlc_info *entry, struct LC_action_args *args, enum GRlocate_action *action));
IGRboolean VLisSurfacePlanar __((struct GRid *surfId, struct GRmd_env *surfEnv));
IGRint VLisSurfacePlanarAH __((struct GRmd_env *loc_env, struct GRlc_info *entry, struct LC_action_args *args, enum GRlocate_action *action));
IGRint VLisSurfacePlanarPF __((struct GRobj_env *Surf, VSfenceArgs *args));

/* VLmiscFunk.I */
IGRlong VLvector __((IGRlong *msg, IGRpoint point1, IGRpoint point2, IGRdouble coef1, IGRdouble coef2, IGRboolean normed, IGRvector vector));
IGRlong VLendpts __((IGRlong *msg, struct GRid *Obj, struct GRmd_env *Env, IGRdouble spt[], IGRdouble ept[]));
IGRlong VLdetplane __((IGRlong *msg, struct GRid *Kline, struct GRmd_env *Env, IGRdouble *Normal, IGRdouble *Axis, struct IGRplane *Kplane));
IGRlong VLextractVSplateSurface __((IGRlong *msg, struct GRid *plate_id, struct GRmd_env *plate_env, IGRchar *side, struct GRid *surface_id, struct GRmd_env *surface_env, struct IGRbsp_surface **sf));
IGRlong VLcreatePlane __((IGRpoint Point, IGRvector Normal, struct GRmd_env *Env, struct GRvg_construct *cst, struct GRid *Plane, IGRlong *msg));
IGRlong VLsortPlateImage __((IGRlong *msg, IGRint nplt, struct GRid *Iplt, struct GRmd_env *Env, struct GRobj_env **Oplt, IGRint *nimg));
IGRlong VLcreateLineSeg __((IGRdouble *spt, IGRdouble *ept, struct GRmd_env *Env, struct GRvg_construct *cst, struct GRid *Line, IGRlong *msg));
IGRlong VLevalUvGridFromSrf __((struct GRobj_env srfObjEnv, IGRint uNumPoints, IGRint vNumPoints, IGRint opt, struct IGRbsp_surface **srfGeom, struct IGRbsp_surface **uvGrid, IGRlong *msg));
IGRlong VLquery1 __((IGRlong *msg, struct GRobj_env *object, struct GRmd_env *Env, GRclassid classid, IGRlong (*geometric )__ ((struct GRobj_env *base_obj, struct GRobj_env *test_obj, struct GRmd_env *loc_env )), IGRint *count, struct GRobj_env *list[]));
IGRint VLsortSeam __((struct VLsortTpl *a, struct VLsortTpl *b));
IGRlong VLsortPlateSeams __((struct GRobj_env *Plate, IGRchar *side, IGRint nseam, struct GRobj_env *Seam[], IGRlong *msg));
IGRlong VLcheckSurfSurf __((struct GRobj_env *Surf1, struct GRobj_env *Surf2, struct GRmd_env *Env, struct GRobj_env *Inter));
IGRlong VLquery2 __((IGRlong *msg, struct GRobj_env *object, struct GRmd_env *Env, GRclassid classid, IGRlong (*geometric )__ ((struct GRobj_env *base_obj, struct GRobj_env *test_obj, struct GRmd_env *loc_env, struct GRobj_env *resp_obj )), IGRchar *side, IGRint *count, struct GRobj_env *list[]));
IGRint VLplaceRootHeader __((IGRmatrix cs_matrix, IGRchar *mac_name, struct GRmd_env *Env, struct GRid *Result, IGRlong *msg));
void VLencode __((IGRint binary[], IGRint number, IGRint *code));
void VLdecode __((IGRint code, IGRint number, IGRint binary[]));
IGRint VLimgKludge __((struct GRid *Obj, struct GRmd_env *Env, struct GRid *Cmp, IGRlong *msg));

/* VLmiscMacro.I */
IGRint VLreturn_foot __((IGRlong *msg, IGRchar *name, struct GRid *objId, struct GRmd_env *objEnv, struct GRid *footId, struct GRmd_env *footEnv));
IGRint VLconstPlaceNameState __((IGRlong *msg, GRclassid classid, IGRint prop, IGRchar rep, IGRchar *MacName, IGRint number, struct GRid *template, struct GRmd_env *Env, IGRboolean ChgState, IGRchar mask, IGRchar state, IGRchar *MatchKey, IGRchar *CobName, OM_E_WRT_FLAG mode, struct GRid *MatchId, IGRchar *CommonName, enum GRdpmode dpmode, OM_S_OBJID CobMyId, struct GRid *occ_id, struct GRsymbology *occ_symb, IGRchar *occ_path));

/* VLnameFunk.I */
void VLoccNaming __((IGRchar *target_dir, IGRchar *mac_name, IGRchar *occ_name, IGRlong *msg));
void VLoccNaming1 __((IGRchar *target_dir, IGRchar *mac_name, IGRchar *occ_name, IGRlong *msg));

/* VLoverFunk.I */
IGRdouble VLatan2 __((IGRdouble sin, IGRdouble cos));

/* VLpathFunk.I */
IGRlong VLgetWorkDirectory __((struct GRmd_env *cenv, IGRchar path[], struct GRid *work));
IGRlong VLchangeTemporaryName __((struct GRmd_env *cenv, struct GRid *obj, IGRchar nam[], IGRlong *msg));
IGRlong VLsetSymb_Name_Disp __((IGRlong *msg, IGRchar *name, IGRchar *matchKey, struct GRid *matchId, struct GRid *tar_geom, enum GRdpmode *dpmode, struct GRmd_env *md_env));

/* VLrlocFunk.I */
int VLrLocate_LCAH __((struct VLqList *LCargs, struct GRlc_info *entry, struct LC_action_args *args, enum GRlocate_action *action));
long VLrLocate __((long *msg, GRrange range, int *count, struct GRobj_env **list, struct GRmd_env *st_env));
long VLrLocRef __((GRrange range, int *count, struct GRobj_env **list, struct GRmd_env *st_env));
long VLxformRange __((double *mat, GRrange inRange, GRrange outRange));
int VLgetStifAtStep __((const struct GRid *curPlt, struct VLlistElmtId *cumulatedList));
long VLgetStifByTree __((struct GRobj_env *plate, int *count, struct GRobj_env **list));
int VLgetMacrosAtStep __((const struct GRid *step, struct VLlistElmtId *cuList));
int VLgetStepInfo __((const struct GRid *step, struct VLlistElmtId *cuList));
int VLprintStep __((const struct GRid *step, struct VLlistElmtId *noUsed));
long VLbrowseFctInTree __((struct GRobj_env *entry, short topProps, struct GRobj_env *limId, short downProps, int (*fct )(), int *count, struct GRobj_env **list));
void VLinterList __((int len1, struct GRobj_env *l1, int len2, struct GRobj_env *l2, int (*fct_test )(), int *count, struct GRobj_env *lint));
int VLtstObjEnv __((struct GRobj_env *atom1, struct GRobj_env *atom2));

/* VLscaleSymb.I */
IGRint VLscalSymb __((IGRmatrix cs_matrix, struct GRid *scalObj, struct GRmd_env *Env, IGRlong *msg));

/* VLtool1Funk.I */
void VLinitCnst __((struct GRvg_construct *usr_cnst));
IGRlong VLcreateInter __((IGRlong *msg, struct GRid *input1, struct GRmd_env *env1, IGRshort trim1, struct GRid *input2, struct GRmd_env *env2, IGRshort trim2, struct GRid *inter, struct GRmd_env *loc_env));
IGRlong VLcreateSurface __((IGRlong *msg, struct GRid in_obj, struct GRmd_env *in_env, struct GRid *out_surf, struct GRmd_env *loc_env, IGRboolean *cr_state, IGRdouble *vector, IGRboolean cs_flag));
IGRlong VLcreatePtInter __((IGRlong *msg, struct GRid *input1, struct GRmd_env *env1, struct GRid *input2, struct GRmd_env *env2, struct GRid *inter, struct GRmd_env *loc_env));
IGRlong VLcreateDblInter __((IGRlong *msg, struct GRid *input1, struct GRmd_env *env1, struct GRid *input2, struct GRmd_env *env2, IGRdouble *dbl, struct GRmd_env *loc_env));
IGRlong VLselectClosestCv __((IGRlong *msg, IGRint nb_cv, struct GRid *list_cv, struct GRmd_env *cv_env, IGRdouble *select_pt, struct GRid *closest));
IGRlong VLcreateAllInter __((IGRlong *msg, struct GRid *input1, struct GRmd_env *env1, IGRshort trim1, struct GRid *input2, struct GRmd_env *env2, IGRshort trim2, IGRint *nb_inter, struct GRid **inter, struct GRmd_env *loc_env));
IGRlong VLlengthAlongCv __((IGRlong *msg, struct GRid *cv, struct GRmd_env *cv_env, struct GRid *pt1, struct GRmd_env *pt1_env, struct GRid *pt2, struct GRmd_env *pt2_env, IGRdouble *length));
IGRlong VLfillText __((IGRlong *msg, IGRchar *txt, IGRint txt_size, IGRint *index, IGRint nb_char, IGRchar *field));
IGRlong VLinterPtAlong __((IGRlong *msg, struct GRid *input1, struct GRmd_env *env1, struct GRid *input2, struct GRmd_env *env2, IGRshort inter_way, struct GRmd_env *out_env, IGRdouble *direct, IGRdouble *dist, IGRdouble *pt_int, IGRdouble *pt_on, IGRdouble *dev));

/* VLtoolsFunk.I */
IGRlong VLcurveOnSfByVec __((struct GRobj_env *BaseSurf, struct GRobj_env *BaseCrv, IGRdouble *normal, struct GRvg_construct *cst, IGRboolean CrvIsProj, IGRboolean WantStat, IGRboolean TrimReq, IGRboolean display, struct GRsymbology *symbology, IGRlong *NumProjCrvs, struct GRid *feet, IGRlong *msg));
long VLreparameter_off_curve __((struct GRobj_env *offcv, IGRint nbEdge, struct EdgeMatch *edgeList, IGRdouble *ofval, IGRdouble *info, struct GRid *CmpLst, struct IGRbsp_curve **edgeCv, struct IGRbsp_curve **CmpCv, struct GRvg_construct *cst, IGRboolean InOut));
IGRlong VLoffset_Cv __((struct GRobj_env *CrvToOf, struct GRvg_construct *cst, IGRboolean InOutSide, IGRdouble *normal, IGRint NumOf, IGRdouble *OfVal, IGRdouble *info, IGRboolean display, struct GRobj_env *OfCrv, IGRint *NumOldCrvs, struct GRid **OldCrvs, IGRlong *suc));
IGRlong VLoffCrv __((struct GRobj_env *CrvToOf, struct GRvg_construct *cst, IGRboolean InOutSide, IGRdouble *normal, IGRint NumOf, IGRdouble *OfVal, IGRdouble *info, IGRboolean display, struct GRobj_env *OfCrv, IGRlong *suc));
IGRlong VLgetChildrenMacro __((struct GRobj_env parentId, IGRchar *childMacName, IGRint *numMacros, struct GRid **macrosId, struct GRid *realParent));

/* ck_store.C */
long VLgetStandSize __((char *table_name, double *tol, int nb_exp, double *list_exp, double *list_st));

/* gf_cirappi.I */
void mypr_bscv __((IGRchar *txt, struct IGRbsp_curve *bsp, IGRlong *rc));
void GFgetStrFromGRid __((IGRlong *msgmsg, struct GRid obj_id, GRclassid type, struct GRmd_env *from_env, struct geomStruct *geomData, IGRdouble *length));
void GFsetLineFromBS __((IGRlong *msg, struct IGRbsp_curve *crv, IGRint fromInd, IGRint toInd, struct geomStruct *geomData, IGRdouble *length));
void GFcir_app_str __((IGRlong *msgmsg, struct IGRbsp_curve *loccrv, struct GRobj_env *locobj, IGRdouble tol, struct geomStruct **newcrv, IGRint *nb_arcs, IGRdouble *err_max, IGRdouble *min_len));
void GFcopyGRid __((IGRlong *msgmsg, struct GRid obj_id, struct GRmd_env *from_env, struct GRvg_construct *cst, struct GRid *COMP, IGRdouble *length));
void GFcreArcLine __((IGRlong *rc, struct geomStruct *geomData, struct GRvg_construct *cst, struct GRid *geomId));
void GFnew_cir_app __((IGRlong *msgmsg, struct IGRbsp_curve *loccrv, struct GRobj_env *locobj, IGRdouble tol, struct GRvg_construct *cst, struct GRid **newcrv, IGRint *nb_arcs, IGRdouble *err_max, IGRdouble *min_len));

#if defined(__cplusplus)
}
#endif

