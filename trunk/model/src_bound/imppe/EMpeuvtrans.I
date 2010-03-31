/* ###################   APOGEE COMPILED   ################## */
/*
 Notes
        If the incoming part edge is a part of antural edge, 
        after transformation it may become one of the following:
         o It is a part of natural edge.
         o It is a natural edge.
         o It is a linear edge.

        Depending upon the case the transformed part natural edge's
        class is appropriately changed.

        If the incoming edge is a part of linear edge or BS edge,
        it is collapsed and the transformation message is passed
        on to the collapsed edge.

History
        RC      04/29/87        Creation date
        RC      08/31/87        Modified the arguments and
                                the appropriate code.
        SM      09/02/87        Added the code for following
                                See if the part Nedge, after 
                                transformation is ON any natural edge.
                                If(partedge ON original natural edge)
                                {
                                  If end points match natural edge, 
                                    replace part edge by the natural edge.
                                  else re-evaluate the bounds on the 
                                   partedge and store them.
                                }
                                else
                                {
                                  replace part edge with linear edge.
                                }

       RC      11/05/87         If I am not a part of a natural edge,
                                collapse myself and transform the 
                                collapsed edge.

       RC      10/10/88         IF I am not a part of a natural edge,
                                collapse myself and transform the 
                                collapsed edge only if 
                                EMS_TF_NO_PE_TRANSFORM is not passed
                                as an option. If the user opts for
                                not transforming the partial edge,
                                it is his responsibility to transform 
                                the edge this partial edge is part of.
                                Also, if I am replaced by another edge
                                and the caller requests the replacement
                                info, return my_id and rpl_edge. The
                                replacement_info structure is passed
                                in null_ptr2.
        SM     01-Mar-92        Assuming that the incoming partol is for the 
			        new (transformed) parametric space, obtain the
			        partol for the old surface and use where
			        appropriate.

        Sudha  06/04/93         modified to include BSprototype header files
        SM     07/01/93         Use of EM2ddistptpts was incorrect.
        WBC    12/22/93         When constructing edges, set their curve type
                                to be the same as my (the current object)
                                curve type.
Algorithm
*/

class implementation EMSpartedge;

#include "EMS.h"
#include <stdio.h>
#include "emserr.h"
#include "emsmacros.h"
#include "OMmacros.h"
#include "bsparameters.h"
%safe
#include "math.h"
%endsafe
#include "emsedgedef.h"
#include "emsmapdef.h"
#include "emsdef.h"
#include "bserr.h"
#include "EMSbnd.h"
#include "emsdattyp.h"
#include "emssfint.h"
#include "mamulmx.h"

extern OMuword OPP_EMSnatedge_class_id, OPP_EMSlinedge_class_id;

from EMSnatedge import EMmake_natural_edge;
from EMSlinedge import EMleinit;

method EMuv_transform (
        IGRlong                 *EMmsg;
        IGRdouble               matrix[16];
        struct EMSpartolbasis   *partolbasis;
        IGRshort                option;
        IGRchar                 *null_ptr1;
        IGRchar                 *null_ptr2)

