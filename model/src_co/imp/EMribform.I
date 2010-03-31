class implementation ECrib;

/* 
Histroy:
 Rustagi  ???? Creation
*/

#if DEBUG
#include <stdio.h>
#endif

#ifndef OMmacros_include
#include "OMmacros.h"
#endif

#ifndef igrtypedef_include
#include "igrtypedef.h"
#endif

#ifndef igrdef_include
#include "igrdef.h"
#endif

#ifndef igrdp_include
#include "igrdp.h"
#endif

#ifndef igewinmacros_include
#include "igewinmacros.h"
#endif

#ifndef exmacros_include
#include "exmacros.h"
#endif

#ifndef exdef_include
#include "exdef.h"
#endif

#ifndef griomacros_include
#include "griomacros.h"
#endif

#include "comisc.h"
#include "EC_M.h"
#include "EC_E.h"

#define ENTER_THICKNESS 1

/* define the gadget label for form */
#define FORM1       1 

#define SYMMETRIC  11
#define ONE_SIDED  12
#define TO_NEXT 14
#define FINITE 15
#define EXTEND_CURVE_TOG 21

#define SAVE     		1
#define CONVERT_TO_WINDOW	5

#ifndef DEBUG
#define DEBUG 0  /* Set to 1 if want error strings printed. */
#endif

#if DEBUG
#define ERROR(sts_stupid, error_number, error_message)\
{ \
   if(! (1 & sts_stupid & error_number)) \
   { \
      printf("\n%s\n", error_message); \
      goto ret_end; \
   } \
}
#else
#define ERROR(sts_stupid, error_number, error_message)\
{ \
   if(! (1 & sts_stupid & error_number))  goto ret_end; \
}
#endif

/* This method handles all the input that the gadget(s) of form received */

method do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
        IGRdouble value)
{
 IGRlong  	sts, event_size;
 int 		ret;

 sts = OM_S_SUCCESS;
 event_size = sizeof(struct GRevent);

 if(form_label == 1) 
 {
 switch(gadget_label)
  {
   case SYMMETRIC:
     me->symmetric = TRUE; 
     FIg_set_state_on(ME.ECrib->form1, SYMMETRIC);
     FIg_set_state_off(ME.ECrib->form1, ONE_SIDED);
     break;
   case ONE_SIDED:
     me->symmetric = FALSE;
     FIg_set_state_off(ME.ECrib->form1, SYMMETRIC);
     FIg_set_state_on(ME.ECrib->form1, ONE_SIDED);
     break;
   case EXTEND_CURVE_TOG:
     me->extend_curve = !me->extend_curve;
     break;
   case FINITE:
     me->is_finite = TRUE;
     FIg_set_state_on(ME.ECrib->form1, FINITE);
     FIg_set_state_off(ME.ECrib->form1, TO_NEXT);
     break;
   case TO_NEXT:
     me->is_finite = FALSE;
     FIg_set_state_on(ME.ECrib->form1, TO_NEXT);
     FIg_set_state_off(ME.ECrib->form1, FINITE);
     break; 
   case SAVE:
     FIg_set_state_off(ME.ECrib->form1, SAVE);
     ret = FIf_erase(ME.ECrib->form1);
     me->form_displayed = FALSE;
     break;
   case CONVERT_TO_WINDOW:
     FIg_erase(ME.ECrib->form1, CONVERT_TO_WINDOW);
     break;
   default:
    return (OM_E_ABORT);
   } 
 }
 return(sts);
}


IGRint ECrib_process_form(form_label, gadget_label, value, form_ptr)
IGRint form_label, gadget_label;
IGRdouble value;
Form  form_ptr;
{
IGRint 		stat_func, stat_OM;
IGRlong 	msg_loc;
GRobjid 	cmdobj;
GRspacenum 	cmdos;

 stat_OM = OM_S_SUCCESS;

 stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
 if(stat_func)
  return (OM_E_ABORT);
 stat_OM = om$send (msg = message ECrib.do_form (&msg_loc, form_label,
                gadget_label, value),
            senderid = NULL_OBJID, 
            targetid = cmdobj,
            targetos = cmdos);
 if(! (stat_OM & 1)) return (OM_E_ABORT);
 return(OM_S_SUCCESS);
}

/* This method sets up the instance data needed by the form_input method */

method status_disp()
{
IGRlong  	msg_loc, sts;
IGRint 		ret;
IGRint 		ECrib_process_form();

 sts = msg_loc = OM_S_SUCCESS;

 /* Invoke the form after the command being invoked */
  if(ME.super_cmd->state == ENTER_THICKNESS && !me->form_displayed)
   {
   if(!ME.ECrib->form1)
    {
     ret = FIf_new(FORM1, "MDRib", ECrib_process_form, &ME.ECrib->form1);
      if(ret) return (OM_E_ABORT);
    if(me->symmetric == TRUE)
     FIg_set_state_on(ME.ECrib->form1, SYMMETRIC);
    else
     FIg_set_state_on(ME.ECrib->form1, ONE_SIDED);
    if(me->is_finite == TRUE)
     FIg_set_state_on(ME.ECrib->form1, FINITE);
    else
     FIg_set_state_on(ME.ECrib->form1, TO_NEXT);
   }
  ret = FIf_set_cmd_oid_os(ME.ECrib->form1, my_id, OM_Gw_current_OS);
   if(ret) return (OM_E_ABORT);
  ret = FIf_display (ME.ECrib->form1);
   if(ret) return (OM_E_ABORT);
  me->form_displayed = TRUE;
 }
return(sts);
} /* status_disp */

end implementation ECrib;
