
/* $Id: VDDLU_start.I,v 1.2 2001/01/26 22:52:05 ad Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDDLU_start.I
 *
 * Description:
 *
 * Implementation file for form startup messages
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDLU_start.I,v $
 *      Revision 1.2  2001/01/26 22:52:05  ad
 *      *** empty log message ***
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/03/23  22:33:38  pinnacle
# Replaced: vdtbl/cmd/VDDLU_start.I for:  by mdong for vds
#
# Revision 1.3  1998/01/27  20:08:50  pinnacle
# Replaced: vdtbl/cmd/VDDLU_start.I for:  by azuurhou for
#
# Revision 1.2  1997/10/21  04:43:22  pinnacle
# Replaced: vdtbl/cmd/VDDLU_start.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.14  1996/04/12  19:50:30  pinnacle
# Replaced: vdtbl/cmd/VDDLU_start.I for:  by hverstee for vds.240
#
# Revision 1.12  1995/11/29  13:56:54  pinnacle
# Replaced: ./vdtbl/cmd/VDDLU_start.I for:  by ksundar for vds.240
#
# Revision 1.11  1995/09/25  23:00:22  pinnacle
# Replaced: vdtbl/cmd/VDDLU_start.I for:  by sundar for vds.240
#
# Revision 1.10  1995/09/25  13:08:22  pinnacle
# Replaced: vdtbl/cmd/VDDLU_start.I for:  by hverstee for vds.240
#
# Revision 1.9  1995/09/11  22:53:22  pinnacle
# Replaced: vdtbl/cmd/VDDLU_start.I for:  by hverstee for vds.240
#
# Revision 1.8  1995/09/08  23:29:56  pinnacle
# Replaced: vdtbl/cmd/VDDLU_start.I for:  by hverstee for vds.240
#
# Revision 1.7  1995/09/06  18:42:54  pinnacle
# Replaced: vdtbl/cmd/VDDLU_start.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/09/05  23:13:20  pinnacle
# Replaced: vdtbl/cmd/VDDLU_start.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/08/18  21:00:50  pinnacle
# Replaced: vdtbl/cmd/VDDLU_start.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/15  23:53:04  pinnacle
# Replaced: vdtbl/cmd/VDDLU_start.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/06  16:13:40  pinnacle
# Replaced: vdtbl/cmd/VDDLU_start.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  20:02:22  pinnacle
# Replaced: vdtbl/cmd/VDDLU_start.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/05/11  17:01:26  pinnacle
# Replaced: vdtbl/cmd/VDDLU_start.I by hverstee r#
#
# Revision 1.1  1995/04/29  17:05:30  pinnacle
# Created: vdtbl/cmd/VDDLU_start.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/20/95          HV            New
 *	10/20/97        Sundar          Modified for expression table
 *      03/23/98         Ming           TR179800724 && TR179800499
 *      01/19/01        ylong           ETL4898, not assigned TR# yet
 * -------------------------------------------------------------------*/

class implementation VDCmdDLU;

#include <stdio.h>
#include <string.h>

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
#include "PDUerror.h"

#include "FI.h"
%safe
#include "VX_FIproto.h"
%endsafe
#include "AS_status.h"

#include "VDdrwlo.h"
#include "VDdrwlo_db.h"
#include "VDdrwlo_int.h"
#include "VDDbDef.h"

#include "vdtblmacros.h"
#include "VDmem.h"

// #define vdsDEBUG        1
#include "v_dbgmacros.h"

/*
#define   MY_DEBUG
*/



