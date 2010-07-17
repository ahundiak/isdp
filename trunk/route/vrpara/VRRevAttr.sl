/* $Id: VRRevAttr.sl,v 1.1.1.1 2001/01/04 21:13:00 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpara/VRRevAttr.sl
 *
 * Description:
	This command is intended to review the various
	  attributes ( System, User, Missing, Static )
	  associated with any I/ROUTE component
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRRevAttr.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:00  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  1999/04/20  08:15:26  pinnacle
# Replaced: vrpara/VRRevAttr.sl for:  by sbilla for route
#
# Revision 1.2  1998/10/27  08:34:12  pinnacle
# Replaced: vrpara/VRRevAttr.sl for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.8  1996/04/04  21:54:42  pinnacle
# Replaced: vrpara/VRRevAttr.sl for:  by ashankar for route240
#
# Revision 1.7  1996/03/28  17:21:40  pinnacle
# Replaced: vrpara/VRRevAttr.sl for:  by hverstee for route240
#
# Revision 1.6  1996/03/05  20:46:36  pinnacle
# Replaced: vrpara/VRRevAttr.sl for:  by hverstee for route240
#
# Revision 1.5  1996/03/01  23:09:18  pinnacle
# Replaced: vrpara/VRRevAttr.sl for:  by hverstee for route240
#
# Revision 1.4  1996/01/17  14:47:02  pinnacle
# Replaced: vrpara/VRRevAttr.sl for:  by r240_int for route240
#
# Revision 1.3  1995/12/08  21:23:34  pinnacle
# Replaced: vrpara/VRRevAttr.sl for:  by r240_int for route240
#
 *
 * History:
 *	09/11/93	Manyam	creation
 *	12/06/95	tlb	Remove VRcmd.h
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *      10/27/98        Reddy   In the state PROCESS_OBJ, VRUpdSysForm
 *   				method is placed below the VRDispForm method
 *      04/20/99        Reddy   Two instance variables added to get Raceway
 *				tier information
 *************************************************************************/

command_string       VRC_M_RevPpCompAttr,0,VRRvPpAttr
synonym              VRC_M_RevHvCompAttr,1,VRRvHvAttr
synonym              VRC_M_RevRwCompAttr,2,VRRvRwAttr
/*
synonym              VRC_M_RevCbAttr,3,VRRvCbAttr
synonym              VRC_M_RevFoAttr,4,VRRvFoAttr
*/
class                VRRevAttr
super_class	     VRActParam
product_name         "$ROUTE"
command_table	     "route.cmd"

specification

#include	"growner.h"
#include	"VRRevdef.h"
#include 	"VRRwDimen.h"

instance
{
	IGRint			bPid;		/* Type of represent	*/
	IGRint			CurCmpIndex;	/* Index of the Component	
						   in the list for which
						   attributes ar being 
						   reviewed */
  	IGRint			NumOfObjects; /* number of located objects	*/
	IGRint			NbCpts;       /* No. of connect points for a
component CR179900491*/
  	struct	GRobj_env	*LocatedObjects;  /* list of located objects		*/
	struct	GRid		ModelId;	/* ModelId of the Cmp currently
						   Under Process	*/
	struct	GRid		MissingId;	/* Missing Parameters ID*/
        
	struct  VRRwCptDetails  RwCptData[10];  /* Stores Raceway details CR179900491 */
}

/*C	reject any of the messages required	*/

implementation

#include	"OMprimitives.h"
#include	"OMmacros.h"
#include	"GRtypedef.h"
#include	"igrdef.h"
#include	"dpdef.h"
#include	"dpmacros.h"
#include	"AS_status.h"
#include	"FI.h"
#include	"VRchgattrdef.h"
#include	"coparamac.h"
#include	"acrepdef.h"
#include	"VRPid.h"
#include	"VDmem.h"
#include 	"VRRwDimen.h"

%safe
#include "VX_FIproto.h"
%endsafe

	extern GRclassid OPP_VRPComp_class_id;
	extern GRclassid OPP_VRPCComp_class_id;
	extern GRclassid OPP_VRHComp_class_id;
	extern GRclassid OPP_VRHCComp_class_id;
	extern GRclassid OPP_VRRComp_class_id;
	extern GRclassid OPP_VRRCComp_class_id;
