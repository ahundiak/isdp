/* $Id: VDsupPO.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDsupPO.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsupPO.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/10/28  19:05:38  pinnacle
 * Added Headers
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTIO
 *      10/28/97        ah              added header
 ***************************************************************************/

/* ---------------------------------- 
 * PO support functions, originally in
 * vlPfunk.h
 * use master define to avoid dup copies
 * evenutally remove from loft product
 */

#ifndef __PO_PROTOTYPES__
#define __PO_PROTOTYPES__

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

/* poangv1v2.c */
int POangv1v2 __((IGRdouble *v1, IGRdouble *v2, IGRdouble *vz, IGRdouble *angle, BSrc *rc));

/* poapplaw2val.c */
int POapplaw2val __((IGRint law, IGRdouble strVal, IGRdouble endVal, IGRdouble strInt, IGRdouble endInt, IGRdouble paInt, IGRdouble *valSol, IGRlong *rc));

/* poarepolaln.c */
int POarepolaln __((struct IGRbsp_curve *bsp, IGRdouble tol, IGRlong *rc));

/* pochkarcisln.c */
IGRlong POchkArcIsLn __((struct geomStruct *arcStr, IGRdouble *p1, IGRdouble *p2, struct IGRbsp_curve *cv, IGRdouble tol, IGRdouble *dmax, IGRlong *rc));

/* pochkcirarc.c */
int POchkCirArc __((IGRdouble *pts, IGRdouble *weights, IGRint numPts, IGRdouble relTol, struct IGRarc *arcStr, IGRshort *isArc, IGRlong *rc));

/* pocircnvfit.c */
IGRlong POcircnvfit __((struct IGRbsp_curve *bsp_crv, IGRdouble *A, IGRdouble *VA, IGRdouble *B, IGRdouble *VB, IGRdouble tol, IGRdouble *mat, struct geomStruct *arc1, struct geomStruct *arc2, IGRdouble *ecmax, IGRdouble *umax, IGRdouble *arclen_min, BSrc *rc));

/* pocstarcstr.c */
int POcstarcstr __((IGRdouble *center, IGRdouble *strvec, IGRdouble *endvec, IGRdouble radius, struct IGRarc *arc, IGRdouble *arc_len, IGRlong *rc));

/* pocvev.c */
int POcvev __((IGRshort idim, IGRboolean rational, IGRdouble *poles, IGRint order, IGRdouble u, IGRdouble *sol, BSrc *rc));

/* pocvevgreabs.c */
int POcvevGreAbs __((struct IGRbsp_curve *sourceCv, struct IGRbsp_curve *tempCv, IGRboolean distEvalWanted, IGRint greIndex, IGRint numGreAbs, struct cvGrePa *greAbs, BSrc *rc));

/* pocvevlen.c */
IGRdouble POcvevlen __((struct IGRbsp_curve *cv, IGRdouble ustart, IGRdouble uend, BSrc *rc));

/* pocvevpgbind.c */
int POcvevpgbind __((IGRshort idim, struct IGRbsp_curve *cv, IGRdouble *par, IGRint ikt, IGRdouble *pole, IGRdouble *weight, BSrc *rc));

/* pocvfndcusps.c */
int POcvFndCusps __((struct IGRbsp_curve *cv, IGRdouble tol2, IGRint *numCusps, IGRint **cuspIndex, IGRboolean *arePolesAlign, BSrc *rc));

/* pocvfrmpoles.c */
int POcvFrmPoles __((struct IGRbsp_curve *cv, IGRshort parType, IGRint fromPole, IGRint toPole, struct IGRbsp_curve *cvsol, BSrc *rc));

/* pocvinsgrekt.c */
int POcvInsGreKt __((struct IGRbsp_curve *cv, IGRdouble relativeErr, IGRint maxIt, struct IGRbsp_curve **cvsol, IGRint *itSol, IGRdouble *ratioSol, BSrc *rc));

/* poevpolelen.c */
int POevPoleLen __((struct IGRbsp_curve *cv, IGRboolean totalLenWanted, IGRint startIndex, IGRint numPoles, IGRdouble *poleLen, IGRdouble *totalLen, IGRlong *rc));

/* pofndktind.c */
int POfndKtInd __((IGRint order, IGRdouble *kts, IGRdouble t, IGRint greIndex, IGRint *ktsIndex, BSrc *rc));

/* pofndmaxdist.c */
int POfndMaxDist __((struct cvGrePa *greAbs, IGRint numGreAbs, IGRint *indexMax, BSrc *rc));

/* pofndonefib.c */
int POfndOneFib __((struct IGRbsp_curve *cv1, struct IGRbsp_curve *cv2, struct IGRbsp_curve *midCv, IGRdouble *norCvs, IGRdouble par1, IGRdouble par2, IGRdouble *parSol, IGRdouble *ptsSol, IGRdouble *intPts, IGRdouble *u, IGRdouble *a, IGRdouble *b, IGRlong *rc));
int POcheckPaOrd __((IGRdouble *u, IGRdouble *pts, IGRdouble *us1, IGRdouble *us2, IGRdouble *p1, IGRdouble *p2));

/* polmu.c */
int POlmu __((IGRint order, IGRdouble par, IGRdouble *bern, BSrc *rc));

/* popolarnif.c */
int POpolarnif __((IGRint order, IGRdouble *knots, IGRint ikt, IGRdouble *par, IGRdouble *b, BSrc *rc));

/* porac2.c */
int POrac2 __((IGRdouble a, IGRdouble b, IGRdouble c, IGRint flag, IGRdouble *root, IGRlong *rc));

/* pospancv.c */
int POspancv __((struct IGRbsp_curve *bsp_curve, IGRint i_span, IGRint num_mkt, IGRdouble *tmul, IGRint *index, struct IGRbsp_curve *bsp_span, BSrc *rc));

#if defined(__cplusplus)
}
#endif

#endif

