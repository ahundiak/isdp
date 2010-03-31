/* ###################   APOGEE COMPILED   ################## */
class implementation ECmvpls;

/*
 * This file contains the implementation for the form which interacts with the
 * the move pole command object.
 */

/*
History

   Rustagi   05/25/92    Modified for message sub-system compliance.
   Kumar N   01.25.93    Reaction to shamrock for WINDOWS-NT
   scw       06/14/93    Removed references to the X11 directory for 
                         include files.
   scw       08/13/94    Added X11 for Intel Solaris port

*/

#include "EMS.h"
#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"
#include "comisc.h"
#include <stdio.h>

#if defined( NT )
#if 0  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif

#ifdef X11
#  include <X11/Xlib.h>
#  include <X11/Xutil.h>
#endif

#if defined(__STDC__) || defined(__cplusplus)
#if 0  /* because opp can not handle it */
#  if defined( X11 )
#    include <XFIproto_pub.h>
#  elif defined( ENV5 )
#    include <FIproto_pub.h>
#  elif defined( NT )
#    include <shampub.h>
#  endif
#else
#  include <FI.h>
#endif
#endif

#define FORM1  1


#define CONVERT_TO_WINDOW 5

method status_disp()
{
 IGRlong status;
 IGRlong EMmsg;
 int ret;
 IGRint ECmvpls_process_form();

 status = OM_S_SUCCESS;
 EMmsg = 1;

/*
 * The status display form can only be displayed in these states.
 */
 if ((ME.super_cmd->state >= 3) && (ME.super_cmd->state <=6))
 {
 if(! ME.ECmvpls->form1 )
 {
   ret = FIf_new(FORM1, "EMSmvSfPls", ECmvpls_process_form, 
                         &ME.ECmvpls->form1);
   if (ret){
     return (OM_E_ABORT);
   }
 }

   ret = FIf_set_cmd_oid_os (ME.ECmvpls->form1, my_id, OM_Gw_current_OS);

   /* position the form on the right edge of the screen */
   GRposition_form(ME.ECmvpls->form1, RIGHT_EDGE);

   FIg_set_state_on (ME.ECmvpls->form1, INDIVIDUALLY);
   FIg_set_state_on (ME.ECmvpls->form1, VECTOR);
   FIg_set_state_on (ME.ECmvpls->form1, EQUALLY);

  if (me->magnitude_gadgets_displayed)
  {
   FIg_erase(ME.ECmvpls->form1, MAGNITUDE);
   FIg_erase(ME.ECmvpls->form1, DIRECTLY);
   FIg_erase(ME.ECmvpls->form1, INVERSELY);
   FIg_erase(ME.ECmvpls->form1, EQUALLY);
   FIg_erase(ME.ECmvpls->form1, MAG_BORDER);

   me->magnitude_gadgets_displayed = FALSE;
  }

  ret = FIf_display(ME.ECmvpls->form1);
  if (ret){
    return(OM_E_ABORT);
  }
  me->form_displayed = TRUE;
 }
 else
  ex$message(msgnumb = EMS_S_RestComactStFm);

 if (!(1&status&EMmsg))
 {
 #if DEBUG
   fprintf (stderr,"Error in status displaying a form");
 #else
   return (OM_E_ABORT);
 #endif
 }
 return (status);
}

IGRint ECmvpls_process_form (form_label, gadget_label, value, form_ptr)
IGRint form_label, gadget_label;
IGRdouble value;
Form  form_ptr;
{
 IGRint stat_func, stat_OM;
  IGRlong msg_loc;
  GRobjid cmdobj;
  GRspacenum cmdos;

  stat_OM = OM_S_SUCCESS;

  stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
  if (stat_func)
    return (OM_E_ABORT);
  
  stat_OM = om$send (msg = message ECmvpls.do_form (&msg_loc, form_label,
                     gadget_label, value),
             senderid = NULL_OBJID, targetid = cmdobj, targetos = cmdos);
  if(! (stat_OM & 1))
   return (OM_E_ABORT);
  return (OM_S_SUCCESS);
}

