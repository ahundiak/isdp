/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method calculates a UV point at a given parameter value on the
  edge. The point returned is 2D. The parameter passed is either in the
  span_index-parameter format or in the bspline parameter format.

Assumption
	The liner edge is made up of 'spans' between a pair of its points and
  each span is parametrized from 0 to 1.

History
	SM	02/26/87   Creation date
        Sudha   07/06/93        modified for BSprototype includes

*/

class implementation EMSlinedge;

#include "EMS.h"
#include "bserr.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "bschrdlkts.h"

#define PolesBuf	90
#define MaxPoles	30
#define PtsBuf		300
#define MaxPts		150
#define KnotsBuf	100
#define MaxKnots	100

method EMptatpr(IGRlong *EMmsg;IGRint num_param;struct EMSedgebound *edparam;
		IGRdouble  *bs_param;
		IGRdouble *point)
{
 IGRlong		sts,i,j,rc;
 IGRdouble		*point1 = NULL, *point2 = NULL, param, *knots = NULL;
 IGRshort		span_inx;
 struct IGRpolyline	bspoly;
 struct EMSpypoint 	pyspace, *pyptr = NULL;
 IGRdouble		polesbuff[PolesBuf], *poles = NULL, ptsbuff[PtsBuf], 
			knotbuff[KnotsBuf];
	
   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;

   bspoly.points = NULL;
   bspoly.num_points = 0;
   pyptr = &pyspace;

   if(bs_param&&edparam) {*EMmsg=EMS_E_InvalidArg;goto wrapup;}
 
/* If a bspline parameter(which is wrt the entire curve) is passed
   then it will have to be converted into the span_inx - param,
   format. For this the generation of knot vector is necesary.
*/
  if(bs_param)   
   {
     IGRlong	num_poles;
     IGRshort	order;
     IGRboolean periodic=FALSE;
  
     bspoly.num_points = ME.EMSlinedge->num_points;
     if(bspoly.num_points <= MaxPts)
      bspoly.points = (IGRdouble *) ptsbuff;
     else
      bspoly.points = (IGRdouble *) om$malloc(size=sizeof(IGRdouble)*
				ME.EMSlinedge->num_points);
     EMerr_hndlr(!bspoly.points,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);

     if(ME.EMSlinedge->num_points + 2 < MaxKnots)
      knots = (IGRdouble *) knotbuff;
     else
      knots = (IGRdouble *) om$malloc(size=sizeof(IGRdouble)*
				(ME.EMSlinedge->num_points + 2));
     EMerr_hndlr(!knots,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);

     num_poles = (IGRlong) ME.EMSlinedge->num_points;
     order = 2;
     if(num_poles <= MaxPoles) poles = (IGRdouble *) polesbuff;
     else
	poles = (IGRdouble *) om$malloc(size = num_poles * 3 * 
					sizeof(IGRdouble));
     EMerr_hndlr(!poles, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

     (void)EM2dto3d(ME.EMSlinedge->points, num_poles, poles);
		
     sts = BSchrdlkts(&rc, &num_poles, poles, &order, &periodic, knots);
     if(!sts){*EMmsg=EMS_E_EdgeError;sts=OM_S_SUCCESS;goto wrapup;}
     if(rc!=BSSUCC){*EMmsg=EMS_E_EdgeError;sts=OM_S_SUCCESS;goto wrapup;}
	
     OM_BLOCK_MOVE(&knots[1],bspoly.points,sizeof(IGRdouble)*
				num_poles);
   }

 j=0;
 for(i=0;i<num_param;i++)
  {
    if(edparam)
     {
       span_inx = edparam[i].span_inx;
       param = edparam[i].param;
     }
    else if(bs_param)
     {
      IGRdouble mindist;
     /* Get the span in the knot vector on which the input bsparam lies.
        Since degenerate span in the knot vector does not make any difference
        zero tolerance is passed in to EMcnvtpypts().
     */
     EMcnvtpypts(EMmsg,&bspoly,1,1,&bs_param[i],0.0, pyptr,&mindist);
     EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
     span_inx = pyptr->span_inx;
     param = pyptr->param;
     }

/* get the end points of the span
*/
   point1 = &ME.EMSlinedge->points[2*span_inx];
   point2 = &ME.EMSlinedge->points[2*span_inx + 2];

/* Calculate the point at the given parameter value
*/
   point[j++] = point1[0] + param * (point2[0] - point1[0]);
   point[j++] = point1[1] + param * (point2[1] - point1[1]);
 }
wrapup:
  if(knots && (knots != knotbuff)) om$dealloc(ptr=knots);
  if(bspoly.points && (bspoly.points != ptsbuff)) 
		om$dealloc(ptr=bspoly.points);
  if(poles && (poles != polesbuff)) om$dealloc(ptr = poles);

  EMWRAPUP(*EMmsg,sts,"In EMSlinedge.EMptatpr")
  return(sts);
}

end implementation EMSlinedge;
