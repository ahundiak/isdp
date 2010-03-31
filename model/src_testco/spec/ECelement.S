/* ###################   APOGEE COMPILED   ################## */
class specification ECelement (1:0) of super_cmd;

/*

ABSTRACT

This class contains instance data that is needed by command objects
that locate an element and process from there on.

HISTORY
    
08/14/94    scw Clarified sleep method
05/05/91    jhw Added is_associative method.
11 May 1989 jBk Added override of wakeup and edited abstract.

                Added motivations for overrides.

SS 10/04/86 : Design Date

*/

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

/* gr.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
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

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

/* end of gr.h replacement */

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

/* grdpb.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef ex_include
# include "ex.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef grdpbdef_include
# include "grdpbdef.h"
# endif

# ifndef grdpb_include
# include "grdpb.h"
# endif

/* end of grdpb.h replacement */

# ifndef lcdef_include
# include "lcdef.h"
# endif

# ifndef lc_include
# include "lc.h"    /* GRlc_{stack,info}, etc. */
# endif

#include "lcmacros.h"

instance ECelement
{
    struct GRmd_env md_env;
    struct IGRdisplay active_display;
    IGRshort active_level;
    struct GRevent locev;
    struct GRlc_stack locate_stack;
    struct GRlc_info elem;
    IGRboolean elem_hilit;
};

override init,

/*

MOTIVATION

The instance data initialized to zero by creation of objects of
this class since objects are calloced.  The me^^super_cmd.mytype
instance variable is set by this override.

*/

wakeup,

/*

MOTIVATION

If the elem_hilit instance variable is TRUE, whatever is in the
elem.located_obj instance variable will be highlighted when
commands of this class are sent the wakeup message.

*/

super_cmd.sleep;

/*

MOTIVATION

If the elem_hilit instance variable is TRUE, the highlight plane
is erased.

*/

end specification ECelement;
