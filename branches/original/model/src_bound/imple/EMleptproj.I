/*
Notes
	This method projects an input point onto an edge. The input point
   is in parametric space (2D)
   The information returned is the projected point (2D) on the edge, the
   minimum distance to the edge and the edge param of the point on the
   edge(in the format span index-parameter pair).

History
        SS      03/19/88    Returning good intersection-location.
	SS	11/30/87    the tangent field in the EMSproj_info structure
			    is initialized
	SM	02/26/87    creation date
        Sudha   07/06/93        modified for BSprototype includes
*/
class implementation EMSlinedge;

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "emsmacros.h"
#include "OMmacros.h"
#include "bsnorvec.h"

#define X 0
#define Y 1
#define Z 2

#define STATIC_PT_BUF	50
#define STATIC_BUF	100

method EMptproject (IGRlong *EMmsg; 
                    IGRdouble *point; 
		    IGRint num_points;
		    struct EMSproj_info *proj_info;
		    struct EMSpartedinfo *bnd;
		    struct EMSpartolbasis *partolbasis)
{
  IGRboolean 		loc_reversed, reversed, found, cusp, at_end, at_stop;
  IGRushort		dumprops;
  IGRint		sts,i,idx,span_inx, dumnum;
  IGRlong		minptinx,rc;
  struct EMSpypoint 	*pyprojpt,pyspace;
  void			EMcnvtpypts(),EMcnvtedpar();
  IGRdouble		mindist,*minseg,partollenvec,param,vec1[4],vec2[4];
  struct IGRpolyline	poly, py;
  IGRboolean		EFextract_par();
  struct EMSedgebound	cnvt;
  GRobjid		nxted;
  IGRboolean		degenerate_edge = FALSE, 
			ambiguous_case = FALSE;
  IGRdouble		ptbuf[STATIC_BUF];



  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  poly.num_points=0;
  
  if(ME.EMSlinedge->num_points +1 > STATIC_PT_BUF)
   poly.points = NULL;
  else poly.points = (IGRdouble *) ptbuf;

  if(!partolbasis->is_valid)
   {
     sts = om$send(msg=message EMSboundary.EMgetsurface_info
				(EMmsg,NULL,partolbasis),targetid=my_id);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
   }
  sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&partollenvec,&rc);

