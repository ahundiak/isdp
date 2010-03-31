/* ###################   APOGEE COMPILED   ################## */
/*
Name

      TOgetcvovlap.C
Synopsis

IGRint TOgetcv_ovlap( IGRlong *EMmsg;
       	              struct edge **ed;
                      IGRint *num_ovlap;
                      IGRdouble *ovlap0;
                      IGRdouble *ovlap1;
                      IGRdouble tolerance;
                      IGRint *hitinfo0;
                      IGRint *hitinfo1;
                      IGRushort options)

   EMmsg       - return code
   ed          - edge pointer in topological structures
   num_ovlap   - number of overlap intervals
   ovlap0      - overlap interval for the first curve
   ovlap1      - overlap interval for the second curve
   tolerance   - checking tolerance
   hitinfo0    - overlap parameter at start (0), end (1) of the first curve
                 or at an inner point (2)
   hitinfo1    - like hitinfo0 but for the second curve
   options     - not used now


Description

  This function finds the overlap intervals of two overlapping curves.
  The overlap calculation algorithm is not completely general. It assumes
  that at least two of the four end-points (of the two curves) are at the
  overlap  boundaries. In other words, if the overlap is completely 
  exclusive of all the end-points, or includes only one, it can not be
  detected.

  ovlap0 and ovlap1 must point to space enough for 2 or 4 'doubles', 
  depending on whether 1 or 2 overlap intervals are found, which in
  turn depends on whether one or both curves are physically closed
  etc. So, when in doubt, pass pointer to 4 'doubles'.

Return Values

  EMS_S_Success		if all goes well and overlap intervals are found.

  EMS_I_Fail		if overlap can not be detected.

  EMS_E_BSerror		if a BS (math) call fails.

Notes

History

  B.Burkhardt 12 Apr 94 Created as modification of
                        ./modelsrc/src_funk/EMgetcvovlap.C
  SCW     02/13/97      Included emsmacros_c.h rather than emsmacros.h

*/

#include "EMS.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include <math.h>				/* fabs */
#include <stdio.h>
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "emsmacros_c.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "bsmdstptcv.h"
#include "bsdistptpt.h"
#include "bscveval.h"
#include "bsbxint.h"
#include "bsbx2.h"
#include "TOdsl.h"
#include "TOstruct1.h"
#include "TOproto_ds.h"

static IGRboolean make_hit();

#define BGN	0
#define FIN	1

#define CheckFactor	2


IGRint TOgetcv_ovlap(IGRlong *EMmsg,
	             struct edge *ed[2],
	             IGRint *num_ovlap,
	             IGRdouble *ovlap0,
	             IGRdouble *ovlap1,
	             IGRdouble tolerance,
	             IGRint *hitinfo0,
	             IGRint *hitinfo1,
	             IGRushort options)

