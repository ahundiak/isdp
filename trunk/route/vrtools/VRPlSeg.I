/* $Id: VRPlSeg.I,v 1.2 2001/02/20 01:18:00 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRPlSeg.I
 *
 * Description:
 *     	This file contains the macro to rebuild a segment adding all 
 *			correction components.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRPlSeg.I,v $
 *	Revision 1.2  2001/02/20 01:18:00  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:12  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/27  13:27:04  pinnacle
# Replaced: vrtools/VRPlSeg.I for:  by kddinov for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/18  00:31:56  pinnacle
# Replaced: vrtools/VRPlSeg.I for:  by r240_int for route240
#
 *
 * History:
 *	01/10/92   momo	creation
 *	01/17/96   tlb	Add prototypes
 *	4-98	   KDD	for Alwin. 
 *
 *************************************************************************/

class implementation Root;

/*
#define AS_DEBUG 			1
*/

#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "dp.h"
#include "msdef.h"
#include "VRclsymbf.h"
#include "csmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "VRclsymb.h"
#include "bstypes.h"
#include "bserr.h"
#include "VRcsdef.h"
#include "nddef.h"
#include "bsparameters.h"
#include "VRsketchdef.h"
#include "VRpriv_attr.h"
#include "VRprivmacros.h"
#include "ndmacros.h"
#include "parametric.h"
#include "AS_status.h"
#include "vrtools_pto.h"
#include "maidmx.h"
#include "vrdbgmacros.h"


from	GRgraphics	import	GRconstruct, GRdisplay;
from	NDnode		import	NDdisplay;
from	NDmacro		import	ACreturn_foot;
from	VRCnrlSeg	import	VRget_planes, VRget_terminators;
from	VRNozzle	import	VRGetRefId;

/******************************************************************************/

VRPlaceSegment(	p_retmsg, Product, GivenAction, 
		p_SegmentPt0, p_SegmentPt1, p_PrevSegId,
		p_CmpToConnectId, CmpCptNum, p_CptCoord, 
		p_CmpMdEnv, p_ModuleInfo, p_NewSegmentId )

IGRlong		*p_retmsg;		/* return message code		*/
IGRshort	Product;		/* segment product		*/
IGRshort	GivenAction;		/* given action to share planes */
IGRdouble	*p_SegmentPt0;		/* segment to create start point*/
IGRdouble	*p_SegmentPt1;		/* segment to create end point  */
struct	GRid	*p_PrevSegId;		/* previous segment if any	*/
struct	GRid	*p_CmpToConnectId;	/* component to connect to	*/
IGRshort	CmpCptNum;		/* component connection cpt	*/
IGRdouble	*p_CptCoord;		/* component cpt coord.		*/
struct GRmd_env	*p_CmpMdEnv;		/* module info			*/
struct GRmd_env	*p_ModuleInfo;		/* module info			*/
struct	GRid	*p_NewSegmentId;	/* new segment 			*/

