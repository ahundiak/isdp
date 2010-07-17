/* $Id: VRskutilfunk.I,v 1.4 2002/04/10 20:44:59 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRskutilfunk.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRskutilfunk.I,v $
 *	Revision 1.4  2002/04/10 20:44:59  louis
 *	TR5649-Standardize tolerance
 *	
 *	Revision 1.3  2001/02/20 01:18:23  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 20:09:41  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/24  01:33:30  pinnacle
# Created: route/vrtools/VRskutilfunk.I by lawaddel for Service Pack
#
# Revision 1.2  1999/06/29  14:40:00  pinnacle
# Replaced: vrtools/VRskutilfunk.I for: TR 179900499 by aharihar for route
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
# Revision 1.7  1996/05/03  17:56:52  pinnacle
# Replaced: vrtools/VRskutilfunk.I for:  by hverstee for route240
#
# Revision 1.6  1996/04/04  19:06:04  pinnacle
# Replaced: vrtools/VRskutilfunk.I for:  by ashankar for route240
#
# Revision 1.5  1996/04/04  16:37:34  pinnacle
# Replaced: vrtools/VRskutilfunk.I for:  by ashankar for route240
#
# Revision 1.4  1996/01/18  23:07:34  pinnacle
# Replaced: vrtools/VRskutilfunk.I for:  by r240_int for route240
#
# Revision 1.3  1996/01/18  00:33:32  pinnacle
# Replaced: vrtools/VRskutilfunk.I for:  by r240_int for route240
#
 *
 * History:
 *	01/15/96   tlb		Add VX_FIproto.h, prototypes
 *	01/18/96   tlb		Copy values into 3rd arg to BSproj0
 *				Change to ANSII style:
 *				     VRChangeSegLength, 
 *				     VRSkReplaceTeeByElbow, VRGetPipeParams
 *				     VRGetCorrection, VRSkGetAttrFromCmp
 *				     VRModifyParameterBox, VRGetCorrectionType
 *				     VRSkGetCorVirtualSupport, VRSkLocatePipe
 *				     VRGetCptNum_GivenCptCoordm, VRUpdateGraph
 *				     VRGetCompInfo, VRGetCCompInfo
 *					VRDisplayHvacOrientTee
 *
 *	Jun 29 1999 	Anand	Fix for TR 179900499. A variable that stored
 *				magnitude of a vector was declared as an int
 *				(as opposed to a double value)! This lead to a
 *				loss in precision, and a failure of an if
 *				condition (length<BSBASISVAL).
 *				The fix was very difficult to arrive at, and
 *				the bug could have been easily avoided if care
 *				had been taken while declaring the variable.
 *      04/08/02        law     TR5649-standardize tolerance with VRGetTol
 *					
 *************************************************************************/
/*
 *	List of functions :
 *	
 *		- VRChangeSegLength
 *		- VRSplitSegment
 *		- VRSplit
 *		- VRMergeCorrection
 *		- VRDeleteCorrection
 *		- VRSkLocatePipe
 *		- VRSkGetPipeVirtualSupportInfo
 *		- VRSkReplaceTeeByElbow
 *		- VRModifyParameterBox
 *		- VRGetPipeParams
 *		- VRGetCorrection
 *		- VRUpdateGraph
 *		- VRUpdateSegLength
 *		- VRGetCorrectionType
 *		- VRSkGetElbowTopo
 *		- VRSkGetAttrFromCmp
 *		- VRGetCompInfo
 *		- VRGetCCompInfo
 *		- VRDisplayCorrection
 *		- VRSkGetCorVirtualSupport
 *		- VRGetCptNum_GivenCptCoord
 *		- VRget_axis
 *		- PointViewDependant
 *		- VRDisplayHvacOrientTee
 *
 */

class implementation Root;


#include "OMerrordef.h"
#include "msdef.h"
#include "godef.h"
#include "griodef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "dpdef.h"
#include "grdpbdef.h"
#include "VRdef.h" 
#include "VRcsdef.h" 
#include "VRcompdef.h" 
#include "VRdimdef.h" 
#include "VRattr_def.h"
#include "VRsketchdef.h"
#include "nddef.h"
#include "vrconsdef.h"
#include "VRparamdef.h"
#include "VRcordef.h"
#include "VRDbParamDef.h"
#include "VRutildef.h"

#include "OMlimits.h"
#include "OMminimum.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "exmacros.h"
#include "dpmacros.h"
#include "grio.h"
#include "grdpb.h"
#include "dpstruct.h"
#include "parametric.h"
#include "VRstructs.h" 
#include "VRpriv_attr.h"
#include "parametric.h"
#include "VRact_params.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "ndmacros.h"
#include "VRmacros.h"
#include "VRutilmacros.h"
#include "VRMath.h"
#include "VRprivmacros.h"
#include "AS_status.h"
#include "VDmem.h"

#include "vrtools_pto.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bsproj0.h"
#include "bspt_on_lne.h"
#include "maidmx.h"
#include "mainvmx.h"

#include "vrdbgmacros.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define AS_DEBUG

/*
#define MY_DEBUG
*/
from	GRgraphics	import	GRdisplay;
from	IGEgragad	import	DPinrot;
from	NDnode		import	NDdelete, NDdisplay, NDchg_state, NDget_objects,
				NDs_compute_node;
from	NDnodein	import	NDchange_connect;
from	VRplane		import	VRget_plane_state;
from	VRCnrlSeg	import	VRget_planes, VRChgSegState, VRsplit_segment, VRget_terminators,
				VRSegConstrainsType, VRSegMinLength;
from	VRGeneric	import	VRGetIndex, VRGetSysType, VRGetTopo, VRGetStatus,
				VRGetSupports, VRGetCptOnSup, VRGetSupOnCpt,
				VRGetCptGeom, VRGetCptProp, VRGetCorOnCpt, VRGetCompDesc,
				VRGetNextOnCpt, VRGetNumberOfCpts, VRGetOrigCoor;
from	VRCorrection	import	VRGetMyCmp, VRget_state, VRGetPipeCpts,
				VRSplit, VRMergeCorrection;
from	ACrg_collect	import	AClist_attribute, ACset_list_attribute;

extern	GRclassid	OPP_ACrg_collect_class_id; 


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRChangeSegLength( 	IGRshort			Factor,
			IGRshort			FittingType,
			struct 		GRid 		*seg_id,	
			struct 		GRmd_env 	*md_env)

/*.VRChangeSegLength */
{
  IGRint 			NbCmps, plane_index;
  IGRint			PlaneState;
  BSrc	 			bsretcode;
  IGRlong 			status;
  IGRlong 			retcode;
  IGRdouble	  		end_pt[6];
  IGRdouble 			my_vector[3];
  IGRdouble 			min_length, my_norm;
  IGRmatrix                     matrix;
  struct 	GRid		plane_to_move;


  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  /*| Get plane to move */

  if( Factor == BEGIN_OF_SEG ) plane_index = 0;
  else			       plane_index = 3;

  status = om$send ( msg = message VRCnrlSeg.VRget_planes
                                   ( &retcode, NULL, NULL,
                                     ( plane_index ) ? NULL : &plane_to_move,
                                     ( plane_index ) ? &plane_to_move : NULL
                                   ),
                     senderid = NULL_OBJID,
                     targetid = seg_id->objid, 
                     targetos = seg_id->osnum);
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"plan_to_move = %d\n", plane_to_move.objid */

  /* Is it a fixed plane */

  status = om$send( msg      = message VRplane.VRget_plane_state( &PlaneState ),
                    senderid = NULL_OBJID,
                    targetid = plane_to_move.objid,
                    targetos = plane_to_move.osnum );
  as$status( action = RET_STATUS );

  /*"Plane = %d State is %d\n", plane_to_move.objid, PlaneState */
    
  if( ! PlaneState )
  {
    /*| Is a free plane ==>  get segment end points to make my_vector */

    status = om$send( msg      = message VRCnrlSeg.VRget_terminators
                                 ( &retcode, &NbCmps, md_env, end_pt, NULL ),
                      senderid = NULL_OBJID,
                      targetid = seg_id->objid, 
                      targetos = seg_id->osnum);
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    my_vector[0] = end_pt[3] - end_pt[0];
    my_vector[1] = end_pt[4] - end_pt[1];
    my_vector[2] = end_pt[5] - end_pt[2];

    my_norm = BSlenvec( &bsretcode, my_vector );

    BSnorvec( &bsretcode, my_vector );

    /*"my vector %f %f %f\n", my_vector[0], my_vector[1], my_vector[2] */

    /* calculate the xform matrix */

    status = om$send( msg      = message VRCnrlSeg.VRSegMinLength
						( &retcode, VR_GET_LENGTH, &min_length, NULL ),
                      senderid = NULL_OBJID,
                      targetid = seg_id->objid, 
                      targetos = seg_id->osnum);
    as$status( action = RET_STATUS );

#ifdef MY_DEBUG
    printf ("my_norm = %f .. my_minlength = %f\n", my_norm, min_length);
#endif


    /* I am not fitting to fitting nor in overlap */
    if( FittingType == FALSE && my_norm >= min_length ) return OM_S_SUCCESS;

    MAidmx( &bsretcode, matrix );

    if( FittingType != VR_UNKNOWN )
    {
      matrix[3]  = - Factor * ( my_norm - min_length ) * my_vector[0];
      matrix[7]  = - Factor * ( my_norm - min_length ) * my_vector[1];
      matrix[11] = - Factor * ( my_norm - min_length ) * my_vector[2];
    }

    /*"trans = %f %f %f\n", matrix[3], matrix[7], matrix[11] */

    status = VRskxform( &retcode, matrix, &plane_to_move, md_env );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    if( FittingType == TRUE )
    {
      /*"Change constrain type to %d\n", VR_CNS_VAL */

      status = om$send( msg = message VRCnrlSeg.VRSegConstrainsType
                              		( VR_UPDATE_TYPE, VR_CNS_PARA | VR_CNS_VAL, NULL ),
                        senderid = NULL_OBJID,
                        targetid = seg_id->objid,
                        targetos = seg_id->osnum );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );
    }
  }

  return(OM_S_SUCCESS);
}

