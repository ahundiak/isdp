/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgencompsf;

#include "EMS.h"

#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "emsdef.h"
# include "EMSbnddef.h"
# include "emsdattyp.h"
# include "emsinter.h"
# include "EMSbnd.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsfreecv.h"
#include "bsbxint.h"

#define INITIAL_SIZE 		64
#define INCREMENT		32
#define INIT_EDGE_BUF_SIZE	64
#define INIT_SURF_BUF_SIZE	8
#define EDGE_BUF_INCREMENT	32
#define SURF_BUF_INCREMENT	4

from EMSedge import EMget_bcxyz_geom, EMget_props, EMget_top_part_edges,
		    EMstitch;


method EMmake_comp (IGRlong *EMmsg;
		 IGRint num_comps;
		 GRobjid *comps;
		 struct GRmd_env *mod_info)


/*
Description

    This method makes or adds surfaces to a composite surface. It accepts an
    array of components (each a surfcae or a composite) and  stitches them 
    (one-by-one) onto the existing/new composite surface.

Return values 

    EMS_S_Success 		 if all is well.

    EMS_I_Fail			 if composite surface cannot be made/added to
				 this means that not a single stitch could 
				 be made.

Notes


Change history:

    RV		09/01/87	Creation
    rlw         04/04/88        A couple of pointers were not being
                                initialized.
    BL		23/06/89	corrected surf_geom allocate struct from
				IGRbsp_curve to IGRbsp_surface.
    Tapadia     08/05/91 	Argument of GRgetrang was not correctly passed.

    Sudha       06/21/93        Modified to handle BSprototype ansification
*/

