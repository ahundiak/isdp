/* ###################   APOGEE COMPILED   ################## */

class implementation EMSdpb;


/*
  File History:  (for method histories see below)

   06/14/93 : scw : Removed references to the X11 directory for include files.
   08/13/94 : scw : Intel Solaris port
*/


#include "EMS.h"

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

%safe
#include <math.h>
%endsafe

#define FORM_LABEL 0   /* Definitions of gadgets */
#define U_ORDER 40
#define V_ORDER 32
#define U_RULES 30
#define V_RULES 27
#define U_PERIODIC 31
#define V_PERIODIC 33
#define POLYGON_DISPLAY 34
#define CONSIDER_BOUNDARIES 37
#define BASTOL 29
#define CONVERT_TO_WINDOW 5
#define CHT 43
#define ARCTOL 38
#define OFFTOL 41
#define SAVE 1
#include "ems_m_inc.h"			/* Includes everything */
#include "griomacros.h"
#include "exmacros.h"                   /* For ex$put_queue */
#include "exdef.h"                      /* For EX_FORM_FINISHED */
#include "emsdef.h"                     /* For MAXFLOAT */
#include "EMSerrordef.h"                /* EMSerror defintions */
#include "EMSdpb.h"                     /* EMSdpb declarations */
#include "igewinmacros.h"               /* For ige$SR_active */
#define DEBUG 0
#if DEBUG
#include <stdio.h>
#endif

static IGRboolean EFget_tol();

method EMupdate_form(IGRlong *EMmsg)

/* *********************************************************************

Description
  This method updates the values of the form with the currently active values
  stored in the dpb object. The tolerances (basis, offtol, cht and arctol)
  are obtained from IGE dpb object by calling appropriate macros

Arguments
  Input
   form_GRid : struct GRid of the form object

  Output
   EMmsg : Completion code. 

Notes
  Upon exit the completion code will be one of the following:
  EMS_S_Success : if all is success
  EMS_E_Fail : if there is some failure
  
History
  01/26/90      : PP  : Initialised FI_data_st values to prevent
                        some unusual behaviour related to certain
                        fields not getting displayed.
  06/13/88      : PP  : Removed locate edges from the form
  04/29/88      : PP  : design date
   ********************************************************************* */
{

 IGRdouble bastol, offtol, arctol, cht;
 IGRlong status;
 char alpha[132];
 extern IGRlong EFconvert_to_user_units();

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 if (!EFget_tol (&bastol, &offtol, &cht, &arctol)) return (OM_E_ABORT);;

 FIfld_set_value(me->form1, U_ORDER, 0, 0, (double) me->u_order);
 FIfld_set_value(me->form1, V_ORDER, 0, 0, (double) me->v_order);
 FIfld_set_value(me->form1, U_RULES, 0, 0, (double) me->u_rules);
 FIfld_set_value(me->form1, V_RULES, 0, 0, (double) me->v_rules);

 if (me->props & EMDPB_U_PERIODIC)
   FIg_set_state_on (me->form1, U_PERIODIC);
 else
   FIg_set_state_off (me->form1, U_PERIODIC);

  if (me->props & EMDPB_V_PERIODIC)
   FIg_set_state_on (me->form1, V_PERIODIC);
 else
   FIg_set_state_off (me->form1, V_PERIODIC);

  if (me->props & EMDPB_IGNORE_BOUNDARIES)
   FIg_set_state_off (me->form1, CONSIDER_BOUNDARIES);
 else
   FIg_set_state_on (me->form1, CONSIDER_BOUNDARIES);

 if (me->props & EMDPB_POLYGON_DISPLAY_ON)
   FIg_set_state_on (me->form1, POLYGON_DISPLAY);
 else
   FIg_set_state_off (me->form1, POLYGON_DISPLAY);

 FIg_set_state_off (me->form1, SAVE);

 alpha[0] = '\0';
 status = EFconvert_to_user_units(
    bastol, 
    TRUE,
    alpha,
    EMmsg);
 if (!(1&status&*EMmsg)) goto wrapup;
 FIg_set_text(me->form1, BASTOL, alpha);

 alpha[0] = '\0';
 status = EFconvert_to_user_units(
    arctol, 
    TRUE,
    alpha,
    EMmsg);
 if (!(1&status&*EMmsg)) goto wrapup;
 FIg_set_text(me->form1, ARCTOL, alpha);

 alpha[0] = '\0';
 status = EFconvert_to_user_units(
    cht,    
    TRUE,
    alpha,
    EMmsg);
 if (!(1&status&*EMmsg)) goto wrapup;
 FIg_set_text(me->form1, CHT, alpha);

 alpha[0] = '\0';
 status = EFconvert_to_user_units(
    offtol, 
    TRUE,
    alpha,
    EMmsg);
 if (!(1&status&*EMmsg)) goto wrapup;
 FIg_set_text(me->form1, OFFTOL, alpha);

wrapup:
 if (!(1&*EMmsg)) return (OM_E_ABORT);
 return (status);
}

