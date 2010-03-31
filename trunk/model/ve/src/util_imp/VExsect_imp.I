
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:02 $
$Locker:  $
*/

class implementation Root;

#define CHECK_RETURN_CODES 1

#include <stdio.h>

#include "bs.h"
#include "bsparameters.h"

#include "OMerrordef.h"

#include "madef.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"

#include "igewindef.h"

#include "msdef.h"

#include "dpdef.h"
#include "dpstruct.h"

#include "gr.h"
#include "godef.h"
#include "go.h"

#include "emsbool.h"
#include "emssfintdef.h"
#include "emsdef.h"
#include "emsedgedef.h"
#include "EMSopt.h"

#include "EMSmsgdef.h"
#include "EMS_I.h"
#include "EMS_E.h"
#include "EMS_F.h"

#include "vedef.h"
#include "ve.h"
#include "ve_inst.h"
#include "veerr.h"
#include "vemsg.h"

#include "msmacros.h"

/* prototype files */
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"

#include "bsalloccv.h"
#include "bsfreecv.h"
#include "bsmerge_cv.h"
#include "mainvmx.h"

from GRgraphics   import GRgetrang;
from GRgraphics   import GRdelete;
from GRvg         import GRgenabsg;
from GRvg         import GRchgcolor;
from EMSproject   import EMplace_surface_of_projection;
from EMSsfsolid   import EMcap_thyself;
from EMSsfboolean import EMboolean;
from EMSdpr       import EMundo;
from EMSsurface   import EMgetSurfsOfPrim;

extern OMuword OPP_EMSsfsolid_class_id;
extern OMuword OPP_EMSproject_class_id;
extern OMuword OPP_EMSslboolean_class_id;


/*--- VEget_object_viewing_range ----------------------------------------------*/

void VEget_object_viewing_range( OM_S_OBJID objid,
				 OMuword    osnum,
				 IGRmatrix  matrix,
				 IGRshort   matrix_type,
				 GRrange    range )

/*
DESCRIPTION
	This function gets the viewing coordinate range of an object
	given its object id, object space number and environment.

HISTORY
	S.P. Rogers  12/20/89  Creation Date
*/

	{
	IGRboolean apply_mat;
	IGRlong    msg, sts;
	IGRint     x,y,z;
	IGRdouble  range_cube[24], *range_cube_ptr;

	apply_mat = 1;
	sts = om$send( msg      = message GRgraphics.GRgetrang( &msg, &matrix_type, matrix,
	                                                        &apply_mat, range ),
	               targetid = objid,
	               targetos = osnum,
	               senderid = NULL_OBJID );

	/* build the range cube out of the two range points */
	range_cube_ptr = (IGRdouble *)range_cube;
        for ( x=0; x<6; x+=3 )
	   for ( y=1; y<6; y+=3 )
	      for ( z=2; z<6; z+=3 )
                 {
	         *range_cube_ptr++ = range[x];
	         *range_cube_ptr++ = range[y];
	         *range_cube_ptr++ = range[z];
	         }

	/* get the range of the eight points in viewing coordinates */
	VEget_range( 8, range_cube, NULL, range, TRUE );

	}  /* VEget_object_viewing_range */


/*--- VEconstruct_sectioning_curve -------------------------------------------------*/

void VEconstruct_sectioning_curve( curve_grid, curve_env,
	                           solid_range, proj_pt0, proj_pt1,
	                           save_side_dir, curve_geom )

	struct GRid         *curve_grid;
	struct GRmd_env     *curve_env;
	IGRdouble           solid_range[6];
	IGRdouble           proj_pt0[3];
	IGRdouble           proj_pt1[3];
	IGRint              save_side_dir;
	struct IGRbsp_curve **curve_geom;

