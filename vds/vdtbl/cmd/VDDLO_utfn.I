
/* $Id: VDDLO_utfn.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDDLO_utfn.I
 *
 * Description:
 *
 * Implementation file for utilities form notification
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDLO_utfn.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
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
# Revision 1.4  1995/09/05  23:17:46  pinnacle
# Replaced: vdtbl/cmd/VDDLO_utfn.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/14  22:44:40  pinnacle
# Replaced: vdtbl/cmd/VDDLO_utfn.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/06  16:07:18  pinnacle
# Replaced: vdtbl/cmd/VDDLO_utfn.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:21:22  pinnacle
# Created: vdtbl/cmd/* by tdumbach for vds.240
#
# Revision 1.2  1995/05/11  17:03:58  pinnacle
# Replaced: vdtbl/cmd/VDDLO_utfn.I by hverstee r#
#
# Revision 1.1  1995/04/13  14:10:30  pinnacle
# Created: vdtbl/cmd/VDDLO_utfn.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/20/95          HV            New
 *
 * -------------------------------------------------------------------*/

/*     no longer needed, function is done by VDDLU* part    */

/*   dummy   */
class implementation VDCmdDLO;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "gr.h"

static  VDDLO_ut_dumm ()
{
  return (OM_E_ABORT);
}
end implementation VDCmdDLO;