/*
	extern GRclassid OPP_VRLink_class_id;
	extern GRclassid OPP_VRElCable_class_id;
	extern GRclassid OPP_VRFoCable_class_id;
*/
from	VRGeneric	import	VRGetParams;
from	VRProduct	import	VRGetProduct;
from	ACncpx		import	ACget_rep;

/*C	 state table definition for the command	*/

state_table
#include	"VRmsg.h"
#include	"VRchgattrdef.h"
#include	"VRRevdef.h"
#include	"dp.h"

state	main

	on CMD_TYPE = 0 
		do	message_key	VR_M_RevPpCompAttr
		state start

	on CMD_TYPE = 1
		do	message_key	VR_M_RevHvCompAttr
		state start

	on CMD_TYPE = 2
		do	message_key	VR_M_RevRwCompAttr
		state start

	on CMD_TYPE = 3
		do	message_key	VR_M_RevCbAttr
		state start

	on CMD_TYPE = 4
		do	message_key	VR_M_RevCbAttr
		state start

state	start

	on ELSE	
		state GET_OBJ

state	GET_OBJ

	prompt_key		VR_P_IdComp
   	accept_key		VR_P_AccReject
   	relocate_key		VR_S_CompNotFound
	dynamics		off
	locate_owner		"LC_RIGID_COMP | LC_REF_OBJECTS " 
   	filter			locate_noauto
	disconnect_located	0

   	on EX_DATA or EX_OBJID	
		do VRGetLocObjects( &me->ret )
			on ERROR
				state .

		state PROCESS_OBJ

	on ELSE
		do VREraseForms()
		do VRFreeMemory()
		state terminate

state PROCESS_OBJ

	on ELSE
		do VRProcessNextObj( )
		do VRDispForm(VR_SYSTEM_ATTR)
		do VRUpdSysForm()
		state	GET_OBJ

/*C	End of state table definition	*/

/*C	init : send the init message wrt to message	*/

action init
{
	int		i;

	/*A Initialize my instance data -- */
	me->Product = -1;		/* Not anything specific	*/
	me->bPid = FALSE;		/* Set to Non Pid		*/
	me->CurCmpIndex = -1;		/* set to invalid value 	*/
	
	me->NumOfObjects = 0;		/* Set to zero initially	*/
	me->LocatedObjects = NULL;	/* Set to NULL			*/
	for ( i=0; i<NUM_FORMS; i++ )
	{
		me->form_ptr[i] = NULL;
		me->form_name[i] = NULL;
	}

	/*C Set all attr objids to NULL_OBJID	*/
  	me->ModelId.objid = me->SysId.objid = NULL_OBJID;
  	me->UsrId.objid = me->MissingId.objid = NULL_OBJID;

	/*A send the parent's init message wrt message */
	status =
	om$send( msg    = message VDB_LOCATE.init ( type, str_ptr ),
	   	mode   = OM_e_wrt_message,
	   	targetid = my_id);
  	as$status( action = RET_STATUS );
        if (me->VDB_terminated) return (status);

	/*A set the eligible class list based on the product type */
	me->locate_eligible_thing.w_count = 2;
	me->locate_eligible_thing.w_flags = OM_CLST_subclass;
  	om$vla_set_dimension( varray = me->eligible_classids,
        		size   = me->locate_eligible_thing.w_count );

	switch( type )
	{
		case 0 :
		me->Product = VR_PIPING;
  		me->form_name[MAIN_FORM] = PIPING_FORM_NAME ;
             	me->eligible_classids[0] = OPP_VRPComp_class_id;
             	me->eligible_classids[1] = OPP_VRPCComp_class_id;
             	break;

		case 1 :
		me->Product = VR_HVAC;
  		me->form_name[MAIN_FORM] = HVAC_FORM_NAME ;
             	me->eligible_classids[0] = OPP_VRHComp_class_id;
             	me->eligible_classids[1] = OPP_VRHCComp_class_id;
             	break;

		case 2 :
		me->Product = VR_CABLING;
  		me->form_name[MAIN_FORM] = RACEWAY_FORM_NAME ;
             	me->eligible_classids[0] = OPP_VRRComp_class_id;
             	me->eligible_classids[1] = OPP_VRRCComp_class_id;
             	break;

		case 3 :
		me->Product = VR_ELECTRIC;
/*  		me->form_name[MAIN_FORM] = ELCABLE_FORM_NAME ;
             	me->eligible_classids[0] = OPP_VRLink_class_id;
             	me->eligible_classids[1] = OPP_VRElCable_class_id;	*/
             	break;

		case 4 :
		me->Product = VR_FIBER;
/*  		me->form_name[MAIN_FORM] = ELCABLE_FORM_NAME ;
             	me->eligible_classids[0] = OPP_VRLink_class_id;
             	me->eligible_classids[1] = OPP_VRFoCable_class_id;	*/
             	break;

		default:
		return OM_E_ABORT;
  	}

	me->locate_eligible_thing.p_classes = me->eligible_classids;
	me->locate_eligible = &me->locate_eligible_thing;

	me->form_name[SUB_FORM] = SUB_FORM_NAME ;

	/* set the delete_flag so as to use the parent's message */
	me->delete_flag = 0;


	/*A read the proper form in to the system */
	status =
	om$send( msg      = message VRActParam.VRInitForm( 
			VR_SYSTEM_ATTR ),
		targetid = my_id );
	as$status();

	return OM_S_SUCCESS;
}

