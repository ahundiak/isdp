/**@***********************************************************************

 FILE:
 	IDcvbyptsi.I

 ROUTINES:
	init()
	delete()
	pre_sleep()
	output_command_string()
	next_event_processing()
	verify_event()
	backup_event()
	perform_dynamics()
	IDdyn_cvbypts()
	perform_construction()
	fit_unifm_cv()

 **************************************************************************/

class implementation IDcvbypts;

/*
Abstract
	This command places a b-spline curve passing through a set of 
        input points. The command is similar to the existing command
        Place Curve by Points. The major difference between the two
        command is that the current command uses Direct Fit to calculate
        the output curve while the previous one used Fitted Curve routine.
        Thus this command is much more efficient than the other one.
        The speed difference can be easily felt when dynamically input
        points while the curve is drawn with the cursor.

History
	02/28/92	JSY	Design and coding.
	04/20/92	JSY	Add code to place uniform B-spline curve.
	06/25/92	JSY	Add code to display curve dynamically
				inside the 3D input generator.
	07/08/92	JSY	Add code to impose tangency constraint
				at the end point of an existing curve.
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
#include "bs.h"
#include "bsparameters.h"
#include "msdef.h"
#include "IDffmsg.h"
#include "IDffcmd.h"
#include "EMS.h"
#include "ems_m_inc.h"
#include "EC_P.h"
#include "IDdyn.h"
#include "IDcvbyptsi.h"
#include "bserr.h"
#include "bsalloccv.h"    /* prototypes */
#include "bscv_copy.h"    /* prototypes */
#include "bsdirfitcv.h"    /* prototypes */
#include "bsfitratcv.h"    /* prototypes */
#include "bsfreecv.h"    /* prototypes */
#include "bslenvec.h"    /* prototypes */
#include "bsmdstptarr.h"    /* prototypes */
#include "bsunwght_p.h"    /* prototypes */
#include "bsxtractpar.h"    /* prototypes */
#include "msmacros.h"    /* prototypes */
#include <memory.h>    /* prototypes */

extern OMuword OPP_GRbcsubbc_class_id;
from GRsubbc import EMdirect_fit_curve;
from GRvg import GRconstruct;

/**@*********** fit_unifm_cv() ********************************************

 ABSTRACT:
	This function constructs a uniform B-spline curve passing through
	a given input set of points

 SYNOPSIS:
	IGRlong fit_unifm_cv( num_points, points, order, periodic, tan, cv )

	(I)	IGRint num_points
			Number of input points
	(I)	IGRdouble *points
			Pointer to the array of (x, y, z) of points
	(I)	IGRint order
			Order of the B-spline curve wanted
	(I)	IGRboolean periodic
			TRUE for a periodic curve; FALSE otherwise
	(I)	IGRvector tan
			NULL if no tangent constraint at the starting point
			Otherwise, the curve has the given tangent (tan)
			at its starting point
	(O)	IGRbsp_curve **cv
			The resulting B-spline curve

 RETURN:
	BSSUCC: succeed; BSFAIL: fail

 NOTES:
	The memory for the resulting curve is allocated by this routine.

 **************************************************************************/

IGRlong fit_unifm_cv(
    IGRint num_points, 
    IGRdouble *points, 
    IGRint order, 
    IGRboolean periodic, 
    IGRvector tan, 
    struct IGRbsp_curve **cv)
{
  IGRint mod, num_seg, num_knots, *spns, code, maxind, sts, i;
  IGRdouble *knots, *pars, delta, avgerr, maxerr;
  IGRpoint maxpt;
  BSrc rc;

  /* initialize */
  sts = OM_S_SUCCESS;
  knots = pars = NULL;
  spns = NULL;
  code = ( periodic == TRUE ? 0 : 2 );
  mod = order % 2;

  /* determine num_seg: see notes in BSktsprsfft */
  if ( periodic == TRUE )
    num_seg = num_points - 1;
  else
    num_seg = num_points - 1 + mod;

  /* ---------------------------------------------------- */
  /* computing num_knots: the following code is extracted */
  /* from BSkts_f_fit() of the BSPMATH library            */
  /* ---------------------------------------------------- */
  if( num_seg == 1 )
  {
    if ( periodic == FALSE )
      num_knots = 2 * order;
    else
    {
      sts = OM_E_ABORT;
      goto quit;
    }
  }
  else
  {
    if (( num_points == ( num_seg + 1 - mod )) &&
	!( periodic == TRUE || mod == 1 ))
    {
      /* direct fit */
      if ( periodic == FALSE )
      {
	if ( mod == 0 ) 
	  num_knots = num_points + 2 * order - 2;
	else
	  num_knots = num_points + 2 * order - 1;
      }
      else
	num_knots = num_points + 2 * order - 2;
    }
    else
	num_knots = 2 * order + num_seg - 1;
  }

  /* allocate space for knots */
  knots = ( IGRdouble * ) om$malloc( size = num_knots * sizeof( IGRdouble ));
  if ( knots == NULL )
  {
    sts = OM_E_ABORT;
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
    goto quit;
  }

  /* computing uniform knot vector */
  delta = 1.0 / (( IGRdouble ) ( num_knots - 2 * order + 1 ));
  if ( periodic == TRUE )
  {
    if (( num_points + 2 ) == order )
    {
      /* this is the Bezier case */
      for ( i = 0; i < 2 * order; i++ )
	knots[i] = -( order - 1 ) + i;
    }
    else
    {
      for ( i = 0; i < num_knots; i++ )
	knots[i] = ( i + 1 - order ) * delta;
    }
  }
  else
  {
    /* computing knots */
    for ( i = 0; i < order; i++ )
    {
      knots[i] = 0.0;
      knots[num_knots - 1 - i] = 1.0;
    }
    for ( i = 0; i < ( num_knots - 2 * order ); i++ )
      knots[order + i] = ( i + 1 ) * delta;
  }

  /* allocate space for parameters and span indices */
  pars = ( IGRdouble * ) om$malloc( size = num_points * sizeof( IGRdouble ));
  if ( pars == NULL )
  {
    sts = OM_E_ABORT;
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
    goto quit;
  }
  spns = ( IGRint * ) om$malloc( size = num_points * sizeof( IGRint ));
  if ( spns == NULL )
  {
    sts = OM_E_ABORT;
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
    goto quit;
  }

  /* computing parameters */
  if ( mod == 0 )
  {
    memcpy( (char *)pars, (char *)(knots + order - 1), 
        num_points * sizeof( IGRdouble ));
    spns[0] = spns[1] = order - 1;
    for ( i = 2; i < num_points; i++ )
      spns[i] = spns[i - 1] + 1;
  }
  else
  {
    if ( periodic == TRUE )
    {
      pars[0] = delta / 2.0;
      spns[0] = order - 1;
      for ( i = 1; i < num_points; i++ )
      {
	pars[i] = pars[i - 1] + delta;
	spns[i] = spns[i - 1] + 1;
      }
    }
    else
    {
      pars[0] = 0.0;
      pars[1] = delta * 1.5;
      for ( i = 2; i < ( num_points - 1 ); i++ )
	pars[i] = pars[i - 1] + delta;
      pars[num_points - 1] = 1.0;
      spns[0] = order - 1;
      for ( i = 1; i < num_points; i++ )
	spns[i] = spns[i - 1] + 1;
    }
  }

  /* fit a curve through the points */
  BSfitratcv( num_points, (IGRpoint *)points, NULL, pars, spns, order,
	      num_knots, knots, periodic,
	      code, ( tan ? 1 : 0 ), 0, tan, NULL, NULL, NULL,
	      0.0, 0.0, 0.0, 0.0, 1, 0.0,
	      cv, &avgerr, &maxerr, &maxind, maxpt, &rc );
  if ( rc != BSSUCC )
    sts = OM_E_ABORT;

 quit:
  if ( knots )
    om$dealloc( ptr = knots );
  if ( pars )
    om$dealloc( ptr = pars );
  if ( spns )
    om$dealloc( ptr = spns );
  return sts;
}

