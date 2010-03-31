/* ###################   APOGEE COMPILED   ################## */
class implementation EMSnatedge;

# include "msdef.h"         /* MSSUCC           */
# include "dpdef.h"         /* for dpmacros.h   */
# include "exmacros.h"      /* ex$get_cur_mod   */
# include "dperr.h"         /* DPSTOPDRAW       */
# include "dpmacros.h"      /* dp$...           */
# include "emsdef.h"
# include "emsmacros.h"
# include "EMSlmdef.h"
# include "EMScmacros.h"    /* EMSmsgReport     */
# include "bstypes.h"       /* BSrc             */
# include "OMmacros.h"
# include "grdpbdef.h"
# include "grdpbmacros.h"

from EMSsubbs import EMget_ele_header;

extern void GRdv_tangent_edge_display();

extern OMuword OPP_EMSrevol_class_id,
               OPP_EMSelpcone_class_id,
               OPP_EMSgraloop_class_id;

method EMdisplay(IGRlong                *EMmsg;
                 struct DPele_header    *surface_ele_header;
                 IGRshort               *mx_type;
                 IGRmatrix              matrix;
                 enum GRdpmode          *display_mode;
                 struct DP_information  *sp_info;
                 IGRshort               display_flag;
                 struct EMSpartedinfo   *partinfo)
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
    Jack 10 Dec  92  Removed EMgettopedge call.  The top edge is either
                     partinfo->edid or my_id.  Also, moved code to 
                     see if I am in a graphic loop to be done only
                     if this edge is tangent and tangent edges are supressed.
    Jack 24 Sept 92  if gettopedge returns NULL_OBJID, I am top edge.
    Jack 22 Sept 92  Initialize topedge to NULL_OBJID.
    Jack 15 Sept 92  If tangent edge, and tan edge display is supressed,
                     just exit.  Also, if this is both an EMSgraloop edge
                     and a tan edge, and tan edge display is supressed, 
                     don't supress.
    Jack 11 Aug  92  Sort the partinfo bdrys before sending them to 
                     the display macro.   
    Jack 14 May  91  If this edge is marked tangent, and tangent edge 
                     display is turned off, then don't display. 
    AIC  03 Jan 1992 Support EMS_CHECk_SEAM_TANGENCY.
    Jack 11 Dec 1991 Added check to not display if the edge is
                     degenerate.
    AIC  17 Apr 1989 Support MSC.
    AIC  02 Dec 1988 Genesis