/*C	delete: send the delete message wrt to message	*/

action delete
{

  if (!(me->VDB_terminated))
  {
	/*C erase MAIN_FORM form */
	if ( me->form_ptr[MAIN_FORM] ) FIf_delete( me->form_ptr[MAIN_FORM] );

  	/*C erase sub form */
	if ( me->form_ptr[SUB_FORM] )  FIf_delete( me->form_ptr[SUB_FORM] );

	/*C free the memory that has been allocated */
	status =
  	om$send(	msg = message VRRevAttr.VRFreeMemory(),
			targetid = my_id);
  }

	/*C send the delete message wrt message to myself */
	status =
	om$send(	msg = message VDB_LOCATE.delete ( 0 ) ,
			mode = OM_e_wrt_message,
	targetid = my_id);

	return status;
}/* end delete */

/*C
	VRGetLocObjects	: gets all the located objects ( single or
	group ( fence ) locate ) and stores the objids in to the
	instance data of the command object
*/

action VRGetLocObjects
{
	IGRint			i,NumOfFenceObjs;
        IGRshort                nLocProd;
	struct	GRobj_env	*FenceObjs;

	*sts = MSSUCC;

	/*A Initioalization */
	NumOfFenceObjs = 0;
	FenceObjs = NULL;

	/*A get the fence contents */

	as$start_fence(set= &me->event1.located_object[0].located_obj,
         	set_env = &me->event1.located_object[0].module_info,
		nb_obj = &NumOfFenceObjs,
		p_obj_env = &FenceObjs, 
		response = me->response, 
		response_data = me->response_data);

	/*" NumOfObjects = %d \n",NumOfFenceObjs */

	/*A return error if no object is found */
	if ( !NumOfFenceObjs )	
	{
		*sts = MSFAIL;
		return	OM_S_SUCCESS;
	} 

	/*A dehighlight the previous reviewed component	*/
	if ( me->LocatedObjects && me->CurCmpIndex != -1 )
	{	
		IGRint	retmsg;

		dp$display(msg = &retmsg, 
			oids = &me->LocatedObjects[me->CurCmpIndex].obj_id, 
			mode = GRhe );

		/*A free the memory that has been allocated */
		status =
  		om$send(	msg = message VRRevAttr.VRFreeMemory(),
				targetid = my_id);

		/*A erase the subform */
		if ( me->form_ptr[SUB_FORM] != NULL ) 
			FIf_erase( me->form_ptr[SUB_FORM] );
	}

	/*A Allocate memory for holding the GRids in the instance data */
	me->NumOfObjects = NumOfFenceObjs;
	me->LocatedObjects = ( struct GRobj_env * )
		_CALLOC( NumOfFenceObjs, struct GRobj_env );
	if ( !me->LocatedObjects ) 
	{
		printf( " Could Not allocate Dynamic Memory \n" );
		goto wrapup;
	}	

	/*A transfer all the route Cmp objects to the instance data */
	for ( i=0; i<me->NumOfObjects; i++ )
	{
		me->LocatedObjects[i] = FenceObjs[i];
		/*" i = %d, objid = %d \n", i,
			me->LocatedObjects[i].obj_id.objid */
	}	

        /*C Get the product of the first located object  */

        status =
        om$send (msg = message VRProduct.VRGetProduct (&nLocProd, NULL),
            targetid = me->LocatedObjects[0].obj_id.objid,
            targetos = me->LocatedObjects[0].obj_id.osnum);
        as$status();

        me->Product = nLocProd;

	/*A set the CurCmpIndex in the instance data to 0 */
	me->CurCmpIndex = 0;
wrapup:
	ASend_fence();	/* Free the memory allocated by the fence macro */
	
	return OM_S_SUCCESS;
	
}

