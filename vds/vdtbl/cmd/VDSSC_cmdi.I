
/* $Id: VDSSC_cmdi.I,v 1.2 2001/02/22 22:25:16 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDSSC_cmdi.I
 *
 * Description:
 *
 * Implementation file for VDSSC command object initialization/reset
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDSSC_cmdi.I,v $
 *      Revision 1.2  2001/02/22 22:25:16  ylong
 *      *** empty log message ***
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1997/11/26  21:33:32  pinnacle
# Replaced: vdtbl/cmd/VDSSC_cmdi.I for:  by mdong for vds
#
# Revision 1.3  1997/11/11  03:16:24  pinnacle
# Replaced: vdtbl/cmd/VDSSC_cmdi.I for:  by mdong for vds
#
# Revision 1.2  1997/11/11  02:40:02  pinnacle
# Replaced: vdtbl/cmd/VDSSC_cmdi.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.13  1996/03/06  15:41:10  pinnacle
# Replaced: vdtbl/cmd/VDSSC_cmdi.I for:  by yzhu for vds.240
#
# Revision 1.12  1995/11/29  13:57:04  pinnacle
# Replaced: ./vdtbl/cmd/VDSSC_cmdi.I for:  by ksundar for vds.240
#
# Revision 1.11  1995/09/25  23:00:38  pinnacle
# Replaced: vdtbl/cmd/VDSSC_cmdi.I for:  by sundar for vds.240
#
# Revision 1.10  1995/09/05  23:15:16  pinnacle
# Replaced: vdtbl/cmd/VDSSC_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.9  1995/08/15  23:52:22  pinnacle
# Replaced: vdtbl/cmd/VDSSC_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.8  1995/08/11  23:36:00  pinnacle
# Replaced: vdtbl/cmd/VDSSC_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.7  1995/08/04  14:37:36  pinnacle
# Replaced: vdtbl/cmd/VDSSC_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/07/28  16:35:08  pinnacle
# Replaced: vdtbl/cmd/VDSSC_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/06  16:20:52  pinnacle
# Replaced: vdtbl/cmd/VDSSC_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  20:03:14  pinnacle
# Replaced: vdtbl/cmd/VDSSC_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/05/15  16:18:34  pinnacle
# Replaced: vdtbl/cmd/VDSSC_cmdi.I by hverstee r#
#
# Revision 1.2  1995/05/11  17:00:52  pinnacle
# Replaced: vdtbl/cmd/VDSSC_cmdi.I by hverstee r#
#
# Revision 1.1  1995/04/29  17:00:08  pinnacle
# Created: vdtbl/cmd/VDSSC_cmdi.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/20/95          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VDCmdSSC;

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

#include "VDmem.h"
#include "VDdrwlo_pr.h"
#include "vdpardef.h"
#include "vdtblmacros.h"
#include "VDCmdSSC.h"
#include "PDUerror.h"
#include "v_dbgmacros.h"


%safe
  static int x1_pos = -1,y1_pos = -1;
  static int x2_pos = -1,y2_pos = -1;
  static int x3_pos = -1,y3_pos = -1;
  static int x4_pos = -1,y4_pos = -1;
  static int x5_pos = -1,y5_pos = -1;
  static int x6_pos = -1,y6_pos = -1;
%endsafe

extern int              VDSverify_login();


method save_form_pos ( long * sts;
                       char * form_ptr )

{
  *sts = MSSUCC;

  switch (me->My_Type)
  {
    default:
    case VD_CMD_SRT_EDIT:
      FIf_get_location(form_ptr,&x1_pos,&y1_pos);
      break;

    case VD_CMD_SUM_EDIT:
      FIf_get_location(form_ptr,&x2_pos,&y2_pos);
      break;

    case VD_CMD_EXP_EDIT:
      FIf_get_location( form_ptr, &x5_pos, &y5_pos );
      break;

    case VD_CMD_SRT_REV:
      FIf_get_location(form_ptr,&x3_pos,&y3_pos);
      break;

    case VD_CMD_SUM_REV:
      FIf_get_location(form_ptr,&x4_pos,&y4_pos);
      break;

    case VD_CMD_EXP_REV:
      FIf_get_location( form_ptr, &x6_pos, &y6_pos );
      break;
  }

  return OM_S_SUCCESS;
}

method set_form_pos ( long * sts;
                      char * form_ptr )

{
  *sts = MSSUCC;
  switch (me->My_Type)
  {
    default:
    case VD_CMD_SRT_EDIT:
      if(x1_pos != -1 && y1_pos != -1)
        FIf_set_location(form_ptr,x1_pos,y1_pos);
      break;

    case VD_CMD_SUM_EDIT:
      if(x2_pos != -1 && y2_pos != -1)
        FIf_set_location(form_ptr,x2_pos,y2_pos);
      break;

    case VD_CMD_EXP_EDIT:
      if( x5_pos != -1 && y5_pos != -1 )
        FIf_set_location( form_ptr, x5_pos, y5_pos );
      break;

    case VD_CMD_SRT_REV:
      if(x3_pos != -1 && y3_pos != -1)
        FIf_set_location(form_ptr,x3_pos,y3_pos);
      break;

    case VD_CMD_SUM_REV:
      if(x4_pos != -1 && y4_pos != -1)
        FIf_set_location(form_ptr,x4_pos,y4_pos);
      break;

    case VD_CMD_EXP_REV:
      if( x6_pos != -1 && y6_pos != -1 )
        FIf_set_location( form_ptr, x6_pos, y6_pos );
      break;
  }

  return OM_S_SUCCESS;
}

method init ( int type ; char * str_ptr )
{
  int             status;
  char            szmsg[80];

  /*A initialize superclass */

  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message CEO.init (type, str_ptr),
                    targetid = my_id);
  as$status (action = RET_STATUS);

  me->My_Type       = type;

  ex$get_cur_mod (osnum = &me->My_OS);

  me->pTabNams      = NULL;
  me->pCat          = NULL;
  me->pSbC          = NULL;
  me->pCompar       = NULL;

  me->nTabNams      = 0;
  me->nNumCat       = 0;
  me->nNumSbC       = 0;
  me->nMaxSbC       = 0;
  me->nNumComp      = 0;

  if( me->My_Type == VD_CMD_EXP_EDIT )
  {
    if( VDSverify_login() != PDM_S_SUCCESS )
        {
          strcpy( szmsg, VD_CREXP_EMSG_WNDB );
          UI_status( szmsg );
        }
  }

  me->pExprTyps     = NULL;
  me->pExprNams     = NULL;
  me->pExprCats     = NULL;
  me->CUR_pExpFuncs = NULL;
  me->CUR_pExpSymbs = NULL;
  me->pObjParams    = NULL;

  me->CUR_exptyp[0] = '\0';
  me->CUR_expnam[0] = '\0';
  me->CUR_cpynam[0] = '\0';

  me->nExprTyps     = 0;
  me->nExprNams     = 0;
  me->nExprCats     = 0;
  me->nExprfunc     = 0;
  me->nExprData     = 0;
  me->nObjParams    = 0;
  me->CUR_nExpFuncs = 0;
  me->newflag       = FALSE;
  me->insert_pos    = -1;

  me->cpymode       = VD_DRWEXP_EN_APPEND;
  me->outmode       = VD_DRWEXP_EN_ASCII;
  me->insmode       = VD_DRWEXP_EN_APPEND;

  me->SSid_exp.Tabtyp[0] = '\0';
  me->SSid_exp.Tabnam[0] = '\0';
  me->SSid_exp.Shdesc[0] = '\0';
  me->SSid_exp.Timest[0] = '\0';
  me->SSid_exp.Userid[0] = '\0';
  me->SSid_exp.Local     = FALSE;
  me->SSid_exp.data_type = VD_DRWEXP_EN_ASCII;

  status   	    = om$vla_set_dimension( varray = me->Lexpdata, size = 0 );
  status   	    = om$vla_set_dimension( varray = me->Lexpfunc, size = 0 );

  return (OM_S_SUCCESS);
}