/**@*********** IDdyn_cvbypts() *******************************************

 ABSTRACT:
	This function performs the actual dynamics

 SYNOPSIS:
	IGRint IDdyn_cvbypts( DYinfo, points, matrix, objects, num_objects,
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
IGRint IDdyn_cvbypts(
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
      if ( DYinfo->dyn_cv.mytype == CV_POINTS_NONUNIFM )
      {
	/* call Math */
	BSdirfitcv( num_points, ( IGRpoint * ) DYinfo->dyn_cv.points,
		    DYinfo->dyn_cv.cv_order,
		    ( DYinfo->dyn_cv.have_tan == TRUE ? 1 : 0 ), 0,
		    DYinfo->dyn_cv.cv_periodic,
		    ( DYinfo->dyn_cv.have_tan == TRUE ? DYinfo->dyn_cv.tan : NULL ), NULL,
		    DYinfo->dyn_cv.header[1].geometry.bspcurve, &msg );
      }
      else
      {
	sts = fit_unifm_cv( num_points, DYinfo->dyn_cv.points,
			    DYinfo->dyn_cv.cv_order,
			    DYinfo->dyn_cv.cv_periodic,
			    ( DYinfo->dyn_cv.have_tan == TRUE ? DYinfo->dyn_cv.tan : NULL ), &cv );
      }

      if (( msg != BSSUCC && DYinfo->dyn_cv.mytype == CV_POINTS_NONUNIFM ) ||
	  ( sts == OM_E_ABORT && DYinfo->dyn_cv.mytype == CV_POINTS_UNIFM ))
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_MAERR );
	*buffers = &DYinfo->dyn_cv.header[0];
	*num_buffers = 1;
      }
      else
      {
	if ( DYinfo->dyn_cv.mytype == CV_POINTS_UNIFM )
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


/**@*********** init() ****************************************************

 ABSTRACT:
	Initialize the object

 SYNOPSIS:
	IGRlong init( IGRint type;
		      IGRchar *str_ptr )

	(I)	IGRint type
			Don't its functionality. Refer to original definition
	(I)	IGRchar *str_ptr
			Don't its functionality. Refer to original definition

 RETURN:
	OM_S_SUCCESS

 NOTES:
	This is a method

 **************************************************************************/

method init( IGRint type; IGRchar *str_ptr )
{
  IGRlong sts;
  
  sts = om$send( msg = message ECfit.init( type, str_ptr ),
		 mode = OM_e_wrt_message,
		 targetid = my_id );

  me->cv_info.dyn_cv.num_points = 0;
  me->cv_info.dyn_cv.points = NULL;
  me->cv_info.dyn_cv.draw_curve = FALSE;
  me->cv_info.dyn_cv.have_tan = FALSE;
  me->cv_info.num_stat_elem = 0;
  me->bspcv = NULL;

  me->snapped = FALSE;
  
  return OM_S_SUCCESS;
}

/**@*********** delete() **************************************************

 ABSTRACT:
	Delete the current object

 SYNOPSIS:
	IGRlong delete( IGRint defer_flag )

	(I)	IGRint defer_flag
			Don't its functionality. Refer to original definition

 RETURN:
	OM_S_SUCCESS

 NOTES:
	This is a method

 **************************************************************************/

method delete( IGRint defer_flag )
{
  IGRlong msg, sts;
  
  if ( me->cv_info.dyn_cv.points )
    om$dealloc( ptr = me->cv_info.dyn_cv.points );
  if ( me->bspcv )
    BSfreecv( &msg, me->bspcv );
  me->cv_info.num_stat_elem = 0;

  sts = om$send( msg = message ECfit.delete( defer_flag ),
		 mode = OM_e_wrt_message,
		 targetid = my_id );
  return OM_S_SUCCESS;
}

/**@*********** pre_sleep() ***********************************************

 ABSTRACT:
	Store the dynamic function and its data before sleeping

 SYNOPSIS:
	IGRlong pre_sleep( IGRint ( **dyn_func )();
			   IGRchar **addnl_info )

	(O)	IGRint ( **dyn_func )()
			The dynamic function that needs to be called by
			the next command
	(O)	IGRchar **addnl_info
			Information needed by the dynamic function

 RETURN:
	OM_S_SUCCESS

 NOTES:
	This is a method

 **************************************************************************/

method pre_sleep( IGRint ( **dyn_func )(); IGRchar **addnl_info )
{
  if ( me->cv_info.dyn_cv.num_points <= 1 )
    me->cv_info.num_stat_elem = 0;

  if ( me->cv_info.dyn_cv.num_points == 0 )
  {
    *dyn_func = NULL;
    *addnl_info = NULL;
  }
  else
  {
    *dyn_func = IDdyn_cvbypts;
    *addnl_info = ( IGRchar * ) &me->cv_info;
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
    ex$message( field = MESSAGE_FIELD, msgnumb = IDFFC_M_CvByPts );
  }
  else
  {
    ex$message( field = MESSAGE_FIELD, msgnumb = IDFFC_M_UCvByPts );
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

  /* initialize */
  me->msg = MSSUCC;

  /* determine if the user can move on yet */
  num_points = me->number_of_events_input;
  if ( num_points == 1 && me->events[0].subtype == GRst_KEYPOINT &&
       me->snapped == FALSE )
  {
    IGRlong my_event_mask, response;
    struct GRevent acc_event;
    IGRchar response_data[1024];
    IGRlong sts, msg;
    
    me->snapped = TRUE;
    
    /* initialize */
    my_event_mask = GRm_DATA | GRm_RJT_MOVEON | GRm_RESTART;
    
    sts = co$getevent( msg = &msg,
		       event_mask = my_event_mask | GRm_STRING,
		       msgnum = IDFF_P_AccRjtCnstCrv,
		       response = &response,
		       response_data = response_data,
		       event = &acc_event );
    
    switch ( acc_event.response )
    {
    case EX_STRING:
      if ( acc_event.event.keyin[0] != '\0' )
	break;
      
    case EX_DATA:
      {
	struct GRlc_info *loc_info;
	struct GRmd_env *md_env;
	struct GRid *id;
	struct IGRbsp_curve *cv;
	IGRpoint acc_pt, end_pts[2];
	IGRint ind1, ind2;
	IGRdouble dist;
	extern IGRlong EMgetvggeom();
	
	me->cv_info.dyn_cv.have_tan = TRUE;

	/* get that snapped curve */
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
	
	/* get the accept data point */
	acc_pt[0] = me->events[0].event.button.x;
	acc_pt[1] = me->events[0].event.button.y;
	acc_pt[2] = me->events[0].event.button.z;

	/* unweight pole if the curve is rational */
	if ( cv->rational )
	{
	  if ( cv->weights )
	    BSunwght_p( &msg, cv->poles, cv->weights, &( cv->num_poles ), cv->poles );
	}

	/* assign end points */
	memcpy( (char *)end_pts[0], (char *)cv->poles, sizeof( IGRpoint ));
	memcpy( (char *)end_pts[1], (char *)(cv->poles + 
            ( cv->num_poles - 1 ) * 3), sizeof( IGRpoint ));
	BSmdstptarr( 1, &acc_pt, 2, end_pts, &ind1, &ind2, &dist, &msg );

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

	/* free memory */
	om$dealloc( ptr = cv );
      }
      break;
      
    case EX_BACK_UP:
    case EX_RJT_MOVEON:
    default:
      break;
    }
  }
    
  if ( me->u_order > 3 )
  {
    if (( num_points + 1 ) >= me->u_order ||
	(( num_points >= ( me->u_order - 1 )) && me->u_periodic == TRUE ))
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

  /* check the type of event input */
  event = &me->events[me->number_of_events_input - 1];
  if ( event->response == EX_RJT_MOVEON )
    *done = TRUE;

  return OM_S_SUCCESS;
}

/**@*********** backup_event() ********************************************

 ABSTRACT:
	Backup to the last state

 SYNOPSIS:
	IGRlong backup_event()

 RETURN:
	OM_S_SUCCESS

 NOTES:
	This is a method

 **************************************************************************/

method backup_event()
{
  IGRlong sts;
  
  /* initialize */
  me->msg = MSSUCC;

  sts = om$send( msg = message ECfit.backup_event(),
		 mode = OM_e_wrt_message,
		 targetid = my_id );

  if ( me->number_of_events_input == 1 ||
       me->number_of_events_input == 0 )
  {
    me->snapped = FALSE;
    me->cv_info.dyn_cv.have_tan = FALSE;
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
  if ( me->mytype == 0 )
    me->cv_info.dyn_cv.mytype = CV_POINTS_NONUNIFM;
  else
    me->cv_info.dyn_cv.mytype = CV_POINTS_UNIFM;

  /* get points */
  me->cv_info.dyn_cv.num_points = me->number_of_events_input;
  if ( me->cv_info.dyn_cv.points )
    om$dealloc( ptr = me->cv_info.dyn_cv.points );
  me->cv_info.dyn_cv.points = ( IGRdouble * ) om$malloc( size = ( me->cv_info.dyn_cv.num_points + 2 ) * 3 * sizeof( IGRdouble ));
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
  UI_status( " " );
  sts = dp$dynamics( dyn_fun = IDdyn_cvbypts,
		     information = &me->cv_info );

  msg = TRUE;

 quit:
    return OM_S_SUCCESS;
}

/**@*********** perform_construction() ************************************

 ABSTRACT:
	Perform construction

 SYNOPSIS:
	IGRlong perform_construction()

 RETURN:
	OM_S_SUCCESS

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
  me->msg = MSSUCC;
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
								  ( me->cv_info.dyn_cv.have_tan == TRUE ? ( IGRvector * ) me->cv_info.dyn_cv.tan : NULL ),
								  NULL,
								  my_construct_list ),
		        p_objid = &me->constructed_object,
		        osnum = me->construct_env.md_id.osnum );
  }
  else
  {
    sts = fit_unifm_cv( (IGRint)number_of_points, points, (IGRint) me->u_order, 
        me->u_periodic, 
        ( me->cv_info.dyn_cv.have_tan == TRUE ? me->cv_info.dyn_cv.tan : NULL),
        &bspcv );
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


end implementation IDcvbypts;
