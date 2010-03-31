/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "EMSbnddef.h"

extern OMuword OPP_EMSgencompsf_class_id;
extern OMuword OPP_EMSdpr_class_id;
extern OMuword OPP_EMSsolid_class_id;

from EMSedge import EMgetsurface_info;
from EMSdpr  import EMmake_primitive1;

method EMleavecs (IGRlong *EMmsg; 
                  struct GRmd_env *mod_info)


/*
Description

    Selectively drop out from the composite surface. The selective drop
    may create disjoint pieces, each of which is detected. If a disjoint
    piece is a collection of surfaces, it forms a new composite surface.
    If a disjoint piece is a single surface, then it is disconnected
    from the composite. If all the pieces are single surfaces, the 
    composite object is deleted.
    If the surface is dropping  out of a solid, the remainder of the solid
    becomes a general composite surface.
    If the active id is a dpr object, the tree is compressed before the 
    drop takes place. If the surface is the leaf of a surface tree, the
    selective drop just amounts to compressing the tree.


Return values 

    EMS_S_Success       if all is well.

    EMS_I_Fail          if I am not part of a composite.

Change history:
    NP         	08/25/92	Modified for ANSI compliance. Changed properties 
				variable "csmask" to IGRshort from IGRushort, since
				that is the type expected by GRvg.GRchgprops. Also
				changed "total_count" variable type to "IGRuint".
    DLB         06/01/91        Fix creator_id in topology of removed sfs and
                                those that had their composite owner changed 
                                due to disjoint cases.
    DLB         10/20/88        Added code to disconnect me if the I have 
                                no stitched edges.  Previously when this
                                happened, EMS_I_Fail was returned.
    RV          09/25/87        Creation
*/
{
 IGRlong                OM_stat;    
 IGRuint                total_count;
 IGRint                 num_st_edges = 0, st_buf_size = 0,
                        num_tr_surfs = 0, tr_buf_size = 0,
                        edg, srf;
 GRobjid                *tr_surfs = NULL;
 struct GRid            *st_edges = NULL;
 GRobjid                *adjoin_surfs = NULL;
 struct GRid            new_cs, adj_act_GRid, active_GRid, prim_GRid;
 OM_S_CHANSELECT        my_to_cpx, to_cpx, to_comps, to_common_edge;
 IGRshort          csmask = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
 IGRboolean             csaction = 1;
 OMuword                gen_classid;

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 OM_stat = om$send(msg = message EMSsubbs.EMgetactiveid(EMmsg,
                                            &active_GRid, NULL),
                        targetid = my_id);     
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
 if (my_id == active_GRid.objid) {*EMmsg = EMS_I_Fail; goto wrapup;}

 OM_stat = om$get_classid(objid = active_GRid.objid,
                          osnum = active_GRid.osnum,
                          p_classid = &gen_classid);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 OM_stat = om$is_ancestry_valid(subclassid = gen_classid,
                                superclassid = OPP_EMSdpr_class_id);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
 
 if (OM_stat == OM_S_SUCCESS)
 {
      OM_stat = om$send(msg = message EMSdpr.EMmake_primitive1(EMmsg,
                                                mod_info, &prim_GRid),
                                targetid = active_GRid.objid,
                                targetos = active_GRid.osnum);
      EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

      if (prim_GRid.objid == my_id) goto wrapup;
 }
 else
 {
      OM_stat = OM_S_SUCCESS;
      prim_GRid = active_GRid;
 }

 OM_stat = om$get_classid(objid = prim_GRid.objid,
                          osnum = prim_GRid.osnum,
                          p_classid = &gen_classid);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 OM_stat = om$is_ancestry_valid(subclassid = gen_classid,
                                superclassid = OPP_EMSsolid_class_id);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
 
 if (OM_stat == OM_S_SUCCESS)
 {
        struct GRid temp_GRid;

        OM_stat = om$construct(classid = OPP_EMSgencompsf_class_id,
                                           p_objid = &temp_GRid.objid);
        EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
        temp_GRid.osnum = prim_GRid.osnum;

        OM_stat = om$send(msg = message GRvg.GRchgprops(EMmsg,
                                              &csaction, &csmask),
                                    targetos = temp_GRid.osnum,
                                    targetid = temp_GRid.objid);
        EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

        OM_stat = om$send(msg = message EMSsurface.EMmovesurfs(EMmsg,
                                                         &temp_GRid,
                                                         mod_info),
                                        targetos = prim_GRid.osnum,
                                        targetid = prim_GRid.objid);
        EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

        prim_GRid = temp_GRid;

        OM_stat = om$send(msg = message EMSsurface.EMfix_creator_id
                                (EMmsg, NULL, prim_GRid.objid, NULL),
                          targetid = prim_GRid.objid);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 }
 else OM_stat = OM_S_SUCCESS;

 my_to_cpx.type = OM_e_addr;
 my_to_cpx.u_sel.addr = &ME.GRconnector->to_owners;

 OM_stat = EMmake_chanselect (GRconnector_to_owners, &to_cpx);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 OM_stat = om$get_channel_count(objid = prim_GRid.objid,
                                p_chanselect = &to_comps,
                                count = &total_count);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 OM_stat = om$send(msg = message EMSsubbs.EMgetedges(EMmsg,
                         EMS_OPT_STITCHED, 
                         &st_edges, &st_buf_size,
                         &num_st_edges, NULL, NULL,
                         NULL,NULL),
                   targetid = my_id);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 if (num_st_edges) /*If stmt added by DLB 10/20/88.*/
 {
   adjoin_surfs = (GRobjid *) om$malloc (size = (unsigned) 
                  (num_st_edges * sizeof (GRobjid)));
   EMerr_hndlr (!(adjoin_surfs),*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);

   for (edg=0; edg<num_st_edges; edg++)
   {
       OM_stat = om$send(msg = message EMSedge.EMgetsurface_info(EMmsg,
                                                  &adjoin_surfs[edg], NULL),
                         senderid = st_edges[edg].objid,
                         p_chanselect = &to_common_edge);
       EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
   }
 }

 OM_stat = om$send(msg = message EMSsubbs.EMdrop(EMmsg, mod_info),
                        targetid = my_id);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg, &prim_GRid),
                              senderid = prim_GRid.objid,
                              targetid = my_id);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
        
 if (!num_st_edges) goto wrapup; /*This stmt moved here 10/20/88 by DLB.*/

 total_count--;

 for (edg=0; edg<num_st_edges; edg++) 
 {
     OM_stat = om$send(msg = message EMSsubbs.EMgetactiveid(EMmsg,
                                            &adj_act_GRid, NULL),
                        targetid = adjoin_surfs[edg]);     
     EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

     if (adj_act_GRid.objid != prim_GRid.objid) continue;
     else
     {
         num_tr_surfs = 0;
         OM_stat = om$send(msg = message EMSsubbs.EMcomp_traverse(EMmsg,
                                &tr_surfs, &num_tr_surfs, &tr_buf_size),
                        targetid = adjoin_surfs[edg]);
         EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

         if (num_tr_surfs == total_count)
         {
            if (total_count == 1)
            {
               OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg,
                                       &prim_GRid),
                                 senderid = prim_GRid.objid,
                                 targetid = tr_surfs[0]);
               EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

               OM_stat = om$send(msg = message EMSsurface.EMfix_creator_id
                                       (EMmsg, NULL, tr_surfs[0], NULL),
                                 targetid = tr_surfs[0]);
               if (!(1 & OM_stat & *EMmsg)) goto wrapup;

               OM_stat = om$send(msg = message Root.delete(0),
                                   targetid = prim_GRid.objid);
               EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
            }
            break;
         }              /* no disjointness      */
         else
         {
            if (num_tr_surfs == 1)
            {
               OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg,
                                       &prim_GRid),
                                 senderid = prim_GRid.objid,
                                 targetid = tr_surfs[0]);
               EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

               OM_stat = om$send(msg = message EMSsurface.EMfix_creator_id
                                       (EMmsg, NULL, tr_surfs[0], NULL),
                                 targetid = tr_surfs[0]);
               if (!(1 & OM_stat & *EMmsg)) goto wrapup;
            }
            else
            {
                OM_stat = om$construct(classid = OPP_EMSgencompsf_class_id,
                                       p_objid = &new_cs.objid);
                EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
                new_cs.osnum = OM_Gw_current_OS;

                for(srf=0; srf<num_tr_surfs; srf++)
                {
                  OM_stat = om$send(msg = message GRconnector.GRdisconn(
                                          EMmsg, &prim_GRid),
                                    senderid = prim_GRid.objid,
                                    targetid = tr_surfs[srf]);
                  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

                  OM_stat = om$send(msg = message EMSsubbs.EMmovesurfs(
                                          EMmsg, &new_cs, mod_info),
                                    targetid = tr_surfs[srf]);
                  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
                }
                OM_stat = om$send(msg = message GRvg.GRchgprops(EMmsg,
                                        &csaction, &csmask),
                                  targetid = new_cs.objid);
                EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

                OM_stat = om$send(msg = message EMSsurface.EMfix_creator_id
                                        (EMmsg, NULL, new_cs.objid, NULL),
                                  targetid = new_cs.objid);
                if (!(1 & OM_stat & *EMmsg)) goto wrapup;
            }           /* create new composite     */
         }              /* ditch disjoint component */
         total_count-= num_tr_surfs;
     }                  /* traverse with neighbor   */
 }                      /* process  each neighbor   */

 wrapup:

  if (st_edges) om$dealloc(ptr = st_edges);
  if (tr_surfs) om$dealloc(ptr = tr_surfs);

  EMWRAPUP(*EMmsg, OM_stat, "In EMSsubbs.EMleavecs")
  return (OM_stat);
}
end  implementation EMSsubbs;
