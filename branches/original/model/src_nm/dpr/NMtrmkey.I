/*
This override is required due to the fact that, any loop added by this node
does not imply that all the edges in that loop are also added by this
node. This assumtion is true for EMSsfboolean, but for this node, some
of those edges may have been created by a NMinters node.

This node can create -
1) Loops
2) Edges (within those loops)

Keying mechanism -

for (1) 2 keys -
key[0] - the surface on which the loop was created
key[1] - the loop created

for(2) 3 keys -
key[0] - the surface on which the loop was created
key[1] - the loop in which the edge was created
key[2] - the edge created
*/
class implementation NMtrim;

#include "OMmacros.h"
#include "EMSkey.h"
#include "nm.h"

#ifndef DEBUG
#define DEBUG 0
#endif

#define EdInc 5

from EMSboundary import EMget_put_creator_id, EMget_objid;
extern OMuword OPP_EMSboundary_class_id, OPP_EMSloop_class_id;
extern OMuint OM_Gf_verbose_warning;

method EMtranslate_id_key(IGRlong *EMmsg; 
                          unsigned int options;
                          struct GRmd_env *md_env;
                          GRobjid *component_objid;
                          IGRint *key_size;
                          IGRchar **key)
{
 IGRlong		sts = OM_S_SUCCESS;
 GRobjid		creatorid, *id = NULL;
 IGRint			i, j, m, numeds = 0, chan_numeds = 0, numkey = 0;
 IGRboolean		bingo = FALSE, islp = FALSE;
 struct EMSkey		lockey[3];
 union EMSssi_table	*mod_table = NULL;
 struct EMSboolssi_table *my_info;
 OM_S_CHANSELECT	to_edges;
 GRobjid		*edges = NULL;
 IGRint			edgesbufsize = 0;
 
 *EMmsg = EMS_S_Success;
 for(i=0; i<3; i++)
  {
   lockey[i].chan_count = 0;
   lockey[i].chan_index = 0;
   lockey[i].sub_item_type = NMkey_Unknown;
  }
 EMmake_chanselect(EMSbd_owner_to_comps, &to_edges);


 if(options & EMS_OPT_KEY_FROM_ID)
  {
   if(EFisAncestryValid(EMmsg, *component_objid, OM_Gw_current_OS, 
      OPP_EMSboundary_class_id, TRUE))
    {
     sts = om$send(msg = message EMSboundary.EMget_put_creator_id(EMmsg, 
           &creatorid, FALSE), targetid = *component_objid);
     if(!(1&*EMmsg&sts)) goto wrapup;
     islp = EFisAncestryValid(EMmsg, *component_objid, OM_Gw_current_OS, 
            OPP_EMSloop_class_id, TRUE);
    }
   else
    {
     *EMmsg = EMS_E_InvalidArg;
     goto wrapup;
    }

   /* If I am not the creator, why did this message come to me? Untill I find
      out, returning an error.
   */
   EMerr_hndlr(!IF_EQ_OBJID(creatorid, my_id), *EMmsg, EMS_E_InvalidSend,
               wrapup);
   numkey = islp ? 2 : 3;

   /* We know that any element created by this node will always have
      exactly 2 or 3 key counts. So if only the size is desired, return it.
   */
   if(key_size && !key)
    {
     *key_size = numkey * sizeof(struct EMSkey);
     goto wrapup;
    }

   sts = om$send(msg = message EMSdpr.EMgetSSI (EMmsg, &mod_table),
         targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
   my_info = &mod_table->bool_info;

   lockey[0].sub_item_type = NMkey_Surface;
   lockey[0].chan_count = (unsigned short) my_info->num_surfaces;
   id = my_info->region_in_ids;
   for (i = 0; i < my_info->num_surfaces; i++)
    {
     lockey[0].chan_index = (unsigned short) i;

     lockey[1].sub_item_type = NMkey_Loop;
     lockey[1].chan_count = (unsigned short) my_info->num_regions_in[i];
     for (j = 0; j < my_info->num_regions_in[i]; j++)
      {
       lockey[1].chan_index = (unsigned short) j;
       if(islp && IF_EQ_OBJID(*component_objid, *id))
        {
 	 bingo = TRUE;
	 break;
        }

       if(islp) goto next_loop;

       /* Create a list of all the edges in this loop that were created by
	  me.
       */
       sts = om$get_channel_count(objid = *id, p_chanselect = &to_edges, 
	     count = (OMuint *) &chan_numeds);
       if(!(1&sts)) goto wrapup;
       if(chan_numeds > edgesbufsize)
        {
	 if(edges) 
	  edges = (GRobjid *) om$realloc(ptr = (IGRchar *) edges, 
		  size = (edgesbufsize + EdInc) * sizeof(GRobjid));
	 else
	  edges = (GRobjid *) om$malloc(size = EdInc * sizeof(GRobjid));
	 EMerr_hndlr(!edges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
	 edgesbufsize += EdInc;
        }
       numeds = 0;
       for(m=0; m<chan_numeds; m++)
        {
	 GRobjid edcrtid = NULL_OBJID;

         sts = om$send(msg = message EMSboundary.EMget_put_creator_id(EMmsg, 
               &edcrtid, FALSE), p_chanselect = &to_edges, 
	       senderid = *id, from = m, to = m);
         if(!(1&*EMmsg&sts)) goto wrapup;
	 if(!IF_EQ_OBJID(edcrtid, my_id)) continue;

         sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, 
               &edges[numeds++]), p_chanselect = &to_edges, 
	       senderid = *id, from = m, to = m);
         if(!(1&*EMmsg&sts)) goto wrapup;
        }

       lockey[2].sub_item_type = NMkey_CreatedEdge;
       lockey[2].chan_count = (unsigned short) numeds;
       for(m = 0; m<numeds; m++)
        {
         lockey[2].chan_index = (unsigned short) m;
         if(IF_EQ_OBJID(*component_objid, edges[m]))
          {
 	   bingo = TRUE;
	   break;
          }
        }

next_loop:
       if(bingo) break;
       id++;

      } /* for (j = 0; j < my_info->num_regions_in[i]; j++) */

     if(bingo) break;

    } /* for (i = 0; i < my_info->num_surfaces; i++) */

   EMerr_hndlr(!bingo, *EMmsg, EMS_E_Fail, wrapup);

   if(key)
    {
     struct EMSkey *locptr = NULL;

     if(!*key)
      {
       locptr = (struct EMSkey *) 
		om$malloc(size = numkey * sizeof(struct EMSkey));
       EMerr_hndlr(!locptr, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       *key = (IGRchar *) locptr;
      }
     else locptr = (struct EMSkey *) *key;
     OM_BLOCK_MOVE(lockey, locptr, numkey * sizeof(struct EMSkey));
    }
   if(key_size) *key_size = numkey * sizeof(struct EMSkey);

  } /* if(options & EMS_OPT_KEY_FROM_ID) */


 else if(options & EMS_OPT_ID_FROM_KEY)
  {
   struct EMSkey *locptr;
   IGRint numrg = 0;

   sts = om$send(msg = message EMSdpr.EMgetSSI (EMmsg, &mod_table),
         targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
   my_info = &mod_table->bool_info;
   
   *component_objid = NULL_OBJID;
   locptr = (struct EMSkey *) *key;
   numkey = (*key_size)/(sizeof(struct EMSkey));
  
   /* If the first key is not for a surface modified, or if the surface
      index coming in is greater than total number of surfaces modified
      signal a mismatch and quit.
      If there is a total count mismatch between the number of surfaces
      modified, signal a topology mismatch.
   */
   if((numkey != 2) && (numkey != 3))
    {
     if(OM_Gf_verbose_warning)
      fprintf(stderr, "NMtrim - Possible Topology Mismatch1\n");
     *EMmsg = EMS_I_Fail;
     goto wrapup;
    }

   if(locptr[0].sub_item_type == NMkey_Surface)
    {
     if( ((int)(locptr[0].chan_index) > (my_info->num_surfaces - 1)) ||
         ((int)(locptr[0].chan_count) != my_info->num_surfaces))
      {
       if(OM_Gf_verbose_warning)
        fprintf(stderr, "NMtrim - Possible Topology Mismatch2\n");
       *EMmsg = EMS_I_Fail;
       goto wrapup;
      }
    }
   else 
    {
     if(OM_Gf_verbose_warning)
      fprintf(stderr, "NMtrim - Possible Topology Mismatch3\n");
     *EMmsg = EMS_I_Fail;
     goto wrapup;
    }

   if(locptr[1].sub_item_type != NMkey_Loop)
    {
     if(OM_Gf_verbose_warning)
      fprintf(stderr, "NMtrim - Possible Topology Mismatch4\n");
     *EMmsg = EMS_I_Fail;
     goto wrapup;
    }

   numrg = my_info->num_regions_in[locptr[0].chan_index];
   if(((int)(locptr[1].chan_index) > (numrg - 1)) ||
      ((int)(locptr[1].chan_count) != numrg))
    {
     if(OM_Gf_verbose_warning)
      fprintf(stderr, "NMtrim - Possible Topology Mismatch5\n");
     *EMmsg = EMS_I_Fail;
     goto wrapup;
    }

   id = my_info->region_in_ids;
   for(i=0; i<locptr[0].chan_index; i++) 
    for(j=0; j<my_info->num_regions_in[i]; j++)
      id++;

   for(j=0; j<locptr[1].chan_index; j++) id++;

   if(numkey == 2) *component_objid = *id;
   else
    {
     /* Create a list of all the edges in this loop that were created by
	me.
     */
     sts = om$get_channel_count(objid = *id, p_chanselect = &to_edges, 
	   count = (OMuint *) &chan_numeds);
     if(!(1&sts)) goto wrapup;
     if(chan_numeds > edgesbufsize)
      {
       if(edges) 
        edges = (GRobjid *) om$realloc(ptr = (IGRchar *)edges, 
		size = (edgesbufsize + EdInc) * sizeof(GRobjid));
       else
        edges = (GRobjid *) om$malloc(size = EdInc * sizeof(GRobjid));
       EMerr_hndlr(!edges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       edgesbufsize += EdInc;
      }
     numeds = 0;
     for(m=0; m<chan_numeds; m++)
      {
       GRobjid edcrtid = NULL_OBJID;

       sts = om$send(msg = message EMSboundary.EMget_put_creator_id(EMmsg, 
             &edcrtid, FALSE), p_chanselect = &to_edges, 
	     senderid = *id, from = m, to = m);
       if(!(1&*EMmsg&sts)) goto wrapup;
       if(!IF_EQ_OBJID(edcrtid, my_id)) continue;

       sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, 
             &edges[numeds++]), p_chanselect = &to_edges, 
	     senderid = *id, from = m, to = m);
       if(!(1&*EMmsg&sts)) goto wrapup;
      }

     if(((int)(locptr[2].chan_index) > (numeds - 1)) ||
       ((int)(locptr[2].chan_count) != numeds))
      {
       if(OM_Gf_verbose_warning)
        fprintf(stderr, "NMtrim - Possible Topology Mismatch6\n");
       *EMmsg = EMS_I_Fail;
       goto wrapup;
      }
     *component_objid = edges[locptr[2].chan_index];
    }


   if(EFisAncestryValid(EMmsg, *component_objid, OM_Gw_current_OS, 
       OPP_EMSboundary_class_id, FALSE))
    {
     sts = om$send(msg = message EMSboundary.EMget_put_creator_id(EMmsg, 
           &creatorid, FALSE), targetid = *component_objid);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
   /* If I am not the creator, why did this message come to me? Untill I find
      out, returning an error.
   */
   EMerr_hndlr(!IF_EQ_OBJID(creatorid, my_id), *EMmsg, EMS_E_InvalidSend,
               wrapup);

  } /* else if(options & EMS_OPT_ID_FROM_KEY) */

 else
  *EMmsg = EMS_E_InvalidArg;
 
wrapup:
if(mod_table) om$dealloc (ptr = mod_table);
if(edges) om$dealloc(ptr = edges);
EMWRAPUP(*EMmsg, sts, "NMtrim.EMtranslate_id_key");
return(sts);
}

end implementation NMtrim;
