/* #################   APOGEE  COMPILED   ######################### */
class implementation EMSedge;

# include "msdef.h"         /* MSSUCC           */
# include "dpdef.h"         /* for dpmacros.h   */
# include "exmacros.h"      /* ex$get_cur_mod   */
# include "dperr.h"         /* DPSTOPDRAW       */
# include "dpmacros.h"  /* dp$build_dis_buffer dp$dispelem dp$display */
# include "emsdef.h"
# include "emsmacros.h"
# include "EMSlmdef.h"
# include "EMScmacros.h"    /* EMSmsgReport     */
# include "bstypes.h"       /* BSrc             */
# include "EMSobjmgrdef.h"
# include "EMS.h"           /* for sharables */
# include "EMSlcdef.h"
# include "OMmacros.h"      /* added OMmacros.h for OM_BLOCK_MOVE T.G.M */
# include "grdpbdef.h"
# include "grdpbmacros.h"

extern void GRdv_tangent_edge_display();

extern OMuword    OPP_EMSgraloop_class_id;

from EMSsubbs import EMget_ele_header;
from GRvg import EMptatpr, GRgetsymb, GRgetgeom, GRchglevel;

method EMdisplay(IGRlong *EMmsg; struct DPele_header *surface_ele_header;
                 IGRshort *mx_type; IGRmatrix matrix;
                 enum GRdpmode *display_mode;
                 struct DP_information *sp_info; IGRshort display_flag;
                 struct EMSpartedinfo *partinfo)
