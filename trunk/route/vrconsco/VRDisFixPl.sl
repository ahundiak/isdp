/* $Id: VRDisFixPl.sl,v 1.4 2002/04/02 17:22:19 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrconsco/VRDisFixPl.sl
 *
 * Description:
 *    This command display fixed plane.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRDisFixPl.sl,v $
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
# Revision 1.4  1996/03/04  20:56:12  pinnacle
# Replaced: vrconsco/VRDisFixPl.sl for:  by hverstee for route240
#
# Revision 1.3  1996/02/23  05:45:06  pinnacle
# Replaced: vrconsco/VRDisFixPl.sl for:  by ashankar for route240
#
# Revision 1.2  1995/12/08  21:20:52  pinnacle
# Replaced: vrconsco/VRDisFixPl.sl for:  by r240_int for route240
#
 *
 * History:
 *    	25-04-1991			changed
 *	12/06/95	tlb		Remove VRcmd.h
 *	May 22 '01	Anand		Added call to VRinfo_DisplayPlanes
 *					(that displays all locked planes in the
 *					design file) in VRDisplayPlanes (wakeup
 *					state)
 *************************************************************************/

command_string       VRC_M_DspFixPln,0,VRDsLcPl
/* Service pack complained about message keys in product other than Route
command_string       "Display Locked Plane",0,VRDsLcPl
 */
class                VRDisFixPl
super_class          VDB_LOCATE
product_name         "$ROUTE_PATH"
command_table	     "route.cmd"

specification

instance
{
  IGRint			NumOfLocatedObjects;
  struct	  GRid		*LocatedObjects;
}


implementation


#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "AS_status.h"

#define	AS_DEBUG
#define VR_N_Fix_Pl_Found	0x01
#define VR_N_Pl_Selected	0x02

extern GRclassid  OPP_VRplane_class_id;

from	VRplane		import	VRget_plane_state;
from	GRgraphics	import	GRdisplay;

/**********************************************************/

state_table

#include "VRmsg.h"

#define VR_N_Fix_Pl_Found	0x01
#define VR_N_Pl_Selected	0x02

state start

   message_key          VR_M_DspFixPln
   prompt_key		VR_P_IdPln
   dynamics		off
   locate_class		"VRplane"
   relocate_key		VR_E_NoObjLoc
   filter		locate

   on EX_BACK_UP or EX_RJT_MOVEON				state .

   on EX_DATA or EX_OBJID  		do VRGetPlanes              
                           		do VRDisplayPlanes
      on RETURN_CODE = "VR_N_Fix_Pl_Found"			state MESS
      on RETURN_CODE = "VR_N_Pl_Selected" 			state MESS1
								state .

state MESS
	status_key		VR_S_No_FixPlFnd
		on ELSE 		do remove_located_object
								state start

state MESS1
	status_key		VR_S_InvalidInput
		on ELSE						state start

   at init 	do init_cmd
   at wakeup    do VRDisplayPlanes
   at delete	do remove_located_object


/**********************************************************/

action init_cmd
{
  *sts = MSSUCC;

  me->NumOfLocatedObjects = 0;
  me->LocatedObjects      = NULL;
}

/**********************************************************/

action remove_located_object {

	if( me->NumOfLocatedObjects  ) {
		ASend_fence() ;

		me->NumOfLocatedObjects = 0 ;
		me->LocatedObjects	= NULL ;
	}

	/* Below call to remove highlighting in delete - put in by Anand */
	dp$erase_hilite ( msg = sts );

} /* remove_located_object */


/**********************************************************/

action VRGetPlanes
{

  *sts = MSSUCC;

  /* Remove last components located. */
  status =
  om$send( msg      = message VRDisFixPl.remove_located_object( sts ),
  	   targetid = my_id ) ;

  /*"Located object = %d\n", me->event1.located_object[0].located_obj */

  ASstart_fence
  ( me->event1.located_object[0].located_obj, me->ModuleInfo.md_id.osnum,
    &me->NumOfLocatedObjects, &me->LocatedObjects, me->response,
    me->response_data
  );

  if( ! me->NumOfLocatedObjects ) me->ret = MSFAIL;

  /*^
   {IGRint i;
      for( i=0; i<me->NumOfLocatedObjects; i++ )
      {
        printf("LocatedObjects[%d] = %d\n", i, me->LocatedObjects[i].objid );
      }
   }
  */

}


/**********************************************************/

action VRDisplayPlanes
{
  IGRint 			i, PlaneState;
  IGRlong			msg;
  IGRboolean			PlaneFound = FALSE;
  enum 		GRdpmode 	mode;
  IGRint			PlaneSelected=FALSE;
  GRclassid			obj_class;
  extern int	VRinfo_DisplayPlanes(struct GRmd_env *);

  status = VRinfo_DisplayPlanes(&me->ModuleInfo);

  for( i=0; i<me->NumOfLocatedObjects; i++ )
  {
	status = om$get_classid(objid = me->LocatedObjects[i].objid,
				osnum = me->LocatedObjects[i].osnum,
				p_classid = &obj_class);
	as$status();

	if( om$is_ancestry_valid
		(subclassid = obj_class,
		superclassid = OPP_VRplane_class_id ) != OM_S_SUCCESS )
	    continue;

	PlaneSelected = TRUE;

	om$send( msg      = message VRplane.VRget_plane_state
                                                               ( &PlaneState ),
                      targetid = me->LocatedObjects[i].objid,
                      targetos = me->LocatedObjects[i].osnum );
	as$status( action = RET_STATUS );

	/*"Plane = %d Stateis %d\n", me->LocatedObjects[i].objid, PlaneState */
    
	if( PlaneState )
	{
		PlaneFound = TRUE;
		
		/* 02-Jun-93 : karine : Replace NDdisplay by a */
		/* GRdisplay as the Module Info seems to have some */
		/* matrix problem whence selecting elts in view */ 

		mode = GRhd;
		status = om$send( msg      = message GRgraphics.GRdisplay
			       ( &msg, &me->ModuleInfo.md_env.matrix_type,
				 me->ModuleInfo.md_env.matrix, &mode, 
				 &me->ModuleInfo.md_id ),
		    targetid = me->LocatedObjects[i].objid, 
		    targetos = me->LocatedObjects[i].osnum );
  		as$status();
	}
  }

  if( ! PlaneSelected ) 
  {
	*sts = VR_N_Pl_Selected;
	return OM_S_SUCCESS;
  }

  if( ! PlaneFound ) *sts = VR_N_Fix_Pl_Found;
}
 
