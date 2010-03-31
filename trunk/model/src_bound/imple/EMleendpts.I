/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method returns the begin and the end point of an edge in
  parametric space(2D). If NULL is passed for the boundary, then the endpts
  are wrt the whole edge. Otherwise the input boundary is applied and the
  endpts are wrt the active part of the edge.

History
	SM	02/26/87    creation date
*/
class implementation EMSlinedge;

#include "EMS.h"
#include "OMmacros.h"
#include "emsmacros.h"

#define X 0
#define Y 1

method EMendpts (IGRlong *EMmsg; 
		 IGRdouble *begin_pt,*end_pt;
		 struct EMSedgebound *begin_param,*end_param;
		    struct EMSpartedinfo *bnd)
{
  IGRint		sts,size,pt_inx1,pt_inx2,i,j;
  IGRdouble		point[4],*point1,*point2;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;


  size = 2*sizeof(IGRdouble);

  if (bnd)
    {
/* If there is a boundary passed in, then evaluate the two parameters to
   get the end points
*/
      j=0;
      for(i=0;i<2;i++)
       {

/* Find the point indices of the begin and end points of the span
*/   
          pt_inx1 = bnd->edbdry[i].span_inx + 1;
          pt_inx2 = pt_inx1 + 1;

/* get the end points
*/
          point1 = &ME.EMSlinedge->points[2*pt_inx1 -2];
          point2 = &ME.EMSlinedge->points[2*pt_inx2 -2];

/* Calculate the end point at the given parameter value
*/
         point[j++] = point1[0] + bnd->edbdry[i].param*(point2[0] - point1[0]);
         point[j++] = point1[1] + bnd->edbdry[i].param*(point2[1] - point1[1]);
       }
      if (begin_pt)
        OM_BLOCK_MOVE(point,begin_pt,size);
      if (end_pt)
        OM_BLOCK_MOVE(&point[2],end_pt,size);
      if(begin_param) *begin_param = bnd->edbdry[0];
      if(end_param)*end_param = bnd->edbdry[1];
    }
  else
    {
      if( ME.EMSedge->ed_props & EMED_REVERSED)
	{
          if (begin_pt)
	   OM_BLOCK_MOVE(&ME.EMSlinedge->points[2*ME.EMSlinedge->num_points-2],
			begin_pt,size);
          if (end_pt)
	   OM_BLOCK_MOVE(ME.EMSlinedge->points,end_pt,size);
	  if(begin_param)
	   {
	     begin_param->span_inx = ME.EMSlinedge->num_points - 2;
	     begin_param->param = 1.0;
  	   }
	  if(end_param)
	   {
	     end_param->span_inx = 0;
	     end_param->param = 0;
	   }
	}
      else
	{
	  if(end_pt)
	   OM_BLOCK_MOVE(&ME.EMSlinedge->points[2*ME.EMSlinedge->num_points-2],
			end_pt,size);
	  if(begin_pt)
	   OM_BLOCK_MOVE(ME.EMSlinedge->points,begin_pt,size);
	  if(begin_param)
	   {
	     begin_param->span_inx = 0;
	     begin_param->param = 0;
	   }
	  if(end_param)
	   {
	     end_param->span_inx = ME.EMSlinedge->num_points - 2;
	     end_param->param = 1.0;
	   }
	}
    }
         

wrapup:
  EMWRAPUP(*EMmsg,sts,"In EMSlinedge.EMendpts")
  return (sts);
}

end implementation EMSlinedge;