/*
DESCRIPTION
	Given a planar curve, the range of a solid and a direction to save,
	this function creates a closed curve that can be used to define a
	solid of projection which can be differenced from the original
	solid to simulate cross-sectioning.  The closed curve is created
	by extending the input curve outside the range of the solid and the
	range of the input curve in he appropriate directions.

HISTORY
	S.P. Rogers  12/20/89  Creation Date
*/

	{
	IGRlong             sts,msg,rc;
	IGRint              ii;
	IGRint              poles_minus_one;
	IGRdouble           curve_z, proj_len;
	struct IGRbsp_curve *temp_curve;
	IGRdouble           end_pt0[3], end_pt1[3];
	IGRdouble           y_extend;
	IGRdouble           curve_range[6];
	IGRdouble           stack_poles[12];
	IGRdouble           stack_knots[6];
	struct IGRbsp_curve line_string;

	/* fill in the line-string structure for an order 2, 4 pole curve */
	line_string.order = 2;
	line_string.periodic = line_string.non_uniform = FALSE;
	line_string.num_poles = 4;
	line_string.poles = stack_poles;
	line_string.num_knots = 6;
	line_string.knots = stack_knots;
	line_string.rational = FALSE;
	line_string.weights = NULL;
	line_string.planar = TRUE;
	line_string.phy_closed = FALSE;
	line_string.num_boundaries = 0;
	line_string.bdrys = NULL;

	/* get the range of the sectioning curve */
	VEget_object_viewing_range( curve_grid->objid, curve_grid->osnum, 
	                            curve_env->md_env.matrix, curve_env->md_env.matrix_type, curve_range );

	/* get the sectioning curve geometry */
	sts = om$send( msg      = message GRvg.GRgenabsg( &msg,
	                                                  &curve_env->md_env.matrix_type,
	                                                  curve_env->md_env.matrix,
	                                                  (IGRchar **)&temp_curve ),
	               targetid = curve_grid->objid,
	               targetos = curve_grid->osnum,
	               senderid = NULL_OBJID );

	   OM_ERRCHK( sts, "GRvg.GRgenabsg for send sectioning curve failed" );
	   MSG_ERRCHK( msg, "GRvg.GRgenabsg for sectioning curve failed" );

	/* copy and transform curve to viewing coordinates */
	VEcopy_and_trans_to_view( (IGRchar **)&temp_curve, CURVE );

	/* set the Z's of the sectioning curve to be just outside solid range */
	curve_z = solid_range[5] + (solid_range[5] - solid_range[2]) * 0.05;
	if (  temp_curve->rational )
	   {
	   for ( ii = 0; ii < temp_curve->num_poles; ii++ )
	      temp_curve->poles[ ii * 3 + 2 ] = curve_z * temp_curve->weights[ii];
	   }
	else
	   {
	   for ( ii = 0; ii < temp_curve->num_poles; ii++ )
	      temp_curve->poles[ ii * 3 + 2 ] = curve_z;
	   }

	if ( ! temp_curve->phy_closed )
	   {
	   /* calculate the y-value to extend the sectioning curve to */
	   if ( save_side_dir == -1 )
	      {
	      /* User wants to save in the direction of decreasing Y in DITS.  In DITS, this */
	      /* direction is up (toward the top of the screen).  In the viewing coordinate  */
	      /* system used by VE, Y decreases as you move down so the user wants to save   */
	      /* in the direction of increasing Y in viewing coordinates.  We, therefore,    */
	      /* want to extend the sectioning curve a little past the smallest Y-min of the */
	      /* solid and the sectioning curve.  The sectioning curve range is used so we   */ 
	      /* don't construct a curve that intersects itself.                             */
	      if ( solid_range[1] < curve_range[1] )
	         y_extend = solid_range[1] - (solid_range[4] - solid_range[1]) * 0.05;
	      else
	         y_extend = curve_range[1] - (solid_range[4] - solid_range[1]) * 0.05;
	      }
	   else
	      {
	      /* User wants to save in the direction of increasing Y in DITS.  In DITS, this      */
	      /* direction is down (toward the bottom of the screen).  In the viewing             */
	      /* coordinate system used by VE, Y decreases as you move down so the user wants     */
	      /* to save in the direction of decreasing Y in viewing coordinates. We, therefore,  */
	      /* want to extend the sectioning curve a little past the largest Y-max of the solid */
	      /* and the sectioning curve.  The sectioning curve range is used so we don't        */
	      /* construct a curve that intersects itself.                                        */
	      if ( solid_range[4] > curve_range[4] )
	         y_extend = solid_range[4] + (solid_range[4] - solid_range[1]) * 0.05;
	      else
	         y_extend = curve_range[4] + (solid_range[4] - solid_range[1]) * 0.05;
	      }

	   /* get the end-points of the sectioning curve */
	   poles_minus_one = temp_curve->num_poles - 1;

	   end_pt0[0] = temp_curve->poles[0];
	   end_pt0[1] = temp_curve->poles[1];
	   end_pt0[2] = temp_curve->poles[2];

	   end_pt1[0] = temp_curve->poles[ poles_minus_one * 3 ];
	   end_pt1[1] = temp_curve->poles[ poles_minus_one * 3 + 1 ];
	   end_pt1[2] = temp_curve->poles[ poles_minus_one * 3 + 2 ];

	   if ( temp_curve->rational )
	      {
	      end_pt0[0] /= temp_curve->weights[0];
	      end_pt0[1] /= temp_curve->weights[0];
	      end_pt0[2] /= temp_curve->weights[0];

	      end_pt1[0] /= temp_curve->weights[poles_minus_one];
	      end_pt1[1] /= temp_curve->weights[poles_minus_one];
	      end_pt1[2] /= temp_curve->weights[poles_minus_one];
	      }

	   /* construct linestring to merge with sectioning curve */
	   stack_poles[0] = end_pt0[0];
	   stack_poles[1] = end_pt0[1];
	   stack_poles[2] = end_pt0[2];

	   stack_poles[3] = end_pt0[0];
	   stack_poles[4] = y_extend;
	   stack_poles[5] = end_pt0[2];

	   stack_poles[6] = end_pt1[0];
	   stack_poles[7] = y_extend;
	   stack_poles[8] = end_pt1[2];

	   stack_poles[9]  = end_pt1[0];
	   stack_poles[10] = end_pt1[1];
	   stack_poles[11] = end_pt1[2];

	   stack_knots[0] = stack_knots[1] = 0.0;
	   stack_knots[2] = 1.0 / 3.0;
	   stack_knots[3] = 2.0 / 3.0;
	   stack_knots[4] = stack_knots[5] = 1.0;

	   /* worst case allocation for merging 'temp_curve' with an order 2, 4 pole curve */
	   BSalloccv( temp_curve->order, temp_curve->num_poles + 4 + (4 * (temp_curve->order - 2)),
	              temp_curve->rational, 0, curve_geom, &rc );

	   if ( rc != BSSUCC )
	      fprintf( stderr, "CURVE ALLOCATION FAILED\n" );

	   /* merge section curve and line string to yield a closed curve */
	   BSmerge_cv( &rc, temp_curve, &line_string, *curve_geom );

	   if ( rc != BSSUCC )
	      fprintf( stderr, "CURVE MERGE FAILED\n" );

	   /* free the sectioning curve geometry */
	   BSfreecv( &rc, temp_curve );
	   }  /* end: if ( ! temp_curve->phy_closed ) */
	else
	   {
	   /* The sectioning curve is already closed = use it without modification */
	   *curve_geom = temp_curve;
	   }

	/* transform curve back to world coordinates */
	VEtrans_to_world_without_projecting( (IGRchar *)*curve_geom, CURVE );

	/* setup projection vector that will project the curve */
	/* through the range of the solid in Z                 */
	proj_len = (solid_range[5] - solid_range[2]) + (solid_range[5] - solid_range[2]) * 0.1;

	line_string.num_poles = 2;
	line_string.num_knots = 4;

	stack_knots[2] = stack_knots[3] = 1.0;

	stack_poles[0] = stack_poles[1] = 0.0;
	stack_poles[2] = curve_z;
	stack_poles[3] = stack_poles[4] = 0.0;
	stack_poles[5] = curve_z - proj_len;

	/* transform projection vector to world coordinates */
	VEtrans_to_world_without_projecting( (IGRchar *)&line_string, CURVE );
	
	/* copy projection points from temporary line structure */
	proj_pt0[0] = stack_poles[0];
	proj_pt0[1] = stack_poles[1];
	proj_pt0[2] = stack_poles[2];

	proj_pt1[0] = stack_poles[3];
	proj_pt1[1] = stack_poles[4];
	proj_pt1[2] = stack_poles[5];

	}  /* VEconstruct_sectioning_curve */


