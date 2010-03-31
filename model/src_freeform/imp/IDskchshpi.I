class implementation IDskchshp;

/*
Abstract
	This command enhences the default EMS Place Curve by Digitizing
	command. User is allowed to input more than one line strings and
	then to convert line strings to B-spline curves.

History
	03/20/92	JSY	Design and coding.
*/

#include <stdio.h>
#include <math.h>
#include "OMlimits.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "igrdef.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "dp.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"

#include "grdpbmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "adpdef.h"
#include "grmacros.h"
#include "dpstruct.h"
#include "bsparameters.h"

#include "EMS.h"
#include "EMSdpb.h"
#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"

#include "msdef.h"
#include "IDffmsg.h"
#include "IDffcmd.h"
#include "ECmsg.h"
#include "bsfitratcv.h"    /* prototypes */
#include "bsxtractpar.h"    /* prototypes */
#include "msmacros.h"    /* prototypes */
#include <memory.h>    /* prototypes */

/* state number definition */
#define INPUT_START_PT 2
#define INPUT_END_PT 3
#define CONSTRUCT_CV 4

extern OMuword OPP_GRbcsubbc_class_id;
from GRgraphics import GRconstruct;

/*----------------------------------------------------------------------*
 * Wakeup method                                                        *
 *----------------------------------------------------------------------*/
method wakeup( IGRint pos )
{
  IGRlong sts;
  
  sts = om$send( msg = message ECdgts.wakeup( pos ),
		 mode = OM_e_wrt_message,
		 targetid = my_id );

  me->espy.is_closed = FALSE;
  me->info.poly = &me->polyline;
  me->info.md_env = &ME.ECelement->md_env;

  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------*
 * Execute method                                                       *
 *----------------------------------------------------------------------*/
method execute( IGRint *response; IGRchar *response_data; IGRint pos )
{
  struct IGRpolyline disp_ln;
  IGRlong event_mask;
  struct GRevent acc_event;
  struct DPele_header dp_buff;
  IGRint flags = DP_NO_CURSOR;
  OM_S_OBJID new_objid;
  struct GRid id;
  IGRboolean loop = TRUE, periodic = FALSE;
  IGRlong sts, msg;

  extern void EMgenptstream();

  ex$message( field = MESSAGE_FIELD, msgnumb = IDFFC_M_SkchShp );

  /* initialization */
  event_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_RESTART;

  /* initialize display buffer */
  disp_ln.num_points = 0;
  disp_ln.points = NULL;
  dp$build_dis_buffer( buffer = &me->info.buff,
		       type = IGRPY,
		       display_att = &ME.ECelement->active_display,
		       ele_spec_att = &me->espy,
		       geometry = &disp_ln );
  dp$build_dis_buffer( buffer = &dp_buff,
		       type = IGRPY,
		       display_att = &ME.ECelement->active_display,
		       ele_spec_att = &me->espy,
		       geometry = &me->polyline );

  /* enter infinite loop */
  do
  {
    switch ( ME.super_cmd->state )
    {
    case 0:
      ME.super_cmd->state = INPUT_START_PT;
      break;

    case INPUT_START_PT:
      /* initialization */
      if ( me->polyline.points )
	om$dealloc( ptr = me->polyline.points );
      me->polyline.num_points = 0;
      me->polyline.points = NULL;
      me->info.firstcall = TRUE;

      /* initialize window information */
      EMinit_wininfo();

      sts = co$getevent( msg = &msg,
			 event_mask = event_mask,
			 msgnum = IDFF_P_StartSkch,
			 response = response,
			 response_data = response_data,
			 event = &acc_event );
      if ( !( 1 & sts ))
	return OM_E_ABORT;
      UI_status( "" );

      switch ( acc_event.response )
      {
      case EX_RJT_MOVEON:
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_IGRJTMOVEON );
	ME.super_cmd->state = INPUT_START_PT;
	break;

      case EX_DATA:
	memcpy( (char *)me->from_point, (char *)&acc_event.event.button.x, 
            sizeof( IGRpoint ));
	memcpy( (char *)me->info.start_pt, (char *)me->from_point, 
            sizeof( IGRpoint ));

	ME.super_cmd->state = INPUT_END_PT;
	break;

      case EX_BACK_UP:
      default:
	return OM_S_SUCCESS;
      }
      break;

    case INPUT_END_PT:
      /* print prompt */
      ex$message( field = PROMPT_FIELD, msgnumb = IDFF_P_EndSkch );

      /* invoke dynamics to draw line string */
      sts = dp$dynamics( dyn_fun = EMgenptstream,
			 information = &me->info,
			 flags = &flags );

      sts = co$getevent( msg = &msg,
			 event_mask = event_mask,
			 response = response,
			 response_data = response_data,
			 event = &acc_event );
      if ( !( 1 & sts ))
	return OM_E_ABORT;

      /* erase the line string drawed */
      dp$display( msg = &msg,
		  mode = GRbehe,
		  num_elem = 1,
		  buffer = &dp_buff );

      switch ( acc_event.response )
      {
      case GR_UNKNOWN_TYPE:
	return OM_S_SUCCESS;

      case EX_RJT_MOVEON:
      case EX_BACK_UP:
	ME.super_cmd->state = INPUT_START_PT;
	break;

      case EX_DATA:
	ME.super_cmd->state = CONSTRUCT_CV;
	break;

      default:
	return OM_S_SUCCESS;
      }
      break;

    case CONSTRUCT_CV:
      {
	IGRdouble chd_tol, avg_err, max_err;
	IGRpoint max_pt;
	IGRint max_ind;
	struct GRvg_construct cnst_list;
	OMuword act_os;
	struct IGRbsp_curve *cv = NULL;
	IGRshort cv_order;
	IGRuchar ch;
	
	BSxtractpar( &msg, BSTOLCHRDHT, &chd_tol );
	
	/* make tolerance a little bigger so that later least square fit
	   performs faster when it tries to fit a curve through the set
	   of input points */
	chd_tol *= 10.0;
	
	/* initialize standard construction list */
	cnst_list.msg = &msg;
	cnst_list.newflag = 0;
	cnst_list.level = ME.ECelement->active_level;
	cnst_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
	cnst_list.display = &ME.ECelement->active_display;
	cnst_list.name = NULL;
	cnst_list.class_attr = NULL;
	cnst_list.env_info = &ME.ECelement->md_env;
	cnst_list.geometry = NULL;
	
	act_os = ME.ECelement->md_env.md_id.osnum;
	
	EMdpb_get( &msg, EMSdpb_u_order, &ch );
	cv_order = ( IGRshort ) ch;
	
	/* processing */
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_M_ProcSts );
	
	if ( me->polyline.num_points )
	{
	  BSfitratcv( me->polyline.num_points,
		      ( IGRpoint * ) me->polyline.points,
		      NULL,
		      NULL,
		      NULL,
		      cv_order,
		      0,
		      NULL,
		      periodic,
		      2,
		      0,
		      0,
		      NULL,
		      NULL,
		      NULL,
		      NULL,
		      0.0,
		      0.0,
		      0.0,
		      0.0,
		      2,
		      chd_tol,
		      &cv,
		      &avg_err,
		      &max_err,
		      &max_ind,
		      max_pt,
		      &msg );
	  if ( msg != BSSUCC )
	  {
	    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_ErrCnstCv );
	    EFplace_line_string( NULL_OBJID, &cnst_list, me->polyline.num_points, me->polyline.points, &new_objid, &msg );
	  }
	  else
	  {
	    cnst_list.geometry = ( IGRchar * ) cv;
	    sts = om$construct( classid = OPP_GRbcsubbc_class_id,
			       osnum = act_os,
			       p_objid = &new_objid,
			       msg = message GRgraphics.GRconstruct( &cnst_list ));
	    if ( !( 1 & sts ))
	    {
	      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_ErrCnstCv );
	      cnst_list.geometry = NULL;
	      EFplace_line_string( NULL_OBJID, &cnst_list, me->polyline.num_points, me->polyline.points, &new_objid, &msg );
	    }
	    else
	      UI_status( "" );
	  }
	}
	else
	{
	  EFplace_line_string( NULL_OBJID, &cnst_list, 1, me->info.start_pt, &new_objid, &msg );
	  UI_status( "" );
	}

	/* display the object */
	id.objid = new_objid;
	id.osnum = act_os;
	gr$display_object( object_id = &id,
			   mode = GRbd );

	ME.super_cmd->state = INPUT_START_PT;
      }
      break;
    }
  } while ( loop );

  return OM_S_SUCCESS;
}

end implementation IDskchshp;
