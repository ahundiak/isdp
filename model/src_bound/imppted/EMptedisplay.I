/* ###################   APOGEE COMPILED   ################## */
/*
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
Jack 10 Dec  92  Moved code to see if I am in a graphic loop to be
                 done only if this edge is tangent and tangent edges
                 are supressed.
Jack 24 Sept 92  Don't call gettopedge, I will always be top edge.
                 Also, change error msg to specify EMSptedge rather
                 than EMSedge.
Jack 22 Sept 92  Initialize topedge to NULL_OBJID.
Jack 15 Sept 92  Exit if tangent and tangent edges are supressed.
                 Also, if this is both an EMSgraloop edge and a 
                 tan edge, and tan edge display is supressed, 
                 don't supress.
Jack 14 May  91  If this edge is marked tangent, and tangent edge 
                 display is turned off, then don't display. 
06 Oct 91   AIC Arguments to EMget_ele_header changed.
29 Aug 1988 jBk Modified to use dp$build_dis_buffer instead of
                explicitly setting each field of display element
                headers.
SM  19-Nov-87   Modified EMeddisplay.I
SM  07-Jul-88   Earlier I was sending EMSedge.EMdisplay
                wrt message to myself, with the display_flag
                set to EMS_EDGE_BEG_PT to display the point
                edge. The edge implementation however
                sets the weight to 5 unconditionally. Since
                this results into the point edge being
                displayed with weight more than other
                edges and people don't like it I have
                had to copy the code here and not mess
                with weight. This of course is a KLUDGE and
                this day is witness to the fact that
                Allen has promised to set things
                right as soon as he can!
*/

class implementation EMSptedge;

# include "msdef.h"         /* MSSUCC           */
# include "dpdef.h"         /* for dpmacros.h   */
# include "exmacros.h"      /* ex$get_cur_mod   */
# include "dpmacros.h"  /* dp$build_dis_buffer dp$dispelem dp$display */
# include "emsdef.h"
# include "emsmacros.h"
# include "EMSlmdef.h"
# include "EMScmacros.h"    /* EMSmsgReport     */
# include "bstypes.h"       /* BSrc             */
# include "dperr.h"         /* DPSTOPDRAW       */
# include "OMmacros.h"      /* added for OM_BLOCK_MOVE - TGM */
# include "grdpbdef.h"
# include "grdpbmacros.h"

from EMSsubbs import EMget_ele_header;
from GRvg import EMptatpr, GRgetsymb, GRgetgeom;

extern OMuword    OPP_EMSgraloop_class_id;

extern void GRdv_tangent_edge_display();

method EMdisplay(IGRlong *EMmsg; struct DPele_header *surface_ele_header;
                 IGRshort *mx_type; IGRmatrix matrix;
                 enum GRdpmode *display_mode;
                 struct DP_information *sp_info; IGRshort display_flag;
                 struct EMSpartedinfo *partinfo)
{
  extern IGRboolean     ASbroadcast_in_progress;

  IGRlong               sts = OM_S_SUCCESS;
  struct GRmdenv_info   mdenv_info;
  IGRint                inquire_only,
                        turn_on,
                        display_on;
  enum GRdpmode         sv_dis_mode;
  GRobjid               topedge=NULL_OBJID;
  OMuint                count,
                        c_count=0;  
  OM_S_OBJECT_LINKAGE  *channel_objects = NULL;
  IGRint                cnt=0,
                        graloop_edge=0;
  OMuword               my_classid;
  OM_S_CHANSELECT       chan_to_owner;

  *EMmsg = MSSUCC;

  sv_dis_mode = *display_mode; 

  if(me->ed_props & EMED_NO_DISPLAY) goto wrapup;



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
        
           /*
            * for EMSptedge, I will always be the top edge
            */
           topedge = my_id;
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

  if((me->ed_props & EMED_SEAM) && (me->ed_props & EMED_TANGENT) && sp_info)
    if(sp_info->gragad->flags & DP_NO_RULE_LINES) goto wrapup;

/*****************************
  UNCONDITIONALLY SET DISPLAY FLAG TO EMS_EDGE_BEG_PT.
*****************************/

