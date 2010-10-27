/* $Id: VDSclose_bnd.h,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdspace/ppl / VDSclose_bnd.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSclose_bnd.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:23  cvs
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

/*  This because the makemake does not like 
/*#include "cieveryone.h"
/*#include "cimacros.h"
/*#include "ci_mac_def.h"
/*#include "bstypes.h"
/*#include "bserr.h"
/*#include "bsconic.h"
/*#include "emsedgedef.h"
/*#include "macro.h"
/*#include "nddef.h"

/*#include "DIdef.h"
/*#include "acmacros.h"
/*#include "COmdef.h"
/*#include "AS_status.h"
/*#include "grdpbdef.h"
/*#include "grdpbmacros.h"
/*
/**/
/*#define   DEBUG2	1 */
/*  */


VDclose_bnd(msg, bdry )
long *msg;
struct IGRbsp_bdry_pts *bdry;
/*.VDclose_bnd*/
{
int		flag,close_bd,nb_time;
IGRdouble	coeff,tol;
int		i,k;
long		nput, nret;
extern double   fabs();
extern int	GRdpb_get();

# ifdef DEBUG2
  printf("VDclose_bnd ------------\n");
# endif

close_bd = 0;
nb_time = 0;
*msg = 1;
flag = 0;

nput = sizeof(tol);
gr$get_basis_tolerance(msg = msg, sizbuf = &nput, buffer = &tol, nret = &nret);
# ifdef DEBUG2
  printf("basis_tolerance: %lf\n",tol);
# endif

while(close_bd != 1 && nb_time < 5)
 {
coeff = 0;
# ifdef DEBUG2
  printf("bdry[0]: %lf, bdry[1]: %lf\n", bdry->points[0],bdry->points[1]);
  printf("bdry[%d]: %lf, bdry[%d]: %lf\n",2*(bdry->num_points-1 ),
                             bdry->points[2*(bdry->num_points-1 )],
                             2*(bdry->num_points-1 )+1,
                             bdry->points[2*(bdry->num_points-1 )+1]);
# endif
    for(k=0;k<2;k=k+1) 
         coeff = coeff + fabs(bdry->points[k] - 
                         bdry->points[2*(bdry->num_points-1 )+k]);

    if (coeff < tol)
	{
           close_bd = 1;
#          ifdef DEBUG2
           printf("close bd\n");
#          endif
           break;
	}
     else
        {
#         ifdef DEBUG2
          printf("add necessary points to close the boundary\n");
#         endif

          if (bdry->points[0] != 0 && bdry->points[0] !=1 &&
	      bdry->points[1] != 0 && bdry->points[1] != 1) 
                {
                 printf("error, point 0 is not on the border\n");
                 *msg = 0;
                 return(1);
                }
          if (bdry->points[2*(bdry->num_points-1 )] != 0 && bdry->points[2*(bdry->num_points-1 )] !=1 &&
	      bdry->points[2*(bdry->num_points-1 )+1] != 0 && bdry->points[2*(bdry->num_points-1 )+1] != 1) 
                {
                 printf("error, point n is not on the border\n");
                 *msg = 0;
                 return(1);
                }

          if ((bdry->points[0] == bdry->points[2*(bdry->num_points-1 )] &&
	       (bdry->points[0] == 1|| bdry->points[0] == 0)) ||
	      (bdry->points[1] == bdry->points[2*(bdry->num_points-1 )+1] &&
	      (bdry->points[1] == 1 || bdry->points[1] == 0)))
             {
#               ifdef DEBUG2
                printf("x0=xn=1/0 ou y0=yn=0/1 => double point de fin\n");
#               endif
                bdry->points[2*(bdry->num_points-1 )+2] = bdry->points[0];
                bdry->points[2*(bdry->num_points-1 )+3] = bdry->points[1];
                bdry->num_points = bdry->num_points + 1;
	     }
          else if ((bdry->points[0] == 0 || bdry->points[0] == 1)  &&
                   (bdry->points[2*(bdry->num_points-1 )+1] == 0 || bdry->points[2*(bdry->num_points-1 )+1] == 1)) 
             {
#               ifdef DEBUG2
                printf("x0 = 0/1 & yn =0/1 => the point to add is a corner\n");
#               endif

                bdry->points[2*(bdry->num_points-1 )+2] = bdry->points[0];
                bdry->points[2*(bdry->num_points-1 )+3] = bdry->points[2*(bdry->num_points-1 )+1];
                bdry->num_points = bdry->num_points + 1;
             }
          else if ((bdry->points[2*(bdry->num_points-1 )] == 0 || 
                    bdry->points[2*(bdry->num_points-1 )] == 1)  &&
                   (bdry->points[1] == 0 || bdry->points[1] == 1)) 
             {
#               ifdef DEBUG2
                printf("xn = 0/1 & y0 =0/1 => the point to add is a corner\n");
#               endif

                bdry->points[2*(bdry->num_points-1 )+2] = bdry->points[2*(bdry->num_points-1 )];
                bdry->points[2*(bdry->num_points-1 )+3] = bdry->points[1];
                bdry->num_points = bdry->num_points + 1;
             }
          else 
             {
#               ifdef DEBUG2
                printf("ajout d'un coin au hasard pour se ramener aux cas pcdt\n");
#               endif
                if(bdry->points[2*(bdry->num_points-1 )] == 0 || 
                    bdry->points[2*(bdry->num_points-1 )] == 1)
                 {
                   bdry->points[2*(bdry->num_points-1 )+2] = bdry->points[2*(bdry->num_points-1 )];
                   bdry->points[2*(bdry->num_points-1 )+3] = 0;
                 }
                else if(bdry->points[2*(bdry->num_points-1 )+1] == 0 || 
                    bdry->points[2*(bdry->num_points-1 )+1] == 1)
                 {
                   bdry->points[2*(bdry->num_points-1 )+2] = 0;
                   bdry->points[2*(bdry->num_points-1 )+3] = bdry->points[2*(bdry->num_points-1 )+1];
                 }
                else 
                  {
                     printf("point n is not on the surface\n");
                     *msg = 0;
                     return(1);
                  }
                bdry->num_points = bdry->num_points + 1;
             }
   
        }/* end not closed */

# ifdef DEBUG2
  printf("num_point: %d\n",bdry->num_points );
  for(i=0; i<bdry->num_points ; i=i+1) 
      printf("point (u,v): %lf, %lf\n", bdry->points[2*i],bdry->points[2*i+1]);
# endif

    nb_time = nb_time + 1;
 }/* end while */

if(!close_bd)
 {
   printf("error, boundary cannot be closed\n");
   *msg = 0;
   return(1);
 }
*msg = 1;
return(1);
}

