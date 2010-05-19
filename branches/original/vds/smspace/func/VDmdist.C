/* $Id: VDmdist.C,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/func / VDmdist.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDmdist.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/* Find all the points at minimum distance between 2 curves

Arguments

IGRbsp_curve *bc1  I  curve 1
IGRbsp_curve *bc2  I  curve 2
int	     *num  O  number of points at minimum distance
double 	     **pt1 O  points at minimun distance on curve 1
double 	     **pt2 O  points at minimun distance on curve 2
		      NB : pt1 and pt2 are allocated by the function and must 
		           be freed by the caller if !NULL
double	     *dist O  minimum distance between the curves
double	     dist0 I  Points at minimum distance are returned only if distance
		      found is less than dist0
double	     eps   I  for a minimun distance dist0 between the 2 curves,
		      points where distance is less than dist0 + eps are
 		      returned as points at minimum distance 
long 	     *rc   O  return code BSSUCC if success

*/




#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"

double BSlenvec(),BSdotp(),sqrt(),fabs();

VDmdistcvcv(bc1,bc2,num,pt1,pt2,dist0,dist,eps,rc)
struct IGRbsp_curve *bc1,*bc2;
int *num;
double **pt1,**pt2,dist0,*dist,eps;
long *rc;

{
 long loc_rc;

 int num_bc2,size_bc2,i_bc2,loc_num,max_num_poles,i;

 double *loc_pt1,*loc_pt2,*loc_par1,*loc_par2;
 double loc_dist,val1[6],val2[6],tng1,tng2,tng12,
	delta,min_u,max_u,middle;

 struct IGRbsp_curve **bc2_stack,line;
 char *end_point;
 double eps_par = 1.e-4;
 double line_poles[6],line_knots[4];

 /* Initializations */

 *num = 0;
 *pt1 = NULL;
 *pt2 = NULL;
 
 num_bc2 = 1;
 size_bc2 = 10;
 bc2_stack = (struct IGRbsp_curve **) 
			       malloc(size_bc2*sizeof(struct IGRbsp_curve **));
 end_point = (char *) malloc(size_bc2);
 *dist = dist0; 
 bc2_stack[0] = bc2; 
 end_point[0] = 0;

 line.poles = line_poles;
 line.knots = line_knots;

 for(i_bc2=0;i_bc2<num_bc2;i_bc2++)
  {
   bc2 = bc2_stack[i_bc2];

   /* Search point at minimum distance */

   loc_pt1  = NULL;
   loc_pt2  = NULL;
   loc_par1 = NULL;
   loc_par2 = NULL;
   BSmdistcvcv(bc1,bc2,&loc_num,&loc_par1,&loc_par2,&loc_pt1,&loc_pt2,
	      &loc_dist,&loc_rc);

   if(loc_num <= 0 || loc_rc != BSSUCC) continue;


   if( (loc_par2[0] <   eps_par && (end_point[i_bc2]&1 ))
          ||(loc_par2[0] > 1-eps_par && (end_point[i_bc2]&2 )))
    {
     /* in certain cases, BSmindistcvcv returns end point instead of
	real min distance. Try to track the problem */
     loc_par2[0] = 1.-loc_par2[0];
     BScveval(bc2,loc_par2[0],0,val2,&loc_rc);
     BSlnn2cvs(&loc_rc,bc1,bc2,val2,val2,&line,loc_par1,loc_par2);
     if(loc_rc == BSSUCC && loc_par2[0]>eps_par &&loc_par2[0] <1-eps_par)
      {
       /* Split bc2 at this points */

       if(num_bc2+2 > size_bc2)
        {
         size_bc2 += 10;
         bc2_stack = (struct IGRbsp_curve **) realloc
			    (bc2_stack,size_bc2*sizeof(struct IGRbsp_curve **));
         end_point = (char *) realloc(end_point,size_bc2);
        }
 

       max_num_poles = bc2->num_poles + 2*bc2->order - 1;
       if(bc2->phy_closed)
       {
	printf("SHOULD NEVER GO THERE\n");
       }
       else
       {
        BSalloccv(bc2->order,max_num_poles,bc2->rational,bc2->num_boundaries,
	       bc2_stack+num_bc2,&loc_rc);
        BSpartofcv(&loc_rc,bc2,0.,0.,loc_par2[0],bc2_stack[num_bc2]);
	if(loc_rc == BSSUCC) 
          end_point[num_bc2++] = end_point[i_bc2] & 2 ;
	else printf("partofcv failure for 0 -- lf\n",loc_par2[0]);
        BSalloccv(bc2->order,max_num_poles,bc2->rational,bc2->num_boundaries,
	       bc2_stack+num_bc2,&loc_rc);
        BSpartofcv(&loc_rc,bc2,loc_par2[0],1.,1.,bc2_stack[num_bc2]);
	if(loc_rc == BSSUCC) 
          end_point[num_bc2++] = end_point[i_bc2] & 1 ;
	else printf("partofcv failure for %lf -- 1\n",loc_par2[0]);
      }
     }
    }

   else if( loc_dist > *dist +eps)
     { /* not a valid solution */}

 /* Store the point only if it's not an end point resulting from intersection */

   else
    {
     {
     if(loc_dist < *dist - eps) *num = 0;
     *dist = *dist < loc_dist ? *dist : loc_dist;
     if(*pt1) *pt1 = (double *) realloc(*pt1,3* (*num+1) * sizeof(double));
     else     *pt1 = (double *)  malloc(     3* (*num+1) * sizeof(double));

     if(*pt2) *pt2 = (double *) realloc(*pt2,3* (*num+1) * sizeof(double));
     else     *pt2 = (double *)  malloc(     3* (*num+1) * sizeof(double));
   
     for(i=0;i<3;i++)
     {
      (*pt1)[3* *num + i] = loc_pt1[i];
      (*pt2)[3* *num + i] = loc_pt2[i];
     }
     (*num)++;
    }

  /* Search points on bc2 far enought from bc1 */

   min_u= loc_par2[0];
   max_u= loc_par2[0];

   BScveval(bc1,loc_par1[0],1,val1,&loc_rc);
   BScveval(bc2,loc_par2[0],1,val2,&loc_rc);

   tng1 = BSlenvec(&loc_rc,val1+3);
   tng2 = BSlenvec(&loc_rc,val2+3);
   tng12 = BSdotp(&loc_rc,val1+3,val2+3);

   delta = 0;
   if(tng1 > 1.e-12)
     delta = tng2*tng2 - tng12*tng12/(tng1*tng1);

   if(delta > 1.e-12)
     delta = sqrt((eps*eps + 2*eps*loc_dist)/delta);
   if(delta < 2*eps_par) delta = 2*eps_par;

   min_u = min_u - delta;
   if(min_u <0 && bc2->phy_closed) min_u += 1;

   max_u = max_u + delta;
   if(max_u >1 && bc2->phy_closed) max_u -= 1;
     
  /* Split bc2 at this points */

   if(num_bc2+2 > size_bc2)
    {
      size_bc2 += 10;
      bc2_stack = (struct IGRbsp_curve **) realloc
			    (bc2_stack,size_bc2*sizeof(struct IGRbsp_curve **));
      end_point = (char *) realloc(end_point,size_bc2);
    }
 

   max_num_poles = bc2->num_poles + 2*bc2->order - 1;
   if(bc2->phy_closed)
    {
     middle = 0.5*(min_u+max_u);
     if(max_u>min_u) middle += 0.5; 
     BSalloccv(bc2->order,max_num_poles,bc2->rational,bc2->num_boundaries,
	       bc2_stack+num_bc2,&loc_rc);
     BSpartofcv(&loc_rc,bc2,max_u,middle,min_u,bc2_stack[num_bc2]);
     if(loc_rc == BSSUCC) end_point[num_bc2++] = 3;
     else printf("partofcv failure for %lf -- %lf \n",max_u,min_u);
    }
   else
    {
     if(min_u > 0)
      {
       BSalloccv(bc2->order,max_num_poles,bc2->rational,bc2->num_boundaries,
	       bc2_stack+num_bc2,&loc_rc);
       BSpartofcv(&loc_rc,bc2,0.,0.,min_u,bc2_stack[num_bc2]);
       if(loc_rc == BSSUCC) end_point[num_bc2++] = end_point[i_bc2] | 2;
       else printf("partofcv failure for 0 -- %lf \n",min_u);
      }
     if(max_u < 1)
      {
       BSalloccv(bc2->order,max_num_poles,bc2->rational,bc2->num_boundaries,
	       bc2_stack+num_bc2,&loc_rc);
       BSpartofcv(&loc_rc,bc2,max_u,1.,1.,bc2_stack[num_bc2]);
       if(loc_rc == BSSUCC) end_point[num_bc2++] = end_point[i_bc2] | 1;
       else printf("partofcv failure for %lf  -- 1 \n",max_u);
      }
    }
   }
   
  /* Free what was allocated by BSmdistcvcv */

   if(loc_pt1)  free (loc_pt1); 
   if(loc_pt2)  free (loc_pt2); 
   if(loc_par1) free (loc_par1); 
   if(loc_par2) free (loc_par2); 
  }

 /* Free memory allocated for intermediate bspline curve */

 for(i_bc2=1;i_bc2<num_bc2;i_bc2++)
  {if(bc2_stack[i_bc2])  free(bc2_stack[i_bc2]);}

 free(bc2_stack);
 free(end_point);

 *rc = BSSUCC;

}
 

