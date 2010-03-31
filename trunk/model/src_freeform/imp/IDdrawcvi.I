/**@***********************************************************************

 FILE:
 	IDdrawcvi.I

 ROUTINES:
	init()
	wakeup()
	delete()
	pre_sleep()
	sleep()
	status_disp()
	do_form()
	drawcv_process_fm()
	output_command_string()
	next_event_processing()
	verify_event()
	perform_dynamics()
	perform_construction()

 **************************************************************************/

class implementation IDdrawcv;

/*
Abstract
	This command consolidates the existing curve creation commands.
	It has a status form to choose either one of the following ways
	to create a curve:
	points or poles;
	uniform or nonuniform;
	tangent constraint or not.
	
History
	08/18/92	JSY	Creation.
	08/31/93	JSY	Add support for smart sketch.
	08/13/94        scw     clarified sleep method
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
#include "comisc.h"
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
#include "FI.h"
#include "SSdef.h"
#include "SS.h"
#include "SSmacros.h"
#include "SKdef.h"
#include "SKmacros.h"
#include "IDdrawcvi.h"     /* prototypes */
#ifdef X11
/* problem finding Xlib.h since included by not with X11/Xlib.h
	#include "XFIproto_pub.h"*/    /* prototypes */
#else
#include "IDffforms.h"    /* prototypes */
#endif
#include "IDcurbypoli.h"    /* prototypes */
#include "IDcvbyptsi.h"    /* prototypes */
#include "bsalloccv.h"    /* prototypes */
#include "bscvarrevt.h"    /* prototypes */
#include "bsdotp.h"    /* prototypes */
#include "bsfreecv.h"    /* prototypes */
#include "bsmkvec.h"    /* prototypes */
#include "bsnorvec.h"    /* prototypes */
#include "bsxtractpar.h"    /* prototypes */
#include "mabcupexp.h"    /* prototypes */
#include "msmacros.h"    /* prototypes */
#include <memory.h>    /* prototypes */
#include "bsdistptpt.h"    /* prototypes */

#define STAT_FORM 101
#define SAVE_CHANGE 1
#define NO_CHANGE 4
#define BY_POINTS 11
#define BY_POLES 12
#define UNIFM_CV 14
#define NONUNIFM_CV 15
#define TAN_CONSTR 16

extern OMuword OPP_GRsubbc_class_id;
extern OMuword OPP_GRbcsubbc_class_id;
from GRsubbc import EMdirect_fit_curve, EMcurve_by_poles;
from GRvg import GRconstruct;

/*----------------------------------------------------------------------*
 * Function to project a point onto a line                              *
 *----------------------------------------------------------------------*/
void IDproj_pt_onto_line(
    IGRpoint ln_pt, 
    IGRvector ln_dir, 
    IGRpoint pt, 
    IGRpoint proj_pt)
{
  IGRvector dir, vec;
  IGRdouble proj_len;
  IGRlong msg;

  memcpy((char *) dir, (char *)ln_dir, sizeof( IGRvector ));
  BSnorvec( &msg, dir );
  
  BSmkvec( &msg, vec, ln_pt, pt );
  proj_len = BSdotp( &msg, vec, dir );
  
  proj_pt[0] = ln_pt[0] + proj_len * dir[0];
  proj_pt[1] = ln_pt[1] + proj_len * dir[1];
  proj_pt[2] = ln_pt[2] + proj_len * dir[2];
}
/**@*********** drawcv_process_fm() ***************************************

 ABSTRACT:
	Form notification routine

 SYNOPSIS:
	void drawcv_process_fm( IGRint form_label;
				IGRint gadget_label;
				IGRdouble value;
				Form form_ptr )

	(I)	IGRint form_label
			The status form label
	(I)	IGRint gadget_label
			The gadget label
	(I)	IGRdouble value
			The gadget input value
	(I)     Form form_ptr
			Pointer to the status form

 RETURN:
	NONE

 **************************************************************************/

void drawcv_process_fm( form_label, gadget_label, value, form_ptr )
IGRint form_label, gadget_label;
IGRdouble value;
Form form_ptr;
{
  GRobjid cmd_obj;
  GRspacenum cmd_os;
  IGRlong msg, sts;
  
  sts = FIf_get_cmd_oid_os( form_ptr, (unsigned int *) &cmd_obj, &cmd_os );
  if ( sts != FI_SUCCESS )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_ErrFmCmdObj );
  }    
  else
  {
    sts = om$send( msg = message IDdrawcv.do_form( &msg,
						   form_label,
						   gadget_label,
						   value ),
		   senderid = NULL_OBJID,
		   targetid = cmd_obj,
		   targetos = cmd_os );
    if ( sts != OM_S_SUCCESS )
    {
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_ErrProcForm );
    }
  }
}

/*----------------------------------------------------------------------*
 * Function to do real dynamics                                         *
 *----------------------------------------------------------------------*/
#argsused
IGRint IDdyn_projptln(
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
  IGRpoint cur_pt, proj_pt;

  memcpy((char *) cur_pt, (char *)&( point->x ), sizeof( IGRpoint ));
  IDproj_pt_onto_line( DYinfo->dyn_cv.points,
		     DYinfo->dyn_cv.tan,
		     cur_pt, proj_pt );
  
  /* assign the cursor position */
  memcpy((char *) (DYinfo->dyn_cv.points + DYinfo->dyn_cv.num_points * 3),
	  (char *)proj_pt, sizeof( IGRpoint ));
  
  *buffers = &DYinfo->dyn_cv.header[0];
  *num_buffers = 1;

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
  IGRdouble gd_val;
  IGRlong sts;
  
  /* send init message to parent */
  sts = om$send( msg = message ECfit.init( type, str_ptr ),
		 mode = OM_e_wrt_message,
		 targetid = my_id );
  ex$message( field = ERROR_FIELD, msgnumb = EMS_I_InvkStatusFrm );

  /* initialize status form */
  sts = FIf_new( STAT_FORM, "IDDrawCv", drawcv_process_fm, &me->stat_form );
  if ( sts != FI_SUCCESS )
    return OM_E_ABORT;
  sts = FIf_set_cmd_oid_os( me->stat_form, my_id, OM_Gw_current_OS );
  if ( sts != FI_SUCCESS )
    return OM_E_ABORT;

  /* get default form parameter setting */
  me->pts_or_pol = 0;
  FIg_get_value( me->stat_form, BY_POINTS, &gd_val );
  if (( IGRboolean ) gd_val == TRUE )
  {
    me->pts_or_pol = BY_POINTS;
    FIg_set_state( me->stat_form, BY_POLES, 0 );
  }
  else
  {
    FIg_get_value( me->stat_form, BY_POLES, &gd_val );
    if (( IGRboolean ) gd_val == TRUE )
      me->pts_or_pol = BY_POLES;
    else
    {
      /* if none of the type is set, assign a default one */
      me->pts_or_pol = BY_POINTS;
      FIg_set_state( me->stat_form, BY_POINTS, 1 );
    }
  }

  me->cv_type = 0;
  FIg_get_value( me->stat_form, UNIFM_CV, &gd_val );
  if (( IGRboolean ) gd_val == TRUE )
  {
    me->cv_type = UNIFM_CV;
    FIg_set_state( me->stat_form, NONUNIFM_CV, 0 );
  }
  else
  {
    FIg_get_value( me->stat_form, NONUNIFM_CV, &gd_val );
    if (( IGRboolean ) gd_val == TRUE )
      me->cv_type = NONUNIFM_CV;
    else
    {
      /* if none of the type is set, assign a default one */
      me->cv_type = UNIFM_CV;
      FIg_set_state( me->stat_form, UNIFM_CV, 1 );
    }
  }
  FIg_get_value( me->stat_form, TAN_CONSTR, &gd_val );
  me->tan_cnstr = ( IGRboolean ) gd_val;

  me->form_displayed = FALSE;

  me->cv_info.dyn_cv.num_points = 0;
  me->cv_info.dyn_cv.points = NULL;
  me->cv_info.dyn_cv.draw_curve = FALSE;
  me->cv_info.dyn_cv.have_tan = FALSE;
  me->cv_info.num_stat_elem = 0;
  me->bspcv = NULL;
  me->stat_cv.poles = NULL;
  me->stat_cv.knots = NULL;
  me->valid_snap = FALSE;

  return OM_S_SUCCESS;
}

/**@*********** wakeup() **************************************************

 ABSTRACT:
	Wakeup routine

 SYNOPSIS:
	IGRlong wakeup( pos )

	(I)	IGRint pos;
			Don't know the use of it

 RETURN:
	OM_S_SUCCESS

 NOTES:
	This is a method

 **************************************************************************/

