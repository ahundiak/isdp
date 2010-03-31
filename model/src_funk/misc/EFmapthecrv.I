/* ###################   APOGEE COMPILED   ################## */
class implementation Root;

#include "EMS.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "EMSopt.h"

#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsinterdef.h"
#include "emssfint.h"
#include "msdef.h"                      /* MS error return codes */
#include "madef.h"                      /* macro + MA error return codes */
#include "bsparameters.h"               /* BSEXTRACTPAR macro */
#include "bserr.h"                      /* BS error return codes */
#include "emsbreak.h"                   /* EM_BLOCK_MOVE macro */
#include "EMSmsgdef.h"
#include "emsedgedef.h"
#include "EMSerrordef.h"
#include "EMSerrnumdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmapdef.h"
#include "OMerrordef.h"
#include "emsmacros.h"
#include "bsunwght_p.h"
#include "bstst_plan.h"
#include "bssfptseval.h"
#include "bssfeval.h"
#include "bsprptsonsf.h"
#include "bsprptonsf.h"
#include "bspartofcv.h"
#include "bsmdistcvcv.h"
#include "bsfreecv.h"
#include "bscv_copy.h"
#include "bsconstprcv.h"
#include "bschangepar.h"
#include "bsalloccv.h"
#include "bsadd_ktr.h"

%safe
static IGRboolean EFclip_the_curve ();
static void EFinsert_pts ();
static IGRboolean check_for_nat_crossing();
static long EFspecial_stroke_curve();
%endsafe

#define TEST_PARAM 	0.5
#define BUF_INC    	100
#define NB_SAMPLE_SEG   25

extern OMuword OPP_GRbcsubbc_class_id;

from  EMSloopset import EMlsparttrim;
from  GRvg       import GRclipto;

/*

DESCRIPTION
   Given a bspline curve and a bspline surface this function maps the
   curve into the parametric space of the surface. This function
   returns the mapped curves in the surface's parametric space
   and as well as in the model space. Also, the model space counterparts
   of the mapped curve's type is also returned.

   It the surface is a special plane, it performs the following
   actions are taken:

    a) A special mapping function is used. The advantages of using
    the special mapping function are:

        i) It is more efficient than the regular math function.

        ii) The poles of the incoming curve that are outside the
        bounds of the surface can be optionally snapped to the surface.
        This option is needed in creating a BSedge.

    b) The mapped curve may be clipped against the surface's loopset,
    if caller requests.


ON ENTRY

    curve_GRid          Objid and osnum of the incoming curve.

    in_curve            Incoming curve geometry.

    surface             Incoming Surface geometry.

    loopset_GRid        Objid and osnum of the loopset against which
                        the mapped curve is to be clipped.

    cht_tol             Chord-height tolerance to be used in stroking
                        and mapping the curve.

    partolbasis         Parametric tolerance to be used in trimming the
                        mapped curve.

    options             Caller defined options. These are defined in
                        emsgetlpdef.h. They are:

                        -  EMMapBnd_WantBadCurves

                           Accept curves even if it is not within twice
                           the chord-height tolerance of the surface.

                        -  EMMapBnd_WantStatMsg

                           Want status messages

                        -  EMMapBnd_StrokeIfNeeded

                           Stroke the curve if needed.

                        -  EMMapBnd_StrokeAlways

                           Always stroke the curve

                        -  EMMapBnd_NoStroke

                           Donot stroke the curve.

                        -  EMMapBnd_NoClip

                           Donot clip the mapped curve even if
                           they are outside the surface bounds by
                           more than twice the chord height tolerance.

                        -  EMMapBnd_ClipBdryArea

                           Treat the clipping boundary as belonging
                           to area. Relevant only if NoClip turned off.

                        -  EMMapBnd_RmvDegenCvs

                           Remove any degenerate curves that remain/result
                           after clipping has been performed.

                        -  EMMapBnd_NoCurveType

                           The model space curve type of the mapped
                           curve is not needed.


        is_surf_planar   - Input/Output - Flag stating of the surface
                           is a special plane.

ON EXIT

        is_surf_planar   - Input/Output - Flag stating of the surface
                           is a special plane.

        num_out_curves   - The curves resulted after mapping.

        out_uv_curves    - Output curves in the surface's parametric
                           space.

        out_xyz_curves   - Output Curves in the model space.

        out_curve_type   - Model space curve type of the mapped curve.

        ls_bdrys         - Trim info of the mapped curve.

        EMmsg            - Return code.

                         EMS_S_Success  - if successful.

                         EMS_E_Fail     - if failure occurs in one
                                          of the following calls:

                           - EFstroke_the_curve ()
                           - EFis_linear_map_ok()
                           - EFmap_xyz_to_uv_for_planes()
                           - EFmap_uv_to_xyz_for_planes()
                           - EFclip_the_curve()
                           - EFget_the_edge_type_for_an_object()
			   - EFpts_degenerate()
                           - GRlipto()

                        EMS_E_NoDynamicMmeory - If failure in malloc.

                        EMS_E_BSerror   - if failure in BSunwght_p() or
                                BSprtptsonsf()

                        EMS_E_InvalidArg - if the curve is not within
                           twice the chord height tolerance of the
                           surface and bad curves are not wanted.

                        MANONPLANAR   - if the surface is not a special
                           plane and the caller does not want to stroke
                           the curve.

                        EMS_E_OMerror - if failure in om$get_classid.

NOTES

        The following enhancements should be made in future:

        1) If the incoming curve is a line string and the surface is
           is not a special plane, a set points should be inserted
           so as to have consequtive points within chord height
           tolerance of the surface.

        2) If the surface is not a special plane but is of 2nd order,
           the incomig curve should be clipped against the surface
           boundaries before stroking.

HISTORY

    01/22/87 : rlw : creation date
    04/10/87 : rlw : Added want_bad_curve argument
    04/28/87 : rlw : Added additional argument which allows the user to
                     specify whether stroking is to be performed.
    05/06/87 : rlw : Modified due to BNuv_pn_pt being changed and renamed
                     and removed code to return xyz points for the no
                     stroke case.
    05/13/87 : rlw : Fixed a free bug Sunit found for no stroke case.
                     It did not set the xyz pointer to NULL upon return.
                     Modified code such that order 2 data is "clipped"
                     regardless of the option want_stroked_curve.

    08/25/87 : RC  : Rewrote the function. Added clipping functionality
                     needed in the process of mapping.

    29-Oct-87: SM : Modified such that 'out_curve_type' is not returned
                    if the caller does not want it(EMGetLP_NoCurveType).
    11/05/87 : RC : Changed the arguments to call
                    EFmap_xyz_to_uv_for_planes() and
                    EFmap_uv_to_xyz_for_planes().
    07/06/88 : RC : Modified such that if the incoming curve is of
                    order 2 and is rational, it is internally
                    unweighted and is used as a non-rational curve.
                    This is done to ensure that points are inserterted
                    if needed.
    10/03/88 : RC : If the mapped curve is a bsplie_curve, test if
                    its end pts are within surface's parametric range.
                    If not, snap it to surface's range boundary.
    10/10/88: rlw : Modified such that if the surface is planar then
                    the curve is projected onto the plane and the edge
                    type is set properly even if the curve is not within
                    tolerance of the surface.
    02/07/89: SS  : Added the option to treat the clipping boundary as
                    belonging to area.
    02/10/89: RC  : if the incoming option is EMMapBnd_RmvDegenCvs and
                    the surface is a special plane, do not return
                    degenerate curves.
    05/02/89  RC  : Get the curve_geom_type after invoking
                    EFproject_curve_onto_plane as this call may change
                    the type of geometry.
    01-Aug-89 SM  : Set uv_xyz_map to TRUE if clipping is performed.
		    This is because the xyz data is no longer the same
		    as that returned by EFmap_xyz_to_uv_for_planes().
    08-Nov-90 SM  : Call EFclassify_degenerate_edges() and EFfix_uv_on_degene..

    03/11/92 : SM  : Problem - When a curve to be mapped on a closed surface
		     crosses the seam of the surface, there is a jump created
		     in the parametric data of the surface after
		     mapping. Unless stroking has created a point at the
		     seam, the jump fixing routine will simply create a point
		     by linear interpolation, for lack of a better
		     guess. This new point introduced could be completely off
		     the original curve depending on the cht used.
		     Solution - If closed surface is input, introduce knot
		     or multiplicity = order-1 in the curve, at every point
		     where it intersects the surface seam. This ensures that
		     stroking will maintain that point.
  04/15/92 SM        Allocate maximum poles,knots and weights in check_for_seam
                     crossing funcction.
  09/28/92 NP	     In the "check_for_seam_crossing" function, knot
		     (see comments on 3/11/92 above) is introduced even if the
	 	     curve is more than chord height away from the surface.
  11/27/92 SM        extended the function 'check_for_seam_crossing' to check
                     crossing all natural boundaries. Changed the name to
                     'check_for_nat_crossing'.
  07-Jun-93 SM	     Clipping against the input loopset was not being
                     done for surfaces where linear mapping was not possible.
                     Added code to do this. This also necessitated calling
                     EFfix_the_intersection to fix jumps, self intersections
                     etc. on the uv data before it can be trimmed.
  18-Jun-93 scw      Initialized all_points_within_tolerance to TRUE to
                     get Purify to shut up.

  07-08-93  Sudha    Modified for BSprototypes ansification
  01-Sep-93 ashok    Modified to pass "ls_bdrys" to EFclip_the_curve if the
		     surface is non-planar. Earlier NULL argument was passed.
  11-18-93 Rustagi   Added fix for TR#119311452
  29-Dec-93 ashok    Fixed a memory problem in EFclip_the_curve.
  04-Jan-94 SM       Honor EMMapBnd_NoRmvColEds option when calling
                     EFfix_the_int to prevent removal of pieces mapped
                     to natural bounds.
  11-Jan-94 ashok    Memory for ls_bdrys was not being allocated in
		     EFclip_the_curve if num_bdrys is 1, the assumption being
		     memory is already allocated by caller. Modified to
		     allocate memory if caller has not allocated it. This
		     makes the interface more consistent.
 */
#argsused
IGRboolean EFmap_the_curve(
        curve_GRid,
        in_curve,
        surface,
        loopset_GRid,
        cht_tol,
        partolbasis,
        options,
        is_surf_planar,
        num_out_curves,
        out_uv_curves,
        out_xyz_curves,
        out_curve_type,
        ls_bdrys,
        insert_points,
        EMmsg)

        struct  GRid            curve_GRid, loopset_GRid;
        struct  IGRbsp_curve    *in_curve;
        struct  IGRbsp_surface  *surface;
        IGRdouble               *cht_tol;
        struct EMSpartolbasis   *partolbasis;
        IGRushort       options;
        IGRshort                *is_surf_planar;
        IGRint                  *num_out_curves;
        struct EMSdataselect    **out_uv_curves, **out_xyz_curves;
        struct EMSsfintedpar    ***ls_bdrys;
        IGRuchar        *out_curve_type;
        IGRboolean              insert_points;
        IGRlong                 *EMmsg;

