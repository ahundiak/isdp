/* #######################    APOGEE COMPILED   ######################## */
#include "msdef.h"
#include "igrtypedef.h"

/* prototype files */
#include "DPdyplane.h"  /* defining file */
#include "maptsxfor.h"

DPdyplane ( msg, radius, distance, pts, matrix)

IGRlong 	*msg;
IGRdouble	radius;
IGRdouble 	distance;
IGRdouble	*pts; /* array of 5 points */
IGRdouble	*matrix;

{
IGRlong	status = TRUE;
IGRlong num_pts = 4;

        pts[0] = - radius;
        pts[1] = - radius;
        pts[2] = distance;

    	pts[3] = - radius;
    	pts[4] = radius;
   	pts[5] =  distance;

    	pts[6] =  radius;
    	pts[7] = radius;
    	pts[8] =  distance;

    	pts[9] =  radius;
    	pts[10] = - radius;
    	pts[11] = distance;

	status = MAptsxform (msg, &num_pts,matrix,pts,pts);

	pts[12] = pts[0];
        pts[13] = pts[1];
        pts[14] = pts[2];

return (status);
}
