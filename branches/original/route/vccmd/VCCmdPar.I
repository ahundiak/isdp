
/* $Id: VCCmdPar.I,v 1.1.1.1 2001/01/04 21:12:28 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCCmdPar.I
 *
 * Description:
 *      Implementation file for command objects that display and
 *      edit attributes.
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCCmdPar.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *  Initial import to CVS
 *
# Revision 1.2  1998/12/22  17:02:28  pinnacle
# Replaced: vccmd/VCCmdPar.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.11  1997/07/22  16:04:50  pinnacle
# Replaced: vccmd/VCCmdPar.I for:  by hverstee for cabling
#
# Revision 1.10  1997/07/14  22:53:02  pinnacle
# Replaced: vccmd/VCCmdPar.I for:  by hverstee for cabling
#
# Revision 1.9  1997/05/22  14:45:22  pinnacle
# Replaced: vccmd/VCCmdPar.I for:  by hverstee for cabling
#
# Revision 1.8  1997/05/19  14:07:02  pinnacle
# Replaced: vccmd/VCCmdPar.I for:  by hverstee for cabling
#
# Revision 1.7  1997/03/12  21:59:34  pinnacle
# Replaced: vccmd/VCCmdPar.I for:  by hverstee for cabling
#
# Revision 1.6  1997/01/09  20:01:06  pinnacle
# Replaced: vccmd/VCCmdPar.I for:  by hverstee for cabling
#
# Revision 1.4  1996/12/18  17:48:40  pinnacle
# Replaced: vccmd/VCCmdPar.I for:  by hverstee for cabling
#
# Revision 1.3  1996/10/09  22:02:00  pinnacle
# Replaced: vccmd/VCCmdPar.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/08  21:59:42  pinnacle
# Replaced: vccmd/VCCmdPar.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:17:18  pinnacle
# Created: vccmd/VCCmdPar.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *  12/02/98      law     CR179802404 - rotation given by form field
 *
 *************************************************************************/

class implementation VCCmdParam;

#include "OMparameters.h"
#include "igrmacros.h"
#include "msdef.h"
#include "exdef.h"
#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include "exmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "FI.h"
#include "FEI.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "VCCmdForm.h"

#include "VDmem.h"

from  GRgraphics    import   GRdelete;
from  VCRoot        import   VCGetSysPar;
from  VCRoot        import   VCGetUsrPar;
from  ACrg_collect  import   ACset_list_attribute;

%safe
#include "VX_FIproto.h"
%endsafe

/*
#define MY_DEBUG
*/


/**********************************************************/

method VCCmdRetCode  ( int * sts)
{

  me->ret = *sts = me->My_localret;

  return (OM_S_SUCCESS);
}

/**********************************************************/

method  VCCmdCleanup (int * sts)
{
  int      status;
  IGRlong  retcode;

  *sts = VC_RTC_ALLOK;

  /*   save form position     */

  if (me->ConstrId.objid != NULL_OBJID)
  {
#ifdef MY_DEBUG
    printf (" CLEANUP, delete <%d %d> !!!!!\n",me->ConstrId.objid,
                                               me->ConstrId.osnum) ;
#endif

    status =
    om$send (msg = message GRgraphics.GRdelete  (&retcode, &me->ModuleInfo),
        targetid = me->ConstrId.objid,
        targetos = me->ConstrId.osnum) ;
  }

  /*     make sure all forms are closed    */

  if (me->pSysAtt)
    status = VC_Cmd_form_close (me->pSysAtt, me->FCmain);

  if (me->pUsrAtt)
    status = VC_Cmd_form_close (me->pUsrAtt, me->FCsub);

  me->bSysUp = me->bUsrUp = FALSE;

  if (me->pCtlAtt)
    status = VC_Cmd_form_close (me->pCtlAtt, me->FCcontrol);

  _FREE (me->CClist);
  _FREE (me->CCdesc);
  me->nCC   = 0;

  status =
  om$send(  msg = message VDS_LOCATE.delete ( 0 ) ,
           mode = OM_e_wrt_message,
       targetid = my_id);

  return (OM_S_SUCCESS);
}

