class implementation ECprims;

/*
  HISTORY

	Sudha	07/05/93	Modified for BSprototype ansification

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
#include "bserr.h"
#include "primco.h"
#include "exdef.h"
#include "exmacros.h"
#include "maptlnpro.h"
#include "bscveval.h"


from GRvg import GRdetplane;

struct DYextrude_info
{
    IGRint                  mode;
    struct IGRline          line;
    IGRdouble               point1[3];
    IGRdouble               point2[3]; 
    IGRint                  num_lines;
    struct DPele_header   * lines;
    IGRint                  num_curves;
    struct DPele_header   * curves;
    IGRint                  num_buffers;
    struct DPele_header   * buffers;
    IGRdouble               last_delta[3];
};

IGRint DYextrude ( msg, 
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
    IGRint                  i, j;
    IGRboolean              dyn_on;         
    IGRboolean              inquire = 1;    
    IGRlong                 size;
    struct DYextrude_info   dyn_info;         
    IGRint                  DYextrude_dyn();
    IGRint                  num_lines, old_num_lines;
    struct DPele_header   * lines;
    struct IGRdisplay       center_disp, curve_disp;
    IGRdouble             * point;
    struct IGRplane         plane;
    IGRdouble               plane_point[3];
    IGRdouble               plane_normal[3];
    IGRdouble             * from_point;
    struct GRmd_env       * mod_env;
    IGRchar                 response_data[1024];
    IGRint                  response;
    IGRdouble             * points;

    *msg = MSSUCC;

    from_point = &events[1].event.button.x;
    mod_env = &events[0].located_object[0].module_info;

    dyn_info.mode = *info;

    center_disp.color = 2;
    center_disp.weight = 0;
    center_disp.style = 7;

    curve_disp.color = 2;
    curve_disp.weight = 0;
    curve_disp.style = 0;

    for (i=0, size = 0; i<num_curves; ++i)
    {
        if (buffers[i].type == IGRPY)
            size += buffers[i].geometry.polyline->num_points;
        else 
            size += buffers[i].geometry.bspcurve->num_knots;
    }

    lines = (struct DPele_header *)alloca(size * sizeof(struct DPele_header));

    /*
     * Get the curve keypoints.
     */
    for (i=0, num_lines=0 ; i<num_curves; ++i)
    {
        switch (buffers[i].type)
        {
        case IGRPY:
        {
            IGRint                  num_points;
            struct IGRpolyline    * polyline;

            num_points = buffers[i].geometry.polyline->num_points;

            if (num_points > 1)
            {
                points = buffers[i].geometry.polyline->points;

                for (j=0; j<num_points; ++j, points+=3)
                {
                    polyline = (struct IGRpolyline *)alloca(sizeof(struct IGRpolyline));
                    polyline->num_points = 2;
                    polyline->points = (IGRdouble *)alloca(6 * sizeof(IGRdouble));
                    polyline->points[0] = polyline->points[3] = points[0];
                    polyline->points[1] = polyline->points[4] = points[1];
                    polyline->points[2] = polyline->points[5] = points[2];
                    dp$build_dis_buffer ( buffer = &lines[num_lines],
                                          type = IGRPY,
                                          display_att = (num_points == 1) ? 
                                          &center_disp : &curve_disp,
                                          geometry = polyline );
                    num_lines++; /* Don't put this in dp$build_dis_buffer!!!! */
                }
            }
         }
            break;

        case IGRBC:
        {
            IGRint                  num_knots;
            IGRdouble             * knots, last_knot;
            struct IGRpolyline    * polyline;
            struct IGRbsp_curve   * bspcurve;

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
                    polyline = (struct IGRpolyline *)alloca(sizeof(struct IGRpolyline));
                    polyline->num_points = 2;
                    polyline->points = (IGRdouble *)alloca(6 * sizeof(IGRdouble));

                    BScveval (bspcurve, knots[j], 0, (IGRpoint *)polyline->points, msg);

                    if (*msg == BSSUCC)
                    {
                        polyline->points[3] = polyline->points[0];
                        polyline->points[4] = polyline->points[1];
                        polyline->points[5] = polyline->points[2];

                        dp$build_dis_buffer ( buffer = &lines[num_lines],
                                              type = IGRPY,
                                              display_att = &curve_disp,
                                              geometry = polyline );
                        num_lines++; /* Don't put this in dp$build_dis_buffer!!!! */
                    }

                    last_knot = knots[j];
                }
            }
        }
            break;

        }
    }

    /*
     * Allocate the display buffers;
     */
    dyn_info.buffers = dyn_info.curves = (struct DPele_header *)alloca((num_lines + num_curves) * sizeof(struct DPele_header));

    /*
     * Add the curve display buffers.
     */
    memcpy ( dyn_info.curves,
             buffers,
             num_curves * sizeof(struct DPele_header));

    /*
     * Add the projection line display buffers getting rid of duplicates.
     */
    old_num_lines = num_lines;
    dyn_info.lines = &dyn_info.curves[num_curves];
    for (i=0,num_lines=0; i<old_num_lines; ++i)
    {
        point = lines[i].geometry.polyline->points;

        for (j=0; j<num_lines; ++j)
            if (i != j)
                if (!memcmp ( point,
                              dyn_info.lines[j].geometry.polyline->points,
                              sizeof(IGRpoint))) break;

        if (j == num_lines)
            dyn_info.lines[num_lines++] = lines[i];
    }

    /*
     * Set up the display buffers.
     */
    dyn_info.num_curves = num_curves;
    dyn_info.num_lines = num_lines;
    dyn_info.num_buffers = num_curves + num_lines;

    /*
     * Initialize the last delta.
     */
    dyn_info.last_delta[0] = 0.0;
    dyn_info.last_delta[1] = 0.0;
    dyn_info.last_delta[2] = 0.0;

    /* 
     * Set up the projection line.
     */
    plane.point = plane_point;
    plane.normal = plane_normal;

    EFdetermine_plane ( msg,
                        mod_env,
                        &events[0].located_object[0].located_obj, 
                        &plane );

    if (!(*msg & 1))
    {
        dyn_info.mode = EC_EXTRUDE_NON_ORTHO;
        *msg = MSSUCC;
    }

    for (i=0; i<3; ++i)
    {
        dyn_info.point1[i] = from_point[i];
        dyn_info.point2[i] = from_point[i] + plane_normal[i];
    }

    dyn_info.line.point1 = dyn_info.point1;
    dyn_info.line.point2 = dyn_info.point2;

    /*
     * Invoke dynamics.
     */
    /* 
     * Exit if dynamics is off. 
     */
    DPdynflags (msg, &inquire, &dyn_on, NULL);

    if (dyn_on)
        dp$dynamics (dyn_fun = DYextrude_dyn, information = &dyn_info);


    /*
     * Get the input.
     */
    size = 1024;
    *msg = ex$wait_for_input ( response = &response,  
                               buffer = response_data,
                               byte = (int *)&size );

    /*
     * If this is a data point, project it onto the normal line
     * if that mode is set.
     */
    if ( (*msg & 1) && (response == EX_DATA) && (dyn_info.mode == EC_EXTRUDE_ORTHO))
    {
        IGRdouble          loc_point[3], loc_parm;
        struct EX_button * loc_button;

        loc_button = (struct EX_button *)response_data;
        MAptlnproj (msg, &loc_button->x, &dyn_info.line, loc_point, &loc_parm);
        memcpy (&loc_button->x, loc_point, sizeof(IGRpoint));
    }

    /*
     * Push the input back on the queue.
     */
    ex$putque ( msg = msg,
                response = &response,
                byte = &size,
                buffer = response_data );

    return (OM_S_SUCCESS);
}

