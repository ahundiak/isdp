/* $Id: vdrepsrf.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $ */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/prototypes/vdrepsrf.h
 *
 * Description:    Include file for functions defined in vds/vdloft/cmd.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdrepsrf.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1998/01/29  20:14:48  pinnacle
 * TR_179702387: converted file from Loft to VDS
 *
 *
 * History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *  01/23/98  ejm     TR:179702387, converted file from Loft to VDS
 ***************************************************************************/

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

/* VDrmover.I */
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

