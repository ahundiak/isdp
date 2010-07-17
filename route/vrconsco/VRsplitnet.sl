/* $Id: VRsplitnet.sl,v 1.4 2002/04/02 17:22:19 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrconsco/VRsplitnet.sl
 *
 * Description:
 *	"Split Network" command.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRsplitnet.sl,v $
 *	Revision 1.4  2002/04/02 17:22:19  anand
 *	SP -> Pload changes.
 *	
 *	Revision 1.3  2001/05/29 15:21:04  anand
 *	Service pack complained of message keys for products besides Route at
 *	product startup. Replaced message keys for this file with the
 *	hard-coded Command name taken from $ROUTE/config/english/messages/src
 *	
 *	Revision 1.2  2001/05/23 00:34:50  anand
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
# Revision 1.7  1996/05/08  19:57:40  pinnacle
# Replaced: vrconsco/VRsplitnet.sl for:  by ashankar for route240
#
# Revision 1.5  1996/04/03  22:23:10  pinnacle
# Replaced: vrconsco/VRsplitnet.sl for:  by ashankar for route240
#
# Revision 1.4  1996/03/04  20:55:00  pinnacle
# Replaced: vrconsco/VRsplitnet.sl for:  by hverstee for route240
#
# Revision 1.3  1996/01/16  21:54:40  pinnacle
# Replaced: vrconsco/VRsplitnet.sl for:  by r240_int for route240
#
# Revision 1.2  1995/12/08  21:21:24  pinnacle
# Replaced: vrconsco/VRsplitnet.sl for:  by r240_int for route240
#
 *
 * History:
 *	12/06/95	tlb	Remove VRcmd.h
 *	01/15/96	tlb	Add prototypes
 *
 *************************************************************************/

command_string	     VRC_M_SpNt,0,VRSpNt
/* Service pack complained about message keys in product other than Route
command_string	     "Split Network",0,VRSpNt
 */
class		     VRsplitnet
super_class	     VDB_LOCATE
product_name	     "$ROUTE_PATH"
command_table	     "route.cmd"

specification

#include "igrtypedef.h"
#include "growner.h"

instance {
	struct GRobj_env	component ;	/* Component where network    */
						/* is splitting.	      */
	IGRpoint		split_point ;	/* Split point. 	      */
	IGRshort		component_type ;/* Component type.	      */
}

implementation

#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "VRcompdef.h"
#include "VRdimdef.h"
#include "VRcordef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "dpmacros.h"
#include "VRcordef.h"
#include "AS_status.h"
#include "VRmsg.h"
#include "EMSmsgdef.h"
#include "OMprimitives.h"
#include "asbox.h"
#include "alloca.h"
#include "vrtools_pto.h"

#define AS_DEBUG

#define _objid			obj_id.objid
#define _osnum			obj_id.osnum

#define VR_NOZZ			0x0001
#define VR_REF_FILE		0x0010

#define VR_K_IsACorrection	0x01
#define VR_K_FitToFit		0x03
#define VR_K_ACT_SUCCESS	0x02

from	NDnode		import	NDget_objects;
from 	VRGeneric	import 	VRGetStatus,
				VRGetSupports,
				VRGetCorrections,
			       	VRSetStatus ;
from 	VRCnrlSeg	import 	VRnotify_disconnect;
from 	VRCorrection	import 	VRget_state;
from 	GRgraphics 	import 	GRdelete ;

state_table

#include "VRmsg.h"
#include "grmessage.h"

#define VR_K_IsACorrection	0x01
#define VR_K_FitToFit		0x03
#define VR_K_ACT_SUCCESS	0x02

state start
	message 		"Split Network"
	prompt_key		VR_P_IdComp
	locate_class		"+VRGeneric"
	accept_key		VR_P_AccReject
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER "

	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate

		on EX_DATA 	do store_component( &me->ret )
					on RETURN_CODE = "VR_K_FitToFit"
					state .
					on RETURN_CODE = "VR_K_IsACorrection"
					state get_split_point
				do split_network( &me->ret )
					on RETURN_CODE != "VR_K_ACT_SUCCESS"
					state haveError
					state .


