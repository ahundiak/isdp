command_string	IDFFC_M_ADDRWPLS,0,IDInsPls
class		IDinspls
super_class	IDdisp_poly
super_class	IDundo
super_class	ECcmd
spec_path	"$MODEL/spec"
product_name	"$MODEL"

specification

/*
Abstract
	This command object modifies an element by inserting a row of poles.

History

	04/09/92	JSY - Added ele_spec_att to dp$build_dis_buffer
			to properly initialize struct IGResbc entry.
			There was a core dump before doing this initialization.
	07/14/92	JSY - Added option to add a row of poles and change
			surface shape.
	09/17/92	JSY - Change function calls turn_poly_on and
			turn_poly_off to get rid of the parameter objid.
			Also not to TRUE and FALSE instead include OMtypes.h.
*/
#include "IDdyn.h"

instance
{
  IGRshort cmd_type;
  IGRpoint proj_pt;
  IGRdouble u_par, v_par;
  IGRshort pole_direction;  	/* 0: U  or   1:  V direction */
  struct IGRdisplay cv_disp, sf_disp, poly_disp, pt_disp;
  struct IGResbc cv_attr;
  struct IGResqbs sf_attr;
  IGRdouble *u_rules, *v_rules;
  IGRint *u_bounds, *v_bounds;
  IGRint num_poles;
  IGRdouble *row_poles;
  struct DP_sfisocv dyn_isocv;
  struct DP_sfinspls dyn_inspls;
}


implementation
/*
Abstract

Algorithm

*/

/*      ************ */


#include "EMS.h"
#include <stdio.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "lcmacros.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "emsdef.h"
#include "lcdef.h"
#include "lc.h"
#include "emserr.h"
#include "ECcmd_def.h"
#include "EMSssprops.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsconic.h"
#include "adpdef.h" 
#include "IDffmsg.h"
#include "IDffcmd.h"
#include "grmacros.h"
#include "alloca.h"
#include "exms.h" 
#include "msdef.h"
#include "msmacros.h" 
#include "grmessage.h" 
#include "dpstruct.h"
#include "IDdyn.h"
#include "dperr.h" 
#include "IDinsplsi.h"    /* prototypes */
#include "bsalloccv.h"    /* prototypes */
#include "bsallocsf.h"    /* prototypes */
#include "bsconstprcv.h"    /* prototypes */
#include "bsfreecv.h"    /* prototypes */
#include "bsfreesf.h"    /* prototypes */
#include "bsinspolsf1.h"    /* prototypes */
#include "bsinspolsf2.h"    /* prototypes */
#include "bsmdstptarr.h"    /* prototypes */
#include "bssf_copy.h"    /* prototypes */
#include <memory.h>    /* prototypes */


#define EMS_CK_TANGENCY 101
#define IDRMPL_SURFACE	0
#define U_DIRECTION		0
#define V_DIRECTION		1
#define BOTH_UV_DIRECTION	2
#define ID_SURFACE_GEOM		1
#define ID_CURVE_GEOM		0
#define DYN_PTONSURF		101
#define DYN_INSPOLES		102
#define NO_SHPCHG		10001

from GRgraphics import GRdisplay;
from GRvg	import GRgetattr, GRgetsize, GRgetgeom, GRpostabsg;

/*----------------------------------------------------------------------*
 * Function to do iso curve dynamics                                    *
 *----------------------------------------------------------------------*/
