/*
Command object for various debug actions such as toggling switches.
*/
class specification NMdebug (1:0) of CObuild;

# include "igrtypedef.h"
# include "OMlimits.h"
# include "OMminimum.h"
# include "igetypedef.h"
# include "ex.h"
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "griodef.h"
# include "lcdef.h"
# include "lc.h"
# include "lcmacros.h"
#include "EMSdpb.h"


instance NMdebug
{
  struct GRevent                locate_event;
  struct GRlc_stack 		locate_stack;
};

override sleep, delete, execute;

end specification NMdebug;