{
  OM_S_CHANSELECT         to_edge;
  struct EMSproj_info     proj_info;
  struct IGRbsp_curve     curve;
  struct IGRbsp_surface   *old_surf;
  struct EMSdataselect    *out_uv_curves, *out_xyz_curves;
  struct EMSsfintedpar    *ls_bdrys, **ls_bdrys_ptr;
  struct EMSuvtrans_info  *rpl_info;
  IGRdouble               old_endpt[2][2], mat_a[4], mat_c[4],  
                          new_endpt[2][2], nat_points[2][2], parsqtol, 
                          partol, cht_tol;
  IGRlong                 OM_stat, mthd_stat, rc;
  IGRint                  size, arrsz, num_out_curves;
  IGRboolean              status, pe_on_nat_edge;
  IGRshort                nat_edge_location, i, j, l, m, n, planar;
  GRobjid                 nat_id, rpl_edge = NULL_OBJID;
  IGRushort       props, map_options;
  IGRboolean              EFextract_par(), EFmap_the_curve();
  extern void             EMnatpoints(), EFmemory_allocation();
  struct EMSpartolbasis oldpartol, *partolptr = NULL;
  
  /* **************************************************************** */
	
  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  old_surf = (struct IGRbsp_surface *) null_ptr1;
  curve.poles = NULL;
  curve.knots = NULL;
  curve.weights = NULL;
  out_uv_curves = NULL;
  out_xyz_curves = NULL;
  num_out_curves = NULL;
  planar = EMS_O_NonPlanar;
  ls_bdrys = NULL;
  ls_bdrys_ptr = &ls_bdrys;
  
  if (!partolbasis->is_valid)
  {
    OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info (
                        &mthd_stat, NULL, partolbasis),
                       targetid = my_id);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
  }

  partolptr = partolbasis;
  if(partolbasis && old_surf)
   {
    oldpartol = *partolbasis;
    OM_stat = EFsspbtol_by_geom(&mthd_stat, old_surf, &oldpartol.tol);
    EMerr_hndlr(!(1&mthd_stat&OM_stat), *EMmsg, mthd_stat, wrapup);
    oldpartol.is_valid = TRUE;
    partolptr = &oldpartol;
   }

  /*
   * If I am a part of a natural edge, it may be possible
   * that after transformation, I will become a natural
   * edge. In such a case, replace myself with a natural edge.
   * On the other hand, if I donot become a natural edge, I will
   * have to change boundaries wrt new natural edge.
   */

  if (ME.EMSedge->ed_props & EMED_NATURAL)
  {
    
    to_edge.type = OM_e_addr;
    to_edge.u_sel.addr = &ME.EMSbd_owner->to_comps;

    /* Should use partol for new space here
       SM 01-Mar-92.
    */
    status = EFextract_par (BSTOLSQLENVEC, partolbasis->tol, 
                            &parsqtol, &mthd_stat);

    status = EFextract_par (BSTOLLENVEC, partolbasis->tol, 
                            &partol, &mthd_stat);

    OM_stat = om$send(msg = message EMSedge.EMendpts(&mthd_stat, 
                       (IGRdouble *)old_endpt, old_endpt[1], NULL, NULL, NULL), 
                      targetid = my_id);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

    l = m = 4;
    n = 1;

    size = 2 * sizeof(IGRdouble);

    for(i=0 ; i<2; i++)
    {
      OM_BLOCK_MOVE(old_endpt[i], mat_a, size);
      mat_a[2] = 0.0;
      mat_a[3] = 1.0;

      status = MAmulmx (&mthd_stat, &l, &m, &n, matrix, mat_a, mat_c);
      EMerr_hndlr((!status||!(1&mthd_stat)),*EMmsg,EMS_E_Fail,wrapup);

      /*
       * After transformation, if the u or v values go out of
       * (0 - 1) range and very small, it is an error
       * accumulated during matrix multiplication and
       * thus should be reduced to (0 - 1) range. 
       * tolerance should be considered here. -- SM.
       */

      for ( j = 0; j < 2; j++)
      {
         if ( fabs(mat_c[j] - 0.0) < partol) mat_c[j] = 0.0;
         if ( fabs(mat_c[j] - 1.0) < partol) mat_c[j] = 1.0;
      }

      OM_BLOCK_MOVE(mat_c, new_endpt[i], size);

    } /* for(i=0 ; i<2; i++) */

    pe_on_nat_edge = TRUE;
	
    OM_stat = om$send(msg = message EMSboundary.EMget_objid
                       (&mthd_stat, &nat_id), 
                      p_chanselect = &to_edge);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_EdgeError, wrapup);
	
    for(i=0; i<2; i++)
    {
      /* Should use partol for the new space.
         SM 01-Mar-92.
      */
      OM_stat = om$send(msg = message EMSedge.EMptproject(&mthd_stat, 
                         new_endpt[i], 1, &proj_info, NULL, partolbasis), 
                        targetid = nat_id);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_EdgeError, wrapup);

      if(proj_info.dist > partol)
      {
        pe_on_nat_edge = FALSE;
        break;
      }

    } /* for(i=0; i<2; i++) */
	
    if(!pe_on_nat_edge)
    {
       struct  IGRpolyline   poly;
	   struct  GRid			 curve_GRid,loopset_GRid;
		
      /* Replace myself by a linear edge. The new edge is NOT reversed
         because we obtained the geometry of the partedge in the
         direction of the edge for transforming it.
         Also the new edge is NON natural. Rest of the properties are
         transferred into the new edge.
	
         Feb 29, 1988 - 
         When replacing part natural edge with a linear edge, stoke the
         xyz geometry of the natural edge if the surface is non planar
         and if the natuaral xyz curve has order > 2.
      */
       
       if(old_surf && (!( (old_surf->u_order == 2) && 
	   (old_surf->v_order == 2))) &&
	   (! (ME.EMSedge->ed_props & EMED_DEGENERATE)))
        {
          OM_stat = om$send(msg = message EMSedge.EMget_bcxyz_geom
				(&mthd_stat, NULL, NULL, old_surf, 0, 
				 MAXINT, FALSE, NULL, &curve), 
				targetid = my_id);
	  EMerr_hndlr(!(1&mthd_stat&OM_stat), *EMmsg, EMS_E_EdgeError, 
					wrapup);
	  if(curve.order < 3) 
	   {
	    poly.num_points = 2;
	    poly.points = (IGRdouble *)new_endpt;
	   }
	  else
	   {
	    map_options = EMMapBnd_WantBadCurves | EMMapBnd_StrokeAlways
			| EMMapBnd_NoClip | EMMapBnd_NoCurveType 
			| EMMapBnd_NoRmvColEds;
	    num_out_curves = 0;
	    curve_GRid.objid = loopset_GRid.objid = NULL_OBJID;
	    BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht_tol);
	    /* Use partol for old space
	       SM 01-Mar-92
	    */
	    status = EFmap_the_curve(curve_GRid, &curve, old_surf, 
				  loopset_GRid, &cht_tol, 
				  partolptr, map_options, &planar, 
				  &num_out_curves, &out_uv_curves, 
				  &out_xyz_curves, NULL, &ls_bdrys_ptr, FALSE, 
				  &mthd_stat);
            EMerr_hndlr(!status, *EMmsg, EMS_E_Fail, wrapup);
	    if( (num_out_curves != 1) || 
	        (out_uv_curves[0].datatype != EMSdata_poly2d))
	     {
	      poly.num_points = 2;
	      poly.points = (IGRdouble *)new_endpt;
	      goto GotPtsForLinEdge;
	
	      /* *EMmsg = EMS_E_Fail; goto wrapup; */
	     }
	
	    poly = *(out_uv_curves[0].data.poly);

	    /* If this was a seam edge then the xyz to uv mapping 
	       might have resulted into the points being shifted to
	       the connected side of the surface.
   	    */
		
	    if(ME.EMSedge->ed_props & EMED_SEAM)
             {
                  IGRushort U_V_LOCATION;
		  IGRdouble U_V_VALUE;
		  IGRint ii;

                  OM_stat = om$send(msg = message EMSedge.EMget_location
			    (&mthd_stat, &nat_edge_location), 
			    p_chanselect = &to_edge);
                  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,
							wrapup);
               
		  U_V_LOCATION = nat_edge_location % 2;
 		  U_V_VALUE    = ( (nat_edge_location % 3) ? 1.00 : 0.00 );
	          for(ii=0; ii<poly.num_points; ii++)
		   {
		    poly.points[2*ii + U_V_LOCATION] = U_V_VALUE; /* SAM */
                   }
	       }
	      }
	    }
       else /* mapping necessary */
        {
         poly.num_points = 2;
         poly.points = (IGRdouble *)new_endpt;
	}