#argsused
IGRint IDdyn_isocv(
        struct DP_sfisocv *DYinfo, 
        struct EX_button *point, 
        IGRdouble *matrix, 
        struct GRid **objects, 
        IGRint *num_objects, 
        struct DPele_header **buffers, 
        IGRint *num_buffers, 
        IGRchar *dummy_in1, IGRchar *dummy_in2, IGRchar *dummy_in3, 
        IGRchar *dummy_out1, IGRchar *dummy_out2, IGRchar *dummy_out3)
{
  struct GRevent event;
  GRobjid stupid_id = NULL;
  struct IGRbsp_curve *isocv;
  IGRboolean test_planar = FALSE;
  IGRshort iso_opt;
  IGRdouble uv_par;
  IGRlong msg;
  extern IGRlong EFpoint_on_object();

  /* initialize */
  event.event.button = *point;
  isocv = DYinfo->header[0].geometry.bspcurve;

  /* project the point */
  EFpoint_on_object( DYinfo->loc_obj, &event, stupid_id, &msg );

  /* assign the projected point */
  memcpy( (char *) DYinfo->header[1].geometry.point_set->points,
	  (char *) &( event.event.button.x ), sizeof( IGRpoint ));
  
  /* extract iso curve */
  if ( DYinfo->pole_direction == U_DIRECTION )
  {
    uv_par = event.located_object[0].geom_parms.v;
    iso_opt = 2;
  }
  else
  {
    uv_par = event.located_object[0].geom_parms.u;
    iso_opt = 1;
  }

  if ( uv_par < 0.0 || uv_par > 1.0 )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_PjtPtOutSf );
    *num_buffers = 0;
  }
  else
  {
    BSconstprcv( &msg, DYinfo->bspsf, &iso_opt, &uv_par, &test_planar, isocv );
    memcpy( (char *) DYinfo->proj_pt, (char *) &( event.event.button.x ),
	    sizeof( IGRpoint ));
  }

  *buffers = DYinfo->header;
  *num_buffers = 2;
  
  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------*
 * Function to do insert row of poles dynamics                          *
 *----------------------------------------------------------------------*/
#argsused
IGRint IDdyn_inspls(
        struct DP_sfinspls *DYinfo, 
        struct EX_button *point, 
        IGRdouble *matrix, 
        struct GRid **objects, 
        IGRint *num_objects, 
        struct DPele_header **buffers, 
        IGRint *num_buffers, 
        IGRchar *dummy_in1, IGRchar *dummy_in2, IGRchar *dummy_in3, 
        IGRchar *dummy_out1, IGRchar *dummy_out2, IGRchar *dummy_out3)
{
  IGRdouble dist;
  IGRint ind1;
  IGRlong msg;

  /* initialize */
  DYinfo->cur_pt[0] = point->x;
  DYinfo->cur_pt[1] = point->y;
  DYinfo->cur_pt[2] = point->z;

  /* make a copy of the input surface */
  BSsf_copy( &msg, DYinfo->surf, DYinfo->header[0].geometry.bspsurf );

  /* make a copy of the row of poles */
  memcpy( (char *)DYinfo->header[1].geometry.polyline->points, 
	  (char *)DYinfo->ins_poles, DYinfo->num_poles * sizeof( IGRpoint ));

  /* find out which pole to replace */
  BSmdstptarr( 1, &(DYinfo->cur_pt), DYinfo->num_poles,
	       ( IGRpoint * ) DYinfo->header[1].geometry.polyline->points,
	       &ind1, &DYinfo->index, &dist, &msg );
  memcpy( (char *)(DYinfo->header[1].geometry.polyline->points + 
    DYinfo->index * 3), (char *)DYinfo->cur_pt, sizeof( IGRpoint ));

  /* insert a row of poles */
  if ( DYinfo->pole_direction == U_DIRECTION )
    BSinspolsf1( DYinfo->header[0].geometry.bspsurf, BSULEFTBND,
		 DYinfo->header[1].geometry.polyline->points,
		 DYinfo->num_poles,
		 (IGRpoint *)DYinfo->header[1].geometry.polyline->points, 
                &msg );
  else
    BSinspolsf1( DYinfo->header[0].geometry.bspsurf, BSVLEFTBND,
		 DYinfo->header[1].geometry.polyline->points,
		 DYinfo->num_poles,
		 (IGRpoint *)DYinfo->header[1].geometry.polyline->points, 
                &msg );

  *buffers = DYinfo->header;
  *num_buffers = 2;

  return OM_S_SUCCESS;
}

state_table
#include "OMtypes.h"
#include <msdef.h>
#include <ECcmd_def.h>
#include "IDffmsg.h"
#include "IDffcmd.h"
#define EMS_CK_TANGENCY 101
#define IDRMPL_SURFACE	0
#define U_DIRECTION		0
#define V_DIRECTION		1
#define BOTH_UV_DIRECTION	2
#define ID_SURFACE_GEOM		1
#define ID_CURVE_GEOM		0
#define DYN_PTONSURF		101
#define DYN_INSPOLES		102
#define NO_SHPCHG		10001

at wakeup
  do turn_poly_on(&me->ret,
		  ID_SURFACE_GEOM,
		  &me->located_obj[0],
		  TRUE)
  do message_key IDFFC_M_ADDRWPLS

at sleep 
  do turn_poly_off(&me->ret, 
		   ID_SURFACE_GEOM,
		   &me->located_obj[0],
		   TRUE)

