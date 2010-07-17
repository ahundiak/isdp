/* $Id: VRPocketInit.C,v 1.1.1.1 2001/01/04 21:12:57 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinit / VRPocketInit.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRPocketInit.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:57  cvs
 *	Initial import to CVS
 *	
 * Revision 1.2  2000/03/10  23:00:18  pinnacle
 * Replaced: vrinit/VRPocketInit.C for:  by apazhani for route
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/07/17  18:30:54  pinnacle
 * route 2.5
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.2  1996/01/17  16:34:10  pinnacle
 * Replaced: vrinit/VRPocketInit.C for:  by r240_int for route240
 *
 *
 * History:
 *	Date			Author		Decription
 *	03/10/2000		Alwin		Added one more icon for Select Cable.CR179800048
 *
 *************************************************************************/
#include "OMerrordef.h"
#include <stdio.h>
#include "FI.h"
#include "FIdyn.h"
#include "msdef.h"

#include "vdpktdef.h"
#include "vdpktmacros.h"

/*----------------------------------------------------------------------------*/
int VRAddToPocketMenu()
/*.VRAddToPocketMenu*/
{
static struct VDpktGadgets VRlist[] = {

 { FI_CMD_STRING, "Select Components Along Network", "VRpkt.sym", 71 },
 { FI_CMD_STRING, "Put Ref On Queue", "VRpkt.sym", 70 },
 { FI_CMD_STRING, "Select Cables", "VRpkt.sym", 72 }, //added for CR179800048
 { VDPKT_ENDLIST, 0, 0, 0 } };

int	sts = MSSUCC;

  /*
   * Add gadgets to default pocket menu.
   */
  sts = vd$pkt_add_gadgets( gadgets = VRlist );

  sts = vd$pkt_menu( );

  return sts;

} /* end VRAddToPocketMenu */
/*----------------------------------------------------------------------------*/
int VRDelToPocketMenu()
/*.VRDelToPocketMenu*/
{
static struct VDpktGadgets VRlist[] = {

 { FI_CMD_STRING, "Select Components Along Network", "VRpkt.sym", 71 },
 { VDPKT_ENDLIST, 0, 0, 0 } };

int	sts = MSSUCC;

  /*
   * Delete gadgets to default pocket menu.
   */
  sts = vd$pkt_del_gadgets( gadgets = VRlist );

  sts = vd$pkt_menu( );

  return sts;

} /* end VRDelToPocketMenu */
/*----------------------------------------------------------------------------*/
