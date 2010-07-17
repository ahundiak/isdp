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

/* VLrmover.I */
void VDSmvTwoPolesOnCv __((struct IGRbsp_curve *crv, IGRint begPol, IGRint endPol, IGRint firstPolInd, IGRdouble polTol, IGRlong *msg));
void VDSmvThreePolesOnCv __((struct IGRbsp_curve *crv, IGRint begPol, IGRint endPol, IGRint firstPolInd, IGRdouble polTol, IGRlong *msg));
void VDSmvFourPolesOnCv __((struct IGRbsp_curve *crv, IGRint begPol, IGRint endPol, IGRint firstPolInd, IGRdouble polTol, IGRlong *msg));
void VDSmvPolesOnCv __((struct IGRbsp_curve *crv, IGRint begPol, IGRint endPol, IGRint firstPolInd, IGRint numCoincident, IGRdouble polTol, IGRlong *msg));
void VDSmvCoincidentPolesOnCv __((struct IGRbsp_curve *crv, IGRdouble knotTol, IGRdouble polTol, IGRboolean *curveIsModifyed, IGRlong *msg));
void VDSremoveOverlaps __((struct IGRbsp_curve *crv, IGRint firstPoleInd, IGRint numPolesToModify, IGRint *poleIndexToModify, IGRlong *msg));
IGRboolean VDSfindOverlapsOnSpan __((IGRdouble *poles, IGRshort deg, IGRdouble tol, IGRint *numPolesToModify, IGRint *polesIndexToModify, IGRlong *msg));
void VDSfindOverlapsOnCv __((struct IGRbsp_curve *crv, IGRboolean modifNeeded, IGRdouble zeroTol, IGRdouble chtTol, IGRboolean *curveHasOverlaps, IGRlong *msg));
void VDScleanupCv __((struct IGRbsp_curve *crv, IGRboolean modifNeeded, IGRboolean *curveHasOverlaps, IGRlong *msg));

#if defined(__cplusplus)
}
#endif

