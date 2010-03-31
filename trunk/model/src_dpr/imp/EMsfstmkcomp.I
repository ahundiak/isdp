/* ###################   APOGEE COMPILED   ################## */
/*
Name

    EMSsfstitch.EMmake_comp

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
    Sudha       06/23/93        Modified for BSprototype ansification
    mrm         03/26/91        Check for existing attachment to surface,
                                make sure surfaces have topology.
    SM		06-Oct-88	Moved method from EMSgencompsf to
				EMSsfstitch. Also made the modifications
				necessary for state tree creation.
    SM		01-Sep-89	Modified to handle only one surface passed
				in. In such a case the method will try to
				stitch edges within that component (which
				could be a closed single surface with seams
				unconnected or a composite surface with some
				stitchable edges left).
    SM		29-Sep-89	Support option EMSmakecs_CreateShell -
				If only one closed (no connectable edges)
				component is input, create a null stitch
				state and set the return code to 
				EMS_I_Closed. 
    SS          11/02/89	Notification

    SM		28-Nov-89	Before putting 2 edges into a pair structure
				check if their range boxes intersect within
				cht. This should decrease the number of pairs
				considered for stitching.
				Similar check also takes place in
				EMSedge.EMstitch method.

    Inasu       Oct 25,90       Modified to make composite out of surfs closed 
                                in both u & v. (Fix for TR 90n1934)
    DLB		9/27/91		GRgetrang was passed wolrd by value instead
				of *short.  SUN problem.
*/
class implementation EMSsfstitch;

#ifndef DEBUG
#define DEBUG 0
#endif

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
#include "grerr.h"  /* GRNOCONNECT */
#include "timerdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "bststcvdegn.h"
#include "bsfreecv.h"
#include "bschangepar.h"
#include "bsbxint.h"
#include "bsbx2.h"

#define INITIAL_SIZE 		64
#define INCREMENT		32
#define INIT_EDGE_BUF_SIZE	64
#define INIT_SURF_BUF_SIZE	8
#define EDGE_BUF_INCREMENT	32
#define SURF_BUF_INCREMENT	4
#define EdInc			10
#define SfInc			5

#define PartEdBuf	3
#define ConnBuf		500

#define NumPasses       5

#define Pass1Tol	bastol
#define Pass2Tol	bastol+bastol
#define Pass3Tol	cht
#define Pass4Tol	bastol + cht
#define Pass5Tol	cht+cht


from EMSedge import EMget_bcxyz_geom, EMget_props, EMget_top_part_edges,
		    EMstitch, EMreplace_edge, EMset_props;

extern OMuword OPP_EMSsfstitch_class_id;

%safe
static int	        EMgetGeom(), EMstitch(), EMupdateEd();
static void	        EMfree_geom(), EMcompress_list();
static int		EMrecord_edges();
%endsafe

extern IGRboolean _use_timers, _sm_use_new_stitching_algorithm;

method EMmake_comp (IGRlong *EMmsg;
		 IGRint num_comps;
		 GRobjid *comps;
		 struct GRmd_env *mod_info;
		 struct EMSstitch_saveinfo *save_info;
		 struct EMSstitch_info *in_pairs;
		 IGRint in_num_pairs;
		 struct EMSstitch_geominfo *geom;
		 IGRushort makecs_options)


