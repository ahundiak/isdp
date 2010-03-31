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
#include "matlncbcl.h"
#include "maptlnpro.h"
#include "ma2ptdis.h"


struct DYcenterline_info
{
    struct DPele_header   * display_buffers;
    struct IGRpolyline      polyline;
    struct IGRline          line;
    IGRdouble               points[6];
    IGRdouble               diag1[3], diag2[3];
    IGRdouble             * from_point;
    IGRint                  num_buffers;
    struct DPele_header   * buffers;
    struct IGRpolyline    * polylines;
    IGRdouble             * vectors;
};

IGRint DYcenterline ( msg, 
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
    IGRint                   i, j, k;
    IGRboolean               dyn_on;         
    IGRboolean               inquire = 1;    
    IGRlong                  size;
    struct DYcenterline_info dyn_info;         
    IGRint                   DYcenterline_dyn();
    struct IGRdisplay        display, ele_display, end_display;
    IGRdouble              * from_point;
    IGRchar                 response_data[1024];
    IGRint                  response;

    *msg = MSSUCC;

    from_point = &events[1].event.button.x;

    display.color  = 5;
    display.weight = 0;
    display.style  = 7;

    ele_display.color  = 5;
    ele_display.weight = 1;
    ele_display.style  = 0;

    end_display.color  = 5;
    end_display.weight = 1;
    end_display.style  = 1;

    for (i=0, size = 0; i<num_curves; ++i)
    {
        if (buffers[i].type == IGRPY)
            size += buffers[i].geometry.polyline->num_points;
        else 
            ++size; /* End Points */
    }

    dyn_info.vectors = (IGRdouble *)alloca(size * sizeof(IGRvector));
    dyn_info.buffers = (struct DPele_header *)alloca(size * sizeof(struct DPele_header));
    dyn_info.polylines = (struct IGRpolyline *)alloca(size * sizeof(struct IGRpolyline));

    dyn_info.num_buffers = 0;

    for (i=0; i<num_curves; ++i)
    {
        if (buffers[i].type == IGRPY)
        {
            IGRdouble * pts1, * pts2, * vec;
            IGRint      num_points, num;

            num_points = buffers[i].geometry.polyline->num_points;
            pts1 = buffers[i].geometry.polyline->points;

            for (j=0; j<num_points-1; ++j, pts1+=3)
            {
                num = dyn_info.num_buffers;
                dyn_info.polylines[num].num_points = 2;
                dyn_info.polylines[num].points = pts2 = (IGRdouble *)alloca(6 * sizeof(IGRdouble));
                for (k=0; k<6; ++k) pts2[k] = pts1[k];
                vec = &dyn_info.vectors[num * 3];
                for (k=0; k<3; ++k) vec[k] = pts2[k+3] - pts2[k];
                dp$build_dis_buffer( buffer = &dyn_info.buffers[num],
                                     type = IGRPY,
                                     display_att = &ele_display, 
                                     geometry = &dyn_info.polylines[dyn_info.num_buffers++] );
            }            
        }
        else if ((!buffers[i].geometry.bspcurve->phy_closed) &&
                 (buffers[i].geometry.bspcurve->order == 4))
        {
            struct IGRbsp_curve * bspcurve;
            IGRint      num_poles, num;
            IGRdouble * pts, * pole, * vec;
            
            num = dyn_info.num_buffers;
            bspcurve = buffers[i].geometry.bspcurve;
            num_poles = bspcurve->num_poles;

            dyn_info.polylines[num].num_points = 2;
            dyn_info.polylines[num].points = pts = (IGRdouble *)alloca(6 * sizeof(IGRdouble));

            pole = bspcurve->poles;

            pts[0] = pole[0];
            pts[1] = pole[1];
            pts[2] = pole[2];

            pole = &bspcurve->poles[(num_poles * 3) - 3];

            pts[3] = pole[0];
            pts[4] = pole[1];
            pts[5] = pole[2];

            vec = &dyn_info.vectors[num * 3];
            for (k=0; k<3; ++k) vec[k] = pts[k+3] - pts[k];

            dp$build_dis_buffer( buffer = &dyn_info.buffers[num],
                                 type = IGRPY,
                                 display_att = &end_display, 
                                 geometry = &dyn_info.polylines[dyn_info.num_buffers++] );
        }
    }
    
    dyn_info.display_buffers = (struct DPele_header *)alloca((dyn_info.num_buffers + 1)* sizeof(struct DPele_header));

    dyn_info.diag1[0] = dyn_info.diag1[1] = dyn_info.diag1[2] = GRDGNLIMITS_MIN_D;
    dyn_info.diag2[0] = dyn_info.diag2[1] = dyn_info.diag2[2] = GRDGNLIMITS_MAX_D;
    dyn_info.polyline.num_points = 2;
    dyn_info.polyline.points = dyn_info.line.point1 = dyn_info.points;
    dyn_info.line.point2 = &dyn_info.points[3];
    dyn_info.from_point = from_point;

    dp$build_dis_buffer( buffer = &dyn_info.display_buffers[0],
                         type = IGRPY,
                         display_att = &display, 
                         geometry = &dyn_info.polyline );

    DPdynflags (msg, &inquire, &dyn_on, NULL);

    if (dyn_on) 
        dp$dynamics (dyn_fun = DYcenterline_dyn, information = &dyn_info);

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
    if ( (*msg & 1) && (response == EX_DATA) )
    {
        IGRint             which_error;
        struct EX_button * button;
        struct var_list    list[2];
        IGRmatrix          mtx;

        button = (struct EX_button *)response_data;

        list[0].var = VIEW_ROTATION;
        list[0].var_ptr = (IGRchar *)mtx;
        list[0].num_bytes = sizeof(IGRmatrix);
        list[0].bytes_returned = &size;
        list[1].var = END_PARAM;

        dp$inq_set_gragad ( msg = msg,
                            osnum = button->osnum,
                            gragad_objid = button->objid,
                            which_error = &which_error,
                            var_list = list);

        DY_get_centerline ( msg,
                            response_data,
                            &dyn_info, 
                            mtx, 
                            NULL,
                            NULL );
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

#define SQTOL   0.05

IGRint DYcenterline_dyn( dyn_info, 
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

    struct DYcenterline_info *dyn_info;
    struct EX_button         *to_point;
    IGRdouble                *mtx;
    struct GRid             **objects;
    IGRint                   *num_objects;
    struct DPele_header     **buffers;
    IGRint                   *num_buffers;
    IGRchar                  *in_dummy1;
    IGRchar                  *in_dummy2;
    IGRchar                  *in_dummy3;
    IGRchar                 **out_dummy1;
    struct GRmdenv_info     **dyn_mod_info;
    IGRchar                 **out_dummy3;
{
    IGRlong        msg = MSSUCC;

    DY_get_centerline ( &msg,
                        to_point,
                        dyn_info, 
                        mtx, 
                        num_buffers,
                        buffers );
    return (msg);
}

IGRint DY_get_centerline ( msg, 
                           to_point, 
                           dyn_info, 
                           mtx, 
                           num_buffers, 
                           buffers )
    IGRlong                  * msg;
    struct EX_button         * to_point;
    struct DYcenterline_info * dyn_info;
    IGRdouble                * mtx;
    IGRint                   * num_buffers;
    struct DPele_header     ** buffers;
{
    struct IGRline        snap_line, centerline;
    IGRint                i;
    IGRdouble             t1, t2;
    IGRdouble           * p1, * p2, * vec;
    IGRdouble             point[3], proj[3], dist;
    IGRint                is_snapped = 0;

    centerline.point1 = p1 = dyn_info->from_point;
    centerline.point2 = p2 = &to_point->x;

    snap_line.point1 = dyn_info->from_point;
    snap_line.point2 = point;

    if (buffers)
    {
        *num_buffers = 1;
        *buffers = dyn_info->display_buffers;
    }
    
    for (i=0; i<dyn_info->num_buffers; ++i)
    {
        vec = &dyn_info->vectors[i * 3];

        point[0] = p1[0] + vec[0];
        point[1] = p1[1] + vec[1];
        point[2] = p1[2] + vec[2];

        MAptlnproj (msg, p2, &snap_line, proj, &t1);

        if (*msg & 1)
        {
            MA2ptdis (msg, p2, proj, &dist);

            if (*msg & 1)
            {
                dist *= dist;

                if (dist < SQTOL)
                {
                    if (!is_snapped)
                    {
                        p2[0] = point[0];
                        p2[1] = point[1];
                        p2[2] = point[2];
                        is_snapped = 1;
                    }

                    if (buffers)
                    {
                        (*buffers)[(*num_buffers)++] = dyn_info->buffers[i];
                    }
                }
            }
        }
    }

    /*
     * If the centerline wouldn't snap to the curve elements, try snapping
     * to the view x-y axis.
     */
    if (!is_snapped)
    {
        for (i=0; i<=4; i+=4)
        {
            point[0] = p1[0] + mtx[i];
            point[1] = p1[1] + mtx[i+1];
            point[2] = p1[2] + mtx[i+2];

            MAptlnproj (msg, p2, &snap_line, proj, &t1);

            if (*msg & 1)
            {
                MA2ptdis (msg, p2, proj, &dist);

                if (*msg & 1)
                {
                    dist *= dist;
    
                    if (dist < SQTOL)
                    {
                        p2[0] = point[0];
                        p2[1] = point[1];
                        p2[2] = point[2];
                        is_snapped = 1;
                        break;
                    }
                }
            }
        }
    }

    if (buffers)
    {
        dyn_info->display_buffers[0].dis_att->weight = is_snapped;

        MAtlncbclip ( msg, 
                      &centerline, 
                      dyn_info->diag1, dyn_info->diag2, 
                      &t1, &t2, 
                      (struct IGRline_seg *) &dyn_info->line );
    }

    return (1);
}

end implementation ECprims;

