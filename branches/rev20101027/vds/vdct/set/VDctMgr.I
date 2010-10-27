/* $Id: VDctMgr.I,v 1.1.1.1 2001/01/04 21:08:01 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/set/VDctMgr.I
 *
 * Description: Manager Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDctMgr.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:01  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/05/30  14:27:54  pinnacle
# ct
#
# Revision 1.1  1999/05/28  19:08:46  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 ***************************************************************************/
class implementation VDctBase;

#include "VDct.h"
#include "VDdir.h"
#include "VDppl1.h"

extern VDclassid OPP_VDctBase_class_id;

static int traceFlag;

/* ------------------------------------------------------
 * Builds path to manager object 
 */
IGRstat VDctGetMgrPath(VDosnum osnum, IGRchar *mgrPath)
{
  *mgrPath = 0;

  di$give_pathname(osnum = osnum, pathname = mgrPath);
  if (*mgrPath == 0) return 0;

  DIstrcat(mgrPath,"IGENOD");    
  DIstrcat(mgrPath,"VDctMgr");
  
  return 1;
}

/* -------------------------------------------
 * Creates a new manager object
 */
IGRstat VDctCreateManager(VDosnum osnum, TGRid *mgrID)
{
  IGRstat retFlag = 0;

  IGRchar mgrPath[DI_PATH_MAX];
	
  // Enter
  traceFlag = VDdbgGetTraceFlag(41);
  if (traceFlag) printf(">>> VDctCreateManager\n");

  // Create object
  UI_status("Creating SetManager...");

  // Null if fail
  if (mgrID == NULL) goto wrapup;
  mgrID->objid = NULL_OBJID;

  // Create object
  vdct$CreateBaseObject(osnum     = osnum,
	                classType = VDCT_CLASS_TYPE_MGR,
		        objID     = mgrID);
		
  if (mgrID->objid == NULL_OBJID) {
    printf("Problem Creating VDctBase object\n");
    goto wrapup;
  }

  if (mgrID->objid == NULL_OBJID) goto wrapup;

  // Standard path name
  *mgrPath = 0;

  VDctGetMgrPath(mgrID->osnum, mgrPath);
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

  if (traceFlag) printf("<<< VDctCreateManager\n");
   
  return retFlag;
}

/* -------------------------------------------------
 * Get the manager if it exists
 */
IGRstat VDctGetManager(VDosnum osnum, TGRid *objID)
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
  VDctGetMgrPath(objID->osnum, mgrPath);
  if (*mgrPath == 0) {
    printf("Could not build manager name while getting manager\n");
    goto wrapup;
  }
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

/* -----------------------------------------------
 * Manager test routine
 */
IGRstat VDctMgrTest()
{
  IGRstat retFlag = 0;
  
  TGRid  mgrID;
//TGRid  setID;

  // Say Hi
  traceFlag = 1;
  printf(">>> VDctMgrTest\n");

  vdct$CreateManager(mgrID  = &mgrID);
  vdct$GetManager   (mgrID = &mgrID);
  
  retFlag = 1;
  return retFlag;
}

end implementation VDctBase;

