{
   IGRlong     	        OM_stat;
   IGRshort 		active, passive, end_pt, i;
   IGRshort 		tmph = NULL;
   IGRdouble		bgnpar[2], endpar[2];
   IGRdouble 		dist, dist1, rangeinc;
   IGRshort		num_hits, num_mid_hits, num_end_hits;
   IGRdouble	  	hit_param[2][4], test_param, temp_param;
   IGRint			hit_type[2][4], gen_hit_type, temp_hit_type;
   struct IGRbsp_curve    *curv[2];
   IGRpoint     		end_point[2][2], test_point, base_point;
   IGRdouble		gen_hit_param, cht, check_tol;
   IGRboolean		is_hit;
   BSrc			rc;
   GRrange		range[2];
  


   options = options;	/*wrt the compiler */
   OM_stat = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;
   BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht);
   check_tol = tolerance * CheckFactor;
   rangeinc = check_tol/2.0;
   
   for(i=0; i<2; i++)
   {
      if(ed[i]->status != 4)
      {
         curv[i] = ed[i]->ext->edge;
         bgnpar[i] = curv[i]->knots[0];
         endpar[i] = curv[i]->knots[curv[i]->num_poles + curv[i]->order - 1];
      }
      else
      {
         curv[i] = ed[i]->edid0->ext->edge;
         bgnpar[i] = ed[i]->ext->bound[0].param;
         endpar[i] = ed[i]->ext->bound[1].param;
      }
      hit_type[i][0] = hit_type[i][1] = hit_type[i][2] = hit_type[i][3] = 
	EMS_O_unknown;
      if (bgnpar[i] >= endpar[i]) {*EMmsg = EMS_E_InvalidArg; goto wrapup;}
      BScveval(curv[i], bgnpar[i], 0, (IGRpoint *)end_point[i][BGN], &rc);
      EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   
      BScveval(curv[i], endpar[i], 0, (IGRpoint *)end_point[i][FIN], &rc);
      EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   
      BSbx2(&rc, &curv[i]->num_poles, (IGRpoint *)curv[i]->poles,
            curv[i]->weights, &range[i][0], &range[i][3]);
      if (rc != BSSUCC) return FALSE;
      EM3dbxinc(range[i], rangeinc);
   }

   *num_ovlap = 0;

   if ((curv[0]->phy_closed && ed[0]->status != 4)&& 
       (curv[1]->phy_closed && ed[1]->status != 4))
   {
      for(active=0;active<2;active++)
      {  
         passive = (active == 0 ? 1 : 0);
 
         is_hit =  make_hit(&rc, ed[passive], end_point[active][BGN],
	           &gen_hit_param, &gen_hit_type, tolerance, options, NULL, 
		   end_point[passive], range[passive], NULL, NULL, NULL, 
		   check_tol);
         EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   
 
         if (! is_hit) {*EMmsg = EMS_I_Fail;	goto wrapup;}
 
         if (gen_hit_type == EMS_O_begin || gen_hit_type == EMS_O_end)
         {
            hit_param[active][0] = bgnpar[active];
            hit_param[active][1] = endpar[active];
            hit_type[active][0] = EMS_O_begin;
            hit_type[active][1] = EMS_O_end;
            if (active == 1)
            {
               /* test at middle of the curve interval*/
               test_param = bgnpar[active] +
                            0.5*(endpar[active] - bgnpar[active]);
               BScveval(curv[active], test_param, 0, (IGRpoint *)test_point,
                        &rc);
               EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
               BSmdstptcv(curv[passive], test_point, &gen_hit_param, base_point,
                          &dist, &rc);
               EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
               if(dist > tolerance)
               {
                  *num_ovlap = NULL;
                  *EMmsg = EMS_I_Fail;
                  goto wrapup;
               }
               else
                  *num_ovlap = 1;
            }/*if (active == 1)*/
         }
         else /*if (gen_hit_type == EMS_O_begin || gen_hit_type == EMS_O_end)*/
         {
            hit_param[passive][1] = hit_param[passive][2] = gen_hit_param;
            hit_type[passive][1] = EMS_O_middle;
            hit_type[passive][2] = EMS_O_adjacent;

            hit_param[active][0] = bgnpar[active];
            hit_param[active][3] = endpar[active];
            hit_type[active][0] = EMS_O_begin;
            hit_type[active][3] = EMS_O_end;

            if (active == 1)
            {
	       test_param = (hit_param[active][1] - bgnpar[active])/2;
               BScveval(curv[active], test_param, 0, (IGRpoint *)test_point,
                        &rc);
  	       EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

	       is_hit =  make_hit(&rc, ed[passive], test_point, 
	                 &gen_hit_param, &gen_hit_type, tolerance,
                         options, NULL, end_point[passive], range[passive],
                         ed[active], hit_param[passive], hit_param[active],
                         check_tol);
  	       EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

               if (! is_hit)
               {
	          test_param = endpar[active] - 
                              (endpar[active] - hit_param[active][1])/2;
                  BScveval(curv[active], test_param, 0, (IGRpoint *)test_point,
                           &rc);
  	          EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

	          is_hit =  make_hit(&rc, ed[passive], test_point, 
	                    &gen_hit_param, &gen_hit_type, tolerance,
                            options, NULL, end_point[passive], range[passive],
                            ed[active], hit_param[passive], hit_param[active],
                            check_tol);
  	          EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   
                  if (! is_hit)
                  {
                     *EMmsg = EMS_I_Fail;
	             goto wrapup;
                  }
                  *num_ovlap = 1;
                  hit_param[active][0]  = hit_param[active][1]; 
                  hit_param[active][1]  = hit_param[active][3]; 
                  hit_type[active][0]   = hit_type[active][1];
                  hit_type[active][1]   = hit_type[active][3];
	          if (gen_hit_param > hit_param[passive][1])
	          {
                     hit_param[passive][0] = hit_param[passive][1]; 
                     hit_param[passive][1] = hit_param[passive][3]; 
                     hit_type[passive][0]  = hit_type[passive][1];
                     hit_type[passive][1]  = hit_type[passive][3];
                  }		/* swap intervals	*/
                  continue;
               }

	       if (gen_hit_param > hit_param[passive][1])
	       {
	          temp_param = hit_param[passive][0];
                  hit_param[passive][0] = hit_param[passive][3];
                  hit_param[passive][3] = temp_param;
	          temp_hit_type = hit_type[passive][0];
                  hit_type[passive][0] = hit_type[passive][3];
	          hit_type[passive][3] = temp_hit_type;
               }/* swap intervals	*/
               *num_ovlap = 2;	
            }/* if active == 1 	*/
         }/*if (gen_hit_type == EMS_O_begin || gen_hit_type == EMS_O_end)*/
      }/*for(active=0;active<2;active++)*/
   }/* closed - closed*/

   else if ((curv[0]->phy_closed && ed[0]->status != 4)|| 
            (curv[1]->phy_closed && ed[1]->status != 4))
   {
      num_mid_hits = num_end_hits = 0;
      active = (curv[0]->phy_closed  ? 1 : 0);
      passive = (active == 0 ? 1 : 0);   
      for(end_pt=BGN; end_pt<FIN+1; end_pt++)
      {
         is_hit =  make_hit(&rc, ed[passive], end_point[active][end_pt], 
	           &gen_hit_param, &gen_hit_type, tolerance, options, NULL, 
	           end_point[passive], range[passive], NULL, NULL, NULL, 
	           check_tol);
         EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

         if (! is_hit)
            continue; 
         tmph = end_pt;
         hit_param[active][end_pt] = (end_pt == BGN ? bgnpar[active] : 
						      endpar[active]);
         hit_type[active][end_pt] = (end_pt == BGN ? EMS_O_begin : EMS_O_end);
         if (gen_hit_type == EMS_O_middle)
         {
	    hit_param[passive][num_mid_hits] = gen_hit_param;
	    hit_type[passive][num_mid_hits] = EMS_O_middle;
	    num_mid_hits++;	
         }
         else if (gen_hit_type == EMS_O_begin || gen_hit_type == EMS_O_end)
         {
	    num_end_hits++;
         }
      } 					/* end_pt */
      active = passive;			/* closed curve is now active */
      passive = (active == 0 ? 1 : 0);     /* open curve is passive      */

      if (num_mid_hits == 2)
      {
         is_hit =  make_hit(&rc, ed[passive], end_point[active][BGN], 
	           &gen_hit_param, &gen_hit_type, tolerance, options, NULL, 
	           end_point[passive], range[passive], NULL, NULL, NULL, 
		    check_tol);
         EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

         if (! is_hit) /*outside B/E of closed curve */
         {
            IGRdouble      delta;

            delta = fabs((hit_param[active][1] - hit_param[active][0])/2);
            test_param = hit_param[active][0] < hit_param[active][1] ?
                         hit_param[active][0] + delta :
                         hit_param[active][0] - delta;

            BScveval(curv[active], test_param, 0, (IGRpoint *)test_point, &rc);
            EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

            is_hit =  make_hit(&rc, ed[passive], test_point,
                         &gen_hit_param, &gen_hit_type, tolerance, options,
                         NULL, end_point[passive], range[passive], ed[active],
                         hit_param[passive], hit_param[active], check_tol);
            EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

            if (! is_hit)
            {
               *EMmsg = EMS_I_Fail;
               OM_stat = OM_S_SUCCESS;
               goto wrapup;
            }
            else 
               *num_ovlap = 1;
         }
         else
         {
	    IGRboolean	lined_up;

	    hit_param[passive][3] = hit_param[passive][1];
	    hit_type[passive][3] = hit_type[passive][1];
	    hit_param[passive][1] = hit_param[passive][2] = gen_hit_param;
	    hit_type[passive][1] = EMS_O_middle;
	    hit_type[passive][2] = EMS_O_adjacent;
    
	    hit_param[active][2] = hit_param[active][1];
	    hit_param[active][1] = hit_param[active][0];
	    hit_type[active][1] = hit_type[active][2] = EMS_O_middle;
    
	    lined_up = (hit_param[active][2] > hit_param[active][1]);
    
	    hit_param[active][0] = (lined_up ? bgnpar[active] : endpar[active]);
	    hit_type[active][0] = (lined_up ? EMS_O_begin : EMS_O_end);
	    hit_param[active][3] = (lined_up ? endpar[active] : bgnpar[active]);
	    hit_type[active][3] = (lined_up ? EMS_O_end : EMS_O_begin);
    
	    *num_ovlap = 2;	
         } /* ovlap across B/E of closed curve */
      }	/* 2 middle hits */

      else if (num_mid_hits == 1 && num_end_hits == 1)
      {
         hit_param[active][1] = bgnpar[active];
         hit_type[active][1] = EMS_O_begin;

         test_param = hit_param[active][0]/2;
         BScveval(curv[active], test_param, 0, (IGRpoint *)test_point, &rc);
  	 EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

         BSmdstptcv(curv[passive], test_point, &gen_hit_param, base_point,
		    &dist, &rc);
  	 EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

	 test_param = hit_param[active][0] +
				(endpar[active] - hit_param[active][0])/2;
         BScveval(curv[active], test_param, 0, (IGRpoint *)test_point, &rc);
  	 EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

         BSmdstptcv(curv[passive], test_point, &gen_hit_param, base_point,
		    &dist1, &rc);
         EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   
         if (dist1 < dist) 
	 {
		hit_param[active][1] = endpar[active];
		hit_type[active][1] = EMS_O_end;
	 } /* swap intervals */
	 *num_ovlap = 1;
      }	/* 1 middle , 1 begin/end hit	*/
      else if (num_mid_hits == 1 && !num_end_hits)
      {
         is_hit =  make_hit(&rc, ed[passive], end_point[active][BGN], 
	           &gen_hit_param, &gen_hit_type, tolerance, options, NULL, 
	           end_point[passive], range[passive], NULL, NULL, NULL, 
		    check_tol);
         EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

         if (! is_hit)
         {
            *EMmsg = EMS_I_Fail;
            OM_stat = OM_S_SUCCESS;
            goto wrapup;
         }
         else
         {
            hit_param[passive][1-tmph] = gen_hit_param;
            hit_type[passive][1-tmph]  = gen_hit_type;
            *num_ovlap = 1;

            test_param = (hit_param[passive][0] - bgnpar[passive])/2;
            BScveval(curv[active], test_param, 0, (IGRpoint *)test_point,
                     &rc);
            EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

            is_hit =  make_hit(&rc, ed[passive], test_point,
                      &gen_hit_param, &gen_hit_type, tolerance,
                      options, NULL, end_point[passive], range[passive],
                      ed[active], hit_param[passive], hit_param[active],
                      check_tol);
            EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
            hit_param[active][1] = (is_hit ? bgnpar[active] : 
                                             endpar[active]);
            hit_type[active][1] = (is_hit ? EMS_O_begin : EMS_O_end);

         }
      }/* only one middle */
   }  	/* open - closed 		*/


   else	/* both curvs are open		*/
   {
      num_hits = 0; 
      for(active=0;active<2;active++)
      {
         IGRboolean already_hit = FALSE;
         IGRint i;

         passive = (active == 0 ? 1 : 0);

         for(end_pt=BGN; end_pt<FIN+1; end_pt++)
         {
            already_hit = FALSE;
            for(i=0; i<num_hits; i++)
            if(hit_type[active][i] == (end_pt == BGN ?
                                       EMS_O_begin : EMS_O_end))
            {
               already_hit = TRUE;
               break;
            }
            if(already_hit)
            continue;

    	    is_hit =  make_hit(&rc, ed[passive], end_point[active][end_pt], 
		           &hit_param[passive][num_hits],
		           &hit_type[passive][num_hits], tolerance, options,
                           NULL, end_point[passive], range[passive],
                           NULL, NULL, NULL, check_tol);
            EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   
	    if (! is_hit) continue;
            hit_param[active][num_hits] = (end_pt == BGN ? bgnpar[active] : 
							    endpar[active]);
	    hit_type[active][num_hits] = (end_pt == BGN ?
                                          EMS_O_begin : EMS_O_end);
            num_hits++;
         }/*for(end_pt=BGN; end_pt<FIN+1; end_pt++)*/
      }/*for(active=0;active<2;active++)*/
   
      if (num_hits < 2) {*EMmsg = EMS_I_Fail;goto wrapup;}
   	
      if(num_hits > 2)
      {
         IGRint lht[2][4], loc_num_hits = 0;
         IGRdouble lhp[2][4];
   
         if(num_hits == 3)
         {
           /* Find the end-to-end hit and ignore it.
           */
            OM_BLOCK_MOVE(hit_type, lht, 8 * sizeof(IGRint));
            OM_BLOCK_MOVE(hit_param, lhp, 8 * sizeof(IGRdouble));
            loc_num_hits = num_hits;
            num_hits = 0;

            for(i=0; i<loc_num_hits; i++)
            {
               if( ((lht[0][i] == EMS_O_begin) && (lht[1][i] == EMS_O_begin))
                 ||
                 ((lht[0][i] == EMS_O_end) && (lht[1][i] == EMS_O_begin))
                 ||
                 ((lht[0][i] == EMS_O_begin) && (lht[1][i] == EMS_O_end))
                 ||
                 ((lht[0][i] == EMS_O_end) && (lht[1][i] == EMS_O_end)))
               continue;
   
               hit_type[0][num_hits] = lht[0][i];
               hit_type[1][num_hits] = lht[1][i];
               hit_param[0][num_hits] = lhp[0][i];
               hit_param[1][num_hits] = lhp[1][i];
               num_hits++;
               if(num_hits == 2) break;

            } /* for(i=0; i<loc_num_hits; i++) */

         } /* if(num_hits == 3) */

      } /* if(num_hits > 2) */

      active = 0;
      passive = 1;

      if(   (hit_type[active][0] == EMS_O_begin && 
				     hit_type[active][1] == EMS_O_begin) 
              || (hit_type[active][0] == EMS_O_end && 
				     hit_type[active][1] == EMS_O_end) 
              || (hit_type[passive][0] == EMS_O_begin && 
	      			  hit_type[passive][1] == EMS_O_begin) 
              || (hit_type[passive][0] == EMS_O_end && 
				     hit_type[passive][1] == EMS_O_end) 
             ) {*EMmsg = EMS_I_DegenerateEdge; *num_ovlap = 1;}
      else
      {
         IGRdouble	delta;

         delta = fabs((hit_param[active][1] - hit_param[active][0])/2); 
         test_param = hit_param[active][0] < hit_param[active][1] ? 
                    hit_param[active][0] + delta : hit_param[active][0] - delta;
	
         BScveval(curv[active], test_param, 0, (IGRpoint *)test_point, &rc);
         EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

         is_hit =  make_hit(&rc, ed[passive], test_point, 
	              &gen_hit_param, &gen_hit_type, tolerance, options, NULL, 
	              end_point[passive], range[passive], ed[active], 
	              hit_param[passive], 
	              hit_param[active], check_tol);
         EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);   

         if (! is_hit)
         {
            *EMmsg = EMS_I_Fail;
            OM_stat = OM_S_SUCCESS;
            goto wrapup;
         }
         else *num_ovlap = 1;
  
      }/* test mid-point */
 
   } 				/* open-open */

   if (*num_ovlap)
   {
      if (ovlap0)
      OM_BLOCK_MOVE(&hit_param[0][0], ovlap0, 2*(*num_ovlap)*sizeof(IGRdouble));
      if (ovlap1)
      OM_BLOCK_MOVE(&hit_param[1][0], ovlap1, 2*(*num_ovlap)*sizeof(IGRdouble));
      if (hitinfo0)
      OM_BLOCK_MOVE(&hit_type[0][0], hitinfo0, 2*(*num_ovlap)*sizeof(IGRint));
      if (hitinfo1)
      OM_BLOCK_MOVE(&hit_type[1][0], hitinfo1, 2*(*num_ovlap)*sizeof(IGRint));
   }		 

