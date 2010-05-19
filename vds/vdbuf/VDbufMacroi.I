/* $Id: VDbufMacroi.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbuf/VDbufMacro.I
 *
 * Description: Macro Buffer Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbufMacroi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  2000/03/24  15:38:56  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/17/00  ah      Creation
 ***************************************************************************/

class implementation VDbufMacro;

#include "VDtypedef.h"
#include "VDobj.h"

/* ------------------------------------------------------------
 * Allow for prettier status messages
 */
method GRgetobjinfo(IGRlong *msg;
		    struct GRobj_info *info)
{
  IGRstat retFlag = 0;
  
  TGRid   myID;
  IGRchar macName[64];
  
  // Get my macro name
  myID.objid = my_id;
  myID.osnum = OM_Gw_current_OS;
  vdobj$Get(objID = &myID, macName = macName);
  
  // sprintf(info->type,"Macro %s",macName);

  // Just pass it up
  retFlag = om$send(msg = message nci_macro.
		    GRgetobjinfo(msg,info),
		    mode = OM_e_wrt_message,
		    targetid = myID.objid,
		    targetos = myID.osnum);

  // *msg = MSSUCC;
  
  // return OM_S_SUCCESS;
  return retFlag;
  
}

end implementation VDbufMacro;









