class implementation ECprims;

/*
  HISTORY

	Sudha	07/05/93	Modified for BSprototypes ansification

*/

#include <alloca.h>
#include "msdef.h"
#include "grgs.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dp.h"
#include "dpmacros.h"
#include "comndef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "growner.h"
#include "madef.h"
#include "mapriv.h"
#include "bserr.h"
#include "primco.h"
#include "maunitvc.h"
#include "matlncbcl.h"
#include "maptsxfor.h"
#include "maptplpro.h"
#include "magrotmx.h"
#include "bsdistnct2.h"
#include "bscveval.h"
#include "bscirc3pts.h"
#include "bsarc3pts.h"


from GRvg import GRdetplane;

struct DYturn_info
{
    IGRint                  mode;

    struct IGRline          centerline;
    struct IGRplane         plane;

    IGRdouble               start_vec[3];

    IGRint                  num_start_curves;
    struct DPele_header   * start_curves;
    IGRint                  num_start_points;
    IGRdouble             * start_points;

    IGRint                  num_end_curves;
    struct DPele_header   * end_curves;
    IGRint                  num_end_points;
    IGRdouble             * end_points;

    struct DPele_header   * turn_curves;
    IGRdouble             * turn_points;

    IGRint                  num_arcs;
    struct DPele_header   * arcs;
    IGRdouble             * arc_start_points;
    IGRdouble             * arc_mid_points;
    IGRdouble             * arc_end_points;

    IGRint                  num_buffers;
    struct DPele_header   * buffers;
};

IGRint DYturn ( msg, 
                info,
                num_events,
                events,
                num_curves,
                objects,
                buffers )
    IGRlong             * msg;
    IGRchar             * info;
    IGRint                num_events;
    struct GRevent      * events;
    IGRint                num_curves;
    struct GRid         * objects;
    struct DPele_header * buffers;
{
    IGRlong                 bs_msg;
    IGRint                  i, j;
    IGRboolean              dyn_on;         
    IGRboolean              inquire = 1;    
    IGRint                  size;
    struct DYturn_info      dyn_info;         
    IGRint                  DYturn_dyn();
    struct IGRdisplay       arc_display, center_display;
    struct GRmd_env       * mod_env;
    IGRdouble               normal[3], proj_point[3];
    IGRdouble             * p_point, * p_points[2], angle;
    struct DPele_header     centerline, * p_curves[2];
    struct IGRpolyline      polyline;
    IGRdouble               points[6];
    struct IGRline          line;
    IGRdouble               diag1[3], diag2[3], t1, t2;
    struct IGResbc          specific;
    IGRchar                 response_data[1024];
    IGRint                  response;

    *msg = MSSUCC;

    mod_env = &events[0].located_object[0].module_info;

    dyn_info.mode = *info;

    center_display.color  = 5;
    center_display.weight = 1;
    center_display.style  = 7;

    arc_display.color  = 2;
    arc_display.weight = 0;
    arc_display.style  = 0;

    /*
     * Set up element specific display for bsplines.
     */
    specific.is_polydis = FALSE;
    specific.is_curvedis = TRUE;

    /*
     * Get the number of points to allocate.
     */
    for (i=0, size = 0; i<num_curves; ++i)
        size += (buffers[i].type == IGRPY) ? 
            buffers[i].geometry.polyline->num_points :
            buffers[i].geometry.bspcurve->num_poles;

    /*
     * Allocate the display buffers for the end curves and the projection arcs.
     */
    dyn_info.buffers = (struct DPele_header *)alloca(((num_curves * 3) + size) * sizeof(struct DPele_header));

    /*
     * Define the rotation axis and projection plane. 
     */
    dyn_info.centerline.point1 = &events[EC_AXIS_POINT1].event.button.x;
    dyn_info.centerline.point2 = &events[EC_AXIS_POINT2].event.button.x;
    dyn_info.plane.point = dyn_info.centerline.point1;
    for (i=0; i<3; ++i) 
        normal[i] = dyn_info.centerline.point2[i] - dyn_info.centerline.point1[i];
    MAunitvc(msg, normal, normal);
    dyn_info.plane.normal = normal;