{
 IGRboolean		notify = FALSE, sliverproc = FALSE;
 IGRlong	     	sts;    
 OM_S_CHANSELECT     	to_comps, to_common, to_loopset;
 struct GRid		my_GRid,
			*my_edges = NULL, *comp_edges = NULL;
 GRobjid		*my_surf_list = NULL, *comp_surf_list = NULL, 
			part_edges[2][PartEdBuf];
 IGRint			*my_numed_list = NULL, *comp_numed_list = NULL, i, 
			parted_buf[2], j;
 IGRint			my_buf_size = 0, comp_buf_size = 0,
			num_my_edges = 0, num_comp_edges = 0,
 		        current_comp = 0, 
			my_list_size = 0, comp_list_size = 0,
			num_in_my_list = 0, num_in_comp_list = 0,
			my_ed_bgn, cp_ed_bgn, my_ed_end, cp_ed_end,
			my_ed_ix, cp_ed_ix, my_sf_ix, cp_sf_ix,
			num_mysf_stitches = 0, 
			num_cpsf_stitches = 0, iteration = 1;
 IGRlong		idx = MAXINT;
 struct EMSstitch_info  thispair;
 IGRint                 total_stitches = 0;
 BSrc		        rc;
 struct EMSstchssi_table	*my_info = NULL;
 struct EMSstitch_saveinfo	loc_my_info;
 IGRboolean 		action = FALSE, interrupt = FALSE, 
			newly_connected[2], was_connected[2], 
			*conn = NULL, connbuf[ConnBuf], world=FALSE;
 IGRushort 	mask = EMSIS_ACTIVE_STATE;
extern IGRboolean IGEstop() ;
 extern IGRint		EMmake_chanselect(), EMgetvggeom();
 IGRboolean		only_one = FALSE, atleast_one_stitch, 
			first_run = TRUE;
 struct EMSstitch_geominfo loc_geom;
 struct IGRbsp_curve	*edge_geom[2];
 struct IGRbsp_surface  *surf_geom[2];
 GRrange		myrange, comprange, mysfrange, compsfrange, 
			myedrange, compedrange;
 IGRdouble		cht, bastol, stitol, rangeinc;
 GRobjid		*sliversf = NULL, sliversfbuf[ConnBuf];
 IGRint			num_sliversf = 0;

 /* TIMER SET */
 if (_use_timers)
  start_timer (T_EMMAKE_COMP);

 sts = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 if(num_comps > ConnBuf)
  sliversf = (GRobjid *) om$malloc(size = num_comps * sizeof(GRobjid));
 else
  sliversf = sliversfbuf;

 if(_sm_use_new_stitching_algorithm)
   makecs_options &= (~EMSmakecs_NoSpecialProcessing);
 else
   makecs_options |= EMSmakecs_NoSpecialProcessing;


 if(makecs_options & EMSmakecs_NoSpecialProcessing)
  {
   makecs_options &= (~EMSmakecs_SpecialProcessing);
   makecs_options &= (~EMSmakecs_SliverProcessing);
   makecs_options &= (~EMSmakecs_FineToCoarseTol);
  }

 if(makecs_options & EMSmakecs_SliverProcessing)
  {
   makecs_options &= (~EMSmakecs_FineToCoarseTol);
   sliverproc = TRUE;
  }
 else if(!(makecs_options & EMSmakecs_NoSpecialProcessing))
  makecs_options |= EMSmakecs_FineToCoarseTol;

 for(i=0; i<2; i++) parted_buf[i] = PartEdBuf;

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

 my_info = (struct EMSstchssi_table *) &loc_my_info.my_info;
 my_info->num_edges_out = 0;
 my_info->num_edges_connected = 0;
 my_info->num_edges_in = NULL;
 my_info->edges_in = NULL;
 my_info->edges_out = NULL;
 my_info->edges_connected = NULL;
 loc_my_info.edges_out_buf_size = 0;
 loc_my_info.edges_in_buf_size = 0;
 loc_my_info.num_edges_in_buf_size = 0;
 loc_my_info.num_edges_connected_buf_size = 0;
 if(!save_info) save_info = (struct EMSstitch_saveinfo*) &loc_my_info;
 my_info = (struct EMSstchssi_table *) &save_info->my_info;

 EMmake_chanselect (GRcmpowner_to_components, &to_comps);
 EMmake_chanselect(EMSedge_to_common_edge, &to_common);

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 thispair.option = EMSstitch_TopEdge | EMSstitch_NoRangeCheck;
 if( (makecs_options & EMSmakecs_FineToCoarseTol) ||
     (makecs_options & EMSmakecs_SliverProcessing))
  thispair.option |= EMSstitch_MatchTolerance;

 if(makecs_options & EMSmakecs_SliverProcessing)
  thispair.option |= EMSstitch_NoOrientSurfs;

 ME.EMSdpr->dpr_props = EMSIS_ACTIVE_STATE | EMSIS_ACTIVE_PATH;    
 ME.GRgraphics->properties |= GRIS_LOCATABLE | GRIS_DISPLAYABLE;

 if(!sliverproc && !in_pairs && (makecs_options & EMSmakecs_SpecialProcessing)
    && (!(makecs_options & EMSmakecs_NoSpecialProcessing)))
  {
   IGRboolean save_use_timers;

   save_use_timers = _use_timers;
   _use_timers = FALSE;
   
   for(i=0; i<num_comps; i++)
    {
#if DEBUG
     printf("****** Preprocessing Comp %d ******\n", i+1);
#endif
     sts = om$send(msg = message EMSsfstitch.EMmake_comp(EMmsg, 1, &comps[i], 
           mod_info, save_info, NULL, 0, geom, 
           makecs_options | EMSmakecs_SliverProcessing), 
           targetid = my_id);
     if(!(1&*EMmsg&sts)) goto wrapup;
     if(*EMmsg != EMS_I_Fail)
      sliversf[num_sliversf++] = comps[i];
    }

#if DEBUG
   printf("*********** Preprocessing Done (%d sliver surfs) ************\n\n", 
          num_sliversf);
#endif
   _use_timers = save_use_timers;
  }

 if(!in_pairs && !sliverproc)
  {
   idx = MAXINT;
   sts = om$send(msg = message GRconnector.GRrigidconn
                              (EMmsg, &my_GRid, &idx),
                 targetid = comps[current_comp++]);

   if (!(sts & *EMmsg & 1))
   {
        /* check whether the component is already connected (this will be
           true for recomputes) */

        if (*EMmsg == GRNOCONNECT)
        {
            OM_S_CHANSELECT to_owners;

            i = current_comp - 1;
            j = -1;
            EMmake_chanselect (GRconnector_to_owners, &to_owners);
            sts = om$get_index (objid_c = comps[i],
                                p_chanselect = &to_owners,
                                objid = my_id,
                                indexaddr = (OMuint *) &j);

            if ((sts & 1) && (j == 0))
                *EMmsg = EMS_S_Success;
            else
                goto wrapup;
        }
        else
            goto wrapup;
   }

   action = FALSE;
   mask = EMSIS_ACTIVE_STATE;
   sts = om$send(msg = message EMSdpr.EMsetprops(&rc, &action, &mask), 
                      p_chanselect = &to_comps);
   if(sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
  }

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
 BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht);
 BSEXTRACTPAR(&rc, BSTOLLENVEC, bastol);

 stitol = (makecs_options & EMSmakecs_SliverProcessing) ? Pass2Tol : Pass1Tol;

 if( (makecs_options & EMSmakecs_FineToCoarseTol) ||
     (makecs_options & EMSmakecs_SliverProcessing))
  rangeinc = stitol/2;
 else rangeinc = cht;

 /* make sure that each component to be stitched has topology */

 EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);
 for (i = 0; i < num_comps; i++)
 {
    j = 0;
    sts = om$get_channel_count(objid = comps[i],
                               osnum = mod_info->md_id.osnum,
			       p_chanselect = &to_loopset,
			       count = (OMuint *) &j);
    if ((sts & 1) && (j == 0)) /* will fail if not primitive */
    {
        sts = om$send(msg = message EMSsurface.EMmk_nat_bdry
                           (EMmsg, &mod_info->md_env, NULL),
                      targetid = comps[i],
                      targetos = mod_info->md_id.osnum);
        EMerr_hndlr(!(sts & *EMmsg & 1),*EMmsg,EMS_E_EdgeError,wrapup);
    }
 }

 num_my_edges = 0;
 num_in_my_list = 0;
 if(!in_pairs)
  {
   sts = om$send(msg = message EMSsurface.EMgetedges(EMmsg,
       EMS_OPT_CONNECTABLE, &my_edges, &my_buf_size, &num_my_edges,
       &my_surf_list, &my_numed_list, &my_list_size, &num_in_my_list),
       targetid = sliverproc ? comps[0] : my_id);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);
   sts = om$send(msg = message GRvg.GRgetrang(EMmsg,
	    &mod_info->md_env.matrix_type,
	    mod_info->md_env.matrix, &world, myrange),
            targetid = sliverproc ? comps[0] : my_id);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_SurfaceError,wrapup);	
   EM3dbxinc(myrange, rangeinc);
  }

 if(only_one && !num_in_my_list && (makecs_options & EMSmakecs_CreateShell))
  {
   *EMmsg = EMS_I_Closed;
   goto wrapup;
  }

 if(num_comps <= ConnBuf)
   conn = connbuf;
 else conn = (IGRboolean *) om$malloc(size = num_comps * sizeof(IGRboolean));

 for(i=0; i<num_comps; i++) conn[i] = FALSE;

 while(atleast_one_stitch && !interrupt)
  {
   if(interrupt = IGEstop()) break;
   atleast_one_stitch = FALSE;
   if(only_one) current_comp = 0;
   else current_comp = 1;
   if(!in_pairs)
    {
     while ( (current_comp < num_comps) && !interrupt)
     {
      if(! (only_one && !first_run))
       {
        num_comp_edges = 0;
        num_in_comp_list = 0;
       }

      if(interrupt = IGEstop()) break;
      newly_connected[0] = was_connected[0] = FALSE;
      /*if(conn[current_comp]) goto next_comp; */

      sts = om$send(msg = message GRvg.GRgetrang(EMmsg,
	    &mod_info->md_env.matrix_type,
	    mod_info->md_env.matrix, &world, comprange),
			     targetid = comps[current_comp]);
      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_SurfaceError,wrapup);	

      EM3dbxinc(comprange, rangeinc);
      if (!BSbxint(&rc, &myrange[0], &myrange[3],
			&comprange[0], &comprange[3])) goto next_comp;
			
      if(! (only_one && !first_run))
       sts = om$send(msg = message EMSsurface.EMgetedges(EMmsg,
					EMS_OPT_CONNECTABLE,
					&comp_edges,
					&comp_buf_size,
					&num_comp_edges,
					&comp_surf_list,
					&comp_numed_list,
					&comp_list_size,
					&num_in_comp_list),
			   targetid = comps[current_comp]);
      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);		   
      /*
         If the following conditions are true, it is assumed that the user
         is attempting to make a solid/compsf out a of surface which is closed
         in both u &v or an already closed composite surface. So skip everything
       */
      if(num_comps == 1) 
          if( !num_my_edges && !num_comp_edges ) goto wrapup;

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
	num_mysf_stitches = 0;
        thispair.surf0 = my_surf_list[my_sf_ix];
        sts = EMgetGeom(EMmsg, &geom->numsf, &geom->surf_list, 
	      &geom->surf_geom, &geom->surfrange, &geom->surf_buf_size, 
	      SURF_BUF_INCREMENT, 
	      thispair.surf0, &surf_geom[0], mysfrange, FALSE, NULL, mod_info, 
	      rangeinc, makecs_options);
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
	      (!sliverproc &&
	       IF_EQ_OBJID(comp_surf_list[cp_sf_ix], my_surf_list[my_sf_ix]))
	   || (sliverproc && 
	       !IF_EQ_OBJID(comp_surf_list[cp_sf_ix], my_surf_list[my_sf_ix])))
           {
	    cp_ed_bgn = cp_ed_end;
	    continue;
           }
	  num_cpsf_stitches = 0;
          thispair.surf1 = comp_surf_list[cp_sf_ix];
          sts = EMgetGeom(EMmsg, &geom->numsf, &geom->surf_list, 
		&geom->surf_geom, &geom->surfrange, &geom->surf_buf_size, 
		SURF_BUF_INCREMENT, 
		thispair.surf1, &surf_geom[1], compsfrange, FALSE, NULL, 
		mod_info, rangeinc, makecs_options);
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
	    if(IF_NULL_OBJID(my_edges[my_ed_ix].objid)) continue;
            if(interrupt = IGEstop()) break;

            thispair.edge0 = my_edges[my_ed_ix].objid;
	    edge_geom[0] = NULL;
	
            sts = EMgetGeom(EMmsg, &geom->numed, &geom->edge_list, 
                  &geom->edge_geom, &geom->edgerange, &geom->edge_buf_size,
	          EDGE_BUF_INCREMENT, thispair.edge0, &edge_geom[0], 
	          myedrange, TRUE, surf_geom[0], mod_info, rangeinc, 
	          makecs_options);
            if(!(1&*EMmsg)) goto wrapup;
            if(*EMmsg == EMS_I_Degenerate)
             {
	      my_edges[my_ed_ix].objid = NULL_OBJID;
              EMfree_geom((IGRchar **) geom->edge_geom, geom->edgerange, 
              		  &geom->numed, 
			  geom->edge_list, thispair.edge0, TRUE);

	      continue;
             }

            thispair.edge_geom0 = edge_geom[0];
	
	    for (cp_ed_ix=cp_ed_bgn; cp_ed_ix<cp_ed_end; cp_ed_ix++)
	     {
              if(interrupt = IGEstop()) break;
	      if(IF_EQ_OBJID(my_edges[my_ed_ix].objid,
			  comp_edges[cp_ed_ix].objid)) continue;
	      if(IF_NULL_OBJID(comp_edges[cp_ed_ix].objid)) continue;
  	      thispair.edge1 = comp_edges[cp_ed_ix].objid;
	
              sts = EMgetGeom(EMmsg, &geom->numed, &geom->edge_list, 
	            &geom->edge_geom, &geom->edgerange, &geom->edge_buf_size, 
		    EDGE_BUF_INCREMENT,
	            thispair.edge1, &edge_geom[1], compedrange, TRUE, 
		    surf_geom[1], mod_info, rangeinc, makecs_options);
              if(!(1&*EMmsg)) goto wrapup;

              if(*EMmsg == EMS_I_Degenerate)
               {
	        comp_edges[cp_ed_ix].objid = NULL_OBJID;
	        EMfree_geom((IGRchar **) geom->edge_geom, geom->edgerange, 
	                  &geom->numed, 
			  geom->edge_list, thispair.edge1, TRUE);
			
	        continue;
               }

	      thispair.edge_geom1 = edge_geom[1];

              if(!BSbxint(&rc, &myedrange[0], &myedrange[3],
			&compedrange[0], &compedrange[3]))
	       {
	        *EMmsg = EMS_S_Success;
		continue;
	       }
              for(j=0; j<2; j++)
	       for(i=0; i<parted_buf[j]; i++) part_edges[j][i] = NULL_OBJID;

              sts = EMstitch(EMmsg, &thispair, &my_GRid, save_info, 
	            &to_common, &to_comps, mod_info, comps[current_comp],
		    NULL_OBJID, newly_connected, was_connected,  
		    &total_stitches, &num_mysf_stitches, &num_cpsf_stitches, 
		    part_edges, parted_buf, stitol, makecs_options);
              if(*EMmsg == EMS_E_IntersectOrient)
               {
/******************** SM 12/17/93
                if( (!(makecs_options & EMSmakecs_SpecialProcessing)) &&
                    (!(makecs_options & EMSmakecs_NoSpecialProcessing)))
*********************/
                 goto wrapup;
                /*else *EMmsg = EMS_S_Success; SM 12/17/92*/
               }
              if(!(1&*EMmsg&sts)) goto wrapup;
              if(*EMmsg == EMS_I_Fail)
 	       {
	        *EMmsg = EMS_S_Success;
	        continue;
	       }
	
	      /* If stitch succeeded the edge either got itself a common
		 edge or got split. In either case its geometry is
		 useless. Also stop considering that edge in this
		 run. It will get picked up in the next iteration.
	      */
              EMfree_geom((IGRchar **) geom->edge_geom, geom->edgerange, 
              		  &geom->numed, 
			  geom->edge_list, thispair.edge0, TRUE);

	      EMupdateEd(EMmsg, &my_edges, &num_my_edges, &my_buf_size, 
			 &my_numed_list[my_sf_ix], thispair.edge0, 
			 part_edges[0], &my_ed_ix, &to_common, &comp_edges, 
			 &num_comp_edges, &comp_numed_list[cp_sf_ix], 
			 &comp_buf_size, &my_ed_end);
	      if(!(1&*EMmsg)) goto wrapup;
	
	      EMfree_geom((IGRchar **) geom->edge_geom, geom->edgerange, 
	                  &geom->numed, 
			  geom->edge_list, thispair.edge1, TRUE);
			
              EMupdateEd(EMmsg, &comp_edges, &num_comp_edges, &comp_buf_size, 
			   &comp_numed_list[cp_sf_ix], thispair.edge1, 
			   part_edges[1], &cp_ed_ix, &to_common, &my_edges, 
			   &num_my_edges, &my_numed_list[my_sf_ix], 
			   &my_buf_size, &cp_ed_end);
	      if(!(1&*EMmsg)) goto wrapup;
	      break;
	
	     } /* for (cp_ed_ix=cp_ed_bgn; cp_ed_ix<cp_ed_end; cp_ed_ix++) */

   	    if(interrupt) break;
	
           }/* for (my_ed_ix=my_ed_bgn; my_ed_ix<my_ed_end; my_ed_ix++) */
	
	   cp_ed_bgn = cp_ed_end;
	   if(interrupt) break;
	
          } /* for (cp_sf_ix=0; cp_sf_ix<num_in_comp_list; cp_sf_ix++) */

         my_ed_bgn = my_ed_end;
         if(interrupt) break;

        } /* for (my_sf_ix=0; my_sf_ix<num_in_my_list; my_sf_ix++) */

