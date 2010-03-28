/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           

----
%HD%
 
     MODULE NAME	MAcpxform
 
     Abstract:
	Given a curve prism geometry and a transformation 
	matrix, the curve prism geometry is transformed.

	 
-----
%SC%
 
     VALUE = MAcpxform(message,in_cvgeom,t_matrix,out_cvgeom)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     in_cvgeom    IGRcv_prism    curve prism geometry
     t_matrix	  IGRmatrix	 the transformation matrix
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     message  	  IGRlong	 completion code 
					- MSSUCC - if successful 
					- MSFAIL - if unsuccessful
     out_cvgeom   IGRcv_prism    transformed curve prism geometry

     VALUE (IGRboolean) = TRUE		- if successful
                     = FALSE		- if failure

-----
%MD%

     MODULES INVOKED:	
			MAptsxform	
			MA3protmx	
			MAxrotmx	
			MAyrotmx	
			MAtrnmx		
			MAwclsmx	
			MAmulmx		
			
-----
%NB%

     NOTES:		

		1.) 	 Unexpected results may occur if the input
			t_matrix produces a skew effect.
-----
%CH%

     CHANGE HISTORY:
	
	MAS  05/27/87  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

	Given a curve prism geometry and a transformation 
matrix, the curve prism geometry is transformed. Three  vectors 
are formed from the curve prism geometry's matrix (X,Y and the local 
origin). The vectore are transformed using the given t_matrix and 
then sent to math routines to calculate a world to local matrix for 
the new system. Note, this method is used instead of simply 
multiplying the transformation matrix and the prism geometry matrix 
together in order to maintain orthogonality of the axes of the new 
system. The matrix to transform the input curve prism polygon must 
take points from the old local system to the new local system. This 
requires the multiplication of three matrices: (world to new local) 
X (world to world x-form) X (old local to world). In other words,
the multiplication of a form of the above matrix X t_matrix X 
in_cvgeom matrix is used to transform the prism polygon and height
element.
	The only remaining task is to include the translation to the
new origin into the output geometry matrix. This is accomplished by
inserting the X,Y and Z components of the transformed local 
coordinate system origin into the fourth column of the output geometry 
matrix.

----*/
/*EH*/
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "ma.h"
#include "msdef.h"
#include "mapriv.h"

extern    IGRboolean    MA3protmx(),MAptsxform(),MAxrotmx(),MAyrotmx();
extern    IGRboolean    MAtrnmx(),MAwclsmx(),MAmulmx();

