
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:42 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsmath.h"
#include "hsdisplay.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSe2_mesher.h"

#include "HSpr_tiler_f.h"

/*------------------------------
 *  for function
 *    make_trapezoid
 */

#include "HSpr_pbust_f.h"

/*-------------------------------*/

/*
 *  Prototype declaration for static functions
 */


static void subtract_off_z_min (struct HSvertex * vertex_list);
static void send_loop_to_polybuster (struct HSvertex * vertex_list);


#ifdef  TRUE
#undef  TRUE
#endif
#ifdef  FALSE
#undef  FALSE
#endif
#define	FALSE		0
#define	TRUE		~0

#define ZERO_TOL	0.00005

#define	DEBUG_LOOP	0

#define	ZSCALE	(tiling_parms.maximum_z /( active_window->z_max - active_window->z_min))

#define	USE_NEG_OF_DOT_PRODUCT	1
#define	USE_DOT_PRODUCT		2

struct HSvertex *hs_clip_3d ();

/*--- find_smooth_shades ----------------------------------------------------*/

void find_smooth_shades (struct HSvertex * vertex_list,
                              IGRshort code,
                              double x_scale,
                              double y_scale,
                              double z_scale)

/*
 * Converts a loop with normals to a loop with shades, where the
 * shade ranges from 0 to 255 and replaces the X coordinate of the normal.
 *
 * HISTORY: 09/01/86 created				S. A. Rapa
 *	    12/29/86 Multiple light sources		S. A. Rapa
 *	    07/20/89 Added point light source handling	Trevor Mink
 *	    08/03/89 Removed automatic 0,0,-1 view light source
 *								Trevor Mink
 */

    {
    IGRdouble dot_product = 0.0, shade;
    struct HSvertex *stop_vertex;
    IGRint light_num;
    struct HS_light_source *Light;
    double VectorLength, DistanceSquared, Intensity, dx, dy, dz;
    double dx_scaled, dy_scaled, dz_scaled;

    /* Loop through all vertices and put shade in normal X coordinate. */

    stop_vertex = vertex_list;
    do
        {
        /* Flip normals to point towards eye; convert dot product to shade.
         * 
         * 'code' means the following: altered light sources are used AND normal
         * is pointing away from the viewer, so negate the eye/normal dot
         * product before computing the shade; - OR - altered light sources
         * are used AND normal is pointing toward the viewer, so leave the
         * eye/normal dot product alone when computing the shade; - OR -
         * Single default light source is used. Just take absolute value of
         * dot product & ignore the normal's direction. */

        shade = 0.0;

        for (light_num = 0; light_num < active_window->num_lights; light_num++)
            {

            Light = &active_window->light_sources[light_num];

            /* Get average of RGB values and put in 'Intensity' */
            Intensity = (Light->red + Light->green + Light->blue) / 3.0;

            switch (Light->flags & HS_LIGHT_TYPE)
                {
                case (HS_LIGHT_POINT):
                case (HS_LIGHT_SPOT):
                    dx = (vertex_list->coord[0] - Light->location[0]);
                    dy = (vertex_list->coord[1] - Light->location[1]);
                    dz = (vertex_list->coord[2] - Light->location[2]);

                    if (active_window->perspective)
                        {
                        /* prepare to calculate distance-squared */
                        /* scaled to world coordinates		 */
                        dx_scaled = dx / x_scale;
                        dy_scaled = dy / y_scale;
                        dz_scaled = dz / z_scale;

                        DistanceSquared = (dx_scaled * dx_scaled +
                                           dy_scaled * dy_scaled +
                                           dz_scaled * dz_scaled);

                        dx = dx * x_scale;
                        dy = dy * y_scale;
                        dz = dz * z_scale;

                        VectorLength = SQRT ((dx * dx + dy * dy + dz * dz));
                        }
                    else
                        {
                        DistanceSquared = (dx * dx + dy * dy + dz * dz);
                        VectorLength = SQRT (DistanceSquared);
                        }

                    /* Normalize the Light Source -> Surface vector */
                    dx /= VectorLength;
                    dy /= VectorLength;
                    dz /= VectorLength;

                    dot_product =
                        vertex_list->norm[0] * dx +
                        vertex_list->norm[1] * dy +
                        vertex_list->norm[2] * dz;

                    /* I = I x R x R / (D x D) */
                    /* Actually this is distance-squared and radius-squared */
                    if (DistanceSquared > Light->radius)
                        Intensity = Intensity   /* of light */
                            * Light->radius / DistanceSquared;
                    break;

                case (HS_LIGHT_PARALLEL):
                case (HS_LIGHT_PENCIL):
                    dot_product =
                        (vertex_list->norm[0] * Light->direction[0]) +
                        (vertex_list->norm[1] * Light->direction[1]) +
                        (vertex_list->norm[2] * Light->direction[2]);
                    break;
                    }

            if (code == USE_NEG_OF_DOT_PRODUCT)
                dot_product = -dot_product;

            if (dot_product > 0.0)
                shade += dot_product * Intensity;
            }   /* for */
            
        shade += (IGRdouble)tiling_parms.ambient[3];

        if (shade > 255.0)
            vertex_list->norm[0] = 255.0;
        else
            vertex_list->norm[0] = shade;

        vertex_list = vertex_list->next;
        }
    while (stop_vertex != vertex_list);
    }   /* find_smooth_shades() */


