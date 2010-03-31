/*
 History:

   ???    : ?????   : Creation
   Hari   :05/03/95 : Fix for TR#119424173(accessing a null pointer)

   Hari   :10/xx/95 : Flow retained for Replace surface functionality.
                      The add draft functionality will follow a new flow
                      such that the surfaces to be drafted are drafted
                      first followed by the check for extension of adjacent
                      surfaces and then extension routine.

   Hari   :10/xx/95 : New function D_Check_ext() is added to avoid unwanted
                      extentions of adjacent surface. This routine makes
                      use of the topological and geometrical characteristics
                      of the surfaces, in deciding whether the surface needs
                      extension or not.

   Hari   :11/xx/95 : New functions & supporting functions to avoid unwanted 
                      extension of adjacent surfaces. The function details

                      D_SinDou_Draft(): Function which says whether the
                      hinge plane is intersecting in middle of the original
                      surface or at an end; which is the deciding factor for
                      single or double draft.

                      D_mat_addrem(): This function is to get whether the
                      the drafting of required surface results in material 
                      addition/reduction or both to the base solid.

                      D_get_solidinfo(): supporting function for D_Check_ext.
                      This is to get the base solid id and range.

                      D_get_hingegeom(): supporting function for D_Check_ext.
                      and for D_SinDou_Draft(). This is to get the hinge
                      plane geometry.

                      D_get_angletype(): supporting function for D_Check_ext.
                      This is to get the edge type between the adjacent surf.
                      and draft surface.

                      D_adjloop(): supporting function for D_Check_ext. This
                      is to get the info regarding the adjacent of the draft
                      surface; P/C loop.
                      
   Hari   :11/xx/95   New function call for extending and copying the 
                      adjacent surfaces; EMextend_adj_surfs_draft();

   Hari   :11/xx/95   Code to have exact/minimum-required surface extents
                      Fix for TR#119527929  

*/


class  implementation EMSsubbs;

#include "EMS.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_S.h"
#include "msmacros.h"
#include "OMmacros.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
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
#include  <bsvalues.h>
#include  <math.h>
#include "emsdattyp.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsaddraft.h"
#include "emstplydel.h"
#include "EMSprop.h"
#include "EMSdef.h"

#include "bspj_pt_sf.h"
#include "bsdistptpt.h"

#define SURFACES_AND_EDGES_OR_CVS_OR_SURFS 0
#define PLANE_AND_SURFACES 1
#define REPLACE_SURFACE  2
#define EMS_S_INSOLID  1
#define CONVEX 1

from EMSedge import EMget_sf_edges, EMchkconvex;
from EMSedge import  EMgetsurface_info, EMxyz_endpt;
from EMSloopset import EMget_loops;
from EMSloop import EMtreemod, EMget_edges, EMget_props, EMtplydelete;
from EMSsolid import EMpoint_locate;

from EMSdatpln import EMget_pln_info;

extern OMuword OPP_EMSdatpln_class_id;

extern IGRint D_SinDou_Draft(IGRlong *,struct GRmd_env *,
       struct EMSadj_surf_info *, struct IGRbsp_surface **,IGRint *);

extern IGRint EMextend_adj_surfs_draft(IGRlong *,struct GRmd_env *,
       struct GRvg_construct *,IGRdouble,IGRdouble,struct EMSadj_surf_info **,
       IGRint,OMuword,struct EMSadj_surf_info **,IGRint, IGRboolean);

extern IGRint D_mat_addrem(IGRlong *,struct GRmd_env *, 
       struct EMSadj_surf_info **,IGRint,IGRint,struct GRid *,
       struct IGRbsp_surface  **,IGRint *);

extern IGRint D_get_solidinfo(IGRlong *,struct GRmd_env *,
       struct EMSadj_surf_info **,struct GRid *,IGRdouble *);

extern IGRint D_get_hingegeom(IGRlong *,struct GRmd_env *,
       struct EMSadj_surf_info *,GRobjid *,IGRdouble *,
       struct IGRbsp_surface **);

extern IGRint D_get_angletype(struct EMSadj_surf_info **,IGRint,
       GRobjid,GRobjid);

extern IGRint D_adjloop(IGRlong *,struct EMSadj_surf_info **,IGRint,
       GRobjid,GRobjid,IGRint *);

extern IGRint D_Check_ext(IGRlong *,struct GRmd_env *,
       struct EMSadj_surf_info **,IGRint,GRobjid *,IGRint *);

IGRint EMcopy_adj_surfs(EMmsg,
		                md_env,
		                const_list,
                        num_draft_surfs,
                        surfs,
                        replace_surfs,
                        hinges,
                        draft_type, 
                        ang_rev,
		                list_len,
                        draft_angle,
                        min_angle,
		                adj_sf_info_list,
		                cp_sf_info_list)
   IGRlong *EMmsg;
   struct GRmd_env *md_env;
   struct GRvg_construct *const_list;
   IGRint num_draft_surfs;
   struct GRid  surfs[];
   IGRboolean       ang_rev;
   GRobjid *replace_surfs;
   GRobjid *hinges;
   IGRint draft_type, *list_len;
   IGRdouble draft_angle, min_angle;
   struct EMSadj_surf_info ***adj_sf_info_list, ***cp_sf_info_list;
{
    IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
    IGRint indez=0, buff_size, num_edges, index, jj,ii, kk;
    IGRint lp_count = 0;
    struct GRid *edges=NULL;
    struct EMSadj_surf_info **adj_info_list = NULL, **cp_info_list = NULL;
    GRobjid *loop_ids=NULL;
    struct EMSpartolbasis partolbasis;
    OM_S_CHANSELECT to_owner,  to_loopset;
    IGRint depth =0;
    IGRboolean NO_EXTEND, surface_already_processed = FALSE;
    struct IGRbsp_surface *the_surf_geom=NULL;
    IGRlong  buf_size;
    struct GRid temp_grid;
    OMuword class_id;
    IGRint *ext_flag = NULL;
    extern void  EFget_surf_geom();
    IGRboolean   EMget_inx_w_lp(),  EMget_cp_sf();

