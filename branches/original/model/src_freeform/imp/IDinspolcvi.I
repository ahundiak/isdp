class implementation IDinspolcv;

/*
Abstract
	This command is similar to command Insert Pole without Changing
	Shape. The difference is that this command has an option to
	change the shape of the curve after a new pole is inserted.

History
	03/12/92	JSY	Design and coding.
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
#include "godef.h"
#include "go.h"
#include "gocmacros.h"
#include "dp.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grmacros.h"
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
#include "EC_I.h"
#include "EMSdpb.h"
#include "IDinspolcvi.h"    /* prototypes */
#include "bsalloccv.h"    /* prototypes */
#include "bschrdlkts.h"    /* prototypes */
#include "bscv_copy.h"    /* prototypes */
#include "bsdistptpt.h"    /* prototypes */
#include "bsfindspn.h"    /* prototypes */
#include "bsfreecv.h"    /* prototypes */
#include "bsinsertval.h"    /* prototypes */
#include "bsinspolcv1.h"    /* prototypes */
#include "bsmdstptcv.h"    /* prototypes */
#include "msmacros.h"    /* prototypes */
#include <memory.h>    /* prototypes */

#define LITTLE_CURVE 1
#define MAXNUM 100

from GRsubbc import EMinsert_pole;
from GRgraphics import GRdisplay;
from GRvg import GRpostabsg;

/*----------------------------------------------------------------------*
 * Function to do real dynamics                                         *
 *----------------------------------------------------------------------*/
#argsused
IGRint IDdyn_inspol(
	struct DP_inspol *DYinfo, 
	struct EX_button *point, 
	IGRdouble *matrix, 
	struct GRid **objects, 
	IGRint *num_objects, 
	struct DPele_header **buffers, 
	IGRint *num_buffers, 
	IGRchar *dummy_in1, 
        IGRchar *dummy_in2, IGRchar *dummy_in3, IGRchar *dummy_out1, 
        IGRchar *dummy_out2, IGRchar *dummy_out3)
{
  IGRpoint pt, pt1, pt2;
  struct IGRbsp_curve *bspcv;
  struct IGRpolyline *poly_ln;
  IGRpoint base;
  IGRdouble par, dist, node1, node2, dist1, dist2, new_knot, new_weight = 0.0;
  IGRint index, index_k, inum = 1, num_knots, j;
  IGRboolean index_ind = FALSE;
  IGRlong msg;

  /* initialize */
  pt[0] = point->x;
  pt[1] = point->y;
  pt[2] = point->z;
  bspcv = DYinfo->header[1].geometry.bspcurve;
  BScv_copy( &msg, DYinfo->bspcv, bspcv );

  /* ------------------------------------------------ */
  /* the following code is adapted from bsinspolcv1.c */
  /* ------------------------------------------------ */

  BSmdstptcv( &DYinfo->ln, pt, &par, base, &dist, &msg );

  /* determine the segment that contains the pole pt */
  BSfindspn( &msg, &DYinfo->ln.order, &DYinfo->ln.num_poles, DYinfo->ln.knots, &par, &index );
  index--;

  if ( bspcv->rational )
  {
    for ( j = 0; j < 3; j++ )
    {
      pt1[j] = bspcv->poles[index * 3 + j] / bspcv->weights[index];
      pt2[j] = bspcv->poles[( index + 1 ) * 3 + j] / bspcv->weights[index + 1];
    }
  }
  else
  {
    memcpy( (char *)pt1, (char *)(bspcv->poles + index * 3), 
        sizeof( IGRpoint ));
    memcpy( (char *)pt2, (char *)(bspcv->poles + ( index + 1 ) * 3), 
        sizeof( IGRpoint ));
  }

  /* now draw polygon at the cursor */
  poly_ln = DYinfo->header[0].geometry.polyline;
  for ( j = 0; j < 3; j++ )
  {
    poly_ln->points[j] = pt1[j];
    poly_ln->points[3 + j] = pt[j];
    poly_ln->points[6 + j] = pt2[j];
  }

  /* compute the new knot */
  node1 = node2 = 0.0;
  for ( j = index + 1; j < index + bspcv->order; j++ )
  {
    node1 += bspcv->knots[j];
    node2 += bspcv->knots[j + 1];
  }
  node1 /= ( bspcv->order - 1 );
  node2 /= ( bspcv->order - 1 );
  dist1 = BSdistptpt( &msg, pt1, pt );
  dist2 = BSdistptpt( &msg, pt, pt2 );
  new_knot = ( dist1 * node2 + dist2 * node1 ) / ( dist1 + dist2 );

  /* insert new knot into the knot array */
  num_knots = bspcv->num_knots;
  BSinsertval( &msg, &index_ind, &index_k, &num_knots, &bspcv->knots, &inum, &new_knot );
  (bspcv->num_poles)++;
  (bspcv->num_knots)++;
  bspcv->non_uniform = TRUE;
  
  /* if curve is rational, compute and insert new weight */
  if ( bspcv->rational )
  {
    new_weight = ( dist2 * bspcv->weights[index] +
		   dist1 * bspcv->weights[index + 1] ) / ( dist1 + dist2 );
    for ( j = bspcv->num_poles - 1; j > index + 1; j-- )
      bspcv->weights[j] = bspcv->weights[j - 1];
    bspcv->weights[index + 1] = new_weight;
  }

  /* insert new pole into the pole array */
  for ( j = bspcv->num_poles - 1; j > index + 1; j-- )
    memcpy( (char *)(bspcv->poles + 3 * j), (char *)(bspcv->poles + 3 * 
	( j - 1 )), sizeof( IGRpoint ));

  if ( bspcv->rational )
  {
    for ( j = 0; j < 3; j++ )
      bspcv->poles[3 * ( index + 1 ) + j] = new_weight * pt[j];
  }
  else
    memcpy( (char *)(bspcv->poles + 3 * ( index + 1 )), (char *)pt, 
        sizeof( IGRpoint ));

  *buffers = DYinfo->header;
  *num_buffers = 2;

  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------*
 * Output command string                                                *
 *----------------------------------------------------------------------*/
method output_command_string()
{
  ex$message( field = MESSAGE_FIELD, msgnumb = IDFFC_M_InsPolCv );
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
  IGRlong key;

  /* initialze */
  me->msg = MSSUCC;

  /* branch based on the command state */
  switch ( me->number_of_events_input )
  {
  case 0:	/* event 1 prompt */

    *locate_desired = TRUE;
    EFget_locate_information( LITTLE_CURVE, loc_info );
    loc_info->operation_type = geometry_modification;
    loc_info->acc_key = IDFF_P_AccptRejCrv;
    key = EMS_P_00030;
    break;

  case 1:	/* event 2 prompt */

    key = IDFF_P_AccptRejCrv;
    break;

  case 2:	/* event 3 prompt */

    key = IDFF_P_ChgCvShp;
    *event_mask |= GRm_RJT_MOVEON;
    break;

  default:
    me->msg = MSFAIL;
    goto quit;
  }

  /* build the prompt string */
  ex$message( msgnumb = key, buff = prompt_string );

 quit:
  if ( me->msg == MSFAIL )
    return FALSE;
  else
    return TRUE;
}

/*----------------------------------------------------------------------*
 * Verify input event                                                   *
 *----------------------------------------------------------------------*/
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

  if ( me->number_of_events_input == 3 &&
       ( event->response == EX_DATA || event->response == EX_RJT_MOVEON ))
    *done = TRUE;

  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------*
 * Perform dynamics                                                     *
 *----------------------------------------------------------------------*/
method perform_dynamics()
{
  struct GRlc_info *loc_info;
  struct GRmd_env *md_env;
  struct GRid *id;
  struct IGRbsp_curve *curve, *new_bspcv;
  struct DPele_header poly_hd;
  struct IGResbc cv_attr;
  struct IGRpolyline poly_ln;
  IGRdouble pol_array[3 * MAXNUM], knot_array[MAXNUM + MAX_ORDER], pts[9];
  IGRboolean mem_alloc = FALSE;
  IGRint i, j;
  IGRlong sts, msg;
  struct DP_inspol dyn_cv;
  extern IGRlong EMpromote_class(), EMget_the_geometry();

  /* initialize */
  me->msg = MSSUCC;
  loc_info = &me->events[0].located_object[0];
  md_env = &loc_info->module_info;
  id = &loc_info->located_obj;

  if ( me->number_of_events_input == 1 )
  {
    /* ECcons_exec will call dynamics if it is backuped.
       What needs to be done is just to hilite the located curve.
       In order not to override ECcons_exec's execute method, I
       add code here to perform this task */
    gr$display_object( object_id = id,
		       mode = GRhd );
  }
  else
  {
    /* promote class if necessary */
    sts = EMpromote_class( TRUE, md_env, id, &me->msg );
    if ( !( 1 & sts ))
    {
      me->msg = MSFAIL;
      goto quit;
    }

    /* get curve geometry */
    sts = EMget_the_geometry( loc_info, TRUE, FALSE, TRUE, my_id, &curve, &msg );
    if ( !( 1 & sts ))
    {
      if ( curve )
	BSfreecv( &msg, curve );
      me->msg = MSFAIL;
      goto quit;
    }

    /* ------------------------------------------------ */
    /* the following code is adapted from bsinspolcv1.c */
    /* ------------------------------------------------ */

    if ( ( curve->num_poles + 1 ) > MAXNUM )
    {
      mem_alloc = TRUE;
      dyn_cv.ln.poles = ( IGRdouble * ) om$malloc( size = curve->num_poles * sizeof( IGRpoint ));
      if ( dyn_cv.ln.poles == NULL )
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	me->msg = MSFAIL;
	goto quit;
      }
      dyn_cv.ln.knots = ( IGRdouble * ) om$malloc( size = ( 2 + curve->num_poles ) * sizeof( IGRdouble ));
      if ( dyn_cv.ln.knots == NULL )
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	me->msg = MSFAIL;
	goto quit;
      }
    }
    else
    {
      dyn_cv.ln.poles = pol_array;
      dyn_cv.ln.knots = knot_array;
    }
    dyn_cv.ln.order = 2;
    dyn_cv.ln.periodic = FALSE;
    dyn_cv.ln.non_uniform = TRUE;
    dyn_cv.ln.num_poles = curve->num_poles;

    if ( curve->rational )
    {
      for ( i = 0; i < curve->num_poles; i++ )
	for ( j = 0; j < 3; j++ )
	  dyn_cv.ln.poles[i * 3 + j] = curve->poles[i * 3 + j] / curve->weights[i];
    }
    else
      memcpy( (char *)dyn_cv.ln.poles, (char *)curve->poles, 
        curve->num_poles * sizeof( IGRpoint ));

    dyn_cv.ln.num_knots = dyn_cv.ln.order + dyn_cv.ln.num_poles;
    dyn_cv.ln.rational = FALSE;
    dyn_cv.ln.weights = NULL;
    BSchrdlkts( &msg, &dyn_cv.ln.num_poles, dyn_cv.ln.poles, &dyn_cv.ln.order, &dyn_cv.ln.periodic, dyn_cv.ln.knots );

    dyn_cv.ln.planar = curve->planar;
    dyn_cv.ln.phy_closed = curve->phy_closed;
    dyn_cv.ln.num_boundaries = 0;
    dyn_cv.ln.bdrys = NULL;

    /* initialize to display polygon but not curve */
    cv_attr.is_polydis = TRUE;
    cv_attr.is_curvedis = FALSE;

    /* build display buffer */
    dp$build_dis_buffer( buffer = &poly_hd,
			 type = IGRBC,
			 display_att = &me->display,
			 ele_spec_att = &cv_attr,
			 geometry = ( struct IGRbsp_curve * ) &dyn_cv.ln );

    /* display the control polygon */
    dp$display( msg = &msg,
	        mode = GRbd,
	        num_elem = 1,
	        buffer = &poly_hd );

    /* build display buffer */
    poly_ln.num_points = 3;
    poly_ln.points = pts;
    dp$build_dis_buffer( buffer = &dyn_cv.header[0],
			 type = IGRPY,
			 display_att = &me->display,
			 geometry = ( struct IGRpolyline * ) &poly_ln );

    /* allocate and copy curve to dyn_cv.bspcv */
    BSalloccv( curve->order, curve->num_poles, curve->rational, 0, &dyn_cv.bspcv, &msg );
    BScv_copy( &msg, curve, dyn_cv.bspcv );

    /* allocate a bspline curve and build display buffer */
    BSalloccv( curve->order, curve->num_poles + 1, curve->rational, 0, &new_bspcv, &msg );

    /* initialize to display curve but not polygon */
    cv_attr.is_polydis = FALSE;
    cv_attr.is_curvedis = TRUE;

    /* build display buffer */
    dp$build_dis_buffer( buffer = &dyn_cv.header[1],
			 type = IGRBC,
			 display_att = &me->display,
			 ele_spec_att = &cv_attr,
			 geometry = ( struct IGRbsp_curve * ) new_bspcv );

    /* perform dynamics */
    sts = dp$dynamics( dyn_fun = IDdyn_inspol,
		      information = &dyn_cv );

    /* erase the control polygon */
    dp$display( msg = &msg,
	        mode = GRbe,
	        num_elem = 1,
	        buffer = &poly_hd );

    /* free memory */
    if ( mem_alloc )
    {
      om$dealloc( ptr = dyn_cv.ln.poles );
      om$dealloc( ptr = dyn_cv.ln.knots );
    }
    BSfreecv( &msg, dyn_cv.bspcv );
    BSfreecv( &msg, new_bspcv );
    if ( curve )
      BSfreecv( &msg, curve );

    me->msg = MSSUCC;
  }

 quit:
  if ( me->msg == MSFAIL )
    return OM_E_ABORT;
  else
    return OM_S_SUCCESS;
}


/*----------------------------------------------------------------------*
 * Perform modification to the curve                                    *
 *----------------------------------------------------------------------*/
method perform_modification()
{
  struct GRlc_info *loc_info;
  struct GRmd_env *md_env;
  struct GRid *id;
  struct GRevent *event;
  IGRlong sts;
  extern IGRlong EMpromote_class();

  me->msg = MSSUCC;
  loc_info = &me->events[0].located_object[0];
  md_env = &loc_info->module_info;
  id = &loc_info->located_obj;

  /* promote class if necessary */
  sts = EMpromote_class( TRUE, md_env, id, &me->msg );
  if ( !( 1 & sts ))
  {
    me->msg = MSFAIL;
    goto quit;
  }

  /* perform real modification */
  event = &me->events[me->number_of_events_input - 1];
  if ( event->response == EX_DATA )
  {
    /* perform insert and change shape of the curve */
    sts = om$send( msg = message IDinspolcv.IDins_pl_chg_shp( loc_info,
							      &me->events[2].event.button.x,
							      &me->msg ),
		   targetid = my_id );
  }
  else if ( event->response == EX_RJT_MOVEON )
  {
    /* insert pole without change shape */
    sts = om$send( msg = message GRsubbc.EMinsert_pole( loc_info,
						        &me->events[2].event.button.x,
						        &me->msg ),
		   targetid = id->objid,
		   targetos = id->osnum );
  }
  if ( !( 1 & sts ))
  {
    me->msg = MSFAIL;
    goto quit;
  }

 quit:
  if ( 1 & me->msg )
    return OM_S_SUCCESS;
  else
    return OM_E_ABORT;
}