/*--- find_const_shades ----------------------------------------------------*/

void find_const_shades (struct HSvertex * vertex_list,
                             IGRshort code,
                             double x_scale,
                             double y_scale,
                             double z_scale)

/*
 * Converts a loop with normals to a loop with shades, where the
 * shade ranges from 0 to 255 and replaces the X coordinate of the normal.
 *
 * HISTORY: 12/17/86 created				S. A. Rapa
 *	    12/29/86 Multiple light sources		S. A. Rapa
 *	    08/03/89 Removed automatic 0,0,-1 view light source
 *								Trevor Mink
 */

    {
    IGRdouble dot_product = 0, shade;
    struct HSvertex *stop_vertex;
    IGRint light_num;
    struct HS_light_source *Light;

    int i = 0;
    double X = 0.0, Y = 0.0, Z = 0.0, Intensity, DistanceSquared;
    double VectorLength, dx_scaled, dy_scaled, dz_scaled;

    /* 'code' means the following: altered light sources are used, so leave
     * the eye/normal dot product alone when computing the shade; - OR -
     * negate the dot product when calculating the shade.
     * 
     */

    /* Loop through all vertices and find an average x,y,z value to use as
     * the center of the facet. */

    stop_vertex = vertex_list;
    do
        {
        X += vertex_list->coord[0];
        Y += vertex_list->coord[1];
        Z += vertex_list->coord[2];
        i++;
        vertex_list = vertex_list->next;
        }
    while (stop_vertex != vertex_list);

    X = X / (double) i;
    Y = Y / (double) i;
    Z = Z / (double) i;

    shade = 0.0;

    for (light_num = 0; light_num < active_window->num_lights; light_num++)
        {

        Light = &active_window->light_sources[light_num];

        /* Get average of RGB values and put in 'Intensity' */
        Intensity = (Light->red + Light->green + Light->blue) / 3.0;

        switch (Light->flags & HS_LIGHT_TYPE)
            {

            case (HS_LIGHT_POINT):
            case (HS_LIGHT_SPOT):

                /* Take a vector from a point on surface to the light source */
                X -= Light->location[0];
                Y -= Light->location[1];
                Z -= Light->location[2];

                if (active_window->perspective)
                    {
                    /* prepare to calculate distance-squared */
                    /* scaled to world coordinates		 */
                    dx_scaled = X / x_scale;
                    dy_scaled = Y / y_scale;
                    dz_scaled = Z / z_scale;

                    DistanceSquared = (dx_scaled * dx_scaled +
                                       dy_scaled * dy_scaled +
                                       dz_scaled * dz_scaled);

                    /* Scale the Surface -> Light Source vector */
                    X *= x_scale;
                    Y *= y_scale;
                    Z *= z_scale;

                    VectorLength = SQRT ((X * X + Y * Y + Z * Z));
                    }
                else
                    {
                    DistanceSquared = (X * X + Y * Y + Z * Z);
                    VectorLength = SQRT (DistanceSquared);
                    }

                /* Normalize the Surface -> Light Source vector */
                X /= VectorLength;
                Y /= VectorLength;
                Z /= VectorLength;

                dot_product =
                    (element_parms.facet_normal[0] * X) +
                    (element_parms.facet_normal[1] * Y) +
                    (element_parms.facet_normal[2] * Z);

                /* I = I x R x R / (D x D) */

                /* Actually this is distance-squared and radius-squared */
                if (DistanceSquared > Light->radius)
                    Intensity = Intensity       /* of light */
                        * Light->radius / DistanceSquared;
                break;

            case (HS_LIGHT_PARALLEL):
            case (HS_LIGHT_PENCIL):

                /* Handle the parallel light */
                dot_product = (element_parms.facet_normal[0] * Light->direction[0]) +
                    (element_parms.facet_normal[1] * Light->direction[1]) +
                    (element_parms.facet_normal[2] * Light->direction[2]);
                break;
                }

        if (dot_product < 0.0)
            shade += (-dot_product * Intensity);

        }       /* for */

    shade += (IGRdouble)tiling_parms.ambient[3];

    if (shade > 255.0)
        shade = 255.0;

    /* Loop through all vertices and put shade in normal X coordinate. */

    stop_vertex = vertex_list;
    do
        {
        vertex_list->norm[0] = shade;
        vertex_list = vertex_list->next;
        }
    while (stop_vertex != vertex_list);

    }   /* find_const_shades() */

