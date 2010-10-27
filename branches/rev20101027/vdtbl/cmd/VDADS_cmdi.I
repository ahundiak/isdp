
/* $Id: VDADS_cmdi.I,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDADS_cmdi.I
 *
 * Description:
 *
 * Implementation file for VDADS command object initialization/reset
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDADS_cmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:25  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/27  06:09:56  pinnacle
# Replaced: vdtbl/cmd/VDADS_cmdi.I for:  by vgnair for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.12  1996/05/20  16:32:52  pinnacle
# Replaced: vdtbl/cmd/VDADS_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.11  1995/12/14  22:28:46  pinnacle
# Replaced: vdtbl/cmd/VDADS_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.10  1995/11/29  13:55:58  pinnacle
# Replaced: ./vdtbl/cmd/VDADS_cmdi.I for:  by ksundar for vds.240
#
# Revision 1.9  1995/11/17  22:28:32  pinnacle
# Replaced: vdtbl/cmd/VDADS_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.8  1995/09/25  23:43:26  pinnacle
# Replaced: vdtbl/cmd/VDADS_cmdi.I for:  by sundar for vds.240
#
# Revision 1.7  1995/09/25  23:02:52  pinnacle
# Replaced: vdtbl/cmd/VDADS_cmdi.I for:  by sundar for vds.240
#
# Revision 1.6  1995/09/05  23:14:50  pinnacle
# Replaced: vdtbl/cmd/VDADS_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/08/15  23:52:42  pinnacle
# Replaced: vdtbl/cmd/VDADS_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/14  22:41:32  pinnacle
# Replaced: vdtbl/cmd/VDADS_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/11  23:33:34  pinnacle
# Replaced: vdtbl/cmd/VDADS_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/06  15:43:34  pinnacle
# Replaced: vdtbl/cmd/VDADS_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/19  19:58:04  pinnacle
# Created: vdtbl/cmd/VDADS_cmdi.I by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/12/95          HV            New
 * 	11/27/97	  vini		Place cell in BOM table
 *
 * -------------------------------------------------------------------*/

class implementation VDCmdADS;

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
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"
#include "cotxmacros.h"

#include "VDdrwlo_pr.h"
#include "vdpardef.h"
#include "VDmem.h"
#include "vdtblmacros.h"

%safe
  static int x_pos = -1,y_pos = -1;
%endsafe

/*
#define  MY_DEBUG
*/

method save_form_pos ( long * sts )
{

  FIf_get_location(me->forms[0].form_ptr,&x_pos,&y_pos);
  *sts = MSSUCC;

#ifdef MY_DEBUG
  printf (" save pos %d %d\n",x_pos, y_pos);
#endif

  return OM_S_SUCCESS;
}

method set_form_pos ( long * sts )
{
   if(x_pos != -1 && y_pos != -1)
     FIf_set_location ( me->forms[0].form_ptr, x_pos, y_pos );

#ifdef MY_DEBUG
  printf (" set pos %d %d\n",x_pos, y_pos);
#endif

  return OM_S_SUCCESS;
}

