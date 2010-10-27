
/* $Id: VDB_LOCATEi.I,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */
/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:        VDSlocate / VDB_LOCATE.I
 *
 * Description:
 *
 *      High level command class for VDS/ROUTE/STRUCT to implement
 *      automatic termination when not logged into the DB
 *
 * Dependencies:
 *
 *      VDS_LOCATE
 *
 * Revision History:
 *      $Log: VDB_LOCATEi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:53  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/03/07  00:13:28  pinnacle
# Replaced: vdlocate/cmd/VDB_LOCATEi.I for:  by hverstee for vds.240
#
# Revision 1.3  1996/03/06  18:55:24  pinnacle
# Replaced: vdlocate/cmd/VDB_LOCATEi.I for:  by hverstee for vds.240
#
# Revision 1.1  1996/03/01  22:46:20  pinnacle
# Created: vdlocate/cmd/VDB_LOCATEi.I by hverstee for vds.240
#
 *
 * History:
 *      03/01/96        H.Versteeg      Creation Date.
 * -------------------------------------------------------------------------
 */

class implementation VDB_LOCATE;

#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "VDSris_def.h"
#include "VDSris_siz.h"
#include "VDSload.h"
#include "VDSserver.h"
#include "PDUuser.h"
#include "PDUerror.h"

#include "OMparameters.h"
#include "igrmacros.h"
#include "msdef.h"
#include "exdef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "exmacros.h"
#include "asmacros.h"
#include "AS_status.h"

method init ( int type ; char * str_ptr )
{
  IGRint          status;
  IGRint          stat1;
  IGRlong         sts;

  sts = OM_S_SUCCESS;

  status =
  om$send (mode     = OM_e_wrt_message,
           msg      = message CEO_LOCATE.init( type, str_ptr ),
           targetid = my_id);
  as$status();

/***       Does not work in all cases (init???)
  status =
  om$send (msg = message VDS_LOCATE.VDVerifyLogin (&sts),
      targetid = my_id);
 ***/

/*
  sts = VdsRisAttach();
*/

/*    so why does the function work?
      maybe verify project is the culprit... */

  if (VDSverify_login() != PDM_S_SUCCESS)

/*
  if (!(sts & OM_S_SUCCESS))
*/
  {    /*     NOT LOGGED IN, FORCE COMMAND TERMINATION    */

     UI_status("WARNING: Not logged into database");

     me->VDB_terminated = TRUE;
     me->state          = _terminate;
     stat1              = OM_I_STOP_SENDING;
  }
  else
  {
     me->VDB_terminated = FALSE;
     stat1              = OM_S_SUCCESS;
  }

  return (stat1);
}

end implementation VDB_LOCATE;

