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

class implementation EMSnatedge;

#include "emsdef.h"
#include "emsmacros.h"

method EMgetrange(IGRlong *EMmsg; IGRdouble *range;
		  struct EMSpartedinfo *bnd)
{
	IGRlong			sts;
	struct IGRpolyline	actgeom;
	IGRdouble		points[4];
	void			EMnatpoints(),EM2dbx();

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  actgeom.num_points = 0;
  actgeom.points = points;

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
     EMnatpoints(EMmsg,(ME.EMSnatedge->location & 0x3),points);
     if(!(1&*EMmsg&sts)) goto wrapup;
     EM2dbx(2,points,range);
   }

wrapup:
   EMWRAPUP(*EMmsg,sts,"In EMSnatedge.EMgetrange")
   return(sts);
}

end implementation EMSnatedge;
