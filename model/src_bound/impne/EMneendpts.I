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
class implementation EMSnatedge;

#include "OMmacros.h"
#include "emsmacros.h"

#define X 0
#define Y 1

method EMendpts (IGRlong *EMmsg; 
		 IGRdouble *begin_pt,*end_pt;
		 struct EMSedgebound *begin_param,*end_param;
		    struct EMSpartedinfo *bnd)
{
  IGRint		sts,size,j,num_points,i;
  IGRdouble		endpt[4],points[4];
  void			EMnatpoints();

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  size = 2*sizeof(IGRdouble);

/* Get my points
*/
  EMnatpoints(EMmsg,ME.EMSnatedge->location & 0x3,points);
  if(!(1&*EMmsg)) goto wrapup;
  num_points = 2;
  if(begin_param)begin_param->span_inx = 0;
  if(end_param)  end_param->span_inx = 0;
  if (bnd)
    {
/* If there is a boundary passed in, then evaluate the two parameters to
   get the end points
*/
      j=0;
      for(i=0;i<2;i++)
       {
/* Calculate the point at the given parameter value
*/
       	endpt[j++] = points[0] + bnd->edbdry[i].param* (points[2] - points[0]);
   	endpt[j++] = points[1] + bnd->edbdry[i].param* (points[3] - points[1]);
        }
      if (begin_pt)
        OM_BLOCK_MOVE(endpt,begin_pt,size);
      if (end_pt)
        OM_BLOCK_MOVE(&endpt[2],end_pt,size);
      if(begin_param)*begin_param = bnd->edbdry[0];
      if(end_param)*end_param = bnd->edbdry[1];
    }
  else
    {
      if( ME.EMSedge->ed_props & EMED_REVERSED)
	{
          if (begin_pt)
            OM_BLOCK_MOVE(&points[2],begin_pt,size);
          if (end_pt)	  
            OM_BLOCK_MOVE(points,end_pt,size);
	  if(begin_param)begin_param->param = 1.0;
	  if(end_param)end_param->param = 0;
	}
      else
	{
          if (end_pt)
            OM_BLOCK_MOVE(&points[2],end_pt,size);
          if (begin_pt)
            OM_BLOCK_MOVE(points,begin_pt,size);
	  if(begin_param)begin_param->param = 0;
	  if(end_param)end_param->param = 1.0;
	}
    }
         

wrapup:
  EMWRAPUP(*EMmsg,sts,"In EMSnatedge.EMendpts")
  return (sts);
}

end implementation EMSnatedge;