/*--- do_smooth_depth_cueing ----------------------------------------------*/

/*
 * Applies depth cueing to shades for a smooth-shaded facet ... all
 * vertices will not necessarily have the same shade.
 *
 * HISTORY: 11/04/86 created			S. A. Rapa
 */

void do_smooth_depth_cueing (struct HSvertex * vertex_list,
                                  IGRint interp_coord)

    {
    struct
    HSvertex *stop_vertex;
    register
    IGRdouble base, delta;

    base = active_window->depth_cue_base;
    delta = active_window->depth_cue_delta;

    stop_vertex = vertex_list;
    do
        {
        vertex_list->norm[0] *= ((vertex_list->coord[interp_coord] * delta) + base);
        vertex_list = vertex_list->next;
        }

    while (stop_vertex != vertex_list);
    }


/*--- do_const_depth_cueing -------------------------------------------------*/

/*
 * Applies depth cueing to shades for a constant-shaded facet (i.e.
 * all vertices get the same shade).  Shade is determined for
 * z = ((max z) + (min z)) / 2.
 *
 * HISTORY: 11/04/86 created			S. A. Rapa
 */

void do_const_depth_cueing (struct HSvertex * vertex_list,
                                 IGRint interp_coord)

    {
    struct
    HSvertex *stop_vertex;
    register
    IGRdouble base, delta;
    IGRdouble low_z, high_z, this_z, shade;

    base = active_window->depth_cue_base;
    delta = active_window->depth_cue_delta;

    /* Get Z of facet's center. */

    low_z = vertex_list->coord[interp_coord];
    high_z = low_z;
    stop_vertex = vertex_list;
    vertex_list = vertex_list->next;
    do
        {
        this_z = vertex_list->coord[interp_coord];
        if (this_z < low_z)
            low_z = this_z;
        if (this_z > high_z)
            high_z = this_z;
        vertex_list = vertex_list->next;
        }

    while (stop_vertex != vertex_list);

    /* Assign all vertices the same shade */

    shade = ((((high_z + low_z) / 2.0) * delta) + base) * vertex_list->norm[0];

    do
        {
        vertex_list->norm[0] = shade;
        vertex_list = vertex_list->next;
        }

    while (stop_vertex != vertex_list);
    }


/*-- subtract_off_z_min -----------------------------------------------------*/

static void subtract_off_z_min (struct HSvertex * vertex_list)

    {
    struct
    HSvertex *stop_vertex;
    IGRdouble z_min;

    z_min = active_window->z_min;

    stop_vertex = vertex_list;
    do
        {
        vertex_list->coord[2] -= z_min;
        vertex_list = vertex_list->next;
        }

    while (vertex_list != stop_vertex);
    }


/*-- send_loop_to_polybuster  -----------------------------------------------*/

