/* ###################   APOGEE COMPILED   ################## */
/*
 Notes
        The natural edge is transform if the incoming option is
        EMS_TF_TRANSFORM_NE.

History

  RC      04/29/87        Creation date
  SM      09/02/87        Added code to do following -
                          replace myself by a corresponding linear
                          edge and send the message to it. This is
                          done untill Chopra finalises about 
                          different options.
   RC     11/05/87        Natural edge is transformed if and only
                          if EMS_TF_TRANSFORM_NE is set.
   SM     01-Mar-88	      When a natural edge is replaced by
                          a linear edge, stroke the xyz iso
                          curve if necessary and use the corresponding
                          uv points for the linear edge.
   RC     10/10/88        If I am replaced by linear edge and the user
                          requests for replacement info, return it in
                          null_ptr2.
   SM     01-Mar-92	  Assuming that the incoming partol is for the 
			  new (transformed) parametric space, obtain the
			  partol for the old surface and use where
			  appropriate.
   WBC    12/22/93        When constructing a linear edge, set the curve
                          type to be the same as my (the current object)
                          curve type.
*/

class implementation EMSnatedge;

#include "emserr.h"
#include "emsmacros.h"
#include "EMSopt.h"
#include "emsedgedef.h"
#include "bsparameters.h"
#include "emsmapdef.h"
#include "emsdef.h"
#include "bserr.h"
#include "EMSbnd.h"
#include "emsdattyp.h"
#include "emssfint.h"

extern OMuword	OPP_EMSlinedge_class_id;

from EMSlinedge import EMleinit;

method EMuv_transform (
        IGRlong                 *EMmsg;
        IGRdouble               matrix[16];
        struct EMSpartolbasis   *partolbasis;
        IGRshort                option;
        IGRchar                 *null_ptr1;
        IGRchar                 *null_ptr2)

{
 IGRlong mthd_stat;
  IGRlong		sts, rc;
  IGRdouble		nat_points[4], cht_tol;
  void			EMnatpoints();
  IGRushort	props,map_options;
  GRobjid		lin_edge;
  IGRint		EMreplace_edge(), num_out_curves, arrsz;
  struct IGRpolyline	poly;
  struct IGRbsp_surface	*old_surf;
  struct IGRbsp_curve	curve;
  struct EMSdataselect	*out_uv_curves, *out_xyz_curves;
  struct EMSuvtrans_info *rpl_info;
  IGRboolean		EFmap_the_curve();
  IGRshort		planar;
  extern void EFmemory_allocation();
  struct EMSpartolbasis oldpartol, *partolptr = NULL;
  
  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  old_surf = (struct IGRbsp_surface *) null_ptr1;
  curve.poles = NULL;
  curve.knots = NULL;
  curve.weights = NULL;
  out_uv_curves = NULL;
  out_xyz_curves = NULL;
  num_out_curves = NULL;
  planar = EMS_O_NonPlanar;

  partolptr = partolbasis;
  if(partolbasis && old_surf)
   {
    oldpartol = *partolbasis;
    sts = EFsspbtol_by_geom(&mthd_stat, old_surf, &oldpartol.tol);
    EMerr_hndlr(!(1&mthd_stat&sts), *EMmsg, mthd_stat, wrapup);
    oldpartol.is_valid = TRUE;
    partolptr = &oldpartol;
   }

  if (option & EMS_TF_TRANSFORM_NE)
  {
    EMnatpoints(EMmsg, ME.EMSnatedge->location & 0x3, nat_points);
    if(old_surf && (!( (old_surf->u_order == 2) && 
   			          (old_surf->v_order == 2))) &&
					  (! (ME.EMSedge->ed_props & EMED_DEGENERATE)))
    {
      sts = om$send(msg = message EMSedge.EMget_bcxyz_geom
				(&mthd_stat, NULL, NULL, old_surf, 0, 
				 MAXINT, FALSE, NULL, &curve), 
				targetid = my_id);
      EMerr_hndlr(!(1&mthd_stat&sts), *EMmsg, EMS_E_EdgeError, wrapup);
      if(curve.order < 3) 
       {
	     poly.num_points = 2;
	     poly.points = nat_points;
       }
      else
       {
  		struct GRid curve_GRid, loopset_GRid;
 		curve_GRid.objid = loopset_GRid.objid = NULL_OBJID;
	    map_options = EMMapBnd_WantBadCurves | EMMapBnd_StrokeAlways |
			  EMMapBnd_NoClip | EMMapBnd_NoCurveType;
	    num_out_curves = 0;
	    BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht_tol);
	
	    sts = EFmap_the_curve(curve_GRid, &curve, old_surf, loopset_GRid,
				  &cht_tol, partolptr, map_options, &planar, 
				  &num_out_curves, &out_uv_curves, 
				  &out_xyz_curves, NULL, NULL, FALSE, 
				  &mthd_stat);
            EMerr_hndlr(!sts, *EMmsg, EMS_E_Fail, wrapup);
	    if( (out_uv_curves[0].datatype != EMSdata_poly2d) ||
		(num_out_curves != 1) )
		{*EMmsg = EMS_E_Fail; goto wrapup;}
	
	    poly = *(out_uv_curves[0].data.poly);

		/* If this was a seam edge then the xyz to uv mapping 
		   might have resulted into the points being shifted to
		   the connected side of the surface.
	    */
		
	    if(ME.EMSedge->ed_props & EMED_SEAM)
		 {
		   IGRushort nat_edge_location, U_V_LOCATION;
           IGRdouble U_V_VALUE;
    	   IGRint ii;
  
		   nat_edge_location = ME.EMSnatedge->location & 0x3;
		   U_V_LOCATION = nat_edge_location % 2;
           U_V_VALUE    = ( (nat_edge_location % 3) ? 1.00 : 0.00 );
	       for(ii=0; ii<poly.num_points; ii++)
		    { 
			 poly.points[2*ii + U_V_LOCATION] = U_V_VALUE; /* SAM */
            }
		 }
       }
     }
    else
     {
       poly.num_points = 2;
       poly.points = nat_points;
     }

    props = ME.EMSedge->ed_props & ~EMED_NATURAL;

    sts = om$construct(classid = OPP_EMSlinedge_class_id, 
                       p_objid = &lin_edge, 
                       msg = message EMSlinedge.EMleinit
                       (EMmsg, props, ME.EMSedge->curve_type, &poly, 
                        partolptr,NULL, NULL_OBJID));
    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_OMerror,wrapup);

    sts = om$send(msg = message EMSedge.EMreplace_edge(EMmsg, lin_edge, TRUE), 
					targetid = my_id);

