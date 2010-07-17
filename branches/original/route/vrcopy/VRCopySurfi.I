/* $Id: VRCopySurfi.I,v 1.1.1.1 2001/01/04 21:12:48 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcopy / VRCopySurfi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCopySurfi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:48  cvs
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
# Revision 1.3  1996/03/01  23:47:42  pinnacle
# Replaced: vrcopy/VRCopySurfi.I for:  by hverstee for route240
#
# Revision 1.2  1996/01/16  22:39:06  pinnacle
# Replaced: vrcopy/VRCopySurfi.I for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb		Add prototypes
 *
 *************************************************************************/
class implementation VRCopySurf;


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
#include	"VRcompdef.h"
#include	"growner.h"
#include	"coparamac.h"
#include	"matypemx.h"

#include	"vrcopy_pto.h"
#include	"vrtools_pto.h"

extern	GRclassid	OPP_EMSsurface_class_id;
extern	OM_S_CHANSELECT	AS_to_comp;
extern	int		ASstart_var_fence(), ASend_fence();
extern	IGRint		GRdisplay_object();

from	VRGeneric	import	VRGetStatus,
				VRGetMatrix;
from	GRgraphics	import	GRcopy, GRxform;
from	GRvg		import	GRgetsymb, GRputsymb;
from	GRowner		import	GRget_matrix;

/*C	 state table definition for the command	*/


#define _start 0
#define _GET_OBJ 1
#define _GET_FROM_PNT 2
#define _GET_DESTN_PNT 3

method init ( int type ; char * str_ptr )
{
  int		  status = OM_S_SUCCESS;

	int		i;

	/*A Initialize my instance data -- */
	me->NumOfObjects = 0;		/* Set to zero initially	*/
	me->LocatedObjects = NULL;	/* Set to NULL			*/

	/*A send the parent's init message wrt message */
	status =
	om$send( msg    = message VDB_LOCATE.init ( type, str_ptr ),
	   	mode   = OM_e_wrt_message,
	   	targetid = my_id);

	return status;
}

method delete ( int f_defer_flag )
{
  int		  status = OM_S_SUCCESS;


	/*C free the memory that has been allocated */
	status =
  	om$send(	msg = message VRCopySurf.VRFreeMemory(),
			targetid = my_id);

	/*C send the delete message wrt message to myself */
	status =
	om$send(	msg = message VDB_LOCATE.delete ( 0 ) ,
			mode = OM_e_wrt_message,
	targetid = my_id);

	return status;

}

method VRFreeMemory ( )
{

	/*A Free the memory that has been allocated by the system */

	me->NumOfObjects = 0;
	if ( me->LocatedObjects ) free (  me->LocatedObjects );
	me->LocatedObjects = NULL;
	return OM_S_SUCCESS;
}

