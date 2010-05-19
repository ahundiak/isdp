/* $Id: VDct1Mgr.C,v 1.2 2001/03/12 20:36:45 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/set/VDct1Mgr.I
 *
 * Description: Manager Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Mgr.C,v $
 *      Revision 1.2  2001/03/12 20:36:45  jdsauby
 *      Cleaned out unnecessary functions from vdct1/set
 *
 *      Revision 1.1  2001/01/12 14:53:35  art
 *      sp merge
 *
 * Revision 1.1  2000/07/25  18:38:22  pinnacle
 * ah
 *
# Revision 1.2  2000/05/23  18:34:38  pinnacle
# Replaced: vds/vdct1/set/VDct1Mgr.I for:  by pnoel for Service Pack
#
# Revision 1.1  2000/04/20  18:42:58  pinnacle
# Created: vds/vdct1/set/VDct1Mgr.I by pnoel for Service Pack
#
# Revision 1.3  2000/01/11  22:26:02  pinnacle
# ah
#
# Revision 1.1  1999/06/29  18:28:52  pinnacle
# ct
#

 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 * 12/16/99  pn      Update Prototypes in VDct1.h
 ***************************************************************************/

#include "VDct1.h"
#include "VDdir.h"
#include "VDppl1.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/set/VDct1Mgr.C");

/* ------------------------------------------------------
 * Builds path to manager object 
 * Needs to be tweaked for transient space
 */
IGRstat VDct1GetMgrPath(VDosnum osnum, IGRchar *mgrPath)
{
  IGRstat retFlag = 0;

  // Get the path
  di$give_pathname(osnum = osnum, pathname = mgrPath);
  if (*mgrPath == 0) return 0;
  
  // Add the explicit path
  DIstrcat(mgrPath,"IGENOD");    
  DIstrcat(mgrPath,"VDct1Mgr");

  // printf("mgrPath %s\n",mgrPath);
  
  // Done
  retFlag = 1;
  
//wrapup:
  return 1;
}

/* -------------------------------------------
 * Creates a new manager object
 *
 * For now, create VDctBase object and not VDct1Base
 */
IGRstat VDct1CreateManager(VDosnum osnum, TGRid *mgrID)
{
  VDASSERT_FN("VDct1CreateManager");
  IGRstat retFlag = 0;

  IGRchar mgrPath[DI_PATH_MAX];
	
  // Enter
  if (traceFlag) {
    printf(">>> VDct1CreateManager\n");
  }
  
  // Create object
  UI_status("Creating SetManager...");

  // Null if fail
  if (mgrID == NULL) goto wrapup;
  mgrID->objid = NULL_OBJID;

  // Create object
  vdct$CreateBaseObject(osnum     = osnum,
	                classType = VDCT1_CLASS_TYPE_MGR,
		        objID     = mgrID);
		
  if (mgrID->objid == NULL_OBJID) {
    printf("Problem Creating VDct1Base mgr object\n");
    goto wrapup;
  }

  if (mgrID->objid == NULL_OBJID) goto wrapup;

  // Standard path name
  *mgrPath = 0;

  VDct1GetMgrPath(mgrID->osnum, mgrPath);
  if (*mgrPath == 0) goto wrapup;

  di$rm_name (regexp  = mgrPath, osnum = mgrID->osnum);
  di$add_name(objname = mgrPath, osnum = mgrID->osnum, objid = mgrID->objid);

  retFlag = 1;

wrapup:
  if (retFlag != 1) {
    UI_status("Problem Creating Manager Object\n");
    mgrID->objid = NULL_OBJID;
  }
  else UI_status("Created Manager");

  if (traceFlag) printf("<<< VDct1CreateManager\n");
   
  return retFlag;
}

/* -------------------------------------------------
 * Get the manager if it exists
 */
IGRstat VDct1GetManager(VDosnum osnum, TGRid *objID)
{
  IGRstat retFlag = 0;
  IGRchar mgrPath[DI_PATH_MAX];
    
  // Init
  if (objID == NULL) goto wrapup;
  objID->objid = NULL_OBJID;
  
  // Set desired os to search
  if (osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &objID->osnum);
  else objID->osnum = osnum;
  
  *mgrPath = 0;
  VDct1GetMgrPath(objID->osnum, mgrPath);
  if (*mgrPath == 0) goto wrapup;

  di$translate(
    objname = mgrPath,
    p_objid = &objID->objid
  );
  if (objID->objid == NULL_OBJID) 
    goto wrapup;
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
#if 0
/* -----------------------------------------------
 * Manager test routine
 */
IGRstat VDctMgrTest()
{
  IGRstat retFlag = 0;
  
  TGRid  mgrID;
//TGRid  setID;

  // Say Hi
  traceFlag = 0;
  printf(">>> VDctMgrTest\n");

  vdct$CreateManager(mgrID  = &mgrID);
  vdct$GetManager   (mgrID = &mgrID);
  
  retFlag = 1;
  return retFlag;
}
#endif

