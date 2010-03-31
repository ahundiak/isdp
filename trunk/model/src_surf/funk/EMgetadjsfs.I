/*
HISTORY:
	Ramana  08/16/95 Removed values.h as bsvalues.h is changed.
*/
class  implementation EMSsubbs;

#include "EMS.h"
#include "OMmacros.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "emsgeteddef.h"
#include "EMSbnddef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnd.h"
#include "EMSmsgdef.h"
#include "ECcmd.h"
#include "ECmsg.h" 
#include "lcmacros.h"
#include "dpmacros.h"
#include "OMobjectcomm.h"
#include "bsparameters.h"
#include "bsicmpcvoff.h"
#include  <math.h>

#include "emsdattyp.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsaddraft.h"
 
#include "bsvalues.h"

from EMSboundary import EMget_objid;
from EMSedge import EMget_sf_edges, EMchkconvex;
from EMSedge import  EMget_props, EMgetsurface_info;
from EMSloop import  EMget_nest_depth, EMget_edges, EMget_props;
from EMSloopset import  EMget_loops;


IGRint   EMget_adj_sfs(EMmsg,
                 md_env,
                 num_surfs,
                 surf_to_draft,
                 in_loop,
                 external,
                 draft_surf,
                 total_len,
                 num_lists,
                 info_list,
                 edge_angle,
                 recurse)

   IGRlong *EMmsg;
   struct GRmd_env *md_env;
   IGRint num_surfs;
   struct GRid *surf_to_draft, *draft_surf;
   GRobjid  *in_loop;
   IGRboolean external;
   IGRint *total_len, *num_lists;
   struct EMSadj_surf_info **info_list;
   IGRdouble edge_angle;
   IGRint recurse;
   {
    IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
    IGRint ii,ij, num_edges,buff_size;
    struct GRid *edges=NULL;
    OM_S_CHANSELECT   to_outter,
                      to_owner, to_loopset, loopset_to_loops,to_common;
    IGRint dum_os;
    OMuint has_commedge;
    OM_S_OBJECT_LINKAGE par_link, comm_edge_link;
    OMuint has_it;
    IGRint lp_count=0, loop_count;
    OM_S_OBJID the_loop;
    IGRushort edge_props, loop_props;
    OMuword  ozoz;
    IGRint loop_number, depth;
    IGRlong option;
    GRobjid *loops=NULL, *loop_ids=NULL;
    IGRushort *props=NULL;
    IGRboolean dont_recurse,  reversed , attached , already_there=FALSE;
    struct EMSadj_surf_info *surf_list, *tmp_loc,
                        *surf_list_prev, *surf_list_loc, *adj_sf_info_list;
    IGRint ZZZ, XXX, qq, mmm;

    surf_list = *info_list;

/** RECURSION END CONDITION */
    if(recurse == 0)
       goto wrapup;

    num_edges = buff_size = 0;

    stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
    stat_OM = EMmake_chanselect (EMSloopset_to_loops, &loopset_to_loops);
    stat_OM = EMmake_chanselect(EMSedge_to_common_edge, &to_common);
    stat_OM = EMmake_chanselect (EMSedge_to_owner, &to_owner);
    stat_OM = EMmake_chanselect(EMSloop_to_outter, &to_outter);
    EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_Fail, wrapup);

  for(ZZZ=0; ZZZ<num_surfs; ZZZ++)
  {

    loop_ids = NULL;
    loops = NULL;
    props = NULL;
    depth = MAXINT;
    buff_size = 0;
    option = 0;
    lp_count = loop_count = 0;
    loop_number=0;

    stat_OM = om$send(msg = message EMSloopset.EMget_loops
                        (&msg_loc ,option,&depth,&loops,&props,&buff_size,
                         &loop_count),
			senderid = surf_to_draft[ZZZ].objid,
                        targetos = surf_to_draft[ZZZ].osnum,
			p_chanselect = &to_loopset);
    EMerr_hndlr(EMSerror(stat_OM & msg_loc), *EMmsg,EMS_E_LoopsetError,wrapup);

    lp_count = loop_count;
    loop_number = lp_count;
    loop_ids = &loops[0];
    if(!external)
     {
       for(ii=0; ii<loop_count; ii++)
         if(loop_ids[ii] == *in_loop)
            break;
         loop_number=ii;
     }

     (*num_lists)++;
     for(XXX=0; XXX<lp_count; XXX++)
     {
     /* if(XXX > loop_number ) continue; */
      for(surf_list_prev = NULL, surf_list_loc= surf_list;
                        surf_list_loc; 
      surf_list_prev= surf_list_loc, surf_list_loc= surf_list_loc->next)
       {
          if( surf_list_loc->the_loop == loop_ids[XXX]) 
             {
                already_there = TRUE;
                if(XXX == loop_number)
                    surf_list_loc->operate = TRUE;
                if(external)
                    {
                    surf_list_loc->operate = TRUE;
                    surf_list_loc->affect |= EM_ADDRFT_EXTND;
                    }
                break;
             }
/*********************
          else if(surf_list_loc->myself.objid == surf_to_draft[ZZZ].objid) 
             {
             if(surf_list_loc->loop_no == XXX)
                {
                already_there = TRUE;
                if(XXX == loop_number)
                    surf_list_loc->operate = TRUE;
                if(external)
                    surf_list_loc->affect = EM_ADDRFT_EXTND;
                break;
                }
             }
*********************/
       }

         if(already_there)
           {
           already_there =  FALSE;
           continue;
           }

       (*total_len)++;
       stat_OM = om$get_channel_objects
                                 (objid = loop_ids[XXX],
                                 osnum =  surf_to_draft[ZZZ].osnum,
                                 p_chanselect = &to_outter,
                                 size = 1,
                                 list = &par_link,
                                 count = &has_it);
       EMerr_hndlr (!(1&stat_OM) && !has_it, *EMmsg, EMS_E_Fail,wrapup);

       adj_sf_info_list =(struct EMSadj_surf_info *)
       om$malloc(size = (lp_count) * sizeof(struct EMSadj_surf_info));
       EMerr_hndlr (!adj_sf_info_list,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

       adj_sf_info_list->extend = 1;
       adj_sf_info_list->operate = TRUE;
       if((!external) && (loop_number != XXX))
         adj_sf_info_list->operate =  FALSE;

       if(external || XXX == 0)
         adj_sf_info_list->affect = EM_ADDRFT_EXTND;
       else 
         adj_sf_info_list->affect = EM_ADDRFT_INTRNL_LP;

       adj_sf_info_list->the_loop = NULL_OBJID;
       adj_sf_info_list->loop_props = NULL;
       adj_sf_info_list->num_adjacent = 0;
       adj_sf_info_list->commedges = NULL;
       adj_sf_info_list->edges = NULL;
       adj_sf_info_list->adj_surfs = NULL;
       adj_sf_info_list->adj_loops = NULL;

       adj_sf_info_list->myself.objid  = surf_to_draft[ZZZ].objid;
       adj_sf_info_list->myself.osnum  = surf_to_draft[ZZZ].osnum;

       if(recurse ==2)
       adj_sf_info_list->affect  |= EM_ADDRFT_DRAFT_SRF;

       adj_sf_info_list->the_loop  = loop_ids[XXX];
       if(external)
          adj_sf_info_list->loop_no  = XXX;
       else
          adj_sf_info_list->loop_no  = loop_number;

          adj_sf_info_list->loop_no  = XXX; 
       
       adj_sf_info_list->next = NULL;
       adj_sf_info_list->my_inters = NULL;
       adj_sf_info_list->adj_inters = NULL;
       adj_sf_info_list->comedge_cncv = NULL;
       adj_sf_info_list->pos_orient = FALSE;
       adj_sf_info_list->planar = TRUE;

        adj_sf_info_list->par_loop_no = -1;
        if(has_it)
           {
           for(qq=0;qq<loop_count;qq++)
              if(loops[qq]==par_link.S_objid)
                 adj_sf_info_list->par_loop_no = qq;
           }

       /*** arrange the nodes according to loop no ***/
       attached = FALSE;
       if(!surf_list)
       {
          attached = TRUE;
          surf_list = adj_sf_info_list;
       }
       else
       {
        for(surf_list_prev = NULL, surf_list_loc= surf_list;
                          surf_list_loc; 
        surf_list_prev= surf_list_loc, surf_list_loc= surf_list_loc->next)
         {
          if(surf_list_loc->myself.objid == adj_sf_info_list->myself.objid)
           {
              if(surf_list_loc->loop_no > adj_sf_info_list->loop_no)
               {
               tmp_loc =  surf_list_loc;
               if(surf_list_prev)
                 surf_list_prev->next = adj_sf_info_list;
               else
                 surf_list_loc = adj_sf_info_list;
               adj_sf_info_list->next = tmp_loc;
               attached = TRUE;
               }
             else if((!surf_list_loc->next) || 
                     (surf_list_loc->next &&
                      surf_list_loc->next->myself.objid != 
                     adj_sf_info_list->myself.objid))
               {
               tmp_loc = surf_list_loc->next;
               surf_list_loc->next = adj_sf_info_list;
               adj_sf_info_list->next = tmp_loc;
               attached = TRUE;
               }
             else
               {
                continue;
               }
            }
           if(attached) break;
         }
        if(!attached) surf_list_prev->next = adj_sf_info_list;
       }


       stat_OM = om$send( msg = message EMSloop.EMget_props(
                    &msg_loc, &loop_props),
                        senderid = NULL_OBJID,
                        targetid = loop_ids[XXX],
                        targetos = surf_to_draft[ZZZ].osnum);
       EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

       if(loop_props&EMLP_PLOOP)
          adj_sf_info_list->loop_props |= EMLP_PLOOP;
       reversed = FALSE;
       if(loop_props & EMLP_REVERSED)
           reversed = TRUE;

       edges=NULL;
       buff_size= num_edges = 0;
       stat_OM = om$send(msg = message EMSloop.EMget_edges(&msg_loc,
                                        1,
                                        /* EMS_OPT_NOSEAM, */
                                        EMS_OPT_ALL,
                                        &edges, 
                                        &buff_size,
                                        &num_edges),
                        senderid = NULL_OBJID,
                        targetid = loop_ids[XXX],
                        targetos = surf_to_draft[ZZZ].osnum);
       EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

       adj_sf_info_list->num_adjacent = num_edges;

       adj_sf_info_list->edges
            = (GRobjid *)om$malloc(size = num_edges * sizeof(GRobjid));
       EMerr_hndlr (!adj_sf_info_list->edges, *EMmsg,
                                     EMS_E_NoDynamicMemory, wrapup);

       adj_sf_info_list->commedges
            = (GRobjid *)om$malloc(size = num_edges * sizeof(GRobjid));
       EMerr_hndlr (!adj_sf_info_list->commedges, *EMmsg,
                                     EMS_E_NoDynamicMemory, wrapup);

       adj_sf_info_list->adj_loops
            = (GRobjid *)om$malloc(size = num_edges * sizeof(GRobjid));
       EMerr_hndlr (!adj_sf_info_list->adj_loops, *EMmsg,
                                     EMS_E_NoDynamicMemory, wrapup);

       adj_sf_info_list->adj_surfs
            = (GRobjid *)om$malloc(size = num_edges * sizeof(GRobjid));
       EMerr_hndlr (!adj_sf_info_list->adj_surfs,
                                    *EMmsg, EMS_E_NoDynamicMemory,wrapup);

       adj_sf_info_list->comedge_cncv = 
             (IGRint *)om$malloc(size = num_edges * sizeof(IGRint));
       EMerr_hndlr (!adj_sf_info_list->adj_surfs,
                                    *EMmsg, EMS_E_NoDynamicMemory,wrapup);

       for(ii=0; ii <num_edges; ii++)
          {
       adj_sf_info_list->edges[ii] = NULL_OBJID;
       adj_sf_info_list->commedges[ii] = NULL_OBJID;
       adj_sf_info_list->adj_loops[ii] = NULL_OBJID;
       adj_sf_info_list->adj_surfs[ii] = NULL_OBJID;
          }

       for(ij=0, ii = (reversed ? num_edges-1 : 0);
                 (reversed ? ii >=0 : ii < num_edges) ; 
                     ii = (reversed ? ii-1 : ii+1))
         {
          stat_OM = om$send( msg = message EMSedge.EMget_props
                      (&msg_loc,
                       &edge_props),
                   senderid = NULL_OBJID,
                   targetid = edges[ii].objid,
                   targetos = surf_to_draft[ZZZ].osnum);
          EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

         dum_os = OM_Gw_current_OS;
         stat_OM = om$get_channel_objects(objid = edges[ii].objid,
                                 osnum = edges[ii].osnum,
                                 p_chanselect = &to_common,
                                 size = 1,
                                 list = &comm_edge_link,
                                 count = &has_commedge);

         stat_OM = OM_S_SUCCESS; msg_loc = EMS_S_Success;

         adj_sf_info_list->edges[ii] = edges[ii].objid;
         adj_sf_info_list->comedge_cncv[ii] = 2;
         if(!has_commedge)
           {
           if(edge_props&EMED_DEGENERATE)
             adj_sf_info_list->comedge_cncv[ii] = 4;
           else
             adj_sf_info_list->comedge_cncv[ii] = 3;
           continue;
           }

         adj_sf_info_list->edges[ii] = edges[ii].objid;
         adj_sf_info_list->commedges[ii] = comm_edge_link.S_objid;

         stat_OM = om$send(msg = message EMSedge.EMgetsurface_info(&msg_loc,
                                    &adj_sf_info_list->adj_surfs[ii],
                                    NULL),
                                targetos = edges[ii].osnum,
                                senderid = edges[ii].objid,
                                p_chanselect = &to_common);
         EMerr_hndlr (!(1&stat_OM) && !has_it, *EMmsg, EMS_E_Fail,wrapup);

         the_loop = NULL_OBJID;
         stat_OM = EMsend_loops ( EMmsg,
                  message EMSboundary.EMget_objid(&msg_loc, &the_loop),
                  comm_edge_link.S_objid, 0, MAXINT, EMLP_ACTIVE, NULL, NULL);
         EMerr_hndlr (!(1&stat_OM) && !has_it, *EMmsg, EMS_E_Fail,wrapup);

         adj_sf_info_list->adj_loops[ii] = the_loop;

         stat_OM = om$send( msg = message EMSloop.EMget_props(
                    &msg_loc, &loop_props),
                                targetos = edges[ii].osnum,
                                targetid = the_loop,
                                senderid = NULL_OBJID);
         EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
        
         dont_recurse = FALSE;
         for(mmm=0; mmm<num_surfs; mmm++)
           if(adj_sf_info_list->adj_surfs[ii] == surf_to_draft[mmm].objid)
             dont_recurse = TRUE;

         if((!external) && (loop_number != XXX))
              dont_recurse = TRUE;

         if(!dont_recurse)
           {
            struct GRid surf;
            surf.objid = adj_sf_info_list->adj_surfs[ii];
            surf.osnum =  surf_to_draft[ZZZ].osnum;

              EMget_adj_sfs(&msg_loc,
                 md_env,
                 1,
                 &surf,
                 &the_loop,
           ((loop_props&EMLP_EXTERNAL || loop_props&EMLP_NATURAL )?TRUE:FALSE),
                 &surf,
                 total_len,
                 num_lists,
                 &surf_list,
                 edge_angle, 
                 recurse-1);
           }
           ij++; /**** INCREMENT *************/
        }
        if(edges)
          om$dealloc (ptr = edges);
        edges = NULL;

     adj_sf_info_list = NULL;
     }
     if(loop_ids)
        om$dealloc(ptr=loops);
     loops = NULL;
     if(props)
        om$dealloc(ptr=props);
     props = NULL;
   }
   *info_list = surf_list;
      
  wrapup:
    if(edges)
       om$dealloc (ptr = edges);
    if(loops)
       om$dealloc(ptr=loops);
    if(props)
       om$dealloc(ptr=props);

    EMWRAPUP( *EMmsg, stat_OM, "EMadj_sf_info");
    return (stat_OM);
  }


end  implementation EMSsubbs;