method VRGetLocObjects ( long * sts )
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

	as$start_fence(set= &me->event1.located_object[0].located_obj,
         	set_env = &me->event1.located_object[0].module_info,
		nb_obj = &NumOfFenceObjs,
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

method VRGetFromPnt ()
{

	/*A get the from point	*/
	me->dFromPnt[0] = me->event1.event.button.x;
	me->dFromPnt[1] = me->event1.event.button.y;
	me->dFromPnt[2] = me->event1.event.button.z;

	return OM_S_SUCCESS;
}

method VRGetDestnPnt ()
{

	/*A get the destination point	*/
	me->dDestination[0] = me->event1.event.button.x;
	me->dDestination[1] = me->event1.event.button.y;
	me->dDestination[2] = me->event1.event.button.z;

	return OM_S_SUCCESS;
}

method VRCopyXform ( )
{
  int		  status = OM_S_SUCCESS;

	/*C variable declaration	*/
	struct GRid		*pObjects,NewId;
	GRobjid			*LocObjIds=NULL;
	GRspacenum		*LocOsNums=NULL;
	struct	GRmd_env	*LocModEnv=NULL;
	IGRint			NbObj,NbCmps, ArrayLen;
	GRobjid			NewObjId;
	IGRint			i, j;
	IGRlong			retmsg;
	struct	GRmd_env	ActModEnv;
	IGRdouble		dMatrix[16], dFromPnt[3], dDestination[3];
	IGRdouble		dXlateVec[3];
	IGRshort		nMatType;
	IGRboolean		bRetStatus;
	struct	GRsymbology	CmpSymb;
	IGRshort		nStatus;
	IGRuchar		cRep;

	IGRint			junk;

	/*A fill the structure	*/
	NbCmps = me->NumOfObjects;

#ifdef	DEBUG
	printf( " dFromPnt = %f, %f , %f \n",
		me->dFromPnt[0], me->dFromPnt[1], me->dFromPnt[2] );
	printf( " dDestination = %f, %f , %f \n",
		me->dDestination[0], me->dDestination[1], me->dDestination[2] );
#endif
	/*A get the active module information	*/
	ActModEnv = me->ModuleInfo;
	
	/*A allocate the memory	*/
        LocObjIds = ( GRobjid * )
		calloc( me->NumOfObjects, sizeof( GRobjid ) );

        LocOsNums = ( GRspacenum * )
		calloc( me->NumOfObjects, sizeof( GRspacenum ) );

        LocModEnv = ( struct GRmd_env * )
		calloc( me->NumOfObjects, sizeof( struct GRmd_env ) );

	if ( !LocModEnv || !LocOsNums || !LocObjIds ) 
	{
		printf( " Could Not allocate Dynamic Memory \n" );
		goto SurfWrapup;
	}	

	/*A xfer the data 	*/
	for ( i=0; i< me->NumOfObjects; i=i+1 )
	{
		LocObjIds[i] = me->LocatedObjects[i].obj_id.objid;
		LocOsNums[i] = me->LocatedObjects[i].obj_id.osnum;
		LocModEnv[i] = me->LocatedObjects[i].mod_env;
	}

	/*A calculate the xlate vector	*/
	for ( i=0; i<3; i= i+1 )
		dXlateVec[i] = me->dDestination[i] - me->dFromPnt[i];

	/*A get the active symbology	*/
	status =
	VRget_active_symb( &CmpSymb.level, &CmpSymb.display_attr );

	/*A process each of the component	*/	
	for ( i=0; i<NbCmps; i=i+1 )
	{
		pObjects = NULL;
		ArrayLen  = 10;

		/*A get the status of the component	*/
#ifdef	DEBUG
		printf( " LOC CmpID[%d] = %d, %d \n", i,
			LocObjIds[i], LocOsNums[i] );
		printf("LOC CMP's MOD ENV: %d, %d\n",
			LocModEnv[i].md_id.objid, LocModEnv[i].md_id.osnum );
#endif
		status =
		om$send( msg = message VRGeneric.VRGetStatus(
				&retmsg, &nStatus ),
			targetid = LocObjIds[i],
			targetos = LocOsNums[i] );
		as$status();
		
		/*A get the symbology from the component	*/
/*	
		status =
		om$send( msg = message GRvg.GRgetsymb(
				&retmsg, &CmpSymb ),
			targetid = LocObjIds[i],
			targetos = LocOsNums[i] );
		as$status(action=RET_STATUS);
*/
		/*A Malloc pObjects */
		pObjects = 
		(struct GRid *) malloc( sizeof(struct GRid) * ArrayLen);
		if( pObjects == NULL )
		{
	          printf(" Error not enougth dynamic memory \n");
        	  return  OM_E_NODYNMEM;
	        }
		
		/*A fill the list	*/
		pObjects[0].objid = LocObjIds[i];
		pObjects[0].osnum = LocOsNums[i];
		NbObj = 1;

		for ( j=0; j< NbObj; j=j+1 )
		{

			/*A get all the surface ids	*/
			status = 
			VRGetNodes(&retmsg,j,&ArrayLen,&pObjects,
				&NbObj,OPP_EMSsurface_class_id );
			if( ! status )
			{
				printf(" Error in fct VRGetNodes\n");
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
				/*A copy all the surfaces	*/
				status =
				om$send( msg = message GRgraphics.GRcopy(
					&retmsg, &LocModEnv[i],	
					&ActModEnv, &NewObjId ),
					targetid = pObjects[j].objid,
					targetos = pObjects[j].osnum);
				as$status();
#ifdef	DEBUG
				printf( " NewObjectID = %d \n",
					NewObjId );
#endif
				if ( nStatus & VR_CORRECTION )
				/*A get the matrix for correction components*/
				status =
				om$send( msg = message GRowner.GRget_matrix(
				        &retmsg, &LocModEnv[i].md_env.matrix_type,
					LocModEnv[i].md_env.matrix,
				        &nMatType, dMatrix ),
					senderid = LocObjIds[i],
					targetos = LocOsNums[i],
					p_chanselect = &AS_to_comp );
				else
				/*A get the xformation matrix from 
				the header object		*/
				status =
				om$send( msg = message VRGeneric.VRGetMatrix(
						&retmsg, 0, NULL, 
						dMatrix, &LocModEnv[i] ),
					targetid = LocObjIds[i],
					targetos = LocOsNums[i] );
				as$status( );
#ifdef	DEBUG
	for(junk=0;junk<13;junk=junk+4)
		printf(" Matrix : %lf  %lf  %lf  %lf\n",
			dMatrix[junk],
			dMatrix[junk+1],
			dMatrix[junk+2],
			dMatrix[junk+3]);

	printf(" New Origin : %lf  %lf  %lf \n",
			dDestination[0],
			dDestination[1],
			dDestination[2] );
#endif
				/*A xlate the origin to the given point	*/
				dMatrix[3]	= dMatrix[3] + dXlateVec[0];
				dMatrix[7]	= dMatrix[7] + dXlateVec[1];
				dMatrix[11]	= dMatrix[11] + dXlateVec[2];

				/*A get the matrix type 	*/
				bRetStatus =
				MAtypemx( &retmsg, dMatrix,&nMatType);

				/*A post the new xformation matrix to the
				copied object				*/
				status =
				om$send ( msg = message GRgraphics.GRxform( 
						&retmsg, &ActModEnv,
						&nMatType,dMatrix, &NewObjId ),
					targetid =  NewObjId,
					targetos =  ActModEnv.md_id.osnum );
				as$status( );

				/*A put the symbology	*/
 				status =
				om$send( msg = message GRvg.GRputsymb(
						&retmsg, &CmpSymb ),
					targetid =  NewObjId,
					targetos =  ActModEnv.md_id.osnum );
 				as$status();

				NewId.objid	= NewObjId;
				NewId.osnum	= ActModEnv.md_id.osnum;

				/*A display the copied object	*/
				status =
				gr$display_object( 
					object_id	= &NewId,
					md_env		= &ActModEnv,
					mode		= GRbd );
				as$status();
				
			}	

		}/* end processing forleave objects	*/

		/*A free any of the memory that is allocated	*/
		if ( pObjects )	free ( pObjects	);
	
	}/* end processing for all the cmps	*/


SurfWrapup: 
	if ( LocObjIds ) free ( LocObjIds );
	if ( LocOsNums ) free ( LocOsNums );
	if ( LocModEnv ) free ( LocModEnv );

	return OM_S_SUCCESS;
}

end implementation VRCopySurf;