/*--- VEconstruct_solid_of_projection ---------------------------------------------*/

void VEconstruct_solid_of_projection( struct IGRbsp_curve *curve,
				      IGRdouble           proj_pt0[3], 
				      IGRdouble           proj_pt1[3],
				      struct IGRdisplay   *active_display,
				      IGRshort            active_level,
				      struct GRmd_env     *sect_solid_env,
				      struct GRid         *solid_grid )
	
/*
DESCRIPTION
	Given a curve and two points defining a projection vector, this function
	constructs a solid of projection and returns its object id and object
	space number.  The curve must be planar and physically closed.

HISTORY
	S.P. Rogers  12/20/89  Creation Date
*/

	{
	IGRlong               sts;
	IGRlong               msg;
	IGRshort              dim;  /* Sun Fix - S.P. Rogers  10/31/91 */
	IGRdouble             i_matrix[4][4];
	IGRdouble             *matrix;
	GRobjid               temp_id, project_id;
	struct GRvg_construct construct_list;
	struct IGResbs        class_attr;
	struct GRmd_env       id_env;


	/* set up identity environment for constructing the solid of projection */
	id_env.md_id.objid = sect_solid_env->md_id.objid;
	id_env.md_id.osnum = sect_solid_env->md_id.osnum;

	id_env.md_env.matrix_type = MAIDMX;
	matrix =  (IGRdouble *) id_env.md_env.matrix;
	matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1.0;

	matrix[1]   = matrix[2]   = matrix[3]  =
	matrix[4]   = matrix[6]   = matrix[7]  =
	matrix[8]   = matrix[9]   = matrix[11]  =
	matrix[12]  = matrix[13]  = matrix[14]  = 0.0;

	/* transform the curve and projection points into the environment of the      */
	/* solid to be sectioned by inverting the environment matrix and transforming */
	/* the poles of the curve with the inverse                                    */
	dim = 4;
	MAinvmx( &msg, &dim, sect_solid_env->md_env.matrix, (IGRdouble *)i_matrix );

	VEtransform_3D_points( i_matrix,
	                       curve->num_poles, curve->poles,
	                       (curve->rational) ? curve->weights : NULL );

	VEtransform_3D_points( i_matrix, 1, proj_pt0, NULL );
	VEtransform_3D_points( i_matrix, 1, proj_pt1, NULL );

	solid_grid->osnum = sect_solid_env->md_id.osnum;

	class_attr.u_rules = (IGRlong) 0;
	class_attr.v_rules = (IGRlong) 0;
	class_attr.is_polydis = FALSE;
	class_attr.is_surfdis = TRUE; 
	class_attr.is_slowdis = FALSE;

	construct_list.newflag = FALSE;
	construct_list.display = active_display;
	construct_list.geometry = NULL;
	construct_list.class_attr = (IGRchar *) &class_attr;
	construct_list.msg = &msg;
	construct_list.env_info = &id_env;
	construct_list.level = active_level;
	construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
	construct_list.name = NULL;

	/* construct a surface of projection using the curve and projection points */
	/* $$$$$ OPTIMIZATON:  Call EMS function to determine the type of $$$$$ */
	/* $$$$$ the curve instead of defaulting it to EMfreeform_curve   $$$$$ */
	sts = om$construct( classid  = OPP_EMSproject_class_id,
	                    msg      = message EMSproject.EMplace_surface_of_projection( &construct_list,
	                                                                                 NULL,
	                                                                                 &id_env,
	                                                                                 curve,
	                                                                                 EMfreeform_curve,
	                                                                                 proj_pt0,
	                                                                                 proj_pt1,
	                                                                                 TRUE,
	                                                                                 &project_id ),
	                     p_objid = &temp_id,
	                     osnum   = solid_grid->osnum );

	/* construct a solid object and have it cap the */
	/* surface of projection for its geometry       */
	sts = om$construct( classid = OPP_EMSsfsolid_class_id,
	                    msg     = message EMSsfsolid.EMcap_thyself( &msg,
	                                                                &construct_list,
 	                                                                &project_id ),
	                    p_objid = &solid_grid->objid,
	                    osnum   = solid_grid->osnum );

	}  /* VEconstruct_solid_of_projection */


