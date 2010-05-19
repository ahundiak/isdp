/* $Id: VDmac.I,v 1.3 2001/01/11 16:34:31 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDmac.I
 *
 * Description:	Macro Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDmac.I,v $
 *      Revision 1.3  2001/01/11 16:34:31  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:58  art
 *      s merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/01/27  17:52:44  pinnacle
# spades
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/04/23  23:11:06  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/23/98  ah      Creation
 *
 ***************************************************************************/
class implementation ACncpx;

#include "VDtypedef.h"

#include "VDobj.h"
#include "VDchn.h"
#include "VDmac.h"

from ACcpx_defn import ACgive_feet_desc;
from ACcpx_defn import ACgive_name;

/* ------------------------------------------------------------------------
 * Get routine
 */
extern IGRstar VDmacGet
(TGRobj_env *a_objOE,
 TGRid      *a_objID,
    
 IGRchar    *a_footName,

 IGRchar    *a_defName,
 TGRid      *a_defID,

 TGRid      *a_footID
 )
{
  IGRstat retFlag = 0;
  
  TGRid objID;
  TGRid defID;
  TGRid footID;
  
  IGRchar *defName = NULL;
  
  IGRint     i;

  IGRint         feetNum = 0;
  struct myfeet *feetDesc = NULL;
  
  // Init
  if (a_defName)  *a_defName = 0;
  if (a_defID)     a_defID->objid  = NULL_OBJID;
  if (a_footID)    a_footID->objid = NULL_OBJID;
    
  // Arg Check
  objID.objid = NULL_OBJID;
  
  if (a_objOE)  objID  =  a_objOE->obj_id;
  if (a_objID)  objID  = *a_objID;

  if (objID.objid == NULL_OBJID) goto wrapup;
  
  // Get the defination
  defID.objid = NULL_OBJID;
  
  om$send(msg = message ACcpx.find_macro(&defID),
	  senderid = NULL_OBJID,
	  targetid = objID.objid,
	  targetos = objID.osnum);
  if (defID.objid == NULL_OBJID) goto wrapup;

  if (a_defID) *a_defID = defID;
  
  // Want name ?
  if (a_defName) {
    om$send(msg = message ACcpx_defn.ACgive_name(&defName),
      senderid = NULL_OBJID,
      targetid = defID.objid,
      targetos = defID.osnum);
    
    if (defName != NULL) {
      if (a_defName) strcpy(a_defName,defName);
      retFlag = 1;
      
    }
  }
  
  // Search foot by name
  if ((a_footID != NULL) && (a_footName != NULL)) {
    
    om$send(msg = message ACcpx_defn.ACgive_feet_desc(&feetNum,&feetDesc),
	    senderid = NULL_OBJID,
	    targetid = defID.objid,
	    targetos = defID.osnum);

#if 0
    for(i = 0; i < feetNum; i++) {
      printf("Foot %2d %s\n",i,feetDesc[i].name);
    }
#endif

    for(i = 0; (i < feetNum) && (strcmp(a_footName,feetDesc[i].name)); i++);

    if (i < feetNum) {

      footID.objid = NULL_OBJID;
      
      vdchn$Get(il_objID  = &objID,
		ic_IDX    = VDCHN_IDX_TO_COMPONENTS,
		ir_objIDX = i,
		or_objID  = &footID);

      if (footID.objid != NULL_OBJID) {
	*a_footID = footID;
	retFlag = 1;
      }
    }
  }
  
wrapup:

  return retFlag;
}

end implementation ACncpx;