{
        OMuword                 projected_curve_class;
        IGRlong                 OM_stat, rc;
        IGRlong                 num_pnts, num_poles, num_bytes;
        IGRint                  i, j, n, m;
        enum EMSdatatype        curve_geom_type, cv_org_gm_type;

        IGRboolean              status, linear_map_ok = FALSE,
                                stroke_the_curve = FALSE, snap_to_edge,
                                all_points_on_surface,
                                all_points_within_range,
                                all_points_within_tolerance = TRUE,
                                uv_xyz_map,
                                is_crv_clipped,
                                clipping_performed = FALSE,
                                nsp_pl_trimming_done = FALSE,
                                is_non_sp_plane = FALSE;

        IGRdouble               *xyz_pnts, *uv_pnts, *uv_poles = NULL,
                                *xyz_poles, *temp_poles, *temp_knots,
                                *temp_weights, *uv_2d_poles, old_cht,
                                minu, minv, maxu, maxv, *end_pts, wt;

        struct IGRpolyline      *poly_2d, *poly_3d, polyline;
        struct IGRbsp_curve     *crv_uv, *crv_xyz, **tr_cvs, *curve,
                                *temp_cv, modified_curve;
        struct EMSdataselect    *in_geom;

        IGRboolean              EFis_linear_map_ok(),
				EFmap_uv_to_xyz_for_planes(),
                                EFmapxyz_to_uv_for_planes(),
                                EFstroke_the_curve();

        void                    EFtrim_cv_to_non_sp_plane(),
                                EFstroke_line_string();

        IGRlong                 EFget_the_edge_type_for_an_object ();
        IGRint 			loc_num_out_curves = 0,loc_num_trim_curves = 0,
                                num_groups = 0;
        IGRlong			*points_per_group = NULL;
        struct EMSdataselect 	*loc_out_uv_curves = NULL,
				*loc_out_trim_curves = NULL;
        struct IGRpolyline 	loc_poly3d, loc_poly2d;
        IGRdouble		**xyz_group = NULL, **uv_group = NULL;
        typedef IGRdouble	dummy[2];

        OM_stat = OM_S_SUCCESS;
        *EMmsg  = EMS_S_Success;

        is_crv_clipped = FALSE;
        *num_out_curves = 0;
        *out_xyz_curves = NULL;
        *out_uv_curves = NULL;
        tr_cvs = NULL;
        curve = NULL;
        uv_2d_poles = NULL;
        in_geom = NULL;
        xyz_pnts = NULL;
        uv_pnts = NULL;
        polyline.points = NULL;
        modified_curve.poles = NULL;
        modified_curve.knots = NULL;
        modified_curve.weights = NULL;
        loc_poly3d.points = loc_poly2d.points = NULL;

        /*
         * If the incoming curve is of order 2 and is rational,
         * points will not be inserted. Since, by unweighting the
         * poles of the 2nd order curve will not change the shape,
         * the curve is made non-rational.
         */

        if (in_curve->order == 2 && in_curve->rational)
        {
          BSalloccv (in_curve->order, in_curve->num_poles,
                     FALSE, 0, &curve, &rc);
          EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
          temp_poles = curve->poles;
          temp_knots = curve->knots;
          *curve = *in_curve;
          curve->poles = temp_poles;
          curve->knots = temp_knots;

          status = BSunwght_p (&rc, in_curve->poles, in_curve->weights,
                               &in_curve->num_poles, curve->poles);
          EMerr_hndlr(!status||rc!= BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

          num_bytes = in_curve->num_knots * sizeof(IGRdouble);
          EM_BLOCK_MOVE ((char *)in_curve->knots, (char *)curve->knots, num_bytes);

          curve->rational = FALSE;
          curve->weights = NULL;

        } /* if (in_curve->order == 2 && in_curve->rational) */
        else
          curve = in_curve;

/*
 * If the surface is planar then project the curve onto the
 * plane and in the process of doing this determine the correct
 * type of the resulting projected curve.
 */
        if (surface->planar)
         {
          IGRvector	normal_vector;

          BStst_plan(
            surface->u_num_poles * surface->v_num_poles,
            surface->poles,
            surface->weights,
            &surface->planar,
            normal_vector,
            &rc);
          if ((rc == BSSUCC) &&
              surface->planar)
           {
            extern	IGRlong EFproject_curve_onto_plane();
            OMuword	input_curve_class;
            IGRlong	sts;
            IGRpoint	point_on_plane;
            struct	IGRplane plane;
            struct	IGRbsp_curve *projected_curve;

            if (options & EMMapBnd_NoCurveType)
             input_curve_class = OPP_GRbcsubbc_class_id;
            else
             {
              sts = om$get_classid(
                objid = curve_GRid.objid,
                osnum = curve_GRid.osnum,
                p_classid = &input_curve_class);
               if (! (1 & sts))
                {
                 *EMmsg = EMS_E_Fail;
                 goto wrapup;
                }
             } /* ELSE FOR if (options & EMMapBnd_NoCurveType) */
            projected_curve = NULL;
            BSalloccv(
              curve->order,
              curve->num_poles,
              curve->rational,
              0,			/* No boundaries */
              &projected_curve,
              &rc);
             EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
            point_on_plane[0] = surface->poles[0];
            point_on_plane[1] = surface->poles[1];
            point_on_plane[2] = surface->poles[2];
            if (surface->rational)
             {
              IGRdouble	weight;

              weight = surface->weights[0];
              point_on_plane[0] /= weight;
              point_on_plane[1] /= weight;
              point_on_plane[2] /= weight;
             } /* if (surface->rational) */
            plane.point = &point_on_plane[0];
            plane.normal = &normal_vector[0];
            sts = EFproject_curve_onto_plane(
              NULL,
              curve,
              input_curve_class,
              &plane,
              normal_vector,
              NULL_OBJID,
              projected_curve,
              &projected_curve_class,
              EMmsg);
             if (! (1 & sts)) goto wrapup;
            if (curve != in_curve)
             {
              status = BSfreecv(
               &rc,
               curve);
             }
            curve = projected_curve;
           } /* surface is truely planar */
         } /* if (surface->planar) */
/*
 * End rlw
 */

        curve_geom_type = (curve->order == 2 && !curve->rational) ?
                        EMSdata_poly2d : EMSdata_curve3d;

        cv_org_gm_type = curve_geom_type;

        /*
         * check if the surface is a special plane.
         * A surface is a special plane, if it
         * of 2nd order , opposite polygon segments are equal and
         * the knots are equally distributed. This check is made
         * only if the caller does not know.
         */

        linear_map_ok = FALSE;

        if (*is_surf_planar == EMS_O_Unknown ||
                *is_surf_planar == EMS_O_Planar )
        {
          if (*is_surf_planar == EMS_O_Unknown )
           {
            status = EFis_linear_map_ok (&rc, surface, &linear_map_ok);
            EMerr_hndlr (!status || !(1&rc),*EMmsg,EMS_E_Fail,wrapup);

            if (linear_map_ok) *is_surf_planar = EMS_O_Planar;
            else *is_surf_planar = EMS_O_NonPlanar;

           }
           else
           {
            /*
             * Added fix for TR#119311452. Instead of setting
             * linear_map_ok = TRUE, the function is being called. It is
             * because a drafted surface can be planar but at the same
             * time not a SPECIAL_PLANE and hence setting of linear_map_ok
             * to TRUE is not valid. Better rely on the result returned by
             * the function call.
             */
            status = EFis_linear_map_ok (&rc, surface, &linear_map_ok);
            EMerr_hndlr (!status || !(1&rc),*EMmsg,EMS_E_Fail,wrapup);
            /*
             * linear_map_ok = TRUE;
             */
           }


        } /* if (*is_surf_planar == EMS_O_Unknown ||
                *is_surf_planar == EMS_O_Planar ) */

        if (!linear_map_ok && (options & EMMapBnd_NoStroke) )
        {
          *EMmsg = MANONPLANAR;
          goto wrapup;
        }

        /*
         * find out if stroking is necessary.
         */

        if ( (options & EMMapBnd_StrokeAlways) ||
             (options & EMMapBnd_StrokeIfNeeded))
        {
          if (options & EMMapBnd_StrokeIfNeeded)
          {
            if (!linear_map_ok) stroke_the_curve = TRUE;

          } /* if (options &EMMapBnd_StrokeIfNeeded) */

          else stroke_the_curve = TRUE;

        } /* if ( (options & EMMapBnd_StrokeAlways) ||
                (options & EMMapBnd_StrokeIfNeeded) ) */

        /*
         * Perform the mapping for a special plane.
         */

        if (linear_map_ok)
        {
          if (stroke_the_curve)
          {
           if(check_for_nat_crossing(curve, &modified_curve, surface))
            status = EFstroke_the_curve (&modified_curve, cht_tol, &polyline,
		     &rc);
           else
            status = EFstroke_the_curve (curve, cht_tol, &polyline, &rc);
           EMerr_hndlr (!status || !(1&rc),*EMmsg,EMS_E_Fail,wrapup);

           if(modified_curve.poles) om$dealloc(ptr = modified_curve.poles);
           if(modified_curve.knots) om$dealloc(ptr = modified_curve.knots);
           if(modified_curve.weights) om$dealloc(ptr = modified_curve.weights);
           modified_curve.poles = NULL;
           modified_curve.knots = NULL;
           modified_curve.weights = NULL;

            num_pnts = polyline.num_points;
            xyz_pnts = polyline.points;
            polyline.points = NULL;
            polyline.num_points = NULL;
            curve_geom_type = EMSdata_poly2d;

          } /* if (stroke_the_curve) */

          else
          {
            num_pnts = curve->num_poles;
            num_bytes = num_pnts * sizeof (IGRpoint);

            xyz_pnts = (IGRdouble *) om$malloc (size = num_bytes);
            EMerr_hndlr (!xyz_pnts,*EMmsg, EMS_E_NoDynamicMemory, wrapup);

            if (curve->rational)
            {
              status = BSunwght_p (&rc, curve->poles, curve->weights,
                                        &curve->num_poles, xyz_pnts);
              EMerr_hndlr(!status||rc!= BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
            }

            else  EM_BLOCK_MOVE ((char *)curve->poles, (char *)xyz_pnts, num_bytes);

          } /* else for if (stroke_the_curve) */

          /*
           * map the points on the surface's parametric space.
           */

          uv_pnts = (IGRdouble *) om$malloc (size = num_pnts * 2 *
                         sizeof (IGRdouble));
          EMerr_hndlr(!uv_pnts,*EMmsg,EMS_E_NoDynamicMemory, wrapup);

          snap_to_edge = stroke_the_curve;

          status = EFmap_xyz_to_uv_for_planes (&rc, surface,
                     *cht_tol, partolbasis->tol, num_pnts,
                     xyz_pnts, &all_points_within_range,
                     &all_points_within_tolerance, snap_to_edge, uv_pnts);
          EMerr_hndlr (!status || !(1&rc), *EMmsg, EMS_E_Fail, wrapup);

          all_points_on_surface = all_points_within_range &&
                                  all_points_within_tolerance;

          if (!(all_points_on_surface || (options & EMMapBnd_WantBadCurves) ))
          {
            *EMmsg = EMS_E_InvalidArg;
            goto wrapup;
          }

          *num_out_curves = 1;
          if (!all_points_on_surface )
                   uv_xyz_map = TRUE;
          else  uv_xyz_map = FALSE;

          /*
           * If linear mapping was performed with snap_to_edges
           * switch OFF, it may be possible that
           * some of the (u,v) points lie outside ths surface's
           * parametric space. In such a case, clip the mapped the
           * curve against the incoming loopset
           */

          if ( !(options & EMMapBnd_NoClip) )
          {
            clipping_performed = TRUE;

            in_geom = (struct EMSdataselect *) om$malloc (size =
                                sizeof(struct EMSdataselect));
            EMerr_hndlr(!in_geom,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

            in_geom->datatype = curve_geom_type;

            if (curve_geom_type == EMSdata_curve3d)
            {
              BSalloccv (curve->order, curve->num_poles,
                      curve->rational, 0, &crv_uv, &rc);
              EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory,
                        wrapup);

              temp_poles = crv_uv->poles;
              temp_knots = crv_uv->knots;
              temp_weights = crv_uv->weights;
              *crv_uv = *curve;

              for (j = 0; j < crv_uv->num_poles; j++)
              {
                temp_poles[3*j] = uv_pnts[2*j];
                temp_poles[3*j+1] = uv_pnts[2*j+1];
                temp_poles[3*j+2] = 0;
              }
              crv_uv->poles = temp_poles;

              if (curve->knots)
              {
                num_bytes = crv_uv->num_knots * sizeof(IGRdouble);
                EM_BLOCK_MOVE ((char *)curve->knots, (char *)temp_knots, num_bytes);
                crv_uv->knots = temp_knots;
              }

              if (curve->rational)
              {
                num_bytes = crv_uv->num_poles * sizeof(IGRdouble);
                EM_BLOCK_MOVE((char *)curve->weights, (char *)temp_weights, num_bytes);
                crv_uv->weights = temp_weights;

                for (j = 0; j < crv_uv->num_poles; j++)
                {
                  crv_uv->poles[3*j] *= crv_uv->weights[j];
                  crv_uv->poles[3*j+1] *= crv_uv->weights[j];
                }
               }

               in_geom->data.curve = crv_uv;

            } /* if (curve_geom_type == EMSdata_curve3d) */

            else
            {
              in_geom->data.poly = (struct IGRpolyline *) om$malloc (
                                 size = sizeof(struct IGRpolyline));
              EMerr_hndlr (!(in_geom->data.poly),*EMmsg,
                        EMS_E_NoDynamicMemory, wrapup);

              in_geom->data.poly->num_points = num_pnts;
              in_geom->data.poly->points = uv_pnts;
              uv_pnts = NULL;
            }

            status = EFclip_the_curve (&in_geom, loopset_GRid,
                       partolbasis, options, &is_crv_clipped, num_out_curves,
                       out_uv_curves, ls_bdrys, &rc);
            EMerr_hndlr (!status || !(1&rc),*EMmsg,EMS_E_Fail,wrapup);
	    if(is_crv_clipped) uv_xyz_map = TRUE;

          } /* if ( !(options & EMMapBnd_NoClip) ) */

         /*
          * Now mapping has been performed. Time to massage the results
          * into the output form.
          */

         if (*num_out_curves)
         {

           *out_xyz_curves = (struct EMSdataselect *) om$malloc (
                size = (*num_out_curves) * sizeof(struct EMSdataselect));
           EMerr_hndlr (!(*out_xyz_curves),*EMmsg,EMS_E_NoDynamicMemory,
                wrapup);

           if (curve_geom_type == EMSdata_curve3d)
           {
             num_bytes = (curve->num_poles + 2 * curve->order - 1) *
                        2 * sizeof(IGRdouble);
             uv_2d_poles = (IGRdouble *) om$malloc(size = num_bytes);
             EMerr_hndlr (!uv_2d_poles,*EMmsg,EMS_E_NoDynamicMemory, wrapup);
           }

           for (i = 0; i < *num_out_curves; i++)
           {

             if (curve_geom_type == EMSdata_poly2d)
                     (*out_xyz_curves)[i].datatype = EMSdata_poly3d;
             else (*out_xyz_curves)[i].datatype = EMSdata_curve3d;

             if (clipping_performed)
             {

              if (uv_xyz_map)
              {
                 if ((*out_uv_curves)[i].datatype == EMSdata_poly2d)
                 {
                     poly_2d = (*out_uv_curves)[i].data.poly;
                     num_poles = poly_2d->num_points;
                     uv_poles = poly_2d->points;

                  } /* if((*out_uv_curves[i].datatype == EMSdata_poly2d)*/

                  else
                  {
                     crv_uv = (*out_uv_curves)[i].data.curve;
                     num_poles = crv_uv->num_poles;
                     uv_poles = uv_2d_poles;
                     for (j = 0; j < num_poles; j++)
                     {
                        uv_poles[2*j] = crv_uv->poles[3*j];
                        uv_poles[2*j+1] = crv_uv->poles[3*j+1];
                     }

                     if (crv_uv->rational)
                     {
                        for (j = 0; j < num_poles; j++)
                        {
                           uv_poles[2*j] /= crv_uv->weights[j];
                           uv_poles[2*j+1] /= crv_uv->weights[j];
                        }
                     }

                 } /* else for if((*out_uv_curves[i].datatype ==
                                                EMSdata_poly2d)*/
              } /* if (uv_xyz_map) */

             } /* if (clipping_performed) */

             else
             {
              out_uv_curves[i] = (struct EMSdataselect *) om$malloc
                                (size = sizeof(struct EMSdataselect));
              EMerr_hndlr(!out_uv_curves[i],*EMmsg,
                EMS_E_NoDynamicMemory, wrapup);

              if (stroke_the_curve || (curve->order == 2 &&
                                !curve->rational))
              {
                poly_2d = NULL;
                poly_2d = (struct IGRpolyline *) om$malloc (
                                size = sizeof(struct IGRpolyline));
                EMerr_hndlr(!poly_2d,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

                poly_2d->num_points = num_poles = num_pnts;
                poly_2d->points = uv_poles = uv_pnts;
                (*out_uv_curves)[i].datatype = EMSdata_poly2d;
                (*out_uv_curves)[i].data.poly = poly_2d;
                uv_pnts = NULL;
              }

              else
              {
                 BSalloccv (curve->order, curve->num_poles,
                      curve->rational, 0, &crv_uv, &rc);
                 EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory,
                        wrapup);

                 temp_poles = crv_uv->poles;
                 temp_knots = crv_uv->knots;
                 temp_weights = crv_uv->weights;
                 *crv_uv = *curve;

                 for (j = 0; j < crv_uv->num_poles; j++)
                 {
                    temp_poles[3*j] = uv_pnts[2*j];
                    temp_poles[3*j+1] = uv_pnts[2*j+1];
                    temp_poles[3*j+2] = 0;
                 }
                 crv_uv->poles = temp_poles;

                 if (curve->knots)
                 {
                  num_bytes = crv_uv->num_knots * sizeof(IGRdouble);
                  EM_BLOCK_MOVE ((char *)curve->knots, (char *)temp_knots, num_bytes);
                  crv_uv->knots = temp_knots;
                 }

                 if (curve->rational)
                 {
                   num_bytes = crv_uv->num_poles * sizeof(IGRdouble);
                   EM_BLOCK_MOVE((char *)curve->weights, (char *)temp_weights, num_bytes);
                   crv_uv->weights = temp_weights;

                   for (j = 0; j < crv_uv->num_poles; j++)
                   {
                      crv_uv->poles[3*j] *= crv_uv->weights[j];
                      crv_uv->poles[3*j+1] *= crv_uv->weights[j];
                   }
                 }

                (*out_uv_curves)[i].datatype = EMSdata_curve3d;
                (*out_uv_curves)[i].data.curve = crv_uv;

                num_poles = crv_uv->num_poles;
                uv_poles = uv_pnts;

              } /* else for if (stroke_the_curve || (curve->order == 2 &&
                                !curve->rational)) */

             } /* else for if (clipping_performed) */

             if ((*out_uv_curves)[i].datatype == EMSdata_poly2d)
             {
                poly_2d = (*out_uv_curves)[i].data.poly;
                poly_3d = (struct IGRpolyline *) om$malloc (size =
                        sizeof(struct IGRpolyline));
                EMerr_hndlr(!poly_3d,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

                poly_3d->num_points = num_poles = poly_2d->num_points;
                poly_3d->points = (IGRdouble *) om$malloc (size =
                                num_poles * 3 * sizeof(IGRdouble));
                EMerr_hndlr (!poly_3d->points, *EMmsg,
                        EMS_E_NoDynamicMemory, wrapup);

                (*out_xyz_curves)[i].data.poly = poly_3d;

                xyz_poles = poly_3d->points;

             } /* if ((*out_uv_curves)[i].datatype == EMSdata_poly2d) */

             else
             {
                crv_uv = (*out_uv_curves)[i].data.curve;

                BSalloccv (crv_uv->order, crv_uv->num_poles,
                        crv_uv->rational, 0, &crv_xyz, &rc);
                EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory,
                        wrapup);

                temp_poles = crv_xyz->poles;
                temp_knots = crv_xyz->knots;
                temp_weights = crv_xyz->weights;
                *crv_xyz = *crv_uv;

                if (crv_uv->knots)
                {
                  num_bytes = crv_xyz->num_knots * sizeof(IGRdouble);
                  EM_BLOCK_MOVE ((char *)crv_uv->knots, (char *)temp_knots, num_bytes);
                  crv_xyz->knots = temp_knots;
                }

                if (crv_uv->rational)
                {
                  num_bytes = crv_xyz->num_poles * sizeof(IGRdouble);
                  EM_BLOCK_MOVE((char *)crv_uv->weights, (char *)temp_weights, num_bytes);
                  crv_xyz->weights = temp_weights;
                }

                num_poles = crv_xyz->num_poles;
                crv_xyz->poles = xyz_poles = temp_poles;
                (*out_xyz_curves)[i].data.curve = crv_xyz;

             } /* else for if ((*out_uv_curves)[i].datatype ==
                        EMSdata_poly2d) */

             if (uv_xyz_map)
             {
                status = EFmap_uv_to_xyz_for_planes ( &rc, surface,
                           *cht_tol, num_poles, uv_poles,
                           xyz_poles);
                EMerr_hndlr(!status || !(1&rc),*EMmsg,EMS_E_Fail, wrapup);

             } /* if (uv_xyz_map) */

             else
             {
                num_bytes = num_poles * sizeof(IGRpoint);
                EM_BLOCK_MOVE ((char *)xyz_pnts, (char *)xyz_poles, num_bytes);

             } /* else for if (uv_xyz_map) */

             if ((*out_xyz_curves)[i].datatype == EMSdata_curve3d)
             {
                  crv_xyz = (*out_xyz_curves)[i].data.curve;
                  if (crv_xyz->rational)
                  {
                    for (j = 0; j < crv_xyz->num_poles; j++)
                    {
                        xyz_poles[3*j] *= crv_xyz->weights[j];
                        xyz_poles[3*j+1] *= crv_xyz->weights[j];
                        xyz_poles[3*j+2] *= crv_xyz->weights[j];

                    } /* for (j = 0; j < crv_xyz->num_poles; j++) */

                  } /* if (crv_xyz->rational) */

              } /* if ((*out_xyz_curves)[i].datatype ==
                     EMSdata_curve3d)*/

           } /* for (i = 0; i < *num_out_curves; i++) */

         } /* if (*num_out_curves) */

        } /* if (linear_map_ok) */

        else
        {
          /*
           * If the surface is a non-special plane and the curve
           * is off the surface, it should be trimmed against the
           * the surface.
           */


          if (surface->u_order == 2 && surface->v_order == 2 &&
              !surface->rational && surface->planar  &&
              !(options & EMMapBnd_NoClip) )
          {
             IGRdouble bas_tol;

             status = BSEXTRACTPAR (&rc, BSTOLBASIS, bas_tol);
             is_non_sp_plane = TRUE;
             EFtrim_cv_to_non_sp_plane (curve, surface, bas_tol,
                  &loc_num_out_curves, &tr_cvs, &is_crv_clipped, &rc);
             EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);
             nsp_pl_trimming_done = TRUE;
	     if(is_crv_clipped) uv_xyz_map = TRUE;
          }
          else
          {
             loc_num_out_curves = 1;
             tr_cvs = &curve;
          }

          if (loc_num_out_curves)
          {
            IGRboolean is_degenerate[2][2];
            IGRint out_curves_buff = 0;

            status = BSEXTRACTPAR (&rc, BSTOLCHRDHT, old_cht);

            if (old_cht != *cht_tol)
               status = BSchangepar (&rc, BSTOLCHRDHT, *cht_tol);

            EFclassify_degenerate_edges(surface, is_degenerate, &rc);

            *num_out_curves = 0;
            out_curves_buff = 0;

            for (i = 0; i < loc_num_out_curves; i++)
            {
	      if(loc_poly3d.points) om$dealloc(ptr = loc_poly3d.points);
	      if(loc_poly2d.points) om$dealloc(ptr = loc_poly2d.points);

              loc_poly3d.num_points = 0;
              loc_poly3d.points = NULL;
              loc_poly2d.num_points = 0;
              loc_poly2d.points = NULL;

              if(check_for_nat_crossing(tr_cvs[i], &modified_curve, surface))
              {
                status = EFspecial_stroke_curve( surface, &modified_curve,
                                                 cht_tol, &loc_poly3d, &rc);
              }
              else
               status = EFstroke_the_curve (tr_cvs[i], cht_tol, &loc_poly3d,
                                         &rc);
              EMerr_hndlr (!status || !(1&rc),*EMmsg, EMS_E_Fail, wrapup);
              if(modified_curve.poles) om$dealloc(ptr = modified_curve.poles);
              if(modified_curve.knots) om$dealloc(ptr = modified_curve.knots);
              if(modified_curve.weights) om$dealloc(ptr =
					modified_curve.weights);
              modified_curve.poles = NULL;
              modified_curve.knots = NULL;
              modified_curve.weights = NULL;

              /*
               * The curve is clipped and stroked. Map it to the
               * parametric space.
               */

              loc_poly2d.points = (IGRdouble *) om$malloc (size =
                       sizeof(IGRdouble) * loc_poly3d.num_points * 2);
              EMerr_hndlr(!loc_poly2d.points,*EMmsg,EMS_E_NoDynamicMemory,
                            wrapup);
              BSprptsonsf (loc_poly3d.num_points, (IGRpoint *)loc_poly3d.points,
                           surface, (dummy *)loc_poly2d.points,
                           &all_points_on_surface, &rc);
              EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
              if ( !all_points_on_surface)
               {
                if (!(options & EMMapBnd_WantBadCurves))
                 {
                  *EMmsg = EMS_E_InvalidArg;
                  goto wrapup;
                 }
                else
                 {
                  is_crv_clipped = TRUE;
	          uv_xyz_map = TRUE;
                 }
               }

              loc_poly2d.num_points = loc_poly3d.num_points;

              EFfix_uv_on_degenerate_edges(surface, partolbasis->tol,
              is_degenerate, &loc_poly2d.num_points, &loc_poly2d.points,
              &loc_poly3d.points, &rc);

              loc_poly3d.num_points = loc_poly2d.num_points;

              for(n=0; n<num_groups; n++)
               {
	        if(xyz_group && xyz_group[n]) om$dealloc(ptr = xyz_group[n]);
	        if(uv_group && uv_group[n]) om$dealloc(ptr = uv_group[n]);
               }
              if(points_per_group) om$dealloc(ptr = points_per_group);
              if(xyz_group) om$dealloc(ptr = xyz_group);
              if(uv_group) om$dealloc(ptr = uv_group);

              points_per_group = NULL;
              xyz_group = uv_group = NULL;
              points_per_group = (IGRlong *) om$malloc(size = sizeof(IGRlong));
              xyz_group = (IGRdouble **) om$malloc(size = sizeof(IGRdouble *));
              uv_group = (IGRdouble **) om$malloc(size = sizeof(IGRdouble *));
              EMerr_hndlr(!points_per_group || !xyz_group || !uv_group, *EMmsg,
                           EMS_E_NoDynamicMemory, wrapup);

              num_groups = 1;
              points_per_group[0] = loc_poly3d.num_points;
              xyz_group[0] = loc_poly3d.points;
              uv_group[0] = loc_poly2d.points;
              loc_poly3d.points = NULL;
              loc_poly2d.points = NULL;

              status = EFfix_the_int(NULL,
		       (options & EMMapBnd_NoRmvColEds) ? FALSE : TRUE,
                       surface, NULL, &num_groups,
                       &points_per_group, &xyz_group, &uv_group, NULL, EMmsg);
              if(!(1&*EMmsg)) goto wrapup;

              for(m=0; m<num_groups; m++)
               {
                if(loc_out_uv_curves) om$dealloc(ptr = loc_out_uv_curves);
                loc_out_uv_curves = NULL;

                loc_out_uv_curves = (struct EMSdataselect *) om$malloc(size =
                                  sizeof(struct EMSdataselect));
                EMerr_hndlr(!loc_out_uv_curves, *EMmsg, EMS_E_NoDynamicMemory,
                          wrapup);

                loc_out_uv_curves->datatype = EMSdata_poly2d;
                loc_out_uv_curves->data.poly = (struct IGRpolyline *)
                     om$malloc(size = sizeof(struct IGRpolyline));
                loc_out_uv_curves->data.poly->num_points = points_per_group[m];
                loc_out_uv_curves->data.poly->points = uv_group[m];

                uv_group[m] = NULL;
                if(xyz_group[m]) om$dealloc(ptr = xyz_group[m]);
                xyz_group[m] = NULL;

               /* If the mapped data needs to be clipped against the boundaries
                  of the input loopset, do so now. Evaluate such clipped data
                  back to the model space to produce xyz data.
               */
                if(loc_out_trim_curves) om$dealloc(ptr = loc_out_trim_curves);
                loc_num_trim_curves = 0;
                loc_out_trim_curves = NULL;
                if(options & EMMapBnd_NoClip)
                 {
	          loc_out_trim_curves = (struct EMSdataselect *) om$malloc(
	                               size = sizeof(struct EMSdataselect));
	          EMerr_hndlr(!loc_out_trim_curves, *EMmsg,
	                    EMS_E_NoDynamicMemory, wrapup);
	          loc_out_trim_curves->datatype = EMSdata_poly2d;
                  loc_out_trim_curves->data.poly =loc_out_uv_curves->data.poly;
	          loc_out_uv_curves->datatype = EMSdata_null;
	          loc_out_uv_curves->data.poly = NULL;
	          loc_num_trim_curves = 1;
                 }
                else
                 {
/* Modified to pass "ls_bdrys" as argument below instead of NULL */
                  status = EFclip_the_curve (&loc_out_uv_curves, loopset_GRid,
                           partolbasis, options, &is_crv_clipped,
                           &loc_num_trim_curves,
/*                           &loc_out_trim_curves, NULL, &rc); Ashok 1-8-93 */
                             &loc_out_trim_curves, ls_bdrys, &rc);
                  EMerr_hndlr (!status || !(1&rc),*EMmsg,EMS_E_Fail,wrapup);
 	          if(is_crv_clipped) uv_xyz_map = TRUE;
                 }

                if(loc_num_trim_curves > out_curves_buff)
                 {
	          if(*out_xyz_curves)
	           {
	            *out_xyz_curves = (struct EMSdataselect *) om$realloc(
	               ptr = (IGRchar *) *out_xyz_curves,
	               size = (*num_out_curves +
	               2*loc_num_trim_curves) * sizeof(struct EMSdataselect));

	            *out_uv_curves = (struct EMSdataselect *) om$realloc(
	               ptr = (IGRchar *) *out_uv_curves,
	               size = (*num_out_curves +
	               2*loc_num_trim_curves) * sizeof(struct EMSdataselect));
	           }
	          else
	           {
	            *out_xyz_curves = (struct EMSdataselect *) om$malloc(size=
	                2*loc_num_trim_curves * sizeof(struct EMSdataselect));

	            *out_uv_curves = (struct EMSdataselect *) om$malloc(size=
	                2*loc_num_trim_curves * sizeof(struct EMSdataselect));
	           }
                  out_curves_buff = 2*loc_num_trim_curves;
	          EMerr_hndlr(!*out_xyz_curves || !*out_uv_curves, *EMmsg,
	                      EMS_E_NoDynamicMemory, wrapup);

                 } /* if(loc_num_trim_curves > out_curves_buff) */

                for(j=0; j<loc_num_trim_curves; j++)
                 {
	          struct IGRpolyline *poly_3d, *poly_2d;

	          (*out_uv_curves)[*num_out_curves] = loc_out_trim_curves[j];
                  loc_out_trim_curves[j].data.poly = NULL;
                  loc_out_trim_curves[j].datatype = EMSdata_null;
                  poly_2d = (*out_uv_curves)[*num_out_curves].data.poly;

                  (*out_xyz_curves)[*num_out_curves].datatype = EMSdata_poly3d;
                  poly_3d = (struct IGRpolyline *) om$malloc(size =
                            sizeof(struct IGRpolyline));
                  EMerr_hndlr(!poly_3d, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
                  poly_3d->num_points = poly_2d->num_points;

                  poly_3d->points = (IGRdouble *) om$malloc(size =
                             poly_2d->num_points * 3 * sizeof(IGRdouble));
                  EMerr_hndlr(!poly_3d->points, *EMmsg, EMS_E_NoDynamicMemory,
                    wrapup);

                  BSsfptseval (surface, poly_2d->num_points,
                             poly_2d->points, poly_3d->points, &rc);
                  EMerr_hndlr (rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

                  (*out_xyz_curves)[*num_out_curves].data.poly = poly_3d;

                  EFstroke_line_string (&rc, surface, partolbasis->tol,
                           &poly_3d->num_points,
                           &poly_3d->points, &poly_2d->points );
                  EMerr_hndlr(!(1&rc),*EMmsg,EMS_E_Fail,wrapup);
                  poly_2d->num_points = poly_3d->num_points;

                  (*num_out_curves)++;
                  out_curves_buff--;
                 }

               } /* for(m=0; m<num_groups; m++) */

            } /* for (i = 0; i < loc_num_out_curves; i++) */

            if (old_cht != *cht_tol)
                 status = BSchangepar (&rc, BSTOLCHRDHT, old_cht);

          } /* if (*num_out_curves) */

        } /* else for if (linear_map_ok) */

        /*
         * set the output curve types correctly
         */

        if( !(options & EMMapBnd_NoCurveType) && *num_out_curves)
        {
           IGRboolean	get_clipped_type = FALSE;
           IGRboolean	clipping_on;

           clipping_on = ( ! (options & EMMapBnd_NoClip));
           if (surface->planar)		/* rlw 10/10/88 */
            {
              if(clipping_on && is_crv_clipped)
               get_clipped_type = TRUE;
              rc = EFget_the_edge_type_for_an_object (NULL_OBJID,
                      NULL, projected_curve_class, out_curve_type);
              EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);
            }
           else if ((*out_xyz_curves)[0].datatype == EMSdata_poly3d )
           {
	      if (surface->planar) *out_curve_type = EMplanar_linestring;
	      else *out_curve_type = EMlinestring;
           }
           else
           {
             if (all_points_on_surface)
             {
	        rc = EFget_the_edge_type_for_an_object (curve_GRid.objid,
			curve_GRid.osnum, NULL, out_curve_type);
		    EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);
             }

             else if (!all_points_within_tolerance)
                *out_curve_type = EMfreeform_curve;

             else
              {
                if (clipping_on && is_crv_clipped)
                 get_clipped_type = TRUE;
                rc = EFget_the_edge_type_for_an_object (curve_GRid.objid,
                        curve_GRid.osnum, NULL, out_curve_type);
                EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);
              }
           } /* else for if ((*out_xyz_curves)[i].datatype ==
                                                   EMSdata_poly3d ) */
          if (get_clipped_type)
           {
            extern	IGRlong EFget_clipped_edge_type();

            rc = EFget_clipped_edge_type(
             EMmsg,
             *out_curve_type,
             out_curve_type);
           }

        } /* if( !(options & EMGetBnd_NoCurveType) && *num_out_curves) */

        /*
         * If the mapped curve is a 3d-bspline, it is possible that
         * its end pts slightly outside the uv_range though within
         * parametric tolerance. In such cases, snap it to the
         * uv_range.
         */

        minu = surface->u_knots[surface->u_order-1];
        maxu = surface->u_knots[surface->u_num_poles];
        minv = surface->v_knots[surface->v_order-1];
        maxv = surface->v_knots[surface->v_num_poles];

        for (i = 0; i < *num_out_curves; i++)
        {
         if ( (*out_uv_curves)[i].datatype == EMSdata_curve3d)
         {
           temp_cv = (*out_uv_curves)[i].data.curve;
           for (j = 0; j < 2; j++)
           {
             end_pts = j ? &temp_cv->poles[3*(temp_cv->num_poles-1)] :
                            temp_cv->poles;

             if (temp_cv->rational)
             {
               wt = j ? temp_cv->weights[temp_cv->num_poles-1] :
                        temp_cv->weights[0];

               if ( (end_pts[0]/wt) < minu &&
                    (minu - end_pts[0]/wt) <= partolbasis->tol)
                  end_pts[0] = wt * minu;
               else if ( (end_pts[0]/wt) > maxu &&
                         (end_pts[0]/wt - maxu) <= partolbasis->tol)
                   end_pts[0] = wt * maxu;

               if ( (end_pts[1]/wt) < minv &&
                    (minv - end_pts[1]/wt) <= partolbasis->tol )
                  end_pts[1] = wt * minv;
               else if ( (end_pts[1]/wt) > maxv &&
                         (end_pts[1]/wt - maxv) <= partolbasis->tol)
                  end_pts[1] = wt * maxv;

             } /* if (temp_cv->rational) */
             else
             {
               if ( end_pts[0] < minu &&
                    (minu - end_pts[0]) <= partolbasis->tol )
                 end_pts[0] = minu;
               else if ( end_pts[0] > maxu &&
                         (end_pts[0] - maxu) <= partolbasis->tol )
                 end_pts[0] = maxu;

               if ( end_pts[1] < minv &&
                    (minv - end_pts[1]) <= partolbasis->tol)
                  end_pts[1] = minv;
               else if ( end_pts[1] > maxv &&
                         (end_pts[1] - maxv) <= partolbasis->tol)
                  end_pts[1] = maxv;

             } /* else for if (temp_cv->rational) */

           } /* for (j = 0; j < 2; j++) */

         } /* if ( (*out_uv_curves)[i].datatype == EMSdata_curve3d) */


        } /* for (i = 0; i < *num_out_curves; i++) */

wrapup:
        if ( (1&*EMmsg) &&
             (is_crv_clipped || !all_points_within_tolerance) )
          *EMmsg = EMS_I_OutOfBounds;

        if (uv_pnts) om$dealloc(ptr = uv_pnts);
        if (xyz_pnts) om$dealloc(ptr = xyz_pnts);
        if (uv_2d_poles) om$dealloc (ptr = uv_2d_poles);
        if (in_geom)
        {
          if (in_geom->datatype == EMSdata_poly2d)
          {
            if (in_geom->data.poly)
            {
                poly_2d = in_geom->data.poly;
                if (poly_2d->points)
                om$dealloc (ptr = poly_2d->points);
                om$dealloc (ptr = poly_2d);
            }
          } /* if (in_geom->datatype == EMSdata_poly2d) */

          else  /* it is EMSdata_curve3d */
          {
                crv_uv = in_geom->data.curve;
                if (crv_uv) BSfreecv (&rc, crv_uv);

           } /* else for if (in_geom->datatype == EMSdata_poly2d) */

           om$dealloc(ptr = in_geom);

        } /* if (in_geom) */

        if (nsp_pl_trimming_done)
        {
           for (i = 0; i < *num_out_curves; i++)
           {
             status = BSfreecv (&rc, tr_cvs[i]);
           }
           if (tr_cvs) om$dealloc (ptr = tr_cvs);

        } /* if (nsp_pl_trimming_done) */

/*      if (in_curve->order == 2 && in_curve->rational) */
        if (curve && (curve != in_curve))	/* rlw - 10/10/88 */
          status = BSfreecv (&rc, curve);

        if(modified_curve.poles) om$dealloc(ptr = modified_curve.poles);
        if(modified_curve.knots) om$dealloc(ptr = modified_curve.knots);
        if(modified_curve.weights) om$dealloc(ptr = modified_curve.weights);

        if(loc_poly3d.points) om$dealloc(ptr = loc_poly3d.points);
	if(loc_poly2d.points) om$dealloc(ptr = loc_poly2d.points);
        if(loc_out_trim_curves) om$dealloc(ptr = loc_out_trim_curves);
        if(loc_out_uv_curves) om$dealloc(ptr = loc_out_uv_curves);
        for(n=0; n<num_groups; n++)
         {
          if(xyz_group && xyz_group[n]) om$dealloc(ptr = xyz_group[n]);
	  if(uv_group && uv_group[n]) om$dealloc(ptr = uv_group[n]);
         }
        if(points_per_group) om$dealloc(ptr = points_per_group);
        if(xyz_group) om$dealloc(ptr = xyz_group);
        if(uv_group) om$dealloc(ptr = uv_group);

        if (!(1 & *EMmsg) ) return (FALSE);
        return (TRUE);

} /* end EFmap_the_crv */