/*C	VRProcessNextObj : sets the instance data based on the 
	component that is to be reviewed
*/

action VRProcessNextObj( )
{
	IGRint		Rep;
	IGRlong		retcode;
  
	/*A initialization */
	retcode = OM_S_SUCCESS;

	/*"Cur Index of the Cmp in the list = %d \n",
			me->CurCmpIndex */

	if ( me->CurCmpIndex == -1 )	return	OM_E_ABORT;

	/*C highlight the object */
	dp$display(msg = &retcode, 
		oids = &me->LocatedObjects[me->CurCmpIndex].obj_id, 
		mode = GRhd );

	/*C set to NUL_OBJIDs */
  	me->ModelId.objid = me->SysId.objid = NULL_OBJID;
  	me->UsrId.objid = me->MissingId.objid = NULL_OBJID;

	/*A get the system, user and missing parameters from comp */
	status =
	om$send( msg      = message VRGeneric.VRGetParams
		( &retcode, &me->SysId, &me->UsrId, &me->MissingId),
		targetid = me->LocatedObjects[me->CurCmpIndex].obj_id.objid,
		targetos = me->LocatedObjects[me->CurCmpIndex].obj_id.osnum );
	as$status( action = RET_STATUS );
             
	/*"SystemId = %d, UserId = %d, MissingId = %d \n",
		me->SysId.objid, me->UsrId.objid, me->MissingId.objid */

	/*C return error in the following case
	if ( me->SysId.objid == NULL_OBJID &&
		 me->UsrId.objid == NULL_OBJID &&
			 me->MissingId.objid == NULL_OBJID )
				return OM_E_ABORT;
	/*A get the type of representation 	*/
	status =
	om$send( msg      = message VRGeneric.ACget_rep (&Rep),
		targetid = me->LocatedObjects[me->CurCmpIndex].obj_id.objid,
		targetos = me->LocatedObjects[me->CurCmpIndex].obj_id.osnum );
	as$status();

	if ( bVR_IS_PID ( Rep ) )	me->bPid = TRUE;
	else me->bPid = FALSE;

wrapup:
	return OM_S_SUCCESS;

}

/*C	VREraseForms : erases the forms displayed , resets the
	required data and dehighlights the highlighted component
*/

action	VREraseForms( )
{
	int		i;
	IGRlong		retcode;

	/*A erase MAIN and all sub forms if displayed */
	if( me->form_ptr[MAIN_FORM] != NULL ) 
		FIf_erase( me->form_ptr[MAIN_FORM] );

	if ( me->form_ptr[SUB_FORM] != NULL ) 
		FIf_erase( me->form_ptr[SUB_FORM] );

	/*A dehighlight the reviewed component	*/
	if ( me->LocatedObjects )
		dp$display(msg = &retcode, 
			oids = &me->LocatedObjects[me->CurCmpIndex].obj_id, 
			mode = GRhe );

wrapup:
	return OM_S_SUCCESS;
}

/*C	VRFreeMemory : frees the dynamic memory allocated	*/

action VRFreeMemory( )
{
	/*A Free the memory that has been allocated by the system */

	me->NumOfObjects = 0;
	if ( me->LocatedObjects ) _FREE (  me->LocatedObjects );
	me->LocatedObjects = NULL;
	return OM_S_SUCCESS;
}

/*C	these methods are defined in the other related files	*/

action	form_notification				extern
action	VRUpdSysForm( )					extern
action	VRSetParamForm( long *msg; int	gadget_label )	extern
