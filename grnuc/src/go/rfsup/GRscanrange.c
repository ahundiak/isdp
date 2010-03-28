/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "igr.h"
#include "igrdef.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "msdef.h"
#include "madef.h"
#include "mapriv.h"

#define DEBUG 1

IGRboolean GRscanrange(msg, pt1, pt2, md_env,vw_volume,
		        master_to_ref_matrix,clip_matrix,
			tolerance,  range)
IGRlong		*msg;
IGRdouble	*pt1;
IGRdouble 	*pt2;
struct GRmdenv_info *md_env;
IGRdouble	*vw_volume;
IGRmatrix	master_to_ref_matrix;
IGRmatrix	clip_matrix;
IGRdouble	*tolerance;
GRrange		range;

{
    IGRshort    mx_size;

    IGRlong	msg1;
    IGRlong 	i;

    IGRdouble   *mxptr ;		/* working pointers		*/
    IGRdouble   points[6];

    IGRmatrix	invmx,tmatrix,tmatrix2;	/* working matrices		*/

    struct IGRlbsys lbsys;		/* local bounded system		*/

extern    IGRboolean    MAinvmx();

    *msg = MSSUCC;
    mx_size = 4;

    if (md_env->matrix_type != MAIDMX)
    {
 	/* points and tolerance must be transformed to current master
	 * file's world coordinate system before scan range can be computed
	 * from the input points
	 */

	if (MAinvmx(msg,&mx_size,md_env->matrix,invmx))
	{
	   MAmulmx(&msg1,&mx_size,&mx_size,&mx_size,
		   master_to_ref_matrix, invmx, tmatrix);

	   mxptr = (IGRdouble *)&tmatrix[0];

	}
    }
    else
    {
	mxptr = (IGRdouble *)&master_to_ref_matrix[0];    
    }
    if ( 1 & *msg)
    {
	if (MAinvmx(msg,&mx_size,clip_matrix,invmx))
	{
	    MAmulmx(&msg1,&mx_size,&mx_size,&mx_size,
		    invmx,mxptr,tmatrix2);
				/* bump points by tolerance	*/
	    for (i=0; i<3; ++i)
            {
		if (pt1[i] < pt2[i])
		{
		    points[i] = pt1[i] - *tolerance;
	   	    points[i+3] = pt2[i] + *tolerance;
		}
		else
		{		
		    points[i] = pt2[i] - *tolerance;
	   	    points[i+3] = pt1[i] + *tolerance;
		}
	    }
	    /* transform the input points of line to view coordinates*/
   	    i = 2;
	    MAptsxform(&msg1,&i,tmatrix2,points,points);

#ifdef DEBUG
 printf("points in view coordiates\n");

 for (i=0; i<2 ; ++i)
 {
    printf("%lf %lf %lf\n",
	  points[i*3],points[i*3+1],points[i*3+2]);
 }
#endif
				/* load points for extents		*/
    	    for (i=0; i<2; ++i)
	    {
		if (points[i] < points[i+3]) 
		{
		    lbsys.diag_pt1[i] = points[i];
		    lbsys.diag_pt2[i] = points[i+3];
		}
		else
		{
		    lbsys.diag_pt1[i] = points[i+3];
		    lbsys.diag_pt2[i] = points[i];
		}

	    }
	    lbsys.diag_pt1[2] = vw_volume[2];
	    lbsys.diag_pt2[2] = vw_volume[5];
	    for (i=0; i<16; ++i)
	    {
	        lbsys.matrix[i] = clip_matrix[i];
	    }
#ifdef DEBUG
 printf("local bounded system\n");

 printf("%lf %lf %lf\n",
	  lbsys.diag_pt1[0],lbsys.diag_pt1[1],lbsys.diag_pt1[2]);
 printf("%lf %lf %lf\n",
	  lbsys.diag_pt2[0],lbsys.diag_pt2[1],lbsys.diag_pt2[2]);
 for (i=0; i>4; ++i)
 {
    printf("%lf %lf %lf %lf\n", 
	  lbsys.matrix[i*4],lbsys.matrix[i*4+1],lbsys.matrix[i*4+2],
	  lbsys.matrix[i*4+3]);
 }
#endif

	/* The diagonal points are in local coordinates of the reference
	 * file. Now form the cube defined from the above points which
	 * have been extended to the z limits of the local design space
	 * The matrix sent as input transforms the diagonal points to
	 * the world coordinates of the reference file.
  	 */

	    MAlbextents(&msg1,&lbsys,range,&range[3]);

#ifdef DEBUG
  printf("range in GRscanrange = \n");
  for (i=0; i<2 ; ++i)
  {
    printf("%lf %lf %lf\n",
	    range[i*3],range[i*3+1],range[i*3+2]);
  }
#endif
	}
	else
	{
	    *msg = MSFAIL;
	}
    }
        
    return (*msg == MSSUCC);
}
