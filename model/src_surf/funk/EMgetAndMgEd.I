/**

 08/14/97 : Nilesh : Creation : Given a common edge, this function identifies
                                the adjacent surfaces(if any) and the edges on
                                the adjacent surfaces which need to be merged.
                                It then calls the function, which actually 
                                performs the merging of edges.  Added for
                                handling the Unite of Tangential surfaces.
 01/08/98 : Kiran :  Modified : Code was modified to not to allow the
                                corrupt solid to be generated if the operation
                                Fails. Modified all deallocations and added
                                few, to remove the memory logically.
**/
                                 
class implementation EMSsfunitesf;

#include "OMmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "EMS.h"
#include "igr.h"
#include "gr.h"
#include "ECmsg.h"
#include "EMSbnd.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "prototypes/bsdistptpt.h"
#include "emsmacros.h"
#include "EMmergeEdges.h"

#define BUFF_INCR 8

from EMSedge import EMget_vtx_sfs;
from EMSedge import EMxyz_endpt;
from EMSedge import EMgetbcgeom;

//extern MergeEdgesOnSf();

/******** for(united surface and adjacent surfaces)
          o Get the edges to be merged

          o Merge the split edges and create a new BS edge.
           
          o Disconnect the parent edges from the loopset of the surface.

          o Connect the newly created edge to the corresponding surface loopset.       
          o Take care to handle simple Unite case with no adjacent surfaces 

********/        

IGRlong GetEdgesAndMerge(EMmsg,new_surf,construct_list,is_simple_surf,surfs,
                  ref_id,md_env,num_merge_edges, mg_edges,num_merged,conn_edges,
                  num_sort,sorted_edges)