*/
{
  extern IGRboolean     ASbroadcast_in_progress;

  IGRlong           sts = OM_S_SUCCESS;
  struct GRmdenv_info   mdenv_info;
  OMuword               sf_classid;
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
  if(me->ed_props & EMED_DEGENERATE) goto wrapup;


  if(me->location & EMS_CHECK_SEAM_TANGENCY)
  {  
     
    /* turn off the bit */
    me->location &= ~(EMS_CHECK_SEAM_TANGENCY);
 
    sts = om$get_classid( objid = surface_ele_header->tag,
                          p_classid = &sf_classid );    

    if(
       ((sts = om$is_ancestry_valid(subclassid = sf_classid, 
            superclassid = OPP_EMSrevol_class_id))== OM_S_SUCCESS) ||
       ((sts = om$is_ancestry_valid(subclassid = sf_classid, 
            superclassid = OPP_EMSelpcone_class_id))== OM_S_SUCCESS)
      ) 
       me->ed_props |= EMED_TANGENT; /* turn on the tangent edge bit */
  }


  if((me->ed_props & EMED_SEAM) && (me->ed_props & EMED_TANGENT) && sp_info)
    if(sp_info->gragad->flags & DP_NO_RULE_LINES) goto wrapup;


  /* block */
  {
    IGRushort ed_props;
    GRobjid           ed_id;

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
         * don't suppress display if tangent and tangent edge display is off.
         */
      
         /*
          * we know ed_id is the top edge id
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
         goto wrapup;          /* if this edge is tangent and tangent edge display
                                * is turned off, just exit.
                                */
      }

   }


    if((display_flag IS EMS_EDGE_BEG_PT) ||
       (display_flag IS EMS_EDGE_END_PT) ||
       (ed_props & EMED_MSCEXISTS))
    {
      sts = om$send(msg = message EMSedge.EMdisplay(
                      EMmsg,
                      surface_ele_header, 
                      mx_type,
                      matrix,
                      display_mode,
                      sp_info,
                      display_flag,
                      partinfo),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
    }
  
    else if(! ((display_flag IS EMS_NONNATURAL_EDGE) ||
               ((display_flag IS EMS_NONSUBORDINATE_EDGE) &&
                (ed_props & EMED_SUBORDINATE))))
    {
      struct DPele_header     local_sf_ele_header;
      struct GRsymbology      symb;
      struct IGResqbs         bsqsurf, ne_rlt, *save_rlt;
      GRrange                 range;
      IGRdouble               bdrys[4], *bdry_ptr;
      IGRdouble               zero = 0.0, one=1.0;
      IGRint                  num_bound;
  
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
        sts = om$send(msg = message EMSboundary.EMgetsurface_info(
                          EMmsg,
                          &srf_id.objid,
                          NULL),
                      targetid = ed_id);
        if(! (1 & *EMmsg & sts)) goto wrapup;
        srf_id.osnum = OM_Gw_current_OS;
  
        /*
         * Get the element header
         */
        mdenv_info.matrix_type = *mx_type;
        OM_BLOCK_MOVE(matrix, mdenv_info.matrix, sizeof(IGRmatrix));

        sts = om$send(msg = message EMSsubbs.EMget_ele_header(
                          EMmsg,
                          NULL,
                          &mdenv_info,
                          NULL,
                          surface_ele_header,
                          range,
                          &symb.display_attr,
                          ele_spec_att,
                          NULL),
                      targetid = srf_id.objid);
        if(! (1 & *EMmsg & sts)) goto wrapup;
      }
  
      switch (display_flag)
      {
        case EMS_EDGE_W_VERTICES:
        case EMS_NONSUBORDINATE_EDGE:
        case EMS_NONNATURAL_EDGE:
        case EMS_WHL_EDGE:        /* display  the edge */
          if(partinfo)
          {

            num_bound = 2;
            bdry_ptr = bdrys;
            bdrys[0] = 0.0;
            /*
             * need to make "shure" :^) that the boundaries are in ascending order
             * Note: since this is a natural edge, we don't need to worry about
             * the span_inx.
             */
            if(partinfo->edbdry[0].param > partinfo->edbdry[1].param) 
             {
              bdrys[1] = partinfo->edbdry[1].param;
              bdrys[2] = partinfo->edbdry[0].param;
             }
            else 
             {
              bdrys[1] = partinfo->edbdry[0].param;
              bdrys[2] = partinfo->edbdry[1].param;
             }
            bdrys[3] = 1.0;
  
          }
          else
          {
            num_bound = 0;
            bdry_ptr = NULL;
          }
  
          ne_rlt.is_polydis = FALSE;
          ne_rlt.is_surfdis = TRUE;
          ne_rlt.is_slowdis = FALSE;
          ne_rlt.type = NULL;
          ne_rlt.rules_specified = TRUE;
          ne_rlt.u_rules=0;
          ne_rlt.v_rules=0;
          ne_rlt.u_rule_values=NULL;
          ne_rlt.v_rule_values=NULL;
          ne_rlt.u_num_bound=0;
          ne_rlt.v_num_bound=0;
          ne_rlt.u_bdrys=NULL;
          ne_rlt.v_bdrys=NULL;
  
          switch(me->location & 0x3)
          {
            case 0:
              ne_rlt.u_rules = 1;
              ne_rlt.v_rules = 0;
              ne_rlt.u_rule_values = &zero;
              ne_rlt.u_num_bound = &num_bound;
              ne_rlt.u_bdrys = &bdry_ptr;
              break;
  
            case 1:
              ne_rlt.u_rules = 0;
              ne_rlt.v_rules = 1;
              ne_rlt.v_rule_values = &one;
              ne_rlt.v_num_bound = &num_bound;
              ne_rlt.v_bdrys = &bdry_ptr;
              break;
  
            case 2:
              ne_rlt.u_rules = 1;
              ne_rlt.v_rules = 0;
              ne_rlt.u_rule_values = &one;
              ne_rlt.u_num_bound = &num_bound;
              if(bdry_ptr)
              {
                IGRdouble tmp[4];
  
                OM_BLOCK_MOVE(bdry_ptr, tmp, 4 * sizeof(IGRdouble));
                bdry_ptr[0] = 1.0 - tmp[3];
                bdry_ptr[1] = 1.0 - tmp[2];
                bdry_ptr[2] = 1.0 - tmp[1];
                bdry_ptr[3] = 1.0 - tmp[0];
              }
              ne_rlt.u_bdrys = &bdry_ptr;
              break;
  
            case 3:
              ne_rlt.u_rules = 0;
              ne_rlt.v_rules = 1;
              ne_rlt.v_rule_values = &zero;
              ne_rlt.v_num_bound = &num_bound;
              if(bdry_ptr)
              {
                IGRdouble tmp[4];
  
                OM_BLOCK_MOVE(bdry_ptr, tmp, 4 * sizeof(IGRdouble));
                bdry_ptr[0] = 1.0 - tmp[3];
                bdry_ptr[1] = 1.0 - tmp[2];
                bdry_ptr[2] = 1.0 - tmp[1];
                bdry_ptr[3] = 1.0 - tmp[0];
              }
              ne_rlt.v_bdrys = &bdry_ptr;
              break;
  
            default:
              *EMmsg = EMS_E_InvalidCase;
              break;
          }
  
          break;
  
        default:
          *EMmsg = EMS_E_InvalidArg;
          goto wrapup;
  
      }  /* end switch */
  
      /*
       * Place the NE RLT in the element header.
       */
      save_rlt = surface_ele_header->ele_spec_att.bsqsurf;
      surface_ele_header->ele_spec_att.bsqsurf = &ne_rlt;
  
      /* 
       * display
       */
      if(sp_info)
      {
        dp$dispelem(msg =     EMmsg,
                    buffer =  surface_ele_header,
                    mode =    *display_mode,
                    dp_info = sp_info);
      }
      else
      {
        struct GRid moduleGRid;
  
        ex$get_cur_mod(id =       &moduleGRid.objid,
                       osnum =    &moduleGRid.osnum);
  
        dp$display(msg =          EMmsg,
                   osnum =        moduleGRid.osnum,
                   objid =        moduleGRid.objid, mode = *display_mode,
                   buffer =       surface_ele_header);
      }
  
      if(! (1 & *EMmsg)) goto wrapup;
  
      /*
       * Restore the surface rule line table.
       */
      surface_ele_header->ele_spec_att.bsqsurf = save_rlt;
  
      if((*EMmsg ISNT DPSTOPDRAW) && (display_flag IS EMS_EDGE_W_VERTICES))
      {
        sts = om$send(msg = message EMSedge.EMdisplay(
                          EMmsg,
                          surface_ele_header,
                          mx_type,
                          matrix,
                          display_mode,
                          sp_info,
                          EMS_EDGE_BEG_PT,
                          partinfo),
                      targetid = my_id);
        if(! (1 & *EMmsg & sts)) goto wrapup;
  
        if(*EMmsg ISNT DPSTOPDRAW)
        {
          sts = om$send(msg = message EMSedge.EMdisplay(
                          EMmsg,
                          surface_ele_header,
                          mx_type,
                          matrix,
                          display_mode,
                          sp_info,
                          EMS_EDGE_END_PT,
                          partinfo),
                        targetid = my_id);
        }
  
      }
  
    } /* if display flag matches edge properties */

  } /* if the edge is displayable */


wrapup:

  *display_mode = sv_dis_mode;
  
  EMSmsgReport(sts, "EMSnatedge.EMdisplay", FALSE);
  EMSmsgReport(*EMmsg, "EMSnatedge.EMdisplay", FALSE);

  if(*EMmsg IS DPSTOPDRAW) sts = OM_I_STOP_SENDING;
  else { *EMmsg = MSSUCC; sts = OM_S_SUCCESS; }

  return(sts);
}

end implementation EMSnatedge;