method init ( int type ; char * str_ptr )
{
  int             status;
  IGRlong         retmsg;

  /*A initialize superclass */

  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message CEO.init (type, str_ptr),
                    targetid = my_id);
  as$status (action = RET_STATUS);

  me->My_Type       = type;

  me->pTabNams      = NULL;
  me->pr_fonts      = NULL;

  me->nTabNams      = 0;

  ex$get_cur_mod (osnum = &me->My_OS);

  /*   set up comparators list   */

  me->nNumComp = VD_ADSYM_NUM_COMPAR;
  me->pCompar  = _MALLOC (me->nNumComp * VD_ADSYM_STL_COMPAR, IGRchar);
  if (me->pCompar == NULL)
  {
    UI_status (VD_ADS_EMSG_MEM);
    _put_response( resp = TERMINATE);
    goto quit;
  }

  strcpy (&me->pCompar[0], "NONE");
  strcpy (&me->pCompar[VD_ADSYM_STL_COMPAR * 1], VD_str_qry_EQUAL);
  strcpy (&me->pCompar[VD_ADSYM_STL_COMPAR * 2], VD_str_qry_N_EQUAL);
  strcpy (&me->pCompar[VD_ADSYM_STL_COMPAR * 3], VD_str_qry_G_EQUAL);
  strcpy (&me->pCompar[VD_ADSYM_STL_COMPAR * 4], VD_str_qry_L_EQUAL);
  strcpy (&me->pCompar[VD_ADSYM_STL_COMPAR * 5], VD_str_qry_G_THAN);
  strcpy (&me->pCompar[VD_ADSYM_STL_COMPAR * 6], VD_str_qry_L_THAN);

  me->defrec.Symbol[0]   = '\0';
  me->defrec.szAtt[0]    = '\0';
  me->defrec.szAttval[0] = '\0';

  me->defrec.nDattyp     = VD_DRWLO_EN_ASCII;
  me->defrec.nnREL       = VD_cnt_qry_NONE;
  me->defrec.dAttval     = 0.0;
  me->defrec.nnSide      = VD_DRWLO_EN_LEFT;
  me->defrec.dOffset     = 1.0;
  me->defrec.dCharhgt    = 0.1;
  me->defrec.dCharwdt    = 0.1;
  me->defrec.dCharspc    = 1.0;

  /*    fonts list                */

  VD_get_fontlist (&retmsg, &me->nFonts, NULL);

  if (me->nFonts > 0)
  {
    me->pr_fonts = _MALLOC (me->nFonts * FONT_NAME, IGRchar);

    if (me->pr_fonts == NULL)
    {
      UI_status (VD_ADS_EMSG_MEM);
      _put_response( resp = TERMINATE);
      goto quit;
    }

    VD_get_fontlist (&retmsg, &me->nFonts, me->pr_fonts);

    strcpy (me->defrec.font, me->pr_fonts);
  }
  else
  {
    me->pr_fonts = NULL;

    strcpy (me->defrec.font, "default");
  }

  quit:
  return (OM_S_SUCCESS);
}

method delete (int   f_defer_flag)
{
  IGRint      status;
  long        sts;

  status = 
  om$send (msg = message VDCmdADS.VDADS_Cleanup (&sts),
      targetid = my_id);

  return (OM_S_SUCCESS);
}



method  VDADS_Cleanup ( long * sts )
{
  int    status;

  *sts = MSSUCC;

  status =
  om$send (msg = message VDCmdADS.save_form_pos (sts),
      targetid = my_id);

  FIf_erase (me->forms[0].form_ptr);

  VDtbl_ads_close (sts);

  _FREE (me->pTabNams);
  _FREE (me->pCompar);
  _FREE (me->pr_fonts);

  status =
  om$send (msg = message CEO_LOCATE.delete (0),
          mode = OM_e_wrt_message,
      targetid = my_id);

  return (OM_S_SUCCESS);
}


method  VDADS_Reset ( long * sts )
{
  IGRint     status;
  IGRlong    retmsg;

  *sts = MSSUCC;

  me->My_localret   = 0;

  me->CUR_tabnam[0] = '\0';

  me->SSid_tab.Tabnam[0] = '\0';
  me->SSid_tab.Shdesc[0] = '\0';
  me->SSid_tab.Timest[0] = '\0';
  me->SSid_tab.Userid[0] = '\0';

  me->SSid_tab.Local     = TRUE;

  status =
  om$send (msg = message VDADS.VDADS_init (&retmsg, &me->SSid_tab),
      targetid = my_id);
  as$status();

  me->My_stored_lo.objid = NULL_OBJID;

  me->nCurSym       = -1;
  me->nMaxSym       =  0;

  VDtbl_ads_close (sts);

  return (OM_S_SUCCESS);
}


method VDADS_StEdit (long     *msg)

