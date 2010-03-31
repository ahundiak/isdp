/* 
Non manifold interface for EMSsurface.EMgetedges 
*/
class implementation NMnonmani;

#include "OMmacros.h"

extern OMuword OPP_GRowner_class_id, OPP_NMedflp_class_id, 
	       OPP_NMnonmanigm_class_id;

#define StaticBuf 10
#define SfInc	3
#define EdInc	10

from NMfeaturelp import NMget_nesting_parent;
from EMSsurface import EMgetedges;
from EMSboundary import EMget_edges;
from NMnonmanigm import NMget_number_components, NMget_components;

IGRint NMgetedges(EMmsg, option, edges, buf_size, num_edges, surf_list,
		  numed_list, list_size, num_in_list, sfid, nmquery_opt)
IGRlong		*EMmsg;
IGRlong		option;
struct GRid	**edges;
IGRint		*buf_size, *num_edges;
GRobjid		**surf_list;
IGRint		**numed_list, *list_size, *num_in_list;
struct GRid	*sfid;
unsigned int nmquery_opt;
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			num_comps = 0, count = 0, num_flps = 0, 
			num_flp_edges = 0, flp_edges_bufsize = 0, j, i, m, 
			num_thiscomp_edges = 0, num_before = 0, 
			tmpedbufsize = 0;
 struct GRid		*comps = NULL, compsbuf[StaticBuf], *flps = NULL, 
			*flp_edges = NULL, *tmped = NULL, tmpedbuf[StaticBuf];
 struct GRmd_env	env;


 *EMmsg = EMS_S_Success;
 tmped = tmpedbuf;
 tmpedbufsize = StaticBuf;

 EMidmatrix(EMmsg, &env.md_env.matrix_type, env.md_env.matrix);
 env.md_id.objid = NULL_OBJID;
 env.md_id.osnum = sfid->osnum;

 /* If the sfid is a composite, break it down into its leaf components and
    start getting edges from each.
 */
 if(EFisAncestryValid(EMmsg, sfid->objid, sfid->osnum, 
    OPP_GRowner_class_id, FALSE)) 
  {
   if(EFisAncestryValid(EMmsg, sfid->objid, sfid->osnum, 
      OPP_NMnonmanigm_class_id, FALSE)) 
    sts = om$send(msg = message NMnonmanigm.NMget_number_components(EMmsg, 
	  &count), targetid = sfid->objid, targetos = sfid->osnum, 
	  senderid =NULL_OBJID);
   else
    sts = om$send(msg = message GRowner.GRget_number_components(EMmsg, &count),
	 targetid = sfid->objid, targetos = sfid->osnum, senderid =NULL_OBJID);
	
   if(!(1&*EMmsg&sts)) goto wrapup;

   EMerr_hndlr(!count, *EMmsg, EMS_E_Fail, wrapup);
   if(count > StaticBuf)  
    comps = (struct GRid *) om$malloc(size = count * sizeof(struct GRid));
   else comps = compsbuf;
   EMerr_hndlr(!comps, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   if(EFisAncestryValid(EMmsg, sfid->objid, sfid->osnum, 
      OPP_NMnonmanigm_class_id, FALSE)) 
    sts = om$send(msg = message NMnonmanigm.NMget_components(EMmsg, &env, 
	  comps, count, &num_comps, 0, MAXINT), targetid = sfid->objid, 
	  targetos = sfid->osnum, senderid = NULL_OBJID);
   else
    sts = om$send(msg = message GRowner.GRget_components(EMmsg, &env, comps, 
	  count, &num_comps, 0, MAXINT), targetid = sfid->objid, 
	  targetos = sfid->osnum, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 else
  {
   num_comps = 1;
   comps = compsbuf;
   comps[0] = *sfid;
  }

 /* Get edges from each component.
 */
 for(i=0; i<num_comps; i++)
  {
   num_before = *num_edges;
   sts = om$send(msg = message EMSsurface.EMgetedges(EMmsg, option, edges, 
         buf_size, num_edges, surf_list, numed_list, list_size, num_in_list), 
         targetid = comps[i].objid, senderid = comps[i].objid, 
         targetos = comps[i].osnum);
   if(!(1&*EMmsg&sts)) goto wrapup;
   num_thiscomp_edges = *num_edges - num_before;

   /* After getting the regular edges, we need to get the edges owned by
      NMfeaturelp objects under the surface. The options which apply to the
      regular edges will also be applied to these edges.
   */
   if(flps) om$dealloc(ptr = flps);
   flps = NULL;
   num_flps = 0;
   sts = NMget_feature_loops(EMmsg, &comps[i], &num_flps, &flps, NULL, NULL, 
	 NULL, NULL, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;

   for(j=0; j<num_flps; j++)
    {
     num_flp_edges = 0;
     sts = om$send(msg = message EMSboundary.EMget_edges(EMmsg, MAXINT, 
	   option, &flp_edges, &flp_edges_bufsize, &num_flp_edges), 
	   targetid = flps[j].objid, targetos = flps[j].osnum, 
	   senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EMerr_hndlr(!num_flp_edges, *EMmsg, EMS_E_Fail, wrapup);

     if(*buf_size < (*num_edges + num_flp_edges))
      {
       if(*edges)
	*edges = (struct GRid *) om$realloc(ptr = (IGRchar *) *edges, size = 
		   (*num_edges + num_flp_edges + EdInc) * sizeof(struct GRid));
       else 
	*edges = (struct GRid *) om$malloc(size = (num_flp_edges + EdInc)
		    * sizeof(struct GRid));
       EMerr_hndlr(!(*edges), *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       *buf_size = *num_edges + num_flp_edges + EdInc;
      }

     /* If this is a NMedflp, then its edges replace a regular edge contributed
	by this component. If this is a NMfeaturelp, add its edges to
	the edges contributed by this component.
     */

     if(EFisAncestryValid(EMmsg, flps[j].objid, flps[j].osnum, 
	OPP_NMedflp_class_id, FALSE))
      {
       GRobjid region_edge = NULL_OBJID;
       IGRint edidx = 0;
       IGRboolean found = FALSE;
       IGRint	new_num_thiscomp_edges = 0;

       sts = om$send(msg = message NMfeaturelp.NMget_nesting_parent(EMmsg, 
	     &region_edge, TRUE), targetid = flps[j].objid, 
	     targetos = flps[j].osnum, senderid = NULL_OBJID);
       if(!(1&*EMmsg&sts)) goto wrapup;

       /* Find the edge in the list and replace it with the new edges.
       */
       for(m=num_before; m<*num_edges; m++)
        {
 	 if(IF_EQ_OBJID(region_edge, (*edges)[m].objid))
	  {
	   found = TRUE;
	   break;
	  }
	 edidx++;
	}
       EMerr_hndlr(!found, *EMmsg, EMS_E_Fail, wrapup);
       if(tmpedbufsize < num_thiscomp_edges)
        {
	 if(tmped != tmpedbuf)
	  tmped = (struct GRid *) om$realloc(ptr = (IGRchar *) tmped, size = 
		   num_thiscomp_edges * sizeof(struct GRid));
	 else tmped = (struct GRid *) om$malloc(size = num_thiscomp_edges
		  * sizeof(struct GRid));
	 EMerr_hndlr(!tmped, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
	 tmpedbufsize = num_thiscomp_edges;
        }
       
       OM_BLOCK_MOVE(&(*edges)[num_before], tmped, num_thiscomp_edges * 
	sizeof(struct GRid));
	
       if(edidx)
  	{
         OM_BLOCK_MOVE(tmped, &(*edges)[num_before], edidx *
			sizeof(struct GRid));
         new_num_thiscomp_edges = edidx;
        }
 
       OM_BLOCK_MOVE(flp_edges, &(*edges)[num_before + new_num_thiscomp_edges],
	             num_flp_edges * sizeof(struct GRid));
       new_num_thiscomp_edges += num_flp_edges;
       (*num_edges) += (num_flp_edges - 1);

       if(edidx < (num_thiscomp_edges - 1))
        {
         OM_BLOCK_MOVE(&tmped[edidx+1], 
	  &(*edges)[num_before+new_num_thiscomp_edges], 
	  (num_thiscomp_edges - 1 - edidx) * sizeof(struct GRid));
         new_num_thiscomp_edges += (num_thiscomp_edges - 1 - edidx);
        }
       num_thiscomp_edges = new_num_thiscomp_edges;


       /* Update the surf_list
       */
       if(surf_list)
	{
         EMerr_hndlr(!IF_EQ_OBJID(comps[i].objid,
         (*surf_list)[*num_in_list - 1]), *EMmsg, EMS_E_Fail, wrapup);
         if(numed_list) (*numed_list)[*num_in_list - 1] = num_thiscomp_edges;
	}
	
      } /* if NMedflp */
     else
      {
       OM_BLOCK_MOVE(flp_edges, &(*edges)[*num_edges], num_flp_edges *
			sizeof(struct GRid));
       (*num_edges) += num_flp_edges;
       if(surf_list)     
        {
         if(num_thiscomp_edges)
          {
	   EMerr_hndlr(!IF_EQ_OBJID(comps[i].objid,
	   (*surf_list)[*num_in_list - 1]), *EMmsg, EMS_E_Fail, wrapup);
	   if(numed_list) (*numed_list)[*num_in_list - 1] += num_flp_edges;
	   num_thiscomp_edges += num_flp_edges;
          }
         else
          {
	   if( *list_size < (*num_in_list + 1))
	    {
	     if(*surf_list)
	      {
	       *surf_list = (GRobjid *) om$realloc(ptr = (IGRchar *) *surf_list, 
			    size = (*list_size + SfInc) * sizeof(GRobjid));
               EMerr_hndlr (!(*surf_list), *EMmsg, EMS_E_NoDynamicMemory,wrapup);
               if(numed_list)
                {
                 *numed_list = (IGRint  *) om$realloc (ptr = (IGRchar *)
*numed_list, 
		               size = (*list_size + SfInc) * sizeof(IGRint));
                 EMerr_hndlr (!(*numed_list), *EMmsg, EMS_E_NoDynamicMemory,
			      wrapup);
                }
	      }
	     else
	      {
     	       *surf_list = (GRobjid *) om$malloc (size = 
		             SfInc * sizeof (GRobjid));
               EMerr_hndlr (!(*surf_list), *EMmsg, EMS_E_NoDynamicMemory,wrapup);
               if(numed_list)
     	        {
       	         *numed_list = (IGRint *) om$malloc (size =
			       SfInc * sizeof (IGRint));
                 EMerr_hndlr (!(*numed_list), *EMmsg, EMS_E_NoDynamicMemory,
			      wrapup);

       	        }
	      }
	     *list_size += SfInc;
	
	    } /* if( *list_size < (*num_in_list + 1)) */

           (*surf_list)[*num_in_list] = comps[i].objid;
           if(numed_list) (*numed_list)[*num_in_list] = num_flp_edges;
           (*num_in_list)++;
	   num_thiscomp_edges = num_flp_edges;
	
          }/* else for - if(num_thiscomp_edges) */

        } /* if(surf_list) */

      } /* else for if NMedflp */

    } /* for(j=0; j<num_flps; j++) */

  } /* for(i=0; i<num_comps; i++) */

wrapup:
if(flps) om$dealloc(ptr = flps);
if(comps && (comps != compsbuf)) om$dealloc(ptr = comps);
if(flp_edges) om$dealloc(ptr = flp_edges);
if(tmped && (tmped != tmpedbuf)) om$dealloc(ptr = tmped);
EMWRAPUP(*EMmsg, sts, "NMgetedges");
return(sts);
}
end implementation NMnonmani;
