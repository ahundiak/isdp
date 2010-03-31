/*
 * HISTORY
 * 
 * Rajiv Agrawal : 07/01/92 : Message system compliance
 * Kumar N       : 01.26.93 : Reaction to shamrock - WINDOWS NT
 * scw           : 08/13/94 : Added X11 for Intel Solaris port
 * scw           : 08/15/94 : Clarified sleep method
 */

class implementation ECdtmfc;

#include <stdio.h>                      /* Needed for print statements */

#if defined( NT )
#if 0  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif

#ifdef X11
#  include "X11/Xlib.h"
#  include "X11/Xutil.h"
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
#include "griodef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "igrdef.h"                     /* Has IGRPY */
#include "griodef.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "lcmacros.h"

#include "exmacros.h"                   /* Has ex$putque */
#include "maerr.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "godef.h"
#include "dpdef.h"
#include "EMSdatumdef.h"
#include "EMSdpb.h"
#include "EMSasopts.h"
#include "EMdtmacros.h" /* For ems$get_..*/
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "REdatpln.h"
#include "msmacros.h"
#include "ECmsg.h"

# ifndef DEBUG
# define DEBUG 0  /*Set to 1 if want error strings printed.*/
# endif

#define IDENTIFY_PLANAR_ELEMENT 1
#define IDENTIFY_EDGE_ELEMENT 2
#define LOCATE_WINDOW 3
#define PROCESS 4

/* Gadget labels on the form */

#define SAVE 1
#define CONVERT_TO_WINDOW 5
#define BOTTOM 13
#define TOP 14
#define LEFT 15
#define RIGHT 16
#define PARALLEL_PLANE 0

#define MAX_NUM_WIN 32
from GRgraphics   import GRdisplay;
from EMSdatpln import EMget_pln_info;
from EMSdatplnmgr import EMget_info, EMactivate;

extern OMuword OPP_GRbspline_class_id,
               OPP_EMSsubbs_class_id,
               OPP_GRvg_class_id,
               OPP_GR3dlineseg_class_id,
               OPP_GRcurve_class_id;


method super_cmd.sleep(int pos)
{
  IGRlong sts = OM_S_SUCCESS;
  IGRlong msg = MSSUCC;

  if (me->is_associative)
    GRdisplay_associative_button(FALSE);
 
  sts = dp$erase_hilite(msg = &msg);
  if (!(1&sts&msg)) 
    return (OM_E_ABORT);

  if (me->form_displayed)
    FIf_erase(ME.ECdtmfc->form);

  sts = om$send (msg = message ECdtmfc.sleep(pos),
                 mode = OM_e_wrt_parent,
                 targetid = my_id);

 return(sts);
}

method wakeup (int pos)
{
 IGRlong sts = OM_S_SUCCESS;
 IGRlong msg = MSSUCC,i;
 enum GRdpmode display_mode; 
 
 sts = om$send (msg = message ECdtmfc.wakeup(pos),
                mode = OM_e_wrt_parent,
                targetid = my_id);

 {
   IGRuchar props;

   EMdpb_get(&msg, EMSdpb_props, &props);
   gr$get_associative_flag( buffer = &me->is_associative ); 
   if (me->is_associative)
    GRdisplay_associative_button(TRUE);
 }

 if (me->form_displayed)
   FIf_display(ME.ECdtmfc->form);

 for (i=0;i<me->num_hilited;i++)
 {
   display_mode = GRhd;

   sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                      &me->md_env.md_env.matrix_type,
                      me->md_env.md_env.matrix,
                      &display_mode,
                      &me->md_env.md_id),
                   targetid = me->elems[i+1].located_obj.objid,
                   targetos = me->elems[i+1].located_obj.osnum);
   if (!(1&sts&msg))  return (OM_E_ABORT);
 }

 return(sts);
}


method init(int type; char *str_ptr)
{

  int	 i, status = OM_S_SUCCESS;
  IGRint ret;
  IGRint EFrefpln_process_form();

  status = om$send (msg = message ECdtmfc.init(type,str_ptr),
                    mode = OM_e_wrt_parent,
                    targetid = my_id);
  if (!(1&status)) return (OM_E_ABORT);

  for (i=0;i<5;i++)
    ME.ECdtmfc->elems[i].located_obj.objid = NULL_OBJID;

  me->num_hilited = 0;
  me->options = EMS_BOTTOM_ELEMENT;
  me->form = NULL;

  /*
   * Create - but do not display the form
   */
  ret = FIf_new( 1, 
		 "EMSrfplnOp", 
		 EFrefpln_process_form, 
                &ME.ECdtmfc->form);
  if (ret) return (OM_E_ABORT);
  ret = FIf_set_cmd_oid_os (ME.ECdtmfc->form, my_id, OM_Gw_current_OS);

  return (status);
}

method status_disp()
{
  IGRlong status;
  IGRlong EMmsg;
  IGRint ret;

  status = OM_S_SUCCESS;
  EMmsg = 1;

  /*
   * The status display form can be displayed in any state now. 9/30/92 Shelley
   */
  if (me->form_displayed)
    return (OM_S_SUCCESS);

  ret = FIf_display(ME.ECdtmfc->form);
  if (ret)
    return(OM_E_ABORT);

  me->form_displayed = TRUE;

  return (status);
}


/* we override delete to get rid of the status form */
method delete (int f_defer_flag)
{
   int sts;

   if (!(FIf_is_valid(ME.ECdtmfc->form))){
             FIf_delete(ME.ECdtmfc->form);
                     ME.ECdtmfc->form = 0;
       }

   sts = om$send ( msg = message ECelement.delete(f_defer_flag),
                   mode = OM_e_wrt_message,
                   targetid = my_id);

   return (OM_S_SUCCESS);
}

IGRint EFrefpln_process_form (form_label, gadget_label, value, form_ptr)
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
  
  stat_OM = om$send (msg = message ECdtmfc.do_form (&msg_loc, form_label,
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
  long response = EX_FORM_FINISHED;
  long msg;


  status = OM_S_SUCCESS;
  EMmsg = 1;

  switch (gadget_label)
  {

    case BOTTOM:
    {
      me->options = EMS_BOTTOM_ELEMENT;
      ex$putque( msg = &msg, response = (int *) &response );
      break;
    }
 
    case TOP:
    {
      me->options = EMS_TOP_ELEMENT;
      ex$putque( msg = &msg, response = (int *) &response );
      break;
    }
 
    case LEFT:
    {
      me->options = EMS_LEFT_ELEMENT;
      ex$putque( msg = &msg, response = (int *) &response );
      break;
    }
 
    case RIGHT:
    {
      me->options = EMS_RIGHT_ELEMENT;
      ex$putque( msg = &msg, response = (int *) &response );
      break;
    }
 
    case SAVE:
    {
#ifdef NT
   IGRlong num_byte;
   IGRint  resp;
   struct GRevent dumevent;
#endif

      ret = FIf_erase(ME.ECdtmfc->form);
#ifdef NT
   resp = EX_FORM_FINISHED;
   num_byte = sizeof (struct GRevent);

   status = ex$putque (msg = &EMmsg, response = &resp, byte = &num_byte,
                       buffer = dumevent.event.keyin);
   if (!(1&status&EMmsg)) return (OM_E_ABORT);
#endif
      me->form_displayed = FALSE;
      break;
    }
  }

  return (status);
}

method is_status_form_valid(IGRint *valid)
{
  *valid = TRUE;
  return (OM_S_SUCCESS);
}
end implementation ECdtmfc;

