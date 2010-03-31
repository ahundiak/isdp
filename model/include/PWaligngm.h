#ifndef PWaligngm_include
#define PWaligngm_include

/*
 * OVERVIEW
 *    This file consists the macros, for alignment of memory pointers and 
 *    which will be used internally to align a contiguous memory for curve
 *    and surface data structures.
 */

/*
 * The following macros a memory pointer to align to the respective boundary
 * i.e. double, int, short etc. speciifed.
 */
#define PW_ALIGN_BDRY(bdry,ptr) (((unsigned long) (ptr) % (bdry)) ?   \
                                (bdry) - (unsigned long) (ptr) %     \
                                (bdry) + (char *) (ptr) : (char *)(ptr))

#define PW_ALIGN_DOUBLE(ptr)  PW_ALIGN_BDRY(sizeof(double),ptr)
#define PW_ALIGN_INT(ptr)     PW_ALIGN_BDRY(sizeof(int),ptr)
#define PW_ALIGN_SHORT(ptr)   PW_ALIGN_BDRY(sizeof(short),ptr)

/*************************************************************************
 * This macro determines the number of bytes necessary to hold a B-spline
 * curve data structure immediately followed by its poles, knots, weights,
 * and boundary points (with proper alignment).
 *
 * input:
 *  short   order            - order of curve
 *  long    num_poles        - number of poles
 *  boolean rational         - rational curve indicator
 *  short   num_boundaries   - number of curve boundaries
 *
 * output:
 *  int     size             - number of bytes required
 *************************************************************************/

#define PW_ALIGN_CVSIZE(num_poles, order, rational, num_boundaries, size) \
{ \
  size = (num_poles) * ((rational) ? 4 : 3); \
  size += (num_poles) + (order) + 2 * (num_boundaries); \
  size *= sizeof(double); \
  size += sizeof(struct IGRbsp_curve) + 20; \
}

/*************************************************************************
 * This macro determines the number of bytes necessary to hold a
 * B-spline surface data structure immediately followed by its
 * poles, knots, weights, and boundary points (with proper
 * alignment).
 *
 *   input:
 *
 *   IGRshort   u_order          - order in the u direction
 *   IGRshort   v_order          - order in the v direction
 *   IGRlong    u_num_poles      - number of poles in u
 *   IGRlong    v_num_poles      - number of poles in v
 *   IGRboolean rational         - rational indicator
 *   IGRshort   num_boundaries   - number of boundaries
 *   IGRlong    points_per_bnd[] - number of points per boundary
 *
 *   output:
 *
 *   int    size             - number of bytes required
 *
 *************************************************************************/
#define PW_ALIGN_SFSIZE(u_num_poles, v_num_poles, u_order, v_order, rational, num_boundaries, points_per_bnd, size) \
{ \
    size = (u_num_poles) * (v_num_poles) * ((rational) ? 4 : 3);        \
    size += (u_num_poles) + (u_order) + (v_num_poles) + (v_order) + 10; \
    size *= sizeof(double);                                             \
    size += sizeof(struct IGRbsp_surface);                              \
    if (num_boundaries)                                                 \
    {                                                                   \
        int i = 0, j = 0;                                               \
                                                                        \
        while (i < (num_boundaries)) j += (points_per_bnd)[i++];        \
        size += 2 * j * sizeof(double);                                 \
        size += (num_boundaries) * sizeof(struct IGRbsp_bdry_pts);      \
    }                                                                   \
}


/*************************************************************************
 *
 * This macro partitions a contiguous array of memory (starting at a
 * B-spline curve structure) so that the structure is immediately
 * followed by the curve's poles, knots, weights, and boundary points.
 * It is assumed that the curve is properly aligned.  The internal
 * pointers in the curve will be properly aligned.
 *
 *  input: 
 *   IGRshort   order            - order of curve
 *   IGRlong    num_poles        - number of poles
 *   IGRboolean rational         - rational curve indicator
 *   IGRshort   num_boundaries   - number of curve boundaries
 *
 *  output:
 *   struct IGRbsp_curve *curve   - curve data structure
 *
 *************************************************************************/