state start
  on CMD_TYPE = IDRMPL_SURFACE
    do message_key IDFFC_M_ADDRWPLS
    state start_id

state start_id
  on CMD_TYPE = IDRMPL_SURFACE
    do message_key IDFFC_M_ADDRWPLS
    do prompt_key IDFF_P_IdentSurf
    do relocate_key IDFF_E_RelocSurf
    do locate_class "EMSsubbs"
    state locate_ele

state locate_ele
  locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT | LC_ERASE_LOC_ELEMENT"
  locate_properties 29 /* locate locatable,displayable,read_write */
  locate_owner LC_FLEX_COMP /* locate flexible comp */
  locate_mask "GRm_DATA | GRm_BACK_UP | GRm_RESTART"
  accept_mask "GRm_DATA | GRm_RESTART"
  accept_key IDFF_P_AccptRejSurf
  filter locate
  on EX_BACK_UP
    state start_id
  on DATA
    do highlight_located 0 /* dehilited locate channel */
    do ECcmd.EMsave_located_object(&me->event1,
				   &me->located_obj[0])
    do turn_poly_on(&me->ret, 
		    ID_SURFACE_GEOM,
		    &me->located_obj[0],
		    TRUE)
    state decide_command

state decide_command
  status " "
  prompt_key IDFF_P_InsPlsOption
  filter get_event
  mask "GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP | GRm_RESTART"
  on EX_BACK_UP
    do turn_poly_off(&me->ret, 
		     ID_SURFACE_GEOM,
		     &me->located_obj[0],
		     TRUE)
    state start_id
  on EX_RJT_MOVEON
    do which_command(1)
    state decide_iso_curve
  on DATA
    do which_command(0)
    state decide_iso_curve

state decide_iso_curve
  prompt_key IDFF_P_DefRowPls
  dynamics DYN_PTONSURF
  filter get_event
  mask "GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP | GRm_RESTART"
  on EX_BACK_UP
    state decide_command
  on EX_RJT_MOVEON
    do toggle_row_direction()
    state decide_iso_curve
  on EX_DATA
    do set_up_command
    on RETURN_CODE = NO_SHPCHG
      do insert_pole
      state insert_no_shpchg
    state decide_row_poles

state insert_no_shpchg
  on MSFAIL
    do delete_saved_geom(ID_SURFACE_GEOM)
    state not_mod
  on ELSE
    state accept_new_surface

state decide_row_poles
  prompt_key IDFF_P_DefIndPole
  dynamics DYN_INSPOLES
  filter get_event
  mask "GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP | GRm_RESTART"
  on EX_BACK_UP
    do clean_storage()
    state decide_iso_curve
  on EX_RJT_MOVEON
    do insert_pole
    on MSFAIL
      do delete_saved_geom(ID_SURFACE_GEOM)
      state not_mod
      do turn_poly_off(&me->ret, 
		       ID_SURFACE_GEOM,
		       &me->located_obj[0],
		       TRUE)
      state accept_new_surface
  on EX_DATA
    do update_row_poles()
    state decide_row_poles

state accept_new_surface
  prompt_key IDFF_P_IdentSurf
  status_key IDFF_P_BckMovUndo
  filter get_event
  mask "GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP | GRm_RESTART"
  on EX_BACK_UP
    do restore_original_geometry(&me->ret,
				 &me->located_obj[0],
				 &me->located_obj[0].located_obj.objid)
    do delete_saved_geom(ID_SURFACE_GEOM)
    do status_key IDFF_M_SurfRestored
    do init_variables
    state start_id
  on EX_RJT_MOVEON
    do restore_original_geometry(&me->ret,
				 &me->located_obj[0],
				 &me->located_obj[0].located_obj.objid)
    do delete_saved_geom(ID_SURFACE_GEOM)
    do status_key IDFF_M_SurfRestored
    do init_variables
    state start_id
  on DATA		
    do delete_saved_geom(ID_SURFACE_GEOM)   
    do turn_poly_off(&me->ret,
		     ID_SURFACE_GEOM,
		     &me->located_obj[0],
		     TRUE)
    do init_variables
    do feed_event_back_to_locate
    state start_id

state not_mod
  status " "
  on CMD_TYPE = IDRMPL_SURFACE
    do status_key IDFF_E_SurfNotMod
    state start_id

/* ********************************************************************	*/
/* ********************************************************************	*/

