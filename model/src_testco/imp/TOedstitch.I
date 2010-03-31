/* ###################   APOGEE COMPILED   ################## */
class implementation ECtpanaly;

#include "emserr.h"
#include "EMS.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include <stdio.h>			/* FILE 	*/
#include "emsdattyp.h"
#include "emsmacros.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsinter.h"
#include "emssfint.h"
#include "bscveval.h"
#include "bsbxint.h"
#include "bsbx2.h"
#include "TOdsl.h"
#include "TOtopology.h"
#include "TOstruct1.h"
#include "TOproto_ta.h"
#include "TOproto_ds.h"
#include "TOnumbers.h"

#define SELF	0
#define OTHR	1



/*
Name

    TOedstitch.I

Abstract

    text

Synopsis

sts=TOedstitch(struct topology *topo;
               struct EMSstitch_info *pair;
               struct edge **ed;
               IGRint sample_size;
               IGRdouble match_tol;
               IGRdouble same_an_tol;
               IGRdouble same_rd_tol;
               int          *n_poi_p_con;
               struct point **p_con_head;
               struct point **p_con_tail;
               int          *n_poi_n_con;
               struct point **n_con_head;
               struct point **n_con_tail;
               int          *n_poi_r_con;
               struct point **r_con_head;
               struct point **r_con_tail)

   topo         - main structure of topological informations
   pair         - structure with the geometrical informations for surfaces
                  and edges which are to compare
   ed           - list of the pointers of the edges to compare in the topo-
                  logical data structure
   sample_size  - number of points for analysis
   match_tol    - same point tolerance
   same_an_tol  - same angle tolerance
   same_rd_tol  - same radius tolerance
   n_poi_p_con	- number of points with violated distance continuity
   p_con_head	- list header for points with violated distance continuity
   p_con_tail	- list tail for points with violated distance continuity
   n_poi_n_con	- number of points with violated normal continuity
   n_con_head	- list header for points with violated normal continuity
   n_con_tail	- list tail for points with violated normal continuity
   n_poi_r_con	- number of points with violated radius continuity
   r_con_head	- list header for points with violated radius continuity
   r_con_tail	- list tailfor points with violated radius continuity

Description

  This method performs the "stitching" operation with a partner-to-be
  edge.
  The overlap interval is found and the required analysis is performed
   

Return Value

  sts=TOanalyze_failed (-1)
                - if there are computing errors
		  
  sts=TOno_conti (0)
                - if the investigation is not successful, i.e. there is not 
		  at least one overlap, which is successfully stitched.

  sts=TOpoint_conti (1)
                - if the investigation is successful for point continuity

  sts=TOnormal_conti (2)
                - if the investigation is successful for normal continuity

  sts=TOradius_conti (3)
                - if the investigation is successful for radius continuity


Notes

Index

Keywords

History

B.Burkhardt 09-Mar-94 Created as modification of EMSedge.EMstitch
                      (..modelsrc/src_bound/imped/EMedstitch.I)
                      removed all parts for connecting edges
B.Burkhardt 09-May-94 Improvement for edge geometry handling
B.Burkhardt 27-Jul-94 Improvement for Investigate edge
B.Burkhardt 12-Sep-94 Included worst case display
*/

int TOedstitch(struct topology *topo,
               struct       EMSstitch_info *pair,
               struct       edge **ed,
               IGRint       sample_size,
               IGRdouble    match_tol,
               IGRdouble    same_an_tol,
               IGRdouble    same_rd_tol,
               int          *n_poi_p_con,
               struct point **p_con_head,
               struct point **p_con_tail,
               int          *n_poi_n_con,
               struct point **n_con_head,
               struct point **n_con_tail,
               int          *n_poi_r_con,
               struct point **r_con_head,
               struct point **r_con_tail)

{
   IGRlong             		EMmsg;
   IGRlong             		OM_stat;
   GRspacenum                   pair_space[2];
   struct IGRbsp_curve 		*edge_geom[2];
   struct IGRbsp_surface  	*surf_geom[2];
   IGRpoint 			min[2], max[2];
   BSrc  			rc;
   IGRshort 			edg_ix;
   IGRint			num_ovlap;
   IGRdouble			bsovlap[2][4];
   IGRint			ovlap_type[2][4];
   GRobjid 			edge[2], surf[2];
   IGRdouble			cht_tol, sti_tol;
   extern void EMget_stitchtol() ;
  
   int             sts =NULL;
   IGRint          num_hits,num_misses;

   OM_stat = OM_S_SUCCESS;
   EMmsg = EMS_S_Success;

   edge[SELF] = pair->edge0;
   edge[OTHR] = pair->edge1;
   surf[SELF] = pair->surf0;
   surf[OTHR] = pair->surf1;
  
   surf_geom[SELF] = pair->surf_geom0;
   surf_geom[OTHR] = pair->surf_geom1;
   edge_geom[SELF] = pair->edge_geom0;
   edge_geom[OTHR] = pair->edge_geom1;

