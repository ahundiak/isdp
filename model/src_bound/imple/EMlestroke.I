/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlinedge;

#include "OMmacros.h"
#include "emsmacros.h"                  /* for EMWRAPUP */
#include "bstypes.h"                    /* for BSrc */
#include "bserr.h"                      /* for BSSUCC */
#include "bsparameters.h"               
#include "emsmapdef.h"			/* mapping options	*/
#include "emsdef.h"

%safe
#include <math.h>			/* fabs	*/
%endsafe

#include "emsedgedef.h"
#include "EMS.h"
#include "bschtptstcv.h"
#include "bsactivsplt.h"
#include "bsconstprcv.h"

#define CONSTANT_U	1
#define CONSTANT_V	2

#ifndef DEBUG
#define DEBUG	0
#endif

from GRvg   import GRgetsize, GRgetgeom;
from EMSpartedge import EMchange_bounds;

method EMstroke_iso_edge (
  IGRlong               *EMmsg;
  IGRmatrix		matrix;
  IGRshort		*mx_type;
  struct GRid           *srf_id;
  struct IGRbsp_surface *srf_geom;
  IGRboolean            reverse;
  struct EMSpartolbasis	*my_partol;
  GRobjid		user_id;
  struct IGRpolyline	*stroked_geom;
  IGRboolean		update_instance_data)


/*

History  
	15-Nov-88	SM	Reworked RV's code so that explicit mapping is
				avoided (xyz to uv).

        Sudha   07/06/93        modified for BSprototype includes
Notes 



*/