IGRboolean MAcpxform(message,in_cvgeom,t_matrix,out_cvgeom)

	IGRlong		*message;
	struct		IGRcv_prism	*in_cvgeom;
	struct		IGRcv_prism     *out_cvgeom;
	IGRmatrix	t_matrix;
 {
	IGRdouble	*cp_x_axis,
			*cp_y_axis,
			*cp_loc_org,
			*cp_wc_org,
			array[12];

	IGRpoint	axis_buf,point;
	IGRshort	index,i;
        IGRlong         num;
	IGRmatrix	new_cp_mx, wtolmx;
	IGRmatrix	temp_mx,newlocmx;
	
	*message = MSSUCC;
/*
 * Set up X axis, Y axis vectors from the input matrix
 * And retrieve local origin in world coordinates
 */
        cp_x_axis = array;
	cp_y_axis = &array[3];
	cp_loc_org = &array[6];
	cp_wc_org = &array[9];
		
	cp_x_axis[0] = in_cvgeom->matrix[0];
	cp_x_axis[1] = in_cvgeom->matrix[4];
	cp_x_axis[2] = in_cvgeom->matrix[8];

	cp_y_axis[0] = in_cvgeom->matrix[1];
	cp_y_axis[1] = in_cvgeom->matrix[5];
	cp_y_axis[2] = in_cvgeom->matrix[9];

	cp_loc_org[0] = in_cvgeom->matrix[3];
	cp_loc_org[1] = in_cvgeom->matrix[7];
	cp_loc_org[2] = in_cvgeom->matrix[11];

	cp_wc_org[0] = 0;
	cp_wc_org[1] = 0;
	cp_wc_org[2] = 0; 			/* WORLD  ORG = [0,0,0] */
/*
 * transform these axes to the new system (in world coord)  
 */
	num = 4;				/* 4 points in array	*/
	MAptsxform(message,&num,t_matrix,array,array);

	if (*message != MSSUCC)
	{
		goto wrapup;
	}
/*
 * Build the output prism matrix by calling
 * either MA3protmx, MAxrotmx, MAyrotmx. These form
 * a world to local system - what we need is a
 * local to world.
 *
 */

	if (!MA3protmx(message,cp_wc_org,cp_x_axis,cp_y_axis,
	    new_cp_mx))
	{
/*
 * MA3protmx failed, call  MAxrotmx with the x axis
 * vector adjusted to the origin
 */
	    axis_buf[0] = cp_x_axis[0] - cp_wc_org[0];
	    axis_buf[1] = cp_x_axis[1] - cp_wc_org[1];
	    axis_buf[2] = cp_x_axis[2] - cp_wc_org[2];
	    if (!MAxrotmx(message,axis_buf,new_cp_mx))
	    {
/*
 * MAxrotmx failed, call MAyrotmx with the 
 *Y axis vector adjusted back to the origin
 *
 */
		axis_buf[0] = cp_y_axis[0] - cp_wc_org[0];
		axis_buf[1] = cp_y_axis[1] - cp_wc_org[1];
		axis_buf[2] = cp_y_axis[2] - cp_wc_org[2];
		if (!MAyrotmx(message,axis_buf,new_cp_mx))
		{
/*
 *All three methods failed. The matrix is
 *therefore arbitrary and is reset to the input matrix
 *
 */
		    *message = MSFAIL;		/* flag for transpose */
		    MAcopymtx(in_cvgeom->matrix,new_cp_mx,1);
		}	
	    }
	}
	index = 4;
	if (*message == MSSUCC)
	{
/*
 *MESSAGE = MSSUCC means one of the math routines
 *succeeded.Transpose the matrix to get a local to world 
 *matrix.
 */
	    if (!MAtrnmx(message,&index,new_cp_mx,new_cp_mx))
	    {
		goto wrapup;
	    }
	}
	*message = MSSUCC;
	if (MAwclsmx(message,cp_loc_org,new_cp_mx,wtolmx))	
	{		/*temp_mx=(world to world) X (loc to world)*/
	    if (MAmulmx(message,&index,&index,&index,t_matrix,
		    in_cvgeom->matrix,temp_mx))		
	    {		/* newlocmx takes points from old local system */
		if (MAmulmx(message,&index,&index,&index,	
			    wtolmx,temp_mx,newlocmx))			
		{
		    if (in_cvgeom->curve.rational)
		    {
  		       point[0] = in_cvgeom->curve.poles[0]/
				in_cvgeom->curve.weights[0];	
		       point[1] = in_cvgeom->curve.poles[1] /
				in_cvgeom->curve.weights[0];	
		       point[2] = in_cvgeom->height;			
		    }
		    else
		    {
  		       point[0] = in_cvgeom->curve.poles[0];
		       point[1] = in_cvgeom->curve.poles[1];
		       point[2] = in_cvgeom->height;			
		    }			
		    num = 1;
		    if (MAptsxform(message,&num,newlocmx,point,point))
		    {
			out_cvgeom->height =  point[2];		

			if (MArptsxform(message,
				&in_cvgeom->curve.num_poles,
				&in_cvgeom->curve.rational,
				in_cvgeom->curve.weights,
				newlocmx,in_cvgeom->curve.poles,
                                out_cvgeom->curve.poles))
			{
			    MAcopymtx(new_cp_mx,out_cvgeom->matrix,1);
/*
 * Insert origin translation into new prism matrix
 */
			    out_cvgeom->matrix[3] = cp_loc_org[0];
			    out_cvgeom->matrix[7] = cp_loc_org[1];
			    out_cvgeom->matrix[11] = cp_loc_org[2];

  			    out_cvgeom->curve.num_poles = 
			    	in_cvgeom->curve.num_poles;
  			    out_cvgeom->curve.num_knots = 
			    	in_cvgeom->curve.num_knots;
  			    out_cvgeom->curve.planar = 
			    	in_cvgeom->curve.planar;
  			    out_cvgeom->curve.periodic = 
			    	in_cvgeom->curve.periodic;
  			    out_cvgeom->curve.order = 
			    	in_cvgeom->curve.order;
  			    out_cvgeom->curve.rational = 
			    	in_cvgeom->curve.rational;
  			    out_cvgeom->curve.non_uniform = 
			    	in_cvgeom->curve.non_uniform;
  			    out_cvgeom->curve.phy_closed = 
			    	in_cvgeom->curve.phy_closed;
  			    out_cvgeom->curve.num_boundaries = 
			    	in_cvgeom->curve.num_boundaries;

			    for (i=0; i<out_cvgeom->curve.num_knots; ++i)
			    {
  			        out_cvgeom->curve.knots[i] = 
			    	    in_cvgeom->curve.knots[i];
			    }
			    if (out_cvgeom->curve.rational)
			    {
			        for (i=0;i<out_cvgeom->curve.num_poles;++i)
			        {
  			            out_cvgeom->curve.weights[i] = 
			    	        in_cvgeom->curve.weights[i];
				}
			    }
			    for (i=0; 
				i < out_cvgeom->curve.num_boundaries * 2; 
				++i)
			    {
  			        out_cvgeom->curve.bdrys[i] = 
			    	    in_cvgeom->curve.bdrys[i];
			    }
			}
 		    }
	        }
	    }
	}
wrapup:
	return	(*message == MSSUCC);
}