{
 IGRlong	     	OM_stat;    
 OM_S_CHANSELECT     	to_comps;
 struct GRid		my_GRid,
			*my_edges = NULL, *comp_edges = NULL;
 GRobjid		*my_surf_list = NULL, *comp_surf_list = NULL;
 IGRint			*my_numed_list = NULL, *comp_numed_list = NULL;
 IGRint			my_buf_size = 0, comp_buf_size = 0,
			num_my_edges = 0, num_comp_edges = 0,
 		        num_comps_joined = 0, current_comp = 0, 
			my_list_size = 0, comp_list_size = 0,
			num_in_my_list = 0, num_in_comp_list = 0,
			my_ed_bgn, cp_ed_bgn, my_ed_end, cp_ed_end,
			my_ed_ix, cp_ed_ix, my_sf_ix, cp_sf_ix,
			pairs_buf_size = INITIAL_SIZE, num_pairs;
 OMuint count;
 GRobjid		*waiting_list = NULL;
 IGRint			num_waiting = 0, waiting_list_size = 4;
 struct EMSstitch_info  *pairs = NULL;
 GRrange		my_surf_range, comp_surf_range;
 IGRdouble		dis_tol;
 IGRboolean 		was_empty = FALSE, current_comp_joined;
 GRobjid	     *surf_list = NULL, *edge_list = NULL;
 struct IGRbsp_surface **surf_geom = NULL;
 struct IGRbsp_curve **edge_geom = NULL;
 IGRint		     edge_buf_size = INIT_EDGE_BUF_SIZE;
 IGRint		     surf_buf_size = INIT_SURF_BUF_SIZE;
 IGRint		     num_in_surf_list = 0, num_in_edge_list = 0;
 IGRboolean	     geom0_found, geom1_found;
 IGRint		     surf0_idx, surf1_idx, edge0_idx, edge1_idx;
 IGRushort   props;
 IGRint              pair_idx, idx, num_stitches, surf_size;
 BSrc		     rc;
 IGRboolean world = FALSE;


 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
    
 to_comps.type = OM_e_addr;
 to_comps.u_sel.addr = &ME.GRcmpowner->to_components;
 
 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 OM_stat = om$get_channel_count(object = me,
				p_chanselect = &to_comps,
				count = &count);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);	

 if (!count)
 {
   was_empty = TRUE;
   OM_stat = om$send(msg = message EMSsurface.EMmovesurfs(EMmsg,
							 &my_GRid,
							 mod_info),
			   targetid = comps[current_comp++]);
   EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);	
   num_comps_joined++;
 }

 pairs = (struct EMSstitch_info *) om$malloc( 
      size = (unsigned) (pairs_buf_size) * sizeof(struct EMSstitch_info));
 EMerr_hndlr (!(pairs),*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);

 waiting_list = (GRobjid *) om$malloc( 
      size = (unsigned) (waiting_list_size) * sizeof(GRobjid));
 EMerr_hndlr (!(waiting_list),*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);

 edge_geom = (struct IGRbsp_curve **) om$malloc(size = (OMuint)
				 INIT_EDGE_BUF_SIZE * sizeof(char *));
 EMerr_hndlr(!edge_geom,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);   
 edge_list = (GRobjid *) om$malloc(size = (OMuint)
				 INIT_EDGE_BUF_SIZE * sizeof(GRobjid));
 EMerr_hndlr(!edge_list,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);   
 surf_geom = (struct IGRbsp_surface **) om$malloc(size = (OMuint)
				 INIT_SURF_BUF_SIZE * sizeof(char *));
 EMerr_hndlr(!surf_geom,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);   
 surf_list = (GRobjid *) om$malloc(size = (OMuint)
				 INIT_SURF_BUF_SIZE * sizeof(GRobjid));
 EMerr_hndlr(!surf_list,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);   
 
 BSEXTRACTPAR(&rc, BSTOLLENVEC, dis_tol);
 EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

 while (current_comp < num_comps)
 {
   num_my_edges = num_comp_edges = 0;
   num_in_my_list = num_in_comp_list = 0;
   current_comp_joined = FALSE;

   OM_stat = om$send(msg = message EMSsurface.EMgetedges(EMmsg,
					EMS_OPT_CONNECTABLE,
					&my_edges,
					&my_buf_size,
					&num_my_edges,
					&my_surf_list,
					&my_numed_list,
					&my_list_size,
					&num_in_my_list),
			   targetid = my_id);
   EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);		   

   OM_stat = om$send(msg = message EMSsurface.EMgetedges(EMmsg,
					EMS_OPT_CONNECTABLE,
					&comp_edges,
					&comp_buf_size,
					&num_comp_edges,
					&comp_surf_list,
					&comp_numed_list,
					&comp_list_size,
					&num_in_comp_list),
			   targetid = comps[current_comp]);
   EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);		   

   num_pairs = 0;
   my_ed_bgn = cp_ed_bgn = 0;

   for (my_sf_ix=0; my_sf_ix<num_in_my_list; my_sf_ix++)
   {
     my_ed_end = my_ed_bgn + my_numed_list[my_sf_ix];
     cp_ed_bgn = 0;
     OM_stat = om$send(msg = message GRvg.GRgetrang(EMmsg,
					&mod_info->md_env.matrix_type,
					mod_info->md_env.matrix,
					&world,
					my_surf_range),
			     targetid = my_surf_list[my_sf_ix]);
     EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);	

     my_surf_range[0] -= dis_tol;
     my_surf_range[1] -= dis_tol;
     my_surf_range[2] -= dis_tol;
     my_surf_range[3] += dis_tol;
     my_surf_range[4] += dis_tol;
     my_surf_range[5] += dis_tol;

     for (cp_sf_ix=0; cp_sf_ix<num_in_comp_list; cp_sf_ix++)
     {
        cp_ed_end = cp_ed_bgn + comp_numed_list[cp_sf_ix];
	OM_stat = om$send(msg = message GRvg.GRgetrang(EMmsg,
					&mod_info->md_env.matrix_type,
					mod_info->md_env.matrix,
					&world,
					comp_surf_range),
			  	targetid = comp_surf_list[cp_sf_ix]);
        EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);	

        comp_surf_range[0] -= dis_tol;
        comp_surf_range[1] -= dis_tol;
        comp_surf_range[2] -= dis_tol;
        comp_surf_range[3] += dis_tol;
        comp_surf_range[4] += dis_tol;
        comp_surf_range[5] += dis_tol;

        if (! BSbxint(&rc, &my_surf_range[0],   &my_surf_range[3],
			     &comp_surf_range[0], &comp_surf_range[3]))
	{
		cp_ed_bgn = cp_ed_end;
		continue;
	}
        EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);	
	for (my_ed_ix=my_ed_bgn; my_ed_ix<my_ed_end; my_ed_ix++)
	{
	  for (cp_ed_ix=cp_ed_bgn; cp_ed_ix<cp_ed_end; cp_ed_ix++)
	  {
		if (num_pairs >= pairs_buf_size)
		{
		   (pairs_buf_size) += INCREMENT;
  		   pairs = (struct EMSstitch_info *) om$realloc(ptr = 
                           (IGRchar *)pairs, size = (unsigned) 
			(pairs_buf_size) * sizeof(struct EMSstitch_info));
     		   EMerr_hndlr (!(pairs),*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
		}
	  	pairs[num_pairs].surf0 = my_surf_list[my_sf_ix];
	  	pairs[num_pairs].edge0 = my_edges[my_ed_ix].objid;
	  	pairs[num_pairs].surf1 = comp_surf_list[cp_sf_ix];
	  	pairs[num_pairs].edge1 = comp_edges[cp_ed_ix].objid;

		geom0_found = FALSE;
		geom1_found = FALSE;
		for (idx=0; idx<num_in_surf_list; idx++)
		{
		  if (pairs[num_pairs].surf0 == surf_list[idx])
		  {geom0_found = TRUE; surf0_idx = idx;}
		  if (pairs[num_pairs].surf1 == surf_list[idx])
		  {geom1_found = TRUE; surf1_idx = idx;}
		  if (geom0_found && geom1_found) break;
		}
		if((!geom0_found || !geom1_found) && 
		   num_in_surf_list > surf_buf_size-2)
		{
		  surf_buf_size += SURF_BUF_INCREMENT;
	          surf_list = (GRobjid *) om$realloc(ptr=(IGRchar *)surf_list, 
		      size = (OMuint) (surf_buf_size) * sizeof(GRobjid));
		  EMerr_hndlr(!(surf_list),*EMmsg,
				EMS_E_DynamicMemoryAllocated,wrapup);
	  	  surf_geom = (struct IGRbsp_surface **) 
			om$realloc(ptr = (IGRchar *)surf_geom, 
		        size = (OMuint) (surf_buf_size) * sizeof(char *));
		  EMerr_hndlr(!(surf_list),*EMmsg,
				EMS_E_DynamicMemoryAllocated,wrapup);
		}
		if (!geom0_found)
		{
		  OM_stat = om$send (msg = message GRvg.GRgetsize(EMmsg,
	 	    	               &mod_info->md_env.matrix_type,
	  	    	               mod_info->md_env.matrix,
 	  	     	               (IGRlong *) &surf_size),
	    	             targetid = pairs[num_pairs].surf0);
		  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

                 if ((surf_geom[num_in_surf_list] = (struct IGRbsp_surface *)
		 om$malloc (size = (int) surf_size)) == NULL)
		 {*EMmsg = EMS_E_DynamicMemoryAllocated; goto wrapup;}

		  OM_stat = om$send(msg = message GRvg.GRgetgeom (EMmsg,
 		                   &mod_info->md_env.matrix_type,
  		                   mod_info->md_env.matrix,
   	 	            (IGRchar *) surf_geom[num_in_surf_list]),
    		             targetid = pairs[num_pairs].surf0);
		  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

		  surf_list[num_in_surf_list] = pairs[num_pairs].surf0;
		  surf0_idx = num_in_surf_list++;
		}	/* if !geom0_found */

		if (!geom1_found)
		{
		  OM_stat = om$send (msg = message GRvg.GRgetsize(EMmsg,
 	  	  	               &mod_info->md_env.matrix_type,
  	  	  	               mod_info->md_env.matrix,
   	  	   	               (IGRlong *)&surf_size),
    	  	           targetid = pairs[num_pairs].surf1);
		  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

		  surf_geom[num_in_surf_list] = NULL;
		  if ((surf_geom[num_in_surf_list] = (struct IGRbsp_surface *) 
			om$malloc (size = (OMuint) surf_size)) == NULL)
		    {*EMmsg = EMS_E_DynamicMemoryAllocated; goto wrapup;}

		  OM_stat = om$send(msg = message GRvg.GRgetgeom (EMmsg,
 		                   &mod_info->md_env.matrix_type,
  		                   mod_info->md_env.matrix,
   	 	              (IGRchar *)surf_geom[num_in_surf_list]),
    		             targetid = pairs[num_pairs].surf1);
		  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

		  surf_list[num_in_surf_list] = pairs[num_pairs].surf1;
		  surf1_idx = num_in_surf_list++;

		} /* if !geom1_found */

		geom0_found = FALSE;
		geom1_found = FALSE;
		for (idx=0; idx<num_in_edge_list; idx++)
		{
		  if (pairs[num_pairs].edge0 == edge_list[idx])
		  {geom0_found = TRUE; edge0_idx = idx;}
		  if (pairs[num_pairs].edge1 == edge_list[idx])
		  {geom1_found = TRUE; edge1_idx = idx;}
		  if (geom0_found && geom1_found) break;
		}
		if((!geom0_found || !geom1_found) && 
		   num_in_edge_list > edge_buf_size-2)
		{
		  edge_buf_size += EDGE_BUF_INCREMENT;
	          edge_list = (GRobjid *) om$realloc(ptr=(IGRchar *)edge_list, 
		      size = (OMuint) (edge_buf_size) * sizeof(GRobjid));
		  EMerr_hndlr(!(edge_list),*EMmsg,
				EMS_E_DynamicMemoryAllocated,wrapup);
	  	  edge_geom = (struct IGRbsp_curve **) 
				om$realloc(ptr = (IGRchar *)edge_geom, 
		      size = (OMuint) (edge_buf_size) * sizeof(char *));
		  EMerr_hndlr(!(edge_list),*EMmsg,
				EMS_E_DynamicMemoryAllocated,wrapup);
		}
		if (!geom0_found)
		{
		  edge_geom[num_in_edge_list] = NULL;
		  edge_geom[num_in_edge_list] = (struct IGRbsp_curve *)
		       om$malloc(size = (OMuint) sizeof(struct IGRbsp_curve));
		  EMerr_hndlr(!edge_geom[num_in_edge_list],*EMmsg,
				EMS_E_DynamicMemoryAllocated,wrapup);   
		  edge_geom[num_in_edge_list]->poles = NULL;
	          edge_geom[num_in_edge_list]->knots = NULL;
	          edge_geom[num_in_edge_list]->weights = NULL;
	          edge_geom[num_in_edge_list]->bdrys = NULL;

		  OM_stat = om$send(msg =  message EMSedge.EMget_props(EMmsg,
								 &props),
				     targetid = pairs[num_pairs].edge0);
		  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

		  OM_stat = om$send (msg = message EMSedge.EMget_bcxyz_geom(
					 EMmsg,
				   	 NULL, NULL, surf_geom[surf0_idx],
					 0, OM_K_MAXINT,
				(props & EMED_REVERSED ? TRUE : FALSE),
					 NULL, edge_geom[num_in_edge_list]),   
			     targetid = pairs[num_pairs].edge0);
	          EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

		  edge_list[num_in_edge_list] = pairs[num_pairs].edge0;
		  edge0_idx = num_in_edge_list++;
		}	/* if !geom0_found */

		if (!geom1_found)
		{
		  edge_geom[num_in_edge_list] = NULL;
		  edge_geom[num_in_edge_list] = (struct IGRbsp_curve *)
		      om$malloc(size = (OMuint) sizeof(struct IGRbsp_curve));
		  EMerr_hndlr(!edge_geom[num_in_edge_list],*EMmsg,
				EMS_E_DynamicMemoryAllocated,wrapup);   
		  edge_geom[num_in_edge_list]->poles = NULL;
	          edge_geom[num_in_edge_list]->knots = NULL;
	          edge_geom[num_in_edge_list]->weights = NULL;
	          edge_geom[num_in_edge_list]->bdrys = NULL;

		  OM_stat = om$send(msg =  message EMSedge.EMget_props(EMmsg,
								 &props),
			     	targetid = pairs[num_pairs].edge1);
		  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

		  OM_stat = om$send (msg = message EMSedge.EMget_bcxyz_geom(
					 EMmsg,
				   	 NULL, NULL, surf_geom[surf1_idx],
					 0, OM_K_MAXINT,
				(props & EMED_REVERSED ? TRUE : FALSE),
					 NULL, edge_geom[num_in_edge_list]),   
			     targetid = pairs[num_pairs].edge1);
	          EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

		  edge_list[num_in_edge_list] = pairs[num_pairs].edge1;
		  edge1_idx = num_in_edge_list++;
		}	/* if !geom1_found */

	  	pairs[num_pairs].surf_geom0 = surf_geom[surf0_idx];
	  	pairs[num_pairs].surf_geom1 = surf_geom[surf1_idx];
	  	pairs[num_pairs].edge_geom0 = edge_geom[edge0_idx];
	  	pairs[num_pairs].edge_geom1 = edge_geom[edge1_idx];
		pairs[num_pairs].option = 0x0;
		num_pairs++;		
	  }
	}
	cp_ed_bgn = cp_ed_end;
     }
     my_ed_bgn = my_ed_end;
   }
   
   if (num_pairs)
   {
     num_stitches = 0;
     for (pair_idx=0;pair_idx<num_pairs;pair_idx++)
     {
        OM_stat = om$send(msg = message EMSedge.EMstitch(EMmsg,
				&pairs[pair_idx],
                                mod_info,
				&my_GRid,
				NULL, NULL, NULL, NULL),
                        targetid = pairs[pair_idx].edge0);
        EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);

        if (*EMmsg == EMS_I_Fail)  *EMmsg = EMS_S_Success;
	else  num_stitches++;
     }   
     if (num_stitches)     
     {
	current_comp_joined = TRUE;
   	num_comps_joined++;
     }
   }

   if (! current_comp_joined)
   {
     if (num_waiting >= waiting_list_size)
     {
        (waiting_list_size) += INCREMENT;
        waiting_list = (GRobjid *) om$realloc(ptr = (IGRchar *)waiting_list, 
            size = (unsigned) 	(waiting_list_size) * sizeof(GRobjid));
        EMerr_hndlr (!(waiting_list),*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
     }
     waiting_list[num_waiting++] = comps[current_comp];
   }
   current_comp++;
 }


 if (num_comps_joined == 1)
 {
    OM_stat = om$get_channel_count(object = me,
				p_chanselect = &to_comps,
				count = &count);
    EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);	
 
    if (count == 1)
    {
	struct GRid		my_obj;

	my_obj.objid = my_id;
	my_obj.osnum = OM_Gw_current_OS;

        OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg, &my_obj),
	                      p_chanselect = &to_comps);
        EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 	num_comps_joined--;
    }
    else if (was_empty) num_comps_joined--;
 }

 if (! num_comps_joined) *EMmsg = EMS_I_Fail;
 else if (num_waiting)
 {
     OM_stat = om$send(msg = message EMSgencompsf.EMmake_comp(EMmsg,
							num_waiting,
							waiting_list,
							mod_info),
		       targetid = my_id);
     EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);	

     if (*EMmsg != EMS_S_Success) *EMmsg = EMS_S_Success;
 }
 else *EMmsg = EMS_S_Success;

 wrapup:

  if (my_edges) om$dealloc(ptr = my_edges);
  if (my_surf_list) om$dealloc(ptr = my_surf_list);
  if (my_numed_list) om$dealloc(ptr = my_numed_list);
  if (comp_edges) om$dealloc(ptr = comp_edges);
  if (comp_surf_list) om$dealloc(ptr = comp_surf_list);
  if (comp_numed_list) om$dealloc(ptr = comp_numed_list);
  if (pairs) om$dealloc(ptr = pairs);
  if (waiting_list) om$dealloc(ptr = waiting_list);
   
   for(idx=0; idx<num_in_surf_list; idx++)
   {
     if (surf_geom[idx]) om$dealloc(ptr = surf_geom[idx]);
   }
   for(idx=0; idx<num_in_edge_list; idx++)
   {
     if (edge_geom[idx]) BSfreecv(&rc, edge_geom[idx]);
   }
   if (surf_geom) om$dealloc(ptr = surf_geom);
   if (edge_geom) om$dealloc(ptr = edge_geom);
   if (surf_list) om$dealloc(ptr = surf_list);
   if (edge_list) om$dealloc(ptr = edge_list);


  EMWRAPUP(*EMmsg, OM_stat, "In EMSgencompsf.EMmake_comp")
  return (OM_stat);
}
end  implementation EMSgencompsf;

