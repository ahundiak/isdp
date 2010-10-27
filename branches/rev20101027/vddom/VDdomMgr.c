/* $Id: VDdomMgr.c,v 1.2 2001/03/11 18:35:11 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdxml/VDdomMgr.c
 *
 * Description: Dom Tree Manager
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDdomMgr.c,v $
 *      Revision 1.2  2001/03/11 18:35:11  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/14 16:35:25  art
 *      sp merge
 *
 * Revision 1.1  2000/12/06  15:01:08  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/14/00  ah      Creation
 * 01/13/01  ah      sp17 merge
 * 03/11/01  ah      Use vdGbl data
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDgbl.h"
#include "VDdom.h"

#include "VDassert.h"

VDASSERT_FFN("vds/vddom/VDdomMgr.c");

/* -----------------------------------------------
 * Get the manager, creating if required
 */
void VDdomGetMgr(VDosnum osnum, IGRint flag, TGRid *a_mgrID)
{
  VDASSERT_FN("VDdomGetMgr");

  TGRid parentID;
  TGRid *mgrID;

  TVDdomStaticData *s = vdGblStaticData01;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(a_mgrID); a_mgrID->objid = NULL_OBJID;
  VDASSERTW(s);
  mgrID = &s->mgrID;
  
  // Return it
  if (mgrID->objid != NULL_OBJID) {
    *a_mgrID = *mgrID;
    goto wrapup;
  }
  
  // See if should create
  if (flag == 0) goto wrapup;
  
  // Setup fake parent
  if (osnum == NULL_OSNUM) VDdomGetActiveOsnum(&parentID.osnum);
  else parentID.osnum = osnum;  
  parentID.objid = NULL_OBJID;
  
  // Create it
  VDdomCreateObj(&parentID,"dom_mgr",mgrID);
  VDASSERTW(mgrID->objid != NULL_OBJID);
  
  // Change it to a set
  VDdomSetObjClassType(mgrID,VDDOM_CLASS_TYPE_MGR);
  
  // Done
  *a_mgrID = *mgrID;
  
 wrapup:

  // Say Bi
  if (traceFlag) printf("<<< %s\n",fn);

  return;
}
