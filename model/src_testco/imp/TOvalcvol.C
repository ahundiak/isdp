/*
Name

	TOvalcvovlap.C

Abstract


Synopsis
IGRint TOvalcv_ovlap( IGRlong        *EMmsg,
                      struct IGRbsp_curve *crv0,
                      struct IGRbsp_curve *crv1,
                      IGRdouble       *ovlap0,
                      IGRdouble       *ovlap1,
                      IGRint          sample_size,
                      IGRint          *num_hits,
                      IGRint          *num_misses,
                      IGRdouble       tolerance,
                      IGRushort       option,
                      struct topology *topo,
                      int             *n_poi_p_con,
                      struct point    **p_con_head,
                      struct point    **p_con_tail)


			
   EMmsg                - return code
   crv0                 - the first curve for investigation
   crv1                 - the second curve for investigation
   ovlap0               - overlap on crv0
   ovlap1               - overlap on crv1
   sample_size          - number of sample pts.
   num_hits             - number of points where tolerance is satisfied
   num_misses           - number of points where point cont is violated
   tolerance            - analysis tolerance 
   option               - validation option (see TOtopology.h)	
   topo                 - Main structure for topology informations
                        list of all points where tolerance is not satisfied
                        for graphic output in Invest Edge Match
   n_poi_p_con          - number of points where point cont is violated
   p_con_head           - header of list of points
   p_con_tail           - tail of list of points

Description

  This function accepts two curves and an overlap interval on each
  curve. It validates the overlap by sampling the specified number
  of points on the overlap interval of one curve (curv0) and checking
  if the overlap interval on the other curve (crv1) is within 
  tolerance. It returns the number of successful hits and the number
  of misses. The  value for 'sample_size' must be at least 2 (in which
  case only the end points of the overlap are used).

Return Values

  EMS_S_Success		if all goes well.

  EMS_E_InvalidArg  	if num_hits or num_misses is a NULL pointer 
			
			OR
		
			if sample size is less than 2.

  EMS_E_BSerror		if a BS (math) call fails.

Notes

History

  B.Burkhardt 12 Apr 94      Created as a modification of EMvalcvovlap.C
  B.Burkhardt 10 Aug 94      Included the quick_project function
  B.Burkhardt 10 Sep 94      Included worst case dieplay
  SCW         02/13/97       Included emsmacros_c.h rather than emsmacros.h

*/

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
#include "emsmacros_c.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "bsdistptpts.h"
#include "bsmdstptcv.h"
#include "bscveval.h"
#include "TOproto_ds.h"
#include "TOnumbers.h"
#include "TOtopology.h"

#define TparsBuff	20

IGRint TOvalcv_ovlap( IGRlong         *EMmsg,
                      struct IGRbsp_curve *crv0,
                      struct IGRbsp_curve *crv1,
                      IGRdouble       *ovlap0,
                      IGRdouble       *ovlap1,
                      IGRint          sample_size,
                      IGRint          *num_hits,
                      IGRint          *num_misses,
                      IGRdouble       tolerance,
                      IGRushort       option,
                      struct topology *topo,
                      int             *n_poi_p_con,
                      struct point    **p_con_head,
                      struct point    **p_con_tail)

{
   IGRint	i= NULL;
   IGRint       sts = -1;
   BSrc		rc;
   IGRlong      OM_stat;
   IGRdouble 	dist1,dist2;
   IGRdouble    ovlap0_bgn, ovlap0_end;
   IGRdouble   	ovlap1_bgn, ovlap1_end;
   IGRdouble   	ovlap_tmp;
   IGRdouble   	knot_tol0, knot_tol1;
   IGRdouble   	worst_miss;
   IGRdouble   	worst_loc;
   IGRdouble	*tpars0 = NULL, tparsbuff0[TparsBuff];
   IGRpoint	worst_point;
   IGRpoint	worst_loc_point;
   IGRpoint	point00, point01, point1;
   struct point *phead = NULL;
   struct point *ptail = NULL;
   struct point *pmax  = NULL;

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
   IGRint       max_loc;
   IGRdouble    max_dist;
   IGRint       err_i;
   IGRlong      ret;
   IGRboolean   restart;

/*start of executable code*/

   r = o_par; /* wrt compiler*/
   q = o_pts; /* wrt compiler*/
   OM_stat = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;

