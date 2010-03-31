/* ###################   APOGEE COMPILED   ################## */
class specification EClink (1:0) of CObuild;

#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "ex.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"

instance EClink
{
  IGRboolean	ext_to_int, associative;
  IGRint		num_comp, end_of_interest;
  IGRint		levels[32];
  IGRdouble		search_tol, connect_tol;
  IGRpoint		start_pnt, stop_pnt;
  struct GRevent	event_1;
  struct GRlc_stack	lc_stack;
  struct GRmd_env	ModuleInfo;
  variable struct GRlc_info		located_obj[];
};

override init, wakeup, sleep, execute;

end specification EClink;
