class implementation Root;

#include <stdio.h>

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMminimum.h"

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


tst_change_group ( test, bad )
                   GRint test     /*Test = 0, debug off; otherwise ON   (IN) */;
                   GRint bad      /*Bad = 0, good input; otherwise bad  (IN) */;

/*
   This routine is supposed to test the change_group (change_group) feature.
   The inputs are test and bad to specify debug OFF/ON and GOOD/BAD input.
*/
/*.tst_change_group */
{
  GRint      status, om_status;
  GRobjid    groupid;
  GRspacenum osnum;

  if (bad == 0)
  {

  status = gr$cg ( groupname = "one", passwd = "uno" );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "tst_change_group : gr$cg" );

  status = di$mkdir ( dirname = ":transient:testing",
		      p_dirid = &groupid, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "change_group : di$mkdir" );

  status = gr$cg ( groupname = "two", passwd = "dos" );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "tst_change_group : gr$cg" );

  status = gr$change_group ( objid = groupid, old_passwd = "uno" );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status,
                      comment = "tst_change_group : gr$change_group (1)" );

  status = gr$cg ( groupname = "one", passwd = "uno" );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "tst_change_group : gr$cg" );

  status = gr$change_group ( objname = ":transient:testing",
			     osnum = osnum, old_passwd = "dos" );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status,
                      comment = "tst_change_group : gr$change_group (2)" );
  }

  else
  {

  status = gr$cg ( groupname = "one", passwd = "uno" );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "tst_change_group : gr$cg" );

  status = di$mkdir ( dirname = ":transient:testing4",
                      p_dirid = &groupid, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "change_group : di$mkdir" );

  status = gr$cg ( groupname = "two", passwd = "dos" );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "tst_change_group : gr$cg" );

  status = gr$change_group ( objid = groupid, new_gr_name = "a", osnum = osnum,
			     new_passwd = "si", old_passwd = "uno" );
  if (status == GR_S_SUCCESS)
    gr$report_error ( sts = status,
                      comment = "tst_change_group : gr$change_group" );

  status = gr$change_group ( objid = groupid, new_gr_name = "a", osnum = osnum,
			     new_passwd = "seis", old_passwd = "help" );
  if (status == GR_S_SUCCESS)
    gr$report_error ( sts = status,
                      comment = "tst_change_group : gr$change_group" );

  status = gr$change_group ( objid = groupid, osnum = osnum, new_passwd = "si",
                             new_gr_name = "what", old_passwd = "uno" );
  if (status == GR_S_SUCCESS)
    gr$report_error ( sts = status,
                      comment = "tst_change_group : gr$change_group" );

  status = gr$change_group ( );
  if (status == GR_S_SUCCESS)
    gr$report_error ( sts = status,
                      comment = "tst_change_group : gr$change_group" );

  }


  return GR_S_SUCCESS;
}

end implementation Root;
