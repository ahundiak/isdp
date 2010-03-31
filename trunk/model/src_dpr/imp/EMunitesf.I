class implementation EMSsfunitesf;

#include "EMS.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "EMSbnd.h"
#include "emsplndef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "EMSopt.h"
#include "gr.h"
#include "EMgetAndMgEd.h"
#include "EMsfmaped.h"
#include "EMsfrewtsf.h"
#include "EMgetplngeom.h"

/*

DESCRIPTION 
 
  This method takes in the input coplanar surfaces and creates a big
plane to replace them. The common edge connections are then
transferred to the new plane.

HISTORY

  October 1991 : AMD : Creation
  07/09/1992   : AMD : Redesigned to do the creation of plane myself
                       instead of relying on EMplOfCrv.
  06/02/93     : Jack : Added dealloc of ssibuff to fix Purify memory leak.
  08/14/97     : Nilesh : Added code to handle Unite of Tangential surfaces.
  01/07/98     : Kiran  : Added code to avoid corruption of solid in case of
                          operation failure. still to implement for closed
                          surfaces.
  01/09/98     : Jaikish : Fix for TR#119800015
  01/20/98     : Kiran, Jaikish: Modified the code temporarily to avoid those
                                 cases which are not supported by math.

*/

#include "igetypedef.h"
#include "emsgeteddef.h"
#include "EMSlmdef.h"
#include "emsdef.h"

#define OUTTER 1
#define BUFF_INCR 20
#define MY_BUFF 7

from EMSedge import EMget_encompassing_edges,
                    EMdisplay;
from EMSsubbs import EMpartolbasis;
from EMSplane import EMreplace_with_new_plane,
                     EMmap_edges_on_plane;
from EMSedge import EMgetsurface_info,EMextend_geom;
from EMSgenbs import EMmerge_surfaces;

extern IGRlong EMmake_plane_from_encompassing_edges();
extern IGRlong EMmap_edge_onto_plane();
extern IGRlong EMget_outter_edge();

extern OMuword OPP_EMSsfunitesf_class_id;
extern OMuword OPP_EMSslunitesf_class_id;

method  EMmerge_coincident_surfs( 
               IGRlong                          *msg;
               struct GRvg_construct            construct_list;
               IGRushort                        options;
               struct GRid                      active_GRid;
               IGRint                           num_surfs;
               GRobjid                          *surfs;
               GRobjid                          *new_surf;
               GRobjid                          *display_ids[];
               IGRint                           *display_count)

