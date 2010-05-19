/* $Id: VDCmdCpSurf.sl,v 1.1.1.1 2001/01/04 21:08:48 cvs Exp $  */

/* I/VDS
 *
 * File:	vdgraphics/com/VDCmdCpSurf.sl
 *
 * Description:
 *	
 *	This is the command object for copying the surfaces of differant 
 * I/ROUTE entities either in a design file or across the design files.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdCpSurf.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:48  cvs
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
# Revision 1.3  1995/07/29  16:52:34  pinnacle
# Replaced: vdgraphics/cmd/VDCmdCpSurf.sl for:  by azuurhou for vds.240
#
# Revision 1.2  1995/03/07  16:20:12  pinnacle
# Replaced: vdgraphics/cmd by azuurhou r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/05/94	Manyam		Creation
 */

/*---------------------
 * class specification area
 */
command_string       VDC_M_CopySurf,0,VDCpSurf
class                VDCmdCpSurf
super_class	     VDS_LOCATE	
command_table	     "vds.cmd"
product_name         "$VDS"
 
/*---------------------
 * specification area
 */
specification

/*+cmd
  Command Object Class VDCmdCpSurf

  Superclass
      VDS_LOCATE

  Abstract
      Command object for "Copy Component Surfaces"

  Methods
      <Name>		<Public/Private>	<Description>
      
       VDFreeMemory	Private			Free memory
       VDGetLocObjects  Public			Gets the located objects and
						stores the info in the instance
						data
       VDGetFromPnt	Public			Gets the From Pnt and stores it
						in the instance data.
       VDGetDestnPnt	Public			Gets the Destination Pnt and
						stores it in the instance data
       VDCopyXform	Private			Copies and Xforms the objects
						identified.
	
  Overridden Methods
     <Name>		<Description>

      init		Initialize my instance data also.
      delete		Free any memory that has been allocated by COB

-cmd*/

#include	"growner.h"

instance
{
	IGRdouble		dFromPnt[3];
	IGRdouble		dDestination[3];
  	IGRint			NumOfObjects;	/* number of located objects */
  	struct	GRobj_env	*LocatedObjects;  /* list of located objects */
}


/*---------------------
 * implementation area
 */

implementation
#include	<stdio.h>
#include	<stdlib.h>
#include	"OMminimum.h"
#include	"OMerrordef.h"
#include	"msdef.h"
#include	"igrtypedef.h"
#include	"igetypedef.h"
#include	"gr.h"
#include	"godef.h"
#include	"igr.h"
#include	"igrdp.h"
#include	"dp.h"
#include	"go.h"
#include	"ex.h"
#include	"grio.h"
#include	"OMprimitives.h"
#include	"AS_status.h"
#include	"asmacros.h"
#include	"grmacros.h"
#include	"growner.h"
#include	"coparamac.h"
#include	"v_miscmacros.h"
#include 	"v_dbgmacros.h"

extern	GRclassid	OPP_EMSsurface_class_id;
extern	OM_S_CHANSELECT	AS_to_comp;
extern	int		ASstart_var_fence(), ASend_fence();
extern	IGRint		VDcp_get_active_symb();
extern	IGRint		VDcp_GetNodes(); 

from	GRgraphics	import	GRcptform;
from	GRvg		import	GRputsymb;
from	GRowner		import	GRget_matrix;

/*---------------------
 * state table area
 */

state_table

#include "VDmsg.h"

state	start

	on CMD_TYPE = 0 
		do message_key	VD_M_CopySurf
								state GET_OBJ
	on ELSE
								state terminate

state	GET_OBJ

  prompt_key		VD_P_IdComp
  status		""
  accept_key		VD_P_AccRej
  relocate_key		VD_S_CpSfCmpNotFnd
  dynamics		off
  locate_eligible	"+VDSroot"
  locate_owner		"LC_RIGID_COMP | LC_REF_OBJECTS " 
  filter		locate

	on EX_BACK_UP or EX_RJT_MOVEON				state -

   	on EX_DATA or EX_OBJID
		do VDGetLocObjects( &me->ret )
			on ERROR				state .
								state from_pnt

	on ELSE							state terminate

state	from_pnt

  message_key		VD_M_CopySurf
  prompt_key		VD_P_CpSfAccFmPnt
  dynamics		off
  filter		get_event

	on EX_BACK_UP or EX_RJT_MOVEON
		do VDFreeMemory					state start
	
	on EX_DATA
		do VDGetFromPnt					state destn_pnt
	
state	destn_pnt

  message_key		VD_M_CopySurf
  prompt_key		VD_P_CpSfDestLoc
  dynamics		off
  filter		get_event

	on EX_BACK_UP
		do VDFreeMemory					state start

	on EX_RJT_MOVEON					state -

	on EX_DATA
		do VDGetDestnPnt
		do VDCopyXform
		do VDFreeMemory					state start
		
