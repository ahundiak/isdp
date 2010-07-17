
/* $Id: VRDelPlanei.I,v 1.2 2001/02/20 01:18:27 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrutil/VRDelPlanei.I
 *
 * Description:
 *      Implementation file for Delete Plane command. The command to highlight
 *		all the elements that are affected/deleted when deleting a plane.
 *
 * Dependenomes:
 *
 * Revision History:
 *  $Log: VRDelPlanei.I,v $
 *  Revision 1.2  2001/02/20 01:18:27  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:13:13  cvs
 *  Initial import to CVS
 *
# Revision 1.2  2000/04/05  22:24:50  pinnacle
# Replaced: vrutil/VRDelPlanei.I for:  by lawaddel for route
#
# Revision 1.1  2000/03/15  19:03:48  pinnacle
# added for CR179900493
#
 *
 * History:
 *  03/15/2000    Alwin		Creation   
 *  04/05/00      law           TR179901304 - delete highlighting not stopping
 *				at Offset components 
 *
 *************************************************************************/

class implementation VRDelPlane;

#include <stdio.h>
#include <math.h>
#include "nddef.h"
#include "ndmacros.h"
#include "exmacros.h"
#include "AS_status.h"

#include "asbox.h"
#include "VDmem.h"
#include "coparamac.h"

//#include "VRco.h"
#include "grmacros.h"
#include "vrtools_pto.h"
#include "vrdbgmacros.h"

#define	NODYNMEM  1000
#define VRALL_OK    1105
#define VRNOT_OK    1106

from  NDnode        import  NDget_objects;
from  VRCnrlSeg     import  VRget_planes, VRGetComponents;
from  VRGeneric		import  VRGetCorrections;

method VRinit( long *sts )
{
  SetProc( Md VRinit ); Begin 

  *sts = me->ret = VRALL_OK;

  me->nObjectCount = 0;
  me->pAffectObjectList = NULL;

  End
  return OM_S_SUCCESS;
}

