/*
This file contains the analysis functions for the Topology Analysis project.
*/

class implementation Root;

# include <alloca.h>
# include "igrtypedef.h"
# include "igetypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "gr.h"
# include "go.h"
# include "ex.h"
# include "grdpbdef.h"
# include "grdpbmacros.h"
# include "dp.h"
# include "griodef.h"
# include "grio.h"
# include "lcdef.h"
# include "lc.h"
# include "EMSasnuc.h"
# include "EMSasmacros.h"
# include "EMSasnucdef.h"
# include "madef.h"
# include "godef.h"
# include "EMSmsgdef.h"
# include "OMerrordef.h"
# include "emserr.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "msmacros.h"
# include "EMSopt.h"
# include "EMSprop.h"
# include "EMS.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "EMSlmdef.h"
#include "EMSasopts.h"
#include "EC_P.h"
#include "EC_S.h"
#include "EC_I.h"
#include "EC_E.h"
#include "EC_M.h"
#include "GRtypedef.h"
#include "EMSascmacros.h"
# include <stdio.h>
# include "ECmsg.h"
# include "ECmsg.h"
# include "TOdsl.h"
# include "TOnumbers.h"
# include "TOstruct1.h"
# include "TOtopology.h"
# include "TOproto_ta.h"
#include "TOproto_ds.h"

#define ARC_DEGREE 180.0/3.1415926

/*
Name

   TOinvest_edge_match

Abstract

    text

Synopsis

   int TOinvest_edge_match(struct topology *topo,
                           struct edge     *edge1,
                           struct edge     *edge2,
                           int             *n_poi_p_con,
                           struct point    **p_con_head,
                           struct point    **p_con_tail,
                           int             *n_poi_n_con,
                           struct point    **n_con_head,
                           struct point    **n_con_tail,
                           int             *n_poi_r_con,
                           struct point    **r_con_head,
                           struct point    **r_con_tail)


   topo			- pointer to the main structure for topology
   edge1		- pointer to the first edge for investigation 
   edge2		- pointer to the second edge for investigation
   n_poi_p_con		- number of points where point cont is violated
   p_con_head		- header of list of points
   p_con_tail		- tail of list of points
   n_poi_n_con		- number of points where normal cont is violated
   n_con_head		- header of list of points
   n_con_tail		- tail of list of points
   n_poi_r_con		- number of points where radius cont is violated
   r_con_head		- header of list of points
   r_con_tail		- tail of list of points

Description

   investigate match for given edges at a defined number of sample points 
   and write information to a file and display points where continuity
   failed

Return Value

    0		if processing succesfull 
    != 0 	if processing failed

Notes

Index

Keywords

History

    27 Jul 94   B.Burkhardt     Creation
*/
int TOinvest_edge_match(struct topology *topo,
                        struct edge     *edge1,
                        struct edge     *edge2,
                        int             *n_poi_p_con,
                        struct point    **p_con_head,
                        struct point    **p_con_tail,
                        int             *n_poi_n_con,
                        struct point    **n_con_head,
                        struct point    **n_con_tail,
                        int             *n_poi_r_con,
                        struct point    **r_con_head,
                        struct point    **r_con_tail)
{
   IGRint                sample_size ;
   IGRdouble             match_tol ;
   IGRdouble             same_an_tol;
   IGRdouble             same_rd_tol;
   struct EMSstitch_info pair;
   int                   sts=NULL;
   int                   nret=NULL;
   struct edge           *ed[2];
   IGRdouble             max_dist, max_norm, max_radi;

#ifdef DBG
   printf("TOinvest_edge_match\n");
#endif
   ex$message(msgnumb = EMS_I_ClearStatusField);
   ex$message(msgnumb = EMS_P_ClearPromptField);
   if(edge1 == NULL || edge2 == NULL)
   {
      nret = -1;
      ex$message(field = ERROR_FIELD,
                 msgnumb = EMS_E_InvEdFail); /*Invest Edge Match failed*/
      goto wrapup;
   }
   sts = TOprint_hd(topo);
   if(sts)
#ifdef DBG
      printf("hat nicht geklappt\n");
#endif

   if(!(topo->pa.option & TOPO_MO_RADIUS) &&
      !(topo->pa.option & TOPO_MO_NORMAL) &&
       (topo->pa.option & TOPO_MO_DISTANCE))
      {
         ex$message(field = ERROR_FIELD,
                    msgnumb = EMS_E_PrDistV);/*Processing Distance Violation*/
      }
      else if(!(topo->pa.option & TOPO_MO_RADIUS) &&
               (topo->pa.option & TOPO_MO_NORMAL))
      {
         ex$message(field = ERROR_FIELD,
                    msgnumb = EMS_E_PrDiNo);/*Processing Distance and Normal
                                             Violation*/
      }
      else if(topo->pa.option & TOPO_MO_RADIUS)
      {
         ex$message(field = ERROR_FIELD,
                    msgnumb = EMS_E_PrDiNoRa);/*Processing Distance,Normal
                                             and Radius Violation*/
      }