action feed_event_back_to_locate
{
    long size = sizeof(struct GRevent) - sizeof(long) * 2;
    IGRint response = EX_DATA;
    IGRlong msg;

    status = ex$putque(msg= &msg, byte = &size, response = &response,
		       buffer = (IGRchar *) &ME.CEO_LOCATE->event1.event);
}

/* ********************************************************************	*/
action which_command( IGRshort cmd_type )
{
  me->cmd_type = cmd_type;
}

/* ********************************************************************	*/
action set_up_command
{
  struct IGRbsp_surface *sf = NULL;
  struct IGRbsp_curve *iso_cv = NULL;
  IGRdouble uv_par;
  IGRboolean test_planar = FALSE;
  IGRshort iso_opt;
  IGRlong msg;
  GRobjid stupid_id = NULL;
  extern IGRlong EMget_the_geometry();
  extern IGRlong EFpoint_on_object();
  
  /* get surface geometry */
  *sts = EMget_the_geometry( &me->located_obj[0], FALSE, FALSE, TRUE, my_id, &sf, &msg );
  if ( !( 1 & *sts ))
  {
    if ( sf )
      BSfreesf( &msg, sf );
    *sts = MSFAIL;
    goto quit;
  }
  
  /* project the point */
  EFpoint_on_object( &me->located_obj[0], &me->event1, stupid_id, &msg );

  /* copy projection point and its u and v to instance variables */
  memcpy( (char *)me->proj_pt, (char *)&( me->event1.event.button.x ),
	  sizeof( IGRpoint ));
  me->u_par = me->event1.located_object[0].geom_parms.u;
  me->v_par = me->event1.located_object[0].geom_parms.v;

  if ( me->cmd_type == 0 )
    me->ret = NO_SHPCHG;
  else
  {
    if ( me->pole_direction == U_DIRECTION )
    {
      me->num_poles = sf->u_num_poles;
      BSalloccv( sf->u_order, sf->u_num_poles, sf->rational, 0, &iso_cv, &msg );
      iso_opt = 2;
      uv_par = me->v_par;
    }
    else
    {
      me->num_poles = sf->v_num_poles;
      BSalloccv( sf->v_order, sf->v_num_poles, sf->rational, 0, &iso_cv, &msg );
      iso_opt = 1;
      uv_par = me->u_par;
    }

    if ( me->row_poles )
      om$dealloc( ptr = me->row_poles );
    me->row_poles = ( IGRdouble * ) om$malloc( size = me->num_poles * sizeof( IGRpoint ));
    if ( !me->row_poles )
    {
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
      *sts = MSFAIL;
      goto quit;
    }

    /* extract the iso curve */
    BSconstprcv( &msg, sf, &iso_opt, &uv_par, &test_planar, iso_cv );
    memcpy( (char *)me->row_poles, (char *)iso_cv->poles, 
	    me->num_poles * sizeof( IGRpoint ));

    /* free curve */
    BSfreecv( &msg, iso_cv );
  }

  if ( sf )
    BSfreesf( &msg, sf );
}