IGRint EMSdpb_process_form (form_label, gadget_label, value, form_ptr)
int form_label, gadget_label;
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

  stat_OM = om$send (msg = message EMSdpb.do_form (&msg_loc, form_label,
                     gadget_label, value),
             senderid = NULL_OBJID, targetid = cmdobj, targetos = cmdos);
  if(! (stat_OM & 1))
   return (OM_E_ABORT);
return (stat_OM);
}

method is_displayed (IGRlong *msg; IGRint *displayed)
{
  int ret, temp;

   *msg = EMS_S_Success;
   ret = FIf_is_displayed(me->form1, &temp);
   if (ret)
     return (OM_E_ABORT);
   *displayed = temp;
  return (OM_S_SUCCESS);
}

method disp_form (IGRlong *msg)
{
   int ret;

  *msg = EMS_S_Success;
  ret = FIf_display (me->form1);
  if (ret)
   return (OM_E_ABORT);
  return (OM_S_SUCCESS);
}

method erase_form (IGRlong *msg)
{
int ret;

  *msg = EMS_S_Success;
  ret = FIf_erase (me->form1);
  if (ret)
   return (OM_E_ABORT);
  return (OM_S_SUCCESS);
}


method do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
               IGRdouble value)
{
/* **********************
   Description
     The DPB object gets a form input message whenever some gadget is poked
     at in the form. This method then tries to decipher the input and 
     appropriately modify the instance data of the dpb object.
     
     The arguments and the name of the message are the same as the one
     defined at super_cmd. Hence whenever the arguments at super_cmd change
     we need to change too.

  ********************** */
      
 IGRlong status;
 IGRint EMdpb_put ();
 IGRlong EMmsg;
 IGRboolean update_form = FALSE;
 IGRint double_size;
 IGRdouble temptol, tempchar;
 IGRint loworder,highorder,lowrules,highrules, state;
 IGRdouble bastol, offtol, arctol, cht;
 int sel_flag, r_pos;
 char alpha[132];


 loworder = 2;
 highorder = 16;
 lowrules = 0;
 highrules = 255;
 double_size = sizeof (IGRdouble);

 status = OM_S_SUCCESS;

if (!EFget_tol (&bastol, &offtol, &cht, &arctol)) return (OM_E_ABORT);;

 switch (gadget_label)
 {
  case U_ORDER:
  {
   FIfld_get_value (me->form1, U_ORDER, 0, 0, &tempchar, &sel_flag, &r_pos);
   if ((tempchar >= loworder) && tempchar <= highorder)
     me->u_order = tempchar;
   else
     update_form = TRUE;
  }
  break;

  case V_ORDER:
  {
   FIfld_get_value (me->form1, V_ORDER, 0, 0, &tempchar, &sel_flag, &r_pos);
   if ((tempchar >= loworder) && tempchar <= highorder)
    me->v_order = tempchar;
   else update_form = TRUE;
  }
  break;

  case U_RULES:
  {
   FIfld_get_value (me->form1, U_RULES, 0, 0, &tempchar, &sel_flag, &r_pos);
   if ((tempchar >= lowrules) && (tempchar <= highrules))
    me->u_rules = tempchar;
   else update_form = TRUE;
  }
  break;

  case V_RULES:
  {
   FIfld_get_value (me->form1, V_RULES, 0, 0, &tempchar, &sel_flag, &r_pos);
   if ((tempchar >= lowrules) && (tempchar <= highrules))
    me->v_rules = tempchar;
   else update_form = TRUE;
  }
  break;

  case CONSIDER_BOUNDARIES:
   FIg_get_state(me->form1, CONSIDER_BOUNDARIES, &state);
   if (state)
     me->props &= ~EMDPB_IGNORE_BOUNDARIES;
   else
     me->props |= EMDPB_IGNORE_BOUNDARIES;
  break;

  case CONVERT_TO_WINDOW:
  {
   IGRlong num_byte;
   IGRint resp;
   struct GRevent dumevent;

   FIg_erase(me->form1, CONVERT_TO_WINDOW);
/*
 * A dummy event is put onto the queue to let the command object break
 * from an infinite loop. This only happens when there is a save restore
 * form.
 */

   num_byte = sizeof(struct GRevent);
   resp = EX_FORM_FINISHED;

#if DEBUG
 fprintf (stderr, "num_byte %d \n", num_byte);
#endif

   status = ex$putque (msg = &EMmsg, response = &resp, byte = &num_byte,
                       buffer = dumevent.event.keyin);
   if (!(1&status&EMmsg)) return (OM_E_ABORT);
   break;
  }

  case U_PERIODIC:
   FIg_get_state(me->form1, U_PERIODIC, &state);
   if (state)
    me->props |= EMDPB_U_PERIODIC;
   else
    me->props &= ~EMDPB_U_PERIODIC;
  break;

  case V_PERIODIC:
   FIg_get_state(me->form1, V_PERIODIC, &state);
   if (state)
    me->props |= EMDPB_V_PERIODIC;
   else
    me->props &= ~EMDPB_V_PERIODIC;
  break;

/*
 * If the inputted arc length tolerance, off set tolerance, 
 * or chord height tolerance is less than the basis tolerance then 
 * the user is informed that this is not possible ,and the relevant tolerance is
 * automatically increased such that the same is at least three orders
 * of magnitude greater than the basis tolerance.
 */

  case ARCTOL :
    update_form = TRUE;
    FIfld_get_text(me->form1, ARCTOL, 0, 0, 132, alpha, &sel_flag, &r_pos);
    status = co$expreval(
         msg = &EMmsg,
         scale_flag = GRIO_NO_SCALE, /* Scaling on ACS not supported for tol */ 
         expression = alpha,
         unit_type = "UOM_DISTANCE",
         result = &temptol);
    if (!(1&EMmsg&status))
     break;

    if (temptol > bastol)
    {
     status = gr$put_arclength_tolerance(msg = &EMmsg, sizbuf = &double_size,
              buffer = &temptol);
     if (!(1&status)) return(OM_E_ABORT);
    }
  break;

  case BASTOL :
    update_form = TRUE;
    FIfld_get_text(me->form1, BASTOL, 0, 0, 132, alpha, &sel_flag, &r_pos);
    status = co$expreval(
         msg = &EMmsg,
         scale_flag = GRIO_NO_SCALE, /* Scaling on ACS not supported for tol */ 
         expression = alpha,
         unit_type = "UOM_DISTANCE",
         result = &temptol);
    if (!(1&EMmsg&status))
     break;

    if ((temptol < arctol) && (temptol < offtol) &&
        (temptol < cht))
    {
     status = gr$put_basis_tolerance (msg = &EMmsg, sizbuf = &double_size,
              buffer = &temptol);
     if (!(1&status)) return(OM_E_ABORT);
    }
  
  break;

  case OFFTOL:
    update_form = TRUE;
    FIfld_get_text(me->form1, OFFTOL, 0, 0, 132, alpha, &sel_flag, &r_pos);
    status = co$expreval(
         msg = &EMmsg,
         scale_flag = GRIO_NO_SCALE, /* Scaling on ACS not supported for tol */ 
         expression = alpha,
         unit_type = "UOM_DISTANCE",
         result = &temptol);
    if (!(1&EMmsg&status))
     break;

    if (temptol > bastol)
    {
     status = gr$put_offset_tolerance(msg = &EMmsg, sizbuf = &double_size,
              buffer = &temptol);
     if (!(1&status)) return(OM_E_ABORT);
    }
  break;
  
  case CHT :
    update_form = TRUE;
    FIfld_get_text(me->form1, CHT, 0, 0, 132, alpha, &sel_flag, &r_pos);
    status = co$expreval(
         msg = &EMmsg,
         scale_flag = GRIO_NO_SCALE, /* Scaling on ACS not supported for tol */ 
         expression = alpha,
         unit_type = "UOM_DISTANCE",
         result = &temptol);
    if (!(1&EMmsg&status))
     break;
    if (temptol > bastol)
    {
     status = gr$put_chord_height_tolerance (msg = &EMmsg, 
              sizbuf = &double_size,
              buffer = &temptol);
     if (!(1&status)) return(OM_E_ABORT);
    }
  break;

  case POLYGON_DISPLAY:
    FIg_get_state (me->form1, POLYGON_DISPLAY, &state);
    if (state)
    me->props |= EMDPB_POLYGON_DISPLAY_ON;
   else
    me->props &= ~EMDPB_POLYGON_DISPLAY_ON;
  break;

  case SAVE:
  {
   IGRboolean save_restore_was_active;
/*
 * A dummy event is put onto the queue to let the command object break
 * from an infinite loop. This only happens when there is a save restore
 * form. If we do this all the time then the command object which was put
 * to sleep suddenly has to deal with spurious input. Again, if the form
 * was not save restore to begin with we would not have gone into an infinite
 * loop. The ideal solution would be for the form to put a form_finished
 * onto the queue.  
 */

   save_restore_was_active = ige$SR_active();

   FIf_erase(me->form1);

  if (save_restore_was_active)
  {

   IGRlong num_byte;
   IGRint  resp;
   struct GRevent dumevent;

#if DEBUG
   fprintf (stderr, "Save restore form is active \n");
#endif

   resp = EX_FORM_FINISHED;
   num_byte = sizeof (struct GRevent);

#if DEBUG
 fprintf (stderr, "num_byte %d \n", num_byte);
#endif

/*
   button = &dumevent.event.button;
   button->x = MAXFLOAT;
   button->y = MAXFLOAT;
   button->z = MAXFLOAT;
*/

   status = ex$putque (msg = &EMmsg, response = &resp, byte = &num_byte,
                       buffer = dumevent.event.keyin);
   if (!(1&status&EMmsg)) return (OM_E_ABORT);
  }
 }
  break;

  default:
  break;
 } /* end switch */

 if (update_form)
 {
  status = om$send (msg = message EMSdpb.EMupdate_form(&EMmsg),
                    targetid = my_id);
  if (!(1&status&EMmsg)) return (OM_E_ABORT);
 }

 return (status);
}

