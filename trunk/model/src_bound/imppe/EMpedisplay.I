/* ###################   APOGEE COMPILED   ################## */
/*
History
        ??      ??              Creation.
        SM      03-Jan-90       Check MSCEXISTS property out of the
                                partedgeinfo instead of instance data.
                                Was causing problems for nested
                                partedges where top partedge had no MSC
                                while intermediate partedge did.
   Jack 14 May  91  If this edge is marked tangent, and tangent edge 
                    display is turned off, then don't display. 
   Jack 15 Sept 92  Exit if tangent and tangent edges are supressed.
                    Also, if this is both an EMSgraloop edge and a 
                    tan edge, and tan edge display is supressed, 
                    don't supress.
   Jack 22 Sept 92  Since we know this is an EMSpartedge, we can get the point
                    on the edge to set par from my boundary instance data.
   Jack 24 Sept 92  if gettopedge returns NULL_OBJID, I am top edge.
   Jack 10 Dec  92  Removed EMgettopedge call.  The top edge is either
                    partinfo->ed_id or my_id.  Also, moved code to 
                    see if I am in a graphic loop to be done only
                    if this edge is tangent and tangent edges are supressed.
   WBC  29 Apr  93  If the mode to create model space counterparts (MSCs) is
                    on and this edge is not a common subordinate edge, create
                    an MSC for this edge.
   WBC  21 Sept 93  Only create an MSC for this edge if the edge is being
                    displayed (not erased).
   WBC  15 Oct  93  Don't create an MSC for this edge if an associative
                    broadcast is in progress.
   WBC  07 Jul  94  Removed code to create MSCs; we are no longer
                    trying to create these on the fly.  Users must
                    explicitly use the command "Enable Read-Only Detailing"
                    to create EMSpointers and MSCs for read-only detailing
                    (TRs 119420413 and 119419323).
*/
class implementation EMSpartedge;

# include "msdef.h"
# include "OMmacros.h"
# include "emsmacros.h"
# include "dperr.h"         /* DPSTOPDRAW   */
# include "dpdef.h"
# include "grdpbdef.h"
# include "grdpbmacros.h"

extern void GRdv_tangent_edge_display();

extern OMuword    OPP_EMSgraloop_class_id;

method EMdisplay(IGRlong *EMmsg; struct DPele_header *ele_header;
                 IGRshort *mx_type;IGRmatrix matrix;enum GRdpmode *mode;
                 struct DP_information *sp_info; IGRshort display_flag;
                 struct EMSpartedinfo *partinfo)
{
  extern IGRboolean     ASbroadcast_in_progress;

  IGRint        inquire_only,
                turn_on,
                display_on;
  enum GRdpmode sv_dis_mode;
  GRobjid               topedge=NULL_OBJID;
  OMuint                count,
                        c_count=0;  
  OM_S_OBJECT_LINKAGE  *channel_objects = NULL;
  IGRint                cnt=0,
                        graloop_edge=0;
  OMuword               my_classid;
  OM_S_CHANSELECT       chan_to_owner;


  IGRlong sts = OM_S_SUCCESS;

  *EMmsg = EMS_S_Success;

   sv_dis_mode = *mode;

  if(me->ed_props & EMED_NO_DISPLAY) goto wrapup;

  if((me->ed_props & EMED_SEAM) && (me->ed_props & EMED_TANGENT) && sp_info)
    if(sp_info->gragad->flags & DP_NO_RULE_LINES) goto wrapup;

  /* block */
  {
    struct EMSpartedinfo  mypartinfo;

    if (!partinfo)
    {
      /*
       * Get my partinfo
       */
      EMput_partinfo (mypartinfo);
      partinfo = &mypartinfo;
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
         * we know that partinfo is the top edge id
         */ 
         topedge = partinfo->edid;
      
        /*
         * determine if this edge is in a graphic loop.  if so,
         * don't suppress display 
         */

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
          goto wrapup;  /* if this edge is tangent and tangent edge display 
                         * is toggled off, just exit
                         */
      }

   }



    if (partinfo->edprops & EMED_MSCEXISTS)
    {
      sts = om$send(msg = message EMSedge.EMdisplay(EMmsg, ele_header,
                    mx_type, matrix, mode, sp_info, display_flag,
                    partinfo), mode = OM_e_wrt_message, targetid = my_id);
    }
    else
    {
      OM_S_CHANSELECT       chan_to_edge;

      /*
       * Pass the message on to my edge.
       */
      EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_edge);
      sts = om$send(msg = message EMSedge.EMdisplay(EMmsg, ele_header,
                        mx_type,matrix,mode,sp_info,display_flag,partinfo),
                        p_chanselect = &chan_to_edge);
    }
  }

wrapup:
  /*
   * Wrapup
   */
  EMSmsgReport(sts, "EMSpartedge.EMdisplay", FALSE);
  EMSmsgReport(*EMmsg, "EMSpartedge.EMdisplay", FALSE);

  *mode = sv_dis_mode;

  if(*EMmsg IS DPSTOPDRAW)
  {
    sts = OM_I_STOP_SENDING;
  }
  else
  {
    *EMmsg = EMS_S_Success;
    sts = OM_S_SUCCESS;
  }
  return(sts);
}

end implementation EMSpartedge;