method wakeup( IGRint pos )
{
  IGRlong sts;

  GRstatus_display_button(1);

  sts = om$send( msg = message ECfit.wakeup( pos ),
		 mode = OM_e_wrt_message,
		 targetid = my_id );

  if ( me->form_displayed )
  {
    sts = FIf_display( me->stat_form );
    if ( sts )
      return OM_E_ABORT;
  }

  ss$enter();

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
  if ( me->stat_cv.knots )
    om$dealloc( ptr = me->stat_cv.knots );
  me->cv_info.num_stat_elem = 0;

  if ( me->stat_form )
    FIf_delete( me->stat_form );

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
    if ( me->pts_or_pol == BY_POINTS )
      *dyn_func = IDdyn_cvbypts;
    else
    {
      if ( me->number_of_events_input == 1 )
	*dyn_func = IDdyn_projptln;
      else
	*dyn_func = IDdyn_curbypol;
    }
    *addnl_info = ( IGRchar * ) &me->cv_info;
  }

  return OM_S_SUCCESS;
}

/**@*********** sleep() ***************************************************

 ABSTRACT:
	Sleep routine

 SYNOPSIS:
	IGRlong sleep( pos )

	(I)	IGRint pos;
			Don't know the use of it

 RETURN:
	OM_S_SUCCESS

 NOTES:
	This is a method

 **************************************************************************/

method super_cmd.sleep( IGRint pos )
{
  IGRlong sts;

  sts = om$send( msg = message ECfit.sleep( pos ),
		 mode = OM_e_wrt_message,
		 targetid = my_id );

  if ( me->form_displayed )
    FIf_erase( me->stat_form );

  ss$exit();
  
  return OM_S_SUCCESS;
}

/**@*********** status_disp() *********************************************

 ABSTRACT:
	Display the status form

 SYNOPSIS:
	IGRlong status_disp()

 RETURN:
	OM_S_SUCCESS

 NOTES:
	This is a method

 **************************************************************************/

method status_disp()
{
  IGRlong sts;
  
  if ( !me->form_displayed )
  {
    sts = FIf_display( me->stat_form );
    if ( sts )
      return OM_E_ABORT;
    me->form_displayed = TRUE;
  }

  return OM_S_SUCCESS;
}

/**@*********** do_form() *************************************************

 ABSTRACT:
	Process form input data

 SYNOPSIS:
	IGRlong do_form( IGRlong *msg;
	                 IGRint form_label;
			 IGRint gadget_label;
			 IGRdouble value )

	(O)	IGRlong *msg
			Status of the method execution
	(I)	IGRint form_label
			Form label of the status form
	(I)	IGRint gadget_label
			Gadget label
	(I)	IGRdouble value
			Gadget input value

 RETURN:
	OM_S_SUCCESS

 NOTES:
	This is a method

 **************************************************************************/

method do_form( IGRlong *msg; IGRint form_label;
	        IGRint gadget_label; IGRdouble value )
{
  IGRdouble gd_val;
  IGRlong sts;
  
  if ( form_label == STAT_FORM )
  {
    switch ( gadget_label )
    {
    case SAVE_CHANGE:
      FIg_reset( me->stat_form, SAVE_CHANGE );
      FIf_erase( me->stat_form );
      me->form_displayed = FALSE;
      sts = om$send( msg = message IDdrawcv.output_command_string(),
		     targetid = my_id );
      break;
    case NO_CHANGE:
      FIg_reset( me->stat_form, NO_CHANGE );
      FIf_erase( me->stat_form );
      me->form_displayed = FALSE;
      break;
    case BY_POINTS:
      FIg_set_state( me->stat_form, BY_POINTS, 1 );
      me->pts_or_pol = BY_POINTS;
      FIg_set_state( me->stat_form, BY_POLES, 0 );
      break;
    case BY_POLES:
      FIg_set_state( me->stat_form, BY_POLES, 1 );
      me->pts_or_pol = BY_POLES;
      FIg_set_state( me->stat_form, BY_POINTS, 0 );
      break;
    case UNIFM_CV:
      FIg_set_state( me->stat_form, UNIFM_CV, 1 );
      me->cv_type = UNIFM_CV;
      FIg_set_state( me->stat_form, NONUNIFM_CV, 0 );
      break;
    case NONUNIFM_CV:
      FIg_set_state( me->stat_form, NONUNIFM_CV, 1 );
      me->cv_type = NONUNIFM_CV;
      FIg_set_state( me->stat_form, UNIFM_CV, 0 );
      break;
    case TAN_CONSTR:
      FIg_get_value( me->stat_form, TAN_CONSTR, &gd_val );
      me->tan_cnstr = ( IGRboolean ) gd_val;
      if ( me->tan_cnstr == TRUE )
      {
	if ( me->number_of_events_input )
	{
	  if ( me->valid_snap == FALSE )
	  {
	    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_NoTanVec );
	    FIg_set_state( me->stat_form, TAN_CONSTR, 0 );
	    me->cv_info.dyn_cv.have_tan = FALSE;
	  }
	  else
	    me->cv_info.dyn_cv.have_tan = TRUE;
	}
	else
	  me->cv_info.dyn_cv.have_tan = FALSE;
      }
      else
	me->cv_info.dyn_cv.have_tan = FALSE;
      break;
    default:
      break;
    }
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
  ex$message( field = MESSAGE_FIELD, msgnumb = IDFFC_M_DrawCv );
  /*
  if ( me->pts_or_pol == BY_POINTS )
  {
    if ( me->cv_type == UNIFM_CV )
    {
      if ( me->tan_cnstr == TRUE )
      {
	ex$message( field = MESSAGE_FIELD, msgnumb = IDFFC_M_UCvByTanPts );
      }
      else
      {
	ex$message( field = MESSAGE_FIELD, msgnumb = IDFFC_M_UCvByPts );
      }
    }
    else
    {
      if ( me->tan_cnstr == TRUE )
      {
	ex$message( field = MESSAGE_FIELD, msgnumb = IDFFC_M_CvByTanPts );
      }
      else
      {
	ex$message( field = MESSAGE_FIELD, msgnumb = IDFFC_M_CvByPts );
      }
    }
  }
  else
  {
    if ( me->cv_type == UNIFM_CV )
    {
      ex$message( field = MESSAGE_FIELD, msgnumb = IDFFC_M_UCvByPol );
    }
    else
    {
      ex$message( field = MESSAGE_FIELD, msgnumb = IDFFC_M_CurByPol );
    }
  }
  */
  ss$activate();
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
  IGRlong sts, msg;

  /* initialize */
  me->msg = MSSUCC;

  /* determine if the user can move on yet */
  key = 0;
  num_points = me->number_of_events_input;
  if ( num_points > 0 )
  {
    FIg_disable( me->stat_form, BY_POINTS );
    FIg_disable( me->stat_form, BY_POLES );
  }
  else
  {
    FIg_enable( me->stat_form, BY_POINTS );
    FIg_enable( me->stat_form, BY_POLES );
  }

  if ( num_points == 1 && me->events[0].subtype == GRst_KEYPOINT )
  {
    me->cv_info.dyn_cv.have_tan = FALSE;
    me->valid_snap = FALSE;
    if ( me->events[0].num_id > 0 )
    {
      struct GRlc_info *loc_info;
      struct GRmd_env *md_env;
      struct GRid *id;
      OMuword classid;
      struct IGRbsp_curve *cv;
      IGRpoint tan_vec[2];
      extern IGRlong EMgetvggeom();
	
      /* get that snapped object */
      loc_info = &me->events[0].located_object[0];
      md_env = &loc_info->module_info;
      id = &loc_info->located_obj;
	
      /* promote class if necessary */
      sts = om$get_classid( osnum = id->osnum,
			    objid = id->objid,
			    p_classid = &classid );
      if ( om$is_ancestry_valid( subclassid = classid,
				 superclassname = "GRbspline" ) == OM_S_SUCCESS )
      {
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

	/* -------------------------------------------------------
	 * Add following fix for TR#119304444.
	 * Before 3.0, when user snaps a point, its class is not
	 * under GRbspline. Now in 3.0, Place Point command places
	 * a profile point which is a subclass of GRbspline.
	 * -------------------------------------------------------
	 */
	if ( cv->num_poles > 2 )
	{
	  me->cv_info.dyn_cv.have_tan = me->tan_cnstr;
	  me->valid_snap = TRUE;

	  /* get the tangent vector at the snapping point */
	  BScvarrevt( cv, &loc_info->geom_parms.u, 1, 1.0, &tan_vec, &msg );

	  me->cv_info.dyn_cv.tan[0] = tan_vec[1][0] - tan_vec[0][0];
	  me->cv_info.dyn_cv.tan[1] = tan_vec[1][1] - tan_vec[0][1];
	  me->cv_info.dyn_cv.tan[2] = tan_vec[1][2] - tan_vec[0][2];
        }
	/* -------------------------------------------------------
	 * Add following fix for TR#119304444.
	 * Before 3.0, when user snaps a point, its class is not
	 * under GRbspline. Now in 3.0, Place Point command places
	 * a profile point which is a subclass of GRbspline.
	 *
	 * A profile point in EMS has two poles with identical
	 * coordinates.
	 * -------------------------------------------------------
	 */
	else if ( cv->num_poles == 2 )
	{
	  IGRdouble tolr, dist;
	    
	  BSxtractpar( &msg, BSTOLLENVEC, &tolr );
	  dist = BSdistptpt( &msg, cv->poles, cv->poles + 3 );

	  if ( dist > tolr )
	  {
	    me->cv_info.dyn_cv.have_tan = me->tan_cnstr;
	    me->valid_snap = TRUE;

	    /* get the tangent vector at the snapping point */
	    BScvarrevt( cv, &loc_info->geom_parms.u, 1, 1.0, &tan_vec, &msg );

	    me->cv_info.dyn_cv.tan[0] = tan_vec[1][0] - tan_vec[0][0];
	    me->cv_info.dyn_cv.tan[1] = tan_vec[1][1] - tan_vec[0][1];
	    me->cv_info.dyn_cv.tan[2] = tan_vec[1][2] - tan_vec[0][2];
	  }
	  else
	  {
	    if ( me->tan_cnstr == TRUE )
	    {
	      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_NoTanVec );
	    }
	    me->cv_info.dyn_cv.have_tan = FALSE;
	  }
        }
	else
	{
	  if ( me->tan_cnstr == TRUE )
	  {
	    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_NoTanVec );
	  }
	  me->cv_info.dyn_cv.have_tan = FALSE;
        }

	/* free memory */
	om$dealloc( ptr = cv );
      }
      else
      {
	if ( me->tan_cnstr == TRUE )
	{
	  ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_NoTanVec );
        }
	me->cv_info.dyn_cv.have_tan = FALSE;
      }
    }
    else
    {
      /*
      if ( me->tan_cnstr == TRUE )
      {
        ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_NoTanVec );
	me->msg = MSFAIL;
	goto quit;
      }
      */
      if ( me->tan_cnstr == TRUE )
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_NoTanVec );
      }
      me->cv_info.dyn_cv.have_tan = FALSE;
    }
  }
    
  if ( me->pts_or_pol == BY_POINTS )
  {
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
  }
  else if ( me->pts_or_pol == BY_POLES )
  {
    if (( num_points >= me->u_order && me->u_periodic == FALSE ) ||
	(( num_points >= ( me->u_order - 1 )) && me->u_periodic == TRUE ))
    {
      key = EMS_P_00083;
      *event_mask |= GRm_RJT_MOVEON;
    }
    else
      key = EMS_P_00082;
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
  IGRpoint fstpt, sndpt, proj_pt;

  /* initialize */
  me->msg = MSSUCC;
  *was_valid_event = TRUE;

  /* project point if there is tangent constraint for curve by poles */
  if ( me->pts_or_pol == BY_POLES &&
       me->cv_info.dyn_cv.have_tan == TRUE &&
       me->number_of_events_input == 2 )
  {
    memcpy( (char *)fstpt, (char *)&me->events[0].event.button.x, 
        sizeof( IGRpoint ));
    memcpy((char *) sndpt, (char *)&me->events[1].event.button.x, 
        sizeof( IGRpoint ));
    IDproj_pt_onto_line( fstpt, me->cv_info.dyn_cv.tan, sndpt, proj_pt );
    memcpy( (char *)&me->events[1].event.button.x, (char *)proj_pt, 
        sizeof( IGRpoint ));
  }
    
  /* check the type of event input */
  event = &me->events[me->number_of_events_input - 1];
  if ( event->response == EX_RJT_MOVEON )
    *done = TRUE;

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
  struct DPele_header cv_hd;
  IGRboolean disp_cv = FALSE;
  IGRint sts, i;
  IGRdouble delta;
  IGRlong msg;

  /* assign which command */
  if ( me->pts_or_pol == BY_POINTS )
  {
    BSxtractpar( &msg, BSTOLLENVEC, &me->cv_info.dyn_cv.lenvec_tol );
    if ( me->cv_type == UNIFM_CV )
      me->cv_info.dyn_cv.mytype = CV_POINTS_UNIFM;
    else
      me->cv_info.dyn_cv.mytype = CV_POINTS_NONUNIFM;
  }
  else
  {
    me->bspcv = NULL;
    if ( me->cv_type == UNIFM_CV )
      me->cv_info.dyn_cv.mytype = CV_POLES_UNIFM;
    else
      me->cv_info.dyn_cv.mytype = CV_POLES_NONUNIFM;
  }

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

  if ( me->pts_or_pol == BY_POINTS )
  {
    /* check whether curve is available */
    if (( me->cv_info.dyn_cv.num_points > 1 ) &&
	(( me->cv_info.dyn_cv.num_points + 2 ) >= me->u_order ||
	 ( me->u_periodic == TRUE &&
	 ( me->cv_info.dyn_cv.num_points + 1 ) >= ( me->u_order - 1 ))))
    {	/* curve is available */
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
  }
  else
  {
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
      if ( me->cv_info.dyn_cv.mytype == CV_POLES_UNIFM &&
	   me->cv_info.dyn_cv.cv_periodic == FALSE )
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
  }

  /* activate smart sketch */
  ss$activate();
  
  /* perform dynamics */
  UI_status( " " );
  if ( me->pts_or_pol == BY_POINTS )
    sts = dp$dynamics( dyn_fun = IDdyn_cvbypts,
		       information = &me->cv_info );
  else
  {
    if ( me->cv_info.dyn_cv.have_tan == TRUE &&
	 me->cv_info.dyn_cv.num_points == 1 )
      sts = dp$dynamics( dyn_fun = IDdyn_projptln,
			 information = &me->cv_info );
    else
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
      me->bspcv = NULL;
    }
  }

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
  IGRlong msg, sts, number_of_points, i;
  IGRint mytype;
  IGRdouble *points, span, gd_val;
  struct IGRbsp_curve *bspcv;
  struct GRvg_construct *my_construct_list;
  struct IGResbs *surface_specific;
  struct IGResbc curve_specific;

  my_construct_list = &me->construct_list;
  me->msg = MSSUCC;
  sts = OM_S_SUCCESS;
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

  /* assign which command */
  if ( me->pts_or_pol == BY_POINTS )
  {
    if ( me->cv_type == UNIFM_CV )
      mytype = CV_POINTS_UNIFM;
    else
      mytype = CV_POINTS_NONUNIFM;
  }
  else
  {
    if ( me->cv_type == UNIFM_CV )
      mytype = CV_POLES_UNIFM;
    else
      mytype = CV_POLES_NONUNIFM;
  }

  switch ( mytype )
  {
  case CV_POINTS_NONUNIFM:
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
    break;
  case CV_POINTS_UNIFM:
    sts = fit_unifm_cv( number_of_points, points, me->u_order, me->u_periodic,
		        ( me->cv_info.dyn_cv.have_tan == TRUE ? me->cv_info.dyn_cv.tan : NULL ), &bspcv );
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
    break;
  case CV_POLES_NONUNIFM:
    sts = om$construct( classid = OPP_GRbcsubbc_class_id,
		        msg = message GRsubbc.EMcurve_by_poles( me->u_order,
							        me->u_periodic,
							        number_of_points,
							        ( IGRpoint * ) points,
							        NULL,
							        my_construct_list ),
		        p_objid = &me->constructed_object,
		        osnum = me->construct_env.md_id.osnum );
    break;
  case CV_POLES_UNIFM:
    bspcv = ( struct IGRbsp_curve * ) om$malloc( size = sizeof( struct IGRbsp_curve ));
    
    /* initialize curve struct */
    bspcv->order = me->u_order;
    bspcv->periodic = me->u_periodic;
    bspcv->non_uniform = FALSE;
    bspcv->num_poles = number_of_points;
    bspcv->poles = ( IGRdouble * ) points;
    bspcv->rational = FALSE;
    bspcv->weights = NULL;
    bspcv->num_boundaries = 0;
    bspcv->bdrys = NULL;

    if ( bspcv->periodic == TRUE )
    {
      IGRlong total_num_poles;
      IGRpoint *total_poles;

      total_num_poles = bspcv->num_poles + bspcv->order;
      total_poles = ( IGRpoint * ) om$malloc( size = total_num_poles * sizeof( IGRpoint ));
      if ( total_poles == NULL )
      {
	me->msg = MSFAIL;
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	goto quit;
      }
      MAbcupexpand( &me->msg, &bspcv->order, &bspcv->rational,
	    &bspcv->num_poles, (IGRpoint *) bspcv->poles, 
            bspcv->weights,
	    &total_num_poles, total_poles, NULL );
      bspcv->num_poles = total_num_poles;
      bspcv->poles = ( IGRdouble * ) total_poles;
    }

    /* determine knots */
    bspcv->num_knots = bspcv->order + bspcv->num_poles;
    bspcv->knots = ( IGRdouble * ) om$malloc( size = bspcv->num_knots * sizeof( IGRdouble ));
    if ( bspcv->knots == NULL )
    {
      me->msg = MSFAIL;
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
      goto quit;
    }

    if ( bspcv->periodic == TRUE )
    {
      /* uniform and periodic */
      if ( bspcv->num_poles == bspcv->order )
	for ( i = 0; i < 2 * bspcv->num_poles; i++ )
	  bspcv->knots[i] = -( bspcv->order - 1 ) + i;
      else
      {
	span = 1.0 / (( IGRdouble ) ( bspcv->num_poles - bspcv->order + 1 ));
	bspcv->knots[bspcv->order - 1] = 0.0;
	for ( i = 0; i < bspcv->num_poles; i++ )
	  bspcv->knots[bspcv->order + i] = bspcv->knots[bspcv->order - 1 + i] + span;
	for ( i = bspcv->order - 1; i > 0; i-- )
	  bspcv->knots[i - 1] = bspcv->knots[i] - span;
      }
    }
    else
    {
      for ( i = 0; i < bspcv->order; i++ )
      {
	bspcv->knots[i] = 0;
	bspcv->knots[bspcv->num_poles + i] = 1.0;
      }
      span = ( IGRdouble ) ( bspcv->num_poles - bspcv->order + 1 );
      for ( i = 0; i < ( bspcv->num_poles - bspcv->order ); i++ )
	bspcv->knots[bspcv->order + i] = ( IGRdouble ) ( i + 1 ) / span;
    }

    /* assign geometry to construction list */
    my_construct_list->geometry = ( IGRchar * ) bspcv;

    sts = om$construct( classid = OPP_GRbcsubbc_class_id,
		        msg = message GRvg.GRconstruct( my_construct_list ),
		        p_objid = &me->constructed_object,
		        osnum = me->construct_env.md_id.osnum );

    /* free memory */
    if ( bspcv->periodic == TRUE && bspcv->poles )
      om$dealloc( ptr = bspcv->poles );
    if ( bspcv->knots )
      om$dealloc( ptr = bspcv->knots );
    om$dealloc( ptr = bspcv );
    break;
  }

  if ( !( 1 & sts ))
  {
      me->msg = MSFAIL;
  }
  else
  {
      IGRboolean         assoc_flag;
      IGRlong            msg;

      /* Convert to profile element if the associate flag is ON.
	 If it is not successful, we still want the non-converted
	 curve to be there. So we don't need to check the return code */

      gr$get_associative_flag( buffer = &assoc_flag );
      if(assoc_flag)
      {
	  struct GRid curve_id;
	  curve_id.objid = me->constructed_object;
	  curve_id.osnum = me->construct_env.md_id.osnum;
	  sk$convert_to_profile (msg = &msg, 
				 options = SK_CONVERT_VERBOSE,
				 module = &me->construct_env,
				 geometry = curve_id,
				 automask = SK_AUTO_GEOMETRIC);
      }

  }

 quit:
  my_construct_list->class_attr = ( IGRchar * ) surface_specific;
  if ( points )
    om$dealloc( ptr = points );

  /* enable the status form */
  FIg_enable( me->stat_form, BY_POINTS );
  FIg_enable( me->stat_form, BY_POLES );
  me->form_displayed = FALSE;
  me->valid_snap = FALSE;
  me->cv_info.dyn_cv.have_tan = FALSE;
  FIg_get_value( me->stat_form, TAN_CONSTR, &gd_val );
  me->tan_cnstr = ( IGRboolean ) gd_val;

  if ( 1 & me->msg )
    return OM_S_SUCCESS;
  else
  {
    me->constructed_object = NULL_OBJID;
    return OM_E_ABORT;
  }
}

end implementation IDdrawcv;
