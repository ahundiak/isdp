/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
# include "EMSmsgdef.h"
# include "emsmacros.h"
# include "emsdef.h"
# include "EMSbnddef.h"
# include "EMSopt.h"

# define INITIAL_SIZE   16
# define INCREMENT      8


from EMSedge import EMgetsurface_info;

method EMcomp_traverse (IGRlong *EMmsg; GRobjid **surfs;
                  IGRint  *num_surfs;
                  IGRint  *buf_size)

/*
Description

    Starting from this surface, traverse all surfaces reachable through
    common-edge connections. Each surface that is visited deposits its
    id in the list 'surfs' and increments the count 'num_surfs'.

Return values 

    EMS_S_Success is returned if all is well.

Change history:

    RV          09/25/87        Creation
    gupta       11/30/89        ignore the edges which does not have an 
                                active loop - see below
    NP		08/26/92	Modified for ANSI compliance. Added typecast in
				realloc.
*/

{
 IGRlong                OM_stat;    
 OM_S_CHANSELECT        to_common_edge;
 IGRint                 num_st_edges = 0, st_buf_size = 0,
                        edg, srf;
 struct GRid            *st_edges = NULL;
 GRobjid                adjoin_surf;
      
 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
    
 for (srf=0; srf<*num_surfs; srf++)
 {
   if ((*surfs)[srf] == my_id) goto wrapup;
 }
 
 if (! (*buf_size) | ! (*surfs))
 {
     *surfs = (GRobjid *) om$malloc (size = (unsigned) 
                (INITIAL_SIZE * sizeof (GRobjid)));
     *buf_size = INITIAL_SIZE;
     EMerr_hndlr (!(*surfs),*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
 }
 else if (! (*buf_size > *num_surfs))
 {
     (*buf_size) += INCREMENT;
     *surfs = (GRobjid *) om$realloc (ptr = (IGRchar *)*surfs, 
                size = (*buf_size) * sizeof(GRobjid));

     EMerr_hndlr (!(*surfs),*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
 }

 (*surfs)[*num_surfs] = my_id;
 (*num_surfs)++;

 OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 OM_stat = om$send(msg = message EMSsubbs.EMgetedges(EMmsg, EMS_OPT_STITCHED,
                                                &st_edges, &st_buf_size,
                                                &num_st_edges, NULL, NULL,
                                                NULL,NULL),
                        targetid = my_id);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 for (edg=0; edg<num_st_edges; edg++)
 {
     OM_stat = om$send(msg = message EMSedge.EMgetsurface_info(EMmsg,
                                                &adjoin_surf, NULL),
                        senderid = st_edges[edg].objid,
                        p_chanselect = &to_common_edge);
     EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
    
     /* this might be sending thru inactive loop hence ignore such
        edges -- gupta 11/30/89 */

     if (OM_stat == OM_I_CHAN_EMPTY)
      {
       OM_stat = OM_S_SUCCESS;
       continue;
      }

     OM_stat = om$send(msg = message EMSsubbs.EMcomp_traverse(EMmsg,
                                surfs, num_surfs, buf_size),
                        targetid = adjoin_surf);
     EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
} 

 wrapup:

  if (st_edges) om$dealloc(ptr = st_edges);

  EMWRAPUP(*EMmsg, OM_stat, "In EMSsubbs.EMcomp_traverse")
  return (OM_stat);
}
end  implementation EMSsubbs;