static void send_loop_to_polybuster (struct HSvertex * vertex_list)

    {
    struct HSvertex *this_point;
    struct HSvertex *last_point;
    struct HSvertex *stop_point;
    IGRdouble z_scale;

    z_scale = ZSCALE;

    /* It is critical to the polybusting routine that polygons do not cross
     * themselves in the xy plane; to be safe, force adjacent points which
     * are 'close' to be exactly equal in x and y.  This prevents floating
     * exceptions in the polybuster caused when trying to divide by a very
     * small delta Y during interpolation. */

    stop_point = vertex_list;

    do
        {
        last_point = vertex_list;
        vertex_list = vertex_list->next;

        if (FABS (vertex_list->coord[0] - last_point->coord[0]) < ZERO_TOL)
            vertex_list->coord[0] = last_point->coord[0];

        if (FABS (vertex_list->coord[1] - last_point->coord[1]) < ZERO_TOL)
            vertex_list->coord[1] = last_point->coord[1];

        /* Must do z's too (for perspective cases) */

        if (FABS (vertex_list->coord[2] - last_point->coord[2]) < ZERO_TOL)
            vertex_list->coord[2] = last_point->coord[2];
        }

    while (vertex_list != stop_point);

    /* Re-check first and second point; if the first, second, and last points
     * have nearly identical coordinates, move the first point away (since it
     * is difficult to force them to all be the same, which would be the
     * ideal solution). Note that by moving the coordinate I may accidentally
     * force the loop to cross itself ... hopefully this situation will never
     * occur. */

    this_point = vertex_list->next;
    if ((FABS (vertex_list->coord[0] - this_point->coord[0]) < ZERO_TOL) &&
        (vertex_list->coord[0] != this_point->coord[0]))
        vertex_list->coord[0] += 0.0001;

    if ((FABS (vertex_list->coord[1] - this_point->coord[1]) < ZERO_TOL) &&
        (vertex_list->coord[1] != this_point->coord[1]))
        vertex_list->coord[1] += 0.0001;

    /* Must do z's too (for perspective cases) */

    if ((FABS (vertex_list->coord[2] - this_point->coord[2]) < ZERO_TOL) &&
        (vertex_list->coord[2] != this_point->coord[2]))
        vertex_list->coord[2] += 0.0001;

    if (element_parms.facet_type != RENDERED)
        {
        /* only scale z's if not rendering */
        vertex_list->coord[2] *= z_scale;
        }
    else if (!element_parms.front_facing_facet)
        {
        /* flip the normal to point toward the eye for rendering */
        vertex_list->norm[0] = -vertex_list->norm[0];
        vertex_list->norm[1] = -vertex_list->norm[1];
        vertex_list->norm[2] = -vertex_list->norm[2];
        }

    make_trapezoids (
                     vertex_list->coord[0],     /* x */
                     vertex_list->coord[1],     /* y */
                     vertex_list->coord[2],     /* z */
                     vertex_list->coord[3],     /* w */
                     vertex_list->norm[0],      /* intensity (xnorm) */
                     vertex_list->norm[1],      /* v_val     (ynorm) */
                     vertex_list->norm[2],      /* znorm */
                     vertex_list->u,    /* u */
                     vertex_list->v,    /* v */
                     vertex_list->percent,      /* percent */
                     vertex_list->edge_flag,    /* edge mark */
                     1);        /* clip flag */

    stop_point = vertex_list;
    this_point = vertex_list->next;
    do
        {
        if (element_parms.facet_type != RENDERED)
            {
            /* only scale z's if not rendering */
            this_point->coord[2] *= z_scale;
            }
        else if (!element_parms.front_facing_facet)
            {
            /* flip the normal to point toward the eye for rendering */
            this_point->norm[0] = -this_point->norm[0];
            this_point->norm[1] = -this_point->norm[1];
            this_point->norm[2] = -this_point->norm[2];
            }

        make_trapezoids (
                         this_point->coord[0],  /* x */
                         this_point->coord[1],  /* y */
                         this_point->coord[2],  /* z */
                         this_point->coord[3],  /* w */
                         this_point->norm[0],   /* intensity (xnorm) */
                         this_point->norm[1],   /* v_val     (ynorm) */
                         this_point->norm[2],   /* znorm */
                         this_point->u, /* u */
                         this_point->v, /* v */
                         this_point->percent,   /* percent */
                         this_point->edge_flag, /* edge_mark */
                         0);    /* clip flag */

        this_point = this_point->next;
        }

    while (this_point != stop_point);
    }