/*---------------------
 * message area
 */

/*+mo
  Overridden Message
	init		from	super_cmd

  Abstract
	Initialize my own instance data and send the message wrt message

-mo*/

action init
{
	int		i;

	/*A Initialize my instance data -- */
	me->NumOfObjects = 0;		/* Set to zero initially	*/
	me->LocatedObjects = NULL;	/* Set to NULL			*/

	/*A send the parent's init message wrt message */
	status =
	_VD_SEND_WRT_M( my_id, VDS_LOCATE.init ( type, str_ptr ));
  	as$status( action = RET_STATUS );

	return OM_S_SUCCESS;
}

/*+mo
  Overridden Message
	delete		from	super_cmd

  Abstract
	Free any memory that has been allocated and send the delete 
	message wrt to message
-mo*/

action delete
{
IGRlong	msg;

	/*C free the memory that has been allocated */
	status =
	_VD_SEND_MY( VDCmdCpSurf.VDFreeMemory(&msg));

	/*C send the delete message wrt message to myself */
	status =
	_VD_SEND_WRT_M(	my_id, VDS_LOCATE.delete ( 0 ));

	return status;

}/* end delete */


/*+mi
  Private Message VDFreeMemory

  Abstract
	Free the dynamic memory allocated

  Status/Return Code
      status == OM_S_SUCCESS	if success;
-mi*/

action VDFreeMemory
{
	/*A Free the memory that has been allocated by the system */

	me->NumOfObjects = 0;
	_FREE( me->LocatedObjects );
	me->LocatedObjects = NULL;

	return OM_S_SUCCESS;
}

/*+me
  Public Message VDGetLocObjects

  Abstract

	Gets all the located objects ( single or group ( fence ) locate )
	and stores the objids in to the instance data of the command object

  Status/Return Code
      status == OM_S_SUCCESS	if success;
-me*/

action VDGetLocObjects
{
	IGRint			i,NumOfFenceObjs;
        IGRshort                nLocProd;
	struct	GRobj_env	*FenceObjs;

	*sts = MSSUCC;

	/*A Initialization */
	NumOfFenceObjs = 0;
	FenceObjs = NULL;

	/*A get the fence contents */

	as$start_fence(
		set	= &me->event1.located_object[0].located_obj,
         	set_env = &me->event1.located_object[0].module_info,
		nb_obj  = &NumOfFenceObjs,
		p_obj_env = &FenceObjs, 
		response = me->response, 
		response_data = me->response_data);
#ifdef	DEBUG
	printf(" NumOfObjects = %d \n",NumOfFenceObjs );
#endif
	/*A return error if no object is found */
	if ( !NumOfFenceObjs )	
	{
		*sts = MSFAIL;
		return	OM_S_SUCCESS;
	} 

	/*A Allocate memory for holding the GRids in the instance data */
	me->NumOfObjects = NumOfFenceObjs;
	me->LocatedObjects = ( struct GRobj_env * )
		calloc( NumOfFenceObjs, sizeof( struct GRobj_env ) );
	if ( !me->LocatedObjects ) 
	{
		printf( " Could Not allocate Dynamic Memory \n" );
		goto wrapup;
	}	

	/*A transfer all the route Cmp objects to the instance data */
	for ( i=0; i<me->NumOfObjects; i++ )
	{
		me->LocatedObjects[i] = FenceObjs[i];
#ifdef DEBUG
		printf(" i = %d, objid = %d \n", i,
			me->LocatedObjects[i].obj_id.objid );
#endif
	}	

wrapup:
	ASend_fence();	/* Free the memory allocated by the fence macro */
	
	return OM_S_SUCCESS;
	
}

/*+me
  Public Message VDGetFromPnt

  Abstract

	Gets the From Pnt and stores it in the instance
	data of the command object

  Status/Return Code
      status == OM_S_SUCCESS	if success;
-me*/


action	VDGetFromPnt
{
	/*A get the from point	*/
	me->dFromPnt[0] = me->event1.event.button.x;
	me->dFromPnt[1] = me->event1.event.button.y;
	me->dFromPnt[2] = me->event1.event.button.z;

	return OM_S_SUCCESS;
}

/*+me
  Public Message VDGetDestnPt

  Abstract

	Gets the Destination Pnt and stores it in the instance
	data of the command object

  Status/Return Code
      status == OM_S_SUCCESS	if success;
-me*/

action	VDGetDestnPnt
{
	/*A get the destination point	*/
	me->dDestination[0] = me->event1.event.button.x;
	me->dDestination[1] = me->event1.event.button.y;
	me->dDestination[2] = me->event1.event.button.z;

	return OM_S_SUCCESS;
}