/*
Notes

display_flag -- input

    The edge can me displayed in the following modes:
        1. EMS_WHL_EDGE  display the whole edge.
        2. EMS_EDGE_BEG_PT display the begin pt of the edge with
           the weighted pt.
        3. EMS_EDGE_END_PT display the end pt of the edge with the
           weighted pt.
        4. EMS_NONNATURAL_EDGE display the whole edge if it is not
           natural.
        5. EMS_NONSUBORDINATE_EDGE display the whole edge if it is not
           dominant and not natural.

History
   WBC  07 Jul  94  Removed code to create MSCs; we are no longer
                    trying to create these on the fly.  Users must
                    explicitly use the command "Enable Read-Only Detailing"
                    to create EMSpointers and MSCs for read-only detailing
                    (TRs 119420413 and 119419323).
   WBC  17 Jun  94  Before creating MSCs, put in check to make sure the object
                    is not in a read-only object space.
   WBC  03 Jan  94  Only apply partinfo boundaries if part edge id is different
                    than my_id, otherwise the boundaries are applied twice
                    (TR#119314707).
   WBC  29 Nov  93  Before displaying an edge's MSC, update its level if its
                    current level is not displayable.
   WBC  15 Oct  93  Don't create an MSC for this edge if an associative
                    broadcast is in progress.
   WBC  21 Sept 93  Only create an MSC for this edge if the edge is being
                    displayed (not erased).
   WBC  28 Apr  93  If the mode to create model space counterparts (MSCs) is
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
    SS  16 Jun  89  If the edge has a model-space counterpart and sp_info
                    is NULL, use GRdisplay instead of GRdisyourself
                    to do the display.
    SS  17 Feb  89  The property check has been changed to check the props
                    of the incoming partinfo (if non-NULL). Also, the 
                    edgeid for display.
    SS  06 Dec  88  If this edge has a model-space counterpart, it is
                    is displayed via this MSC.
29 Aug 1988 jBk Changed to use dp$build_dis_buffer instead of
                explicitly assigning element display header fields.
    AIC 25 Sept 87  Display as a curve is now the default display
                    mode for edges. Also, optimize by displaying
                    part edge info as curve boundaries instead of
                    extracting partial curve.
    AIC 18 Sept 87  Use part edge info to get surface info.
    AIC 15 Sept 87  Always return Success
    AIC 15-Jul-87   1) Accept surface element header for whole edge cases.
                    2) Use the FPE for EMS_WHL_EDGE case.
                    3) Add optional supression of dominant, natural edges.
    RC  04/08/87    Creation date
*/
{
  extern IGRboolean     ASbroadcast_in_progress;

  IGRushort             ed_props;
  GRobjid               ed_id;
  IGRlong               sts, msg_loc;
  struct IGRbsp_curve   curve_geom;
  struct GRmdenv_info   mdenv_info;
  IGRint                inquire_only,
                        turn_on,
                        display_on;
  enum GRdpmode         sv_dis_mode;
  GRobjid               topedge=NULL_OBJID,
                        MSCid;
  OMuint                count,
                        c_count=0;  
  OM_S_OBJECT_LINKAGE  *channel_objects = NULL;
  IGRint                cnt=0,
                        graloop_edge=0;
  OMuword               my_classid;
  OM_S_CHANSELECT       chan_to_owner;




  *EMmsg = MSSUCC;
  sts = OM_S_SUCCESS;
  curve_geom.poles = /* NULL; */
  curve_geom.weights = /* NULL; */
  curve_geom.knots = NULL;
  sv_dis_mode = *display_mode;

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

  if(ed_props & EMED_NO_DISPLAY) goto wrapup;
  


  if(ed_props & EMED_TANGENT)
   {
     inquire_only=1;
     turn_on=1; /* won't be used */
     GRdv_tangent_edge_display(inquire_only,
                               turn_on,
                              &display_on);
     if(!display_on)
      {

       /*
        * we know that ed_id is the top edge
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
         goto wrapup;          /* if this edge is tangent and tangent edge
                                * display is toggled off, just exit
                                */
      }

   }


  if((ed_props & EMED_SEAM) && (ed_props & EMED_TANGENT) && sp_info)
    if(sp_info->gragad->flags & DP_NO_RULE_LINES) goto wrapup;

  if((display_flag == EMS_NONSUBORDINATE_EDGE) &&
     (ed_props & EMED_SUBORDINATE)) goto wrapup;

  if((display_flag == EMS_NONNATURAL_EDGE) && (ed_props & EMED_NATURAL))
    goto wrapup;

  /* block */
  {
    IGRboolean              edge_display_performed = FALSE;
    struct IGRaltdisplay    altsymb;

    struct IGRpointset      pt_set;
    struct IGResps          ps_attr;
    struct IGResbc          bc_attr;
    struct DPele_header     local_sf_ele_header, local_ele_header,
                            *display_ele_header = NULL;
    struct GRsymbology      symb;
    struct IGResqbs         bsqsurf;
    IGRpoint                xyz_pt;
    GRrange                 range;
    IGRdouble               curve_bdrys[4];

    /*
     * Make shure we have the surface element header
     */
    if(! surface_ele_header)
    {
      struct GRid         srf_id;
      union IGRele_attr   ele_spec_att;

      surface_ele_header = &local_sf_ele_header;
      ele_spec_att.bsqsurf = &bsqsurf;

      /*
       * get the surface info, I am a part of
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
                    &mdenv_info, NULL, surface_ele_header, range,
                    &symb.display_attr, ele_spec_att, NULL),
                    targetid = srf_id.objid);
      if(! (1 & *EMmsg & sts)) goto wrapup;
    }

    switch (display_flag)
    {
      case EMS_EDGE_W_VERTICES:
      case EMS_NONSUBORDINATE_EDGE:
      case EMS_NONNATURAL_EDGE:
      case EMS_WHL_EDGE:        /* display  the edge */

        if(ed_props & EMED_MSCEXISTS && sp_info && !ASbroadcast_in_progress)
        {
          msg_loc = EMS_S_Success;

          sts = om$send(msg = message EMSboundary.EMgetxyzobj(&msg_loc,
                                                  EMSlcopt_existingmsc,
                                                  NULL, NULL, NULL,
                                                  NULL, NULL,
                                                  OM_Gw_current_OS, &MSCid),
                        targetid = my_id);

          if ((1 & sts & msg_loc) &&
              (msg_loc != EMS_I_NotFound))
            {
            struct GRsymbology elem_symb;
            GRobjid srf_objid;

            altsymb.color = &surface_ele_header->dis_att->color;
            altsymb.weight = &surface_ele_header->dis_att->weight;
            altsymb.style = &surface_ele_header->dis_att->style;

            /* get the MSC's level to see if it is on a level that is being
             * displayed; if not, get the level of edge's surface (which must
             * be displayable since the display message got this far) and
             * update the level of the MSC; this is necessary in case the
             * edge's suface's level changed while the edge's loop was
             * inactive (TR#119311570)
             */

            sts = om$send(msg = message GRvg.GRgetsymb(&msg_loc,
                                                       &elem_symb),
                          targetid = MSCid);

            if ((1 & sts & msg_loc) &&
                (! DPlevel_on(elem_symb.level, sp_info)))
            {
              sts = om$send(msg = message EMSboundary.EMgetsurface_info
                                                (&msg_loc, &srf_objid, NULL),
                            targetid = ed_id);

              if (1 & sts & msg_loc)
              {
                sts = om$send(msg = message GRvg.GRgetsymb(&msg_loc,
                                                           &elem_symb),
                              targetid = srf_objid);

                if (1 & sts & msg_loc)
                {
                  om$send(msg = message GRvg.GRchglevel(&msg_loc,
                                                        &elem_symb.level),
                          targetid = MSCid);
                }
              }
            }

            sts = om$send(msg = message GRgraphics.GRdisyourself (&msg_loc,
                   mx_type, matrix, display_mode, &altsymb, sp_info, NULL),
                   targetid = MSCid);
            if (!EMSerror (sts & msg_loc))
              edge_display_performed = TRUE;
            else
              sts = OM_S_SUCCESS;
            }
        }

        if (!edge_display_performed)
        {
          /*
           * Get the edge geometry
           */
          sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(EMmsg, NULL,
                        NULL, surface_ele_header->geometry.bspsurf,0,
                        MAXINT, me->ed_props & EMED_REVERSED, NULL,
                        &curve_geom), targetid = my_id);
          if(! (1 & *EMmsg & sts)) goto wrapup;

          if(partinfo &&
             (partinfo->edid != my_id))
          {
            void          EFpartinfo_to_cvbnd();

            /*
             * Warning: Use of this function requires that EMSlinedge
             * overrides EMdisplay.
             */
            curve_geom.bdrys = curve_bdrys;
            EFpartinfo_to_cvbnd(EMmsg, partinfo, &curve_geom);
            if(! (1 & *EMmsg & sts)) goto wrapup;
          }

          bc_attr.is_polydis = FALSE;
          bc_attr.is_curvedis = TRUE;

          symb.display_attr = *surface_ele_header->dis_att;

          display_ele_header = &local_ele_header;

          dp$build_dis_buffer (
              buffer = display_ele_header,
              type = IGRBC, /* type of abstract geom. */
              range = surface_ele_header->range,
              level = surface_ele_header->level,
              display_att = &symb.display_attr,
              ele_spec_att = &bc_attr,
              geometry = &curve_geom
          );
        }
        break;

      case EMS_EDGE_BEG_PT:
      case EMS_EDGE_END_PT:       /* display a vertex */
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
        }

        symb.display_attr = *surface_ele_header->dis_att;
        symb.display_attr.weight = 5;

        ps_attr.is_connected = FALSE;

        pt_set.num_points = 1;
        pt_set.points = xyz_pt;

        display_ele_header = &local_ele_header;

        dp$build_dis_buffer (
            buffer = display_ele_header,
            type = IGRPS,
            display_att = &symb.display_attr,
            ele_spec_att = &ps_attr,
            geometry = &pt_set,
        );

        break;

      default:
        *EMmsg = EMS_E_InvalidArg;
        goto wrapup;

    }  /* end switch */

      /* 
       * display
       */
      if (! edge_display_performed)
      {
        if(sp_info)
        {
          dp$dispelem(msg = EMmsg, buffer = display_ele_header,
                      mode = *display_mode, dp_info = sp_info);
        }
        else
        {
          struct GRid moduleGRid;

          ex$get_cur_mod(id = &moduleGRid.objid, 
                         osnum = &moduleGRid.osnum);

          dp$display(msg = EMmsg, osnum = moduleGRid.osnum,
                     objid = moduleGRid.objid, mode = *display_mode,
                     buffer = display_ele_header);
        }
      }

