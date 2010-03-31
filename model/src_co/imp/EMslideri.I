/* ###################   APOGEE COMPILED   ################## */
class implementation EMSslider;

/*
  File History:  (for method histories see below)

   06/14/93 : scw : Removed references to the X11 directory for include files.
   08/13/94 : scw : Added X11 for Intel Solaris port
*/

#include "EMS.h"
#include <stdio.h>

#if defined( NT )
#if 0  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "lcdef.h"
#include "lc.h"
#include "emserr.h"
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
#else
#  include <FI.h>
#endif
#include "comisc.h"

#define BOT_LEFT     18
#define BOT_RIGHT    19
#define TOP_LEFT     13
#define TOP_RIGHT    17
#define LEFT_SLIDER  12
#define RIGHT_SLIDER 14
#define CANCEL       4
#define SAVE         1

#define CURVE   1
#define SURFACE 0
#define FORM1   1

%safe
static Form form1=NULL;
%endsafe

from GRvg    import  GRpostabsg, GRgetsize, GRgetgeom;
from GRgraphics  import  GRdisplay, GRcopy, GRdelete;

/*
Abstract
    This init method constructs the form object and initializes its data.

Notes

History
97/13/91 pp         Made corrections to delete the c based form and 
                    removed the code to delete the OMbased form
18 March 1991  msm  Changed to c-based form.

25 May 1989 Rlw Fixed send of GRgraphics.GRdisplay.

22 May 1989 jBk Replaced GRgetevent invocation with co$getevent
                invocation.

    dhm    10/5/88    creation date.
    mrm    10/25/91   position the form on the right edge of the screen,
                      fix error checking to actually work

    Kumar N 01/19/93    port to NT.  

*/


method init(int type; char *str_ptr)
{
  int       ret;
  IGRint    EMSslider_process_form();

  ret = FIf_new (FORM1, "EMSblendshape", EMSslider_process_form, &form1);
  if (ret != FI_SUCCESS)
    return (OM_E_ABORT);

  /* position the form on the right edge of the screen */
  GRposition_form(form1, RIGHT_EDGE);

  ret = FIf_set_cmd_oid_os(form1, my_id, OM_Gw_current_OS);
  if (ret != FI_SUCCESS)
    return (OM_E_ABORT);

  return(OM_S_SUCCESS);
}


/*
Abstract
    This delete method deletes the form object and the class object,
    EMSslider.

Notes

History
    dhm    10/5/88    creation date.
*/

method delete(int f_defer_flag)
{
  IGRlong    status = OM_S_SUCCESS;

/*
  status = om$send(msg = message Root.delete(1),
                   targetid = me->form_id);
  EMomerr_hndlr(status, ret_end, "EMSslider.delete error\n");
*/
  if (form1)
  {
   FIf_delete(form1);
   form1 = NULL;
  }

  status = om$send(mode = OM_e_wrt_message,
                   msg = message Root.delete(1),
                   targetid = my_id);
  EMomerr_hndlr(status, ret_end, "EMSslider.delete error\n");


  ret_end:
    return(status);

}

IGRint EMSslider_process_form (form_label, gadget_label, value)
IGRint form_label;
IGRint  gadget_label;
IGRdouble value;
{
  IGRint stat_func, stat_OM;
  IGRlong msg_loc;
  GRobjid cmdobj;
  GRspacenum cmdos;


  stat_OM = msg_loc = OM_S_SUCCESS;

  stat_func = FIf_get_cmd_oid_os (form1, &cmdobj, &cmdos);
  EMerr_hndlr (stat_func != FI_SUCCESS, stat_OM, OM_E_ABORT, ret_end);

  stat_OM = om$send (msg = message EMSslider.do_form (&msg_loc, form_label,
                     gadget_label, value),
             senderid = NULL_OBJID, targetid = cmdobj, targetos = cmdos);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

ret_end:
  return (stat_OM);
}

/*
Abstract
    This method handles all the input that the form receives.
    If one of the sliders are changed then it copies the original
    object and calls the function to move the poles on that copied
    object and displays the copied object.  If a save is given then
    it puts a data event on the queue.  If a cancel is given then it
    puts a reject event on the queue.

Notes

History
    dhm    10/5/88    creation date.
    dhm    10/7/88    modified to handle both curves and surfaces.
    dhm    2/22/89    changed to allow the user to specify a range for the
                      sliders.
    msm    3/25/91    Changed to c_based form.
    Kumar N    1/19/93    ported to NT.
*/

method do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label; 
               IGRdouble value)
{
  IGRlong    msg_loc, status, size;

  IGRint     ivalue;
  IGRdouble  x, y, z, t, dvalue, val;
  extern IGRlong      EFsrf_move_poles();
  extern IGRlong      EFcrv_move_poles();
  IGRint     response;
  IGRboolean save_broadcast_flag;
  extern IGRboolean ASbroadcast_in_progress;
  enum GRdpmode       DisplayMode;
  struct GRevent      event;
  struct GRlc_info    copy_obj;


  copy_obj.located_obj.objid = NULL_OBJID;
 if (form_label == FORM1) {
   switch (gadget_label)
  {

    case BOT_LEFT:
    case BOT_RIGHT:
    {
      FIg_get_value (form1, gadget_label, &val);
      ivalue = val;
      if ( (ivalue < 0) || (ivalue > 100) || (ivalue == 
         ((gadget_label == BOT_LEFT) ? me->top_left : me->top_right)) )
      {
        if (gadget_label == BOT_LEFT)
        {
          dvalue = me->bot_left;
          FIg_set_value(form1, gadget_label, dvalue);
        }
        else
        {
          dvalue = me->bot_right;
          FIg_set_value(form1, gadget_label, dvalue);
        }

      }
      else if (gadget_label == BOT_LEFT)
        me->bot_left = ivalue;
      else
        me->bot_right = ivalue;

      break;
    }


    case TOP_LEFT:
    case TOP_RIGHT:
    {
      FIg_get_value (form1, gadget_label, &val);
      ivalue = val;
      if ( (ivalue < 0) || (ivalue > 100) || (ivalue == 
         ((gadget_label == TOP_LEFT) ? me->bot_left : me->bot_right)) )
      {
        if (gadget_label == TOP_LEFT)
        {
          dvalue = me->top_left;
          FIg_set_value (form1, gadget_label, dvalue);
        }
        else
        {
          dvalue = me->top_right;
          FIg_set_value (form1, gadget_label, dvalue);
        }
      }
      else if (gadget_label == TOP_LEFT)
        me->top_left = ivalue;
      else
        me->top_right = ivalue;

      break;
    }


    case LEFT_SLIDER:
    case RIGHT_SLIDER:
    {
      FIg_get_value (form1, gadget_label, &val);
      ivalue = val;
      status = dp$erase_hilite(msg = &msg_loc);
      EMomerr_hndlr(status, ret_end, "EMSslider.form_input error\n");
      EMerr_hndlr(EMis_error(msg_loc), status, OM_E_ABORT, ret_end);

      copy_obj.located_obj.osnum = me->obj_info.located_obj.osnum;
      OM_BLOCK_MOVE(&me->obj_info.module_info, &copy_obj.module_info,
                    sizeof(struct GRmd_env));
      copy_obj.module_info.md_id.objid = NULL_OBJID;

      status = om$send(msg = message GRgraphics.GRcopy(&msg_loc,
                          &me->obj_info.module_info, &copy_obj.module_info,
                          &copy_obj.located_obj.objid),
                       targetid = me->obj_info.located_obj.objid,
                       targetos = me->obj_info.located_obj.osnum);
      EMomerr_hndlr(status, ret_end, "EMSslider.form_input error\n");
      EMerr_hndlr(EMis_error(msg_loc), status, OM_E_ABORT, ret_end);

      if (gadget_label == LEFT_SLIDER)
      {
         x = (IGRdouble) me->top_left - me->bot_left;
         y = (IGRdouble) ivalue / 100.0;
         z = x * y;
         t = (IGRdouble) me->bot_left + z;
         me->tleft = t / 10.0;
      }
      else
      {
         x = (IGRdouble) me->top_right - me->bot_right;
         y = (IGRdouble) ivalue / 100.0;
         z = x * y;
         t = (IGRdouble) me->bot_right + z;
         me->tright = t / 10.0;
      }

      if (me->geom)
      {
         om$dealloc(ptr = me->geom);
         me->geom = NULL;
      }

      if (me->obj_type == CURVE)
      {
        status = EFcrv_move_poles(&msg_loc, &copy_obj, me->tleft,
                                  me->tright,
                                  (struct IGRbsp_curve **) &me->geom);
        EMomerr_hndlr(status, ret_end, "EMSslider.form_input error\n");
        EMerr_hndlr(EMis_error(msg_loc), status, OM_E_ABORT, ret_end);
      }
      else if (me->obj_type == SURFACE)
      {
/*
 * We are playing with the broadcast in progress flag to prevent
 * the copied surface from getting into the batch. (Since the
 * same is going to get deleted.
 * pp 09/27/91
 */

        save_broadcast_flag = ASbroadcast_in_progress;
        ASbroadcast_in_progress = TRUE;
        status = EFsrf_move_poles(&msg_loc, &copy_obj, me->u, me->v,
                                  me->tleft, me->tright,
                                  (struct IGRbsp_surface **) &me->geom);
        ASbroadcast_in_progress = save_broadcast_flag;
/* end pp */

        EMomerr_hndlr(status, ret_end, "EMSslider.form_input error\n");
        EMerr_hndlr(EMis_error(msg_loc), status, OM_E_ABORT, ret_end);
      }

/*
Rlw -- 25 May 1989

The module id for the copied object is NULL_OBJID.  Doree did
this so the copy would not go into the R-tree.  Sending this in a
display request is not proper.
*/
      DisplayMode = GRhd;

      status = om$send (
        msg = message GRgraphics.GRdisplay (
            &msg_loc,
            &copy_obj.module_info.md_env.matrix_type,
            copy_obj.module_info.md_env.matrix,
            &DisplayMode,
/*          &copy_obj.module_info.md_id                     */
            &me->obj_info.module_info.md_id
        ),
        targetid = copy_obj.located_obj.objid,
        targetos = copy_obj.located_obj.osnum
      );

      EMomerr_hndlr(status, ret_end, "EMSslider.form_input error\n");
      EMerr_hndlr(EMis_error(msg_loc), status, OM_E_ABORT, ret_end);

      break;
    }


    case SAVE:
    {
      response = EX_DATA;
      event.response = EX_DATA;
      size = sizeof(struct GRevent);
      status = ex$putque(msg = &msg_loc, response = &response,
                         byte = &size, buffer = (IGRchar *)&event);
      EMomerr_hndlr(status, ret_end, "EMSslider.form_input error\n");
      EMerr_hndlr(EMis_error(msg_loc), status, OM_E_ABORT, ret_end);

      break;
    }


    case CANCEL:
    {
      response = EX_RJT_MOVEON;
      event.response = EX_RJT_MOVEON;
      size = sizeof(struct GRevent);
      status = ex$putque(msg = &msg_loc, response = &response,
                         byte = &size, buffer = (IGRchar *)&event);
      EMomerr_hndlr(status, ret_end, "EMSslider.form_input error\n");
      EMerr_hndlr(EMis_error(msg_loc), status, OM_E_ABORT, ret_end);

      break;
    }


    default:
    {
      break;
    }

  }   /* end switch */

}
  ret_end:
    if (copy_obj.located_obj.objid != NULL_OBJID)
    {
      status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                             &copy_obj.module_info),
                       targetid = copy_obj.located_obj.objid,
                       targetos = copy_obj.located_obj.osnum);
      EMomerr_hndlr_action(status, ;, "EMSslider.form_input error\n");
      EMerr_hndlr_action(EMis_error(msg_loc), status, OM_E_ABORT, ;);
    }

    if ( !(status&1) && (me->geom) )
    {
       om$dealloc(ptr = me->geom);
       me->geom = NULL;
    }

    return(status);

}


