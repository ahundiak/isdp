/* #######################    APOGEE COMPILED   ######################## */
/* This module is a support function for Reference files.  It
   prepares the range key structure to do an R-tree pass in
   the R-tree of the reference file.  Additionally processing
   is needed for the case of a skew view for skew scan on the
   R_tree.

   If the range is requested, it will be computed from the 
   boreline sent in extended to the design file limits in
   the reference file and "thickened" cube defined by
   the tolerance.

   The arguments are defined below.
 */
#include "math.h"
#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "OMindex.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "madef.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include "bstypes.h"
#include "bsmklnintbx.h"
#include "bserr.h"
#include "bsparameters.h"

extern    IGRboolean    MAinvmx();
extern    IGRboolean    MAlswcmx();

IGRboolean GRpassrange(msg, pt1, pt2, type, matrix,clip_poly,
	vw_volume,master_to_ref_matrix,vw_matrix,range,compute_range,
	is_skew,tolerance,range_key)

IGRlong		*msg;		/* return code				*/
IGRdouble	*pt1;		/* optional boreline points		*/
IGRdouble 	*pt2;		/* option boreline points		*/
IGRshort	*type;		/* matrix type				*/
IGRmatrix	matrix;		/* environment matrix			*/
struct IGRcv_prism *clip_poly;	/* clipping polygon			*/
IGRdouble	*vw_volume;	/* vw_volume in ref. view coordinates	*/
IGRmatrix	master_to_ref_matrix;
IGRmatrix	vw_matrix;	/* matrix for view to reference file world
				   coordinates 				*/
GRrange		range;		/* optional input/output 		
				 * you may send it in or request it be
				   computed from the boreline and view	*/
IGRshort	compute_range;	/* 0 = range sent in
				 * 1 = compute range from boreline pts	*/
IGRshort	is_skew;	/* indicator if view is skew view
				 * 0 = view is not skew		
				 * 1 = view is skew			*/
IGRdouble	*tolerance;	/* tolerance if boreline used		*/
IGRchar		*range_key;	/* range key for pass message		*/