/*--- VEdifference_solids_for_xsection ----------------------------------------------*/

void VEdifference_solids_for_xsection(  struct GRid       *sect_solid,
					struct GRmd_env   *sect_env,
					struct GRid       *proj_solid,
					struct IGRdisplay *active_display,
					IGRshort          active_level,
					struct GRid       *master_module_grid,
					struct GRid       *bool_id )

	{
	IGRlong               sts;
	IGRlong               msg;
	struct GRvg_construct construct_list;
	IGRlong               eventmsg;
	IGRchar               status_str[54];
	IGRushort             optionsEMboolean;
	enum EMSbooltype      type;
	struct GRmd_env       display_env;

	/* setup display environment */
	display_env = *sect_env;
	display_env.md_id.objid = master_module_grid->objid;
	display_env.md_id.osnum = master_module_grid->osnum;

	type = EMSbool_difference;
	optionsEMboolean = EMSsfbool_opt_display | EMSsfbool_opt_HandleStop;

	bool_id->osnum = sect_solid->osnum;

	strcpy( status_str, "Sectioning Solid" );

	construct_list.msg = &msg;
	construct_list.env_info = sect_env;  /* should be display_env if display is to work, but boolean */
	construct_list.newflag = FALSE;      /* will only work if it is sect_env                         */
	construct_list.geometry = NULL;
	construct_list.class_attr = NULL;
	construct_list.level = active_level;
	construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
	construct_list.display = active_display;
	construct_list.name = NULL;

	sts = om$construct( classid = OPP_EMSslboolean_class_id,
	                    p_objid = &bool_id->objid,
	                    osnum   = bool_id->osnum );

	sts = om$send( msg = message EMSsfboolean.EMboolean( &eventmsg,
	                                                     &sect_env->md_env.matrix_type,
	                                                     sect_env->md_env.matrix,
	                                                     sect_solid->objid, 1, &proj_solid->objid,
	                                                     &construct_list, type, 	
	                                                     optionsEMboolean, status_str, 
	                                                     NULL, NULL, NULL, NULL ), 
	               targetid = bool_id->objid,
	               targetos = bool_id->osnum,
	               senderid = NULL_OBJID );

	if ( (! sts & 1) || (! eventmsg & 1) ||
	     (eventmsg == EMS_I_NoIntersection) ||
	     (eventmsg == EMS_I_Interrupt) ) 
	   {
           /* for some reason, no intersection and no retry */
	   switch( eventmsg )
	      {
	      case EMS_I_Interrupt:
	         ex$message( msgnumb = VE_E_ProcIntrpt, 
			     field = ERROR_FIELD );
	         break;
	      case EMS_I_NoIntersection:
	         ex$message( msgnumb = VE_E_SecSolNoInter, 
			     field = ERROR_FIELD );
	         break;
	      default:
	         ex$message( msgnumb = VE_E_OperFail, 
			     field = ERROR_FIELD );
	      }  

	   if (eventmsg != EMS_E_BoolFail)
	      {
	      sts = om$send( msg = message Root.delete( NULL ),
	                     targetid = bool_id->objid,
	                     targetos = bool_id->osnum,
	                     senderid = NULL_OBJID );

	      bool_id->objid = NULL_OBJID;
	      }
	   }        

	}  /* VEdifference_solids_for_xsection */


