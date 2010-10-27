/* $Id: VDct1Defn.I,v 1.4 2001/03/12 20:36:43 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/set/VDct1Defn.I
 *
 * Description: Generic Macro Defination
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Defn.I,v $
 *      Revision 1.4  2001/03/12 20:36:43  jdsauby
 *      Cleaned out unnecessary functions from vdct1/set
 *
 *      Revision 1.3  2001/01/12 14:53:35  art
 *      sp merge
 *
# Revision 1.1  2000/07/25  18:39:02  pinnacle
# ah
#
# Revision 1.1  2000/04/20  18:42:46  pinnacle
# Created: vds/vdct1/set/VDct1Defn.I by pnoel for Service Pack
#
# Revision 1.2  2000/01/11  22:26:02  pinnacle
# ah
#
# Revision 1.1  1999/06/29  18:28:52  pinnacle
# ct
#

 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 * 12/16/99  pn      Update Prototypes in spx/include/VDct1.h
 ***************************************************************************/
class implementation Root;

#include "VDct1.h"
#include "VDdir.h"
#include "VDppl1.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/set/VDct1Defn.I");

/* ------------------------------------------------------
 * Builds path to manager object 
 */
IGRstat VDct1GetDefnPath(VDosnum osnum, IGRchar *defnPath)
{
  *defnPath = 0;

  di$give_pathname(osnum = osnum, pathname = defnPath);
  if (*defnPath == 0) return 0;

  DIstrcat(defnPath,"IGENOD");    
  DIstrcat(defnPath,"VDct1Defn");
  
  return 1;
}
extern VDclassid VDct1Defn_class_id;

from VDct1Defn import VDctDefnSetName;

/* -------------------------------------------
 * Creates a new defination object
 *
 */
IGRstat VDct1CreateDefn(VDosnum osnum, TGRid *defnID)
{
  VDASSERT_FN("VDct1CreateDefn");
  
  IGRstat retFlag = 0;

  IGRchar defnPath[DI_PATH_MAX];
	
  // Enter
  if (traceFlag) printf(">>> VDct1Createdefn\n");

  // Null if fail
  if (defnID == NULL) goto wrapup;
  defnID->objid = NULL_OBJID;

  if(osnum == OM_K_NOT_AN_OS) ex$get_cur_mod (osnum = &defnID->osnum);
  else                        defnID->osnum = osnum;

  // Create object
  om$construct(classid =  OPP_VDct1Defn_class_id,
	       osnum   =  defnID->osnum,
	       p_objid = &defnID->objid);
  
  if (defnID->objid == NULL_OBJID) {
    printf("Problem Creating VDct1Defn object\n");
    goto wrapup;
  }

  // Standard Name For Now
  om$send(msg = message VDct1Defn.VDctDefnSetName("VDct1Base"),
          senderid = NULL_OBJID,
          targetid = defnID->objid,
          targetos = defnID->osnum);

  // Standard path name
  *defnPath = 0;

  VDct1GetDefnPath(defnID->osnum, defnPath);
  if (*defnPath == 0) goto wrapup;

  di$rm_name (regexp  = defnPath, osnum = defnID->osnum);
  di$add_name(objname = defnPath, osnum = defnID->osnum, objid = defnID->objid);

  retFlag = 1;

wrapup:

  if (traceFlag) printf("<<< VDct1CreateDefn\n");
   
  return retFlag;
}

/* -------------------------------------------------
 * Get the macro defination, create one of required
 */
IGRstat VDct1GetDefn(VDosnum osnum, TGRid *objID)
{
  IGRstat retFlag = 0;
  IGRchar defnPath[DI_PATH_MAX];
    
  // Init
  if (objID == NULL) goto wrapup;
  objID->objid = NULL_OBJID;
  
  // Set desired os to search
  if (osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &objID->osnum);
  else objID->osnum = osnum;
  
  *defnPath = 0;
  VDct1GetDefnPath(objID->osnum, defnPath);
  if (*defnPath == 0) {
    printf("Could not build macro def name while getting defn\n");
    goto wrapup;
  }
  di$translate(
    objname = defnPath,
    p_objid = &objID->objid
  );
  if (objID->objid != NULL_OBJID) {
    retFlag = 1; 
    goto wrapup;
  }

  // Create it
  VDct1CreateDefn(objID->osnum,objID);
  if (objID->objid != NULL_OBJID) {
    retFlag = 1; 
    goto wrapup;
  }

  // Give up
  printf("Problem getting the VDct1Defn object\n");

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
  traceFlag = 1;
  printf(">>> VDctMgrTest\n");

  vdct$CreateManager(mgrID  = &mgrID);
  vdct$GetManager   (mgrID = &mgrID);
  
  retFlag = 1;
  return retFlag;
}
#endif

end implementation Root;



