class implementation EMSproject;
/*
Description

This override computes the intersection data between a non-planar surface of
projection (without scaling) and a special plane. It returns bspline
curve data for the plane and stroked points for the sf-of-proj. The
data returned is trimmed with the natural bounds of the two surfaces.
It also returns intelligent curve-type for the intersection data.

History

05/xx/88 : RV  : Creation.  
09/29/88 : DLB : Deleted natural loopset created for call to EFmap_the_crv. 
09/30/88 : DLB : Changed wrapup send of OPPmargs to the expanded
                 form with the classname of EMSsubbs.
11/04/88 : rlw : Reworked
01/11/89 : rlw : Modified to return flag indicating if resulting edges are iso.
02/02/89 : rlw : Modified to support return of correlation information used
                 to map trim points from the BS edge to the linear edge.
02/07/89 : SS  : Modified the call to EFmap_the_curve to treat the clipping
                 boundary as area. This prevents intersections along seams
                 to be clipped off.
02/24/89 : rlw : Modified to not flag linear intersections as iso.
09/12/89 : SM  : If isoness is incorrectly determined (which is detected
		 after special map from xyz to uv), call the method recursively
		 ,this time overriding isocheck.
08/19/92 : NP  : Modified for ANSI compliance. Added missing typecasts.
*/

#include "bsconic.h"		/* Conic properties */
#include "msdef.h"		/* MSINARG */
#include "EMSbnddef.h"		/* Watermark for iso edges */
#include "EMSbnd.h"		/* Compiler seems to want this */
#include "EMSproject.h"		/* Compiler seems to want this */
#include "EMSmsgdef.h"		/* EMS message codes */
#include "bserr.h"		/* BS error return codes */
#include "bsparameters.h"	/* BSEXTRACTPAR macro */
#include "emsedgedef.h"		/* edge types */
#include "emsmapdef.h"		/* mapping options */
#include "EMSssprops.h"		/* EMSformat defines */
#include "emssfintdef.h"	/* intinfo flags */
#include "emsinterdef.h"	/* EMS_INTER_NOISO */

from EMSrevol import EMget_int_data;
from EMSloopset import EMmake_natural_loopset;

extern OMuword OPP_EMSloopset_class_id;
extern OMuword OPP_EMSplane_class_id, OPP_EMAplane_class_id;
extern OMuword OPP_EMScylindr_class_id, OPP_EMAcylindr_class_id;
extern OMuword OPP_EMSpcylindr_class_id, OPP_EMApcylindr_class_id;
extern OMuword OPP_EMSelpcyl_class_id, OPP_EMAelpcyl_class_id;
extern OMuword OPP_EMScone_class_id, OPP_EMAcone_class_id;
extern OMuword OPP_EMSpcone_class_id, OPP_EMApcone_class_id;
extern OMuword OPP_EMSelpcone_class_id, OPP_EMAelpcone_class_id;

extern IGRboolean _new_sfsfint_math;

method EMget_int_data (
 IGRlong                       *EMmsg;
 IGRushort             options;
 struct EMSdataselect          *other_data;
 struct IGRbsp_surface         *my_geom;
 struct IGRbsp_surface         *other_geom;
 IGRdouble		       *my_uvrange;
 IGRdouble		       *other_uvrange;
 struct EMSpartolbasis         *my_partol;
 struct EMSpartolbasis         *other_partol;
 IGRint                        *num_out_cvs;
 struct EMSdataselect          **my_xyz_data;
 struct EMSdataselect          **other_xyz_data;
 struct EMSdataselect          **my_uv_data;
 struct EMSdataselect          **other_uv_data;
 IGRdouble		       ***correlation;
 IGRchar                       *curve_type;
 IGRushort             *intinfo)