{
  IGRint      status;
  int         Selflag;
  int         i, idsp;
  char      * form_ptr;
  IGRlong     retmsg;
  IGRboolean  bLocal;
  IGRchar     szFld[6];

  Selflag  = FALSE;
  bLocal   = FALSE;
  *msg     = MSSUCC;

  _FREE (me->pTabNams);

  vd$tblads_idx ( msg     = &retmsg,
                  osnum   = me->My_OS,
                  p_count = &me->nTabNams);

  me->pTabNams = _MALLOC ((me->nTabNams + 1) * VD_DRWLO_CHR_IDFLD, IGRchar);
  if (me->pTabNams == NULL)
  {
    UI_status (VD_ADS_EMSG_MEM);
    _put_response( resp = TERMINATE);
    goto quit;
  }

  vd$tblads_idx ( msg     = &retmsg,
                  osnum   = me->My_OS,
                  p_nams  = me->pTabNams,
                  p_count = &me->nTabNams);

#ifdef MY_DEBUG
  printf (" get adstab index %d entries\n",me->nTabNams);
#endif

  form_ptr = me->forms[0].form_ptr;

  status =
  om$send (msg = message VDCmdADS.set_form_pos (&retmsg),
      targetid = my_id);

  FIf_display (form_ptr);

  FIfld_set_list_num_rows (form_ptr, VD_ADSYM_FLD_TABNAM, 0, (int)me->nTabNams);
  FIfld_set_list_num_rows (form_ptr, VD_ADSYM_FLD_COPY  , 0, (int)me->nTabNams);

  if (me->nTabNams > 10)
  {
    FIfld_set_list_scroll (form_ptr, VD_ADSYM_FLD_TABNAM, 1, 0);
    FIfld_set_list_scroll (form_ptr, VD_ADSYM_FLD_COPY  , 1, 0);
  }
  else
  {
    FIfld_set_list_scroll (form_ptr, VD_ADSYM_FLD_TABNAM, 0, 0);
    FIfld_set_list_scroll (form_ptr, VD_ADSYM_FLD_COPY  , 0, 0);
  }

  for (i=0; i<me->nTabNams; i++)
  {
    idsp = i * VD_DRWLO_CHR_IDFLD;
    VDfld_set_list_text (form_ptr, VD_ADSYM_FLD_TABNAM, i, 0,
                                   &me->pTabNams[idsp], Selflag);
    VDfld_set_list_text (form_ptr, VD_ADSYM_FLD_COPY  , i, 0,
                                   &me->pTabNams[idsp], Selflag);
  }

  FIfld_set_list_num_rows (form_ptr, VD_ADSYM_FLD_RELTYP, 0, (int)me->nNumComp);

  FIfld_set_list_scroll (form_ptr, VD_ADSYM_FLD_RELTYP, 0, 0);

  for (i=0; i<me->nNumComp; i++)
  {
    idsp = i * VD_ADSYM_STL_COMPAR;

    VDfld_set_list_text (form_ptr, VD_ADSYM_FLD_RELTYP, i, 0,
                                   &me->pCompar[idsp], Selflag);
  }


  if (me->nFonts > 5)
    FIfld_set_list_scroll (form_ptr, VD_ADSYM_FLD_CHFONT, 1, 0);
  else
    FIfld_set_list_scroll (form_ptr, VD_ADSYM_FLD_CHFONT, 0, 0);


  for (i=0; i<me->nFonts; i++)
  {
    idsp = i * FONT_NAME;

    VDfld_set_list_text (form_ptr, VD_ADSYM_FLD_CHFONT, i, 0,
                                &me->pr_fonts[idsp], Selflag);
  }


  FIfld_set_list_scroll (form_ptr, VD_ADSYM_FLD_CHWGT,  1, 0);

  for (i=0; i<32; i++)
  {
    sprintf (szFld,"%4d",i);

    VDfld_set_list_text (form_ptr, VD_ADSYM_FLD_CHWGT, i, 0, szFld, Selflag);
  }

  /*    Limit scrollability of input fields      */

  FIfld_set_max_num_chars (form_ptr, VD_ADSYM_FLD_DESCR, 0,
                              VD_DRWLO_CHR_DESC);
  FIfld_set_max_num_chars (form_ptr, VD_ADSYM_FLD_ATTNAM, 0,
                              VD_DRWLO_CHR_ATTRNAM);
  FIfld_set_max_num_chars (form_ptr, VD_ADSYM_FLD_ATVASC, 0,
                              VD_DRWLO_CHR_DESC);
  FIfld_set_max_num_chars (form_ptr, VD_ADSYM_FLD_CHFONT, 0,
                              VD_DRWLO_CHR_IDFLD);

  status =
  om$send (msg = message VDCmdADS.VDADS_Reset (msg),
      targetid = my_id);

  quit:
  return OM_S_SUCCESS;
}