#define PW_ALIGN_CVGEOM(num_poles, order, rational, num_boundaries, p_curve) \
{                                                                     \
  (p_curve)->poles = (IGRdouble *) (PW_ALIGN_DOUBLE((p_curve) + 1));  \
  (p_curve)->knots = &(p_curve)->poles[3 * (num_poles)];              \
  if ((rational))                                                     \
  {                                                                   \
    (p_curve)->weights = &(p_curve)->knots[(num_poles) + (order)];    \
    if ((num_boundaries))                                             \
    {                                                                 \
      (p_curve)->bdrys = &(p_curve)->weights[(num_poles)];            \
    }                                                                 \
    else                                                              \
    {                                                                 \
      (p_curve)->bdrys = 0;                                           \
    }                                                                 \
  }                                                                   \
  else                                                                \
  {                                                                   \
    (p_curve)->weights = 0;                                           \
    if ((num_boundaries))                                             \
    {                                                                 \
      (p_curve)->bdrys = &(p_curve)->knots[(num_poles) + (order)];    \
    }                                                                 \
    else                                                              \
    {                                                                 \
      (p_curve)->bdrys = 0;                                           \
    }                                                                 \
  }                                                                   \
}


/*************************************************************************
 * This macro partitions a contiguous array of memory
 * (starting at a B-spline surface structure) so that the
 *  structure is immediately followed by the surface's poles,
 * knots, weights, and boundary points.  It is assumed that the
 * surface is properly aligned.  The internal pointers in the
 * surface will be properly aligned.
 * 
 *  input:
 *   IGRshort   u_order              - order in the u direction
 *   IGRshort   v_order              - order in the v direction
 *   IGRlong    u_num_poles          - number of poles in u
 *   IGRlong    v_num_poles          - number of poles in v
 *   IGRboolean rational             - rational indicator
 *   IGRshort   num_boundaries       - number of boundaries
 *   IGRlong    points_per_bnd[]     - number of points per boundary
 *
 *  output:
 *    struct IGRbsp_surface *surface  - surface data structure
 *************************************************************************/

#define PW_ALIGN_SFGEOM(u_num_poles, v_num_poles, u_order, v_order, rational, num_boundaries, points_per_bnd, p_surface)                              \
{                                                                     \
    long total_poles;                                                 \
    double *double_ptr;                                               \
                                                                      \
    double_ptr = (double *) PW_ALIGN_DOUBLE((p_surface) + 1);         \
    (p_surface)->poles = double_ptr;                                  \
    total_poles = (u_num_poles) * (v_num_poles);                      \
    double_ptr += 3 * total_poles;                                    \
    if (rational)                                                     \
    {                                                                 \
        (p_surface)->weights = double_ptr;                            \
        double_ptr += total_poles;                                    \
    }                                                                 \
    else                                                              \
        (p_surface)->weights = NULL;                                  \
    (p_surface)->u_knots = double_ptr;                                \
    double_ptr += (u_num_poles) + (u_order);                          \
    (p_surface)->v_knots = double_ptr;                                \
    double_ptr += (v_num_poles) + (v_order);                          \
    if (num_boundaries)                                               \
    {                                                                 \
        int i;                                                        \
        (p_surface)->bdrys = (struct IGRbsp_bdry_pts *) double_ptr;   \
        double_ptr = (double *)                                       \
            PW_ALIGN_DOUBLE((p_surface)->bdrys + (num_boundaries));   \
        for (i = 0; i < (num_boundaries); i++)                        \
        {                                                             \
            (p_surface)->bdrys[i].num_points = (points_per_bnd)[i];   \
            (p_surface)->bdrys[i].points = double_ptr;                \
            double_ptr += 2 * (points_per_bnd)[i];                    \
        }                                                             \
    }                                                                 \
    else                                                              \
        (p_surface)->bdrys = NULL;                                    \
}

#endif
