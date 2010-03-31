/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlinedge;

#include "EMS.h"
#include "bserr.h"
#include "OMmacros.h"
#include "emsmacros.h"

/*
 * History
 *                 PP : 23/05/87  Made changes in the manner in which the knot
 *                                vector was being calculated
 */

method EMbstobnd(IGRlong *EMmsg;IGRint num_param;
		IGRdouble  *bs_param;
		struct EMSedgebound *bnd_param)
{
	IGRlong			sts,i;
        IGRshort		j;
	IGRdouble		knot, knot_increment;
	struct IGRpolyline	bspoly;
	struct EMSpypoint 	pyspace,*pyptr;


   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;

   bspoly.points = NULL;
   bspoly.num_points = 0;
   pyptr = &pyspace;
   knot = 0.0;

/* Generate my knot vector and put it into the polyline structure
   for EMcnvtpypoints().
*/ 
  
     bspoly.num_points = ME.EMSlinedge->num_points;
     bspoly.points = (IGRdouble *) om$malloc(size=sizeof(IGRdouble)*
				ME.EMSlinedge->num_points);
     EMerr_hndlr(!bspoly.points,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);

     knot_increment = 1.0 / (ME.EMSlinedge->num_points - 1);

     for (i=0 ; i < ME.EMSlinedge->num_points; i++)
     {
      bspoly.points[i] = knot;
      knot += knot_increment;
     }


 for(i=0;i<num_param;i++)
  {
   for (j=0 ; j < bspoly.num_points - 1; j++)
     {
       if (((bs_param[i] - bspoly.points[j]) >= 0 ) &&
           ((bs_param[i] - bspoly.points[j+1]) <= 0 ))
       {
	bnd_param[i].span_inx = j;
	bnd_param[i].param  = (bs_param[i] - bspoly.points[j]) /
                               knot_increment; 
       }
     }
   }

wrapup:
  if(bspoly.points) om$dealloc(ptr=bspoly.points);
  EMWRAPUP(*EMmsg,sts,"In EMSlinedge.EMbstobnd")
  return(sts);
}

end implementation EMSlinedge;
