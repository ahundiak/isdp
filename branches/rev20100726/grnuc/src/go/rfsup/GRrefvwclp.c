/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "bserr.h"
#include "msdef.h"

IGRlong GRrefvwclp(msg,lbsys,cv_prism,intersect,out_cvprism)

IGRlong 	*msg;
struct IGRlbsys *lbsys;
struct IGRcv_prism *cv_prism;
IGRboolean 	*intersect;
struct IGRcv_prism *out_cvprism;

{

    IGRlong i;			/* loop index			*/
    struct IGRrt_prism rt_prism,out_rtprism;

    *msg = MSSUCC;

    if ((cv_prism->curve.order == 2) && (!cv_prism->curve.rational))
    {
        rt_prism.polygon.points = cv_prism->curve.poles;
        rt_prism.polygon.num_points = cv_prism->curve.num_poles;
        rt_prism.height = cv_prism->height;
        for (i=0; i<16; ++i)
    	{
	    rt_prism.matrix[i] = cv_prism->matrix[i];
    	}	   

    	out_rtprism.polygon.points = out_cvprism->curve.poles;

    	BSrefvwclp(lbsys,&rt_prism,intersect,&out_rtprism,msg);

    	if (*msg == BSSUCC)
    	{
					/* assign info to curve prism	*/
            for (i=0; i<16; ++i)
            {
           	out_cvprism->matrix[i] = out_rtprism.matrix[i];
       	    }

       	    out_cvprism->height = out_rtprism.height;
					/* convert polyline to curve	*/
       	    MApytobc(msg,&out_rtprism.polygon,&out_cvprism->curve);
    	}
    }
    else				/* can't handle this case yet	*/
    {
	*msg = MSINARG;
    }


    return( 1 & *msg );
}
