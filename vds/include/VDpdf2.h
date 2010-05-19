/* $Id: VDpdf2.h,v 1.2 2001/10/19 18:29:47 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDpdf2.h
 *
 * Description:	PDF oriented stuff, C Friendly
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDpdf2.h,v $
 *      Revision 1.2  2001/10/19 18:29:47  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/09/14 13:47:40  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/05/01  ah      Creation
 * 10/18/01  ah      Remove VDdoM stuff
 ***************************************************************************/
#ifndef VDpdf2_include
#define VDpdf2_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ---------------------------------------------
 * Main file information 
 */
#define PDF_OBJ_DT       0x00
#define PDF_OBJ_LEN      0x00
#define PDF_OBJ_BEG_MASK 0x8000
#define PDF_OBJ_END_MASK 0x4000
#include "VDpdfAttrs.h"

/* ---------------------------------------------
 * Main file information 
 */
typedef struct {
  IGRchar  fileName[256];
  FILE    *file;

  // Handy to have global translate
  struct 
  {
    IGRdouble x,y,z;
  } trn;

} TVDpdfFileInfo;

extern IGRstat VDpdfOpenOutputFile  __((TVDpdfFileInfo *pdf, IGRchar *fileName));
extern IGRstat VDpdfCloseOutputFile __((TVDpdfFileInfo *pdf));

extern IGRstat VDpdfWriteInt      __((TVDpdfFileInfo *pdf, IGRlong   val));
extern IGRstat VDpdfWriteReal     __((TVDpdfFileInfo *pdf, IGRdouble val));

extern IGRstat VDpdfWriteAttrReal __((TVDpdfFileInfo *pdf, IGRint recType, IGRdouble val));
extern IGRstat VDpdfWriteAttrInt  __((TVDpdfFileInfo *pdf, IGRint recType, IGRlong   val));
extern IGRstat VDpdfWriteAttrText __((TVDpdfFileInfo *pdf, IGRint recType, IGRchar  *val));

extern IGRstat VDpdfWriteObjBeg   __((TVDpdfFileInfo *pdf, IGRint   recType));
extern IGRstat VDpdfWriteObjEnd   __((TVDpdfFileInfo *pdf, IGRint   recType));
extern IGRstat VDpdfWriteAttrEnd  __((TVDpdfFileInfo *pdf, IGRchar *recDesc));

extern IGRstat VDpdfWriteHdr 
__((TVDpdfFileInfo *pdf,
    IGRint recType, 
    IGRint dataType, 
    IGRint dataLen));

extern IGRstat VDpdfWriteReals __((TVDpdfFileInfo *pdf,
				   IGRint          recType, 
				   IGRint          realCnt, 
				   IGRdouble      *reals));

extern IGRstat VDpdfWrite3dPts __((TVDpdfFileInfo *pdf,
				   IGRint          recType, 
				   IGRint          ptCnt, 
				   IGRdouble      *pts));
extern IGRstat VDpdfWriteCvgCurve __((TVDpdfFileInfo *pdf,
				      IGRint          recType,
				      IGRint          numVertexes,
				      TVDcvgVertex   *vertexes));

extern IGRstat VDpdfWriteCvgCurveParametric __((TVDpdfFileInfo *pdf,
						IGRint          recType,
						TVDcvgCurve    *crv));

extern IGRstat VDpdfWriteCvgLabel __((TVDpdfFileInfo *pdf,
				      IGRint          isAttrFlag,
				      IGRchar        *labelType,
				      TVDcvgText     *text));

extern IGRstat VDpdfVerifyFile __((IGRchar *pdfFileName));


/* -----------------------------------------------
 * Auto generated switch statement
 */
extern int VDpdfGetRecDesc __((int recNum, char *recDesc));

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif

