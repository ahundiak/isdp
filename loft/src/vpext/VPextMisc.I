/* $Id: VPextMisc.I,v 1.1.1.1 2001/01/04 21:11:58 cvs Exp $  */

/***************************************************************************
 * I/EFP
 *
 * File:        vpext/VPextSetup.I
 *
 * Description: Extract Setup Information
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VPextMisc.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:11:58  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/05/24  18:39:42  pinnacle
# ah
#
# Revision 1.2  1998/11/14  14:09:48  pinnacle
# ah
#
# Revision 1.1  1998/06/14  16:13:26  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/12/98  ah      Creation
 *
 ***************************************************************************/

class implementation VDbtBase;

#include "VDtypedef.h"
#include "VDfrm.h"
#include "VDobj.h"
#include "VDsa.h"

#include "VDatMaster.h"

#include "VPextCmd.h"
#include "VPpdf.h"

 
/* --------------------------------------------------------
 * Extract Setup
 */
IGRstar VPextCMD_ExtractSetup(TVPextCMD_Info *info)
{
  IGRstat retFlag = 0;
  
  IGRint  pplRet;
    
  // Make sure set was picked
  if (info->setID.objid == NULL_OBJID) goto wrapup;
  
  // Start the main object
  VPpdfWriteObjBeg (PDF_OBJ_SETUP);

  // PPL does the actual extraction
  VDahPPL_SetValue(&info->pplID,"OBJECT_ID",sizeof(TGRid),(IGRchar*)&info->setID);
  VDahPPL_Run(&info->pplID,"extractSetup",&pplRet);
    
  // Clean up
  VPpdfWriteObjEnd(PDF_OBJ_SETUP);
  
  retFlag = 1;

wrapup:

  return retFlag;
}

/* --------------------------------------------------------
 * Extract Ship
 */
IGRstar VPextCMD_ExtractShip(TVPextCMD_Info *info)
{
  IGRstat retFlag = 0;
  
  IGRint  pplRet;
    
  // Make sure set was picked
  if (info->setID.objid == NULL_OBJID) goto wrapup;
  
  // Start the main object
  VPpdfWriteObjBeg (PDF_OBJ_SHIP);

  // PPL does the actual extraction
  VDahPPL_SetValue(&info->pplID,"OBJECT_ID",sizeof(TGRid),(IGRchar*)&info->setID);
  VDahPPL_Run(&info->pplID,"extractShip",&pplRet);
    
  // Clean up
  VPpdfWriteObjEnd(PDF_OBJ_SHIP);
  
  retFlag = 1;

wrapup:

  return retFlag;
}

end implementation VDbtBase;




