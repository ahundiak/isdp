/* ###################   APOGEE COMPILED   ################## */
/*
   ABSTRACT:

    The purpose of this method is to provide a flexible means of "posting"
    the edges geometry. The input is in a polyline format. If the edge is
    internally represented in the B-spline curve format, the edge is first
    converted to a B-spline of compatible format using the appropriate 
    chord-height tolerance. Thus geometry may be inserted into the existing
    geometry at any place. But restrictions apply.

    This method is applicable only on those edges that fulfil the following
    criteria:
    i) It is not a part-edge or a natural-edge,
    ii) The geometry to be added will not cause the edge to cross the
         uv-domain fo the surface.

    Geometry may be inserted anywhere in the existing geometry by
    specifying the point ("before_ptinx") before which the insertion
    is to take place.  If the reverse flag is set, "before_ptinx" applies to
    the reversed edge. The input geometry is expected in the consistent
    order.If before_ptinx exceeds the last point-index, the input geometry is
    inserted at the 'logical' end.
    The point indices start with 0.

History
	SS	??/??/??	Creation.
	SM	09-Mar-88	Modified to update partedge bounds instead
				of erroring out if there are any partedges.
				The last argument partolbasis is required
				during this update. If there are no partedges
				this can be NULL.
        RV      06-Sep-88	Stroke out instance data and update
				before_ptinx if ISO-edge. No attempt is
				made to test for ISO after insertion. When
				that is required, use leinit.
	SM	12-Sep-88	If stroked ISO edge update 'insptinx'
				immediately. Also stoke after reverse flag
				is applied to input geometry.
	SM	29-Sep-88	Added 'surf_data' argument. If the edge is iso
				it needs surf geom for stroking itself
				out. If non iso, this can be NULL. Also if
				surf_data is not supplied (and if it is needed)
				an attempt will be made to get it. 
	SM	21-Feb-89	When updating partedge bounds, do explicit
				send on to_owners channel instead of using
				EMsend_partedges function so that dummy edges
				get the message too.
	SS	10-Apr-89	After this method the curve-type should reflect
				the existing situation. Eg: A previously
				lineseg situation changes to a linestring
				because of more than two poles.
*/

class implementation EMSlinedge;

#include "EMS.h"

#ifndef DEBUG
#define DEBUG	0
#endif

#if DEBUG
#define BUF	1
#else
#define BUF	6
#endif

#include "OMmacros.h"
#include "emsdef.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "emsedgedef.h"

#define LINESEG_SIZE 2

from EMSpartedge import EMchange_bounds, EMget_span_constraints;
from EMSloop import EMsetrange;