method VDADS_StRev (long     *msg)

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

  vd$tblads_idx ( msg     = &retmsg,
                  osnum   = me->My_OS,
                  p_count = &me->nTabNams);

  me->pTabNams = _MALLOC ((me->nTabNams + 1) * VD_DRWLO_CHR_IDFLD, IGRchar);
  if (me->pTabNams == NULL)
  {
    UI_status (VD_ADS_EMSG_MEM);
    _put_response( resp = TERMINATE);
    goto quit;
  }

  vd$tblads_idx ( msg     = &retmsg,
                  osnum   = me->My_OS,
                  p_nams  = me->pTabNams,
                  p_count = &me->nTabNams);

#ifdef MY_DEBUG
  printf (" get adstab index %d entries\n",me->nTabNams);
#endif

  form_ptr = me->forms[0].form_ptr;

  status =
  om$send (msg = message VDCmdADS.set_form_pos (&retmsg),
      targetid = my_id);

  /*    change form to review mode    */

  FIg_erase   (form_ptr, VD_ADSYM_TXT_EDIT);
  FIg_display (form_ptr, VD_ADSYM_TXT_REVIEW);

  FIg_erase   (form_ptr, VD_ADSYM_FLD_COPY);
  FIg_erase   (form_ptr, VD_ADSYM_TXT_COPY);

  FIg_erase   (form_ptr, VD_ADSYM_TGG_ATTTYP);
  FIg_erase   (form_ptr, VD_ADSYM_TGG_PLACE);

  FIg_display (form_ptr, VD_ADSYM_FLD_ATTTYP);
  FIg_display (form_ptr, VD_ADSYM_FLD_PLACE);

  FIg_erase   (form_ptr, VD_ADSYM_BTN_DELETE);
  FIg_erase   (form_ptr, VD_ADSYM_BTN_INSERT);
  FIg_erase   (form_ptr, VD_ADSYM_BTN_DEFAULT);

  FIg_erase   (form_ptr, VD_ADSYM_FLD_RELTYP);
  FIg_erase   (form_ptr, VD_ADSYM_FLD_CHFONT);
  FIg_erase   (form_ptr, VD_ADSYM_FLD_CHWGT);

  FIg_display (form_ptr, VD_ADSYM_RF_RELTYP);
  FIg_display (form_ptr, VD_ADSYM_RF_CHFONT);
  FIg_display (form_ptr, VD_ADSYM_RF_CHWGT);


  FIg_display (form_ptr, VD_ADSYM_RF_CELLS);

  FIg_disable (form_ptr, FI_ACCEPT);
  FIg_disable (form_ptr, FI_EXECUTE);

  FIfld_set_mode (form_ptr, VD_ADSYM_FLD_DESCR  , 0, FI_REVIEW);
  FIfld_set_mode (form_ptr, VD_ADSYM_FLD_SYMSTR , 0, FI_REVIEW);
  FIfld_set_mode (form_ptr, VD_ADSYM_FLD_ATTNAM , 0, FI_REVIEW);
  FIfld_set_mode (form_ptr, VD_ADSYM_FLD_ATVASC , 0, FI_REVIEW);
  FIfld_set_mode (form_ptr, VD_ADSYM_FLD_ATVNUM , 0, FI_REVIEW);

  FIfld_set_mode (form_ptr, VD_ADSYM_FLD_OFFSET , 0, FI_REVIEW);
  FIfld_set_mode (form_ptr, VD_ADSYM_FLD_CHHGT  , 0, FI_REVIEW);
  FIfld_set_mode (form_ptr, VD_ADSYM_FLD_CHWDT  , 0, FI_REVIEW);
  FIfld_set_mode (form_ptr, VD_ADSYM_FLD_CHSPC  , 0, FI_REVIEW);

  FIfld_set_list_num_rows (form_ptr, VD_ADSYM_FLD_TABNAM, 0, (int)me->nTabNams);

  if (me->nTabNams > 10)
  {
    FIfld_set_list_scroll (form_ptr, VD_ADSYM_FLD_TABNAM, 1, 0);
  }
  else
  {
    FIfld_set_list_scroll (form_ptr, VD_ADSYM_FLD_TABNAM, 0, 0);
  }

  for (i=0; i<me->nTabNams; i++)
  {
    idsp = i * VD_DRWLO_CHR_IDFLD;
    VDfld_set_list_text (form_ptr, VD_ADSYM_FLD_TABNAM, i, 0,
                                   &me->pTabNams[idsp], Selflag);
  }

  status =
  om$send (msg = message VDCmdADS.VDADS_Reset (msg),
      targetid = my_id);

  quit:
  return OM_S_SUCCESS;
}