/*
 * This code will be used for solid edges
 *
      display_ele_header->dis_att->style = 0;
    }
 */
    if(! (1 & *EMmsg)) goto wrapup;

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

  } /* if display flag matches edge properties */

wrapup:
  /*
   * Free the curve poles, weights and knots
   */
  if(curve_geom.poles) om$dealloc(ptr = curve_geom.poles);
  if(curve_geom.weights) om$dealloc(ptr = curve_geom.weights);
  if(curve_geom.knots) om$dealloc(ptr = curve_geom.knots);

  *display_mode = sv_dis_mode;

  EMSmsgReport(sts, "EMSedge.EMdisplay", FALSE);
  EMSmsgReport(*EMmsg, "EMSedge.EMdisplay", FALSE);
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

void EFpartinfo_to_cvbnd(EMmsg, partinfo, curve)

IGRlong                 *EMmsg;
struct EMSpartedinfo    *partinfo;
struct IGRbsp_curve     *curve;

/*
Notes

    Curve->bdrys must point to an array of at least four doubles;

    This function does not work for partinfo on a linear edge.
*/

{
  IGRboolean    crossing;
  IGRint        bdry_index = 0;
  IGRdouble     region[2];

  *EMmsg = EMS_S_Success;

  if(partinfo->edbdry[0].param < partinfo->edbdry[1].param)
  {
    region[0] = partinfo->edbdry[0].param;
    region[1] = partinfo->edbdry[1].param;
    crossing = (partinfo->edprops & EMED_REVERSED) ? TRUE : FALSE;
  }
  else
  {
    region[0] = partinfo->edbdry[1].param;
    region[1] = partinfo->edbdry[0].param;
    crossing = (partinfo->edprops & EMED_REVERSED) ? FALSE : TRUE;
  }

  if(crossing)
  {
    /*
     * Part edge is crossing from 1.0 to 0.0: Partinfo reflects
     * the boundary
     */
    curve->num_boundaries = 1;
    curve->bdrys[0] = region[0];
    curve->bdrys[1] = region[1];
  }
  else /* not crossing */
  {
    /*
     * Partinfo reflects the active portion.
     */
    curve->num_boundaries = 0;
    if(region[0] ISNT 0.0)
    {
      curve->num_boundaries ++;
      curve->bdrys[bdry_index ++] = 0.0;
      curve->bdrys[bdry_index ++] = region[0];
    }
    if(region[1] ISNT 1.0)
    {
      curve->num_boundaries ++;
      curve->bdrys[bdry_index ++] = region[1];
      curve->bdrys[bdry_index ++] = 1.0;
    }
  }

  return;
}

end implementation EMSedge;
