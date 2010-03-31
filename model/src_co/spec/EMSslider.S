/* ###################   APOGEE COMPILED   ################## */
class specification EMSslider (1:1) of super_cmd;

/*
Abstract
    This class handles the processing of the blend shape form.
    It does the init, delete, form_input, and handles the set up
    of the instance data.

Notes

History
    dhm     10/5/88    creation date.
    dhm     10/7/88    added obj_type to the EMprocess_form method and
                       changed geom type from IGRbsp_surface to IGRchar.
    dhm     2/22/89    added bot_left, bot_right, top_left, top_right to
                       instance data.
    msm     3/25/91    Removed the form_input method and added do_form method
                       to handle c_based form.
*/

#include <OMminimum.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "ex.h"
#include "lcdef.h"
#include "lc.h"

instance EMSslider
{
  IGRdouble    tleft, tright;
  IGRint       bot_left, top_left, bot_right, top_right;
  IGRboolean   u, v, obj_type;
  GRobjid      form_id;
  struct IGRchar   *geom;
  struct GRlc_info obj_info;
};

message EMprocess_form(IGRlong *msg; struct GRlc_info *srf; IGRboolean u,
                       v, obj_type; IGRint *response;
                       IGRchar *response_data);
message do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
                 IGRdouble value);
override init, delete;

end specification EMSslider;
