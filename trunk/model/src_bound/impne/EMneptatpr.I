/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method calculates a UV point at a given parameter value on the
  edge. The point returned is 2D. The parameter passed is in the
  span_index-parameter format or the baparam format.For the natural edge
  both the formats are same since the span index is 0. So if a bsparam
  is passed, it is still interpreted as a parameter with span index 0.
  In simple English there is no difference between the two.

				
History
	SM	02/26/87   Creation date

*/

class implementation EMSnatedge;

#include "emsmacros.h"

method EMptatpr(IGRlong *EMmsg;IGRint num_param;struct EMSedgebound *param;
		IGRdouble *bs_param;IGRdouble *point)
{
	IGRlong		sts,i,j;
	IGRdouble	points[4],val;
	void		EMnatpoints();

   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;

 if(param&&bs_param){*EMmsg=EMS_E_InvalidArg;goto wrapup;}
  
/* Get my points
*/
	EMnatpoints(EMmsg,ME.EMSnatedge->location & 0x3,points);
        if(!(1&*EMmsg&sts)) goto wrapup;

 j=0;
 for(i=0;i<num_param;i++)
  {
	if(bs_param) val = bs_param[i];
	else val = param[i].param;

/* Calculate the point at the given parameter value
*/
   	point[j++] = points[0] + val * (points[2] - points[0]);
   	point[j++] = points[1] + val * (points[3] - points[1]);
   }
wrapup:
  EMWRAPUP(*EMmsg,sts,"In EMSnatedge.EMptatpr")
  return(sts);
}

end implementation EMSnatedge;