/*
 * The following functions clips a geometry (EMSdata_poly2d or
 * EMSdata_curve3d) against a loopset and returns the
 * clipped geomteries (EMSdata_poly2d or EMSdata_curve3d) that
 * correspond to the solid areas of the loopset.
 */

static IGRboolean EFclip_the_curve (
        in_curve,
        ls_GRid,
        partolbasis,
	options,
        is_crv_clipped,
        num_clipped_curves,
        clipped_curves,
        edge_bdrys,
        EMmsg)

struct EMSdataselect    **in_curve;
struct GRid             ls_GRid;
struct EMSpartolbasis   *partolbasis;
IGRushort	options;
IGRboolean              *is_crv_clipped;
IGRint                  *num_clipped_curves;
struct EMSdataselect    **clipped_curves;
struct EMSsfintedpar    ***edge_bdrys;
IGRlong                 *EMmsg;

{
  IGRlong               OM_stat, mthd_stat, rc;
  IGRint                num_bdrys, i, num_poles, cvinx;
  IGRboolean            status, cl_crv_good, cl_crv_deg;
  IGRdouble             beg_par, end_par, mid_par;
  struct  IGRpolyline   *in_geom_poly = NULL, clipped_poly;
  struct  IGRbsp_curve  *in_gm_crv = NULL, *cl_crv;
  struct  EMSpypoint    *in_geom_bdrys, *in_geom_bdrys_ptr;
  struct  EMSsfintedpar *ls_bdrys, *ls_bdrys_ptr;
  struct  EMSdataselect *in_geom, *out_data_ptr;

  void          EMgetactpy ();
  extern IGRboolean EFpts_degenerate() ;
  extern   void          EMpypoint_free();

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  *is_crv_clipped = TRUE;
  in_geom = *in_curve;
  in_geom_bdrys = NULL;
  *num_clipped_curves = 0;
  ls_bdrys = ls_bdrys_ptr = NULL;
  in_geom_bdrys = in_geom_bdrys_ptr = NULL;
  num_bdrys = 0;

  /*
   * trim the in coming geometry against the
   * loopset under consideration.
   */

  OM_stat = om$send (msg = message EMSloopset.EMlsparttrim (
             &mthd_stat, in_geom, partolbasis,
             options & EMMapBnd_ClipBdryArea ? EMS_INTER_BDRYISAREA : NULL,
             &num_bdrys, &in_geom_bdrys, edge_bdrys ? &ls_bdrys : NULL),
             senderid = NULL_OBJID, targetid = ls_GRid.objid,
             targetos = ls_GRid.osnum);
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

  if (num_bdrys)
  {
    if (in_geom->datatype == EMSdata_poly2d)
                in_geom_poly = in_geom->data.poly;
    else in_gm_crv = in_geom->data.curve;

    /*
     * if the num_bdrys is 1, there is only one portion
     * of the in_geom is in thesolid area. If the parameter
     * at bdrys represent the begin and end parameters,
     * the whole curve is in the solid area.
     */

    if (num_bdrys == 1)
    {
        if (in_geom->datatype == EMSdata_poly2d)
        {
          IGRint  last_pole;

          last_pole = (in_geom_poly->num_points - 1) * 2;

          if ((in_geom_bdrys->point[0] == in_geom_poly->points[0])
            && (in_geom_bdrys->point[1] == in_geom_poly->points[1])
            && (in_geom_bdrys->next->point[0] == in_geom_poly->points[last_pole])
            && (in_geom_bdrys->next->point[1]==in_geom_poly->points[last_pole+1]))

            *is_crv_clipped = FALSE;

          } /* if (in_geom->datatype == EMSdata_poly2d) */
          else
          {
             if (in_geom_bdrys->param == 0 &&
             in_geom_bdrys->next->param == 1) *is_crv_clipped = FALSE;
          }

          if (!(*is_crv_clipped))
          {
            cl_crv_good = TRUE;

           if (options & EMMapBnd_RmvDegenCvs)
           {
            if (in_geom->datatype == EMSdata_poly2d)

             cl_crv_deg =  EFpts_degenerate (in_geom_poly->num_points,
                           in_geom_poly->points,
                           NULL, 2, partolbasis->tol);
            else
             cl_crv_deg =  EFpts_degenerate (in_gm_crv->num_poles,
                             in_gm_crv->poles, in_gm_crv->weights, 3,
                             partolbasis->tol);
           if (cl_crv_deg) cl_crv_good = FALSE;
          }

          if (cl_crv_good)
          {
            *num_clipped_curves = 1;
            clipped_curves[0] = in_geom;
            *in_curve = NULL;
            if (edge_bdrys)
	    {
	      /* Added the check to see if memory is allocated in *edge_bdrys.
		 If not allocating it. - Ashok 11/Jan/94
	      */
	      if(!(*edge_bdrys))
	      {
		*edge_bdrys = (struct EMSsfintedpar **) om$malloc (size =
                        num_bdrys * sizeof (struct EMSsfintedpar *));
		EMerr_hndlr (!(*edge_bdrys),*EMmsg,EMS_E_NoDynamicMemory,
			     wrapup);
	      }
              (*edge_bdrys)[0] = ls_bdrys;
	    }
          }
          goto wrapup;
          } /* if (!(*is_crv_clipped))  */

    } /* if (num_bdrys == 1) */

    *clipped_curves = (struct EMSdataselect *) om$malloc (
                        size = num_bdrys * sizeof(struct EMSdataselect));
    EMerr_hndlr (!(*clipped_curves),*EMmsg, EMS_E_NoDynamicMemory,wrapup);

    if (edge_bdrys)
    {
    *edge_bdrys = (struct EMSsfintedpar **) om$malloc (size =
                        num_bdrys * sizeof (struct EMSsfintedpar *));
    EMerr_hndlr (!(*edge_bdrys),*EMmsg,EMS_E_NoDynamicMemory,wrapup);

    }
    in_geom_bdrys_ptr = in_geom_bdrys;
    ls_bdrys_ptr = ls_bdrys;

    cvinx = 0;
    for (i = 0 ; i < num_bdrys; i++)
    {
        if (in_geom->datatype == EMSdata_poly2d)
        {
          clipped_poly.points = NULL;
          EMgetactpy (&rc, in_geom->data.poly, 2,
                in_geom_bdrys_ptr, &clipped_poly);
          EMerr_hndlr(!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

        } /* if (in_geom->datatype == EMSdata_poly2d) */

        else
        {
          cl_crv = NULL;
          num_poles = in_gm_crv->num_poles + 2 * in_gm_crv->order - 1;
          BSalloccv (in_gm_crv->order, num_poles,
                        in_gm_crv->rational, 0, &cl_crv, &rc);
          EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory,
                        wrapup);

          beg_par = in_geom_bdrys_ptr[0].param;
          end_par = in_geom_bdrys_ptr[0].next[0].param;

          if (in_gm_crv->phy_closed)
           mid_par = (beg_par < end_par) ? ((beg_par+end_par)/2.) : 0. ;
          else mid_par = 0;

          status = BSpartofcv (&rc, in_gm_crv, beg_par, mid_par,
                                         end_par, cl_crv);
          EMerr_hndlr(!status || rc!=BSSUCC,*EMmsg,EMS_E_BSerror, wrapup);

        } /* else for if (in_geom->datatype == EMSdata_poly2d) */

        cl_crv_good = TRUE;
        if (options & EMMapBnd_RmvDegenCvs)
        {
         if (in_geom->datatype == EMSdata_poly2d)

         cl_crv_deg =  EFpts_degenerate (clipped_poly.num_points,
                          clipped_poly.points, NULL, 2, partolbasis->tol);
         else
          cl_crv_deg =  EFpts_degenerate (cl_crv->num_poles,
                             cl_crv->poles, cl_crv->weights, 3,
                             partolbasis->tol);
         if (cl_crv_deg) cl_crv_good = FALSE;
        }

        if (cl_crv_good)
        {
         out_data_ptr = &(*clipped_curves)[cvinx];
         if (in_geom->datatype == EMSdata_poly2d)
         {
          out_data_ptr->datatype = EMSdata_poly2d;
          out_data_ptr->data.poly = (struct IGRpolyline *)
                om$malloc (size = sizeof(struct IGRpolyline));
          out_data_ptr->data.poly->points = clipped_poly.points;
          out_data_ptr->data.poly->num_points = clipped_poly.num_points;
         } /* if (in_geom->datatype == EMSdata_poly2d) */
         else
         {
          out_data_ptr->datatype = EMSdata_curve3d;
          out_data_ptr->data.curve = cl_crv;
         }

         if (edge_bdrys)
         {
	   /* Fixed a memory problem. Added lines shown below.
	      Ashok 29/Dec/93
	   */
	   struct EMSsfintedpar	*tmp_edpars;        /* Added this line -Ashok */
	   tmp_edpars = ls_bdrys_ptr->next->next;   /* Added this line -Ashok */
           (*edge_bdrys)[cvinx] = ls_bdrys_ptr;
           (*edge_bdrys)[cvinx]->next->next = NULL;
	   ls_bdrys_ptr = tmp_edpars;		    /* Added this line -Ashok */
         }
         cvinx++;
        } /* if (cl_crv_good) */

        else
        {
          if (in_geom->datatype == EMSdata_poly2d)
           om$dealloc (ptr = clipped_poly.points);
          else
            BSfreecv (&rc, cl_crv);
          if (edge_bdrys) ls_bdrys_ptr = ls_bdrys_ptr->next->next;
        }

/* Moved the line below into the else block above -Ashok 29-Dec-93
        if (edge_bdrys) ls_bdrys_ptr = ls_bdrys_ptr->next->next;
*/
        in_geom_bdrys_ptr = in_geom_bdrys_ptr->next->next;

    } /* for (i = 0 ; i < num_bdrys; i++) */

  *num_clipped_curves = cvinx;

  } /* if (num_bdrys) */


wrapup:
        if (in_geom_bdrys)
          EMpypoint_free (in_geom_bdrys, NULL);
        if (!(1 & *EMmsg) ) return (FALSE);
        return (TRUE);

}  /* end of EFclip_the_curve */