state get_split_point
	prompt			"Give Split Point"
	filter			get_event

		on EX_BACK_UP					state -

		on EX_DATA	do store_point( &me->ret )
					on RETURN_CODE != "VR_K_ACT_SUCCESS"
					do status_key VR_E_BadPoint
					state .
				do split_network( &me->ret )
					on RETURN_CODE != "VR_K_ACT_SUCCESS"
					state haveError
					state -


state haveError
	status_key		GR_E_ErrEncCmdRst
		on ELSE 					state start

/*----------------------------------------------------------------------------*/
action store_component( IGRlong *msg ) {

	IGRshort	i, type ;
	IGRint		state;

	me->component.obj_id  = me->event1.located_object[0].located_obj ;
	me->component.mod_env = me->event1.located_object[0].module_info ;

	/*"Component located : [%d,%d]\n", me->component._osnum, me->component._objid */

	dp$erase_hilite( msg = msg );
	/*
	 * See if the component is a correction.
	 */
	status = om$send( msg	   = message VRGeneric.VRGetStatus( msg,
								    &type ),
			  targetid = me->component._objid,
			  targetos = me->component._osnum ) ;

	as$status( action = RET_STATUS ) ;
	as$status( action = RET_STATUS, sts = *msg ) ;

	if( type & VR_CORRECTION )
        {
		IGRint NbCorrections;
		struct GRid CorIds[1];
		/*|Component is a correction*/
		me->component_type = VR_CORRECTION ;

		  status = 
		  om$send( msg = message VRGeneric.VRGetCorrections
				( msg, 1, CorIds, &NbCorrections ),
					targetid = me->component._objid,
					targetos = me->component._osnum );
		  as$status();

		status = om$send( msg = message VRCorrection.VRget_state( 
								    &state ),
			  targetid = CorIds[0].objid,
			  targetos = CorIds[0].osnum ) ;

		if( state & VR_FIT_TO_FIT )
			*msg = VR_K_FitToFit;
		else
			*msg = VR_K_IsACorrection ;

	} 
	else
	{
		GRclassid	obj_classid;
	 
		extern	GRclassid OPP_VRNozzle_class_id;

		*msg = VR_K_ACT_SUCCESS ;

    		om$get_classid( objid     = me->component._objid,
		    		osnum     = me->component._osnum,
                    		p_classid = &obj_classid );

    		if(om$is_ancestry_valid( subclassid   = obj_classid,
                             		 superclassid = OPP_VRNozzle_class_id) == OM_S_SUCCESS)
		{
			/*|Component is a nozzle */
			me->component_type = VR_NOZZ;
		}
		else
		{
			if( me->component._osnum != me->ModuleInfo.md_id.osnum )
			{
				/*| Component is in ref. file */
				me->component_type = VR_REF_FILE;
			}
			else
			{
			  IGRint NbCorrections;
			  struct GRid CorIds[VR_MAX_CPTS];

			  /*|Component is neither a correction nor a nozzle */

			  status = 
			  om$send( msg = message VRGeneric.VRGetCorrections
					( msg, VR_MAX_CPTS, CorIds, &NbCorrections ),
					targetid = me->component._objid,
					targetos = me->component._osnum );
			  as$status();

			  for( i = 0; i < NbCorrections; i++ )
			  {
			    status = 
			    om$send( msg = message VRCorrection.VRget_state( 
								    &state ),
			  		targetid = CorIds[i].objid,
			  		targetos = CorIds[i].osnum ) ;

			    if( state & VR_FIT_TO_FIT )
				break;
			  }
					
			  if( i != NbCorrections )
				*msg = VR_K_FitToFit;
			  me->component_type = 0 ;
			}
		}
   	}
	
	if( *msg == VR_K_FitToFit )
		UI_status( "Cannot Split Network with Fit-to-Fit Constrains" );

} /* store_component */
/*----------------------------------------------------------------------------*/
action store_point( IGRlong *msg ) {

	IGRpoint	accept_point ;

	accept_point[0] = me->event1.event.button.x ;
	accept_point[1] = me->event1.event.button.y ;
	accept_point[2] = me->event1.event.button.z ;

	/*^
		printf( "accept point = %g %g %g\n", accept_point[0],
						     accept_point[1],
						     accept_point[2] ) ;
	*/

	/*
	 * Find point on segment.
	 */
	VRSkLocatePipe( msg,
			&me->event1,
			accept_point,
			&me->component.obj_id,
			&me->component.mod_env,
			me->split_point ) ;

	if( !( *msg & 1 ) ) {
		*msg = MSFAIL ;
		return OM_S_SUCCESS ;
	}

	/*^
		printf( "split point = %g %g %g\n", me->split_point[0],
						    me->split_point[1],
						    me->split_point[2] ) ;
	*/

	*msg = VR_K_ACT_SUCCESS ;

} /* store_point */
/*----------------------------------------------------------------------------*/
action split_network( IGRlong *msg ) {

	struct	GRid	SegId[2];
	struct	GRid	*child[2] ;
	int		i;

	extern OMuword OPP_VRcompoint_class_id ;

	for( i=0; i<2; i++ ) child[i] = NULL ;

	*msg = MSFAIL ;

	if( me->component_type & VR_CORRECTION )
	{

		/*
		 * Retrieve segment to split .
		 */
		status = VRSkGetCorVirtualSupport
			  ( &me->component.obj_id, me->split_point, &me->component.mod_env,
			    &SegId[0] );
		as$status( action = RET_STATUS ) ;

		/*"Segment to split : [%d,%d]\n", SegId[0].osnum, SegId[0].objid*/

		/*
		 * Split segment at split point.
		 */
		status = VRSplitNetWork
			  ( msg, &SegId[0], me->split_point, &me->component.mod_env,
			    &me->component.obj_id, &SegId[1]
			  );

		as$status( action = RET_STATUS ) ;
		as$status( action = RET_STATUS, sts = *msg ) ;

		/*"Spliting segment : [%d,%d]\n", SegId[1].osnum, SegId[1].objid*/

	}
	else if( me->component_type & VR_NOZZ || me->component_type & VR_REF_FILE )
	{
		IGRint		CptNum=-1, index, NbSegs;
		struct	GRid	SupportId, VRCptBuffer[VR_MAX_CPTS];

		if( me->component_type & VR_REF_FILE )
		{
  			extern GRclassid 	OPP_ACpretendin_class_id;
  			extern GRclassid 	OPP_VRCptIn_class_id;
  			IGRint 			index1, count1; 
			IGRuint			count;  	
			GRclassid 		obj_class;
			struct	GRid		*buffer;
			OM_S_OBJECT_LINKAGE   	*child;

  			/* Try to find a matching ACpretendin */
  			status = om$get_channel_count( 	objid 	     = me->component._objid,
							osnum 	     = me->component._osnum,
							p_chanselect = &AS_notification,
							count 	     = &count);
  			as$status( action = RET_STATUS );

			/*"count = %d\n", count */
  
  			if( count > 0 )
   			{
    				child =(OM_S_OBJECT_LINKAGE *) alloca(count * sizeof(OM_S_OBJECT_LINKAGE));
    				if(!child) return OM_W_ABORT;
  
    				status = om$get_channel_objects( objid 	      = me->component._objid,
								 osnum        = me->component._osnum,
								 p_chanselect = &AS_notification,
								 list 	      = child,
								 size         = count,
								 count        = &count);
				
				/*"count = %d\n", count */

    				for(index=0, CptNum=0;index<count;index++)
    				{
					/*"child[%d] = %d\n", index, child[index].S_objid */
     					status = om$get_classid( osnum	   = child[index].osnum, 
      			       					 objid 	   = child[index].S_objid, 
								 p_classid = &obj_class );
     					as$status( );

     					if( om$is_ancestry_valid( subclassid   = obj_class,
		        					  superclassid = OPP_ACpretendin_class_id )
									!= OM_S_SUCCESS ) continue;

				     	/*| it is a pretendin ==> get the VRcptIn */
					status =
					om$send( msg      = message NDnode.NDget_objects
								     ( ND_CHILDREN | ND_IN_BUF, NULL, 0, &buffer, 0, OM_K_MAXINT, &count1 ),
							  targetid = child[index].S_objid,
							  targetos = child[index].osnum );
					as$status();

					/*"count1 = %d\n", count1 */

					for( index1=0; index1<count1; index1++ )
					{
						/*"buffer[%d]=%d\n", index1, buffer[index1].objid */
     						status = om$get_classid( osnum	   = buffer[index1].osnum, 
      			       					 	 objid 	   = buffer[index1].objid, 
								 	 p_classid = &obj_class );
     						as$status( );

     						if( om$is_ancestry_valid( subclassid   = obj_class,
		        					  	  superclassid = OPP_VRCptIn_class_id )
									!= OM_S_SUCCESS ) continue;

						VRCptBuffer[CptNum++] = buffer[index1];
						/*"VRCptBuffer[%d]=%d\n", CptNum-1, VRCptBuffer[CptNum-1].objid */
					}
				}
			}
		}
		else
		{
			CptNum = 1;
			VRCptBuffer[0] = me->component.obj_id;
		}

		for( index=0; index<CptNum; index++ )
		{
			me->component.obj_id = VRCptBuffer[index];

			/*| Get the nozzle support */
			status = om$send( msg      = message VRGeneric.VRGetSupports 
					     	     ( msg, 1, &SupportId, &NbSegs ),
				  	  targetid = me->component._objid,
				  	  targetos = me->component._osnum );
			as$status();

			/*"NbSeg = %d\n", NbSegs */

			/*"SegId = %d %d\n", SupportId.objid, SupportId.osnum */

			/*| Disconnect the Nozzle or the VRCptIn */
			status = om$send( msg      = message VRCnrlSeg.VRnotify_disconnect
							( 0, me->component.obj_id ), 
					  targetid = SupportId.objid,
					  targetos = SupportId.osnum );
			as$status();
		}

		*msg = VR_K_ACT_SUCCESS;
		return OM_S_SUCCESS;
	}
	else
	{
		status = om$send( msg	   = message VRGeneric.VRSetStatus(
							msg,
							VR_DUMB_DEL,
							VR_DUMB_DEL ),
			  targetid = me->component._objid,
			  targetos = me->component._osnum ) ;

		as$status( action = RET_STATUS ) ;
		as$status( action = RET_STATUS, sts = *msg ) ;

		status =
		om$send( msg	   = message GRgraphics.GRdelete
					( msg, &me->component.mod_env ),
			targetid = me->component._objid,
			targetos = me->component._osnum ) ;

		as$status( action = RET_STATUS ) ;
		as$status( action = RET_STATUS, sts = *msg ) ;

		status = VRSplitNetwork( msg,&(me->component.obj_id),
					&me->component.mod_env );
		*msg = VR_K_ACT_SUCCESS;

		nd$exec_batch();
		return status;
	}

	/*
	 * Disconnect planes.
	 */

	/*"Disconnect planes of : [%d,%d]\n",SegId[0].objid, SegId[1].objid*/

	status = VRdisconnect( (int *)msg,
			       &SegId[0],
			       &SegId[1],
			       &me->component.mod_env ) ;

	as$status() ;
	as$status( sts = *msg ) ;

	*msg = VR_K_ACT_SUCCESS;

} /* split_network */
/*----------------------------------------------------------------------------*/