    /* 
     * Get a start vector. 
     */
    for (i=0; i<num_curves; ++i)
    {
        p_point = (buffers[i].type == IGRPY) ? 
                   buffers[i].geometry.polyline->points : 
                   buffers[i].geometry.bspcurve->poles;

        MAptplproj (msg, (IGRpoint *)p_point, &dyn_info.plane, proj_point);

        if (BSdistnct2(&bs_msg, dyn_info.plane.point, proj_point))
        {
            for (i=0; i<3; ++i) 
                dyn_info.start_vec[i] = proj_point[i] - dyn_info.plane.point[i];
            break;
        }
    }

    if (i==num_curves) goto quit;

    /*
     * Allocate the start and end point buffers.
     */
    dyn_info.num_start_points = dyn_info.num_end_points = size;
    dyn_info.start_points = (IGRdouble *)alloca(size * sizeof(IGRpoint));
    dyn_info.end_points = (IGRdouble *)alloca(size * sizeof(IGRpoint));

    /*
     * Set up the start curves buffer.
     */
    dyn_info.num_start_curves = num_curves;
    dyn_info.start_curves = (struct DPele_header *)alloca(num_curves * sizeof(struct DPele_header));
    memcpy(dyn_info.start_curves, buffers, num_curves * sizeof(struct DPele_header));

    for (i=0, p_point = dyn_info.start_points; i<num_curves; ++i)
    {
        if (buffers[i].type == IGRPY)
        {
            dyn_info.start_curves[i].geometry.polyline = (struct IGRpolyline *)alloca(sizeof(struct IGRpolyline));
            dyn_info.start_curves[i].geometry.polyline->num_points = buffers[i].geometry.polyline->num_points;
            dyn_info.start_curves[i].geometry.polyline->points = p_point;
            memcpy (p_point, buffers[i].geometry.polyline->points, buffers[i].geometry.polyline->num_points * sizeof(IGRpoint));
            p_point += buffers[i].geometry.polyline->num_points * 3;
        }
        else
        {
            dyn_info.start_curves[i].geometry.bspcurve = (struct IGRbsp_curve *)alloca(sizeof(struct IGRbsp_curve));
            *(dyn_info.start_curves[i].geometry.bspcurve) = *(buffers[i].geometry.bspcurve);
            dyn_info.start_curves[i].geometry.bspcurve->poles = p_point;
            memcpy (p_point, buffers[i].geometry.bspcurve->poles, buffers[i].geometry.bspcurve->num_poles * sizeof(IGRpoint));
            p_point += buffers[i].geometry.bspcurve->num_poles * 3;
        }
    }

    /*
     * Set up the end curves buffer.
     */
    dyn_info.end_curves = dyn_info.buffers;
    dyn_info.num_end_curves = num_curves;
    memcpy(dyn_info.end_curves, buffers, num_curves * sizeof(struct DPele_header));

    for (i=0, p_point = dyn_info.end_points; i<num_curves; ++i)
    {
        if (buffers[i].type == IGRPY)
        {
            dyn_info.end_curves[i].geometry.polyline = (struct IGRpolyline *)alloca(sizeof(struct IGRpolyline));
            dyn_info.end_curves[i].geometry.polyline->num_points = buffers[i].geometry.polyline->num_points;
            dyn_info.end_curves[i].geometry.polyline->points = p_point;
            p_point += buffers[i].geometry.polyline->num_points * 3;
        }
        else
        {
            dyn_info.end_curves[i].geometry.bspcurve = (struct IGRbsp_curve *)alloca(sizeof(struct IGRbsp_curve));
            *(dyn_info.end_curves[i].geometry.bspcurve) = *(buffers[i].geometry.bspcurve);
            dyn_info.end_curves[i].geometry.bspcurve->poles = p_point;
            p_point += buffers[i].geometry.bspcurve->num_poles * 3;
        }
    }

