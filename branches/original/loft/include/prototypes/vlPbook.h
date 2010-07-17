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

/* VLbookFunk.I */
IGRlong VLcreateDirectory __((struct GRid *check, IGRchar usr[], IGRchar name[]));
IGRlong VLgenerateDirectories __((struct GRmd_env *Env, IGRchar usr[]));
IGRlong VLgetRealBookData __((IGRchar *path, struct GRmd_env *Env, struct GRobj_env *Real));
IGRboolean VLcheckInDirectory __((struct GRid *Elem, struct GRmd_env *Env, IGRchar *path, IGRchar *name));
IGRchar *VLindexToChapterName __((IGRint idx));
IGRchar *VLindexToDirName __((IGRint idx));
IGRlong VLgetElemInDirectory __((IGRint idx, IGRchar usr[], struct GRmd_env *Env, IGRint *num, IGRchar **mac, IGRchar **nam));
void VLputElemInMultiField __((IGRint idx, IGRchar *usr, struct GRmd_env *Env, IGRchar *form_ptr, IGRint label));
void VLrenameInDir __((IGRint idx, IGRchar usr[]));
void VLdelElemInMultiField __((IGRint idx, IGRchar usr[], struct GRmd_env *Env, IGRchar *form_ptr, IGRint label));
void VLdisplayReal __((IGRint idx, IGRchar usr[], struct GRmd_env *Env, IGRchar *form_ptr, IGRint label, enum GRdpmode dpmode));
void VLverifyInDir __((IGRint chapter, IGRchar usr[], IGRlong *msg));
void VLgetLoftBookHeader __((VLlbHead *Header));
IGRint VLgetElemPlane __((IGRchar usr[], IGRchar nam[], IGRint idx, struct GRmd_env *Env, struct IGRplane *plane, IGRlong *msg));
IGRint VLgetElemGeom __((IGRchar usr[], IGRchar nam[], IGRint idx, struct GRmd_env *Env, IGRchar **elem, IGRlong *msg));
IGRint VLgetLoftBookData __((IGRchar usr[], struct GRmd_env *Env, VLlbData *data, IGRlong *msg));
IGRint VLintCrvPln __((struct IGRbsp_curve *Crv, struct IGRplane *Pln, IGRint *numSol, IGRpoint *ptSol, IGRlong *msg));
IGRint VLintPlPlSf __((struct IGRbsp_curve *Crv, struct IGRplane *Pln, struct IGRplane *Frm, struct IGRbsp_surface *Srf, IGRint *numSol, IGRpoint *ptSol, IGRlong *msg));
void VLextractFormat __((IGRchar Iformat[], IGRint max, IGRint Oindex[], VStktxt Oformat[]));
IGRint VLsortCrossing __((VLlbCross a[], VLlbCross b[]));
void VLfillCrossAttr __((struct ACrg_coll attr[]));
void VLelimInChtTol __((IGRint *number, VLlbCross *cross, IGRint name));
IGRint VLdecodeAxis __((const VSdrwArgLst *argl));
IGRint VLgiveSMposition __((struct GRid *Plane, IGRdouble *value, IGRlong *msg));
void VLgetElemInMultiField __((IGRint idx, IGRchar usr[], struct GRmd_env *Env, IGRchar *form_ptr, IGRint label, struct GRid *Elem, IGRchar Path[], IGRlong *msg));
void VLputqueueElemInMultiField __((IGRint idx, IGRchar usr[], struct GRmd_env *Env, IGRchar *form_ptr, IGRint label));
void VLdeleteAllMultiField __((IGRint idx, IGRchar usr[], struct GRmd_env *Env));
IGRint VLcreateDispStations __((IGRint idx, IGRchar usr[], struct GRmd_env *Env, IGRint type, IGRchar *form_ptr));
void VLnearestDispStation __((VLlbData Dat[], IGRchar nam[], IGRdouble *dst));

#if defined(__cplusplus)
}
#endif

