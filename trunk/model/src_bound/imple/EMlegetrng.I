/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method returns the min max box of an edge. The min max box
  is 2D. If valid boundary is passed, the box is wrt the active part of the
  edge(defined by the boundary). If NULL is passed for the boundary then
  the box is wrt the whole edge.

Algorithm
	If boundary is passed extract the geometry and find the range box
  else find the range box of my entire geometry.

History
	SM	03/03/87	Creation date
*/

class implementation EMSlinedge;

#include "EMS.h"
#include "emsdef.h"
#include "emsmacros.h"

#define	POINTS_BUF	100
#define NUM_POINTS_BUF	50

method EMgetrange(IGRlong *EMmsg; IGRdouble *range;
		  struct EMSpartedinfo *bnd)
{
	IGRlong			sts,num_points;
	struct IGRpolyline	actgeom;
	void			EM2dbx();
	IGRdouble		points[POINTS_BUF];

  if(ME.EMSlinedge->num_points > NUM_POINTS_BUF)
   actgeom.points = NULL;
  else actgeom.points = (IGRdouble *) points;

  actgeom.num_points = 0;

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if(bnd)
   {
     sts = om$send(msg=message EMSedge.EMgetpygeom
			(EMmsg,0,MAXINT,FALSE,bnd,&actgeom, NULL, NULL),
		 	targetid = my_id);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EM2dbx(actgeom.num_points,actgeom.points,range);
   }
  else
   {
     num_points = (IGRlong) ME.EMSlinedge->num_points;
     EM2dbx(num_points,ME.EMSlinedge->points,range);
   }

wrapup:
   if(actgeom.points && (actgeom.points != points)) 
    om$dealloc(ptr = actgeom.points);
   EMWRAPUP(*EMmsg,sts,"In EMSlinedge.EMgetrng")
   return(sts);
}
end implementation EMSlinedge;
