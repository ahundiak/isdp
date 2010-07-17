/* $Id: VRPlCor.I,v 1.2 2001/03/08 23:43:00 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRPlCor.I
 *
 * Description:
 *     	This file contains the macro to rebuild a segment adding all 
 *	correction components.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRPlCor.I,v $
 *	Revision 1.2  2001/03/08 23:43:00  louis
 *	tr4725-dbg prints only
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:12  cvs
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
# Revision 1.2  1996/01/18  00:31:50  pinnacle
# Replaced: vrtools/VRPlCor.I for:  by r240_int for route240
#
 *
 * History:
 *	01/10/92   momo		creation
 *	01/17/96   tlb		Add prototypes, 
 *				Change VRPlaceCorrection to ANSII style
 *      03/08/01   law          dbg prints
 *
 *************************************************************************/

class implementation Root;


#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "msdef.h"
#include "VRdef.h"
#include "VRcordef.h"
#include "VRcsdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "AS_status.h"
#include "vrtools_pto.h"
#include "vrdbgmacros.h"

#define AS_DEBUG 1

from	GRgraphics	import	GRdisplay;
from  	NDnode		import	NDplace, NDdisplay, NDs_compute_node;
from 	VRGeneric	import	VRGetCptOnSup, VRGetCorOnCpt, VRGetNextOnCpt;
from	VRCorrection	import	VRNotifyDelete, VRChgCorInstance, VRUpdateConnection;
from    VRCnrlSeg	import	VRget_terminators, VRGetSegProduct;

extern	struct GRid	NULL_GRID;
extern 	GRclassid 	OPP_VRPCorentity_class_id;
extern 	GRclassid 	OPP_VRHCorentity_class_id;
extern 	GRclassid 	OPP_VRRCorentity_class_id;


VRPlaceCorrection( 	GRclassid		  	ClassId,
			IGRshort			CorType,
			struct		GRid		*ParentId,
			struct		GRid		*p_CorEntityId,
			struct 		GRmd_env 	*p_MdEnv
			)
{
  IGRlong 		  	status=OM_S_SUCCESS;
  struct 	GRas	  	assoc_list;

  /*"Correction parents = %d %d\n", ParentId[0].objid, ParentId[1].objid */
  SetProc( Fn VRPlaceCorrection ); Begin 

  if( CorType == VR_UNKNOWN ) CorType = FALSE;

  assoc_list.as_attr         = ( IGRchar * ) &CorType;
  assoc_list.num_parents     = 2;
  assoc_list.parents         = ParentId;

  p_CorEntityId->osnum = p_MdEnv->md_id.osnum;
  status = om$construct( classid = ClassId,
        	         p_objid = &p_CorEntityId->objid, 
                	 osnum   = p_CorEntityId->osnum   );
  as$status( action = RET_STATUS );

  /*"CorEntity = %d %d\n", p_CorEntityId->objid, p_CorEntityId->osnum */

  status = om$send( msg      = message NDnode.NDplace( &assoc_list, p_MdEnv, NULL ),
		    senderid = NULL_OBJID,
                    targetid = p_CorEntityId->objid,
	            targetos = p_CorEntityId->osnum  );
  as$status( action = RET_STATUS );

  status = om$send( msg      = message NDnode.NDdisplay( 0, GRbd, p_MdEnv ),
		    senderid = NULL_OBJID,
                    targetid = p_CorEntityId->objid,
	            targetos = p_CorEntityId->osnum );
  as$status();

  End
  return OM_S_SUCCESS;
}

/****************************************************************************/

VRComputeCorrection( p_retmsg, ComputeType, CorType, p_SegmentId,
                     p_MdEnv, p_CorId
		   )

IGRlong 			*p_retmsg;
IGRshort			ComputeType;
IGRshort			CorType;
struct 		GRid		*p_SegmentId;
struct 		GRmd_env 	*p_MdEnv;
struct		GRid		*p_CorId;

