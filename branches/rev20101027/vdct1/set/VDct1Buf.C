/* $Id: VDct1Buf.C,v 1.2 2001/03/12 20:36:37 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/set/VDct1Buf.I
 *
 * Description: Paste Buffer Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Buf.C,v $
 *      Revision 1.2  2001/03/12 20:36:37  jdsauby
 *      Cleaned out unnecessary functions from vdct1/set
 *
 *      Revision 1.1  2001/01/12 14:53:34  art
 *      sp merge
 *
 * Revision 1.1  2000/07/25  18:38:22  pinnacle
 * ah
 *
# Revision 1.1  2000/04/20  18:41:56  pinnacle
# Created: vds/vdct1/set/VDct1Buf.I by pnoel for Service Pack
#
# Revision 1.2  2000/01/11  22:26:02  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/30/99  ah      Creation
 ***************************************************************************/

#include "VDct1.h"
#include "VDdir.h"
#include "VDppl1.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/set/VDct1Buf.C");
#if 0
/* ------------------------------------------------------
 * Builds path to paste buffer object 
 */
IGRstat VDct1GetPasteBufferPath(VDosnum osnum, IGRchar *path)
{
  IGRstat retFlag = 0;

  // Get the os path
  di$give_pathname(osnum = osnum, pathname = path);
  if (*path == 0) goto wrapup;
  
  // Add the explicit path
  if (osnum != VDtraOS) DIstrcat(path,"IGENOD");    
  DIstrcat(path,"VDct1PasteBuffer");
  
  // Done
  retFlag = 1;
  
wrapup:
  return 1;
}
#endif

#if 0
/* -------------------------------------------
 * Create a new paste buffer
 *
 */
IGRstat VDct1CreatePasteBuffer(VDosnum osnum, TGRid *objID)
{
  VDASSERT_FN("VDct1CreatePasteBuffer");
  
  IGRstat retFlag = 0;

  IGRchar path[DI_PATH_MAX];
	
  // Enter
  traceFlag = VDdbgGetTraceFlag(41);
  if (traceFlag) printf(">>> VDct1CreateBuf\n");

  // Arg Check
  if (objID == NULL) goto wrapup;
  objID->objid = NULL_OBJID;

  // Create object
  vdct$CreateBaseObject(osnum     = osnum,
	                classType = VDCT1_CLASS_TYPE_MGR,
		        objID     = objID);
		
  if (objID->objid == NULL_OBJID) {
    printf("Problem Creating VDct1Base paste buffer object\n");
    goto wrapup;
  }

  if (objID->objid == NULL_OBJID) goto wrapup;

  // Standard path name
  *path = 0;

  VDct1GetPasteBufferPath(objID->osnum, path);
  if (*path == 0) goto wrapup;

  di$rm_name (regexp  = path, osnum = objID->osnum);
  di$add_name(objname = path, osnum = objID->osnum, objid = objID->objid);

  retFlag = 1;

wrapup:
  if (retFlag != 1) {
    UI_status("Problem Creating Paste Buffer Object\n");
    objID->objid = NULL_OBJID;
  }
   
  return retFlag;
}
#endif

#if 0
/* -------------------------------------------------
 * Get the manager if it exists
 */
IGRstat VDct1GetPasteBuffer(VDosnum osnum, IGRint createFlag, TGRid *objID)
{
  IGRstat retFlag = 0;
  IGRchar path[DI_PATH_MAX];
    
  // Init
  if (objID == NULL) goto wrapup;
  objID->objid = NULL_OBJID;
  
  // Set desired os to search
  if (osnum == OM_K_NOT_AN_OS) objID->osnum = VDtraOS;
  else objID->osnum = osnum;
  
  *path = 0;
  VDct1GetPasteBufferPath(objID->osnum, path);
  if (*path == 0) goto wrapup;

  di$translate(
    objname =  path,
    p_objid = &objID->objid
  );
  if (objID->objid != NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }
  
  // See if want to create
  if (createFlag == 0) goto wrapup;
    
  retFlag = VDct1CreatePasteBuffer(objID->osnum,objID);
  
wrapup:
  return retFlag;
}

#endif