method do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
               IGRdouble value)
{
 IGRlong status,EMmsg;
 int ret;

 status = OM_S_SUCCESS;
 EMmsg = 1;

 if(form_label == 1) {
   switch (gadget_label)
   {
    case RANGE:

   ret = FIg_set_state_on (ME.ECmvpls->form1, RANGE);
   me->pole_selection = RANGE;

  FIg_set_state_off(ME.ECmvpls->form1, INDIVIDUALLY);
  FIg_set_state_off(ME.ECmvpls->form1, ROW);
  break;

  case INDIVIDUALLY:

   ret = FIg_set_state_on (ME.ECmvpls->form1, INDIVIDUALLY);
   me->pole_selection = INDIVIDUALLY;

  FIg_set_state_off(ME.ECmvpls->form1, RANGE);
  FIg_set_state_off(ME.ECmvpls->form1, ROW);

  break;

  case ROW:
   ret = FIg_set_state_on (ME.ECmvpls->form1, ROW);
   me->pole_selection = ROW;

  FIg_set_state_off(ME.ECmvpls->form1, INDIVIDUALLY);
  FIg_set_state_off(ME.ECmvpls->form1, RANGE);
  break;

  case VECTOR:

   ret = FIg_set_state_on (ME.ECmvpls->form1, VECTOR);
   me->direction = VECTOR;
  FIg_set_state_off(ME.ECmvpls->form1, NORMAL_TO_ELEMENT);

  if (me->magnitude_gadgets_displayed)
  {
   FIg_erase (ME.ECmvpls->form1, MAGNITUDE);
   FIg_erase (ME.ECmvpls->form1, DIRECTLY);
   FIg_erase (ME.ECmvpls->form1, INVERSELY);
   FIg_erase (ME.ECmvpls->form1, EQUALLY);
   FIg_erase (ME.ECmvpls->form1, MAG_BORDER);
   me->magnitude_gadgets_displayed = FALSE;
  }

  break;

  case NORMAL_TO_ELEMENT:
   me->direction = NORMAL_TO_ELEMENT;
  FIg_set_state_off(ME.ECmvpls->form1, VECTOR);

  if (!me->magnitude_gadgets_displayed)
  {
   FIg_display(ME.ECmvpls->form1, MAGNITUDE);
   FIg_display(ME.ECmvpls->form1, DIRECTLY);
   FIg_display(ME.ECmvpls->form1, INVERSELY);
   FIg_display(ME.ECmvpls->form1, EQUALLY);
   FIg_display(ME.ECmvpls->form1, MAG_BORDER);

   me->magnitude_gadgets_displayed = TRUE;;
  }
  break;

  case DIRECTLY:

   me->mag = DIRECTLY;
   ret = FIg_set_state_on (ME.ECmvpls->form1, DIRECTLY);
  FIg_set_state_off(ME.ECmvpls->form1, INVERSELY);
  FIg_set_state_off(ME.ECmvpls->form1, EQUALLY);

  break;

  case INVERSELY:
   me->mag = INVERSELY;
   ret = FIg_set_state_on (ME.ECmvpls->form1, INVERSELY);
  FIg_set_state_off(ME.ECmvpls->form1, DIRECTLY);
  FIg_set_state_off(ME.ECmvpls->form1, EQUALLY);
  break;

  case EQUALLY:
   me->mag = EQUALLY;
   ret = FIg_set_state_on (ME.ECmvpls->form1, EQUALLY);
  FIg_set_state_off(ME.ECmvpls->form1, DIRECTLY);
  FIg_set_state_off(ME.ECmvpls->form1, INVERSELY);
  break;

  case SAVE:
#ifdef NT
   IGRlong num_byte;
   IGRint  resp;
   struct GRevent dumevent;
#endif

   FIg_set_state_off(ME.ECmvpls->form1, SAVE);
   ret = FIf_erase(ME.ECmvpls->form1);
#ifdef NT
   resp = EX_FORM_FINISHED;
   num_byte = sizeof (struct GRevent);

   status = ex$putque (msg = &EMmsg, response = &resp, byte = &num_byte,
                       buffer = dumevent.event.keyin);
   if (!(1&status&EMmsg)) return (OM_E_ABORT);
#endif
   me->form_displayed = FALSE;
  break;

  case CONVERT_TO_WINDOW:
  {
#ifdef NT
   IGRlong num_byte;
   IGRint  resp;
   struct GRevent dumevent;
#endif
   FIg_erase(ME.ECmvpls->form1, CONVERT_TO_WINDOW);
#ifdef NT
   resp = EX_FORM_FINISHED;
   num_byte = sizeof (struct GRevent);

   status = ex$putque (msg = &EMmsg, response = &resp, byte = &num_byte,
                       buffer = dumevent.event.keyin);
   if (!(1&status&EMmsg)) return (OM_E_ABORT);
#endif
  }
  break;
 }
 }
 return (status);
}

end implementation ECmvpls;

