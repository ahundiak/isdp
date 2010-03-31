class implementation NMnonmanist;

#ifndef DEBUG
#define DEBUG 0
#endif

#define IN_PAIRS_IMPLEMENTED_FOR_NMSTITCH 0

/* 
  Added one more argument - the osnum of the split edge - to the static
  function - NMupdateEd(). 
 
           - Fix for TR. 169307309 - Vadi - 10/11/93.
*/

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
#include "OMmacros.h"
#include "grownerdef.h"
#include "msmacros.h"
#include "NMmsg.h"

#include "bsfreecv.h"
#include "bsbx2.h"
#include "bsbxint.h"

#define INITIAL_SIZE 		64
#define INCREMENT		32
#define INIT_EDGE_BUF_SIZE	64
#define INIT_SURF_BUF_SIZE	8
#define EDGE_BUF_INCREMENT	32
#define SURF_BUF_INCREMENT	4
#define EdInc			10
#define SfInc			5
#define NmInc			10
#define TpEdSize		4

#define ConnBuf		500

#define Pass1Tol	bastol+bastol
#define Pass2Tol	bastol+cht
#define Pass3Tol	cht+cht

#define StaticBuf	10

from EMSedge import EMget_bcxyz_geom, EMget_props, EMget_top_part_edges;

from EMSsurface import EMputLsIfNotThere, EMgetactiveid;
from EMSsurface import EMtransform_to_associative;
from NMvertex import NMcheck;

extern IGRboolean NMvertex_display_and_Rtree, NMedgevtxuse_assoc;
IGRint	        NMgetGeom(), NMupdateEd();
void	        NMfree_geom(), NMcompress_list();
void	NMfree_geom();
extern IGRboolean IGEstop() ;
 extern IGRint		EMmake_chanselect(), EMgetvggeom();
method NMperform_stitch (IGRlong *EMmsg;
		 	 IGRint num_comps;
		 	 struct GRid *comps;
		 	 struct GRmd_env *mod_info;
		 	 struct EMSstitch_info *in_pairs;
		 	 IGRint in_num_pairs;
		 	 struct EMSstitch_geominfo *geom;
		         struct NMgmSSI *in_ssi;
		 	 unsigned short makecs_options, nm_options;
			 struct GRvg_construct *construct; IGRchar *status_str)


{
 IGRlong	     	sts;    
 OM_S_CHANSELECT     	to_common;
 struct GRid		my_GRid,
			*my_edges = NULL, *comp_edges = NULL;
 GRobjid		*my_surf_list = NULL, *comp_surf_list = NULL, 
			part_edges[2][MaxNumPe], 
			*myed_tped = NULL, *comped_tped = NULL;
 IGRint			*my_numed_list = NULL, *comp_numed_list = NULL, i, 
			j, num_myed_tped = 0, num_comped_tped = 0, 
			myed_tped_size = 0, comped_tped_size = 0;
 IGRint			my_buf_size = 0, comp_buf_size = 0,
			num_my_edges = 0, num_comp_edges = 0,
 		        current_comp = 0, 
			my_list_size = 0, comp_list_size = 0,
			num_in_my_list = 0, num_in_comp_list = 0,
			my_ed_bgn, cp_ed_bgn, my_ed_end, cp_ed_end,
			my_ed_ix, cp_ed_ix, my_sf_ix, cp_sf_ix,
			iteration = 0, my_tped_ix, cp_tped_ix;
 IGRlong		idx = MAXINT;
 struct EMSstitch_info  thispair;
 IGRint                 total_stitches = 0;
 BSrc		        rc;
 struct NMgmSSI		ssi, *ssiptr = NULL;
 IGRboolean 		interrupt = FALSE, 
			newly_connected[2], was_connected[2], 
			*added_once = NULL, added_oncebuf[ConnBuf],
			world = FALSE;
 IGRboolean		only_one = FALSE, atleast_one_stitch,
			first_run = TRUE;
 struct EMSstitch_geominfo loc_geom;
 struct IGRbsp_curve	*edge_geom[2];
 struct IGRbsp_surface  *surf_geom[2];
 GRrange		myrange, comprange, mysfrange, compsfrange, 
			myedrange, compedrange;
 IGRdouble		cht, bastol, stitol, rangeinc;
 GRobjid		*comps_to_connect = NULL, 
			comps_to_connect_buf[StaticBuf], savecrt;
 GRspacenum             spltedos;
 IGRint			num_comps_to_connect = 0, my_numparents = 0;
 struct EMSobject_info	*my_parents = NULL, my_parentsbuf[StaticBuf];
 struct GRid		*my_base = NULL, my_basebuf[StaticBuf];
 IGRboolean		*my_trans = NULL, my_transbuf[StaticBuf], 
			tempcrt = FALSE;
 extern OM_S_OBJID	current_creator;
 IGRchar		locsts_str[200], dot[2];

