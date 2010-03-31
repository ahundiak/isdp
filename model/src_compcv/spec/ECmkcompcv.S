/* ###################   APOGEE COMPILED   ################## */
/*
Make composite curves given a bunch of curves

History:

12 Jun 1989 jBk Removed struct GRsymbology active_symbology.

gk                  03-02-87        reduced numb of inst vars

Kirit Patel(KRP)    Nov-20-1986:    Genesis date.
*/

class specification ECmkcompcv (1:0) of CObuild;

# ifndef igrtypedef_include
# include "igrtypedef.h"     /* needed for lc.h */
# endif

# ifndef gr_include
# include "gr.h"     /* needed for lc.h */
# endif

# ifndef go_include
# include "go.h"     /* needed for lc.h */
# endif

# ifndef grio_include
# include "grio.h"     /* needed for lc.h */
# endif

# ifndef lcdef_include
# include "lcdef.h"     /* needed for lc.h */
# endif

# ifndef lc_include
# include "lc.h"        /* GRlc_stack */
# endif

instance ECmkcompcv
{
   struct        GRmd_env ModuleInfo;
   struct        GRevent locate_event;
   struct        GRlc_stack locate_stack;
   variable      struct   GRlc_info  locobj[ ];
   IGRint        ext_to_int;
   IGRlong       num_crv;   /* numb curves identified */
   IGRdouble     connect_tol, search_tol;
   IGRpoint      flow_pnt;
   struct GRevent accept_event;
};

override wakeup, execute, sleep, init;

end specification ECmkcompcv;

