class implementation Root;

#include <stdio.h>

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#define DEBUG

#include "GRtypedef.h"
#include "GRdef.h"
#include "GRprims.h"
#include "GRglob.h"
#include "DIomac.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"


tst_valid ( name, type, bad )
            GRchar *name                     /* name of group to check  */;
	    GRint  type                      /* type of the operation   */;
	    GRint  bad                       /* good input ... bad = 0  */;
/*
   This routine is supposed to test the validate (gr$validate) feature.  The
   input is the the type of operation to be performed.  Good input when
   bad = 0; otherwise, bad input.
*/
/*.tst_valid */
{
  GRint      status, i, count, groupind;
  GRobjid    groupid;
  GRspacenum osnum;
  DIchar     **lines;

  /*"name : '%s', type : %d\n", name, type */
  if (bad == 0)
  {

  status = di$unindex ( dirname = GR_G_root, name = name, p_index = &groupind );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "tst_valid : di$unindex wrong" );

  status = gr$validate ( type = type, groupind = groupind );
  if (status != GR_S_SUCCESS)
    gr$report_error (sts = status, comment = "tst_valid : gr$valid wrong");


  }

  else
  {

  status = di$unindex ( dirname = GR_G_root, name = name, p_index = &groupind );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "tst_valid : di$unindex wrong" );

  status = gr$validate ( type = type, groupind = groupind );
  if (status == GR_S_SUCCESS)
      gr$report_error (sts=status, comment = "tst_valid : gr$valid wrong");

  }

  return GR_S_SUCCESS;
}

end implementation Root;
