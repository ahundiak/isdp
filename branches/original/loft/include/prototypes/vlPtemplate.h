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

/* VLchtTplCmdi.I */

/* VLheiTplCmdi.I */

/* VLmacroFunk.I */
IGRlong VLtplObj_ret_attr __((struct GRid *lst, VLpltTplArg *arg, IGRlong *msg));
IGRlong VLtplObj_set_attr __((struct GRid *lst, VLpltTplArg *arg, IGRlong *msg));
IGRlong VLconstCntrLine __((IGRlong *msg, IGRint num, struct GRobj_env *plt, IGRdouble *Axis, IGRchar *side, IGRdouble *norm, struct GRmd_env *Env, struct GRid *Kline));
IGRlong VLbuildCntrLine __((IGRlong *msg, IGRint num, struct GRobj_env *plt, IGRdouble *Axis, IGRint type, IGRchar *side, IGRdouble *norm, struct GRmd_env *Env, struct GRid *LK1, struct GRid *LK2));
IGRlong VLsortPortVSplates __((IGRint nplt, struct GRobj_env *plt, IGRchar *side, struct GRmd_env *Env, IGRint *nprt, struct GRobj_env **prt, IGRint *nstb, struct GRobj_env **stb, IGRlong *msg));
IGRlong VLextractSpineTplInfo __((IGRlong *msg, struct GRid *Spine, IGRpoint Spt1, IGRpoint Spt2, IGRchar *Name));
int VLdirectionOrientation __((IGRvector dir, IGRchar *txt));
IGRlong VLextractTemplateCht __((IGRlong *msg, struct GRid *Template, IGRpoint Spt1, IGRpoint Spt2, IGRchar *Title, IGRdouble *Rhei, IGRdouble *Rcht, IGRdouble *Angle, IGRchar *LeanDir, IGRdouble *Shei, IGRdouble *Scht));
IGRlong VLextractTplFromMgr __((IGRlong *msg, struct GRid *Manager, IGRint *Fidx, IGRint *Lidx, struct GRid *Spine));

/* VLmodTplCmdi.I */

/* VLprjTplCmdi.I */

/* VLsnachFunk.I */
IGRlong VLcreateAchContour __((IGRlong *msg, struct GRid *Curve, struct GRid *Kline, struct GRid *Hole, struct GRmd_env *Env, IGRdouble *Tpln, struct GRvg_construct *cst, IGRdouble *Mat, IGRdouble DistTol, IGRdouble BaseTol, IGRdouble Length, IGRdouble Radius, IGRdouble Width));

/* VLspineFunk.I */
IGRlong VLgetPolyline __((IGRlong *msg, struct GRid *Line, struct GRmd_env *Env, struct IGRpolyline *Poly));
IGRlong VLtplSpiMarkText __((IGRlong *msg, struct GRid *Line, struct GRid *Name, struct GRmd_env *Env, struct GRvg_construct *Cst, IGRdouble Size, struct GRid *Cont, struct GRid *Mark, struct GRid *Text));

