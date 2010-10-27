
/* $Id: VDTBX_disp.I,v 1.3 2001/08/16 21:40:14 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDTBX_disp.I
 *
 * Description:
 *
 * Main form display for table to ascii file export command
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDTBX_disp.I,v $
 *      Revision 1.3  2001/08/16 21:40:14  ylong
 *      Added export xml functionality
 *
 *      Revision 1.2  2001/02/22 22:23:47  ylong
 *      TR4657 and TR4702
 *
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
# Revision 1.4  1995/09/25  23:02:06  pinnacle
# Replaced: vdtbl/cmd/VDTBX_disp.I for:  by sundar for vds.240
#
# Revision 1.3  1995/08/11  23:38:34  pinnacle
# Replaced: vdtbl/cmd/VDTBX_disp.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/11  21:55:20  pinnacle
# Replaced: vdtbl/cmd/VDTBX_disp.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/07/06  16:23:42  pinnacle
# Created: vdtbl/cmd/VDTBX_disp.I by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/30/95          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VDCmdTBX;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "gr.h"
#include "FI.h"
%safe
#include "VX_FIproto.h"
%endsafe
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"

/*
#define  MY_DEBUG
*/



method   VDTBX_disp (char    * form_ptr)

{
  int        i;
  int        jcolor;

#ifdef MY_DEBUG
  printf (" TBX display\n");
#endif

  /*    display header   */

  FIg_set_text (form_ptr, VD_TBEX_FLD_TABNAM, me->CUR_tabnam);
  FIg_set_text (form_ptr, VD_TBEX_FLD_FILNAM, me->CUR_filnam);

  FIg_set_text (form_ptr, VD_TBEX_FLD_SEPER, me->szSeper);

  FIg_set_value (form_ptr, VD_TBEX_CHK_NUM, me->bNumquote);
  FIg_set_value (form_ptr, VD_TBEX_CHK_STR, me->bTxtquote);

  /*    display data   */

  FIfld_set_max_num_rows (form_ptr, VD_TBEX_FLD_DATA,
                                                 (int)me->nNumEnt);
  FIfld_set_num_rows (form_ptr, VD_TBEX_FLD_DATA,
                                                 (int)me->nNumEnt);
/*
  FIfld_set_list_num_rows (form_ptr, VD_TBEX_FLD_DATA, 0,
                                                 (int)me->nNumEnt);
*/

  for (i=0; i< me->nNumEnt; i++)
  {
    FIfld_set_value (form_ptr, VD_TBEX_FLD_DATA, i, 0,
                        (double) me->Data[i].colno, FALSE);
    FIfld_set_value (form_ptr, VD_TBEX_FLD_DATA, i, 1,
                        (double) me->Data[i].linno, FALSE);
    FIfld_set_text  (form_ptr, VD_TBEX_FLD_DATA, i, 2,
                         me->Data[i].desc, FALSE);

    jcolor = (me->nSelect[i] != 0) ? FI_RED : -1;

    FIfld_set_line_color (form_ptr, VD_TBEX_FLD_DATA, i, 0, jcolor);
    FIfld_set_line_color (form_ptr, VD_TBEX_FLD_DATA, i, 1, jcolor);
    FIfld_set_line_color (form_ptr, VD_TBEX_FLD_DATA, i, 2, jcolor);

    FImcf_set_select (form_ptr, VD_TBEX_FLD_DATA, i, me->nSelect[i]);
  }

#ifdef MY_DEBUG
  printf ("display done.....\n");
#endif

  return (OM_S_SUCCESS);
}

end implementation VDCmdTBX;

