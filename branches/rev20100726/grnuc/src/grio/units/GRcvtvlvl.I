class implementation Root;

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


IGRlong GRcvt_value_to_value(msg,
                             table_name,
                             osnum,
                             alias_to_cvt_from,
                             alias_to_cvt_to,
                             num_vals,
                             values_in,
                             values_out)

  IGRlong                  *msg;          /* return code from function        */
  IGRchar                  *table_name;   /* type of conversion to be done    */
  OMuword                   osnum;        /* object space # table is in       */
  IGRchar                  *alias_to_cvt_from;
  IGRchar                  *alias_to_cvt_to;
  IGRint                    num_vals;
  IGRdouble                *values_in;
  IGRdouble                *values_out;
{
  IGRlong sts;

  sts = UOM_cvt_value_to_value( msg, table_name, osnum, alias_to_cvt_from,
                                alias_to_cvt_to, num_vals, values_in,
                                values_out );
  if ( sts & 1 )
    sts = OM_S_SUCCESS, *msg = MSSUCC;
  else
    sts = OM_E_ABORT, *msg = MSFAIL;

  return sts;
}

end implementation Root;