{
    IGRshort    mx_size;

    IGRlong	msg1;			
    IGRlong 	i,index;

    IGRdouble   *mxptr,*ptr;		/* working pointers		*/
    IGRdouble   points[30],		/* transformed points		*/
		pt[6], tol, dis;
    IGRdouble   line_in_ref_coord[6],
		line_in_view_coord[6];
    IGRdouble   origin[3];
    IGRdouble	vc1[3];			/* vector for skew range	*/

    GRrange	skew_range;		/* skew range	 		*/

    IGRmatrix	invmx,tmatrix,tmatrix2;	/* working matrices		*/

    struct IGRlbsys lbsys;		/* local bounded system		*/
    struct IGRpolyline py;		/* polyline structure		*/

    struct IGRbsp_curve	line;
    IGRdouble	knots[12];
    IGRdouble	poles[6];
    IGRdouble	vect[3],zerotol;
    IGRdouble   dx,dy,dz;

    OM_p_KEY_DESC key;
    OM_p_SKEW_DESC skew_key;



    line.knots = knots;
    line.poles = poles;

    *msg = MSSUCC;
    mx_size = 4;
    mxptr = NULL;

    if ((compute_range) || ( (is_skew) && (pt1 && pt2)))
    {
	if (*type != MAIDMX)
    	{
 	/* points and tolerance must be transformed to current master
	 * file's world coordinate system before scan range can be computed
	 * from the input points
	 */
	    if (MAinvmx(msg,&mx_size,matrix,invmx))
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
	    origin[0] = vw_matrix[3];
	    origin[1] = vw_matrix[7];
	    origin[2] = vw_matrix[11];

	    if (MAwclsmx(msg,origin,vw_matrix,invmx))
	    {
	    	MAmulmx(&msg1,&mx_size,&mx_size,&mx_size,
		    invmx,mxptr,tmatrix2);
		
		if (pt1 && pt2)
		{
	    	    /* transform the input points of line to 
		     * view coordinates
		     */

   	    	    i = 1;
	    	    MAptsxform(&msg1,&i,tmatrix2,pt1,line_in_view_coord);
	    	    MAptsxform(&msg1,&i,tmatrix2,pt2,&line_in_view_coord[3]);

		    pt[0] = pt[1] = pt[2] = pt[3] = pt[4] = 0.0;
		    pt[5] = 1.0;
		    i = 2;
	    	    MAptsxform(&msg1,&i,tmatrix2,pt,pt);
		    MA2ptdis(&msg1,pt,&pt[3],&dis);

		    tol = *tolerance * dis;

		    /* 
		     * assign the coodinates in the line in
		     * view coordinates.
		     */
/*****
		The following code is now being commented out as it was
		leading to change of orientation of the vector 
	        line_in_view_coord. Instead of this we are computing the
	        intersection between the vw_volume and the line_in_view_coord
	        to get the correct coordinates for line_in_view_coord truncated
	        upto the vw_volume. --- Satya --

                        if ( line_in_view_coord[2] > vw_volume[2])
                        {
                           line_in_view_coord[2] = vw_volume[2];
                        }
                        if (line_in_view_coord[5] < vw_volume[5])
                        {
                           line_in_view_coord[5] = vw_volume[5];
                        }

****/

		     MAsubvc(&msg1,&line_in_view_coord[3],line_in_view_coord,
			     vect);
		     BSnorvec(&msg1,vect);
		     BSmklnintbx(line_in_view_coord,vect,vw_volume,
			      &vw_volume[3],TRUE,&line,&msg1);
		     for(i = 0;i < 6;i++)
		         line_in_view_coord[i] = line.poles[i];

		     ptr = points;	

		     /*
		      * form cube by using tolerance and line in 
		      * reference file view coordinates.
		      */
		
		      *ptr++ = line_in_view_coord[0] + tol;
		      *ptr++ = line_in_view_coord[1] + tol;
		      *ptr++ = line_in_view_coord[2];

		      *ptr++ = line_in_view_coord[0] - tol;
		      *ptr++ = line_in_view_coord[1] + tol;
		      *ptr++ = line_in_view_coord[2];
 
   		      *ptr++ = line_in_view_coord[0] - tol;
		      *ptr++ = line_in_view_coord[1] - tol;
		      *ptr++ = line_in_view_coord[2];

		      *ptr++ = line_in_view_coord[0] + tol;
		      *ptr++ = line_in_view_coord[1] - tol;
		      *ptr++ = line_in_view_coord[2];

		      *ptr++ = line_in_view_coord[3] + tol;
		      *ptr++ = line_in_view_coord[4] + tol;
		      *ptr++ = line_in_view_coord[5];
   
  		      *ptr++ = line_in_view_coord[3] - tol;
		      *ptr++ = line_in_view_coord[4] + tol;
		      *ptr++ = line_in_view_coord[5];

		      *ptr++ = line_in_view_coord[3] - tol;
		      *ptr++ = line_in_view_coord[4] - tol;
		      *ptr++ = line_in_view_coord[5];

		      *ptr++ = line_in_view_coord[3] + tol;
		      *ptr++ = line_in_view_coord[4] - tol;
		      *ptr++ = line_in_view_coord[5];
  
       		      /* 
		       * transform points to reference file world
		       * coordinates
		       */

		      i = 8;
	    	      MAptsxform(&msg1,&i,vw_matrix,points,points);
		    
		      /* transform line to reference file coordinates */

		      i = 1;
	    	      MAptsxform(&msg1,&i,mxptr,pt1,line_in_ref_coord);
	    	      MAptsxform(&msg1,&i,mxptr,pt2,&line_in_ref_coord[3]);
			
		      /*
		       * form skew vector for skew scan
		       */

		      MAsubvc(&msg1,line_in_ref_coord,&line_in_ref_coord[3],
			      vc1);
		      py.num_points = 8;
		      py.points = points;
		      index = 12;
		}
		else		/* pointers not sent in		*/
		{
		    for (i=0; i<3; ++i)
		    {
	    		lbsys.diag_pt1[i] = vw_volume[i];
	    		lbsys.diag_pt2[i] = vw_volume[i+3];
		    }			    
		    /* 
		     * matrix to go from view to reference
		     * file world coordinates		
		     */
    		    for (i=0; i<16; ++i)	
    		    {	
        		lbsys.matrix[i] = vw_matrix[i];
    		    }
		    py.points= points;
		    MApyfrlb(msg,&lbsys,&py);
		    index = 15;
		}
	    }
    	}
    }
    else
    {
	for (i=0; i<3; ++i)
	{
	    lbsys.diag_pt1[i] = vw_volume[i];
	    lbsys.diag_pt2[i] = vw_volume[i+3];
	}	

    	for (i=0; i<16; ++i)	/* matrix to go from view to reference	*/
    	{			/* file world coordinates		*/
            lbsys.matrix[i] = vw_matrix[i];
        }

    	py.points = points;
        MApyfrlb(msg,&lbsys,&py);
	index = 15;
    }
    if ( 1 & *msg)
    {
        if ( compute_range )	/*caller requested the range be computed*/
        {
	    MApyextents(&msg1,&py,range,&range[3]);
    /****

        Added the following code to take care of the cases wherein we get
        a range rectangle instead of getting a range box in some cases due
	to the change made above with respect to vw_volume truncation --- Satya 
    ****/
	    BSEXTRACTPAR ( &msg1, BSTOLCLOSETOZERO, zerotol );
	    dx = fabs(range[3] - range[0]);
	    dy = fabs(range[4] - range[1]);
            dz = fabs(range[5] - range[2]);
            if(dx < zerotol)
            {
              range[0] = range[0] - tol;
              range[3] = range[3] + tol;
            }
            if(dy < zerotol)
            {
              range[1] = range[1] - tol;
              range[4] = range[4] + tol;
            }
            if(dz < zerotol)
            {
              range[2] = range[2] - tol;
              range[5] = range[5] + tol;
            }
	    if (clip_poly)	/* restrict range more			*/
	    {
	      /*********** Do Later ****************/
	    }
    	}

    	if (is_skew)		/* it is for a skew scan		*/
    	{
	    skew_key = (OM_S_SKEW_DESC *) range_key;

	    py.num_points = 4;	/* get skew range			*/
/*	    py.points = &points[index];
*/
	    MApyextents(&msg1,&py,skew_range,&skew_range[3]);

				/* set up skew range key		*/
	    skew_key->key.p_skew_3ddbl->range2.xmin = skew_range[0];
	    skew_key->key.p_skew_3ddbl->range2.ymin = skew_range[1];
	    skew_key->key.p_skew_3ddbl->range2.zmin = skew_range[2];
	    skew_key->key.p_skew_3ddbl->range2.xmax = skew_range[3];
	    skew_key->key.p_skew_3ddbl->range2.ymax = skew_range[4];
	    skew_key->key.p_skew_3ddbl->range2.zmax = skew_range[5];

	    skew_key->key.p_skew_3ddbl->range1.xmin = range[0];
	    skew_key->key.p_skew_3ddbl->range1.ymin = range[1];
	    skew_key->key.p_skew_3ddbl->range1.zmin = range[2];
	    skew_key->key.p_skew_3ddbl->range1.xmax = range[3];
	    skew_key->key.p_skew_3ddbl->range1.ymax = range[4];
	    skew_key->key.p_skew_3ddbl->range1.zmax = range[5];


	    if (!(pt1 && pt2))
	    {
	        vc1[0] = -vw_matrix[2];
	        vc1[1] = -vw_matrix[6];
	        vc1[2] = -vw_matrix[10];
	    }
	    else
	    {
	    	MAunitvc(&msg1,vc1,vc1);
	    }

	    skew_key->key.p_skew_3ddbl->sx = vc1[0];
	    skew_key->key.p_skew_3ddbl->sy = vc1[1];
	    skew_key->key.p_skew_3ddbl->sz = vc1[2];
    	}
    	else
    	{
	    key = (OM_p_KEY_DESC) range_key;

	    key->key.p_3ddbl->xmin = range[0];
	    key->key.p_3ddbl->ymin = range[1];
	    key->key.p_3ddbl->zmin = range[2];
	    key->key.p_3ddbl->xmax = range[3];
	    key->key.p_3ddbl->ymax = range[4];
	    key->key.p_3ddbl->zmax = range[5];
	}
    }

    return (*msg == MSSUCC);
}