/* ********************************************************************	*/
/* This method dynamically shows the shape of the surface with new row  */
/* of poles inserted. 07/14/92 -- JSY                                   */
/* ********************************************************************	*/
action dynamics
{
  struct IGRbsp_surface *sf, *bspsurf;
  struct IGRbsp_curve *iso_cv;
  IGRlong msg;
  extern IGRlong EMget_the_geometry();

  /* get surface geometry */
  *sts = EMget_the_geometry( &me->located_obj[0], FALSE, FALSE, TRUE, my_id, &sf, &msg );
  if ( !( 1 & *sts ))
  {
    if ( sf )
      BSfreesf( &msg, sf );
    *sts = MSFAIL;
    goto quit;
  }
  
  switch ( dynamics )
  {
  case DYN_PTONSURF:
    {
      struct IGRpointset cur_pt;
      IGRpoint pt_coord;

      /* initialize */
      me->dyn_isocv.loc_obj = &me->located_obj[0];
      me->dyn_isocv.bspsf = sf;
      me->dyn_isocv.pole_direction = me->pole_direction;
    
      /* set up display buffer for the iso curve */
      if ( me->pole_direction == U_DIRECTION )
	BSalloccv( sf->u_order, sf->u_num_poles, sf->rational, 0, &iso_cv, &msg );
      else if ( me->pole_direction == V_DIRECTION )
	BSalloccv( sf->v_order, sf->v_num_poles, sf->rational, 0, &iso_cv, &msg );
      else
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_InvalidDir );
	*sts = MSFAIL;
	goto quit;
      }
      dp$build_dis_buffer( buffer = &me->dyn_isocv.header[0],
			   type = IGRBC,
			   display_att = &me->cv_disp,
			   ele_spec_att = &me->cv_attr,
			   geometry = ( struct IGRbsp_curve * ) iso_cv );

      /* set up display buffer for that point */
      cur_pt.num_points = 1;
      cur_pt.points = pt_coord;
      dp$build_dis_buffer( buffer = &me->dyn_isocv.header[1],
			   type = IGRPS,
			   display_att = &me->pt_disp,
			   geometry = ( struct IGRpointset * ) &cur_pt );

      /* start dynamics */
      dp$dynamics( dyn_fun = IDdyn_isocv,
		   information = &me->dyn_isocv );

      /* free memory */
      BSfreecv( &msg, iso_cv );
      BSfreesf( &msg, sf );

      break;
    }
  case DYN_INSPOLES:
    {
      struct IGRpolyline ctrl_poly;

      /* initialize */
      me->dyn_inspls.surf = sf;

      /* allocate surface for dynamics */
      BSallocsf( sf->u_order, sf->v_order, sf->u_num_poles, sf->v_num_poles,
		 sf->rational, sf->num_boundaries,
		 &bspsurf, &msg );

      /* set up display buffer for surface */
      dp$build_dis_buffer( buffer = &me->dyn_inspls.header[0],
			   type = IGRQS,
			   display_att = &me->sf_disp,
			   ele_spec_att = &me->sf_attr,
			   geometry = ( struct IGRbsp_surface * ) bspsurf );

      /* direction of the poles */
      me->dyn_inspls.pole_direction = me->pole_direction;

      me->dyn_inspls.num_poles = me->num_poles;
      me->dyn_inspls.ins_poles = me->row_poles;

      /* initialize polyline structure to display new row of poles */
      ctrl_poly.num_points = me->num_poles;
      ctrl_poly.points = ( IGRdouble * ) om$malloc( size = me->num_poles * sizeof( IGRpoint ));
      if ( !ctrl_poly.points )
      {
        ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	*sts = MSFAIL;
	goto quit;
      }

      /* build display buffer */
      dp$build_dis_buffer( buffer = &me->dyn_inspls.header[1],
			   type = IGRPY,
			   display_att = &me->poly_disp,
			   geometry = ( struct IGRpolyline * ) &ctrl_poly );

      /* start dynamics */
      dp$dynamics( dyn_fun = IDdyn_inspls,
		   information = &me->dyn_inspls );

      /* free buffer memory */
      BSfreesf( &msg, bspsurf );
      om$dealloc( ptr = ctrl_poly.points );
      BSfreesf( &msg, sf );

      break;
    }
  default:
    status = om$send( msg = message CEO.dynamics( dynamics, sts ),
		      mode = OM_e_wrt_message,
		      targetid = my_id );
    if ( !( 1 & status & *sts ))
      return OM_E_ABORT;
  }
}

/* ********************************************************************	*/
action clean_storage()
{
  if ( me->row_poles )
    om$dealloc( ptr = me->row_poles );
  me->row_poles = NULL;
}

/* ********************************************************************	*/
action update_row_poles()
{
  IGRlong msg;
  IGRdouble dist, *cur_pt;
  IGRint ind1, index;
    
  /* get the cursor point */
  cur_pt = (IGRdouble *) &me->event1.event.button.x;

  /* find out which pole to replace */
  BSmdstptarr( 1, ( IGRpoint * ) cur_pt, me->num_poles,
	       ( IGRpoint * ) me->row_poles,
	       &ind1, &index, &dist, &msg );
  /* copy back the changed pole */
  memcpy( ( char * ) ( me->row_poles + index * 3 ),
          ( char * ) cur_pt, sizeof( IGRpoint ));
}

/* ********************************************************************	*/
/*		------------------------------------------------------- */
action toggle_row_direction()
{
  switch(me->pole_direction)
  {
  case U_DIRECTION:
    me->pole_direction = V_DIRECTION;
    break;

  case V_DIRECTION:
    me->pole_direction = U_DIRECTION;
    break;

  default:
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_InvalidDir );
    break;
  }
}

