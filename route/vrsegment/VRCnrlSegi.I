
/* $Id: VRCnrlSegi.I,v 1.7 2002/04/10 20:30:01 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrsegment / VRCnrlSegi.I
 *
 * Description:
 *     	This file contains the method to rebuild a segment
 *	adding all correction components.
 *
 *     	METHOD NAMES: 	VRmerge_segments
 *			VRGetNeighbors
 *			VRget_planes
 *			VRGetComponents
 *			VRget_terminators
 *			VRGetTopo
 *			VRnotify_merge
 *			VRsplit_segment
 *			VRChgSegState
 *			VRSegMinLength
 *			VRGetMyCmpLength
 *			VRGetMyCorLength
 *			VRSegConstrainsType
 *			VRGetNeighbors
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCnrlSegi.I,v $
 *	Revision 1.7  2002/04/10 20:30:01  louis
 *	tr5649-standardize tolerance
 *	
 *	Revision 1.6  2002/02/04 17:29:04  anand
 *	Louis' fix for JTS TR 5888 commented out too many lines.
 *	
 *	Revision 1.5  2002/01/29 16:21:21  louis
 *	*** empty log message ***
 *	
 *	Revision 1.4  2001/11/08 03:44:30  anand
 *	JTS TR MP 5557
 *	
 *	Revision 1.3  2001/09/24 18:52:40  anand
 *	JTS TR 5468.
 *	
 *	Revision 1.2  2001/03/08 23:34:01  louis
 *	tr4725-dbg prints only
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:08  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/05/07  17:17:02  pinnacle
# Replaced: vrsegment/VRCnrlSegi.I for:  by apazhani for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/04/23  15:54:30  pinnacle
# Replaced: vrsegment/VRCnrlSegi.I for:  by hverstee for route240
#
# Revision 1.5  1996/04/23  14:32:56  pinnacle
# Replaced: vrsegment/VRCnrlSegi.I for:  by ashankar for route240
#
# Revision 1.4  1996/04/17  16:05:42  pinnacle
# Replaced: vrsegment/VRCnrlSegi.I for:  by ashankar for route240
#
# Revision 1.3  1996/01/17  23:26:04  pinnacle
# Replaced: vrsegment/VRCnrlSegi.I for:  by r240_int for route240
#
 *
 * History:
 *	11/19/90   momo	creation
 *	06/09/95   Lori Fix for TR# 179525964 Error in 
 *                                computation of Control Segment
 *                                component length when component
 *                                connect point lies outside of 
 *                                control segment boundaries. Fix in
 *                                VRGetMyCmpLength
 *
 *	01/17/96   tlb	Add prototypes
 *
 *      04/17/96   ashankar       Fix for split network.
 *
 *      04/23/96   hv   Revert to version of 02.04.00.18 build,
 *                      Rethink split network use
 *
 *      05/07/97   Alwin    Added some initializing code in VRsplit_segment
 *                          method.
 *      03/08/01   law          dbg prints
 *	09/24/01   Anand	Commented out call to VRGetMyCorLength per
 *				Ed Heinhold's request against JTS TR 5468
 *	11/07/01   Anand	JTS TR MP5557 - When segment with nozzle(s)
 *				at one or both ends is split, ensure
 *				corresponding dependent planes go to the right
 *				segment(s).
 *      01/29/02   law          Fix for TR5468 caused regression in placement
 *                              of auto-flanges in FTF connections. Restored
 *                              call to VRGetMyCorLength.
 *      04/08/02   law          TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/

class implementation VRCnrlSeg;


#include "grdpbdef.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "bsdotp.h"
#include "vrconsdef.h"
#include "grdpbmacros.h"
#include "AS_status.h"
#include "VDchn.h"
#include "VRdef.h"
#include "VRsketchdef.h"
#include "VRprivmacros.h"
#include "VRSttopo.h"
#include "VRMcplace.h"
#include "VRMath.h"
#include "vrtools_pto.h"
#include "vrsegmen_pto.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bslenvec.h"
#include "vrdbgmacros.h"

#define AS_DEBUG 1

from	VRGeneric	import	VRGetIndex,
				VRGetSupports,
				VRGetInstance,
				VRGetCptOnSup,
				VRGetCptGeom,
				VRGetCorOnCpt,
				VRGetOrigCoor,
				VRChgSupport,
				VRGetNextOnCpt,
				VRGetOrientationDef,
				VRDisconnect;
from	VRCorrection	import	VRGetCorLenByCmp,
				VRNotifyDelete,
				VRChgCorInstance,
				VRUpdateConnection;
from	ACncpx		import	ACget_rep;
from	VRNozzle	import	VRGetRefId;

extern	struct GRid	NULL_GRID;
extern 	GRclassid 	OPP_VRPCorentity_class_id;
extern 	GRclassid 	OPP_VRHCorentity_class_id;
extern 	GRclassid 	OPP_VRRCorentity_class_id;

/******************************************************************************/

method VRmerge_segments( IGRlong		*msg;
                         struct	GRid 		*segment_to_merge;
                         struct GRmd_env 	*md_env;
                         struct GRid		*PrevConnectedCmpId;
                         struct	GRid		*cmp_to_connect )
{
  IGRint			nb_support;     /* used by NDget_objects      */
  IGRshort			MyPrevCmpIndex;	/* previous cmp index         */
  IGRlong 			status;         /* return code                */
  IGRlong 			retcode;        /* return code                */
  IGRdouble			MyNewCmpOrientation;
                                                /* my new cmp orientation     */
  struct	GRid		my_grid;        /* my GRid                    */
  struct	GRid		my_plane;       /* my plane to change         */
  struct	GRid		new_plane;      /* my new plane               */
  struct	GRid		seg_plane[4];   /* used by NDget_objects      */
  struct	GRid		NotSeg_plane[4];/* used by NDget_objects      */
  struct	GRid		delseg_cmp[2];  /* used by NDget_objects      */

SetProc( Md. VRCnrlSeg-VRmerge_segments ); Begin
  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  __DBGpr_obj("my_grid",my_grid);
  __DBGpr_obj("Segment to merge",*segment_to_merge);
  __DBGpr_obj("PrevConnectedCmpId",*PrevConnectedCmpId);
  /* update my parent list ==> it depond of my direction and the notified
  /* segment one
  /**/

  status = om$send( msg     = message NDnode.NDget_objects
                              ( ND_ROOT, seg_plane, 4, NULL, 0, OM_K_MAXINT, &nb_support ),
                    targetid = my_id );
  as$status( action = RET_STATUS );

  /*"seg_plane = %d %d %d %d\n", seg_plane[0].objid, seg_plane[1].objid, seg_plane[2].objid, seg_plane[3].objid */

  status = om$send( msg     = message NDnode.NDget_objects
                              ( ND_ROOT, NotSeg_plane, 4, NULL, 0, OM_K_MAXINT, &nb_support ),
                    targetid = segment_to_merge->objid,
                    targetos = segment_to_merge->osnum );
  as$status( action = RET_STATUS );

  /*"NotSeg_plane = %d %d %d %d\n", NotSeg_plane[0].objid, NotSeg_plane[1].objid, NotSeg_plane[2].objid, NotSeg_plane[3].objid */