method  VDSSC_Cleanup ( long * sts )
{
  int    status;
  char  *form_ptr;

  form_ptr = me->forms[me->My_actv_form].form_ptr;

  status =
  om$send (msg = message VDCmdSSC.save_form_pos (sts, form_ptr),
      targetid = my_id);

  FIf_erase (form_ptr);

  *sts = MSSUCC;

  switch( me->My_actv_form )
  {
    case VD_SSC_SORTFORM:
    case VD_SSC_SUMMFORM:

      _FREE (me->pTabNams);
      _FREE (me->pCompar);
      _FREE (me->pSbC);
      _FREE (me->pCat);

      status =
      om$send (msg = message VDCmdSSC.VDSSC_Reset (sts),
          targetid = my_id);

      break;

    case VD_SSC_EXPRFORM:

      status =
      om$send( msg      = message VDCmdSSC.VDSSCexp_Reset(sts,
							  form_ptr),
               targetid = my_id);

      break;

    default:
      break;
  }

  status =
  om$send (msg = message CEO_LOCATE.delete (0),
          mode = OM_e_wrt_message,
      targetid = my_id);

  return (OM_S_SUCCESS);
}


method  VDSSC_Reset ( long * sts )
{
  *sts = MSSUCC;

  me->My_localret   = 0;

  me->CUR_tabnam[0] = '\0';

  me->SSid_tab.Tabnam[0] = '\0';
  me->SSid_tab.Shdesc[0] = '\0';
  me->SSid_tab.Timest[0] = '\0';
  me->SSid_tab.Userid[0] = '\0';

  me->SSid_tab.Local     = TRUE;

  me->My_stored_lo.objid = NULL_OBJID;

  me->nCurSrt       = -1;
  me->nCurQty       = -1;
  me->nCurMtc       = -1;

  me->CUR_catnam[0] = '\0';
  me->CUR_subcat[0] = '\0';

  VDtbl_stc_close (sts);
  VDtbl_suc_close (sts);

  return (OM_S_SUCCESS);
}