next_comp:

      EMcompress_list(my_edges, &num_my_edges, my_surf_list, my_numed_list, 
		       &num_in_my_list, geom);

      /* If this component was newly connected, append its unconnected edges to
	 'my' list.
      */
      if(newly_connected[0] || was_connected[0]) conn[current_comp] = TRUE;
      if(newly_connected[0])
       {
	atleast_one_stitch = TRUE;
	conn[current_comp] = TRUE;
        EMcompress_list(comp_edges, &num_comp_edges, comp_surf_list, 
		       comp_numed_list, &num_in_comp_list, geom);
	if(num_comp_edges)	
	 {
	  if(my_buf_size < (num_comp_edges + num_my_edges))
	   {
	    my_buf_size += (num_comp_edges + EdInc);
	    my_edges = (struct GRid *) om$realloc(ptr = (IGRchar *) my_edges, 
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
	    my_surf_list = (GRobjid *) om$realloc
	    		(ptr = (IGRchar *) my_surf_list, 
  		         size = my_list_size * sizeof(GRobjid));
	    EMerr_hndlr(!my_surf_list, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
	    my_numed_list = (IGRint *) om$realloc
		    	(ptr = (IGRchar *) my_numed_list, 
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
       sts = EMstitch(EMmsg, &in_pairs[idx], &my_GRid, save_info, 
		       &to_common, &to_comps, mod_info, loc_comp[0], 
		       loc_comp[1], newly_connected, was_connected, 
		       &total_stitches, NULL, NULL, part_edges, parted_buf, 
		       stitol, makecs_options);
       if(!(1&*EMmsg&sts)) goto wrapup;
       if(*EMmsg == EMS_I_Fail)
        {
         *EMmsg = EMS_S_Success;
	 continue;
        }
       atleast_one_stitch = TRUE;
       if(in_num_pairs == 1) goto sti_done;

      } /* for (idx=0; (idx<in_num_pairs) && !interrupt; idx++) */

    } /* if(in_pairs) */

   if( (makecs_options & EMSmakecs_FineToCoarseTol) && 
       (iteration < NumPasses) && !atleast_one_stitch)
    {
     IGRdouble oldrangeinc, inc;
     iteration++;
     if(iteration == 2) stitol = Pass2Tol;
     else if(iteration == 3) stitol = Pass3Tol;
     else if(iteration == 4) stitol = Pass4Tol;
     else if(iteration == 5) stitol = Pass5Tol;
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
     for(i=0; i<num_comps; i++) conn[i] = FALSE;

#if DEBUG
     printf("Continuing with iteration %d tolerance %2.13lf\n", iteration, 
	    stitol);
#endif
    }

  } /* while(atleast_one_stitch && !interrupt) */

sti_done:


 /* Rigidly own all components which had slivers.
 */
 for(i=0; i<num_sliversf; i++)
  {
   sts = om$is_objid_on_channel(objid_c = my_id,
			      p_chanselect = &to_comps, 
			      objid = sliversf[i]);
   if(sts == OM_S_SUCCESS)
    continue;
   else sts = OM_S_SUCCESS;

   idx = MAXINT;
   sts = om$send(msg = message GRconnector.GRrigidconn(EMmsg, &my_GRid, 
	 &idx), targetid = sliversf[i]);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

   sts = om$send(msg = message EMSdpr.EMsetprops(&rc, &action, &mask), 
	 p_chanselect = &to_comps);
   sts = OM_S_SUCCESS;
  }


 if(!total_stitches)  /* stitches other than slivers */
  {
   IGRboolean		first_sliver = FALSE;

   for(i=0; i<num_sliversf; i++)
    if(IF_EQ_OBJID(comps[0], sliversf[i]))
     {
      first_sliver = TRUE;
      break;
     }

   if(!sliverproc && !first_sliver)
    {
     /* No surfaces could be stitched. So disconnect the one component
        owned in the begining and make it active again. The caller will
        delete the empty stitch state object.
     */
     action = TRUE;
     mask = EMSIS_ACTIVE_STATE;
     if(!in_pairs)
      {
       sts = om$send(msg = message EMSdpr.EMsetprops(&rc, &action, &mask),
             targetid = comps[0]);
       sts = OM_S_SUCCESS;
       sts = om$send(msg = message GRconnector.GRdisconn(EMmsg, &my_GRid),
	     targetid = comps[0]);
       EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
      }
     else
      {
       sts = om$send(msg = message EMSdpr.EMsetprops(&rc, &action, &mask),
             p_chanselect = &to_comps);
       sts = OM_S_SUCCESS;
       sts = om$send(msg = message GRconnector.GRdisconn(EMmsg, &my_GRid),
	     p_chanselect = &to_comps);
       EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
      }

    }

   if(!num_sliversf) *EMmsg = EMS_I_Fail;
  }

 wrapup:
  if(sliversf && (sliversf != sliversfbuf)) om$dealloc(ptr = sliversf);
  if(conn && (conn != connbuf)) om$dealloc(ptr = conn);
  if (my_edges) om$dealloc(ptr = my_edges);
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

  if( (*EMmsg != EMS_I_Fail) && !sliverproc)
   {
    union EMSssi_table		ssitable;
    IGRboolean action = FALSE;
    IGRushort mask = EMSIS_ACTIVE_STATE;
    IGRlong		sts, rc;

    ssitable.stch_info = *my_info;
    sts = om$send(msg = message EMSdpr.EMputSSI(&rc, &ssitable), 
			targetid = my_id);

    ME.EMSdpr->dpr_props = EMSIS_ACTIVE_STATE | EMSIS_ACTIVE_PATH;    
    ME.GRgraphics->properties |= GRIS_LOCATABLE | GRIS_DISPLAYABLE;

    sts = om$send(msg = message EMSdpr.EMsetprops(&rc, &action, &mask), 
                      p_chanselect = &to_comps);
    if(sts == OM_W_UNKNOWN_MSG)
      sts = OM_S_SUCCESS;

		
    /* If there was an error perform 'undo' operation else
       perform notification */
    if(!(1&*EMmsg&sts))
     {
      IGRushort undo_option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;
      IGRint display_count = 0, invoke_count = 0;
      GRobjid *display_ids = NULL;

      undo_option |= EMS_UNDO_DONTDELME;

      /* If recomputing, do not want to delete this node and above.
      */
      if(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE)
       undo_option |= (EMS_UNDO_DONTDELME | EMS_UNDO_DONTCLEANOWN 
                        | EMS_UNDO_DONTDISCONCOMPS);

      sts = om$send(msg = message EMSdpr.EMundo(&rc, &undo_option, 
		mod_info, NULL, NULL, NULL, &display_ids, &display_count, 
		&invoke_count), targetid = my_id);
     }
    else if (notify)
     {
      OMuint i, num_comps;
      IGRlong local_rc;

      num_comps = 0;
      om$get_channel_count (object = me, p_chanselect = &to_comps,
       count = &num_comps);

      for (i=0; i<num_comps; i++)
        om$send (msg = message EMSsurface.EMpostgeomod (&local_rc,
         EMS_POST_SAVEDSTATE | (i == 0 ? NULL : EMS_POST_NOCOMPONENTS), 
         mod_info, OPPmargs, NULL), from = i, to = i,
         p_chanselect = &to_comps);
     }
   }
  if (notify)
    EMrestore_postproc();

  my_info = &loc_my_info.my_info;
  if(my_info->num_edges_in) om$dealloc(ptr = my_info->num_edges_in);
  if(my_info->edges_in) om$dealloc(ptr = my_info->edges_in);
  if(my_info->edges_out) om$dealloc(ptr = my_info->edges_out);
  if(my_info->edges_connected) om$dealloc(ptr = my_info->edges_connected);

  /* If an orientation problem due to slivers was detected, invoke the method
     again, this time doing special processing.
  */
  if(*EMmsg == EMS_E_IntersectOrient)
   {
    if( (makecs_options & EMSmakecs_SpecialProcessing) ||
        (makecs_options & EMSmakecs_NoSpecialProcessing))
     *EMmsg = EMS_E_IntersectOrient;
    else
     {
      extern unsigned int OM_Gf_verbose_warning;
  
      if(OM_Gf_verbose_warning)
       fprintf(stderr, "Inconsistent Orientation..Special Processing....\n");

      sts = om$send(msg = message EMSsfstitch.EMmake_comp(EMmsg, num_comps, 
           comps, mod_info, NULL, in_pairs, in_num_pairs, NULL, 
           makecs_options | EMSmakecs_SpecialProcessing), 
           targetid = my_id);
     }
   }

  /* STOP TIMER */
   if (_use_timers)
      stop_timer  (T_EMMAKE_COMP, FALSE, "");

  if( (1&*EMmsg&sts) && (*EMmsg != EMS_I_Fail) && interrupt) 
    *EMmsg = EMS_I_Interrupt;
  EMWRAPUP(*EMmsg, sts, "In EMSsfstitch.EMmake_comp")
  return (sts);
}


#define INC	5

static IGRint EMrecord_edges(EMmsg, pair, save_info, to_comm, num1, num2, 
			     part_edges, parted_buf)
IGRlong			*EMmsg;
struct EMSstitch_info	*pair;
struct EMSstitch_saveinfo	*save_info;
OM_S_CHANSELECT		*to_comm;
IGRint			*num1, *num2;
GRobjid			*part_edges;
IGRint			*parted_buf;
{
 IGRlong	sts;
 GRobjid	edges[2];
 IGRint		i, j, total_edges_in, num_partedges = 0;
 IGRboolean	cleanup = FALSE;
 struct EMSstchssi_table	*my_info = NULL;


 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 my_info = (struct EMSstchssi_table *) &save_info->my_info;

 edges[0] = pair->edge0;
 edges[1] = pair->edge1;

 /* Record the information as to which edge was replaced by which
    edges in 'my_info' for save state. If the edge taken out has already
    been recorded then set the objid to NULL_OBJID to indicate that the old
    record should be ignored and store the uptodate information.
 */
 for(i=0; i<my_info->num_edges_out; i++)
  {
   if(IF_EQ_OBJID(my_info->edges_out[i], edges[0])
      || IF_EQ_OBJID(my_info->edges_out[i], edges[1]))
    {
     my_info->edges_out[i] = NULL_OBJID;
     cleanup = TRUE;
    }
  }

 if(cleanup)
  {
   GRobjid		*edges_out = NULL, *edges_in = NULL;
   GRobjid		*in_old, *in_new;
   IGRint	*num_edges_in = NULL, num_edges_out = 0;
   IGRint		total_num_edges_in = 0;

   for(i=0; i<my_info->num_edges_out; i++)
    {
     if(!IF_NULL_OBJID(my_info->edges_out[i]))
      {
	num_edges_out++;
	total_num_edges_in += my_info->num_edges_in[i];
      }
    }

   if(num_edges_out)
    {
     edges_out = (GRobjid *) om$malloc(size = num_edges_out * sizeof(GRobjid));
     EMerr_hndlr(!edges_out, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     num_edges_in = (IGRint *) om$malloc(size = num_edges_out *
					sizeof(IGRint));
     EMerr_hndlr(!num_edges_in, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
    }

   if(total_num_edges_in)
    {
     edges_in = (GRobjid *) om$malloc(size = total_num_edges_in * 
					   sizeof(GRobjid));
     EMerr_hndlr(!edges_in, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
    }

   num_edges_out = 0;
   in_old = (GRobjid *) my_info->edges_in;
   in_new = (GRobjid *) edges_in;
   for(i=0; i<my_info->num_edges_out; i++)
    {
     if(!IF_NULL_OBJID(my_info->edges_out[i]))
      {
	edges_out[num_edges_out] = my_info->edges_out[i];
	num_edges_in[num_edges_out] = my_info->num_edges_in[i];
	OM_BLOCK_MOVE(in_old, in_new, my_info->num_edges_in[i] * 
					sizeof(GRobjid));
	in_new += my_info->num_edges_in[i];
	num_edges_out++;
      }
     in_old += my_info->num_edges_in[i];
    }

   om$dealloc(ptr = my_info->edges_out);
   om$dealloc(ptr = my_info->edges_in);
   om$dealloc(ptr = my_info->num_edges_in);

   my_info->num_edges_out = num_edges_out;
   my_info->num_edges_in = num_edges_in;
   my_info->edges_out = edges_out;
   my_info->edges_in = edges_in;
   save_info->edges_out_buf_size = 0;
   save_info->edges_in_buf_size = 0;
   save_info->num_edges_in_buf_size = 0;

  } /* if(cleanup) */

 for(i=0; i<2; i++)
  {
   GRobjid *ped;
   
   ped = (GRobjid *) &part_edges[i ? 3 : 0];
   num_partedges = 0;
   sts = om$send(msg = message EMSedge.EMget_top_part_edges
		(EMmsg, &ped, &num_partedges, &parted_buf[i]),
		targetid = edges[i], senderid = edges[i]);
   EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
   
   /* If the edge does not have any partedges, it means that the edge matching
      did not call for splitting. The two edges were however connected
      on the common edge channel. The fact that they were connected during 
      this state needs to be recorded (for disconnection during undo). 
   */
   if( (num_partedges == 1) && IF_EQ_OBJID(ped[0], edges[i]))
    {
	OM_S_OBJECT_LINKAGE		comm;
	OMuint				count = 0, k, m, l;
	GRobjid				connedge;
	IGRboolean			in1 = FALSE, in2 = FALSE;

     if( (i ? num2 : num1)) (i ? (*num2)++ : (*num1)++);

     l = 0;
     for(k=0; (k<my_info->num_edges_out) && !in1; k++)
      for(m=0; m<my_info->num_edges_in[k]; m++, l++)
       if(IF_EQ_OBJID(my_info->edges_in[l], edges[i])) 
	{in1 = TRUE; break;}
		
     sts = om$get_channel_objects(objid = edges[i], p_chanselect = to_comm, 
				list = &comm, size = 1, count = &count);
     EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
     if(!count) continue;
     connedge = comm.S_objid;
	
     l = 0;
     for(k=0; (k<my_info->num_edges_out) && !in2; k++)
      for(m=0; m<my_info->num_edges_in[k]; m++, l++)
       if(IF_EQ_OBJID(my_info->edges_in[l], connedge)) 
	{in2 = TRUE; break;}

     /* If this edge and its common edge were both added during this operation
	then we need not store their connection information again.
     */
     if(in1 && in2)
      {
       if(!i && IF_EQ_OBJID(connedge, edges[1]))
        {
	 part_edges[3] = edges[1];
	 if(num2) (*num2)++;	
	 break;
        }
       else continue;
      }

     if(save_info->num_edges_connected_buf_size < 2)
      {
       if(my_info->num_edges_connected) 
         my_info->edges_connected = (GRobjid *) om$realloc(
			    ptr = (IGRchar *) my_info->edges_connected, 
 			    size = (my_info->num_edges_connected + 
					    INC) * sizeof(GRobjid));
       else my_info->edges_connected = (GRobjid *) om$malloc(size = 
					INC * sizeof(GRobjid));
       EMerr_hndlr(!my_info->edges_connected, *EMmsg, EMS_E_NoDynamicMemory, 
		   wrapup);
       save_info->num_edges_connected_buf_size = INC;
      }
     (my_info->edges_connected)[my_info->num_edges_connected++] = edges[i];
     (my_info->edges_connected)[my_info->num_edges_connected++] = connedge;
     (save_info->num_edges_connected_buf_size) -= 2;
     if(!i && IF_EQ_OBJID(connedge, edges[1]))
      {
       part_edges[3] = edges[1];
       if(num2) (*num2)++;	
       break;
      }
    }
   else if(num_partedges > 1)
    {
     if(!(save_info->num_edges_in_buf_size))
      {
       if(my_info->num_edges_in) 
         my_info->num_edges_in = (IGRint *) om$realloc(ptr = 
					    (IGRchar *) my_info->num_edges_in, 
	 size = (my_info->num_edges_out + INC) * sizeof(IGRint));
       else my_info->num_edges_in = (IGRint *) om$malloc(size = INC *
			sizeof(IGRint));
       EMerr_hndlr(!my_info->num_edges_in, *EMmsg, EMS_E_NoDynamicMemory, 
		   wrapup);
       save_info->num_edges_in_buf_size = INC;
      }
     my_info->num_edges_in[my_info->num_edges_out] = num_partedges;
     (save_info->num_edges_in_buf_size)--;

     if(!(save_info->edges_out_buf_size))
      {
       if(my_info->edges_out)
         my_info->edges_out = (GRobjid *) om$realloc
         	(ptr = (IGRchar *) my_info->edges_out, 
		 size = (my_info->num_edges_out + INC) * sizeof(GRobjid));
       else my_info->edges_out = (GRobjid *) om$malloc(size = sizeof(GRobjid) 
						       * INC);
       EMerr_hndlr(!my_info->edges_out, *EMmsg, EMS_E_NoDynamicMemory, 
		   wrapup);

       save_info->edges_out_buf_size = INC;
      }
     my_info->edges_out[my_info->num_edges_out] = edges[i];
     (save_info->edges_out_buf_size)--;

     total_edges_in = 0;
     for(j=0; j<my_info->num_edges_out; j++)
      total_edges_in += my_info->num_edges_in[j];

     if(save_info->edges_in_buf_size < num_partedges)
      {
       if(my_info->edges_in)
        my_info->edges_in = (GRobjid *) om$realloc
         (ptr = (IGRchar *) my_info->edges_in, 
	  size = (total_edges_in + num_partedges + INC) * sizeof(GRobjid));
        else my_info->edges_in = (GRobjid *) om$malloc(size = (num_partedges + 
						INC) * sizeof(GRobjid));
       EMerr_hndlr(!my_info->edges_in, *EMmsg, EMS_E_NoDynamicMemory, 
		   wrapup);
       save_info->edges_in_buf_size = num_partedges + INC;
      }

     OM_BLOCK_MOVE(ped, &my_info->edges_in[total_edges_in], 
		 num_partedges * sizeof(GRobjid));
     (save_info->edges_in_buf_size) -= num_partedges;

     (my_info->num_edges_out)++;

    } /* else if(num_partedges > 1) */

  }/* for(i=0; i<2; i++) */


wrapup:
EMWRAPUP(*EMmsg, sts, "In EMrecord_edges");
return(sts);
}




static void EMfree_geom(geom, rng, num, list, id, isedge)
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

/************
#if DEBUG
   printf(isedge ? "Free %d :Num in edge list %d\n" 
	         : "Free %d :Num in surf list %d\n", id, *num);
#endif
***********/

  }
}




static IGRint EMstitch(EMmsg, thispair, my_GRid, save_info, to_comm, to_comps, 
		       mod_info, compid1, compid2, newly_connected, 
		       was_connected, num_stitches, num1, num2, 
		       part_edges, parted_buf, stitol, makecs_options)

IGRlong			*EMmsg;
struct EMSstitch_info	*thispair;
struct GRid		*my_GRid;
struct EMSstitch_saveinfo *save_info;
OM_S_CHANSELECT		*to_comm, *to_comps;
struct GRmd_env		*mod_info;
GRobjid			compid1, compid2;
IGRboolean		*newly_connected, *was_connected;
IGRint			*num_stitches, *num1, *num2;
GRobjid			*part_edges;
IGRint			*parted_buf;
IGRdouble		stitol;
IGRushort 		makecs_options;
{
 IGRlong		sts, rc;
 IGRint			i;
 IGRlong		idx = MAXINT;
 IGRboolean		action = FALSE;
 IGRushort	mask = EMSIS_ACTIVE_STATE;
 IGRboolean		orientProb = FALSE;

 thispair->option |= EMSstitch_NoMoveSurfs;
/********
 if( (makecs_options & EMSmakecs_NoSpecialProcessing) ||
     (makecs_options & EMSmakecs_SpecialProcessing))
  thispair->option |= EMSstitch_IgnoreOrientError;
 else
********* SM 12/17/93 */
  thispair->option &= (~EMSstitch_IgnoreOrientError);

 sts = om$send(msg = message EMSedge.EMstitch(EMmsg, thispair, 
	       mod_info, my_GRid, NULL, stitol, NULL, NULL),
               targetid = thispair->edge0, senderid = NULL_OBJID);
 if(*EMmsg == EMS_E_IntersectOrient)
  {
   orientProb = TRUE;
   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;
  }
 EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
	
 if (*EMmsg == EMS_I_Fail)  goto wrapup;

#if DEBUG
 if(makecs_options & EMSmakecs_SliverProcessing)
  {
   if(IF_EQ_OBJID(thispair->surf0, thispair->surf1))
    printf("*** SLIVER STITCHED - edges %d and %d on surface %d\n", 
        thispair->edge0, thispair->edge1, thispair->surf0);
   else
    printf("*** SLIVER OPTION ON DIFFERENT SURFACES - %d and %d\n", 
        thispair->surf0, thispair->surf1);
  }
#endif

 EMrecord_edges(EMmsg, thispair, save_info, to_comm, num1, num2, part_edges, 
		parted_buf);
 if(!(1&*EMmsg)) goto wrapup;

 for(i=0; i<2; i++)
  {
   GRobjid compid;
   compid = i ? compid2 : compid1;
   if(IF_NULL_OBJID(compid)) continue;
   sts = om$is_objid_on_channel(objid_c = my_GRid->objid,
			      osnum_c = my_GRid->osnum, 
			      p_chanselect = to_comps, 
			      objid = compid);
   if(sts == OM_S_SUCCESS) {was_connected[i] = TRUE; continue;}
   else sts = OM_S_SUCCESS;

   if(!(makecs_options & EMSmakecs_SliverProcessing))
    {
     sts = om$send(msg = message GRconnector.GRrigidconn(EMmsg, my_GRid, 
			&idx),targetid = compid, senderid = my_GRid->objid);
     EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
     sts = om$send(msg = message EMSdpr.EMsetprops(&rc, &action, &mask), 
		 senderid = my_GRid->objid, p_chanselect = to_comps);
     sts = OM_S_SUCCESS;
    }
   newly_connected[i] = TRUE;
  }
 (*num_stitches)++;

wrapup:
#if DEBUG
if(!(1&*EMmsg&sts))
 printf("Problem in EMstitch\n");
#endif
 if(orientProb) *EMmsg = EMS_E_IntersectOrient;
return(sts);
}


static IGRint EMgetGeom(EMmsg, num, oblist, ptrlist, rnglist, bufsize, inc, id,
			gmptr, rngptr, isedge, sfgm, mod_info, rangeinc, 
			makecs_options)
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
IGRushort       makecs_options;
{
 IGRint 		i;
 IGRboolean 		found = FALSE, world = FALSE;
 IGRlong		sts = OM_S_SUCCESS;
 IGRushort		props;
 extern IGRint		EMgetvggeom();
 IGRdouble      	cht, disq_tol;
 IGRboolean 		isdegn = FALSE;

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
   *oblist = (GRobjid *) om$realloc(ptr = (IGRchar *) *oblist, 
		      size = *bufsize * sizeof(GRobjid));
   EMerr_hndlr(!(*oblist), *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   *ptrlist = (IGRchar **) om$realloc(ptr = (IGRchar *) *ptrlist, 
				      size = *bufsize * sizeof(IGRchar *));
   EMerr_hndlr(!(*ptrlist), *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   *rnglist = (GRrange **) om$realloc(ptr = (IGRchar *) *rnglist, 
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

   /* Test for degeneracy
   */
   if(makecs_options & EMSmakecs_SpecialProcessing)
    {
     BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht);
     BSEXTRACTPAR(&rc, BSTOLSQLENVEC, disq_tol);
     BSchangepar(&rc, BSTOLSQLENVEC, cht*cht);
     (void) BStstcvdegn (edgm[*num], &isdegn, &rc);
     if( (rc == BSSUCC) && isdegn)
      {
       sts = om$send(msg = message EMSedge.EMset_props(EMmsg, EMED_DEGENERATE, 
             EMS_O_ON), targetid = id, senderid = NULL_OBJID);
#if DEBUG
       printf("Edge %d marked degenerate\n", id);
#endif
       *EMmsg = EMS_I_Degenerate;
      }
     BSchangepar(&rc, BSTOLSQLENVEC, disq_tol);
    }
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

/************
#if DEBUG
 printf(isedge ? "Alloc %d :Num in edge list %d\n" 
	       : "Alloc %d :Num in surf list %d\n", id, *num);
#endif
*************/
wrapup:
#if DEBUG
if(!(1&*EMmsg&sts)) printf("Problem in EMgetGeom\n");
#endif
return(sts);
}



static IGRint EMupdateEd(EMmsg, edlist, numedlist, edlistsize, numthissf, edid,
			 ped, edlistix, to_comm, otherlist, num_other_list, 
			 num_other_sf, other_list_size, endix)
IGRlong		*EMmsg;
struct GRid	**edlist, **otherlist;
IGRint		*numedlist, *num_other_list, *numthissf, *num_other_sf;
GRobjid		edid, *ped;
IGRint		*edlistix, *edlistsize, *other_list_size, *endix;
OM_S_CHANSELECT *to_comm;
{
 OMuint		count[3];
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

 if(IF_EQ_OBJID(ped[0], edid))
  {
   /* Case 1 - edge did not get split.
   */
   (*edlist)[*edlistix].objid = NULL_OBJID;
   if(inother) (*otherlist)[otherix].objid = NULL_OBJID;
   goto wrapup;
  } 

 for(i=0; i<3; i++)
  {
   if(!IF_NULL_OBJID(ped[i]))
    {
     sts = om$get_channel_count(objid = ped[i], p_chanselect = to_comm, 
			      count = &count[i]);
     if(!(1&sts)) goto wrapup;
    }
   else count[i] = 1;
  }

 for(i=0; i<3; i++) if(!count[i]) num_connectable++;

 if(!num_connectable)
  {
   /* Case 3 - edge got split but all partedges were stitched.
   */
   (*edlist)[*edlistix].objid = NULL_OBJID;
   if(inother) (*otherlist)[otherix].objid = NULL_OBJID;
   goto wrapup;
  }
 else if(num_connectable == 1)
  {
   if(!count[0]) (*edlist)[*edlistix].objid = ped[0];
   else if(!count[1]) (*edlist)[*edlistix].objid = ped[1];
   else (*edlist)[*edlistix].objid = ped[2];
   if(inother)
    (*otherlist)[otherix].objid = (*edlist)[*edlistix].objid;
   (*edlistix)--;
   goto wrapup;
  }

 /* number of connectable edges is more than 1.
 */
 if( (*numedlist+num_connectable-1) > *edlistsize)
  {
   *edlist = (struct GRid *) om$realloc
	   	(ptr = (IGRchar *) *edlist, size = (*edlistsize+
		 num_connectable - 1 + EdInc) * sizeof(struct GRid));
   EMerr_hndlr(!*edlist, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   *edlistsize += (num_connectable - 1 + EdInc);
  }


 if( inother && ((*num_other_list+num_connectable-1) > *other_list_size))
  {
   *otherlist = (struct GRid *) om$realloc(ptr = (IGRchar *) *otherlist, 
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

 for(i=0; i<3; i++)
  {
   if(count[i]) continue;
   (*edlist)[(*edlistix)++].objid = ped[i];
   if(inother)
     (*otherlist)[otherix++].objid = ped[i];
  }

 (*numthissf) += (num_connectable - 1);
 if(inother) (*num_other_sf) += (num_connectable - 1);
 (*edlistix) = save_edlistix - 1;
 (*endix) += (num_connectable - 1);
 *numedlist += (num_connectable - 1);
 if(inother) *num_other_list += (num_connectable - 1);

wrapup:
#if DEBUG
if(!(1&*EMmsg&sts)) printf("Problem in EMupdateEd\n");
#endif
return(sts);
}



static void EMcompress_list(edlist, numed, sflist,numedlist, numsf, geom)
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
     EMfree_geom((IGRchar **) geom->surf_geom, geom->surfrange, &geom->numsf, 
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

end  implementation EMSsfstitch;