{
 IGRlong                      sts,status;
 IGRboolean                   world,is_first_time=TRUE;
 struct EMmerge_info          *edinfo=NULL,*temp_edinfo=NULL;
 struct IGRbsp_surface        *surf=NULL;
 IGRlong                      sf_size,msg_loc,msg1;
 IGRushort                    edoptions;
 struct GRmd_env              *md_env=NULL;
 IGRint                       num_edinfo,temp_num_info,i,j;
 struct EMSpartolbasis        partolbasis;
 struct GRid                  my_GRid;
 struct EMSownercomp          *solrmsfs=NULL, *ownlist=NULL;
 IGRint                       numsolsmod, inx, inxlim,pntr,num_commedge;
 struct EMSunssi_table        *myssiinfo=NULL;
 union  EMSssi_table          *ssibuff=NULL;
 union  EMSssiSizeData        size_data;
 OM_S_CHANSELECT              to_components,set_loop,out_loops; 
 IGRboolean                   chkdisplist, do_display;
 enum GRdpmode                dpmode;
 GRobjid                      **test_surfs = NULL,ref_edge,*ref_edgeid=NULL;
 GRobjid                      *merged_edges=NULL,*merg_edges=NULL;
 GRobjid                      *sort_edges=NULL,*merged_edges1=NULL;
 GRobjid                      *merg_edges1=NULL,*sort_edges1=NULL;
 IGRint                      num_merg_edges1,num_sort1,num_merged1,crib;
 IGRint                      num_merg_edges,index,num_sort,num_merged,counter=0;
 IGRboolean                   recompute = FALSE, remap=FALSE,found;
 IGRboolean                   is_simple_surf=FALSE,corrupt_flag=FALSE;
 IGRboolean                   is_planar = TRUE,is_tangent = FALSE,merge_planar;
 IGRboolean                   avoid_merging=FALSE;
 IGRint                       vla_size,final_vla_size;
 IGRuint                      count_obj,junk_count;
 OMuword                      cls_id;

 OM_S_OBJECT_LINKAGE *loop_setids=NULL;
  *msg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  status = OM_S_SUCCESS;
  edoptions = NULL;

  numsolsmod = 0;
  num_commedge=0;
  num_merg_edges=0;
  num_merged=0;
  num_sort=0;
  temp_num_info=0;

  merge_planar=FALSE;

  ref_edgeid = (GRobjid *)om$malloc(size=MY_BUFF*sizeof(GRobjid));

  EMmake_chanselect(GRcmpowner_to_components, &to_components);
  EMmake_chanselect(EMSsubbs_to_loopset, &set_loop);
  EMmake_chanselect(EMSloopset_to_loops, &out_loops);
  md_env = construct_list.env_info;

  world = TRUE;

  do_display = options & EMS_DO_DISPLAY;
  chkdisplist = options & EMS_DONT_REDRAW;

  /* during recompute the surface may not be coplanar. In this case
     exit with a return code of severe failure */
  {
   struct EMStest_plan_group  data;

   test_surfs = (GRobjid **) om$malloc ( size = num_surfs * sizeof
                                                (GRobjid *)); 
   for ( i=0; i<num_surfs; i++)
    test_surfs[i] = &(surfs[i]);

   data.option = EMIndividual_Ids;
   data.data.sf_ids = test_surfs;
   data.num_sfs = num_surfs;
  
   sts = EMtest_planar ( msg, &data, md_env, &is_planar);
   EMomerr_hndlr (sts, ret_end, "EMtest_planar"); 

   {
       /* check if the surfaces are tangent */
       /* V.Srinivas */
       
       IGRint j;
       GRobjid *tgt_surfs=NULL;
       IGRint   num_tgt_surfs;

        for (j = 0; j < num_surfs-1; j++)
        {
         EMget_tgt_surfaces(msg,surfs[j], OM_Gw_current_OS,
                              &tgt_surfs, &num_tgt_surfs,
                              &md_env->md_env.matrix_type,
                              md_env->md_env.matrix);

         is_tangent = FALSE;
         for(i=0; i<num_tgt_surfs; ++i)
             if(tgt_surfs[i] == surfs[j+1])
                { is_tangent = TRUE; break; }
         if ( !is_tangent)
         {
          *msg = EMS_E_Fail;
          goto ret_end;
         }
     }
  }

/*
   if( !is_planar )
   {
    ex$message ( msgnumb = EMS_S_SurfIsNotCoplanar);
    sleep(2);
    *msg = EMS_E_Fail;
    goto ret_end;
   }

 */

  }
             /* Get the partolbasis */

  partolbasis.tol=0.0;
  sts = om$send (msg = message EMSsubbs.EMpartolbasis( msg,
                 &md_env->md_env.matrix_type, md_env->md_env.matrix,
                 &world, FALSE, &partolbasis.tol),
           targetid = surfs[0]);
  EMomerr_hndlr (sts, ret_end, "EMSsubbs.EMpartolbasis");

  partolbasis.in_world = TRUE;
  partolbasis.is_valid = TRUE;
  partolbasis.mattyp = &md_env->md_env.matrix_type;
  partolbasis.mat = md_env->md_env.matrix;
  
  om$get_classid(objid = my_id,
                 osnum = OM_Gw_current_OS,
                 p_classid=&cls_id);
  EMomerr_hndlr (sts, ret_end, "om$get_classid");

  if(is_planar)
  {
    /* Create a new plane and map the surface edges */

    sts = om$construct ( classid = OPP_EMSplane_class_id,
                       p_objid = new_surf );
    EMomerr_hndlr (sts, ret_end, "om$construct");

/* 
 It is assumed that Planar Simple surfaces will not be merged because
 the intention is to Help rounding succeed and rounding will not be
 done on Simple united surfaces. By simple surfaces I mean surfaces
 which do not occupy any volume in space!!!!!, ie it can have adjacent
 surfaces but do not enclose any volume. 
*/

    if((num_surfs == 2) && (!(cls_id ==OPP_EMSsfunitesf_class_id)))
                                                merge_planar=TRUE;
    
    if(merge_planar)
    {
      sts = EMget_planar_geometry(msg,num_surfs,surfs,*new_surf,construct_list);
      EMomerr_hndlr (sts, ret_end, "EMget_planar_geometry"); 
    }
  }

  if( (is_tangent && !is_planar)||(merge_planar))
  {
    struct GRlc_info *surfaces=NULL;

    if(is_tangent && !is_planar)
    {
      surfaces = (struct GRlc_info *)malloc(num_surfs*sizeof(struct GRlc_info));

      sts = om$construct ( classid = OPP_EMSgenbs_class_id,
                       p_objid = new_surf );
      EMomerr_hndlr (sts, ret_end, "om$construct"); 

      for (i=0; i< num_surfs; ++i)
      {
        surfaces[i].located_obj.objid = surfs[i];
        surfaces[i].located_obj.osnum = OM_Gw_current_OS;
        surfaces[i].module_info = *md_env;  
      }
     sts = om$send ( msg = message EMSgenbs.EMmerge_surfaces(
                           num_surfs,surfaces, &construct_list,msg),
                           targetid = *new_surf); 
     EMomerr_hndlr (sts, ret_end, "EMSgenbs.EMmerge_surfaces"); 
  }

{

 OM_S_CHANSELECT                   to_common_edge;
 IGRboolean                        surf_in_buffer;
 OM_S_OBJECT_LINKAGE               comm_edge;
 IGRuint                           edge_count,k;
 GRobjid                           srfid;

 num_edinfo = 0;
 EMmake_chanselect ( EMSedge_to_common_edge, &to_common_edge );

 for (i=0; i<num_surfs; i++)
 {
  IGRint numed = 0;
  struct GRid *sfedges = NULL;
  IGRint array_size = 0;
  OMuword class_id;
  sts = om$send ( msg = message EMSsurface.EMgetedges ( msg,
                  EMS_OPT_NONDEG_NONSEAM, &sfedges, &array_size,
                  &numed, NULL, NULL, NULL, NULL),
           senderid = NULL_OBJID,
           targetid = surfs[i]);
  EMomerr_hndlr (sts, ret_end, "EMSsurface.EMgetedges");

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

   for (j=0 ; j<numed; j++)
   {
    surf_in_buffer = FALSE;

    /* check if this edge has a common edge with the list of surfs */

    sts = om$get_channel_objects(
          objid = sfedges[j].objid,
          p_chanselect = &to_common_edge,
          list = &comm_edge,
          size = 1 ,
          count = &edge_count);
    EMomerr_hndlr (sts, ret_end, "om$get_channel_objects");
     if(edge_count)
     {
       sts = om$send ( msg = message EMSedge.EMgetsurface_info( msg, &srfid, NULL),
                senderid = NULL_OBJID,
                targetid = comm_edge.S_objid);
    EMomerr_hndlr (sts, ret_end, "EMSedge.EMgetsurface_info");

       sts = om$get_classid(objid = surfs[i],
                             osnum = OM_Gw_current_OS,
                             p_classid=&class_id);
    EMomerr_hndlr (sts, ret_end, "om$get_classid");

       for(k=0; k<num_surfs; k++)
       { 
         if( srfid == surfs[k])
         {
             surf_in_buffer = TRUE;
             ref_edgeid[num_commedge]=comm_edge.S_objid; 
             num_commedge++;
             break; 
         }
       }
     }

    if(comm_edge.S_objid)
    {
    if(surf_in_buffer) continue;

      /* Else the edge has passed the test. Now fill up
         the EMmerge_info structure */

    if (! ((num_edinfo) % BUFF_INCR))
    {
     if (!(num_edinfo))
     edinfo = (struct EMmerge_info *) om$malloc (size =
               (BUFF_INCR) * sizeof (struct EMmerge_info));

     else
      edinfo = (struct EMmerge_info *) om$realloc (ptr = (IGRchar *)(edinfo),
      size = (unsigned) (num_edinfo + BUFF_INCR) * sizeof
      (struct EMmerge_info));
      EMerr_hndlr (! edinfo , *msg, EMS_E_NoDynamicMemory, ret_end );
    }
  
    if (! ((num_edinfo) % BUFF_INCR))
    {
     if (!(num_edinfo))
     temp_edinfo = (struct EMmerge_info *) om$malloc (size =
               (BUFF_INCR) * sizeof (struct EMmerge_info));

     else
   temp_edinfo=(struct EMmerge_info *)om$realloc(ptr=(IGRchar *)(temp_edinfo),
      size = (unsigned) (num_edinfo + BUFF_INCR) * sizeof
      (struct EMmerge_info));
      EMerr_hndlr (! temp_edinfo , *msg, EMS_E_NoDynamicMemory, ret_end );
    }

    if(edge_count)
    {
     (edinfo)[num_edinfo].edge0 = sfedges[j].objid;
     (edinfo)[num_edinfo].surf0 = surfs[i];
     (edinfo)[num_edinfo].edge1 = comm_edge.S_objid;
     (edinfo)[num_edinfo].surf1 = srfid;
    }
    else
    {
     (edinfo)[num_edinfo].edge0 = sfedges[j].objid;
     (edinfo)[num_edinfo].surf0 = surfs[i];
     (edinfo)[num_edinfo].edge1 = NULL_OBJID;
     (edinfo)[num_edinfo].surf1 = NULL_OBJID;
    }

    (num_edinfo)++;
  }
}
 /* fix for mlk */
    if (sfedges)
      {
      om$dealloc ( ptr = sfedges );
      sfedges = NULL;
      }
   }
}

   /***** If my_id is EMSsfunitesf, its a case of simple surf and so at this
          stage skip going to GetEdgesAndMerge() function. *****/ 

   num_merged=0;
   num_commedge=num_commedge*0.5;
/*
 Added a block here is avoid the surfaces having more than one P'loop to merge
 for release 3.4.00.8. It is a known fact that math donot support to merge
 them.
*/
/**************** Start of Block Addition ***************************/
  if((num_commedge == 2) && (num_surfs == 2))
     {
      for(crib = 0; crib< num_surfs; crib ++)
       {
        count_obj = 0;
        om$get_channel_count (objid = surfs[crib],
                             osnum = OM_Gw_current_OS,
                             p_chanselect = &set_loop,
                             count = &count_obj);
        if(count_obj == 1)
            {
         loop_setids=(OM_S_OBJECT_LINKAGE *)om$malloc(
                                  size =count_obj*sizeof(OM_S_OBJECT_LINKAGE));

            sts = om$get_channel_objects(objid = surfs[crib],
                                         p_chanselect = &set_loop,
                                         list = loop_setids,
                                         size = count_obj ,
                                         count = &junk_count);
            count_obj = 0;
            om$get_channel_count (objid = loop_setids[0].S_objid,
                                  osnum = OM_Gw_current_OS,
                                  p_chanselect = &out_loops,
                                  count = &count_obj);
                   if(count_obj > 1) 
                   {
                    if(loop_setids) om$dealloc(ptr = loop_setids);
                    sts = 0;
                    ex$message (msgnumb =EMS_I_InpDiscard );
                    sleep(2);
                    goto ret_end;
                   }

            }
       }
    }
/************* End of Block Addition *************************/

   if((num_edinfo)&& (!(cls_id ==OPP_EMSsfunitesf_class_id)))
   {
    for(i=0;i<num_commedge;i++)
    {

    merg_edges1=(GRobjid *)om$malloc(size=MY_BUFF*sizeof(GRobjid));
    merged_edges1=(GRobjid *)om$malloc(size=MY_BUFF*sizeof(GRobjid));
    sort_edges1=(GRobjid *)om$malloc(size=MY_BUFF*sizeof(GRobjid));
    sts=GetEdgesAndMerge(&msg_loc,*new_surf,construct_list,is_simple_surf,surfs,
                         ref_edgeid[num_commedge+i],md_env,&num_merg_edges1,
                         &merg_edges1, &num_merged1,&merged_edges1,
                         &num_sort1,&sort_edges1);
    if(num_commedge == 2 && num_surfs == 2 && i == 1)
    {
    if(!(1&sts)) sts = 1;
    }
    else
      {
       if(!(1&sts)) goto ret_end;
      }
  
    num_merg_edges = num_merg_edges + num_merg_edges1;
    num_merged = num_merged + num_merged1;
    num_sort = num_sort + num_sort1;

    if(is_first_time)
    {
     merg_edges = (GRobjid *)om$malloc(size = 2*num_merg_edges*sizeof(GRobjid));

     merged_edges =(GRobjid *)om$malloc(size = 2*num_merged*sizeof(GRobjid));

     sort_edges = (GRobjid *)om$malloc(size = 2*num_sort*sizeof(GRobjid));
    }
    
    OM_BLOCK_MOVE(merg_edges1,merg_edges + (num_merg_edges - num_merg_edges1),
                  sizeof(GRobjid)*(num_merg_edges1));
    OM_BLOCK_MOVE(merged_edges1,merged_edges + (num_merged - num_merged1),
                  sizeof(GRobjid)*(num_merged1));
    OM_BLOCK_MOVE(sort_edges1,sort_edges + (num_sort - num_sort1),
                   sizeof(GRobjid)*(num_sort1));
    if(merg_edges1)
    {
     om$dealloc(ptr=merg_edges1);
     merg_edges1=NULL;
    }
    if(merged_edges1)
    {
     om$dealloc(ptr=merged_edges1);
     merged_edges1=NULL;
    }
    if(sort_edges1)
    {
     om$dealloc(ptr=sort_edges1);
     sort_edges1=NULL;
    }
    is_first_time=FALSE;
    num_merg_edges1=0;
    num_merged1=0;
    num_sort1=0;

   } 

 }

sort_edinfo:

   found = TRUE;

    if(num_merged)
    { 
      for(index=0;index<num_edinfo;index++)
      {
        if(is_simple_surf)
        {
          ref_edge = edinfo[index].new_edge;
        }
        else
        {
          ref_edge = edinfo[index].edge1;
        }

       for(inx=0;inx<num_merg_edges;inx++)
       {
         if((ref_edge == merg_edges[inx]))
         {
           found=FALSE;
           break;
         } 
         else
         {
           found=TRUE;
         }
       }

       if(found)
       {
          (temp_edinfo)[counter].edge0 = edinfo[index].edge0;
          (temp_edinfo)[counter].surf0 = edinfo[index].surf0;
          (temp_edinfo)[counter].edge1 = edinfo[index].edge1;
          (temp_edinfo)[counter].surf1 = edinfo[index].surf1;
          if(is_simple_surf)
          {
            (temp_edinfo)[counter].new_edge = edinfo[index].new_edge;
          }
          counter++;
   
       } 
     }
   }
 /**** Fill temp_info with newly created merged edges at the right index ****/  

    if(num_merged)
    { 
      if(is_simple_surf)
      {
        for(index=0;index<num_merged;index++)
        {
         (temp_edinfo)[counter].edge1 = NULL_OBJID;
         (temp_edinfo)[counter].edge0 = merged_edges[index];
          counter++;
        }
      }
      else
      {
       for(index=0;index<num_merged;index++)
       {
        (temp_edinfo)[counter].edge1 = merged_edges[index]; 
        (temp_edinfo)[counter].edge0 = NULL_OBJID; 
         counter++;
       }
      }  
      temp_num_info = counter;
    }

   /*** Handle Cases wherin the class id is EMSslunitesf but no Merging occurs
        like in the case of corrupted solids with free edges.
   ***/
   if(!(num_merged) && (cls_id == OPP_EMSslunitesf_class_id)) 
   {
      corrupt_flag=TRUE;
      avoid_merging=TRUE;
      is_simple_surf=FALSE;
   }  
   if(!(num_merged) && (cls_id == OPP_EMSsfunitesf_class_id))
   {
     is_simple_surf = TRUE;
   }
   if(num_merged && !remap)
   {
     sts = EMmap_edges_on_surface( msg, *new_surf,temp_num_info,temp_edinfo,
                   construct_list,&partolbasis,is_simple_surf);
      EMomerr_hndlr (sts, ret_end, "EMmap_edges_on_surface"); 
   }
   else if(is_simple_surf && !remap || avoid_merging)
    {
     sts = EMmap_edges_on_surface( msg, *new_surf,num_edinfo,edinfo,
                   construct_list,&partolbasis,is_simple_surf);
      EMomerr_hndlr (sts, ret_end, "EMmap_edges_on_surface");

    }

  if(is_simple_surf && !remap)
  {
   /*** Case of simple surf. Call again the merging function but this time
        on the merged simple surface. ***/

    for(i=0;i<num_commedge;i++)
    {
    
    merg_edges1=(GRobjid *)om$malloc(size=MY_BUFF*sizeof(GRobjid));
    merged_edges1=(GRobjid *)om$malloc(size=MY_BUFF*sizeof(GRobjid));
    sort_edges1=(GRobjid *)om$malloc(size=MY_BUFF*sizeof(GRobjid));

    sts=GetEdgesAndMerge(&msg_loc,*new_surf,construct_list,is_simple_surf,surfs,
                         ref_edgeid[num_commedge+i],md_env,&num_merg_edges1,
                         &merg_edges1,&num_merged1,&merged_edges1,
                         &num_sort1,&sort_edges1);
      if(!(1&sts)) goto ret_end;

    num_merg_edges = num_merg_edges + num_merg_edges1;
    num_merged = num_merged + num_merged1;
    num_sort = num_sort + num_sort1;

   /*** Handle temporarily corrupt solids ***/

    if(corrupt_flag)is_first_time=TRUE;

    if(is_first_time )
    {
     merg_edges = (GRobjid *)om$malloc(size = 2*num_merg_edges*sizeof(GRobjid));

     merged_edges =(GRobjid *)om$malloc(size = 2*num_merged*sizeof(GRobjid));

     sort_edges = (GRobjid *)om$malloc(size = 2*num_sort*sizeof(GRobjid));
    }
    
    OM_BLOCK_MOVE(merg_edges1,merg_edges + (num_merg_edges - num_merg_edges1),
                  sizeof(GRobjid)*(num_merg_edges1));
    OM_BLOCK_MOVE(merged_edges1,merged_edges + (num_merged - num_merged1),
                  sizeof(GRobjid)*(num_merged1));
    OM_BLOCK_MOVE(sort_edges1,sort_edges + (num_sort - num_sort1),
                   sizeof(GRobjid)*(num_sort1));

    if(merg_edges1)
    {
     om$dealloc(ptr=merg_edges1);
     merg_edges1=NULL;
    }
    if(merged_edges1)
    {
     om$dealloc(ptr=merged_edges1);
     merged_edges1=NULL;
    }
    if(sort_edges1)
    {
     om$dealloc(ptr=sort_edges1);
     sort_edges1=NULL;
    } 
    is_first_time=FALSE;
    num_merg_edges1=0;
    num_merged1=0;
    num_sort1=0;
 }
    /** Set a flag to avoid remapping **/
   remap = TRUE;
   goto sort_edinfo;

 }

 if(num_merged)
 {
  sts = EMreplace_with_new_surf(
                  msg, md_env, &partolbasis, num_surfs, surfs, 
                  temp_num_info, temp_edinfo, &numsolsmod, &solrmsfs,
                  *new_surf);
  EMomerr_hndlr (sts, ret_end, "EMreplace_with_new_surf"); 
  }
 else if(avoid_merging)
  {
   sts = EMreplace_with_new_surf(
                  msg, md_env, &partolbasis, num_surfs, surfs,
                  num_edinfo, edinfo, &numsolsmod, &solrmsfs,
                  *new_surf);
  EMomerr_hndlr (sts, ret_end, "EMreplace_with_new_surf");

  }

 }
else 
{
  sts = om$send ( msg = message EMSplane.EMmap_edges_on_plane
                ( msg, construct_list, &partolbasis, num_surfs, 
                  surfs, &num_edinfo, &edinfo),
           targetid = *new_surf);
  EMomerr_hndlr (sts, ret_end, "EMSplane.EMmap_edges_on_plane"); 


  /* We have a new plane now. Transfer the common edge connections */

  sts = om$send ( msg = message EMSplane.EMreplace_with_new_plane(
                  msg, md_env, &partolbasis, num_surfs, surfs, 
                  num_edinfo, edinfo, &numsolsmod, &solrmsfs ),
           targetid = *new_surf );
  EMomerr_hndlr (sts, ret_end, "EMSplane.EMreplace_with_new_plane"); 

}

  /* Find out the size of SSI table */

  size_data.un_info.num_composites = numsolsmod;
  size_data.un_info.num_surfaces_out = num_surfs;

  if(num_surfs != 2) avoid_merging = TRUE;
  /** Start filling up SSI table appropriately in case of Uniting surfs **/

  if ((is_tangent && !is_planar || !avoid_merging) && num_merged)
  {
  size_data.un_info.num_edges = temp_num_info;
  }
  else
  {
  size_data.un_info.num_edges = num_edinfo;
  }
  sts = om$send ( msg = message EMSdpr.EMgetSSIbuffer (
                  msg, &size_data, &ssibuff),
           targetid = my_id,
           targetos = OM_Gw_current_OS);
  EMomerr_hndlr (sts, ret_end, "EMSdpr.EMrgetSSIbuffer"); 

  /* Fill up the SSI table */

  myssiinfo = &ssibuff->un_info;
  myssiinfo->num_composites = numsolsmod;

  ownlist = solrmsfs;
  inx = 0;

  for (i=0; i<numsolsmod; i++)
  {
   myssiinfo->composite_ids[i] = ownlist->owner;
   inxlim = myssiinfo->num_surfaces_out[i] = ownlist->num_comps;
    for (j=0; j<inxlim; j++)
    {
     myssiinfo->surface_out_ids[inx] = ownlist->comps[j];
     myssiinfo->composite_indices[inx] = ownlist->ownerindex[j];
     inx++;
    }
   ownlist = ownlist->next;
  }
  if ((is_tangent && !is_planar || !avoid_merging) && num_merged)
  {
  myssiinfo->num_edges = temp_num_info;
  }
  else
  {
  myssiinfo->num_edges = num_edinfo;
  }

  if ((is_tangent && !is_planar || !avoid_merging) && num_merged)
  {
    for ( i=0; i<temp_num_info; i++)
    {
      myssiinfo->edges_removed[i] = temp_edinfo[i].edge0;
      myssiinfo->edges_disconnected[i] = temp_edinfo[i].edge1;
      myssiinfo->edges_added[i] = temp_edinfo[i].new_edge;
    }
  }
  else
  {
    for ( i=0; i<num_edinfo; i++)
    {
      myssiinfo->edges_removed[i] = edinfo[i].edge0;
      myssiinfo->edges_disconnected[i] = edinfo[i].edge1;
      myssiinfo->edges_added[i] = edinfo[i].new_edge;
    }
  }

  sts = om$send (msg = message EMSdpr.EMputSSI ( msg, 
                       (union EMSssi_table *) myssiinfo),
                 targetid = my_id);
  EMomerr_hndlr (sts, ret_end, "EMSdpr.EMputSSI");

  /** I am now replacing the old spec file and instead Iam directly adding the
      merge_ids to ME.EMSdpr->ids array. First get the current size of this
      vla, expand it to hold the merge_ids, and then using OM_BLOCK_MOVE copy
      the merge_ids into the vla **/

  vla_size=0;
  final_vla_size=0;

  vla_size = om$dimension_of(varray=ME.EMSdpr->ids);

  final_vla_size = vla_size + num_sort;

  sts = om$vla_set_dimension(varray=ME.EMSdpr->ids,
                             size = final_vla_size);

  OM_BLOCK_MOVE(sort_edges,&ME.EMSdpr->ids[vla_size],num_sort*sizeof(GRobjid));

  /* Handle case of removing an associative surface from a composite */

  if (myssiinfo)
   {
    GRobjid                 *sfout_id=NULL;
    IGRint                  ii, jj;

    sfout_id = myssiinfo->surface_out_ids;

    for(ii=0; ii<myssiinfo->num_composites; ii++)
    {
      for(jj=0; jj<myssiinfo->num_surfaces_out[ii]; jj++, *sfout_id++)
      {
        sts = EFfix_parent_child_relationship(msg, 
                            *sfout_id, myssiinfo->composite_ids[ii],
                            OM_Gw_current_OS, TRUE, NULL);
        if (!(1 & sts & *msg)) goto ret_end;
      }
    }
   }
  /* store the constructed plane in my instance data */

  if (do_display)
  {
   IGRint dispinx;

   inx = 0;
   for (i=0; i<myssiinfo->num_composites; i++)
   {
    for (j=0; j<myssiinfo->num_surfaces_out[i]; j++)
     {
      found = FALSE;
      if (chkdisplist)
      for (dispinx=0; dispinx<*display_count; dispinx++)
      if ((*display_ids)[dispinx] == myssiinfo->surface_out_ids[inx])
      {
       found = TRUE;
       break;
      }
 
      if (!found)
      {
       dpmode = GRbehe;
       sts = om$send( msg = message GRgraphics.GRdisplay(&msg1,
                      &md_env->md_env.matrix_type,
                      md_env->md_env.matrix, &dpmode,
                      &md_env->md_id),
               targetid = myssiinfo->surface_out_ids[inx]);
       EMomerr_hndlr (sts, ret_end, "GRgraphics.GRdisplay"); 
 
       if (chkdisplist)
       {
        EFrealloc_if_needed (msg, display_ids, *display_count, 
         DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
        EMomerr_hndlr (*msg, ret_end, "EFrealloc_if_needed");  

        (*display_ids)[*display_count]=myssiinfo->surface_out_ids[inx];
        (*display_count)++;
       }
      }
     inx++;  
    }
   }
               /** Deallocate the memory **/
        
 if(merg_edges) 
 { 
  om$dealloc(ptr = merg_edges);
  merg_edges=NULL;
 } 
 if(merged_edges) 
 { 
  om$dealloc(ptr = merged_edges);
  merged_edges=NULL;
 }
 if(sort_edges) 
 {
  om$dealloc(ptr = sort_edges);
  sort_edges=NULL;
 }
 if (test_surfs) 
 {
  om$dealloc (ptr =test_surfs);
  test_surfs=NULL;
 }
 if(ssibuff) 
 {
  om$dealloc (ptr = ssibuff);
  ssibuff=NULL;
 }
 if (edinfo) 
 {
  om$dealloc (ptr = edinfo);
  edinfo=NULL;
 }
 if (temp_edinfo) 
 {
  om$dealloc (ptr = temp_edinfo);
  temp_edinfo=NULL;
 }
   dpmode = GRbd;
   sts = om$send( msg = message GRgraphics.GRdisplay(&msg1,
                  &md_env->md_env.matrix_type,
                  md_env->md_env.matrix, &dpmode,
                  &md_env->md_id),
            senderid = my_id,
            targetos=OM_Gw_current_OS,
            targetid = *new_surf);
   EMomerr_hndlr (sts, ret_end, "GRgraphics.GRdisplay"); 
  }

  /* The property bits are set off for surfaces removed */

  for (i=0; i<num_surfs; i++)
   EFsetsfstate ( msg, surfs[i], OM_Gw_current_OS, EMS_O_OFF);

  /* Added for associativity check. In case of recompute the
     connection already exists. */

  {
   GRobjid compid;
   GRspacenum dumosnum;

   sts = om$get_objid_at_index (objid = my_id, 
                 p_chanselect = &to_components,
                 index = 0,
                 objidaddr = &compid,
                 osnumaddr = &dumosnum);
/*   EMomerr_hndlr (sts, ret_end, "om$get_objid_at_index");  */

   if(compid == active_GRid.objid) recompute = TRUE;
  }

  /* Connect the active state and the new plane to myself */

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;
 
  if(!recompute)
  {
   i=0;
   sts = om$send ( msg = message GRconnector.GRrigidconn(msg,
                         &my_GRid, (IGRlong *) &i),
            targetid = active_GRid.objid);
   EMomerr_hndlr (sts, ret_end, "GRconnector.GRrigidconn"); 
  }

  i=1;
  sts = om$send ( msg = message GRconnector.GRrigidconn(msg,
                        &my_GRid, (IGRlong *) &i),
           targetid = *new_surf);
  EMomerr_hndlr (sts, ret_end, "GRconnector.GRrigidconn"); 

  if(recompute) goto ret_end;

  ME.EMSdpr->dpr_props = EMSIS_ACTIVE_STATE | EMSIS_ACTIVE_PATH;    
 
  ME.GRgraphics->properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

  {
   /*Set my last state's active bits off - this could be subbs so I ignore
    * UNKNOWN_MSG warning. -- DLB
    */

    IGRboolean action = FALSE;
    IGRushort mask = EMSIS_ACTIVE_STATE;

    sts = om$send(msg = message EMSdpr.EMsetprops(msg, &action, 
                            &mask),
                      p_chanselect = &to_components,
             senderid = my_id);
    if(sts != OM_W_UNKNOWN_MSG)
    {
      EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, ret_end);
    }
    else
      sts = OM_S_SUCCESS; /*fix the return code*/
  }
  

ret_end:
 if (ssibuff) 
 {
  om$dealloc (ptr = ssibuff);
 }
 if (edinfo) 
 {
  om$dealloc (ptr = edinfo);
 }
 if (temp_edinfo) 
 {
  om$dealloc (ptr = temp_edinfo);
 }
 if(merged_edges) 
 {
  om$dealloc(ptr = merged_edges);
 }
 if(sort_edges) 
 {
  om$dealloc(ptr = sort_edges);
 }

 if (solrmsfs) EMownercomp_free (solrmsfs, MAXINT);
 if (test_surfs) om$dealloc (ptr = (test_surfs));

 /** Delete the new plane (or the new_suface as the case may be) in case of
    any failure and if it is not already not being deleted.
  **/

 if(!(sts & 1))
 {
   status = om$is_objid_valid(osnum = OM_Gw_current_OS,
                              objid = *new_surf); 

   if((status==OM_S_SUCCESS))
   status = om$send(msg = message Root.delete(1),
                               targetid = *new_surf);
 }
 return (sts);

}

end implementation EMSsfunitesf;
