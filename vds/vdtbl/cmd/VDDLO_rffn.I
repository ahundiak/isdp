
/* $Id: VDDLO_rffn.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDDLO_rffn.I
 *
 * Description:
 *
 * Implementation file for sub review fill form notification
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDLO_rffn.I,v $
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
# Revision 1.5  1995/09/25  22:58:56  pinnacle
# Replaced: vdtbl/cmd/VDDLO_rffn.I for:  by sundar for vds.240
#
# Revision 1.4  1995/08/14  22:43:26  pinnacle
# Replaced: vdtbl/cmd/VDDLO_rffn.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/11  23:33:10  pinnacle
# Replaced: vdtbl/cmd/VDDLO_rffn.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/06  16:06:04  pinnacle
# Replaced: vdtbl/cmd/VDDLO_rffn.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:21:22  pinnacle
# Created: vdtbl/cmd/* by tdumbach for vds.240
#
# Revision 1.3  1995/05/11  17:05:58  pinnacle
# Replaced: vdtbl/cmd/VDDLO_rffn.I by hverstee r#
#
# Revision 1.2  1995/05/08  20:35:18  pinnacle
# Replaced: vdtbl/cmd/VDDLO_rffn.I by hverstee r#
#
# Revision 1.1  1995/04/13  14:08:36  pinnacle
# Created: vdtbl/cmd/VDDLO_rffn.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/20/95          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VDCmdDLO;

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



method   VDDLO_rf_formnot  (int        gadget_label;
                            double     value;
                            char     * form_ptr)
{
  IGRint       status;
  IGRlong      retmsg;
  IGRint       nVal;

  status = OM_S_SUCCESS;

  nVal     = (value > 0) ? (value + 0.001) : (value - 0.001);

  FIg_set_text (form_ptr, VD_RLOF_FLD_MSG, "");

  me->My_localret = 0;

  switch (gadget_label)
  {
    case VD_RLOF_FLD_LINENUM:
      if ((nVal < 1) || (nVal > me->nMax_linenum))
      {
        FIg_set_text (form_ptr, VD_RLOF_FLD_MSG, VD_DLO_EMSG_PAR);
        break;
      }

      me->nCur_linenum = nVal;
      break;

    case VD_RLOF_BTN_DN:
      if (me->nCur_linenum > 1) me->nCur_linenum--;
      goto F_PROCESS;

    case VD_RLOF_BTN_UP:
      if (me->nCur_linenum < me->nMax_linenum) me->nCur_linenum++;

      F_PROCESS:
      status =
      om$send (msg = message VDdrwlo.VDdrwlo_xfld
                            (&retmsg, me->nCur_group, me->nCur_colnum, 
                              me->sCur_fieldid, me->nCur_linenum,
                             &me->nCur_fldrec),
          targetid = my_id);

      status =
      om$send (msg = message VDCmdDLO.VDDLO_disp (form_ptr),
          targetid = my_id);
      break;

    case FI_CANCEL:
      status =
      om$send (msg = message VDCmdDLO.save_form_pos
                            (&retmsg, me->My_actv_form, form_ptr),
          targetid = my_id);

      me->nCur_fldrec  = -1;
      me->nCur_linenum = 0;
      _put_response( resp = EX_FORM_FINISHED );
      break;

    default:
      break;
  }

  quit:
  return (status);
}

end implementation VDCmdDLO;

