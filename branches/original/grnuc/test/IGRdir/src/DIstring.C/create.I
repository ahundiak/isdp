class implementation Root;

#include <stdio.h>

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#define DEBUG

#include "GRtypedef.h"
#include "GRdef.h"
#include "GRprims.h"
#include "DIomac.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

main6 ()
{
  /* dummy test routine for this on */
  system ( "cp output/masterout output/newout" );
  
  return 1;
}


tst_create ( name, type, passwd, bad )
             GRchar *name                     /* name of the new group   */;
	     GRint  type                      /* type of the new group   */;
	     GRchar *passwd                   /* passwd of the new group */;
	     GRint  bad                       /* good input ... bad = 0   */;
/*
   This routine is supposed to test the add_group feature.  The inputs are
   the groupname, type, and passwd for the new group.  The input stream
   is altered by the bad mode ( good input when bad = 0; else, bad input ).
*/
/*.tst_create */
{
  GRint status;

  /*"name : '%s', type : %d, passwd : '%s'\n", name, type, passwd */
  if (bad == 0)
  {
    status = gr$cg ( groupname = "sys", passwd = "kozzy", flag = 1 );
    if (status != GR_S_SUCCESS)
      gr$report_error ( sts = status, comment = "tst_create : gr$cg is wrong" );

    /*"type is %d\n", type */
    status = gr$add_group ( groupname = name,
			    type      = type,
			    passwd    = passwd );
    if (status != GR_S_SUCCESS)
      gr$report_error ( sts = status,
                        comment = "tst_create : gr$add_group is wrong" );
  }
  else
  {

    /*"type is %d\n", type */
    status = gr$add_group ( groupname = name,
			    type      = type,
			    passwd    = passwd );
    if (status == GR_S_SUCCESS)
      gr$report_error ( sts = status,
                        comment = "tst_create : gr$add_group is wrong" );

  }

  return GR_S_SUCCESS;
}

end implementation Root;