method VDSSC_StSrt (long     *msg)

{
  IGRint      status;
  int         Selflag;
  int         i, idsp;
  char      * form_ptr;
  IGRlong     retmsg;
  IGRboolean  bLocal;

  Selflag  = FALSE;
  bLocal   = FALSE;
  *msg     = MSSUCC;

  _FREE (me->pTabNams);
  _FREE (me->pCompar);
  _FREE (me->pSbC);
  _FREE (me->pCat);

  me->nNumCat = me->nMaxSbC = me->nNumComp = me->nTabNams = 0;

  me->My_actv_form = VD_SSC_SORTFORM;

  vd$tblstc_idx ( msg     = &retmsg,
                  osnum   = me->My_OS,
                  p_count = &me->nTabNams);

  me->pTabNams = _MALLOC ((me->nTabNams + 1) * VD_DRWLO_CHR_IDFLD, IGRchar);
  if (me->pTabNams == NULL)
  {
    UI_status (VD_SSC_EMSG_MEM);
    _put_response( resp = TERMINATE);
    goto quit;
  }

  vd$tblstc_idx ( msg     = &retmsg,
                  osnum   = me->My_OS,
                  p_nams  = me->pTabNams,
                  p_count = &me->nTabNams);

  form_ptr = me->forms[me->My_actv_form].form_ptr;

  status =
  om$send (msg = message VDCmdSSC.set_form_pos (&retmsg, form_ptr),
      targetid = my_id);

  FIf_display (form_ptr);

  FIfld_set_list_num_rows (form_ptr, VD_CRSRT_FLD_TABNAM, 0, (int)me->nTabNams);
  FIfld_set_list_num_rows (form_ptr, VD_CRSRT_FLD_COPY  , 0, (int)me->nTabNams);

  if (me->nTabNams > 10)
  {
    FIfld_set_list_scroll (form_ptr, VD_CRSRT_FLD_TABNAM, 1, 0);
    FIfld_set_list_scroll (form_ptr, VD_CRSRT_FLD_COPY  , 1, 0);
  }
  else
  {
    FIfld_set_list_scroll (form_ptr, VD_CRSRT_FLD_TABNAM, 0, 0);
    FIfld_set_list_scroll (form_ptr, VD_CRSRT_FLD_COPY  , 0, 0);
  }

  for (i=0; i<me->nTabNams; i++)
  {
    idsp = i * VD_DRWLO_CHR_IDFLD;
    VDfld_set_list_text (form_ptr, VD_CRSRT_FLD_TABNAM, i, 0,
                                   &me->pTabNams[idsp], Selflag);
    VDfld_set_list_text (form_ptr, VD_CRSRT_FLD_COPY  , i, 0,
                                   &me->pTabNams[idsp], Selflag);
  }

  status =
  om$send (msg = message VDCmdSSC.VDSSC_Reset (msg),
      targetid = my_id);

  if (me->My_Type == VD_CMD_SRT_REV)
  {    /*  review function, adapt form    */
    FIg_erase   (form_ptr, VD_CRSRT_TXT_EDTITLE);
    FIg_display (form_ptr, VD_CRSRT_TXT_REVTITLE);

    FIg_erase   (form_ptr, VD_CRSRT_FLD_COPY);
    FIg_erase   (form_ptr, VD_CRSRT_TXT_COPY);

    FIg_erase   (form_ptr, VD_CRSRT_TGG_SEQ);
    FIg_erase   (form_ptr, VD_CRSRT_TGG_TYP);

    FIg_disable (form_ptr, FI_ACCEPT);
    FIg_disable (form_ptr, FI_EXECUTE);

    FIg_erase   (form_ptr, VD_CRSRT_BTN_INSERT);
    FIg_erase   (form_ptr, VD_CRSRT_BTN_DELETE);

    FIfld_set_mode (form_ptr, VD_CRSRT_FLD_DESCR, 0, FI_REVIEW);
    FIfld_set_mode (form_ptr, VD_CRSRT_FLD_ATTR , 0, FI_REVIEW);

    FIg_display (form_ptr, VD_CRSRT_FLD_REVSEQ);
    FIg_display (form_ptr, VD_CRSRT_FLD_REVTYP);
  }
  else
  {   /*    limit scrollability of input fields    */
    FIfld_set_max_num_chars (form_ptr, VD_CRSRT_FLD_DESCR, 0,
                              VD_DRWLO_CHR_DESC);
    FIfld_set_max_num_chars (form_ptr, VD_CRSRT_FLD_ATTR, 0,
                              VD_DRWLO_CHR_ATTRNAM);
  }

  quit:
  return OM_S_SUCCESS;
}

