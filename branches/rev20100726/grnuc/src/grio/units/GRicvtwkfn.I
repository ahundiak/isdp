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

IGRlong GRcvt_imp_to_wrk(msg,
                         table_name,
                         osnum,
                         primary,
                         second,
                         tertiary,
                         working_units)


  IGRlong      *msg;          /* return code from function                  */
  IGRchar      *table_name;   /* type of conversion to be done              */
  OMuword       osnum;        /* object space # table is in                 */
  IGRdouble     primary;      /* num of working units to convert from       */
  IGRdouble     second;       /* num of working units to convert from       */
  IGRdouble     tertiary;     /* num of working units to convert from       */
  IGRdouble    *working_units;/* num of working units convert to            */
{
  IGRlong sts;

  sts = UOM_cvt_imp_to_wrk( msg, table_name, osnum, primary, second,
                            tertiary, working_units );
  if ( sts & 1 )
    sts = OM_S_SUCCESS, *msg = MSSUCC;
  else
    sts = OM_E_ABORT, *msg = MSFAIL;

  return sts;
}

end implementation Root;