/*
Abstract
    This method sets up the instance data needed by the form_input method
    and waits on the form_input method to return to it.

Notes

History
    dhm    10/5/88    creation date.
    dhm    10/7/88    modified to handle both surfaces and curves.
    dhm    2/22/89    added the range initialization.
*/

method EMprocess_form(IGRlong *msg; struct GRlc_info *obj; IGRboolean u, v,
                      obj_type; IGRint *response; IGRchar *response_data)
{
  IGRlong    msg_loc, status;
  IGRboolean  sts;
  extern IGRboolean   GRabsg_del_all();
/*  extern IGRlong   GRgetevent(); */
  IGRchar    errmsg[GR_MAX_CHAR];
  GRobjid    newid;
  struct GRpost_info  info;
  struct GRevent      ret_event;
  enum GRdpmode       DisplayMode;
  int       ret;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg, "EMSslider.EMprocess_form error\n");
  me->geom = NULL;
  me->bot_left = 0;
  me->bot_right = 0;
  me->top_left = 100;
  me->top_right = 100;
  me->tleft = 1.0;
  me->tright = 1.0;
  me->obj_type = obj_type;
  me->u = u;
  me->v = v;
  me->obj_info.located_obj.objid = obj->located_obj.objid;
  me->obj_info.located_obj.osnum = obj->located_obj.osnum;
  OM_BLOCK_MOVE(&obj->module_info, &me->obj_info.module_info,
                sizeof(struct GRmd_env));
 
  ret = FIf_display(form1);
  if (ret)
    return(OM_E_ABORT);

  DisplayMode = GRhd;
  status = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                         &obj->module_info.md_env.matrix_type,
                         obj->module_info.md_env.matrix,
                         &DisplayMode, &obj->module_info.md_id),
                   targetid = obj->located_obj.objid,
                   targetos = obj->located_obj.osnum);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

