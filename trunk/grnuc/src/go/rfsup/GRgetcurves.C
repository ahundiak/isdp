/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "gocmacros.h"
#include "msdef.h"

IGRboolean GRgetcurves(msg,curve,how_many,curve_ptr_array)

IGRlong		*msg;
struct IGRbsp_curve *curve;
IGRlong		*how_many;
struct IGRbsp_curve **curve_ptr_array;
{
    IGRchar	*ptr;

    IGRlong	nbytes,
		i,
/*		size,	*/
		tot_nbytes;

    *msg = MSSUCC;
    i = curve->num_poles + curve->order * 2 - 1;

					/* compute size to allocate	*/
    GRbc_size(curve->order,i,curve->rational,curve->num_boundaries,nbytes)

    nbytes += 16;	 		/* allow for alignment		*/

	
    tot_nbytes = nbytes *  *how_many;    
					/* allocate for new curves	*/
    ptr = (IGRchar *)om$malloc(size = tot_nbytes);

    if (ptr)
    {
       	*curve_ptr_array = (struct IGRbsp_curve *)ptr;
       	GRbc_partition(*curve_ptr_array,curve->order,
   		(curve->num_poles+curve->order),
	 	curve->rational,curve->num_boundaries);

					/* assign curves		*/
    	for (i=1; i<*how_many; ++i)
    	{
            curve_ptr_array[i] = (struct IGRbsp_curve *)
	    	(GRalign_quad( (IGRchar *) 
		((IGRlong)curve_ptr_array[i-1] + nbytes)));
    	    GRbc_partition(curve_ptr_array[i],curve->order,
		(curve->num_poles+curve->order),
		   curve->rational,curve->num_boundaries);
	}	
    }
    else
    {
	*msg = MSFAIL;
    }

    return(*msg == MSSUCC);
}
