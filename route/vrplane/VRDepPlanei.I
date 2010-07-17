/* $Id: VRDepPlanei.I,v 1.4 2001/12/05 16:01:41 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrplane / VRDepPlanei.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRDepPlanei.I,v $
 *	Revision 1.4  2001/12/05 16:01:41  louis
 *	tr5611-geometry of some corrections adjacent to nozzles were collapsing
 *	
 *	Revision 1.3  2001/02/20 01:15:30  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 23:34:20  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/23  23:38:48  pinnacle
# Created: route/vrplane/VRDepPlanei.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/04/27  14:08:04  pinnacle
# Replaced: vrplane/VRDepPlanei.I for:  by kddinov for route
#
# Revision 1.3  1998/04/09  08:36:38  pinnacle
# Replaced: vrplane/VRDepPlanei.I for:  by apazhani for route
#
# Revision 1.2  1998/03/29  10:32:04  pinnacle
# Replaced: vrplane/VRDepPlanei.I for:  by apazhani for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/17  17:33:10  pinnacle
# Replaced: vrplane/VRDepPlanei.I for:  by r240_int for route240
#
 *
 * History:
 *	01/15/96	tlb	Add prototypes
 *	03/29/98	Alwin	Modified the NDcompute_node method, to
 *				set the VRplane information correctly and to
 *				transform accordingly. TR179800791
 *      04/09/98        Alwin   Modified the NDcompute_node method, to correct
 *                              End Plane locations.
 *      12/04/01        law&    Commented out the code related to tr179800791
 *                      anand   and tr179800882 because it collapsed the
 *                              geometry of the duct when the equipment was
 *                              modified. 
 *************************************************************************/
class implementation VRDepPlane;

#include "igrdef.h"    
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "exmacros.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "VRplanedef.h"
#include "AS_status.h"

#include "bserr.h"
#include "bsdotp.h"
#include "bsvalues.h"
#include "bscrossp.h"
#include "bsnorvec.h"
#include "bsparameters.h"
#include "bsdistptpl.h"
#include "vrdbgmacros.h"
#include "VDmem.h"

#define AS_DEBUG

from	VRGeneric	import	VRGetCptGeom;
	