    /*
     * Set up the projection arc buffers.
     */
    dyn_info.num_arcs = 0;
    dyn_info.arcs = &dyn_info.end_curves[num_curves];
    dyn_info.arc_start_points = p_point = (IGRdouble *)alloca(size * sizeof(IGRpoint));
    dyn_info.arc_mid_points = (IGRdouble *)alloca(size * sizeof(IGRpoint));
    /*
     * Get the curve keypoints.
     */
    for (i=0; i<num_curves; ++i)
    {
        switch (buffers[i].type)
        {
        case IGRPY:
        {
            IGRlong                 num_points;
            IGRdouble             * points;
            struct IGRbsp_curve   * arc;

            num_points = buffers[i].geometry.polyline->num_points;

            if (num_points > 1)
            {
                points = buffers[i].geometry.polyline->points;

                for (j=0; j<num_points; ++j, points+=3)
                {
                    p_point[0] = points[0];
                    p_point[1] = points[1];
                    p_point[2] = points[2];
                    p_point += 3;

                    arc = (struct IGRbsp_curve *)alloca(sizeof(struct IGRbsp_curve));
                    arc->poles = (IGRdouble *)alloca(7 * sizeof(IGRpoint));
                    arc->weights = (IGRdouble *)alloca(7 * sizeof(IGRdouble));
                    arc->knots = (IGRdouble *)alloca(10 * sizeof(IGRdouble));

                    dp$build_dis_buffer ( buffer = &dyn_info.arcs[dyn_info.num_arcs],
                                          type = IGRBC,
                                          display_att = &arc_display,
                                          geometry = arc,
                                          ele_spec_att = &specific );
                    dyn_info.num_arcs++; /* Don't put this in dp$build_dis_buffer!!!! */
                }
            }
         }
            break;

        case IGRBC:
        {
            IGRint                  num_knots;
            IGRdouble             * knots, last_knot;
            struct IGRbsp_curve   * arc, * bspcurve;

            bspcurve = buffers[i].geometry.bspcurve;

            num_knots = bspcurve->num_knots;
            knots = bspcurve->knots;

            last_knot = -1;
    
            /* If it's a circular arc add a midpoint. */
            if (!bspcurve->phy_closed && (bspcurve->num_knots==6))
            {
                knots = (IGRdouble *)alloca(++num_knots * sizeof(IGRdouble));
                memcpy(knots, bspcurve->knots, num_knots * sizeof(IGRdouble));
                knots[bspcurve->num_knots] = 0.5;
            }

            for (j=0; j<num_knots; ++j)
            {
                if (knots[j] != last_knot)
                {
                    BScveval (bspcurve, knots[j], 0, (IGRpoint *)p_point, &bs_msg);

                    if (bs_msg == BSSUCC)
                    {
                        p_point += 3;

                        arc = (struct IGRbsp_curve *)alloca(sizeof(struct IGRbsp_curve));
                        arc->poles = (IGRdouble *)alloca(7 * sizeof(IGRpoint));
                        arc->weights = (IGRdouble *)alloca(7 * sizeof(IGRdouble));
                        arc->knots = (IGRdouble *)alloca(10 * sizeof(IGRdouble));
    
                        dp$build_dis_buffer ( buffer = &dyn_info.arcs[dyn_info.num_arcs],
                                              type = IGRBC,
                                              display_att = &arc_display,
                                              geometry = arc,
                                              ele_spec_att = &specific );
                        dyn_info.num_arcs++; /* Don't put this in dp$build_dis_buffer!!!! */
                    }
                    else *msg = MSFAIL;

                    last_knot = knots[j];
                }
            }
        }
            break;

        }
    }

    dyn_info.arc_end_points = (IGRdouble *)alloca(dyn_info.num_arcs * sizeof(IGRpoint));
    dyn_info.num_buffers = num_curves + dyn_info.num_arcs;

    /*
     * Allocate the interior turn curves.
     */
    p_curves[0] = dyn_info.turn_curves = &dyn_info.buffers[dyn_info.num_buffers];
    p_curves[1] = &dyn_info.turn_curves[num_curves];
    p_points[0] = dyn_info.turn_points = (IGRdouble *)alloca(2 * size * sizeof(IGRpoint));
    p_points[1] = &dyn_info.turn_points[size * 3];
    memcpy(p_curves[0], buffers, num_curves * sizeof(struct DPele_header));
    memcpy(p_curves[1], buffers, num_curves * sizeof(struct DPele_header));

