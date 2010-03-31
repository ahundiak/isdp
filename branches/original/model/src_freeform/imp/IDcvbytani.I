/**@***********************************************************************

 FILE:
 	IDcvbytani.I

 ROUTINES:
	output_command_string()
	next_event_processing()
	verify_event()
	perform_dynamics()
	IDdyn_cvbytan()
	display_constructions()
	perform_construction()

 **************************************************************************/

class implementation IDcvbytan;

/*
Abstract
	This command places a curve which is tangent to a located curve
	at the end point.

History
	07/06/92	JSY	Creation.
*/

#include <stdio.h>
#include <math.h>
#include "OMlimits.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "igrdef.h"
#include "igr.h"
#include "gr.h"
#include "go.h"
#include "dp.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "msmacros.h"
#include "msdef.h"
#include "IDffmsg.h"
#include "IDffcmd.h"
#include "EMS.h"
#include "EMSdpb.h"
#include "ems_m_inc.h"
#include "EC_P.h"
#include "IDcvbytani.h"
#include "IDcvbyptsi.h"    /* prototypes */
#include "bsalloccv.h"    /* prototypes */
#include "bscv_copy.h"    /* prototypes */
#include "bsdirfitcv.h"    /* prototypes */
#include "bsfreecv.h"    /* prototypes */
#include "bslenvec.h"    /* prototypes */
#include "bsmdstptarr.h"    /* prototypes */
#include "bsunwght_p.h"    /* prototypes */
#include "bsxtractpar.h"    /* prototypes */
#include <memory.h>    /* prototypes */

#define LITTLE_CURVE 1

extern OMuword OPP_GRbcsubbc_class_id;
from GRsubbc import EMdirect_fit_curve;
from GRvg import GRconstruct;

/**@*********** IDdyn_cvbytan() *******************************************

 ABSTRACT:
	This function performs the actual dynamics

 SYNOPSIS:
	IGRint IDdyn_cvbytan( DYinfo, points, matrix, objects, num_objects,
			      buffers, num_buffers,
			      dummy_in1, dummy_in2, dummy_in3,
			      dummy_out1, dummy_out2, dummy_out3 )

	(I)	struct DPaddnl_info *DYinfo
			Pointer to a structure filled information needed
			for performing dynamics

 RETURN:
	OM_S_SUCCESS

 **************************************************************************/