    ex$message(msgnumb = EMS_S_ProcessingOne);

    stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
    EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_Fail, wrapup);

    stat_OM = EMmake_chanselect (EMSedge_to_owner, &to_owner);
    EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_Fail, wrapup);

    adj_info_list = *adj_sf_info_list;

    /*
     * ALLOCATE MEMORY 
     */
    if(!cp_info_list)
    {
      cp_info_list = (struct EMSadj_surf_info **) om$malloc( size = 
                         *list_len * sizeof( struct EMSadj_surf_info *));
      EMerr_hndlr(!cp_info_list , *EMmsg, EMS_E_NoDynamicMemory, wrapup);

      for(ii=0;ii<*list_len; ii++)
      {
        cp_info_list[ii] = (struct EMSadj_surf_info *) om$malloc( size = 
                            sizeof( struct EMSadj_surf_info ));
        EMerr_hndlr(!cp_info_list , *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }
    }

    /*
     * INITIALIZE 
     */
    for(ii=0; ii< *list_len ; ii++)
    {
      cp_info_list[ii]->extend= adj_info_list[ii]->extend;
      cp_info_list[ii]->affect= adj_info_list[ii]->affect;
      cp_info_list[ii]->myself.objid =  adj_info_list[ii]->copy;
      cp_info_list[ii]->myself.osnum =  adj_info_list[ii]->myself.osnum;
      cp_info_list[ii]->operate = adj_info_list[ii]->operate; 
      cp_info_list[ii]->the_loop = adj_info_list[ii]->the_loop;
      cp_info_list[ii]->loop_no = adj_info_list[ii]->loop_no;
      cp_info_list[ii]->par_loop_no = adj_info_list[ii]->par_loop_no;
      cp_info_list[ii]->loop_props = adj_info_list[ii]->loop_props;
      cp_info_list[ii]->copy = adj_info_list[ii]->myself.objid;
      cp_info_list[ii]->num_adjacent =  adj_info_list[ii]->num_adjacent;
      cp_info_list[ii]->edges = NULL;
      cp_info_list[ii]->adj_surfs = NULL;
      cp_info_list[ii]->adj_loops = NULL;
      cp_info_list[ii]->commedges = NULL;
      cp_info_list[ii]->comedge_cncv =  NULL;
      cp_info_list[ii]->my_inters =  NULL;
      cp_info_list[ii]->adj_inters = NULL;
      cp_info_list[ii]->next = NULL;
   }

   for(ii=0; ii< *list_len ; ii++)
   {
      surface_already_processed = FALSE;
      if(ii>0 &&
          adj_info_list[ii]->myself.objid == adj_info_list[ii-1]->myself.objid)
      {
           cp_info_list[ii]->myself.objid = cp_info_list[ii-1]->myself.objid;
           cp_info_list[ii]->copy = cp_info_list[ii-1]->copy;
           cp_info_list[ii]->pos_orient = cp_info_list[ii-1]->pos_orient;
           adj_info_list[ii]->pos_orient = adj_info_list[ii-1]->pos_orient;
           cp_info_list[ii]->planar = cp_info_list[ii-1]->planar;
           adj_info_list[ii]->planar = adj_info_list[ii-1]->planar;
           surface_already_processed = TRUE;
      }

      NO_EXTEND = FALSE;
      if(!(adj_info_list[ii]->operate
              && (!(adj_info_list[ii]->affect&EM_ADDRFT_INTRNL_LP)))   )
           NO_EXTEND=TRUE;

      if( NO_EXTEND || adj_info_list[ii]->affect&EM_ADDRFT_DRAFT_SRF  ||
          adj_info_list[ii]->affect&EM_ADDRFT_TRIM ||
            adj_info_list[ii]->affect&EM_ADDRFT_PIVOT ||
                adj_info_list[ii]->affect&EM_ADDRFT_INTRNL_LP)
       {
           if ((adj_info_list[ii]->affect&EM_ADDRFT_DRAFT_SRF) &&
                                      !(surface_already_processed) )
           {
             if(draft_type == REPLACE_SURFACE)
             {
                temp_grid.objid = replace_surfs[indez++];
                temp_grid.osnum = adj_info_list[ii]->myself.osnum; 
                EFget_big_man(&msg_loc,
                              md_env,
                              &adj_info_list[ii]->myself.objid,
                              &temp_grid,
                              &cp_info_list[ii]->myself.objid,
                              const_list,
                              &draft_angle);
                EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_SurfaceError, wrapup);
             }
             else
             {
                stat_OM = EMcreate_draft_sf(&msg_loc,
                                            md_env,
                                            adj_info_list[ii],
                                            (draft_type == 1) ? &hinges[0]
                                                              :NULL, //planes
                                            (draft_type == 0) ? &hinges[kk]
                                                              :NULL, //edges 
                                            ang_rev,
                                            draft_angle,
                                            min_angle,
                                            &cp_info_list[ii]->myself,
                                            const_list );
                EMerr_hndlr(!(1&stat_OM&msg_loc),
                            *EMmsg,EMS_E_SurfaceError,wrapup);
             }
             adj_info_list[ii]->copy = cp_info_list[ii]->myself.objid;
          }

          if(adj_info_list[ii]->affect&EM_ADDRFT_TRIM || 
             adj_info_list[ii]->affect&EM_ADDRFT_PIVOT ||
                NO_EXTEND ||
                 adj_info_list[ii]->affect&EM_ADDRFT_INTRNL_LP)
          {
            if(!surface_already_processed)
            {
              stat_OM = om$send(msg = message EMSsurface.GRcopy(&msg_loc,
				      md_env,md_env,
                                      &cp_info_list[ii]->myself.objid),
	                   senderid = NULL_OBJID,
	                   targetid = adj_info_list[ii]->myself.objid,
	                   targetos = adj_info_list[ii]->myself.osnum); 
              EMerr_hndlr(!(1&stat_OM&msg_loc) , *EMmsg, EMS_E_Fail, wrapup);

              if(loop_ids) { om$dealloc(ptr = loop_ids); loop_ids=NULL; }
              lp_count = 0;
              buff_size = 0;
              depth = MAXINT;
              stat_OM = om$send( msg = message EMSloopset.EMget_loops(
		                       &msg_loc,0,&depth,&loop_ids,
		                       NULL,&buff_size,&lp_count),
		        p_chanselect = &to_loopset,
		                from = 0,
		                  to = MAXINT,
		            senderid = cp_info_list[ii]->myself.objid,
		            targetos = adj_info_list[0]->myself.osnum);
              EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
            }
            
           if((surface_already_processed && loop_ids)||  
                !surface_already_processed )
            {

	       if((adj_info_list[ii]->affect&EM_ADDRFT_INTRNL_LP)
                                     && (adj_info_list[ii]->operate))
	       {
                 /* delete the inner  loop  */
                 partolbasis.is_valid=FALSE;
	         stat_OM = om$send( msg = message EMSloop.EMtreemod(
                                          &msg_loc,NULL,3,&partolbasis),
                               senderid = NULL_OBJID,
	                       targetid = loop_ids[adj_info_list[ii]->loop_no],
	                       targetos = adj_info_list[0]->myself.osnum);
	         EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
	       }
               else
               {
                 cp_info_list[ii]->the_loop =
                                   loop_ids[adj_info_list[ii]->loop_no];
                 adj_info_list[ii]->the_loop =
                                   loop_ids[adj_info_list[ii]->loop_no];
               }
            }
	 } 
         if(ii>0 &&
           adj_info_list[ii]->myself.objid == adj_info_list[ii-1]->myself.objid)
         {
           cp_info_list[ii]->pos_orient = cp_info_list[ii-1]->pos_orient;
           adj_info_list[ii]->pos_orient = adj_info_list[ii-1]->pos_orient;
           cp_info_list[ii]->planar = cp_info_list[ii-1]->planar;
           adj_info_list[ii]->planar = adj_info_list[ii-1]->planar;
           goto Next;
         }

         EFget_surf_geom(&msg_loc, md_env,cp_info_list[ii]->myself.objid,
                         cp_info_list[ii]->myself.osnum, &the_surf_geom);
         EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_SurfaceError, wrapup);

         cp_info_list[ii]->pos_orient = the_surf_geom->pos_orient;
         cp_info_list[ii]->planar = the_surf_geom->planar;

         if(the_surf_geom){om$dealloc(ptr= the_surf_geom); the_surf_geom =NULL;}

         EFget_surf_geom(&msg_loc, md_env,adj_info_list[ii]->myself.objid,
                         adj_info_list[ii]->myself.osnum,  &the_surf_geom);
         EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_SurfaceError, wrapup);

         adj_info_list[ii]->pos_orient = the_surf_geom->pos_orient;
         adj_info_list[ii]->planar = the_surf_geom->planar;

         if(the_surf_geom){om$dealloc(ptr= the_surf_geom); the_surf_geom =NULL;}
      }
      else if((!surface_already_processed) && (draft_type == REPLACE_SURFACE))
      {
         /*
          * Flow retained for replace surface functionality.
          */
         om$get_classid (objid = adj_info_list[ii]->myself.objid ,
                         osnum = adj_info_list[ii]->myself.osnum,
                     p_classid = &class_id);

         stat_OM = EMextend_adj_surfs(&msg_loc,md_env,const_list,
                                      draft_angle,min_angle,adj_info_list,
                                      *list_len,ii,class_id,cp_info_list[ii]);
	 EMerr_hndlr(!(1&stat_OM&msg_loc) , *EMmsg, EMS_E_Fail, wrapup);
      }

      Next:
      adj_info_list[ii]->copy = cp_info_list[ii]->myself.objid;
      cp_info_list[ii]->copy = adj_info_list[ii]->myself.objid;
      cp_info_list[ii]->myself.osnum = adj_info_list[ii]->myself.osnum;
  }

  /*
   * Code added to modify the flow for the add draft code
   */
  if(draft_type != REPLACE_SURFACE)
  {
    
      //initialize the ext.flag
      ext_flag = (IGRint *)om$malloc(size=(*list_len)*sizeof(IGRint));
      for(ii=0; ii< *list_len ; ii++) ext_flag[ii] = TRUE;

      if(&hinges[0])
      {
      stat_OM = D_Check_ext(&msg_loc,md_env,adj_info_list,*list_len,
                            hinges, ext_flag);
      EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
      }


      /*
       * Process for copying the adjacent surface with the geometrical 
       * change(extension)
       */
      for(ii=0; ii< *list_len ; ii++)
      {
        IGRboolean surf_noext = FALSE;

        surf_noext = (ext_flag[ii]) ? FALSE:TRUE;
   

        /*
         * If the surface is already processed then just copy the
         * necessary data
         */
        surface_already_processed = FALSE;
        if(ii>0 &&
           adj_info_list[ii]->myself.objid == adj_info_list[ii-1]->myself.objid)
        {
           cp_info_list[ii]->myself.objid = cp_info_list[ii-1]->myself.objid;
           cp_info_list[ii]->copy = cp_info_list[ii-1]->copy;
           cp_info_list[ii]->pos_orient = cp_info_list[ii-1]->pos_orient;
           adj_info_list[ii]->pos_orient = adj_info_list[ii-1]->pos_orient;
           cp_info_list[ii]->planar = cp_info_list[ii-1]->planar;
           adj_info_list[ii]->planar = adj_info_list[ii-1]->planar;
           surface_already_processed = TRUE;
        }

        /*
         * Now consider only those surfaces which are not considered
         * so far, that is the surface to be extended
         */
        NO_EXTEND = FALSE;
        if(!(adj_info_list[ii]->operate &&
           (!(adj_info_list[ii]->affect&EM_ADDRFT_INTRNL_LP)))   )
             NO_EXTEND=TRUE;

        if(( !(NO_EXTEND ||
               adj_info_list[ii]->affect&EM_ADDRFT_DRAFT_SRF  ||
               adj_info_list[ii]->affect&EM_ADDRFT_TRIM ||
               adj_info_list[ii]->affect&EM_ADDRFT_PIVOT ||
               adj_info_list[ii]->affect&EM_ADDRFT_INTRNL_LP))
            && (!surface_already_processed))
        {
           /*
            * Get the surface class id
            */
           om$get_classid (objid = adj_info_list[ii]->myself.objid ,
                           osnum = adj_info_list[ii]->myself.osnum,
                           p_classid = &class_id);

           /*
            * New function call for extending and copying the adjacent
            * surfaces
            */
           stat_OM = EMextend_adj_surfs_draft(&msg_loc,md_env,const_list,
                                              draft_angle,min_angle,
                                              adj_info_list,ii,class_id,
                                              cp_info_list,*list_len,
                                              surf_noext);
           EMerr_hndlr(!(1&stat_OM&msg_loc),*EMmsg, EMS_E_Fail, wrapup);
        }
        adj_info_list[ii]->copy = cp_info_list[ii]->myself.objid;
        cp_info_list[ii]->copy = adj_info_list[ii]->myself.objid;
        cp_info_list[ii]->myself.osnum = adj_info_list[ii]->myself.osnum;
      }
  }

  /*****************************
    Code not modified below this
   ******************************/


  /*
   * GET THE SURFACE EDGES FOR THE COPIES OF THE SURFACES TO BE TRIMED 
   * OR IF THEIR INTERNAL LOOPS ONLY ARE AFFECTED 
   */  
   for(ii=0; ii< *list_len; ii++)
   {
           cp_info_list[ii]->adj_surfs = 
	    (GRobjid *)om$malloc( size = 
		  cp_info_list[ii]->num_adjacent * sizeof(GRobjid));

	   cp_info_list[ii]->adj_loops = 
	    (GRobjid *)om$malloc( size = 
		  cp_info_list[ii]->num_adjacent * sizeof(GRobjid));

           for(jj=0; jj< cp_info_list[ii]->num_adjacent; jj++)
             cp_info_list[ii]->adj_loops[jj] = adj_info_list[ii]->adj_loops[jj];

	    cp_info_list[ii]->comedge_cncv = 
		    (IGRint *)om$malloc( size = 
			  cp_info_list[ii]->num_adjacent * sizeof(IGRint));

            if( cp_info_list[ii]->affect&EM_ADDRFT_TRIM  ||  
               cp_info_list[ii]->affect&EM_ADDRFT_PIVOT  ||
                 (!cp_info_list[ii]->operate)  ||
	           cp_info_list[ii]->affect&EM_ADDRFT_INTRNL_LP )
   	   {
	    num_edges = buff_size = 0;

            stat_OM = om$send(msg = message EMSloop.EMget_edges(&msg_loc,
                                        1,
                                        EMS_OPT_NONDEG,
                                        &edges,
                                        &buff_size,
                                        &num_edges),
                        senderid = NULL_OBJID,
                        targetid = cp_info_list[ii]->the_loop,
                        targetos = cp_info_list[ii]->myself.osnum);
            EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

            cp_info_list[ii]->edges = 
               (GRobjid *)om$malloc( size = num_edges * sizeof(GRobjid));
            
            for(kk=0; kk<num_edges; kk++)
               cp_info_list[ii]->edges[kk] = edges[kk].objid;


            if(edges)
                {
                om$dealloc(ptr = edges);
                edges=NULL;
                }
            }

/* GET ADJACENT SURFACES FOR THE AFFECTED SURFACE'S COPIES ****/

        for(jj = 0; jj< adj_info_list[ii]->num_adjacent; jj++)
          {
          index = 0;
          if(!  EMget_cp_sf(&msg_loc,
                   *list_len,
                      adj_info_list,
                        &adj_info_list[ii]->adj_surfs[jj],
                           &cp_info_list[ii]->adj_surfs[jj], &index)  )
              cp_info_list[ii]->adj_surfs[jj] =
                              adj_info_list[ii]->adj_surfs[jj];

           cp_info_list[ii]->comedge_cncv[jj] =
                                        adj_info_list[ii]->comedge_cncv[jj];
          }
   }


