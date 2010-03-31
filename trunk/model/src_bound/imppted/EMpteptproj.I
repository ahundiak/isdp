/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method projects an input point onto an edge. The input point
   is in parametric space (2D)
   The information returned is the projected point (2D) on the edge, the
   minimum distance to the edge and the edge param of the point on the
   edge(in the format span index-parameter pair).

Return Values

	EMmsg			EMS_I_DegenerateEdge
	
History
	SM	22-Oct-87    1.1 Genesis
*/
class implementation EMSptedge;

#include "EMS.h"
#include "OMmacros.h"
#include "emsmacros.h"
%safe
#include <math.h>
%endsafe
#include "emsinter.h"

method EMptproject (IGRlong *EMmsg; 
                    IGRdouble *point; 
		    IGRint num_points;
		    struct EMSproj_info *proj_info;
		    struct EMSpartedinfo *bnd;
		    struct EMSpartolbasis *partolbasis)
{
  IGRint		sts, size, i;
  IGRdouble		distsq;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  size = 2 * sizeof(IGRdouble);

  for(i=0; i< 2 * num_points; i+=2)
   {
     OM_BLOCK_MOVE(ME.EMSptedge->point, proj_info[i].proj_pt, size);
     distsq = EM2ddistptpts(ME.EMSptedge->point, &point[i]);
     proj_info[i].dist = sqrt(distsq);
     proj_info[i].param.span_inx = 0;
     proj_info[i].param.param = 0.0;
     proj_info[i].location = EMScvint_collapsed;
   }

wrapup:

  *EMmsg = EMS_I_DegenerateEdge;

  EMWRAPUP(*EMmsg,sts,"In EMSptedge.EMptproject")
  return (sts);
}

end implementation EMSptedge;
