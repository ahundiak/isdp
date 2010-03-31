/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This override traps the locate send to the surface and depending
    on the eligible class-list and other properties, decides to 
    either just process the surface, just process the edges of which
    this surface is the owner, or to process both.

  HISTORY

    WBC :  11/22/93  :  When attempting to locate a horizon curve, ignore
                        error messages returned from sends out the notification
                        channel since some types of objects may return an error
                        but this should cause this method to exit with an error.
    WBC :  07/22/93  :  Locating the surface's horizon curves, if any.  If a
                        horizon curve is located or even "hit" but not
                        accepted by the user, horizon edges are not located.
    AIC :  04/06/93  :  If the surface is not associative, convert it
                        before locating. This is done to avoid the case
                        that generation of a model-space couterpart
                        makes the surface associative with sends on its
                        channel outstanding.
    DLB :  08/28/92  :  KLUDGE locate to pick rigid components if doing the
                         nutty navigate graph thing.
    DLB :  05/28/92  :  Handle LC_LOCALMOD special case.
    WBC :  11/07/91  :  Return success if the message send to the graphics
                        loop returns unknown message.
    WBC :  06/20/91  :  Added code to locate graphic loops.
    DLB :  04/14/89  :  Replaced code to figure out if inactive with a message
                        send which does the same thing.  This way others who
                        have the same problems with old design files with 
                        inactive surfaces should send this message first.
    DLB :  03/31/89  :  Added check to figure out if the surface is inactive
                        or active.  Basically, the surface is non-locateable
                        and non-displayable and it ALL its loops are
                        inactive then set the inactive bit on in ss_props. 
    SS  :  08/16/88  :  Modified the way in which loopsets are maintained
                        for simple surfaces (surfaces w/o loopsets).
    DLB :  07/26/88  :  Added code to check surface inactive bit.  If set,
                        I simply return success.
    SS  :  03/25/88  :  Creation
*/

class implementation EMSsubbs;

#include "OMmacros.h"
#include "msdef.h"
#include "gocmacros.h"
#include "EMS.h"
#include "EMSprop.h"
#include "EMSlc.h"
#include "EMSlcdef.h"
#include "EMSssprops.h"
#include "EMSstruct.h"
#include "EMSobjmgrdef.h"
#include "EMSopt.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSboundary import EMbdrylocate;
from EMShrzcvs   import EMlocate, EMbdrylocate;

extern OMuword  OPP_EMSloopset_class_id,
                OPP_GRcurve_class_id,
                OPP_EMSedge_class_id,
                OPP_EMSloop_class_id,
                OPP_EMAsubbs_class_id;

