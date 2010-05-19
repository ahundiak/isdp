
/* $Id: VDDLU_cmdi.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDDLU_cmdi.I
 *
 * Description:
 *
 * Implementation file for VDDLU command object initialization/reset
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDLU_cmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/21  04:28:18  pinnacle
# Replaced: vdtbl/cmd/VDDLU_cmdi.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.8  1995/09/25  22:59:40  pinnacle
# Replaced: vdtbl/cmd/VDDLU_cmdi.I for:  by sundar for vds.240
#
# Revision 1.7  1995/09/05  23:15:48  pinnacle
# Replaced: vdtbl/cmd/VDDLU_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/08/18  20:59:38  pinnacle
# Replaced: vdtbl/cmd/VDDLU_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/08/15  23:50:34  pinnacle
# Replaced: vdtbl/cmd/VDDLU_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/11  23:38:58  pinnacle
# Replaced: vdtbl/cmd/VDDLU_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/06  16:12:06  pinnacle
# Replaced: vdtbl/cmd/VDDLU_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  20:02:48  pinnacle
# Replaced: vdtbl/cmd/VDDLU_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/05/11  17:03:22  pinnacle
# Replaced: vdtbl/cmd/VDDLU_cmdi.I by hverstee r#
#
# Revision 1.1  1995/04/29  17:03:34  pinnacle
# Created: vdtbl/cmd/VDDLU_cmdi.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/20/95          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VDCmdDLU;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "gr.h"
#include "FI.h"
%safe
#include "VX_FIproto.h"
%endsafe
#include "ASmatrix.h"

#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"

#include "VDdrwlo_pr.h"

// #define vdsDEBUG        1
#include "v_dbgmacros.h"

%safe
  static int x1_pos = -1,y1_pos = -1;
  static int x2_pos = -1,y2_pos = -1;
%endsafe



method save_form_pos ( long * sts )
{

  SetProc( VDCmdDLU.save_form_pos ); Begin

  if (me->My_Type == VD_DLU_CMD_DELETE)
    FIf_get_location(me->forms[0].form_ptr,&x1_pos,&y1_pos);
  else
    FIf_get_location(me->forms[0].form_ptr,&x2_pos,&y2_pos);

  *sts = MSSUCC;

  End
  return OM_S_SUCCESS;
}

method set_form_pos ( long * sts )
{
  SetProc( VDCmdDLU.set_form_pos ); Begin

  if (me->My_Type == VD_DLU_CMD_DELETE)
  {
    if(x1_pos != -1 && y1_pos != -1)
      FIf_set_location ( me->forms[0].form_ptr, x1_pos, y1_pos );
  }
  else
  {
    if(x2_pos != -1 && y2_pos != -1)
      FIf_set_location ( me->forms[0].form_ptr, x2_pos, y2_pos );
  }

  *sts = MSSUCC;

  End
  return OM_S_SUCCESS;
}

method init ( int type ; char * str_ptr )
{
  int             status;

  /*A initialize superclass */

  SetProc( VDCmdDLU.init ); Begin

  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message CEO.init (type, str_ptr),
                    targetid = my_id);
  as$status (action = RET_STATUS);

  me->My_Type       = type;

  ex$get_cur_mod (osnum = &me->My_OS);

  me->nPARNams      = 0;
  me->nDELopt       = 0;

  me->pPARNams      = NULL;
  me->pDELopt       = NULL;

  me->nNamAll       = 0;
  me->nNamLoc       = 0;
  me->nNamDB        = 0;
  me->nNamBoth      = 0;

  me->nTypAll       = 0;
  me->nTypLoc       = 0;
  me->nTypDB        = 0;
  me->nTypBoth      = 0;

  me->pNamBoth      = NULL;
  me->pNamLoc       = NULL;
  me->pNamDB        = NULL;

  me->pDesDB        = NULL;

  me->pTypBoth      = NULL;
  me->pTypLoc       = NULL;
  me->pTypDB        = NULL;

  End
  return (OM_S_SUCCESS);
}


method delete (int   f_defer_flag)
{
  IGRint      status;
  long        sts;

  SetProc( VDCmdDLU.delete ); Begin

  status =
  om$send (msg = message VDCmdDLU.VDDLU_Cleanup (&sts),
      targetid = my_id);

  End
  return (OM_S_SUCCESS);
}


method VDDLU_Rtc (long    *retcode)
{

  SetProc( VDCmdDLU.VDDLU_Rtc ); Begin
  *retcode = me->My_localret;

  End
  return OM_S_SUCCESS;
}

end implementation VDCmdDLU;