/* VLtemplFunk.I */
IGRint VLsortName __((struct VLsortTpl *a, struct VLsortTpl *b));
IGRint VLsortRang __((struct VLsortTpl *a, struct VLsortTpl *b));
void VLsort3dTemplates __((struct VLsortTpl *array, IGRint number));
IGRboolean VLpltPlaInterference __((struct GRid *Plate, struct GRid *Plane, struct GRmd_env *Env, IGRlong *msg));
IGRboolean VLverifyIntersect __((struct GRobj_env *plate, struct GRobj_env *plane, struct GRmd_env *Env, IGRlong *msg));
IGRlong VLcreateName __((IGRlong *msg, IGRint nplate, struct GRid Iplate[], struct GRid Iplane[], struct GRmd_env *Env, IGRchar code[], IGRchar name[]));
IGRlong VLextendCurve __((IGRlong *msg, struct GRid *Curve, struct GRmd_env *Env, IGRdouble d, IGRdouble b, IGRdouble ext1, IGRdouble ext2, struct GRid *Pt1, struct GRid *Pt2));
IGRlong VLcomputePlanes __((IGRdouble *Bplane, struct GRid *plane_id, IGRdouble grd_dist, struct GRmd_env *Env, IGRdouble *Pplane, IGRdouble *Tplane, IGRlong *msg));
IGRlong VLcreateContour __((IGRlong *msg, struct GRid *Curve, struct GRmd_env *Env, IGRdouble *Tplane, struct GRvg_construct *cst, IGRdouble DistTol, IGRdouble BaseTol, IGRdouble Spt[], IGRdouble Ept[]));
IGRboolean VLcounterClockwise __((IGRint npt, IGRdouble pts[], IGRlong *msg));
IGRlong VLcontrolDist __((struct GRobj_env Plate[], IGRint Nplate, IGRint Cnorm, IGRint Inorm, IGRchar *side, IGRdouble *Odist, IGRlong *msg));
IGRboolean VLcolinear __((IGRint npt, IGRdouble pts[], IGRvector base));
IGRlong VLverifyExtremity __((struct GRobj_env *plate, struct GRobj_env *ref_plane, struct GRmd_env *Env, IGRint *ncap, IGRdouble u[], IGRdouble v[], IGRlong *msg));
IGRlong VLextremityPlane __((struct IGRbsp_surface **sf, IGRdouble u, IGRdouble v, IGRdouble norm[], struct GRmd_env *Env, struct GRvg_construct *cst, struct GRid *plane_id, IGRdouble track[], IGRchar idx[], IGRlong *msg));
IGRchar *VLmainOrientation __((IGRvector dir));
IGRlong VLcreateSline __((struct GRid *Contour, IGRdouble Tplane[], struct GRid *Cline, struct GRid *Frame, IGRdouble *Normal, struct GRmd_env *Env, IGRdouble *Axis, IGRdouble Middle, IGRdouble Size, struct IGRbsp_surface *Sf, struct GRid *Sline, IGRdouble *Angle, IGRchar *LeanDir, IGRlong *msg));
IGRlong VLcreateTplText __((IGRchar title[], IGRdouble angle, IGRdouble Rpt1[], IGRdouble Rpt2[], IGRdouble Tsize, IGRint inv_norm, IGRint tpl_state, struct GRid *Sline, struct GRid *Amark, struct GRid *Line1, struct GRid *Line2, struct GRid *Wpt1_id, struct GRid *Wpt2_id, struct GRmd_env *Env, struct GRvg_construct *Cst, struct GRid text_id[], IGRdouble loc_mat[], IGRlong *msg));
IGRlong VLdrawFrame __((struct GRobj_env *Ref, struct GRvg_construct *Cst, IGRdouble H, IGRdouble W, IGRint P, struct GRid *Frm, IGRlong *msg));
IGRlong VLupdateXyRange __((struct GRid *Mac, struct GRmd_env *Md_Env, IGRdouble H, IGRdouble W, IGRint *Page, IGRdouble *Wmax, IGRdouble *Xrg, IGRdouble *Yrg, IGRlong *msg));
IGRlong VLretrieveIsoOrEdg __((IGRlong *msg, struct GRobj_env *Sf, IGRdouble *Track, IGRboolean trim, IGRdouble u, IGRdouble v, struct GRmd_env *Env, struct GRvg_construct *Cst, IGRboolean *Iso, struct GRid *Line));
IGRlong VLgetRollLineTrace __((IGRlong *msg, struct GRobj_env *VLrolLine, IGRchar *footname, struct IGRplane *Splane, IGRpoint *Trace));
IGRlong VLgetRollLineTraces __((IGRlong *msg, struct GRobj_env *VLrolLine, struct GRid *plane_id, struct GRmd_env *Env, IGRint *count, IGRpoint **traces));
IGRlong VLsetRollLineTraces __((IGRlong *msg, IGRpoint trace, IGRdouble Tsize, IGRdouble loc_mat[], struct GRmd_env *Env, struct GRvg_construct *Cst, struct GRid *markID, struct GRid *textID));

/* VLtpl2dCmdi.I */

#if defined(__cplusplus)
}
#endif

