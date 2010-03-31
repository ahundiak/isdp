class implementation IDcurbypol;

/*
Abstract
	This command is the same as ECcurbypol except adding dynamics
	function. The curve gets displayed while creating.

History
	02/24/92	JSY	Design and coding.
	04/12/92	JSY	Add code to place uniform B-spline curve.
*/

#include <stdio.h>
#include <math.h>
#include <memory.h>
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
#include "msdef.h"
#include "EMS.h"
#include "ems_m_inc.h"
#include "EC_P.h"
#include "IDffmsg.h"
#include "IDffcmd.h"
#include "IDdyn.h"
#include "IDcurbypoli.h" /* prototypes */
#include "bschrdlkts.h"    /* prototypes */
#include "mabcupexp.h"    /* prototypes */
#include "msmacros.h"    /* prototypes */

extern OMuword OPP_GRbcsubbc_class_id;
from GRsubbc import EMcurve_by_poles;
from GRvg import GRconstruct;

/*----------------------------------------------------------------------*
 * Function to do real dynamics                                         *
 *----------------------------------------------------------------------*/
#argsused
#if defined(__STDC__) || defined(__cplusplus)
    IGRint IDdyn_curbypol( 
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
	IGRchar *dummy_out3 )
#else
    IGRint IDdyn_curbypol( DYinfo, point, matrix, objects, num_objects,
		       buffers, num_buffers, dummy_in1, dummy_in2, dummy_in3,
		       dummy_out1, dummy_out2, dummy_out3 )
        struct DPaddnl_info *DYinfo;
        struct EX_button *point;
        IGRdouble *matrix;
        struct GRid **objects;
        struct DPele_header **buffers;
        IGRint *num_objects, *num_buffers;
        IGRchar *dummy_in1, *dummy_in2, *dummy_in3;
        IGRchar *dummy_out1, *dummy_out2, *dummy_out3;
#endif
{
  struct IGRbsp_curve *bspcv;
  IGRlong msg;
  extern IGRboolean BSchrdlkts();

  /* assign the cursor position */
  DYinfo->dyn_cv.points[DYinfo->dyn_cv.num_points*3] = point->x;
  DYinfo->dyn_cv.points[DYinfo->dyn_cv.num_points*3+1] = point->y;
  DYinfo->dyn_cv.points[DYinfo->dyn_cv.num_points*3+2] = point->z;

  /* determine whether curve is available */
  if ( DYinfo->dyn_cv.draw_curve == TRUE )
  {
    bspcv = DYinfo->dyn_cv.header[1].geometry.bspcurve;
    bspcv->order = DYinfo->dyn_cv.cv_order;
    bspcv->periodic = DYinfo->dyn_cv.cv_periodic;
    if ( DYinfo->dyn_cv.mytype == CV_POLES_NONUNIFM || bspcv->periodic == TRUE )
      bspcv->num_poles = DYinfo->dyn_cv.num_points + 1;
    else
      /* if uniform B-spline, draw the portion which is affected by
	 the current cursor position */
      bspcv->num_poles = bspcv->order;
    if ( bspcv->poles )
      om$dealloc( ptr = bspcv->poles );
    bspcv->poles = ( IGRdouble * ) om$malloc( size = ( bspcv->num_poles + 2 ) * sizeof( IGRpoint ));
    if ( bspcv->poles == NULL )
    {
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
      goto quit;
    }
    if ( DYinfo->dyn_cv.mytype == CV_POLES_NONUNIFM || bspcv->periodic == TRUE )
      memcpy( (char *) bspcv->poles, (char *) DYinfo->dyn_cv.points, 
        bspcv->num_poles * sizeof( IGRpoint ));
    else
      memcpy( (char *)bspcv->poles,
	      (char *) (DYinfo->dyn_cv.points +
	      3 * ( DYinfo->dyn_cv.num_points + 1 - bspcv->order )),
	      bspcv->num_poles * sizeof( IGRpoint ));
    bspcv->rational = FALSE;
    bspcv->weights = NULL;
    bspcv->planar = FALSE;
    bspcv->num_boundaries = 0;
    bspcv->bdrys = NULL;

    /* pole duplication if this is a periodic curve */
    if ( bspcv->periodic == TRUE )
    {
      IGRlong total_num_poles;
      IGRpoint *total_poles;

      /* make the last one pole to be the same as the first one */
      bspcv->num_poles = DYinfo->dyn_cv.num_points + 2;
      memcpy( (char *) (bspcv->poles + 3 * bspcv->num_poles), 
        (char *)DYinfo->dyn_cv.points,
	      sizeof( IGRpoint ));

      total_num_poles = bspcv->num_poles + bspcv->order;
      total_poles = ( IGRpoint * ) om$malloc( size = total_num_poles * sizeof( IGRpoint ));
      if ( total_poles == NULL )
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	goto quit;
      }
      MAbcupexpand( &msg, &bspcv->order, &bspcv->rational, &bspcv->num_poles,
		    (IGRpoint *)bspcv->poles, bspcv->weights,
		    &total_num_poles, total_poles, (IGRdouble *)NULL );
      om$dealloc( ptr = bspcv->poles );
      bspcv->num_poles = total_num_poles;
      bspcv->poles = ( IGRdouble * ) total_poles;
    }

    /* determine Bezier or B-spline */
    if ( DYinfo->dyn_cv.mytype == CV_POLES_NONUNIFM )
    {
      if ( bspcv->order == bspcv->num_poles )
	bspcv->non_uniform = FALSE;
      else
	bspcv->non_uniform = TRUE;
    }
    else
      bspcv->non_uniform = FALSE;

    /* determine knots */
    if ( DYinfo->dyn_cv.mytype == CV_POLES_NONUNIFM || bspcv->periodic == TRUE )
    {
      bspcv->num_knots = bspcv->order + bspcv->num_poles;
      if ( bspcv->knots )
	om$dealloc( ptr = bspcv->knots );
      bspcv->knots = ( IGRdouble * ) om$malloc( size = bspcv->num_knots * sizeof( IGRdouble ));
      if ( bspcv->knots == NULL )
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	goto quit;
      }

      if ( DYinfo->dyn_cv.mytype == CV_POLES_NONUNIFM )
	BSchrdlkts( &msg, &bspcv->num_poles, bspcv->poles, &bspcv->order,
		    &bspcv->periodic, bspcv->knots );
      else
      {
	IGRint i;
	IGRdouble delta;

	/* uniform and periodic */
	if ( bspcv->num_poles == bspcv->order )
	  for ( i = 0; i < 2 * bspcv->num_poles; i++ )
	    bspcv->knots[i] = -( bspcv->order - 1 ) + i;
	else
	{
	  delta = 1.0 / (( IGRdouble ) ( bspcv->num_poles - bspcv->order + 1 ));
	  bspcv->knots[bspcv->order - 1] = 0.0;
	  for ( i = 0; i < bspcv->num_poles; i++ )
	    bspcv->knots[bspcv->order + i] = bspcv->knots[bspcv->order - 1 + i] + delta;
	  for ( i = bspcv->order - 1; i > 0; i-- )
	    bspcv->knots[i - 1] = bspcv->knots[i] - delta;
	}
      }
    }
    else
    {
      IGRint i;
      IGRdouble delta;

      /* uniform and nonperiodic B-spline */
      bspcv->num_knots = 2 * bspcv->order;
      if ( bspcv->knots )
	om$dealloc( ptr = bspcv->knots );
      bspcv->knots = ( IGRdouble * ) om$malloc( size = bspcv->num_knots * sizeof( IGRdouble ));
      if ( bspcv->knots == NULL )
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	goto quit;
      }
      delta = 1.0 / (( IGRdouble ) (( DYinfo->dyn_cv.num_points + 1 ) - bspcv->order + 1 ));
      for ( i = 0; i < bspcv->order; i++ )
      {
	bspcv->knots[bspcv->order + i] = 1.0;
	bspcv->knots[bspcv->order - 1 - i] = 1.0 - ( i + 1 ) * delta;
	if ( bspcv->knots[bspcv->order - 1 - i] < 0.0 )
	  bspcv->knots[bspcv->order - 1 - i] = 0.0;
      }
    }

    *buffers = DYinfo->dyn_cv.header;
    *num_buffers = 2;
  }
  else
  {
    *buffers = &DYinfo->dyn_cv.header[0];
    *num_buffers = 1;
  }

 quit:
    return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------*
 * Override init method                                                 *
 *----------------------------------------------------------------------*/
