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

/* VLstfTplCmdi.I */

/* VLstfnrFunk.I */
IGRint VLgetVSbeamFace __((struct GRobj_env *Beam, IGRchar *Name, IGRshort props, struct GRobj_env *Face, IGRlong *msg));
IGRint VLgetCommonEdge __((struct GRobj_env *Beam, IGRchar *Wname, IGRchar *Fname, struct GRobj_env *Wface, struct GRobj_env *Fface, struct GRmd_env *Env, struct GRid *Cedge, IGRlong *msg));
IGRint VLtopStfTpl __((struct GRobj_env *Face, struct GRid *Bedge, IGRdouble Height, IGRdouble Wside, struct GRmd_env *Env, struct GRid *Tedge, IGRlong *msg));
IGRint VLcontourStfTpl __((struct GRid *Bedge, struct GRid *Tedge, struct GRmd_env *Env, IGRdouble dTol, IGRdouble bTol, struct GRid *Contour, IGRlong *msg));
IGRint VLorderedEndpts __((struct GRid *Master, struct GRid *Slave, struct GRmd_env *Env, IGRpoint Extrem[], IGRlong *msg));
IGRint VLtextStfTpl __((struct GRid *Bedge, struct GRid *Tedge, IGRpoint Extrem[], IGRpoint Vertex[], IGRchar TagNam[], IGRint nvtx, struct GRmd_env *Env, VLquLine Qline[], struct GRobj_env Qlist[], IGRdouble Xinv, struct GRid Text[], struct GRid Line[], IGRlong *msg));
IGRint VLmarkStfTpl __((IGRpoint Point, IGRchar *Tname, IGRpoint Track, struct GRid *Tedge, struct GRmd_env *Env, struct GRobj_env *Ortho, IGRdouble Weight, IGRdouble Xinv, struct GRid *Text, struct GRid *Line, IGRlong *msg));
IGRint VLsortVertex __((VLstfTpl *a, VLstfTpl *b));
IGRint VLqueryStfTpl __((struct GRobj_env *Surf, struct GRobj_env *Stf, VLquLine Qline[], IGRdouble Extd, struct GRmd_env *Env, IGRint *nlin, struct GRobj_env **Line, IGRint *nmac, struct GRobj_env **Macr, IGRlong *msg));
void VLelimVertex __((IGRint cnt, VLstfTpl Vtx[], IGRint *num));
IGRint VLvertexStfTpl __((IGRint nlst, struct GRobj_env List[], IGRint nmac, struct GRobj_env Macr[], struct GRobj_env *Line, IGRdouble Dist, IGRpoint spt, IGRpoint ept, VLquLine Qline[], struct ACrg_coll **attr, IGRint *nvtx, IGRpoint **Vtx, IGRchar **Tag, IGRlong *msg));
IGRint VLcreateAttrStfTpl __((IGRint nline, IGRint nmacr, struct ACrg_coll **attr, IGRlong *msg));
void VLqLineStfTpl __((VLquLine Qline[]));
IGRint VLaskMacroNames __((struct GRobj_env *object, VLquLine Qline[], IGRchar occName[], IGRchar defName[], IGRchar datName[], IGRlong *msg));
IGRint VLgetLineNames __((struct GRobj_env *object, VLquLine Qline[], IGRchar occName[], IGRchar tagName[], IGRlong *msg));
IGRint VLgetMacroNames __((struct GRobj_env *object, IGRchar occName[], IGRchar tagName[], IGRlong *msg));

/* VLstfnrSymb.I */
void VLstfnrAxisOrient __((IGRpoint Spt, IGRpoint Ept, IGRint *axis, IGRint *orien));
IGRint VLdirectionStfTpl __((struct GRid *Bcrv, struct GRid *Tcrv, struct GRmd_env *Env, IGRpoint Spt, IGRpoint Ept, IGRint nlin, struct GRid *Line, struct GRid *Arrow, struct GRid *Symbol, IGRlong *msg));

#if defined(__cplusplus)
}
#endif