   /*start initialization for while loop */
   err_i   = -1;
   restart = TRUE;
   num_pts = sample_size;    
   worst_miss = topo->pa.max_dist_viol;
   worst_loc = NULL;
   max_loc   = -1;
   /* for investigate edge match initialize point list for misses
      and initialize worst_miss*/
   if(option & TOPO_MO_DISTANCE)
   {
      worst_miss = NULL;
      sts = TOinit_pt(topo,&phead,&ptail);
      if(sts)
      {
         sts = -1; 
         goto wrapup;
      }
   }   
  
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

   distances =(IGRdouble *)om$malloc(size=(sample_size+1)*sizeof(IGRdouble));
   EMerr_hndlr(!distances, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   BScvkttol2(crv0->order, crv0->knots, crv0->num_poles,
              crv0->poles, crv0->weights, &knot_tol0, &rc);
   EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

   BScvkttol2(crv1->order, crv1->knots, crv1->num_poles,
              crv1->poles, crv1->weights, &knot_tol1, &rc);
   EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
  
   *num_hits = 0;
   *num_misses = 0;
   /*at first evaluate points on crv0 and project to crv2*/   
  
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
      for(s=tpars0+1,smax=tpars0+sample_size; s<smax; s++)
         *s = *(s-1)+dist1;
      tpars0[sample_size-1]=ovlap0_end;
      for (i=0,p=input_pts,q=output_pts,s=distances; i<num_pts;
           i++,p+=3,       q+=3,        s++)
      {
         BScveval(crv0, tpars0[i], 0, (IGRpoint *)p, &rc);
         EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   
         BSmdstptcv(crv1,p, &(output_par[i]),q, s, &rc);
         EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      }/*for (i=0, p = input_pts ,q = output_pts; i<num_pts; i++, p+=3 ,q+=3)*/
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
      for(s=tpars0+1,smax=tpars0+sample_size; s<smax; s++)
         *s = *(s-1)+dist1;
      tpars0[sample_size-1]=ovlap0_end;
      /* evaluate the list of input points for quick_project */
      for (p=input_pts ,s=tpars0,smax=tpars0+num_pts; s<smax; p+=3 ,s++)
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

   for(i=0,p=input_pts,q=output_pts,s=distances;i<sample_size;i++,p+=3,q+=3,s++)
   {
      if (*s > worst_miss)
      {
         max_i          = i;
         worst_miss     = *s;
         worst_point[0] = *(q);
         worst_point[1] = *(q+1);
         worst_point[2] = *(q+2);
      }
      if(*s >tolerance || (output_par[i] < ovlap1_bgn - knot_tol1 ||
                           output_par[i] > ovlap1_end + knot_tol1))
      {
         if(*s < tolerance && output_par[i] < ovlap1_bgn - knot_tol1)
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
            if(dist1 < tolerance)
            {
               (*num_hits)++;
               sts = TOpoint_conti;
               continue;
            } 
         }
         if(*s<tolerance && output_par[i] > ovlap1_end + knot_tol1)
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
            if(dist1 < tolerance)
            {
               (*num_hits)++;
               sts = TOpoint_conti;
               continue;
            }
         }
          
         (*num_misses)++;
         if((option & TOPO_MO_DISTANCE))
         {
            sts = TOadd_pt1(topo,NULL,p,NULL,NULL,&ptail);
            if(sts)
               goto wrapup;
            if (*s >= worst_miss) pmax = ptail->next;
         }
         else
         {
            if (*s > worst_loc)
            {
               max_loc      = i;
               worst_loc    = *s;
               worst_loc_point[0] = *(q);
               worst_loc_point[1] = *(q+1);
               worst_loc_point[2] = *(q+2);
            }
            sts = TOno_conti;
         }
      }
      else /* if(*s >tolerance)*/
      {
         (*num_hits)++;
         sts = TOpoint_conti;
      }/* if(*s >tolerance)*/
   } /*for(i=0, p=input_pts, s=distances; i<sample_size; i++, p+=3, s++)*/
   /* mark the investigated point with the maxixmum deviation */
   if((option & TOPO_MO_DISTANCE)&& pmax !=NULL)
      pmax->status = 99;
   /* output the results on file if required */
   if(topo->pa.file_name != NULL && (option & TOPO_MO_DISTANCE))
   {
      IGRint size_flag = 10;

      TOprint_dist_viol(topo, size_flag, ovlap0, ovlap1,
                        input_pts, tpars0, output_pts, output_par,
                        distances, max_i, worst_miss, &ret);
   }

   /* Now investigate edge2-->edge1; evaluate points on crv1
      and project to crv2*/
   num_pts = sample_size +1;

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
      }/*for (i=0,p=input_pts,q=output_pts,s=distances; i<num_pts;
              i++,p+=3 ,      q+=3,        s++)*/
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

         ovlap_tmp = ovlap1_bgn;
         ovlap1_bgn = ovlap1_end;
         ovlap1_end = ovlap_tmp;
      }
      /* fill the parameter vector for the input points*/
      dist1 = (ovlap1_end -ovlap1_bgn)/(sample_size - 1);
      tpars0[0]=ovlap1_bgn;
      tpars0[1]=ovlap1_bgn + dist1/2.;
      for(s=tpars0+2,smax=tpars0+num_pts; s<smax; s++)
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
      if (*s > worst_miss)
      {
         max_i          = i;
         worst_miss     = *s;
         worst_point[0] = *(q);
         worst_point[1] = *(q+1);
         worst_point[2] = *(q+2);
      }
      if(*s >tolerance || (output_par[i] < ovlap0_bgn - knot_tol0 ||
                           output_par[i] > ovlap0_end + knot_tol0))
      {
         if(*s<tolerance && output_par[i] < ovlap0_bgn - knot_tol0)
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
            if(dist1 < tolerance)
            {
               (*num_hits)++;
               sts = TOpoint_conti;
               continue;
            }
         }/* if(output_par[i] < ovlap0_bgn - knot_tol0)*/

         if(*s<tolerance && output_par[i] > ovlap0_end + knot_tol0)
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
            if(dist1 < tolerance)
            {
               (*num_hits)++;
               sts = TOpoint_conti;
               continue;
            }
         }/* if(output_par[i] > ovlap0_end + knot_tol0)*/
         (*num_misses)++;
         if((option & TOPO_MO_DISTANCE))
         {
            sts = TOadd_pt1(topo,NULL,p,NULL,NULL,&ptail);
            if(sts)
               goto wrapup;
            if (*s >= worst_miss) pmax = ptail->next;
         }
         else
         {
            if (*s > worst_loc)
            {
               max_loc      = i;
               worst_loc    = *s;
               worst_loc_point[0] = *(q);
               worst_loc_point[1] = *(q+1);
               worst_loc_point[2] = *(q+2);
            }
            sts = TOno_conti;
         }
      }
      else /* if(*s >tolerance)*/
      {
         (*num_hits)++;
         sts = TOpoint_conti;
      }/* if(*s >tolerance)*/
   } /*for(i=0, p=input_pts, s=distances; i<sample_size; i++, p+=3, s++)*/
   if((option & TOPO_MO_DISTANCE)&& pmax !=NULL)
      pmax->status = 99;
   /* output the results on file if required */
   if(topo->pa.file_name != NULL && (option & TOPO_MO_DISTANCE))
   {
      IGRint size_flag = -10;

      TOprint_dist_viol(topo, size_flag, ovlap0, ovlap1,
                        input_pts, tpars0, output_pts, output_par,
                        distances, max_i, worst_miss, &ret);
   }

wrapup:
   if(option & TOPO_MO_DISTANCE)
   {
      *n_poi_p_con              = *num_misses;
      *p_con_head               = phead;
      *p_con_tail               = ptail;
   }
   else if(max_loc >= NULL)
   {
      sts = TOadd_pt1(topo,NULL,worst_loc_point,NULL,NULL,p_con_tail);
      if(sts)
         return(-1);
   }   
   if(*num_misses)
      sts = NULL;
   topo->pa.max_dist_viol    = worst_miss;
   topo->pa.loc_dist_viol[0] = worst_point[0];
   topo->pa.loc_dist_viol[1] = worst_point[1];
   topo->pa.loc_dist_viol[2] = worst_point[2];

   if(tpars0 && (tpars0 != tparsbuff0)) om$dealloc(ptr = tpars0);
   if(input_pts) om$dealloc(ptr = input_pts);
   if(output_pts) om$dealloc(ptr = output_pts);
   if(output_par) om$dealloc(ptr = output_par);
   if(distances) om$dealloc(ptr = distances);
   EMWRAPUP(*EMmsg, OM_stat, "In TOvalcv_ovlap")
   return(sts);
}