 sts = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 NMinit_ssi(&ssi);
 BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht);
 BSEXTRACTPAR(&rc, BSTOLLENVEC, bastol);
 ssiptr = in_ssi ? in_ssi : &ssi;
 if(nm_options & NMstch_TempCreator) tempcrt = TRUE;

 if(status_str) strcpy (dot, ".");
 if(status_str) strcpy(locsts_str, status_str);

 if(!tempcrt) current_creator = my_id;

 if(in_pairs) num_comps = 0;
 if(num_comps == 1) only_one = TRUE;
 loc_geom.surf_geom = NULL;
 loc_geom.edge_geom = NULL;
 loc_geom.edgerange = NULL;
 loc_geom.surfrange = NULL;
 loc_geom.surf_list = NULL;
 loc_geom.edge_list = NULL;
 loc_geom.numsf = 0;
 loc_geom.numed = 0;
 loc_geom.surf_buf_size = 0;
 loc_geom.edge_buf_size = 0;
 if(!geom) geom = &loc_geom; 

 EMmake_chanselect(EMSedge_to_common_edge, &to_common);

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 thispair.option = EMSstitch_TopEdge | EMSstitch_NoRangeCheck;
 if(makecs_options & EMSmakecs_FineToCoarseTol)
  thispair.option |= EMSstitch_MatchTolerance;

 ME.GRgraphics->properties |= GRIS_LOCATABLE | GRIS_DISPLAYABLE |
				GRIS_ASSOCIATIVE;

 if(num_comps > StaticBuf)
  comps_to_connect = (GRobjid *) om$malloc(size = num_comps * sizeof(GRobjid));
 else comps_to_connect = comps_to_connect_buf;

 if(!in_pairs)
  comps_to_connect[num_comps_to_connect++] = comps[current_comp++].objid;

 if(!geom->edge_geom && !in_pairs)
  {
   geom->edge_geom = (struct IGRbsp_curve **) om$malloc(size = 
	      INIT_EDGE_BUF_SIZE * sizeof(struct IGRbsp_curve *));
   EMerr_hndlr(!geom->edge_geom, *EMmsg, EMS_E_NoDynamicMemory, wrapup);   
   geom->edge_list = (GRobjid *) om$malloc(size = 
				 INIT_EDGE_BUF_SIZE * sizeof(GRobjid));
   EMerr_hndlr(!geom->edge_list, *EMmsg, EMS_E_NoDynamicMemory, wrapup); 
   geom->edgerange = (GRrange **) om$malloc(size = INIT_EDGE_BUF_SIZE *
				  sizeof(GRrange *));
   EMerr_hndlr(!geom->edgerange, *EMmsg, EMS_E_NoDynamicMemory, wrapup); 
   geom->edge_buf_size = INIT_EDGE_BUF_SIZE;
  }

 if(!geom->surf_geom && !in_pairs)
  {
   geom->surf_geom = (struct IGRbsp_surface **) om$malloc(size = 
	      INIT_SURF_BUF_SIZE * sizeof(struct IGRbsp_surface *));
   EMerr_hndlr(!geom->surf_geom, *EMmsg, EMS_E_NoDynamicMemory, wrapup);   
   geom->surf_list = (GRobjid *) om$malloc(size = 
				 INIT_SURF_BUF_SIZE * sizeof(GRobjid));
   EMerr_hndlr(!geom->surf_list, *EMmsg, EMS_E_NoDynamicMemory, wrapup);   
   geom->surfrange = (GRrange **) om$malloc(size = INIT_SURF_BUF_SIZE *
				  sizeof(GRrange *));
   EMerr_hndlr(!geom->surfrange, *EMmsg, EMS_E_NoDynamicMemory, wrapup); 
   geom->surf_buf_size = INIT_SURF_BUF_SIZE;
  }

 atleast_one_stitch = TRUE;
 total_stitches = 0;

 stitol = Pass1Tol;

 if(makecs_options & EMSmakecs_FineToCoarseTol)
  rangeinc = stitol/2;
 else rangeinc = cht;

 /* make sure that each component to be stitched has topology */

 for (i = 0; i < num_comps; i++)
 {
  if(!EFisAncestryValid(EMmsg, comps[i].objid, comps[i].osnum, 
       OPP_NDnodein_class_id, FALSE) &&
     EFisAncestryValid(EMmsg, comps[i].objid, comps[i].osnum, 
       OPP_EMSsurface_class_id, FALSE))
     {
      OM_S_OBJID junk;

      sts = om$send(msg = message EMSsurface.EMtransform_to_associative
            (EMmsg, &junk), targetid = comps[i].objid, 
            targetos = comps[i].osnum);
      if(!(1&*EMmsg&sts)) goto wrapup;
      EMerr_hndlr(!IF_EQ_OBJID(junk, comps[i].objid), *EMmsg, EMS_E_Fail, 
                wrapup);
     }

  if(EFisAncestryValid(EMmsg, comps[i].objid, comps[i].osnum, 
       OPP_EMSsurface_class_id, FALSE))
   {
    GRobjid svcrt;

    svcrt = current_creator;
    current_creator = comps[i].objid;
    sts = om$send(msg = message EMSsurface.EMputLsIfNotThere(EMmsg, 
	  &mod_info->md_env, NULL, NULL, NULL, NULL), 
	  targetid = comps[i].objid);
    current_creator = svcrt;
    EMerr_hndlr(!(sts & *EMmsg & 1),*EMmsg,EMS_E_EdgeError,wrapup);
   }
 }

 num_my_edges = 0;
 num_in_my_list = 0;
 if(!in_pairs)
  {
   sts = NMgetedges(EMmsg, EMS_OPT_ALL, &my_edges, &my_buf_size, &num_my_edges,
         &my_surf_list, &my_numed_list, &my_list_size, &num_in_my_list, 
      	 &comps[0], NULL);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);
   sts = om$send(msg = message GRvg.GRgetrang(EMmsg,
	    &mod_info->md_env.matrix_type,
	    mod_info->md_env.matrix, &world, myrange),
			     targetid = comps[0].objid);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_SurfaceError,wrapup);	
   EM3dbxinc(myrange, rangeinc);
  }

 if(only_one && !num_in_my_list && (makecs_options & EMSmakecs_CreateShell))
  {
   *EMmsg = EMS_I_Closed;
   goto wrapup;
  }

 if(num_comps <= ConnBuf)
   added_once = added_oncebuf;
 else added_once = (IGRboolean *) om$malloc(size = num_comps * 
		   sizeof(IGRboolean));

 for(i=0; i<num_comps; i++) added_once[i] = FALSE;

 while(atleast_one_stitch && !interrupt)
  {
   if(interrupt = IGEstop()) break;
   atleast_one_stitch = FALSE;
   if(only_one) current_comp = 0;
   else current_comp = 1;

   if(status_str) strcpy(locsts_str, status_str);
  
   if(!in_pairs)
    {
     while ( (current_comp < num_comps) && !interrupt)
     {
	
      if(status_str)
       {
        strcat (locsts_str, dot);
        UI_status (locsts_str);
       }

      if(! (only_one && !first_run))
       {
        num_comp_edges = 0;
        num_in_comp_list = 0;
       }

      if(interrupt = IGEstop()) break;
      newly_connected[0] = was_connected[0] = FALSE;

      sts = om$send(msg = message GRvg.GRgetrang(EMmsg,
	    &mod_info->md_env.matrix_type,
	    mod_info->md_env.matrix, &world, comprange),
			     targetid = comps[current_comp].objid);
      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_SurfaceError,wrapup);	

      EM3dbxinc(comprange, rangeinc);
      if (!BSbxint(&rc, &myrange[0], &myrange[3],
			&comprange[0], &comprange[3])) goto next_comp;
			
      if(! (only_one && !first_run))

      sts = NMgetedges(EMmsg, EMS_OPT_ALL, &comp_edges, &comp_buf_size,
	    &num_comp_edges, &comp_surf_list, &comp_numed_list,
	    &comp_list_size, &num_in_comp_list, &comps[current_comp], NULL);
      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);

      /*
         If the following conditions are true, it is assumed that the user
         is attempting to make a solid/compsf out a of surface which is closed
         in both u &v or an already closed composite surface. So skip 
	 everything
       */
      if(num_comps == 1) 
          if( !num_my_edges && !num_comp_edges ) goto sti_done;

      if(!num_in_comp_list)
       goto next_comp;

      my_ed_bgn = cp_ed_bgn = 0;
      if(only_one) first_run = FALSE;

      for (my_sf_ix=0; my_sf_ix<num_in_my_list; my_sf_ix++)
       {
        my_ed_end = my_ed_bgn + my_numed_list[my_sf_ix];
        cp_ed_bgn = 0;
        if(IF_NULL_OBJID(my_surf_list[my_sf_ix]))
         {
          my_ed_bgn = my_ed_end;
          continue;
         }
        thispair.surf0 = my_surf_list[my_sf_ix];
        sts = NMgetGeom(EMmsg, &geom->numsf, &geom->surf_list, 
	      &geom->surf_geom, &geom->surfrange, &geom->surf_buf_size, 
	      SURF_BUF_INCREMENT, 
	      thispair.surf0, &surf_geom[0], mysfrange, FALSE, NULL, mod_info, 
	      rangeinc);
        if(!(1&*EMmsg&sts)) goto wrapup;

        if (!BSbxint(&rc, &mysfrange[0], &mysfrange[3],
			&comprange[0], &comprange[3]))
         {
          my_ed_bgn = my_ed_end;
          continue;
         }
			
        thispair.surf_geom0 = surf_geom[0];

        for (cp_sf_ix=0; cp_sf_ix<num_in_comp_list; cp_sf_ix++)
         {
          cp_ed_end = cp_ed_bgn + comp_numed_list[cp_sf_ix];
          if(IF_NULL_OBJID(comp_surf_list[cp_sf_ix]) ||
	     IF_EQ_OBJID(comp_surf_list[cp_sf_ix], my_surf_list[my_sf_ix]))
           {
	    if(num_comps > 1)
	     {
	      cp_ed_bgn = cp_ed_end;
	      continue;
	     }
           }
          thispair.surf1 = comp_surf_list[cp_sf_ix];
          sts = NMgetGeom(EMmsg, &geom->numsf, &geom->surf_list, 
		&geom->surf_geom, &geom->surfrange, &geom->surf_buf_size, 
		SURF_BUF_INCREMENT, 
		thispair.surf1, &surf_geom[1], compsfrange, FALSE, NULL, 
		mod_info, rangeinc);
          if(!(1&*EMmsg&sts)) goto wrapup;

          if (!BSbxint(&rc, &mysfrange[0], &mysfrange[3],
			&compsfrange[0], &compsfrange[3]))
           {
	    cp_ed_bgn = cp_ed_end;
	    continue;
           }

	  thispair.surf_geom1 = surf_geom[1];
	
          for (my_ed_ix=my_ed_bgn; my_ed_ix<my_ed_end; my_ed_ix++)
           {
	    IGRboolean got_stitched = FALSE;
	
	    if(IF_NULL_OBJID(my_edges[my_ed_ix].objid)) continue;
            if(interrupt = IGEstop()) break;
	    
	    num_myed_tped = 0;
	
	    if(!myed_tped_size)
	     {
	      myed_tped = (GRobjid *) om$malloc(size = TpEdSize * 
				sizeof(GRobjid));
	      EMerr_hndlr(!myed_tped, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
	      myed_tped_size = TpEdSize;
	     }
	
            spltedos = my_edges[my_ed_ix].osnum;
            sts = NMsend_to_partedges(&rc, message EMSedge.EMget_top_part_edges
                  (&rc, &myed_tped, &num_myed_tped, &myed_tped_size), 
		  my_edges[my_ed_ix].objid, my_edges[my_ed_ix].osnum, 0, 
		  MAXINT, NULL, NULL, NULL);
            EMerr_hndlr (!(1&sts&rc),*EMmsg,EMS_E_EdgeError,wrapup);
            if(!num_myed_tped)
             {
              num_myed_tped = 1;
              myed_tped[0] = my_edges[my_ed_ix].objid;
             }

            for(my_tped_ix = 0; my_tped_ix < num_myed_tped; my_tped_ix++)
             {
              thispair.edge0 = myed_tped[my_tped_ix];
  	      edge_geom[0] = NULL;

	      for (cp_ed_ix=cp_ed_bgn; cp_ed_ix<cp_ed_end; cp_ed_ix++)
	       {
                if(interrupt = IGEstop()) break;
	        if(IF_EQ_OBJID(my_edges[my_ed_ix].objid,
			  comp_edges[cp_ed_ix].objid)) continue;
	        if(IF_NULL_OBJID(comp_edges[cp_ed_ix].objid)) continue;

	        num_comped_tped = 0;

	        if(!comped_tped_size)
	         {
	          comped_tped = (GRobjid *) om$malloc(size = TpEdSize * 
				sizeof(GRobjid));
	          EMerr_hndlr(!comped_tped, *EMmsg, EMS_E_NoDynamicMemory, 
				wrapup);
	          comped_tped_size = TpEdSize;
	         }

                sts = NMsend_to_partedges(&rc, message 
		      EMSedge.EMget_top_part_edges
                      (&rc, &comped_tped, &num_comped_tped, &comped_tped_size),
		      comp_edges[cp_ed_ix].objid, comp_edges[cp_ed_ix].osnum, 
		      0, MAXINT, NULL, NULL, NULL);
                EMerr_hndlr (!(1&sts&rc),*EMmsg,EMS_E_EdgeError,wrapup);
                if(!num_comped_tped)
                 {
                  num_comped_tped = 1;
                  comped_tped[0] = comp_edges[cp_ed_ix].objid;
                 }
	
	        for(cp_tped_ix = 0; cp_tped_ix<num_comped_tped; cp_tped_ix++)
	         {
  	          thispair.edge1 = comped_tped[cp_tped_ix];
	          if(!edge_geom[0])
	           {
                    sts = NMgetGeom(EMmsg, &geom->numed, &geom->edge_list, 
	                  &geom->edge_geom, &geom->edgerange, 
			  &geom->edge_buf_size,
		          EDGE_BUF_INCREMENT, thispair.edge0, &edge_geom[0], 
		          myedrange, TRUE, surf_geom[0], mod_info, rangeinc);
                    if(!(1&*EMmsg)) goto wrapup;
	            thispair.edge_geom0 = edge_geom[0];
	           }
	
                  sts = NMgetGeom(EMmsg, &geom->numed, &geom->edge_list, 
	                &geom->edge_geom, &geom->edgerange, 
			&geom->edge_buf_size, 
		        EDGE_BUF_INCREMENT,
	                thispair.edge1, &edge_geom[1], compedrange, TRUE, 
		        surf_geom[1], mod_info, rangeinc);
                  if(!(1&*EMmsg)) goto wrapup;
	          thispair.edge_geom1 = edge_geom[1];

                  if(!BSbxint(&rc, &myedrange[0], &myedrange[3],
		 	&compedrange[0], &compedrange[3]))
	           {
	            *EMmsg = EMS_S_Success;
		    continue;
	           }
	          else
	           {
	            for(j=0; j<2; j++)
	            for(i=0; i<MaxNumPe; i++) part_edges[j][i] = NULL_OBJID;

    		    if(!tempcrt) current_creator = my_id;
                    sts = NMstitch_edge(EMmsg, &thispair, &my_GRid, ssiptr, 
		          &to_common, mod_info, comps[current_comp].objid,
		          NULL_OBJID, newly_connected, was_connected,  
		          &total_stitches, part_edges, stitol, 
		          comps_to_connect, &num_comps_to_connect, construct);
		    if(!tempcrt) current_creator = NULL_OBJID;
                    if(!(1&*EMmsg&sts)) goto wrapup;
                    if(*EMmsg == EMS_I_Fail)
 	             {
	              *EMmsg = EMS_S_Success;
		      continue;
		     }
	           }
	
	          /* If stitch succeeded and the edge got split, its geometry 
		     is useless.
	          */
	          if(!IF_EQ_OBJID(part_edges[0][0], thispair.edge0))
                   NMfree_geom(geom->edge_geom, geom->edgerange, &geom->numed, 
               	           geom->edge_list, thispair.edge0, TRUE);
	
	          NMupdateEd(EMmsg, &my_edges, &num_my_edges, &my_buf_size, 
			     &my_numed_list[my_sf_ix], thispair.edge0,
                             spltedos, part_edges[0], &my_ed_ix, &comp_edges, 
			     &num_comp_edges, &comp_numed_list[cp_sf_ix], 
			     &comp_buf_size, &my_ed_end);
	          if(!(1&*EMmsg)) goto wrapup;
	
	          if(!IF_EQ_OBJID(part_edges[1][0], thispair.edge1))
                   NMfree_geom(geom->edge_geom, geom->edgerange, &geom->numed, 
			   geom->edge_list, thispair.edge1, TRUE);
		
                  NMupdateEd(EMmsg, &comp_edges, &num_comp_edges, 
			     &comp_buf_size, 
			     &comp_numed_list[cp_sf_ix], thispair.edge1, 
			     spltedos, part_edges[1], &cp_ed_ix, &my_edges, 
			     &num_my_edges, &my_numed_list[my_sf_ix], 
			     &my_buf_size, &cp_ed_end);
	          if(!(1&*EMmsg)) goto wrapup;
		  got_stitched = TRUE;
	          break;
	
	         }/* for(cp_tped_ix=0; cp_tped_ix<num_ccomped_tped;..)*/
	
	        if(got_stitched) break;
	
	       } /* for (cp_ed_ix=cp_ed_bgn; cp_ed_ix<cp_ed_end; cp_ed_ix++) */

	      if(got_stitched) break;
	
	     } /* for(my_tped_ix = 0; my_tped_ix<num_myed_tped; my_tped_ix++)*/
	
   	    if(interrupt) break;
	
           }/* for (my_ed_ix=my_ed_bgn; my_ed_ix<my_ed_end; my_ed_ix++) */
	
	   cp_ed_bgn = cp_ed_end;
	   if(interrupt) break;
	
          } /* for (cp_sf_ix=0; cp_sf_ix<num_in_comp_list; cp_sf_ix++) */

         my_ed_bgn = my_ed_end;
         if(interrupt) break;

        } /* for (my_sf_ix=0; my_sf_ix<num_in_my_list; my_sf_ix++) */

next_comp:

      NMcompress_list(my_edges, &num_my_edges, my_surf_list, my_numed_list, 
		       &num_in_my_list, geom);

      /* If this component was newly connected, append its unconnected edges to
	 'my' list.
      */
      if(newly_connected[0] || was_connected[0])
       {
	if(newly_connected[0] || 
	   (was_connected[0] && !added_once[current_comp])) 
	   atleast_one_stitch = TRUE;
	added_once[current_comp] = TRUE;
        NMcompress_list(comp_edges, &num_comp_edges, comp_surf_list, 
		       comp_numed_list, &num_in_comp_list, geom);
	if(num_comp_edges)	
	 {
	  if(my_buf_size < (num_comp_edges + num_my_edges))
	   {
	    my_buf_size += (num_comp_edges + EdInc);
	    my_edges = (struct GRid *) om$realloc(ptr = (IGRchar *)my_edges, 
	    size = my_buf_size * sizeof(struct GRid));
	    EMerr_hndlr(!my_edges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
	   }
 	  OM_BLOCK_MOVE(comp_edges, &my_edges[num_my_edges],
		       num_comp_edges * sizeof(struct GRid));
	  num_my_edges += num_comp_edges;
	 }
	
	if(num_in_comp_list)
	 {
	  if(my_list_size < (num_in_comp_list + num_in_my_list))
	   {
	    my_list_size += (num_in_comp_list + SfInc);
	    my_surf_list = (GRobjid *) om$realloc(ptr = (IGRchar *)my_surf_list, 
	    size = my_list_size * sizeof(GRobjid));
	    EMerr_hndlr(!my_surf_list, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
	    my_numed_list = (IGRint *) om$realloc(ptr = (IGRchar *)my_numed_list, 
	    size = my_list_size * sizeof(IGRint));
	   }
	  OM_BLOCK_MOVE(comp_surf_list, &my_surf_list[num_in_my_list], 
			num_in_comp_list * sizeof(GRobjid));
	  OM_BLOCK_MOVE(comp_numed_list, &my_numed_list[num_in_my_list], 
			num_in_comp_list * sizeof(IGRint));
	  num_in_my_list += num_in_comp_list;
	 }
	
	/* Since a new component has been connected, update my locally
	   stored range.
	*/
	for(i=0; i<3; i++)
	 if(comprange[i] < myrange[i]) myrange[i] = comprange[i];
	for(i=3; i<6; i++)
	 if(comprange[i] > myrange[i]) myrange[i] = comprange[i];
	
       } /* if(newly_connected[0]) */

      current_comp++;

     } /* while ( (current_comp < num_comps) && !interrupt) */

    } /* if(!in_pairs) */
   else
    {
	
#if IN_PAIRS_IMPLEMENTED_FOR_NMSTITCH

     GRobjid	loc_comp[2];
     struct GRid junk;

     for (idx=0; (idx<in_num_pairs) && !interrupt; idx++)
      {
       if(interrupt = IGEstop()) break;

       in_pairs[idx].option &= ~EMSstitch_TopEdge;
       for(i=0; i<2; i++)
        {
         sts = om$send(msg = message EMSsurface.EMgetactiveid
	       (EMmsg, &junk, NULL), 
                        targetid = i ? in_pairs[idx].surf1 
				     : in_pairs[idx].surf0);
         if(!(1&*EMmsg&sts)) goto wrapup;				
	 loc_comp[i] = junk.objid;
        }
       if(makecs_options & EMSmakecs_FineToCoarseTol)
        in_pairs[idx].option |= EMSstitch_MatchTolerance;

       sts = NMstitch_edge(EMmsg, &in_pairs[idx], &my_GRid, ssiptr, 
	     &to_common, mod_info, loc_comp[0], 
             loc_comp[1], newly_connected, was_connected, 
	     &total_stitches, NULL, NULL, part_edges, 
	     stitol, comps_to_connect, &num_comps_to_connect, construct);
       if(!(1&*EMmsg&sts)) goto wrapup;

       if(*EMmsg == EMS_I_Fail)
        {
         *EMmsg = EMS_S_Success;
	 continue;
        }
       atleast_one_stitch = TRUE;
       if(in_num_pairs == 1) goto sti_done;

      } /* for (idx=0; (idx<in_num_pairs) && !interrupt; idx++) */
#else

     fprintf(stderr, "NOT IMPLEMENTED YET\n");
     *EMmsg = EMS_I_Fail;
     total_stitches = 0;
     goto sti_done;

#endif

    } /* if(in_pairs) */

   if( (makecs_options & EMSmakecs_FineToCoarseTol) && (iteration < 2) &&
       !atleast_one_stitch)
    {
     IGRdouble oldrangeinc, inc;
     iteration++;
     if(iteration == 1) stitol = Pass2Tol;
     else if(iteration == 2) stitol = Pass3Tol;
     oldrangeinc = rangeinc;
     rangeinc = stitol/2;
     inc = rangeinc - oldrangeinc;

     if((inc > 0.0) && geom->edgerange)
     for(i=0; i<geom->numed; i++)
      if(geom->edgerange[i]) EM3dbxinc(geom->edgerange[i][0], inc);

     if( (inc > 0.0) && geom->surfrange)
     for(i=0; i<geom->numsf; i++)
      if(geom->surfrange[i]) EM3dbxinc(geom->surfrange[i][0], inc);

     if( (inc > 0.0) && !in_pairs) EM3dbxinc(myrange, inc);
   
     atleast_one_stitch = TRUE;
     for(i=0; i<num_comps; i++) added_once[i] = FALSE;

#if DEBUG
     printf("Continuing with iteration %d tolerance %2.13lf\n", iteration, 
	    stitol);
#endif
    }

  } /* while(atleast_one_stitch && !interrupt) */

sti_done:

 if (!total_stitches) *EMmsg = EMS_I_Fail;

 wrapup:

  if(added_once && (added_once != added_oncebuf)) om$dealloc(ptr = added_once);
  if (my_edges) om$dealloc(ptr = my_edges);
  if(myed_tped) om$dealloc(ptr = myed_tped);
  if(comped_tped) om$dealloc(ptr = comped_tped);
  if (my_surf_list) om$dealloc(ptr = my_surf_list);
  if (my_numed_list) om$dealloc(ptr = my_numed_list);
  if (comp_edges) om$dealloc(ptr = comp_edges);
  if (comp_surf_list) om$dealloc(ptr = comp_surf_list);
  if (comp_numed_list) om$dealloc(ptr = comp_numed_list);

  if(loc_geom.surf_geom)   
   for(idx=0; idx<loc_geom.numsf; idx++)
    if (loc_geom.surf_geom[idx]) om$dealloc(ptr = loc_geom.surf_geom[idx]);

  if(loc_geom.surfrange)   
   for(idx=0; idx<loc_geom.numsf; idx++)
    if (loc_geom.surfrange[idx]) om$dealloc(ptr = loc_geom.surfrange[idx]);

  if(loc_geom.edge_geom)
   for(idx=0; idx<loc_geom.numed; idx++)
    if (loc_geom.edge_geom[idx]) BSfreecv(&rc, loc_geom.edge_geom[idx]);

  if(loc_geom.edgerange)   
   for(idx=0; idx<loc_geom.numed; idx++)
    if (loc_geom.edgerange[idx]) om$dealloc(ptr = loc_geom.edgerange[idx]);

   if (loc_geom.surf_geom) om$dealloc(ptr = loc_geom.surf_geom);
   if (loc_geom.surfrange) om$dealloc(ptr = loc_geom.surfrange);
   if (loc_geom.edge_geom) om$dealloc(ptr = loc_geom.edge_geom);
   if (loc_geom.edgerange) om$dealloc(ptr = loc_geom.edgerange);
   if (loc_geom.surf_list) om$dealloc(ptr = loc_geom.surf_list);
   if (loc_geom.edge_list) om$dealloc(ptr = loc_geom.edge_list);

/* If there was an error then go ahead and pretend as if things went all
   right and then perform an internal undo operation. This is done so
   that the caller gets back the topology unchnged in case of a failure.
   if the return code at this point is EMS_I_Fail then the topology is intact
   (no splits or common edge connections have occured). So we need to do
   nothing.
*/

  if(*EMmsg != EMS_I_Fail) 
   {
    IGRlong		sts, rc;

    ME.NMnonmanigm->nmprops &= (~NMgm_NullState);

    if( (!(ME.NMnonmanigm->nmprops & NMgm_Unevaluated)) &&
        (!(nm_options & NMstch_GlueEdgesOnly)))
     {
      if(num_comps_to_connect > StaticBuf)
       {
        my_parents = (struct EMSobject_info *) om$malloc(size = 
                     num_comps_to_connect * sizeof(struct EMSobject_info));
        my_base = (struct GRid *) om$malloc(size = 
                  num_comps_to_connect * sizeof(struct GRid));
        my_trans = (IGRboolean *) om$malloc(size = 
                  num_comps_to_connect * sizeof(IGRboolean));
       }
      else
       {
        my_parents = (struct EMSobject_info *) my_parentsbuf;
        my_base = (struct GRid *) my_basebuf;
        my_trans = (IGRboolean *) my_transbuf;
       }

      EMerr_hndlr(!my_parents || !my_base || !my_trans, *EMmsg, 
      EMS_E_NoDynamicMemory, finish);

      my_numparents = 0;
      for(i=0; i<num_comps_to_connect; i++)
       {
        struct GRid actid, compid;

        compid.osnum = OM_Gw_current_OS;
        compid.objid = comps_to_connect[i];

        sts = NMget_node(EMmsg, &compid, NULL, NULL, NULL, NULL, NULL, &actid, 
		       NULL);
        if(!(1&*EMmsg&sts)) goto finish;

        if(IF_EQ_GRID(my_GRid, actid)) actid = compid;
        my_parents[my_numparents].grid = actid;
        my_parents[my_numparents].env = *mod_info;
        my_base[my_numparents] = compid;
        my_trans[my_numparents++] = TRUE;	/* Transmigrate on each comp */
       }

      if(my_numparents)
       {
        sts = om$send(msg = message NMassoctrans.NMinit_associative(EMmsg, 
              EMS_no_const_assoc, NMinitas_NoDuplicateParents, my_numparents, 
              my_parents, my_numparents, my_trans, my_base, NULL, NULL, NULL, 
	      construct), targetid = my_id);
        if(!(1&*EMmsg&sts)) goto finish;
       }

      for(i=0; i<my_numparents; i++)
       {
        unsigned short nmprops = NMgm_Active;

        sts = om$send(msg = message NMnonmanigm.NMprop(EMmsg, NMprop_SetOff, 
	      &nmprops), targetid = my_parents[i].grid.objid, 
	      targetos = my_parents[i].grid.osnum);
        if(sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
        if(!(1&*EMmsg&sts)) goto finish;
       }

      ME.NMnonmanigm->nmprops = NMgm_Active;

      ME.GRgraphics->properties = construct->properties | GRIS_ASSOCIATIVE |
		                  GRIS_LOCATABLE | GRIS_DISPLAYABLE;
      ME.GRflxown->owner_properties = GR_ORPHAN;

      /* Store the tolerances.
      */
      ME.NMnonmanist->lentol = bastol;
      ME.NMnonmanist->cht = cht;

     } /* if(!(ME.NMnonmanigm->nmprops & NMgm_Unevaluated)) */

    for(i=0; i<ssiptr->num_vtx; i++)
     {
      sts = om$send(msg = message NMvertex.NMcheck(EMmsg, ssiptr, 
	    NMconnect_AddToSSI), 
	    targetid = ssiptr->vtx[i]);
      if(!(1&*EMmsg&sts)) goto finish;
     }

    if(!(nm_options & NMstch_GlueEdgesOnly))
     {
      sts = om$send(msg = message NMnonmanigm.NMput_SSI(&rc, ssiptr), 
	    targetid = my_id);


      /* Display the affected surfaces.
      */
      {
       unsigned short ssiopt = NMssiact_DrawFlps | NMssiact_DrawVtx;
       sts = om$send(msg = message NMnonmanigm.NMSSI_action(EMmsg, ssiopt, 
             mod_info, ssiptr), targetid = my_id);
      }


      /* If there was an error perform 'undo' operation.
      */

      if( (!(1&*EMmsg&sts)) && (!(ME.NMnonmanigm->nmprops & NMgm_Unevaluated)))
       sts = om$send(msg = message GRowner.GRdrop(&rc, mod_info), 
	    targetid = my_id);
     }

   } /* if(*EMmsg != EMS_I_Fail) */

  else if(ME.NMnonmanigm->nmprops & NMgm_Unevaluated)
   {
    /* Stitch has failed, so create a NULL state. Post the empry ssi to
       clear out previous data.
    */
    ME.NMnonmanigm->nmprops |= NMgm_NullState;
    if(!(nm_options & NMstch_GlueEdgesOnly))
     sts = om$send(msg = message NMnonmanigm.NMput_SSI(&rc, ssiptr), 
	   targetid = my_id);
    ex$message(msgnumb = NM_I_NullState);
    sleep(3);
   }
   

finish:

  if(!tempcrt) current_creator = NULL_OBJID;
  if(my_parents && (my_parents != my_parentsbuf))
   om$dealloc(ptr = my_parents);
  if(my_base && (my_base != my_basebuf))
   om$dealloc(ptr = my_base);
  if(my_trans && (my_trans != my_transbuf))
   om$dealloc(ptr = my_trans);
  if (comps_to_connect && (comps_to_connect != comps_to_connect_buf))
   om$dealloc(ptr = comps_to_connect);

  if(!in_ssi) NMfree_ssi(&ssi);

  if( (1&*EMmsg&sts) && (*EMmsg != EMS_I_Fail) && interrupt) 
    *EMmsg = EMS_I_Interrupt;

  EMWRAPUP(*EMmsg, sts, "In NMnonmanist.NMperform_stitch")
  return (sts);
}





static IGRint NMgetGeom(EMmsg, num, oblist, ptrlist, rnglist, bufsize, inc, id,
			gmptr, rngptr, isedge, sfgm, mod_info, rangeinc)
IGRlong		*EMmsg;
IGRint		*num;
GRobjid		**oblist;
IGRchar		***ptrlist, **gmptr;
GRrange		*rngptr, ***rnglist;
IGRint		*bufsize, inc, id;
IGRboolean	isedge;
struct IGRbsp_surface *sfgm;
struct GRmd_env		*mod_info;
IGRdouble	rangeinc;
{
 IGRint 		i;
 IGRboolean 		found = FALSE, world = FALSE;
 IGRlong		sts = OM_S_SUCCESS;
 unsigned short	props;
 extern IGRint		EMgetvggeom();

 *EMmsg = EMS_S_Success;

 for (i=0; i<*num; i++)
  {
   if (id == (*oblist)[i]) 
    { 
     found = TRUE; 
     *gmptr = (*ptrlist)[i];
     OM_BLOCK_MOVE( (*rnglist)[i][0], rngptr, sizeof(GRrange));
     break;
    }
  }

 if(found) goto wrapup;

 if(*num > *bufsize - 1)
  {
   (*bufsize) += inc;
   *oblist = (GRobjid *) om$realloc(ptr = (IGRchar *)*oblist, 
		      size = *bufsize * sizeof(GRobjid));
   EMerr_hndlr(!(*oblist), *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   *ptrlist = (IGRchar **) om$realloc(ptr = (IGRchar *)*ptrlist, 
				      size = *bufsize * sizeof(IGRchar *));
   EMerr_hndlr(!(*ptrlist), *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   *rnglist = (GRrange **) om$realloc(ptr = (IGRchar *)*rnglist, 
				      size = *bufsize * sizeof(GRrange *));
   EMerr_hndlr(!(*rnglist), *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  }

 (*rnglist) [*num] = (GRrange *) om$malloc(size = sizeof(GRrange));
 EMerr_hndlr(!(*rnglist)[*num], *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 if(isedge)
  {
   struct IGRbsp_curve **edgm;
   IGRlong rc;

   edgm = (struct IGRbsp_curve **) *ptrlist;

   edgm[*num] = NULL;
   edgm[*num] = (struct IGRbsp_curve *)
	       om$malloc(size = sizeof(struct IGRbsp_curve));
   EMerr_hndlr(!edgm[*num],*EMmsg,EMS_E_NoDynamicMemory,wrapup);   
   edgm[*num]->poles = NULL;
   edgm[*num]->knots = NULL;
   edgm[*num]->weights = NULL;
   edgm[*num]->bdrys = NULL;
   sts = om$send(msg =  message EMSedge.EMget_props(EMmsg, &props),
		      targetid = id, senderid = NULL_OBJID);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);

   sts = om$send (msg = message EMSedge.EMget_bcxyz_geom(EMmsg,
		NULL, NULL, sfgm, 0, OM_K_MAXINT,
		(props & EMED_REVERSED ? TRUE : FALSE), NULL, edgm[*num]),   
		targetid = id, senderid = NULL_OBJID);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);

   BSbx2(&rc, &edgm[*num]->num_poles, (IGRpoint *)edgm[*num]->poles,
   edgm[*num]->weights, &(*rnglist)[*num][0][0], &(*rnglist)[*num][0][3]);
   EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
  }
 else
  {
   struct GRid	dummy;
   struct IGRbsp_surface **sfgeom;

   sfgeom = (struct IGRbsp_surface **) *ptrlist;
   dummy.objid = id;
   dummy.osnum = OM_Gw_current_OS;
   sfgeom[*num] = NULL;
   sts = EMgetvggeom(EMmsg, &mod_info->md_env.matrix_type,
	  mod_info->md_env.matrix, &dummy, &sfgeom[*num], NULL);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_SurfaceError,wrapup);

   sts = om$send(msg = message GRvg.GRgetrang(EMmsg,
	    &mod_info->md_env.matrix_type,
	    mod_info->md_env.matrix, &world, (*rnglist)[*num][0]),
			     targetid = id, senderid = NULL_OBJID);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_SurfaceError,wrapup);	
  }

 *gmptr = (*ptrlist)[*num];
 (*oblist)[*num] = id;
 EM3dbxinc((*rnglist)[*num][0], rangeinc);
 OM_BLOCK_MOVE((*rnglist)[*num][0], rngptr, sizeof(GRrange));
 (*num)++;

wrapup:
#if DEBUG
if(!(1&*EMmsg&sts)) printf("Problem in NMgetGeom\n");
#endif
return(sts);
}



static IGRint NMupdateEd(EMmsg, edlist, numedlist, edlistsize, numthissf, edid,
			 edos, ped, edlistix, otherlist, num_other_list, 
			 num_other_sf, other_list_size, endix)
IGRlong		*EMmsg;
struct GRid	**edlist, **otherlist;
IGRint		*numedlist, *num_other_list, *numthissf, *num_other_sf;
GRobjid		edid, *ped;
GRspacenum      edos;
IGRint		*edlistix, *edlistsize, *other_list_size, *endix;
{
 IGRint		i, sts = OM_S_SUCCESS, num_connectable = 0, otherix = 0, 
		save_edlistix;
 IGRboolean	inother = FALSE;

 *EMmsg = EMS_S_Success;
 if(IF_NULL_OBJID(ped[0])) goto wrapup;
 if(IF_NULL_OBJID((*edlist)[*edlistix].objid)) goto wrapup;

 if(!IF_EQ_OBJID((*edlist)[*edlistix].objid, edid)) goto wrapup;
 save_edlistix = *edlistix;

 for(i=0; i<*num_other_list; i++)
  if(IF_EQ_OBJID((*otherlist)[i].objid, edid))
   {
    inother = TRUE;
    otherix = i;
    break;
   }

 /* If the edge did not get split, keep it under consideration for future
    multiple stitches.
 */
 if(IF_EQ_OBJID(ped[0], edid))
   goto wrapup;

 for(i=0; i<MaxNumPe; i++) if(!IF_NULL_OBJID(ped[i])) num_connectable++;

 EMerr_hndlr(num_connectable<=1, *EMmsg, EMS_E_Fail, wrapup);

 /* number of connectable edges is more than 1.
 */
 if( (*numedlist+num_connectable-1) > *edlistsize)
  {
   *edlist = (struct GRid *) om$realloc(ptr = (IGRchar *)*edlist, size = (*edlistsize+
		num_connectable - 1 + EdInc) * sizeof(struct GRid));
   EMerr_hndlr(!*edlist, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   *edlistsize += (num_connectable - 1 + EdInc);
  }


 if( inother && ((*num_other_list+num_connectable-1) > *other_list_size))
  {
   *otherlist = (struct GRid *) om$realloc(ptr = (IGRchar *)*otherlist, 
		size = (*other_list_size + num_connectable - 1 + EdInc) * 
		       sizeof(struct GRid));
   EMerr_hndlr(!*otherlist, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   *other_list_size += (num_connectable - 1 + EdInc);
  }


 if( (num_connectable > 1) && (*edlistix != (*numedlist - 1)))
  OM_BLOCK_MOVE(&(*edlist)[*edlistix+1], 
	        &(*edlist)[*edlistix+num_connectable], 
	        (*numedlist - *edlistix - 1) * sizeof(struct GRid));
 if(inother && (num_connectable > 1) && (otherix != (*num_other_list - 1)))
  OM_BLOCK_MOVE(&(*otherlist)[otherix+1], 
	        &(*otherlist)[otherix+num_connectable], 
	        (*num_other_list - otherix - 1) 
	               * sizeof(struct GRid));

 for(i=0; i<MaxNumPe; i++)
  {
   if(IF_NULL_OBJID(ped[i])) continue;
   (*edlist)[(*edlistix)].objid = ped[i];
   (*edlist)[(*edlistix)++].osnum = edos;
   if(inother) {
     (*otherlist)[otherix].objid = ped[i];
     (*otherlist)[otherix++].osnum = edos;
     }
  }

 (*numthissf) += (num_connectable - 1);
 if(inother) (*num_other_sf) += (num_connectable - 1);
 (*edlistix) = save_edlistix - 1;
 (*endix) += (num_connectable - 1);
 *numedlist += (num_connectable - 1);
 if(inother) *num_other_list += (num_connectable - 1);

wrapup:
#if DEBUG
if(!(1&*EMmsg&sts)) printf("Problem in NMupdateEd\n");
#endif
return(sts);
}



static void NMcompress_list(edlist, numed, sflist,numedlist, numsf, geom)
struct GRid *edlist;
IGRint	*numed, *numedlist, *numsf;
GRobjid *sflist;
struct EMSstitch_geominfo *geom;
{
 IGRboolean	atleast_one = FALSE;
 IGRint		i, j, m, numthissf;


 m = 0;
 for(i=0; i<*numsf; i++)
  {
   numthissf = 0;
   for(j=0; j<numedlist[i]; j++)
    if(!IF_NULL_OBJID(edlist[m++].objid)) numthissf++;
   numedlist[i] = numthissf;
   if(!numedlist[i])
    {
     NMfree_geom(geom->surf_geom, geom->surfrange, &geom->numsf, 
		 geom->surf_list, sflist[i], FALSE);
     sflist[i] = NULL_OBJID;
    }
  }

 atleast_one = TRUE;
 while(atleast_one)
  {
   atleast_one = FALSE;
   for(i=0; i< *numsf; i++)
    {
     if(numedlist[i]) continue;
     for(j=i; j<*numsf - 1; j++)
      {
       sflist[j] = sflist[j+1];
       numedlist[j] = numedlist[j+1];
      }
     (*numsf)--;
     atleast_one = TRUE;
     break;
    }
  }

 atleast_one = TRUE;
 while(atleast_one)
  {
   atleast_one = FALSE;
   for(i=0; i<*numed; i++)
    {
     if(!IF_NULL_OBJID(edlist[i].objid)) continue;
     for(j=i; j<*numed - 1; j++)
      edlist[j] = edlist[j+1];
     (*numed)--;
     atleast_one = TRUE;
     break;
    }
  }

}



static void NMfree_geom(geom, rng, num, list, id, isedge)
IGRchar **geom;
GRrange **rng;
IGRint *num;
GRobjid *list, id;
IGRboolean isedge;
{
 IGRint	i, idx = 0;
 IGRboolean found = FALSE;
 IGRlong rc;

 if(IF_NULL_OBJID(id)) found = FALSE;
 else
  {
   for(i=0; i<*num; i++)
    if(IF_EQ_OBJID(id, list[i]))
     {
      found = TRUE;
      idx = i;
      break;
     }
  }

 if(found && geom[idx])
  {
   if(isedge) BSfreecv(&rc, (struct IGRbsp_curve *)geom[idx]);
   else if(geom[idx]) om$dealloc(ptr = geom[idx]);
   
   if(rng[idx]) om$dealloc(ptr = rng[idx]);
   geom[idx] = NULL;
   rng[idx] = NULL;
   list[idx] = NULL_OBJID;
   for(i=idx; i<*num-1; i++)
    {
     geom[i] = geom[i+1];
     rng[i] = rng[i+1];
     list[i] = list[i+1];
    }
   (*num)--;
  }
}

end  implementation NMnonmanist;

