/* ###################   APOGEE COMPILED   ################## */
class specification ECdgts (1:0) of ECelement;

#include "ems_m_inc.h"
#include "griomacros.h" /* For co$get_event */
#include "dpdef.h" 
#include "igrdef.h"     /* For IGRPY */
#include "OMmacros.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "emserr.h"
#include "EMSdpb.h" /* For EMSdpb_u_order */

struct modbuff_info
{
 IGRint firstcall;
 IGRpoint start_pt;
 IGRint store_num_points;
 struct IGRpolyline *poly;
 struct DPele_header buff;
 struct GRmd_env *md_env;
};

instance ECdgts
{
 IGRpoint from_point;
 struct IGRpolyline polyline;
 struct IGRespy espy;
 struct modbuff_info info;
 IGRboolean form_displayed;
 IGRboolean dynamics_on;
 IGRboolean dynamics_all_windows;
};
 
override status_disp, execute, init,wakeup,super_cmd.sleep,delete;

end specification ECdgts;