/* *******************************************************************	*/
/* This method does the actual insert of the pole from the surface and	*/
/* then posts the new geometry. Erasure of old geometry and display	*/
/* of the new geometry is done too.					*/
/*	dependent on:							*/
/*		me->located_obj						*/
/*		me->event1						*/
/*		me->pt_on_surf						*/
/*		me->located_obj[0].located_obj.objid			*/
/*		------------------------------------------------------- */
action insert_pole
{
  struct IGRbsp_surface *sf;
  struct GRpost_info info;
  IGRlong msg;
  extern IGRlong EMget_the_geometry();

  /* get surface geometry */
  status = EMget_the_geometry( &me->located_obj[0], FALSE, FALSE, TRUE, my_id, &sf, &msg );
  if ( !( 1 & status ))
  {
    if ( sf )
      BSfreesf( &msg, sf );
    *sts = MSFAIL;
    goto quit;
  }

  /* erase the original object */
  gr$display_object( object_id = &me->located_obj[0].located_obj,
		     mode = GRbe );
  
  /* save the original geometry for undo */
  status = om$send( msg = message IDundo.save_original_geometry( &msg,
							         ( char * ) sf,
								 ID_SURFACE_GEOM ),
		    mode = OM_e_wrt_message,
		    targetid = my_id);

  /* insert a row of poles */
  if ( me->cmd_type == 0 )
    BSinspolsf2( sf, me->proj_pt, me->pole_direction, &msg );
  else
    BSinspolsf1( sf, 
        (me->pole_direction == U_DIRECTION ? BSULEFTBND : BSVLEFTBND ),
        me->row_poles, me->num_poles, (IGRpoint *)me->row_poles, &msg);
  if ( msg != BSSUCC )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_MAERR );
    return OM_E_ABORT;
  }

  /* post the updated geometry */
  info.construct_flag = TRUE;
  info.construct_flag = FALSE;
  status = om$send( msg = message GRvg.GRpostabsg( &msg,
						   &me->located_obj[0].module_info,
						   &info,
						   ( IGRchar * ) sf,
						   &me->located_obj[0].located_obj.objid ),
		    targetid = me->located_obj[0].located_obj.objid,
		    targetos = me->located_obj[0].located_obj.osnum );
  EMomerr_hndlr( status, ret_end, "GRpostabsg error\n" );
  EMerr_hndlr( EMis_error(msg), *sts, MSFAIL, ret_end );

  /* put this in to clear the object cache so that we show the new change */
  /* THIS WORKS, but try more efficient delete from cache 		    */
  /* 	GRabsg_del_all(); */
  GRabsg_del_by_objid( &me->located_obj[0].located_obj.objid,
		       &me->located_obj[0].located_obj.osnum );

  /* free memory */
  BSfreesf( &msg, sf );

ret_end:
  /* display the modified object */
  gr$display_object( object_id = &me->located_obj[0].located_obj,
		     mode = GRbd );
  
  if ( me->cmd_type == 1 )
  {
    if ( me->row_poles )
      om$dealloc( ptr = me->row_poles );
    me->row_poles = NULL;
  }
}

