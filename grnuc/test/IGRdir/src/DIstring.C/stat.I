class implementation Root;

#include <stdio.h>

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"



#include "GRtypedef.h"
#include "GRdef.h"
#include "GRprims.h"
#include "DIomac.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

main22 ()
{
  /* dummy test routine for this on */
  system ( "cp output/masterout output/newout" );
  
  return 1;
}


tst_stat ( status )
           GRint status           				/* IN  */;
/*
   This routine is supposed to test the group error status feature.
   The input is the integer value of the error status.
*/
{
    gr$report_error ( sts = status, comment = "tst_stat : report_error" );

  return GR_S_SUCCESS;
}

end implementation Root;