/*.VRPlaceSegment */
{
  IGRshort			Flag=VR_PLANES_NO_TOPO, SegIndex;
  short unsigned		SegProperties;
  IGRboolean			ConsFlag=FALSE;
  BSrc				bsretcode;
  IGRint			i, mode_batch;
  IGRlong			retcode=MSSUCC, status=OM_S_SUCCESS;
  enum		GRdpmode	mode;
  IGRdouble			EndSegPt[6], SegmentPts[6];
  IGRmatrix			matrix;
  struct	GRid		SegId, *p_SegId, 
				DepPlanesId[VR_NB_DEP_PLANES], PlanesId[3],
 			       SegmentPlanes[VR_NB_SEG_PLANES+VR_NB_DEP_PLANES],
			       SymbId;
  struct	GRas		AssocList;
  struct	GRsymbology	SegSymbology;
  struct	GRvg_construct	CnstList;


  SetProc( Fn VRPlaceSegment ); Begin 

  *p_retmsg = MSSUCC;

  SegProperties = GRIS_NEW | GRIS_DISPLAYABLE;

  SymbId.osnum = p_ModuleInfo->md_id.osnum;
  VR$symbology( return_code = &retcode,
                symb_id     = &SymbId,
                symb        = &SegSymbology );
  as$status( sts = retcode );

  /*"Symbology:level  = %d\n", SegSymbology.level               */
  /*"Symbology:color  = %d\n", SegSymbology.display_attr.color  */
  /*"Symbology:wieght = %d\n", SegSymbology.display_attr.weight */
  /*"Symbology:style  = %d\n", SegSymbology.display_attr.style  */

  status = VRGetConstructionList
         	( &retcode, p_ModuleInfo, &SegProperties, &SegSymbology, NULL,
         	  ( IGRchar * ) &AssocList, &CnstList
          	);
  as$status();                       		

  for( i=0; i<3; i++ )
  {
	PlanesId[i].objid 	= NULL_OBJID;
	DepPlanesId[i].objid 	= NULL_OBJID;
	SegmentPts[i+3]   	= p_SegmentPt1[i];

	if( p_SegmentPt0 ) SegmentPts[i] = p_SegmentPt0[i];
  }

  if( p_PrevSegId )
  {
	if( !p_SegmentPt0 )
	{
		status = om$send( msg      = message VRCnrlSeg.VRget_terminators
						( &retcode, NULL, p_ModuleInfo, EndSegPt, NULL ),
			  	  senderid = NULL_OBJID,
			  	  targetid = p_PrevSegId->objid,
			  	  targetos = p_PrevSegId->osnum );
		as$status( action = RET_STATUS );
		as$status( sts = retcode, action = RET_STATUS );
		
		SegmentPts[0] = EndSegPt[3];
		SegmentPts[1] = EndSegPt[4];
		SegmentPts[2] = EndSegPt[5];
	}
		
	/*"SegPt0 = %f %f %f\n", SegmentPts[0], SegmentPts[1], SegmentPts[2] */
	/*"SegPt1 = %f %f %f\n", SegmentPts[3], SegmentPts[4], SegmentPts[5] */

	status = VRCompPosOnTopo( 1, p_PrevSegId, &SegmentPts[0], &SegIndex, p_ModuleInfo );
	as$status( action = RET_STATUS );

	/*"SegIndex = %d\n", SegIndex */

	/*| get planes */
	status= om$send( msg      = message VRCnrlSeg.VRget_planes
				    	( &retcode, &PlanesId[1], &PlanesId[2],
			              	  SegIndex ? NULL : &PlanesId[0],
				      	  SegIndex ? &PlanesId[0] : NULL ),
			 senderid = NULL_OBJID,
			 targetid = p_PrevSegId->objid,
			 targetos = p_PrevSegId->osnum );
	as$status ( action = RET_STATUS );
		
	if( GivenAction & IS_AN_EXTEND )
	{
		if( GivenAction & VR_SHARE_PLANES ) ConsFlag = TRUE;
		else
		{
			/*| calculate the xform matrix */

     			MAidmx( &bsretcode, matrix );

      			matrix[3]  = SegmentPts[3] - SegmentPts[0];
      			matrix[7]  = SegmentPts[4] - SegmentPts[1];
      			matrix[11] = SegmentPts[5] - SegmentPts[2];

      			status = VRskxform( &retcode, matrix, &PlanesId[0], p_ModuleInfo );
      			as$status();

  			nd$mod_batch( 	request    = ND_GET,
                			p_ret_mode = &mode_batch );
			if( mode_batch != ND_DEFER ) nd$exec_batch();

  			mode = GRbd;
  			status = om$send( msg      = message GRgraphics.GRdisplay
			       				( &retcode, &p_ModuleInfo->md_env.matrix_type,
				 			  p_ModuleInfo->md_env.matrix, &mode, &p_ModuleInfo->md_id ),
					  senderid = NULL_OBJID,
		    			  targetid = p_PrevSegId->objid,
		    			  targetos = p_PrevSegId->osnum );
  			as$status();
  
			__DBGpr_com( " Share planes and exit " );
			End
			return OM_S_SUCCESS;
		}
	}
	else ConsFlag = FALSE;
  }
  else if( p_CmpToConnectId )
  	{
		__DBGpr_obj( " Component Id ", *p_CmpToConnectId );
		__DBGpr_com( " Calling the VRGetCompPlanes " );
		p_CmpMdEnv->md_id.osnum = p_CmpToConnectId->osnum;
		status = VRGetCompPlanes
 			 ( &retcode, p_CmpToConnectId, CmpCptNum, p_CptCoord, p_CmpMdEnv, 
			   p_ModuleInfo, PlanesId, DepPlanesId );
		as$status();
		as$status( sts = retcode );
	}
	else
	{
		PlanesId[0].osnum = p_ModuleInfo->md_id.osnum;
           	cs$get_active_info(	msg   = &retcode,
                               		osnum = PlanesId[0].osnum,
                               		objid = &PlanesId[0].objid );
                /*"cs id = %d %d\n", PlanesId[0].objid, PlanesId[0].osnum */
		Flag = VR_NO_TOPO;
  	}

  /*"given planes 0 = %d %d\n", PlanesId[0].objid, PlanesId[0].osnum */   
  /*"given planes 1 = %d %d\n", PlanesId[1].objid, PlanesId[0].osnum */   
  /*"given planes 2 = %d %d\n", PlanesId[2].objid, PlanesId[0].osnum */   

  __DBGpr_com( " Calling VR$DefineSegPlanes " );
  status = VR$DefineSegPlanes(	p_retmsg	= &retcode,
  				TopoFlag	= Flag,
  				p_InPutPlanes	= PlanesId,
  				p_SegmentPt0	= &SegmentPts[0],
  				p_SegmentPt1	= &SegmentPts[3],
  				SharePlanes	= ConsFlag,
  				InPutPlanesType	= FALSE,
  				p_MdEnv		= p_ModuleInfo,
  				p_OutPutPlanes	= SegmentPlanes );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );
    				
  /*"New segment planes 0 = %d %d\n", SegmentPlanes[0].objid,  SegmentPlanes[0].osnum */   
  /*"New segment planes 1 = %d %d\n", SegmentPlanes[1].objid,  SegmentPlanes[1].osnum */   
  /*"New segment planes 2 = %d %d\n", SegmentPlanes[2].objid,  SegmentPlanes[2].osnum */   
  /*"New segment planes 3 = %d %d\n", SegmentPlanes[3].objid,  SegmentPlanes[3].osnum */   

  __DBGpr_obj( " Dep Plane[0] Id ", DepPlanesId[0] );
  if( DepPlanesId[0].objid != NULL_OBJID )
  {
	SegmentPlanes[4] = DepPlanesId[0];
	SegmentPlanes[5] = DepPlanesId[1];
	SegmentPlanes[6] = DepPlanesId[2];

	/*"New segment planes 0 = %d %d\n", SegmentPlanes[4].objid,  SegmentPlanes[4].osnum */   
  	/*"New segment planes 1 = %d %d\n", SegmentPlanes[5].objid,  SegmentPlanes[5].osnum */   
  	/*"New segment planes 2 = %d %d\n", SegmentPlanes[6].objid,  SegmentPlanes[6].osnum */   

	AssocList.num_parents = VR_NB_DEP_PLANES;
  }
  else AssocList.num_parents = 0;

  __DBGpr_int( " Nb of Dependant Planes ", AssocList.num_parents );

  				/* CREATE SEGMENT */

  AssocList.as_attr 		= (char *) &Product;
  AssocList.num_parents    	+= VR_NB_SEG_PLANES;
  AssocList.parents 		= SegmentPlanes;
  AssocList.context 		= NULL;
  AssocList.go_objid.objid 	= NULL_OBJID;

  if( p_NewSegmentId )  p_SegId = p_NewSegmentId;
  else			p_SegId = &SegId;

  p_SegId->osnum = p_ModuleInfo->md_id.osnum;
  __DBGpr_com( " Construct the Line Segment " );
  status = om$construct(	classname = "VRCnrlSeg", 
		          	p_objid   = &p_SegId->objid, 
			  	osnum     = p_SegId->osnum,
                          	msg       = message GRgraphics.GRconstruct( &CnstList ) );
  as$status( action = RET_STATUS );

  /*"CS id %d %d\n", p_SegId->objid, p_SegId->osnum */

  status = om$send( msg      = message NDnode.NDdisplay( 0, GRbd, p_ModuleInfo ),
		    senderid = NULL_OBJID,
                    targetid = p_SegId->objid, 
                    targetos = p_SegId->osnum);
  as$status();

  End
  return OM_S_SUCCESS;
}

end implementation Root;