{
 IGRboolean	project_along_v, is_iso_edge, is_revolution, 
		incorrect_iso = FALSE;
 OMuword	my_classid;
 IGRlong	sts, number_of_curves, edge_type;
 struct		IGRbsp_curve **curves;
 IGRvector	plane_normal;
 IGRpoint	plane_point;
 struct		IGRplane plane;
/*
 * Initialize
 */
 *EMmsg = EMS_S_Success;
 number_of_curves = 0;
 curves = NULL;
 *num_out_cvs = 0;
 *my_xyz_data = NULL;
 *other_xyz_data = NULL;
 *my_uv_data = NULL;
 *other_uv_data = NULL;
 *correlation = NULL;
 *intinfo = 0;			/* See emssfintdef.h */
 is_revolution = FALSE;

 if (_new_sfsfint_math)
     return (om$send(
      mode = OM_e_wrt_message,
      msg = message EMSsubbs.EMget_int_data(
       EMmsg,
       options,
       other_data,
       my_geom,
       other_geom,
       my_uvrange,
       other_uvrange,
       my_partol,
       other_partol,
       num_out_cvs,
       my_xyz_data,
       other_xyz_data,
       my_uv_data,
       other_uv_data,
       correlation,
       curve_type,
       intinfo),
      targetid = my_id));

/*
 * Give it up if I am planar or I was created by sweeping a linestring.
 * This can create problems if dealt with in this method because both
 * xyz intersections are linestrings.  Because I do some optimzations
 * to produce only the minimumal number of points on iso_edge 
 * intersections, my model space intersection, if linear, should never
 * be output as it will not contain all the required vertices.
 */
 if (my_geom->planar ||
     ((my_geom->u_order == 2) &&
      (my_geom->v_order == 2)))
  {
   *EMmsg = EMS_I_NoSolution;
   goto wrapup;
  }
/*
 * Determine what kind of surface I am
 */
 sts = om$get_classid(
   object = me,
   p_classid = &my_classid);
  if (! (1 & sts))
   {
    *EMmsg = EMS_E_OMerror;
    goto wrapup;
   }
/*
 * Determine whether I am projected along u or v.
 * If the error return code is not success then
 * the routine was unable to determine this information.
 */
 sts = om$send(
   msg = message EMSproject.EMgetDirection(
    EMmsg,
    my_geom,
    &project_along_v),
   targetid = my_id);
  if (*EMmsg != EMS_S_Success) goto wrapup;
/*
 * Determine whether I am a surface of projection
 * with scaling.  This method cannot handle surfaces
 * that are scaled.
 */
 if ((me->ss_props & EMSformat) == EMSprojectedFormat)
  {
   struct	EMSprojectedSurfaceHeader *instance_data;
   IGRuchar 	format;

   instance_data = (struct EMSprojectedSurfaceHeader *) me->packed_data;
   format = (IGRuchar) (instance_data->pj_props & EMS_PJ_SUBTYPE);
   if (format == EMSIS_PJ_SCALED)
    {
     *EMmsg = EMS_I_NoSolution;
     goto wrapup;
    }
  }
 else if ((my_classid != OPP_EMScylindr_class_id) &&
          (my_classid != OPP_EMAcylindr_class_id) &&
          (my_classid != OPP_EMSelpcyl_class_id) &&
          (my_classid != OPP_EMAelpcyl_class_id) &&
          (my_classid != OPP_EMApcylindr_class_id) &&
          (my_classid != OPP_EMSpcylindr_class_id))
  {
   if ((my_classid == OPP_EMScone_class_id) ||
       (my_classid == OPP_EMAcone_class_id) ||
       (my_classid == OPP_EMApcone_class_id) ||
       (my_classid == OPP_EMSpcone_class_id))
    is_revolution = TRUE;
   *EMmsg = EMS_I_NoSolution;
   goto wrapup;
  }
/*
 * Determine if the other surface is a special plane and
 * determine the equation of this plane.
 */
 if (other_data->datatype == EMSdata_plane)
  {
   struct	IGRplane *input_plane;

   input_plane = other_data->data.plane;
   plane.point =  input_plane->point;
   plane.normal = input_plane->normal;
  } /* if (other_data->datatype == EMSdata_plane) */
 else
  {
   IGRboolean	is_special_plane;

   is_special_plane = FALSE;
   if (other_data->datatype == EMSdata_surface)
    other_geom = other_data->data.surface;
   else if (other_data->datatype == EMSdata_object)
    {
     OMuword	other_classid;
     struct	GRid *id;

     id = other_data->data.object;
     sts = om$get_classid(
       objid = id->objid,
       osnum = id->osnum,
       p_classid = &other_classid);
      if (! (1 & sts))
       {
        *EMmsg = EMS_E_OMerror;
        goto wrapup;
       }
     if (other_classid == OPP_EMSplane_class_id ||
         other_classid == OPP_EMAplane_class_id)
      is_special_plane = TRUE;
    } /* ELSE FOR else if (other_data->datatype == EMSdata_object) */
   if (! is_special_plane)
    {
     extern	IGRboolean EFis_linear_map_ok();
     IGRboolean	status;

     status = EFis_linear_map_ok(
       EMmsg,
       other_geom,
       &is_special_plane);
      if ((! status) ||
          (! (1 & *EMmsg)))
       {
        *EMmsg = EMS_E_Fail;
        goto wrapup;
       }
    } /* if (! is_special_plane) */
   if (is_special_plane)
    {
     extern	void BStst_plan();
     IGRboolean	is_planar;
     IGRlong	loc_msg;

     plane.point =  plane_point;
     plane.normal = plane_normal;
     plane_point[0] = other_geom->poles[0];
     plane_point[1] = other_geom->poles[1];
     plane_point[2] = other_geom->poles[2];
     BStst_plan(			/* Special planes are not rational */
       other_geom->u_num_poles * other_geom->v_num_poles,
       other_geom->poles,
       NULL,
       &is_planar,
       plane_normal,
       &loc_msg);
      if (loc_msg != BSSUCC)
       {
        *EMmsg = EMS_E_BSerror;
        goto wrapup;
       }
     if (!is_planar)			/* Impossible */
      {
       *EMmsg = EMS_E_Fail;
       goto wrapup;
      }
    } /* if (special_plane) */
   else
    {
     *EMmsg = EMS_I_NoSolution;
     goto wrapup;
    } /* ELSE FOR if (special_plane) */
  } /* ELSE FOR if (other_data->datatype == EMSdata_plane) */
/*
 * At this point I know the following:
 *
 * I am a surface of projection.
 * I know whether or not I am scaled.
 * I know that the other object is a special plane.
 * I know the equation of the plane defining the other object.
 */
/*
 * Intersect the surface of projection with the infinite plane
 */
 {
  extern	IGRlong EFintersect_sf_of_proj_with_plane();
  IGRlong	sts, base_curve_type;

  if ((my_classid == OPP_EMScylindr_class_id) ||
      (my_classid == OPP_EMAcylindr_class_id) ||
      (my_classid == OPP_EMSpcylindr_class_id) ||
      (my_classid == OPP_EMApcylindr_class_id))
   base_curve_type = BSCCIRCLE;
  else if (my_classid == OPP_EMSelpcyl_class_id ||
           my_classid == OPP_EMAelpcyl_class_id)
   base_curve_type = BSCELLIPSE;
  else
   base_curve_type = BSCUNKNOWNTYPE;
  sts = EFintersect_sf_of_proj_with_plane(
    my_geom,
    project_along_v,
    &plane,
    base_curve_type,
    &is_iso_edge,
    &edge_type,
    &number_of_curves,
    &curves,
    EMmsg);
   if ((! (1 & *EMmsg)) ||
       (*EMmsg == EMS_I_NoSolution) ||
       (*EMmsg == EMS_I_NoIntersection))
    goto wrapup;

  /* Following override of isoness introduced.
   * SM 12-Sep-89
  */
  if(is_iso_edge && (options & EMS_INTER_NOISO))
   {
    is_iso_edge = FALSE;
    if(edge_type == EMcircle) edge_type = EMellipse;
    else if(edge_type == EMcircular_arc) edge_type = EMelliptical_arc;
   }

  if (is_iso_edge) *intinfo |= EMSintdata_isoedge;
 }
/*
 * We know have one or more intersection curves which are
 * clipped to the natural surface.  Now we need to clip these
 * curves to the natural loopset of the plane.
 */
 if (other_data->datatype != EMSdata_plane)
  {
   OMuword	object_space_number;
   IGRboolean	was_data_clipped;
   IGRlong	EFmap_intersection_to_special_plane();

   object_space_number = OM_Gw_current_OS;
   sts = EFmap_intersection_to_special_plane(
     number_of_curves,
     curves,
     object_space_number,
     other_geom,
     other_partol,
     &was_data_clipped,
     num_out_cvs,
     other_uv_data,
     other_xyz_data,
     EMmsg);
    if (! sts) goto wrapup;
   if (*num_out_cvs == 0)
    {
     *EMmsg = EMS_I_NoIntersection;
     goto wrapup;
    }
   if (was_data_clipped)
    {
     switch (edge_type)
      {
       case EMcircle:
        edge_type = EMcircular_arc;
        break;
       case EMellipse:
        edge_type = EMelliptical_arc;
        break;
       default:
        break;
      } /* switch (edge_type) */
    } /* if (was_data_clipped) */
  } /* if (other_data->datatype != EMSdata_plane) */
/*
 * If the plane is infinite then he has no uv data.
 * In this case the xyz data is the same as that generated
 * earlier.
 */
 else
  {
   IGRlong	i;

   *other_xyz_data = (struct EMSdataselect *) malloc(
     number_of_curves * sizeof(struct EMSdataselect));
    if (! *other_xyz_data)
     {
      *EMmsg = EMS_E_NoDynamicMemory;
      goto wrapup;
     }
   for (i = 0; i < number_of_curves; i++)
    {
     (*other_xyz_data)[i].datatype = EMSdata_curve3d;
     (*other_xyz_data)[i].data.curve = curves[i];
    } /* for (i = 0; i < number_of_curves; i++) */
   *num_out_cvs = number_of_curves;
   free(curves);
   number_of_curves = 0;
   curves = NULL;
  } /* ELSE FOR if (other_data->datatype != EMSdata_plane) */
 *curve_type = edge_type;
/*
 * At this point we have the following:
 *
 * num_out_cvs    - The number of intersection curves
 * other_xyz_data - The model space data for the plane
 * other_uv_data  - The parameteric space data on the plane, unless it's 
 *                  infinite.
 * curve_type     - The edge type
 *
 * We need the following:
 *
 * my_xyz_data    - My model space data
 * my_uv_data     - My parametric space data
 */
 {
  extern	IGRlong EFspecial_map_xyz_to_uv();
  IGRlong	type, water_mark, i, number_of_points, msg;
  IGRdouble	*knots;
  IGRpoint	*xyz_data;
  BSpair	*uv_data;
  struct	IGRpolyline *poly;
  struct	IGRbsp_curve *curve_to_clip, static_curve;

  water_mark = LinearToIsoWaterMark + 1;
  if ((my_classid == OPP_EMScylindr_class_id)  ||
      (my_classid == OPP_EMAcylindr_class_id)  ||
      (my_classid == OPP_EMSpcylindr_class_id) ||
      (my_classid == OPP_EMApcylindr_class_id) ||
      (my_classid == OPP_EMScone_class_id)     ||
      (my_classid == OPP_EMAcone_class_id)     ||
      (my_classid == OPP_EMSpcone_class_id) ||
      (my_classid == OPP_EMApcone_class_id))
   type = BSCCIRCLE;
  else if ((my_classid == OPP_EMSelpcyl_class_id) ||
           (my_classid == OPP_EMAelpcyl_class_id) ||
           (my_classid == OPP_EMSelpcone_class_id) ||
           (my_classid == OPP_EMAelpcone_class_id))
   type = BSCELLIPSE;
  else
   type = BSCUNKNOWNTYPE;
  *my_xyz_data = (struct EMSdataselect *) malloc(
    *num_out_cvs * sizeof(struct EMSdataselect));
   if (! *my_xyz_data)
    {
     *EMmsg = EMS_E_NoDynamicMemory;
     goto wrapup;
    }
  for (i = 0; i < *num_out_cvs; i++)
   (*my_xyz_data)[i].datatype = EMSdata_null;
  *my_uv_data = (struct EMSdataselect *) malloc(
    *num_out_cvs * sizeof(struct EMSdataselect));
   if (! *my_uv_data)
    {
     *EMmsg = EMS_E_NoDynamicMemory;
     goto wrapup;
    }
  for (i = 0; i < *num_out_cvs; i++)
   (*my_uv_data)[i].datatype = EMSdata_null;
  *correlation = (IGRdouble **) malloc(
    *num_out_cvs * sizeof(IGRdouble *));
   if (! *correlation)
    {
     *EMmsg = EMS_E_NoDynamicMemory;
     goto wrapup;
    }
  for (i = 0; i < *num_out_cvs; i++)
   (*correlation)[i] = NULL;
  for (i = 0; i < *num_out_cvs; i++)
   {
    knots = NULL;
    if ((*other_xyz_data)[i].datatype == EMSdata_poly3d)
     {
      extern		IGRboolean MApytobc();
      IGRboolean	status;
      IGRlong		num_knots;

      if (is_iso_edge) *intinfo &= ~EMSintdata_isoedge;
      poly = (*other_xyz_data)[i].data.poly;
      curve_to_clip = &static_curve;
      curve_to_clip->poles = poly->points;
      num_knots = poly->num_points + 2;
      curve_to_clip->knots = (IGRdouble *) malloc(num_knots * 
        sizeof(IGRdouble));
       if (! curve_to_clip->knots)
        {
         *EMmsg = EMS_E_NoDynamicMemory;
         goto wrapup;
        }
      status = MApytobc(
        &msg,
        poly,
        curve_to_clip);
       if (! status)
        {
         *EMmsg = EMS_E_Fail;
         goto wrapup;
        }
     }
    else
     curve_to_clip = (*other_xyz_data)[i].data.curve;
    sts = EFspecial_map_xyz_to_uv(
      curve_to_clip,			/* The xyz data */
      my_geom,				/* The surface data */
      my_partol->tol,			/* My parametric tolerance */
      type,				/* Determines type of surface */
      is_iso_edge,			/* Is the data iso on input */
      &number_of_points,		/* Amount of data */
      &xyz_data,			/* Model space data */
      &uv_data,				/* Parametric space data */
      &(*correlation)[i],		/* Correlation mapping information */
      &msg);				/* Error return code */
    if (knots) free(knots);
     if (! (1 & msg))
      {
       if (msg == MSINARG)
        *EMmsg = EMS_I_NoSolution;
       else if(msg == EMS_E_InvalidArg)
        {
	 incorrect_iso = TRUE;
	 *EMmsg = EMS_I_NoSolution;
        }
       else
        *EMmsg = EMS_E_Fail;
       goto wrapup;
      }
    poly = (struct IGRpolyline *) malloc(sizeof(struct IGRpolyline));
     if (! poly)
      {
       *EMmsg = EMS_E_NoDynamicMemory;
       goto wrapup;
      }
    (*my_xyz_data)[i].datatype = EMSdata_poly3d;
    (*my_xyz_data)[i].data.poly = poly;
    (*my_xyz_data)[i].data.poly->num_points = number_of_points;
    (*my_xyz_data)[i].data.poly->points = (IGRdouble *)xyz_data;
    poly = (struct IGRpolyline *) malloc(sizeof(struct IGRpolyline));
     if (! poly)
      {
       *EMmsg = EMS_E_NoDynamicMemory;
       goto wrapup;
      }
    (*my_uv_data)[i].datatype = EMSdata_poly2d;
    (*my_uv_data)[i].data.poly = poly;
    (*my_uv_data)[i].data.poly->num_points = number_of_points;
    (*my_uv_data)[i].data.poly->points = (IGRdouble *)uv_data;
   } /* for (i = 0; i < *num_out_cvs; i++) */
 }
/*
 * Free up memory
 */
wrapup:
 {
  extern	IGRboolean BSfreecv();
  IGRboolean	status;
  IGRlong	loc_msg, i;

  for (i = 0; i < number_of_curves; i++)
   {
    if (curves[i])
     {
      status = BSfreecv(
       &loc_msg,
       curves[i]);
     }
   } /* for (i = 0; i < number_of_curves; i++) */
  if (curves) free(curves);
 }
/*
 * If we did not find a proper solution, then
 * free all the memory allocated in the data
 * selectors.
 */
 if ((! (1 & *EMmsg)) ||
     (*EMmsg == EMS_I_NoSolution))
  {
   extern	void EMdataselect_data_free();
   IGRlong	msg, i;
   struct	EMSdataselect *dataselect[4];

   dataselect[0] = *my_xyz_data;
   dataselect[1] = *other_xyz_data;
   dataselect[2] = *my_uv_data;
   dataselect[3] = *other_uv_data;
   for (i = 0; i < 4; i++)
    {
     if (dataselect[i])
      {
       EMdataselect_data_free(
        &msg,
        dataselect[i],
        *num_out_cvs);
       free(dataselect[i]);
      } /* if (dataselect) */
    } /* for (i = 0; i < 4; i++) */
   if (*correlation)
    {
     for (i = 0; i < *num_out_cvs; i++)
      {
       if ((*correlation)[i]) free((*correlation)[i]);
      }
     free(*correlation);
    }
   *num_out_cvs = 0;
   *my_xyz_data = NULL;
   *other_xyz_data = NULL;
   *my_uv_data = NULL;
   *other_uv_data = NULL;
   *correlation = NULL;
  } /* if no proper solution was found */
/*
 * If we have failed because we were unable
 * to properly support the operation then
 * let someone else take a shot at the problem.

 * If we failed because of incorrect iso determination try again, this time
 * ignoring isoness.
 */
 if (*EMmsg == EMS_I_NoSolution)
  {
   if (is_revolution)
    {
     sts = om$send(
      mode = OM_e_wrt_message,
      msg = message EMSrevol.EMget_int_data(
       EMmsg,
       options,
       other_data,
       my_geom,
       other_geom,
       my_uvrange,
       other_uvrange,
       my_partol,
       other_partol,
       num_out_cvs,
       my_xyz_data,
       other_xyz_data,
       my_uv_data,
       other_uv_data,
       correlation,
       curve_type,
       intinfo),
      targetid = my_id);
    }
   else if(incorrect_iso)
    {
     sts = om$send(
      mode = OM_e_wrt_message,
      msg = message EMSproject.EMget_int_data(
       EMmsg,
       options | EMS_INTER_NOISO,
       other_data,
       my_geom,
       other_geom,
       my_uvrange,
       other_uvrange,
       my_partol,
       other_partol,
       num_out_cvs,
       my_xyz_data,
       other_xyz_data,
       my_uv_data,
       other_uv_data,
       correlation,
       curve_type,
       intinfo),
      targetid = my_id);
    }
   else
    {
     sts = om$send(
      mode = OM_e_wrt_message,
      msg = message EMSsubbs.EMget_int_data(
       EMmsg,
       options,
       other_data,
       my_geom,
       other_geom,
       my_uvrange,
       other_uvrange,
       my_partol,
       other_partol,
       num_out_cvs,
       my_xyz_data,
       other_xyz_data,
       my_uv_data,
       other_uv_data,
       correlation,
       curve_type,
       intinfo),
      targetid = my_id);
    }
   return(sts);
  } /* if (*EMmsg == EMS_I_NoSolution) */
/*
 * The end
 */
 if (! (1 & *EMmsg))
  return(OM_E_ABORT);
 else
  return(OM_S_SUCCESS);
}
/*
 Description

 Given an array of model space curves and a plane, this
 function will map the curves to the space of the plane.

 History

 10/27/88 : rlw : Creation date

 */