method VDADS_Save (IGRlong     *msg)
{
  IGRint    status;
  IGRlong   retmsg;
  IGRshort  nCount;

  *msg = MSFAIL;

  if (me->CUR_tabnam[0] == '\0') return (OM_S_SUCCESS);

  if (me->My_stored_lo.objid == NULL_OBJID)
  {    /*    new object, create    */
    if (me->My_Type == VD_CMD_ADS_EDIT)
    {
      vd$tblads_new (msg    = &retmsg,
                     osnum  = me->My_OS,
                     tabnam = me->CUR_tabnam,
                     GRid   = &me->My_stored_lo);
    }
    else
      return (OM_S_SUCCESS);

#ifdef MY_DEBUG
      printf ("created ads object <%d %d>\n",me->My_stored_lo.objid,
                                             me->My_stored_lo.osnum);
#endif
  }

  *msg = MSSUCC;

  status =
  om$send (msg = message VDADS.VDADS_init (&retmsg, &me->SSid_tab),
      targetid = me->My_stored_lo.objid,
      targetos = me->My_stored_lo.osnum);
  as$status();

  if (me->My_Type == VD_CMD_ADS_EDIT)
  {
    nCount = om$dimension_of (varray = me->Ladsrec);

    if (nCount > 0)
    {
      status =
      om$send (msg = message VDADS.VDADS_srec
                                (&retmsg, nCount, me->Ladsrec),
          targetid = me->My_stored_lo.objid,
          targetos = me->My_stored_lo.osnum);
#ifdef MY_DEBUG
      printf ("stored %d ads keys\n",nCount);
#endif
    }
  }

  return (OM_S_SUCCESS);
}


method   VDADS_load   (IGRlong    *msg;
                struct GRid       *lGrid)
{
  IGRint       status;
  IGRlong      retmsg;

  me->nMaxSym = 0;

  status =
  om$send (msg = message VDADS.VDADS_gtab (&retmsg, &me->SSid_tab),
      targetid = lGrid->objid,
      targetos = lGrid->osnum);

  status =
  om$send (msg = message VDADS.VDADS_grec
                         (&retmsg, NULL, NULL, &me->nMaxSym, NULL),
      targetid = lGrid->objid,
      targetos = lGrid->osnum);

#ifdef MY_DEBUG
  printf ("in load, found %d ads-records\n",me->nMaxSym);
#endif

  status =
  om$vla_set_dimension (varray = me->Ladsrec,
                        size   = me->nMaxSym);

  status =
  om$send (msg = message VDADS.VDADS_grec
                         (&retmsg, NULL, NULL, &me->nMaxSym, me->Ladsrec),
      targetid = lGrid->objid,
      targetos = lGrid->osnum);

  if (me->nMaxSym > 0) me->nCurSym = 0;
  else                 me->nCurSym = -1;

  return (OM_S_SUCCESS);
}

method VDADS_Rtc (long    *retcode)
{

  *retcode = me->My_localret;

#ifdef MY_DEBUG
  printf ("retcode %d\n",me->My_localret);
#endif

  return OM_S_SUCCESS;
}


end implementation VDCmdADS;

