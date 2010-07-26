/* #######################    APOGEE COMPILED   ######################## */
class implementation Root;

#ifndef NT
#include <sys/time.h>
#endif
#include <time.h>
#include "msdef.h"
#include "OMlimits.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"

#include "grimport.h"
#include "igrmacros.h"
#include <stdio.h>

%safe
#include <math.h>
%endsafe

IGRlong GRput_default_units(msg,
                            table_name,
                            osnum,
                            flag,
                            num_defaults,
                            default_units)



  IGRlong           *msg;          /* return code from function             */
  IGRchar           *table_name;   /* type of conversion to be done         */
  OMuword            osnum;        /* object space # table is in            */
  IGRshort          *flag;         /* 0 - INPUT, 1 - OUTPUT                 */
  IGRshort          *num_defaults;
  GRIOalias_name    *default_units;

{
  IGRlong sts;

  sts = UOM_put_default_units( msg, table_name, osnum, flag, num_defaults,
                               default_units );
  if ( sts & 1 )
    sts = OM_S_SUCCESS, *msg = MSSUCC;
  else
    sts = OM_E_ABORT, *msg = MSFAIL;

  return sts;
}

end implementation Root;
