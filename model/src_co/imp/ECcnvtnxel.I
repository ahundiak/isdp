/* ###################   APOGEE COMPILED   ################## */
class implementation ECigdsiems;

#include "EMS.h"
#include <stdio.h>

method cvt_next_ele ( IGRlong *msg; struct GRid *object_info )
{
 extern int pp_igds_ems_num_calls;
 extern int pp_output_igds_ems_log;
 extern int pp_increment;

 ++pp_igds_ems_num_calls;

if (pp_output_igds_ems_log)
{
 if ((pp_igds_ems_num_calls == 1) ||
    (!(pp_igds_ems_num_calls % pp_increment)))
 fprintf (stderr,"Processing %d \n",pp_igds_ems_num_calls);
}

 return (om$send (msg = message ECigdsiems.cvt_next_ele(msg,object_info),
                  mode = OM_e_wrt_parent,
                  targetid = my_id));

}

end implementation ECigdsiems;

