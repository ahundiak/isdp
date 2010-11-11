/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

    BSstk.h:  This is a file to allow easy use of stack memory
    allocation utilities

    CHANGE HISTORY:
        
    30-Apr-1986  :  Creation date; J. Brooke King, author. (JBK)
*/

# ifndef bsstk_include
# define bsstk_include

# ifndef bsdefs_include
#   include "bsdefs.h"
# endif

# ifndef bserr_include
#   include "bserr.h"
# endif

# ifndef bsstackalloc_include
#   include "bsstackalloc.h"
# endif

# define BSPTSIZE ((unsigned)(sizeof (IGRpoint)))
# define BSPOINTS(num_points) ((unsigned)(BSPTSIZE * (num_points)))

# define BSDOUBLESIZE ((unsigned)(sizeof (IGRdouble)))
# define BSDOUBLES(num_doubles) ((unsigned)(BSDOUBLESIZE * (num_doubles)))

# define BSCVBDRYSIZE ((unsigned)(2 * sizeof (IGRdouble)))
# define BSCVBDRYS(nr_bdrys) ((unsigned)(BSCVBDRYSIZE * (nr_bdrys)))

# define BSSFBDRYSIZE ((unsigned)(sizeof(struct IGRbsp_bdry_pts)))
# define BSSFBDRYS(nr_bdrys) ((unsigned)((nr_bdrys) * BSSFBDRYSIZE))

# include "bsstallcvfl.h"
# include "bsstfrecvfl.h"
# include "bsstallsffl.h"
# include "bsstfresffl.h"

# define BSstkalcvfl(rc, curve, nr_poles, weighted, nr_knots, nr_bdrys) \
{ \
    BSstallcvfl( nr_poles, weighted, nr_knots, curve, rc ); \
}

# define BSstkallocv(rc, curve, nr_poles, weighted, nr_knots, nr_bdrys) \
{ \
    (curve) = (struct IGRbsp_curve *)BSstackalloc \
        ((unsigned)(sizeof (struct IGRbsp_curve))); \
    if (!(curve)) \
       *(rc) = BSNOSTKMEMORY; \
    else \
       BSstallcvfl( nr_poles, weighted, nr_knots, curve, rc ); \
}

# define BSstkfrcvfl(rc, curve) \
    BSstfrecvfl( rc, curve )

# define BSstkalsffl(rc, surf, nu_poles, nv_poles, weighted, nu_knots, nv_knots, nr_bdrys) \
{ \
    BSstallsffl( nu_poles, nv_poles, weighted, nu_knots, \
                          nv_knots, surf, rc ); \
}

# define BSstkallosf(rc, surf, nu_poles, nv_poles, weighted, nu_knots, nv_knots, nr_bdrys) \
{ \
    (surf) = (struct IGRbsp_surface *)BSstackalloc \
        ((unsigned)(sizeof (struct IGRbsp_surface))); \
    if (!(surf)) \
       *(rc) = BSNOSTKMEMORY; \
    else \
       BSstallsffl( nu_poles, nv_poles, weighted, nu_knots, nv_knots, \
                    surf, rc ); \
}

# define BSstkfrsffl(rc, surf) \
    BSstfresffl( rc, surf )

# define BSstkfreecv(rc, curve) \
{ \
    BSstfrecvfl (rc, curve); \
    BSstackdealloc ((char *)curve); \
}

# define BSstkfreesf(rc, surf) \
{ \
    BSstfresffl (rc, surf); \
    BSstackdealloc ((char *)surf); \
}

# endif /* bsstk_include */