/*
  mask = GRm_DATA | GRm_RJT_MOVEON;
  size = sizeof(struct GRevent);
  status = GRgetevent(&msg_loc, &mask, &size, &ret_event, response,
                      response_data);
*/

  status = co$getevent (
    msg = &msg_loc,
    event_mask = GRm_DATA | GRm_RJT_MOVEON,
    response = response,
    response_data = response_data,
    event = &ret_event
  );

  if (!status) goto ret_end;

  switch (ret_event.response)
  {
    case EX_DATA:
    {
      if (me->geom)
      {
        info.construct_flag = FALSE;
        status = om$send(msg = message GRvg.GRpostabsg(&msg_loc,
                               &obj->module_info, &info,
                               (IGRchar *)me->geom, &newid),
                         targetid = obj->located_obj.objid,
                         targetos = obj->located_obj.osnum);
        EMomerr_hndlr(status, ret_end, errmsg);
        EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

        sts = GRabsg_del_all();
      }

      ex$clear_event_queue();
      break;
    }

    case EX_RJT_MOVEON:
    {
      ex$clear_event_queue();
      break;
    }

    default:
    {
      ex$clear_event_queue();
      break;
    }

  }   /* end switch */


  ret_end:
    status = dp$erase_hilite(msg = &msg_loc);
    EMomerr_hndlr(status, ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

    if (me->geom)  om$dealloc(ptr = me->geom);

    FIf_erase (form1);
    FIf_reset (form1);
    return(status);

}

end implementation EMSslider;
