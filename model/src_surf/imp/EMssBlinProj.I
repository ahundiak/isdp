/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

# include <string.h>
# include "msdef.h"     /* MSSUCC           */
# include "gocmacros.h" /* GRgetabsg macro  */
# include "OMmacros.h"  /* OM_BLOCK_MOVE    */
# include "EMSfrtdef.h" /* RLT_BUFFER_SIZE  */
# include "ex.h"
# include "griodef.h"
# include "grio.h"
# include "grerr.h"     /* GR_I_OUTSIED_TOL */
# include "EMSlc.h"
# include "EMSlcdef.h"
# include "alloca.h"
# define INT        0

extern IGRchar  EMSrltBuffer[RLT_BUFFER_SIZE];
extern IGRint   EFrule_lines_on_off();
extern void     EMSsubbs_get_locate_window();

from EMSboundary    import  EMbdrylocate;
from EMSgradata     import  EMlocate;
from EMShrzcvs      import  EMlocate;

/*
History

    AIC   long ago   Creation
    Jack  05-June-91 Only deal with rule lines if rule lines are on.
                     2.0.1 Horizon Loops.
    AIC   20-July-91 Make rule lines on/off window-specific.
    NP    24-Aug-92  Modified for ANSI compliance. "matrix_type" comes in as an
		     "IGRshort *", but should be cast as "IGRint *" into the
		     "EMgetRuleLineTable" method for ANSI compatibility.
   Jack   07-May-93  Initialized cvl.classes pointer to NULL to fix umr's(Purify)
   WBC    07-Jul-93  Checking to see if the surface's horizon curves, if any,
                     are hit by this locate.
   WBC    22-Nov-93  Getting the list of objects on the notification channel
                     and sending each of them the EMShrzcvs.EMlocate message
                     until OM_I_STOP_SENDING is returned instead of just
                     sending the message out the notification channel.
*/                   

method GRlnprocess(IGRlong *EMmsg; IGRshort *matrix_type;
                   IGRmatrix matrix; IGRdouble *acc_tolerance;
                   struct IGRline *line;
                   IGRpoint line_pt, surf_pt; IGRdouble *t;
                   struct GRparms *proj_parms)
{
  IGRlong               sts = OM_S_SUCCESS;
  OM_S_CHANSELECT       to_helpers,
                        notification_chan;
  struct IGRbsp_surface *surface = NULL;
  struct IGResqbs       *rlt = NULL;

  /*
   * Initialize
   */
  *EMmsg = MSSUCC;
  sts = EMmake_chanselect (EMSrequester_to_helpers, &to_helpers);
  if(! (1 & sts)) goto wrapup;

  /*
   * Get the surface geometry
   */
  GRgetabsg(EMmsg, matrix_type, matrix, (IGRchar **) &surface, INT);