/*----------------------------------------------------------------------*
 * Insert pole into curve and change curve shape                        *
 *----------------------------------------------------------------------*/
method IDins_pl_chg_shp( struct GRlc_info *lc_info;
			 IGRpoint point;
			 IGRlong *msg )
{
  struct IGRbsp_curve *curve = NULL;
  struct GRid *id;
  struct GRpost_info info;
  GRobjid new_objid;
  IGRlong sts;
  extern IGRlong EMget_the_geometry();

  /* get curve geometry */
  sts = EMget_the_geometry( lc_info, TRUE, FALSE, TRUE, my_id, &curve, msg );
  if ( !( 1 & sts ))
  {
    *msg = MSFAIL;
    goto quit;
  }

  /* call math to insert pole and change curve shape */
  BSinspolcv1( point, point, curve, msg );
  if ( *msg != BSSUCC )
  {
    *msg = MSFAIL;
    goto quit;
  }

  /* post modified geometry into database */
  info.construct_flag = FALSE;
  id = &lc_info->located_obj;
  sts = om$send( msg = message GRvg.GRpostabsg( msg,
					        &lc_info->module_info,
					        &info,
					        ( IGRchar * ) curve,
					        &new_objid ),
		 targetid = id->objid,
		 targetos = id->osnum );
  if ( !( 1 & sts ))
  {
    if ( curve )
      BSfreecv( msg, curve );
    *msg = MSFAIL;
    goto quit;
  }

  if ( curve )
    BSfreecv( msg, curve );
  GRabsg_del_all();
  /*
  GR_NOTIFY_LISTERNERS( msg, &sts, GR_GEOM_MODIFIED );
  */
  
 quit:
  if ( *msg == MSFAIL )
    return OM_E_ABORT;
  else
  {
    *msg = MSSUCC;
    return OM_S_SUCCESS;
  }
}

/*----------------------------------------------------------------------*
 * Perform duty to modify curve                                         *
 *----------------------------------------------------------------------*/
method perform_duty()
{
  struct GRlc_info *loc_info;
  struct GRid *id;
  IGRlong sts;

  /* initialize */
  loc_info = &me->events[0].located_object[0];
  id = &loc_info->located_obj;

  /* Erase the object */
  gr$display_object( object_id = id,
		     mode = GRbehe );

  /* perform modification */
  sts = om$send( msg = message ECmodify.perform_modification(),
		 targetid = my_id );

  /* if an error occured then inform user that modification failed */
  if ( !( 1 & sts ))
  {
    ex$message( field = ERROR_FIELD, msgnumb = EMS_I_00029 );
    me->msg = MSFAIL;
    goto quit;
  }

  /* display the modified object */
  gr$display_object( object_id = id,
		     mode = GRbd );

  /* clear the status field */
  ex$message( field = ERROR_FIELD, msgnumb = EMS_I_00000 );

  me->msg = MSSUCC;

 quit:
  return OM_S_SUCCESS;
}

end implementation IDinspolcv;