method VDSSC_StSum (long     *msg)

{
  IGRint      status;
  int         Selflag;
  int         i, idsp;
  char      * form_ptr;
  IGRlong     retmsg;
  IGRboolean  bLocal;

  Selflag  = FALSE;
  bLocal   = FALSE;
  *msg     = MSSUCC;

  _FREE (me->pTabNams);
  _FREE (me->pCompar);
  _FREE (me->pSbC);
  _FREE (me->pCat);

  me->nNumCat = me->nMaxSbC = me->nNumComp = me->nTabNams = 0;

  me->My_actv_form = VD_SSC_SUMMFORM;

  vd$tblsuc_idx ( msg     = &retmsg,
                  osnum   = me->My_OS,
                  p_count = &me->nTabNams);

  me->pTabNams = _MALLOC ((me->nTabNams + 1) * VD_DRWLO_CHR_IDFLD, IGRchar);
  if (me->pTabNams == NULL)
  {
    UI_status (VD_SSC_EMSG_MEM);
    _put_response( resp = TERMINATE);
    goto quit;
  }

  vd$tblsuc_idx ( msg     = &retmsg,
                  osnum   = me->My_OS,
                  p_nams  = me->pTabNams,
                  p_count = &me->nTabNams);

  form_ptr = me->forms[me->My_actv_form].form_ptr;

  status =
  om$send (msg = message VDCmdSSC.set_form_pos (&retmsg, form_ptr),
      targetid = my_id);

  FIf_display (form_ptr);

  FIfld_set_list_num_rows (form_ptr, VD_CRSUM_FLD_TABNAM, 0, (int)me->nTabNams);
  FIfld_set_list_num_rows (form_ptr, VD_CRSUM_FLD_COPY  , 0, (int)me->nTabNams);

  if (me->nTabNams > 10)
  {
    FIfld_set_list_scroll (form_ptr, VD_CRSUM_FLD_TABNAM, 1, 0);
    FIfld_set_list_scroll (form_ptr, VD_CRSUM_FLD_COPY  , 1, 0);
  }
  else
  {
    FIfld_set_list_scroll (form_ptr, VD_CRSUM_FLD_TABNAM, 0, 0);
    FIfld_set_list_scroll (form_ptr, VD_CRSUM_FLD_COPY  , 0, 0);
  }

  for (i=0; i<me->nTabNams; i++)
  {
    idsp = i * VD_DRWLO_CHR_IDFLD;
    VDfld_set_list_text (form_ptr, VD_CRSUM_FLD_TABNAM, i, 0,
                                   &me->pTabNams[idsp], Selflag);
    VDfld_set_list_text (form_ptr, VD_CRSUM_FLD_COPY  , i, 0,
                                   &me->pTabNams[idsp], Selflag);
  }

  /*   set comparators list */

  me->nNumComp = 7;
  me->pCompar  = _MALLOC (me->nNumComp * VD_CRSUM_STL_COMPAR, IGRchar);

  if (me->pCompar == NULL)
  {
    UI_status (VD_SSC_EMSG_MEM);
    _put_response( resp = TERMINATE);
    goto quit;
  }

  strcpy (&me->pCompar[0], "NONE");
  strcpy (&me->pCompar[VD_CRSUM_STL_COMPAR * 1], VD_str_qry_EQUAL);
  strcpy (&me->pCompar[VD_CRSUM_STL_COMPAR * 2], VD_str_qry_N_EQUAL);
  strcpy (&me->pCompar[VD_CRSUM_STL_COMPAR * 3], VD_str_qry_G_EQUAL);
  strcpy (&me->pCompar[VD_CRSUM_STL_COMPAR * 4], VD_str_qry_L_EQUAL);
  strcpy (&me->pCompar[VD_CRSUM_STL_COMPAR * 5], VD_str_qry_G_THAN);
  strcpy (&me->pCompar[VD_CRSUM_STL_COMPAR * 6], VD_str_qry_L_THAN);

  FIfld_set_list_num_rows (form_ptr, VD_CRSUM_FLD_MREL, 0, (int)me->nNumComp);

  FIfld_set_list_scroll (form_ptr, VD_CRSUM_FLD_MREL, 0, 0);

  for (i=0; i<me->nNumComp; i++)
  {
    idsp = i * VD_CRSUM_STL_COMPAR;

    VDfld_set_list_text (form_ptr, VD_CRSUM_FLD_MREL, i, 0,
                                   &me->pCompar[idsp], Selflag);
  }

  status =
  om$send (msg = message VDCmdSSC.VDSSC_Reset (msg),
      targetid = my_id);

  /*  SET PREDEFINED CATEGORIES       */

  if (me->My_Type == VD_CMD_SUM_EDIT)
  {  /*    edit, load full categories list    */

    int    NumFnd;

    status =
    VD_compGetCompNames (VD_CRSUM_STL_CAT, &NumFnd, &(me->pCat));

    /* TR 179600521 */
    FIg_display(form_ptr, VD_CRSUM_FLD_MREL);
    FIg_erase(form_ptr, VD_CRSUM_FLD_MREL_REW);

    me->nNumCat = NumFnd;

    FIfld_set_list_num_rows (form_ptr, VD_CRSUM_FLD_CAT, 0, (int)me->nNumCat);

    if (me->nNumCat > 10)
      FIfld_set_list_scroll (form_ptr, VD_CRSUM_FLD_CAT, 1, 0);
    else
      FIfld_set_list_scroll (form_ptr, VD_CRSUM_FLD_CAT, 0, 0);

    for (i=0; i<me->nNumCat; i++)
    {
      idsp = i * VD_CRSUM_STL_CAT;

      VDfld_set_list_text (form_ptr, VD_CRSUM_FLD_CAT, i, 0,
                                     &me->pCat[idsp], Selflag);
    }

    /*    limit scrollability of input fields    */
    FIfld_set_max_num_chars (form_ptr, VD_CRSUM_FLD_DESCR, 0,
                              VD_DRWLO_CHR_DESC);
    FIfld_set_max_num_chars (form_ptr, VD_CRSUM_FLD_QEXP, 0,
                              VD_DRWLO_CHR_DESC);
    FIfld_set_max_num_chars (form_ptr, VD_CRSUM_FLD_MEXP, 0,
                              VD_DRWLO_CHR_DESC);
    FIfld_set_max_num_chars (form_ptr, VD_CRSUM_FLD_MATT, 0,
                              VD_DRWLO_CHR_ATTRNAM);
  }
  else
  {    /*  review function, adapt form , group done in disp   */
    FIg_erase   (form_ptr, VD_CRSUM_TXT_EDTITLE);
    FIg_display (form_ptr, VD_CRSUM_TXT_REVTITLE);

    FIg_erase   (form_ptr, VD_CRSUM_FLD_COPY);
    FIg_erase   (form_ptr, VD_CRSUM_TXT_COPY);

    /* TR 179600521 */
    FIg_erase   (form_ptr, VD_CRSUM_FLD_MREL);
    FIg_display (form_ptr, VD_CRSUM_FLD_MREL_REW);


    FIg_disable (form_ptr, FI_ACCEPT);
    FIg_disable (form_ptr, FI_EXECUTE);

    FIfld_set_mode (form_ptr, VD_CRSUM_FLD_DESCR, 0, FI_REVIEW);
    FIfld_set_mode (form_ptr, VD_CRSUM_FLD_QEXP , 0, FI_REVIEW);
    FIfld_set_mode (form_ptr, VD_CRSUM_FLD_MATT , 0, FI_REVIEW);
    FIfld_set_mode (form_ptr, VD_CRSUM_FLD_MREL , 0, FI_REVIEW);
    FIfld_set_mode (form_ptr, VD_CRSUM_FLD_MEXP , 0, FI_REVIEW);
  }

  quit:
  return OM_S_SUCCESS;
}