  {
    IGRboolean          was_located = FALSE, target_srf;
    struct GRlc_info    lc_info;
    struct GRlc_cvl     cvl;
    struct IGResbs      element_specific;
    extern IGRboolean   EMsrfloc_putinfo();

    /*
     * Initialize
     */
    lc_info.located_obj.objid = my_id;
    lc_info.located_obj.osnum = OM_Gw_current_OS;
    lc_info.module_info.md_id.objid = NULL_OBJID;
    lc_info.module_info.md_env.matrix_type = *matrix_type;
    OM_BLOCK_MOVE(matrix, lc_info.module_info.md_env.matrix,
                  sizeof(IGRmatrix));
    lc_info.geom_parms.polygon_inx = 3; /* defined in go.h as "not set" */

    OM_BLOCK_MOVE(&lc_info.module_info, &cvl.module,
                  sizeof(struct GRmd_env));
    cvl.attributes.type = GR_bl_loc;
    cvl.attributes.acc_line = *line;
    cvl.attributes.acc_tolerance = *acc_tolerance;
    cvl.action_handler = NULL;
    cvl.classes = NULL;
    strcpy(cvl.attributes.obj_attr.classes, " ");
    EMSsubbs_get_locate_window(&cvl.button.objid, &cvl.button.osnum);

    /*
     * get my attributes
     */
    sts = om$send(msg = message EMSsubbs.GRgetattr(EMmsg,
                  (IGRchar *) &element_specific), targetid = my_id);
    if (!(1 & (sts & *EMmsg))) goto wrapup;

    target_srf = EMsrfloc_putinfo (my_id, NULL_OBJID, EMSsrfloc_null, 
                  NULL_OBJID);
    /*
     * if the polygon is displayed, first check the
     * polygon by projecting the point on the polygon
     */
    if (element_specific.is_polydis)
    {
      void      EFpolygonLocate();

      EFpolygonLocate(EMmsg, surface, &lc_info, &cvl, NULL, NULL, NULL,
                      NULL, &was_located);
      if(! (1 & *EMmsg)) goto wrapup;

      if (target_srf && was_located)
        EMsrfloc_putinfo (my_id,NULL_OBJID,EMSsrfloc_polygon,NULL_OBJID);
    }

    if(! was_located)
    {
      OM_S_CHANSELECT       to_loopset;
      struct GRid           window_id;
      struct EMSlcinput     lcin;
      struct EMSlcoutput    lcout;
      struct EMSsfinfo      sfinfo;
      void                  EMSsubbs_get_locate_window();

      EMSsubbs_get_locate_window(&window_id.objid, &window_id.osnum);

      EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);

      sfinfo.geom = surface;
      sfinfo.props = ME.GRgraphics->properties;
      sfinfo.symb.display_attr = ME.GRvg->display_attr;
      sfinfo.symb.level = me->level;

      lcin.options = EMSlcopt_hitormiss | EMSlcopt_rangechk;
      lcin.eligfunc = NULL;
      lcin.eligfunc_args = NULL;
      lcin.more_info = NULL;

      lcout.props = NULL;

      sts = om$send(msg = message EMSboundary.EMbdrylocate(
                        EMmsg,
                        &sfinfo,
                        &lcin,
                        &cvl,
                        NULL, /* range_key */
                        &lcout),
                    p_chanselect = &to_loopset);
      if(sts IS OM_I_STOP_SENDING) sts = OM_S_SUCCESS;
      if(! ( 1 & sts)) goto wrapup;

      was_located = (lcout.props & EMSlcoutput_located) ? TRUE : FALSE;

      if(was_located)
      {
        lc_info.proj_pnt[0] = lcout.locobj.proj_pnt[0];
        lc_info.proj_pnt[1] = lcout.locobj.proj_pnt[1];
        lc_info.proj_pnt[2] = lcout.locobj.proj_pnt[2];
      }
      else
      {
        OM_S_MESSAGE         locate_msg;
        OM_S_OBJECT_LINKAGE *channel_objects;
        OMuint               num_on_channel,
                             index;
        struct EMShrzcvs_EMlocate_Msg EMlocate_args;

        /* Send to horizon curves; getting the list of objects on the
         * notification channel and sending each of them the
         * EMShrzcvs.EMlocate message until OM_I_STOP_SENDING is returned.
         * This is being done instead of just sending the message out the
         * notification channel since a non-horizon curve object on the
         * channel could return an error status and cause the send to
         * terminate before the appropriate horizon curve was hit.
         */

        sts = EMmake_chanselect (GRnotify_notification, &notification_chan);
        if(! (1 & sts)) goto wrapup;

        sts = om$get_channel_count(osnum = OM_Gw_current_OS,
                                   objid = my_id,
                                   p_chanselect = &notification_chan,
                                   count = &num_on_channel);
        if(! (1 & sts)) goto wrapup;

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
                                       p_chanselect = &notification_chan,
                                       list = channel_objects,
                                       size = num_on_channel,
                                       count = &num_on_channel);
          if(! (1 & sts)) goto wrapup;

          sts = OM_S_SUCCESS;
          *EMmsg = EMS_I_NoResponse;

          /* using make message for efficiency purposes */

          EMlocate_args.EMmsg = EMmsg;
          EMlocate_args.cvl = &cvl;
          EMlocate_args.window_grid = &window_id;
          EMlocate_args.prism_rel = NULL;
          EMlocate_args.inside = NULL;
          EMlocate_args.outside = NULL;
          EMlocate_args.overlap = NULL;
          EMlocate_args.loc_parms = &lc_info;
          EMlocate_args.was_located = &was_located;

          sts = om$make_message(classname = "EMShrzcvs",
                                methodname = "EMlocate",
                                size = sizeof(EMlocate_args),
                                p_arglist = &EMlocate_args,
                                p_msg = &locate_msg);
          if(! (1 & sts)) goto wrapup;

          for (index = 0; (index < num_on_channel) &&
                          (sts != OM_I_STOP_SENDING); index++)
          {
            sts = om$send(msg = &locate_msg,
                          targetid = channel_objects[index].S_objid,
                          targetos = channel_objects[index].osnum);
          }
        }