method  VDDLU_Start ( long * sts )
{
  int         status;
  long        retmsg;
  int         i, idsp;
  int         SelFlag;
  IGRchar    *form_ptr;

  SetProc( VDCmdDLU.VDDLU_Start ); Begin

  *sts     = MSSUCC;
  SelFlag  = FALSE;
  form_ptr = me->forms[0].form_ptr;

#ifdef MY_DEBUG
  printf (" start\n");
#endif

  status = VD_DLO_SetIndx (me->CUR_userid, NULL, NULL, NULL);

  me->CUR_dbowner[0] = '\0';

  status =
  om$send (msg = message VDCmdDLU.VDDLU_Reset (&retmsg),
      targetid = my_id);

  /*  (re)fill the predefined lists */


  FIfld_set_list_num_rows (form_ptr, VD_DLU_FLD_PARAM, 0, me->nPARNams);
  FIfld_set_list_scroll   (form_ptr, VD_DLU_FLD_PARAM, 0, 0);

  for (i=0; i<me->nPARNams; i++)
  {
    idsp = i * VD_DLU_PAR_LENGTH;
    VDfld_set_list_text (form_ptr, VD_DLU_FLD_PARAM, i, 0,
                           &me->pPARNams[idsp], SelFlag);
  }

  FIfld_set_list_num_rows (form_ptr, VD_DLU_FLD_DELOPT, 0, me->nDELopt);
  FIfld_set_list_scroll   (form_ptr, VD_DLU_FLD_DELOPT, 0, 0);

  for (i=0; i<me->nDELopt; i++)
  {
    idsp = i * VD_DRWLO_CHR_IDFLD;
    VDfld_set_list_text (form_ptr, VD_DLU_FLD_DELOPT, i, 0,
                           &me->pDELopt[idsp], SelFlag);
  }

  /*    adapt form    */

  if (me->My_Type == VD_DLU_CMD_DELETE)
  {
    FIg_display (form_ptr, VD_DLU_TXT_DELETE);
    FIg_display (form_ptr, VD_DLU_TXT_DELOPT);
    FIg_display (form_ptr, VD_DLU_FLD_DELOPT);
  }
  else
  {
    FIg_display (form_ptr, VD_DLU_TXT_POST);
    FIg_erase   (form_ptr, VD_DLU_TXT_DELOPT);
    FIg_erase   (form_ptr, VD_DLU_FLD_DELOPT);
  }

  status =
  om$send (msg = message VDCmdDLU.VDDLU_Load (&retmsg),
      targetid = my_id);

  status =
  om$send (msg = message VDCmdDLU.VDDLU_disp (form_ptr),
      targetid = my_id);

  End
  return (OM_S_SUCCESS);
}


method  VDDLU_Init (long  *sts)