method VDSSC_Save (IGRlong     *msg)
{
  IGRint    status;
  IGRlong   retmsg;
  IGRshort  nCount;

  *msg = MSFAIL;

  if (me->CUR_tabnam[0] == '\0')
  {   /*  save of empty , do nothing   */
    *msg = MSSUCC;
    return (OM_S_SUCCESS);
  }

  if (me->My_stored_lo.objid == NULL_OBJID)
  {    /*    new object, create    */
    if (me->My_Type == VD_CMD_SRT_EDIT)
    {
      vd$tblstc_new (msg    = &retmsg,
                     osnum  = me->My_OS,
                     tabnam = me->CUR_tabnam,
                     GRid   = &me->My_stored_lo);
    }
    else
    if (me->My_Type == VD_CMD_SUM_EDIT)
    {
      vd$tblsuc_new (msg    = &retmsg,
                     osnum  = me->My_OS,
                     tabnam = me->CUR_tabnam,
                     GRid   = &me->My_stored_lo);
    }
    else
      return (OM_S_SUCCESS);
      __DBGpr_obj ("created sort/summ object",me->My_stored_lo);
  }

  *msg = MSSUCC;

  status =
  om$send (msg = message VDSSC.VDSSC_init (&retmsg, &me->SSid_tab),
      targetid = me->My_stored_lo.objid,
      targetos = me->My_stored_lo.osnum);
  as$status();

  if (me->My_Type == VD_CMD_SRT_EDIT)
  {
    nCount = om$dimension_of (varray = me->Lsortrec);

    if (nCount > 0)
    {
      status =
      om$send (msg = message VDSSC.VDSSC_ssort
                                (&retmsg, nCount, me->Lsortrec),
          targetid = me->My_stored_lo.objid,
          targetos = me->My_stored_lo.osnum);
      __DBGpr_int ("stored %d sort keys",nCount);
    }
  }
  else
  if (me->My_Type == VD_CMD_SUM_EDIT)
  {
    nCount = om$dimension_of (varray = me->Lsqtyrec);

    if (nCount > 0)
    {
      status =
      om$send (msg = message VDSSC.VDSSC_ssqty
                                (&retmsg, nCount, me->Lsqtyrec),
          targetid = me->My_stored_lo.objid,
          targetos = me->My_stored_lo.osnum);
      __DBGpr_int ("stored %d quantity recs",nCount);
    }

    nCount = om$dimension_of (varray = me->Lsmtcrec);

    if (nCount > 0)
    {
      status =
      om$send (msg = message VDSSC.VDSSC_ssmtc
                                (&retmsg, nCount, me->Lsmtcrec),
          targetid = me->My_stored_lo.objid,
          targetos = me->My_stored_lo.osnum);
      __DBGpr_int ("stored %d match recs",nCount);
    }
  }

  return (OM_S_SUCCESS);
}