GotPtsForLinEdge:
       props = ME.EMSedge->ed_props & ~EMED_NATURAL & ~EMED_REVERSED;

       OM_stat = om$construct(classid = OPP_EMSlinedge_class_id, 
                              p_objid = &rpl_edge, 
                              msg = message EMSlinedge.EMleinit
                               (&mthd_stat, props, ME.EMSedge->curve_type, 
                                &poly, partolbasis,NULL, NULL_OBJID));
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_OMerror,wrapup);

       OM_stat = om$send(msg = message EMSedge.EMreplace_edge
			(&mthd_stat, rpl_edge, TRUE), 
			targetid = my_id);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

       /* If the new geometry for the linear is untransformed then
          we need to transform it.
       */
       if(poly.points != (IGRdouble *)new_endpt)
        OM_stat = om$send(msg = OPPmargs,targetid = rpl_edge);

    } /* if(!pe_on_nat_edge) */

    else
    {
       OM_stat = om$send(msg = message EMSedge.EMget_location(&mthd_stat,
                          &nat_edge_location), p_chanselect = &to_edge);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

       EMnatpoints(&mthd_stat, nat_edge_location, nat_points);

       /* 
        * If after transformation, the partedge matches the 
        * corresponding natural edge then replace it by a natural 
        * edge of that location.
        */

       if ( (EM2ddistptpts(new_endpt[0], nat_points[0]) < parsqtol) &&
            (EM2ddistptpts(new_endpt[1], nat_points[1])< parsqtol))
    
       {
        OM_stat = om$construct(classid = OPP_EMSnatedge_class_id, 
                              p_objid = &rpl_edge, 
                              msg = message EMSnatedge.EMmake_natural_edge
                               (&mthd_stat, nat_edge_location,
                                &ME.EMSedge->curve_type, NULL));
          EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_OMerror,wrapup);

          /* 
           * Transfer my properties into the new natural edge. The new
	   * edge is NOT reversed.
           */
	  
         props = ME.EMSedge->ed_props & ~EMED_REVERSED;
         OM_stat = om$send(msg = message EMSedge.EMset_props(
                            &mthd_stat, props, EMS_O_ON), 
                           targetid = rpl_edge);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

	OM_stat = om$send(msg = message EMSedge.EMreplace_edge
				(&mthd_stat, rpl_edge, TRUE), 
				targetid = my_id);
	/**********************
				
	  Function replaced by message. SM. 14 Feb, 1989.
	
         OM_stat = EMreplace_edge(&mthd_stat, rpl_edge, my_id, TRUE);
	************************/

        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

       } /* if ( (EM2ddistptpts(new_endpt[0], nat_points[0]) < parsqtol) &&
            (EM2ddistptpts(new_endpt[1], nat_points[1])< parsqtol)) */

       else
       {
          IGRboolean    off_edge[2];

          /* 
           * If the partedge does not match the natural edge 
           * then evaluate the new parametric bounds for the 
           * partial edge and store them.
           */

          OM_stat = om$send (msg = message EMSedge.EMpratpt ( &mthd_stat,
                           (IGRdouble *)new_endpt, 2, ME.EMSpartedge->boundary, 
                              off_edge, NULL, partolbasis),
                             p_chanselect = &to_edge);
          EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

       } /* else for if ( (EM2ddistptpts(new_endpt[0], nat_points[0]) < 
                           parsqtol) &&
            (EM2ddistptpts(new_endpt[1], nat_points[1])< parsqtol)) */

    } /* else for if(!pe_on_nat_edge) */
	
  } /* if (ME.EMSedge->ed_props & EMED_NATURAL) */
	
  else 
  {
    if (!(option & EMS_TF_NO_PE_TRANSFORM))
    {

      OM_stat = om$send (msg = message EMSboundary.EMcompress_top(
                          &mthd_stat, partolptr, &rpl_edge), 
                         targetid = my_id);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

      OM_stat = om$send (msg = OPPmargs, targetid = rpl_edge);
      EMerr_hndlr(!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);

    } /* if (!(option & EMS_TF_NO_PE_TRANSFORM)) */

  } /* else for if (ME.EMSedge->ed_props & EMED_NATURAL) */

  /*
   * If I have been replaced by another edge and the caller
   * has requested for replacement information, return this info.
   */

  if (rpl_edge != NULL_OBJID && null_ptr2)
  {
    rpl_info = (struct EMSuvtrans_info *) null_ptr2;
    if ( (rpl_info->num_eds + 1) > rpl_info->eds_arrsz)
    {
      arrsz = rpl_info->eds_arrsz;
      EFmemory_allocation (&rc, (IGRchar **) &rpl_info->ed_ids,
               rpl_info->num_eds+1, &arrsz, sizeof(GRobjid),
               10, 5);
      EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

      EFmemory_allocation (&rc, (IGRchar **) &rpl_info->rpl_ed_ids,
               rpl_info->num_eds+1, &rpl_info->eds_arrsz, sizeof(GRobjid),
               10, 5);
      EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

    } /* if ( (rpl_info.num_eds + 1) > eds_arrsz) */

    rpl_info->ed_ids[rpl_info->num_eds] = my_id;
    rpl_info->rpl_ed_ids[rpl_info->num_eds++] = rpl_edge;

  } /* if (rpl_edge != NULL_OBJID && null_ptr2) */

wrapup:

   if(ls_bdrys)
      EMsfintedpar_free(ls_bdrys, NULL);

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

   EMWRAPUP (*EMmsg, OM_stat, "In EMSpartedge.EMuv_transform");
   
   return (OM_stat);

}

end implementation EMSpartedge;