{
  IGRint          status;
  IGRlong         retmsg;
  IGRshort        iLL;
  char          * form_ptr;

  extern int VDSverify_login();
  extern int VdsVerifyRisTable();

  SetProc( VDCmdDLU.VDDLU_Init ); Begin

  *sts = MSSUCC;

  me->My_ParTyp     = VD_DLU_PAR_NONE;
  me->My_Delopt     = VD_DLU_DST_LOCAL;
  me->Db_Ixtab[0]   = '\0';

  /*  check if we're logged into the DB    */

  me->My_Dblogin = (VDSverify_login() == PDM_S_SUCCESS);

  if ((me->My_Type == VD_DLU_CMD_POST) && (!me->My_Dblogin))
  {  /*  terminate for post and no DB   */
      UI_status (VD_DLU_EMSG_NODB);
      _put_response( resp = TERMINATE);
      goto quit;
  }

  if (me->My_Dblogin)
    me->My_Dblogin = (VdsVerifyRisTable(VDCREXP_NAM_TAB) == VDS_DBTABLE_FOUND);
    
  if ((me->My_Type == VD_DLU_CMD_POST) && (!me->My_Dblogin))
  {  /*  Warning for post and no support EXPR. tables   */
      UI_status ("Database does not support EXPRESSION tables");
  }

  /*    allocate and fill predefined lists   */

  me->pPARNams = _MALLOC (6 * VD_DLU_PAR_LENGTH, IGRchar);
  me->pDELopt  = _MALLOC (3 * VD_DRWLO_CHR_IDFLD, IGRchar);

  if ((me->pPARNams == NULL) || (me->pDELopt == NULL))
  {   /*   abort   */
      UI_status (VD_DLU_EMSG_MEM);
      _put_response( resp = TERMINATE);
      goto quit;
  }

  me->nPARNams = 6;
  strcpy (&me->pPARNams[0], VD_DLU_OL_ALL);
  strcpy (&me->pPARNams[VD_DLU_PAR_LENGTH], VD_DLU_OL_DLO);
  strcpy (&me->pPARNams[VD_DLU_PAR_LENGTH*2], VD_DLU_OL_STC);
  strcpy (&me->pPARNams[VD_DLU_PAR_LENGTH*3], VD_DLU_OL_SUC);
  strcpy (&me->pPARNams[VD_DLU_PAR_LENGTH*4], VD_DLU_OL_ADS);
  strcpy (&me->pPARNams[VD_DLU_PAR_LENGTH*5], VD_DLU_OL_EXP);

  me->nDELopt = 3;
  strcpy (me->pDELopt, VD_DLU_DO_FILE);
  strcpy (&me->pDELopt[VD_DRWLO_CHR_IDFLD], VD_DLU_DO_DB);
  strcpy (&me->pDELopt[VD_DRWLO_CHR_IDFLD*2], VD_DLU_DO_BOTH);

  /*    determine size of indices  */

  vd$tbldlo_idt (msg     = &retmsg,
                 osnum   = me->My_OS,
                 p_count = &me->nTypAll);

  vd$tblexp_idt (msg     = &retmsg,
                 osnum   = me->My_OS,
                 p_count = &iLL);
  if (iLL > me->nTypAll) me->nTypAll = iLL;

  (me->nTypAll)++;


  vd$tbldlo_idx (msg     = &retmsg,
                 osnum   = me->My_OS,
                 p_count = &iLL);
  if (iLL > me->nNamAll) me->nNamAll = iLL;

  vd$tblstc_idx (msg     = &retmsg,
                 osnum   = me->My_OS,
                 p_count = &iLL);
  if (iLL > me->nNamAll) me->nNamAll = iLL;

  vd$tblsuc_idx (msg     = &retmsg,
                 osnum   = me->My_OS,
                 p_count = &iLL);
  if (iLL > me->nNamAll) me->nNamAll = iLL;

  vd$tblads_idx (msg     = &retmsg,
                 osnum   = me->My_OS,
                 p_count = &iLL);
  if (iLL > me->nNamAll) me->nNamAll = iLL;

  /* Begin added for expression table -- sundar */
  vd$tblexp_idx (msg     = &retmsg,
                 osnum   = me->My_OS,
                 p_count = &iLL);
  if (iLL > me->nNamAll) me->nNamAll = iLL;
  /* End added for expression table -- sundar */

  (me->nNamAll)++;

  /*    allocate room for lists   */

  me->pNamLoc  = _MALLOC (me->nNamAll * VD_DRWLO_CHR_IDFLD, IGRchar);
  me->pNamDB   = _MALLOC (me->nNamAll * VD_DRWLO_CHR_IDFLD, IGRchar);
  me->pNamBoth = _MALLOC (me->nNamAll * VD_DRWLO_CHR_IDFLD, IGRchar);

  me->pDesDB   = _MALLOC (me->nNamAll * VD_DRWLO_CHR_DESC , IGRchar);

  me->pTypLoc  = _MALLOC (me->nNamAll * VD_DRWLO_CHR_IDFLD, IGRchar);
  me->pTypDB   = _MALLOC (me->nNamAll * VD_DRWLO_CHR_IDFLD, IGRchar);
  me->pTypBoth = _MALLOC (me->nNamAll * VD_DRWLO_CHR_IDFLD, IGRchar);

  if ((me->pNamLoc  == NULL) ||
      (me->pNamDB   == NULL) ||
      (me->pNamBoth == NULL) ||
      (me->pDesDB   == NULL) ||
      (me->pTypDB   == NULL) ||
      (me->pTypDB   == NULL) ||
      (me->pTypBoth == NULL) )
  {   /*   abort   */
      UI_status (VD_DLU_EMSG_MEM);
      _put_response( resp = TERMINATE);
      goto quit;
  }

  /*  startup the form    */

  form_ptr = me->forms[0].form_ptr;

  status =
  om$send (msg = message VDCmdDLU.set_form_pos (sts),
      targetid = my_id);

  FIf_display (form_ptr);

  quit:
  End
  return (OM_S_SUCCESS);
}