method GRlocate (struct GRlc_cvl *cvl; OM_p_KEY_DESC range_key)
{
  IGRshort *mattyp;
  OMuword my_classid;
  OMuint lsexists, num_helpers, i, num_hrz_curves;
  IGRint hrz_edges_on;
  IGRlong stat_OM, msg_loc, *cvlmsg;
  IGRdouble *mat;
  GRobjid lsobj;
  struct EMSsfinfo sfinfo;
  struct EMSlcinput lcin;
  struct EMSlcoutput lcout;
  struct EMSgrobj sf_objinfo;
  struct GRid     window_grid;
  enum EMSdatatype dumtype;
  OM_S_CHANSELECT chan_to_loopset,
                  to_helpers,
                  notification_chan;
  OM_S_OBJECT_LINKAGE objlink;
  IGRboolean          was_located,
                      reset_hrz_edge_display;
  extern void EFset_surface_display();
  extern void EMsrfloc_init();
  extern IGRboolean EMlsconstructor(), EMlsvalidator();
  extern IGRboolean EMbdrys_eligible(), EMnogeomhit();
  extern IGRlong EMgetvggeom(), EMgetshobj();
  extern int GRnavigate_locate_rigid_comps;
  extern IGRint EFhorizon_edge_display_on_off();

  cvlmsg = &cvl->msg;
  *cvlmsg = MSSUCC;
  stat_OM = OM_S_SUCCESS;
  hrz_edges_on = FALSE;
  reset_hrz_edge_display = FALSE;

  sfinfo.geom = NULL;


    /*The following has been added by DLB on 03/31/89.*/
    if ( !(ME.GRgraphics->properties & GRIS_LOCATABLE  ) &&
         !(ME.GRgraphics->properties & GRIS_DISPLAYABLE) &&
         !(ME.EMSsubbs->ss_props & EMSIS_INACTIVE      ) )
    {
      IGRboolean did_set_inactive;  
      /*Changed to message send on 04/15/89.-DLB*/
      stat_OM = om$send(msg = message EMSsubbs.EMset_inactive(&msg_loc, 
                              &did_set_inactive),
                        targetid = my_id);
      if (!(1 & stat_OM & msg_loc)) goto ret_end;                      
    }

    if (ME.EMSsubbs->ss_props & EMSIS_INACTIVE) goto ret_end;

    if (cvl->attributes.obj_attr.owner_action & LC_LOCALMOD)
    {
      GRobjid  tree_top_id;
      IGRshort grprops;

      /*Special case of local mod issuing locate as read op but really doing
       * a write op.  If top id is rigidly owned then dont locate.
       */
      stat_OM = om$send(msg = message EMSsurface.EMget_tree_top(&msg_loc,
                              &tree_top_id, NULL, NULL),
                        targetid = my_id);
      if (!(1 & stat_OM & msg_loc)) goto ret_end;

      stat_OM = om$send(msg = message GRgraphics.GRgetprops(&msg_loc,&grprops),
                        targetid = tree_top_id);
      if (!(1 & stat_OM & msg_loc)) goto ret_end;

      if (grprops & GR_RIGID_RELATIONSHIP) goto ret_end;
    }

    if (GRnavigate_locate_rigid_comps) 
    {
      /*WE BE KLUDG'IN NOW!!!!*/
      cvl->attributes.obj_attr.owner_action |= LC_RIGID_COMP;
    }

    EMsrfloc_init (my_id);
    stat_OM = om$send (mode = OM_e_wrt_message, msg = message
               EMSsurface.GRlocate (cvl, range_key), targetid = my_id);
    /*
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (*cvlmsg), *cvlmsg, MSFAIL, ret_end);
    */
    if (stat_OM == OM_I_STOP_SENDING || EMnogeomhit (cvl))
      goto ret_end;

    sfinfo.props = ME.GRgraphics->properties;
    sfinfo.symb.display_attr = ME.GRvg->display_attr;
    sfinfo.symb.level = me->level;
    if (EMbdrys_eligible (cvl, &sfinfo))
    {
      OM_p_CLASSLIST lcclass;

      sfinfo.id.objid = my_id;
      sfinfo.id.osnum = OM_Gw_current_OS;

      mattyp = &cvl->module.md_env.matrix_type;
      mat = cvl->module.md_env.matrix;
      stat_OM = EMgetvggeom (&msg_loc, mattyp, mat, &sfinfo.id, &sfinfo.geom,
                &dumtype);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *cvlmsg, MSFAIL, ret_end);

      chan_to_loopset.type = OM_e_addr;
      chan_to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

      lcclass = cvl->classes;

      /*
       * It is assumed that the user would be interested in locating either
       * model space counterpart objects or topology objects and
       * not both.
       * pp (10/12/89)
       */
      if (EMclass_eligible (OPP_GRcurve_class_id, lcclass))
        lcin.options = EMSlcopt_xyzelem | EMSlcopt_rangechk;
      else if (EMclass_eligible (OPP_EMSedge_class_id, lcclass) ||
               EMclass_eligible (OPP_EMSloop_class_id, lcclass))
        lcin.options = EMSlcopt_uvelem | EMSlcopt_rangechk;

      lcin.eligfunc = NULL;
      lcin.eligfunc_args = NULL;
      lcin.more_info = NULL;

      stat_OM = om$get_channel_objects (object = me, 
                 p_chanselect = &chan_to_loopset, list = &objlink, 
                 size = 1, count = &lsexists);
      if (!lsexists)
      {
        /*
         * A loopset does not exist for this surface. Attach a shell loopset,
         * using the locally defined constructor and validator functions. 
         */

        sf_objinfo.grid.objid = my_id;
        sf_objinfo.grid.osnum = OM_Gw_current_OS;
        sf_objinfo.envptr = TRUE;
        sf_objinfo.grenv.ptr = &cvl->module.md_env;
        stat_OM = EMgetshobj (&msg_loc, NULL, OPP_EMSloopset_class_id, 
                   EMSshobj_sfbdry, OM_Gw_current_OS, &sf_objinfo,
                   EMlsconstructor, &sf_objinfo, EMlsvalidator, &lsobj);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *cvlmsg, MSFAIL, ret_end);
      }

      stat_OM = om$send (msg = message EMSboundary.EMbdrylocate (&msg_loc,
                 &sfinfo, &lcin, cvl, range_key, &lcout),
                 p_chanselect = &chan_to_loopset);

      if (stat_OM == OM_I_STOP_SENDING)
        goto ret_end;
      /*
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (*cvlmsg), *cvlmsg, MSFAIL, ret_end);
      */

      /* haven't accepted anything yet; try to locate horizon curves (if any)
       * if xyz elements are being requested
       */

      if (lcin.options & EMSlcopt_xyzelem)
      {
        stat_OM = EMmake_chanselect(GRnotify_notification, &notification_chan);
        EMomerr_exit (stat_OM, ret_end);

        stat_OM = om$get_channel_count(objid = my_id,
                                       p_chanselect = &notification_chan,
                                       count = &num_hrz_curves);
        EMomerr_exit (stat_OM, ret_end);

        window_grid.objid = cvl->button.objid;
        window_grid.osnum = cvl->button.osnum;
        hrz_edges_on = EFhorizon_edge_display_on_off();

        for (i = 0; i < num_hrz_curves; i++)
        {
          if (lcin.options & EMSlcopt_hitormiss)
          {
            stat_OM = om$send (msg = message EMShrzcvs.EMlocate (&msg_loc,
                                                                 cvl,
                                                                 &window_grid,
                                                                 NULL, NULL,
                                                                 NULL, NULL,
                                                                 NULL,
                                                                 &was_located),
                               p_chanselect = &notification_chan,
                               to = i,
                               from = i);
          }
          else  /* do a "real" locate */
          {
            stat_OM = om$send (msg = message EMShrzcvs.EMbdrylocate (&msg_loc,
                                                             cvl, range_key),
                               p_chanselect = &notification_chan,
                               to = i,
                               from = i);
          }

          if (stat_OM == OM_I_STOP_SENDING)
            goto ret_end;
          else if ((stat_OM == OM_S_SUCCESS) &&
                   (msg_loc == EMS_I_Found)  &&
                   hrz_edges_on)
          {
            /* a horizon curve was "hit" during locate but it was not
             * accepted; don't want to allow horizon edges to be located in
             * this case since, if there are also horizon edges, it would
             * appear to the user that the same edge was being selected twice
             */

            EFset_surface_display(DISPLAY_HRZ_EDGES, FALSE);
            hrz_edges_on = FALSE;
            reset_hrz_edge_display = TRUE;
          }
          else
            stat_OM = OM_S_SUCCESS;
        }
      }

      /* still haven't accepted anything; try to locate graphics loop (if any)
      */

      stat_OM = EMmake_chanselect(EMSrequester_to_helpers, &to_helpers);
      EMomerr_exit (stat_OM, ret_end);

      stat_OM = om$get_channel_count(objid = my_id,
                                     p_chanselect = &to_helpers,
                                     count = &num_helpers);
      EMomerr_exit (stat_OM, ret_end);

      for (i = 0; i < num_helpers; i++)
      {
        stat_OM = om$send (msg = message EMSboundary.EMbdrylocate (&msg_loc,
                           &sfinfo, &lcin, cvl, range_key, &lcout),
                           p_chanselect = &to_helpers,
                           to = i,
                           from = i);

        if (stat_OM == OM_I_STOP_SENDING)
          break;
        else if (stat_OM == OM_W_UNKNOWN_MSG)
          stat_OM = OM_S_SUCCESS;
        else
        {
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (*cvlmsg), *cvlmsg, MSFAIL, ret_end);
        }
      }

      if (reset_hrz_edge_display)
        EFset_surface_display(DISPLAY_HRZ_EDGES, TRUE);
    }

ret_end:
  if (sfinfo.geom)
    om$dealloc (ptr = sfinfo.geom);
/*
  EMWRAPUP (*cvlmsg, stat_OM, "EMSsubbs.GRlocate");
*/
  if (GRnavigate_locate_rigid_comps) 
  {
    /*WE BE KLUDG'IN NOW!!!!*/
    cvl->attributes.obj_attr.owner_action &= ~LC_RIGID_COMP;
  }

  if (reset_hrz_edge_display)
    EFset_surface_display(DISPLAY_HRZ_EDGES, TRUE);

  return (stat_OM);
}

end implementation EMSsubbs;
