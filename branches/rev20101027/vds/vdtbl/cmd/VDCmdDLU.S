
/* $Id: VDCmdDLU.S,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDCmdDLU.S
 *
 * Description:
 *
 * Specification file for drawing table layout utilities commands
 *    supersedes VDDLUcmd.S
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdDLU.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/27  04:43:54  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLU.S for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.6  1996/04/03  20:45:20  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLU.S for:  by hverstee for vds.240
#
# Revision 1.5  1995/09/06  18:42:42  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLU.S for:  by hverstee for vds.240
#
# Revision 1.4  1995/09/05  23:01:20  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLU.S for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/18  20:52:18  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLU.S for:  by hverstee for vds.240
#
# Revision 1.2  1995/08/11  23:17:32  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLU.S for:  by hverstee for vds.240
#
# Revision 1.1  1995/07/06  15:14:16  pinnacle
# Created: vdtbl/cmd/VDCmdDLU.S by hverstee for vds.240
#
# Revision 1.2  1995/06/19  19:42:40  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLU.S for:  by hverstee for vds.240
#
# Revision 1.2  1995/05/10  22:49:00  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLU.S by hverstee r#
#
# Revision 1.1  1995/04/29  16:48:18  pinnacle
# Created: vdtbl/cmd/VDCmdDLU.S by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/20/95          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VDCmdDLU (0:1) of VDdrwlo, VDSSC, VDcrexp, CEO_LOCATE;

#include <stdio.h>
#include <string.h>

#include "igr.h"
#include "igrtypedef.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"

#include "VDCmdDLU.h"

instance  VDCmdDLU
{
   IGRshort     My_Type;
   IGRshort     My_ParTyp;
   IGRshort     My_Delopt;

   IGRboolean   My_Localflag;
   IGRboolean   My_Dblogin;

   IGRint       My_localret;
   GRspacenum   My_OS;

   IGRchar      CUR_tabnam[VD_DRWLO_CHR_IDFLD];
   IGRchar      CUR_tabtyp[VD_DRWLO_CHR_IDFLD];

   IGRchar      CUR_userid[VD_DRWLO_CHR_IDFLD];
   IGRchar      CUR_dbowner[VD_DRWLO_CHR_IDFLD];

   /*  db index table name    */
   IGRchar      Db_Ixtab[40];

   /*  fixed lists          */

   IGRshort     nPARNams;
   IGRshort     nDELopt;

   IGRchar     *pPARNams;
   IGRchar     *pDELopt;

   /*    directory lists    */

   IGRchar     *pNamLoc;
   IGRchar     *pNamDB;
   IGRchar     *pNamBoth;

   IGRchar     *pDesDB;

   IGRchar     *pTypLoc;
   IGRchar     *pTypDB;
   IGRchar     *pTypBoth;

   IGRshort     nNamLoc;
   IGRshort     nNamDB;
   IGRshort     nNamBoth;

   IGRshort     nTypLoc;
   IGRshort     nTypDB;
   IGRshort     nTypBoth;

   IGRshort     nNamAll;
   IGRshort     nTypAll;

   struct  GRid    My_stored_lo;
};

/*   general form display   */
message  VDDLU_disp (char    * form_ptr);

/*   startup commands   */
message  VDDLU_Init  ( long * sts );
message  VDDLU_Start ( long * sts );

/*   misc maintenance   */
message  VDDLU_Cleanup ( long * sts );
message  VDDLU_Reset   ( long * sts );
message  VDDLU_Rtc     ( long * sts );
message  VDDLU_Load    ( long * sts );

message  VDDLU_Post   ( long    *sts;
                        IGRchar *szmsg;
                        IGRchar *szms1;
                        int      gadget_label);
message  VDDLU_Delete ( long    *sts;
                        IGRchar *szmsg;
                        IGRchar *szms1;
                        int      gadget_label);

message save_form_pos ( long * sts );
message set_form_pos  ( long * sts );

override   init;
override   form_notification;
override   delete;

end specification VDCmdDLU;

