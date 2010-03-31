/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method extends/deextends the geometry of a bs edge.
	
Arguments
	extnd_pt	input		point for extension/distension.
	location	input		which end of the edge should be
					considered. The end is wrt the
					actual geometry, regardless of the
					reversed bit of the edge. This argument
					can point to BEGIN, END, or
					UNKNOWN. If UNKNOWN
					is passed, the end to which the
					extnd_pt is closer is used and the
					corresponding location is
					returned.
	replace_endpt   input		Ignored
	mindist		output		Ignored
	outpypoint	output		Ignored
	new_geom	output		Ignored
	partolbasis	input		Paramatric basis tolerance.
	
History
	SM	06-jun-88	Creation.
    gupta 20-jun-90  added support for replace_endpt

          Sudha 06/04/93          modified to include BSprototype header files

*/
class implementation EMSbsedge;
#include "EMS.h"

#ifndef DEBUG
#define DEBUG	0
#endif

#if DEBUG
#include <stdio.h>
#endif
#include "bsparameters.h"
#include "bserr.h"
#include "EMSlmdef.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "emsdef.h"
#include "emsedgedef.h"
#include "bsmodshpcvg.h"
#include "bsfreecv.h"
#include "bsdistptpts.h"
#include "bscv_endpt.h"

from EMSloop import EMsetrange;

method EMextend_geom( IGRlong *EMmsg;
		      IGRdouble *extnd_pt;
		      IGRint *location;
		      IGRboolean replace_endpt;
		      IGRdouble *mindist;
		      struct EMSpypoint *outpypoint;
		      struct IGRpolyline *new_geom;
		      struct EMSpartolbasis *partolbasis;
                      IGRushort option;
                      struct GRid *srf_id;
                      struct IGRbsp_surface *srf_geom;
                      IGRmatrix matrix;
                      IGRshort *mx_type)

{
  IGRlong		sts, rc;
  IGRdouble		lentol, newendpt[3], to_move_par;
  IGRpoint      startpt, endpt;
  struct IGRbsp_curve	my_geom, *new_geom = NULL, *in1 = NULL;
  extern IGRint		EMextend_curve();
  IGRint		i;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  my_geom.poles = NULL;
  my_geom.knots = NULL;
  my_geom.weights = NULL;
  my_geom.bdrys = NULL;
  in1 = &my_geom;

  /* If the parametric tolerance passed in is not valid go get it.
  */
  if(!partolbasis->is_valid)
   {
     sts = om$send(msg=message EMSboundary.EMgetsurface_info(EMmsg,NULL,
                        partolbasis),targetid=my_id);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
   }
  sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&lentol,&rc);


  sts = om$send(msg = message EMSedge.EMgetbcgeom(EMmsg, 0, MAXINT, 
			ME.EMSedge->ed_props & EMED_REVERSED, NULL, &my_geom,
                        partolbasis, NULL), 
			targetid = my_id);
  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);

  /* I am using the EMS_ROUND_OPR criterion only to ensure that
     this change does not break booleans or any other operation at
     this moment.
     gupta/June 20, 1990
  */

  if ((option & EMS_ROUND_OPR) && (replace_endpt))
   {
    if (*location == BEGIN) to_move_par = 0.0;
    else if (*location == END) to_move_par = 1.0;
    else
     {
      for (i=0; i<3; i++)
       {
        startpt[i] = my_geom.poles[i] / my_geom.weights[0];
        endpt[i] = my_geom.poles[3*(my_geom.num_poles-1)+i] / 
                 my_geom.weights[my_geom.num_poles-1];
       }

      if (BSdistptpts (&rc, startpt, extnd_pt) <
          BSdistptpts (&rc, endpt,   extnd_pt))
          to_move_par = 0.0;
      else
          to_move_par = 1.0;
     }
    BSmodshpcvg (&my_geom, to_move_par, extnd_pt, FALSE, FALSE,
                 &new_geom, &rc);
    if(rc != BSSUCC){*EMmsg = EMS_E_Fail; goto wrapup;}
    ME.EMSedge->curve_type = EMfreeform_curve;
   }
  else
   {
    sts = EMextend_curve (EMmsg, &in1, &new_geom, extnd_pt, location,
                          lentol, 2, TRUE);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
    if(*EMmsg == EMS_I_Degenerate) goto wrapup;
   }

  if(new_geom)
   {
    /* If the bs edge has been extended out of uv space do not post the
	data.
    */
    sts = BScv_endpt(&rc, new_geom, extnd_pt, newendpt);
    if(rc != BSSUCC){*EMmsg = EMS_E_Fail; goto wrapup;}
    for(i=0; i<2; i++)
     {
      if( fabs(newendpt[i] - 0.0) < lentol) newendpt[i] = 0.0;
      if( fabs(newendpt[i] - 1.0) < lentol) newendpt[i] = 1.0;
     }
    if( (newendpt[0] < 0.0) || (newendpt[0] > 1.0) || (newendpt[1] < 0.0)
	|| (newendpt[1] > 1.0))
	{
#if DEBUG
	 fprintf(stderr, "BSedge extended out of UV -- declined\n");
#endif
	 *EMmsg = EMS_E_Fail; 
	 goto wrapup;
	}
    sts = om$send(msg = message EMSedge.EMputbcgeom(EMmsg, 0, 
				ME.EMSedge->ed_props & EMED_REVERSED, 
				new_geom), targetid = my_id);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

#if DEBUG
    fprintf(stderr,"BSedge %d Extended\n", my_id);
#endif

   }

 /* Update the range of the loop.
 */
 sts = EMsend_loops(&rc, message EMSloop.EMsetrange(EMmsg), 
        my_id, 0, MAXINT, EMLP_ACTIVE, NULL, NULL);
 if(!(1&*EMmsg&sts)) goto wrapup;  /* just incase code is added later*/

wrapup:
if(my_geom.poles) om$dealloc(ptr = my_geom.poles);
if(my_geom.knots) om$dealloc(ptr = my_geom.knots);
if(my_geom.weights) om$dealloc(ptr = my_geom.weights);
if(new_geom) BSfreecv(&rc, new_geom);
return(sts);
}

end implementation EMSbsedge;