method VDSSC_Rtc (long    *retcode)
{

  *retcode = me->My_localret;

  return OM_S_SUCCESS;
}

method form_notification ( int         form_label ;
                           int         gadget_label ;
                           double      value ;
                           char      * form_ptr )
{
  int        status;
  double     dLocVal;

  if (form_label != me->My_actv_form) goto quit;

  FIg_get_value (form_ptr, gadget_label, &dLocVal);

  if (form_label == VD_SSC_SORTFORM)
  {
    status =
    om$send (msg = message VDCmdSSC.VDSSC_srt_fn
                                         (gadget_label, dLocVal, form_ptr),
        targetid = my_id);
  }
  else if( form_label == VD_SSC_EXPRFORM )
  {
    status =
    om$send( msg      = message VDCmdSSC.VDSSC_exp_fn(gadget_label,
						      dLocVal,
						      form_ptr),
             targetid = my_id);
  }
  else
  {
    status =
    om$send (msg = message VDCmdSSC.VDSSC_sum_fn
                                         (gadget_label, dLocVal, form_ptr),
        targetid = my_id);
  }

  quit:
  return (OM_S_SUCCESS);
}

method delete (int   f_defer_flag)
{
  IGRint      status;
  long        sts;

  status = 
  om$send (msg = message VDCmdSSC.VDSSC_Cleanup (&sts),
      targetid = my_id);

  return (OM_S_SUCCESS);
}
end implementation VDCmdSSC;