/**********************************************************/

method delete ( int f_defer_flag )

{
  int      status;
  int      sts;

  /* Block and be sure to do cleanup    */

  status =
  om$send (msg = message VCCmdParam.VCCmdCleanup (&sts),
      targetid = my_id);

  return status;

}/* end delete */

/**********************************************************/

method init ( int type ; char * str_ptr )
{
  int      status;
  int      ret;

  status =
  om$send (msg = message VCAT.init (type, str_ptr),
        mode   = OM_e_wrt_message,
      targetid = my_id);

  me->My_localret    = 0;
  me->CommGadget     = 0;
  me->bGdcode        = FALSE;

  me->bTERM          = FALSE;

  VC_INITSTR(me->CompCode);
  VC_INITSTR(me->CompDesc);
  VC_INITSTR(me->szMsg);

  me->CClist      = NULL;
  me->CCdesc      = NULL;
  me->nCC         = 0;

  me->RefId.objid    = NULL_OBJID;
  me->ConstrId.objid = NULL_OBJID;

  /*   do custom startup    */
  status =
  om$send (msg = message VCCmdParam.VCCmdStart (&ret),
      targetid = my_id);

  /*   and display the initial form   */

  if (me->iSynType != VC_CMDTYP_MISC1)
  {
    me->Actv_Form = VC_FRM_MAIN;

    status = VC_Cmd_form_open (me->pSysAtt, me->FCmain);
    me->bSysUp = TRUE;
  }

  return OM_S_SUCCESS;
}

/**********************************************************/

method  VCCmdDisp (int * sts;
                   int   nForm)
{
  IGRlong  retmsg;
  int      status;

  status = OM_S_SUCCESS;
  *sts = VC_RTC_ALLOK;

  if (nForm == VC_FRM_MAIN)
  {
    FIg_set_text (me->pSysAtt, VC_GDG_FLD_COMPCODE, me->CompCode);
    FIg_set_text (me->pSysAtt, VC_GDG_FLD_SDESC,    me->CompDesc);

    FIg_set_text (me->pSysAtt, VC_GDG_FLD_TAGNUMBER, me->TagNum);

    status =
    om$send (msg = message VCAT.VCAT_sdsp (&retmsg, me->pSysAtt),
        targetid = my_id);

    FIg_set_value (me->pSysAtt, VC_GDG_FLD_DIAMETER, me->dDiameter);

    FIg_set_value (me->pSysAtt, VC_GDG_CHK_NOMTO, me->bMTO);

    FIg_set_state_off (me->pSysAtt, VC_GDG_BTN_LOADATT);
    FIg_set_state_off (me->pSysAtt, VC_GDG_BTN_USRPAR);

#ifdef MY_DEBUG
    printf (" redisplay main\n");
#endif
  }
  else
  {
    status =
    om$send (msg = message VCAT.VCAT_udsp (&retmsg, me->pUsrAtt),
        targetid = my_id);

    FIg_set_state_off (me->pUsrAtt, FI_RESET);

#ifdef MY_DEBUG
    printf (" redisplay sub \n");
#endif
  }

  return OM_S_SUCCESS;
}

/**********************************************************/

method VCCmdGetRef (int * sts)
{
  GRclassid         loccl;

  struct  GRid      Locid;

  *sts = VC_RTC_ALLOK;

  Locid = me->event1.located_object[0].located_obj;

  om$get_classid (objid = Locid.objid,
                  osnum = Locid.osnum,
              p_classid = &loccl);

  if (om$is_ancestry_valid
            (subclassid = loccl,
           superclassid = OPP_VCRoot_class_id ) & OM_S_SUCCESS)
  {
    me->RefId = Locid;
  }
  else
  {
    *sts = VC_RTC_ERROR;
  }

  return (OM_S_SUCCESS);
}