void EFstroke_line_string (
     msg,
     sf_geom,
     par_tol,
     num_pts,
     xyzpts,
     uvpts)

IGRlong               *msg;
struct IGRbsp_surface *sf_geom;
IGRdouble             par_tol;
IGRlong               *num_pts;
IGRdouble             **xyzpts, **uvpts;

{
  IGRboolean    status, onsrf, ins_pt, seam_utest, seam_vtest;
  IGRint        loop_cnt, cur_inx, uvarray_size, xyzarray_size, num_seam_pts;
  IGRlong       rc;
  IGRdouble     tol_sq, cht_tol, *xyzseg, *uvseg, uvpt[4], xyzpt[6],
                prev_dist,   bastol, exist_uv[2][2], uvdist;
  IGRdouble     dist_sq, TEST_BAND, TEST_LU, TEST_HU, TEST_LV, TEST_HV;
  extern  IGRdouble  fabs();
  IGRdouble     EMmdistptseg();

  TEST_BAND = 0.90;
  TEST_LU = ( 1 - TEST_BAND ) / 2.;
  TEST_HU = 1 - TEST_LU;
  TEST_LV = TEST_LU;
  TEST_HV = TEST_HU;

  *msg = EMS_S_Success;
  uvarray_size = xyzarray_size = *num_pts;

  BSEXTRACTPAR (&rc, BSTOLCHRDHT, cht_tol);
  BSEXTRACTPAR (&rc, BSTOLLENVEC, bastol);
  tol_sq = cht_tol * cht_tol;

  /*
   * It is assumed that the end points of the incoming
   * linestring lie onto the surface.
   * The uvlinstring's segments are evaluated at their mid points.
   * If this mid point is away from the corresponding model space
   * line segment by more than chord_height tolerance, a point is
   * inserted at the middle of the model space line_segment. This
   * process is repeated until each linsegment is within chord_height
   * tolerance of its uv counterpart.
   *
   * If the surface is physically closed in one or both
   * directions, the following check is made while
   * crossing over the seam line. This is done to avoid infinite looping
   * conditions:
   *
   *  If the end points of uv_linesegment lie outside the TEST_BAND,
   *  in the physically closed direction and the new point inserted
   *  happens to be lie outside TEST_BAND, it is assumed the linesegment
   *  is crossing over the seam. In such a situation, the linesegment
   *  is sikkped for further checking and the control goes to the
   *  next segment.
   *
   */

   loop_cnt = cur_inx = 0;
   prev_dist = MAXDOUBLE;
   do
   {
     xyzseg = &((*xyzpts)[cur_inx*3]);
     uvseg = &((*uvpts)[cur_inx*2]);
     OM_BLOCK_MOVE(uvseg, exist_uv[0], 2*sizeof(IGRdouble));
     OM_BLOCK_MOVE(&uvseg[2], exist_uv[1], 2*sizeof(IGRdouble));

     seam_utest = seam_vtest = FALSE;

     if (sf_geom->u_phy_closed)
       if ( fabs( uvseg[2] - uvseg[0]) > TEST_BAND ) seam_utest = TRUE;

     if (sf_geom->v_phy_closed )
       if ( fabs(uvseg[3] - uvseg[1]) > TEST_BAND ) seam_vtest = TRUE;

     uvpt[0] = uvseg[0] + TEST_PARAM * (uvseg[2] - uvseg[0]);
     uvpt[1] = uvseg[1] + TEST_PARAM * (uvseg[3] - uvseg[1]);

     BSsfeval (sf_geom, uvpt[0], uvpt[1], 0, (IGRpoint *)xyzpt, &rc);
     EMerr_hndlr (rc != BSSUCC, *msg, EMS_E_BSerror, wrapup);

     dist_sq = EMmdistptseg (&rc, xyzseg, &xyzseg[3], xyzpt,
                             3, NULL, NULL, NULL);
     if ( (dist_sq > tol_sq) && ( fabs(dist_sq - prev_dist) > bastol))
     {
       IGRboolean uv_already_exists = FALSE;

       prev_dist = dist_sq;
       xyzpt[X] = xyzseg[X] + 0.5 * (xyzseg[3+X] - xyzseg[X]);
       xyzpt[Y] = xyzseg[Y] + 0.5 * (xyzseg[3+Y] - xyzseg[Y]);
       xyzpt[Z] = xyzseg[Z] + 0.5 * (xyzseg[3+Z] - xyzseg[Z]);

       status = BSprptonsf (&rc, sf_geom, xyzpt, &uvpt[0], &uvpt[1], &onsrf);
       EMerr_hndlr (rc != BSSUCC, *msg, EMS_E_BSerror, wrapup);

       BSsfeval (sf_geom, uvpt[0], uvpt[1], 0, (IGRpoint *)xyzpt, &rc);
       EMerr_hndlr (rc != BSSUCC, *msg, EMS_E_BSerror, wrapup);

       ins_pt = TRUE;

       if (seam_utest)
         if ( ( uvpt[0] >= 0. && uvpt[0] <= TEST_LU ) ||
              ( uvpt[0] >= TEST_HU && uvpt[0] <= 1.0 ) ) ins_pt = FALSE;

       if (ins_pt && seam_vtest )
         if ( ( uvpt[1] >= 0. && uvpt[1] <= TEST_LV ) ||
              ( uvpt[1] >= TEST_HV && uvpt[1] <= 1.0 ) ) ins_pt = FALSE;

       uv_already_exists = FALSE;
       if(ins_pt)
       {
         uvdist = EM2ddistptpt(exist_uv[1], uvpt);
         if(uvdist < par_tol) uv_already_exists = TRUE;
         else
         {
           uvdist = EM2ddistptpt(exist_uv[0], uvpt);
           if(uvdist < par_tol) uv_already_exists = TRUE;
         }
       }

       if (ins_pt && !uv_already_exists)
       {
         EFinsert_pts (&rc, 2, 1, uvpt, cur_inx+1, num_pts, uvpts, &uvarray_size);
         EMerr_hndlr (!(1&rc), *msg, EMS_E_Fail, wrapup);

         EFinsert_pts (&rc, 3, 1, xyzpt, cur_inx+1, num_pts, xyzpts, &xyzarray_size);
         EMerr_hndlr (!(1&rc), *msg, EMS_E_Fail, wrapup);

         (*num_pts)++;

       } /* if (ins_pt) */

       else if(!uv_already_exists)
       {
         num_seam_pts = 0;

         /*
          * It may be possible that the segement under consideration
          * is the first or the last segment. In such a case only one
          * point needs to be inserted, either at the begin or at the
          * end.
          */

         if (sf_geom->u_phy_closed && !sf_geom->v_phy_closed)
         {
           IGRdouble   u = 0.0, v = 0.0;
           IGRboolean  avg_v = TRUE, end_seg = FALSE;

           if (!cur_inx)
           {
             if ( (fabs(uvseg[U] - 0.) < par_tol) ||
                  (fabs(uvseg[U] - 1.0) < par_tol) )  end_seg = TRUE;
           }
           else if (cur_inx == *num_pts - 2)
           {
             if ( (fabs(uvseg[U+2] - 0.) < par_tol) ||
                  (fabs(uvseg[U+2] - 1.0) < par_tol) )  end_seg = TRUE;

           } /* else if (cur_inx == *num_pts - 2) */

           if (end_seg)
           {
             u = uvpt[U] < 0.5 ? 0. : 1.0;
             if (!cur_inx)
               uvseg[U] = u;
             else
               uvseg[2+U] = u;
           } /* if (end_seg) */
           else
           {
             u = uvseg[U] < 0.50 ? 0. : 1.0;
             if ( fabs(uvseg[U] - u) > par_tol )
             {
               uvpt[num_seam_pts*2] = u;
               num_seam_pts++;
             }
             else
             {
               uvseg[U] = u;
               v = uvseg[V];
               avg_v = FALSE;
             }

             u = uvseg[U] < 0.50 ? 1. : 0.;
             if ( fabs(uvseg[2+U] - u) > par_tol )
             {
               uvpt[num_seam_pts*2] = u;
               num_seam_pts++;
             }
             else
             {
               uvseg[2+U] = u;
               v = uvseg[2+V];
               avg_v = FALSE;
             }
             if (num_seam_pts)
             {
               if (avg_v)
                 uvpt[V] = uvpt[2+V] = (uvseg[V] + uvseg[2+V])/2.;
               else
                 uvpt[V] = uvpt[2+V] = v;
             }
           } /* else if (end_seg) */

         } /* if (sf_geom->u_phy_closed && !sf_geom->v_phy_closed) */

         if (sf_geom->v_phy_closed && !sf_geom->u_phy_closed)
         {
           IGRdouble    u = 0, v = 0;
           IGRboolean  avg_u = TRUE, end_seg = FALSE;

           if (!cur_inx)
           {
             if ( (fabs(uvseg[V] - 0.) < par_tol) ||
                  (fabs(uvseg[V] - 1.0) < par_tol) )  end_seg = TRUE;
           }
           else if (cur_inx == *num_pts - 2)
           {
             if ( (fabs(uvseg[V+2] - 0.) < par_tol) ||
                  (fabs(uvseg[V+2] - 1.0) < par_tol) )  end_seg = TRUE;

           } /* else if (cur_inx == *num_pts - 2) */

           if (end_seg)
           {
             v = uvpt[V] < 0.5 ? 0. : 1.0;
             if (!cur_inx)
               uvseg[V] = v;
             else
               uvseg[2+V] = v;

           } /* if (end_seg) */

           else
           {
             v = uvseg[V] < 0.50 ? 0. : 1.0;
             if ( fabs(uvseg[V] - v) > par_tol )
             {
               uvpt[num_seam_pts*2+1] = v;
               num_seam_pts++;
             }
             else
             {
               uvseg[V] = v;
               u = uvseg[U];
               avg_u = FALSE;
             }

             v = uvseg[V] < 0.50 ? 1. : 0.;
             if ( fabs(uvseg[2+V] - v) > par_tol )
             {
               uvpt[num_seam_pts*2+1] = v;
               num_seam_pts++;
             }
             else
             {
               uvseg[2+V] = v;
               u = uvseg[2+U];
               avg_u = FALSE;
             }
             if (num_seam_pts)
             {
               if (avg_u)
                 uvpt[U] = uvpt[2+U] = (uvseg[U] + uvseg[2+U])/2.;
               else
                 uvpt[U] = uvpt[2+U] = u;
             }
           } /* else for if (end_seg) */

         } /* if (sf_geom->v_phy_closed && !sf_geom->u_phy_closed) */

         if (num_seam_pts)
         {

           BSsfptseval (sf_geom, num_seam_pts, uvpt,
                        xyzpt, &rc);
           EMerr_hndlr (rc != BSSUCC,*msg,EMS_E_BSerror,wrapup);
           EFinsert_pts (&rc, 2, num_seam_pts, uvpt, cur_inx+1,
                         num_pts, uvpts, &uvarray_size);
           EMerr_hndlr (!(1&rc), *msg, EMS_E_Fail, wrapup);

           EFinsert_pts (&rc, 3, num_seam_pts, xyzpt, cur_inx+1,
                         num_pts, xyzpts, &xyzarray_size);
           EMerr_hndlr (!(1&rc), *msg, EMS_E_Fail, wrapup);

         } /* if (num_seam_pts) */

         (*num_pts) += num_seam_pts;
         cur_inx += (num_seam_pts+1);

       } /* else for if (ins_pt) */
       else
       {
         cur_inx++;
         prev_dist = MAXDOUBLE;
       }

     } /* if (dist_sq > tolsq) */
     else
     {
       cur_inx++;
       prev_dist = MAXDOUBLE;
     }
     //HF: 03/08/2001 - TR# MP4828 Should never get into infinite loop ...
     if (loop_cnt++ > 100 && cur_inx == 0)
     {
       rc=0;
       EMerr_hndlr (!(1&rc), *msg, EMS_E_Fail, wrapup);
     }
   } while (cur_inx < *num_pts-1);

   if (uvarray_size > *num_pts)
   {
     *xyzpts = (IGRdouble *) om$realloc (ptr = (IGRchar *)*xyzpts,
                                         size = (*num_pts) * 3 * sizeof(IGRdouble));
     *uvpts = (IGRdouble *) om$realloc (ptr = (IGRchar *)*uvpts,
                                        size = (*num_pts) * 2 * sizeof(IGRdouble));
   }

wrapup:

  return;

} /*  EFstroke_line_string */