  /*| set my_plane to change and my new plane */

  if( NotSeg_plane[0].objid == seg_plane[0].objid )
  {
    /*| -----<----  && ----->----- */

    my_plane  = seg_plane[0];
    new_plane = NotSeg_plane[3];
    MyPrevCmpIndex      = 0;
    MyNewCmpOrientation = -1;
  }
  else if( NotSeg_plane[3].objid == seg_plane[0].objid )
  {
    /*| -----<----  && -----<----- */

    my_plane  = seg_plane[0];
    new_plane = NotSeg_plane[0];
    MyPrevCmpIndex      = 0;
    MyNewCmpOrientation = 1;
  }
  else if( NotSeg_plane[0].objid == seg_plane[3].objid )
  {
    /*| ----->----  && ----->----- */

    my_plane  = seg_plane[3];
    new_plane = NotSeg_plane[3];
    MyPrevCmpIndex      = 1;
    MyNewCmpOrientation = 1;
  }
  else
  {
    /*| ----->----  && -----<----- */

    my_plane  = seg_plane[3];
    new_plane = NotSeg_plane[0];
    MyPrevCmpIndex      = 1;
    MyNewCmpOrientation = -1;
  }

  /*"my plane to change = %d\n", my_plane.objid */

  /*"my new plane to connect to = %d\n", new_plane.objid */
  status = om$send( msg      = message NDnode.NDchange_connect( 1, &my_plane, &new_plane ),
                    targetid = my_id );
  as$status( action = RET_STATUS );

  /* Get my new component from notified segment ==> it is the not deleted one */

  status = om$send( msg     = message VRCnrlSeg.VRget_terminators
                              ( &retcode,&nb_support,md_env,NULL,delseg_cmp ),
                    targetid = segment_to_merge->objid,
                    targetos = segment_to_merge->osnum );
  as$status( action = RET_STATUS );

  if( delseg_cmp[0].objid == PrevConnectedCmpId->objid ) 
                                               *cmp_to_connect = delseg_cmp[1];
  else  *cmp_to_connect = delseg_cmp[0];

  __DBGpr_obj("cmp_to_connect",*cmp_to_connect);

  /*" new cmp = %d\n", cmp_to_connect->objid */

  /* Update index and orientation of my new component */
  {
    IGRint 		SegToDeleteConsType;
    IGRdouble		PrimOrient;
    IGRdouble		SecOrient;
    struct	GRid	PsegId;

    if( PrevConnectedCmpId->objid != NULL_OBJID )
    {
      status = om$send( msg      = message VRGeneric.VRGetIndex
                                   ( &retcode, &my_grid, &MyPrevCmpIndex ),
                        targetid = PrevConnectedCmpId->objid,
                        targetos = PrevConnectedCmpId->osnum );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );

      /*| disconnect the old component */
      __DBGpr_obj("object to disconnect",*PrevConnectedCmpId);

      status = om$send( msg      = message NDnode.NDdisconnect( 1, &my_grid ),
                        targetid = PrevConnectedCmpId->objid,
                        targetos = PrevConnectedCmpId->osnum );
      as$status( action = RET_STATUS );

      __DBGpr_com(" Get my new component orientation on his old segment");
      status = om$send( msg      = message VRGeneric.VRGetOrientationDef
                                   ( &retcode, &PsegId, NULL, &PrimOrient,
                                     NULL, NULL, &SecOrient
                                   ),
                        targetid = cmp_to_connect->objid,
                        targetos = cmp_to_connect->osnum );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );
      __DBGpr_dbl("PrimOrient",PrimOrient);
      __DBGpr_dbl("SecOrient",SecOrient);
      __DBGpr_obj("PsegId",PsegId);

      __DBGpr_com("if segment_to_merge is PsegId, new orient is PrimOrient");
      __DBGpr_com(" else is SecOrient");
      if( segment_to_merge->objid == PsegId.objid ) 
      {
        MyNewCmpOrientation *= PrimOrient;
      }
      else MyNewCmpOrientation *= SecOrient;
    }

    __DBGpr_com("calling VRGeneric.VRChgSupport");
    status = om$send( msg      = message VRGeneric.VRChgSupport
                                 (&retcode,MyNewCmpOrientation, MyPrevCmpIndex, 
                                  segment_to_merge, &my_grid ),
                      targetid = cmp_to_connect->objid,
                      targetos = cmp_to_connect->osnum );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );
    __DBGpr_obj("segment_to_merge",*segment_to_merge);

    /* Update my Constype */
    status = om$send( msg      = message VRCnrlSeg.VRSegConstrainsType
                                                   ( VR_GET_TYPE, 0, &SegToDeleteConsType ),
                      targetid = segment_to_merge->objid,
                      targetos = segment_to_merge->osnum );
    as$status( action = RET_STATUS );

    __DBGpr_int("me->ConsType", me->ConsType);
    __DBGpr_int("SegToDeleteConsType",SegToDeleteConsType);
    if( me->ConsType != SegToDeleteConsType )
    {
      __DBGpr_com("calling VRSegConstrainsType");
      status = om$send( msg      = message VRCnrlSeg.VRSegConstrainsType( VR_INIT_TYPE, VR_UNKNOWN, NULL ),
                        targetid = my_id );
      as$status();  

      /*"ConsType = %d\n", me->ConsType */
    }
  }

  return(OM_S_SUCCESS);
}

/*============================================================================*/

method VRget_planes( IGRlong 			*msg;
                     struct 	GRid		*common_plane;
                     struct 	GRid		*vertical_plane;
                     struct 	GRid		*start_plane;                  
                     struct 	GRid		*end_plane )
{
  IGRint			nb_of_planes;   /* number of my father        */
  IGRlong 			status;         /* return code                */
  struct	GRid		planes_grid[VR_NB_SEG_PLANES];
                                                /* my father GRid             */


  *msg 	  = MSSUCC;
  status  = OM_S_SUCCESS;

  if( common_plane || vertical_plane || start_plane || end_plane )
  {
    status = om$send( msg      = message NDnode.NDget_objects
                                 ( ND_ROOT, planes_grid, VR_NB_SEG_PLANES, NULL, 0,
                                   OM_K_MAXINT, &nb_of_planes ),
                      targetid = my_id );

    /*"nb_planes = %d\n", nb_of_planes */

    /*"parent list = %d %d %d %d\n", planes_grid[0].objid, planes_grid[1].objid, planes_grid[2].objid, planes_grid[3].objid */

    if( common_plane   != NULL ) *common_plane   = planes_grid[1];
    if( vertical_plane != NULL ) *vertical_plane = planes_grid[2];
    if( start_plane    != NULL ) *start_plane    = planes_grid[0];
    if( end_plane      != NULL ) *end_plane      = planes_grid[3];
  }

  return ( OM_S_SUCCESS );

}

/***************************************************************************/

method VRGetComponents( IGRlong 		*p_retmsg; 
                        IGRint			*p_nb_cmps;
                        struct 	GRid 		*p_cmp_id  )
{
  IGRint			i, j, NbChild;
  IGRlong        		status=OM_S_SUCCESS;
  struct	 GRid 		*p_ChildId=NULL;
  
  
	*p_retmsg    = MSSUCC;

	if( !p_cmp_id && !p_nb_cmps ) return OM_E_INVARG;

	/* init p_nb_cmps */
	if( p_nb_cmps ) *p_nb_cmps = 0;

	status =
	om$send( msg    = message NDnode.NDget_objects
				( ND_CHILDREN | ND_IN_BUF, NULL, 0, &p_ChildId, 0,
				  OM_K_MAXINT, &NbChild ),
		targetid = my_id );
    	as$status( action = RET_STATUS );

    	for( i=0, j=0; i<NbChild; i++ )
    	{
		GRclassid	obj_class;
		/*"My Children[%d] = %d\n", i, p_ChildId[i].objid */

      		status =
		om$get_classid( osnum     = p_ChildId[i].osnum,
				objid     = p_ChildId[i].objid,
				p_classid = &obj_class );

      		if( 	(status & 1) &&
			om$is_ancestry_valid
				( subclassid   = obj_class,
				  superclassid = OPP_VRGeneric_class_id ) == OM_S_SUCCESS )
      		{
        		if( p_cmp_id )
        		{
        			p_cmp_id[j++] = p_ChildId[i];
        			/*"Comp[%d] = %d\n", j-1, p_cmp_id[j-1].objid */
			}
	
        		if( p_nb_cmps ) ( *p_nb_cmps )++;
      		}
    	}

  return OM_S_SUCCESS;

}

/***************************************************************************/

method VRget_terminators( IGRlong 			*p_retmsg; 
                          IGRint			*p_nb_cmps;
		          struct 	GRmd_env 	*p_MdEnv;
                          IGRdouble 			*p_cmp_pt;
			  struct 	GRid 		*p_cmp_id  )
{
  IGRshort			index;
  IGRint			NbCmps;
  IGRlong        		status=OM_S_SUCCESS, retcode=MSSUCC;
  struct	 GRid 		my_grid, ChildrenId[VR_NB_CMPS];
  struct	ret_struct	seg_str;   


  *p_retmsg = MSSUCC;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  if( !p_cmp_id && !p_cmp_pt && !p_nb_cmps ) return OM_E_INVARG;

  if( p_cmp_id )
  {
    	/* get component connected to the segment */
    	status = om$send( msg      = message VRCnrlSeg.VRGetComponents
                                                 ( &retcode, &NbCmps, ChildrenId ),
                      	  targetid = my_id );
    	as$status( action = RET_STATUS );

	/*"Nbcmps = %d\n", NbCmps */

    	if( NbCmps )
    	{
      		status = om$send( msg      = message VRGeneric.VRGetIndex
      								( &retcode, &my_grid, &index ),
                        	  targetid = ChildrenId[0].objid,
                        	  targetos = ChildrenId[0].osnum );
		/*"Child0 = %d\n", ChildrenId[0].objid */
      		/*"Children[0]_index = %d\n", index */

      		as$status( action = RET_STATUS );
      		as$status( sts = retcode, action = RET_STATUS );

      		/* cmp_id[0] is the start component of the segment and cmp_id[1] is the end component */

      		if( NbCmps > 1 )
      		{
        		if( ! index )
        		{
          			p_cmp_id[0] = ChildrenId[0];
          			p_cmp_id[1] = ChildrenId[1];
        		}
        		else
        		{
          			p_cmp_id[0] = ChildrenId[1];
          			p_cmp_id[1] = ChildrenId[0];
        		}
      		}
      		else p_cmp_id[0] = ChildrenId[0];

		/*^
				IGRint i;
	  	  		printf("VRCnrlSeg.VRget_terminators\n");
          	  		for( i=0; i<NbCmps; i++ )
            	    			printf("\t\tMy Terminator[%d] = %d\n",i,p_cmp_id[i].objid);
      		*/
    	}
  }

  if( p_cmp_pt )
  {
	status = om$send( msg      = message NDnode.NDgive_structure
							( &retcode, &seg_str, p_MdEnv ),
                       	  targetid = my_id );
     	as$status( action = RET_STATUS );  
     	as$status( sts = retcode, action = RET_STATUS );  

     	/*"start pt = %f %f %f\n", seg_str.var.line_st.p0[0], seg_str.var.line_st.p0[1], seg_str.var.line_st.p0[2] */
     	/*"end pt   = %f %f %f\n", seg_str.var.line_st.p1[0], seg_str.var.line_st.p1[1], seg_str.var.line_st.p1[2] */

     	p_cmp_pt[0] = seg_str.var.line_st.p0[0];
     	p_cmp_pt[1] = seg_str.var.line_st.p0[1];
     	p_cmp_pt[2] = seg_str.var.line_st.p0[2];
     	p_cmp_pt[3] = seg_str.var.line_st.p1[0];
     	p_cmp_pt[4] = seg_str.var.line_st.p1[1];
     	p_cmp_pt[5] = seg_str.var.line_st.p1[2];
  }

  if( p_nb_cmps )
  {
  	if( p_cmp_id ) *p_nb_cmps = NbCmps;
  	else
  	{
    		status =
		om$send( msg      = message VRCnrlSeg.VRGetComponents
                                               ( &retcode, p_nb_cmps, NULL ),
                      	  	  targetid = my_id );
    		as$status( action = RET_STATUS );
  	}
  }
	
  return OM_S_SUCCESS;

}

/*============================================================================*/

method VRGetTopo( IGRlong 			*msg;
                  IGRdouble			*my_vector;
                  struct 	IGRplane	*common_plane;
                  struct 	IGRplane	*vertical_plane;
                  struct 	IGRplane	*start_plane;                  
                  struct 	IGRplane	*end_plane;
                  struct 	GRmd_env 	*md_env  )  
{
  IGRmatrix			matrix;	 	/* needed for ASreturn_go     */
  struct	GRid		planes_grid[4]; /* my father GRid             */
  struct	GRid		go_planes;      /* used to get planes def.    */
  struct	ret_struct	my_structure;   /* my structure               */
  IGRlong 			status;         /* return code                */
  IGRlong 			retcode;        /* return code                */
  IGRint			nb_of_planes;   /* number of my father        */
  IGRshort			matrix_type;    /* needed for ASreturn_go     */
  BSrc				bsretcode;	/* Bs retur code	      */

//  SetProc (VRCnrtSeg_VRGetTopo ); Begin


  *msg 	  = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  

//   if( md_env )
//	__DBGpr_obj("md_env ", md_env->md_id );

  if( my_vector || start_plane || end_plane )
  {
    status = om$send( msg      = message  NDnode.NDgive_structure
						( &retcode, &my_structure, md_env ),
   	 	      targetid = my_id );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

//    __DBGpr_vec("start pt ", my_structure.var.line_st.p0 );
//    __DBGpr_vec(" end  pt ", my_structure.var.line_st.p1 );
//    __DBGpr_vec(" vec  pt ", my_structure.var.line_st.v0 );
  }
  
  if( common_plane || vertical_plane || start_plane || end_plane )
  {
    /* get planes of segment */

    status = om$send( msg      = message NDnode.NDget_objects
                                 ( ND_ROOT, planes_grid, VR_NB_SEG_PLANES, NULL,0,OM_K_MAXINT,&nb_of_planes ),
                      targetid = my_id );
    as$status( action = RET_STATUS );

//    __DBGpr_int("nb_planes ", nb_of_planes );

    /*"parent list = %d %d %d %d\n", planes_grid[0].objid, planes_grid[1].objid, planes_grid[2].objid, planes_grid[3].objid */

    if( common_plane != NULL )
    {
      /*| get common_plane structure */

      status = om$send( msg      = message NDnode.ASreturn_go
                                           ( &go_planes, &matrix_type, matrix ),
                        targetid = planes_grid[1].objid,
  	  	        targetos = planes_grid[1].osnum );
      as$status( action = RET_STATUS );

      /*"go_planes = %d %d\n", go_planes.objid, go_planes.osnum */

      status = om$send( msg      = message  GRvg.GRdetplane
                                   ( &retcode, &matrix_type, matrix, common_plane ),
    	 	        targetid = go_planes.objid,
	  	        targetos = go_planes.osnum );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );
       
//      __DBGpr_vec("common plane point", common_plane->point );
//      __DBGpr_vec("common plane normal", common_plane->normal );
    } 

    if( vertical_plane != NULL )
    {
      /*| get vertical_plane structure */

      status = om$send( msg      = message NDnode.ASreturn_go
                                           ( &go_planes, &matrix_type, matrix ),
                        targetid = planes_grid[2].objid,
  	  	        targetos = planes_grid[2].osnum );
      as$status( action = RET_STATUS );

//      __DBGpr_obj("go_planes ", go_planes );

      status = om$send( msg      = message  GRvg.GRdetplane
                                   ( &retcode, &matrix_type, matrix, vertical_plane ),
   	 	        targetid = go_planes.objid,
	  	        targetos = go_planes.osnum );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );
   
//      __DBGpr_vec("Vert Plane point", vertical_plane->point );
//      __DBGpr_vec("Vert Plane  normal", vertical_plane->normal );
    }

    if( start_plane != NULL )
    {
      /*| get start_plane structure */

      status = om$send( msg      = message NDnode.ASreturn_go
                                           ( &go_planes, &matrix_type, matrix ),
                        targetid = planes_grid[0].objid,
  	  	        targetos = planes_grid[0].osnum );
      as$status( action = RET_STATUS );

      /*"go_planes = %d %d\n", go_planes.objid, go_planes.osnum */

      status = om$send( msg      = message  GRvg.GRdetplane
                                   ( &retcode, &matrix_type, matrix, start_plane ),
   	 	        targetid = go_planes.objid,
	  	        targetos = go_planes.osnum );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );

      start_plane->point[0] = my_structure.var.line_st.p0[0];
      start_plane->point[1] = my_structure.var.line_st.p0[1];
      start_plane->point[2] = my_structure.var.line_st.p0[2];

//      __DBGpr_vec("START Plane point", start_plane->point );
//      __DBGpr_vec("START Plane  normal", start_plane->normal );
    }

    if( end_plane != NULL )
    {
      /*| get end_plane structure */

      status = om$send( msg      = message NDnode.ASreturn_go
                                           ( &go_planes, &matrix_type, matrix ),
                        targetid = planes_grid[3].objid,
  	  	        targetos = planes_grid[3].osnum );
      as$status( action = RET_STATUS );

      /*"go_planes = %d %d\n", go_planes.objid, go_planes.osnum */

      status = om$send( msg      = message  GRvg.GRdetplane
                                   ( &retcode, &matrix_type, matrix, end_plane ),
    	 	        targetid = go_planes.objid,
	  	        targetos = go_planes.osnum );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );
   
      end_plane->point[0] = my_structure.var.line_st.p1[0];
      end_plane->point[1] = my_structure.var.line_st.p1[1];
      end_plane->point[2] = my_structure.var.line_st.p1[2];

//      __DBGpr_vec("END Plane point", end_plane->point );
//      __DBGpr_vec("END Plane  normal", end_plane->normal );
    }
  }

  if( my_vector )
  {
  	IGRdouble MyVect[3];

	/* NDgive_structure return V0 = ( 1,0,0 ) if p0 and p1 are coincident. So to get
	/* the segment vector we the normal of the start vector.
	/**/

	BSmkvec(&bsretcode, MyVect, my_structure.var.line_st.p0, my_structure.var.line_st.p1);
	if( BSlenvec( &bsretcode, MyVect ) < VRGetTol(VR_LENGTH_TOL) )
	{
		if( ! start_plane )
		{
  			struct 		IGRplane	StartPlane;
  			IGRdouble			Point[3], Normal[3];

			/*| get start_plane grid */
      			status = om$send( msg      = message VRCnrlSeg.VRget_planes
                                           	     ( &retcode, NULL, NULL, &planes_grid[0],
						       NULL ),
                        	  	  targetid = my_id );
      			as$status( action = RET_STATUS );

			/*| get start_plane structure */
      			status = om$send( msg      = message NDnode.ASreturn_go
                                           		( &go_planes, &matrix_type, matrix ),
                        	  	  targetid = planes_grid[0].objid,
  	  	        	  	  targetos = planes_grid[0].osnum );
      			as$status( action = RET_STATUS );

      			/*"go_planes = %d %d\n", go_planes.objid, go_planes.osnum */

			StartPlane.point  = Point;
			StartPlane.normal = Normal;
      			status = om$send( msg      = message  GRvg.GRdetplane
                                   			( &retcode, &matrix_type, matrix,
							  &StartPlane
							),
   	 	        	  	  targetid = go_planes.objid,
	  	        	  	  targetos = go_planes.osnum );
      			as$status( action = RET_STATUS );
      			as$status( sts = retcode, action = RET_STATUS );

    			my_vector[0] = StartPlane.normal[0];
    			my_vector[1] = StartPlane.normal[1];
    			my_vector[2] = StartPlane.normal[2];
		}
		else
		{
    			my_vector[0] = start_plane->normal[0];
    			my_vector[1] = start_plane->normal[1];
    			my_vector[2] = start_plane->normal[2];

		}
	}
	else
	{
    		my_vector[0] = my_structure.var.line_st.v0[0];
    		my_vector[1] = my_structure.var.line_st.v0[1];
    		my_vector[2] = my_structure.var.line_st.v0[2];
	}

//        __DBGpr_vec("my_vector ", my_vector );
  }

//  End
  return ( OM_S_SUCCESS );

}


/******************************************************************************/

method VRnotify_merge( IGRlong *p_retmsg; struct GRmd_env *md_env )
{
  IGRlong		status=OM_S_SUCCESS;
  struct	GRid	my_GRid;


  *p_retmsg    = MSSUCC;

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  /*"my_GRid = %d %d\n", my_GRid.objid, my_GRid.osnum */

  status = VRDeleteObjects( 1, &my_GRid, md_env );
  as$status();

  return(OM_S_SUCCESS);

}

/******************************************************************************/
method VRsplit_segment( IGRlong 			*msg; 
                        IGRboolean			SharePlane;
                        IGRdouble 			*split_point;
                        struct 		GRmd_env 	*md_env;
                	struct 		GRid 		*NewSeg_id )

{
  BSrc				bsretcode;
  IGRint			i, NbCmps;
  IGRint			nb_support;     /* used by NDget_objects      */
  IGRlong 			status;         /* return code                */
  IGRlong 			retcode;        /* return code                */
  IGRboolean			SplitNearEnd;
  IGRdouble			*p_SplitPoint, EndPt[6];
  IGRpoint			SplitPoint;
  IGRvector			MyVect, TmpVect;
  struct	GRid		new_plane;      /* new segment GRid           */
  struct	GRid		seg_plane[10];  /* used by NDget_objects      */
  struct	GRid		parents[4];     /* used to create new segment */
  struct	ret_struct	plane_def;      /* used to create new plane   */

	       /* Below variables added by Anand for TR 5557 */
  GRclassid			ClassId;
  extern	GRclassid	OPP_VRNozzle_class_id, OPP_VRDepPlane_class_id;
  struct	GRid		CompIds[2];     /* Components of old segment  */
	       /* Above variables added by Anand for TR 5557 */

  SetProc( VRsplit_segment ); Begin

  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  SplitNearEnd = FALSE;

  status = om$send( msg     = message VRCnrlSeg.VRget_terminators
                              ( &retcode, &NbCmps, md_env, EndPt, CompIds ),
                    targetid = my_id );
  as$status( action = RET_STATUS );

  BSmkvec( &bsretcode, MyVect, EndPt, &EndPt[3] );
  BSnorvec( &bsretcode, MyVect );

  BSmkvec( &bsretcode, TmpVect, EndPt, split_point );
  if( BSlenvec( &bsretcode, TmpVect ) < VRGetTol(VR_LENGTH_TOL) ) 
  {
    for(i=0;i<3;i++) SplitPoint[i] = split_point[i] +
                                       VRGetTol(VR_LENGTH_TOL) * MyVect[i];

    SplitNearEnd = TRUE;
  }
  else
  {
    BSmkvec( &bsretcode, TmpVect, split_point, &EndPt[3] );
    if( BSlenvec( &bsretcode, TmpVect ) < VRGetTol(VR_LENGTH_TOL) ) 
    {
      for(i=0;i<3;i++) SplitPoint[i] = split_point[i] - VRGetTol(VR_LENGTH_TOL) * MyVect[i];

      SplitNearEnd = TRUE;
    }
  }

  if( SplitNearEnd ) p_SplitPoint = SplitPoint;
  else               p_SplitPoint = split_point;

  status = om$send( msg     = message NDnode.NDget_objects
                              ( ND_ROOT, seg_plane, 10, NULL, 0, OM_K_MAXINT, &nb_support ),
                    targetid = my_id );
  as$status( action = RET_STATUS );
  __DBGpr_objlist("Planes on me CS", nb_support, seg_plane);

  /*| get the end plane structure */

  status = om$send( msg      = message NDnode.NDgive_structure( &retcode,
					                        &plane_def,
						                md_env ),
                    targetid = seg_plane[3].objid,
                    targetos = seg_plane[3].osnum);
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );

	/*"normal of del. plane = %f %f %f\n", plane_def.var.ref_st.t[3], plane_def.var.ref_st.t[4], plane_def.var.ref_st.t[5] */


	/*| create the new plane */
	cre_plan( p_SplitPoint , &plane_def.var.ref_st.t[3], md_env, &new_plane );

	/* ------------------- */
	/*| Create New Segment */
	/* ------------------- */

	status =
	om$send( msg = message NDnode.NDcopy
		( &retcode, 0, md_env, md_env, NewSeg_id ),
		targetid = my_id);
	as$status( action = RET_STATUS );
	/*"NewSeg id %d %d\n", NewSeg_id->objid, NewSeg_id->osnum */

        /* added by alwin -- for TR#179603661  */
        /* Initialize the Minimum Length Instance Variable of Line Segment */
        /* to zero.                                                        */
        status = om$send ( msg = message VRCnrlSeg.VRSegMinLength(
                                    &retcode, VR_INIT_LENGTH, NULL,
                                    md_env ),
                        senderid = NULL_OBJID,
                        targetid = NewSeg_id->objid,
                        targetos = NewSeg_id->osnum );
        /* added by alwin -- for TR#179603661  */

	parents[0] = new_plane;
	parents[1] = seg_plane[1];
	parents[2] = seg_plane[2];
	parents[3] = seg_plane[3];

	status =
	om$send( msg = message NDnode.NDconnect
			(4, parents, NULL_GRID, ND_NEW),
		targetid = NewSeg_id->objid,
		targetos = NewSeg_id->osnum  );
	as$status( action = RET_STATUS );

	/*"me->ConsType = %x\n", me->ConsType */

	if( ( me->ConsType & VR_CNS_AFF ) == VR_CNS_VAL )
	{
		/*| Segment to split is FITTING TO FITTING */
		status =
		om$send( msg = message VRCnrlSeg.VRSegConstrainsType
				( VR_UPDATE_TYPE, me->ConsType, NULL ),
			targetid = NewSeg_id->objid,
			targetos = NewSeg_id->osnum  );
		as$status( action = RET_STATUS );
	}

		      /* BEGIN FIX FOR JTS TR MP 5557 */

	__DBGpr_objlist("Comp child of orig CS", 2, CompIds);

	/* Nice thing about VRget_terminators method of VRCnrlSeg is that it
	 * returns the component children in the same sequence as they are
	 * hooked on to the CS, i.e., CompIds[0] is the 0th child of the CS
	 * and CompIds[1] is the 1st child */
	om$get_classid( osnum     = CompIds[1].osnum,
			objid     = CompIds[1].objid,
			p_classid = &ClassId );

	if( SharePlane == TRUE &&
	    om$is_ancestry_valid( subclassid   = ClassId,
				  superclassid = OPP_VRNozzle_class_id )
				== OM_S_SUCCESS )
	{
	    IGRint	NbDepPln=0;
	    struct GRid RefId, DepPlaneIds[3];
	    OM_S_CHANSELECT	NDfather_channel, NDchild_channel;

	    __DBGpr_me();
	    __DBGpr_obj(" New CS", *NewSeg_id);

	    status = om$make_chanselect(channame     ="NDfather.father",
					p_chanselect = &NDfather_channel );
	    as$status(action = RET_STATUS);

	    status = om$make_chanselect(channame     ="NDchildren.children",
					p_chanselect = &NDchild_channel );
	    as$status(action = RET_STATUS);

	    status = om$send( msg = message VRNozzle.VRGetRefId( &retcode,
								 &RefId ),
			      targetid = CompIds[1].objid,
			      targetos = CompIds[1].osnum );
	    __DBGpr_obj(" Coord Sys Ref ID of Nozzle", RefId);

	    status = vdchn$GetList( objID	= &RefId,
				    chnIDx	= VDCHN_IDX_CHILDREN,
				    maxCnt	= 3,
				    cnt		= &NbDepPln,
				    outIDs	= DepPlaneIds,
				    FltrClsId	= OPP_VRDepPlane_class_id );
	    __DBGpr_objlist(" Dependent planes", NbDepPln, DepPlaneIds );

	    /* NDdisconnect for VRDepPlanes has been overridden, and this also
	     * deletes the DepPlanes! So use Root.disconnect instead. */
	    __DBGpr_objlist("Disconnecting Dep Plane from me", 3, DepPlaneIds);
	    for( i=0 ; i<3 ; i++ )
	    {
		status = om$send( msg      = message Root.disconnect(
							  NDfather_channel,
							  DepPlaneIds[i].objid,
							  DepPlaneIds[i].osnum,
							  NDchild_channel
								    ),
				  senderid = NULL_OBJID,
				  targetid = my_id );
		as$status( action = RET_STATUS );
	    }
	    __DBGpr_objlist("Disconnected Dep Plane from me", 3, DepPlaneIds);
	
	    status = om$send( msg = message NDnode.NDconnect( 3, DepPlaneIds,
							      NULL_GRID,
							      ND_ADD ),
			      senderid = NULL_OBJID,
			      targetid = NewSeg_id->objid,
			      targetos = NewSeg_id->osnum  );
	    as$status( action = RET_STATUS );
	}

		       /* END FIX FOR JTS TR MP 5557 */

	/*| compute the New CS */
	status =
	om$send( msg      = message NDnode.NDs_compute_node
				( &retcode, 0, md_env ),
		targetid = NewSeg_id->objid,
		targetos = NewSeg_id->osnum  );
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );

	/* ---- Change my end plane ---- */

	if( ! SharePlane )
	{
		/* Create a second plane at the same location */
		cre_plan( p_SplitPoint , &plane_def.var.ref_st.t[3], md_env, &new_plane );
	}

	/*| connect the main CS to the new plane */
	status =
	om$send( msg = message NDnode.NDchange_connect
			( 1, &seg_plane[3], &new_plane ),
		targetid = my_id );
	as$status( action = RET_STATUS );

	/*| compute the main CS */
	status = om$send( msg = message NDnode.NDs_compute_node
			( &retcode, 0, md_env ),
		targetid = my_id );
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );


  End
  return(OM_S_SUCCESS);

}/* end VRsplit_segment */


/*********************************************************/

method VRChgSegState( IGRshort CorState, ConstState )
{
   if( CorState   != -1 ) me->CreateCorEntity    = CorState;
   if( ConstState != -1 ) me->EvaluateConstrains = ConstState;

   /*"New State = %d %d\n", me->CreateCorEntity, me->EvaluateConstrains */

   return(OM_S_SUCCESS);
}

/****************************************************************************/

method VRSegMinLength( 	IGRlong				*p_retmsg;
			IGRint 				Operation;
			IGRdouble			*MinLength; 
		       	struct 		GRmd_env 	*p_MdEnv )
{
  IGRlong status=OM_S_SUCCESS, retcode=MSSUCC;
	
  SetProc( VRSegMinLength ); Begin
	
  *p_retmsg = MSSUCC;

  __DBGpr_me();
  __DBGpr_int(" Operation", Operation);

  if( Operation & VR_INIT_LENGTH ) me->MinLength = 0.;

  if( Operation & VR_UPDATE_LENGTH )
  {
  	IGRint		i, NbTerm;
  	IGRdouble	CmpLength, CorLength=0.0;
  	struct	GRid	CmpsId[VR_NB_CMPS];

	me->MinLength = 0.;

	status = om$send( msg      = message VRCnrlSeg.VRget_terminators
               				( &retcode, &NbTerm, p_MdEnv, NULL, CmpsId ),
                    	  targetid = my_id );
  	as$status( action = RET_STATUS );
  	as$status( sts = retcode, action = RET_STATUS );

  	/* NbTerm = %d .. Term = %d %d\n", NbTerm, CmpsId[0].objid, CmpsId[1].objid */
	__DBGpr_objlist(" Child Comp", NbTerm, CmpsId);
 
  	for( i=0; i<NbTerm; i++ )
  	{
    		status = om$send( msg      = message VRCnrlSeg.VRGetMyCmpLength
                       			     ( &retcode, &CmpsId[i], p_MdEnv, &CmpLength ),
                      		  targetid = my_id );
    		as$status( action = RET_STATUS );
    		as$status( sts = retcode, action = RET_STATUS );

		__DBGpr_dbl(" Length of Cmp", CmpLength);

    		status = om$send( msg      = message VRCnrlSeg.VRGetMyCorLength
                      			     ( &retcode, &CmpsId[i], p_MdEnv, &CorLength ),
                      		  targetid = my_id );
    		as$status( action = RET_STATUS );
    		as$status( sts = retcode, action = RET_STATUS );
  
    		__DBGpr_dbl(" Corlen ", CorLength );

    		me->MinLength += CmpLength + CorLength;
  	}

  	__DBGpr_dbl(" My MinLength", me->MinLength );
  }
	
  if( Operation & VR_GET_LENGTH ) *MinLength = me->MinLength;
  
  End
  return OM_S_SUCCESS;
}

/******************************************************************************/

method VRGetMyCmpLength( IGRlong 			*msg;
                          struct 	GRid 		*CmpId;
                          struct 	GRmd_env 	*md_env;
			  IGRdouble			*CmpLength )
{
  IGRshort		CptIndex;
  BSrc			bsretcode;
  IGRint		Index, Other;
  IGRint		NbChildren;
  IGRlong		retcode, status;
  IGRdouble		EndPt[3*VR_NB_CMPS];
  IGRpoint		CmpCptCoor;
  IGRvector		CmpVect, SegVect;
  struct	GRid	my_grid, ChildrenId[VR_NB_CMPS];
  IGRint                LengthSign;

  SetProc( VRGetMyCmpLength ); Begin

  if( ! CmpLength || ! CmpId ) return OM_E_INVARG;

  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  __DBGpr_obj(" CmpId ", *CmpId );

  status = om$send( msg      = message VRCnrlSeg.VRget_terminators
                               ( &retcode, &NbChildren, md_env, EndPt, ChildrenId ),
                    targetid = my_id );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"Child = %d %d\n", ChildrenId[0].objid, ChildrenId[1].objid */
  __DBGpr_vec(" start pt ", EndPt );
  __DBGpr_vec(" endpt ", &EndPt[3] );

  if( ChildrenId[0].objid == CmpId->objid )
    {
      Index = 0;
      Other = 1;
    }
  else
    {
      Index = 1;
      Other = 0;
    }

  __DBGpr_int(" Index", Index );

  status = om$send( msg      = message VRGeneric.VRGetCptOnSup
                               			   ( &retcode, &my_grid, &CptIndex, md_env ),
                    targetid = CmpId->objid,
                    targetos = CmpId->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  __DBGpr_int(" Cpt Index is ", CptIndex );

  status = om$send( msg      = message VRGeneric.VRGetCptGeom
                               ( &retcode, CptIndex, CmpCptCoor, NULL, NULL, md_env ),
                    targetid = CmpId->objid,
                    targetos = CmpId->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  __DBGpr_vec(" Cmp0CptCoor", CmpCptCoor );
  /*"endpt       = %f %f %f\n", EndPt[3*Index], EndPt[3*Index+1], EndPt[3*Index+2] */

  /* Compute the vector from the segment end point to the component 
     connect point */
  BSmkvec( &bsretcode, CmpVect, &EndPt[3*Index], CmpCptCoor );
  __DBGpr_vec(" Vector from end pt of seg and cpt", CmpVect );
  
  /* Compute the vector from one segment end point to the other */
  BSmkvec( &bsretcode, SegVect, &EndPt[3*Index], &EndPt[3*Other]);
  __DBGpr_vec(" Vector from start pt of seg and end pt of seg", SegVect );

  LengthSign = 1;

  /* See if the two vector point the the same or opposite directions */
  if ( BSdotp( &bsretcode, CmpVect, SegVect) < 0)
    LengthSign = -1;

  __DBGpr_int(" LengthSign",LengthSign);

  *CmpLength = (double) LengthSign * BSlenvec( &bsretcode, CmpVect );

  __DBGpr_dbl(" CmpLength", *CmpLength );

  End
  return OM_S_SUCCESS;
}

/******************************************************************************/

method VRGetMyCorLength( IGRlong 			*msg;
                          struct 	GRid 		*CmpId;
                          struct 	GRmd_env 	*md_env;
			  IGRdouble			*CorLength )
{
  IGRshort		CptIndex;
  IGRlong		retcode, status;
  struct	GRid	CorId, my_grid;


  if( ! CorLength || ! CmpId ) return OM_E_INVARG;

  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  status = om$send( msg      = message VRGeneric.VRGetCptOnSup
                               			    ( &retcode, &my_grid, &CptIndex, md_env ),
                    targetid = CmpId->objid,
                    targetos = CmpId->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"Cpt Index = %d\n", CptIndex */

  status = om$send( msg      = message VRGeneric.VRGetCorOnCpt
                               			    ( &retcode, CptIndex, &CorId, md_env  ),
                    targetid = CmpId->objid,
                    targetos = CmpId->osnum );
  as$status( action = RET_STATUS );

  /*"CorId = %d\n", CorId.objid */

  if( retcode == MSFAIL ) *CorLength = 0;
  else
  {
    status = om$send( msg      = message VRCorrection.VRGetCorLenByCmp
                                         		( &retcode, CmpId, md_env, CorLength ),
                      targetid = CorId.objid,
                      targetos = CorId.osnum );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );
  }

  /*"CorLength = %f\n", *CorLength */

  return OM_S_SUCCESS;
}

/******************************************************************************/

method VRSegConstrainsType( IGRint Operation, NewConsType, *SegConsType )
{
  if( Operation & VR_INIT_TYPE )
  {
  	me->NbCons = 1;

  	if( me->csstate & VR_REVERSE ) 	me->ConsType = VR_CNS_PARA | VR_CNS_MAX;
  	else				me->ConsType = VR_CNS_PARA | VR_CNS_MIN;
  }

  if( Operation & VR_GET_TYPE ) *SegConsType = me->ConsType;

  if( Operation & VR_UPDATE_TYPE ) me->ConsType = NewConsType;

  /*"me->ConsType = %x\n", me->ConsType */

  return OM_S_SUCCESS;
}

/******************************************************************************/

method VRGetNeighbors( IGRlong 			*p_retmsg;
                       IGRint			SizeBuff;
                       IGRint			*NbOfNeigh;
		       struct	GRid		*NeiIds;
		       struct	GRmd_env	*md_env )
{
  IGRint		i, j, LoopStop, NbChild, NbSup0, NbSup1, NbNeigh;
  IGRlong		retcode=MSSUCC, status=OM_S_SUCCESS;
  struct	GRid	ChildList[VR_NB_CMPS], SupIds0[VR_MAX_CPTS],
                        SupIds1[VR_MAX_CPTS];

  *p_retmsg = MSSUCC;
  
  /*| Get my Child */	
  status = om$send( msg      = message VRCnrlSeg.VRget_terminators
                               ( &retcode, &NbChild, md_env, NULL, ChildList ),
                    targetid = my_id );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  if( NbChild != VR_NB_CMPS )
  {
    as$status( sts = OM_E_ABORT,
               msg = "Segment number of parents is not valid" );

    return OM_E_ABORT;
  }
  
  /*| Get supports of my Child 0 */	
  status = om$send( msg      = message VRGeneric.VRGetSupports
		                               ( &retcode, VR_MAX_CPTS, SupIds0, &NbSup0 ),
                    targetid = ChildList[0].objid,
                    targetos = ChildList[0].osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );
  
  /*| Get supports of my Child 1 */	
  status = om$send( msg      = message VRGeneric.VRGetSupports
                		               ( &retcode, VR_MAX_CPTS, SupIds1, &NbSup1 ),
                    targetid = ChildList[1].objid,
                    targetos = ChildList[1].osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  if( SizeBuff < ( NbSup0 + NbSup1 - 2 ) )
  {
    as$status( sts = OM_E_ABORT, msg = "Buffer size not enought" );
    return OM_W_ABORT;
  }

  for( i=0, NbNeigh=0; i<NbSup0; i++ )
  {
    /*"SupId0[%d] = %d ... my_id = %d\n", i, SupIds0[i].objid, my_id */
    if( SupIds0[i].objid != my_id )
    {
      NbNeigh++;
      NeiIds[NbNeigh-1] = SupIds0[i];
      /*"NeiIds[%d] = %d\n", NbNeigh-1, NeiIds[NbNeigh-1].objid */
    }
  }

  for( i=0, LoopStop=NbNeigh; i<NbSup1; i++ )
  {
    /*"SupId1[%d] = %d ... my_id = %d\n", i, SupIds1[i].objid, my_id */
    if( SupIds1[i].objid != my_id )
    {
      for(j=0;j<LoopStop;j++) if( SupIds1[i].objid == NeiIds[j].objid ) break;
      NbNeigh++;
      NeiIds[NbNeigh-1] = SupIds1[i];
      /*"NeiIds[%d] = %d\n", NbNeigh-1, NeiIds[NbNeigh-1].objid */
    }
  }

  if( NbOfNeigh ) *NbOfNeigh = NbNeigh;

  /*^
      printf("VRCnrlSeg.VRGetNeigh ===============================\n");

      printf("\t\t NbOfNeigh = %d\n", NbNeigh );

      for( i=0; i<NbNeigh; i++ )
      {
        printf("\t\t NeiIds[%d] = %d\n", i, NeiIds[i].objid );
      }
      printf("VRCnrlSeg.VRGetNeigh ===============================\n");
  */

  return OM_S_SUCCESS;

}

/****************************************************************************/

method VRGetSegProduct( IGRshort *SegProduct )
{
  *SegProduct = me->csproduct;

  return OM_S_SUCCESS;
}


/******************************************************************************/

method VRnotify_disconnect( IGRshort delete_flag; struct GRid previous_connected )
{
  IGRshort			index;          /* component index            */
  IGRint			nb_support;     /* used by GetSupports        */
  IGRint			cn_type; 
  IGRint			wait_index;     /* used by is_waiting macro   */
  IGRint 			NbCmp;
  IGRlong			NumberOfBytes;  /* number of bytes            */
  IGRlong			BytesReceived;   /* number of received bytes  */
  IGRlong 			status;         /* return code                */
  IGRlong 			retcode;        /* return code                */
  IGRboolean			Merge;          /* test to merge              */
  IGRint			cRep;
  struct	GRid		OldId;
  struct	GRid		my_grid;        /* my GRid                    */
  struct 	GRid		MyNewCmpId;
  struct	GRid		cmp_support[VR_NB_CMP_SUPPORTS];
                                                /* previous disconnectd supp. */
  struct	GRid		segment_to_notify;
                                                /* seg. to notify for merge   */
  struct	GRmd_env	md_env;         /* module env                 */


  if( previous_connected.objid == NULL_OBJID ) return(OM_S_SUCCESS);

  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  /*"my_grid = %d %d\n", my_grid.objid, my_grid.osnum */

  me->CreateCorEntity = 0;

  NDis_waiting( GR_DELETED, 0, &my_grid, &wait_index, NULL, NULL, 1 );

  if( wait_index != -1 )
  {
    /*| I am in the delete list */

     return(OM_S_SUCCESS);
  }

  if( delete_flag )
  {
  	NDis_waiting(GR_DELETED, 0, &previous_connected, &wait_index, NULL, NULL, 1);

  	if( wait_index == -1 )
  	{
    		/*| previous connected are not in the delete list */

     		return(OM_S_SUCCESS);
  	}
  }

  /*"cmp to delete = %d\n", previous_connected.objid */

  status = om$send( msg     = message VRGeneric.VRGetSupports
           		              ( &retcode, VR_NB_CMP_SUPPORTS,
                                        cmp_support, &nb_support
                                      ),
                    targetid = previous_connected.objid,
                    targetos = previous_connected.osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"nb_support = %d\n", nb_support */

  /*| Get the current module info */

  NumberOfBytes = sizeof( struct GRmd_env );
  status = gr$get_model_env( msg    = &retcode,
			     sizbuf = &NumberOfBytes,
			     buffer = &md_env,
			     nret   = &BytesReceived );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );
   
  /*"module_info = %d %d\n", md_env.md_id.objid, md_env.md_id.osnum */

  Merge = FALSE;

  if( nb_support > 1 )
  {
    /*| See if Merge */

    status = VRget_segment_to_notify( &retcode, nb_support, cmp_support,
                                      &my_grid, &segment_to_notify, &md_env, &Merge );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );
  }
 
  if( Merge )
  {

    status = om$send( msg      = message VRCnrlSeg.VRnotify_merge( &retcode, &md_env ),
                      targetid = segment_to_notify.objid,
                      targetos = segment_to_notify.osnum );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    status = om$send( msg      = message VRCnrlSeg.VRmerge_segments
                                 ( &retcode, &segment_to_notify, &md_env, &previous_connected, 
                                   &MyNewCmpId
                                 ),
                      targetid = my_id );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    status = om$send( msg      = message NDnode.NDs_compute_node( &retcode, 0, &md_env ),
                      targetid = my_id );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );
  }
  else
  {
    IGRshort			CmpIndex;
    IGRdouble			section[9];
    struct 	GRid		CmpId[VR_NB_CMPS], ActParamId, UserParamId;
    struct	GRsymbology	Symb;

    /*| Get the construction list to place a dangling */
    
    /* Get index of dangling : this index is not previous_connected object one
    /* in any case ( because component dosn't update its index instance when 
    /* it disconnect from a segment ). So I deduice this index from my ohter
    /* component one.
    /* I am not going to call get_terminators to get my childs because it
    /* uses VRGetIndex message.
    /**/

	status =
	om$send( msg    = message VRCnrlSeg.VRGetComponents
                                                 ( &retcode, &NbCmp, CmpId ),
		targetid = my_id );
	as$status( action = RET_STATUS );

	if( NbCmp > 1 )
	{
		if( CmpId[0].objid == previous_connected.objid ) CmpIndex = 1;
		else                                             CmpIndex = 0;
	}
	else CmpIndex = 0;

	status =
	om$send( msg      = message VRGeneric.VRGetIndex
						( &retcode, &my_grid, &index ),
		targetid = CmpId[CmpIndex].objid,
		targetos = CmpId[CmpIndex].osnum );
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );

	if( NbCmp > 1 ) index = 1 - index;

	/*"cmp_index = %d\n", index */

	/* to place the dangling we need prevoius_connected object connect point parameters on
	/* the notified segment. the message VRGetCptOnSup uses the index, so we can use it
	/* here. To get the connect point number we use VRSelectCptByGeom message.
	/* this message needs a vector and point. we get these from segment.
	/**/

	status = VRGetAttrFromCpt
	( me->csproduct, index, (me->csproduct==VR_PIPING) ? NULL : section,
	  &ActParamId, &UserParamId, &previous_connected, &my_grid, &md_env );

	status =
	om$send( msg      = message VRGeneric.ACget_rep( &cRep),
		 targetid = previous_connected.objid,
		 targetos = previous_connected.osnum );
	as$status( action = RET_STATUS );

	status =
	om$send( msg      = message GRvg.GRgetsymb( &retcode, &Symb),
		 targetid = previous_connected.objid,
		 targetos = previous_connected.osnum );
	as$status( action = RET_STATUS );

	/*| disconnect the old component */
	status =
	om$send( msg      = message VRGeneric.VRDisconnect( &retcode, &my_grid, &md_env ),
		 targetid = previous_connected.objid,
		 targetos = previous_connected.osnum );
	as$status( action = RET_STATUS );

	{
		struct VRTopo	Topo;

	Topo.SegId 	= my_grid;
	Topo.nEndPoint	= index;
	Topo.pd3Width	= (me->csproduct==VR_PIPING) ? NULL : &section[3];

	status =
	VRPlaceAutoComponent (	&retcode, (IGRint)me->csproduct, &OldId,
				((IGRboolean) (NbCmp>1) ? FALSE : TRUE),
				&ActParamId, &UserParamId, 1, &Topo,
				&Symb, cRep, &md_env );
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );
	}
  }

  if( Merge || NbCmp > 1 )
  {
  	me->CreateCorEntity = VR_UPDATE_COR;

  	cn_type = ND_COMP;
  	nd$wait_batch( 	type       = GR_GEOM_POSTED, 
                 	l_object   = &my_grid,
                 	l_obj_info = &cn_type,
                 	nb_obj     = 1 );
  }

  return(OM_S_SUCCESS);

}

/******************************************************************************/

method VRget_state ( IGRint *n_state )
{
  /*"get state of %d is %x\n", my_id, me->my_state */

  *n_state = me->my_state;

  return(OM_S_SUCCESS);
}

/******************************************************************************/

method VRchg_state ( IGRint mask, n_state )
{
  /*"obj %d mask %x n_state %x\n",my_id,mask,n_state */

  me->my_state = ( me->my_state & ~mask) | ( n_state & mask );

  return(OM_S_SUCCESS);
}

end implementation VRCnrlSeg;
