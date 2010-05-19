/* $Id: VEsms.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VExmlSms.h
 *
 * Description:	Struct Manufacturing Solutions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VEsms.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  2000/03/24  15:44:46  pinnacle
 * ah
 *
 * Revision 1.1  2000/02/25  17:34:00  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/13/00  ah      Creation
 ***************************************************************************/
#ifndef VEsms_include
#define VEsms_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#ifndef   VDxml_include
#include "VDxml.h"
#endif

#ifndef   VDcvg_include
#include "VDcvg.h"
#endif

#ifndef   VEsmsXml_include
#include "VEsmsXml.h"
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
#define VE_SMS_PPL_EXTRACT "VEsmsExt"

/* --------------------------------------------------
 * Main output structure
 */
typedef struct 
{
  IGRchar unitReal[32];
  IGRchar unitTest[32];

  TVDcvgFileInfo  cvg;
  TVDxmlFileInfo *xml;
  
  TGRid setID;
  TGRid nodeID;
  
  TGRid pplID;
  
  IGRchar what[32];  // Flag showing what is being extracted
  IGRchar hull[32];  // The hull number
  
} TVEsmsOutputInfo;

/* ---------------------------------------------
 * pdf setup object
 */
typedef struct 
{
  IGRchar internal_units[64];
  IGRchar date      [64];
  IGRchar pdf_name [256];  
  IGRchar file_name[256];  
  IGRchar pdm_cat   [64];  
  IGRchar pdm_part  [64];  
  IGRchar pdm_rev   [64];  
  IGRchar pdm_status[64];
  IGRint  flag;
} TVEpdfSetup;

extern IGRstat VEpdfSetupLoad __((IGRchar *xmlFileName, TVEpdfSetup *info));

typedef struct 
{
  IGRchar name [64];
  IGRchar owner[64];
  IGRchar hull [64];
  IGRchar hull_app[64];
  IGRchar dimensions[64];
  IGRchar global_coord_system[64];
  IGRchar fwd_perpendicular[64];
  IGRint  flag;
} TVEpdfShip;

extern IGRstat VEpdfShipLoad __((IGRchar *xmlFileName, TVEpdfShip *info));

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif





