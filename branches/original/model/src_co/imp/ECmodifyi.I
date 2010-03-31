/* ###################   APOGEE COMPILED   ################## */
class implementation ECmodify;

%safe
#include <math.h>
%endsafe

#include "EMS.h"

/*
 Description

 This method performs the element modification.  It assumes
 that one object is being modified and that it was located
 in the first event.

 History

 12/29/87 : rlw : Creation date
 08/09/88 : rlw : Modified not to erase and redisplay for delete boundary
                  as the method will do this.
 11/03/93 : dhm : Added errors checks for 'Insert Pole' mytype == 78
 */

#include "ems_m_inc.h"			/* Includes everything */
#include "EC_I.h"			/* Informational messages */
#include "EMSdpb.h"			/* DPB include file */
#include "bserr.h"			/* Needed by bsparameters.h */
#include "bsparameters.h"		/* BSEXTRACTPAR() stuff */

from GRgraphics import GRdisplay;

method perform_duty()
{
 enum		GRdpmode DisplayMode;
 IGRboolean	clear_status_field;
 IGRlong	sts, *my_msg;
 struct		GRmdenv_info *mdenv_info;
 struct		GRlc_info *loc_info;
 struct		GRid *id;
/*
 * Compiler optimizations
 */
 my_msg = &me->msg;
/*
 * Initialize
 */
 me->have_a_constructed_object = FALSE;
 loc_info = &me->events[0].located_object[0];
 id = &loc_info->located_obj;
 mdenv_info = &loc_info->module_info.md_env;
 clear_status_field = FALSE;
/*
 * Erase the object
 */
 if (me->mytype != 86)
  {
   DisplayMode = GRbe;
   sts = om$send(
     msg = message GRgraphics.GRdisplay(
      my_msg,
      &mdenv_info->matrix_type,
      mdenv_info->matrix,
      &DisplayMode, 
      &me->display_env.md_id),
     targetid = id->objid,
     targetos = id->osnum);
    if (! (1 & sts))
     {
      *my_msg = MSFAIL;
      return(OM_E_ABORT);
     }
  } /* if (me->mytype != 86) */
/*
 * Modify the object
 */
 sts = om$send(
   msg = message ECmodify.perform_modification(),
   targetid = my_id);
/*
 * If an error occured then inform the user
 * that the modification failed
 */
 if (sts == OM_I_INVANCESTRY)  /* returned from 'Insert Pole' mytype = 78 */
 {
     sts = OM_S_SUCCESS;
     ex$message(msgnumb = EMS_I_InvEleLoc);
 }
 else if (me->msg == MSINARG)  /* returned from 'Insert Pole' mytype = 78 */
 {
     *my_msg = MSSUCC;
     ex$message(msgnumb = EMS_I_InvPole);
 }
 else if (! (1 & sts) )
 {
     ex$message(msgnumb = EMS_I_00029)	/* Modification failed */
 }
 else
 {
     /*
      * Display the modified object
      */

     ex$message(				/* Processing . */
                msgnumb = EMS_I_00004,
                type = "%s",
                var = " . ")
     clear_status_field = TRUE;
 }
/*
 * Draw the object
 */
 if (me->mytype != 86)
  {
   DisplayMode = GRbd;
   sts = om$send(
     msg = message GRgraphics.GRdisplay(
      my_msg,
      &mdenv_info->matrix_type,
      mdenv_info->matrix,
      &DisplayMode, 
      &me->display_env.md_id),
     targetid = me->constructed_object,
     targetos = id->osnum);
    if (! (1 & sts))
     {
      *my_msg = MSFAIL;
      return(OM_E_ABORT);
     }
  } /* if (me->mytype != 86) */
/*
 * Clear the status field
 */
if (clear_status_field)
 ex$message(msgnumb = EMS_I_00000)	/* Clear field */
/*
 * eof
 */
 me->msg = MSSUCC;
 return(OM_S_SUCCESS);
}

/*
 Description

  This is the wakeup method for modify commands.
  It merely loads the active parameters from the
  dpb into the command objects instance data and
  displays them to the user.

 History

  12/29/87 : rlw : The beginning
  08/05/88 : rlw : Modified to output fit tolerance for data reduction
  02/28/89 : rlw : Modified to add conditional compilation statements
                   for the I/DRAW product.
 */

method wakeup(int pos)
{
 IGRuchar buffer;
 IGRlong	loc_msg, sts;
/*
 * Do what my parent does
 */
 sts = om$send(
   mode = OM_e_wrt_message,
   msg = message ECconstruct.wakeup(pos),
   targetid = my_id);
  ERROR_ABORT
/*
 * Display active parameters based on the
 * command which is active.
 */
 switch (me->mytype)
  {
#ifndef IDRAW
/*
 * These command display the active orders.
 */
   case 71:	/* Change curve order */
   case 72:	/* Change surface order */
   case 73:	/* Increase curve order */
   case 74:	/* Increase surface order */
/*
 * If I have no events then load
 * the active properties.  
 */
    if (! me->number_of_events_input)
     {
      sts = EMdpb_get(
        &loc_msg,
        EMSdpb_u_order,
        &buffer);
       if (! (1 & sts))
        {
         me->msg = MSFAIL;
         return(OM_E_ABORT);
        }
      me->u_order = buffer;
      sts = EMdpb_get(
        &loc_msg,
        EMSdpb_v_order,
        &buffer);
       if (! (1 & sts))
        {
         me->msg = MSFAIL;
         return(OM_E_ABORT);
        }
      me->v_order = buffer;
     }
/*
 * Display the active parameters
 */
    ex$message(
     msgnumb = EMS_I_00028,
     type = "%2d%2d",
     var = `me->u_order, me->v_order`);
    break;
/*
 * Get the active fit tolerance (cht)
 */
   case 107:	/* Reduce curve data */
   case 114:	/* Reduce surface data */
    {
     IGRchar	status_string[80];
     IGRboolean	status;
     extern	IGRlong EFconvert_to_user_units();
     IGRdouble	tolerance;

     status = BSEXTRACTPAR(
      &loc_msg,
      BSTOLCHRDHT,
      tolerance);
     status_string[0] = '\0';
     sts = EFconvert_to_user_units(
       tolerance,
       TRUE,
       status_string,
       &loc_msg);
      if (! (1 & sts))
       {
        me->msg = MSFAIL;
        return(OM_E_ABORT);
       }
     ex$message(
      msgnumb = EMS_I_00025,
      type = "%s",
      var = `status_string`);
    }
    break;
#endif
/*
 * Default is to do nothing
 */
   default:
    break;
  } /* switch (me->mytype) */
/*
 * eof
 */
 return(OM_S_SUCCESS);
}

end implementation ECmodify;