/* GET COMMON EDGE INFORMATION FOR THE COPIED SURFS IF AVAILABLE */

 for(ii=0; ii< *list_len; ii++)
 {
  cp_info_list[ii]->commedges =
  (GRobjid *)om$malloc(size = cp_info_list[ii]->num_adjacent * sizeof(GRobjid));

  for(jj = 0; jj< adj_info_list[ii]->num_adjacent; jj++)
      cp_info_list[ii]->commedges[jj] = NULL_OBJID;

  for(jj = 0; jj< adj_info_list[ii]->num_adjacent; jj++)
    {
     index = 0;
     if( !EMget_inx_w_lp(&msg_loc, *list_len, adj_info_list,
                      &adj_info_list[ii]->adj_loops[jj], &index) )
           cp_info_list[ii]->commedges[jj] = adj_info_list[ii]->commedges[jj];
    }
  } 


/***********************************/
 for(ii=0; ii< *list_len; ii++)
 {
  if(adj_info_list[ii]->pos_orient != cp_info_list[ii]->pos_orient )
      {
      IGRint temp, num_adj, half_num_adj;

       num_adj = cp_info_list[ii]->num_adjacent;
       half_num_adj = num_adj/2.0;
      
       num_adj--;
       for(jj=0;jj< half_num_adj; jj++)
          {
           temp = cp_info_list[ii]->adj_loops[jj];
           cp_info_list[ii]->adj_loops[jj] =
                            cp_info_list[ii]->adj_loops[num_adj-jj] ;
           cp_info_list[ii]->adj_loops[num_adj-jj] = temp;

           temp = cp_info_list[ii]->adj_surfs[jj];
           cp_info_list[ii]->adj_surfs[jj] =
                            cp_info_list[ii]->adj_surfs[num_adj-jj] ;
           cp_info_list[ii]->adj_surfs[num_adj-jj] = temp;

           temp = cp_info_list[ii]->commedges[jj];
           cp_info_list[ii]->commedges[jj] =
                            cp_info_list[ii]->commedges[num_adj-jj] ;
           cp_info_list[ii]->commedges[num_adj-jj] = temp;

           if(cp_info_list[ii]->edges)
             {
             temp = cp_info_list[ii]->edges[jj];
             cp_info_list[ii]->edges[jj] = cp_info_list[ii]->edges[num_adj-jj] ;
             cp_info_list[ii]->edges[num_adj-jj] = temp;
             }

           temp = cp_info_list[ii]->comedge_cncv[jj];
           cp_info_list[ii]->comedge_cncv[jj] =
                            cp_info_list[ii]->comedge_cncv[num_adj-jj] ;
           cp_info_list[ii]->comedge_cncv[num_adj-jj] = temp;

           /***in the  original topology  .... ***/
           temp = adj_info_list[ii]->adj_loops[jj];
           adj_info_list[ii]->adj_loops[jj] =
                            adj_info_list[ii]->adj_loops[num_adj-jj] ;
           adj_info_list[ii]->adj_loops[num_adj-jj] = temp;

           temp = adj_info_list[ii]->adj_surfs[jj];
           adj_info_list[ii]->adj_surfs[jj] =
                            adj_info_list[ii]->adj_surfs[num_adj-jj] ;
           adj_info_list[ii]->adj_surfs[num_adj-jj] = temp;

           temp = adj_info_list[ii]->edges[jj];
           adj_info_list[ii]->edges[jj] =adj_info_list[ii]->edges[num_adj-jj] ;
           adj_info_list[ii]->edges[num_adj-jj] = temp;

           temp = adj_info_list[ii]->commedges[jj];
           adj_info_list[ii]->commedges[jj]
                                   =adj_info_list[ii]->commedges[num_adj-jj];
           adj_info_list[ii]->commedges[num_adj-jj] = temp;
          }
      }
  }
