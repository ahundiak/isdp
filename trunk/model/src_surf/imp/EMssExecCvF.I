/* ###################   APOGEE COMPILED   ################## */
/*
History
    AIC     many moons ago      Creation.
    SM      05-Sep-89           If loopset does not exist request
                                EFexecuteCurveFunction to process
                                natural rule lines. This is to correctly
                                handle a surface with no boundaries
                                imposed.
    SM      13-Sep-89           Pass curve types to EFexecuteCurveFunction().
                                Changed name of the function to
                                EFexecuteCurveFunc() due to argument change.
    Jack    05-June-91          only deal with rule lines if rule lines
                                are on.  2.0.1 Horizon Loops. 
    AIC     20-July-91          Make rule lines on/off window-specific.
    NP      25-Aug-92           Modified for ANSI compliance. Changed "ls_count" to
				"IGRuint".
    WBC     26-Jul-93           Call the specified function for horizon curves,
                                if any.  If the function is called for horizon
                                curves, don't want to call it for horizon
                                loops.
    WBC     22-Nov-93           Getting the list of objects on the notification
                                channel and sending each of them the
                                EMShrzcvs.EMexecuteCurveFunction message until
                                OM_I_STOP_SENDING is returned instead of just
                                sending the message out the notification
                                channel.
*/
class implementation EMSsubbs;

# include "msdef.h"     /* MSSUCC           */
# include "gocmacros.h" /* GRgetabsg macro  */
# include "OMmacros.h"  /* OM_BLOCK_MOVE    */
# include "EMSfrtdef.h" /* RLT_BUFFER_SIZE  */
#include "emseligible.h"
#include "EMShrzcvs.h"
#include "alloca.h"

extern IGRchar  EMSrltBuffer[RLT_BUFFER_SIZE];
extern IGRint   EFrule_lines_on_off();
extern void     EMSsubbs_get_locate_window();

from EMShelper import EMexecuteCurveFunction;
from EMSloopset import EMtree_traverse;
from EMSloop import EMexecuteCurveFunction;
from EMShrzcvs import EMexecuteCurveFunction;