  display_flag = EMS_EDGE_BEG_PT;

/*
    These checks were made useless by the above assignment.

  if(! ((display_flag IS EMS_NONSUBORDINATE_EDGE) &&
        (me->ed_props & (EMED_SUBORDINATE | EMED_NATURAL))) ||
       ((display_flag IS EMS_NONNATURAL_EDGE) &&
        (me->ed_props & EMED_NATURAL)))
*/
  {
    struct IGRpointset      pt_set;
    struct IGResps          ps_attr;
    struct DPele_header     local_sf_ele_header, local_ele_header,
                            *display_ele_header;
    struct GRsymbology      symb;
    struct IGResqbs         bsqsurf;
    IGRpoint                xyz_pt;
    GRrange                 range;

    /*
     * Make shure we have the surface element header
     */
    if(! surface_ele_header)
    {
      struct GRid         srf_id;
      GRobjid             edge_id;
      union IGRele_attr   ele_spec_att;

      surface_ele_header = &local_sf_ele_header;
      ele_spec_att.bsqsurf = &bsqsurf;

      /*
       * get the surface info, I am a part of
       */
      if(partinfo) edge_id = partinfo->edid;
      else edge_id = my_id;
      sts = om$send(msg = message EMSboundary.EMgetsurface_info
                    (EMmsg, &srf_id.objid, NULL), targetid = edge_id);
      if(! (1 & *EMmsg & sts)) goto wrapup;
      srf_id.osnum = OM_Gw_current_OS;

      /*
       * Get the element header
       */

      mdenv_info.matrix_type = *mx_type;
      OM_BLOCK_MOVE(matrix, mdenv_info.matrix, sizeof(IGRmatrix));
      sts = om$send(msg = message EMSsubbs.EMget_ele_header(EMmsg, NULL,
                      &mdenv_info, NULL, surface_ele_header, range,
                      &symb.display_attr, ele_spec_att, NULL),
                    targetid = srf_id.objid);
      if(! (1 & *EMmsg & sts)) goto wrapup;
    }

    /* display a vertex.
    */
    {
     extern void BSsfeval();
     BSrc      rc;
     IGRdouble vt_pt[2], *begin_pt, *end_pt;

     /*
      * get my end point
      */
     if(display_flag IS EMS_EDGE_BEG_PT){begin_pt=vt_pt;end_pt=NULL;}
     else { begin_pt = NULL; end_pt = vt_pt; }

     sts = om$send(msg=message EMSedge.EMendpts(EMmsg, begin_pt,
                        end_pt, NULL, NULL, partinfo), targetid = my_id);
     if(! (1 & *EMmsg & sts)) goto wrapup;

     /*
      * Get the xyz point  
      */
      BSsfeval(surface_ele_header->geometry.bspsurf, vt_pt[0],
                   vt_pt[1], 0, xyz_pt, &rc);
      if(rc) { *EMmsg = EMS_E_Fail; goto wrapup; }

      display_ele_header = &local_ele_header;

      symb.display_attr = *surface_ele_header->dis_att;

      ps_attr.is_connected = FALSE;

      pt_set.num_points = 1;
      pt_set.points = xyz_pt;

      dp$build_dis_buffer (
        buffer = display_ele_header,
        type = IGRPS,
        display_att = &symb.display_attr,
        ele_spec_att = &ps_attr,
        geometry = &pt_set
      );

      /**************************
      display_ele_header->dis_att->weight = 5;
      ***************************/
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

    if(! (1 & *EMmsg)) goto wrapup;

#if DLB_DISPLAY_FLAG_IS_ALWAYS_SET_TO_EMS_EDGE_BEG_PT_SO_FOLLOWING_CODE_REMOVED
    if((*EMmsg ISNT DPSTOPDRAW) && (display_flag IS EMS_EDGE_W_VERTICES))
    {
      sts = om$send(msg = message EMSedge.EMdisplay(EMmsg,
                    surface_ele_header, mx_type, matrix, display_mode,
                    sp_info, EMS_EDGE_BEG_PT, partinfo),
                    targetid = my_id);
      if(! (1 & *EMmsg & sts)) goto wrapup;

      if(*EMmsg ISNT DPSTOPDRAW)
      {
        sts = om$send(msg = message EMSedge.EMdisplay(EMmsg,
                      surface_ele_header, mx_type, matrix, display_mode,
                      sp_info, EMS_EDGE_END_PT, partinfo),
                      targetid = my_id);
      }
    }
#endif

  } /* if display flag matches edge properties */

wrapup:

  *display_mode = sv_dis_mode;

  EMSmsgReport(sts, "EMSptedge.EMdisplay", FALSE);
  EMSmsgReport(*EMmsg, "EMSptedge.EMdisplay", FALSE);
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


end implementation EMSptedge;
