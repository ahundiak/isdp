# ifndef EMSmovepole_include
# define EMSmovepole_include 1

/* Options used during movement of poles on surface */

#define EMMOVE_POLE_ALONG_SPECIFIED_VECTORS 0x1 
#define EMMOVE_POLE_ALONG_SPECIFIED_DISTS 0x2

/*
 * This structure supplements information being passed to the move pole
 * method.
 */

struct EMmove_pole_addtnl_info
{
 IGRdouble *vectors;    /* Vector direction of each pole */
 IGRdouble *dists;      /* Distance each pole is moving by */
 IGRdouble *ref_vector; /* Reference vector is necessary when passing in
                           vectors information. */
 IGRdouble *ref_dist;   /* Reference distance */
};

# endif
