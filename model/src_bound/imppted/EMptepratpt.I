/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	Always return 0 as the param.
	If point is not within tolerance from the stored point, return
	off edge.
History
	SM	23-Oct-87	Genesis
*/
class implementation EMSptedge;

#include "EMS.h"
#include "emsmacros.h"
#include "bsparameters.h"

method EMpratpt(IGRlong *EMmsg; 
                IGRdouble *points; 
		IGRint num_points;
		struct EMSedgebound *param;
		IGRboolean *off_edge;
		struct EMSpartedinfo *bnd;
		struct EMSpartolbasis *partolbasis)
{
  IGRint		sts,i,idx, rc;
  IGRdouble		partollenvec;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  if(!partolbasis->is_valid)
   {
     sts = om$send(msg=message EMSboundary.EMgetsurface_info
				(EMmsg,NULL,partolbasis),targetid=my_id);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
   }
  sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&partollenvec,&rc);

  for(i=0, idx=0; i<num_points; i++, idx+=2)
   { 
     param[i].span_inx = 0;
     param[i].param = 0;
     if(EM2ddistptpt(ME.EMSptedge->point, &points[idx]) > partollenvec)
        off_edge[i] = TRUE;
     else off_edge[i] = FALSE;
 }

wrapup:

  if(1&*EMmsg&sts) *EMmsg = EMS_I_DegenerateEdge;

  EMWRAPUP(*EMmsg,sts,"In EMSptedge.EMpratpt")
  return (sts);
}

end implementation EMSptedge;