    for (i=0; i<2; ++i)
    {
        for (j=0; j<num_curves; ++j)
        {
            if ((p_curves[i])[j].type == IGRPY)
            {
                (p_curves[i])[j].geometry.polyline = (struct IGRpolyline *)alloca(sizeof(struct IGRpolyline));
                (p_curves[i])[j].geometry.polyline->num_points = buffers[j].geometry.polyline->num_points;
                (p_curves[i])[j].geometry.polyline->points = p_points[i];
                p_points[i] += buffers[j].geometry.polyline->num_points * 3;
            }
            else
            {
                (p_curves[i])[j].geometry.bspcurve = (struct IGRbsp_curve *)alloca(sizeof(struct IGRbsp_curve));
                *((p_curves[i])[j].geometry.bspcurve) = *(buffers[j].geometry.bspcurve);
                (p_curves[i])[j].geometry.bspcurve->poles = p_points[i];
                p_points[i] += buffers[j].geometry.bspcurve->num_poles * 3;
            }
        }
    }

    /*
     * Display the centerline.
     */
    line.point1 = points;
    line.point2 = &points[3];

    polyline.num_points = 2;
    polyline.points = points;

    diag1[0] = diag1[1] = diag1[2] = GRDGNLIMITS_MIN_D;
    diag2[0] = diag2[1] = diag2[2] = GRDGNLIMITS_MAX_D;

    MAtlncbclip (msg, &dyn_info.centerline, diag1, diag2, &t1, &t2, (struct IGRline_seg *)&line);

    dp$build_dis_buffer( buffer = &centerline,
                         type = IGRPY,
                         display_att = &center_display,
                         geometry = &polyline );

    dp$display ( msg = msg, mode = GRbd, buffer = &centerline );

    /*
     * Invoke dynamics.
     */
    DPdynflags (msg, &inquire, &dyn_on, NULL);

    if (dyn_on) 
        dp$dynamics (dyn_fun = DYturn_dyn, information = &dyn_info);

    /*
     * Erase the centerline.
     */
    center_display.style = 0;
    dp$display ( msg = msg, mode = GRbe, buffer = &centerline );

    /*
     * Get the input.
     */
    size = 1024;
    *msg = ex$wait_for_input ( response = &response,  
                               buffer = response_data,
                               byte = &size );

    /*
     * If this is a data point, project it onto the plane and get the angle.
     */
    if ( (*msg & 1) && (response == EX_DATA) )
    {
        EFget_turn_angle ( msg, 
                           &((struct EX_button *)response_data)->x, 
                           &dyn_info.plane, 
                           dyn_info.start_vec, 
                           &angle);

        response = EX_STRING;
        sprintf(response_data,"%f radians",angle);
        size = strlen(response_data) + 1;
    }

    /*
     * Push the input back on the queue.
     */
    ex$putque ( msg = msg,
                response = &response,
                byte = (long *)&size,
                buffer = response_data );

quit:

    return (OM_S_SUCCESS);
}