IGRlong *EMmsg;
GRobjid new_surf;
struct GRvg_construct construct_list;
IGRboolean is_simple_surf;
GRobjid *surfs;
GRobjid ref_id;
struct GRmd_env *md_env;
IGRint  *num_merge_edges; /** No of Edges participating in Merging **/
GRobjid **mg_edges;    /** Edges participating in Merging **/
IGRint  *num_merged;      /** No of Merged Edges **/ 
GRobjid **conn_edges;     /** Merged Edges **/ 
IGRint   *num_sort;
GRobjid **sorted_edges;
{
   IGRlong           msg,sts,status,bsrc;
   IGRint            num_ed;
   IGRshort          os;
   struct GRid       *sf_edges;
   IGRint            arr_size,num_surfs1=0,num_surfs2=0;
   IGRint            num_mergedges,counter,counter1;
   GRobjid           merge_surfs[2],*surf_ids1=NULL,*surf_ids2=NULL;
   GRobjid           temp_edgeid,parent_loopid;
   GRobjid           *mgedges=NULL,merge_edges[4];
   IGRboolean        is_vtx_closed;
   IGRdouble         *start_pt=NULL,*end_pt=NULL,xyztol,sqtol;
   IGRdouble         *start_pt1=NULL,*end_pt1=NULL,*ref_pt=NULL;
   IGRdouble         dist,dist1;
   IGRboolean        found=FALSE;
   IGRint            i,j,k,num_edges,pntr,inx,index=0;
   IGRint            count1,count2,adj_surf_count;
   OM_S_CHANSELECT   to_owner,to_comps,to_ls;
   OM_S_OBJECT_LINKAGE *parent_loop,parent_loopset;
   OMuint            count,chan_index1,chan_index2,loop_count;

/*****Initialize **********/
  counter=0; 
  counter1=0;
  count=0;
  pntr=0;
  chan_index1=0;
  chan_index2=0;
  adj_surf_count=0;

  *num_merge_edges=0;
  *num_merged=0;
  *num_sort=0;
 
  *EMmsg = OM_S_SUCCESS;
  os=OM_Gw_current_OS;
  status = OM_S_SUCCESS;
  parent_loopid = NULL_OBJID;

  /****** Allocate the memory for the output *******/

  start_pt = (IGRdouble *)alloca(sizeof(IGRpoint));
  end_pt = (IGRdouble *)alloca(sizeof(IGRpoint));
  start_pt1 = (IGRdouble *)alloca(sizeof(IGRpoint));
  end_pt1 = (IGRdouble *)alloca(sizeof(IGRpoint));

  EMmake_chanselect (EMSedge_to_owner, &to_owner);
  EMmake_chanselect (EMSbd_owner_to_comps, &to_comps);
  EMmake_chanselect (EMSloop_to_outter, &to_ls);

  sts = om$send (msg = message EMSedge.EMxyz_endpt(&msg,NULL,
                                          &md_env->md_env,
                                          NULL,NULL,start_pt,end_pt,NULL),
                                          senderid = NULL_OBJID,
                                          targetid = ref_id);
  EMerr_hndlr(!(1&msg&sts), *EMmsg, EMS_E_Fail, wrapup);

  /*******Try getting adjacent edges on both sides (TRUE,FALSE) *******/

  sts = om$send (msg = message EMSedge.EMget_vtx_sfs(&msg,NULL,TRUE,&num_surfs1,
                                        &surf_ids1,&is_vtx_closed),
                                     senderid = NULL_OBJID,
                                     targetid = ref_id);
  if(!(1&msg&sts)) { sts = 1; goto wrapup;}

 sts = om$send (msg = message EMSedge.EMget_vtx_sfs(&msg,NULL,FALSE,&num_surfs2,
                                        &surf_ids2,&is_vtx_closed),
                                     senderid = NULL_OBJID,
                                     targetid = ref_id);
  EMerr_hndlr(!(1&msg&sts), *EMmsg, EMS_E_Fail, wrapup);

  /*** Handle situation in which there is a third edge running along the 
       vertex. The action here is not to merge that adjacent surface. Also
       decide 3 possibilites for not going ahead with merging.

       a] simple surfaces without adjacent surfaces.

       b] Solids having adjacent surfaces, but having a third edge running along          the verted.

       c] Corrupted solids having adjacent surfaces, no third edge along the
          verted.

   ***/

  if(num_surfs1 > 3) num_surfs1=0;
  if(num_surfs2 > 3) num_surfs2=0;

  /************ Store the desired adjacent surfaces ***********/

  for(i=0;i<2;i++)
  {
    for(j=0;j<num_surfs1;j++)
    {
      if(!(surfs[i]==surf_ids1[j]))
       {  
        found=TRUE;
        adj_surf_count++;
        break;
       } 
    }

    if(found)
    {
      merge_surfs[index]=surf_ids1[j];
      index++;
    } 

     break;

  }

  for(i=0;i<2;i++)
  {
    for(j=0;j<num_surfs2;j++)
    {
      if(!(surfs[i]==surf_ids2[j]))
       {
         found=TRUE;
         adj_surf_count++;
         break;
        }
    }

    if(found)
    {
      merge_surfs[index]=surf_ids2[j];
    }

     break;
  }

/*****
      If adj_surf_count=0, implies that this a simple surface . In this case
      merge edges (though they belong to two different surfaces), but ensure
      that the merged edge is connected to the loopset of new_surf instead of
      connecting it to the corresponding adjacent surf as we have been doing
      so far.
*****/

 if(!adj_surf_count && is_simple_surf)
 {
       /** Merge the edges on new surf **/ 
     adj_surf_count=1;
     merge_surfs[0]=new_surf;
 }

/****** Store the United surface ***************/

 for(count1=0;count1<adj_surf_count;count1++)
 {
    sf_edges = NULL;
    arr_size = 0;
    num_edges=0;
    num_ed =0;
    inx=0;
    sts = om$send ( msg = message EMSsurface.EMgetedges ( &msg,
                    EMS_OPT_NONDEG_NONSEAM, &sf_edges, &arr_size,
                     &num_ed, NULL, NULL, NULL, NULL),
                     senderid = NULL_OBJID,
                     targetid = merge_surfs[count1]);
    EMerr_hndlr(!(1&msg&sts), *EMmsg, EMS_E_Fail, wrapup);

    ref_pt=start_pt;

    for(i=0;i<2;i++)
    {
     for(count2=0;count2<num_ed;count2++)
     {
       dist=0.0;
       dist1=0.0;
       temp_edgeid=sf_edges[count2].objid;

       sts = om$send (msg = message EMSedge.EMxyz_endpt(&msg,NULL,
                                          &md_env->md_env,
                                          NULL,NULL,start_pt1,end_pt1,NULL),
                                          senderid = NULL_OBJID,
                                          targetid = temp_edgeid);
       EMerr_hndlr(!(1&msg&sts), *EMmsg, EMS_E_Fail, wrapup); 
        
        BSEXTRACTPAR(&bsrc,BSTOLCHRDHT,xyztol);
        sqtol=(xyztol)*(xyztol);

         /***** Added the Math Call ****/

         dist = BSdistptpt(&bsrc,ref_pt,start_pt1);
         if(bsrc!=BSSUCC) goto wrapup;

         dist1 = BSdistptpt(&bsrc,ref_pt,end_pt1);
         if(bsrc!=BSSUCC) goto wrapup;
 
         if(dist < sqtol || dist1 <sqtol)
         {
          merge_edges[inx]=temp_edgeid;

   /**** Return the no of edges participating in merging and their ids ****/
    
          (*mg_edges)[counter1]=merge_edges[inx];
          inx++;
          counter1++;
         *num_merge_edges=counter1;
         }
      }
      ref_pt=end_pt;
   }
    num_edges = inx;

 /*** Handle edges connected to more than one loop ***/
 
  loop_count=0;
  sts = om$get_channel_count(osnum = OM_Gw_current_OS,
                              objid = merge_edges[0],
                              p_chanselect = &to_owner,
                              count = &loop_count);
 if(!(sts & 1)) {
                 EMWRAPUP(*EMmsg, sts, "EMgetAndMgEd channel_count");
                 goto wrapup;
                }

 parent_loop=(OM_S_OBJECT_LINKAGE *)om$malloc(
                                 size =loop_count*sizeof(OM_S_OBJECT_LINKAGE));


  sts = om$get_channel_objects(
          objid = merge_edges[0],
          p_chanselect = &to_owner,
          list = parent_loop,
          size = loop_count ,
          count = &count);
  if(!(1&sts)) goto wrapup;
  
 for(i=0;i<loop_count;i++)
 {
   parent_loopset.S_objid=NULL_OBJID;
   sts = om$get_channel_objects(
          objid = parent_loop[i].S_objid,
          p_chanselect = &to_ls,
          list = &parent_loopset,
          size = 1 ,
          count = &count);
 if(!(sts & 1)) goto wrapup;

 if(!(parent_loopset.S_objid == NULL_OBJID))
    parent_loopid = parent_loop[i].S_objid;

 }

 /** Get the indices of the edges[merge_edges[0:1] later useful for sorting  **/

 sts = om$get_index(osnum_c = OM_Gw_current_OS,
                    objid_c = parent_loopid,
                    p_chanselect = &to_comps,
                    objid = merge_edges[0],
                    indexaddr = &chan_index1);
 if(!(1&sts)) {
               EMWRAPUP(*EMmsg, sts, "EMgetAndMgEd In get_index");
               goto wrapup;
              }

 sts = om$get_index(osnum_c = OM_Gw_current_OS,
                    objid_c = parent_loopid,
                    p_chanselect = &to_comps,
                    objid = merge_edges[1],
                    indexaddr = &chan_index2);

if(!(1&sts)) {
               EMWRAPUP(*EMmsg, sts, "EMgetAndMgEd In get_index");
               goto wrapup;
              }

  sts = MergeEdgesOnSf(&msg,new_surf,construct_list,is_simple_surf,merge_edges, 
                       num_edges, md_env,&num_mergedges,&mgedges);
  if(!(1&sts)) {
                EMWRAPUP(*EMmsg, sts, "EMgetAndMgEd MergeEdgesOnSf ");
                goto wrapup;
               }

 /** Return the no. of Merged edges, Merged Edges and their corresponding 
     Merging edges which went for merging in the sorted order based on the
     index of the edges participating in the process of merging **/

  for(k=0;k<num_mergedges;k++)
  {
      (*conn_edges)[counter]=mgedges[k];
      counter++;
  }

  *num_merged = counter;

    /** Return the sorted list of edges which include both merged and 
        merging edges as an output **/

   for(k=0;k<num_mergedges;k++)
   {
     if(chan_index1 < chan_index2)
     {
       (*sorted_edges)[pntr] = mgedges[k];
       (*sorted_edges)[pntr+1] = merge_edges[0];
       (*sorted_edges)[pntr+2] = merge_edges[1];
     }
     else
     {
       (*sorted_edges)[pntr] = mgedges[k];
       (*sorted_edges)[pntr+1] = merge_edges[1];
       (*sorted_edges)[pntr+2] = merge_edges[0];
     }

     pntr = pntr+3;
     *num_sort=pntr;

   } 

   if(parent_loop)om$dealloc(ptr=parent_loop);

 }

wrapup:

 if(!(1&sts)) EMWRAPUP(*EMmsg, sts, "In EMgetAndMgEd");
 return(sts);

}

end implementation EMSsfunitesf;
