/*###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

# include "godef.h"
# include "gocmacros.h"     /* GRgetabsg macro          */
# include "msdef.h"         /* MS message codes         */
# include "madef.h"         /* MAIDMX                   */
# include "dpmacros.h"      /* dpmacros.h               */
# include "EMSfrtdef.h"     /* RLT_BUFFER_SIZE          */
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "dperr.h"         /* DPSTOPDRAW               */
# include "EMSlmdef.h"      /* display flags            */
# include "exdef.h"
# include "exmacros.h"
# include "EMSssprops.h"
# include "EMSopt.h"
# include "emsmacros.h"
# include "OMmacros.h"
# include "dpdef.h"
# include "EMShrzcvs.h"
#include "DPdlist.h"
# include "alloca.h"

# define EMSisUpdate(dp_info) ((dp_info)->is_update)

# define EMSisDisplayable(properties, mode) \
         ((properties & GRIS_DISPLAYABLE) || \
          (mode IS GRhdo) || (mode IS GRhhdo) || (mode IS GRheo) || \
          (mode IS GRbdheo) || (mode IS GRbeheo) )

from EMSboundary    import  EMtree_traverse;
from EMSedge        import  EMdisplay;
from EMShelper      import  EMdisplay;
from EMShrzcvs      import  EMdisplay;

extern IGRchar  EMSrltBuffer[RLT_BUFFER_SIZE];
extern IGRboolean dynamics_in_progress;
extern IGRint     EFrule_lines_on_off();

method GRdisyourself(IGRlong *EMmsg;
                     IGRshort *type;
                     IGRmatrix matrix;
                     enum GRdpmode *mode;
                     struct IGRaltdisplay *alt_symb;
                     struct DP_information *sp_info;
                     OM_p_KEY_DESC key)
/*
Abstract

    This method displays the surface.

Arguements

    matrix, type - input
        Matrix and matrix type

    mode - input
        Display mode

    alt_symb - input
        Alternate symbology. This argument may be NULL, in which case
        the surface will use its own symbology.

    sp_info - input
        Display information provided by the display subsystem.

    key - input
        Range key.

Algorithm

    Send EMShelper.EMdisplay on the to_associations channel. If there
    is no response, and rule lines are on, then get my rule line table 
    and call the display function.

Return Status

Bugs

Notes

    Display can be further optimized by supressing the display
    of one in a pair of common edges, when appropriate.

Examples

History
        WBC    22-Nov-93    Getting the list of objects on the notification
                            channel and sending each of them the
                            EMShrzcvs.EMdisplay message until OM_I_STOP_SENDING
                            is returned instead of just sending the message
                            out the notification channel.
        WBC     29 Oct 93   Ignoring error messages returned from the horizon
                            curve display message sent out the notification
                            channel because other types of objects may be
                            attached to this channel and if they return some
                            error message the display of the surface shouldn't
                            be aborted (I/Fold WS#3722382).
        WBC     22 Jul 93   Before displaying any horizon edges try to
                            display horizon curves.  If horizon curves
                            are displayed, don't display horizon edges.
        NP      25 Aug 92   Modified for ANSI compliance. Changed "mcount" and 
                            "ls_count" to "IGRuint". Added other typecasts.
        Jack    13 May 92   The sp_info struct now has the view_objid
                            and view_osnum filled out regardless of 
                            whether or not this is a fit so I removed
                            the conditional for calling EMShelper.EMdisplay.
        Jack    05 Oct 91   Only call the EMShelper.EMdisplay if
                            this call is not because of a fit.
        AIC     20 Sep 91   Pass mdenv_info to EMget_ele_header.
        AIC     19 Jul 91   Make rule lines on/off window-specific.
        Jack    10-June-91  Only deal with rule lines if rule lines are
                            on.  2.0.1 Horizon Loops. 
        PP      08 Jun 1991 Cause an update of the range in rtree only
                            if broadcast is not in progress.
        RC      29 Dec 1989 Update range in rtree if dynamics is not
                            in progress.
        RC      16 Jun 1989 Replaced ex$get_cur_mod by ex$get_modid
                            as the current module may not be my module
                            if I am in a reference file.
        AIC     12 Oct 1988 Call EMSsubbs.EMget_boundaries
                            instead of EMSloopset.EMpack.
        DLB 04/17/89        Added EMset_inactive send to handle pre 1.2.0
                            OS's which dont have inactive bit set.
        rlw     27-Sep-88   Modified to remove stop draw logic as Tony
                            Tassone was going to put this in display logic
                            in the 1.2.0 release.

        rlw     01-Jul-88   Modified to check the hardware event in order
                            to stop unnecessary draws.
 
        DLB 07/26/88    Added code to check for inactive bit.  If set
                        just return success.
        SAM 05-Jun-88   Added code to send EMput_range_in_rtree, if
                        the surface bit EMIS_RANGE_MODIFIED is set.

        AIC     14-Jun-88   Moidified local EMSisUpdate macro to
                            fix common edge display.

        dhm     05-Mar-88   Added GR_NOTIFY_LISTENERS.

        AIC     15-Jul-87   Use facewise diplay.

        AIC     04/20/87    Pack the boundaries until facewise display
                            is completed.

        RLW     09/21/86    OM 4.0 modifications plus addition of key
                            arguement

        RLW     06/27/86    The beginning
*/
{
  extern IGRshort           BSbx2();
  extern IGRshort           GRtransrange();
  extern IGRboolean         ASbroadcast_in_progress;
  IGRint                    sts, i;
  IGRdouble                 range[6];
  struct IGResbs            bs_attr;
  struct IGRdisplay         display_attributes;
  struct DPele_header       ele_header;
  struct IGRbsp_surface     *surface = NULL;
  OM_S_CHANSELECT           to_owners;
  IGRboolean                owner_origin;
  int                       dlist_flags;
  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = MSSUCC;
  surface = NULL;
  ele_header.ele_spec_att.bsqsurf = NULL;

  /*The following has been added by DLB on 04/17/89.*/
# ifndef NOTYET
  if ( !(ME.GRgraphics->properties & GRIS_LOCATABLE  ) &&
       !(ME.GRgraphics->properties & GRIS_DISPLAYABLE) &&
       !(ME.EMSsubbs->ss_props & EMSIS_INACTIVE      ) )
  {
    IGRlong dlb_loc_msg;
    IGRboolean dlb_did_set_inactive;  
    /*Changed to message send on 04/15/89.-DLB*/
    om$send(msg = message EMSsubbs.EMset_inactive(&dlb_loc_msg, 
                  &dlb_did_set_inactive),
            targetid = my_id);
  }
#endif
  if (ME.EMSsubbs->ss_props & EMSIS_INACTIVE) goto wrapup;

  if EMSisUpdate(sp_info) owner_origin = TRUE;
  else
  {
     EMmake_chanselect(GRconnector_to_owners, &to_owners);

     sts = om$is_objid_on_channel(object_c = me,
                                  p_chanselect = &to_owners,
                                  objid = sender_id);
     owner_origin = sts IS OM_S_SUCCESS ? TRUE : FALSE;
     if(sts IS OM_W_NOTONCHAN) sts = OM_S_SUCCESS;
     if(! (1 & *EMmsg & sts)) goto wrapup;
  }

  dlist_flags = sp_info->is_update ? 0 : DP_DLIST_DISPLAY_SINGLE_ELEMENT;
  if ( !owner_origin )
  {
     dlist_flags |= DP_DLIST_DISPLAY_ALL_EDGES;
  }
  sts = DPdlist_display_element( my_id, OM_Gw_current_OS,
                                 sp_info, matrix, *type, *mode, alt_symb,
                                 key, dlist_flags );
  if ( 1 & sts )
  {
     goto wrapup;
  }
  sts = OM_S_SUCCESS;


  /*
   * If the dynamics is in progress, the surface will not be in Rtree.
   * In such a case donot try to update its range. -- RC 12/29/89
   */

  /*
   * KLUDGE
   *
   * If broadcast is in progress, the surface will not be in Rtree.
   * Do this until France supports NDupdate message, at which time this
   * will not be necessary.
   * pp 06/07/91
   *
   * Removed the kludge since I do not believe this is necessary any
   * more. pp 01/08/91 
   *
   * Added the kludge back since (despite our best attempts) we cannot
   * seem to avoid displaying objects when they are recomputing. Strange
   * as it may seem, this whole affair seems extremely depressing. It is
   * easy to answer the meaning of life than solve this ?&*%@#$.
   * pp 01/13/91
   */


  if( !dynamics_in_progress && !ASbroadcast_in_progress &&
      (ME.EMSsubbs->ss_props & EMSIS_RANGE_MODIFIED) )
  {
    OMuword send_depth;
    OM_S_OBJECT_LINKAGE objlink;
    OM_S_CHANSELECT prim_chan;
    IGRuint mcount;
    struct GRid md_grid;

    /*
     * Replaced ex$get_cur_mod by ex$get_modid -- RC 05/16/89
     */

    md_grid.osnum = OM_Gw_current_OS;
    sts = ex$get_modid(mod_osnum = md_grid.osnum, 
                       mod_id =  &md_grid.objid);
    if(!(1&sts)) goto wrapup;

    sts = EMmake_chanselect (module_primary, &prim_chan);
    if(!(1&sts)) goto wrapup;

    sts = om$get_channel_objects(objid = md_grid.objid,
                                 p_chanselect = &prim_chan,
                                 list = &objlink,
                                 size = 1, count = &mcount);
    if(!(1&sts)) goto wrapup;

    sts = om$get_senddepth(objid = objlink.S_objid,
                           osnum = objlink.osnum,
                           p_depth = &send_depth);
    if(!(1&sts)) goto wrapup;
    
    if(!send_depth)
    {
      sts = om$send(msg = message EMSsubbs.EMput_range_in_rtree(
                    EMmsg,
                    NULL,  /* geometry of the surface */
                    NULL, /* old range of the surface */
                    NULL, /* new range of the surface */
                    TOPOLOGICAL, /* surface change */
                    &md_grid),
            targetid = my_id);
      if(!(1&sts)) goto wrapup;

    } /* If (!send_depth) */

  } /* if( !dynamics_in_progress && 
           (ME.EMSsubbs->ss_props & EMSIS_RANGE_MODIFIED) ) */


  if EMSisDisplayable(ME.GRgraphics->properties, *mode)
  {
    if DPlevel_on((IGRint)me->level, sp_info)
    {
      union IGRele_attr     ele_spec_att;
      struct GRmdenv_info   mdenv_info;
      OM_S_CHANSELECT       notification_chansel;

      /*
       * Get the element header with the element specific attributes
       * and remove the attributes from the element header.
       */
      ele_spec_att.bspsurf = &bs_attr;
      mdenv_info.matrix_type = *type;
      OM_BLOCK_MOVE(matrix, mdenv_info.matrix, sizeof(IGRmatrix));

      sts = om$send(msg = message EMSsubbs.EMget_ele_header(EMmsg, NULL,
                    &mdenv_info, alt_symb, &ele_header, range,
                    &display_attributes, ele_spec_att, key),
                    targetid = my_id);
      if(! (1 & *EMmsg & sts)) goto wrapup;
      ele_header.ele_spec_att.bspsurf = NULL;

      /*
       * Display
       */
      {
        extern void         EFset_surface_display();
        extern IGRint       EFhorizon_edge_display_on_off();

        IGRboolean          world,
                            compute,
                            display_done;
        struct IGResqbs     *rlt;
        OM_S_CHANSELECT     to_helpers;
        IGRuint             ls_count;
        IGRint              hrz_edges_on;
        OM_S_CHANSELECT     to_loopset;

        EMmake_chanselect(EMSrequester_to_helpers, &to_helpers);
        EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);

        om$get_channel_count(object = me,
                             p_chanselect = &to_loopset,
                             count = &ls_count);

        rlt = NULL;
        world = TRUE;
        compute = FALSE;
        display_done = FALSE;

        if DPis_wireframe(sp_info)
        {
          OM_S_MESSAGE                    display_msg;
          OM_S_OBJECT_LINKAGE            *channel_objects;
          OMuint                          num_on_channel,
                                          index;
          struct EMShrzcvs_EMdisplay_Msg  EMdisplay_args;
          struct EMSpartolbasis           partol;

          /* display the surface's horizon curves, if any */

          /* Send to horizon curves; getting the list of objects on the
           * notification channel and sending each of them the
           * EMShrzcvs.EMdisply message until OM_I_STOP_SENDING is returned.
           * This is being done instead of just sending the message out the
           * notification channel since a non-horizon curve object on the
           * channel could return an error status and cause the send to
           * terminate before the appropriate horizon curve was displayed.
           */

          sts = EMmake_chanselect(GRnotify_notification, &notification_chansel);
          if(! (1 & sts)) goto wrapup;

          sts = om$get_channel_count(osnum = OM_Gw_current_OS,
                                     objid = my_id,
                                     p_chanselect = &notification_chansel,
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
                                         p_chanselect = &notification_chansel,
                                         list = channel_objects,
                                         size = num_on_channel,
                                         count = &num_on_channel);
            if(! (1 & sts)) goto wrapup;

            sts = OM_S_SUCCESS;

            /* using make message for efficiency purposes */

            EMdisplay_args.EMmsg = EMmsg;
            EMdisplay_args.options = EMS_HRZCVS_STOP_SEND;
            EMdisplay_args.matrix_type = type;
            EMdisplay_args.matrix = matrix;
            EMdisplay_args.mode = mode;
            EMdisplay_args.alt_symb = alt_symb;
            EMdisplay_args.sp_info = sp_info;
            EMdisplay_args.key = key;

            sts = om$make_message(classname = "EMShrzcvs",
                                  methodname = "EMdisplay",
                                  size = sizeof(EMdisplay_args),
                                  p_arglist = &EMdisplay_args,
                                  p_msg = &display_msg);
            if(! (1 & sts)) goto wrapup;

            for (index = 0; (index < num_on_channel) &&
                            (sts != OM_I_STOP_SENDING); index++)
            {
              sts = om$send(msg = &display_msg,
                            targetid = channel_objects[index].S_objid,
                            targetos = channel_objects[index].osnum);
            }
          }

          /* if any horizon curves were displayed for this view we don't
           * want to also display horizon edges in this same view for the
           * same surface
           */

          partol.is_valid = FALSE;
          partol.mattyp = type;
          partol.mat = matrix;

          if ((sts == OM_I_STOP_SENDING) &&
              (*EMmsg == EMS_S_Success) &&
              (hrz_edges_on = EFhorizon_edge_display_on_off()))
          {
            EFset_surface_display(DISPLAY_HRZ_EDGES, FALSE);
          }
          else
            hrz_edges_on = FALSE;

          {
            struct GRid *window_id_ptr,
                        window_id;

            if(sp_info)
            {
              window_id_ptr = &window_id;
              window_id.objid = sp_info->view_objid;
              window_id.osnum = sp_info->view_osnum;
            }
            else window_id_ptr = NULL;

            sts = om$send(msg = message EMShelper.EMdisplay(
                              EMmsg,
                              owner_origin,
                              mode,
                              sp_info,
                              &bs_attr,
                              &ele_header,
                              type,
                              matrix,
                              EMSrltBuffer,
                              RLT_BUFFER_SIZE,
                              &partol,
                              &display_done,
                              window_id_ptr),
                            p_chanselect = &to_helpers);

            if (hrz_edges_on)
            {
              EFset_surface_display(DISPLAY_HRZ_EDGES, TRUE);
            }

            if(sts IS OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
            if((! (1 & *EMmsg & sts)) OR (sts IS OM_I_STOP_SENDING))
              goto wrapup;
          }

          if(ls_count)
          {
            /*
             * Display the loopset (natural edges)
             */
            sts = om$send(msg = message EMSboundary.EMtree_traverse(
                            EMmsg,
                            message EMSedge.EMdisplay(
                                EMmsg,
                                &ele_header,
                                type,
                                matrix,
                                mode,
                                sp_info,
                                owner_origin ? EMS_NONSUBORDINATE_EDGE :
                                               EMS_WHL_EDGE,
                                NULL),
                            MAXINT,
                            1,
                            &OPP_EMSedge_class_id,
                            NULL,
                            NULL,
                            NULL,
                            NULL),
                          p_chanselect = &to_loopset);
            if(! (1 & sts)) goto wrapup;
          }
        }

        /*
         * If rule lines are off and the window is a wireframe window,
         * there is no need to perform the following display.
         */
        if(DPis_wireframe(sp_info) &&
           (sp_info->gragad->flags & DP_NO_RULE_LINES))
        {
          display_done = TRUE;
        }

        if(! display_done)
        {
          /*
           * Get my rule lines.
           */
          sts = om$send(msg = message EMSsubbs.EMgetRuleLineTable(
                            EMmsg,
                            ls_count ? FALSE : TRUE,
                            (IGRint *)&bs_attr.u_rules, /*expects "IGRint *" */
                            (IGRint *)&bs_attr.v_rules, /*expects "IGRint *" */
                            ele_header.geometry.bspsurf,
                            (IGRint *)type, /* expects pointer to IGRint */
                            matrix,
                            EMSrltBuffer,
                            RLT_BUFFER_SIZE,
                            &ele_header.ele_spec_att.bsqsurf),
                        targetid = my_id);
          if(! (1 & *EMmsg & sts)) goto wrapup;

          if(! DPis_wireframe(sp_info))
          {
            /*
             * Pack boundaries for non-wireframe display
             */
            surface = ele_header.geometry.bspsurf;
            surface->bdrys = NULL;
            sts = om$send(msg = message EMSsubbs.EMget_boundaries(EMmsg,
                          type, matrix, &surface->on_off,
                          &surface->num_boundaries, &surface->bdrys),
                          targetid = my_id);
            if(! (1 & *EMmsg & sts)) goto wrapup;

            /*
             * Set the element type to IGRBS for non-wireframe display.
             */
            ele_header.type = IGRBS;
          }

          /*
           * Display the surface
           */
          dp$dispelem(msg = EMmsg, buffer = &ele_header, mode = *mode, 
                      dp_info = sp_info);

        } /* if not display_done */

      } /* block */

    } /* if level is on */

  } /* if displayable */

