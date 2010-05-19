/* $Id: EMdprdeactst.I,v 1.1.1.1 2001/01/04 21:07:28 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	emsfixes/model/EMdprdeactst.I
 *
 * Description:
 *		Overwritten to control the UI_status message.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: EMdprdeactst.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:28  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1996/02/07  23:44:50  pinnacle
# Created: ./emsfixes/model/EMdprdeactst.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	02/07/96	adz		creation date
 *
 ***************************************************************************/

class implementation EMSdpr;

#include "emsdef.h"
#include "EMSerrordef.h"
#include "EMSopt.h"
#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/
#include "EMSkey.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

#if DEBUG
#include "stdio.h"
#endif

from EMSsurface import  EMgetstatedesc;

void EFcantrc(EMmsg, node_id, node_os)
IGRlong *EMmsg;
GRobjid node_id;
OMuword node_os;
{
  IGRlong OM_stat=OM_S_SUCCESS;
  IGRchar desc_str[54], print_str[128];

# if DEBUG
   fprintf(stderr, "Node %d can not recompute.\n", node_id);
# endif        

  *EMmsg = EMS_S_Success;
  OM_stat = om$send(msg = message EMSsurface.EMgetstatedesc(EMmsg, desc_str),
                    senderid = NULL_OBJID,
                    targetid = node_id,
                    targetos = node_os);
  if (1 & OM_stat & *EMmsg)
  {
    ex$message(msgnumb = EMS_I_NodeIdAffectsNodeCantRecomp, buff = print_str)
    strcat(print_str, " ( ");
    strcat(print_str, desc_str);
    strcat(print_str, " )");
    UI_status(print_str);
  }
  return;
}
end implementation EMSdpr;

