class implementation Root;

#include <stdio.h>

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#define DEBUG

#include "GRtypedef.h"
#include "GRdef.h"
#include "GRglob.h"
#include "GRprims.h"
#include "DIomac.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"


tst_cp ( name, old, new, bad )
         GRchar *name           /* name of the group       */;
         GRchar *old            /* old passwd of the group */;
         GRchar *new            /* new passwd of the group */;
         GRint  bad             /* good input ... bad = 0  */;
/*
   This routine is supposed to test the change_passwd (gr$change_passwd) feature
   for the GRoup system.  The inputs are the name and passwd of the group to
   alter, along with the new passwd for the group.  Good input when bad = 0;
   otherwise, bad input.
*/
/*.tst_cp */
{
  GRint      status;

  if (bad == 0)
  {

  status = gr$cg ( groupname = name, passwd = old );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "tst_cp : gr$cg_1 is wrong" );

  status = gr$cg ( groupname = "usr", passwd = "" );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "tst_cp : gr$cg_2 is wrong" );

  status = gr$change_passwd ( groupname  = name,
			      old_passwd = old,
			      new_passwd = new );
  if (status != GR_S_SUCCESS)
    gr$report_error (sts = status, comment = "tst_cp : gr$change_passwd wrong");

  status = gr$cg ( groupname = name, passwd = old );
  if (status == GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "tst_cp : gr$cg_3 is wrong" );

  status = gr$cg ( groupname = "sys", passwd = "kozzy" );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "tst_cp : gr$cg_4 is wrong" );

  status = gr$cg ( groupname = name );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "tst_cp : gr$cg_5 is wrong" );

  }

  else
  {

  status = gr$change_passwd ( groupname = name,
			      old_passwd = old,
			      new_passwd = new );
  if (status == GR_S_SUCCESS)
    gr$report_error (sts = status, comment = "tst_cp : gr$change_passwd wrong");

  }


  return GR_S_SUCCESS;
}

end implementation Root;