/***********************************/
    *cp_sf_info_list = cp_info_list;

    wrapup:

       if(ext_flag) om$dealloc(ptr = ext_flag);

       if(loop_ids)
           om$dealloc(ptr = loop_ids);

        if(the_surf_geom)
           om$dealloc(ptr=the_surf_geom);

        EMWRAPUP( *EMmsg, stat_OM, "EMcopy_adj_sfs");
        return (stat_OM);
}

/*
 * This is to get single/double draft, given the hinge and adj_sf_info
 */

IGRint D_SinDou_Draft(IGRlong *EMmsg,
                      struct GRmd_env *md_env,
                      struct EMSadj_surf_info *adj_info,
                      struct IGRbsp_surface **hinge_plane_geom,
                      IGRint  *draft_type)
{
  IGRint ind1,ind2;
  IGRdouble pt_xyz[6];
  IGRdouble diss=0.0;
  IGRboolean fflag, start,side;
  IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
  BSrc rc;
  IGRdouble chttol;
  IGRdouble u_par[1],v_par[1];
  IGRdouble pnts[3],nrml[3];
  struct IGRbsp_surface *hinge_geom=NULL;

  hinge_geom = *hinge_plane_geom;

  //get the tolearance
  BSEXTRACTPAR(&rc, BSTOLCHRDHT, chttol);

  //get the hinge plane point & normal.
  u_par[0] = v_par[0] = 0.5;
  BSsfarrevn(&rc,hinge_geom,1,u_par,1,v_par, pnts, nrml);
  EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  BSnorvec(&rc, nrml);

  start = TRUE;
  for(ind1=0;ind1<adj_info->num_adjacent;++ind1)
  {
    stat_OM = om$send(msg = message EMSedge.EMxyz_endpt(&msg_loc,
                            &adj_info->myself,&md_env->md_env,
                            NULL,NULL,&pt_xyz[0],&pt_xyz[3],NULL),
                 senderid = NULL_OBJID,
                 targetid = adj_info->edges[ind1],
                 targetos = adj_info->myself.osnum);
    EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    for(ind2=0;ind2<2;++ind2)
    {
         BSdistptpl(&rc,&pt_xyz[ind2*3],pnts,nrml,&diss);
         if(fabs(diss) < chttol) continue;
 
         BSptonnsdsf(hinge_geom,&pt_xyz[ind2*3],&side,&rc);
 
         if(start)
         { start=FALSE; fflag = side;}
         else
         {
           if(fflag !=side)
           {
             //double_draft
             *draft_type=2;
             goto wrapup;
           }
          }
     }
   }
   //single_draft
   *draft_type=1;

  wrapup:
  EMWRAPUP( *EMmsg, stat_OM, "D_SinDou_Draft");
  return(stat_OM);

}

