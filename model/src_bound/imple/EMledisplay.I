/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlinedge;

# include "msdef.h"         /* MSSUCC           */
# include "exmacros.h"      /* ex$get_cur_mod   */
# include "dpdef.h"
# include "dpmacros.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "EMScmacros.h"    /* EMSmsgReport     */
# include "bstypes.h"       /* BSrc             */
# include "EMSlmdef.h"
# include "dperr.h"         /* DPSTOPDRAW       */
# include "OMmacros.h"      /* added for OM_BLOCK_MOVE - TGM */
# include "grdpbdef.h"
# include "grdpbmacros.h"

from EMSsubbs import EMget_ele_header;
from GRvg import EMptatpr, GRgetsymb, GRgetgeom;

extern OMuword    OPP_EMSgraloop_class_id;

extern void GRdv_tangent_edge_display();

method EMdisplay(IGRlong *EMmsg; struct DPele_header *ele_header;
                 IGRshort *mx_type; IGRmatrix matrix;
                 enum GRdpmode *display_mode;
                 struct DP_information *sp_info; IGRshort display_flag;
                 struct EMSpartedinfo *partinfo)
/*
Notes

display_flag -- input

    The edge can be displayed in the following modes:
        1. EMS_WHL_EDGE  display the whole edge.
        2. EMS_EDGE_BEG_PT display the begin pt of the edge with
           the weighted pt.
        3. EMS_EDGE_END_PT display the end pt of the edge with the
           weighted pt.
        4. EMS_NONNATURAL_EDGE display the whole edge if it is not
           natural.
        5. EMS_NONSUBORDINATE_EDGE display the whole edge if it is not
           dominant and not natural.

    I have included the EFpartinfo_to_pts function in this file.

History
   WBC  07 Jul  94  Removed code to create MSCs; we are no longer
                    trying to create these on the fly.  Users must
                    explicitly use the command "Enable Read-Only Detailing"
                    to create EMSpointers and MSCs for read-only detailing
                    (TRs 119420413 and 119419323).
   WBC  17 Jun  94  Before creating MSCs, put in check to make sure the object
                    is not in a read-only object space.
   WBC  15 Oct  93  Don't create an MSC for this edge if an associative
                    broadcast is in progress.
   WBC  21 Sept 93  Only create an MSC for this edge if the edge is being
                    displayed (not erased).
   WBC  29 Apr  93  If the mode to create model space counterparts (MSCs) is
                    on and this edge is not a common subordinate edge, create
                    an MSC for this edge.
   Jack 10 Dec  92  Removed EMgettopedge call.  The top edge is either
                    partinfo->edid or my_id.  Also, moved code to 
                    see if I am in a graphic loop to be done only
                    if this edge is tangent and tangent edges are supressed.
   Jack 24 Sept 92  if gettopedge returns NULL_OBJID, I am top edge.
   Jack 22 Sept 92  Initialize topedge to NULL_OBJID.
   Jack 15 Sept 92  Exit if tangent and tangent edges are supressed.
                    Also, if this is both an EMSgraloop edge and a 
                    tan edge, and tan edge display is supressed, 
                    don't supress.
   Jack 14 May  91  If this edge is marked tangent, and tangent edge 
                    display is turned off, then don't display. 
    AIC 06 Oct  91  Arguments to EMget_ele_header changed.
    SS  17 Feb  89  The property check has been changed to check the props
                    of the incoming partinfo (if non-NULL). Also, the 
                    edgeid for display.
    AIC 07 Feb  89  Fixed for partinfo on ISO edges.
    AIC 29 Dec  88  ISO-edge support. (NOTE: it is assumed that
                    iso-edges have only one span.)
    SS  06 Dec  88  Model-space counterpart display
    AIC 25 Sept 87  Creation Date
*/
{
  extern IGRboolean     ASbroadcast_in_progress;

  IGRlong           sts;
  IGRushort ed_props;
  GRobjid           ed_id;
  struct IGResqbs   save_bsqsurf;
  struct GRmdenv_info   mdenv_info;
  IGRint                inquire_only,
                        turn_on,
                        display_on;
  enum GRdpmode     sv_dis_mode;
  GRobjid               topedge=NULL_OBJID;
  OMuint                count,
                        c_count=0;  
  OM_S_OBJECT_LINKAGE  *channel_objects = NULL;
  IGRint                cnt=0,
                        graloop_edge=0;
  OMuword               my_classid;
  OM_S_CHANSELECT       chan_to_owner;

  *EMmsg = MSSUCC;
  sts = OM_S_SUCCESS;
  sv_dis_mode = *display_mode;

  if(me->ed_props & EMED_NO_DISPLAY) goto wrapup;


  if((me->ed_props & EMED_SEAM) && (me->ed_props & EMED_TANGENT) && sp_info)
    if(sp_info->gragad->flags & DP_NO_RULE_LINES) goto wrapup;

  if (partinfo)
  {
    ed_props = partinfo->edprops;
    ed_id = partinfo->edid;
  }
  else
  {
    ed_props = me->ed_props;
    ed_id = my_id;
  }


  if(me->ed_props & EMED_TANGENT)
   {
     inquire_only=1;
     turn_on=1; /* won't be used */
     GRdv_tangent_edge_display(inquire_only,
                               turn_on,
                              &display_on);
     if(!display_on)
      {
        /*
         * determine if this edge is in a graphic loop.  if so,
         * don't suppress display
         */
         topedge = ed_id;
         count = 0;
      
         EMmake_chanselect (EMSedge_to_owner, &chan_to_owner);
      
         sts = om$get_channel_count(objid = topedge,
                                    p_chanselect = &chan_to_owner,
                                    count = &count);
         
        if(count)
         {
          channel_objects = (OM_S_OBJECT_LINKAGE *) alloca(sizeof(
                                                   OM_S_OBJECT_LINKAGE) * count);
      
          sts = om$get_channel_objects(objid = topedge,
                                       p_chanselect = &chan_to_owner,
                                       list = channel_objects,
                                       size = count,
                                       count = &c_count);
      
          graloop_edge = 0;
          for(cnt=0;cnt<c_count;cnt++)
           {
            sts = om$get_classid( osnum = channel_objects[cnt].osnum,
                                  objid = channel_objects[cnt].S_objid,
                                  p_classid = &my_classid );
            if(! (1 & sts))
              continue;
              
            if((sts = om$is_ancestry_valid(subclassid = my_classid,
                            superclassid = OPP_EMSgraloop_class_id)) ==
                                                                OM_S_SUCCESS)
              graloop_edge=1;
            else
              sts = OM_S_SUCCESS;  /* reset sts */
      
           }     
           
         }  
        
        if(!graloop_edge)
          goto wrapup;           /* if this edge is tangent and tangent edge display
                                  * is toggled off, just exit
                                  */
      }

   }


  if((display_flag IS EMS_EDGE_BEG_PT) ||
     (display_flag IS EMS_EDGE_END_PT) ||
     (ed_props & EMED_MSCEXISTS))
  {
    sts = om$send(msg = message EMSedge.EMdisplay(EMmsg, ele_header,
                  mx_type, matrix, display_mode, sp_info, display_flag,
                  partinfo), mode = OM_e_wrt_message, targetid = my_id);
  }

  else if(! ((display_flag IS EMS_NONSUBORDINATE_EDGE) &&
             (ed_props & (EMED_SUBORDINATE | EMED_NATURAL))) ||
            ((display_flag IS EMS_NONNATURAL_EDGE) &&
             (ed_props & EMED_NATURAL)))
  {
    struct GRsymbology      symb;
    struct IGResqbs         bsqsurf;
    struct DPele_header     local_ele_header, *display_ele_header;
    struct IGRbsp_bdry_pts  bdry;
    IGRint                  index0, index1;
    IGRdouble               pt0[2], pt1[2];
    GRrange                 range;

    IGRdouble               rlt_bdrys[4], rules;
    IGRint                  numbound = 0;

    /*
     * Initialize the bsqsurf structure
     */
    bsqsurf.u_rules = 0;
    bsqsurf.v_rules = 0;
/* fix for umr */
    bsqsurf.u_rule_values = NULL;
    bsqsurf.v_rule_values = NULL;
    bsqsurf.is_polydis = FALSE;
    bsqsurf.is_surfdis = TRUE;
    bsqsurf.is_slowdis = FALSE;
    bsqsurf.rules_specified = TRUE;

    /*
     * Make shure we have the surface element header
     */
    if(! ele_header)
    {
      struct GRid         srf_id;
      union IGRele_attr   ele_spec_att;

      display_ele_header = &local_ele_header;
      ele_spec_att.bsqsurf = &bsqsurf;

      /*
       * Get the surface id
       */

      sts = om$send(msg = message EMSboundary.EMgetsurface_info
                    (EMmsg, &srf_id.objid, NULL), targetid = ed_id);
      if(! (1 & *EMmsg & sts)) goto wrapup;
      srf_id.osnum = OM_Gw_current_OS;

      /*
       * Get the element header
       */
      mdenv_info.matrix_type = *mx_type;
      OM_BLOCK_MOVE(matrix, mdenv_info.matrix, sizeof(IGRmatrix));

      sts = om$send(msg = message EMSsubbs.EMget_ele_header(EMmsg, NULL, 
                    &mdenv_info,NULL, display_ele_header, range,
                    &symb.display_attr, ele_spec_att, NULL),
                    targetid = srf_id.objid);
      if(! (1 & *EMmsg & sts)) goto wrapup;
    }
    else display_ele_header = ele_header;

    /*
     * Set up the rule line table
     */
    if(!display_ele_header->ele_spec_att.bsqsurf)
    {
      display_ele_header->ele_spec_att.bsqsurf = &bsqsurf;
    }
    else
    {
      save_bsqsurf = display_ele_header->ele_spec_att.bsqsurf[0];
    }

    if (ME.EMSedge->ed_props & EMED_ISO)
    {
      IGRdouble beg_par, end_par, *bdry_ptr;

      /*
       * Display the edge as a rule line.
       */
      bdry_ptr = rlt_bdrys;
      if(fabs(me->points[0] - me->points[2]) <
         fabs(me->points[1] - me->points[3]))
      {
        display_ele_header->ele_spec_att.bsqsurf->u_rules = 1;
        display_ele_header->ele_spec_att.bsqsurf->v_rules = 0;
        display_ele_header->ele_spec_att.bsqsurf->u_rule_values = &rules;
        display_ele_header->ele_spec_att.bsqsurf->u_num_bound = &numbound;
        display_ele_header->ele_spec_att.bsqsurf->u_bdrys = &bdry_ptr;
        rules = (me->points[0] + me->points[2]) / 2;
        beg_par = me->points[1];
        end_par = me->points[3];
      }
      else
      {
        display_ele_header->ele_spec_att.bsqsurf->u_rules = 0;
        display_ele_header->ele_spec_att.bsqsurf->v_rules = 1;
        display_ele_header->ele_spec_att.bsqsurf->v_rule_values = &rules;
        display_ele_header->ele_spec_att.bsqsurf->v_num_bound = &numbound;
        display_ele_header->ele_spec_att.bsqsurf->v_bdrys = &bdry_ptr;
        rules = (me->points[1] + me->points[3]) / 2;
        beg_par = me->points[0];
        end_par = me->points[2];
      }

      /*
       * Use partinfo
       */
      if(partinfo)
      {
        IGRdouble   new_par;

        new_par = partinfo->edbdry[0].param * (end_par - beg_par) + beg_par;
        end_par = partinfo->edbdry[1].param * (end_par - beg_par) + beg_par;
        beg_par = new_par;
      }

      /*
       * Sort the begin and end paramaters
       */
      if(beg_par > end_par)
      {
        IGRdouble   swap;

        swap = beg_par;
        beg_par = end_par;
        end_par = swap;
      }

      if(beg_par ISNT 0.0)
      {
        rlt_bdrys[0] = 0.0;
        rlt_bdrys[1] = beg_par;
        numbound = 1;
      }

      if(end_par ISNT 1.0)
      {
        rlt_bdrys[numbound * 2] = end_par;
        rlt_bdrys[numbound * 2 + 1] = 1.0;
        numbound ++;
      }
    }
    else
    {
      /*
       * Display the edge as a boundary on the surface
       */
      if(partinfo)
      {
        void      EFpartinfo_to_pts();
        IGRdouble new_pt0[2], new_pt1[2];

        EFpartinfo_to_pts(EMmsg, partinfo, me->points, new_pt0, new_pt1,
                          &index0, &index1);
        pt0[0] = me->points[index0];
        pt0[1] = me->points[index0 + 1];
        pt1[0] = me->points[index1];
        pt1[1] = me->points[index1 + 1];
        me->points[index0]     = new_pt0[0];
        me->points[index0 + 1] = new_pt0[1];
        me->points[index1]     = new_pt1[0];
        me->points[index1 + 1] = new_pt1[1];
        bdry.num_points = (index1 - index0) / 2 + 1;
        bdry.points = &me->points[index0];
      }
      else
      {
        bdry.num_points = (IGRlong) me->num_points;
        bdry.points = me->points;
      }

      /*
       * Set up the boundaries
       */
      display_ele_header->geometry.bspsurf->num_boundaries = 1;
      display_ele_header->geometry.bspsurf->bdrys = &bdry;

      display_ele_header->ele_spec_att.bsqsurf->u_rules = 0;
      display_ele_header->ele_spec_att.bsqsurf->v_rules = 0;
    }

    /* 
     * display
     */
    if(sp_info)
    {
      dp$dispelem(msg = EMmsg, buffer = display_ele_header,
                  mode = *display_mode, dp_info = sp_info);
    }
    else
    {
      struct GRid moduleGRid;

      ex$get_cur_mod(id = &moduleGRid.objid, osnum = &moduleGRid.osnum);

      dp$display(msg = EMmsg, osnum = moduleGRid.osnum,
                 objid = moduleGRid.objid, mode = *display_mode,
                 buffer = display_ele_header);
    }

    /*
     * Restore the element header
     */
    if(display_ele_header IS ele_header)
    {
      ele_header->geometry.bspsurf->num_boundaries = 0;
      ele_header->geometry.bspsurf->bdrys = NULL;
      if(ele_header->ele_spec_att.bsqsurf IS &bsqsurf)
      {
        ele_header->ele_spec_att.bsqsurf = NULL;
      }
      else
      {
        ele_header->ele_spec_att.bsqsurf[0] = save_bsqsurf;
      }
    }

    if(partinfo && (! (me->ed_props & EMED_ISO)))
    {
      /*
       * Restore the instance data
       */
      me->points[index0]     = pt0[0];
      me->points[index0 + 1] = pt0[1];
      me->points[index1]     = pt1[0];
      me->points[index1 + 1] = pt1[1];
    }

    if((*EMmsg ISNT DPSTOPDRAW) && (display_flag IS EMS_EDGE_W_VERTICES))
    {
      sts = om$send(msg = message EMSedge.EMdisplay(EMmsg, ele_header,
                    mx_type, matrix, display_mode, sp_info,
                    EMS_EDGE_BEG_PT, partinfo), targetid = my_id);
      if(! (1 & *EMmsg & sts)) goto wrapup;

      if(*EMmsg ISNT DPSTOPDRAW)
      {
        sts = om$send(msg = message EMSedge.EMdisplay(EMmsg, ele_header,
                      mx_type, matrix, display_mode, sp_info,
                      EMS_EDGE_END_PT, partinfo), targetid = my_id);
      }
    }

  } /* if display flag matches edge properties */

wrapup:
  EMSmsgReport(sts, "EMSlinedge.EMdisplay", FALSE);
  EMSmsgReport(*EMmsg, "EMSlinedge.EMdisplay", FALSE);

  *display_mode = sv_dis_mode;

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

void EFpartinfo_to_pts(EMmsg, partinfo, pts, pt0, pt1, index0, index1)

IGRlong                 *EMmsg;
struct EMSpartedinfo    *partinfo;
IGRdouble               *pts, *pt0, *pt1;
IGRint                  *index0, *index1;
/*
    History

        AIC     25 September 87     Creation Date
*/
{
  IGRdouble             param0, param1;
  struct EMSedgebound   *edbdry0, *edbdry1;

  *EMmsg = EMS_S_Success;

  edbdry0 = partinfo->edbdry;
  edbdry1 = edbdry0 + 1;
  if(edbdry0->span_inx IS edbdry1->span_inx)
  {
    *index0 = *index1 = edbdry0->span_inx * 2;
    if(edbdry0->param > edbdry1->param)
    {
      param0 = edbdry1->param;
      param1 = edbdry0->param;
    }
    else /* edbdry0->param <= edbdry1->param) */
    {
      param0 = edbdry0->param;
      param1 = edbdry1->param;
    }
  }
  else if(edbdry0->span_inx > edbdry1->span_inx)
  {
    *index0 = edbdry1->span_inx * 2;
    *index1 = edbdry0->span_inx * 2;
    param0 = edbdry1->param;
    param1 = edbdry0->param;
  }
  else /* edbdry0->span_inx < edbdry1->span_inx */
  {
    *index0 = edbdry0->span_inx * 2;
    *index1 = edbdry1->span_inx * 2;
    param0 = edbdry0->param;
    param1 = edbdry1->param;
  }

  pt0[0] = pts[*index0]   + param0 * (pts[*index0+2] - pts[*index0]);
  pt0[1] = pts[*index0+1] + param0 * (pts[*index0+3] - pts[*index0+1]);
  pt1[0] = pts[*index1]   + param1 * (pts[*index1+2] - pts[*index1]);
  pt1[1] = pts[*index1+1] + param1 * (pts[*index1+3] - pts[*index1+1]);

  *index1 += 2;

  return;
}

end implementation EMSlinedge;