/*---process_facet----------------------------------------------------------*/

/*
 * HISTORY: 08/03/89	Removed automatic 0,0,-1 view light source.
 *								Trevor Mink
 *	    05/20/91	Added code to handled FEM triangular meshes.
 *								Bob Druzynski
*/

void process_facet (struct HSloop * facet)

    {
    struct HSloop *this_loop;
    struct HSvertex *vertex_list, *stop_vertex = NULL, *this_pt, *stop_pt;
    IGRdouble Shade = 0.0, eye_vector[3];
    IGRboolean first_loop = TRUE;
    IGRboolean not_culled = TRUE;


    /* TRANSFORMATION PIPELINE */

#   if DEBUG_LOOP
    fprintf (stderr, "clipshd\n");
    this_loop = facet;
    while (this_loop != NIL_LOOP)
        {
        stop_vertex = vertex_list = this_loop->loop;
        do
            {
            fprintf (stderr, "%10.4f %10.4f %10.4f - %10.4f %10.4f\n",
                     vertex_list->coord[0],
                     vertex_list->coord[1],
                     vertex_list->coord[2],
                     vertex_list->u,
                     vertex_list->v);

            vertex_list = vertex_list->next;
            }

        while (vertex_list != stop_vertex);

        fprintf (stderr, "\n");
        this_loop = this_loop->next;
        }
#   endif

    this_loop = facet;
    while ((this_loop != NIL_LOOP) && (not_culled))
        {
        vertex_list = this_loop->loop;

        /* Clip */

        if (element_parms.facet_type == POLYLINE)
            {
            if (active_window->perspective)
                clipln_4d (vertex_list,
                           element_parms.ele_clip_range[3] * 0.5,
                           element_parms.ele_clip_range[4] * 0.5,
                           tiling_parms.maximum_z);
            else
                clipln_3d (vertex_list,
                           element_parms.ele_clip_range[0],
                           element_parms.ele_clip_range[1],
                           element_parms.ele_clip_range[2],
                           element_parms.ele_clip_range[3],
                           element_parms.ele_clip_range[4],
                           element_parms.ele_clip_range[5],
                           ZSCALE);
            }
        else if (active_window->perspective)
            {
            if (tiling_parms.processing_mode & HS_PMODE_CLIP)
                vertex_list = clip_4d (
                                       vertex_list,
                                       element_parms.doing_vertex_normals,
                                       (element_parms.ele_clip_range[2] -
                                        active_window->dit_clip_range[2]) /
                                       (active_window->dit_clip_range[5] -
                                        active_window->dit_clip_range[2]));
            if (vertex_list)
                {
                eye_vector[0] = vertex_list->coord[0];
                eye_vector[1] = vertex_list->coord[1];
                eye_vector[2] = vertex_list->coord[3];
                }

            this_loop->loop = vertex_list;
            }
        else
            {
            if (tiling_parms.processing_mode & HS_PMODE_CLIP)
                vertex_list = hs_clip_3d (vertex_list,
                                       element_parms.ele_clip_range[0],
                                       element_parms.ele_clip_range[1],
                                       element_parms.ele_clip_range[2],
                                       element_parms.ele_clip_range[3],
                                       element_parms.ele_clip_range[4],
                                       element_parms.ele_clip_range[5],
                                       element_parms.doing_vertex_normals);

            if (vertex_list)
                subtract_off_z_min (vertex_list);

            this_loop->loop = vertex_list;
            }

        element_parms.front_facing_facet =
            front_facing_facet (active_window->perspective, eye_vector);

        /* If this if the first loop,( the solid portion), see if the facet
         * can be culled. */

        if ((first_loop) && (!(tiling_parms.processing_mode & HS_PMODE_DEXEL)))
            {
            switch (element_parms.culling_back_planes)
                {
                case (HS_CULL_POSITIVE):
                    not_culled = (element_parms.front_facing_facet) ?
                        (FALSE) : (TRUE);
                    break;

                case (HS_CULL_NEGATIVE):
                    not_culled = element_parms.front_facing_facet;
                    break;

                default:
                    break;
                    }
            }


        /* Process facet data( as opposed to polyline data, which was already
         * sent out by the polyline clipper). */

        if ((vertex_list) && (not_culled) && (element_parms.facet_type != POLYLINE))
            {

            /* Get shade data */

            if ((element_parms.facet_type != FEM_TILE) && 
                (element_parms.facet_type != FEM_MESH) &&
                (element_parms.facet_type != RENDERED) &&
               !(tiling_parms.processing_mode & HS_PMODE_PHONG_LIGHTS) )
                {
                switch (element_parms.facet_type)
                    {
                    case SMOOTH_SHADE:
                        if (element_parms.front_facing_facet)
                            find_smooth_shades ( vertex_list,
                                                USE_NEG_OF_DOT_PRODUCT,
                                                active_window->persp_x_scale,
                                                active_window->persp_y_scale,
                                              active_window->persp_z_scale);
                        else
                            find_smooth_shades ( vertex_list,
                                                USE_DOT_PRODUCT,
                                                active_window->persp_x_scale,
                                                active_window->persp_y_scale,
                                              active_window->persp_z_scale);

                        if (active_window->perspective)
                            perspective_projection (vertex_list);

                        /* Apply depth cueing */

                        if (active_window->depth_cue_on)
                            if (active_window->perspective)
                                do_smooth_depth_cueing (vertex_list, 3);
                            else
                                do_smooth_depth_cueing (vertex_list, 2);
                        break;


                    case CONST_SHADE:
                        if (first_loop)
                            {

                            /* calculate shade for this facet */

                            HSnormalize_facet_normal ();

                            /* flip the facet normal to point toward the eye */

                            if (!(element_parms.front_facing_facet))
                                HSnegate_facet_normal ();

                            find_const_shades ( vertex_list,
                                               USE_NEG_OF_DOT_PRODUCT,
                                               active_window->persp_x_scale,
                                               active_window->persp_y_scale,
                                               active_window->persp_z_scale);

                            /* restore the facet normal */

                            if (!(element_parms.front_facing_facet))
                                HSnegate_facet_normal ();

                            Shade = vertex_list->norm[0];
                            }
                        else
                            {

                            /* place pre-calculated shade in every vertex for
                             * this loop */

                            stop_vertex = vertex_list;
                            do
                                {
                                vertex_list->norm[0] = Shade;
                                vertex_list = vertex_list->next;
                                }

                            while (vertex_list != stop_vertex);
                            }

                        if (active_window->perspective)
                            perspective_projection (vertex_list);

                        /* Apply depth cueing */

                        if (active_window->depth_cue_on)
                            if (active_window->perspective)
                                do_const_depth_cueing (vertex_list, 3);
                            else
                                do_const_depth_cueing (vertex_list, 2);

                        break;

                    case RASTER_EDGES:
                    case REV_EDGES:
                    case AREA_FILL:
                        if (active_window->perspective)
                            perspective_projection (vertex_list);

                    default:
                        break;
                        }
                }
            else 
            if ((element_parms.facet_type == RENDERED) && 
                 active_window->perspective)
                {
                perspective_projection (vertex_list);
                }

            else
            if (element_parms.facet_type == FEM_MESH)
                {
                /* place shade value into x value of normal */ 
                stop_pt = vertex_list;
                this_pt = vertex_list;
                do
                    {
                    /* red is already in norm[0],put green in u and blue in v */
                    this_pt->u = this_pt->norm[1];
                    this_pt->v = this_pt->norm[2];
                    this_pt = this_pt->next;
                    }

                while (stop_pt != this_pt);
                }
            send_loop_to_polybuster (vertex_list);
            }

        first_loop = FALSE;
        this_loop = this_loop->next;
        }

    /* Invoke polybuster( flag = 2). */

    if ((element_parms.facet_type != POLYLINE) &&
        (not_culled) && (facet->loop != NIL_VERTEX))
        make_trapezoids (
                         0.0,   /* x */
                         0.0,   /* y */
                         0.0,   /* z */
                         0.0,   /* w */
                         0.0,   /* intensity */
                         0.0,   /* v_val */
                         0.0,   /* znorm */
                         0.0,   /* u */
                         0.0,   /* v */
                         0,     /* percent */
                         0,     /* edge_mark */
                         2);    /* clip_flag */

    /* dispose_facet( facet ); */

#   if DEBUG_MEM
    check_memory ();
#   endif
    }