method  VDDLU_Load ( long * sts )
{
  int          status;
  IGRlong      retmsg;

  SetProc( VDCmdDLU.VDDLU_Load ); Begin

  *sts   = MSSUCC;

  switch (me->My_ParTyp)
  {
    case VD_DLU_PAR_DLO:
      vd$tbldlo_idx (msg     = &retmsg,
                     osnum   = me->My_OS,
                     p_nams  = me->pNamBoth,
                     p_count = &me->nNamBoth);

      vd$tbldlo_idx (msg     = &retmsg,
                     osnum   = me->My_OS,
                     dbget   = FALSE,
                     p_nams  = me->pNamLoc,
                     p_count = &me->nNamLoc);

      vd$tbldlo_idx (msg     = &retmsg,
                     osnum   = me->My_OS,
                     local   = FALSE,
                     p_nams  = me->pNamDB,
                     p_desc  = me->pDesDB,
                     p_count = &me->nNamDB);

      vd$tbldlo_idt (msg     = &retmsg,
                     osnum   = me->My_OS,
                     p_typs  = me->pTypBoth,
                     p_count = &me->nTypBoth);

      vd$tbldlo_idt (msg     = &retmsg,
                     osnum   = me->My_OS,
                     dbget   = FALSE,
                     p_typs  = me->pTypLoc,
                     p_count = &me->nTypLoc);

      vd$tbldlo_idt (msg     = &retmsg,
                     osnum   = me->My_OS,
                     local   = FALSE,
                     p_typs  = me->pTypDB,
                     p_count = &me->nTypDB);
      break;

    case VD_DLU_PAR_TYP:
      vd$tbldlo_idx (msg     = &retmsg,
                     osnum   = me->My_OS,
                     typin   = me->CUR_tabtyp,
                     p_nams  = me->pNamBoth,
                     p_count = &me->nNamBoth);

      vd$tbldlo_idx (msg     = &retmsg,
                     osnum   = me->My_OS,
                     dbget   = FALSE,
                     typin   = me->CUR_tabtyp,
                     p_nams  = me->pNamLoc,
                     p_count = &me->nNamLoc);

      vd$tbldlo_idx (msg     = &retmsg,
                     osnum   = me->My_OS,
                     local   = FALSE,
                     typin   = me->CUR_tabtyp,
                     p_nams  = me->pNamDB,
                     p_desc  = me->pDesDB,
                     p_count = &me->nNamDB);
      break;

    case VD_DLU_PAR_SRT:
      vd$tblstc_idx (msg     = &retmsg,
                     osnum   = me->My_OS,
                     p_nams  = me->pNamBoth,
                     p_count = &me->nNamBoth);

      vd$tblstc_idx (msg     = &retmsg,
                     osnum   = me->My_OS,
                     dbget   = FALSE,
                     p_nams  = me->pNamLoc,
                     p_count = &me->nNamLoc);

      vd$tblstc_idx (msg     = &retmsg,
                     osnum   = me->My_OS,
                     local   = FALSE,
                     p_nams  = me->pNamDB,
                     p_desc  = me->pDesDB,
                     p_count = &me->nNamDB);
      break;

    case VD_DLU_PAR_SUM:
      vd$tblsuc_idx (msg     = &retmsg,
                     osnum   = me->My_OS,
                     p_nams  = me->pNamBoth,
                     p_count = &me->nNamBoth);

      vd$tblsuc_idx (msg     = &retmsg,
                     osnum   = me->My_OS,
                     dbget   = FALSE,
                     p_nams  = me->pNamLoc,
                     p_count = &me->nNamLoc);

      vd$tblsuc_idx (msg     = &retmsg,
                     osnum   = me->My_OS,
                     local   = FALSE,
                     p_nams  = me->pNamDB,
                     p_desc  = me->pDesDB,
                     p_count = &me->nNamDB);
      break;

    case VD_DLU_PAR_ADS:
      vd$tblads_idx (msg     = &retmsg,
                     osnum   = me->My_OS,
                     p_nams  = me->pNamBoth,
                     p_count = &me->nNamBoth);

      vd$tblads_idx (msg     = &retmsg,
                     osnum   = me->My_OS,
                     dbget   = FALSE,
                     p_nams  = me->pNamLoc,
                     p_count = &me->nNamLoc);

      vd$tblads_idx (msg     = &retmsg,
                     osnum   = me->My_OS,
                     local   = FALSE,
                     p_nams  = me->pNamDB,
                     p_desc  = me->pDesDB,
                     p_count = &me->nNamDB);
      break;

    /* Begin added for expression table -- sundar */
    case VD_DLU_PAR_EXP:
	vd$tblexp_idx (msg     = &retmsg,
                     osnum   = me->My_OS,
                     p_nams  = me->pNamBoth,
                     p_count = &me->nNamBoth);
 
      vd$tblexp_idx (msg     = &retmsg,
                     osnum   = me->My_OS,
                     dbget   = FALSE,
                     p_nams  = me->pNamLoc,
                     p_count = &me->nNamLoc);
 
      vd$tblexp_idx (msg     = &retmsg,
                     osnum   = me->My_OS,
                     local   = FALSE,
                     p_nams  = me->pNamDB,
                     p_desc  = me->pDesDB,
                     p_count = &me->nNamDB);

      vd$tblexp_idt (msg     = &retmsg,
                     osnum   = me->My_OS,
                     p_typs  = me->pTypBoth,
                     p_count = &me->nTypBoth);
 
      vd$tblexp_idt (msg     = &retmsg,
                     osnum   = me->My_OS,
                     dbget   = FALSE,
                     p_typs  = me->pTypLoc,
                     p_count = &me->nTypLoc);
 
      vd$tblexp_idt (msg     = &retmsg,
                     osnum   = me->My_OS,
                     local   = FALSE,
                     p_typs  = me->pTypDB,
                     p_count = &me->nTypDB);

      break;
    case VD_DLU_PAR_EXP_TYP:
      vd$tblexp_idnd (msg     = &retmsg,
                     osnum   = me->My_OS,
                     p_type   = me->CUR_tabtyp,
                     p_nams  = me->pNamBoth,
                     p_count = &me->nNamBoth);
 
      vd$tblexp_idnd (msg     = &retmsg,
                     osnum   = me->My_OS,
                     dbget   = FALSE,
                     p_type   = me->CUR_tabtyp,
                     p_nams  = me->pNamLoc,
                     p_count = &me->nNamLoc);
 
      vd$tblexp_idnd (msg     = &retmsg,
                     osnum   = me->My_OS,
                     local   = FALSE,
                     p_type   = me->CUR_tabtyp,
                     p_nams  = me->pNamDB,
                     p_desc  = me->pDesDB,
                     p_count = &me->nNamDB);
      break;

    /* End added for expression table -- sundar */
    case VD_DLU_PAR_NONE:
    default:
      break;
  }

  End
  return (OM_S_SUCCESS);
}