EFconvert (EMmsg, invalue, outvalue,option)
/*
 * This function does the necessary units conversion for the tolerances
 */

 IGRlong *EMmsg;
 IGRdouble invalue;
 IGRdouble *outvalue;
 IGRushort option;
{
 IGRlong status;
 IGRdouble factor;
 OM_S_OBJID modid;
 OMuword mod_os;

 *EMmsg= EMS_S_Success;

 status = ex$get_cur_mod (id = &modid, osnum = &mod_os);
 if (!(1&status)) 
 {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
 }

 status = co$cvt_imp_to_wrk (msg = EMmsg, unit_type = "UOM_DISTANCE",
                             osnum = mod_os,
                               primary = 1.0, result = &factor);
 if (!(1&status&*EMmsg)) 
 {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
 }

if (option == 0)
 *outvalue = invalue / factor;
else
 *outvalue = invalue * factor;

wrapup:
 return(status);  /* modified to return "status" - Ashok */
 }

static IGRboolean EFget_tol (bastol, offtol, cht, arctol)
IGRdouble *bastol, *offtol, *cht, *arctol;
{
 IGRlong status, EMmsg;
 IGRdouble dbuff;
 IGRint nret, double_size;

 double_size = sizeof(IGRdouble);

   status = gr$get_arclength_tolerance (msg = &EMmsg, sizbuf = 
                &double_size,
                buffer = &dbuff, nret = &nret);
   if (!(1&status))
       return (FALSE);
   *arctol = dbuff;

   status = gr$get_basis_tolerance (msg = &EMmsg, sizbuf = &double_size,
            buffer = &dbuff, nret = &nret);
   if (!(1&status)) return (FALSE);
   *bastol = dbuff;

   status = gr$get_offset_tolerance (msg = &EMmsg, sizbuf = &double_size,
             buffer = &dbuff, nret = &nret);
   if (!(1&status)) return (FALSE);
   *offtol = dbuff;

   status = gr$get_chord_height_tolerance (msg = &EMmsg, 
            sizbuf = &double_size,
            buffer = &dbuff, nret = &nret);
   if (!(1&status)) return (FALSE);
   *cht = dbuff;

   return (TRUE);
 }

end implementation EMSdpb;
