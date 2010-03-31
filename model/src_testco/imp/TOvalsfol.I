/*
Name

	TOvalsfovlap.I

Abstract


Synopsis

IGRint TOvalsf_ovlap( IGRlong *EMmsg,
                      GRobjid surf[2],
                      GRobjid edge[2],
                      GRspacenum pair_space[2],
                      struct IGRbsp_surface *surf_geom[2],
                      struct IGRbsp_curve *edge_geom[2],
                      IGRdouble *ovlap0,
                      IGRdouble *ovlap1,
                      IGRint sample_size,
                      IGRint *num_hits,
                      IGRint *num_misses,
                      IGRdouble sti_tol,
                      IGRdouble same_an_tol,
                      IGRdouble same_rd_tol,
                      IGRushort option,
                      struct topology *topo,
                      int             *n_poi_p_con,
                      struct point    **p_con_head,
                      struct point    **p_con_tail,
                      int             *n_poi_n_con,
                      struct point    **n_con_head,
                      struct point    **n_con_tail,
                      int             *n_poi_r_con,
                      struct point    **r_con_head,
                      struct point    **r_con_tail)

			
   EMmsg  		- return code
   surf[2]
   edge[2]
   pair_space[2]
   surf_geom
   edge_geom            - curve0
   ovlap0		- overlap on curve0
   ovlap1		- overlap on curve1
   sample_size		- number of sample pts.
   num_hits		- number of hits
   num_misses		- number of misses
   sti_tol		- stitch tolerance (same point toler)
   same_an_tol		- same angle tolerance
   same_rd_tol		- same radius tolerance
   option		- validation option	
   topo                 - main structure for topology
   n_poi_p_con          - number of points where point cont is violated
   p_con_head           - header of list of points
   p_con_tail           - tail of list of points
   n_poi_n_con          - number of points where normal cont is violated
   n_con_head           - header of list of points
   n_con_tail           - tail of list of points
   n_poi_r_con          - number of points where radius cont is violated
   r_con_head           - header of list of points
   r_con_tail           - tail of list of points

Description

Return Values

  EMS_S_Success		if all goes well.

  EMS_E_InvalidArg  	if num_hits or num_misses is a NULL pointer 
			
			OR
		
			if sample size is less than 2.

  EMS_E_BSerror		if a BS (math) call fails.

Notes

History

  B.Burkhardt 12 Apr 94      Created as a modification of EMvalcvovlap.C
  B.Burkhardt 12 Aug 94      Update for the quick_project method
  B.Burkhardt 12 Sep 94      Included worst case display

*/

class implementation ECtpanaly;

#include "EMS.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "OMprimitives.h"

/* igr.h replacement */

# ifndef igrdef_include
# include "igrdef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */

/* gr.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef grdpbdef_include
# include "grdpbdef.h"
# endif

# ifndef grdpbmacros_include
# include "grdpbmacros.h"
# endif

/* end of gr.h replacement */

#include <stdio.h>
#include "ex.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include <math.h>
#include "emsmacros.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "bsdistptpt.h"
#include "bsmdstptcv.h"
#include "bsdividecv.h"
#include "bscvkttol2.h"
#include "bscveval.h"
#include "bssfeval.h"
#include "bscrossp.h"
#include "bsmdistptsf.h"
#include "bsdistptpts.h"
#include "bssfarrevn.h"
#include "bssfarrevmc.h"
#include "bssin.h"
#include "bsvalues.h"
#include "maang2vc.h"
#include "TOproto_ds.h"
#include "TOnumbers.h"
#include "TOtopology.h"

#define SELF    0
#define OTHR    1
#define BGN     0
#define END     1

#define EDGEU0 0
#define EDGEV1 1
#define EDGEU1 2
#define EDGEV0 3

#define TparsBuff	20

#define CURVMIN 1.e-5
#define RADMAX  1.e5

from EMSedge	import EMgetbounds;
from EMSedge	import EMget_location;

extern OMuword OPP_EMSpartedge_class_id;