/*--- VEundo_xsection_booleans --------------------------------------------*/

void VEundo_xsection_booleans( num_solids_sectioned,
	                       diff_grids, solid_envs, proj_grids, master_module_grid )

	IGRint          num_solids_sectioned;
	struct GRid     *diff_grids;
	struct GRmd_env *solid_envs;
	struct GRid     *proj_grids;
	struct GRid     *master_module_grid;

	{
	IGRlong         sts, msg;
	IGRint          ii, jj;
	GRobjid         *display_ids;
	IGRint          display_count;
	IGRint          invoke_count;
	IGRuint         rgb;
	IGRushort       index;
	IGRushort       options;
	IGRint          num_comps;
	IGRint          num_active;
	GRobjid         *comp_ids;
	struct GRmd_env display_env;

	options = EMS_UNDO_DELETE | EMS_DO_DISPLAY | EMS_DELETE_DPR;
	rgb = 0;
	index = DP_INVISIBLE_COLOR;

	for ( ii = 0; ii < num_solids_sectioned; ii++ )
	   {
	   /* setup display environment */
	   display_env = solid_envs[ii];
	   display_env.md_id.objid = master_module_grid->objid;
	   display_env.md_id.osnum = master_module_grid->osnum;


	   /* make the solid of projection invisible so it won't show */
	   /* up when the sectioning boolean is undone                */

	   /* get the surfaces that make up the solid of projection */
	   comp_ids = NULL;
	   num_comps = num_active = 0;
	   sts = om$send( msg      = message EMSsurface.EMgetSurfsOfPrim( &msg, NULL_OBJID, &comp_ids,
	                                                                  &num_comps, &num_active ),
	                  targetid = proj_grids[ii].objid,
	                  targetos = proj_grids[ii].osnum,
	                  senderid = NULL_OBJID );

	      OM_ERRCHK( sts, "VEundo_xsection_booleans: EMSsurface.EMgetSurfsOfPrim send failed" );
	      MSG_ERRCHK( msg, "VEundo_xsection_booleans: EMSsurface.EMgetSurfsOfPrim failed" );

	   for ( jj = 0; jj < num_comps; jj++ )
	      {
	      sts = om$send( msg      = message GRvg.GRchgcolor( &msg, &rgb, &index ),
	                     targetid = comp_ids[jj],
	                     targetos = proj_grids[ii].osnum,
	                     senderid = NULL_OBJID );

	         OM_ERRCHK( sts, "VEundo_xsection_booleans: GRvg.GRchgcolor send failed" );
	         MSG_ERRCHK( msg, "VEundo_xsection_booleans: GRvg.GRchgcolor failed" );
	      }  /* end: for ( jj ... */

	   if ( comp_ids )
	      {
	      om$dealloc( ptr = comp_ids );  /* space allocated with om$malloc() */
	      }

	   /* undo the sectioning boolean */
	   display_ids = NULL;
	   display_count = invoke_count = 0;
	   sts = om$send( msg      = message EMSdpr.EMundo( &msg,
	                                                    &options,
	                                                    &display_env,
	                                                    NULL, NULL, NULL,
	                                                    &display_ids,
	                                                    &display_count,
	                                                    &invoke_count ),

	                  targetid = diff_grids[ii].objid,
	                  targetos = diff_grids[ii].osnum,
	                  senderid = NULL_OBJID );

	      OM_ERRCHK( sts, "VEundo_xsection_booleans: EMSdpr.EMundo send failed" );
	      MSG_ERRCHK( msg, "VEundo_xsection_booleans: EMSdpr.EMundo failed" );
	   
	   /* delete the solid of projection */
	   sts = om$send( msg      = message GRgraphics.GRdelete( &msg, &solid_envs[ii] ),
	                  targetid = proj_grids[ii].objid,
	                  targetos = proj_grids[ii].osnum,
	                  senderid = NULL_OBJID );

	      OM_ERRCHK( sts, "VEundo_xsection_booleans: GRgrahpics.GRdelete send failed" );
	      MSG_ERRCHK( msg, "VEundo_xsection_booleans: GRgrahpics.GRdelete failed" );

	   }  /* end: for ( ii ... */

	}  /* VEundo_xsection_booleans */

end implementation Root;