        if (*EMmsg != EMS_I_Found)
        {
          /*
           * Send to the gradata objects if no horizon curves were found
           */
	  GRgetabsg(EMmsg, matrix_type, matrix, (IGRchar **) &surface, INT);
          *EMmsg = EMS_I_NoResponse;
          sts = om$send(msg = message EMSgradata.EMlocate(
                          EMmsg,
                          surface,
                          &lc_info,
                          &cvl,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          &was_located,
                          &window_id),
                        p_chanselect = &to_helpers);
          if(sts IS OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
          if(! (1 & *EMmsg)) goto wrapup;
        }

        if(*EMmsg IS EMS_I_NoResponse &&
           EFrule_lines_on_off(cvl.button.objid, cvl.button.osnum))
        {
          void              EFlocateRLT();
          IGRuint            ls_count;

          om$get_channel_count(object = me,
                               p_chanselect = &to_loopset,
                               count = &ls_count);

          /*
           * Get my rule lines.
           */
          sts = om$send(msg = message EMSsubbs.EMgetRuleLineTable(
                          EMmsg,
                          ls_count ? FALSE : TRUE,
                          NULL,
                          NULL,
                          surface,
                          (IGRint *)matrix_type,
                          matrix,
                          EMSrltBuffer,
                          RLT_BUFFER_SIZE,
                          &rlt),
                        targetid = my_id);
          if(! (1 & *EMmsg & sts)) goto wrapup;

          EFlocateRLT(EMmsg, rlt, surface, &lc_info, &cvl, NULL, NULL,
                      NULL, NULL, &was_located);
          if(! (1 & *EMmsg)) goto wrapup;

          if(target_srf && was_located)
            EMsrfloc_putinfo(my_id, NULL_OBJID, EMSsrfloc_ruleline,
                             NULL_OBJID);
        }
      }
      if(target_srf && was_located)
        EMsrfloc_putinfo(my_id,NULL_OBJID,EMSsrfloc_insedge,NULL_OBJID);
    }

    /*
     * KLUGED
     */
    if(was_located)
    {
      *EMmsg = MSSUCC;
      line_pt[0] = surf_pt[0] = lc_info.proj_pnt[0];
      line_pt[1] = surf_pt[1] = lc_info.proj_pnt[1];
      line_pt[2] = surf_pt[2] = lc_info.proj_pnt[2];
      *t = 0.5;
      proj_parms->u = 0.5;
      proj_parms->v = 0.5;
      proj_parms->polygon_inx = 0;
    }
    else
    {
      *EMmsg = GR_I_OUTSIDE_TOL;
      line_pt[0] = line_pt[1] = line_pt[2] = 0;
      surf_pt[0] = surf_pt[1] = surf_pt[2] =
        100 * cvl.attributes.acc_tolerance;
    }
  }

wrapup:
  if(rlt && ((IGRchar *)rlt ISNT EMSrltBuffer)) om$dealloc(ptr = rlt);
  EMWRAPUP(*EMmsg, sts, "EMSsubbs.EMborelineProject")
  return(sts);
}

end implementation EMSsubbs;
