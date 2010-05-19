
/* $Id: VDDLO_over.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDDLO_over.I
 *
 * Description:
 *
 * Implementation file for main command object initialization
 *    CEO overrides
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDLO_over.I,v $
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
# Revision 1.11  1996/05/20  16:32:24  pinnacle
# Replaced: vdtbl/cmd/VDDLO_over.I for:  by hverstee for vds.240
#
# Revision 1.10  1995/12/05  12:38:58  pinnacle
# Replaced: vdtbl/cmd/VDDLO_over.I for:  by rgade for vds.240
#
# Revision 1.9  1995/09/25  22:58:42  pinnacle
# Replaced: vdtbl/cmd/VDDLO_over.I for:  by sundar for vds.240
#
# Revision 1.8  1995/09/22  14:07:04  pinnacle
# Replaced: vdtbl/cmd/VDDLO_over.I for:  by hverstee for vds.240
#
# Revision 1.7  1995/09/20  22:04:18  pinnacle
# Replaced: vdtbl/cmd/VDDLO_over.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/09/15  19:21:36  pinnacle
# Replaced: vdtbl/cmd/VDDLO_over.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/09/08  19:36:52  pinnacle
# Replaced: vdtbl/cmd/VDDLO_over.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/09/05  23:16:10  pinnacle
# Replaced: vdtbl/cmd/VDDLO_over.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/03  21:09:20  pinnacle
# Replaced: vdtbl/cmd/VDDLO_over.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/06  16:05:18  pinnacle
# Replaced: vdtbl/cmd/VDDLO_over.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:21:22  pinnacle
# Created: vdtbl/cmd/* by tdumbach for vds.240
#
# Revision 1.4  1995/05/18  14:12:56  pinnacle
# Replaced: vdtbl/cmd/VDDLO_over.I by hverstee r#
#
# Revision 1.3  1995/05/11  16:58:30  pinnacle
# Replaced: vdtbl/cmd/VDDLO_over.I by hverstee r#
#
# Revision 1.2  1995/05/08  20:38:26  pinnacle
# Replaced: vdtbl/cmd/VDDLO_over.I by hverstee r#
#
# Revision 1.1  1995/04/13  14:07:04  pinnacle
# Created: vdtbl/cmd/VDDLO_over.I by hverstee r#
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

#include <stdio.h>
#include <string.h>

#include "FI.h"
%safe
#include "VX_FIproto.h"
%endsafe
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grgsdef.h"
#include "grmessage.h"
#include "grgsmacros.h"
#include "OMmacros.h"
#include "exdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"
#include "asmacros.h"

#include "exmacros.h"

#include "msdef.h"
#include "msmacros.h"
#include "COBmacros.h"

#include "AS_status.h"

#include "VDdrwlo.h"
#include "VDdrwlo_db.h"
#include "VDdrwlo_int.h"

extern IGRboolean   VD_TBL_idquote (IGRchar   *szFld);

/*
#define   MY_DEBUG
*/



method init ( int type ; char * str_ptr )
{
  int             status;
  IGRlong         retmsg;

  /*A initialize superclass */

  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message CEO.init (type, str_ptr),
                    targetid = my_id);
  as$status (action = RET_STATUS);

  me->My_Type        = type;
  me->My_Preview_up  = FALSE;
  me->Pv_need_update = FALSE;
  me->My_Tracer_On   = FALSE;

  ex$get_cur_mod (osnum = &me->My_OS);

  if (me->My_Type == VD_DLO_CMD_EDIT)
    me->My_actv_form = VD_DLO_MAINFORM;
  else
    me->My_actv_form = VD_RLO_MAINFORM;

      /*    initialize edit/review    */

  status =
  om$send (msg = message VDCmdDLO.VDDLO_init (&retmsg),
      targetid = my_id);

  return (status);
}



