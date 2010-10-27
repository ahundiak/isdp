 
/* $Id: VDCmdADS.S,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDCmdADS.S
 *
 * Description:
 *
 * Specification file for attribute driven symbol table manager command
 *    edit/review -- supersedes VDADScmd.S
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdADS.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:25  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/27  06:19:58  pinnacle
# Replaced: vdtbl/cmd/VDCmdADS.S for:  by vgnair for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/09/05  23:01:42  pinnacle
# Replaced: vdtbl/cmd/VDCmdADS.S for:  by hverstee for vds.240
#
# Revision 1.2  1995/08/11  23:16:26  pinnacle
# Replaced: vdtbl/cmd/VDCmdADS.S for:  by hverstee for vds.240
#
# Revision 1.1  1995/07/06  15:14:44  pinnacle
# Created: vdtbl/cmd/VDCmdADS.S by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/12/95          HV            New
 * 	11/27/97	  vini 		added instance field 'flag'
 *
 * -------------------------------------------------------------------*/

class specification VDCmdADS (0:1) of VDADS, CEO_LOCATE;

#include <stdio.h>
#include <string.h>

#include "igr.h"
#include "igrtypedef.h"

#include "VDCmdADS.h"

#include "grsymmacros.h"


instance  VDCmdADS
{
   IGRshort     My_Type;
   IGRint       My_localret;
   GRspacenum   My_OS;

   IGRchar      CUR_tabnam[VD_DRWLO_CHR_IDFLD];

   struct  GRid    My_stored_lo;

   /*       display lists   */

   IGRshort     nTabNams;
   IGRchar     *pTabNams;

   IGRshort     nNumComp;
   IGRchar     *pCompar;

   IGRshort     nFonts;
   IGRchar     *pr_fonts;
   /*       indexing        */

   IGRshort     nCurSym;
   IGRshort     nMaxSym;

   /*       default         */

   struct  VDadsym_rec     defrec;

/*	cell / symbol 	*/
int		flag;

};


/*   load (activate) object   */
message  VDADS_load         (IGRlong     * msg;
                      struct GRid        * LoGrid);

/*   general form display   */
message  VDADS_disp (char    * form_ptr);

/*   startup commands   */
message  VDADS_StEdit ( long * sts );
message  VDADS_StRev  ( long * sts );

/*   misc maintenance   */
message  VDADS_Cleanup ( long * sts );
message  VDADS_Save    ( long * sts );
message  VDADS_Reset   ( long * sts );
message  VDADS_Rtc     ( long * sts );

message save_form_pos ( long * sts );
message set_form_pos  ( long * sts );

override   init;
override   form_notification;
override   delete;

end specification VDCmdADS;

