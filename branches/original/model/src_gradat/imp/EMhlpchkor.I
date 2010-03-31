/* ###################   APOGEE COMPILED   ################## */
class implementation EMShelper;

#include <stdio.h>
#include "bs.h"
#include "bsparameters.h"

/*
History

    04 Jul 91   Jack    Creation Date
    13 Aug 91   Jack    Added struct GRid *obj parm.  Not used in
                        this implementation.
    17 Sep 91   Jack    Added struct GRmdenv_info *mdenv_info parm.  
 */

method EMcheck_orientation(double               vector[3];
                           struct GRmdenv_info *mdenv_info;
                           int                 *match;
                           double              *result;
                           struct GRid         *obj)
{
  long      sts;

   sts = OM_S_SUCCESS;

  return sts;
};

end implementation EMShelper;
