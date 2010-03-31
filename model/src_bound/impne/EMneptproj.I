/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method projects an input point onto an edge. The input point
   is in parametric space(2D).
   The information returned is the projected point (2D) on the edge, the
   minimum distance to the edge and the edge param of the point on the
   edge(in the format span index-parameter pair).

History
	SM	02/26/87    creation date
	SM	02-Nov-87   Modified to return the position of projected
			    point on the edge.
	SS	20-Jan-89   Modified to initialize tangent vector in the
			    project-info structure.
*/

class implementation EMSnatedge;

#include "bsparameters.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "emsmacros.h"
#include "OMmacros.h"

#define U 0
#define V 1

#define FIRST  0
#define SECOND 1
#define THIRD  2
#define FOURTH 3

method EMptproject (IGRlong *EMmsg; 
                    IGRdouble *point;
		    IGRint num_points;
		    struct EMSproj_info *proj_info;
		    struct EMSpartedinfo *bnd;
		    struct EMSpartolbasis *partolbasis)
{
  IGRshort		loc,inx;
  IGRint		sts,i,idx;
  IGRlong		minptinx,rc;
  struct EMSpypoint 	*pyprojpt,pyspace;
  struct IGRpolyline	actgeom;
  void			EMcnvtpypts(),EMnatpoints(),EMcnvtedpar();
  IGRdouble		mindist,*minseg,points[4],partollenvec, *ptr;
  IGRboolean		EFextract_par();
  struct EMSedgebound	cnvt;
  IGRboolean		degenerate_edge = FALSE,  /* Partedge on a natural
						    edge can be degenerate.
						 */
			ambiguous_case = FALSE, 
			reversed = FALSE;
			
  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  if(!partolbasis->is_valid)
   {
     sts = om$send(msg=message EMSboundary.EMgetsurface_info
				(EMmsg,NULL,partolbasis),targetid=my_id);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
   }
  sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&partollenvec,&rc);

  actgeom.points = points;
  actgeom.num_points = 0;

/* If boundary has been passed in, then extract the active part of
   my geometry. Otherwise use the entire geometry.
*/
  if (bnd)
    {
      reversed = bnd->edprops & EMED_REVERSED;
      sts = om$send (msg = message EMSedge.EMgetpygeom
               (EMmsg,0,MAXINT,reversed ? TRUE : FALSE,
		bnd,&actgeom, partolbasis, NULL), 
               targetid = my_id);
      if(!(1&*EMmsg&sts)) goto wrapup;
    }
  else
    {
/* Decide my points
*/
       EMnatpoints(EMmsg,ME.EMSnatedge->location & 0x3,points);
       if(!(1&*EMmsg)) goto wrapup;
      actgeom.num_points = 2;
      reversed = ME.EMSedge->ed_props & EMED_REVERSED;
    }

  idx = 0;
  for(i=0;i<num_points;i++)
   {         
     pyprojpt = &pyspace;
     EMcnvtpypts (EMmsg,&actgeom,2,1,&point[idx], partollenvec, 
		  pyprojpt,&mindist);
     if(!(1&*EMmsg)) goto wrapup;
     degenerate_edge = (*EMmsg == EMS_I_DegenerateEdge) ? TRUE : FALSE;
     ambiguous_case = (*EMmsg == EMS_I_Ambiguous) ? TRUE : FALSE;

     minptinx = pyprojpt->span_inx;
     minseg = &actgeom.points[minptinx*2];

/* If the input point was within tolerance from the edge, then return the
   input itself as the projected point instead of actually calculating
   it.
*/
     if(mindist<partollenvec)
        OM_BLOCK_MOVE(&point[idx],proj_info[i].proj_pt,2*sizeof(IGRdouble));
     else
      {
  	proj_info[i].proj_pt[U] = 
		minseg[U] + pyprojpt->param * (minseg[U+2] - minseg[U]);
  	proj_info[i].proj_pt[V] = 
	        minseg[V] + pyprojpt->param * (minseg[V+2] - minseg[V]);
      }
    proj_info[i].dist = mindist;
    proj_info[i].param.span_inx = pyprojpt->span_inx;
    proj_info[i].param.param  = pyprojpt->param;

/* Fill in the relative location of the projected point in the
   return argument
*/
    if (pyprojpt->props & EMS_PYPT_ATSTART)
      proj_info[i].location = reversed ? EMScvint_rtend : EMScvint_lfend;
    else if (pyprojpt->props & EMS_PYPT_ATSTOP)
      proj_info[i].location = reversed ? EMScvint_lfend : EMScvint_rtend;
    else if (pyprojpt->props & EMS_PYPT_ATMIDDLE)
      proj_info[i].location = EMScvint_middle;
    else if (pyprojpt->props == EMS_PYPT_POSUNKNOWN)
      proj_info[i].location = EMScvint_unknown;
    else
      {*EMmsg = EMS_E_Fail; goto wrapup;}

/* Determine the unit-tangent vector in the logical direction of the
   edge. 
*/
    loc = ME.EMSnatedge->location & 0x3;
    ptr = proj_info[i].tangent;
    inx = loc % 2;
    ptr[inx] = 0.0;
    ptr[!inx] = loc >= THIRD ? -1.0 : 1.0;
    ptr[!inx] = reversed ? -ptr[!inx] : ptr[!inx];

/* If there was a boundary then convert the parameter of the proj_point
   relative to the original geometry
*/
   if(bnd)
    {
      EMcnvtedpar(EMmsg,bnd->edbdry,&bnd->edbdry[1],&proj_info[i].param,
		  &cnvt);
      EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
      OM_BLOCK_MOVE(&cnvt,&proj_info[i].param,sizeof(struct EMSedgebound));
    }
    idx += 2;
  }
wrapup:
  if(degenerate_edge) *EMmsg = EMS_I_DegenerateEdge;
  if(ambiguous_case) *EMmsg = EMS_I_Ambiguous;

  EMWRAPUP(*EMmsg,sts,"In EMSnatedge.EMptproject")
  return (sts);
}

end implementation EMSnatedge;