IGRint DYextrude_dyn( dyn_info, 
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

    struct DYextrude_info *dyn_info;
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
    IGRlong    msg = MSSUCC;
    IGRint     i, j;
    IGRdouble  delta[3], old_last_delta[3], point[3], parm;
    IGRdouble  * last_delta;
    IGRint                num_points;
    IGRdouble           * points;

    if (dyn_info->mode == EC_EXTRUDE_ORTHO)
    {
        /* 
         * Project to_point onto the line.
         */
        MAptlnproj ( &msg, &to_point->x, &dyn_info->line, point, &parm );
    }
    else memcpy (point, &to_point->x, sizeof(IGRpoint));

    /*
     * Get the delta vector for the points, and save the delta between
     * from and to points.
     */
    last_delta = dyn_info->last_delta;

    old_last_delta[0] = last_delta[0];
    old_last_delta[1] = last_delta[1];
    old_last_delta[2] = last_delta[2];

    delta[0] = (last_delta[0] = point[0] - dyn_info->point1[0]) - old_last_delta[0];
    delta[1] = (last_delta[1] = point[1] - dyn_info->point1[1]) - old_last_delta[1];
    delta[2] = (last_delta[2] = point[2] - dyn_info->point1[2]) - old_last_delta[2];

    /*
     * Unweight the curve buffers.
     */
    EFunweight_weight_buffers (dyn_info->curves, dyn_info->num_curves, FALSE);

    /*
     * Translate the curves.
     */
    for (i=0; i<dyn_info->num_curves; ++i)
    {
        if (dyn_info->curves[i].type == IGRPY)
        {
            num_points = dyn_info->curves[i].geometry.polyline->num_points;
            points = dyn_info->curves[i].geometry.polyline->points;
        }
        else
        {
            num_points = dyn_info->curves[i].geometry.bspcurve->num_poles;
            points = dyn_info->curves[i].geometry.bspcurve->poles;
        }

        for (j=0; j<num_points; ++j, points+=3)
        {
            points[0] += delta[0];
            points[1] += delta[1];
            points[2] += delta[2];
        }
    }

    /*
     * Reweight the curve buffers.
     */
    EFunweight_weight_buffers (dyn_info->curves, dyn_info->num_curves, TRUE);

    /*
     * Define the projection lines.
     */
    for (i=0; i<dyn_info->num_lines; ++i)
    {
        points = &dyn_info->lines[i].geometry.polyline->points[3];

        points[0] += delta[0];
        points[1] += delta[1];
        points[2] += delta[2];
    }

    /*
     * Set up the display buffers.
     */
    *num_buffers = dyn_info->num_buffers;
    *buffers = dyn_info->buffers;
    
    return (msg);
}

end implementation ECprims;