/* ********************************************************************	*/
/* This method exists so that we can initialize, and just as 		*/
/* importantly, REinitialize our variables.				*/
/*	--------------------------------------------------------------- */
action init_variables
{
  IGRint i;
  IGRlong sizbuf, nret, msg;
  
  me->located_obj[0].located_obj.objid = NULL_OBJID;
  me->pole_direction = U_DIRECTION;
  me->row_poles = NULL;

  /* set up display parameters for dynamics */
  sizbuf = sizeof( struct IGRdisplay );
  gr$get_active_display( msg = &msg,
			 sizbuf = &sizbuf,
			 buffer = &me->cv_disp,
			 nret = &nret );
  memcpy( (char *) &me->sf_disp, (char *) &me->cv_disp,
	  sizeof( struct IGRdisplay ));
  memcpy( (char *) &me->poly_disp, (char *) &me->cv_disp,
	  sizeof( struct IGRdisplay ));
  memcpy( (char *) &me->pt_disp, (char *) &me->cv_disp,
	  sizeof( struct IGRdisplay ));
  me->cv_disp.weight = 2;
  me->sf_disp.weight = 0;
  me->poly_disp.weight = 2;
  me->poly_disp.style = 4;
  me->pt_disp.weight = 6;

  /* curve display attribute */
  me->cv_attr.is_polydis = TRUE;
  me->cv_attr.is_curvedis = TRUE;

  /* assign surface display attribute */
  me->sf_attr.u_rules = 15;
  me->sf_attr.v_rules = 15;
  me->sf_attr.is_polydis = FALSE;
  me->sf_attr.is_surfdis = TRUE;
  me->sf_attr.is_slowdis = FALSE;
  me->sf_attr.type = NULL;
  me->sf_attr.rules_specified = FALSE;
  me->u_rules = ( IGRdouble * ) om$malloc( size = me->sf_attr.u_rules * sizeof( IGRdouble ));
  if ( !me->u_rules )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
    *sts = MSFAIL;
    goto quit;
  }
  me->u_bounds = ( IGRint * ) om$malloc( size = me->sf_attr.u_rules * sizeof( IGRint ));
  if ( !me->u_bounds )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
    *sts = MSFAIL;
    goto quit;
  }
  for ( i = 0; i < me->sf_attr.u_rules; i++ )
  {
    me->u_rules[i] = i / ( IGRdouble ) ( me->sf_attr.u_rules - 1.0 );
    me->u_bounds[i] = 0;
  }
  me->v_rules = ( IGRdouble * ) om$malloc( size = me->sf_attr.v_rules * sizeof( IGRdouble ));
  if ( !me->v_rules )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
    *sts = MSFAIL;
    goto quit;
  }
  me->v_bounds = ( IGRint * ) om$malloc( size = me->sf_attr.v_rules * sizeof( IGRint ));
  if ( !me->v_bounds )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
    *sts = MSFAIL;
    goto quit;
  }
  for ( i = 0; i < me->sf_attr.v_rules; i++ )
  {
    me->v_rules[i] = i / ( IGRdouble ) ( me->sf_attr.v_rules - 1.0 );
    me->v_bounds[i] = 0;
  }
  me->sf_attr.u_rule_values = me->u_rules;
  me->sf_attr.v_rule_values = me->v_rules;
  me->sf_attr.u_num_bound = me->u_bounds;
  me->sf_attr.v_num_bound = me->v_bounds;
  me->sf_attr.u_bdrys = NULL;
  me->sf_attr.v_bdrys = NULL;
}

/* ********************************************************************	*/
action init
{
    IGRlong msg;

    /* ------------------------------------------------ */
    /* send init message to ECcmd since Undo does not */
    /* ------------------------------------------------ */
    status = om$send(msg = message ECcmd.init(type, str_ptr),
		     mode = OM_e_wrt_message,
		     targetid = my_id);
    EMomerr_hndlr(status, quit, "ECcmd init");

    /* ------------------------------------------------ */
    /* send init message to IDundo                      */
    /* ------------------------------------------------ */
    status = om$send(msg = message IDundo.init(type, str_ptr),
		     mode = OM_e_wrt_message,
		     targetid = my_id);
    EMomerr_hndlr(status, quit, "IDundo init");

    /* ------------------------------------------------ */
    /* send init message to IDdisp_poly                 */
    /* ------------------------------------------------ */
    status = om$send(msg = message IDdisp_poly.init(type, str_ptr),
		     mode = OM_e_wrt_message,
		     targetid = my_id);
    EMomerr_hndlr(status, quit, "IDdisp_poly init");

    status = om$send(msg = message IDinspls.init_variables(&msg),
		     mode = OM_e_wrt_message,
		     targetid = my_id);
}

/* ********************************************************************	*/
action delete
{
    /* ------------------------------------------------------------ */
    /* send delete message to IDundo so it can delete saved geom    */
    /* ------------------------------------------------------------ */
    status = om$send(msg = message IDundo.delete(f_defer_flag ),
		     mode = OM_e_wrt_message,
		     targetid = my_id);
    EMomerr_hndlr(status, quit, "send to IDinspls's parent delete\n");

    /* ------------------------------------------------ */
    /* send delete message to ECcmd since Undo does not */
    /* ------------------------------------------------ */
    status = om$send(msg = message ECcmd.delete(f_defer_flag ),
		     mode = OM_e_wrt_message,
		     targetid = my_id);
    EMomerr_hndlr(status, quit, "send to IDinspls's parent delete\n");

    /* free memory */
    om$dealloc( ptr = me->u_rules );
    om$dealloc( ptr = me->u_bounds );
    om$dealloc( ptr = me->v_rules );
    om$dealloc( ptr = me->v_bounds );
}