/*****************************************************************************/

VRMergeCorrections( p_retmsg, NumCor, p_CorsId, p_MdEnv )

IGRlong			*p_retmsg;
IGRint			NumCor;
struct	GRid		*p_CorsId;
struct	GRmd_env	*p_MdEnv;
{
  IGRboolean		FOUND;
  IGRint		i, j, k, NbTemp;
  IGRlong		retcode=MSSUCC, status=OM_S_SUCCESS;
  struct 	GRid	CommonTempId, MyTemp0[2], MyTemp1[2];   
 
  *p_retmsg = MSSUCC;

  if( !p_CorsId || NumCor < 2 ) return OM_E_INVARG;
  
  for( i=1; i<NumCor; i++ )
  {
	status = om$send( msg      = message NDnode.NDget_objects
					( ND_ROOT, MyTemp0, 2, NULL, 0, OM_K_MAXINT, &NbTemp ),
			  senderid = NULL_OBJID,
			  targetid = p_CorsId[0].objid,
			  targetos = p_CorsId[0].osnum );
	as$status( action = RET_STATUS );

	status = om$send( msg      = message NDnode.NDget_objects
					( ND_ROOT, MyTemp1, 2, NULL, 0, OM_K_MAXINT, &NbTemp ),
			  senderid = NULL_OBJID,
			  targetid = p_CorsId[i].objid,
			  targetos = p_CorsId[i].osnum );
	as$status( action = RET_STATUS );

	for( j=0, FOUND=FALSE; ( j<NbTemp && !FOUND ); j++ )
	{
		for( k=0; ( k<NbTemp && !FOUND ); k++ )
			if( MyTemp0[j].objid == MyTemp1[k].objid &&
					MyTemp0[j].osnum == MyTemp1[k].osnum )
			{
				FOUND = TRUE;
				CommonTempId = MyTemp0[j];
			}
	}
	
	if( !FOUND )
	{
		as$status( sts = OM_E_ABORT,
			   msg = "correction to merge don't have a common template" );
		return OM_E_INVARG;
	}

	/*"Common template = %d %d\n", 	CommonTempId.objid, CommonTempId.osnum */
	
  	status = om$send( msg      = message VRCorrection.VRMergeCorrection
                                       		( &retcode, &CommonTempId, p_MdEnv ),
                    	  senderid = NULL_OBJID,
                    	  targetid = p_CorsId[0].objid,
                    	  targetos = p_CorsId[0].osnum );
  	as$status( action = RET_STATUS );
  	as$status( sts = retcode, action = RET_STATUS );
  }

  return(OM_S_SUCCESS);
}

/*****************************************************************************/

VRDeleteCorrection( msg, SegId, OldCmpId, md_env )

IGRlong			*msg;
struct	GRid		*SegId;
struct	GRid		*OldCmpId;
struct	GRmd_env	*md_env;
{
  IGRlong		retcode, status;
  struct	GRid	CorId;

  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  status = VRGetCorrection( &retcode, SegId, OldCmpId, md_env, &CorId, ( struct GRid * ) NULL );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"Correction to delete = %d\n", CorId.objid */

  status = om$send( msg      = message NDnode.NDdelete( md_env ),
                    senderid = NULL_OBJID,
                    targetid = CorId.objid,
                    targetos = CorId.osnum );
  as$status( action = RET_STATUS );