method form_notification ( int         form_label ;
                           int         gadget_label ;
                           double      value ;
                           char      * form_ptr )
{
  int        status = OM_S_SUCCESS;
  int        iType;

  IGRdouble  dLocVal;

#ifdef MY_DEBUG
  printf (" FORMNOT %d vs %d\n",form_label, me->My_actv_form);
#endif

  me->iarow = me->iapos = -1;

  me->My_Focus = 0;

  if (form_label != me->My_actv_form) goto quit;

  FIfld_get_type (form_ptr, gadget_label, 0, &iType);
  if (iType != FI_ALPHA)
    FIg_get_value (form_ptr, gadget_label, &dLocVal);
  else
    dLocVal = 0.0;

  /*     hidden debug    */

  if (gadget_label == VD_DLO_GDG_ONOFF)
    me->My_Tracer_On = !me->My_Tracer_On;

  if (me->My_Tracer_On && (gadget_label == VD_DLO_GDG_REPORT))
  {
    long     sts;

    status =
    om$send (msg = message VDCmdDLO.VDDLO_Report (&sts),
        targetid = my_id);

    goto quit;
  }

#ifdef MY_DEBUG
  if (me->ppFile != NULL)
  {
    IGRchar     szfld[VD_DRWLO_CHR_BUFFER];

    FIg_get_text (form_ptr, gadget_label, szfld);

    fprintf (me->ppFile, "TRACE gadget %6d string <%20s> value %10f\n",
                         gadget_label, szfld, dLocVal);

    fflush  (me->ppFile);
  }
#endif

  me->Pv_need_update = FALSE;

#ifdef MY_DEBUG
  printf (" FORMNOT value %f\n",dLocVal);
#endif

  switch (form_label)
  {
    case VD_DLO_MAINFORM:
      status =
      om$send (msg = message VDCmdDLO.VDDLO_ed_formnot
                                         (gadget_label, dLocVal, form_ptr),
          targetid = my_id);
      break;

    case VD_DLO_FILLFORM:
      status =
      om$send (msg = message VDCmdDLO.VDDLO_fl_formnot
                                         (gadget_label, dLocVal, form_ptr),
          targetid = my_id);
#ifdef MY_DEBUG
  printf (" Back from fl_formnot\n");
#endif
      break;

    case VD_RLO_MAINFORM:
      status =
      om$send (msg = message VDCmdDLO.VDDLO_rv_formnot
                                         (gadget_label, dLocVal, form_ptr),
          targetid = my_id);
      break;

    case VD_RLO_FILLFORM:
      status =
      om$send (msg = message VDCmdDLO.VDDLO_rf_formnot
                                         (gadget_label, dLocVal, form_ptr),
          targetid = my_id);
      break;

    default:
      status = OM_S_SUCCESS;
      break;
  }

  quit:
#ifdef MY_DEBUG
  printf (" EXIT FORM NOTIFICATION\n");
#endif

  return (status);
}

method delete (int   f_defer_flag)
{
  IGRint      status;
  long        sts;

  /*   redirect to cleanup    */

  status =
  om$send (msg = message VDCmdDLO.VDDLO_Cleanup (&sts),
      targetid = my_id);

  return (OM_S_SUCCESS);
}

method sleep( int position )
{
  IGRint status = OM_S_SUCCESS;

  status = om$send( msg = message CEO_LOCATE.sleep( position ),
			mode = OM_e_wrt_message,
			targetid = my_id );
  as$status();

  if(  me->My_actv_form == VD_DLO_MAINFORM )
  {
	SMVA_disable( me->forms[me->My_actv_form].form_ptr, 22, 7, 9, 16, 17, 
				21, 24, 26, 27, 34, 38, 40, 41, 42, 43, 59, 63,
				69, 70, 81, 131, 147, 163 );
  }
  else if ( me->My_actv_form == VD_DLO_FILLFORM )
  {
        SMVA_disable( me->forms[me->My_actv_form].form_ptr, 15, 7, 9, 14, 18,
			20, 21, 170, 171, 174, 175, 176, 178, 179, 183, 184 );
  }
  else if ( me->My_actv_form == VD_RLO_FILLFORM )
  {
        SMVA_disable( me->forms[me->My_actv_form].form_ptr, 14, 7, 9, 14, 18,
			20, 170, 171, 174, 175, 176, 178, 179, 183, 184 );
  }
  else if(  me->My_actv_form == VD_RLO_MAINFORM )
  {
	SMVA_disable( me->forms[me->My_actv_form].form_ptr, 17, 7, 9, 16, 17, 
			21, 24, 26, 27, 34, 40, 42, 43, 59, 81, 131, 163 );
  }

  return (status);
}

method wakeup( int position )
{
  IGRint status = OM_S_SUCCESS;

  status = om$send( msg = message CEO_LOCATE.wakeup( position ),
			mode = OM_e_wrt_message,
			targetid = my_id );
  as$status();

  if(  me->My_actv_form == VD_DLO_MAINFORM )
  {
	SMVA_enable( me->forms[me->My_actv_form].form_ptr, 22, 7, 9, 16, 17, 
				21, 24, 26, 27, 34, 38, 40, 41, 42, 43, 59, 63,
				69, 70, 81, 131, 147, 163 );
  }
  else if ( me->My_actv_form == VD_DLO_FILLFORM )
  {
        SMVA_enable( me->forms[me->My_actv_form].form_ptr, 15, 7, 9, 14, 18,
			20, 21, 170, 171, 174, 175, 176, 178, 179, 183, 184 );
  }
  else if ( me->My_actv_form == VD_RLO_FILLFORM )
  {
        SMVA_enable( me->forms[me->My_actv_form].form_ptr, 14, 7, 9, 14, 18,
			20, 170, 171, 174, 175, 176, 178, 179, 183, 184 );
  }
  else if(  me->My_actv_form == VD_RLO_MAINFORM )
  {
	SMVA_enable( me->forms[me->My_actv_form].form_ptr, 17, 7, 9, 16, 17, 
			21, 24, 26, 27, 34, 40, 42, 43, 59, 81, 131, 163 );
  }

  return (status);
}

method VDGetRetCode (long    *retcode)
{

  *retcode = me->My_localret;

  return OM_S_SUCCESS;
}

IGRboolean   VD_TBL_idquote (IGRchar   *szFld)

{
  IGRint      i;
  IGRboolean  bVal;

  i    = 0;
  bVal = FALSE;

  while (szFld[i] != '\0')
  {
    if (szFld[i] == '\'')
    {
      bVal = TRUE;
      break;
    }

    i++;
  }

  return (bVal);
}

end implementation VDCmdDLO;
