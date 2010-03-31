/* ###################   APOGEE COMPILED   ################## */
/*
   ABSTRACT:

    The purpose of this method is to provide flexible access to the
    edges "active" geometry in a B-spline format. If the edge is internally
    represented in the B-spline curve format, it is returned as is.
    If it is line-string then it is returned as an order 2 B-spline
    curve.

    Random access to the spans of the edge's B-spline geometry is possible. The 
    geometry can be obtained either reversed or as is.
    The minimum of i) the number of spans requested and ii) the number of 
    spans present starting from "from_spaninx", is returned. 

    If the caller nulls out the "poles, weights and the knots" fields 
    in the IGRbsp_curve structure, this method mallocs the 
    required amount of memory. Else it assumes sufficient
    memory is present. The pointer "bcgeom" should always point to a valid
    IGRbsp_curve structure on entry.

History
 23-Mar-89: SM : Use static memory for 'getpygeom' if possible. Also the
		 method was unconditionally setting bcgeom->poles and
		 bcgeom->knots to NULL. Changed it to not initialize here
		 so that caller can control the memory allocation. Upon error
		 poles and knots are freed only if they came in as NULL.
 08/24/88 : PP : Modified arguments to EMcnvtpybs.
 01/07/87 : PP : Creation
*/

class implementation EMSlinedge;

#include "EMS.h"
#include "emsdef.h"

#define MaxPts	150
#define PtsBuff	300

method EMgetbcgeom (IGRlong *msg; IGRint from_spaninx; IGRint num_spans;
                    IGRboolean reverse; struct EMSpartedinfo *partinfo;
                    struct IGRbsp_curve *bcgeom; struct EMSpartolbasis
                    *partolbasis; IGRushort options)
{
  IGRint status;
  IGRboolean	bssts, poles_mem_alloced_here = FALSE, 
		       knots_mem_alloced_here = FALSE;
  struct IGRpolyline pygeom;
  extern IGRboolean EMcnvtpybsn();
  IGRdouble	ptsbuff[PtsBuff];

  
  *msg = EMS_S_Success;
  status = OM_S_SUCCESS;
  if(ME.EMSlinedge->num_points <= MaxPts)
   pygeom.points = (IGRdouble *) ptsbuff;
  else
   pygeom.points = NULL;

  poles_mem_alloced_here = bcgeom->poles ? FALSE : TRUE;
  knots_mem_alloced_here = bcgeom->knots ? FALSE : TRUE;

/****************************   
  bcgeom->poles = NULL;
  bcgeom->knots = NULL;
*****************************/

  status = om$send (msg = message EMSedge.EMgetpygeom (msg, 0,
                          MAXINT,    
                          reverse, partinfo, &pygeom, partolbasis, options),
                    targetid = my_id);
  EMerr_hndlr(! (1 & status & *msg), *msg, EMS_E_Fail, wrapup);

  bssts = EMcnvtpybsn (msg,2,&pygeom, bcgeom);
  EMerr_hndlr (! (bssts) , *msg, EMS_E_Fail, wrapup);
  
 wrapup:
  if (!(1 & status & *msg))
  {
   if (bcgeom->poles && poles_mem_alloced_here) free (bcgeom->poles);
   if (bcgeom->knots && knots_mem_alloced_here) free (bcgeom->knots);
  }
 
  if (pygeom.points && (pygeom.points != ptsbuff)) free (pygeom.points);

  EMWRAPUP (*msg, status, "In EMSlinedge : EMgetbcgeom error");
  return (status);
}

end implementation EMSlinedge;
