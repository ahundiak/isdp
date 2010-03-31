/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
#include "EMSdprquery.h"  /*DPR_BUFF_INCR              */
#include "emsdef.h"       /*EMSedge_to_common_edge etc.*/
#include "EMSopt.h"       /*EMS_OPT_STITCHED           */

extern OMuword  OPP_EMSsubbs_class_id,
                OPP_EMSdpr_class_id;

from EMSedge  import EMgetsurface_info;

method EMgetCuttingPrims(IGRlong *EMmsg; 
                         GRobjid **cutting_prim_ids; 
                         IGRint *num_cutting_prim; 
                         IGRushort options)
/*
Description
    This message will return the list of primitives that cut the
    target primitive or single surface object.

Return Values
    EMmsg - EMS_S_Success if all is well.
          - EMS_E_Fail if any other failure occurred.

Notes 
    If single surface booleans or local modifications are performed on the
    state tree then then prim ids returned may not be true primitives. 
    They may, in fact, be boolean or lm class object ids.

    About parameters:
        cutting_prim_ids should be set to NULL.

        num_cutting_prim should be set to 0.

        The cutting_prim_ids array will be allocated using om$malloc and
        should be freed by om$dealloc.

        The possible options are:
            None so far (may be passed as NULL).

    Disclaimer:
        This message has been specifically written for the D & M project of
        Salvagnini Transferica.  Due to this the following restriction
        applies: 
            o This message is only supported for primitives in a pure
              boolean tree.

History
    DLB 12/01/88 Creation.
    NP  08/21/92 Modified for ANSI compliance. Changed "num_surfs" to 
                 "IGRuint".
*/
{
 IGRlong         OM_stat=OM_S_SUCCESS;
 IGRint          num_st_edges=0, st_buf_size=0, ii, jj, kk;
 IGRuint         num_surfs = 0;
 GRobjid         my_prim_id, *surf_ids=NULL, adjoin_surf, cutting_prim_id;
 OM_S_CHANSELECT to_owners, to_common_edge;
 struct GRid     *st_edges=NULL;
 IGRboolean      ima_primitive=TRUE;
 OMuword         dumosnum;



 *EMmsg = EMS_S_Success;

 EMmake_chanselect(GRconnector_to_owners, &to_owners);

 if ( EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                        OPP_EMSsubbs_class_id, FALSE) )
 {
   /*Mission: Find the primitives that cut one surface (me).*/

   ima_primitive = FALSE;

   if (! (ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP))
   {*EMmsg = EMS_E_InvalidSend; goto wrapup;}

   /*Get my owner.*/
   OM_stat = om$get_objid_at_index(object = me,
                                   p_chanselect = &to_owners,
                                   index = 0,
                                   objidaddr = &my_prim_id,
                                   osnumaddr = &dumosnum);
   if (!(1 & OM_stat)) goto wrapup;

   surf_ids = &my_id;
   num_surfs = 1;
 }                        
 else
 {
   OM_S_CHANSELECT to_comps;        /*DECL*/

   /*Mission: Find the primitives that intersect one primitive (me).*/

   my_prim_id = my_id;

   EMmake_chanselect(GRcmpowner_to_components, &to_comps);

   /*Get all my surfaces.*/
   OM_stat = om$get_channel_count(object = me,
                                  p_chanselect = &to_comps,
                                  count = &num_surfs);
   if (!(1 & OM_stat)) goto wrapup;

   surf_ids = (GRobjid *) om$malloc(size = num_surfs * sizeof(GRobjid));
   if (!surf_ids) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
   
   for(ii=0; ii<num_surfs; ii++)
   {
     OM_stat = om$get_objid_at_index(object = me,
                                     p_chanselect = &to_comps,
                                     index = ii,
                                     objidaddr = &surf_ids[ii],
                                     osnumaddr = &dumosnum);
     if (!(1 & OM_stat)) goto wrapup;                                     
   }
 }

 EMmake_chanselect(EMSedge_to_common_edge, &to_common_edge);

 for(ii=0; ii<num_surfs; ii++)
 {
   OM_stat = om$send(msg = message EMSsurface.EMgetedges(EMmsg,
                           EMS_OPT_STITCHED, &st_edges, &st_buf_size,
                           &num_st_edges, NULL, NULL, NULL, NULL),
                     targetid = surf_ids[ii]);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   for (jj=0; jj<num_st_edges; jj++)
   {
     OM_stat = om$send(msg = message EMSedge.EMgetsurface_info(EMmsg,
                             &adjoin_surf, NULL),
                       senderid = st_edges[jj].objid,
                       p_chanselect = &to_common_edge);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;

     OM_stat = om$get_objid_at_index(objid = adjoin_surf,
                                     p_chanselect = &to_owners,
                                     index = 0,
                                     objidaddr = &cutting_prim_id,
                                     osnumaddr = &dumosnum);
     if (!(1 & OM_stat)) goto wrapup;

     if (EFisAncestryValid(EMmsg, cutting_prim_id, OM_Gw_current_OS,
                           OPP_EMSdpr_class_id, FALSE))
     {
       /*The owner of the adjoining surface is a DPR.  This means that
        * the surface itself is the cutting primitive (i.e. this was a 
        * single surface boolean.
        */
       cutting_prim_id = adjoin_surf;       
     }                           

     if (cutting_prim_id != my_prim_id)
     {
       /*Got a true cutting primitive.  Now see if already have this one.*/
 
       for(kk=0; kk<(*num_cutting_prim); kk++)
       {
         if ( (*cutting_prim_ids)[kk] == cutting_prim_id) break;
       }
          
       if (kk == *num_cutting_prim)
       {
         /*Got a new cutting primitive so add it.*/
         EFrealloc_if_needed(EMmsg, cutting_prim_ids, *num_cutting_prim, 
                             DPR_BUFF_INCR, sizeof(GRobjid));
         if (!(1 & *EMmsg)) goto wrapup;
                         
         (*cutting_prim_ids)[*num_cutting_prim] = cutting_prim_id;
         (*num_cutting_prim)++;
       }     
     }
   }
   num_st_edges = 0;
 } 
 

 wrapup:
   if (surf_ids && ima_primitive) om$dealloc(ptr = surf_ids);
   if (st_edges) om$dealloc(ptr = st_edges);
   EMWRAPUP(*EMmsg, OM_stat, "In EMSsurface.EMgetCuttingPrims")
   return (OM_stat);
}
end implementation EMSsurface;
