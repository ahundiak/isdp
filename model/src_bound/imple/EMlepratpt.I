/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method returns the parameter on the edge for a UV point
 on the edge. The parameter returned is by convention relative to the full
 edge, even if the method is invoked for a partedge. If the point is
 not on the edge then the off_edge flag for that point is TRUE but the
 corresponding parameter returned is still valid. If the point is on edge
 (considering entire geometry even for a partedge) then the off_edge flag for
 that point is FALSE.

History
	SM	02/26/87    creation date
*/
class implementation EMSlinedge;

#include "EMS.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "emsmacros.h"
#include "OMmacros.h"

#define X 0
#define Y 1

method EMpratpt(IGRlong *EMmsg; 
                IGRdouble *points; 
		IGRint num_points;
		struct EMSedgebound *param;
		IGRboolean *off_edge;
		struct EMSpartedinfo *bnd;
		struct EMSpartolbasis *partolbasis)
{
  IGRint		sts,i,idx;
  IGRlong		rc;
  struct EMSpypoint 	*pyprojpt,pyspace;
  void			EMcnvtpypts();
  IGRdouble		mindist,partollenvec;
  struct IGRpolyline	poly;
  IGRboolean		EFextract_par(), degenerate_edge;


  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  degenerate_edge = FALSE;

  poly.num_points=0;
  poly.points = NULL;

  if(!partolbasis->is_valid)
   {
     sts = om$send(msg=message EMSboundary.EMgetsurface_info
				(EMmsg,NULL,partolbasis),targetid=my_id);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
   }
  sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&partollenvec,&rc);

  poly.num_points = ME.EMSlinedge->num_points;
  poly.points = ME.EMSlinedge->points;

  idx=0;
  for(i=0;i<num_points;i++)
   {         
     pyprojpt = &pyspace;
     EMcnvtpypts (EMmsg, &poly, 2, 1,&points[idx], partollenvec, 
		  pyprojpt, &mindist);
     if(!(1&*EMmsg)) goto wrapup;
     degenerate_edge = (*EMmsg == EMS_I_DegenerateEdge) ? TRUE : FALSE;

     param[i].span_inx = pyprojpt->span_inx;
     param[i].param  = pyprojpt->param;
     if(mindist>partollenvec)
        off_edge[i] = TRUE;
     else
	off_edge[i] = FALSE;
     idx += 2;
 }

wrapup:

  if(degenerate_edge) *EMmsg = EMS_I_DegenerateEdge;

  EMWRAPUP(*EMmsg,sts,"In EMSlinedge.EMpratpt")
  return (sts);
}

end implementation EMSlinedge;
