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


IGRlong GRis_unit_scalable(msg,
			   unit_type,
			   osnum,
			   scale_flag)

  IGRlong                 *msg;          /* return code from function        */
  IGRchar                 *unit_type;   /* type of conversion to be done    */
  OMuword                  osnum;        /* object space # table is in       */
  IGRboolean              *scale_flag;
{
  return UOM_is_unit_scalable( msg, unit_type, osnum, scale_flag );
}

end implementation Root;