{
    IGRboolean		    reversal,  whole_iso;
    IGRdouble               cht_tol, iso_par, beg_par, end_par, 
			    temp_par;
    IGRlong                 OM_stat, mthd_stat;
    BSrc                    rc;
    IGRshort                option = NULL,  
			    num_poles, order;
    struct IGRbsp_surface   *surface;
    struct IGRbsp_curve     temp_crv1, temp_crv2, *final_crv;
    IGRboolean              status, tst_planar;
    struct GRid		    dummy_GRid;
    IGRint		    vla_size, srf_size, i;
    struct GRmdenv_info     mdenv;
    struct IGRpolyline	    insert_poly, uvgeom;
    IGRuchar	    new_pe_curve_type;
    IGRdouble		    points[4], *params = NULL;
    IGRushort	    edprops = NULL;
    IGRint		    num_params = 0;

    *EMmsg = EMS_S_Success;
    OM_stat = OM_S_SUCCESS;

#if DEBUG
   fprintf(stderr, "\n Stroking Iso Edge %d\n", my_id);

#endif

    temp_crv1.poles = temp_crv1.knots = temp_crv1.weights = NULL;
    temp_crv2.poles = temp_crv2.knots = temp_crv2.weights = NULL;
    uvgeom.points = NULL;

    BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht_tol);
    dummy_GRid.objid = NULL_OBJID;
    dummy_GRid.osnum = OM_Gw_current_OS;
    if(IF_NULL_OBJID(user_id)) user_id = my_id;

    surface = srf_geom;

    /*
     * find out if the surface is passed along
     */

    if (!surface )
    {
     if (srf_id)
     {
       OM_stat = om$send (msg = message GRvg.GRgetsize(&mthd_stat,
                        mx_type, matrix, (IGRlong *)&srf_size),
                       targetid = srf_id->objid);
       EMerr_hndlr (!(1&mthd_stat&OM_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

       surface = (struct IGRbsp_surface *) om$malloc (size = srf_size);
       EMerr_hndlr (!(surface),*EMmsg,EMS_E_NoDynamicMemory,wrapup);
    
       OM_stat = om$send(msg = message GRvg.GRgetgeom (&mthd_stat,
                                 mx_type, matrix, (IGRchar *) surface),
                       targetid = srf_id->objid);
       EMerr_hndlr (!(1&mthd_stat&OM_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
     }
     else
     {
       mdenv.matrix_type = *mx_type;
       OM_BLOCK_MOVE (matrix, mdenv.matrix, sizeof (IGRmatrix));

       OM_stat = om$send (msg = message EMSedge.EMget_sf_geom(
                           &mthd_stat, srf_id, &surface, &mdenv),
                          targetid = user_id);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
     }
    } /* if (!surface ) */


/* Get the end points in the direction of actual geometry. We will apply
   the reversal at the end. If the instance data is to be updated, forget
   about the partedge (user_id).
*/
    if(update_instance_data || IF_EQ_OBJID(user_id, my_id))
     {
      OM_BLOCK_MOVE(ME.EMSlinedge->points, points, 4 * sizeof(IGRdouble));
      edprops = ME.EMSedge->ed_props;
     }
    else
     {
      OM_stat = om$send(msg = message EMSedge.EMget_props 
			(&mthd_stat, &edprops), 
				targetid = user_id);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

      OM_stat = om$send(msg = message EMSedge.EMendpts 
		(&mthd_stat, edprops & EMED_REVERSED ? &points[2] : points, 
		 edprops & EMED_REVERSED ? points : &points[2], 
		 NULL, NULL, NULL), targetid = user_id);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
     }

    reversal = FALSE;
    if (fabs(points[0] - points[2]) < fabs(points[1] - points[3]))
    {
       option = CONSTANT_U;
       iso_par = (points[0] + points[2])/2;
       beg_par = points[1];
       end_par = points[3];
    }
    else
    {
       option = CONSTANT_V;
       iso_par = (points[1] + points[3])/2;
       beg_par = points[0];
       end_par = points[2];
    }

    if (beg_par > end_par)
    {
      temp_par = beg_par;
      beg_par = end_par;
      end_par = temp_par;
      reversal = !reversal;
    }

    if (beg_par != 0.0 || end_par != 1.0)  whole_iso = FALSE;
    else whole_iso = TRUE;

    if ( option == CONSTANT_U)
    {
       num_poles = surface->v_num_poles;
       order = surface->v_order;
    }
    else
    {
       num_poles = surface->u_num_poles;
       order = surface->u_order;
    }

    temp_crv1.poles = (IGRdouble *) om$malloc(size=(int) num_poles *
                                                sizeof(IGRpoint));
    EMerr_hndlr(!temp_crv1.poles,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

    temp_crv1.knots =  (IGRdouble *) om$malloc (size = (int) 
                                 (num_poles + order) * sizeof(IGRdouble));
    EMerr_hndlr(!temp_crv1.knots,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

    if (surface->rational)
    {
      temp_crv1.weights = (IGRdouble *) om$malloc (size = (int) 
                                     num_poles * sizeof(IGRdouble));
      EMerr_hndlr(!temp_crv1.weights,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
    }
    else temp_crv1.weights = NULL;
 
    /* 
     * extract b_spline curve from the surface
     */

    tst_planar = TRUE;
    status = BSconstprcv (&rc, surface, &option, &iso_par, &tst_planar, 
                          &temp_crv1);
    EMerr_hndlr (!status || rc!=BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
        
    /*
     * extract part of the iso curve if required.
     */

     if (!whole_iso)
     {
	IGRboolean test_planar = TRUE;

/**************
       if (temp_crv1.phy_closed)  mid_par = (beg_par + end_par)/2.0;
       else mid_par = NULL;
***************/

       num_poles = num_poles + 2*order - 1;

       temp_crv2.poles = (IGRdouble *) om$malloc(size =
                              num_poles * sizeof(IGRpoint));
       EMerr_hndlr(!temp_crv2.poles,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

       temp_crv2.knots =  (IGRdouble *) om$malloc (size =  
                 (num_poles + order) * sizeof(IGRdouble));
       EMerr_hndlr(!temp_crv2.knots,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

       if (surface->rational)
       {
         temp_crv2.weights = (IGRdouble *) om$malloc (size = 
                                      num_poles * sizeof(IGRdouble));
         EMerr_hndlr(!temp_crv2.weights,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
       }
       else temp_crv2.weights = NULL;

/******************************
       status = BSpartofcv (&rc, &temp_crv1, beg_par, mid_par, end_par, 
                            &temp_crv2);
       EMerr_hndlr (!status || rc != BSSUCC, *EMmsg,EMS_E_BSerror,wrapup);
*******************************/

       /* Call BSactivsplt() so that parametrization is maintained. In
	  case of a closed curve, we will never be extracting across seam
	  because the iso edge cannot cross over the surface seams.
	*/
	
       status = BSactivsplt(&rc, &temp_crv1, &beg_par, &end_par, &temp_crv2, 
			&test_planar);
       EMerr_hndlr (!status || rc != BSSUCC, *EMmsg,EMS_E_BSerror,wrapup);
       final_crv = &temp_crv2;
     }
     else final_crv = &temp_crv1;

     /* Stroke the xyz curve and retain the parameters returned. These
	parameters are directly the non constant cordinates in uv space
	for the iso edge.     
     */
     {
      IGRpoint *junkpoints = NULL;

      BSchtptstcv(final_crv, &num_params, &junkpoints, &params, &rc);
      if(junkpoints) free(junkpoints);
      EMerr_hndlr (rc != BSSUCC, *EMmsg,EMS_E_BSerror,wrapup);
     }


     uvgeom.points = (IGRdouble *) om$malloc(size = num_params * 2 * 
		     sizeof(IGRdouble));
     EMerr_hndlr(!uvgeom.points, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     uvgeom.num_points = num_params;

     for(i=0; i<num_params; i++)
      {
	if(option == CONSTANT_U)
	 {
	   uvgeom.points[i * 2] = iso_par;
	   uvgeom.points[i * 2 + 1] = params[i];
	 }
	else if(option == CONSTANT_V)
	 {
	   uvgeom.points[i * 2] = params[i];
	   uvgeom.points[i * 2 + 1] = iso_par;
	 }
	else {*EMmsg = EMS_E_Fail; goto wrapup;}
      }

     /* Applying the reversal flag at this point will give us the actual stoked
	geometry as it should have been in the instance data. Now we still
	have to use edge reversal property and on top of that the input reverse
	flag. However if we are updating the instance data of the edge then
	the edge reversal can be ignored. In case of updating the
	instance data, we will post the stroked geometry
	in the same direction as before (except that it will now be stroked)
	and maintain the reversed property of the edge.
	SM 15-Nov-88.
     */
     if(!update_instance_data && (edprops & EMED_REVERSED))
	reversal = !reversal;
	
     if (reverse) reversal = !reversal;

     if (reversal)
     {
      EMrevpyline (&rc, &uvgeom, 2, NULL);
      EMerr_hndlr(!(1&rc), *EMmsg, EMS_E_Fail, wrapup);
     }

    if(update_instance_data)
     {
	
#if DEBUG
      fprintf(stderr, "\n Making %d edge Non Iso\n", my_id);
#endif

      if(uvgeom.num_points == 1) ME.EMSedge->curve_type = EMpoint;
      else if(uvgeom.num_points ==2) ME.EMSedge->curve_type = EMlinesegment;
      else ME.EMSedge->curve_type = EMlinestring;
      ME.EMSedge->ed_props &= ~EMED_ISO;

      OM_stat = EFget_clipped_edge_type(EMmsg, ME.EMSedge->curve_type, 
					&new_pe_curve_type);

      if ((vla_size = om$dimension_of (varray = ME.EMSlinedge->points)) < 
			      	2*uvgeom.num_points)
         om$vla_set_dimension (varray = ME.EMSlinedge->points, 
     				size = vla_size+2*uvgeom.num_points);
      OM_BLOCK_MOVE (uvgeom.points, ME.EMSlinedge->points, 
      				uvgeom.num_points * 2 * sizeof (IGRdouble));

      ME.EMSlinedge->num_points = uvgeom.num_points;

      /* Update part-edges' bounds */

      insert_poly.num_points = uvgeom.num_points - 2;
      insert_poly.points = &uvgeom.points[1];

      OM_stat = EMsend_partedges(&mthd_stat, 
				 message EMSpartedge.EMchange_bounds
		(EMmsg, 1, &insert_poly, NULL, &uvgeom, &new_pe_curve_type, 
		 NULL,
		 &ME.EMSedge->ed_props, TRUE, NULL, my_partol), 
		 my_id, 0, MAXINT, NULL, NULL, NULL);
      EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);      
     }
    
    if(stroked_geom)
     {
      stroked_geom->points = (IGRdouble *) om$malloc(size = uvgeom.num_points * 2 *
					sizeof(IGRdouble));
      EMerr_hndlr(!stroked_geom->points, *EMmsg, EMS_E_NoDynamicMemory, 
			wrapup);
      OM_BLOCK_MOVE(uvgeom.points, stroked_geom->points, 
			2 * uvgeom.num_points * sizeof(IGRdouble));
      stroked_geom->num_points = uvgeom.num_points;
     }

wrapup:

  if (!srf_geom && surface) om$dealloc (ptr = surface);

  if (temp_crv1.poles) om$dealloc (ptr = temp_crv1.poles);
  if (temp_crv1.knots) om$dealloc (ptr = temp_crv1.knots);
  if (temp_crv1.weights) om$dealloc (ptr = temp_crv1.weights);

  if (temp_crv2.poles) om$dealloc (ptr = temp_crv2.poles);
  if (temp_crv2.knots) om$dealloc (ptr = temp_crv2.knots);
  if (temp_crv2.weights) om$dealloc (ptr = temp_crv2.weights);

/****************************
  if (mapped_crv_uv)
   {
    EMdataselect_data_free(&rc, mapped_crv_uv, 1);
    om$dealloc(ptr = mapped_crv_uv);
   }

  if (mapped_crv_xyz)
   {
    EMdataselect_data_free(&rc, mapped_crv_xyz, 1);
    om$dealloc(ptr = mapped_crv_xyz);
   }
*******************************/

  if(uvgeom.points) om$dealloc(ptr = uvgeom.points);
  if(params) om$dealloc(ptr = params);

  EMWRAPUP (*EMmsg, OM_stat, "In EMSlinedge.EMstroke_iso_edge")
 
 return (OM_stat);

}




/*************************************
 Following mapping code was removed. 15-Nov-88 SM.

     map_option = EMMapBnd_StrokeAlways | EMMapBnd_NoCurveType | 
	      EMMapBnd_WantBadCurves | EMMapBnd_NoClip;
     is_planar = EMS_O_NonPlanar;

     if(!my_partol->is_valid)
      {
       OM_stat = EFsspbtol_by_geom(EMmsg, surface, &my_partol->tol);
       EMerr_hndlr (!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
       my_partol->is_valid = TRUE;
      }

     status = EFmap_the_curve(dummy_GRid, final_crv, surface, dummy_GRid,
		     &cht_tol, my_partol, map_option, &is_planar,
		     &num_mapped_crv, &mapped_crv_uv, 
		     &mapped_crv_xyz, NULL, NULL, TRUE, EMmsg);
		
     EMerr_hndlr (!(1&*EMmsg) || !status, *EMmsg, EMS_E_Fail, wrapup);

      if( (num_mapped_crv != 1) ||
	  (mapped_crv_uv && mapped_crv_uv[0].datatype != EMSdata_poly2d)
	 || (!mapped_crv_uv))
       {
	*EMmsg = EMS_E_Fail;
	goto wrapup;
       }

      poly = (struct IGRpolyline *) mapped_crv_uv[0].data.poly;

      ME.EMSlinedge->num_points = poly->num_points;

*************************************/
      

end implementation EMSlinedge;