/**********************************************************/

method VCCmdReset ( int * sts )
{
  IGRlong     retmsg;
  IGRint      status;
  IGRint      i, idsp;
  int         Selflag;

  Selflag  = 0;

  status =
  om$send (msg = message VCAT.VCAT_act (&retmsg),
      targetid = my_id);

  FIg_display (me->pSysAtt, me->CommGadget);

  if (me->CommGadget == VC_GDG_CMD_GUIDE)
    FIg_display (me->pSysAtt, VC_GDG_TGG_NOCODE);

  if (me->CommGadget == VC_GDG_CMD_BKSH)
  {
    FIg_erase   (me->pSysAtt, VC_GDG_TXT_TAGNUMBER);
    FIg_erase   (me->pSysAtt, VC_GDG_FLD_TAGNUMBER);
  }

  if (bVC_IS_PID(me->nACTrep))
  {
    FIg_display (me->pSysAtt, VC_GDG_TXT_SCALE);
    FIg_display (me->pSysAtt, VC_GDG_FLD_SCALE);
  }
  /* Added for TR179802404 - rotation of terminal/connector */
  if ((me->CommGadget == VC_GDG_CMD_BKSH) ||
			 (me->CommGadget == VC_GDG_CMD_GENTERM))
  {
    FIg_display (me->pSysAtt, VCFORM_GDG_AROT);
    FIg_display (me->pSysAtt, VCFORM_GDG_AROTLBL);
    FIg_set_value(me->pSysAtt, VCFORM_GDG_AROT, 0.0);
  }

  FIfld_set_list_num_rows (me->pSysAtt, VC_GDG_FLD_COMPCODE, 0, (int) me->nCC);

  if (me->nCC > 10)
    FIfld_set_list_scroll (me->pSysAtt, VC_GDG_FLD_COMPCODE, 1, 0);
  else
    FIfld_set_list_scroll (me->pSysAtt, VC_GDG_FLD_COMPCODE, 0, 0);

  for (i=0; i<me->nCC; i++)
  {
    idsp = i * VC_MAX_CCODE;

    VDfld_set_list_text (me->pSysAtt, VC_GDG_FLD_COMPCODE , i, 0,
                                   &me->CClist[idsp], Selflag);
  }

  status =
  om$send (msg = message VCCmdParam.VCCmdDisp (sts, VC_FRM_MAIN),
      targetid = my_id);

  return (OM_S_SUCCESS);
}

/**********************************************************/

method VCCmdLoadAtt (int * sts)
{
  IGRlong   retmsg;
  IGRint    status;

  struct    GRid     LDid;

  *sts = VC_RTC_ALLOK;

  LDid = me->event1.located_object[0].located_obj;

#ifdef MY_DEBUG
  printf ("load att from <%d %d>\n",LDid.objid, LDid.osnum);
#endif

  status =
  om$send (msg = message VCAT.VCAT_load (&retmsg, &LDid),
      targetid = my_id);

  status =
  om$send (msg = message VCCmdParam.VCCmdDisp (sts, VC_FRM_MAIN),
      targetid = my_id);

  status =
  om$send (msg = message VCCmdParam.VCCmdDisp (sts, VC_FRM_SUB),
      targetid = my_id);

  return OM_S_SUCCESS;
}

/**********************************************************/

method VCCmdInit  ( int * sts )
{

  *sts = VC_RTC_ERROR;           /*  must be overridden  */

  return (OM_S_SUCCESS);
}

/**********************************************************/

method VCCmdStart ( int * sts )
{

  *sts = VC_RTC_ERROR;           /*  must be overridden  */

  return (OM_S_SUCCESS);
}

/**********************************************************/

method VCCmdInsert  (int * sts)
{

  *sts = VC_RTC_ERROR;           /*  must be overridden  */

  return (OM_S_SUCCESS);
}

/**********************************************************/

end implementation VCCmdParam;