/*
 * This function says for a given draft surface, the geometrical 
 * changes due to drafting of the surface, results in material
 * addition or removal.
 *
 * Return values:
 *
 *   *flag2  =  1  material addition
 *           = -1  material removal
 *           =  0  cannot decide (both)
 */
IGRint D_mat_addrem(IGRlong *EMmsg,
                    struct GRmd_env *md_env,
                    struct EMSadj_surf_info **adj_info_list,
                    IGRint list_len,
                    IGRint index,
                    struct  GRid *active_solid,
                    struct IGRbsp_surface  **hinge_plane_geom,
                    IGRint *flag2)
{
  IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
  struct IGRbsp_surface *the_surf_geom=NULL;
  IGRdouble ref1_point[3];
  IGRpoint *lo_point = NULL;
  struct EMparms params;
  BSrc rc;
  IGRdouble *u_pr=NULL, *v_pr=NULL;
  IGRlong nu_pts;
  IGRulong location;
  IGRint draft_type;
  extern void  EFget_surf_geom();
  
  //initialize 
  *flag2 = 0;

  //Get the geometry of the drafted surface
  EFget_surf_geom(EMmsg, md_env, adj_info_list[index]->copy,
                  adj_info_list[index]->myself.osnum, &the_surf_geom);

  //check for single/double draft
  stat_OM = D_SinDou_Draft(&msg_loc,md_env,adj_info_list[index],
                           hinge_plane_geom,&draft_type);
  EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  if(draft_type == 2) {*flag2 =0; goto wrapup;}

  /*
   * Get a reference point in the area region of the surface,
   * for deciding material addition or removal.
   */
  {
    IGRint attempt_no=0;
    IGRdouble tem_part_range[4];

    //Get the partial surface uv range of the drafted surface
    stat_OM = om$send(msg = message EMSsubbs.EMgetuvrange(&msg_loc,
                                                    tem_part_range),
                              senderid = NULL_OBJID,
                              targetid = adj_info_list[index]->copy,
                              targetos = adj_info_list[index]->myself.osnum);
    EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
 
    do
    {
    stat_OM = om$send(msg = message EMSsubbs.EMget_point_on_surface (
                            &msg_loc, md_env,0,1, ref1_point,&params),
                 senderid = NULL_OBJID,
                 targetid = adj_info_list[index]->myself.objid,
                 targetos = adj_info_list[index]->myself.osnum);
    EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    ++attempt_no;
    }while( params.u < tem_part_range[0] || params.u > tem_part_range[2] || 
            params.v < tem_part_range[1] || params.v > tem_part_range[3] );
  }

 
  //get the point on the drafted surface
  BSpj_pt_sf(the_surf_geom, ref1_point,params.normal,&nu_pts,&lo_point,
             &u_pr, &v_pr,&rc);
  EMerr_hndlr(rc!=BSSUCC,*EMmsg, EMS_E_BSerror, wrapup);

  if(nu_pts == 0) { *EMmsg = EMS_E_Fail;goto wrapup;}

  //classify the reference point wrt the base solid
  stat_OM = om$send(msg = message EMSsolid.EMpoint_locate(&msg_loc,
                          md_env, NULL, *lo_point, NULL, &location),
               senderid = NULL_OBJID,
               targetid = active_solid->objid,
               targetos = active_solid->osnum);
  EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  /*
   * If inside then the geometrical change due to drafting results
   * in removal of the material
   */
  if(location == EMS_S_INSOLID) *flag2 = -1;
  else *flag2 = 1;
  
  wrapup:
   if(the_surf_geom) {om$dealloc(ptr=the_surf_geom); the_surf_geom=NULL;}
   if(u_pr) {om$dealloc(ptr=u_pr);u_pr=NULL;}
   if(v_pr) {om$dealloc(ptr=v_pr);v_pr=NULL;}
   if(lo_point) {om$dealloc(ptr=lo_point);lo_point=NULL;}
    
   EMWRAPUP( *EMmsg, stat_OM, "D_mat_addrem");
   return (stat_OM);
}