method EMexecuteCurveFunction(IGRlong *EMmsg;
                              struct IGRbsp_surface *alt_geom;
                              IGRshort *mx_type; IGRmatrix mx;
                              IGRint (*f)(); IGRchar *args;
                              IGRushort eligible_edge_type)
{
  extern void           EFset_surface_display();
  extern IGRint         EFhorizon_edge_display_on_off();

  IGRlong               sts = OM_S_SUCCESS;
  GRobjid               window_id;
  GRspacenum            window_os;
  OM_S_CHANSELECT       to_helpers,
                        notification_chansel;
  struct IGRbsp_surface *surface = NULL;
  struct IGResqbs       *rlt = NULL;
  void                  EFexecuteCurveFunc();
  IGRuchar	    cvtype[4], *utype_ptr = NULL, *vtype_ptr = NULL;
  IGRushort	    edprops[4];
  struct GRmdenv_info	    env;
  struct EMShrzcvs_EMexecuteCurveFunction_Msg  EMexecCvFunc_args;
  OMuint                    num_on_channel,
                            index;
  IGRuint               ls_count;
  IGRint                hrz_edges_on = FALSE;
  OM_S_CHANSELECT       to_loopset;
  OM_S_MESSAGE          EMexecCvFunc_msg;
  OM_S_OBJECT_LINKAGE  *channel_objects;
  IGRlong               loc_msg;

  /*
   * Initialize
   */
  *EMmsg = MSSUCC;

  sts = om$make_chanselect(channame = "EMSrequester.to_helpers",
                           p_chanselect = &to_helpers);
  if(! (1 & sts)) goto wrapup;

  EMmake_chanselect(GRnotify_notification, &notification_chansel);

  env.matrix_type = *mx_type;
  OM_BLOCK_MOVE(mx, env.matrix, sizeof(IGRmatrix));

  /* send the execute curve function message to the surface's horizon curves;
   * getting the list of objects on the notification channel and sending each
   * of them the EMShrzcvs.EMexecuteCurveFunction message until
   * OM_I_STOP_SENDING is returned.  This is being done instead of just
   * sending the message out the notification channel since a non-horizon
   * curve object on the channel could return an error status and cause the
   * send to terminate before the appropriate horizon curve was displayed.
   */

  sts = om$get_channel_count(osnum = OM_Gw_current_OS,
                             objid = my_id,
                             p_chanselect = &notification_chansel,
                             count = &num_on_channel);
  if(! (1 & sts)) goto wrapup;

  sts = OM_S_SUCCESS;

  if (num_on_channel)
  {
    channel_objects = (OM_S_OBJECT_LINKAGE *) alloca(num_on_channel *
                                               sizeof( OM_S_OBJECT_LINKAGE ));

    if (! channel_objects)
    {
      sts = OM_E_ERROR;
      *EMmsg = EMS_E_NoStackMemory;
      goto wrapup;
    }

    sts = om$get_channel_objects(osnum = OM_Gw_current_OS,
                                 objid = my_id,
                                 p_chanselect = &notification_chansel,
                                 list = channel_objects,
                                 size = num_on_channel,
                                 count = &num_on_channel);
    if(! (1 & sts)) goto wrapup;

    /* using make message for efficiency purposes */

    EMexecCvFunc_args.EMmsg = EMmsg;
    EMexecCvFunc_args.options = EMS_HRZCVS_STOP_SEND;
    EMexecCvFunc_args.matrix_type = mx_type;
    EMexecCvFunc_args.matrix = mx;
    EMexecCvFunc_args.f = f;
    EMexecCvFunc_args.args = args;

    sts = om$make_message(classname = "EMShrzcvs",
                          methodname = "EMexecuteCurveFunction",
                          size = sizeof(EMexecCvFunc_args),
                          p_arglist = &EMexecCvFunc_args,
                          p_msg = &EMexecCvFunc_msg);
    if(! (1 & sts)) goto wrapup;

    for (index = 0; (index < num_on_channel) &&
                    (sts != OM_I_STOP_SENDING); index++)
    {
      sts = om$send(msg = &EMexecCvFunc_msg,
                    targetid = channel_objects[index].S_objid,
                    targetos = channel_objects[index].osnum);
    }
  }

  /* if any horizon curves were processed, we don't want to also process
   * horizon edges in this same view for the same surface
   */

  if ((sts == OM_I_STOP_SENDING) &&
      (*EMmsg == EMS_S_Success) &&
      (hrz_edges_on = EFhorizon_edge_display_on_off()))
  {
    EFset_surface_display(DISPLAY_HRZ_EDGES, FALSE);
  }
  else
    hrz_edges_on = FALSE;

  /*
   * Get the surface geometry
   */
  if(alt_geom) surface = alt_geom;
  else
  {
    IGRlong num_bytes = 0;

    sts = om$send(mode = OM_e_wrt_object,
                  msg = message EMSsubbs.GRgetsize(
                  EMmsg,
                  mx_type, 
                  mx, 
                  &num_bytes),
                  targetid = my_id);
    if(!(1&sts&*EMmsg)) goto wrapup;

    surface = (struct IGRbsp_surface *) om$malloc(size = num_bytes);
    if(!surface) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

    sts = om$send(mode = OM_e_wrt_object,
                  msg = message EMSsubbs.GRgetgeom(
                  EMmsg, 
                  mx_type, 
                  mx, 
                  (IGRchar *) surface),
                  targetid = my_id);
    if (!(1 & sts&*EMmsg)) goto wrapup;
  }

  /*
   * Send to the gradata objects
   */
    *EMmsg = EMS_I_NoResponse;
    sts = om$send(msg = message EMShelper.EMexecuteCurveFunction(EMmsg,
                surface, mx_type, mx, my_id, f, args, eligible_edge_type),
                p_chanselect = &to_helpers);
    if(sts IS OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
    if(! (1 & *EMmsg)) goto wrapup;

    if (hrz_edges_on)
    {
      EFset_surface_display(DISPLAY_HRZ_EDGES, TRUE);
      hrz_edges_on = FALSE;
    }

  /* If there is no FRT then send the message down to the edges.
   */
  EMSsubbs_get_locate_window(&window_id, &window_os);

  to_loopset.type = OM_e_addr;
  to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

  sts = om$get_channel_count(object = me, count = &ls_count, 
                             p_chanselect = &to_loopset);
  if(!(1&sts)) goto wrapup;

  if(*EMmsg IS EMS_I_NoResponse)
  {
    IGRint          u_rules, v_rules;

    if((!(eligible_edge_type & EMSeligible_NoGradata) &&
      EFrule_lines_on_off(window_id, window_os)))
     {
      u_rules = (IGRint) me^^EMSsubbs.u_rules;
      v_rules = (IGRint) me^^EMSsubbs.v_rules;
      sts = om$send(msg = message EMSsubbs.EMgetRuleLineTable(
                    EMmsg,
                    ls_count ? FALSE : TRUE,
                    &u_rules,
                    &v_rules,
                    surface,
                    (IGRint *)mx_type,
                    mx,
                    EMSrltBuffer,
                    RLT_BUFFER_SIZE,
                    &rlt),
                  targetid = my_id);
      if(! (1 & *EMmsg & sts)) goto wrapup;

      /* Get the curve types in U (same as for natural edges u=0 u=1) 
	 and V (same as for natural edges v=0 v=1) direction.
      */
      sts = om$send(msg = message EMSsubbs.EMget_natedge_info(EMmsg, &env, 
			cvtype, edprops), targetid = my_id);
      if(1&*EMmsg&sts)
       {
        utype_ptr = &cvtype[0];
        vtype_ptr = &cvtype[1];
       }

      /* Process the natural rule lines if there is no loopset. If there
	 is a loopset, the natural edges are going to take care of the
	 natural boundary of the surface.
      */
      EFexecuteCurveFunc(EMmsg, rlt, surface, f, args, 
			     ls_count ? FALSE : TRUE, utype_ptr, vtype_ptr);
      if(! (1 & *EMmsg)) goto wrapup;
     }
   }

    if(ls_count)
    {
      IGRint	depth;

      depth = MAXINT;

      sts = om$send(msg = message EMSloopset.EMtree_traverse(
                        &loc_msg,
                        message EMSloop.EMexecuteCurveFunction(
                            EMmsg,
                            surface,
                            mx_type,
                            mx,
                            my_id,
                            f,
                            args,
                            eligible_edge_type),
                        depth,
                        1,
                        &OPP_EMSloop_class_id, 
                        TRUE,
                        NULL,
                        NULL,
                        NULL),
                    p_chanselect = &to_loopset);
      if(!(1&sts&loc_msg)) goto wrapup;

    }/* if(ls_count) */

wrapup:

  if (hrz_edges_on)
  {
    EFset_surface_display(DISPLAY_HRZ_EDGES, TRUE);
  }

  if(*EMmsg IS EMS_I_Stop) sts = OM_I_STOP_SENDING;
  if(rlt && (rlt ISNT (struct IGResqbs *)EMSrltBuffer)) om$dealloc(ptr = rlt);
  if(surface && (surface ISNT alt_geom)) om$dealloc(ptr = surface);

  EMWRAPUP(*EMmsg, sts, "EMSsubbs.EMexecuteCurveFunction")
  return(sts);
}

end implementation EMSsubbs;
