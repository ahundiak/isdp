/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method convertes an EMSedgebound parameter for an edge into
a bsparameter(based on the entire linestring being parametrized from 0
to 1).

History
	SM	03/23/87	Creation Date.
	Sudha	07/06/93	modified for BSprototype includes
*/

class implementation EMSlinedge;

#define POLES_BUF_3D	90

#include "bserr.h"
#include "emsmacros.h"
#include "EMS.h"
#include "bschrdlkts.h"

method EMbndtobs(IGRlong *EMmsg;IGRint num_param;
		struct EMSedgebound *bnd_param;
		IGRdouble  *bs_param)
{
	IGRlong			sts,i,rc,idx;
	IGRdouble		*knots, *pts;
	IGRdouble		poles_buf[POLES_BUF_3D], *poles;
	
   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;

   knots = NULL;
   poles = NULL;

/* Get my knot vector
*/
   {
     IGRlong	num_poles;
     IGRshort	order;
     IGRboolean periodic=FALSE;
  
     knots = (IGRdouble *) om$malloc(size=sizeof(IGRdouble)*
				(ME.EMSlinedge->num_points + 2));
     EMerr_hndlr(!knots,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
     num_poles = (IGRlong) ME.EMSlinedge->num_points;
     order = 2;
     if(num_poles * 3 > POLES_BUF_3D)
	poles = (IGRdouble *) om$malloc(size = num_poles * 3 * 
					sizeof(IGRdouble));
     else poles = (IGRdouble *) poles_buf;
     EMerr_hndlr(!poles, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

     (void)EM2dto3d(ME.EMSlinedge->points, num_poles, poles);
     sts = BSchrdlkts(&rc,&num_poles, poles, &order, &periodic, knots);
     if(!sts){*EMmsg=EMS_E_EdgeError;sts=OM_S_SUCCESS;goto wrapup;}
     if(rc!=BSSUCC){*EMmsg=EMS_E_EdgeError;sts=OM_S_SUCCESS;goto wrapup;}
   }

 pts = &knots[1];
 for(i=0;i<num_param;i++)
  {
    idx = bnd_param[i].span_inx;
    bs_param[i] = pts[idx] + bnd_param[i].param * (pts[idx+1]-pts[idx]);    
  }

wrapup:
  if(knots) om$dealloc(ptr=knots);
  if(poles && (poles != poles_buf)) om$dealloc(ptr = poles);

  EMWRAPUP(*EMmsg,sts,"In EMSlinedge.EMbndtobs")
  return(sts);
}

end implementation EMSlinedge;