/*
 * This function is to get the base solid id and its range
 */
IGRint D_get_solidinfo(IGRlong *EMmsg,
                       struct GRmd_env *md_env,
                       struct EMSadj_surf_info **adj_info_list,
                       struct  GRid *active_solid,
                       IGRdouble *slrange) 
{
  IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
  IGRboolean world=TRUE;

  //get the base solid id
  stat_OM = om$send(msg = message EMSsurface.EMgetactiveid(&msg_loc,
                          active_solid, NULL),
               senderid = NULL_OBJID,
               targetid = adj_info_list[0]->myself.objid,
               targetos = adj_info_list[0]->myself.osnum);
  EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
 
  //get the solid range
  stat_OM = om$send(msg = message GRgraphics.GRgetrang(&msg_loc,
                          &md_env->md_env.matrix_type,
                          md_env->md_env.matrix, &world, slrange),
               senderid = NULL_OBJID,
               targetid = active_solid->objid,
               targetos = active_solid->osnum );
  EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  wrapup:
  EMWRAPUP( *EMmsg, stat_OM, "D_get_solidinfo");
  return(stat_OM);
}

/*
 * This function is to get the hinge plane geometry
 */
IGRint D_get_hingegeom(IGRlong *EMmsg,
                       struct GRmd_env *md_env,
                       struct EMSadj_surf_info *adj_info,
                       GRobjid *hinges,
                       IGRdouble *slrange,
                       struct IGRbsp_surface **plane_geom)
{
  IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
  IGRdouble ext_dist,u_par[1],v_par[1],pnts[3],nrml[3];
  IGRboolean in_range=TRUE;
  IGRpoint plane_pt1, plane_pt0, plane_pt2;
  IGRint ind1;
  IGRdouble matrix[15];
  struct IGRbsp_surface *hinge_geom = NULL;
  BSrc rc;
  extern void EFget_surf_geom();