IGRint DYturn_dyn( dyn_info, 
                   to_point,
                   mtx,
                   objects,
                   num_objects,
                   buffers,
                   num_buffers,
                   in_dummy1,
                   in_dummy2,
                   in_dummy3,
                   out_dummy1,
                   dyn_mod_info,
                   out_dummy3 )

    struct DYturn_info    *dyn_info;
    struct EX_button      *to_point;
    IGRdouble             *mtx;
    struct GRid          **objects;
    IGRint                *num_objects;
    struct DPele_header  **buffers;
    IGRint                *num_buffers;
    IGRchar               *in_dummy1;
    IGRchar               *in_dummy2;
    IGRchar               *in_dummy3;
    IGRchar              **out_dummy1;
    struct GRmdenv_info  **dyn_mod_info;
    IGRchar              **out_dummy3;
{
    IGRlong      msg, bs_msg, num_points;
    IGRint       i;
    IGRdouble  * normal, * origin, mid_angle;
    IGRdouble  * p_start_point, * p_end_point, * p_mid_point;
    IGRdouble    angle, angles[2];
    IGRint       num_angles, num_curves;
    IGRmatrix    matrix, matrices[2];
    IGRboolean   (*arc_func)(), is_360 = FALSE;

    *num_buffers = *num_objects = 0;
    
    origin = dyn_info->plane.point;
    normal = dyn_info->plane.normal;

    /*
     * Get the turn angle.
     */
    EFget_turn_angle (&msg, &to_point->x, &dyn_info->plane, dyn_info->start_vec, &angle );

    dyn_info->start_curves[0].dis_att->weight = 0;
    dyn_info->arcs[0].dis_att->weight = 0;
    arc_func = BSarc3pts;
    *num_buffers = dyn_info->num_buffers;
    num_angles = 0;
    num_curves = dyn_info->num_start_curves;
    num_points = dyn_info->num_start_points;
    mid_angle = angle/2;

    /*
     * If the angle is almost 360 degrees.
     */
    if ((angle < 0.09) || (angle > 6.20))
    {
        memcpy (dyn_info->end_points, 
                dyn_info->start_points,
                num_points * sizeof(IGRpoint));
        dyn_info->start_curves[0].dis_att->weight = 1;
        dyn_info->arcs[0].dis_att->weight = 1;
        arc_func = BScirc3pts;
        angle = 2 * PI;
        mid_angle = PI;
        MAgrotmx (&msg, normal, origin, &mid_angle, matrix);
        if (!(msg & 1)) goto quit;
        mid_angle /= 2;
        is_360 = TRUE;
    }

    /*
     * Display ghosts of the curve being rotated for visual effect.
     */
    if ((angle > 2.09440) && (angle <= 4.18879))
    {
        angles[0] = mid_angle;
        *num_buffers += num_curves;
        num_angles = 1;
    }
    else if (angle > 4.18879)
    {
        angles[0] = angle / 3;
        angles[1] = (angle * 2) / 3;
        *num_buffers += (2 * num_curves);
        num_angles = 2;
    }

    /*
     * Unweight the bspline curve's poles.
     */
    EFunweight_weight_buffers (dyn_info->start_curves, num_curves, FALSE);

    if (!is_360)
    {
        /*
         * Get the rotation matrix.
         */
        MAgrotmx (&msg, normal, origin, &angle, matrix);

        if (!(msg & 1)) goto quit;

        /*
         * Rotate the curves.
         */
        MAptsxform ( &msg,
                     &num_points, 
                     matrix, 
                     dyn_info->start_points, 
                     dyn_info->end_points );

        if (!(msg & 1)) goto quit;

        EFunweight_weight_buffers (dyn_info->end_curves, num_curves, TRUE);
    }

    for (i=0; i<num_angles; ++i)
    {
        MAgrotmx (&msg, normal, origin, &angles[i], matrices[i]);

        if (!(msg & 1)) goto quit;

        MAptsxform ( &msg,
                     &num_points, 
                     matrices[i],
                     dyn_info->start_points, 
                     &dyn_info->turn_points[i * num_points * 3]);

        if (!(msg & 1)) goto quit;

        EFunweight_weight_buffers (&dyn_info->turn_curves[i * num_curves], num_curves, TRUE);
    }

    /*
     * Reweight the start curves buffer.
     */
    EFunweight_weight_buffers (dyn_info->start_curves, num_curves, TRUE);
    
    /*
     * Define the projections arcs.
     */
    p_start_point = dyn_info->arc_start_points;
    p_mid_point   = dyn_info->arc_mid_points;
    p_end_point   = dyn_info->arc_end_points;

    MAptsxform (&msg, (IGRlong *) &dyn_info->num_arcs, matrix, p_start_point, p_end_point);

    MAgrotmx (&msg, normal, origin, &mid_angle, matrix);
    if (!(msg & 1)) goto quit;

    MAptsxform (&msg, (IGRlong *) &dyn_info->num_arcs, matrix, p_start_point, p_mid_point);

    for (i=0; i<dyn_info->num_arcs; ++i)
    {
        msg = (*arc_func)( &bs_msg,
                           p_start_point, 
                           p_mid_point, 
                           p_end_point,
                           dyn_info->arcs[i].geometry.bspcurve );

        p_start_point += 3;
        p_mid_point   += 3;
        p_end_point   += 3;
    }

    /*
     * Set up the display buffers.
     */
    *buffers = dyn_info->buffers;

quit:

    return (msg);
}

end implementation ECprims;
