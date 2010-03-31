/* ###################   APOGEE COMPILED   ################## */
class specification ECslprjsfpl (1:0) of COconst;


/* grutil.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef ex_include
# include "ex.h"
# endif

# ifndef griodef_include
# include "griodef.h"
# endif

# ifndef grio_include
# include "grio.h"
# endif

/* end of grutil.h replacement */

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */

/* lc.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef OMlimits_include
# include "OMlimits.h"
# endif

# ifndef OMminimum_include
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef ex_include
# include "ex.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef griodef_include
# include "griodef.h"
# endif

# ifndef grio_include
# include "grio.h"
# endif

# ifndef lcdef_include
# include "lcdef.h"
# endif

# ifndef lc_include
# include "lc.h"
# endif

# ifndef lcmacros_include
# include "lcmacros.h"
# endif

/* end of lc.h replacement */
/*
Abstract:

Notes:
    This is not an abstract class.

History:
    DLB  02/03/87     Creation date.
*/
 

instance ECslprjsfpl
{
 struct GRlc_info  sf_info;         /*located surface info*/
 struct GRlc_info  pl_info;         /*located plane info*/
 struct GRlc_stack locate_stack;    /*for locate purposes*/
 struct GRevent    locate_event;    /*for locate purposes*/
 struct IGRplane   plane;           /*point and normal defining plane*/
 IGRboolean        obj1_hi, obj2_hi;/*TRUE if solids are hilited*/
 IGRpoint          plane_pt[3];     /*points defining plane*/
 IGRvector         vec;             /*direction vector*/
};

override execute,
/*
Motivation: 
    This execute method contains the code for the
    implementation of the ECslprjsfpl command object. 
    The execute method is defined in the super_cmd
    class with the idea that it would be overridden
    at the command object class level.               
*/
wakeup,
/*
Motivation:
    The wakeup method is overridden to rehilite the located
    objects if the flag is set indicating so.
*/
sleep;
/*
Motivation:
    The sleep method is overridden to dehilite the located
    objects before leaving the command.
*/    

end specification ECslprjsfpl;