   pair_space[SELF] = ed[SELF]->ext->referenced_object.osnum;
   pair_space[OTHR] = ed[OTHR]->ext->referenced_object.osnum;
   
   
   if(ed[SELF]->status ==9 || ed[OTHR]->status == 9)
   {
#ifdef TEST_INV
      printf("edge %d is degenerated\n",edge[edg_ix]);
#endif
      OM_stat = NULL;
      EMmsg = EMS_I_Fail;
      goto wrapup;
   }
   BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht_tol);
   if(rc != BSSUCC)
   {
#ifdef DBG
      printf("cht could not be extracted\n");
#endif
      OM_stat = -1;
      EMerr_hndlr(rc != BSSUCC,EMmsg,EMS_E_BSerror,wrapup);   
   }
   
   sti_tol = 0;
   if(pair->option & TOstitch_top_tol)
      sti_tol = match_tol;
   else
   {
      EMget_stitchtol(&EMmsg, edge[0], edge[1], &sti_tol);
      EMerr_hndlr(!(1&EMmsg),EMmsg,EMS_E_EdgeError,wrapup);
   }

   for(edg_ix=0;edg_ix<2;edg_ix++)
   {
      if( !(pair->option & TOstitch_no_range_check))
      {
         BSbx2(&rc, &edge_geom[edg_ix]->num_poles,
                    (IGRpoint *)edge_geom[edg_ix]->poles,
	            edge_geom[edg_ix]->weights, min[edg_ix], max[edg_ix]);
         EMerr_hndlr(rc != BSSUCC,EMmsg,EMS_E_BSerror,wrapup);
         min[edg_ix][0] -= sti_tol; max[edg_ix][0] += sti_tol;
         min[edg_ix][1] -= sti_tol; max[edg_ix][1] += sti_tol;
         min[edg_ix][2] -= sti_tol; max[edg_ix][2] += sti_tol;
      }
   }
   if(!(pair->option & TOstitch_no_range_check)&&
      !BSbxint(&rc, min[SELF], max[SELF], min[OTHR], max[OTHR]))
   {
      OM_stat = NULL;
      goto wrapup;
   }    
   if ((pair->option & TOanalyz_p_cont)||
       (pair->option & TOanalyz_n_cont)||
       (pair->option & TOanalyz_r_cont)||
       (pair->option & TOPO_MO_DISTANCE))
   {
      num_misses = NULL;
      num_hits   = NULL;
      bsovlap[SELF][0] = ed[SELF]->ext->bound[0].param;
      bsovlap[OTHR][0] = ed[OTHR]->ext->bound[0].param;
      bsovlap[SELF][1] = ed[SELF]->ext->bound[1].param;
      bsovlap[OTHR][1] = ed[OTHR]->ext->bound[1].param;
      if(((pair->option & TOanalyz_p_cont)||(pair->option & TOPO_MO_DISTANCE))&&
        !((pair->option & TOanalyz_n_cont)||(pair->option & TOPO_MO_NORMAL))&&
        !((pair->option & TOanalyz_r_cont)||(pair->option & TOPO_MO_RADIUS)))
         sts = TOvalcv_ovlap(&EMmsg,
                             edge_geom[SELF], edge_geom[OTHR],
                             &bsovlap[SELF][0], &bsovlap[OTHR][0],
                             sample_size, &num_hits, &num_misses,
                             sti_tol,pair->option, topo,
                             n_poi_p_con, p_con_head, p_con_tail);
      else
         sts = TOvalsf_ovlap(&EMmsg,
                             surf, edge, pair_space,
                             surf_geom, edge_geom,
                             &bsovlap[SELF][0], &bsovlap[OTHR][0],
                             sample_size, &num_hits, &num_misses,
                             sti_tol,same_an_tol,same_rd_tol,pair->option,
                             topo,
                             n_poi_p_con, p_con_head, p_con_tail,
                             n_poi_n_con, n_con_head, n_con_tail,
                             n_poi_r_con, r_con_head, r_con_tail);
         
      if(sts<NULL)
      {
#ifdef DBG
          printf("TOvalsf_ovlap failed\n");
#endif
          return(sts);
      }
      else
      {
         OM_stat = sts;
         goto wrapup;
      }
   }
   if((pair->option&TOcheck_interval)&&(edge_geom[0]->num_poles == 2 &&
                                  edge_geom[1]->num_poles == 2))
   {
      OM_stat = TOpoint_conti;
      goto wrapup;
   }
   OM_stat = TOgetcv_ovlap(&EMmsg, ed, &num_ovlap,
		          &bsovlap[0][0], &bsovlap[1][0], sti_tol,
		          &ovlap_type[0][0], &ovlap_type[1][0], pair->option);
   EMerr_hndlr(!(1&OM_stat),EMmsg,EMS_E_OMerror,wrapup);
   
   if(!num_ovlap)
   {
      OM_stat = NULL;
      goto wrapup;
   }
   if (pair->option & TOcheck_interval)
   {
      OM_stat = 1;
      goto wrapup;
   }
   if(num_ovlap == 1 && (pair->option & TOsplit_edges))
   { 
      sts = TOpartedge(topo,ed,ovlap_type,bsovlap);
      if(sts)
      {
         OM_stat = -1;
         goto wrapup;
      }
   }
   else if(num_ovlap == 2 && (pair->option & TOsplit_edges))
   { 
      sts = TOpartedge1(topo,ed,ovlap_type,bsovlap);
      if(sts)
      {
         OM_stat = -1;
         goto wrapup;
      }
   }

wrapup:

   return(OM_stat);
}

end implementation ECtpanaly;

