/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	For point edge both end points are considered to be same.
	
History
	SM	23-Oct-87	Genesis
*/
class implementation EMSptedge;

#include "EMS.h"
#include "OMmacros.h"
#include "emsmacros.h"


method EMendpts (IGRlong *EMmsg; 
		 IGRdouble *begin_pt,*end_pt;
		 struct EMSedgebound *begin_param,*end_param;
		    struct EMSpartedinfo *bnd)
{
  IGRint		sts,size;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;


  size = 2*sizeof(IGRdouble);

  if (begin_pt)
    OM_BLOCK_MOVE(ME.EMSptedge->point,begin_pt,size);

  if (end_pt)
    OM_BLOCK_MOVE(ME.EMSptedge->point,end_pt,size);

  if(end_param)
   {
     end_param->span_inx = 0;
     end_param->param = 0;
   }

  if(begin_param)
   {
     begin_param->span_inx = 0;
     begin_param->param = 0;
   }

wrapup:

  *EMmsg = EMS_I_DegenerateEdge;

  EMWRAPUP(*EMmsg,sts,"In EMSptedge.EMendpts")
  return (sts);
}

end implementation EMSptedge;
