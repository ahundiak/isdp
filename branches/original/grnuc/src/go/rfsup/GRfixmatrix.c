/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "msdef.h"
#include "madef.h"

#define TWO_DIM_TRANSLATION 1
#define TRANSLATION 5

extern    IGRboolean    MAgrmscht();

GRfixmatrix(msg,in_type,matrix,out_matrix,out_type)

IGRlong 	*msg;
IGRshort 	*in_type;
IGRmatrix 	matrix;
IGRmatrix	out_matrix;
IGRshort	*out_type;
{
    IGRlong	j,i;

    IGRdouble   vectors[9], o_vectors[9],
		pts[6],dist;

    IGRshort	rank,
		num;

    *msg = MSSUCC;

/*  This routine will
 *  turn a non-uniform scale matrix into a uniform scale matrix.
 */

    if ((*in_type == MAIDMX) || (*in_type == TWO_DIM_TRANSLATION)
	|| (*in_type == TRANSLATION))
    {
	*out_type = *in_type;
	for (i = 0; i < 16; ++i)
	{
	    out_matrix[i] = matrix[i];
	}
	goto wrapup;
    }
    for (i=0,j=0; i<9; i+=3 )
    {
 	vectors[i] = matrix[j];
 	vectors[i+1] = matrix[j+1];
 	vectors[i+2] = matrix[j+2];
	j += 4;
    }	     

    num = 3;

    if (!MAgrmscht (msg, &num, &num, vectors, o_vectors, &rank))
    {
	goto wrapup;
    }
    for (i=0,j=0; i<12; i+=4 )
    {
 	out_matrix[i] = o_vectors[j];
 	out_matrix[i+1] = o_vectors[j+1];
 	out_matrix[i+2] = o_vectors[j+2];
	out_matrix[i+3] = 0.0;
	j += 3;
    }	     
    out_matrix[12] = 0.0;
    out_matrix[13] = 0.0;
    out_matrix[14] = 0.0;
    out_matrix[15] = 1.0;
    
    /* To compute a uniform factor to use as the scale factor
     * do the following:
     * Use 2 points of unit distance apart. Transform them using
     * the input matrix.  Compute the distance between the 2 transformed
     * points.  This is the scale factor to be used in the new
     * matrix.
     */
    
    pts[0] = 0.0;
    pts[1] = 0.0;
    pts[2] = 0.0;

    pts[3] = 1.0;
    pts[4] = 0.0;
    pts[5] = 0.0;
    i = 2;
    MAptsxform(msg,&i,matrix,pts,pts);	
    MA2ptdis(msg,pts,&pts[3],&dist);
    num = 4;
    MAscalmx(msg,&num,&num,&dist,out_matrix,out_matrix);

    /* Load in the translation of the original matrix and the 
     * bottom row.
     */
    
    out_matrix[3] = matrix[3];
    out_matrix[7] = matrix[7];
    out_matrix[11] = matrix[11];
    
    out_matrix[12] = matrix[12];
    out_matrix[13] = matrix[13];
    out_matrix[14] = matrix[14];
    out_matrix[15] = matrix[15];

    MAtypemx(msg,out_matrix,out_type);
 
wrapup:
    return(1 & *msg);

}