#argsused
IGRint IDdyn_cvbytan(
    struct DPaddnl_info *DYinfo, 
    struct EX_button *point, 
    IGRdouble *matrix, 
    struct GRid **objects, 
    IGRint *num_objects, 
    struct DPele_header **buffers, 
    IGRint *num_buffers, 
    IGRchar *dummy_in1, 
    IGRchar *dummy_in2, 
    IGRchar *dummy_in3, 
    IGRchar *dummy_out1, 
    IGRchar *dummy_out2, 
    IGRchar *dummy_out3)
{
  IGRint num_points;
  IGRvector vec;
  struct IGRbsp_curve *cv;
  IGRlong msg, sts;

  /* initialize */
  num_points = DYinfo->dyn_cv.num_points;
  
  sts = OM_S_SUCCESS;
  UI_status( " " );

  /* assign the cursor position */
  DYinfo->dyn_cv.points[DYinfo->dyn_cv.num_points*3] = point->x;
  DYinfo->dyn_cv.points[DYinfo->dyn_cv.num_points*3+1] = point->y;
  DYinfo->dyn_cv.points[DYinfo->dyn_cv.num_points*3+2] = point->z;

  /* determine whether curve is available */
  if ( DYinfo->dyn_cv.draw_curve == TRUE )
  {
    /* check to see whether the last two points are the same */
    vec[0] = DYinfo->dyn_cv.points[(DYinfo->dyn_cv.num_points-1)*3] - point->x;
    vec[1] = DYinfo->dyn_cv.points[(DYinfo->dyn_cv.num_points-1)*3+1] - point->y;
    vec[2] = DYinfo->dyn_cv.points[(DYinfo->dyn_cv.num_points-1)*3+2] - point->z;

    if ( BSlenvec( &msg, vec ) < DYinfo->dyn_cv.lenvec_tol )
    {
      /* close the curve if it is periodic */
      if ( DYinfo->dyn_cv.cv_periodic == TRUE )
      {
	memcpy( (char *)(DYinfo->dyn_cv.points + 3 * DYinfo->dyn_cv.num_points),
	        (char *)DYinfo->dyn_cv.points, sizeof( IGRpoint ));
	num_points++;
      }
    }
    else
    {
      /* close the curve if it is periodic */
      if ( DYinfo->dyn_cv.cv_periodic == TRUE )
      {
	memcpy( (char *)(DYinfo->dyn_cv.points + 3 * 
            ( DYinfo->dyn_cv.num_points + 1 )),
	        (char *)DYinfo->dyn_cv.points, sizeof( IGRpoint ));
	num_points++;
      }
      num_points++;
    }

    if (( num_points > 3 ||
	( num_points > 2 && DYinfo->dyn_cv.cv_periodic == FALSE )) &&
	(( num_points + 1 ) >= DYinfo->dyn_cv.cv_order ||
	( DYinfo->dyn_cv.cv_periodic == TRUE && num_points >= ( DYinfo->dyn_cv.cv_order - 1 ))))
    {
      if ( DYinfo->dyn_cv.mytype == 0 )
      {
	/* call Math */
	BSdirfitcv( num_points, ( IGRpoint * ) DYinfo->dyn_cv.points,
		    DYinfo->dyn_cv.cv_order, 1, 0,
		    DYinfo->dyn_cv.cv_periodic,
		    DYinfo->dyn_cv.tan, NULL,
		    DYinfo->dyn_cv.header[1].geometry.bspcurve, &msg );
      }
      else
      {
	sts = fit_unifm_cv( num_points, DYinfo->dyn_cv.points,
			    DYinfo->dyn_cv.cv_order,
			    DYinfo->dyn_cv.cv_periodic,
			    DYinfo->dyn_cv.tan, &cv );
      }

      if (( msg != BSSUCC && DYinfo->dyn_cv.mytype == 0 ) ||
	  ( sts == OM_E_ABORT && DYinfo->dyn_cv.mytype == 1 ))
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_MAERR );
	*buffers = &DYinfo->dyn_cv.header[0];
	*num_buffers = 1;
      }
      else
      {
	if ( DYinfo->dyn_cv.mytype == 1 )
	{
	  BScv_copy( &msg, cv, DYinfo->dyn_cv.header[1].geometry.bspcurve );
	  BSfreecv( &msg, cv );
	}

	*buffers = DYinfo->dyn_cv.header;
	*num_buffers = 2;
      }
    }
    else
    {
      *buffers = &DYinfo->dyn_cv.header[0];
      *num_buffers = 1;
    }
  }
  else
  {
    *buffers = &DYinfo->dyn_cv.header[0];
    *num_buffers = 1;
  }

  return OM_S_SUCCESS;
}

/**@*********** output_command_string() ***********************************

 ABSTRACT:
	Output current command string in the message field

 SYNOPSIS:
	IGRlong output_command_string()

 RETURN:
	OM_S_SUCCESS

 NOTES:
	This is a method

 **************************************************************************/

method output_command_string()
{
  if ( me->mytype == 0 )
  {
    ex$message( field = MESSAGE_FIELD, msgnumb = IDFFC_M_CvByTanPts );
  }
  else
  {
    ex$message( field = MESSAGE_FIELD, msgnumb = IDFFC_M_UCvByTanPts );
  }

  return OM_S_SUCCESS;
}

/**@*********** next_event_processing() ***********************************

 ABSTRACT:
	Preprocessing for getting the next input event

 SYNOPSIS:
	method next_event_processing( IGRchar *prompt_string;
				      IGRlong *prompt_index;
				      IGRlong *event_mask;
				      IGRlong *type_of_value_needed;
				      IGRboolean *locate_desired;
				      struct RLW_locate_info *loc_info )

	(O)	IGRchar *prompt_string
			String printed in the prompt field
	(O)	IGRlong *prompt_index
			Index into the message key in the message file
	(O)	IGRlong *event_mask
			Mask used to get the next event
	(O)	IGRlong *type_of_value_needed
			What type of input wanted: SCALAR, DISTANCE, etc.
	(O)	IGRboolean *located_desired
			Whether the next event is a located event
	(O)	struct RLW_locate_info *loc_info
			A struct contains all the located necessary info

 RETURN:
	TRUE:	success
	FALSE:	failure

 NOTES:
	This is a method

 **************************************************************************/

method next_event_processing( IGRchar *prompt_string;
			      IGRlong *prompt_index;
			      IGRlong *event_mask;
			      IGRlong *type_of_value_needed;
			      IGRboolean *locate_desired;
			      struct RLW_locate_info *loc_info )
{
  IGRlong key, num_points;

  /* initialze */
  me->msg = MSSUCC;

  /* branch based on the command state */
  if ( me->number_of_events_input == 0 )
  {
    /* event 0 prompt */
    *locate_desired = TRUE;
    EFget_locate_information( LITTLE_CURVE, loc_info );
    loc_info->operation_type = info_read_only;
    loc_info->acc_key = IDFF_P_AccptRejCrv;
    loc_info->accept_event_type = dummy;

    ex$message( msgnumb = EMS_P_00030, buff = prompt_string );
  }
  else
  {
    struct GRlc_info *loc_info;
    struct GRmd_env *md_env;
    struct GRid *id;
    struct IGRbsp_curve *cv;
    IGRpoint acc_pt, end_pts[2];
    IGRint ind1, ind2;
    IGRdouble dist;
    IGRlong sts, msg;
    extern IGRlong EMgetvggeom();

    /* initialize */
    loc_info = &me->events[0].located_object[0];
    md_env = &loc_info->module_info;
    id = &loc_info->located_obj;
    
    /* get the curve geometry */
    sts = EMgetvggeom( &msg,
                       &md_env->md_env.matrix_type,
                       md_env->md_env.matrix,
                       id,
                       &cv,
                       NULL );

    if ( !( 1 & sts & msg ))
    {
      me->msg = MSFAIL;
      goto quit;
    }

    /* get data point */
    acc_pt[0] = me->events[0].event.button.x;
    acc_pt[1] = me->events[0].event.button.y;
    acc_pt[2] = me->events[0].event.button.z;
    
    /* unweight pole if the curve is rational */
    if ( cv->rational )
    {
      if ( cv->weights )
	BSunwght_p( &msg, cv->poles, cv->weights, &cv->num_poles, cv->poles );
    }
						      
    /* assign end points */
    memcpy( (char *)end_pts[0], (char *)cv->poles, sizeof( IGRpoint ));
    memcpy( (char *)end_pts[1], (char *)(cv->poles + ( cv->num_poles - 1 ) * 3),
        sizeof( IGRpoint ));
    BSmdstptarr( 1, &acc_pt, 2, end_pts, &ind1, &ind2, &dist, &msg );
    
    /* assign the start point */
    me->events[0].event.button.x = end_pts[ind2][0];
    me->events[0].event.button.y = end_pts[ind2][1];
    me->events[0].event.button.z = end_pts[ind2][2];
    
    /* get that point and tangent information */
    if ( ind2 == 0 )
    {
      /* starting point of the located curve */
      me->cv_info.dyn_cv.tan[0] = cv->poles[0] - cv->poles[3];
      me->cv_info.dyn_cv.tan[1] = cv->poles[1] - cv->poles[4];
      me->cv_info.dyn_cv.tan[2] = cv->poles[2] - cv->poles[5];
    }
    else
    {
      /* ending point of the located curve */
      me->cv_info.dyn_cv.tan[0] = cv->poles[( cv->num_poles - 1 ) * 3] - cv->poles[( cv->num_poles - 2) * 3];
      me->cv_info.dyn_cv.tan[1] = cv->poles[( cv->num_poles - 1 ) * 3 + 1] - cv->poles[( cv->num_poles - 2) * 3 + 1];
      me->cv_info.dyn_cv.tan[2] = cv->poles[( cv->num_poles - 1 ) * 3 + 2] - cv->poles[( cv->num_poles - 2) * 3 + 2];
    }

    /* free the curve */
    om$dealloc( ptr = cv );

    num_points = me->number_of_events_input;
    if ( me->u_order > 3 )
    {
      if (( num_points + 1 ) >= me->u_order ||
	  ( num_points >= ( me->u_order - 1 ) && me->u_periodic == TRUE ))
      {
	key = IDFF_P_InputPtMvOn;
	*event_mask |= GRm_RJT_MOVEON;
      }
      else
	key = IDFF_P_InputPt;
    }
    else
    {
      if ( num_points >= me->u_order )
      {
	key = IDFF_P_InputPtMvOn;
	*event_mask |= GRm_RJT_MOVEON;
      }
      else
	key = IDFF_P_InputPt;
    }
    
    /* build the prompt string */
    num_points++;
    ex$message( msgnumb = key,
	        type = "%d",
	        var = `num_points`,
	        buff = prompt_string );
  }

 quit:
  if ( me->msg == MSFAIL )
    return OM_E_ABORT;
  else
    return OM_S_SUCCESS;
}

/**@*********** verify_event() ********************************************

 ABSTRACT:
	Verify the input event

 SYNOPSIS:
	IGRlong verify_event( IGRboolean use_default;
			      IGRboolean *was_valid_event;
			      IGRboolean *done )

	(I/O)	IGRboolean use_default
			Don't know what is the use of it
	(O)	IGRboolean *was_valid_event
			Whether this a valid event
	(O)	IGRboolean *done
			TRUE if this command gets all the necessary input

 RETURN:
	OM_S_SUCCESS

 NOTES:
	This is a method

 **************************************************************************/

method verify_event( IGRboolean use_default;
		     IGRboolean *was_valid_event;
		     IGRboolean *done )
{
  struct GRevent *event;
  
  /* initialize */
  me->msg = MSSUCC;
  *was_valid_event = TRUE;
  *done = FALSE;

  /* the curve must be located */
  if ( me->number_of_events_input > 1 )
  {
    /* check the type of event input */
    event = &me->events[me->number_of_events_input - 1];
    if ( event->response == EX_RJT_MOVEON )
      *done = TRUE;
  }

  return OM_S_SUCCESS;
}

/**@*********** perform_dynamics() ****************************************

 ABSTRACT:
	Perform dynamics

 SYNOPSIS:
	IGRlong perform_dynamics()

 RETURN:
	OM_S_SUCCESS

 NOTES:
	This is a method

 **************************************************************************/

method perform_dynamics()
{
  IGRlong msg;
  IGRint sts;

  /* assign which command */
  me->cv_info.dyn_cv.mytype = me->mytype;

  /* get points */
  me->cv_info.dyn_cv.num_points = me->number_of_events_input;
  if ( me->cv_info.dyn_cv.points )
    om$dealloc( ptr = me->cv_info.dyn_cv.points );
  me->cv_info.dyn_cv.points = ( IGRdouble * ) om$malloc( size = ( me->cv_info.dyn_cv.num_points + 2 ) * sizeof( IGRpoint ));
  if ( me->cv_info.dyn_cv.points == NULL )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
    goto quit;
  }
  EFextract_points( me->cv_info.dyn_cv.num_points,
		    me->events,
		    ( IGRpoint * ) me->cv_info.dyn_cv.points );
  me->cv_info.dyn_cv.draw_curve = FALSE;

  /* we need to draw control polygon */
  me->ctrl_poly.num_points = 2;
  me->ctrl_poly.points = me->cv_info.dyn_cv.points + ( me->cv_info.dyn_cv.num_points - 1 ) * 3;
  dp$build_dis_buffer( buffer = &me->cv_info.dyn_cv.header[0],
		       type = IGRPY,
		       display_att = &me->display,
		       geometry = ( struct IGRpolyline * ) &me->ctrl_poly );

  /* check whether curve is available */
  if (( me->cv_info.dyn_cv.num_points > 1 ) &&
      (( me->cv_info.dyn_cv.num_points + 2 ) >= me->u_order ||
       ( me->u_periodic == TRUE &&
	( me->cv_info.dyn_cv.num_points + 1 ) >= ( me->u_order - 1 ))))
  {	/* curve is available */
    /* extract tolerance */
    BSxtractpar( &msg, BSTOLLENVEC, &me->cv_info.dyn_cv.lenvec_tol );

    me->cv_info.dyn_cv.draw_curve = TRUE;
    me->cv_info.dyn_cv.cv_order = me->u_order;
    me->cv_info.dyn_cv.cv_periodic = me->u_periodic;

    /* initialize to display curve but not polygon */
    me->attr.is_polydis = FALSE;
    me->attr.is_curvedis = TRUE;

    /* allocate a bspline curve and build display buffer */
    if ( me->bspcv )
      BSfreecv( &msg, me->bspcv );
    BSalloccv( me->u_order, me->cv_info.dyn_cv.num_points + me->u_order + 4,
	       FALSE, 0, &me->bspcv, &msg );

    /* build display buffer */
    dp$build_dis_buffer( buffer = &me->cv_info.dyn_cv.header[1],
			 type = IGRBC,
			 display_att = &me->display,
			 ele_spec_att = &me->attr,
			 geometry = ( struct IGRbsp_curve * ) me->bspcv );
  }

  if ( me->cv_info.dyn_cv.num_points > 1 )
  {
    me->cv_info.num_stat_elem = 1;

    me->stat_line.num_points = me->cv_info.dyn_cv.num_points;
    me->stat_line.points = me->cv_info.dyn_cv.points;
    dp$build_dis_buffer( buffer = &( me->cv_info.stat_elem_buf[0] ),
			 type = IGRPY,
			 display_att = &me->display,
			 geometry = ( struct IGRpolyline * ) &me->stat_line );
  }
  else
    me->cv_info.num_stat_elem = 0;

  /* perform dynamics */
  sts = dp$dynamics( dyn_fun = IDdyn_cvbytan,
		     information = &me->cv_info.dyn_cv );

  msg = TRUE;

 quit:
    return OM_S_SUCCESS;
}


/**@*********** display_constructions() ***********************************

 ABSTRACT:
	Display the current constructing elements

 SYNOPSIS:
	IGRlong display_constructions()

 RETURN:
	OM_S_SUCCESS

 NOTES:
	This is a method

 **************************************************************************/

method display_constructions( IGRboolean draw_background;
			      IGRboolean draw_single )
{
  return OM_S_SUCCESS;
}

/**@*********** perform_construction() ************************************

 ABSTRACT:
	Perform contruction of the curve

 SYNOPSIS:
	IGRlong perform_construction()

 RETURN:
	OM_S_SUCCESS:	success
	OM_E_ABORT:	failure

 NOTES:
	This is a method

 **************************************************************************/

method perform_construction()
{
  IGRlong msg, sts, number_of_points;
  IGRdouble *points;
  struct IGRbsp_curve *bspcv;
  struct GRvg_construct *my_construct_list;
  struct IGResbs *surface_specific;
  struct IGResbc curve_specific;

  my_construct_list = &me->construct_list;
  sts = me->msg = MSSUCC;
  points = NULL;
  number_of_points = me->number_of_events_input - 1;
  surface_specific = ( struct IGResbs * ) my_construct_list->class_attr;

  curve_specific.is_polydis = surface_specific->is_polydis;
  curve_specific.is_curvedis = TRUE;
  my_construct_list->class_attr = ( IGRchar * ) &curve_specific;

  points = ( IGRdouble * ) om$malloc( size = ( number_of_points + 1 ) * sizeof( IGRpoint ));
  if ( points == NULL )
  {
    me->msg = MANOMEMORY;
    goto quit;
  }
  EFextract_points( number_of_points, me->events, ( IGRpoint * ) points );

  /* add the starting point if it is periodic */
  if ( me->u_periodic == TRUE )
  {
    memcpy( (char *)(points + 3 * number_of_points), (char *)points,
        sizeof( IGRpoint ));
    number_of_points++;
  }

  if ( me->mytype == 0 )
  {
    sts = om$construct( classid = OPP_GRbcsubbc_class_id,
		        msg = message GRsubbc.EMdirect_fit_curve( me->u_order,
								  me->u_periodic,
								  number_of_points,
								  ( IGRpoint * ) points,
								  NULL,
								  ( IGRvector * ) me->cv_info.dyn_cv.tan,
								  NULL,
								  my_construct_list ),
		        p_objid = &me->constructed_object,
		        osnum = me->construct_env.md_id.osnum );
  }
  else
  {
    sts = fit_unifm_cv( number_of_points, points, me->u_order, me->u_periodic, me->cv_info.dyn_cv.tan, &bspcv );
    if ( sts == OM_E_ABORT )
    {
      me->msg = MSFAIL;
      goto quit;
    }

    bspcv->non_uniform = FALSE;

    /* assign geometry to construct list */
    my_construct_list->geometry = ( IGRchar * ) bspcv;

    sts = om$construct( classid = OPP_GRbcsubbc_class_id,
		        msg = message GRvg.GRconstruct( my_construct_list ),
		        p_objid = &me->constructed_object,
		        osnum = me->construct_env.md_id.osnum );
    
    if ( bspcv )
      BSfreecv( &msg, bspcv );
  }
  if ( !( 1 & sts ))
    me->msg = MSFAIL;


 quit:
  my_construct_list->class_attr = ( IGRchar * ) surface_specific;
  if ( points )
    om$dealloc( ptr = points );

  if ( 1 & me->msg )
    return OM_S_SUCCESS;
  else
  {
    me->constructed_object = NULL_OBJID;
    return OM_E_ABORT;
  }
}

end implementation IDcvbytan;
