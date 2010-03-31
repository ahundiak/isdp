/**@***********************************************************************

 FILE:
 	IDchgordi.I

 ROUTINES:
	wakeup()
	output_command_string()
	next_event_processing()
	verify_event()
	perform_modification()

 **************************************************************************/

class implementation IDchgord;

/*
Abstract
	This command changes curve or surface order. However, user
	needs not change the default u_order and/or v_order parameter(s)
	in order to change the order(s) of the located curve or surface.

History
	04/02/92	JSY	Design and coding.
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

#define LITTLE_CURVE 1
#define LITTLE_SURFACE 2

from GRsubbc import EMmodify_order;
from EMSgenbs import EMmodify_order;

/**@*********** wakeup() **************************************************

 ABSTRACT:
	Wakeup routine

 SYNOPSIS:
	IGRlong wakeup( pos )

	(I)	IGRint pos;
			dummy argument

 RETURN:
	OM_S_SUCCESS

 NOTES:
	This is a method

 **************************************************************************/

method wakeup( IGRint pos )
{
  IGRuchar buffer;
  IGRlong sts, msg;
  extern IGRint EMdpb_get();

  /* do what my parent does */
  sts = om$send( mode = OM_e_wrt_message,
		 msg = message ECconstruct.wakeup( pos ),
		 targetid = my_id );

  /* copy from ECmodify's wakeup: If I have no events then load
     the active properties */
  if ( !( me->number_of_events_input ))
  {
    sts = EMdpb_get( &msg, EMSdpb_u_order, &buffer );
    if ( !( 1 & sts ))
    {
      me->msg = MSFAIL;
      return OM_E_ABORT;
    }
    me->u_order = buffer;
    sts = EMdpb_get( &msg, EMSdpb_v_order, &buffer );
    if ( !( 1 & sts ))
    {
      me->msg = MSFAIL;
      return OM_E_ABORT;
    }
    me->v_order = buffer;
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
    ex$message( field = MESSAGE_FIELD, msgnumb = IDFFC_M_ChgCvOrd );
  }
  else
  {
    ex$message( field = MESSAGE_FIELD, msgnumb = IDFFC_M_ChgSfOrd );
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
  IGRlong key;
  extern void EFget_locate_information();

  /* initialze */
  me->msg = MSSUCC;

  /* branch based on the command state */
  switch ( me->number_of_events_input )
  {
  case 0:	/* event 1 prompt */

    *locate_desired = TRUE;
    EFget_locate_information( ( me->mytype == 0 ? LITTLE_CURVE
			                        : LITTLE_SURFACE ),
			      loc_info );
    loc_info->operation_type = geometry_modification;
    loc_info->acc_key = ( me->mytype == 0 ? IDFF_P_AccptRejCrv
			                  : IDFF_P_AccptRejSurf );
    loc_info->accept_event_type = dummy;
    key = ( me->mytype == 0 ? EMS_P_00030 : EMS_P_00031 );

    /* build the prompt string */
    ex$message( msgnumb = key, buff = prompt_string );

    break;

  case 1:	/* event 2 prompt */
    /* assign key and display the active parameters */
    if ( me->mytype == 0 )
    {
      key = IDFF_P_ChgCvOrd;
      /*
      ex$message( field = ERROR_FIELD,
		  msgnumb = IDFF_M_ActCvOrd,
		  type = "%d",
		  var = `me->u_order` );
		  */
    }
    else
    {
      key = IDFF_P_ChgSfUOrd;
      /*
      ex$message( field = ERROR_FIELD,
		  msgnumb = IDFF_M_ActSfOrd,
		  type = "%d%2d",
		  var = `me->u_order, me->v_order` );
		  */
    }

    *event_mask |= GRm_DATA;
    *event_mask |= GRm_RJT_MOVEON;
    *type_of_value_needed = SCALAR;

    /* build the prompt string */
    ex$message( msgnumb = key,
	        type = "%d",
	        var = `me->u_order`,
	        buff = prompt_string );

    break;

  case 2:	/* event 3 prompt */
    /* this is only for Change Surface Order */
    key = IDFF_P_ChgSfVOrd;
    /*
    ex$message( field = ERROR_FIELD,
	        msgnumb = IDFF_M_ActSfOrd,
	        type = "%d%2d",
	        var = `me->u_order, me->v_order` );
		*/

    *event_mask |= GRm_DATA;
    *event_mask |= GRm_RJT_MOVEON;
    *type_of_value_needed = SCALAR;

    /* build the prompt string */
    ex$message( msgnumb = key,
	        type = "%d",
	        var = `me->v_order`,
	        buff = prompt_string );

    break;

  default:
    me->msg = MSFAIL;
    goto quit;
  }

 quit:
  if ( me->msg == MSFAIL )
    return FALSE;
  else
    return TRUE;
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
  IGRint new_u_order, new_v_order;

  /* initialize */
  me->msg = MSSUCC;
  *done = FALSE;
  *was_valid_event = TRUE;

  if ( me->number_of_events_input == 2 )
  {
    event = &me->events[1];
    if ( event->response == EX_DATA || event->response == EX_VALUE )
    {
      if ( event->response == EX_VALUE )
      {
	new_u_order = ( IGRint ) event->event.value;
	if ( new_u_order == 0 )
	  new_u_order = me->u_order;
      }
      else
	new_u_order = me->u_order;
      
      if ( new_u_order > MAX_ORDER || new_u_order < 2 )
      {
	me->msg = MSFAIL;
	if ( me->mytype == 0 )
	{
	  ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_InvCrvOrd );
	}
	else
	{
	  ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_InvSfOrd );
	}
	*was_valid_event = FALSE;
      }
      else
      {
	if ( me->mytype == 0 )
	  *done = TRUE;
      }
    }
    else
    {
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_IGRJTMOVEON );
      *was_valid_event = FALSE;
    }
  }

  if ( me->number_of_events_input == 3 )
  {
    event = &me->events[2];
    if ( event->response == EX_DATA || event->response == EX_VALUE )
    {
      if ( event->response == EX_VALUE )
      {
	new_v_order = ( IGRint ) event->event.value;
	if ( new_v_order == 0 )
	  new_v_order = me->v_order;
      }
      else
	new_v_order = me->v_order;
      
      if ( new_v_order > MAX_ORDER || new_v_order < 2 )
      {
	me->msg = MSFAIL;
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_InvSfOrd );
	*was_valid_event = FALSE;
      }
      else
	*done = TRUE;
    }
    else
    {
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_IGRJTMOVEON );
      *was_valid_event = FALSE;
    }
  }

  return OM_S_SUCCESS;
}

/**@*********** perform_modification() ************************************

 ABSTRACT:
	Perform modification to curve/surface

 SYNOPSIS:
	IGRlong perform_modification()

 RETURN:
	OM_S_SUCCESS:	success
	OM_E_ABORT:	failure

 NOTES:
	This is a method

 **************************************************************************/

method perform_modification()
{
  struct GRlc_info *loc_info;
  struct GRmd_env *md_env;
  struct GRid *id;
  struct GRevent *event;
  IGRint new_u_order, new_v_order;
  IGRlong sts, msg;
  extern IGRlong EMpromote_class(), EMget_the_geometry();

  me->msg = MSSUCC;
  loc_info = &me->events[0].located_object[0];
  md_env = &loc_info->module_info;
  id = &loc_info->located_obj;
  me->constructed_object = id->objid;
  new_u_order = new_v_order = 0;

  /* promote class if necessary */
  sts = EMpromote_class( ( me->mytype == 0 ? TRUE : FALSE ),
			 md_env, id, &me->msg );
  if ( !( 1 & sts ))
  {
    me->msg = MSFAIL;
    goto quit;
  }

  /* perform real modification */
  if ( me->mytype == 0 )
  {
    struct IGRbsp_curve *cv;

    event = &me->events[1];
    if ( event->response == EX_DATA || event->response == EX_VALUE )
    {
      if ( event->response == EX_VALUE )
      {
	new_u_order = ( IGRint ) event->event.value;
	if ( new_u_order == 0 )
	  new_u_order = me->u_order;
      }
      else
	new_u_order = me->u_order;

      if ( new_u_order > MAX_ORDER || new_u_order < 2 )
      {
	me->msg = MSFAIL;
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_InvCrvOrd );
	goto quit;
      }

      sts = EMget_the_geometry( loc_info, TRUE, FALSE, FALSE, my_id, &cv, &msg );
      if ( !( 1 & sts ))
      {
	if ( cv )
	  om$dealloc( ptr = cv );
	me->msg = MSFAIL;
	goto quit;
      }

      if ( cv->num_poles < new_u_order )
      {
	if ( cv )
	  om$dealloc( ptr = cv );
	me->msg = MSFAIL;
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_LESSPOL );
	goto quit;
      }

      sts = om$send( msg = message GRsubbc.EMmodify_order( FALSE,
							   loc_info,
							   new_u_order,
							   &msg ),
		     targetid = id->objid,
		     targetos = id->osnum );
      if ( !( 1 & sts ))
      {
	if ( cv )
	  om$dealloc( ptr = cv );
	me->msg = MSFAIL;
	goto quit;
      }
      if ( cv )
	om$dealloc( ptr = cv );
    }
    else
    {
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_IGRJTMOVEON );
    }
  }
  else
  {
    struct IGRbsp_surface *sf;

    event = &me->events[2];
    if ( event->response == EX_DATA || event->response == EX_VALUE )
    {
      if ( event->response == EX_VALUE )
      {
	new_v_order = ( IGRint ) event->event.value;
	if ( new_v_order == 0 )
	  new_v_order = me->v_order;
      }
      else
	new_v_order = me->v_order;

      event = &me->events[1];
      if ( event->response == EX_VALUE )
      {
	new_u_order = ( IGRint ) event->event.value;
	if ( new_u_order == 0 )
	  new_u_order = me->u_order;
      }
      else if ( event->response == EX_DATA )
	new_u_order = me->u_order;
      else
      {
	me->msg = MSFAIL;
	goto quit;
      }

      if ( new_u_order > MAX_ORDER || new_u_order < 2 ||
	   new_v_order > MAX_ORDER || new_v_order < 2 )
      {
	me->msg = MSFAIL;
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_InvSfOrd );
	goto quit;
      }

      sts = EMget_the_geometry( loc_info, FALSE, FALSE, FALSE, my_id, &sf, &msg );
      if ( !( 1 & sts ))
      {
	if ( sf )
	  om$dealloc( ptr = sf );
	me->msg = MSFAIL;
	goto quit;
      }

      if ( sf->u_num_poles < new_u_order ||
	   sf->v_num_poles < new_v_order )
      {
	if ( sf )
	  om$dealloc( ptr = sf );
	me->msg = MSFAIL;
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_LESSPOL );
	goto quit;
      }

      sts = om$send( msg = message EMSgenbs.EMmodify_order( FALSE,
							   loc_info,
							   new_u_order,
							   new_v_order,
							   &msg ),
		     targetid = id->objid,
		     targetos = id->osnum );
      if ( !( 1 & sts ))
      {
	if ( sf )
	  om$dealloc( ptr = sf );
	me->msg = MSFAIL;
	goto quit;
      }
      if ( sf )
	om$dealloc( ptr = sf );
    }
    else
    {
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_IGRJTMOVEON );
    }
  }

 quit:
  if ( 1 & me->msg )
    return OM_S_SUCCESS;
  else
    return OM_E_ABORT;
}

end implementation IDchgord;
