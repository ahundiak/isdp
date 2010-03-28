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

main3 ()
{
  /* dummy test routine for this on */
  system ( "cp output/masterout output/newout" );
  
  return 1;
}


tst_cg ( name, passwd, bad )
         GRchar *name                     /* name of the new group   */;
	 GRchar *passwd                   /* passwd of the new group */;
	 GRint  bad                       /* good input ... bad = 0  */;
/*
   This routine is supposed to test the change_group (gr$cg) feature and
   the present_working_group (gr$pwg) feature.  The inputs are the groupname
   of the new group and its passwd (from cg.in).  Once the current group
   is changed (via gr$cg), the present working group is checked (via gr$pwg).
   Good input when bad = 0; otherwise, bad input.
*/
/*.tst_cg */
{
  GRint      status;
  GRint      groupind, groupind2;
  GRobjid    groupid, groupid2;
  GRspacenum osnum, osnum2;

  /*"name : '%s', passwd : '%s'\n", name, passwd */
  if (bad == 0)
  {

  status = gr$cg ( groupname  = name,
                   passwd     = passwd,
		   p_groupid  = &groupid,
                   p_groupind = &groupind,
		   p_osnum    = &osnum,
		   flag       = 1 );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "tst_cg : gr$cg is wrong" );

  status = gr$pwg ( groupname  = name,
                    p_groupid  = &groupid2,
		    p_groupind = &groupind2,
		    p_osnum    = &osnum2 );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "tst_cg : gr$pwg is wrong" );

  if ((groupid != groupid2) || (osnum != osnum2) || (groupind != groupind2))
  {
    printf ("Incompatability between gr$cg and gr$pwg in tst_cg\n");
    printf ("cg  : '%d','%d','%d'\n", osnum , groupid , groupind );
    printf ("pwg : '%d','%d','%d'\n", osnum2, groupid2, groupind2);
  }

#if 0
  status = gr$validate ( type = GR_R_READ, groupind = groupind );
  if (status != GR_S_SUCCESS)
    gr$report_error (sts = status, comment = "tst_cg : validate READ wrong");

  status = gr$validate ( type = GR_R_WRITE, groupind = groupind );
  if (status != GR_S_SUCCESS)
    gr$report_error (sts = status, comment = "tst_cg : validate WRITE wrong");
#endif

  status = gr$cg ( groupname = "-" );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "tst_cg : gr$cg - is wrong" );

  status = gr$cg ( groupname = "-" );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "tst_cg : gr$cg - is wrong" );

  }

  else
  {

  status = gr$cg ( groupname = name, passwd = passwd, p_groupid = &groupid,
                               p_groupind = &groupind, p_osnum = &osnum );
  if (status == GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "tst_cg : gr$cg is wrong" );

  }


  return GR_S_SUCCESS;
}

end implementation Root;
