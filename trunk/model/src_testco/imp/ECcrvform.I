/* ###################   APOGEE COMPILED   ################## */
class implementation ECrdofcrv;

/*
  File History:  (for method histories see below)

   06/14/93 : scw : Removed references to the X11 directory for include files.
   08/13/94 : scw : Added X11 for Intel Solaris port
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

#define FORM1      1

method status_disp()
{
 IGRlong status;
 IGRlong EMmsg;
 IGRint   ret;
 IGRint  ECrdofcrv_process_form();

 status = OM_S_SUCCESS;
 EMmsg = 1;

 if (!me->form_initiated) {
     if (ME.super_cmd->mytype == CURVE){
       ret = FIf_new (FORM1, "GRcrvprop", ECrdofcrv_process_form, &me->form1);
       if (ret)
        return (OM_E_ABORT);
     }
#ifndef IDRAW
      else {
        ret = FIf_new (FORM1, "MDsrfprop", ECrdofcrv_process_form, &me->form1);
        if (ret)
          return (OM_E_ABORT);
      }
#endif
      ret = FIf_set_cmd_oid_os(me->form1, my_id, OM_Gw_current_OS);
      if (ret)
         return (OM_E_ABORT);
      me->form_initiated = TRUE;
 }

 if (! me->form_displayed) {
    ret = FIf_display (me->form1);
    if (ret)
      return (OM_E_ABORT);
    me->form_displayed = TRUE;
  }
 return (status);
}

IGRint ECrdofcrv_process_form (form_label, gadget_label, value, form_ptr)
IGRint form_label;
IGRint  gadget_label;
IGRdouble value;
Form    form_ptr;
{
  IGRint ret, stat_OM;
  IGRlong msg_loc;
  GRobjid cmdobj;
  GRspacenum cmdos;


  stat_OM = OM_S_SUCCESS;

  ret = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
  if (ret)
    return (OM_E_ABORT);
  stat_OM = om$send (msg = message ECrdofcrv.do_form (&msg_loc, form_label,
                     gadget_label, value),
             senderid = NULL_OBJID, targetid = cmdobj, targetos = cmdos);
  if (! (stat_OM & msg_loc & 1))
    return (OM_E_ABORT);
  return (stat_OM);
}

method do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
               IGRdouble value)
{
 IGRlong status,EMmsg;
 IGRint ret;

 status = OM_S_SUCCESS;
 EMmsg = 1;

 if (me->mytype == CURVE) {
     switch (gadget_label) {
         case RAD_OF_CRV:
            me->curvature_type = RAD_OF_CRV;
            ret = FIg_set_state_on(me->form1, RAD_OF_CRV);
            if (ret)
               return (OM_E_ABORT);
            ret = FIg_set_state_off(me->form1, CURVATURE);
            if (ret)
               return (OM_E_ABORT);
            break;
         case CURVATURE:
            me->curvature_type = CURVATURE;
            ret = FIg_set_state_on(me->form1, CURVATURE);
            if (ret)
               return (OM_E_ABORT);
            ret = FIg_set_state_off(me->form1, RAD_OF_CRV);
            if (ret)
               return (OM_E_ABORT);
            break;
         case SAVE:
#ifdef NT
IGRlong num_byte;
IGRint resp;
struct GRevent dumevent;
#endif

           ret = FIg_set_state_off(me->form1, SAVE);
           ret = FIf_erase (me->form1);
           if (ret)
             return (OM_E_ABORT);
#ifdef NT
        num_byte = sizeof(struct GRevent);
        resp     = EX_FORM_FINISHED;
status = ex$putqueue(msg = &EMmsg, response = &resp, byte = &num_byte,
                     buffer = dumevent, event.keyin);
     if (!(1&status&EMmsg)) return (OM_E_ABORT);
#endif
           me->form_displayed = FALSE;
           return (OM_S_SUCCESS);
         default:
           return (OM_E_ABORT);
         }
   }
   else if (me->mytype == SURFACE) {
      switch (gadget_label) {
        case RAD_OF_CRV:
           me->curvature_type = RAD_OF_CRV;
           ret = FIg_set_state_on(me->form1, RAD_OF_CRV);
           ret = FIg_set_state_off(me->form1, GAUSSIAN);
           ret = FIg_set_state_off(me->form1, MEAN);
           ret = FIg_set_state_off(me->form1, PRINCIPAL_MAX);
           ret = FIg_set_state_off(me->form1, PRINCIPAL_MIN);
           ret = FIg_set_state_off(me->form1, ABSOLUTE);
           break;
  
        case GAUSSIAN:
           me->curvature_type = GAUSSIAN;
           ret = FIg_set_state_on(me->form1, GAUSSIAN);
           ret = FIg_set_state_off(me->form1, RAD_OF_CRV);
           ret = FIg_set_state_off(me->form1, MEAN);
           ret = FIg_set_state_off(me->form1, PRINCIPAL_MAX);
           ret = FIg_set_state_off(me->form1, PRINCIPAL_MIN);
           ret = FIg_set_state_off(me->form1, ABSOLUTE);
           break;
        case MEAN:
           me->curvature_type = MEAN;
           ret = FIg_set_state_on(me->form1, MEAN);
           ret = FIg_set_state_off(me->form1, RAD_OF_CRV);
           ret = FIg_set_state_off(me->form1, GAUSSIAN);
           ret = FIg_set_state_off(me->form1, PRINCIPAL_MAX);
           ret = FIg_set_state_off(me->form1, PRINCIPAL_MIN);
           ret = FIg_set_state_off(me->form1, ABSOLUTE);
           break;
        case PRINCIPAL_MAX:
           me->curvature_type = PRINCIPAL_MAX;
           ret = FIg_set_state_on(me->form1, PRINCIPAL_MAX);
           ret = FIg_set_state_off(me->form1, RAD_OF_CRV);
           ret = FIg_set_state_off(me->form1, GAUSSIAN);
           ret = FIg_set_state_off(me->form1, MEAN);
           ret = FIg_set_state_off(me->form1, PRINCIPAL_MIN);
           ret = FIg_set_state_off(me->form1, ABSOLUTE);
           break;
        case PRINCIPAL_MIN:
           me->curvature_type = PRINCIPAL_MIN;
           ret = FIg_set_state_on(me->form1, PRINCIPAL_MIN);
           ret = FIg_set_state_off(me->form1, RAD_OF_CRV);
           ret = FIg_set_state_off(me->form1, GAUSSIAN);
           ret = FIg_set_state_off(me->form1, MEAN);
           ret = FIg_set_state_off(me->form1, PRINCIPAL_MAX);
           ret = FIg_set_state_off(me->form1, ABSOLUTE);
           break;
        case ABSOLUTE:
           me->curvature_type = ABSOLUTE;
           ret = FIg_set_state_on(me->form1, ABSOLUTE);
           ret = FIg_set_state_off(me->form1, RAD_OF_CRV);
           ret = FIg_set_state_off(me->form1, GAUSSIAN);
           ret = FIg_set_state_off(me->form1, MEAN);
           ret = FIg_set_state_off(me->form1, PRINCIPAL_MAX);
           ret = FIg_set_state_off(me->form1, PRINCIPAL_MIN);
           break;
        case SAVE:
#ifdef NT
IGRlong num_byte;
IGRint resp;
struct GRevent dumevent;
#endif
           ret = FIg_set_state_off(me->form1, SAVE);
           ret = FIf_erase (me->form1);
           if (ret)
             return (OM_E_ABORT);       
#ifdef NT
        num_byte = sizeof(struct GRevent);
        resp     = EX_FORM_FINISHED;
status = ex$putqueue(msg = &EMmsg, response = &resp, byte = &num_byte,
                     buffer = dumevent, event.keyin);
     if (!(1&status&EMmsg)) return (OM_E_ABORT);
#endif
           me->form_displayed = FALSE;
           return (OM_S_SUCCESS);
        default:
           return (OM_E_ABORT);
      }
   }
 return (status);
}

end implementation ECrdofcrv;

