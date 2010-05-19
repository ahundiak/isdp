
/* $Id: VDCmdTBX.S,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDCmdTBX.S
 *
 * Description:
 *
 * Specification file for attribute driven symbol table manager command
 *    edit/review -- supersedes VDTBXcmd.S
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdTBX.S,v $
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
# Revision 1.4  1995/09/05  23:00:30  pinnacle
# Replaced: vdtbl/cmd/VDCmdTBX.S for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/11  23:17:10  pinnacle
# Replaced: vdtbl/cmd/VDCmdTBX.S for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/13  20:16:26  pinnacle
# Replaced: vdtbl/cmd/VDCmdTBX.S for:  by hverstee for vds.240
#
# Revision 1.1  1995/07/06  15:12:54  pinnacle
# Created: vdtbl/cmd/VDCmdTBX.S by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/12/95          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VDCmdTBX (0:1) of CEO_LOCATE;

#include <stdio.h>
#include <string.h>

#include "igr.h"
#include "igrtypedef.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "growner.h"
#include "go.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "acmacros.h"
#include "asbox.h"
#include "ACattrib.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"
#include "exdef.h"
#include "exmacros.h"
#include "msmacros.h"
#include "vdbmacros.h"
#include "vdandef.h"

#include "vds.h"

#include "VDdrwlo.h"
#include "VDdrwlo_db.h"
#include "VDdrwlo_int.h"

#include "VDCmdTBX.h"

instance  VDCmdTBX
{
   IGRshort     My_Type;
   IGRint       My_localret;
   GRspacenum   My_OS;

   IGRchar      CUR_tabnam[VD_TBEX_NUM_CHSTR];
   IGRchar      CUR_filnam[VD_TBEX_NUM_CHSTR];

   struct GRid  Table_Id;
   struct GRid  Layout_Id;

   IGRchar     *Sepertab;

   /*       flags     */

   IGRboolean   bNumquote;
   IGRboolean   bTxtquote;

   IGRchar      szSeper[10];

   IGRshort     iNumTab;
   IGRshort     nNumTab;

   IGRchar     *TabDis;

   struct VD_id_name     *Table_Tab;

   /*       data arrays     */

   IGRshort               nNumEnt;
   variable
   struct VDTBX_data      Data[0];

   variable
   IGRshort               nSelect[0];
};


/*   load (activate) object   */
message  VDTBX_load         (IGRlong     * msg);

/*   general form display   */
message  VDTBX_disp (char    * form_ptr);

/*   startup commands   */
message  VDTBX_Start  ( long * sts );

/*   misc maintenance   */
message  VDTBX_Cleanup ( long * sts );
message  VDTBX_Exec    ( long * sts );
message  VDTBX_Reset   ( long * sts );
message  VDTBX_Rtc     ( long * sts );

message save_form_pos ( long * sts );
message set_form_pos  ( long * sts );

override   init;
override   form_notification;
override   delete;

end specification VDCmdTBX;