static void EFinsert_pts (
  msg,
  dim,
  numinspts,
  inspts,
  atinx,
  numpts,
  pts,
  array_size)

IGRlong     *msg;
IGRshort    dim;
IGRint      numinspts;
IGRdouble   *inspts;
IGRint      atinx, *numpts;
IGRdouble   **pts;
IGRint      *array_size;
{
  IGRint blksize;
  IGRdouble *pts_ptr;

  *msg = EMS_S_Success;

  if (*array_size < (*numpts + numinspts) )
  {
   (*array_size) += BUF_INC;
   blksize = (*array_size) * dim * sizeof(IGRdouble);
   *pts = (IGRdouble *) om$realloc (ptr = (IGRchar *)*pts, size = blksize);
   EMerr_hndlr (! *pts, *msg, EMS_E_NoDynamicMemory, wrapup);
  }

  pts_ptr = *pts;

  blksize = (*numpts - atinx) * dim * sizeof (IGRdouble);
  OM_BLOCK_MOVE (&pts_ptr[atinx * dim],
                 &pts_ptr[(atinx + numinspts) * dim], blksize);

  blksize = numinspts * dim * sizeof (IGRdouble);
  OM_BLOCK_MOVE (inspts, &pts_ptr[atinx * dim], blksize);

wrapup:
  return;
}