  if(EFisAncestryValid(&msg_loc,hinges[0],adj_info->myself.osnum,
                       OPP_EMSdatpln_class_id, FALSE))
  {
     //if reference plane
     stat_OM =om$send(msg = message EMSdatpln.EMget_pln_info(&msg_loc, NULL,
                            md_env,&matrix[0],&matrix[4], &matrix[8], 
                            &matrix[12], NULL),
                 senderid = NULL_OBJID,
                 targetid = hinges[0],
                 targetos = adj_info->myself.osnum);
     EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
     
     //get the extension distance for the defined plane.
     ext_dist = BSdistptpt(&rc,&slrange[0], &slrange[3]);

     for(ind1=0;ind1 <3; ind1++)
     {
       plane_pt1[ind1] = matrix[ind1+12]+
                       10*(matrix[ind1]*ext_dist- matrix[ind1+4]*ext_dist);
       plane_pt2[ind1] = matrix[ind1+12]+
                       10* (matrix[ind1+4]*ext_dist - matrix[ind1]*ext_dist);
       plane_pt0[ind1] = matrix[ind1+12]-
                       10 * (matrix[ind1+4]*ext_dist + matrix[ind1]*ext_dist);
     }
 
     BSallocsf( 2, 2, 2, 2, 0, 0, &hinge_geom, &rc);
     EMerr_hndlr (!hinge_geom, *EMmsg, EMS_E_NoDynamicMemory,wrapup);
 
     BSplane3pt(&rc, plane_pt0, plane_pt1, plane_pt2, hinge_geom);
     EMerr_hndlr(rc!=BSSUCC,*EMmsg, EMS_E_BSerror, wrapup);
  }
  else
  {
     EFget_surf_geom(&msg_loc, md_env,hinges[0],
                     adj_info->myself.osnum,&hinge_geom);
     u_par[0] = v_par[0] = 0.5;
     BSsfarrevn(&rc, hinge_geom, 1, u_par, 1, v_par,pnts,nrml);
     EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     BSnorvec(&rc, nrml);

     BSplptnorrg(&slrange[0], &slrange[3], pnts, nrml, 1.0,&in_range,
                 hinge_geom, &rc);
     EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  }
  *plane_geom = hinge_geom;

  wrapup:
   EMWRAPUP( *EMmsg, stat_OM, "D_get_hingegeom");
   return(stat_OM);
}

/*
 * This function is to get the common edge angle, given the
 * the affected surface list and the id for the draft surface
 * and the surface under consideration.
 *
 *   angle type = 0 concave
 *              = 1 convex 
 *              = 2 neutral
 *              = 3 other cases
 */
IGRint D_get_angletype(struct EMSadj_surf_info **adj_info_list,
                       IGRint list_len,
                       GRobjid draft_surf,
                       GRobjid adj_surf)
{
  IGRint ind1,ind2;
  IGRint angle_type = 3;
 
  for(ind1=0;ind1<list_len;++ind1)
    if(adj_info_list[ind1]->myself.objid == draft_surf) break;

  for(ind2=0;ind2<adj_info_list[ind1]->num_adjacent;++ind2)
  {
    if(adj_info_list[ind1]->adj_surfs[ind2] != adj_surf) continue;
    angle_type = adj_info_list[ind1]->comedge_cncv[ind2];
  }
  
  return(angle_type);
}

/*
 * This function says whether the adjacent surface(loop) for the draft
 * surface is a P-loop or a C-loop
 * 
 * Return values
 *
 *   *flag  = 0  C-loop
 *          = 1  P-loop  
 *          = 2  error case
 */
IGRint D_adjloop(IGRlong *EMmsg,
                 struct EMSadj_surf_info **adj_info_list,
                 IGRint list_len,
                 GRobjid draft_surf,
                 GRobjid adj_surf,
                 IGRint *flag)
{
  IGRint ind1,ind2;
  IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success; 
  IGRushort props;
  *flag = 2;
  
  for(ind1=0;ind1<list_len;++ind1)
    if(adj_info_list[ind1]->myself.objid == draft_surf) break;
 
  for(ind2=0;ind2<adj_info_list[ind1]->num_adjacent;++ind2)
  {
    if(adj_info_list[ind1]->adj_surfs[ind2] != adj_surf) continue;
    stat_OM = om$send (msg = message EMSloop.EMget_props (&msg_loc,
                             &props),
                  senderid = NULL_OBJID,
                  targetid = adj_info_list[ind1]->adj_loops[ind2],
                  targetos = adj_info_list[ind1]->myself.osnum);
    EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    if(!(props & EMLP_PLOOP)) *flag = 0;
    else *flag = 1;
  }

  wrapup:
  EMWRAPUP( *EMmsg, stat_OM, "D_adjloop");
  return(stat_OM);
} 



/*
 * This is the root function for the extension requirement check
 * based on the face topology and geometry.
 *
 * Algorithm:
 *
 *           Add      Rem
 *         ---------------
 *    cx  |  R        NR
 *    cc  |  NR       R
 *
 * Edge type cx/cc;  Material Add/Rem 
 *
 * Return values
 * 
 *  for each surface
 *   ext_flag = 0 No extension
 *            = 1 Extension required
 */