/*. VRComputeCorrection */
{
  IGRshort			Product;	/* correction product		   */
  IGRshort			CptIndex[2];    /* index of segment components     */
  IGRshort			NextCptIndex[2];/* index of segment components     */
  IGRshort			FatherIndex;    /* index of my components cpt      */
  IGRint			NbChildren;
  IGRint			cn_type;
  IGRlong 		  	status=OM_S_SUCCESS;
  IGRlong 		  	retcode=MSSUCC; /* return code                     */
  IGRboolean		  	FirstNext = TRUE;
  GRclassid		  	ClassId=0;
  struct	GRid	  	CorToUpdateId;  /* Correction to update GRid       */
  struct	GRid	  	FirstCmpCorId;  /* first cmp Correction GRid       */
  struct	GRid	  	SecondCmpCorId; /* second cmp Correction GRid      */
  struct	GRid	  	ChildrenId[2];  /* Correction parents' GRid        */
  struct	GRid	  	NextParentId[2];/* Correction parents' GRid        */
  struct	GRid	  	*p_CorEntityId;

  *p_retmsg = MSSUCC;

  /* init p_CorEntityId pointer */

  if( p_CorId ) p_CorEntityId = p_CorId;
  else		p_CorEntityId = &CorToUpdateId;

  if( p_SegmentId )
  {
  	/*| Get my Child */
 
    	status = om$send( msg      = message VRCnrlSeg.VRget_terminators
                                 	( &retcode, &NbChildren, p_MdEnv, NULL, ChildrenId ),
			  senderid = NULL_OBJID,
                      	  targetid = p_SegmentId->objid,
		     	  targetos = p_SegmentId->osnum );
    	as$status( action = RET_STATUS );
    	as$status( sts = retcode, action = RET_STATUS );

	if( ComputeType == VR_PLACE )
	{
		status = om$send( msg      = message VRCnrlSeg.VRGetSegProduct( &Product ),
				  senderid = NULL_OBJID,
				  targetid = p_SegmentId->objid,
				  targetos = p_SegmentId->osnum );
		as$status();

	  	switch( Product )
  		{
			case VR_PIPING:
				ClassId = OPP_VRPCorentity_class_id;
	          		break;
      			case VR_HVAC:
				ClassId = OPP_VRHCorentity_class_id;
               			break;
	      		case VR_CABLING:
				ClassId = OPP_VRRCorentity_class_id;
               			break;
			default:	return OM_E_INVARG;
	  	}

		status = VRPlaceCorrection( ClassId, CorType, ChildrenId, p_CorEntityId, p_MdEnv );
		as$status( action = RET_STATUS );

		return OM_S_SUCCESS;
	}

  	status = om$send( msg      = message VRGeneric.VRGetCptOnSup
                                       ( &retcode, p_SegmentId, &CptIndex[0], p_MdEnv ),
			  senderid = NULL_OBJID,
                    	  targetid = ChildrenId[0].objid,
                    	  targetos = ChildrenId[0].osnum );
  	as$status( action = RET_STATUS );
  	as$status( sts = retcode, action = RET_STATUS );

  	/*"My Parent %d Cpt Index is %d\n", ChildrenId[0].objid, CptIndex[0] */

  	status = om$send( msg      = message VRGeneric.VRGetNextOnCpt
                               		( &retcode, CptIndex[0], &NextParentId[0],
                                 	  &NextCptIndex[0], 0, NULL, NULL, NULL, p_MdEnv ),
			  senderid = NULL_OBJID,
                    	  targetid = ChildrenId[0].objid,
                    	  targetos = ChildrenId[0].osnum );

  	if( status & 1 )
  	{
    		/*"NextId = %d .. NextCpt = %d\n", NextParentId[0].objid, NextCptIndex[0] */

    		status = om$send( msg      = message VRGeneric.VRGetCorOnCpt
                                 		( &retcode, NextCptIndex[0], &FirstCmpCorId,
                                  		  p_MdEnv ),
			  	  senderid = NULL_OBJID,
                      		  targetid = NextParentId[0].objid,
                      		  targetos = NextParentId[0].osnum );
    		as$status( action = RET_STATUS );
  	}
  	else
  	{
    		NextParentId[0]     = ChildrenId[1];
    		FirstCmpCorId.objid = NULL_OBJID;
    		FirstNext = FALSE;
  	}

  	/*"FirstCmpCorId = %d\n", FirstCmpCorId.objid */
  	/*"NextId = %d\n", NextParentId[0].objid */

  	status = om$send( msg      = message VRGeneric.VRGetCptOnSup
                               		( &retcode, p_SegmentId, &CptIndex[1], p_MdEnv  ),
			  senderid = NULL_OBJID,
                    	  targetid = ChildrenId[1].objid,
                    	  targetos = ChildrenId[1].osnum );
  	as$status( action = RET_STATUS );
  	as$status( sts = retcode, action = RET_STATUS );

  	/*"My Parent %d Cpt Index is %d\n", ChildrenId[1].objid, CptIndex[1] */

  	status = om$send( msg      = message VRGeneric.VRGetNextOnCpt
                                       ( &retcode, CptIndex[1], &NextParentId[1], 
                                         &NextCptIndex[1], 0, NULL, NULL, NULL, p_MdEnv ),
			  senderid = NULL_OBJID,
                    	  targetid = ChildrenId[1].objid,
                    	  targetos = ChildrenId[1].osnum );

  	if( status & 1 )
  	{
    		/*"NextId = %d .. NextCpt = %d\n", NextParentId[1].objid, NextCptIndex[1] */

    		status = om$send( msg      = message VRGeneric.VRGetCorOnCpt
                                 		( &retcode, NextCptIndex[1], &SecondCmpCorId,
                                   		  p_MdEnv ),
		      senderid = NULL_OBJID,
                      targetid = NextParentId[1].objid,
                      targetos = NextParentId[1].osnum );
    		as$status( action = RET_STATUS );
 	}
  	else if( ! FirstNext ) return OM_S_SUCCESS;
       	     else
             	{
             		SecondCmpCorId.objid = NULL_OBJID;
         		NextParentId[1]      = ChildrenId[0];
       		}

  	/*"SecondCmpCorId = %d\n", SecondCmpCorId.objid */
  	/*"NextId = %d\n", NextParentId[1].objid */

  	if( FirstCmpCorId.objid == NULL_OBJID && SecondCmpCorId.objid == NULL_OBJID )
  	{
  		struct	GRid	TmpId;

   		/*| PLACE CORRECTION IN THE COMPUTECORENTITY */

	    	TmpId = NextParentId[0];
    		NextParentId[0] = NextParentId[1];
	    	NextParentId[1] = TmpId;

    		/*"Correction parents = %d %d\n", NextParentId[0].objid, NextParentId[1].objid */

		status = om$send( msg      = message VRCnrlSeg.VRGetSegProduct( &Product ),
				  senderid = NULL_OBJID,
				  targetid = p_SegmentId->objid,
				  targetos = p_SegmentId->osnum );
		as$status();

	  	switch( Product )
  		{
			case VR_PIPING:
				ClassId = OPP_VRPCorentity_class_id;
	          		break;
      			case VR_HVAC:
				ClassId = OPP_VRHCorentity_class_id;
               			break;
	      		case VR_CABLING:
				ClassId = OPP_VRRCorentity_class_id;
               			break;
	  	}

		status = VRPlaceCorrection( ClassId, CorType, NextParentId, p_CorEntityId, p_MdEnv );
		as$status( action = RET_STATUS );

	    	return(OM_S_SUCCESS);
	  }

	  FatherIndex    = 0;
	  *p_CorEntityId = FirstCmpCorId;

	  if( FirstCmpCorId.objid != NULL_OBJID && SecondCmpCorId.objid != NULL_OBJID )
	  {
	   	if( FirstCmpCorId.objid != SecondCmpCorId.objid )
    		{
			status =
			VRDeleteObjects( 1, &SecondCmpCorId, p_MdEnv );
			as$status();

      			/*"Correction to notify for the delete = %d\n", SecondCmpCorId.objid  */

	      		status = om$send( msg      = message VRCorrection.VRNotifyDelete(
					&retcode, 0, NULL ),
					senderid = NULL_OBJID,
                	       		targetid = SecondCmpCorId.objid,
                       			targetos = SecondCmpCorId.osnum  );
	      		as$status( action = RET_STATUS );
    		}
  	}
	else
	{
  		if( FirstCmpCorId.objid == NULL_OBJID )
	    	{
      			FatherIndex    = 1;
      			*p_CorEntityId = SecondCmpCorId;
	    	}
  	}

	/*"Correction to update = %d %d\n", p_CorEntityId->objid, p_CorEntityId->osnum  */

  	if( CorType != VR_UNKNOWN )
	{	  
  		status = om$send( msg      = message VRCorrection.VRChgCorInstance
                	               		( &retcode, &CorType, NULL, NULL ),
				  senderid = NULL_OBJID,
	                   	  targetid = p_CorEntityId->objid,
        	              	  targetos = p_CorEntityId->osnum  );
	   	as$status( action = RET_STATUS );
    		as$status( sts = retcode, action = RET_STATUS );
	}

	status = om$send( msg      = message VRCorrection.VRUpdateConnection
                                       ( &retcode, &NextParentId[FatherIndex],
                                         NextCptIndex[FatherIndex], p_MdEnv
                                       ),
		    	  senderid = NULL_OBJID,
                    	  targetid = p_CorEntityId->objid,
	                  targetos = p_CorEntityId->osnum  );
	as$status( action = RET_STATUS );
  	as$status( sts = retcode, action = RET_STATUS );
  
  	switch( ComputeType )
  	{
		case VR_IMMEDIATE_COMPUTE:
			status = om$send( msg      = message NDnode.NDs_compute_node
							( &retcode, 0, p_MdEnv ),
				  	  senderid = NULL_OBJID,
                          		  targetid = p_CorEntityId->objid, 
	                      	  	  targetos = p_CorEntityId->osnum);
			as$status();
    			as$status( sts = retcode );
			break;

		case VR_DEFFER_COMPUTE:
    			cn_type = ND_COMP;
			nd$wait_batch( 	type       = GR_GEOM_POSTED, 
        	           		l_object   = p_CorEntityId,
                	   		l_obj_info = &cn_type,
                   			nb_obj     = 1 );
			break;

		default: break;
  	}
  }

  return OM_S_SUCCESS;

}

end implementation Root;