/* Following function will introduce knot of multiplicity = order-1 at each
   point where the input curve is within tolerence from the seam of a closed
   surface. In case of failures, mod_cv will remain NULL. Memory for the
   new curve is allocated by the function and should be freed by the caller.
*/
static IGRboolean check_for_nat_crossing(in_cv, mod_cv, sf)
struct IGRbsp_curve *in_cv, *mod_cv;
struct IGRbsp_surface *sf;
{
 IGRlong		rc;
 IGRint			i, num = 0, j, multi, extra;
 struct IGRbsp_curve 	nat;
 IGRboolean 		bssts, tst_plan = TRUE, done = FALSE,
		        enough_mem = TRUE;
 IGRshort		opt;
 IGRdouble		uv = 0.0, *par1 = NULL, *par2 = NULL, mindist = 0.0,
			chttol;
 IGRpoint		*pt1 = NULL, *pt2 = NULL;

 mod_cv->poles = NULL;
 mod_cv->knots = NULL;
 mod_cv->weights = NULL;

 nat.poles = NULL;
 nat.knots = NULL;
 nat.weights = NULL;

 if(!sf) goto wrapup;
 /*if(!sf->u_phy_closed && !sf->v_phy_closed) goto wrapup;*/

 nat.poles = (IGRdouble *) om$malloc(size = 3 * sizeof(IGRdouble) *
                (sf->u_num_poles > sf->v_num_poles ? sf->u_num_poles :
		 sf->v_num_poles));

