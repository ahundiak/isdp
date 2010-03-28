/* #######################    APOGEE COMPILED   ######################## */
/*  
 *  temporary function for debugging.


 *  This macro partitions a contiguous array of memory (starting at a 
 *  B-spline curve structure) so that the structure is immediately 
 *  followed by the curve's poles, knots, weights, and boundary points.
 *
 *  struct IGRbsp_curve *curve   - curve data structure
 *  IGRshort   order		- order of curve
 *  IGRlong    num_poles	- number of poles
 *  IGRboolean rational		- rational curve indicator
 *  IGRshort   num_boundaries	- number of curve boundaries
 *
 */

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"

IGRlong  GRbc_part(curve,order,num_poles,rational,num_boundaries)	

struct IGRbsp_curve *curve;	/*   - curve data structure	*/
IGRlong    num_poles;		/*   - number of poles		*/
IGRboolean rational;		/*   - rational curve indicator	*/
IGRshort   num_boundaries;	/*  - number of curve boundaries*/

{
	(curve)->poles = (IGRdouble *) ((curve) + 1);		
	(curve)->knots = &(curve)->poles[3 * (num_poles)];		
	if ((rational))							
	{								
	  (curve)->weights = &(curve)->knots[(num_poles) + (order)];	
	  if ((num_boundaries))						
	  {								
	    (curve)->bdrys = &(curve)->weights[(num_poles)];		
	  }								
	}								
	else if ((num_boundaries))					
	{								
	  (curve)->bdrys = &(curve)->knots[(num_poles) + (order)];	
	}
       
    return(1);
  }
