class implementation VDCmdCpSurf;


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


#define _start 0
#define _GET_OBJ 1
#define _from_pnt 2
#define _destn_pnt 3

method init ( int type ; char * str_ptr )
{
  int		  status = OM_S_SUCCESS;

	int		i;

	/*A Initialize my instance data -- */
	me->NumOfObjects = 0;		/* Set to zero initially	*/
	me->LocatedObjects = NULL;	/* Set to NULL			*/

	/*A send the parent's init message wrt message */
	status =
	_VD_SEND_WRT_M( my_id, VDS_LOCATE.init ( type, str_ptr ));
  	as$status( action = RET_STATUS );

	return OM_S_SUCCESS;
quit:
  return OM_S_SUCCESS;
}

method delete ( int f_defer_flag )
{
  int		  status = OM_S_SUCCESS;

IGRlong	msg;

	/*C free the memory that has been allocated */
	status =
	_VD_SEND_MY( VDCmdCpSurf.VDFreeMemory(&msg));

	/*C send the delete message wrt message to myself */
	status =
	_VD_SEND_WRT_M(	my_id, VDS_LOCATE.delete ( 0 ));

	return status;

quit:
  return OM_S_SUCCESS;
}

method VDFreeMemory ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	/*A Free the memory that has been allocated by the system */

	me->NumOfObjects = 0;
	_FREE( me->LocatedObjects );
	me->LocatedObjects = NULL;

	return OM_S_SUCCESS;
quit:
  return OM_S_SUCCESS;
}

method VDGetLocObjects ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
	
quit:
  return OM_S_SUCCESS;
}

method VDGetFromPnt ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	/*A get the from point	*/
	me->dFromPnt[0] = me->event1.event.button.x;
	me->dFromPnt[1] = me->event1.event.button.y;
	me->dFromPnt[2] = me->event1.event.button.z;

	return OM_S_SUCCESS;
quit:
  return OM_S_SUCCESS;
}

method VDGetDestnPnt ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	/*A get the destination point	*/
	me->dDestination[0] = me->event1.event.button.x;
	me->dDestination[1] = me->event1.event.button.y;
	me->dDestination[2] = me->event1.event.button.z;

	return OM_S_SUCCESS;
quit:
  return OM_S_SUCCESS;
}

method VDCopyXform ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

end implementation VDCmdCpSurf;
