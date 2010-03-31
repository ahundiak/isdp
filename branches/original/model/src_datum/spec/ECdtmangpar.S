/* ###################   APOGEE COMPILED   ################## */
class specification ECdtmangpar (1:0) of ECdtmfc;

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
#include "FI.h"

instance ECdtmangpar
 {
  IGRboolean normal_displayed;
  IGRint           set_edge_locatable_flag;
  struct GRevent   value_event;
  int              assoc_flags;    
  short		   prev_states[8]; /* stores the previous states of the CO */
 };
 

message display_normal(IGRint draw_bg);

override 
   is_status_form_valid,
   execute, 
   sleep, 
   wakeup, 
   init,
   delete;

end specification ECdtmangpar;