IGRlong EFmap_intersection_to_special_plane(
 number_of_curves,		/* Number of curves to clip */
 curves,			/* Curves to be clipped */
 object_space_number,		/* Object space to use for work */
 special_plane,			/* Plane against which the curves are clipped*/
 partolbasis,			/* Tolerance for the plane */
 was_curve_clipped,		/* Makes sense for only 1 input curve */
 number_of_mapped_curves,	/* Number of resulting curves */
 uv_data,			/* Parametric space clipped curves */
 xyz_data,			/* Model space clipped curves */
 EMmsg)				/* Error return code */

IGRlong		number_of_curves;
struct		IGRbsp_curve **curves;
OMuword		object_space_number;
struct		IGRbsp_surface *special_plane;
struct		EMSpartolbasis *partolbasis;
IGRboolean	*was_curve_clipped;
IGRlong		*number_of_mapped_curves;
struct		EMSdataselect **uv_data;
struct		EMSdataselect **xyz_data;
IGRlong		*EMmsg;
{
 extern		IGRboolean EFmap_the_curve();
 IGRboolean	status;
 IGRushort 	options;
 IGRshort	is_surface_planar;
 IGRlong	sts, i, j, k, loc_msg, number_of_output_curves;
 IGRdouble	cht;
 struct		GRid loopset_id;
 struct		EMSdataselect *uv_curves, *xyz_curves;
/*
 * Initialize
 */
 loopset_id.objid = NULL_OBJID;
 *number_of_mapped_curves = 0;
 *uv_data = NULL;
 *xyz_data = NULL;
 *was_curve_clipped = TRUE;
/*
 * Construct the loopset
 */
 loopset_id.osnum = object_space_number;
 sts = om$construct(
   classid = OPP_EMSloopset_class_id,
   osnum = object_space_number,
   msg = message EMSloopset.EMmake_natural_loopset(
    EMmsg,
    NULL,		/* No curve types */
    NULL,		/* No edge properties */
    NULL),		/* No edge ids */
   p_objid = &loopset_id.objid);
  if ((! (1 & sts)) ||
      (! (1 & *EMmsg)))
   {
    *EMmsg = EMS_E_OMerror;
    goto wrapup;
   }
/*
 * Map the curves to the special plane
 */
 BSEXTRACTPAR(
  &loc_msg,
  BSTOLCHRDHT,
  cht);
 options = EMMapBnd_WantBadCurves |
           EMMapBnd_NoStroke |
           EMMapBnd_NoCurveType |
           EMMapBnd_ClipBdryArea |
           EMMapBnd_RmvDegenCvs;
 is_surface_planar = EMS_O_Planar;
 for (i = 0; i < number_of_curves; i++)
  {
   uv_curves = NULL;
   xyz_curves = NULL;
   number_of_output_curves = 0;
   status = EFmap_the_curve(
     loopset_id,		/* Random structure passed by value */
     curves[i],
     special_plane,
     loopset_id,
     &cht,
     partolbasis,
     options,
     &is_surface_planar,
     &number_of_output_curves,
     &uv_curves,
     &xyz_curves,
     NULL,			/* No curve types */
     NULL,			/* No ls boundaries */
     FALSE,			/* Do not insert points */
     EMmsg);
    if ((! status) ||
        (! (1 & *EMmsg)))
     {
      *EMmsg = EMS_E_Fail;
      goto wrapup;
     }
   if (number_of_output_curves)
    {
     IGRlong	total_curves;

     if ((*EMmsg != EMS_I_OutOfBounds) &&
         (number_of_curves == 1))
      *was_curve_clipped = FALSE;
     total_curves = *number_of_mapped_curves + number_of_output_curves;
     if (*number_of_mapped_curves == 0)
      {
       *xyz_data = (struct EMSdataselect *) malloc(
         total_curves * sizeof(struct EMSdataselect));
        if (! *xyz_data)
         {
          *EMmsg = EMS_E_NoDynamicMemory;
          goto wrapup;
         }
       *uv_data = (struct EMSdataselect *) malloc(
         total_curves * sizeof(struct EMSdataselect));
        if (! *uv_data)
         {
          *EMmsg = EMS_E_NoDynamicMemory;
          goto wrapup;
         }
      } /* if (*number_of_mapped_curves == 0) */
     else
      {
       *xyz_data = (struct EMSdataselect *) realloc(
         *xyz_data,
         total_curves * sizeof(struct EMSdataselect));
        if (! *xyz_data)
         {
          *EMmsg = EMS_E_NoDynamicMemory;
          goto wrapup;
         }
       *uv_data = (struct EMSdataselect *) realloc(
         *uv_data,
         total_curves * sizeof(struct EMSdataselect));
        if (! *uv_data)
         {
          *EMmsg = EMS_E_NoDynamicMemory;
          goto wrapup;
         }
      } /* ELSE FOR if (*number_of_mapped_curves == 0) */
     for (j = 0; j < number_of_output_curves; j++)
      {
       k = j + *number_of_mapped_curves;
       (*uv_data)[k] = uv_curves[j];
       (*xyz_data)[k] = xyz_curves[j];
      } /* for (j = 0; j < number_of_output_curves; j++) */
     free(uv_curves);
     free(xyz_curves);
     *number_of_mapped_curves = total_curves;
    } /* else if (number_of_output_curves) */
  } /* for (i = 0; i < number_of_curves; i++) */
/*
 * eof
 */
wrapup:
 if (loopset_id.objid != NULL_OBJID)
  {
   sts = om$send(
    msg = message Root.delete(1),
    senderid = NULL_OBJID,
    targetid = loopset_id.objid,
    targetos = object_space_number);
  } /* if (loopset_id.objid != NULL_OBJID) */
 if (! (1 & *EMmsg))
  {
   extern	IGRboolean BSfreecv();
   IGRboolean	status;
   IGRlong	i, loc_msg;
   struct	IGRbsp_curve *curve;

   for (i = 0; i < *number_of_mapped_curves; i++)
    {
     curve = (*uv_data)[i].data.curve;
     if (curve)
      {
       status = BSfreecv(
        &loc_msg,
        curve);
      }
     curve = (*xyz_data)[i].data.curve;
     if (curve)
      {
       status = BSfreecv(
        &loc_msg,
        curve);
      }
    } /* for (i = 0; i < *number_of_mapped_curves; i++) */
   if (*uv_data) free(*uv_data);
   if (*xyz_data) free(*xyz_data);
   *number_of_mapped_curves = 0;
   *uv_data = NULL;
   *xyz_data = NULL;
   return(FALSE);
  }
 else
  return(TRUE);
}
end implementation EMSproject;