   pair.option  = TOstitch_top_tol | TOstitch_no_range_check;
   sample_size  = topo->pa.number_of_edge_match_points;
   match_tol    = topo->pa.distance;
   same_an_tol  = topo->pa.normal;
   same_rd_tol  = topo->pa.radius;

   if((topo->pa.option & TOPO_MO_DISTANCE) &&
      !(topo->pa.option & TOPO_MO_NORMAL) &&
      !(topo->pa.option & TOPO_MO_RADIUS))
   {
      pair.option |= TOPO_MO_DISTANCE;
      pair.option &= ~TOPO_MO_NORMAL & ~TOPO_MO_RADIUS;
      pair.option |= TOstitch_no_range_check;
      pair.option &= ~TOcheck_interval & ~TOsplit_edges &  ~TOget_interval;
   }
   if((topo->pa.option & TOPO_MO_NORMAL) &&
      !(topo->pa.option & TOPO_MO_RADIUS))
   {
      pair.option |= TOPO_MO_DISTANCE ;
      pair.option |= TOPO_MO_NORMAL;
      pair.option &=  ~TOPO_MO_RADIUS;
      pair.option |= TOstitch_no_range_check;
      pair.option &= ~TOcheck_interval & ~TOsplit_edges &  ~TOget_interval;
   }
   if(topo->pa.option & TOPO_MO_RADIUS)
   {
      pair.option |= TOPO_MO_DISTANCE ;
      pair.option |= TOPO_MO_NORMAL;
      pair.option |= TOPO_MO_RADIUS;
      pair.option |= TOstitch_no_range_check;
      pair.option &= ~TOcheck_interval & ~TOsplit_edges &  ~TOget_interval;
   }
   pair.edge0        = edge1->ext->referenced_object.objid;
   pair.edge1        = edge2->ext->referenced_object.objid;
   pair.surf0        = edge1->sf->ext->referenced_object.objid;
   pair.surf1        = edge2->sf->ext->referenced_object.objid;
   pair.edge_geom0   = edge1->edid0->ext->edge;
   pair.edge_geom1   = edge2->edid0->ext->edge;
   pair.surf_geom0   = edge1->sf->ext->surf;
   pair.surf_geom1   = edge2->sf->ext->surf;

   ed[0]             = edge1;
   ed[1]             = edge2;

   sts = TOedstitch(topo,&pair,ed,sample_size,
                    match_tol,same_an_tol,same_rd_tol,
                    n_poi_p_con,p_con_head,p_con_tail,
                    n_poi_n_con,n_con_head,n_con_tail,
                    n_poi_r_con,r_con_head,r_con_tail);
   if(sts<NULL)
   {
      nret = sts;
      ex$message(field = ERROR_FIELD,
                 msgnumb = EMS_E_InvEdFail); /*Invest Edge Match failed*/
#ifdef DBG
      printf("TOinvest_edge_match\n");
#endif
      goto wrapup;
   }
   if(topo->pa.max_dist_viol<1.e-6)
      max_dist = 0.0;
   else
      max_dist = topo->pa.max_dist_viol;
   if(topo->pa.max_norm_viol<1.e-6)
      max_norm = 0.0;
   else
      max_norm = topo->pa.max_norm_viol*ARC_DEGREE;
   if(topo->pa.max_radi_viol<1.e-6)
      max_radi = 0.0;
   else
      max_radi = topo->pa.max_radi_viol;

   if(!(topo->pa.option & TOPO_MO_RADIUS) &&
      !(topo->pa.option & TOPO_MO_NORMAL) &&
       (topo->pa.option & TOPO_MO_DISTANCE))
      {
         ex$message(field = ERROR_FIELD,
                    msgnumb = EMS_E_MaxDist, /* Dist:.........*/
                    type = "%12.6f",
                    var = `max_dist`);
      }
      else if(!(topo->pa.option & TOPO_MO_RADIUS) &&
               (topo->pa.option & TOPO_MO_NORMAL))
      {
         ex$message(field = ERROR_FIELD,
                    msgnumb = EMS_E_MaxDiNo, /* Dist:...Norm:...*/
                    type = "%12.6f %12.6f",
                    var = `max_dist,max_norm`);

      }
      else if(topo->pa.option & TOPO_MO_RADIUS)
      {
         ex$message(field = ERROR_FIELD,
                    msgnumb = EMS_E_MaxViol, /* Dist:...Norm:...Rad:...*/
                    type = "%12.6f %12.6f %12.6f",
                    var = `max_dist,max_norm,max_radi`);
      }
wrapup:
   return(nret) ;
}
end implementation Root;