/* Gather all the objects that would get affected because of this deletion.
So that we can display them and let the user know. */
method VRGetAffectedObjectsList( long *sts )
{
  IGRlong  			status, i;
  IGRlong 			retmsg;
  GRclassid			parentClassId;
  struct GRid		PlaneId;

  SetProc( Md VRGetAffectedObjectsList ); Begin

  *sts = me->ret = VRNOT_OK;
  PlaneId = me->event1.located_object[0].located_obj;
  __DBGpr_obj( " Plane Id ", PlaneId );

  if( PlaneId.objid != NULL_OBJID )
  {
	  IGRint			i, comp, corr;
	  IGRint			NbLineSegs, NbComponents, NbCorrections;
	  IGRlong			status;
	  struct GRid		*lineSegIds=NULL;

	  status = MSSUCC;
	  NbLineSegs = 0;

	  // Get the Line Segments connected to the Plane Object
	  status = om$send ( msg = message NDnode.NDget_objects(
					ND_CHILDREN, NULL, 0,
					NULL, 0, OM_K_MAXINT, &NbLineSegs ),
			  targetid = PlaneId.objid,
			  targetos = PlaneId.osnum );
	  as$status();
	  __DBGpr_int( " No. of Line Segments ", NbLineSegs );

	  lineSegIds = _MALLOC( NbLineSegs, struct GRid );
	  status = om$send ( msg = message NDnode.NDget_objects(
					ND_CHILDREN, lineSegIds, NbLineSegs,
					NULL, 0, OM_K_MAXINT, &NbLineSegs ),
			  targetid = PlaneId.objid,
			  targetos = PlaneId.osnum );
	  as$status();

	  for( i=0; i<NbLineSegs; i++ )
	  {
		  IGRlong 	msg;
		  struct GRid CommonPlane, VerticalPlane;
		  struct GRid CompIds[2];
		  struct GRid CorrectionId;
		  
		  msg = MSSUCC;

		  /* For the selected plane, its not that all the line segments 
		  connected would get deleted. Only if the Plane happens to be 
		  either Common or Vertical Plane, they would get deleted. Otherwise
		  they get recomputed. In our case, we don't need to highlight that
		  line segment */
                  /* Modified for tr179901304 */
		  /**status = MSFAIL;**/
		  CommonPlane.objid= VerticalPlane.objid = NULL_OBJID;
		  status = om$send( msg = message VRCnrlSeg.VRget_planes( &msg,
								&CommonPlane, &VerticalPlane, NULL, NULL ),
						targetid = lineSegIds[i].objid,
						targetos = lineSegIds[i].osnum );
		  as$status();
		  /***if( status & MSFAIL ) continue;**/

		  __DBGpr_obj( " Common Plane Id ", CommonPlane );
		  __DBGpr_obj( " Vertical Plane Id ", VerticalPlane );

		  if(	(PlaneId.objid != CommonPlane.objid) && 
			(PlaneId.objid != VerticalPlane.objid) ) continue;

		  __DBGpr_obj( " Line SegId ", lineSegIds[i] );

		  // add the plane line segment to the affected Object List
		  status = om$send( msg = message VRDelPlane.VRAddObjectToList( 
								&msg, lineSegIds[i] ),
						targetid = my_id );

		  if( !msg & status & 1 )
		  {
			  UI_status( "Memory Allocation Error !!!" );
			  *sts = me->ret = NODYNMEM;
			  return status;
		  }

		  // Get the Common Correction for the line segment
		  status = VRGetCorrectionFromLineSeg( lineSegIds[i], &CorrectionId );

		  __DBGpr_obj( " Common Correction Id ", CorrectionId );

		  // add the plane line segment to the affected Object List
		  if( CorrectionId.objid != NULL_OBJID )
		  {
			  status = om$send( msg = message VRDelPlane.VRAddObjectToList( 
									&msg, CorrectionId ),
							targetid = my_id );
		  }

		  NbComponents = 2;
		  status = om$send ( msg = message NDnode.NDget_objects(
						ND_CHILDREN, CompIds, 2,
						NULL, 0, OM_K_MAXINT, &NbComponents ),
				  targetid = lineSegIds[i].objid,
				  targetos = lineSegIds[i].osnum );
		  as$status();
		  __DBGpr_int( " No. of Components ", NbComponents );

		  for( comp=0; comp<NbComponents; comp++ )
		  {
			 struct GRid	CorrectionIds[20]; // Max cpt allowed is 10

			 __DBGpr_obj( " Component Id ", CompIds[comp] );

			 // Add the component to affected object list
			 status = om$send( msg = message VRDelPlane.VRAddObjectToList(
							&msg, CompIds[comp] ),
						 targetid = my_id );

			 if( ! status & msg & 1 )
			 {
				 UI_status( "Memory Allocation Error !!!" );
				 *sts = me->ret = NODYNMEM;
				 return status;
			 }

			 NbCorrections = 0;
			 // Get the correction children for the component
			 status = om$send ( msg = message NDnode.NDget_objects(
						 ND_CHILDREN, CorrectionIds, 20,
						 NULL, 0, OM_K_MAXINT, &NbCorrections ),
				   targetid = CompIds[comp].objid,
				   targetos = CompIds[comp].osnum );
			 as$status();
			 __DBGpr_int( " No. of Corrections ", NbCorrections );

			 NbCorrections = 0;
			 for( corr=0; corr<NbCorrections; corr++ )
			 {
				__DBGpr_obj( " Correction Id ", CorrectionIds[corr] );

				/* Make sure correction belongs to the line segment which
				in context. If not we don't need to add this in the list. */

				status = om$send( msg = message VRDelPlane.VRAddObjectToList(
							   &msg, CorrectionIds[corr] ),
							targetid = my_id );

				if( ! status & msg & 1 )
				{
					UI_status( "Memory Allocation Error !!!" );
				    *sts = me->ret = NODYNMEM;
					return status;
				}
			 }
		  }
	  }
	  _FREE( lineSegIds );

	  for( i=0; i<me->nObjectCount; i=i+1 )
		 gr$display_object(object_id = &me->pAffectObjectList[i], mode = GRhd);

	  *sts = me->ret = VRALL_OK;
  }

  End
  return (OM_S_SUCCESS);
}

