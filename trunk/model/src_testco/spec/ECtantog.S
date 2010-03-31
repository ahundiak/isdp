/* ###################   APOGEE COMPILED   ################## */
class specification ECtantog (1:0) of super_cmd;

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

override init, wakeup, execute, sleep;


instance ECtantog
 {
  struct GRevent                locate_event;
  struct GRlc_stack 		locate_stack;
  variable struct GRlc_info 	locobj[20];
  channel {(rel_ordered, many_to_many,
	   initial=1, increment=1)}	drawing_view_channel;
  OM_S_CHANSELECT	  dv_chansel;	/* drawing view chan select    */
  struct GRid window;
  struct GRmd_env md_env;
  OM_S_OBJID os_objid;
 };


end specification ECtantog;