method init( IGRint type; char *str_ptr )
{
  IGRlong sts;
  
  sts = om$send( msg = message ECcurbypol.init( type, str_ptr ),
		 mode = OM_e_wrt_message,
		 targetid = my_id );

  me->cv_info.dyn_cv.points = NULL;
  me->cv_info.dyn_cv.num_points = 0;
  me->cv_info.dyn_cv.draw_curve = FALSE;
  me->cv_info.num_stat_elem = 0;
  me->bspcv = NULL;
  me->stat_cv.poles = NULL;
  me->stat_cv.knots = NULL;
  
  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------*
 * Override delete method                                               *
 *----------------------------------------------------------------------*/
method delete( IGRint defer_flag )
{
  IGRlong sts;
  extern IGRboolean BSfreecv();
  
  if ( me->cv_info.dyn_cv.points )
    om$dealloc( ptr = me->cv_info.dyn_cv.points );
  if ( me->stat_cv.knots )
    om$dealloc( ptr = me->stat_cv.knots );
  me->cv_info.num_stat_elem = 0;

  sts = om$send( msg = message ECcurbypol.delete( defer_flag ),
		 mode = OM_e_wrt_message,
		 targetid = my_id );
  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------*
 * Override pre_sleep method                                            *
 *----------------------------------------------------------------------*/
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
    *dyn_func = IDdyn_curbypol;
    *addnl_info = ( IGRchar * ) &me->cv_info;
  }

  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------*
 * Output command string                                                *
 *----------------------------------------------------------------------*/
method output_command_string()
{
  if ( me->mytype == 0 )
  {
    ex$message( field = MESSAGE_FIELD, msgnumb = IDFFC_M_CurByPol );
  }
  else
  {
    ex$message( field = MESSAGE_FIELD, msgnumb = IDFFC_M_UCvByPol );
  }
  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------*
 * Processing the next event                                            *
 *----------------------------------------------------------------------*/
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
  if (( num_points >= me->u_order && me->u_periodic == FALSE ) ||
      (( num_points >= ( me->u_order - 1 )) && me->u_periodic == TRUE ))
  {
    key = EMS_P_00083;
    *event_mask |= GRm_RJT_MOVEON;
  }
  else
    key = EMS_P_00082;

  /* build the prompt string */
  num_points++;
  ex$message( msgnumb = key,
	      type = "%d",
	      var = `num_points`,
	      buff = prompt_string );

  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------*
 * Perform dynamics method                                              *
 *----------------------------------------------------------------------*/
method perform_dynamics()
{
  struct DPele_header cv_hd;
  IGRboolean disp_cv = FALSE;
  IGRint sts, i;
  IGRdouble delta;
  IGRlong msg;
  extern void EFextract_points(), BSalloccv();

  /* initialize */
  me->bspcv = NULL;

  /* assign which command */
  if ( me->mytype == 0 )
    me->cv_info.dyn_cv.mytype = CV_POLES_NONUNIFM;
  else
    me->cv_info.dyn_cv.mytype = CV_POLES_UNIFM;

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
  if (( me->cv_info.dyn_cv.num_points + 1 ) >= me->u_order ||
      ( me->u_periodic == TRUE &&
      ( me->cv_info.dyn_cv.num_points + 1 ) >= ( me->u_order - 1 )))
  {	/* curve is available */
    me->cv_info.dyn_cv.draw_curve = TRUE;
    me->cv_info.dyn_cv.cv_order = me->u_order;
    me->cv_info.dyn_cv.cv_periodic = me->u_periodic;

    /* initialize to display curve but not polygon */
    me->attr.is_polydis = FALSE;
    me->attr.is_curvedis = TRUE;

    /* Allocate memory for the curve */
    me->bspcv = ( struct IGRbsp_curve * ) om$malloc( size = sizeof( struct IGRbsp_curve ));
    me->bspcv->poles = me->bspcv->knots = NULL;

    /* build display buffer */
    dp$build_dis_buffer( buffer = &me->cv_info.dyn_cv.header[1],
			 type = IGRBC,
			 display_att = &me->display,
			 ele_spec_att = &me->attr,
			 geometry = ( struct IGRbsp_curve * ) me->bspcv );

    /* if uniform B-spline curve and there is static portion
       then display the static portion of the curve */
    if ( me->mytype == 1 && me->cv_info.dyn_cv.cv_periodic == FALSE )
    {
      if ( me->cv_info.dyn_cv.num_points >= me->u_order )
      {
	/* There is a static portion of the curve which won't be affected
	   by current moving cursor. We draw the portion that is static */
	me->stat_cv.order = me->u_order;
	me->stat_cv.periodic = me->u_periodic;
	me->stat_cv.non_uniform = FALSE;
	me->stat_cv.num_poles = me->cv_info.dyn_cv.num_points;
	me->stat_cv.poles = me->cv_info.dyn_cv.points;
	me->stat_cv.rational = FALSE;
	me->stat_cv.weights = NULL;
	me->stat_cv.planar = FALSE;
	me->stat_cv.num_boundaries = 0;
	me->stat_cv.bdrys = NULL;

	/* determine knots */
	me->stat_cv.num_knots = me->stat_cv.order + me->stat_cv.num_poles;
	if ( me->stat_cv.knots )
	  om$dealloc( ptr = me->stat_cv.knots );
	me->stat_cv.knots = ( IGRdouble * ) om$malloc( size = me->stat_cv.num_knots * sizeof( IGRdouble ));
	if ( me->stat_cv.knots == NULL )
	{
	  ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	  goto quit;
	}

	/* assign knot values */
	for ( i = 0; i < me->stat_cv.order; i++ )
	  me->stat_cv.knots[i] = 0.0;
	for ( i = 0; i < me->stat_cv.order - 1; i++ )
	  me->stat_cv.knots[( me->stat_cv.num_poles + 1 ) + i] = 1.0;

	delta = 1.0 / (( IGRdouble ) (( me->stat_cv.num_poles + 1 ) - me->stat_cv.order + 1 ));
	for ( i = 0; i < (( me->stat_cv.num_poles + 1 ) - me->stat_cv.order ); i++ )
	  me->stat_cv.knots[me->stat_cv.order + i] = ( i + 1 ) * delta;

	/* build display buffer */
	dp$build_dis_buffer( buffer = &cv_hd,
			     type = IGRBC,
			     display_att = &me->display,
			     ele_spec_att = &me->attr,
			     geometry = &me->stat_cv );

	/* display that portion of the curve */
	dp$display( msg = &msg,
		    mode = GRbd,
		    num_elem = 1,
		    buffer = &cv_hd );
	disp_cv = TRUE;
      }
    }
  }

  if ( me->cv_info.dyn_cv.num_points > 1 )
  {
    if ( me->cv_info.dyn_cv.draw_curve == TRUE && disp_cv == TRUE )
      me->cv_info.num_stat_elem = 2;
    else
      me->cv_info.num_stat_elem = 1;

    me->stat_line.num_points = me->cv_info.dyn_cv.num_points;
    me->stat_line.points = me->cv_info.dyn_cv.points;

    dp$build_dis_buffer( buffer = &( me->cv_info.stat_elem_buf[0] ),
			 type = IGRPY,
			 display_att = &me->display,
			 geometry = ( struct IGRpolyline * ) &me->stat_line );

    if ( me->cv_info.num_stat_elem == 2 )
      dp$build_dis_buffer( buffer = &( me->cv_info.stat_elem_buf[1] ),
			   type = IGRBC,
			   display_att = &me->display,
			   ele_spec_att = &me->attr,
			   geometry = ( struct IGRbsp_curve * ) &me->stat_cv );
  }
  else
    me->cv_info.num_stat_elem = 0;
  
  /* perform dynamics */
  UI_status( " " );
  sts = dp$dynamics( dyn_fun = IDdyn_curbypol,
		     information = &me->cv_info );

  /* erase the previous drawn static portion of the curve */
  if ( disp_cv == TRUE )
    dp$display( msg = &msg,
	        mode = GRbe,
	        num_elem = 1,
	        buffer = &cv_hd );

  /* free memory */
  if ( me->bspcv )
  {
    if ( me->bspcv->poles )
      om$dealloc( ptr = me->bspcv->poles );
    if ( me->bspcv->knots )
      om$dealloc( ptr = me->bspcv->knots );
    om$dealloc( ptr = me->bspcv );
  }
  
  msg = TRUE;

 quit:
    return OM_S_SUCCESS;
}


/*----------------------------------------------------------------------*
 * Perform construction method                                          *
 *----------------------------------------------------------------------*/
method perform_construction()
{
  struct IGRbsp_curve cv;
  IGRdouble span;
  IGRint i;
  struct GRvg_construct *cnst_list;
  struct IGResbs *sf_spec;
  struct IGResbc cv_spec;
  IGRlong sts;
  extern void EFextract_points();

  me->msg = MSSUCC;
  cv.poles = cv.knots = NULL;

  if ( me->mytype == 0 && me->u_periodic == FALSE )
  {
    sts = om$send( msg = message ECcurbypol.perform_construction(),
		   mode = OM_e_wrt_message,
		   targetid = my_id );
    if ( !( 1 & sts ))
      me->msg = MSFAIL;
  }
  else
  {
    /* load construction list */
    cnst_list = &me->construct_list;

    sf_spec = ( struct IGResbs * ) cnst_list->class_attr;
    cv_spec.is_polydis = sf_spec->is_polydis;
    cv_spec.is_curvedis = TRUE;
    cnst_list->class_attr = ( IGRchar * ) &cv_spec;

    /* initialize curve struct */
    cv.order = me->u_order;
    cv.periodic = me->u_periodic;
    cv.non_uniform = FALSE;
    cv.num_poles = me->number_of_events_input - 1;
    cv.poles = ( IGRdouble * ) om$malloc( size = ( cv.num_poles + 1 ) * 3 * sizeof( IGRdouble ));
    if ( cv.poles == NULL )
    {
      me->msg = MSFAIL;
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
      goto quit;
    }
    EFextract_points( cv.num_poles, me->events, ( IGRpoint * ) cv.poles );
    if ( cv.periodic == TRUE )
    {
      /* if periodic then add last pole to be the same as the first pole */
      memcpy( (char *) (cv.poles + 3 * cv.num_poles), 
        (char *) cv.poles, sizeof( IGRpoint ));
      cv.num_poles++;
    }
    cv.rational = FALSE;
    cv.weights = NULL;
    cv.num_boundaries = 0;
    cv.bdrys = NULL;

    if ( me->mytype == 0 )
    {
      /* this is the periodic and non-uniform case */
      sts = om$construct( classid = OPP_GRbcsubbc_class_id,
			  msg = message GRsubbc.EMcurve_by_poles( cv.order,
								  cv.periodic,
								  cv.num_poles,
								  ( IGRpoint * ) cv.poles,
								  NULL,
								  cnst_list ),
			  p_objid = &me->constructed_object,
			  osnum = me->construct_env.md_id.osnum );
    }
    else
    {
      if ( cv.periodic == TRUE )
      {
	IGRlong total_num_poles;
	IGRpoint *total_poles;

	total_num_poles = cv.num_poles + cv.order;
	total_poles = ( IGRpoint * ) om$malloc( size = total_num_poles * sizeof( IGRpoint ));
	if ( total_poles == NULL )
	{
	  me->msg = MSFAIL;
	  ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	  goto quit;
	}
	MAbcupexpand( &me->msg, &cv.order, &cv.rational, &cv.num_poles,
		      (IGRpoint *)cv.poles, cv.weights,
		      &total_num_poles, total_poles, (IGRdouble *)NULL );
	om$dealloc( ptr = cv.poles );
	cv.num_poles = total_num_poles;
	cv.poles = ( IGRdouble * ) total_poles;
      }

      /* determine knots */
      cv.num_knots = cv.order + cv.num_poles;
      cv.knots = ( IGRdouble * ) om$malloc( size = cv.num_knots * sizeof( IGRdouble ));
      if ( cv.knots == NULL )
      {
	me->msg = MSFAIL;
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	goto quit;
      }

      if ( cv.periodic == TRUE )
      {
	/* uniform and periodic */
	if ( cv.num_poles == cv.order )
	  for ( i = 0; i < 2 * cv.num_poles; i++ )
	    cv.knots[i] = -( cv.order - 1 ) + i;
	else
	{
	  span = 1.0 / (( IGRdouble ) ( cv.num_poles - cv.order + 1 ));
	  cv.knots[cv.order - 1] = 0.0;
	  for ( i = 0; i < cv.num_poles; i++ )
	    cv.knots[cv.order + i] = cv.knots[cv.order - 1 + i] + span;
	  for ( i = cv.order - 1; i > 0; i-- )
	    cv.knots[i - 1] = cv.knots[i] - span;
	}
      }
      else
      {
	for ( i = 0; i < cv.order; i++ )
	{
	  cv.knots[i] = 0;
	  cv.knots[cv.num_poles + i] = 1.0;
	}
	span = ( IGRdouble ) ( cv.num_poles - cv.order + 1 );
	for ( i = 0; i < ( cv.num_poles - cv.order ); i++ )
	  cv.knots[cv.order + i] = ( IGRdouble ) ( i + 1 ) / span;
      }

      /* assign geometry to construction list */
      cnst_list->geometry = ( IGRchar * ) &cv;

      sts = om$construct( classid = OPP_GRbcsubbc_class_id,
			  msg = message GRvg.GRconstruct( cnst_list ),
			  p_objid = &me->constructed_object,
			  osnum = me->construct_env.md_id.osnum );
    }
    if ( !( 1 & sts ))
      me->msg = MSFAIL;
    cnst_list->class_attr = ( IGRchar * ) sf_spec;

    /* free memory */
    if ( cv.poles )
      om$dealloc( ptr = cv.poles );
    if ( cv.knots )
      om$dealloc( ptr = cv.knots );
  }

 quit:
  if ( 1 & me->msg )
    return OM_S_SUCCESS;
  else
  {
    me->constructed_object = NULL_OBJID;
    return OM_S_SUCCESS;
  }
}

end implementation IDcurbypol;
