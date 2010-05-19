/* $Id: VDbufPointi.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbuf/VDbufPointi.I
 *
 * Description: Point Buffer Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbufPointi.I,v $
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

class implementation VDbufPoint;

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
  
  // Get my macro name
  myID.objid = my_id;
  myID.osnum = OM_Gw_current_OS;

  // Just pass it up
  retFlag = om$send(msg = message GR3dpoint.
		    GRgetobjinfo(msg,info),
		    mode = OM_e_wrt_message,
		    targetid = myID.objid,
		    targetos = myID.osnum);

  return retFlag;
  
}

end implementation VDbufPoint;