 nat.knots = (IGRdouble *) om$malloc(size = sizeof(IGRdouble) *
                (sf->u_num_knots > sf->v_num_knots ? sf->u_num_knots :
		 sf->v_num_knots));

 if(sf->rational)
  nat.weights = (IGRdouble *) om$malloc(size = sizeof(IGRdouble) *
                   (sf->u_num_poles > sf->v_num_poles ? sf->u_num_poles :
		   sf->v_num_poles));

 BSEXTRACTPAR(&rc, BSTOLCHRDHT, chttol);

 for(i=0; i<4; i++)
  {
   /* If the surface is open in the direction being considered, continue.
   */
/************
   if( (!i && !sf->u_phy_closed) ||
       (i && !sf->v_phy_closed))
    continue;
************/

   /* Extract the natural bdry in the direction being considered.
   */
   if( (i == 0) || (i == 1))
    {
     opt = 1;   /* constant u */
     uv = i ? 1.0 : 0.0;
    }
   else
    {
     opt = 2;   /* constant v */
     uv = (i == 2) ? 0.0 : 1.0;
    }

   /*opt = i+1;*/
   bssts = BSconstprcv(&rc, sf, &opt, &uv, &tst_plan, &nat);
   if(!bssts || (rc!=BSSUCC)) goto wrapup;

   /* Get minimum distance points between the curve and the natural bdry.
   */
   num = 0;
   if(par1) om$dealloc(ptr = par1);
   if(par2) om$dealloc(ptr = par2);
   if(pt1) om$dealloc(ptr = pt1);
   if(pt2) om$dealloc(ptr = pt2);
   par1 = par2 = NULL;
   pt1 = pt2 = NULL;

   if(!done)
    {
     mod_cv->poles = (IGRdouble *) om$malloc(size = 3 * sizeof(IGRdouble) *
			in_cv->num_poles);
     mod_cv->knots = (IGRdouble *) om$malloc(size = sizeof(IGRdouble) *
			in_cv->num_knots);
     if(!mod_cv->poles || !mod_cv->knots)
      goto wrapup;

     if(in_cv->rational)
      {
       mod_cv->weights = (IGRdouble *) om$malloc(size = sizeof(IGRdouble) *
			 in_cv->num_poles);
       if(!mod_cv->weights)
        goto wrapup;
      }

     bssts = BScv_copy(&rc, in_cv, mod_cv);
     if(!bssts || (rc!=BSSUCC)) goto wrapup;
     done = TRUE;
    }

   BSmdistcvcv(mod_cv, &nat, &num, &par1, &par2, &pt1, &pt2, &mindist, &rc);
   if(rc!=BSSUCC) continue;

   /* Introduce the knot even if the curve to be projected is away from the
    * surface by more than chord height (the modified curve buffer and not the
    * input curve buffer is affected, so no problem). Also, even if the curve
    * to be projected is MORE than chord height away from the surface, we will
    * still have valid projection points at the nats, without having to
    * interpolate for them.
                if(mindist > chttol) continue; (removed on 9/28/92. NP)
    */

   if(!num) continue;

   /* Realloc enough memory for all knot values to be inserted.
      num * (order - 1) extra poles
      num * (order - 1) extra knots
      num * (order - 1) extra weights
   */
   multi = mod_cv->order - 1;
   extra = num * multi;

   mod_cv->poles = (IGRdouble *) om$realloc(size = 3 * sizeof(IGRdouble) *
	   (mod_cv->num_poles + extra), ptr = (IGRchar *)mod_cv->poles);
   mod_cv->knots = (IGRdouble *) om$realloc(size = sizeof(IGRdouble) *
	   (mod_cv->num_knots + extra), ptr = (IGRchar *)mod_cv->knots);
   if(!mod_cv->poles || !mod_cv->knots)
    goto wrapup;

   if(mod_cv->rational)
    {
     mod_cv->weights = (IGRdouble *) om$realloc(size = sizeof(IGRdouble) *
	  (mod_cv->num_poles + extra), ptr = (IGRchar *)mod_cv->weights);
     if(!mod_cv->weights)
      goto wrapup;
    }

    for(j=0; j<num; j++)
     bssts = BSadd_ktr(&rc, mod_cv, &par1[j], &multi, &enough_mem);

  } /* for(i=0; i<2; i++) */

wrapup:

if(nat.poles) om$dealloc(ptr = nat.poles);
if(nat.knots) om$dealloc(ptr = nat.knots);
if(nat.weights) om$dealloc(ptr = nat.weights);
if(par1) om$dealloc(ptr = par1);
if(par2) om$dealloc(ptr = par2);
if(pt1) om$dealloc(ptr = pt1);
if(pt2) om$dealloc(ptr = pt2);


if(done) return(TRUE);
else
 {
  if(mod_cv->poles) om$dealloc(ptr = mod_cv->poles);
  if(mod_cv->knots) om$dealloc(ptr = mod_cv->knots);
  if(mod_cv->weights) om$dealloc(ptr = mod_cv->weights);
  mod_cv->poles = NULL;
  mod_cv->knots = NULL;
  mod_cv->weights = NULL;
  return(FALSE);
 }

}