/* This method goes ahead deleting the plane having got the confirmation from
the User. */
method VRDeletePlane( long *sts )
{
  IGRint	cn_type;

  SetProc( Md VRPlaneDelete ); Begin

  *sts = me->ret = VRALL_OK;

  gr$display_object( 
			object_id = &me->event1.located_object[0].located_obj,
			mode = GRhe );

  __DBGpr_com( " Deleting Plane ..." );
  UI_status( "Deleting Plane ..." );

  cn_type = ND_COMP;
  nd$wait_batch(
		type       = GR_DELETED,
		l_object   = &me->event1.located_object[0].located_obj,
		l_obj_info = &cn_type,
		nb_obj     = 1 );

  nd$exec_batch();

  End
  return (OM_S_SUCCESS);
}

/* To check whether the input object is already in the list. If so, don't add 
it to the list, if not add it to the list. This function is mainly to prevent 
the duplicate objects enterring the list and would cause problems in 
highlighting the objects. */
method VRAddObjectToList( IGRlong *sts; struct GRid ObjectId )
{
   IGRboolean	bExistInList;
   IGRint		i;
   IGRlong		msg, status;

   SetProc( Md VRAddObjectToList ); Begin 

   *sts = MSSUCC;

   __DBGpr_int( " Object Count ", me->nObjectCount );

   if( NULL == me->pAffectObjectList )
   {
		__DBGpr_obj( " Adding the first object ", ObjectId );

		me->nObjectCount = 1;
		me->pAffectObjectList = _MALLOC( me->nObjectCount, struct GRid );
		_CheckMem( me->pAffectObjectList, (*sts), msg, wrapup );

		me->pAffectObjectList[0].objid = ObjectId.objid;
		me->pAffectObjectList[0].osnum = ObjectId.osnum;

		End
		return (*sts);
   }

   bExistInList = FALSE;
   __DBGpr_obj( " Input Object ", ObjectId );
   for( i=0; i<me->nObjectCount; i++ )
   {
	    __DBGpr_obj( " Object in List ", me->pAffectObjectList[i] );

		if( ( me->pAffectObjectList[i].objid == ObjectId.objid ) &&
			( me->pAffectObjectList[i].osnum == ObjectId.osnum ) )
		{
			bExistInList = TRUE;
			break;
		}
   }

   if ( !bExistInList )
   {
		me->nObjectCount = me->nObjectCount + 1;
		me->pAffectObjectList = _REALLOC( me->pAffectObjectList,
										  me->nObjectCount, struct GRid );

		_CheckMem( me->pAffectObjectList, (*sts), msg, wrapup );

	    if( NULL == me->pAffectObjectList ) goto wrapup;

		me->pAffectObjectList[me->nObjectCount-1].objid = ObjectId.objid;
		me->pAffectObjectList[me->nObjectCount-1].osnum = ObjectId.osnum;

		__DBGpr_obj( " Adding Object ...", ObjectId );
   }

   __DBGpr_int( " Object Count ", me->nObjectCount );
wrapup:
   if( (*sts) == MSSUCC ) { End; return OM_S_SUCCESS; }

   End
   return (*sts);
}

/* Release the memory befor leaving the command...good practice */
method VRReleaseMemory( long *sts )
{
   SetProc( Md VRReleaseMemory ); Begin

   _FREE( me->pAffectObjectList );

   End
   return OM_S_SUCCESS;
}

/* Reset the display back to the original, so that user wouldn't have to
refresh the screen */
method VRResetDisplay( long *sts )
{
   IGRint 	i;

   SetProc( Md VRResetDisplay ); Begin

   // Reset the display mode of affected network
   if( me->event1.located_object[0].located_obj.objid != NULL_OBJID )
   {
	   gr$display_object( 
				 object_id = &me->event1.located_object[0].located_obj,
				 mode = GRhe );
   }

   for(i=0; i<me->nObjectCount; i++ )
   {
	  // Reset the display mode of affected network
	  gr$display_object( 
				object_id = &me->pAffectObjectList[i], 
				mode = GRhe );
   }

   End
   return OM_S_SUCCESS;
}

end implementation VRDelPlane;