extern 	struct GRid 	NULL_GRID;
extern  GRclassid	OPP_VRCnrlSeg_class_id;
extern  GRclassid	OPP_VRplane_class_id;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*                                method NDplace                              
/*
/*  DESCRIPTION: 
	Given a CS matrix, this method places the instances of an VRplane
/*      object. the normal is the Z axis of the CS. i.e -> cs[2], cs[6], cs[10],
/*      the origin is the origin of the CS. i.e -> cs[3], cs[7], cs[11].
/*      The other coordinates (X_vector, Y_vector and projections are not used).
/*
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDplace( struct GRas *p_assoc_list; struct GRmd_env *p_md_env; char *p_go_cnst_lis )
{
  IGRint			status=OM_S_SUCCESS;
  IGRlong			retmsg;

  SetProc( VRDepPlane_NDplace ); Begin
  /* test argument validity */
  if( ! p_assoc_list || p_assoc_list->num_parents != 1 )
  {
    End
    return OM_E_INVARG;
  }

  /* set referential dependency flag */
  me->RefPlane = *((IGRint *) p_assoc_list->as_attr);
  /*"refPlane = %x\n", me->RefPlane */

  /* compute plane */
  status =
  om$send( msg      = message NDnode.NDcompute_node
			( &retmsg, 0, p_assoc_list->num_parents,
                        p_assoc_list->parents, p_md_env ),
	            targetid = my_id);
  as$status();

  /* plane need to be deleted if it has no depending child */
  status =
  om$send( msg      = message NDnode.NDchg_state 
			( (IGRchar) ND_DEL_NO_CH | ND_WAIT_DEL, 
			  (IGRchar) ND_DEL_NO_CH | ND_WAIT_DEL),
              	    targetid = my_id);
  as$status();

  /* dependent plane must be a fix plane for the solver */
  me->plane_state = VR_FIXED_PLANE;

  /* connect plane with it's template */
  status =
  om$send( msg	= message NDnode.NDconnect
			( p_assoc_list->num_parents,
			p_assoc_list->parents, NULL_GRID, ND_NEW ),
	targetid = my_id);
  as$status( action = RET_STATUS );

  End
  return OM_S_SUCCESS;

}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             method NDcompute_node                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDcompute_node
  (
  IGRlong            *p_msg;      /* OUT    Returned code                     */
  IGRint             cn_type;     /* IN     Type of compute                   */
  int                count;       /* IN     Number of parents                 */
  struct GRid        list[];      /* IN     List of parents                   */
  struct GRmd_env    *p_md_env    /* IN     Pointer to the environment        */
  )
{
  IGRlong			status=OM_S_SUCCESS, retcode=MSSUCC;
  struct	ret_struct	ret_str;
  IGRboolean    old_flag;
  IGRdouble     DepOrigin[3];
  IGRdouble     DepNormal[3];
  extern IGRboolean ASbroadcast_in_progress;

  SetProc( Md NDcompute_node of VRDepPlane ); Begin 

  old_flag = ASbroadcast_in_progress;

  __DBGpr_obj( " Temp Id ", list[0] );

  /*"refPlane = %x\n", me->RefPlane */
  
  __DBGpr_vec( " Origin ", me->origin );
  __DBGpr_vec( " Normal ", me->normal );
  DepOrigin[0] = me->origin[0];
  DepOrigin[1] = me->origin[1];
  DepOrigin[2] = me->origin[2];
 
  DepNormal[0] = me->normal[0];
  DepNormal[1] = me->normal[1];
  DepNormal[2] = me->normal[2];

  if( me->RefPlane & VR_DEP_PLANE )
  {
	/*| my template is a plane */
	
	status =
	om$send( msg      = message NDnode.NDgive_structure
    				( p_msg, &ret_str, p_md_env ),
		targetid = list[0].objid,
		targetos = list[0].osnum);
	as$status(action = RET_STATUS);

	/*| Fill the plane instances */

	me->origin[0] = ret_str.var.ref_st.t[0];
	me->origin[1] = ret_str.var.ref_st.t[1];
	me->origin[2] = ret_str.var.ref_st.t[2];
	me->normal[0] = ret_str.var.ref_st.t[3];
	me->normal[1] = ret_str.var.ref_st.t[4];
	me->normal[2] = ret_str.var.ref_st.t[5];
  }
  else if( me->RefPlane & VR_DEP_REF )
  {
	/*| my template is a referential */
	
	status =
	om$send( msg      = message NDnode.NDgive_structure
				( p_msg, &ret_str, p_md_env ),
		targetid = list[0].objid,
		targetos = list[0].osnum);
	as$status(action = RET_STATUS);

	/*| Fill the plane instances */

	me->origin[0] = ret_str.var.ref_st.t[3];
	me->origin[1] = ret_str.var.ref_st.t[7];
	me->origin[2] = ret_str.var.ref_st.t[11];

	if( me->RefPlane & VR_DEP_XY_REF )
	{
		me->normal[0] = ret_str.var.ref_st.t[2];
		me->normal[1] = ret_str.var.ref_st.t[6];
		me->normal[2] = ret_str.var.ref_st.t[10];
	}
	else if( me->RefPlane &  VR_DEP_XZ_REF )
	{
		me->normal[0] = ret_str.var.ref_st.t[1];
		me->normal[1] = ret_str.var.ref_st.t[5];
		me->normal[2] = ret_str.var.ref_st.t[9];
	}
	else if( me->RefPlane & VR_DEP_YZ_REF )
	{
		me->normal[0] = ret_str.var.ref_st.t[0];
		me->normal[1] = ret_str.var.ref_st.t[4];
		me->normal[2] = ret_str.var.ref_st.t[8];
	}
	else
        {
          End
          return OM_E_INVARG;
        }

  }
  else if( me->RefPlane & VR_DEP_CPT )
  {
	IGRint	CptNum;
        IGRlong bsretcode;
	GRclassid	TempClassId;
	IGRdouble 	dConAxis[3], dOrieAxis[3], dZ[3];
	struct GRid	CompId;
	struct GRmd_env	CompMdEnv;

	extern GRclassid OPP_VRGeneric_class_id;

  	status = om$get_classid	( 	objid = list[0].objid,
					osnum = list[0].osnum,
					p_classid = &TempClassId
			 	);
  	as$status();

  	if( om$is_ancestry_valid(
		subclassid 	= TempClassId,
	  	superclassid 	= OPP_VRGeneric_class_id )
	    == OM_S_SUCCESS )
	{
		CompId    = list[0];
		CompMdEnv = *p_md_env;
	}
	else
	{
	/*| my template is a component out of the current object space */
		status =
		om$send( msg      = message ASnode.ASreturn_go
				( &CompId, &CompMdEnv.md_env.matrix_type, 
			  	  CompMdEnv.md_env.matrix ),
		  	  targetid = list[0].objid,
		  	  targetos = list[0].osnum );
		as$status ( action = RET_STATUS );

		/*"comp id = %d %d\n", CompId.objid, CompId.osnum */

		CompMdEnv.md_id.osnum = CompId.osnum;
		status = ex$get_modid( 	mod_osnum  = CompMdEnv.md_id.osnum,
					mod_id     = &CompMdEnv.md_id.objid );
		as$status( action = RET_STATUS );
	}

	CptNum = me->RefPlane & VR_CPT_NUM;
	/*"CptNum = %d\n", CptNum */

	/* -- Get CPT Geometry -- */
	status =
	om$send ( msg      = message VRGeneric.VRGetCptGeom
			( &retcode, CptNum, me->origin, dConAxis, dOrieAxis,
			  &CompMdEnv ),
		  targetid = CompId.objid,
		  targetos = CompId.osnum );
	as$status ( action = RET_STATUS );

  	if( me->RefPlane & VR_DEP_XY_REF )
  	{
  		/*| common plane */
		BScrossp( &bsretcode, dConAxis, dOrieAxis, dZ );
    		me->normal[0] = dZ[0];
    		me->normal[1] = dZ[1];
    		me->normal[2] = dZ[2];
 	}
	else if( me->RefPlane &  VR_DEP_XZ_REF )
	{
		/*| end plane */
		me->normal[0] = dConAxis[0];
		me->normal[1] = dConAxis[1];
		me->normal[2] = dConAxis[2];
	}
	else if( me->RefPlane & VR_DEP_YZ_REF )
	{
		/*| ortho plane */
		me->normal[0] = dOrieAxis[0];
		me->normal[1] = dOrieAxis[1];
		me->normal[2] = dOrieAxis[2];
	}
	else
        {
          End
          return OM_E_INVARG;
        }
  }

  {	/* Bruno 13-Oct-1993 */
	BSrc	rc;
	/*C Normalize vectors because template can be scaled ... */
	BSnorvec (&rc, me->normal);
  }

#ifdef vdsDEBUG
printf ( "\n\tDepPlane <%d> : PLACED", my_id);
printf ( "\n\t ORIG %f, %f, %f",me->origin[0],me->origin[1],me->origin[2]);
printf ( "\n\t NORM %f, %f, %f\n",me->normal[0],me->normal[1],me->normal[2]);
#endif

  /* added by alwin ...for TR179800791 */
  /* When a pipe is sketched out of Nozzle placed in a reference file, and when
  the nozzle in the reference file is moved; the plane information needs to set
  correctly. Otherwise the Nozzle alone will be moved and Pipe network will be
  pointing in the same old place. The reason is that, plane information for the
  Line Segment needs resetting depending upon the movement of the Dependant
  Plane. And we need to transform the plane to reflect this change. */
/*** The code below was causing geometry to collapse if the segment was ***/
/*** sketched toward the nozzle. The code was disabled 12/3/01-law      ***/
#ifdef IF_PROBLEM_IN_THE_FUTURE
  {
     IGRint       NbChild=0, i;
     struct GRid *child, MyId;
     old_flag = ASbroadcast_in_progress;

     MyId.objid = my_id;
     MyId.osnum = p_md_env->md_id.osnum;
 
     status =
     om$send ( msg = message NDnode.NDget_objects
                                          (ND_CHILDREN | ND_IN_BUF, NULL, 0,
                                           &child, 0, OM_K_MAXINT, &NbChild ),
                        targetid = my_id);
     as$status( action = RET_STATUS );
     __DBGpr_int( " Nb of Childrens ", NbChild );
 
     for( i=0; i<NbChild; i++ )
     {
          GRclassid obj_classid;
 
          __DBGpr_obj( " Child Id ", child[i] );
 
          om$get_classid( objid     = child[i].objid,
                          osnum     = child[i].osnum,
                          p_classid = &obj_classid );
 
          if( om$is_ancestry_valid( subclassid   = obj_classid,
                                    superclassid = OPP_VRCnrlSeg_class_id )
                                    == OM_S_SUCCESS )
          {
              IGRint NbRoots=0, j, indic;
              struct GRid *buffer;
	      IGRdouble Distance[2];
	      IGRboolean bFarthestPlane[]={ FALSE, FALSE, FALSE, FALSE };
  
              __DBGpr_com( " It's VRCnrlSeg object " );
              status =
              om$send( msg = message NDnode.NDget_objects
                                            (ND_ROOT | ND_IN_BUF, NULL, 0,
                                            &buffer, 0, OM_K_MAXINT, &NbRoots ),
                            targetid = child[i].objid,
                            targetos = child[i].osnum );
              as$status( action = RET_STATUS );
              __DBGpr_int( " Nb of Parents, for Line Segment ", NbRoots );
  
              /* These checks are to prevent the other( 2 & 3 ) Dep. Planes
              executing the following code, Line Segment has three Dep Planes
              as parent, so we don't want the other two planes triggering this
              same routine. */
 
              if( NbRoots != 7 ) goto skip_additonal_compute;
 
              if( ( buffer[4].objid != MyId.objid )  ||
                  ( buffer[4].osnum != MyId.osnum )   )
                        goto skip_additonal_compute;
 
              /* The above condition ensures that we always use the DepPlane
              which is parallel to the End Planes of the line segment. */
 
              /* Just pick up the first and fourth plane to find out which ono
              of them is farthest plane wrt to VRDepPlane. Accordingly
              set (only the Y-displacement ), transformation matrix to that
              plane. Alwin for TR179800882 */
 
              for( j=0, indic=0; j<4; indic++, j+=3 )
              {
                 IGRlong        bsretcode;
                 IGRshort       matrix_type;
                 IGRmatrix      matrix;
		 IGRdouble		point[3], normal[3];
                 struct IGRplane  plane;
 
                 // we need to allocate memory for the point & normal of the
                 // plane structure.
                 plane.point  = point ;
                 plane.normal =  normal ;
 
                 MAidmx( &bsretcode, matrix );
                 __DBGpr_com( " Get the End Plane Informations " );
                 status =
                 om$send( msg      = message GRvg.GRdetplane
                                 ( &retcode, &matrix_type,
                                   matrix, &plane ),
                               targetid = buffer[j].objid,
                               targetos = buffer[j].osnum );
                 as$status( action = RET_STATUS );
 
                 __DBGpr_vec( " Plane Origin ", plane.point );
                 __DBGpr_vec( " Plane Normal ", plane.normal );
 
                 BSdistptpl( &bsretcode, plane.point, DepOrigin,
                             DepNormal, &Distance[indic] );
 
                 __DBGpr_dbl( " Distance between the planes ",
                                                     Distance[indic] );
              }

              if( Distance[0] > Distance[1] )
                bFarthestPlane[0] = TRUE;
              else
                bFarthestPlane[3] = TRUE;

              for( j=0; j<NbRoots; j++ )
              {
	          IGRdouble Normals[12];

                  __DBGpr_obj( " Parent Id ", buffer[j] );
  
                  om$get_classid( objid     = buffer[j].objid,
                                  osnum     = buffer[j].osnum,
                                  p_classid = &obj_classid );
  
                  if( obj_classid == OPP_VRplane_class_id )
                  {
                       IGRshort           matrix_type;
                       IGRlong            bsretcode;
                       IGRmatrix          matrix;
                       struct  ret_struct plane_def;
                       struct  GRid       NewPlaneId;
 
                       __DBGpr_com( " It's a VRPlane " );
                       status =
                       om$send( msg      = message NDnode.NDgive_structure
                                       ( &retcode, &plane_def, p_md_env ),
                                     targetid = buffer[j].objid,
                                     targetos = buffer[j].osnum );
                       as$status( action = RET_STATUS );

		       Normals[3*j]   = plane_def.var.ref_st.t[3];
		       Normals[3*j+1] = plane_def.var.ref_st.t[4];
		       Normals[3*j+2] = plane_def.var.ref_st.t[5];
 
#ifdef vdsDEBUG
        printf("\n\t Plane Object Id [%d,%d] ", buffer[j].objid,
                                                 buffer[j].osnum );
        printf("\n\t Plane Information :\n\tOrigin [%g,%g,%g] ",
                                                plane_def.var.ref_st.t[0],
                                                plane_def.var.ref_st.t[1],
                                                plane_def.var.ref_st.t[2] );
        printf("\n\t Normal [%g,%g,%g] \n", plane_def.var.ref_st.t[3],
                                           plane_def.var.ref_st.t[4],
                                           plane_def.var.ref_st.t[5] );
#endif
                       MAidmx( &bsretcode, matrix );
		       matrix[3] = me->origin[0] - plane_def.var.ref_st.t[0];
		       matrix[7] = me->origin[1] - plane_def.var.ref_st.t[1];
		       matrix[11]= me->origin[2] - plane_def.var.ref_st.t[2];

		       /* In the case of Farthest plane, it should be moved in
		       the directions normal to its normal. Alwin */
		       if( bFarthestPlane[j] )
                       {
			  IGRdouble disp_matrix[3], Delta=0.0, XYZ[3];

			  /* Find the distance to which the we have to move
			  the Fourth plane in both the directions other than
			  the Normal Direction of the plane */

			  disp_matrix[0] = matrix[3];
			  disp_matrix[1] = matrix[7];
			  disp_matrix[2] = matrix[11];
			  __DBGpr_vec( " Initial Displacement ", disp_matrix );
			  
			  /* Get the multiplication factor from the Common
			  plane normal */

			  Delta = BSdotp( &retcode, disp_matrix, &Normals[3] );
			  __DBGpr_dbl( " Multiplication Factor, Z", Delta );

			  /* These are new co-ordinates obtained by ( x + dx,
			  y + dy, z + dz ) */

			  XYZ[0] = plane_def.var.ref_st.t[0] + Delta*Normals[3];
			  XYZ[1] = plane_def.var.ref_st.t[1] + Delta*Normals[4];
			  XYZ[2] = plane_def.var.ref_st.t[2] + Delta*Normals[5];
			
			  Delta = BSdotp( &retcode, disp_matrix, &Normals[6] );
			  __DBGpr_dbl( " Multiplication Factor, Y", Delta );

			  /* New Origin of fourth plane */
			  XYZ[0] += Delta*Normals[6];
			  XYZ[1] += Delta*Normals[7];
			  XYZ[2] += Delta*Normals[8];

			  /* The actual translation to applied for the fourth
			  plane is obtained by finding the differnce between
			  the new co-ordinate ( XYZ ) and the old origin
			  of the plane */

			  matrix[3] = XYZ[0] - plane_def.var.ref_st.t[0];
			  matrix[7] = XYZ[1] - plane_def.var.ref_st.t[1];
			  matrix[11]= XYZ[2] - plane_def.var.ref_st.t[2];
                       }
 
                       /* This is done to force the planes to recompute. Alwin*/
                       ASbroadcast_in_progress = FALSE;
 
                       status =
                       om$send ( msg = message GRgraphics.GRxform(
                                        &retcode, p_md_env, &matrix_type,
                                        matrix, &NewPlaneId.objid ),
                                    targetid = buffer[j].objid,
                                    targetos = buffer[j].osnum );
 
                       /* Reset the old_value, whatever it was */
                  }
               }
               break;
          } // Loop on CnrlSeg
     } // Loop on Nb of Childrens
  }
skip_additonal_compute :
#endif
  ASbroadcast_in_progress = old_flag;
 
  /* added by alwin ...for TR179800791 */
 
  End
  return OM_S_SUCCESS;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                method NDcopy_to_root
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDcopy_to_root( 	IGRlong *msg; IGRint cp_type; struct GRmd_env *md_env,*new_info;
  			struct GRid *newobjid )
{
  IGRint	status;

  SetProc( VRDepPlane_NDcopy_to_root ); Begin
  *msg = MSSUCC;

  status =
  om$send( msg      = message NDnode.NDcopy
			( msg, cp_type, md_env, new_info, newobjid ),
                    targetid = my_id );
  as$status(action = RET_STATUS);

  /*"newobjid = %d %d\n", newobjid->osnum, newobjid->objid */

  status =
  om$change_class( osnum     = newobjid->osnum,
		   objid     = newobjid->objid,
		   classname = "VRplane" );
  as$status ( action = RET_STATUS );	

  status =
  om$send( msg      = message VRplane.VRchg_plane_state
			( VR_FIXED_PLANE, ~VR_FIXED_PLANE ),
	targetid = newobjid->objid,
	targetos = newobjid->osnum );
  as$status(action = RET_STATUS);

  End
  return OM_S_SUCCESS;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method NDnotify_disconnect
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDnotify_disconnect( struct GRid previous_connected )
{
	IGRlong			retcode, status, NumberOfBytes, BytesReceived;
	struct	GRmd_env	md_env;

        SetProc( VRDepPlane_NDnotify_disconnect ); Begin
  	NumberOfBytes = sizeof( struct GRmd_env );
  	status = gr$get_model_env( 	msg    = &retcode,
			     		sizbuf = &NumberOfBytes,
			     		buffer = &md_env,
			     		nret   = &BytesReceived );
  	as$status( action = RET_STATUS );
  	as$status( sts = retcode, action = RET_STATUS );
   
  	/*"module_info = %d %d\n", md_env.md_id.objid, md_env.md_id.osnum */

	status = om$send( msg      = message GRgraphics.GRdelete( &retcode, &md_env ),
			  targetid = my_id );
	as$status();

        End
	return OM_S_SUCCESS;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method GRgetobjinfo                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRgetobjinfo
  (
  IGRlong           *p_msg;         /* OUT    Returned code                   */
  struct GRobj_info *p_info         /* OUT    Returned information            */
  )
  /*
  DESCRIPTION: Get the object information
  */
  {
  SetProc( VRDepPlane_GRgetobjinfo ); Begin
  *p_msg = MSSUCC;
  strcpy(p_info->type,"Dependent Plane");
  End
  return(OM_S_SUCCESS);
}/* end GRgetobjinfo */


method NDmove_to_root (IGRlong *msg; struct GRid *src_grid;
                        struct GRmd_env *md_env)
{
  struct GRid     MyId;

  SetProc( VRDepPlane_NDmove_to_root ); Begin
  *msg = MSSUCC;

  /* -- Delete via batch -- */
  MyId.objid = my_id;
  MyId.osnum = OM_Gw_current_OS;

  nd$wait_batch( type       = GR_DELETED,
                 l_object   = &MyId,
                 nb_obj     = 1 );

  End
  return OM_S_SUCCESS;
}

end implementation VRDepPlane;
