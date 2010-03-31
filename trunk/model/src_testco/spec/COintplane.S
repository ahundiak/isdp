/* ###################   APOGEE COMPILED   ################## */
class specification COintplane (1:0) of CObuild;

#include "lcdef.h"		/* Needed by lc.h */
#include "lc.h"			/* GRlc_stack */

instance COintplane
 {
  IGRboolean	have_plane_by_points;
  IGRint        natural_normal;
  IGRlong	number_of_buffer_cuts;
  IGRdouble	distance_to_plane;
  IGRpoint	points[4];
  IGRpoint	plane_point;
  IGRvector	plane_normal;
  struct	GRlc_info the_plane_object;
  struct	GRlc_info the_intersect_object;
  struct	GRevent locate_event;
  struct	GRlc_stack locate_stack;
  channel
   {
    (rel_ordered,
     many_to_many,
     initial = 1,
     increment = 1)
   } to_graphics;
  IGRboolean is_associative;
 };

override execute,wakeup,sleep;

end specification COintplane;
