/* $Id: VRFixFreePl.sl,v 1.4 2002/04/02 17:22:19 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrconsco/VRFixFreePl.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRFixFreePl.sl,v $
 *	Revision 1.4  2002/04/02 17:22:19  anand
 *	SP -> Pload changes.
 *	
 *	Revision 1.3  2001/05/29 15:21:04  anand
 *	Service pack complained of message keys for products besides Route at
 *	product startup. Replaced message keys for this file with the
 *	hard-coded Command name taken from $ROUTE/config/english/messages/src
 *	
 *	Revision 1.2  2001/05/23 00:34:49  anand
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:47  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/03/04  20:55:48  pinnacle
# Replaced: vrconsco/VRFixFreePl.sl for:  by hverstee for route240
#
# Revision 1.3  1996/01/17  00:24:34  pinnacle
# Replaced: vrconsco/VRFixFreePl.sl for:  by r240_int for route240
#
# Revision 1.2  1995/12/08  21:21:06  pinnacle
# Replaced: vrconsco/VRFixFreePl.sl for:  by r240_int for route240
#
 *
 * History:
 *	12/06/95	tlb		Remove VRcmd.h
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *	May 22 '01	Anand	Added wakeup and delete states (parent class).
 *
 *************************************************************************/

command_string       VRC_M_FixPln,0,VRLcPl
/* Service pack complained about message keys in product other than Route
command_string       "Lock Plane",0,VRLcPl
 */

class                VRFixFreePl
super_class          VDB_LOCATE
super_class          VRDisFixPl
product_name         "$ROUTE_PATH"
command_table	     "route.cmd"

specification

implementation

#include "AS_status.h"

%safe
#include "VX_FIproto.h"
%endsafe


#define	AS_DEBUG
#define	VR_FIXED_PLANE 1


from	VRplane	import	VRchg_plane_state;

/**********************************************************/

state_table

#include "VRmsg.h"

state start

   message_key          VR_M_FixPln
   prompt_key		VR_P_IdPlnToFix
   dynamics		off
   locate_class		"VRplane"
   accept_key		VR_P_AccReject
   relocate_key		VR_E_NoObjLoc
   filter		locate

   on EX_BACK_UP or EX_RJT_MOVEON				state .

   on EX_DATA or EX_OBJID  		do VRGetPlanes              
                           		do VRFixPlanes		state .

at wakeup	do VRDisplayPlanes
at delete	do remove_located_object

/**********************************************************/

action VRFixPlanes
{
  IGRint i;

  for( i=0; i<me->NumOfLocatedObjects; i++ )
  {
    status = om$send( msg      = message VRplane.VRchg_plane_state
                                                          ( VR_FIXED_PLANE, 1 ),
                      targetid = me->LocatedObjects[i].objid,
                      targetos = me->LocatedObjects[i].osnum );
    as$status( action = RET_STATUS );
  }
}
  