IGRint D_Check_ext(IGRlong *EMmsg,
                   struct GRmd_env *md_env,
                   struct EMSadj_surf_info **adj_info_list,
                   IGRint list_len,
                   GRobjid *hinges,
                   IGRint *ext_flag)           
{
  IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
  BSrc rc;
  IGRint ind1,ind2,ind3;
  struct IGRbsp_surface *hinge_geom = NULL;
  IGRdouble slrange[6];
  struct GRid active_solid;
  IGRint flag2,flag3,flag4;

  /*
   * Initialize the extension flag for all the affected surfaces
   * to some tag value(common value, default extension required)
   */
  for(ind1=0;ind1<list_len;++ind1) ext_flag[ind1] = -1;

  /*
   * If the surface is hinge plane then set for NO EXT 
   */
  for(ind1=0;ind1<list_len;++ind1)
    if(hinges && hinges[0] == adj_info_list[ind1]->myself.objid)
      ext_flag[ind1] = 0;

  //get the base solid info
  stat_OM = D_get_solidinfo(&msg_loc, md_env, adj_info_list,&active_solid,
                            slrange);
  EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  //get the hinge plane geom
  stat_OM = D_get_hingegeom(&msg_loc, md_env, adj_info_list[0],hinges,
                            slrange, &hinge_geom); 
  EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  //Process for every draft surface
  for(ind1=0;ind1<list_len;++ind1)
  {
     if(!(adj_info_list[ind1]->affect&EM_ADDRFT_DRAFT_SRF)) continue;
     ext_flag[ind1] = 0;

     //get whether material addition or removal
     stat_OM = D_mat_addrem(&msg_loc, md_env, adj_info_list, list_len,    
                            ind1,&active_solid,&hinge_geom, &flag2);
     EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

     //for every draft surface adjacents
     for(ind2=0;ind2<adj_info_list[ind1]->num_adjacent;++ind2)
     {
       //get the index
       for(ind3=0;ind3<list_len;++ind3)
        if(adj_info_list[ind1]->adj_surfs[ind2] == 
           adj_info_list[ind3]->myself.objid) break;
       if(ind3 >=list_len) continue;

       //if flag set already to ext required, continue
       if(ext_flag[ind3] == 1) continue;

       //if both mat add & removal then ext required
       if(flag2 == 0) {ext_flag[ind3] = 1; continue;}

       //if adjacent to draft surf. is a c-loop NO EXT
       stat_OM = D_adjloop(&msg_loc,adj_info_list,list_len,
                           adj_info_list[ind1]->myself.objid,
                           adj_info_list[ind3]->myself.objid, &flag3);
       EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

       if(flag3 == 0) {ext_flag[ind3] = 0; continue;}
       else if(flag3 == 2) {ext_flag[ind3] = 1; continue;}

       //get commenedge angle
       flag4 = D_get_angletype(adj_info_list,list_len,
                               adj_info_list[ind1]->myself.objid,
                               adj_info_list[ind3]->myself.objid);
       if(flag4>=2) {ext_flag[ind3] = 1; continue;}

       switch(flag2)
       {
         case 1: 
                 if(flag4 == 1) ext_flag[ind3] = 1;
                 else ext_flag[ind3] = 0;
                 break;
         case -1:
                 if(flag4 == 1) ext_flag[ind3] = 0;
                 else ext_flag[ind3] = 1;
                 break;
        }
     }
  } 

  //failure cases
  for(ind1=0;ind1<list_len;++ind1)
   if(ext_flag[ind1] == -1) ext_flag[ind1] = 1;
  
  wrapup:
  if(hinge_geom) {om$dealloc(ptr=hinge_geom); hinge_geom=NULL;}
  EMWRAPUP( *EMmsg, stat_OM, "D_Check_ext");
  return(stat_OM);
}

/***********************************************************************/
IGRboolean   EMget_inx_w_lp(EMmsg, list_len, info_list, loop, index)
   IGRlong *EMmsg;
   struct EMSadj_surf_info  **info_list;
   GRobjid *loop;
   IGRint list_len;
   IGRint *index;
{
    IGRint ii=0;
    IGRboolean   found=FALSE;

    for(ii=0; ii< list_len; ii++)
      {
      if(info_list[ii]->the_loop == *loop)
        {
          found = TRUE;
          *index = ii;
          break;
        }
      }
     return (found);
}

/*********************************************************************/
IGRboolean   EMget_cp_sf(EMmsg, list_len, info_list, surf, copy, index)
   IGRlong *EMmsg;
   struct EMSadj_surf_info  **info_list;
   GRobjid *surf, *copy;
   IGRint list_len;
   IGRint *index;
{
    IGRint ii;
    IGRboolean   found=FALSE;

    for(ii=0; ii< list_len; ii++)
      {
      if(info_list[ii]->myself.objid == *surf)
        {
        /*
        if(info_list[ii]->affect&EM_ADDRFT_EXTND)
             *copy = NULL_OBJID;
        else
        */
             *copy = info_list[ii]->copy;
        found = TRUE;
        *index = ii;
        break;
        }
      }
     return (found);
}
/***********************************************************************/
IGRboolean   EMget_inx_w_sf(EMmsg, list_len, info_list, surf, index)
   IGRlong *EMmsg;
   struct EMSadj_surf_info  **info_list;
   GRobjid *surf;
   IGRint list_len;
   IGRint *index;
{
    IGRint ii=0;
    IGRboolean   found=FALSE;

    for(ii=0; ii< list_len; ii++)
      {
      if(info_list[ii]->myself.objid == *surf)
        {
          found = TRUE;
          *index = ii;
          break;
        }
      }
     return (found);
}


end  implementation EMSsubbs;



