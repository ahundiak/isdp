# ifndef EMScmacros_include
# define EMScmacros_include 1

/* Prerequisite(s):

    if you use EMSmsgReport:
        "EMSlogic.h"

    if you use EMSbs_size or EMSbs_partition:
        "igrtypedef.h"
        "igr.h"

    EMSbs_partition should depend upon "gocmacros.h", but the
    witty guys in go-land put an om$send in "gocmacros.h" so I
    invented our own alignment macros to supplant the go
    versions.  This is hopefully a temporary arrangement.
*/

/*
    On anything other than success or information, EMSmsgReport
    yields a true value.  On success and information,
    EMSmsgReport yields a false value.

    If there is an error, warning or fatal message, or if always
    is true, then an attempt is made to print the message code
    and the string is printed to stderr.
*/

# if RELEASED /* we do not want the message reporting code */

# define EMSmsgReport(sts, string, always) EMSerror (sts)

# else /* NOT RELEASED, then we can do all of the writes */

extern int EFmsgReport ();

# define EMSmsgReport(sts, string, always) \
( \
    ((EMSerror (sts)) OR (always)) ? \
        EFmsgReport (NULL, (sts), (string)) : \
        FALSE \
)

# endif /* RELEASED */

/*

    EMSbs_size determines the number of bytes necessary to hold a
    B-spline surface data structure immediately followed by its
    poles, knots, weights, and boundary points (with proper
    alignment).

    input:

    IGRshort   u_order          - order in the u direction
    IGRshort   v_order          - order in the v direction
    IGRlong    u_num_poles      - number of poles in u
    IGRlong    v_num_poles      - number of poles in v
    IGRboolean rational         - rational indicator
    IGRshort   num_boundaries   - number of boundaries
    IGRlong    points_per_bnd[] - number of points per boundary

    output:

    IGRlong    size             - number of bytes required
  
    25-Mar-87 rlw creation date
    30-Mar-87 jbk changed for loop to while loop
*/

# define EMSbs_size(u_order, v_order, u_num_poles, v_num_poles, rational, num_boundaries, points_per_bnd, size) \
{ \
    size = (u_num_poles) * (v_num_poles) * ((rational) ? 4 : 3);        \
    size += (u_num_poles) + (u_order) + (v_num_poles) + (v_order) + 10; \
    size *= sizeof(IGRdouble);                                          \
    size += sizeof(struct IGRbsp_surface);                              \
    if (num_boundaries)                                                 \
    {                                                                   \
        IGRint i = 0, j = 0;                                            \
                                                                        \
        while (i < (num_boundaries)) j += (points_per_bnd)[i++];        \
        size += 2 * j * sizeof(IGRdouble);                              \
        size += (num_boundaries) * sizeof(struct IGRbsp_bdry_pts);      \
    }                                                                   \
}

/*
    If it is necessary, the following macros align pointers.
    Please refrain from using these alignment macros if you can
    use the "gocmacros.h" versions.
*/

# define EMSalign_bdry(bdry, ptr)            \
    (char *) (((unsigned int) (ptr) % (bdry)) ?       \
    (bdry) - (unsigned int) (ptr) %         \
    (bdry) + (char *) (ptr) : (char *) (ptr))

# define EMSalign_double(ptr) EMSalign_bdry (8, ptr)
# define EMSalign_quad(ptr)   EMSalign_bdry (8, ptr)
# define EMSalign_long(ptr)   EMSalign_bdry (4, ptr)
# define EMSalign_short(ptr)  EMSalign_bdry (2, ptr)
# define EMSalign_char(ptr)   (ptr)


/*
    EMSbs_partition partitions a contiguous array of memory
    (starting at a B-spline surface structure) so that the
    structure is immediately followed by the surface's poles,
    knots, weights, and boundary points.  It is assumed that the
    surface is properly aligned.  The internal pointers in the
    surface will be properly aligned.

    input:
    IGRshort   u_order              - order in the u direction
    IGRshort   v_order              - order in the v direction
    IGRlong    u_num_poles          - number of poles in u
    IGRlong    v_num_poles          - number of poles in v
    IGRboolean rational             - rational indicator
    IGRshort   num_boundaries       - number of boundaries
    IGRlong    points_per_bnd[]     - number of points per boundary

    output:
    struct IGRbsp_surface *surface  - surface data structure

    25-Mar-87 rlw creation
*/

# define EMSbs_partition(u_order, v_order, u_num_poles, v_num_poles, rational, num_boundaries, points_per_bnd, surface) \
{                                                                   \
    IGRlong total_poles;                                            \
    IGRdouble *double_ptr;                                          \
                                                                    \
    double_ptr = (IGRdouble *) EMSalign_double((surface) + 1);       \
    (surface)->poles = double_ptr;                                  \
    total_poles = (u_num_poles) * (v_num_poles);                    \
    double_ptr += 3 * total_poles;                                  \
    if (rational)                                                   \
    {                                                               \
        (surface)->weights = double_ptr;                            \
        double_ptr += total_poles;                                  \
    }                                                               \
    else                                                            \
        (surface)->weights = NULL;                                  \
    (surface)->u_knots = double_ptr;                                \
    double_ptr += (u_num_poles) + (u_order);                        \
    (surface)->v_knots = double_ptr;                                \
    double_ptr += (v_num_poles) + (v_order);                        \
    if (num_boundaries)                                             \
    {                                                               \
        IGRint i;                                                   \
        (surface)->bdrys = (struct IGRbsp_bdry_pts *) double_ptr;   \
        double_ptr = (IGRdouble *)                                  \
            EMSalign_double((surface)->bdrys + (num_boundaries));   \
        for (i = 0; i < (num_boundaries); i++)                      \
        {                                                           \
            (surface)->bdrys[i].num_points = (points_per_bnd)[i];   \
            (surface)->bdrys[i].points = double_ptr;                \
            double_ptr += 2 * (points_per_bnd)[i];                  \
        }                                                           \
    }                                                               \
    else                                                            \
        (surface)->bdrys = NULL;                                    \
}

# endif /* EMScmacros_include */