/*+mi
  Private Message VDCopyXform

  Abstract
	
	Copies and Xforms all the surfaces of the identified objects

  Status/Return Code
      status == OM_S_SUCCESS	if success;
      statuc == OM_E_NODYNMEM   if no dynamic memory for allocation
-mi*/

action	VDCopyXform
{
	/*C variable declaration	*/
	struct GRid		*pObjects,NewId;
	IGRint			NbObj, ArrayLen;
	GRobjid			NewObjId;
	IGRint			i, j;
	IGRlong			retmsg;
	IGRdouble		dMatrix[16], dXlateVec[3];
	IGRshort		nMatType;
	struct	GRsymbology	CmpSymb;

#ifdef	DEBUG
	printf( " dFromPnt = %f, %f , %f \n",
		me->dFromPnt[0], me->dFromPnt[1], me->dFromPnt[2] );
	printf( " dDestination = %f, %f , %f \n",
		me->dDestination[0], me->dDestination[1], me->dDestination[2] );
#endif

	/*A calculate the xlate vector	*/
	for ( i=0; i<3; i++ )
		dXlateVec[i] = me->dDestination[i] - me->dFromPnt[i];

	/*A get the active symbology	*/
	status =
	VDcp_get_active_symb( &CmpSymb.level, &CmpSymb.display_attr );

	pObjects = NULL;

	/*A process each of the component	*/	
	for ( i=0; i<me->NumOfObjects; i++ )
	{
		ArrayLen  = 10;

		/*A Malloc pObjects */
		pObjects = _MALLOC( ArrayLen, struct GRid );
		if( pObjects == NULL )
		{
	          printf(" Error not enougth dynamic memory \n");
        	  return  OM_E_NODYNMEM;
	        }
		
		/*A fill the list	*/
		pObjects[0].objid = me->LocatedObjects[i].obj_id.objid;
		pObjects[0].osnum = me->LocatedObjects[i].obj_id.osnum;
		NbObj = 1;

		for ( j=0; j< NbObj; j=j+1 )
		{

			/*A get all the surface ids	*/
			status = 
			VDcp_GetNodes(	&retmsg,
					j,
					&ArrayLen,
					&pObjects,
					&NbObj,
					OPP_EMSsurface_class_id );
			if( ! status )
			{
				printf(" Error in fct VDcp_GetNodes\n");
				goto SurfWrapup;
			}

			if( retmsg == MSSUCC )
			{
				NewObjId = NULL_OBJID;
#ifdef	DEBUG
				printf( " Surface Id %d , %d \n",
					 pObjects[j].objid,
					 pObjects[j].osnum );
#endif

				/*A get the matrix for the component	*/
				status =
				om$send( msg = message GRowner.GRget_matrix(
				        &retmsg, 
					&me->LocatedObjects[i].mod_env.md_env.matrix_type,
					me->LocatedObjects[i].mod_env.md_env.matrix,
				        &nMatType, dMatrix ),
					senderid = me->LocatedObjects[i].obj_id.objid,
					targetos = me->LocatedObjects[i].obj_id.osnum,
					p_chanselect = &AS_to_comp );
				as$status( );

				/*A xlate the origin to the given point	*/
				dMatrix[3]	= dMatrix[3] + dXlateVec[0];
				dMatrix[7]	= dMatrix[7] + dXlateVec[1];
				dMatrix[11]	= dMatrix[11] + dXlateVec[2];

				/*A copy all surface objects and xform them
				as required				*/
				status =
				_VD_SEND_OBJ(	pObjects[j],
					GRgraphics.GRcptform( 
						&retmsg, 
						&me->LocatedObjects[i].mod_env,
						dMatrix, &me->ModuleInfo,
						&NewObjId ));
				as$status();

#ifdef	DEBUG
				printf( " NewObjectID = %d \n",	NewObjId );
#endif

				/*A put the symbology	*/
 				status =
				om$send( msg = message GRvg.GRputsymb(
						&retmsg, &CmpSymb ),
					targetid =  NewObjId,
					targetos =  me->ModuleInfo.md_id.osnum );
 				as$status();

				NewId.objid	= NewObjId;
				NewId.osnum	= me->ModuleInfo.md_id.osnum;

				/*A display the copied object	*/
				status =
				gr$display_object( 
					object_id	= &NewId,
					md_env		= &me->ModuleInfo,
					mode		= GRbd );
				as$status();
				
			}	

		}/* end processing forleave objects	*/

		/*A free any of the memory that is allocated	*/
		_FREE( pObjects	);
		pObjects = NULL;
	
	}/* end processing for all the cmps	*/


SurfWrapup: 

	_FREE( pObjects );
	return OM_S_SUCCESS;
}