wrapup:
  if((ele_header.ele_spec_att.bsqsurf) &&
     (ele_header.ele_spec_att.bsqsurf ISNT (struct IGResqbs *)&bs_attr) &&
     (ele_header.ele_spec_att.bsqsurf ISNT (struct IGResqbs *)EMSrltBuffer))
    om$dealloc(ptr = ele_header.ele_spec_att.bsqsurf);

  /*
   * Free up the memory used to pack boundaries for hidden surface
   */
  if((surface) && (! DPis_wireframe(sp_info)))
  {
    if(surface->bdrys)
    {
      for(i = 0; i < surface->num_boundaries; i ++)
        om$dealloc(ptr = surface->bdrys[i].points);
      om$dealloc(ptr = surface->bdrys);
    }
    surface->num_boundaries = 0;
  }

  GR_NOTIFY_LISTENERS(EMmsg, &sts, GR_DISPLAYED);

  EMSmsgReport(sts, "EMSsubbs.GRdisyourself", FALSE);
  EMSmsgReport(*EMmsg, "EMSsubbs.GRdisyourself",FALSE);
  if(*EMmsg IS DPSTOPDRAW)
  {
    sts = OM_I_STOP_SENDING;
  }
  else
  {
    *EMmsg = MSSUCC;
    sts = OM_S_SUCCESS;
  }
  return(sts);
}

end implementation EMSsubbs;
