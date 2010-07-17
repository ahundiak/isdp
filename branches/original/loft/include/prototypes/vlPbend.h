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

/* VLbendFunk.I */
IGRdouble VLf __((struct IGRbsp_curve *cv, IGRdouble par, IGRdouble *n, IGRlong *msg));
IGRdouble VLfPrim __((struct IGRbsp_curve *cv, IGRdouble CvPa, IGRdouble *n, IGRdouble cht, IGRlong *ret));
IGRlong VLresol __((struct IGRbsp_curve *Cv, IGRdouble *PaCv, IGRdouble *n, IGRdouble precision, IGRdouble cht));
IGRlong VLresolAlg1 __((struct IGRbsp_curve *Cv1, struct IGRbsp_curve *ExCv1, struct IGRbsp_curve *Cv2, struct IGRbsp_curve *ExCv2, struct BendingLineInfo *BendingLine, IGRdouble prec, IGRdouble cht, IGRlong *msg));
IGRlong VLfindBendLine __((struct GRobj_env *SurfObj, struct GRvg_construct *cst, IGRboolean direction, IGRint *nb_bend_line, IGRvector shipsAxis, struct BendingLineInfo *BendingLine, struct GRobj_env *bendObj, IGRlong *msg));
IGRlong VLfindBendLineAlg1 __((struct GRobj_env *SurfObj, struct GRvg_construct *cst, IGRboolean direction, struct BendingLineInfo *BendingLine, IGRlong *msg));
IGRlong VLfindBendLineAlg2 __((struct GRobj_env *SurfObj, struct GRvg_construct *cst, IGRdouble *shipAxis, struct BendingLineInfo *bendingLine, struct GRobj_env *BendLineObj, IGRlong *msg));
IGRlong VLsimpleControLine __((struct GRobj_env *SurfObj, struct GRvg_construct *cst, IGRdouble *ShipAxis, struct BendingLineInfo *controlLine, struct GRobj_env *ControlObj, IGRlong *msg));
IGRlong VLdrawBendLine __((struct GRobj_env *SrfObj, struct BendingLineInfo *bendingLine, struct GRobj_env *BendCrv, struct GRvg_construct *cst, struct GRsymbology *symbology, struct GRid *BendObj, IGRint *NumBendObj, IGRlong *msg));
IGRlong VLcnstOneFib __((struct IGRbsp_curve *isoCrv, struct IGRbsp_curve *CvSol, IGRdouble *norRef, IGRdouble *org, IGRdouble *xAxis, IGRdouble *yAxis, IGRdouble yOffset, IGRdouble *paPtSol, IGRint nPtSol, struct GRvg_construct *cst, IGRboolean displayWanted, IGRdouble *point, IGRdouble *xAbs, struct GRid *CrvObj, IGRlong *msg));

/* VLinvMethod.I */
int VLfind_longer_stiff __((struct GRobj_env *stiff, IGRint nb, IGRdouble *len));

/* VLstfBenFunk.I */
IGRlong VLcreStifText __((struct GRobj_env *Stfnr, IGRdouble *Mat, IGRdouble Len, IGRdouble Wid, char *web_ratio, struct GRid *Txt, IGRlong *msg));
IGRlong VLcreStifBend __((struct GRobj_env *Stfnr, struct GRobj_env *Bsurf, struct GRvg_construct *cst, IGRdouble *Mat, char *web, IGRint *nout, struct GRid Out[], IGRlong *msg));

#if defined(__cplusplus)
}
#endif

