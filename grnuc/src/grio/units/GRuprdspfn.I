/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

    CLASS  NAME:  GRgnunit

    METHOD NAME:  GR
     

     Design Date:     BMR  12/03/86     

----*/
/* EH */


class implementation Root;

#include <stdio.h>
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

%safe
#include <math.h>
%endsafe

int GRupdate_readout_spec(msg,
                          table_name,
                          osnum,
                          update_flag,
                          readout_spec)
IGRlong                 *msg;
IGRchar                 *table_name;
OMuword                  osnum;
IGRboolean               update_flag;
struct GRIOreadout_spec *readout_spec;
{
  int sts;

  sts = UOM_update_readout_spec( msg, table_name, osnum, update_flag,
                                 readout_spec );
  if ( sts & 1 )
    sts = OM_S_SUCCESS, *msg = MSSUCC;
  else
    sts = OM_E_ABORT, *msg = MSFAIL;

  return sts;
}

end implementation Root;