IGRint TOvalsf_ovlap( IGRlong *EMmsg,
                      GRobjid surf[2],
                      GRobjid edge[2],
                      GRspacenum pair_space[2],
                      struct IGRbsp_surface *surf_geom[2],
                      struct IGRbsp_curve *edge_geom[2],
                      IGRdouble *ovlap0,
                      IGRdouble *ovlap1,
                      IGRint sample_size,
                      IGRint *num_hits,
                      IGRint *num_misses,
                      IGRdouble sti_tol,
                      IGRdouble same_an_tol,
                      IGRdouble same_rd_tol,
                      IGRushort option,
                      struct topology *topo,
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
   IGRlong     	        OM_stat;
   IGRdouble 		dist1, dist2 ,
                        knot_tol0, knot_tol1,
			ovlap0_bgn, ovlap0_end,
			ovlap1_bgn, ovlap1_end,
			ovlap_tmp, worst_dist;
   IGRdouble 		worst_loc_dist;
   IGRpoint		w_point;
   IGRpoint		w_loc_point;
   IGRpoint		w_loc_nor_p;
   IGRpoint		w_loc_rad_p;
   IGRpoint		point00,point01,point1;
   IGRint		sts =NULL;
   IGRint		sts1=NULL;
   IGRint		i =NULL;
   IGRint		state =NULL;
   IGRint		vio_dis =NULL;
   IGRint		vio_nor =NULL;
   IGRint		vio_rad =NULL;
   BSrc			rc;
   struct point         *phead_p = NULL;
   struct point         *ptail_p = NULL;
   struct point         *pmax_p = NULL;
   struct point         *phead_n = NULL;
   struct point         *ptail_n = NULL;
   struct point         *pmax_n = NULL;
   struct point         *phead_r = NULL;
   struct point         *ptail_r = NULL;
   struct point         *pmax_r = NULL;
  
   IGRdouble		*tpars0 = NULL, tparsbuff0[TparsBuff];
   IGRdouble cvpar[2];
   struct IGRbsp_curve *crv0, *crv1;
  
/* declarations for quick_project,description see there */
   IGRint       num_pts;
   IGRdouble    *input_pts = NULL ;
   IGRdouble    *output_pts = NULL;
   IGRdouble    *output_par = NULL;
   IGRdouble    *distances = NULL;
   IGRdouble    *i_pts = NULL ;
   IGRdouble    *o_pts = NULL;
   IGRdouble    *o_par = NULL;
   IGRdouble    *dist = NULL;
   IGRdouble    *p, *q, *r, *s, *smax;
   IGRint       max_i;
   IGRdouble    max_dist;
   IGRint       max_n = NULL;
   IGRdouble    worst_nor;
   IGRdouble    worst_loc_nor;
   IGRdouble    *nor = NULL;
   IGRdouble    *normals = NULL;
   IGRint       max_r = NULL;
   IGRdouble    worst_rad;
   IGRdouble    worst_loc_rad;
   IGRdouble    *rad = NULL;
   IGRdouble    *rad_rel = NULL;
   IGRint       err_i;
   IGRlong      ret;
   IGRboolean   restart;
   IGRint       max_loc_d;
   IGRint       max_loc_n;
   IGRint       max_loc_r;

   OM_stat = OM_S_SUCCESS;
   r = o_par; /*wrt compiler */
   q = o_pts; /*wrt compiler */
   /*start initialization for while loop */
   restart = TRUE;
   err_i   = -1;
   num_pts = sample_size;
   worst_dist = topo->pa.max_dist_viol;
   worst_nor = topo->pa.max_norm_viol;
   worst_rad = topo->pa.max_radi_viol;
   worst_loc_dist = NULL;
   worst_loc_nor = NULL;
   worst_loc_rad = NULL;
   max_loc_d = -1;
   max_loc_n = -1;
   max_loc_r = -1;
   /* for investigate edge match initialize point list for misses
      and initialize worst_dist*/
   if(option & TOPO_MO_DISTANCE)
   {
      worst_dist = NULL;
      sts = TOinit_pt(topo,&phead_p,&ptail_p);
      if(sts)
      {
         sts = -1;
         goto wrapup;
      }
   }
   if(option & TOPO_MO_NORMAL)
   {
      worst_nor = NULL;
      worst_rad = NULL;
      topo->pa.max_norm_viol = NULL;

      sts = TOinit_pt(topo,&phead_n,&ptail_n);
      if(sts)
      {
         sts = -1;
         goto wrapup;
      }
   }
   if(option & TOPO_MO_RADIUS)
   {
      topo->pa.max_radi_viol = NULL;
      sts = TOinit_pt(topo,&phead_r,&ptail_r);
      if(sts)
      {
         sts = -1;
         goto wrapup;
      }
   }
   sti_tol = sti_tol;		/*wrt the compiler */
   *EMmsg = EMS_S_Success;
  
   if (!num_hits || !num_misses || sample_size < 2)
       {*EMmsg  = EMS_E_InvalidArg; goto wrapup;}

   if(sample_size+1 > TparsBuff)
   {
      tpars0 =(IGRdouble *) om$malloc(size = (sample_size+1)*sizeof(IGRdouble));
   }
   else
   {
       tpars0 = (IGRdouble *) tparsbuff0;
   }
   EMerr_hndlr(!tpars0, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   input_pts =(IGRdouble *)om$malloc(size=3*(sample_size+1)*sizeof(IGRdouble));
   EMerr_hndlr(!input_pts, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   output_pts=(IGRdouble *)om$malloc(size=3*(sample_size+1)*sizeof(IGRdouble));
   EMerr_hndlr(!output_pts, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   output_par=(IGRdouble *)om$malloc(size=(sample_size+1)*sizeof(IGRdouble));
   EMerr_hndlr(!output_par, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   distances =(IGRdouble *) om$malloc(size=(sample_size+1)*sizeof(IGRdouble));
   EMerr_hndlr(!distances, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   normals =(IGRdouble *) om$malloc(size=(sample_size+1)*sizeof(IGRdouble));
   EMerr_hndlr(!normals, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   rad_rel =(IGRdouble *) om$malloc(size=(sample_size+1)*sizeof(IGRdouble));
   EMerr_hndlr(!rad_rel, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   crv0 = edge_geom[0];
   crv1 = edge_geom[1];

   BScvkttol2(crv0->order, crv0->knots, crv0->num_poles,
              crv0->poles, crv0->weights, &knot_tol0, &rc);
   EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

   BScvkttol2(crv1->order, crv1->knots, crv1->num_poles,
              crv1->poles, crv1->weights, &knot_tol1, &rc);
   EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
 
  
   *num_hits = NULL;
   *num_misses = NULL;
   vio_dis = NULL;
   vio_nor = NULL;
   vio_rad = NULL;
  
   /* if there are not enough points for quick_project
      or if curve_order<3 use BSmdstptcv */
   if(sample_size < crv1->num_poles || crv1->order<3)
   {
      if (ovlap0[0] < ovlap0[1])
      {
         ovlap0_bgn = ovlap0[0];
         ovlap0_end = ovlap0[1];
      }
      else
      {
         ovlap0_bgn = ovlap0[1];
         ovlap0_end = ovlap0[0];
      }
      if (ovlap1[0] < ovlap1[1])
      {
         ovlap1_bgn = ovlap1[0];
         ovlap1_end = ovlap1[1];
      }
      else
      {
         ovlap1_bgn = ovlap1[1];
         ovlap1_end = ovlap1[0];
      }
      /* fill the parameter vector for the input points*/
      dist1 = (ovlap0_end -ovlap0_bgn)/(sample_size - 1);
      tpars0[0]=ovlap0_bgn;
      for(s=tpars0+1,smax=tpars0+sample_size-1; s<smax; s++)
         *s = *(s-1)+dist1;
      tpars0[sample_size-1]=ovlap0_end;
      for (i=0,p=input_pts,q=output_pts,s=distances; i<num_pts;
           i++,p+=3,       q+=3,        s++)
      {
         BScveval(crv0, tpars0[i], 0, (IGRpoint *)p, &rc);
         EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   
         BSmdstptcv(crv1,p, &(output_par[i]),q, s, &rc);
         EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      }/* for (i=0,p=input_pts,q=output_pts,s=distances; i<num_pts;
               i++,p+=3,       q+=3,        s++)*/
   }
   else/*if(sample_size < crv1->num_poles)*/
   {
      if (ovlap1[0] < ovlap1[1])
      {
         ovlap1_bgn = ovlap1[0];
         ovlap1_end = ovlap1[1];  
         ovlap0_bgn = ovlap0[0];
         ovlap0_end = ovlap0[1];  
      }
      else
      {
         ovlap1_bgn = ovlap1[1];
         ovlap1_end = ovlap1[0];  
         ovlap0_bgn = ovlap0[1];
         ovlap0_end = ovlap0[0];  
      }
      BScveval(crv0, ovlap0_bgn, 0, &point00, &rc);
      EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      BScveval(crv0, ovlap0_end, 0, &point01, &rc);
      EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      BScveval(crv1, ovlap1_bgn, 0, &point1, &rc);
      EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      dist1 = BSdistptpts(&rc,point00,point1);
      EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      dist2 = BSdistptpts(&rc,point01,point1);
      EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      if(dist1>dist2)
      {

         ovlap_tmp = ovlap0_bgn;
         ovlap0_bgn = ovlap0_end;
         ovlap0_end = ovlap_tmp;
      }
      /* fill the parameter vector for the input points*/
      dist1 = (ovlap0_end -ovlap0_bgn)/(sample_size - 1);
      tpars0[0]=ovlap0_bgn;
      for(s=tpars0+1,smax=tpars0+sample_size -1; s<smax; s++)
         *s = *(s-1)+dist1;
      tpars0[sample_size-1]=ovlap0_end;
      /* evaluate the list of input points for quick_project */
      for (p=input_pts ,s=tpars0,smax=tpars0+num_pts; s<smax; i++, p+=3 ,s++)
      {
         BScveval(crv0, *s, 0, (IGRpoint *)p, &rc);
         EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   
      } 
      while(restart)/* start quick_project if there are not all list elements
                     investigated*/
      { 
         if(err_i == -1)/*this is the start initialization*/
         {
            err_i      = NULL;
            ovlap_tmp  = ovlap1_bgn;
            num_pts    = sample_size;
            i_pts      = input_pts;   
            o_pts      = output_pts;   
            o_par      = output_par;   
            dist       = distances;   
         }
         else
         {/*update the start pointers for input and output arrays*/
            ovlap_tmp  = *r;
            num_pts    = num_pts-err_i-1;
            i_pts      = (p+3);   
            o_pts      = (q+3);   
            o_par      = (r+1);   
            dist       = (s+1);   
         }

         TOquick_pr_pt_cv (crv1, ovlap_tmp,ovlap1_end,num_pts,
                           i_pts,o_pts,o_par, dist,
                           &max_i,&max_dist,&err_i,&ret);
         if(ret == -1)/*bscveval failed*/
            goto wrapup;
         /* TOquick_pr_pt_cv failed; give help for the bad point and
            then give quick_project a new chance */ 
         if(!ret)
         {
            p = &(i_pts[3*err_i]);
            r = &(o_par[err_i]);
            q = &(o_pts[3*err_i]);
            s = &(dist[err_i]);
            BSmdstptcv(crv1,p, r,q, s, &rc);
            EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
         }/*if(!ret)*/
         if((err_i == num_pts - 1)||ret) restart = FALSE;
      }/*while(restart)*/
   }/*if(sample_size < crv1->num_poles)*/
   if(sample_size > 2 && crv1->phy_closed)
   {
      IGRdouble test;
      test = 20*knot_tol1;
      if(output_par[0] < ovlap1_bgn + test &&
         output_par[2] - output_par[1]< NULL)
         output_par[0] = ovlap1_end;

      if(output_par[0] > ovlap1_end - test &&
         output_par[2] - output_par[1]> NULL)
         output_par[0] = ovlap1_bgn;

      if(output_par[sample_size-1] < ovlap1_bgn + test &&
         output_par[sample_size-2] - output_par[sample_size-3] > NULL)
         output_par[sample_size-1] = ovlap1_end;

      if(output_par[sample_size-1] > 1 - test &&
         output_par[sample_size-2] - output_par[sample_size-3] < NULL)
         output_par[sample_size-1] = ovlap1_bgn;
   }

   for(i=0,p=input_pts,q=output_pts,rad=rad_rel,nor=normals,s=distances;
       i<sample_size;
       i++,p+=3,       q+=3,        rad++,      nor++,      s++)
   {
      *nor = NULL;
      *rad = NULL;
      if (*s > worst_dist)
      {
         max_i      = i;
         worst_dist = *s;
         w_point[0] = *(q);
         w_point[1] = *(q+1);
         w_point[2] = *(q+2);
      }
      if(*s >sti_tol || (output_par[i] < ovlap1_bgn - knot_tol1 ||
                           output_par[i] > ovlap1_end + knot_tol1))
      {
         if(*s < sti_tol && output_par[i] < ovlap1_bgn - knot_tol1)
         {
            BScveval(crv1, ovlap1_bgn, 0, &point1, &rc);
            if(rc != BSSUCC)
            {
               sts=1;
               goto wrapup;
            }
            dist1 = BSdistptpts(&rc,q,point1);
            if(rc != BSSUCC)
            {
               sts=1;
               goto wrapup;
            }
            if(dist1 < sti_tol)
            {
               (*num_hits)++;
               sts = TOpoint_conti;
               continue;
            }
         }
         if(*s<sti_tol && output_par[i] > ovlap1_end + knot_tol1)
         {
            BScveval(crv1, ovlap1_end, 0, &point1, &rc);
            if(rc != BSSUCC)
            {
               sts=1;
               goto wrapup;
            }
            dist1 = BSdistptpts(&rc,q,point1);
            if(rc != BSSUCC)
            {
               sts=1;
               goto wrapup;
            }
            if(dist1 < sti_tol)
            {
               (*num_hits)++;
               sts = TOpoint_conti;
               continue;
            }
         }

         vio_dis++;
         (*num_misses)++;
         if((option & TOPO_MO_DISTANCE))
         {
            sts = TOadd_pt1(topo,NULL,p,NULL,NULL,&ptail_p);
            if(sts)
               goto wrapup;
            if(*s >= worst_dist)pmax_p = ptail_p->next;
         }
         else
         {
            if (*s > worst_loc_dist)
            {
               max_loc_d      = i;
               worst_loc_dist = *s;
               w_loc_point[0] = *(q);
               w_loc_point[1] = *(q+1);
               w_loc_point[2] = *(q+2);
            }
            vio_dis++;
            sts = TOno_conti;
         }
      }
      else /* if(*s >sti_tol)*/
      {
         if((option&TOanalyz_n_cont)||(option&TOanalyz_r_cont)||
            (option&TOPO_MO_NORMAL) ||(option&TOPO_MO_RADIUS))
         {
            cvpar[0] = tpars0[i];
            cvpar[1] = output_par[i];
            state = TOinv_nor_cont(surf,edge,pair_space,
                                   surf_geom,edge_geom,cvpar,
                                   p,q,sti_tol,
                                   same_an_tol,same_rd_tol,
                                   nor,rad,option,topo);

            if(state<NULL)
            {
#ifdef DBG
               printf("TOinv_nor_cont failed\n");
#endif
               return(state);
            }
            else if(!state)
            {
               vio_dis++;
               (*num_misses)++;
               if((option & TOPO_MO_DISTANCE))
               {
                  sts = TOadd_pt1(topo,NULL,p,NULL,NULL,&ptail_p);
                  if(sts)
                     goto wrapup;
                  if(*s >= worst_dist)pmax_p = ptail_p->next;
               }
               else
               {
                  if (*s > worst_loc_dist)
                  {
                     max_loc_d      = i;
                     worst_loc_dist = *s;
                     w_loc_point[0] = *(q);
                     w_loc_point[1] = *(q+1);
                     w_loc_point[2] = *(q+2);
                  }
                  vio_dis++;
                  sts = TOno_conti;
               }
            }
            else if(state == 1 && ((option & TOanalyz_n_cont) ||
                                   (option & TOPO_MO_NORMAL)))
            {
               if((option & TOPO_MO_NORMAL))
               {
                  sts = TOadd_pt1(topo,NULL,p,NULL,NULL,&ptail_n);
                  if(sts)
                     goto wrapup;
                  if (*nor > worst_loc_nor)
                  {
                     worst_loc_nor  = *nor;
                     pmax_n = ptail_n->next;
                  }
               }
               else
               {
                  if (*nor > worst_loc_nor)
                  {
                     max_loc_n      = i;
                     worst_loc_nor  = *nor;
                     w_loc_nor_p[0] = *(q);
                     w_loc_nor_p[1] = *(q+1);
                     w_loc_nor_p[2] = *(q+2);
                  }
               }
               (*num_misses)++;
               vio_nor++;
               if(*nor > worst_nor)
               {   
                  worst_nor = *nor;
                  max_n      = i;
               }
               sts = state;
            }
            else if(state == 2 && ((option & TOanalyz_r_cont) ||
                                   (option & TOPO_MO_RADIUS)))
            {
               if((option & TOPO_MO_RADIUS))
               {
                  sts = TOadd_pt1(topo,NULL,p,NULL,NULL,&ptail_r);
                  if(sts)
                     goto wrapup;
                  if (*rad > worst_loc_rad)
                  {
                     worst_loc_rad  = *rad;
                     pmax_r = ptail_r->next;
                  }
               }
               else
               {
                  if (*rad > worst_loc_rad)
                  {
                     max_loc_r      = i;
                     worst_loc_rad  = *rad;
                     w_loc_rad_p[0] = *(q);
                     w_loc_rad_p[1] = *(q+1);
                     w_loc_rad_p[2] = *(q+2);
                  }
               }
               (*num_misses)++;
               vio_rad++;
               if(*rad > worst_rad)
               {   
                  worst_rad = *rad;
                  max_r     = i;
               }
               sts = state;
            }
            else
            {
               sts = state;
               (*num_hits)++;
            }
         }
         else /* if(option&TOanalyz_n_cont) */
         {
            sts = TOpoint_conti;
            (*num_hits)++;
         } /* if(option&TOanalyz_n_cont ....) */
      }/* if(*s >sti_tol)*/
   } /*for(i=0, p=input_pts, s=distances; i<sample_size; i++, p+=3, s++)*/
   /* mark the investigated point with the maxixmum deviation */
      if((option & TOPO_MO_DISTANCE)&& pmax_p !=NULL)
      pmax_p->status = 99;
      if((option & TOPO_MO_NORMAL)&& pmax_n !=NULL)
      pmax_n->status = 99;
      if((option & TOPO_MO_RADIUS)&& pmax_r !=NULL)
      pmax_r->status = 99;
   /* output the results on file if required */
   if(topo->pa.file_name != NULL&&
      (option&TOPO_MO_NORMAL) ||(option&TOPO_MO_RADIUS))
   {
      IGRint size_flag = 10;

      TOprint_all_viol(topo, size_flag, ovlap0, ovlap1,
                       input_pts, tpars0, output_pts, output_par,
                       distances, max_i, worst_dist,
                       normals,max_n,worst_nor,
                       rad_rel,max_r,worst_rad, &ret);
   }

/* Now investigate edge2-->edge1; only distance violation and then normal
   and radius if required */
   num_pts = sample_size +1;
   sts1 = sts;
   /* if there are not enough points for quick_project
      or if curve_order<3 use BSmdstptcv */
   if(sample_size < crv0->num_poles || crv0->order<3)
   {
      if (ovlap0[0] < ovlap0[1])
      {
         ovlap0_bgn = ovlap0[0];
         ovlap0_end = ovlap0[1];
      }
      else
      {
         ovlap0_bgn = ovlap0[1];
         ovlap0_end = ovlap0[0];
      }
      if (ovlap1[0] < ovlap1[1])
      {
         ovlap1_bgn = ovlap1[0];
         ovlap1_end = ovlap1[1];
      }
      else
      {
         ovlap1_bgn = ovlap1[1];
         ovlap1_end = ovlap1[0];
      }
      /* fill the parameter vector for the input points*/
      dist1 = (ovlap1_end -ovlap1_bgn)/(sample_size - 1);
      tpars0[0]=ovlap1_bgn;
      tpars0[1]=ovlap1_bgn + dist1/2.;
      for(s=tpars0+2,smax=tpars0+sample_size; s<smax; s++)
         *s = *(s-1)+dist1;
      tpars0[sample_size]=ovlap1_end;
      for (i=0,p=input_pts,q=output_pts,s=distances; i<num_pts;
           i++,p+=3,       q+=3,        s++)
      {
         BScveval(crv1, tpars0[i], 0, (IGRpoint *)p, &rc);
         EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
         BSmdstptcv(crv0,p, &(output_par[i]),q, s, &rc);
         EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      }/* for (i=0,p=input_pts,q=output_pts,s=distances; i<num_pts;
               i++,p+=3,       q+=3,        s++)*/
   }
   else/*if(sample_size < crv0->num_poles)*/
   {
      if (ovlap0[0] < ovlap0[1])
      {
         ovlap0_bgn = ovlap0[0];
         ovlap0_end = ovlap0[1];
         ovlap1_bgn = ovlap1[0];
         ovlap1_end = ovlap1[1];
      }
      else
     {
         ovlap0_bgn = ovlap0[1];
         ovlap0_end = ovlap0[0];
         ovlap1_bgn = ovlap1[1];
         ovlap1_end = ovlap1[0];
      }
      BScveval(crv1, ovlap1_bgn, 0, &point00, &rc);
      EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      BScveval(crv1, ovlap1_end, 0, &point01, &rc);
      EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      BScveval(crv0, ovlap0_bgn, 0, &point1, &rc);
      EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      dist1 = BSdistptpts(&rc,point00,point1);
      EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      dist2 = BSdistptpts(&rc,point01,point1);
      EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      if(dist1>dist2)
      {

         ovlap_tmp = ovlap1_bgn;
         ovlap1_bgn = ovlap1_end;
         ovlap1_end = ovlap_tmp;
      }
      /* fill the parameter vector for the input points*/
      dist1 = (ovlap1_end -ovlap1_bgn)/(sample_size - 1);
      tpars0[0]=ovlap1_bgn;
      tpars0[1]=ovlap1_bgn + dist1/2.;
      for(s=tpars0+2,smax=tpars0+sample_size; s<smax; s++)
         *s = *(s-1)+dist1;
      tpars0[sample_size]=ovlap1_end;
      /* evaluate the list of input points for quick_project */
      for (p=input_pts,s=tpars0,smax=tpars0+num_pts; s<smax; p+=3,s++)
      {
         BScveval(crv1, *s, 0, (IGRpoint *)p, &rc);
         EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      }
      /*start initialization for while loop */
      err_i   = -1;
      restart = TRUE;
      while(restart)/* start quick_project if there are not all list elements
                     investigated*/
      {
         if(err_i == -1)/*this is the start initialization*/
         {
            err_i      = NULL;
            ovlap_tmp  = ovlap0_bgn;
            num_pts    = sample_size+1;
            i_pts      = input_pts;
            o_pts      = output_pts;
            o_par      = output_par;
            dist       = distances;
         }
         else
         {/*update the start pointers for input and output arrays*/
            ovlap_tmp = *r;
            num_pts    = num_pts-err_i-1;
            i_pts      = (p+3);
            o_pts      = (q+3);
            o_par      = (r+1);
            dist       = (s+1);
         }

         TOquick_pr_pt_cv (crv0, ovlap_tmp,ovlap0_end,num_pts,
                           i_pts,o_pts,o_par, dist,
                           &max_i,&max_dist,&err_i,&ret);
         if(ret == -1)/*bscveval failed*/
            goto wrapup;
         /* TOquick_pr_pt_cv failed; give help for the bad point and
            then give quick_project a new chance */
         if(!ret)
         {
            p = &(i_pts[3*err_i]);
            r = &(o_par[err_i]);
            q = &(o_pts[3*err_i]);
            s = &(distances[err_i]);
            BSmdstptcv(crv0,p, r,q, s, &rc);
            EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
         }/*if(!ret)*/
         if((err_i == num_pts - 1)||ret) restart = FALSE;
      }/*while(restart)*/
   }/*if(sample_size < crv0->num_poles)*/
   if(sample_size > 2 && crv0->phy_closed)
   {
      IGRdouble test;
      test = 20 * knot_tol0;
      if(output_par[0] < ovlap0_bgn + test &&
         output_par[2] - output_par[1]< NULL)
         output_par[0] = ovlap0_end;

      if(output_par[0] > ovlap0_end - test &&
         output_par[2] - output_par[1]> NULL)
         output_par[0] = ovlap0_bgn;

      if(output_par[sample_size] < ovlap0_bgn + test &&
         output_par[sample_size-1] - output_par[sample_size-2] > NULL)
         output_par[sample_size] = ovlap0_end;

      if(output_par[sample_size] > ovlap0_end - test &&
         output_par[sample_size-1] - output_par[sample_size-2] < NULL)
         output_par[sample_size] = ovlap0_bgn;
   }

   for(i=0,p=input_pts,q=output_pts,s=distances; i<num_pts; i++,p+=3,q+=3,s++)
   {
      if (*s > worst_dist)
      {
         max_i      = i;
         worst_dist = *s;
         w_point[0] = *(q);
         w_point[1] = *(q+1);
         w_point[2] = *(q+2);
      }
      if(*s >sti_tol || (output_par[i] < ovlap0_bgn - knot_tol0 ||
                           output_par[i] > ovlap0_end + knot_tol0))
      {
         if(*s<sti_tol && output_par[i] < ovlap0_bgn - knot_tol0)
         {
            BScveval(crv0, ovlap0_bgn, 0, &point1, &rc);
            if(rc != BSSUCC)
            {
               sts=1;
               goto wrapup;
            }
            dist1 = BSdistptpts(&rc,q,point1);
            if(rc != BSSUCC)
            {
               sts=1;
               goto wrapup;
            }
            if(dist1 < sti_tol)
            {
               (*num_hits)++;
               sts = TOpoint_conti;
               continue;
            }
         }/* if(output_par[i] < ovlap0_bgn - knot_tol0)*/

         if(*s<sti_tol && output_par[i] > ovlap0_end + knot_tol0)
         {
            BScveval(crv0, ovlap0_end, 0, &point1, &rc);
            if(rc != BSSUCC)
            {
               sts=1;
               goto wrapup;
            }
            dist1 = BSdistptpts(&rc,q,point1);
            if(rc != BSSUCC)
            {
               sts=1;
               goto wrapup;
            }
            if(dist1 < sti_tol)
            {
               (*num_hits)++;
               sts = TOpoint_conti;
               continue;
            }
         }/* if(output_par[i] > ovlap0_end + knot_tol0)*/

         vio_dis++;
         (*num_misses)++;
         if((option & TOPO_MO_DISTANCE))
         {
            sts = TOadd_pt1(topo,NULL,p,NULL,NULL,&ptail_p);
            if(sts)
               goto wrapup;
            if(*s >= worst_dist)pmax_p = ptail_p->next;
         }
         else
         {
            if (*s > worst_loc_dist)
            {
               max_loc_d      = i;
               worst_loc_dist    = *s;
               w_loc_point[0] = *(q);
               w_loc_point[1] = *(q+1);
               w_loc_point[2] = *(q+2);
            }
            vio_dis++;
            sts = TOno_conti;
         }
      }
      else /* if(*s >sti_tol)*/
      {
         sts = sts1;
         (*num_hits)++;
      }/* if(*s >sti_tol)*/
   } /*
   for(i=0,p=input_pts,q=output_pts,s=distances; i<num_pts; i++,p+=3,q+=3,s++)*/
   /* mark the investigated point with the maxixmum deviation */
      if((option & TOPO_MO_DISTANCE)&& pmax_p !=NULL)
      pmax_p->status = 99;
   /* output the results on file if required */
   if(topo->pa.file_name != NULL&&
     (option&TOPO_MO_NORMAL) ||(option&TOPO_MO_RADIUS))
   {
      IGRint size_flag = -9;

      TOprint_dist_viol(topo, size_flag, ovlap0, ovlap1,
                        input_pts, tpars0, output_pts, output_par,
                        distances, max_i, worst_dist, &ret);
   }
wrapup:
   if(option & TOPO_MO_DISTANCE)
   {
      *n_poi_p_con = vio_dis;
      *p_con_head  = phead_p;
      *p_con_tail  = ptail_p;
   }
   if(option & TOPO_MO_NORMAL)
   {
      *n_poi_n_con = vio_nor;
      *n_con_head  = phead_n;
      *n_con_tail  = ptail_n;
   }
   if(option & TOPO_MO_RADIUS)
   {
      *n_poi_r_con = vio_rad;
      *r_con_head  = phead_r;
      *r_con_tail  = ptail_r;
   }
   if(max_loc_d >= NULL)
   {
      (*n_poi_p_con)++;
      sts = TOadd_pt1(topo,NULL,w_loc_point,NULL,NULL,p_con_tail);
      if(sts)
         return(-1);
   }

   if(max_loc_n >= NULL)
   {
      (*n_poi_n_con)++;
      sts = TOadd_pt1(topo,NULL,w_loc_nor_p,NULL,NULL,n_con_tail);
      if(sts)
         return(-1);
   }

   if(max_loc_r >= NULL)
   {
      (*n_poi_r_con)++;
      sts = TOadd_pt1(topo,NULL,w_loc_rad_p,NULL,NULL,r_con_tail);
      if(sts)
         return(-1);
   }

   topo->pa.max_dist_viol    = worst_dist;
   topo->pa.loc_dist_viol[0] = w_point[0];
   topo->pa.loc_dist_viol[1] = w_point[1];
   topo->pa.loc_dist_viol[2] = w_point[2];

   if(tpars0 && (tpars0 != tparsbuff0)) om$dealloc(ptr = tpars0);
   if(input_pts) om$dealloc(ptr = input_pts);
   if(output_pts) om$dealloc(ptr = output_pts);
   if(output_par) om$dealloc(ptr = output_par);
   if(distances) om$dealloc(ptr = distances);

   if(vio_dis)
         sts = TOno_conti;
   else if(vio_nor)
         sts = TOpoint_conti;
   else if(vio_rad)
         sts = TOnormal_conti;

   return(sts);
}

/*
Name

    TOinv_nor_cont

Abstract

    calculates the surface normal for corresponding points
    and compares them with a given same angle tolerance
    also comparing the radius

Synopsis

    state = TOinv_nor_cont(surf,edge,pair_space,
                           surf_geom,edge_geom,cvpar,
                           point_tmp,base_point, sti_tol,
                           same_an_tol,same_rd_tol,nor,rad,option,topo);
    GRobjid        surf[2];
    GRobjid        edge[2];
    GRspacenum     pair_space[2];
    struct IGRbsp_surface *surf_geom[2];
    struct IGRbsp_curve   *edge_geom[2];
    IGRdouble cvpar[2];
    IGRdouble      *tpars0;
    IGRdouble      hit_par;
    IGRpoint       point_tmp;
    IGRpoint       base_point;
    IGRdouble      sti_tol;
    IGRdouble      same_an_tol;
    IGRdouble      same_rd_tol;
    IGRushort      option;
    IGRdouble      *nor;
    IGRdouble      *rad;
    struct topology *topo;




Description


Return Value

    sts =  TOanalyze_failed	if error during computing
           TOno_conti 		if normal comparing failed
           TOnormal_conti	if normal comparing succesful 
           TOradius_conti
Notes

Index

Keywords

History

    12 Apr 94   B.Burkhardt     Creation
*/

IGRint TOinv_nor_cont(GRobjid               surf[2],
                      GRobjid               edge[2],
                      GRspacenum            pair_space[2],
                      struct IGRbsp_surface *surf_geom[2],
                      struct IGRbsp_curve   *edge_geom[2],
                      IGRdouble             cvpar[2],
                      IGRpoint              point0,
                      IGRpoint              point1,
                      IGRdouble             sti_tol,
                      IGRdouble             same_an_tol,
                      IGRdouble             same_rd_tol,
                      IGRdouble             *nor,
                      IGRdouble             *rad_rel,
                      IGRushort             option, 
                      struct topology       *topo) 
{
   IGRint         sts;
   IGRint         OM_stat;
   IGRlong        EMmsg;
   IGRint         edg_ix;
   IGRint         i;
   IGRint         class[2][1];
   IGRshort       natloc;
   OMuword        clid;
   IGRboolean     ispe = FALSE;
   IGRboolean     pflag = TRUE;
   IGRboolean     dflag = TRUE;
   IGRboolean     cflag = TRUE;
   IGRdouble      dist,worst_norm,worst_radi;
   IGRdouble      junk = NULL;
   IGRdouble      uv_point[2];
   IGRdouble      angle_sine;
   IGRpoint       xyz_point, w_norm,w_radi;
   IGRdouble      sf_point[2][1][3]; 
   IGRdouble      sf_normal[2][1][3];
   IGRdouble      angle[3]; /* angle, sine, cosine */
   IGRdouble      cmax[2][1], cmin[2][1];
   IGRdouble      dir1[2][1][3], dir2[2][1][3];
   IGRdouble      dirk[3];
   IGRvector      ctan;
   IGRvector      snor;
   IGRdouble      cn[2];
   IGRdouble      rad[2];
   IGRpoint       curv_eval[2];
   IGRpoint       surf_eval[4];
   BSrc                  rc;

   OM_stat = OM_S_SUCCESS;
   EMmsg   = EMS_S_Success;
   sti_tol = sti_tol;/*wrt the compiler */
   surf[0] = surf[0]; /*wrt the compiler */
   sts     = TOpoint_conti;
   worst_norm = topo->pa.max_norm_viol;
   worst_radi = topo->pa.max_radi_viol;

   for(edg_ix=0; edg_ix<2; edg_ix++)
   {
      OM_stat = om$send(msg = message EMSedge.EMget_location (&EMmsg, &natloc),
                        senderid = NULL_OBJID,
                        targetos = pair_space[edg_ix],
                        targetid = edge[edg_ix]);
      if(!(1&OM_stat))
      {
         sts = TOanalyze_failed;
         EMerr_hndlr(!(1&OM_stat),EMmsg,EMS_E_EdgeError,wrapup);
      }
	
/*    If part natural edge we need to convert the overlap param
*     wrt full edge.
*/
      if( (natloc == EDGEU0) || (natloc == EDGEV1) || 
          (natloc == EDGEU1) || (natloc == EDGEV0))
      {
         OM_stat = om$get_classid(objid = edge[edg_ix],
                                  osnum = pair_space[edg_ix], 
	                          p_classid = &clid);
         if(!(1&OM_stat))
         {
            sts = TOanalyze_failed;
            EMerr_hndlr(!(1&OM_stat),EMmsg,EMS_E_OMerror,wrapup);
         }
	
         if( (clid == OPP_EMSpartedge_class_id) || 
         ( (OM_stat = om$is_ancestry_valid(subclassid = clid, 
         superclassid = OPP_EMSpartedge_class_id))
         == OM_S_SUCCESS)) ispe = TRUE;
         if(ispe)
         {
            struct EMSedgebound		bnd[2], cnvt, tmp;
            tmp.span_inx = 0;
            tmp.param = cvpar[edg_ix];
            OM_stat = om$send(msg = message EMSedge.EMgetbounds(&EMmsg,bnd),
                              senderid = NULL_OBJID,
                              targetos = pair_space[edg_ix],
                              targetid = edge[edg_ix]);
            if(!(1&OM_stat))
            {
               sts = TOanalyze_failed;
               EMerr_hndlr(!(1&OM_stat),EMmsg,EMS_E_OMerror,wrapup);
            }

            EMcnvtedpar(&EMmsg, &bnd[0], &bnd[1], &tmp, &cnvt);
            if(!(1&EMmsg))
            {
               sts = TOanalyze_failed;
               EMerr_hndlr(!(1&EMmsg),EMmsg,EMS_E_EdgeError,wrapup);
            }

            junk = cnvt.param;		    
         } /* if(ispe) */
      }
		
      if(natloc == EDGEU0)
      {
         uv_point[0] = 0.0;
         uv_point[1] = ispe ? junk : cvpar[edg_ix];
      }
      else if(natloc == EDGEV1)
      {
         uv_point[0] = ispe ? junk : cvpar[edg_ix];
         uv_point[1] = 1.0;
      }
      else if(natloc == EDGEU1)
      {
         uv_point[0] = 1.0;
         uv_point[1] = 1.0 - (ispe ? junk : cvpar[edg_ix]);
      }
      else if(natloc == EDGEV0)
      {
         uv_point[0] = 1.0 - (ispe ? junk : cvpar[edg_ix]);
         uv_point[1] = 0.0;
      }
      else
      {
         for(i=0;i<3;i++)
         {
            xyz_point[i]=(edg_ix ? point1[i] : point0[i]);
         }
#ifdef NOT_USED
         BScveval(edge_geom[edg_ix], cvpar[edg_ix],
                  0, (IGRpoint *)xyz_point, &rc);
         if(rc != BSSUCC)
         {
            sts = TOanalyze_failed;
            EMerr_hndlr(rc != BSSUCC,EMmsg,EMS_E_BSerror,wrapup);
         }
#endif
         BSmdistptsf(&rc, surf_geom[edg_ix], xyz_point,
                     &(uv_point[0]),&(uv_point[1]),
                     &(sf_point[0][0][0]), &dist );
         if(rc != BSSUCC)
         {
#ifdef DBG
            printf("BSmdistptsf failed\n");
#endif
            goto wrapup;
         }
      }
      BSsfarrevn( &rc, surf_geom[edg_ix],1, &(uv_point[0]),1,&(uv_point[1]),
                  &(sf_point[0][0][0]), &(sf_normal[edg_ix][0][0]) );
      if(rc == BSINARG)
      {
#ifdef DBG
         printf("surface out of range: u = %8.3f  v = %8.3f\n",
                 uv_point[0],uv_point[1]);
#endif
         continue;
      }
      if(rc != BSSUCC)
      {
#ifdef DBG
         printf("BSsfarrevn failed\n");
#endif
         goto wrapup;
      }
/*    
      now include curvature function
*/
      if((option & TOanalyz_r_cont)||(option & TOPO_MO_RADIUS))
      {
         BSsfarrevmc(surf_geom[edg_ix],1,&(uv_point[0]),1,&(uv_point[1]),
                     NULL,NULL,pflag,NULL,dflag,cflag,&(sf_point[0][0][0]),
                     NULL,NULL, &(cmax[edg_ix][0]),&(cmin[edg_ix][0]),NULL,
                     &(dir1[edg_ix][0][0]),&(dir2[edg_ix][0][0]),
                     &(class[edg_ix][0]),&rc);
         if(rc == BSINARG)
         {
#ifdef DBG
            printf("surface out of range: u = %8.3f  v = %8.3f\n",
                    uv_point[0],uv_point[1]);
#endif
            continue;
         }
         if(rc != BSSUCC)
         {
#ifdef DBG
            printf("BSsfarrevn failed\n");
#endif
            goto wrapup;
         }
      } /* if((option & TOanalyz_r_cont) ||(option & TOPO_MO_RADIUS))*/
   }
/*
   calculate the angle between the surface normals and compare with
   the same angle tolerance;
*/   
   MAang2vc(&EMmsg,&(sf_normal[0][0][0]),&(sf_normal[1][0][0]),angle);
   if(EMmsg !=MSSUCC)
   {
#ifdef DBG
      printf("MAang2vc failed\n");
#endif
      sts = TOanalyze_failed;
      goto wrapup;
   }
   BSsin(same_an_tol,&angle_sine);
   *nor = fabs(angle[1]);
   if (fabs(angle[1]) > worst_norm)
   {
      worst_norm = fabs(angle[1]);
      w_norm[0] = sf_point[0][0][0];
      w_norm[1] = sf_point[0][0][1];
      w_norm[2] = sf_point[0][0][2];
   }

   if(fabs(angle[1])<angle_sine)
   {
      sts = TOnormal_conti;
/*    
      now compare the curvature values
      if the surface normals are in opposite direction change
      cmin-cmax for one surface to make the curvature compatiple
*/
   if(angle[2]<NULL)
   {
      IGRdouble ctmp;
      IGRint ii;
      ctmp = cmax[1][0];
      cmax[1][0] = -cmin[1][0];
      cmin[1][0] = -ctmp;
      for(ii=0;ii<3;ii++)
      {
         ctmp = dir1[1][0][ii];
         dir1[1][0][ii] = -dir2[1][0][ii];
         dir2[1][0][ii] = -ctmp;
      }
   }
      
      if((option & TOanalyz_r_cont)||(option & TOPO_MO_RADIUS))
      {
/*       at first calculate the direction for curvature comparing */
         if((natloc == EDGEU0 || natloc == EDGEV1 || 
             natloc == EDGEU1 || natloc == EDGEV0) && (option&TOPO_MO_UV))
         {
            BSsfeval(surf_geom[1], uv_point[0], uv_point[1],1,surf_eval, &rc);
            if(rc != BSSUCC)
            {
               sts = TOanalyze_failed;
               EMerr_hndlr(rc != BSSUCC,EMmsg,EMS_E_BSerror,wrapup);
            }
            if(natloc == EDGEU0 || natloc == EDGEU1)
            {
               for(i=0;i<3;i++)
                  dirk[i] = surf_eval[1][i];
            }
            else if(natloc == EDGEV0 || natloc == EDGEV1)
            {
               for(i=0;i<3;i++)
                  dirk[i] = surf_eval[2][i];
            }
         }
         else
         {
            BScveval(edge_geom[1], cvpar[1],1,curv_eval, &rc);
            if(rc != BSSUCC)
            {
               sts = TOanalyze_failed;
               EMerr_hndlr(rc != BSSUCC,EMmsg,EMS_E_BSerror,wrapup);
            }
            for(i=0;i<3;i++)
            {
               ctan[i] = curv_eval[1][i];
               snor[i] = sf_normal[1][0][i];
            }
            BScrossp(&rc,ctan,snor,dirk);
            if(rc != BSSUCC)
            {
               sts = TOanalyze_failed;
               EMerr_hndlr(rc != BSSUCC,EMmsg,EMS_E_BSerror,wrapup);
            }
         }
         for(edg_ix=0;edg_ix<2;edg_ix++)
         {
/*
            calculate the angle between the surface normals and compare with
            the same angle tolerance;
*/   
         
            if(class[edg_ix][0]!=1 && class[edg_ix][0]!=4)
            {
               MAang2vc(&EMmsg,&(dir1[edg_ix][0][0]),dirk,angle);
               if(EMmsg !=MSSUCC)
               {
#ifdef DBG
                  printf("MAang2vc failed\n");
#endif
                  sts = TOanalyze_failed;
                  goto wrapup;
               }
               cn[edg_ix] = cmax[edg_ix][0]*angle[2]*angle[2] +
                            cmin[edg_ix][0]*angle[1]*angle[1];          
            }
            else
            {
               cn[edg_ix] = cmin[edg_ix][0];
            }
            if(fabs(cn[edg_ix])>CURVMIN)
            {
               rad[edg_ix] = 1.0/cn[edg_ix];
            }
            else
               rad[edg_ix] = RADMAX;
         } /* for(edg_ix=0;edg_ix<2;edg_ix++) */
/*       use the rules of recommendation VDA 4955 for calculating
         and comparing the curvature
*/
         dist = (fabs(rad[1]-rad[0])/(0.5*(fabs(rad[1])+fabs(rad[0]))));
         *rad_rel = dist;
         if (dist > worst_radi)
         {
            worst_radi = dist;
            w_radi[0] = sf_point[0][0][0];
            w_radi[1] = sf_point[0][0][1];
            w_radi[2] = sf_point[0][0][2];
         }
         if(dist<same_rd_tol)
            sts = TOradius_conti;
      } /* if((option & TOanalyz_r_cont)||(option & TOPO_MO_RADIUS)) */
      
   }
   else
      sts =TOpoint_conti;
wrapup:
   topo->pa.max_norm_viol    = worst_norm;
   topo->pa.loc_norm_viol[0] = w_norm[0];
   topo->pa.loc_norm_viol[1] = w_norm[1];
   topo->pa.loc_norm_viol[2] = w_norm[2];
   topo->pa.max_radi_viol    = worst_radi;
   topo->pa.loc_radi_viol[0] = w_radi[0];
   topo->pa.loc_radi_viol[1] = w_radi[1];
   topo->pa.loc_radi_viol[2] = w_radi[2];

   return(sts);
}
end implementation ECtpanaly;