  return(OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 VR fucntion LocatePipe
 
 CHANGE HISTORY:  momo 06-04-1990 : Design date


 DESCRIPTION  : Locate 

/*****************************************************************************/
VRSkLocatePipe( IGRlong			*msg, 		/* I/O */
		struct	GRevent		*LocatedEvent, 	/* I */
		IGRdouble 		*AcceptPoint,	/* I */
		struct	GRid		*PipeLocatedId, /* I */
		struct	GRmd_env	*md_env,	/* I */
		IGRdouble 		*ProjPoint	/* O */
		)
		
/*.VRLocatePipe */
{
  IGRboolean			GoodPoint;       /* if projpt is in pipe      */
  BSrc		 		bsretcode;       /* math. return code         */
  IGRlong	 		retcode;         /* return code               */
  IGRlong	 		status;          /* return code               */
  IGRdouble	 		min_distance;    /* used bu BSint2lns         */
  IGRdouble	 		borline[3];      /* used to calculate projpt  */
  IGRdouble	 		pt_result[6];    /* used by BSint2lns         */
  IGRdouble			cmp_pt[6];       /* Virtual Segment End pts   */
  IGRdouble			Uparams;         /* needed by BSpt_on_lne     */
  IGRpoint			pnt[2];		 /* used by BSproj0 */
  IGRmatrix			win_matrix;      /* locate window matrix      */
  int				i;
  struct 	IGRline 	line0;           /* used to calculate projpt  */
  struct 	IGRline 	line1;           /* used to calculate projpt  */
  struct 	IGRline 	*line[2];        /* used to calculate projpt  */

  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;
  
  status = VRSkGetPipeVirtualSupportInfo
           ( PipeLocatedId, NULL, md_env, NULL, NULL, cmp_pt );
  as$status( action = RET_STATUS );

  /* get the window matrix */
  status = om$send( msg        = message IGEgragad.DPinrot
                                                   ( &retcode, win_matrix ),
                    senderid = NULL_OBJID,
                    targetid = LocatedEvent->event.button.objid,
                    targetos = LocatedEvent->event.button.osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"win_direction= %f %f %f\n", win_matrix[8], win_matrix[9], win_matrix[10] */

  line0.point1 = &cmp_pt[0];
  line0.point2 = &cmp_pt[3];
  line1.point1 = AcceptPoint;
  line1.point2 = borline;
  line[0]      = &line0;
  line[1]      = &line1;


	  /*| lines defining the win_direction coordinate axis */

  borline[0] = AcceptPoint[0] + 50 * win_matrix[8];
  borline[1] = AcceptPoint[1] + 50 * win_matrix[9];
  borline[2] = AcceptPoint[2] + 50 * win_matrix[10];

  /*"AcceptPoint = %f %f %f\n",AcceptPoint[0],AcceptPoint[1],AcceptPoint[2] */
  /*"borline = %f %f %f\n", borline[0], borline[1], borline[2] */


	  /*| determination of the connect point */

  BSint2lns( line, pt_result, &min_distance, &bsretcode );

  if( bsretcode != BSPARALLEL )
  {
    ProjPoint[0] = pt_result[0];
    ProjPoint[1] = pt_result[1];
    ProjPoint[2] = pt_result[2];
  }
  else {
	for (i=0; i < 3; i++)
		pnt[0][i] = cmp_pt[i];
	for (i=0; i < 3; i++)
		pnt[1][i] = cmp_pt[3+i];
	BSproj0( &bsretcode, AcceptPoint, pnt, ProjPoint );
	}

  /*"ProjPoint = %f %f %f\n", ProjPoint[0], ProjPoint[1], ProjPoint[2] */

  BSpt_on_lne( &bsretcode, cmp_pt, &cmp_pt[3], ProjPoint, &Uparams,
               &GoodPoint
             );

  if( ! GoodPoint ) *msg = MSFAIL;

  return( OM_S_SUCCESS );
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 VR fucntion VRSkGetPipeVirtualSupportInfo
 
 CHANGE HISTORY:  momo 06-04-1990 : Design date


 DESCRIPTION  : 

/****************************************************************************/

VRSkGetPipeVirtualSupportInfo( PipeLocatedId, SplitPt, md_env, SegId, PipeDir,
                               EndPoint )
    

struct		GRid		*PipeLocatedId;
IGRdouble			*SplitPt;
struct		GRmd_env	*md_env;
struct 		GRid		*SegId;
IGRdouble			*PipeDir;
IGRdouble			*EndPoint;

/*.VRSkGetPipeVirtualSupportInfo */
{
  BSrc				bsretcode;       /* BS math return code       */
  IGRlong	 		status;          /* return code               */
  IGRlong	 		retcode;         /* return code               */
  IGRdouble			*p_EndPoint, EndPt[6];
  struct	GRid		CorId;           /* pipe correction owner     */


  if( !SegId && !PipeDir && !EndPoint ) return OM_E_INVARG;

  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  /*"PipelocatedId = %d %d\n", PipeLocatedId->objid, PipeLocatedId->osnum */

  if( PipeDir || EndPoint )
  {
    if( EndPoint ) p_EndPoint = EndPoint;
    else           p_EndPoint = EndPt;

    status = ASget_as_owner( PipeLocatedId, &CorId );
    as$status( action = RET_STATUS );

    /*"CorId = %d %d\n", CorId.objid, CorId.osnum */

    status = om$send( msg      = message VRCorrection.VRGetPipeCpts
                                 ( &retcode, md_env, p_EndPoint ),
                      senderid = NULL_OBJID,
                      targetid = CorId.objid, 
                      targetos = CorId.osnum );
    as$status( action = RET_STATUS );  

    if( PipeDir )
    {
      /*| Get Pipe Direction */

      BSmkvec( &bsretcode, PipeDir, &p_EndPoint[0], &p_EndPoint[3] );
      BSnorvec( &bsretcode, PipeDir );

      /*^printf("pipe dir = %f %f %f\n", PipeDir[0],PipeDir[1],PipeDir[2]); */ 
    }
  }

  if( SegId )
  {
    IGRshort		*NeighCpNum=NULL;
    IGRboolean		GoodPoint, SegFound;
    IGRint		i, NbCpts, NbPipeCpt;
    IGRdouble		*CptCoord=NULL, Uparams;
    IGRpoint		ProjPoint;
    IGRpoint		pnt[2];		 /* used by BSproj0 */
    struct	GRid	*NeighId=NULL;

    SegId->objid = NULL_OBJID;

    /*| Get Virtual Segment */

    /* get number of pipe cpts to malloc memory for GetTopo */
    status = om$send( msg      = message VRGeneric.VRGetNumberOfCpts
                                         ( &retcode, &NbPipeCpt, md_env ),
                      senderid = NULL_OBJID,
                      targetid = PipeLocatedId->objid, 
                      targetos = PipeLocatedId->osnum );
    as$status( action = RET_STATUS );  

    /*"Number of Cpts : %d\n" , NbPipeCpt */

    CptCoord   = ( IGRdouble * )   _MALLOC(3 * NbPipeCpt, IGRdouble );
    NeighCpNum = ( IGRshort  * )   _MALLOC(NbPipeCpt, IGRshort );
    NeighId    = ( struct GRid * ) _MALLOC( NbPipeCpt, struct GRid );

    if( !CptCoord || !NeighCpNum || !NeighId ) 
    {   
      status = OM_E_NODYNMEM;
      goto warup;
    }

    /* call GetTopo to get infomation about the pipe */
    status = om$send( msg      = message VRGeneric.VRGetTopo
                                 ( &retcode,NbPipeCpt,&NbCpts,NULL,CptCoord, 
                                   NeighId, NeighCpNum, md_env 
                                 ),
                      senderid = NULL_OBJID,
                      targetid = PipeLocatedId->objid, 
                      targetos = PipeLocatedId->osnum );
    as$status( action = GOTO_VALUE, value = warup );  

    /*^
        printf("VRsketch.VRskutilfunk\n");
        printf("========================================================\n");
	printf ("Number of Cpts : %d\n" , NbCpts );
	for (i= 0; i<NbCpts; i=i+1)
	{
  	  printf("Cpt #%d :\n",i);
	  printf("NeiId : <%d,%d> \n",NeighId[i].objid,NeighId[i].osnum);
        }
	for(i= 0; i<NbCpts; i++ )
          printf("CptCoord : %f %f %f\n",
                           CptCoord[3*i], CptCoord[3*i+1], CptCoord[3*i+2] );
        printf("========================================================\n");
        printf("VRsketch.VRskutilfunk\n");
    */

    for( i=0; i<NbCpts; i++ )
    {
      IGRshort	CmpStatus;

      /* See if the Neighbor is a correction component */

      status = om$send( msg      = message VRGeneric.VRGetStatus
                                                     ( &retcode, &CmpStatus ),
                        senderid = NULL_OBJID,
                        targetid = NeighId[i].objid,
                        targetos = NeighId[i].osnum );
      as$status( action = GOTO_VALUE, value = warup );  
  
      if( CmpStatus & VR_CORRECTION )
      {
        status = ASget_as_owner( &NeighId[i], &CorId );
        as$status( action = RET_STATUS );

        /*"CorId = %d %d\n", CorId.objid, CorId.osnum */

        status = om$send( msg      = message VRCorrection.VRGetMyCmp
                                     ( &retcode, &NeighId[i], &NeighId[i],
                                       md_env
                                     ),
                          senderid = NULL_OBJID,
                          targetid = CorId.objid,
                          targetos = CorId.osnum );
        as$status( action = GOTO_VALUE, value = warup );  
        as$status( sts = retcode, action = GOTO_VALUE, value = warup );  
      }
    }
        
    /* See between witch CptCoord is the SplitPoint */

    for( i=0, SegFound=FALSE; i<NbCpts-1 && !SegFound; i++ )
    {
	int	k;

	for (k=0; k < 3; k++)
		pnt[0][k] = CptCoord[3*i + k];
	for (k=0; k < 3; k++)
		pnt[1][k] = CptCoord[3*i + 3+k];
      BSproj0( &bsretcode, SplitPt, pnt, ProjPoint );

      /*"ProjPoint = %f %f %f\n", ProjPoint[0], ProjPoint[1], ProjPoint[2] */
      /*"CptCoord  = %f %f %f\n", CptCoord[3*i],CptCoord[3*i+1],CptCoord[3*i+2] */
      /*"CptCoord  = %f %f %f\n", CptCoord[3*(i+1)],CptCoord[3*(i+1)+1],CptCoord[3*(i+1)+2] */

      BSpt_on_lne( &bsretcode, &CptCoord[3*i], &CptCoord[3*(i+1)], ProjPoint,
                   &Uparams, &GoodPoint
                 );

      if( GoodPoint )
      {
        IGRint		j, NbSupport0, NbSupport1;
        struct	GRid	SupportId0[VR_MAX_CPTS], SupportId1[VR_MAX_CPTS];

        /* SplitPoint is between i and i+1 points */
        /* get all supports of i and i+1 pipes' neighbors to get ther common */

        status = om$send( msg      = message VRGeneric.VRGetSupports
                                     ( &retcode, VR_MAX_CPTS, SupportId0, 
                                       &NbSupport0 ),
                          senderid = NULL_OBJID,
                          targetid = NeighId[i].objid, 
                          targetos = NeighId[i].osnum );
        as$status( action = GOTO_VALUE, value = warup );  
        as$status( sts = retcode, action = GOTO_VALUE, value = warup );  

        status = om$send( msg      = message VRGeneric.VRGetSupports
                                     ( &retcode, VR_MAX_CPTS, SupportId1, 
                                       &NbSupport1 ),
                          senderid = NULL_OBJID,
                          targetid = NeighId[i+1].objid, 
                          targetos = NeighId[i+1].osnum );
        as$status( action = GOTO_VALUE, value = warup );  
        as$status( sts = retcode, action = GOTO_VALUE, value = warup );  

        for( i=0; i<NbSupport0 && !SegFound; i++ )
        {
          /*"SupportId0[%d] = %d\n", i, SupportId0[i].objid */

          for( j=0; j<NbSupport1; j++ ) 
          {
            /*"SupportId1[%d] = %d\n", j, SupportId1[j].objid */

            if( SupportId0[i].objid == SupportId1[j].objid )
            {
              *SegId = SupportId0[i];
              SegFound = TRUE;
              /*"MyVirtualSegId = %d\n", SegId->objid */
              break;
            }
          }
        }
       
        if( !SegFound ) as$status( sts = OM_W_ABORT,
                                   msg = "Virtual Segment Not Found" );
      }
    }

warup :

    if( CptCoord )   _FREE( CptCoord );
    if( NeighCpNum ) _FREE( NeighCpNum );
    if( NeighId )    _FREE( NeighId );
  }

  return OM_S_SUCCESS;

}


/*****************************************************************************/

VRSkReplaceTeeByElbow( IGRshort		Product,
			struct	GRid		*TeeId,
			struct	GRmd_env	*MdEnv,
			struct 	GRvg_construct	*CnstList)

/*.VRSkReplaceTeeByElbow */
{
  IGRshort			CmpIndex[2];
  IGRshort			ElbowOrientation[2];
  IGRint			NbSupports;
  IGRlong			retcode, status;
  IGRdouble			CmpAngle;
  struct	GRid		TeeSupportId[3];
  struct	GRid		ActParamId, BufParamId, UserParamId;


  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  CmpAngle = 0.0;

  /*"TeeId = %d\n", TeeId->objid */

  status = om$send( msg      = message VRGeneric.VRGetSupports
                               ( &retcode, 3, TeeSupportId, &NbSupports ),
                    senderid = NULL_OBJID,
                    targetid = TeeId->objid, 
                    targetos = TeeId->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  if( NbSupports != 3 )
  {
    as$status( sts = OM_E_ABORT, msg = "bad number of Tee supports" );
    return OM_E_ABORT;
  }

  /*^
      printf("VRsketch.VRSkReplaceTeeByElbow : Tee supp id = %d %d %d\n",
                                               TeeSupportId[0].objid,
                                               TeeSupportId[1].objid,
                                               TeeSupportId[2].objid  );
  */

  status = om$send( msg      = message VRGeneric.VRGetIndex
                               ( &retcode, &TeeSupportId[0], &CmpIndex[0] ),
                    senderid = NULL_OBJID,
                    targetid = TeeId->objid,
                    targetos = TeeId->osnum  );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  status = om$send( msg      = message VRGeneric.VRGetIndex
                               ( &retcode, &TeeSupportId[1], &CmpIndex[1] ),
                    senderid = NULL_OBJID,
                    targetid = TeeId->objid,
                    targetos = TeeId->osnum  );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"Tee index = %d %d\n", CmpIndex[0], CmpIndex[1] */

  if( CmpIndex[0] ) ElbowOrientation[0] =  1;
  else              ElbowOrientation[0] = -1;

  if( CmpIndex[1] ) ElbowOrientation[1] = -1;
  else              ElbowOrientation[1] =  1;

  status = VR$GetAttributes( 	p_retmsg	= &retcode,
				Product		= Product,
				p_ComponentId	= TeeId,
				p_SysParamId 	= &ActParamId,
				p_UserParamId	= &UserParamId,
				p_MdEnv		= MdEnv );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  BufParamId = ActParamId;

  status = VR$PlaceCmpByItemName( p_retmsg          = &retcode,
				PlacementTime     = VR_OLD_COMP,
				Product	  	  = Product,
				TopoParentsNum    = 2,          
				p_TopoParentsList = TeeSupportId,
				CmpItemName       = VR_ELBOW,
                	        p_CmpIndexOnTopo  = CmpIndex,
                	       	p_RelCmpOrient    = ElbowOrientation,
               			p_CmpAngle        = &CmpAngle,
               			p_OldCmpId        = TeeId,
               			p_MdEnv       	  = MdEnv,
               			p_ActParamId      = &ActParamId,
               			p_BufParamId      = &BufParamId,
               			p_UserParamId     = &UserParamId,
               			p_CmpCstList      = CnstList );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  return OM_S_SUCCESS;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRModifyParameterBox( 
	IGRlong			*msg,              /* return code            */
	IGRshort		product,           /* product type           */
	union	VRparam_attr	*Parameter,        /* New Parameters         */
	struct	GRid		*OldParameterBoxId,/* Old Parameter Box GRid */
	struct	GRid		*NewParameterBoxId /* New Parameter Box GRid */
	)

/*.VRModifyParameterBox */
{
  IGRint			NbAttrMod=0;
  IGRlong			status=OM_S_SUCCESS, retcode=MSSUCC;
  struct	ACrg_coll	NewListAttr[5];

  *msg    = MSSUCC;

  if( OldParameterBoxId->objid != NewParameterBoxId->objid ||
			OldParameterBoxId->osnum != NewParameterBoxId->osnum )
  {
	status =
  	VR$ModifyCollection( 	p_msg			= &retcode,
          			p_InputCollectionId	= OldParameterBoxId,
         			p_OutputCollectionId    = NewParameterBoxId );
  	as$status();
  	as$status( sts = retcode );
  }

if (Parameter)
{
  switch( product )
  {
    case VR_PIPING :

      NbAttrMod = 2;

      strcpy( NewListAttr[0].name, VR_N_GDIAMETER_DB );
      NewListAttr[0].desc.type          = AC_ATTRIB_DOUBLE;
      NewListAttr[0].desc.value.att_exp = Parameter->piping_attr.G_diameter;
      /*"GD = %f\n", NewListAttr[0].desc.value.att_exp */

      strcpy( NewListAttr[1].name, VR_N_RDIAMETER_DB );
      NewListAttr[1].desc.type          = AC_ATTRIB_DOUBLE;
      NewListAttr[1].desc.value.att_exp = Parameter->piping_attr.R_diameter;
      /*"RD = %f\n", NewListAttr[1].desc.value.att_exp */

      break;

    case VR_HVAC    :
    case VR_CABLING :

      NbAttrMod = 5;

      strcpy( NewListAttr[0].name, VR_N_SHAPE_IN );
      NewListAttr[0].desc.type          = AC_ATTRIB_DOUBLE;
      NewListAttr[0].desc.value.att_exp = Parameter->hvac_attr.shape;
      /*"shape = %f\n", NewListAttr[0].desc.value.att_exp */

      strcpy( NewListAttr[1].name, VR_N_WIDTH1_DB );
      NewListAttr[1].desc.type          = AC_ATTRIB_DOUBLE;
      NewListAttr[1].desc.value.att_exp = Parameter->hvac_attr.G_width;
      /*"GW = %f\n", NewListAttr[1].desc.value.att_exp */

      strcpy( NewListAttr[2].name, VR_N_DEPTH1_DB );
      NewListAttr[2].desc.type          = AC_ATTRIB_DOUBLE;
      NewListAttr[2].desc.value.att_exp = Parameter->hvac_attr.G_depth;
      /*"GD = %f\n", NewListAttr[2].desc.value.att_exp */

      strcpy( NewListAttr[3].name, VR_N_WIDTH2_DB );
      NewListAttr[3].desc.type          = AC_ATTRIB_DOUBLE;
      NewListAttr[3].desc.value.att_exp = Parameter->hvac_attr.R_width;
      /*"RW = %f\n", NewListAttr[3].desc.value.att_exp */

      strcpy( NewListAttr[4].name, VR_N_DEPTH2_DB );
      NewListAttr[4].desc.type          = AC_ATTRIB_DOUBLE;
      NewListAttr[4].desc.value.att_exp = Parameter->hvac_attr.R_depth;
      /*"RD = %f\n", NewListAttr[4].desc.value.att_exp */

      break;

    default : return OM_E_ABORT;

  }
	
  status =
  VR$ModifyCollection( 	p_msg			= &retcode,
         		Operation               = VR_UPDATE_COLL,
         		p_ParamsListToModify   	= NewListAttr,
         		NbParamsToModify       	= NbAttrMod,
         		p_OutputCollectionId    = NewParameterBoxId );
  as$status();
  as$status( sts = retcode );

} /* end if Parameter */

  return OM_S_SUCCESS;

} /* end VRModifyParameterBox */


/***************************************************************************/
VRGetPipeParams( IGRshort			Product,
		struct		GRid		*LocatedPipeId,
		struct		GRid		*ActParamId,
		struct		GRid		*UserParamId,
		struct		GRmd_env	*MdEnv)

/*.VRGetPipeParams */
{
  IGRint			NbAttr;
  IGRlong			status, retcode;
  struct	GRid		PipeActParamId;
  struct	GRid		PipeUserParamId;
  struct	ACrg_coll	ListAttr[VR_MAX_ATTR];
  union		VRparam_attr	PipeParam;
                           
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  status = VR$GetAttributes( 	p_retmsg	= &retcode,
				Product		= Product,
				CloneFlag	= TRUE,
				p_ComponentId	= LocatedPipeId,
				p_SysParamId 	= &PipeActParamId,
				p_UserParamId	= &PipeUserParamId,
               			p_MdEnv		= MdEnv );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  status = VR$GetDimensionAttributes( 	p_retmsg	  = &retcode,
					Product		  = Product,
					p_SysCollectionId = &PipeActParamId,
					p_DimAttributes   = &PipeParam,
					p_MdEnv		  = MdEnv );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );
  
  /*^ VRprint_user_attr( &PipeActParamId );  */
  /*^ VRprint_user_attr( &PipeUserParamId ); */

  /*| Create The Parameter Collection */

  if( UserParamId )
  {
    ex$get_cur_mod( osnum = &UserParamId->osnum );
    status = om$construct( classid = OPP_ACrg_collect_class_id,
      		           p_objid = &UserParamId->objid,
		           osnum   = UserParamId->osnum,
                           msg     = message NDnode.NDchg_state( ~0, ND_DEL_NO_CH ));
    as$status( action = RET_STATUS );

    status = om$send( msg      = message ACrg_collect.AClist_attribute
                                 ( &retcode, VR_MAX_ATTR, ListAttr, &NbAttr ),
                      senderid = NULL_OBJID,
                      targetid = PipeUserParamId.objid,
                      targetos = PipeUserParamId.osnum );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    status = om$send( msg      = message ACrg_collect.ACset_list_attribute
                                         ( &retcode, NbAttr, ListAttr ),
                      senderid = NULL_OBJID,
                      targetid = UserParamId->objid,
                      targetos = UserParamId->osnum );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    /*^ VRprint_user_attr( UserParamId ); */
  }

  if( ActParamId )
  {
    ActParamId->objid = NULL_OBJID;
    ActParamId->osnum = MdEnv->md_id.osnum;
    status = VRModifyParameterBox
             ( &retcode, Product, &PipeParam, &PipeActParamId, ActParamId);
    as$status( action = RET_STATUS );

    /*"created ACrg_collect %d\n", ActParamId->objid */

    /*^ VRprint_user_attr( ActParamId ); */
  }
  
  return OM_S_SUCCESS;

}

/***************************************************************************/

VRGetCorrection( IGRlong		*msg,
		struct	GRid		*SegId,
		struct	GRid		*CmpId,
		struct	GRmd_env	*md_env,
		struct	GRid		*CorId,
		struct	GRid		*MyCmpId)

/*.VRGetCorrection */
{
  IGRshort		CptIndex, NextIndex;
  		/* FIX FOR TR 179900499: DECLARE lenght AS DOUBLE!! */
  IGRdouble		lenght;
  IGRdouble		CptVector[3];
  IGRlong		retcode, status;
  BSrc	 		bsretcode;
  struct	GRid	NextId;

  SetProc( VRGetCorrection ); Begin

  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  __DBGpr_obj(" SegId",*SegId);
  __DBGpr_obj(" CmpId",*CmpId);
  
  status = om$send( msg      = message VRGeneric.VRGetCptOnSup
                               ( &retcode, SegId, &CptIndex, md_env ),
                    senderid = NULL_OBJID,
                    targetid = CmpId->objid,
                    targetos = CmpId->osnum );
  __DBGpr_int(" status",status);
  __DBGpr_int(" retcode",retcode);
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"CptIndex = %d \n",CptIndex*/
  __DBGpr_int(" CptIndex",CptIndex);

  /*| Test if cpt vector is null : olet don't have correction */
  
  status =
  om$send( msg      = message VRGeneric.VRGetCptGeom
			( &retcode, CptIndex, NULL, CptVector, NULL, md_env ),
	   senderid = NULL_OBJID,
	   targetid = CmpId->objid,
	   targetos = CmpId->osnum );
  as$status( action = RET_STATUS );

  __DBGpr_vec(" CptVector",CptVector);
  lenght = BSlenvec( &bsretcode, CptVector );
  __DBGpr_dbl(" lenght",lenght);

/* FIX FOR TR 179900499: Now that lenght is declared as double, the below if
 * condition will work as intended. A stupid bug that should have been avoided.
 * 				- Anand (29 June 1999) */

  if ( lenght < VRGetTol(VR_LENGTH_TOL) )
  {
	*msg = MSFAIL;
	CorId->objid = NULL_OBJID;
	CorId->osnum = md_env->md_id.osnum;	
	End
	return OM_S_SUCCESS;	
  }

  status = om$send( msg      = message VRGeneric.VRGetNextOnCpt
                               ( &retcode, CptIndex, &NextId, &NextIndex,
                                 0, NULL, NULL, NULL, md_env
                               ),
                    senderid = NULL_OBJID,
                    targetid = CmpId->objid,
                    targetos = CmpId->osnum );
  as$status( action = RET_STATUS );

  status = om$send( msg      = message VRGeneric.VRGetCorOnCpt
                                       ( &retcode, NextIndex, CorId, md_env  ),
                    senderid = NULL_OBJID,
                    targetid = NextId.objid,
                    targetos = NextId.osnum );
  as$status( action = RET_STATUS );

  /*"CorId found = %d\n", CorId->objid */
  __DBGpr_obj(" CorId ",*CorId);
  __DBGpr_obj(" NextId",NextId);

  if( MyCmpId ) *MyCmpId = NextId;

  End
  return OM_S_SUCCESS;

}


/***************************************************************************/

VRUpdateGraph( 	IGRlong			*p_retmsg,
		IGRshort		Product,
		IGRboolean		*UpdateSegLen,
		struct	GRid		*p_SegId,
		struct	GRid		*p_CmpId,
		IGRshort		CorType,
		IGRshort		CopyType,
		struct	GRmd_env	*p_MdEnv)
		
/*.VRUpdateGrpah */
{
  IGRlong			status=OM_S_SUCCESS, retcode=MSSUCC;
  struct	ACrg_coll	BranchParam;

  SetProc( Func_VRUpdateGraph ); Begin
  *p_retmsg    = MSSUCC;

  *UpdateSegLen = FALSE;
  strcpy( BranchParam.name, VR_N_COMP_TOPO_IN );

  status = om$send( msg      = message VRGeneric.VRGetCompDesc
                               ( &retcode, &BranchParam, p_MdEnv ),
                    senderid = NULL_OBJID,
                    targetid = p_CmpId->objid,
                    targetos = p_CmpId->osnum );
  as$status();
  
  /*"Branch Type = %d\n", ( IGRint ) BranchParam.desc.value.att_exp */

  if( ( Product == VR_PIPING && 
        ( IGRint ) BranchParam.desc.value.att_exp ==  VRP_V_3_WAYS_TOPO ) ||
      ( Product == VR_HVAC   && 
        ( IGRint ) BranchParam.desc.value.att_exp ==  VRH_V_3_WAYS_TOPO ) ||
      ( Product == VR_CABLING   && 
        ( IGRint ) BranchParam.desc.value.att_exp ==  VRR_V_3_WAYS_TOPO ) )
  {
    	/*| split correction */
    	status = VR$SplitCorrection( 	p_retmsg	= &retcode,
					CorType		= CorType,
					p_SegId		= p_SegId,
					p_CmpId		= p_CmpId,
					p_MdEnv		= p_MdEnv,
					NewCorType	= CopyType );
    	as$status();
    	as$status( sts = retcode );
  }
  else *UpdateSegLen = TRUE;

  End
  return OM_S_SUCCESS;
}


/***************************************************************************/

VRUpdateSegLength (IGRlong         *msg,
           struct  GRid            *Seg1Id,
           struct  GRid            *Seg2Id,
           struct  GRmd_env        *md_env)

/*.VRUpdateSegLength */
{
  IGRlong status=OM_S_SUCCESS, retcode=MSSUCC;

  *msg    = MSSUCC;

  if (Seg1Id != NULL)
  {
    status =
    om$send( msg      = message VRCnrlSeg.VRSegMinLength
		( &retcode, VR_INIT_LENGTH | VR_UPDATE_LENGTH, NULL, md_env ),
             senderid = NULL_OBJID,
             targetid = Seg1Id->objid, 
             targetos = Seg1Id->osnum );
    as$status( sts = retcode, action = RET_STATUS );
  }

  if (Seg2Id != NULL)
  {
    status =
    om$send( msg      = message VRCnrlSeg.VRSegMinLength
		( &retcode, VR_INIT_LENGTH | VR_UPDATE_LENGTH, NULL, md_env ),
             senderid = NULL_OBJID,
             targetid = Seg2Id->objid, 
             targetos = Seg2Id->osnum );
    as$status( sts = retcode, action = RET_STATUS );
  }

  return OM_S_SUCCESS;

}

/***************************************************************************/

VRGetCorrectionType( IGRlong				*msg,
			struct		GRid		*CmpId,
			struct		GRid		*SegId,
			IGRshort			*FittingType,
			struct		GRmd_env	*md_env)

/*.VRGetCorrectionType */
{
  IGRshort		CptIndex;
  IGRint		state;
  IGRlong		status=OM_S_SUCCESS, retcode=MSSUCC;
  struct	GRid	CorId;

  SetProc( Func_VRGetCorrectionType ); Begin
  *msg         = MSSUCC;
  *FittingType = FALSE;

  status = om$send( msg      = message VRGeneric.VRGetCptOnSup
                               ( &retcode, SegId, &CptIndex, md_env ),
                    senderid = NULL_OBJID,
                    targetid = CmpId->objid,
                    targetos = CmpId->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"CptIndex = %d\n", CptIndex */

  status = om$send( msg      = message VRGeneric.VRGetCorOnCpt
                                       ( &retcode, CptIndex, &CorId, md_env  ),
                    senderid = NULL_OBJID,
                    targetid = CmpId->objid,
                    targetos = CmpId->osnum );
  as$status( action = RET_STATUS );

  /*"CorId = %d\n", CorId.objid */

  if( CorId.objid != NULL_OBJID )
  {
  	status = om$send( msg      = message VRCorrection.VRget_state( &state ),
                    	  senderid = NULL_OBJID,
                    	  targetid = CorId.objid,
                    	  targetos = CorId.osnum );
  	as$status( action = RET_STATUS );

 	if( state & VR_FIT_TO_FIT ) *FittingType = TRUE;
  }

  /*"FittingType = %d\n", *FittingType */

  End
  return OM_S_SUCCESS;
}


/******************************************************************************/

VRSkGetElbowTopo( LocatedElbowId, ElbowDirP, ElbowDirS, ElbowOrig, MdEnv )

struct		GRid		*LocatedElbowId;
IGRdouble			*ElbowDirP;
IGRdouble			*ElbowDirS;
IGRdouble			*ElbowOrig;
struct		GRmd_env	*MdEnv;

/*.VRSkGetElbowTopo */
{
  IGRlong	status, retcode;

  if( ! LocatedElbowId ) return OM_E_ABORT;

  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  /*| call GetCptGeom to get Primary axis */
  if( ElbowDirP )
  {
    status = om$send( msg      = message VRGeneric.VRGetCptGeom
                                 ( &retcode, 0, NULL, ElbowDirP, NULL, MdEnv ),
                      senderid = NULL_OBJID,
                      targetid = LocatedElbowId->objid,
                      targetos = LocatedElbowId->osnum  );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    ElbowDirP[0] *= -1;
    ElbowDirP[1] *= -1;
    ElbowDirP[2] *= -1;
  }

  /*| call GetCptGeom to get Secondary axis */
  if( ElbowDirS )
  {
    status = om$send( msg      = message VRGeneric.VRGetCptGeom
                                ( &retcode, 1, NULL, ElbowDirS, NULL, MdEnv ),
                      senderid = NULL_OBJID,
                      targetid = LocatedElbowId->objid,
                      targetos = LocatedElbowId->osnum );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    ElbowDirS[0] *= -1;
    ElbowDirS[1] *= -1;
    ElbowDirS[2] *= -1;
  }

  /*| call GetOrigCoor to get component origine */
  if( ElbowOrig )
  {
    status = om$send( msg      = message VRGeneric.VRGetOrigCoor
                                         ( &retcode, ElbowOrig, MdEnv ),
                      senderid = NULL_OBJID,
                      targetid = LocatedElbowId->objid,
                      targetos = LocatedElbowId->osnum  );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );
  }

  return OM_S_SUCCESS;

}


/*****************************************************************************/

VRSkGetAttrFromCmp( 	IGRshort		product,
			struct	GRid		*cmp_param_id,
			struct	GRid		*buf_param_id,
			struct	GRid		*user_param_id,
			struct	GRid		*cmp_id,
			struct	GRid		*seg1_id,
			struct	GRid		*seg2_id,
			struct	GRmd_env	*md_env)

/*.VRSkGetAttrFromCmp */
{
  IGRshort			CptIndex;
  IGRlong			status, retcode;
  struct	GRid		CmpParamId;
  struct	VRcp_attr	ConProp;
  union		VRparam_attr	CmpParam;

  SetProc( Func_VRSkGetAttrFromCmp ); Begin
  status  = OM_S_SUCCESS;
  retcode = MSSUCC;

  status = VR$GetAttributes( 	p_retmsg	= &retcode,
				Product		= product,
				p_ComponentId	= cmp_id,
				p_SysParamId 	= &CmpParamId,
				p_UserParamId	= user_param_id,
        	         	p_MdEnv		= md_env );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  status = VR$GetDimensionAttributes( 	p_retmsg	  = &retcode,
					Product		  = product,
					p_SysCollectionId = &CmpParamId,
					p_DimAttributes   = &CmpParam,
        	         		p_MdEnv		  = md_env );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*^
      if( product == VR_PIPING )
      {
        printf("VRSkGetAttrFromCmp : CmpDiam = %f\n", 
                                             CmpParam.piping_attr.G_diameter );
      }
      else
      {
        printf("VRSkGetAttrFromCmp : CmpWidth = %f\n", 
                                                  CmpParam.hvac_attr.G_width );
        printf("VRSkGetAttrFromCmp : CmpDepth = %f\n", 
                                                  CmpParam.hvac_attr.G_depth );
      }
  */

  /* Construct the collection */
                
  cmp_param_id->objid = NULL_OBJID;
  cmp_param_id->osnum = md_env->md_id.osnum;

  status = om$send( msg      = message VRGeneric.VRGetCptOnSup
                               ( &retcode, seg1_id, &CptIndex, md_env ),
                    senderid = NULL_OBJID,
                    targetid = cmp_id->objid,
                    targetos = cmp_id->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  status = om$send( msg      = message VRGeneric.VRGetCptProp
                               ( &retcode, CptIndex, &ConProp, md_env ),
                    senderid = NULL_OBJID,
                    targetid = cmp_id->objid,
                    targetos = cmp_id->osnum );
  as$status( action = RET_STATUS );
   
  if( retcode == MSSUCC )
  {
    if( product == VR_PIPING )
    {
      	CmpParam.piping_attr.G_diameter = ConProp.width;
      	CmpParam.piping_attr.R_diameter = ConProp.width;

      	/*"diam = %f\n", CmpParam.piping_attr.G_diameter */
    }
    else
    {
      	CmpParam.hvac_attr.G_width = ConProp.width;
      	CmpParam.hvac_attr.G_depth = ConProp.depth;
      	CmpParam.hvac_attr.R_width = ConProp.width;
      	CmpParam.hvac_attr.R_depth = ConProp.depth;

	if(  CmpParam.hvac_attr.shape == 2 )
	{
		CmpParam.hvac_attr.G_depth = CmpParam.hvac_attr.G_width;
		CmpParam.hvac_attr.R_depth = CmpParam.hvac_attr.R_width;
	}

      	/*"Width= %f\n", CmpParam.hvac_attr.G_width */
      	/*"depth= %f\n", CmpParam.hvac_attr.G_depth */
    }    

  status = VRModifyParameterBox
           ( &retcode, product, &CmpParam, &CmpParamId, cmp_param_id);
  as$status( action = RET_STATUS );

  }/* end add cpt attributes */
  else
  {
   status = VRModifyParameterBox
            ( &retcode, product, (union VRparam_attr *)NULL, &CmpParamId, cmp_param_id);
   as$status( action = RET_STATUS );
  }

  /*"created ACrg_collect %d\n", cmp_param_id->objid */

  /*^ VRprint_user_attr( cmp_param_id ); */

  if( buf_param_id && seg2_id )
  {
    buf_param_id->objid = NULL_OBJID;
    buf_param_id->osnum = md_env->md_id.osnum;

    status = om$send( msg      = message VRGeneric.VRGetCptOnSup
                                 ( &retcode, seg2_id, &CptIndex, md_env ),
                      senderid = NULL_OBJID,
                      targetid = cmp_id->objid,
                      targetos = cmp_id->osnum );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    status = om$send( msg      = message VRGeneric.VRGetCptProp
                                 ( &retcode, CptIndex, &ConProp, md_env ),
                      senderid = NULL_OBJID,
                      targetid = cmp_id->objid,
                      targetos = cmp_id->osnum );
    as$status( action = RET_STATUS );

    if( retcode == MSSUCC )
    {
      if( product == VR_PIPING )
      {
        CmpParam.piping_attr.G_diameter = ConProp.width;
        CmpParam.piping_attr.R_diameter = ConProp.width;

        /*"diam = %f\n", CmpParam.piping_attr.G_diameter */
      }
      else
      {
        CmpParam.hvac_attr.G_width = ConProp.width;
        CmpParam.hvac_attr.G_depth = ConProp.depth;
        CmpParam.hvac_attr.R_width = ConProp.width;
        CmpParam.hvac_attr.R_depth = ConProp.depth;

	if(  CmpParam.hvac_attr.shape == 2 )
	{
		CmpParam.hvac_attr.G_depth = CmpParam.hvac_attr.G_width;
		CmpParam.hvac_attr.R_depth = CmpParam.hvac_attr.R_width;
	}

        /*"Width= %f\n", CmpParam.hvac_attr.G_width */
        /*"depth= %f\n", CmpParam.hvac_attr.G_depth */
      }

      status = VRModifyParameterBox
             (&retcode, product, &CmpParam, &CmpParamId, buf_param_id);
      as$status( action = RET_STATUS );
    }
    else
    {
      status = VRModifyParameterBox
             (&retcode, product, (union VRparam_attr *)NULL, &CmpParamId, buf_param_id);
      as$status( action = RET_STATUS );

    /*"created ACrg_collect %d\n", buf_param_id->objid */
    }
  }

  End
  return OM_S_SUCCESS;

}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 VR fucntion LocatePipe
 
 CHANGE HISTORY:  momo 06-04-1990 : Design date


 DESCRIPTION  : Locate 

/*****************************************************************************/

/*****************************************************************************/

VRGetCompInfo( 	IGRshort			Product,
		struct		GRid		*CmpId,
		IGRint				CmpType,
		IGRdouble			*GivenPt,
		struct		GRmd_env	*md_env,
		IGRshort			*CptNum,
		IGRdouble			*CptPtCoord,
		IGRdouble			*CptAxis,
		IGRdouble			*OrientAxis,
		struct		GRid		*ActParamId,
		struct		GRid		*NewActParamId)

/*.VRGetCompInfo */
{
  IGRlong status=OM_S_SUCCESS, retcode=MSSUCC;

  SetProc( Func_VRGetCompInfo ); Begin
  status = VRGetCCompInfo( Product, CmpId, GivenPt, md_env, CptNum, CptPtCoord, CptAxis,
                           OrientAxis, ActParamId, NewActParamId );
  as$status();

  if( CmpType == IS_COMP_TO_CONNECT && CptPtCoord )
  {
    status = om$send( msg      = message VRGeneric.VRGetOrigCoor(&retcode, CptPtCoord, md_env),
                      senderid = NULL_OBJID,
                      targetid = CmpId->objid,
                      targetos = CmpId->osnum ) ;
    as$status( action = RET_STATUS ) ;
    as$status( action = RET_STATUS, sts = retcode ) ;

    /*"ptCoord = %f %f %f\n", CptPtCoord[0], CptPtCoord[1], CptPtCoord[2] */
  }

  End
  return OM_S_SUCCESS; 

}

/*****************************************************************************/

VRGetCCompInfo(	IGRshort			Product,
		struct		GRid		*CmpId,
		IGRdouble			*GivenPt,
		struct		GRmd_env	*md_env,
		IGRshort			*CptNum,
		IGRdouble			*CptPtCoord,
		IGRdouble			*CptAxis,
		IGRdouble			*OrientAxis,
		struct		GRid		*ActParamId,
		struct		GRid		*NewActParamId)

/*.VRGetCCompInfo */
{
  IGRshort			*p_CptNum, Cpt;
  IGRlong			status, retcode ;
  union		VRparam_attr  	Param;

  SetProc( Func_VRGetCCompInfo ); Begin
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;
  
  /*"pt = %f %f %f\n", GivenPt[0], GivenPt[1], GivenPt[2] */

  if( ! (CptNum || CptPtCoord || CptAxis || NewActParamId) )
  {
     End
     return OM_E_INVARG;
  }

  if( CptNum ) p_CptNum = CptNum;
  else         p_CptNum = &Cpt;

  status = VRGetCptNum_GivenCptCoord( &retcode, CmpId, GivenPt, p_CptNum, md_env );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"CptNum = %d\n", *p_CptNum */

  if( CptPtCoord || CptAxis )
  {
    status = om$send( msg      = message VRGeneric.VRGetCptGeom
                                 ( &retcode, *p_CptNum, CptPtCoord, CptAxis,
                                   OrientAxis, md_env ),
                      senderid = NULL_OBJID,
                      targetid = CmpId->objid,
                      targetos = CmpId->osnum ) ;
    as$status( action = RET_STATUS ) ;
    as$status( action = RET_STATUS, sts = retcode ) ;

/*^
    if( CptPtCoord )
    {
	printf ("ptCoord = %f %f %f\n",
		CptPtCoord[0], CptPtCoord[1], CptPtCoord[2]);
    }

    if( CptAxis )
    {
      printf ("ptAxis  = %f %f %f\n", CptAxis[0], CptAxis[1], CptAxis[2]);
    }

    if( OrientAxis )
    {
      printf("OrientAxis = %f %f %f\n",OrientAxis[0],OrientAxis[1],OrientAxis[2]);
    }

*/

  }

  if( NewActParamId )
  {
    struct	VRcp_attr	CptProp;

    ex$get_cur_mod( osnum = &NewActParamId->osnum );
    status = om$construct( classid = OPP_ACrg_collect_class_id,
  		           p_objid = &NewActParamId->objid,
		           osnum   = NewActParamId->osnum,
                           msg     = message NDnode.NDchg_state( ~0, ND_DEL_NO_CH ));
    as$status( action = RET_STATUS ); 

    /*"created ACrg_collect %d\n", NewActParamId->objid */

    status = om$send( msg      = message VRGeneric.VRGetCptProp
                                 ( &retcode, *p_CptNum, &CptProp, md_env ),
                      senderid = NULL_OBJID,
                      targetid = CmpId->objid,
                      targetos = CmpId->osnum ) ;
    as$status( action = RET_STATUS ) ;

    if ( retcode == MSSUCC ) /* Bruno 03-dec-92 */
    {
      switch( Product )
      {
      case VR_PIPING :
        Param.piping_attr.G_diameter = CptProp.width;
        Param.piping_attr.R_diameter = Param.piping_attr.G_diameter;
        break;

      case VR_HVAC :
      case VR_CABLING :
        Param.hvac_attr.shape   = CptProp.section_mask & VR_SHAPE;
        Param.hvac_attr.G_width = CptProp.width;

 	if( Param.hvac_attr.shape == VR_CIRC ) Param.hvac_attr.G_depth = CptProp.width;
        else                                   Param.hvac_attr.G_depth = CptProp.depth;

        Param.hvac_attr.R_width = Param.hvac_attr.G_width;
        Param.hvac_attr.R_depth = Param.hvac_attr.G_depth;
        break;

      default : as$status( sts = OM_E_ABORT, msg = "Invalid Product type" );
                End
                return OM_E_INVARG;
      }

      status = VRModifyParameterBox
             ( &retcode, Product, &Param, ActParamId, NewActParamId );
      as$status( action = RET_STATUS );
    }/* end take cpt properties */
    else
    {
      status = VRModifyParameterBox
             ( &retcode, Product, (union VRparam_attr *)NULL, ActParamId, NewActParamId);
      as$status( action = RET_STATUS );

    }
    /*^ VRprint_user_attr( NewActParamId ); */
  }

  End
  return OM_S_SUCCESS; 
}


/***************************************************************************/

VRDisplayCorrection( SegId, CmpId, md_env )

struct	GRid		*SegId;
struct	GRid		*CmpId;
struct	GRmd_env	*md_env;

/*.VRDisplayCorrection */
{
  IGRlong			status, retcode;
  struct	GRid		CorId;
  enum		GRdpmode	mode; 

  status = VRGetCorrection( &retcode, SegId, CmpId, md_env, &CorId, (struct GRid *)NULL );
  as$status();
  as$status( sts = retcode );

  mode = GRbd;
  status = om$send( msg      = message GRgraphics.GRdisplay
                               ( &retcode, &md_env->md_env.matrix_type,
                                 md_env->md_env.matrix, &mode, &md_env->md_id),
                    senderid = NULL_OBJID,
                    targetid = CorId.objid, 
                    targetos = CorId.osnum );
  as$status();
  as$status( sts = retcode );

  return OM_S_SUCCESS;

}

/****************************************************************************/

VRSkGetCorVirtualSupport( struct	GRid		*LocatedId,
			IGRdouble			*SplitPt,
			struct		GRmd_env	*md_env,
			struct 		GRid		*SegId)

{
  IGRshort		cmp_systype, CmpStatus;
  IGRlong		retcode, status;
  IGRboolean		GoodPoint;
  BSrc		 	bsretcode;
  IGRint	 	i, NbSupport;
  IGRdouble		ProjPoint[3], EndPt[6]; 
  IGRpoint		pnt[2];		 /* used by BSproj0 */
  IGRdouble		Uparams;  
  struct	GRid	MyCmpId, CorId, SupportId[VR_MAX_CPTS];


  SegId->objid = NULL_OBJID;

  status = om$send( msg      = message VRGeneric.VRGetStatus
                                                 ( &retcode, &CmpStatus ),
                    senderid = NULL_OBJID,
                    targetid = LocatedId->objid,
                    targetos = LocatedId->osnum );
  as$status( action = RET_STATUS );

  if( CmpStatus & VR_CORRECTION )
  {
    /*| Is a correction component */

    status = ASget_as_owner( LocatedId, &CorId );
    as$status( action = RET_STATUS );
  }
  else return OM_E_INVARG;

  /*"CorId = %d\n", CorId.objid */

  status = om$send( msg      = message VRGeneric.VRGetSysType
                                       ( &retcode, &cmp_systype ),
                    senderid = NULL_OBJID,
                    targetid = LocatedId->objid,
                    targetos = LocatedId->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"systype = %d\n", cmp_systype */

  if( cmp_systype & VR_PIPE )
  {
    status = VRSkGetPipeVirtualSupportInfo
             ( LocatedId, SplitPt, md_env, SegId, ( IGRdouble * ) NULL, ( IGRdouble * ) NULL );
    as$status( action = RET_STATUS );
  }
  else
  {
    status = om$send( msg      = message VRCorrection.VRGetMyCmp
                                 ( &retcode, LocatedId, &MyCmpId, md_env ),
                      senderid = NULL_OBJID,
                      targetid = CorId.objid,
                      targetos = CorId.osnum );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    /*"MyVmpId = %d\n", MyCmpId.objid */

    status = om$send( msg      = message VRGeneric.VRGetSupports
                                 ( &retcode, VR_MAX_CPTS, SupportId, 
                                   &NbSupport ),
                      senderid = NULL_OBJID,
                      targetid = MyCmpId.objid, 
                      targetos = MyCmpId.osnum );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    for( i=0; i<NbSupport; i++ )
    {
      int	k;

      status = om$send( msg      = message VRCnrlSeg.VRget_terminators
                                   ( &retcode, 0, md_env, EndPt, NULL ),
                        senderid = NULL_OBJID,
                        targetid = SupportId[i].objid, 
                        targetos = SupportId[i].osnum );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );

      for (k=0; k < 3; k++)
		pnt[0][k] = EndPt[k];
      for (k=0; k < 3; k++)
		pnt[1][k] = EndPt[3+k];
      BSproj0( &bsretcode, SplitPt, pnt, ProjPoint );

      /*"ProjPoint = %f %f %f\n", ProjPoint[0], ProjPoint[1], ProjPoint[2] */
      /*"EndPt0    = %f %f %f\n", EndPt[0], EndPt[1], EndPt[2] */
      /*"EndPt1    = %f %f %f\n", EndPt[3], EndPt[4], EndPt[5] */

      BSpt_on_lne( &bsretcode,EndPt,&EndPt[3],ProjPoint,&Uparams,&GoodPoint );

      if( GoodPoint )
      {
        *SegId = SupportId[i];
        break;
      }
    }
  }

  return OM_S_SUCCESS;
}

/*****************************************************************************/

VRGetCptNum_GivenCptCoord( IGRlong				*p_retmsg,
			struct		GRid		*p_CompId,
			IGRdouble			*p_GivenPt,
			IGRshort			*p_CptNum,
			struct		GRmd_env	*p_MdEnv)

/*.VRGetCptNum_GivenCptCoord */
{
  IGRint		i, NbCpt;
  BSrc			bsretcode;
  IGRlong		retcode=MSSUCC, status=OM_S_SUCCESS;
  IGRdouble		DistanceMin = -1.,Distance,CptCoord[3*VR_MAX_CPTS],TmpVect[3];
  struct	GRid	SegId;				
				
  SetProc( Func_VRGetCptNum_GivenCptCoord ); Begin  
  *p_retmsg = MSSUCC;
  
  if( !p_CptNum || !p_GivenPt )
  {
     End
     return OM_E_INVARG;
  }

  /*"Given pt = %f %f %f\n", p_GivenPt[0], p_GivenPt[1], p_GivenPt[2] */

  status = om$send( msg      = message VRGeneric.VRGetTopo
                               ( &retcode, VR_MAX_CPTS, &NbCpt, NULL, CptCoord, NULL, NULL, 
				 p_MdEnv
			       ),
                    senderid = NULL_OBJID,
                    targetid = p_CompId->objid,
                    targetos = p_CompId->osnum ) ;
  as$status( action = RET_STATUS );
  as$status( action = RET_STATUS, sts = retcode ) ;

  /*^  
      printf("========== Root.VRGetCptNum_GivenCptCoord =========== \n");
      printf("\t\t Nb of connect point : %d\n", NbCpt ) ;
      for( i=0; i<NbCpt; i++)
      	printf("\t\t Point[%d]= %f %f %f\n",i,CptCoord[3*i],CptCoord[3*i+1],CptCoord[3*i+2] );
      printf("========== Root.VRGetCptNum_GivenCptCoord =========== \n");
  */

  for( i=0; i<NbCpt; i++ )
  {
    status = om$send( msg      = message VRGeneric.VRGetSupOnCpt
							( &retcode, i, &SegId, p_MdEnv ),
                      senderid = NULL_OBJID,
 		      targetid = p_CompId->objid,
                      targetos = p_CompId->osnum ) ;
    as$status( action = RET_STATUS );

    if( SegId.objid == NULL_OBJID )
    {
    	BSmkvec( &bsretcode, TmpVect, p_GivenPt, &CptCoord[3*i] ) ;
   	Distance = BSlenvec( &bsretcode, TmpVect ) ;

    	/*"Distance : %f\n", Distance*/

    	if( Distance < DistanceMin || DistanceMin < 0 )
    	{
      		DistanceMin = Distance ;
      		*p_CptNum   = i ;
    	}
    	/*"Distance min : %f\n", DistanceMin*/
    }
  }

  /*"CptNum = %d\n", *p_CptNum */

  End
  return OM_S_SUCCESS; 
}

/*************************************************************************/

IGRint VRget_axis( cur_pt, origin, normal, y_axis )

IGRdouble	  *cur_pt;
IGRdouble	  *origin;
IGRdouble	  *normal;
IGRdouble	  *y_axis;

/*.VRget_axis */
{
  IGRlong 	rc;
  IGRdouble	scalar;
  IGRdouble	v[3];

  v[0] = cur_pt[0] - origin[0];
  v[1] = cur_pt[1] - origin[1];
  v[2] = cur_pt[2] - origin[2];

  scalar = BSdotp( &rc, v, normal );

  y_axis[0] = v[0] - scalar * normal[0];
  y_axis[1] = v[1] - scalar * normal[1];
  y_axis[2] = v[2] - scalar * normal[2];

  BSnorvec( &rc, y_axis );

  /*^ printf("y_axis = %f %f %f\n", y_axis[0], y_axis[1], y_axis[2] ); */
	       
  return(OM_S_SUCCESS);

}

/*************************************************************************/

IGRint PointViewDependant ( dPoint, dMatrix,  dNormal, dOrig )

IGRdouble *dPoint;
IGRdouble *dMatrix;
IGRdouble *dNormal;
IGRdouble *dOrig;

/*.PointViewDependant */
{
  BSrc rc;
  IGRdouble dXlnpl [3];
  IGRdouble dInvMat [16];
  IGRdouble dVisee [3];
  IGRshort Quatre = 4;

  MAinvmx (&rc,&Quatre,dMatrix,dInvMat);
  /*^
  	printf ("dPoint in entry = (%lf,%lf,%lf)\n",
						dPoint [0],
						dPoint [1],
						dPoint [2]);
  */

  dVisee [0] = dInvMat [2] + dPoint [0];
  dVisee [1] = dInvMat [6] + dPoint [1];
  dVisee [2] = dInvMat [10] + dPoint [2];

  /*^
	printf ("dVisee computed = (%lf,%lf,%lf)\n",
						dVisee [0],
						dVisee [1],
						dVisee [2]);
  */

  BSxlnpl (&rc, dNormal, dOrig, dPoint, dVisee, dXlnpl);

  if( rc == BSSUCC )
  {
	    /*| Non degenerated case -> point already projected on plane */
	    dPoint [0] = dXlnpl [0];
	    dPoint [1] = dXlnpl [1];
	    dPoint [2] = dXlnpl [2];
  }

  /*^
	printf ("dPoint computed = (%lf,%lf,%lf)\n",
						dPoint [0],
						dPoint [1],
						dPoint [2]);
  */

  return OM_S_SUCCESS;

}

/****************************************************************************/

VRDisplayHvacOrientTee( IGRdouble		*dOrigin,
			IGRdouble		*dXaxis,
			IGRdouble		*dYaxis,
			struct	IGRdisplay	*display,
			struct	GRmd_env	*pMdEnv)

/*.VRDisplayHvacOrientTee */
{
  IGRdouble               	pt_buffer[12];
  struct	IGRpolyline     polyline [2];	
  struct	IGRdisplay      DDisplay; 
  struct	DPele_header	MyHeader [2];
  IGRint			i;
  IGRlong			msg;

  DDisplay                 = *display;
  DDisplay.weight          = 3;
  polyline [0].num_points = 2;
  polyline [0].points     = pt_buffer;
  polyline [1].num_points = 2;
  polyline [1].points     = &pt_buffer [6];

  for( i=0; i<3; i++ )
  {
    	pt_buffer [i] = dOrigin [i];
    	pt_buffer [i+3] = dXaxis [i];
    	pt_buffer [i+6] = dOrigin [i];
    	pt_buffer [i+9] = dYaxis [i];
  }

  dp$build_dis_buffer(	buffer      = &MyHeader [0],
		  	type        = IGRPY,
		  	display_att = &DDisplay,
		  	geometry    = ( struct IGRpolyline *) &polyline [0] );

  dp$build_dis_buffer(	buffer      = &MyHeader [1],
		  	type        = IGRPY,
		  	display_att = &DDisplay,
		  	geometry    = ( struct IGRpolyline *) &polyline [1] );

  dp$display (	msg = &msg,
		osnum = pMdEnv->md_id.osnum,
                num_elem = 2,
		mode = GRhd,
		buffer = MyHeader);

  return OM_S_SUCCESS;
}

end implementation Root;