method  VDDLU_Cleanup ( long * sts )
{
  int    status;

  SetProc( VDCmdDLU.VDDLU_Cleanup ); Begin
  *sts = MSSUCC;

  status =
  om$send (msg = message VDCmdDLU.save_form_pos (sts),
      targetid = my_id);

  FIf_erase (me->forms[0].form_ptr);

  _FREE (me->pNamLoc);
  _FREE (me->pNamDB);
  _FREE (me->pNamBoth);

  _FREE (me->pDesDB);

  _FREE (me->pTypLoc);
  _FREE (me->pTypDB);
  _FREE (me->pTypBoth);

  _FREE (me->pPARNams);
  _FREE (me->pDELopt);

  VDtbl_dlo_close (sts);
  VDtbl_stc_close (sts);
  VDtbl_suc_close (sts);
  VDtbl_ads_close (sts);

  status =
  om$send (msg = message CEO_LOCATE.delete (0),
          mode = OM_e_wrt_message,
      targetid = my_id);

  End
  return (OM_S_SUCCESS);
}


method  VDDLU_Reset ( long * sts )
{
  SetProc( VDCmdDLU.VDDLU_Reset ); Begin

  *sts = MSSUCC;

  me->My_localret   = 0;

  me->My_Localflag  = FALSE;

  me->CUR_tabnam[0] = me->Ltbrec.Tabnam[0] = me->SSid_tab.Tabnam[0] = '\0';
  me->CUR_tabtyp[0] = me->Ltbrec.Tabtyp[0] = '\0';

  me->Ltbrec.SumFil[0]  = '\0';
  me->Ltbrec.SortFil[0] = '\0';
  me->Ltbrec.Shdesc[0]  = me->SSid_tab.Shdesc[0] = '\0';
  me->Ltbrec.Timest[0]  = me->SSid_tab.Timest[0] = '\0';
  me->Ltbrec.Userid[0]  = me->SSid_tab.Userid[0] = '\0';

  me->Ltbrec.direct = VD_DRWLO_EN_DESCEND;
  me->Ltbrec.Local  = me->SSid_tab.Local = FALSE;

  me->Expid_tab.Tabnam[0] =  '\0';
  me->Expid_tab.Shdesc[0] =  '\0';
  me->Expid_tab.Timest[0] =  '\0';
  me->Expid_tab.Userid[0] =  '\0';
  me->Expid_tab.Local =  FALSE;

  me->My_stored_lo.objid = NULL_OBJID;

  VDtbl_dlo_close (sts);
  VDtbl_stc_close (sts);
  VDtbl_suc_close (sts);
  VDtbl_ads_close (sts);
  VDtbl_exp_close (sts);

  End
  return (OM_S_SUCCESS);
}

end implementation VDCmdDLU;