wrapup:

   EMWRAPUP(*EMmsg, OM_stat, "In TOgetcvcv_ovlap")
   return(OM_stat);
}


static IGRboolean make_hit(rc, ed1, point, param, type, tolerance, options, 
			   mdist, curve1_endpts, range1, ed2, ovlap1, 
			   ovlap2, check_tol)
BSrc *rc;
struct edge *ed1;
struct edge *ed2;
IGRpoint point;
IGRdouble *param;
IGRint *type;
IGRdouble tolerance;
IGRushort options;
IGRdouble *mdist, *curve1_endpts, *ovlap1, *ovlap2, check_tol;
GRrange *range1;
{
   struct IGRbsp_curve *curve1=NULL;
   struct IGRbsp_curve *curve2=NULL;
   IGRdouble		hit_par;
   IGRdouble		dis_bgn, dis_end, mdis;
   IGRpoint		base_pnt;
   IGRdouble		*end_pnt, *bgn_pnt;
   GRrange		ptrange;
   IGRint			i;
   IGRdouble		loctol;

   options = options;	/* wrt the compiler */
   loctol  = tolerance;

   if(ed1)
      curve1  = ed1->edid0->ext->edge;
   if(ed2)
      curve2  = ed2->edid0->ext->edge;
   bgn_pnt = curve1_endpts;
   end_pnt = &curve1_endpts[3];

   if(mdist) *mdist = MAXDOUBLE;
   dis_bgn = BSdistptpt(rc, bgn_pnt, point);
   if (*rc != BSSUCC) return FALSE;

   dis_end = BSdistptpt(rc, end_pnt, point);
   if (*rc != BSSUCC) return FALSE;

   if (dis_bgn <= loctol && dis_end <= loctol)
   {
      if(dis_bgn < dis_end)
      {
         *type = EMS_O_begin;
         if(mdist) *mdist = dis_bgn;
      }
      else
      {
         *type = EMS_O_end;
         if(mdist) *mdist = dis_end;
      }
   }
   else if (dis_bgn <= loctol)  
      {*type = EMS_O_begin; if(mdist) *mdist = dis_bgn;}
   else if (dis_end <= loctol)  
      {*type = EMS_O_end; if(mdist) *mdist = dis_end;}
   else
   {
      if(range1)
      {
      for(i=0; i<3; i++)
      {
         ptrange[i] = point[i] - check_tol;
         ptrange[i+3] = point[i] + check_tol;
      }
   }
   if (! BSbxint(rc, ptrange, &ptrange[3], range1[0], &range1[0][3]))
      return FALSE;
   BSmdstptcv(curve1, point, &hit_par, base_pnt, &mdis, rc);
   if (*rc != BSSUCC) return FALSE;
   if(mdist) *mdist = mdis;

   if (mdis > tolerance)
   {
      /*
      Try sample size points. If number of hits is more than number of misses
      consider it as a match. Do this check only if the test point was
      within CheckFactor * tolerance.
      SM  03-Jan-90.
      if(curve2 && (mdis < check_tol))
      {
         IGRlong OM_stat, EMmsg;
         IGRint sample_size = 4, num_hits = 0, num_misses = 0;
         IGRdouble ov1[2], ov2[2];
        
         if(!ovlap1)
         {
            if(ed1->status != 4)
            {
	       ov1[0] = curve1->knots[0];
	       ov1[1] = curve1->knots[curve1->num_poles + curve1->order - 1];
	       ovlap1 = ov1;
            }
            else
            {
               ov1[0] = ed1->ext->bound[0].param;
               ov1[1] = ed1->ext->bound[1].param;
               ovlap1 = ov1;
            }
         }
         if(!ovlap2)
         {
            if(ed1->status != 4)
            {
	       ov2[0] = curve2->knots[0];
	       ov2[1] = curve2->knots[curve2->num_poles + curve2->order - 1];
	       ovlap2 = ov2;
            }
            else
            {
               ov2[0] = ed2->ext->bound[0].param;
               ov2[1] = ed2->ext->bound[1].param;
               ovlap2 = ov2;
            }
         }

         OM_stat = TOvalcv_ovlap(&EMmsg, curve1, curve2, ovlap1, ovlap2,
	    sample_size, &num_hits, &num_misses, tolerance, NULL, NULL);
         if((1&EMmsg&OM_stat) && (num_hits > num_misses))
         {
#ifdef DBG
            printf("Considering hit. Num hits = %d, Num misses = %d\n", 
	    	  num_hits, num_misses);
#endif
            *type = EMS_O_middle;
         }
         else
         {
#ifdef DBG
	    printf("Sample point hit check unsuccessful\n");
#endif
            return FALSE;
         }
      }
      else return FALSE;
      */
      return FALSE;
   }
      else *type = EMS_O_middle;
   }

  /* If the hittype is a middle one then do a model space check to make sure 
     the middle point is not within the tolerance from any of the end points.
     If the middle point is within tolerance from the end point in model space
     then the middle point should be treated as  being at the begin or end. 
     This will avoid the generation of near degenerate edges. 

     TR# 119311435
  */
    
  if ( *type == EMS_O_middle )
  {
	IGRdouble	dis_midbeg, dis_midend;
	IGRpoint	mid_point;
	

	BScveval( curve1, hit_par, 0, (IGRpoint *) &mid_point, rc );
	dis_midbeg = BSdistptpt( rc, bgn_pnt, mid_point );
	dis_midend = BSdistptpt( rc, end_pnt, mid_point );  	
	
	if( dis_midbeg <= loctol && dis_midend <= loctol )
	{
		if( dis_midbeg < dis_midend )
			*type = EMS_O_begin;
		else
			*type = EMS_O_end;
	}
	else if( dis_midbeg <= loctol )
	{
		*type = EMS_O_begin;
	}
	else if( dis_midend <= loctol )
	{
		*type = EMS_O_end;
	}
  } 
   if( *type == EMS_O_begin) 
   {
      if(ed1->status != 4)
         *param = curve1->knots[0];
      else
      {
         if(curve1->knots[0] <
            curve1->knots[curve1->num_poles + curve1->order - 1])
            *param = ed1->ext->bound[0].param;
         else
            *param = ed1->ext->bound[1].param;
      }
   }
   else if ( *type == EMS_O_end)
   {
      if(ed1->status != 4)
         *param = curve1->knots[curve1->num_poles + curve1->order - 1];
      else
      {
         if(curve1->knots[curve1->num_poles + curve1->order - 1] > 
            curve1->knots[0])
            *param = ed1->ext->bound[1].param;
         else
            *param = ed1->ext->bound[0].param;
      }
   }
   else *param = hit_par;
   return TRUE;
}
