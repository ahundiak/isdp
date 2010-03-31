/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSdprquery.h"

#define PAIR_BUFF_INCR 2
#define BUFF_INCR      4

extern OMuword OPP_EMSsubbs_class_id;

from EMSedge import EMgetsurface_info;

method EMgetInfoAboutComponents(IGRlong *EMmsg; IGRint *comp_info_count;
                                struct EMScomponent_info **comp_info)
/*
Description
    This message returns an array of information containing surface ids,
    their common edge surface ids, and the common edge pair ids for each
    common edge surface. 

Notes
    See $EMS/include/EMSdprquery.h for the declaration of EMScomponent_info.

    The user should free the EMScomponent_info structure by calling:

    void EFfreeComponentInfoMem(num_comp_info, comp_info)
        IGRint num_comp_info;              -Size of EMScomponent_info array.
        struct EMScomponent_info *comp_info;  -EMScomponent_info array.

Return Values
    EMmsg - EMS_S_Success if all is well.

History
    DLB 09/21/88 Creation.
*/
{
 IGRlong             OM_stat=OM_S_SUCCESS;
 OMuint              cnt;
 IGRint              i, j, k, edge_index;
 IGRint              edge_count=0, edge_buff_size=0;
 IGRint              surf_edge_buff_size=0, surf_edge_count=0;
 IGRint              *num_edge_list=NULL;
 IGRint              current_surf_num_edges, current_num_adjoin_info;
 IGRint              current_pair_count, comp_count=0;
 GRobjid             current_adjoining_surf_id;
 GRobjid             *surf_list=NULL;
 struct EMSadjoin_info    *current_adjoin_info, *dup_adjoin_info; 
 struct EMScomponent_info *current_comp_info;
 struct GRid         *edge_list=NULL, *comp_list=NULL, my_GRid;
 OM_S_CHANSELECT     to_common_edge;
 OM_S_OBJECT_LINKAGE object_linkage;


 *EMmsg = EMS_S_Success;

 /*Get all surfaces and all edges of each surface that have adjoining 
  * surfaces.
  */
 *comp_info_count = 0;
 *comp_info = NULL;

 edge_list = NULL;
 edge_buff_size = 0;
 edge_count = 0;
 
 surf_list = NULL;
 num_edge_list = NULL;
 surf_edge_buff_size = 0;
 surf_edge_count = 0;

 OM_stat = om$send(msg = message EMSsurface.EMgetedges(EMmsg,             
                         EMS_OPT_STITCHED, &edge_list, &edge_buff_size,
                         &edge_count, &surf_list, &num_edge_list, 
                         &surf_edge_buff_size, &surf_edge_count), 
                   targetid = my_id);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 if (surf_edge_count) 
 {
   *comp_info = (struct EMScomponent_info *) om$malloc
                (size = surf_edge_count * sizeof(struct EMScomponent_info));
   if (! *comp_info) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

   *comp_info_count = surf_edge_count;

   OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);

   edge_index = 0;
   for(i=0; i<surf_edge_count; i++) 
   {
     /*For each surface, get all ajoining surfaces and the edge pairs that
      * make the joint (there could be several pairs for one adjoining
      * surface).      
      */
     current_comp_info = &(*comp_info)[i]; 

     current_surf_num_edges = num_edge_list[i]; 

     current_comp_info->surf_id = surf_list[i];

     /*Malloc the adjoin_info array to be the size of the total number of
      * edges found.  This may be too much since the same surface may be
      * joined by multiple edge pairs but I prefer this over a realloc.
      */

     current_comp_info->num_adjoin_info = current_surf_num_edges;   
     current_comp_info->adjoin_info = NULL;

     /*This could be a single surface with no adjoining surfaces.*/
     if (! current_surf_num_edges) break; 

     current_comp_info->adjoin_info = (struct EMSadjoin_info *) om$malloc
                                      (size = current_surf_num_edges * 
                                             sizeof(struct EMSadjoin_info));
     if (! current_comp_info->adjoin_info)
     {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
 
     for(j=0; j<current_surf_num_edges; j++)
     {
       /*For each edge of the current surf get the adjoining surface id.*/

       current_adjoin_info = &current_comp_info->adjoin_info[j];

       OM_stat = om$send(msg = message EMSedge.EMgetsurface_info(EMmsg,
                               &current_adjoin_info->adjoining_surf_id,
                               NULL),
                         senderid = edge_list[edge_index].objid,
                         p_chanselect = &to_common_edge);
       if (!(1 & OM_stat & *EMmsg)) goto wrapup;                       
     
       /*Now add the known edge pair of the joint to the structure.*/

       current_adjoin_info->other_edge_pairs = NULL;      
       current_adjoin_info->num_edge_pairs = 1;
       current_adjoin_info->first_edge_pair[0]= edge_list[edge_index].objid;

       OM_stat = om$get_channel_objects(objid = edge_list[edge_index].objid,
                                        p_chanselect = &to_common_edge, 
                                        list = &object_linkage,
                                        size = 1,
                                        count = &cnt);
       if (!(1 & OM_stat)) goto wrapup;                               

       current_adjoin_info->first_edge_pair[1] = object_linkage.S_objid;

       edge_index++;
     } /*end for j*/

     /*Have got all adjoining surfaces and the edge pair that makes each
      * joint, now resolve cases of multiple edge pairs for one adjoining
      * surface. 
      */ 
     dup_adjoin_info = current_comp_info->adjoin_info;
     current_num_adjoin_info = current_comp_info->num_adjoin_info;

     for(j=0; j<current_num_adjoin_info; j++)
     {
       current_adjoining_surf_id = current_comp_info->adjoin_info[j].
                                   adjoining_surf_id;
 
       for(k=j+1; k<current_num_adjoin_info; k++)
       {
         if (current_adjoining_surf_id ==
             dup_adjoin_info[k].adjoining_surf_id) 
         {
           /*Got a duplicate surf id.*/
           current_adjoin_info = &current_comp_info->adjoin_info[j];
           current_pair_count = current_adjoin_info->num_edge_pairs;
           current_pair_count--;
           EFrealloc_if_needed(EMmsg, 
                               &current_adjoin_info->other_edge_pairs,
                               current_pair_count, PAIR_BUFF_INCR,
                               sizeof(EMSedge_pair)); 
           if (!(1 & *EMmsg)) goto wrapup;

           for(cnt=0; cnt<2; cnt++)
           {
             current_adjoin_info->other_edge_pairs[current_pair_count][cnt]=
                                  dup_adjoin_info[k].first_edge_pair[cnt];
           }             

           current_adjoin_info->num_edge_pairs++;
 
           /*Shift the adjoining info array down one effectively removing
            * the k'th entry.
            */
           if (k < current_num_adjoin_info-1)
           {
             OM_BLOCK_MOVE(&dup_adjoin_info[k+1], &dup_adjoin_info[k],
                           (current_num_adjoin_info - k - 1) * 
                           sizeof(struct EMSadjoin_info));
           }                     
           current_num_adjoin_info--;
           current_comp_info->num_adjoin_info--;
           k--;
         } /*end if*/
       } /*end for k*/
     } /*end for j*/
   } /*end for i*/
 } /*end if*/

 /*Handle the special case of disjoint or single surfaces.*/

 /*Get all the surfaces involved.*/
 if (EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,                    
                       OPP_EMSsubbs_class_id, FALSE))  
 {
   /*If I am a single surface then don't call EFgetcomponents.*/
   my_GRid.objid = my_id;              
   my_GRid.osnum = OM_Gw_current_OS;
   comp_list = &my_GRid;        /*Avoid a small malloc (see wrapup label).*/
   comp_count = 1;
 }
 else
 {
   EFgetcomponents(EMmsg, my_id, my_id, OM_Gw_current_OS, &comp_count,
                   &comp_list); 
   if (!(1 & *EMmsg)) goto wrapup; 
 }

 if (! comp_count) {*EMmsg = EMS_E_InvalidSend; goto wrapup;} 

 if (! *comp_info_count)
 {
   /*There are no components previously processed, so allocate the structure
    * and move the disjoint one(s) into it.
    */
   *comp_info = (struct EMScomponent_info *) om$malloc
                (size = comp_count * sizeof(struct EMScomponent_info));
   if (! *comp_info) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

   *comp_info_count = comp_count;

   for(i=0; i<comp_count; i++) 
   {
     /*Fill the EMScomponent_info structure.*/
     current_comp_info = &(*comp_info)[i]; 

     current_comp_info->surf_id = comp_list[i].objid;
     current_comp_info->num_adjoin_info = 0;
     current_comp_info->adjoin_info = NULL;
   } /*end for i*/
 } /*end if*/
 else
 {
   /*See if there are any surfaces in the comp_list array that are not in
    * the comp_info array.  If so, then these surfaces are the disjoint
    * ones and must be added to the comp_list array.
    */
   IGRint beginning_comp_info_count, comp_info_array_size;
   GRobjid current_comp_list_surf_id;


   comp_info_array_size = beginning_comp_info_count = *comp_info_count;

   for(i=0; i<comp_count; i++)
   {
     current_comp_list_surf_id = comp_list[i].objid;

     current_comp_info = *comp_info; 

     for (j=0; j<beginning_comp_info_count; j++)
     {
       if (current_comp_list_surf_id == current_comp_info[j].surf_id) break;
     }

     if (j == beginning_comp_info_count)
     {
       /*Got one.*/
       if (comp_info_array_size <= *comp_info_count)
       {
         /*Realloc the comp_info array.*/
         *comp_info = (struct EMScomponent_info *) om$realloc
                      (ptr = (char *) (*comp_info), 
                       size = (comp_info_array_size + BUFF_INCR) *
                              sizeof(struct EMScomponent_info));
         if (! *comp_info) 
         {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

         comp_info_array_size += BUFF_INCR;
       } /*end if*/                   

       current_comp_info = &(*comp_info)[*comp_info_count];
        
       current_comp_info->surf_id = current_comp_list_surf_id;
       current_comp_info->num_adjoin_info = 0;
       current_comp_info->adjoin_info = NULL;
       (*comp_info_count)++;
     } /*end if*/
   } /*end for i*/
 } /*end else*/

 wrapup:
   if (comp_list && comp_count > 1) om$dealloc(ptr = comp_list);
   if (edge_list) om$dealloc(ptr = edge_list);
   if (surf_list) om$dealloc(ptr = surf_list);
   if (num_edge_list) om$dealloc(ptr = num_edge_list);
   EMWRAPUP(*EMmsg, OM_stat, "In EMSsurface.EMgetInfoAboutComponents")
   return (OM_stat);
}


void EFfreeComponentInfoMem(num_comp_info, comp_info)
IGRint num_comp_info;
struct EMScomponent_info *comp_info;
{
  IGRint i, j, k;

  for(i=0; i<num_comp_info; i++)
  {
    for(j=0; j<comp_info[i].num_adjoin_info; j++)
    {
      if (comp_info[i].adjoin_info[j].num_edge_pairs > 1)
        om$dealloc(ptr = comp_info[i].adjoin_info[j].other_edge_pairs);
    }
    om$dealloc(ptr = comp_info[i].adjoin_info);    
  } 
  om$dealloc(ptr = comp_info);
}
end implementation EMSsurface;
