/* $Id: VLsms.h,v 1.2 2001/01/16 18:11:58 ramarao Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        include/VLsms.h
 *
 * Description:	Struct Manufacturing Solutions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLsms.h,v $
 *      Revision 1.2  2001/01/16 18:11:58  ramarao
 *      *** empty log message ***
 *
 * Revision 1.3  2000/11/27  20:22:12  pinnacle
 * ah
 *
 * Revision 1.2  2000/05/26  17:51:16  pinnacle
 * ah
 *
 * Revision 1.1  2000/04/25  16:26:24  pinnacle
 * ah
 *
 * Revision 1.1  2000/02/25  17:34:00  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/10/99  ah      Creation
 ***************************************************************************/
#ifndef VLsms_include
#define VLsms_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#ifndef   VDxml_include
#include "VDxml.h"
#endif

#ifndef   VDcvg_include
#include "VDcvg.h"
#endif

#ifndef   VLsmsXml_include
#include "VLsmsXml.h"
#endif

#ifndef   VLunwMisc_include
#include "VLunwMisc.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ---------------------------------------------------
 * The ppl used to customize the extraction process
 */
#define SMS_PPL_EXTRACT "VLsmsExt"

/* ----------------------------------------------------
 * Main file information structure
 */

#define VLSMS_MAX_BEVEL 64

typedef struct 
{
  TVDcvgFileInfo cvg;

  IGRpoint  r1,r2;   // 2D Range
  IGRdouble scale;
  
  IGRint    presentOffset;

  IGRint                numBevels;
  TVLunwUnwrapBevelInfo bevels[VLSMS_MAX_BEVEL];
  
} TVLsmsFileInfo;

/* -----------------------------------------------
 * File routines 
*/
extern IGRstat VLsmsOpenOutputFile  __((TVLsmsFileInfo *info, IGRchar *fileName));
extern IGRstat VLsmsCloseOutputFile __((TVLsmsFileInfo *info, IGRint   flag));

/* -----------------------------------------------
 * Unwrap routines 
*/
extern IGRstat VLsmsWriteUnwrap  __((TVLsmsFileInfo *info, TGRobj_env *unwrapOE));
  
/* -----------------------------------------------
 * Bevel Routines
 */
extern IGRstat VLsmsWriteUnwrapBevels __((TVLsmsFileInfo *file,TGRobj_env *unwrapOE));

/* ----------------------------------------------------
 * Low level extract routines
 */
extern IGRstat VLsmsExtGenFileName __((TGRid   *setID, 
				       IGRchar *fileHull,
				       IGRchar *fileWhat,
				       IGRchar *timeStamp,
				       IGRchar *spadesFileName));

extern IGRstat VLsmsExtExtractShip __((TVDxmlFileInfo *xml,
				       IGRchar        *hull));

extern IGRstat VLsmsExtExtractSetup __((TVDxmlFileInfo *xml,
					IGRchar        *timeStamp,
					IGRchar        *spadesFileName,
					IGRchar        *fileStatus,
					IGRint          preTranslate));

extern IGRstat VLsmsExtExtractTreeNode __((TVDxmlFileInfo *xml,
					   TGRid          *nodeID));

/* -------------------------------------------------------
 * VLsmsLog.I 
 */
extern IGRstat VLsmsLog1 __((IGRint type, IGRint stdOut, IGRchar *fmt, ...));
extern IGRstat VLsmsLog2 __((IGRint type, IGRint stdOut, IGRchar *pre, 
			     TGRobj_env *objOE, TGRid *objID));

extern IGRstat VLsmsCloseLogFiles __(());
extern IGRstat VLsmsInitLogFiles  __(());
extern IGRstat VLsmsSetLogFile    __((IGRint nth, FILE *file));
extern FILE   *VLsmsGetLogFile    __((IGRint nth));

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif








