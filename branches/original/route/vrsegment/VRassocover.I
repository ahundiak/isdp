/* $Id: VRassocover.I,v 1.2 2001/03/08 23:34:04 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	usr2/law/assign/newcode/route/vrsegment / VRassocover.I
 *
 * Description:
 *     This file contains the method to place a control segment.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRassocover.I,v $
 *	Revision 1.2  2001/03/08 23:34:04  louis
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
# Revision 1.1  1997/06/26  13:49:02  pinnacle
# initial revision
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	06/25/97   law          changed name VRassoc_over.I to VRassocover.I
 *      03/08/01   law          dbg prints

 *************************************************************************/

/* Original hist
 * rev 1.1  1996/07/25  18:25:44 
 * Creation of Route 241 project
 *
 * rev 1.2  1996/01/17  23:26:12
 * vrsegment/VRassoc_over.I for  by r240_int for route240
 *
 *      10/15/90   momo         creation
 *      15-Nov-91  Bruno        1.4.3.9
 *              - NDmove_to_root was performing a split network when
 *                the Vertical plane was in the delete list. It now
 *                also test that the common plane is NOT in the delete
 *                list.
 *      23-Mar-92  Bruno        2.1.1.22
 *              - NDmove_to_root had twice the code for end planes
 *                management and could be interrupted before connecting
 *                the new plane => exit with one plane missing.
 *      01/17/96   tlb          Add prototypes
 */

class implementation VRCnrlSeg;


#include "grdpbdef.h"
#include "alloca.h"
#include "asdef.h"
#include "VRdef.h"
#include "VRcordef.h"
#include "OMmacros.h"
#include "igr.h"
#include "grdpbmacros.h"
#include "parametric.h"
#include "ASmatrix.h"
#include "bstypes.h"
#include "asmacros.h"
#include "VRmacros.h"
#include "AS_status.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "VRpriv_attr.h"
#include "VRprivmacros.h"
#include "VRact_params.h"
#include "VRattr_def.h"
#include "VRsketchdef.h"
#include "vrdbgmacros.h"
#include "vrsegmen_pto.h"
#include "vrtools_pto.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bslenvec.h"

#define AS_DEBUG 	1

from	GRlinear	import	GRputpolyline;
from	VRGeneric	import	VRGetIndex, VRGetSupports, VRGetCptOnSup, VRGetCorOnCpt;
from	VRCorrection	import	VRUpdateConnection;

extern 			GRabsg_del_by_objid();
extern 	struct GRid 	NULL_GRID;
extern 	GRclassid 	OPP_GR3dlineseg_class_id;
extern	OM_S_CHANSELECT	AS_to_comp;


/****************************************************************************/

method NDupdate( IGRint 		*msg, cn_type, count;
		 struct GRid 		*parents;
		 IGRint 		*parent_state;
		 struct GRid 		*context, *new_objid;
		 struct GRmd_env 	*md_env )
{
  IGRint 		status=OM_S_SUCCESS, nbcmp, i;
  IGRlong 		retcode=MSSUCC;
  IGRboolean		break_connect=FALSE, equip_moved=FALSE;
  GRclassid		CompClassId;
  struct	GRid	cmp[2];

  extern GRclassid OPP_VRNozzle_class_id, OPP_VRCptIn_class_id;
 
SetProc( VRCnrlSeg_NDupdate ); Begin
  /* -- Check whether parents attributes have changed -- */

  for( i=VR_NB_SEG_PLANES; i<count; i++ )
  {
	if( parent_state[i] != ND_COMP_SAME ) 
	{
		/*| equip moved */
		equip_moved = TRUE;
		break;
	}
  }	

  if( !equip_moved )
  {
	/*| plane moved */
	if( !( me->my_state & VR_MAINTAIN_CONNECT ) && 
              ( parent_state[1] != ND_COMP_SAME || 
		parent_state[2] != ND_COMP_SAME ) ) break_connect = TRUE;
  }
    
  if( break_connect )
  {
    __DBGpr_com("parent 1 or 2 has changed");
    __DBGpr_obj("parent 1",parents[1]);
    __DBGpr_obj("parent 2",parents[2]);
    /*"parent %d or %d is changed\n", parents[1].objid, parents[2].objid */

    status = om$send( msg     = message VRCnrlSeg.VRget_terminators
                                ( &retcode, &nbcmp, md_env, NULL, cmp ),
                    targetid = my_id );
    End
    as$status( action = RET_STATUS );

    for( i=0; i<nbcmp; i++ )
    {
      /* if my terminator is a nozzle or a VRCptIn I replace it with a dangling */
      status = om$get_classid( 	objid     = cmp[i].objid,
				osnum     = cmp[i].osnum,
				p_classid = &CompClassId
  			     );
      as$status();

      if( om$is_ancestry_valid( subclassid   = CompClassId,
		  	        superclassid = OPP_VRNozzle_class_id ) == OM_S_SUCCESS )
      {
	/*"disconnect = %d\n", cmp[i].objid */
        status = om$send( msg      = message VRCnrlSeg.VRnotify_disconnect
			                                         ( 0, cmp[i] ),
                          targetid = my_id );
        End
        as$status( action = RET_STATUS );
      }
    }
  }

  /* -- Go back to normal process -- */

  status = om$send( mode     = OM_e_wrt_message,
		    msg      = message ASnode.NDupdate 
				( msg, cn_type, count, parents, parent_state,
			  	  context, new_objid, md_env ),
		    targetid = my_id );
  End
  return status;

}

/******************************************************************************/

method NDconnect( IGRint nb_root; struct GRid *root; struct GRid original;
                  IGRint type)
{
  BSrc	 			bsretcode;
  IGRlong 			retcode;
  IGRlong 			status;
  IGRdouble 			SegOrient;
  IGRdouble 			MyVector[3];
  IGRdouble 			MyStartPlanePoint[3];
  IGRdouble 			MyStartPlaneNormal[3];
  struct	IGRplane	MyStartPlane;

SetProc( VRCnrlSeg_NDconnect ); Begin
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  status = om$send( mode     = OM_e_wrt_message,
                    msg      = message ASnode.NDconnect
                                              ( nb_root, root, original, type ),
 		    targetid = my_id );
  as$status( action = RET_STATUS );

  /* don't change my constrain type if my length is fixed */
  if( ( me->ConsType & VR_CNS_AFF ) == VR_CNS_VAL ) return OM_S_SUCCESS;

  MyStartPlane.point  = MyStartPlanePoint;
  MyStartPlane.normal = MyStartPlaneNormal;

  status = om$send( msg      = message VRCnrlSeg.VRGetTopo
                               ( &retcode, MyVector, NULL, NULL, &MyStartPlane,
                                 NULL, NULL ),
                    targetid = my_id );
  as$status( action = RET_STATUS );  
  as$status( sts = retcode, action = RET_STATUS );  

  SegOrient = BSdotp( &bsretcode, MyVector, MyStartPlaneNormal );

  /*"SegOrient = %f\n", SegOrient */

  if( SegOrient < 0 ) me->csstate |= VR_REVERSE;
  else                me->csstate &= ~VR_REVERSE;

  /*"my_state = %d\n", me->csstate */

  /* Init my constraint type */

  status = om$send( msg      = message VRCnrlSeg.VRSegConstrainsType( VR_INIT_TYPE, VR_UNKNOWN, NULL ),
                    targetid = my_id );
  as$status();  

  /*"ConsType = %d\n", me->ConsType */

  End
  return OM_S_SUCCESS;
}

/******************************************************************************/

method NDchange_connect( IGRint nb_root; struct GRid *old, *new )
{
  BSrc	 			bsretcode;
  IGRlong 			retcode;
  IGRlong 			status;
  IGRdouble 			SegOrient;
  IGRdouble 			MyVector[3];
  IGRdouble 			MyStartPlanePoint[3];
  IGRdouble 			MyStartPlaneNormal[3];
  struct	IGRplane	MyStartPlane;

SetProc( VRCnrlSeg_NDchange_connect ); Begin
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  __DBGpr_int("Calling NDnodein.NDchange_connect with my_id",my_id);
  status = om$send( mode     = OM_e_wrt_message,
                    msg      = message NDnodein.NDchange_connect( nb_root, old, new ),
 		    targetid = my_id );
  as$status( action = RET_STATUS );

  /* don't change my constrain type if my length is fixed */
  if( ( me->ConsType & VR_CNS_AFF ) == VR_CNS_VAL ) return OM_S_SUCCESS;
 
  MyStartPlane.point  = MyStartPlanePoint;
  MyStartPlane.normal = MyStartPlaneNormal;

  status = om$send( msg      = message VRCnrlSeg.VRGetTopo
                               ( &retcode, MyVector, NULL, NULL, &MyStartPlane, NULL, NULL ),
                    targetid = my_id );
  as$status( action = RET_STATUS );  
  as$status( sts = retcode, action = RET_STATUS );  
  __DBGpr_vec("MyStartPlanePoint",MyStartPlanePoint);

  SegOrient = BSdotp( &bsretcode, MyVector, MyStartPlaneNormal );

  /*"SegOrient = %f\n", SegOrient */

  if( SegOrient < 0 ) me->csstate |= VR_REVERSE;
  else                me->csstate &= ~VR_REVERSE;

  /*"my_state = %d\n", me->csstate */

  /* Init my constraint type */

  status = om$send( msg      = message VRCnrlSeg.VRSegConstrainsType( VR_INIT_TYPE, VR_UNKNOWN, NULL ),
                    targetid = my_id );
  as$status();  

  /*"ConsType = %d\n", me->ConsType */

  End
  return OM_S_SUCCESS;
}
/******************************************************************************/

method NDplace( struct 	GRas 		*assoc_list; 
                struct 	GRmd_env 	*md_env;
		IGRchar 		*go_cnst_lis )
{
  struct 	IGRplane	plane_info[VR_NB_SEG_PLANES]; 
						 /* parent planes structure  */
  IGRmatrix			matrix;	 	 /* needed for ASreturn_go   */
  IGRdouble			normal[12];      /* parent planes normal     */
  IGRdouble			points[12];      /* parent planes point      */
  IGRdouble			line[6];         /* segment geometry         */
  struct	GRid	 	*list;           /* parent plane list GRid   */
  struct	GRid		go_planes[VR_NB_SEG_PLANES];
						 /* graphic planes           */
  IGRlong 			status;          /* return code              */
  IGRlong 			retcode;         /* return code              */
  IGRint 			i;               /* index loop               */
  OMuint 			count;	         /* number of parents        */
  IGRshort			matrix_type;     /* needed for ASreturn_go   */


SetProc( VRCnrlSeg_NDplace ); Begin
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  me->csproduct          = *((IGRshort *)assoc_list->as_attr);
  me->my_state 		 = VR_MAINTAIN_CONNECT;
  me->CreateCorEntity    = 0;
  me->EvaluateConstrains = 0;
  me->MinLength          = 0;
  me->ConsType           = VR_CNS_PARA | VR_CNS_MIN; /* any thing. real value will
                                                     /* be set in NDconnect method
                                                     /**/

  count  = assoc_list->num_parents;
  list   = assoc_list->parents;

  /*"num of parents %d\n", count */

  /* get planes structure */
  for( i = 0; i<VR_NB_SEG_PLANES; i++ )
  {
    /*"parent num %d = %d %d\n", i, list[i].objid, list[i].osnum */

    plane_info[i].point  = &points[3*i];
    plane_info[i].normal = &normal[3*i];

    status = om$send( msg      = message NDnode.ASreturn_go
                                         ( &go_planes[i], &matrix_type, matrix ),
                      targetid = list[i].objid,
	  	      targetos = list[i].osnum );
    as$status( action = RET_STATUS );

    /*"graphic parent num %d = %d %d\n", i, go_planes[i].objid, go_planes[i].osnum */

    status = om$send( msg      = message  GRvg.GRdetplane
                                 ( &retcode, &matrix_type, matrix, &plane_info[i] ),
                      targetid = go_planes[i].objid,
	  	      targetos = go_planes[i].osnum );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );
#ifdef vdsDEBUG

      printf(" plane %d point: %lf , %lf , %lf \n", i,
                                                    plane_info[i].point[0],
					            plane_info[i].point[1],
						    plane_info[i].point[2]);

      printf("plane %d normal: %lf , %lf , %lf \n", i,
                                                    plane_info[i].normal[0],
					            plane_info[i].normal[1],
						    plane_info[i].normal[2]);
#endif
  }

  __DBGpr_com("Calling VRget_segment_geom-------------------------------");
  status = VRget_segment_geom( (int *)&retcode, plane_info, &line[0], &line[3] ); 
  as$status( action = RET_STATUS );

  /*"segment point1 : %f , %f , %f\n", line[0], line[1], line[2] */
  /*"segment point2 : %f , %f , %f\n", line[3], line[4], line[5] */

  __DBGpr_vec("line begin",&line[0]);
  __DBGpr_vec("line end",&line[3]);
  if( go_cnst_lis != NULL )
  {
    struct IGRpolyline geom;
    IGRint ii;

    geom.num_points = 2;
    geom.points     = line;

    ((struct GRvg_construct *) go_cnst_lis)->geometry = ( IGRchar * ) &geom;

    __DBGpr_com("CONSTRUCTING NEW SEGMENT with ASnode.ASconstruct_go -------------------------------");
    status = om$send( msg      = message ASnode.ASconstruct_go
                                 ( assoc_list, md_env,  go_cnst_lis, OPP_GR3dlineseg_class_id, TRUE ),
	    	      targetid = my_id);
    __DBGpr_obj("newlineseg",assoc_list->go_objid);
    __DBGpr_int("no_parents",assoc_list->num_parents);

    for(ii=0;ii<assoc_list->num_parents;ii++)
    {
       __DBGpr_obj("parent obj",list[ii]);
    }
    as$status( action = RET_STATUS );
  }

  /*------------------------------------------------------------------
  we ask the graph manager to add the new VRCnrlSeg to the graph 
  --------------------------------------------------------------------*/

  __DBGpr_com("ask the graph manager to add the new VRCnrlSeg to the graph");
  __DBGpr_int("Calling NDnode.NDconnect for my_id",my_id);
  status = om$send( msg      = message NDnode.NDconnect( count, list, NULL_GRID,ND_NEW ),
		    targetid = my_id);
  as$status( action = RET_STATUS );

  return(OM_S_SUCCESS);

}


/* ========================================================================= */

method NDcompute_node( IGRlong 			*msg;
                       IGRint  			cn_type;
		       IGRint  			count;
                       struct	GRid 		list []; 
                       struct	GRmd_env 	*md_env  )  
{
  IGRshort			mat_type;
  IGRint			i;               /* loop index                   */
  IGRlong			status, retcode; /* return code                  */
  IGRdouble			points[3*VR_NB_SEG_PLANES];
                                                 /* parent planes origin         */
  IGRdouble			normal[3*VR_NB_SEG_PLANES];
                                                 /* parent planes normal         */
  IGRdouble			line[6];         /* end points of segment        */
  IGRmatrix			matrix;          
  GRobjid			newobjid;        /* used by putpolyline          */
  struct	GRid		MyGRid, seg_go_grid;
  struct	IGRplane	planes[VR_NB_SEG_PLANES];
                                                 /* planes structure             */
  struct 	IGRpolyline	geom;            /* segment geometry             */
  struct	GRpost_info    	post_info;       /* used by putpolyline          */


  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  MyGRid.objid = my_id;
  MyGRid.osnum = OM_Gw_current_OS;

  /*| get parents structure */
  for( i=0; i<VR_NB_SEG_PLANES; i++ )
  {
    planes[i].point  = &points[3*i];
    planes[i].normal = &normal[3*i];

    /*"get plane %d structure\n", list[i].objid */

    status = om$send( msg      = message  GRvg.GRdetplane
                                          ( &retcode,
		       		            &md_env->md_env.matrix_type,
			       		    md_env->md_env.matrix,
                                            &planes[i] ),
 	 	      targetid = list[i].objid,
	  	      targetos = list[i].osnum );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );
   
    /*^
        printf("plane %d point : %lf , %lf , %lf \n", i,
                                                      planes[i].point[0],
				                      planes[i].point[1],
						      planes[i].point[2]  );

        printf("plane %d normal : %lf , %lf , %lf \n", i,
                                                       planes[i].normal[0],
						       planes[i].normal[1],
						       planes[i].normal[2]);
    */
  }

  status = VRget_segment_geom( (int *)&retcode, planes, &line[0], &line[3] );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"new segment point 0 : %f %f %f\n", line[0], line[1], line[2] */
  /*"new segment point 1 : %f %f %f\n", line[3], line[4], line[5] */

  /*| update graphic object */

  geom.num_points          = 2;
  geom.points              = line;
  post_info.construct_flag = FALSE;

  /* RESET THE GEOMETRY BUFFER : probleme in GRNUC */

  status = om$send( msg      = message NDnode.ASreturn_go
                               ( &seg_go_grid, &mat_type, matrix ),
                    targetid = my_id );

  /*"graphic object = %d %d\n", seg_go_grid.objid, seg_go_grid.osnum */

  GRabsg_del_by_objid( &seg_go_grid.objid, &seg_go_grid.osnum );

  status = om$send( msg      = message GRlinear.GRputpolyline
                               ( &retcode, md_env, &post_info, &geom, &newobjid ),
                    targetid = seg_go_grid.objid,
                    targetos = seg_go_grid.osnum  );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  if( me->CreateCorEntity )
  {   
	status = VR$ComputeCorrection( 	p_retmsg	= &retcode,
					ComputeType	= VR_NO_COMPUTE,
					CorType		= VR_UNKNOWN,
 					p_SegmentId	= &MyGRid,
 					p_MdEnv		= md_env );
    	as$status( action = RET_STATUS );
    	as$status( sts = retcode, action = RET_STATUS );
  }

  me->CreateCorEntity = 0;
 
  return OM_S_SUCCESS;

}

/******************************************************************************/

method NDnotify_disconnect( struct GRid previous_connected )
{
  IGRlong status;

  status = om$send( msg      = message VRCnrlSeg.VRnotify_disconnect
						 ( 1, previous_connected ),
		    targetid = my_id );
  as$status();

  return OM_S_SUCCESS;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDmove_to_root( IGRlong 			*msg;
		       struct 	GRid 		*src_grid; 
		       struct	GRmd_env	*md_env )
{
  IGRint 			i;		/* loop index                 */
  IGRint 			Number;
  IGRint			wait_index[VR_NB_SEG_PLANES];
                                                /* used by is_waiting macro   */
  IGRlong			retcode, status;/* return code                */
  IGRboolean			Align;

  struct 	GRid 		my_grid;        /* my GRid                    */
  struct 	GRid 		PlaneId[VR_NB_SEG_PLANES];
                                                /* parent planes GRid         */
  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

	/* get my planes parents */

	status =
	om$send( msg      = message NDnode.NDget_objects
			( ND_ROOT, PlaneId, VR_NB_SEG_PLANES,
			  NULL, 0, OM_K_MAXINT, &Number ),
		targetid = my_id );
	as$status( action = RET_STATUS );

	/* see if parents are in delete queue */

	status =
	NDis_waiting( GR_DELETED,0,PlaneId,wait_index,NULL,NULL, VR_NB_SEG_PLANES);

	/*^
	for( i=0; i<VR_NB_SEG_PLANES; i++ )
	{
	   printf("VRCnrlSeg.VRcsmvtort : parent = %d \n", PlaneId[i].objid );
           printf ("VRcsmvtort wait index %d\n", wait_index[i]);
	}
	*/

	/* If ONLY vertical plane gets deleted ==> Split the network */

	if( wait_index[2] != -1 && wait_index[1] == -1 )
	{
		struct	GRid	ChildId[VR_NB_CMPS];

		/*| common or vertical planes are in the batch delete list */
		status =
		om$send( msg      = message NDnode.NDget_objects
					( ND_CHILDREN, ChildId, VR_NB_CMPS,
					NULL, 0, OM_K_MAXINT, &Number ),
			targetid = my_id );
			as$status( action = RET_STATUS );

		for( i=0; i<Number; i++ )
		{
			status =
			VRSplitNetwork( &retcode, &ChildId[i], md_env );
			as$status();
		}
	}

	/* If common and/or vertical plane get deleted ==> Delete myself */

	if( wait_index[1] != -1 || wait_index[2] != -1 )
		return VRDeleteObjects( 1, &my_grid, md_env );

	if( wait_index[0] != -1 || wait_index[3] != -1 )
	{
		IGRint			EndNum;		/* deleted plane index		*/
		struct	ret_struct 	plane_def;	/* deleted plane structure	*/
		struct	GRid 		new_plane;	/* new plane GRid		*/
		struct 	GRid 		NeighId;
		struct 	GRid 		*p_ChildrenId;

		EndNum =  (wait_index[0] != -1) ? 0 : 3;

		/*" End plane %d gets deleted\n", EndNum */

		status =
		om$send( msg      = message NDnode.NDgive_structure
    					( &retcode, &plane_def, md_env ),
        	              targetid = PlaneId[EndNum].objid,
        	              targetos = PlaneId[EndNum].osnum);
		as$status( action = GOTO_VALUE, value = DELETE_SEGMENT );

		/* set the new plane structure : origin and normal */

		status =
		cre_plan ( 	&plane_def.var.ref_st.t[0],
				&plane_def.var.ref_st.t[3],
				md_env, &new_plane );
		as$status( action = GOTO_VALUE, value = DELETE_SEGMENT );

		/*"new plane = %d %d\n", new_plane.objid, new_plane.osnum */

		/* connect the Cs to the new plane */

		status =
		om$send(mode     = OM_e_wrt_message,
			msg      = message NDnodein.NDchange_connect
					( 1, &PlaneId[EndNum], &new_plane  ), 
			targetid = my_id );
		as$status( action = GOTO_VALUE, value = DELETE_SEGMENT );

		/* Get all segment to notify */

		status =
		om$send( msg      = message NDnode.NDget_objects
				( ND_CHILDREN,  NULL, 0, NULL, 0,
				  OM_K_MAXINT, &Number),
			targetid = PlaneId[EndNum].objid,
			targetos = PlaneId[EndNum].osnum);
		as$status( action = RET_STATUS );
		as$status( sts = retcode, action = RET_STATUS );

		if( !Number ) return OM_S_SUCCESS;

		p_ChildrenId =
		(struct GRid *) alloca(Number * sizeof(struct GRid ));
		if( !p_ChildrenId ) return OM_E_NODYNMEM;

		status =
		om$send( msg      = message NDnode.NDget_objects
				( ND_CHILDREN, p_ChildrenId, Number, NULL, 0,
				  OM_K_MAXINT, &Number),
			targetid = PlaneId[EndNum].objid,
			targetos = PlaneId[EndNum].osnum);
		as$status( action = RET_STATUS );


		/*^
		for(i=0; i<Number; i++ )
	       	  printf("VRCnrlSeg.NDmove_to_root : SegId ==> %d\n",
        	                                               p_ChildrenId[i].objid );
		*/

		status = 
		VRget_segment_to_notify( &retcode, Number, p_ChildrenId, &my_grid,
					&NeighId, md_env, &Align );
		as$status( action = RET_STATUS );
		as$status( sts = retcode, action = RET_STATUS );


		if( Align )
		{
			/*" Reconnect also %d\n", NeighId.objid */

			status =
			om$send( mode     = OM_e_wrt_message,
				 msg      = message NDnodein.NDchange_connect
					( 1, &PlaneId[EndNum], &new_plane  ), 
				targetid = NeighId.objid,
				targetos = NeighId.osnum );
			as$status( action = RET_STATUS );
		}

	}

	return OM_S_SUCCESS ;

DELETE_SEGMENT :

	return VRDeleteObjects( 1, &my_grid, md_env );

}/* end NDmove_to_root */


/*****************************************************************************/

method ASpossible_parent( IGRint ifrom, 
				 ito, 
				 *geom_code, 
				 *option_code,
      		                 *index_track, 
				 *index_ref, 
				 *index_plan, 
				 *nb_return, 
				 *nb_tot )
{
  IGRint i, j;

  /* set total number of parents */

  *nb_tot = 4;

  if( ifrom < 0 ) ifrom = 0;

  if( ito  < ifrom ) { *nb_return = 0; return(OM_S_SUCCESS); }

  if( ito  > *nb_tot - 1 ) ito = *nb_tot - 1;
  
  *nb_return = ito - ifrom + 1;

  /* set the type of each parent */
 
  for( i = ifrom, j = 0; i <= ito ; i++, j++ )
  {
    switch( i )
    {
      case 0 : 
      {
        geom_code[j]   = debug_type;
        option_code[j] = 1; /* obligatory */
        break;
      }

      case 1 : 
      {
        geom_code[j]   = debug_type;
        option_code[j] = 1;/* obligatory */
        break;
      }

      case 2 : 
      {
        geom_code[j]   = debug_type;
        option_code[j] = 1;/* obligatory */
        break;
      }

      case 3 : 
      {
        geom_code[j]   = debug_type;
        option_code[j] = 1;/* obligatory */
        break;
      }
    } /*  end switch  */
  }

  /*  track point or ref or plane : used for normal associtaive object */

  *index_ref   = -1;
  *index_track = -1;
  *index_plan  = -1;

  return(OM_S_SUCCESS);

}

/*****************************************************************************/
/*                                                                           */
/*        Return number of constraints defined bu the control segment.       */
/*                 Only constrain between end plane for now                  */
/*                                                                           */
/*****************************************************************************/

method VRget_nb_constrain( IGRint *nb_cons )
{
  if( me->EvaluateConstrains ) *nb_cons = me->NbCons;
  else                         *nb_cons = 0;

  /*"nb_cons = %d\n", *nb_cons */

  return OM_S_SUCCESS;
}

/*****************************************************************************/
/*                                                                           */
/*        Return the ith constrain defined by the control segment            */
/*                                                                           */
/*****************************************************************************/

method VRget_constrain( IGRlong *suc; IGRint i; IGRint *cons_type;
                        struct GRid *cons_obj; IGRint *nb_obj; IGRint size_obj;
                        IGRdouble *cons_val; IGRint *nb_val; IGRint size_val )

{
  IGRint 		count;
  IGRlong 		status;
  struct 	GRid 	my_root[4]; 

  if( size_val <= 0 ) return OM_E_ABORT;

  *suc   = MSSUCC;
  status = OM_S_SUCCESS;

  status = om$send( msg      = message NDnode.NDget_objects
                               ( ND_ROOT, my_root, VR_NB_SEG_PLANES , NULL, 0, OM_K_MAXINT, 
 			         &count 
                               ),
 		    targetid = my_id);
  as$status(action = RET_STATUS);

  switch( i ) 
  {
     case 0 :

       *nb_obj = 2;
       if(size_obj>0) cons_obj[0] = my_root[0];
       if(size_obj>1) cons_obj[1] = my_root[3];

       *nb_val = 1;
       *cons_type = me->ConsType;

       /*"cons_type = %d\n", *cons_type */

       if( me->csstate & VR_REVERSE ) cons_val[0] = - me->MinLength;
       else                           cons_val[0] = me->MinLength;

       break;
   
    default : status = OM_W_ABORT;
  }

  /*"cons_val = %f\n", cons_val[0] */

 return status;

}

end implementation VRCnrlSeg;