/* If boundary has been passed in, then extract the active part of
   my geometry. Otherwise use the entire geometry.
*/

  if (bnd)
    {
      reversed = bnd->edprops & EMED_REVERSED;
      sts = om$send (msg = message EMSedge.EMgetpygeom
               (EMmsg,0,MAXINT, reversed ? TRUE : FALSE,
		bnd,&poly, partolbasis, NULL), 
               targetid = my_id);
      if(!(1&*EMmsg&sts)) goto wrapup;
      if(!poly.points){*EMmsg=EMS_F_Fail;goto wrapup;}
    }
  else
    {
      poly.num_points = ME.EMSlinedge->num_points;
      poly.points = ME.EMSlinedge->points;
      reversed = ME.EMSedge->ed_props & EMED_REVERSED;
    }

  idx=0;
  for(i=0;i<num_points;i++)
   {         
     pyprojpt = &pyspace;
     EMcnvtpypts (EMmsg, &poly, 2, 1,&point[idx], partollenvec, 
		  pyprojpt, &mindist);
     if(!(1&*EMmsg)) goto wrapup;
     degenerate_edge = (*EMmsg == EMS_I_DegenerateEdge) ? TRUE : FALSE;
     ambiguous_case = (*EMmsg == EMS_I_Ambiguous) ? TRUE : FALSE;

     minptinx = pyprojpt->span_inx;
     minseg = &poly.points[minptinx*2];

/* If the input point was within tolerance from the edge, then return the
   input itself as the projected point instead of actually calculating
   it.
*/
     if(mindist<partollenvec)
        OM_BLOCK_MOVE(&point[idx],proj_info[i].proj_pt,2*sizeof(IGRdouble));
      else
       {
         proj_info[i].proj_pt[X] = 
		minseg[X] + pyprojpt->param * (minseg[X+2] - minseg[X]);
         proj_info[i].proj_pt[Y] = 
	        minseg[Y] + pyprojpt->param * (minseg[Y+2] - minseg[Y]);
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
   edge. The average tangent is computed if the point lies at an internal
   cusp. If the point lies at the end-point of this edge, and if there
   is a contiguous next edge, the average tangent is computed.
*/
     OM_BLOCK_MOVE (minseg, vec1, 4 * sizeof (IGRdouble));
     vec1[X] = vec1[X+2] - vec1[X];
     vec1[Y] = vec1[Y+2] - vec1[Y];
     vec1[Z] = 0.0;
     if (reversed)
       {
       vec1[X] = -vec1[X];
       vec1[Y] = -vec1[Y];
       }
     BSnorvec (&rc, vec1);

     span_inx = pyprojpt->span_inx;
     param = pyprojpt->param;
     cusp = param <= MINDOUBLE || param >= 1.0-MINDOUBLE;
     at_end = proj_info[i].location == EMScvint_lfend || 
               proj_info[i].location == EMScvint_rtend;
     if (cusp || at_end)
       {
       /* "loc_reversed" is used to indicate whether the tangent obtained for 
        * either the next "span" (for cusp) or for next "edge" (if at end)
        * should be reversed. Ultimately we want "vec2"to flow opposite
        * to the logical direction so that we may compute an avg. of the two
        * tangents (the first tangent "vec1" flows in the logical direction).
        */
       loc_reversed = FALSE;
       found = FALSE;
       if (at_end)
         {
         nxted = NULL_OBJID;
         at_stop = proj_info[i].location == EMScvint_rtend;
         sts = EMgetnxtedges (EMmsg, EMSvtxedges_nodegenerate, my_id,
                OM_Gw_current_OS, at_stop,
                1, &dumnum, &nxted, &dumprops, &dumnum);
         if (!EMSerror (sts & *EMmsg) && !IF_NULL_OBJID (nxted))
           {
           py.num_points = 2;
           py.points = vec2;
           sts = om$send (msg = message EMSedge.EMgetpygeom (EMmsg,
                  0, 1, !at_stop, NULL, &py, NULL, NULL), targetid = nxted);
           if (!EMSerror (sts & *EMmsg))
             {
             loc_reversed = !at_stop;
             found = TRUE;
             }
           }
         }
       else
         {
         if (param <= MINDOUBLE)
           span_inx--;
         else
           span_inx++;
         OM_BLOCK_MOVE (&poly.points[span_inx*2], vec2, 
          4 * sizeof (IGRdouble));
         loc_reversed = reversed;
         found = TRUE;
         }

       if (found)
         {
         vec2[X] = vec2[X+2] - vec2[X];
         vec2[Y] = vec2[Y+2] - vec2[Y];
         vec2[Z] = 0.0;
         if (loc_reversed)
           {
           vec2[X] = -vec2[X];
           vec2[Y] = -vec2[Y];
           }
         BSnorvec (&rc, vec2);

         vec1[X] = (vec2[X] + vec1[X]) / 2.0;
         vec1[Y] = (vec2[Y] + vec1[Y]) / 2.0;
         BSnorvec (&rc, vec1);
         }
       }

     proj_info[i].tangent[X] = vec1[X];
     proj_info[i].tangent[Y] = vec1[Y];

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
  if (bnd && poly.points && (poly.points != ptbuf))
      om$dealloc (ptr = poly.points);
  if(degenerate_edge) *EMmsg = EMS_I_DegenerateEdge;
  if(ambiguous_case) *EMmsg = EMS_I_Ambiguous;

  EMWRAPUP(*EMmsg,sts,"In EMSlinedge.EMptproject")
  return (sts);
}

end implementation EMSlinedge;
