/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method extends/deextends the geometry of a linear edge.
	
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
	replace_endpt   input		If TRUE the suitable end point
					is simply replaced by the extnd_pt.
	mindist		output		minimum distance between the edge
					and the extnd_pt.
					Interested ? non NULL : NULL.
	outpypoint	output		Info about nearest point on
					edge.Interested ? non NULL : NULL.
	new_geom	output		Resultant geometry of the edge.
					Interested ? non NULL : NULL.
	partolbasis	input		Paramatric basis tolerance.
	
History
	SM	24-mar-88	Creation.
        RV      06-Sep-88       Stroke out instance data (make non-ISO)
				if ISO-edge. No attempt is made to check
				if the edge can be made into ISO after
				extension. If and when that is required,
				use leinit to do it.
	SM	29-Sep-88	Optimised stroking of an iso edge by doing
				it only if necessary (checking after extention)
	SS	10-Apr-89	Check/maintain integrity of curve-type.
*/
class implementation EMSlinedge;
#ifndef DEBUG
#define DEBUG	0
#endif

#if DEBUG
#include <stdio.h>
#endif
#include "bsparameters.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "EMS.h"

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
  IGRuchar	cvtype;
  IGRlong		sts, rc;
  IGRdouble		*curr_pts, *new_pts, lentol;
  struct IGRpolyline	inpoly, outpoly;
  IGRint		totsize;
  IGRboolean		EFget_new_linear_edge_type();

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  /* If the parametric tolerance passed in is not valid go get it.
  */
  if(!partolbasis->is_valid)
   {
     sts = om$send(msg=message EMSboundary.EMgetsurface_info(EMmsg,NULL,
                        partolbasis),targetid=my_id);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
   }
  sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&lentol,&rc);

  curr_pts = NULL;
  new_pts = NULL;
  inpoly.points = NULL;
  outpoly.points = NULL;

  if(replace_endpt)
   {
    if (ME.EMSedge->ed_props & EMED_ISO)
     {
#if DEBUG
      fprintf(stderr, "\nStroking iso edge %d from leextend\n", my_id);
#endif
      sts = om$send(msg = message EMSlinedge.EMstroke_iso_edge(EMmsg,
				matrix, mx_type, srf_id, srf_geom, FALSE, 
				partolbasis, my_id, NULL, TRUE),
			targetid = my_id);
      EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_Fail, wrapup);
     }

    inpoly.num_points = ME.EMSlinedge->num_points;
    inpoly.points = ME.EMSlinedge->points;
    sts = EMextend_poly(EMmsg, 2, &inpoly, NULL, extnd_pt, location, 
		      replace_endpt, mindist, outpypoint, lentol, TRUE);
    inpoly.points = NULL;
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
    goto wrapup;
   }

  totsize = ME.EMSlinedge->num_points * 2 * sizeof(IGRdouble);
  curr_pts = (IGRdouble *) om$malloc(size = totsize);
  EMerr_hndlr(!curr_pts, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  inpoly.num_points = ME.EMSlinedge->num_points;
  OM_BLOCK_MOVE(ME.EMSlinedge->points, curr_pts, totsize);
  inpoly.points = curr_pts;

  sts = EMextend_poly(EMmsg, 2, &inpoly, &outpoly, extnd_pt, location, 
		      replace_endpt, mindist, outpypoint, lentol, TRUE);
  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
  if(*EMmsg == EMS_I_Degenerate) goto wrapup;

  /* If the edge is iso, then check if it is still iso after extension.
     If so, then we can just post the new geom and keep the edge iso.
     If however, the edge becomes non iso after extending, then we need to
     stroke the iso edge (make it non iso) and perform the extension
     again. This will be cheaper than always stroking the edge if it was
     iso, and then again making it iso if appropriate after extending. The
     premise for this being that an iso edge will rarely become non iso.
  */
  if(ME.EMSedge->ed_props & EMED_ISO)
   {
     IGRboolean EMis_iso_edge();
     IGRdouble  iso_buff[4];

     if (!EMis_iso_edge(outpoly.num_points, outpoly.points, lentol, iso_buff))
      {
#if DEBUG
        fprintf(stderr, "\nStroking iso edge %d from leextend\n", my_id);
#endif
        sts = om$send(msg = message EMSlinedge.EMstroke_iso_edge(EMmsg,
				matrix, mx_type, srf_id, srf_geom, FALSE, 
				partolbasis, my_id, NULL, TRUE),
			targetid = my_id);
        EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_Fail, wrapup);
        sts = om$send(msg = OPPmargs, targetid = my_id);
        if(inpoly.points) om$dealloc(ptr = inpoly.points);
        if( outpoly.points && (inpoly.points != outpoly.points))
         om$dealloc(ptr = outpoly.points);
        return(sts);
      }
   }

  /* Post the new polyline. Cannot detect change in geometry by looking at
     the num_points. So always post it.
  */
  ME.EMSlinedge->num_points = outpoly.num_points;
  totsize = 2 * outpoly.num_points;
  om$vla_set_dimension (varray = ME.EMSlinedge->points, size = totsize);
  OM_BLOCK_MOVE (outpoly.points, ME.EMSlinedge->points, 
		 totsize * sizeof (IGRdouble));

  /*
   * Check to see if the curve-type is still valid. Validate it and
   * replace it with the good one.
   */

  cvtype = ME.EMSedge->curve_type;
  EFget_new_linear_edge_type (cvtype, ME.EMSlinedge->num_points, &cvtype);
  ME.EMSedge->curve_type = cvtype;

  /* Update the range of the loop.
  */
  sts = EMsend_loops(&rc, message EMSloop.EMsetrange(EMmsg), 
        my_id, 0, MAXINT, EMLP_ACTIVE, NULL, NULL);
  if(!(1&*EMmsg&sts)) goto wrapup;  /* just incase code is added later*/

wrapup:
    if(new_geom && !replace_endpt)
     {
       *new_geom = outpoly;
       if( inpoly.points && (inpoly.points != outpoly.points))
        om$dealloc(ptr = inpoly.points);
     }
    else
     {
       if(inpoly.points) om$dealloc(ptr = inpoly.points);
       if( outpoly.points && (inpoly.points != outpoly.points))
        om$dealloc(ptr = outpoly.points);
     }

    EMWRAPUP(*EMmsg, sts, "In EMSlinedge.EMextend_geom");
    return(sts);

}
end implementation EMSlinedge;