method EMputpygeom (IGRlong *EMmsg; IGRint before_ptinx; IGRboolean reverse;
                    struct IGRpolyline *inpygeom;
		    IGRboolean check_constraints;
		    struct EMSpartolbasis *partolbasis;
		    struct EMSpartedinfo *part;
		    struct EMSdataselect *surf_data;
		    IGRshort *mattyp;
		    IGRmatrix mat)
{
  IGRuchar 	cvtype;
  IGRint 		sts, i, num_points, j;
  IGRint 		incr, size, insptinx;
  IGRlong 		msg_loc, rc;
  IGRdouble 		*points, *pt1, *pt2, partollen, temp_pt[2];
  IGRint 		EMcount_partedges();
  void 			EMrevpyline();
  struct IGRpolyline	new_geom, const_geom;
  IGRboolean 		update_partedges = TRUE, 
			constraints_added = FALSE;
  IGRint 		num_constraints, buf_size;
  struct EMSedgebound 	*params;
  IGRdouble		static_doubles[BUF];
  GRobjid		user_id;
  IGRushort	user_props;
  OM_S_CHANSELECT	to_owners;
  IGRint		numowners = 0;
  extern IGRboolean	EFget_new_linear_edge_type();
  extern IGRlong	EMmake_chanselect();

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  params = NULL;
  buf_size = 0;
  num_constraints = 0;
  new_geom.points = NULL;
  const_geom.points = static_doubles;
  if(part)
   {
    user_id = part->edid;
    user_props = part->edprops;
   }
  else
   {
    user_id = my_id;
    user_props = ME.EMSedge->ed_props;
   }

  EMerr_hndlr (before_ptinx < 0, *EMmsg, EMS_E_InvalidArg, ret_end);

  if(!partolbasis->is_valid)
   {
    sts = om$send(msg=message EMSboundary.EMgetsurface_info(EMmsg,NULL,
                       partolbasis), targetid = user_id);
    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError, ret_end);
   }
  sts = EFextract_par(BSTOLLENVEC, partolbasis->tol, &partollen, &rc);

  sts = EMmake_chanselect(EMSedge_to_owner, &to_owners);
  sts = om$get_channel_count (object = me, p_chanselect = &to_owners,
             			   count = (OMuint *)&numowners);


  reverse = user_props & EMED_REVERSED ? 
             (reverse ? FALSE : TRUE) :
             (reverse ? TRUE : FALSE);

  num_points = ME.EMSlinedge->num_points;
  if (before_ptinx >= num_points) 
    before_ptinx = num_points - 1;
  if (reverse)
    {
    EMrevpyline (&msg_loc, inpygeom, 2, NULL);
    EMerr_hndlr (EMSerror (msg_loc), *EMmsg, EMS_E_Fail, ret_end);
    insptinx = num_points - before_ptinx;
    }
  else
    insptinx = before_ptinx;

  /* If ISO-edge, stroke instance data */

  if (user_props & EMED_ISO)
  {
   struct EMSpypoint pyspace, *pyptr;
   IGRdouble mindist;
   struct IGRpolyline	my_poly;
   struct GRid		*srf_id = NULL;
   struct IGRbsp_surface *srf_geom = NULL;

   if(surf_data)
    {
     if(surf_data->datatype == EMSdata_surface)
      srf_geom = (struct IGRbsp_surface *) surf_data->data.surface;
     else if(surf_data->datatype == EMSdata_object)
      srf_id = (struct GRid *) surf_data->data.object;
     else {*EMmsg = EMS_E_InvalidArg; goto ret_end;}
    }
   sts = om$send(msg = message EMSlinedge.EMstroke_iso_edge(&msg_loc,
				mat, mattyp, srf_id, srf_geom, FALSE, 
				partolbasis, user_id, NULL, TRUE),
			targetid = my_id);
   EMerr_hndlr(!(1&msg_loc&sts), *EMmsg, EMS_E_Fail, ret_end);

   user_props &= ~EMED_ISO;

   /* Since the edge got stroked, recalculate the insptinx.
   */
   pyptr = &pyspace;     
   my_poly.num_points = ME.EMSlinedge->num_points;
   my_poly.points = ME.EMSlinedge->points;
   EMcnvtpypts(&msg_loc, &my_poly, 2, 1, inpygeom->points, partollen, 
		 pyptr, &mindist);
   insptinx = pyptr->span_inx + 1;
  }

  num_points = ME.EMSlinedge->num_points;

  /* The polyline is ready to be added to my geometry. If the affected
     span has some partedge endpoints on it then those points of the partedges
     are 'constraints' on my geometry and hence the new geometry should
     rubberband around these constraints. If this is not done then the partedge
     bounds with respect to the new geometry might result into a gap in the
     loop between two edges. 
  */

  constraints_added = FALSE;

  if(check_constraints)
   {
    for(i=0; i<numowners; i++)
     {
      sts = om$send(msg = message EMSpartedge.EMget_span_constraints
			(EMmsg, insptinx-1, &num_constraints, &params, 
			 NULL, &buf_size), from = i, to = i, 
			 p_chanselect = &to_owners);
      if(sts == OM_W_UNKNOWN_MSG)		/* could be a loop */
		sts = OM_S_SUCCESS;
      EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, ret_end);
     }
   }

  if(num_constraints)
   {
     /* If there are some constraints on the affected span, then insert those
        uv points into my geometry before inserting the input geometry. The
	points within uv length tolerance from existing points are not 
	duplicated.
     */

     const_geom.num_points = 0;
     if(BUF < num_constraints * 2)
       const_geom.points = (IGRdouble *) om$malloc(size = num_constraints * 2 *
					sizeof(IGRdouble));
     pt1 = &ME.EMSlinedge->points[(insptinx-1)*2];
     pt2 = &ME.EMSlinedge->points[insptinx * 2];

     j=0;
     for(i=0; i<num_constraints; i++)
      {
	temp_pt[0] = pt1[0] + params[i].param * (pt2[0] - pt1[0]);
	temp_pt[1] = pt1[1] + params[i].param * (pt2[1] - pt1[1]);
	
	if(EM2ddistptpt(temp_pt, pt1) < partollen) continue;
	if(EM2ddistptpt(temp_pt, pt2) < partollen) continue;
	
        if(j && EM2ddistptpt(temp_pt, &const_geom.points[j-2]) < partollen)
	    continue;
	OM_BLOCK_MOVE(temp_pt, &const_geom.points[j], 2*sizeof(IGRdouble));
	j+=2;
	const_geom.num_points++;
      }

    reverse = ME.EMSedge->ed_props & EMED_REVERSED ? TRUE : FALSE;

    if(const_geom.num_points)
     {
      sts = om$send(msg = message EMSedge.EMputpygeom(&msg_loc, insptinx, 
			reverse, &const_geom, FALSE, partolbasis, NULL,
			surf_data, mattyp, mat), 
		targetid = my_id);
      EMerr_hndlr(!(1&msg_loc&sts), *EMmsg, EMS_E_Fail, ret_end);
      constraints_added = TRUE;
     }
   }

  /* If the geometry of the linear edge was changed by adding some
     points, then the insptinx already calculated may now be invalid.
     The new ptinx is computed by finding the span closest to the first input
     point.
  */
  if(constraints_added)
   {
     struct EMSpypoint pyspace, *pyptr;
     IGRdouble mindist;
     struct IGRpolyline	my_poly;

     pyptr = &pyspace;     
     my_poly.num_points = ME.EMSlinedge->num_points;
     my_poly.points = ME.EMSlinedge->points;
     EMcnvtpypts(&msg_loc, &my_poly, 2, 1, inpygeom->points, partollen, 
		 pyptr, &mindist);
     insptinx = pyptr->span_inx + 1;
   }

  num_points = ME.EMSlinedge->num_points;
  size = (num_points + inpygeom->num_points) * 2;
  if (om$dimension_of (varray = ME.EMSlinedge->points) < size)
    om$vla_set_dimension (varray = ME.EMSlinedge->points, size = size);
  points = ME.EMSlinedge->points;

  size = 2 * sizeof (IGRdouble);  
  incr = inpygeom->num_points;
  for (i=num_points-1; i>=insptinx; i--)
    OM_BLOCK_MOVE (&points[i*2], &points[(i+incr)*2], size);

  size = inpygeom->num_points * 2 * sizeof (IGRdouble); 
  OM_BLOCK_MOVE (inpygeom->points, &points[insptinx*2], size);

  ME.EMSlinedge->num_points += inpygeom->num_points;

  new_geom.num_points = ME.EMSlinedge->num_points;
  new_geom.points = ME.EMSlinedge->points;

  ME.EMSedge->ed_props &= ~EMED_ISO;

  /* update the bounds for dummy edge, partedges that own me.
  */
  for(i=0; i<numowners; i++)
   {
    sts = om$send(msg = message EMSpartedge.EMchange_bounds
		(EMmsg, insptinx, inpygeom, NULL, &new_geom, NULL, NULL,
			 &ME.EMSedge->ed_props, update_partedges, 
			 NULL, partolbasis), from = i, to = i, 
			 p_chanselect = &to_owners);
			
    if(sts == OM_W_UNKNOWN_MSG)		/* could be a loop */
		sts = OM_S_SUCCESS;
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, ret_end);
   }

  /*
   * If the curve-type of this edge was either a line-segment or a line-string,
   * check if this type remains valid after the change (if any) in the
   * number of points. If two points then line-segment, if more, line-string.
   */

  cvtype = ME.EMSedge->curve_type;
  EFget_new_linear_edge_type (cvtype, ME.EMSlinedge->num_points, &cvtype);
  ME.EMSedge->curve_type = cvtype;

  /* Update the range of the loop.
  */
  sts = EMsend_loops(&rc, message EMSloop.EMsetrange(EMmsg), 
        user_id, 0, MAXINT, EMLP_ACTIVE, NULL, NULL);
  if(!(1&*EMmsg&sts)) goto ret_end;  /* just incase code is added later*/

ret_end:
  if(params) om$dealloc(ptr = params);
  if(const_geom.points && (const_geom.points != static_doubles))
   om$dealloc(ptr = const_geom.points);

  EMWRAPUP_MSG (*EMmsg, sts, "In EMSlinedge.EMputpygeom");
  return (sts);
}

end implementation EMSlinedge;