/*****************************
					
    Function replaced by message. SM. Feb 14, 1989.
    sts = EMreplace_edge(EMmsg, lin_edge, my_id, TRUE);
*****************************/

    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

    /* Send parametric tolerance for the new space here.
       SM 01-Mar-92.
    */
    sts = om$send(msg = message EMSboundary.EMuv_transform
                 (EMmsg, matrix, partolbasis, option, null_ptr1, 
                  null_ptr2), targetid = lin_edge);

    /*
     * Return replacement info, If the caller has requested 
     * so.
     */

    if (null_ptr2)
    {
      rpl_info = (struct EMSuvtrans_info *) null_ptr2;
      if ((rpl_info->num_eds + 1) > rpl_info->eds_arrsz)
      {
        arrsz = rpl_info->eds_arrsz;
        EFmemory_allocation (&rc, (IGRchar **)&rpl_info->ed_ids,
                 rpl_info->num_eds+1, &arrsz, sizeof(GRobjid),
                 10, 5);
        EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

        EFmemory_allocation (&rc, (IGRchar **) &rpl_info->rpl_ed_ids,
                 rpl_info->num_eds+1, &rpl_info->eds_arrsz, 
                 sizeof(GRobjid), 10, 5);
        EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

      } /* if ((rpl_info->num_eds + 1) > rpl_info->eds_arrsz) */

      rpl_info->ed_ids[rpl_info->num_eds] = my_id;
      rpl_info->rpl_ed_ids[rpl_info->num_eds++] = lin_edge;

    } /* if (null_ptr2) */

  } /* if (option & EMS_TF_TRANSFORM_NE) */
			
wrapup:

   if(out_uv_curves)
    {
      EMdataselect_data_free(&rc, out_uv_curves, 1);
      om$dealloc(ptr = out_uv_curves);
    }

   if(out_xyz_curves)
    {
      EMdataselect_data_free(&rc, out_xyz_curves, 1);
      om$dealloc(ptr = out_xyz_curves);
    }

 if(curve.poles) om$dealloc(ptr = curve.poles);
 if(curve.knots) om$dealloc(ptr = curve.knots);
 if(curve.weights) om$dealloc(ptr = curve.weights);

  EMWRAPUP(*EMmsg, sts, "In EMSnatedge.EMuvtransform");
  return (sts);
}

end implementation EMSnatedge;
