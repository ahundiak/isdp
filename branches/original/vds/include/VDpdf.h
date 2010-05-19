/* $Id: VDpdf.h,v 1.4 2001/10/19 18:29:47 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDpdf.h
 *
 * Description:	PDF oriented stuff
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDpdf.h,v $
 *      Revision 1.4  2001/10/19 18:29:47  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/06/07 19:03:42  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/10 16:01:54  art
 *      sp merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  2000/08/05  16:26:40  pinnacle
 * ah
 *
 * Revision 1.1  2000/02/18  16:01:30  pinnacle
 * sms
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/13/00  ah      Creation
 * 08/01/00  ah      Add DOM Interface
 * 01/10/01  ah      sp merge
 * 10/18/01  ah      Remove VDdoM stuff, File is probably obsolete
 ***************************************************************************/
#ifndef VDpdf_include
#define VDpdf_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#ifndef   VDxml_include
#include "VDxml.h"
#endif

#ifndef   VDcvg_include
#include "VDcvg.h"
#endif

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

extern IGRstar VDpdfWriteHdr 
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