static long EFspecial_stroke_curve( struct IGRbsp_surface 	*srf_geom,
				    struct IGRbsp_curve		*crv_geom,
				    IGRdouble			*cht_tol,
				    struct IGRpolyline		*poly3d,
				    BSrc			*rc )
{
IGRlong			sts;
IGRint			i, nb_seg;
IGRboolean		is_planar, is_collinear, EFstroke_the_curve();
IGRdouble		par_u1, par_u2, par_v1, par_v2, mdist, base_pt[3],
			tpars[NB_SAMPLE_SEG+1];
IGRvector     		vec, normal_vector;

     // Check if the surface is planar
     BStst_plan( srf_geom->u_num_poles * srf_geom->v_num_poles,
                 srf_geom->poles, srf_geom->weights, &is_planar,
		 normal_vector, rc );
     if( *rc != BSSUCC || is_planar == FALSE ) goto default_stroke;

     // Check if the surface is a "normal" plane
     if( srf_geom->u_order == 2 && srf_geom->v_order == 2 &&
	 srf_geom->u_num_poles == 2 && srf_geom->v_num_poles == 2 )
      goto default_stroke;

/*
     // Check if four points form a "rectangural" plane
     for( i=0; i<3; ++i )
	vec[i] = srf_geom->poles[i] - srf_geom->poles[i+3] -
		 srf_geom->poles[i+6] + srf_geom->poles[i+9] ;
     printf("Vector = %g, %g, %g\n", vec[0], vec[1], vec[2] );

     if( fabs( BSdotp( rc, vec, vec ) ) > 1e-5 ) goto default_stroke;
*/

     // Check the length of curve.
     BSmdistptsf( rc, srf_geom, &crv_geom->poles[0], &par_u1, &par_v1,
		  &base_pt, &mdist );
     if( *rc != BSSUCC ) goto default_stroke;

     BSmdistptsf( rc, srf_geom, &crv_geom->poles[3*(crv_geom->num_poles-1)],
		  &par_u2, &par_v2, &base_pt, &mdist );
     if( *rc != BSSUCC ) goto default_stroke;

     if( fabs( par_u1 - par_u2 ) < 0.04 || fabs( par_v1 - par_v2 ) < 0.04 )
	goto default_stroke;

     // Check if all the point on the curve are collinear
     BScollinmn2( crv_geom->num_poles, crv_geom->poles, crv_geom->weights,
		  &is_collinear, rc );
     if( *rc != BSSUCC || is_collinear == FALSE ) goto default_stroke;

     poly3d->num_points = NB_SAMPLE_SEG+1;
     poly3d->points = (IGRdouble *) om$malloc (size =
                   sizeof(IGRdouble) * poly3d->num_points * 3);

     nb_seg = NB_SAMPLE_SEG;
     BSequalspcs( rc, crv_geom, &crv_geom->knots[crv_geom->order-1],
                  &nb_seg, tpars, poly3d->points );
     if( *rc == BSSUCC ) { *rc = 1; return 1; }
     else		 { *rc = 0; return 0; }

default_stroke:
     sts = EFstroke_the_curve( crv_geom, cht_tol, poly3d, rc );
     return sts;
}

end implementation Root;
