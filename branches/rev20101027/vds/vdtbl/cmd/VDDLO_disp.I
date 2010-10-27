
/* $Id: VDDLO_disp.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDDLO_disp.I
 *
 * Description:
 *
 * Initially display a table(index)/column/htf or field record in the form 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDLO_disp.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.3  2000/02/04  21:36:04  pinnacle
# (No comment)
#
# Revision 1.2  1999/07/14  20:49:32  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.5  1998/03/19  18:10:12  pinnacle
# Replaced: vdtbl/cmd/VDDLO_disp.I for:  by vgnair for vds
#
# Revision 1.4  1998/01/07  11:40:50  pinnacle
# Replaced: vdtbl/cmd/VDDLO_disp.I for:  by vgnair for vds
#
# Revision 1.3  1997/12/02  08:25:38  pinnacle
# Replaced: vdtbl/cmd/VDDLO_disp.I for:  by vgnair for vds
#
# Revision 1.2  1997/11/24  14:52:04  pinnacle
# Replaced: vdtbl/cmd/VDDLO_disp.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.15  1995/11/29  13:56:04  pinnacle
# Replaced: ./vdtbl/cmd/VDDLO_disp.I for:  by ksundar for vds.240
#
# Revision 1.14  1995/11/10  21:22:24  pinnacle
# Replaced: vdtbl/cmd/VDDLO_disp.I for:  by hverstee for vds.240
#
# Revision 1.13  1995/10/12  16:36:30  pinnacle
# Replaced: vdtbl/cmd/VDDLO_disp.I for:  by yzhu for vds.240
#
# Revision 1.12  1995/09/25  22:57:28  pinnacle
# Replaced: vdtbl/cmd/VDDLO_disp.I for:  by sundar for vds.240
#
# Revision 1.11  1995/09/20  22:04:04  pinnacle
# Replaced: vdtbl/cmd/VDDLO_disp.I for:  by hverstee for vds.240
#
# Revision 1.10  1995/09/08  19:37:02  pinnacle
# Replaced: vdtbl/cmd/VDDLO_disp.I for:  by hverstee for vds.240
#
# Revision 1.9  1995/09/05  23:17:10  pinnacle
# Replaced: vdtbl/cmd/VDDLO_disp.I for:  by hverstee for vds.240
#
# Revision 1.8  1995/08/29  20:32:14  pinnacle
# Replaced: vdtbl/cmd/VDDLO_disp.I for:  by hverstee for vds.240
#
# Revision 1.7  1995/08/14  22:45:26  pinnacle
# Replaced: vdtbl/cmd/VDDLO_disp.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/08/03  21:07:30  pinnacle
# Replaced: vdtbl/cmd/VDDLO_disp.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/07/11  21:56:26  pinnacle
# Replaced: vdtbl/cmd/VDDLO_disp.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/07/06  16:03:06  pinnacle
# Replaced: vdtbl/cmd/VDDLO_disp.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  19:59:50  pinnacle
# Replaced: vdtbl/cmd/VDDLO_disp.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/05/11  17:07:12  pinnacle
# Replaced: vdtbl/cmd/VDDLO_disp.I by hverstee r#
#
# Revision 1.2  1995/05/08  20:37:46  pinnacle
# Replaced: vdtbl/cmd/VDDLO_disp.I by hverstee r#
#
# Revision 1.1  1995/04/13  14:03:30  pinnacle
# Created: vdtbl/cmd/VDDLO_disp.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/20/95          HV            New
 *	12/02/97	  vini		Added cell
 * 	03/  /98 	  vini		TR-179800596
 *      07/13/99	  Ming	 	TR179900709
 *	02/04/00	  Ming		CR179901032
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
#include "vdtblmacros.h"

#include "grmacros.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grerr.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grdpbmacros.h"
#include "grsymmacros.h"
#include "griomacros.h"
#include "grmsg.h"

#include "VDCmdDrwlo.h"
#include "vdsmacros.h"

/*
#define  MY_DEBUG
*/



method   VDDLO_disp (char    * form_ptr)
{
  IGRint       status;
  IGRlong      retmsg;

  struct   VDdrwlo_ins_col  *pCLoc;
  struct   VDdrwlo_ins_htf  *pHLoc;
  struct   VDdrwlo_db_fld   *pFLoc;

  if (me->nCur_htfrec >= 0)
    pHLoc = &(me->Lhtfrec[me->nCur_htfrec]);
  else
    pHLoc = &(me->HtfCUR);

  if (me->nCur_colrec >= 0)
    pCLoc = &(me->Lcolrec[me->nCur_colrec]);
  else
    pCLoc = &(me->ColCUR);

  if (me->nCur_fldrec >= 0)
    pFLoc = &(me->Lfldrec[me->nCur_fldrec]);
  else
    pFLoc = &(me->FldCUR);

  switch (me->My_actv_form)
  {
    case VD_DLO_MAINFORM:
    default:

      status =
      om$send  (msg = message VDCmdDLO.VDDLO_dsp_em
                                (form_ptr, pCLoc, pHLoc, pFLoc),
           targetid = my_id);
      break;

    case VD_DLO_FILLFORM:

      status =
      om$send  (msg = message VDCmdDLO.VDDLO_dsp_ef
                                (form_ptr, pCLoc, pHLoc, pFLoc),
           targetid = my_id);
      break;

    case VD_RLO_MAINFORM:

      status =
      om$send  (msg = message VDCmdDLO.VDDLO_dsp_rm
                                (form_ptr, pCLoc, pHLoc, pFLoc),
           targetid = my_id);
      break;

    case VD_RLO_FILLFORM:

      status =
      om$send  (msg = message VDCmdDLO.VDDLO_dsp_rf
                                (form_ptr, pCLoc, pHLoc, pFLoc),
           targetid = my_id);
      break;

  }

  /*    update continuous preview   */

  if ((me->My_Preview_up) && (me->Pv_need_update))
  {
    IGRboolean   bGRonly;
    IGRboolean   bFit;

    bGRonly = TRUE;

    status =
    om$send (msg = message VDCmdDLO.VDDLO_pvdel (&retmsg, bGRonly),
        targetid = my_id);

    bFit = FALSE;

    status =
    om$send (msg = message VDCmdDLO.VDDLO_pvdsp (&retmsg, bFit),
        targetid = my_id);
  }

  return (status);
}

method   VDDLO_dsp_em (char             *form_ptr;
                struct VDdrwlo_ins_col  *pCLoc;
                struct VDdrwlo_ins_htf  *pHLoc;
                struct VDdrwlo_db_fld   *pFLoc)
{
  IGRint       status;
  IGRint       i, idsp, num_row = 0;
  IGRint       Selflag;
  IGRlong      retmsg;

  status  = OM_S_SUCCESS;
  Selflag = FALSE;

  /*   always redisplay general header   */

  FIg_set_text (form_ptr, VD_DLOM_FLD_TABNAM, me->CUR_tabnam);
  FIg_set_text (form_ptr, VD_DLOM_FLD_TABTYP, me->CUR_tabtyp);

  FIg_set_text (form_ptr, VD_DLOM_FLD_USERID, me->Ltbrec.Userid);
  FIg_set_text (form_ptr, VD_DLOM_FLD_DESCR , me->Ltbrec.Shdesc);
  FIg_set_text (form_ptr, VD_DLOM_FLD_TIMEST, me->Ltbrec.Timest);
  FIg_set_text (form_ptr, VD_DLOM_FLD_SUMM,   me->Ltbrec.SumFil);
  FIg_set_text (form_ptr, VD_DLOM_FLD_SORT,   me->Ltbrec.SortFil);

  FIg_set_value (form_ptr, VD_DLOM_TGG_DISPSEQ,
                          (double) me->Ltbrec.direct);

  if (me->Ltbrec.Local)
    FIg_set_text (form_ptr, VD_DLOM_FLD_LOCAL, "X");
  else
    FIg_set_text (form_ptr, VD_DLOM_FLD_LOCAL, " ");

  FIg_set_text (form_ptr, VD_DLOM_FLD_COPY,   "");

  if (me->bCP_lo)
  {
     FIg_set_state (form_ptr, VD_DLOM_BTN_COPY, 1);
     FIg_display   (form_ptr, VD_DLOM_FLD_COPY);
  }
  else
  {
     FIg_set_state (form_ptr, VD_DLOM_BTN_COPY, 0);
     FIg_erase     (form_ptr, VD_DLOM_FLD_COPY);
  }

  if (me->bCP_fld)
     FIg_set_state (form_ptr, VD_DLOH_BTN_COPY, 1);
  else
     FIg_set_state (form_ptr, VD_DLOH_BTN_COPY, 0);

  switch (me->nCur_group)
  {
    case VD_DRWLO_EN_ALL:

      /*    display header   */

      FIg_erase   (form_ptr, VD_DLOM_GRP_BOTH);
      FIg_erase   (form_ptr, VD_DLOM_GRP_COL);
      FIg_erase   (form_ptr, VD_DLOM_GRP_HTF);
      FIg_erase   (form_ptr, VD_DLOM_GRP_COLNO);
      FIg_erase   (form_ptr, VD_DLOM_GRP_HTFNO);
      FIg_erase   (form_ptr, VD_DLOH_FLD_COPY);

      FIg_set_text (form_ptr, VD_DLOM_FLD_GREDIT, "");
      break;

    case VD_DRWLO_EN_DATA:

      /*    display groups   */

      FIg_erase   (form_ptr, VD_DLOM_GRP_HTF);
      FIg_erase   (form_ptr, VD_DLOM_GRP_HTFNO);
      FIg_erase   (form_ptr, VD_DLOH_FLD_COPY);

      FIg_display (form_ptr, VD_DLOM_GRP_COL);

      FIg_set_value (form_ptr, VD_DLOC_FLD_COLNUM,
                 (double)me->nCur_colnum);

      if (me->nCur_colrec < 0)
      {
        FIg_erase   (form_ptr, VD_DLOM_GRP_BOTH);
        FIg_erase   (form_ptr, VD_DLOM_GRP_COLNO);
        break;
      }

      FIg_display (form_ptr, VD_DLOM_GRP_BOTH);
      FIg_display (form_ptr, VD_DLOM_GRP_COLNO);

      /*    display common gadgets   */

      FIg_set_value (form_ptr, VD_DLOB_FLD_NLINES,
            (double)     pCLoc->col_lns);
      FIg_set_value (form_ptr, VD_DLOB_FLD_LINSPC,
                         pCLoc->col_db.col_linspc);
      FIg_set_value (form_ptr, VD_DLOB_FLD_NUMCHR,
            (double)     pCLoc->col_db.col_chars);
      FIg_set_value (form_ptr, VD_DLOB_FLD_CHRHGT,
                         pCLoc->col_db.col_charhgt);
      FIg_set_value (form_ptr, VD_DLOB_FLD_CHRSPC,
                         pCLoc->col_db.col_charspc);
      FIg_set_value (form_ptr, VD_DLOB_FLD_CHRWDT,
                         pCLoc->col_db.col_charwdt);

      FIg_set_value (form_ptr, VD_DLOB_FLD_BLST,
             (double)    pCLoc->col_db.ltop_style);
      FIg_set_value (form_ptr, VD_DLOB_FLD_BLSB,
             (double)    pCLoc->col_db.lbot_style);
      FIg_set_value (form_ptr, VD_DLOB_FLD_BLSL,
             (double)    pCLoc->col_db.llft_style);
      FIg_set_value (form_ptr, VD_DLOB_FLD_BLSR,
             (double)    pCLoc->col_db.lrgt_style);

      FIg_set_value (form_ptr, VD_DLOB_FLD_BLWT,
             (double)    pCLoc->col_db.ltop_wgt);
      FIg_set_value (form_ptr, VD_DLOB_FLD_BLWB,
             (double)    pCLoc->col_db.lbot_wgt);
      FIg_set_value (form_ptr, VD_DLOB_FLD_BLWL,
             (double)    pCLoc->col_db.llft_wgt);
      FIg_set_value (form_ptr, VD_DLOB_FLD_BLWR,
             (double)    pCLoc->col_db.lrgt_wgt);

      FIg_set_value (form_ptr, VD_DLOB_CKL_BL_TR,
             (double)    pCLoc->col_db.bl_tr);
      FIg_set_value (form_ptr, VD_DLOB_CKL_TL_BR,
             (double)    pCLoc->col_db.tl_br);

      /*    and the specific column values   */

      FIg_set_value (form_ptr, VD_DLOC_FLD_COLHGT,
                         pCLoc->col_db.col_hgt);
      FIg_set_value (form_ptr, VD_DLOC_FLD_COLWDT,
                         pCLoc->col_db.col_wdt);
      break;

    case VD_DRWLO_EN_HEADER:
    case VD_DRWLO_EN_TRAILER:
    case VD_DRWLO_EN_BRKHDR:
    case VD_DRWLO_EN_BRKTRLR:

      FIg_erase   (form_ptr, VD_DLOM_GRP_COL);
      FIg_erase   (form_ptr, VD_DLOM_GRP_COLNO);

      /*    display groups   */

      FIg_display (form_ptr, VD_DLOM_GRP_HTF);
      FIg_erase   (form_ptr, VD_DLOH_FLD_COPY);

      /*  set field selection lists  */

      if (me->nFldTab > 5)
        FIfld_set_list_scroll (form_ptr, VD_DLOH_FLD_FLDID, 1, 0);
      else
        FIfld_set_list_scroll (form_ptr, VD_DLOH_FLD_FLDID, 0, 0);


      /* get list row number and clear previous field */

      FIfld_get_list_num_rows(form_ptr, VD_DLOH_FLD_FLDID, 0, &num_row);

      for (i=0; i<num_row; i++) {
              VDfld_set_list_text (form_ptr, VD_DLOH_FLD_FLDID, i, 0,
                             "", Selflag);
      }


      for (i=0; i<me->nFldTab; i++)
      {
        idsp = i*VD_DRWLO_CHR_IDFLD;

        VDfld_set_list_text (form_ptr, VD_DLOH_FLD_FLDID, i, 0,
                             &me->pFldTab[idsp], Selflag);
      }

      FIg_set_text (form_ptr, VD_DLOH_FLD_FLDID, me->sCur_fieldid);

      /*  set copy field   */

      if (me->nFtotTab > 5)
        FIfld_set_list_scroll (form_ptr, VD_DLOH_FLD_COPY, 1, 0);
      else
        FIfld_set_list_scroll (form_ptr, VD_DLOH_FLD_COPY, 0, 0);

      for (i=0; i<me->nFtotTab; i++)
      {
        idsp = i*VD_DRWLO_CHR_IDFLD;

        VDfld_set_list_text (form_ptr, VD_DLOH_FLD_COPY, i, 0,
                             &me->pFtotTab[idsp], Selflag);
      }

      FIg_set_text (form_ptr, VD_DLOH_FLD_COPY, "");

      if (me->bCP_fld)
         FIg_display (form_ptr, VD_DLOH_FLD_COPY);
      else
         FIg_erase   (form_ptr, VD_DLOH_FLD_COPY);

      /*    set alignment lists    */

      status =
      om$send (msg = message VDCmdDLO.VDDLO_set_alist
                                     (&retmsg, form_ptr, pHLoc),
          targetid = my_id);

      /*  display current alignment table   */

      FIfld_set_max_num_rows (form_ptr, VD_DLOH_FLD_OFFSET,
                                                 (int)me->nAlg_lines);
      FIfld_set_list_num_rows (form_ptr, VD_DLOH_FLD_OFFSET, 0,
                                                 (int)me->nAlg_lines);

      for (i=0; i<me->nAlg_lines; i++)
      {
        FIfld_set_value (form_ptr, VD_DLOH_FLD_OFFSET, i, 0,
                         (double) me->pCur_alg[i].aligncode, Selflag);
        FIfld_set_value (form_ptr, VD_DLOH_FLD_OFFSET, i, 1,
                         (double) me->pCur_alg[i].value, Selflag);
      }

      if (me->iarow > 0)
        FIfld_set_active_row (form_ptr, VD_DLOH_FLD_OFFSET,
                              me->iarow, me->iapos);

      /*    switching alignment edit    */

      if ((me->nAlg_curact != 0) && (me->nAlg_curact != me->nAlg_lines))
      {     /*    modify mode   (line active)    */
        FIg_erase   (form_ptr, VD_DLOH_TXT_ALGADD);
        FIg_display (form_ptr, VD_DLOH_TXT_ALGMOD);
        FIg_display (form_ptr, VD_DLOH_BTN_DELALG);
        Selflag = TRUE;

        FIfld_set_line_color (form_ptr, VD_DLOH_FLD_OFFSET,
                              (int)me->nAlg_curact, 1, FI_RED);
      }
      else
      {     /*    add mode    */
        FIg_erase   (form_ptr, VD_DLOH_BTN_DELALG);
        FIg_erase   (form_ptr, VD_DLOH_TXT_ALGMOD);
        FIg_display (form_ptr, VD_DLOH_TXT_ALGADD);
      }

      FIg_set_value (form_ptr, VD_DLOH_FLD_ALGMOD, (double)0.0);

      if (me->My_Focus == VD_DLOH_FLD_ALGMOD)
      { /*   force focus   */
        FIg_start_seq (form_ptr, VD_DLOH_FLD_ALGMOD);
      }

      if (me->nCur_htfrec < 0)
      {
        FIg_erase   (form_ptr, VD_DLOM_GRP_BOTH);
        FIg_erase   (form_ptr, VD_DLOM_GRP_HTFNO);
        break;
      }

      FIg_display (form_ptr, VD_DLOM_GRP_BOTH);
      FIg_display (form_ptr, VD_DLOM_GRP_HTFNO);

      /*    display common gadgets   */

      FIg_set_value (form_ptr, VD_DLOB_FLD_NLINES,
            (double)     pHLoc->htf_lns);
      FIg_set_value (form_ptr, VD_DLOB_FLD_LINSPC,
                         pHLoc->htf_db.fld_linspc);
      FIg_set_value (form_ptr, VD_DLOB_FLD_NUMCHR,
            (double)     pHLoc->htf_db.fld_chars);
      FIg_set_value (form_ptr, VD_DLOB_FLD_CHRHGT,
                         pHLoc->htf_db.fld_charhgt);
      FIg_set_value (form_ptr, VD_DLOB_FLD_CHRSPC,
                         pHLoc->htf_db.fld_charspc);
      FIg_set_value (form_ptr, VD_DLOB_FLD_CHRWDT,
                         pHLoc->htf_db.fld_charwdt);

      FIg_set_value (form_ptr, VD_DLOB_FLD_BLST,
             (double)    pHLoc->htf_db.ltop_style);
      FIg_set_value (form_ptr, VD_DLOB_FLD_BLSB,
             (double)    pHLoc->htf_db.lbot_style);
      FIg_set_value (form_ptr, VD_DLOB_FLD_BLSL,
             (double)    pHLoc->htf_db.llft_style);
      FIg_set_value (form_ptr, VD_DLOB_FLD_BLSR,
             (double)    pHLoc->htf_db.lrgt_style);

      FIg_set_value (form_ptr, VD_DLOB_FLD_BLWT,
             (double)    pHLoc->htf_db.ltop_wgt);
      FIg_set_value (form_ptr, VD_DLOB_FLD_BLWB,
             (double)    pHLoc->htf_db.lbot_wgt);
      FIg_set_value (form_ptr, VD_DLOB_FLD_BLWL,
             (double)    pHLoc->htf_db.llft_wgt);
      FIg_set_value (form_ptr, VD_DLOB_FLD_BLWR,
             (double)    pHLoc->htf_db.lrgt_wgt);

      FIg_set_value (form_ptr, VD_DLOB_CKL_BL_TR,
             (double)    pHLoc->htf_db.bl_tr);
      FIg_set_value (form_ptr, VD_DLOB_CKL_TL_BR,
             (double)    pHLoc->htf_db.tl_br);

        /*   display specific htf fields   */

      FIg_set_value (form_ptr, VD_DLOH_FLD_ALGT,
             (double)    pHLoc->htf_db.align_top);
      FIg_set_value (form_ptr, VD_DLOH_FLD_ALGB,
             (double)    pHLoc->htf_db.align_bot);
      FIg_set_value (form_ptr, VD_DLOH_FLD_ALGL,
             (double)    pHLoc->htf_db.align_lcol);
      FIg_set_value (form_ptr, VD_DLOH_FLD_ALGR,
             (double)    pHLoc->htf_db.align_rcol);

      FIg_set_value (form_ptr, VD_DLOH_FLD_FLDWDT,
                        (pHLoc->htf_x2 - pHLoc->htf_x1));
      FIg_set_value (form_ptr, VD_DLOH_FLD_FLDHGT,
                        (pHLoc->htf_y2 - pHLoc->htf_y1));
      break;

    default:
      break;
  }

  return (status);
}

method   VDDLO_dsp_ef (char             *form_ptr;
                struct VDdrwlo_ins_col  *pCLoc;
                struct VDdrwlo_ins_htf  *pHLoc;
                struct VDdrwlo_db_fld   *pFLoc)
{
  IGRint       status;
  IGRint       i, idsp;
  IGRint       Selflag;
  double       xmaxchar;
  IGRchar      szFld[10];
  IGRchar      *temp_ptr = NULL;
  IGRchar      temp_str[VD_DRWLO_CHR_TEXT];
  IGRlong      retmsg;
  struct GRid  lGRID;

  char 		null[1];
  int  		rows;
  char 		*cell;
  int 		cell_count ;
  IGRchar 	szmsg[60];

  IGRlong       sts,
                ret_msg;
  struct   GRactive_symbol_def     active_symbol;
  struct   GRsymbol_lib_file       file;
  struct   GRid                    symbol_id;

  sts      = MSSUCC;
  ret_msg  = MSSUCC;
  symbol_id.objid = NULL_OBJID;
  szmsg[0] = '\0';
  cell_count = 0 ;

  status  = OM_S_SUCCESS;
  Selflag = FALSE;

  FIg_set_value (form_ptr, VD_DLOF_FLD_LINENO, (double)me->nCur_linenum);

  if (pFLoc->hdtr_type == VD_DRWLO_EN_ALL)
    xmaxchar = 0;
  else
  if (pFLoc->hdtr_type == VD_DRWLO_EN_DATA)
    xmaxchar = pCLoc->col_db.col_chars;
  else
    xmaxchar = pHLoc->htf_db.fld_chars;

  FIfld_set_list_scroll (form_ptr, VD_DLOF_FLD_WEIGHT, 1, 0);

  for (i=0; i<32; i++)
  {
    sprintf (szFld,"%4d",i);

    VDfld_set_list_text (form_ptr, VD_DLOF_FLD_WEIGHT,
                                i, 0, szFld, Selflag);
  }

  FIg_set_value (form_ptr, VD_DLOF_FLD_WEIGHT, (double)  pFLoc->id_weight);

  FIg_set_value (form_ptr, VD_DLOF_FLD_MAXCHAR, xmaxchar);
  FIg_set_text  (form_ptr, VD_DLOF_FLD_FONT, pFLoc->id_Font);

  idsp = pFLoc->fieldtype * VD_DRWLO_CHR_IDFLD;
  FIg_set_text (form_ptr,VD_DLOF_FLD_FILL,&me->pr_filltyp[idsp]);

  idsp = pFLoc->datatype * VD_DRWLO_CHR_IDFLD;
  FIg_set_text (form_ptr,VD_DLOF_FLD_DTYPE,&me->pr_dattyp[idsp]);

  idsp = pFLoc->justification * VD_DRWLO_CHR_IDFLD;
  FIg_set_text (form_ptr, VD_DLOF_FLD_JUST, &me->pr_justif[idsp]);

  switch (pFLoc->fieldtype)
  {
    case VD_DRWLO_EN_TEXT:
      FIg_erase    (form_ptr, VD_DLOF_TXT_DEFTXT);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXPRESS);
      /*
      FIg_erase    (form_ptr, VD_DLOF_TXT_ATTRID);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXPID);
      */
      FIg_erase    (form_ptr, VD_DLOF_TXT_FIELDID);
      FIg_erase    (form_ptr, VD_DLOF_TXT_PARLIST);
      FIg_erase    (form_ptr, VD_DLOF_TXT_FMTSTR);
      FIg_erase    (form_ptr, VD_DLOF_TXT_DTYPE);
      FIg_erase    (form_ptr, VD_DLOF_TXT_DEC);
      FIg_erase    (form_ptr, VD_DLOF_FLD_DTYPE);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXPATT);
      FIg_erase    (form_ptr, VD_DLOF_FLD_DEC);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXTYP);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXNAM);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXTYP);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXNAM);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXPRESS);

      FIg_erase    (form_ptr, 25);
      FIg_erase    (form_ptr, 28);
      FIg_erase    (form_ptr, 30);
      FIg_erase    (form_ptr, 29);
      FIg_display  (form_ptr, 18);
      FIg_display  (form_ptr, 19);

      FIg_display  (form_ptr, VD_DLOF_TXT_DISTXT);
      FIg_display  (form_ptr, VD_DLOF_FLD_TEXT);

      FIg_set_text (form_ptr, VD_DLOF_FLD_TEXT, pFLoc->Ftext);
      break;

    case VD_DRWLO_EN_ATTRIBUTE:
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXPRESS);
      FIg_erase    (form_ptr, VD_DLOF_TXT_DISTXT);
      FIg_erase    (form_ptr, VD_DLOF_TXT_PARLIST);
      FIg_erase    (form_ptr, VD_DLOF_TXT_FMTSTR);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXTYP);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXNAM);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXTYP);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXNAM);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXPRESS);

      FIg_erase    (form_ptr, 27);
      FIg_erase    (form_ptr, 28);
      FIg_erase    (form_ptr, 30); 
      FIg_erase    (form_ptr, 29);
      FIg_display  (form_ptr, 18);
      FIg_display  (form_ptr, 19);

      FIg_display  (form_ptr, VD_DLOF_TXT_DEFTXT);
      /*
      FIg_display  (form_ptr, VD_DLOF_TXT_ATTRID);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXPID);
      */
      FIg_display  (form_ptr, VD_DLOF_TXT_DTYPE);

      FIg_display  (form_ptr, VD_DLOF_FLD_DTYPE);
      FIg_display  (form_ptr, VD_DLOF_FLD_EXPATT);
      FIg_display  (form_ptr, VD_DLOF_TXT_FIELDID);
      FIg_display  (form_ptr, VD_DLOF_FLD_TEXT);

      FIg_set_text (form_ptr, VD_DLOF_FLD_EXPATT, pFLoc->id_name);
      FIg_set_text (form_ptr, VD_DLOF_FLD_TEXT, pFLoc->Ftext);

      if (pFLoc->datatype == VD_DRWLO_EN_ASCII)
      {   /*   ascii, remove decimals field  */
        FIg_erase (form_ptr, VD_DLOF_TXT_DEC);
        FIg_erase (form_ptr, VD_DLOF_FLD_DEC);
      }
      else
      {
        FIg_display (form_ptr, VD_DLOF_TXT_DEC);
        FIg_display (form_ptr, VD_DLOF_FLD_DEC);
        FIg_set_value (form_ptr, VD_DLOF_FLD_DEC,(double) pFLoc->f_decimal);
      }
      break;

    case VD_DRWLO_EN_EXPRESSION:
      FIg_erase    (form_ptr, VD_DLOF_TXT_DEFTXT);
      /*
      FIg_erase    (form_ptr, VD_DLOF_TXT_ATTRID);
      FIg_display  (form_ptr, VD_DLOF_TXT_EXPID);
      */
      FIg_erase    (form_ptr, VD_DLOF_TXT_DISTXT);
      FIg_erase    (form_ptr, VD_DLOF_TXT_PARLIST);
      FIg_erase    (form_ptr, VD_DLOF_TXT_FMTSTR);
      FIg_erase    (form_ptr, VD_DLOF_TXT_DTYPE);
      FIg_erase    (form_ptr, VD_DLOF_FLD_DTYPE);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXTYP);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXNAM);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXTYP);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXNAM);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXPRESS);

      FIg_erase    (form_ptr, 27);
      FIg_erase    (form_ptr, 28);
      FIg_erase    (form_ptr, 30);
      FIg_erase    (form_ptr, 29);
      FIg_display  (form_ptr, 18);
      FIg_display  (form_ptr, 19);

      FIg_display  (form_ptr, VD_DLOF_TXT_EXPRESS);
      FIg_display  (form_ptr, VD_DLOF_TXT_DTYPE);

      FIg_display  (form_ptr, VD_DLOF_FLD_DTYPE);
      FIg_display  (form_ptr, VD_DLOF_FLD_EXPATT);
      FIg_display  (form_ptr, VD_DLOF_TXT_FIELDID);
      FIg_display  (form_ptr, VD_DLOF_FLD_TEXT);

      FIg_set_text (form_ptr, VD_DLOF_FLD_EXPATT, pFLoc->id_name);
      FIg_set_text (form_ptr, VD_DLOF_FLD_TEXT, pFLoc->Ftext);

      if (pFLoc->datatype == VD_DRWLO_EN_ASCII)
      {   /*   ascii, remove decimals field  */
        FIg_erase (form_ptr, VD_DLOF_TXT_DEC);
        FIg_erase (form_ptr, VD_DLOF_FLD_DEC);
      }
      else
      {
        FIg_display (form_ptr, VD_DLOF_TXT_DEC);
        FIg_display (form_ptr, VD_DLOF_FLD_DEC);
        FIg_set_value (form_ptr, VD_DLOF_FLD_DEC,(double) pFLoc->f_decimal);
      }
      break;

    case VD_DRWLO_EN_EXPR_TABLE:
      FIg_erase( form_ptr, VD_DLOF_TXT_DEFTXT  );
      /*
      FIg_erase( form_ptr, VD_DLOF_TXT_ATTRID  );
      FIg_display( form_ptr, VD_DLOF_TXT_EXPID   );
      */
      FIg_erase( form_ptr, VD_DLOF_TXT_DISTXT  );
      FIg_erase( form_ptr, VD_DLOF_TXT_PARLIST );
      FIg_erase( form_ptr, VD_DLOF_TXT_FMTSTR  );
      FIg_erase( form_ptr, VD_DLOF_TXT_DTYPE   );
      FIg_erase( form_ptr, VD_DLOF_FLD_DTYPE   );
      FIg_erase( form_ptr, VD_DLOF_FLD_TEXT    );

      FIg_erase    (form_ptr, 27);
      FIg_erase    (form_ptr, 28);
      FIg_erase    (form_ptr, 30);
      FIg_erase    (form_ptr, 29);
      FIg_display  (form_ptr, 18);
      FIg_display  (form_ptr, 19);

      FIg_display( form_ptr, VD_DLOF_TXT_EXPRESS );
      FIg_display( form_ptr, VD_DLOF_TXT_DTYPE   );

      FIg_display ( form_ptr, VD_DLOF_FLD_EXTYP );
      FIg_display ( form_ptr, VD_DLOF_TXT_EXTYP );
      FIg_display( form_ptr, VD_DLOF_FLD_EXNAM );
      FIg_display( form_ptr, VD_DLOF_TXT_EXNAM );

      FIg_display( form_ptr, VD_DLOF_FLD_DTYPE   );
      FIg_display( form_ptr, VD_DLOF_FLD_EXPRESS );
      FIg_display( form_ptr, VD_DLOF_FLD_EXPATT  );
      FIg_display  (form_ptr, VD_DLOF_TXT_FIELDID);

      FIg_set_text( form_ptr, VD_DLOF_FLD_EXPATT, pFLoc->id_name );

      status =
      om$send( msg      = message VDCmdDLO.VDDLO_exptyp(&retmsg, form_ptr),
               targetid = my_id );

      strcpy( temp_str, pFLoc->Ftext );
      temp_ptr = strchr( temp_str, ',' );
      if( temp_ptr != NULL )
      {
        *temp_ptr = '\0';
        ++temp_ptr;
        FIg_set_text( form_ptr, VD_DLOF_FLD_EXNAM , temp_ptr  );
        FIg_set_text( form_ptr, VD_DLOF_FLD_EXTYP , temp_str  );

        vd$tblexp_old( msg     = &retmsg,
                       osnum   = me->My_OS,
                       tabnam  = temp_ptr,
                       GRid    = &lGRID );
        if( lGRID.objid != NULL_OBJID )
        {
          status =
          om$send( msg      = message VDCmdDLO.VDDLO_expload(&retmsg,
                                                             form_ptr,
                                                             &lGRID),
                   targetid = my_id );
        }

        status =
        om$send( msg      = message VDCmdDLO.VDDLO_expnam(&retmsg,
                                                          form_ptr,
                                                          temp_str),
                 targetid = my_id );
      }

      if (pFLoc->datatype == VD_DRWLO_EN_ASCII)
      {   /*   ascii, remove decimals field  */
        FIg_erase( form_ptr, VD_DLOF_TXT_DEC );
        FIg_erase( form_ptr, VD_DLOF_FLD_DEC );
      }
      else
      {
        FIg_display( form_ptr, VD_DLOF_TXT_DEC );
        FIg_display( form_ptr, VD_DLOF_FLD_DEC );
        FIg_set_value( form_ptr, VD_DLOF_FLD_DEC, (double)pFLoc->f_decimal );
      }
      break;

    case VD_DRWLO_EN_FORMTEXT:
      FIg_erase    (form_ptr, VD_DLOF_TXT_DEFTXT);
      /*
      FIg_erase    (form_ptr, VD_DLOF_TXT_ATTRID);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXPID);
      */
      FIg_erase    (form_ptr, VD_DLOF_TXT_DISTXT);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXPRESS);
      FIg_erase    (form_ptr, VD_DLOF_TXT_DTYPE);
      FIg_erase    (form_ptr, VD_DLOF_TXT_DEC);
      FIg_erase    (form_ptr, VD_DLOF_FLD_DTYPE);
      FIg_erase    (form_ptr, VD_DLOF_FLD_DEC);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXTYP);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXNAM);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXTYP);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXNAM);
      FIg_erase    (form_ptr, VD_DLOF_TXT_FIELDID);

      FIg_display  (form_ptr, VD_DLOF_TXT_FMTSTR);
      FIg_display  (form_ptr, VD_DLOF_TXT_PARLIST);

      FIg_display  (form_ptr, VD_DLOF_FLD_EXPATT);
      FIg_display  (form_ptr, VD_DLOF_FLD_TEXT);

      FIg_set_text (form_ptr, VD_DLOF_FLD_EXPATT, pFLoc->id_name);
      FIg_set_text (form_ptr, VD_DLOF_FLD_TEXT, pFLoc->Ftext);
      break;

    case VD_DRWLO_EN_QUANTITY:
      FIg_erase    (form_ptr, VD_DLOF_TXT_DEFTXT);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXPRESS);
      /*
      FIg_erase    (form_ptr, VD_DLOF_TXT_ATTRID);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXPID);
      */
      FIg_erase    (form_ptr, VD_DLOF_TXT_DISTXT);
      FIg_erase    (form_ptr, VD_DLOF_TXT_PARLIST);
      FIg_erase    (form_ptr, VD_DLOF_TXT_FMTSTR);
      FIg_erase    (form_ptr, VD_DLOF_TXT_DTYPE);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXTYP);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXNAM);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXTYP);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXNAM);

      FIg_erase    (form_ptr, 27);
      FIg_erase    (form_ptr, 28);
      FIg_erase    (form_ptr, 30);
      FIg_erase    (form_ptr, 29);
      FIg_display  (form_ptr, 18);
      FIg_display  (form_ptr, 19);

      FIg_erase    (form_ptr, VD_DLOF_FLD_DTYPE);
      /*
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXPATT);
      */
      FIg_display  (form_ptr, VD_DLOF_FLD_EXPATT);
      FIg_display  (form_ptr, VD_DLOF_TXT_FIELDID);
      FIg_erase    (form_ptr, VD_DLOF_FLD_TEXT);

      FIg_display  (form_ptr, VD_DLOF_TXT_DEC);
      FIg_display  (form_ptr, VD_DLOF_FLD_DEC);
      FIg_set_value (form_ptr, VD_DLOF_FLD_DEC,(double) pFLoc->f_decimal);
      FIg_set_text (form_ptr, VD_DLOF_FLD_EXPATT, pFLoc->id_name);
      break;

/* for the cell */
case VD_DRWLO_EN_CELL:
	/* TR-179800596 */	if( me->nCur_group == 0 )break;
      FIg_erase    (form_ptr, VD_DLOF_TXT_DEFTXT);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXPRESS);
      /*
      FIg_erase    (form_ptr, VD_DLOF_TXT_ATTRID);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXPID);
      */
      FIg_erase    (form_ptr, VD_DLOF_TXT_PARLIST);
      FIg_erase    (form_ptr, VD_DLOF_TXT_FMTSTR);
      FIg_erase    (form_ptr, VD_DLOF_TXT_DTYPE);
      FIg_erase    (form_ptr, VD_DLOF_TXT_DEC);
      FIg_erase    (form_ptr, VD_DLOF_FLD_DTYPE);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXPATT);
      FIg_erase    (form_ptr, VD_DLOF_TXT_FIELDID);
      FIg_erase    (form_ptr, VD_DLOF_FLD_DEC);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXTYP);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXNAM);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXTYP);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXNAM);

      FIg_erase  (form_ptr, 18);
      FIg_display  (form_ptr, 27);

      FIg_erase  (form_ptr, VD_DLOF_TXT_DISTXT);
      FIg_erase  (form_ptr, 19);
      FIg_display  (form_ptr, 28);
      FIg_display  (form_ptr, VD_DLOF_TXT_CELLS);
      FIg_erase  (form_ptr, VD_DLOF_FLD_TEXT);
      FIg_display  (form_ptr, VD_DLOF_FLD_CELLS);

/* get the active lib and the cell */

      gr$symget_asl_info( msg = &ret_msg, file = &file);
      if( ret_msg == GR_I_NOSL)
      {
         pFLoc->id_Font[0] = NULL ;
         strcpy( szmsg," Active Library not defined");
      }

      /* Added by Ming for TR179900709 */
      {
        char *new_file_name = NULL;
        char firstDir[1024];
        char absPathName[1024];
	char tmp_file_name[1024];

	tmp_file_name[0] = '\0';
	strcpy( tmp_file_name, file.file_name );
        new_file_name = strrchr( tmp_file_name, '/' );

        if( !new_file_name )
        {
	  strcpy( pFLoc->id_Font , tmp_file_name );
        }
	else
	{
	  new_file_name++;
          strcpy( pFLoc->id_Font, new_file_name );
	  strcpy( file.file_name, new_file_name );
	}

        firstDir[0] = absPathName[0] = '\0';
        strcpy( firstDir, "." );

        status =
        vd$file_path( msg = &retmsg,
                      fileToFind = file.file_name,
                      dirToSearchFirst = firstDir,
                      dirInProdPathToSearchThen = VD_DLO_CELL_CONFIG_RELPATH,
                      absPathName = absPathName );

        if( status&retmsg&1 )
          strcpy( file.file_name, absPathName );
	else
	  goto wrapup;
      }

      status = gr$symretrieve_cell_library( filename = file.file_name,
                			    file_no = &file.file_no,
                			    flag = EX_read_write | EX_read_only,
                			    fstat = EX_old_module );

      if( status == GR_E_NO_FILE )
      {
        printf( "File Does Not Exist!\n" );
        goto wrapup;
      }
      else if( status == GR_E_NOT_CELL_LIB)
      {
        printf( "File Not A Cell Library!\n" );
        goto wrapup;
      }
      else if( status == GR_E_NO_PREMISSION )
      {
        printf( "No Permission for Operation!\n" );
        goto wrapup;
      }
      else if( !(status&1) ) goto wrapup;

      status = gr$symput_asl( msg  = &ret_msg,
                     	      file = &file);

      /* Commented by Ming 
        strcpy(pFLoc->id_Font , file.file_name);

        for the active cell

        gr$symget_active_symbol (msg = &ret_msg,
                   act_symbol_def = &active_symbol);
        if(ret_msg == MSSUCC)
                strcpy( pFLoc->Ftext,active_symbol.name);
        else pFLoc->Ftext[0] = '\0';
      */

        cell = NULL;

        /* for the cells in the library */

        gr$get_cell_def_info( p_count = &cell_count,
                        pp_names = &cell);

       if(cell_count == 0 )
            strcpy (szmsg, " Cells not defined in the library \n");


        FIg_set_text(form_ptr, VD_DLOF_FLD_CELLS, pFLoc->Ftext);

        null[0] = '\0';
        FIfld_get_list_num_rows( form_ptr, VD_DLOF_FLD_CELLS,0, &rows );
     for (i=0; i<rows; i++) {
        VDfld_set_list_text (form_ptr, VD_DLOF_FLD_CELLS, i, 0,
                        null, Selflag);
        }


  if (cell_count > 5)
    FIfld_set_list_scroll (form_ptr, VD_DLOF_FLD_CELLS, 1, 0);
  else
    FIfld_set_list_scroll (form_ptr, VD_DLOF_FLD_CELLS, 0, 0);

  for (i=0; i<cell_count; i++)
  {

    VDfld_set_list_text (form_ptr, VD_DLOF_FLD_CELLS, i, 0,
               &cell[MAX_SYMBOL_DEF_NAME * i], Selflag);
  }


        FIg_set_text(form_ptr, VD_DLOF_FLD_LIBRY, pFLoc->id_Font );
        FIg_set_text (form_ptr, VD_DLOF_FLD_CELLS, pFLoc->Ftext);
        if (cell != NULL) free(cell);
        FIg_set_text (form_ptr, VD_DLOM_FLD_MSG, szmsg);
      break;

    case VD_DRWLO_EN_USERDEFINED:
    case VD_DRWLO_EN_OVERFLOW:
    case VD_DRWLO_EN_ITEMNO:
    default:
      FIg_erase    (form_ptr, VD_DLOF_TXT_DEFTXT);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXPRESS);
      /*
      FIg_erase    (form_ptr, VD_DLOF_TXT_ATTRID);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXPID);
      */
      FIg_erase    (form_ptr, VD_DLOF_TXT_DISTXT);
      FIg_erase    (form_ptr, VD_DLOF_TXT_PARLIST);
      FIg_erase    (form_ptr, VD_DLOF_TXT_FMTSTR);
      FIg_erase    (form_ptr, VD_DLOF_TXT_DTYPE);
      FIg_erase    (form_ptr, VD_DLOF_TXT_DEC);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXTYP);
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXNAM);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXTYP);
      FIg_erase    (form_ptr, VD_DLOF_TXT_EXNAM);

      FIg_erase    (form_ptr, VD_DLOF_FLD_DTYPE);
      /*
      FIg_erase    (form_ptr, VD_DLOF_FLD_EXPATT);
      */
      FIg_display  (form_ptr, VD_DLOF_FLD_EXPATT);
      FIg_display  (form_ptr, VD_DLOF_TXT_FIELDID);
      FIg_erase    (form_ptr, VD_DLOF_FLD_TEXT);
      FIg_erase    (form_ptr, VD_DLOF_FLD_DEC);

      FIg_erase    (form_ptr, 27);
      FIg_erase    (form_ptr, 28);
      FIg_erase    (form_ptr, 30);
      FIg_erase    (form_ptr, 29);
      FIg_display  (form_ptr, 18);
      FIg_display  (form_ptr, 19);
      FIg_set_text (form_ptr, VD_DLOF_FLD_EXPATT, pFLoc->id_name);

      break;
  }

wrapup:
  return (status);
}

method   VDDLO_dsp_rm (char             *form_ptr;
                struct VDdrwlo_ins_col  *pCLoc;
                struct VDdrwlo_ins_htf  *pHLoc;
                struct VDdrwlo_db_fld   *pFLoc)
{
  IGRint       status;
  IGRint       i, idsp;
  IGRint       Selflag;

  status  = OM_S_SUCCESS;
  Selflag = FALSE;

  switch (me->nCur_group)
  {
    case VD_DRWLO_EN_ALL:

      /*    display header   */

      FIg_erase   (form_ptr, VD_RLOM_GRP_BOTH);
      FIg_erase   (form_ptr, VD_RLOM_GRP_COL);
      FIg_erase   (form_ptr, VD_RLOM_GRP_HTF);

      FIg_set_text (form_ptr, VD_RLOM_FLD_TABNAM, me->Ltbrec.Tabnam);
      FIg_set_text (form_ptr, VD_RLOM_FLD_TABTYP, me->Ltbrec.Tabtyp);
      FIg_set_text (form_ptr, VD_RLOM_FLD_USERID, me->Ltbrec.Userid);
      FIg_set_text (form_ptr, VD_RLOM_FLD_DESCR , me->Ltbrec.Shdesc);
      FIg_set_text (form_ptr, VD_RLOM_FLD_TIMEST, me->Ltbrec.Timest);
      FIg_set_text (form_ptr, VD_RLOM_FLD_SUMM,   me->Ltbrec.SumFil);
      FIg_set_text (form_ptr, VD_RLOM_FLD_SORT,   me->Ltbrec.SortFil);

      if (me->Ltbrec.direct == VD_DRWLO_EN_DESCEND)
        FIg_set_text (form_ptr, VD_RLOM_FLD_DISPSEQ, "Descending");
      else
        FIg_set_text (form_ptr, VD_RLOM_FLD_DISPSEQ, "Ascending");

      if (me->Ltbrec.Local)
        FIg_set_text (form_ptr, VD_RLOM_FLD_LOCAL, "X");
      else
        FIg_set_text (form_ptr, VD_RLOM_FLD_LOCAL, " ");
      break;

    case VD_DRWLO_EN_DATA:

      /*    display groups   */

      FIg_erase   (form_ptr, VD_RLOM_GRP_HTF);
      if (me->nCur_colrec >= 0)
        FIg_display (form_ptr, VD_RLOM_GRP_BOTH);
      else
        FIg_erase   (form_ptr, VD_RLOM_GRP_BOTH);

      FIg_display (form_ptr, VD_RLOM_GRP_COL);

      /*    display common gadgets   */

      FIg_set_value (form_ptr, VD_RLOB_FLD_NLINES,
            (double)     pCLoc->col_lns);
      FIg_set_value (form_ptr, VD_RLOB_FLD_LINSPC,
                         pCLoc->col_db.col_linspc);
      FIg_set_value (form_ptr, VD_RLOB_FLD_NUMCHR,
            (double)     pCLoc->col_db.col_chars);
      FIg_set_value (form_ptr, VD_RLOB_FLD_CHRHGT,
                         pCLoc->col_db.col_charhgt);
      FIg_set_value (form_ptr, VD_RLOB_FLD_CHRSPC,
                         pCLoc->col_db.col_charspc);
      FIg_set_value (form_ptr, VD_RLOB_FLD_CHRWDT,
                         pCLoc->col_db.col_charwdt);

      FIg_set_value (form_ptr, VD_RLOB_FLD_BLST,
             (double)    pCLoc->col_db.ltop_style);
      FIg_set_value (form_ptr, VD_RLOB_FLD_BLSB,
             (double)    pCLoc->col_db.lbot_style);
      FIg_set_value (form_ptr, VD_RLOB_FLD_BLSL,
             (double)    pCLoc->col_db.llft_style);
      FIg_set_value (form_ptr, VD_RLOB_FLD_BLSR,
             (double)    pCLoc->col_db.lrgt_style);

      FIg_set_value (form_ptr, VD_RLOB_FLD_BLWT,
             (double)    pCLoc->col_db.ltop_wgt);
      FIg_set_value (form_ptr, VD_RLOB_FLD_BLWB,
             (double)    pCLoc->col_db.lbot_wgt);
      FIg_set_value (form_ptr, VD_RLOB_FLD_BLWL,
             (double)    pCLoc->col_db.llft_wgt);
      FIg_set_value (form_ptr, VD_RLOB_FLD_BLWR,
             (double)    pCLoc->col_db.lrgt_wgt);

      FIg_set_value (form_ptr, VD_RLOB_CKL_BL_TR,
             (double)    pCLoc->col_db.bl_tr);
      FIg_set_value (form_ptr, VD_RLOB_CKL_TL_BR,
             (double)    pCLoc->col_db.tl_br);

      /*    and the specific column values   */

      FIg_set_value (form_ptr, VD_RLOC_FLD_COLNUM,
                     (double)me->nCur_colnum);

      FIg_set_value (form_ptr, VD_RLOC_FLD_COLHGT,
                         pCLoc->col_db.col_hgt);
      FIg_set_value (form_ptr, VD_RLOC_FLD_COLWDT,
                         pCLoc->col_db.col_wdt);
      break;

    case VD_DRWLO_EN_HEADER:
    case VD_DRWLO_EN_TRAILER:
    case VD_DRWLO_EN_BRKHDR:
    case VD_DRWLO_EN_BRKTRLR:

      /*    display groups   */

      FIg_erase   (form_ptr, VD_RLOM_GRP_COL);
      if (me->nCur_htfrec >= 0)
        FIg_display (form_ptr, VD_RLOM_GRP_BOTH);
      else
        FIg_erase   (form_ptr, VD_RLOM_GRP_BOTH);

      FIg_display (form_ptr, VD_RLOM_GRP_HTF);

      /*    display common gadgets   */

      FIg_set_value (form_ptr, VD_RLOB_FLD_NLINES,
            (double)     pHLoc->htf_lns);
      FIg_set_value (form_ptr, VD_RLOB_FLD_LINSPC,
                         pHLoc->htf_db.fld_linspc);
      FIg_set_value (form_ptr, VD_RLOB_FLD_NUMCHR,
            (double)     pHLoc->htf_db.fld_chars);
      FIg_set_value (form_ptr, VD_RLOB_FLD_CHRHGT,
                         pHLoc->htf_db.fld_charhgt);
      FIg_set_value (form_ptr, VD_RLOB_FLD_CHRSPC,
                         pHLoc->htf_db.fld_charspc);
      FIg_set_value (form_ptr, VD_RLOB_FLD_CHRWDT,
                         pHLoc->htf_db.fld_charwdt);

      FIg_set_value (form_ptr, VD_RLOB_FLD_BLST,
             (double)    pHLoc->htf_db.ltop_style);
      FIg_set_value (form_ptr, VD_RLOB_FLD_BLSB,
             (double)    pHLoc->htf_db.lbot_style);
      FIg_set_value (form_ptr, VD_RLOB_FLD_BLSL,
             (double)    pHLoc->htf_db.llft_style);
      FIg_set_value (form_ptr, VD_RLOB_FLD_BLSR,
             (double)    pHLoc->htf_db.lrgt_style);

      FIg_set_value (form_ptr, VD_RLOB_FLD_BLWT,
             (double)    pHLoc->htf_db.ltop_wgt);
      FIg_set_value (form_ptr, VD_RLOB_FLD_BLWB,
             (double)    pHLoc->htf_db.lbot_wgt);
      FIg_set_value (form_ptr, VD_RLOB_FLD_BLWL,
             (double)    pHLoc->htf_db.llft_wgt);
      FIg_set_value (form_ptr, VD_RLOB_FLD_BLWR,
             (double)    pHLoc->htf_db.lrgt_wgt);

      FIg_set_value (form_ptr, VD_RLOB_CKL_BL_TR,
             (double)    pHLoc->htf_db.bl_tr);
      FIg_set_value (form_ptr, VD_RLOB_CKL_TL_BR,
             (double)    pHLoc->htf_db.tl_br);

      /*   display specific htf fields   */

      FIg_set_text (form_ptr, VD_RLOH_FLD_FLDID, me->sCur_fieldid);

      FIg_set_value (form_ptr, VD_RLOH_FLD_ALGT,
             (double)    pHLoc->htf_db.align_top);
      FIg_set_value (form_ptr, VD_RLOH_FLD_ALGB,
             (double)    pHLoc->htf_db.align_bot);
      FIg_set_value (form_ptr, VD_RLOH_FLD_ALGL,
             (double)    pHLoc->htf_db.align_lcol);
      FIg_set_value (form_ptr, VD_RLOH_FLD_ALGR,
             (double)    pHLoc->htf_db.align_rcol);

      FIg_set_value (form_ptr, VD_RLOH_FLD_FLDWDT,
                        (pHLoc->htf_x2 - pHLoc->htf_x1));
      FIg_set_value (form_ptr, VD_RLOH_FLD_FLDHGT,
                        (pHLoc->htf_y2 - pHLoc->htf_y1));

      /*  set field selection list  */

      if (me->nFldTab > 5)
        FIfld_set_list_scroll (form_ptr, VD_RLOH_FLD_FLDID, 1, 0);
      else
        FIfld_set_list_scroll (form_ptr, VD_RLOH_FLD_FLDID, 0, 0);

      FIfld_set_list_num_rows (form_ptr, VD_RLOH_FLD_FLDID, 0,
                                 (int) me->nFldTab);

      for (i=0; i<me->nFldTab; i++)
      {
        idsp = i * VD_DRWLO_CHR_IDFLD;

        VDfld_set_list_text (form_ptr, VD_RLOH_FLD_FLDID, i, 0,
                             &me->pFldTab[idsp], Selflag);
      }

      /*  display current alignment table   */

      FIfld_set_max_num_rows (form_ptr, VD_RLOH_FLD_OFFSET,
                                             (int)me->nAlg_alloc);
      FIfld_set_list_num_rows (form_ptr, VD_RLOH_FLD_OFFSET, 0,
                                             (int)me->nAlg_lines);

      for (i=0; i<me->nAlg_lines; i++)
      {
        FIfld_set_value (form_ptr, VD_RLOH_FLD_OFFSET, i, 0,
                         (double) me->pCur_alg[i].aligncode, Selflag);
        FIfld_set_value (form_ptr, VD_RLOH_FLD_OFFSET, i, 1,
                         (double) me->pCur_alg[i].value, Selflag);
      }
      break;

    default:
      break;
  }

  return (status);
}

method   VDDLO_dsp_rf (char             *form_ptr;
                struct VDdrwlo_ins_col  *pCLoc;
                struct VDdrwlo_ins_htf  *pHLoc;
                struct VDdrwlo_db_fld   *pFLoc)
{
  IGRint       status;
  IGRint       idsp;
  IGRint       Selflag;
  double       xmaxchar;
  IGRchar      *temp_ptr = NULL;
  IGRchar      temp_str[VD_DRWLO_CHR_TEXT];
  IGRlong      retmsg;
  struct GRid  lGRID;

  status  = OM_S_SUCCESS;
  Selflag = FALSE;

  FIg_set_value (form_ptr, VD_RLOF_FLD_LINENUM, (double)me->nCur_linenum);

  if (pFLoc->hdtr_type == VD_DRWLO_EN_ALL)
    xmaxchar = 0;
  else
  if (pFLoc->hdtr_type == VD_DRWLO_EN_DATA)
    xmaxchar = pCLoc->col_db.col_chars;
  else
    xmaxchar = pHLoc->htf_db.fld_chars;

  FIg_set_value (form_ptr, VD_RLOF_FLD_MAXCHAR, xmaxchar);
  FIg_set_value (form_ptr, VD_RLOF_FLD_WEIGHT, (double)  pFLoc->id_weight);
  FIg_set_text  (form_ptr, VD_RLOF_FLD_FONT, pFLoc->id_Font);

  idsp = pFLoc->fieldtype * VD_DRWLO_CHR_IDFLD;
  FIg_set_text (form_ptr,VD_RLOF_FLD_FILL,&me->pr_filltyp[idsp]);

  idsp = pFLoc->datatype * VD_DRWLO_CHR_IDFLD;
  FIg_set_text (form_ptr,VD_RLOF_FLD_DTYPE,&me->pr_dattyp[idsp]);

  idsp = pFLoc->justification * VD_DRWLO_CHR_IDFLD;
  FIg_set_text (form_ptr, VD_RLOF_FLD_JUST, &me->pr_justif[idsp]);

  switch (pFLoc->fieldtype)
  {
    case VD_DRWLO_EN_TEXT:
      FIg_erase    (form_ptr, VD_RLOF_TXT_DEFTXT);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXPRESS);
      /*
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXPID);
      FIg_erase    (form_ptr, VD_RLOF_TXT_ATTRID);
      */
      FIg_erase    (form_ptr, VD_RLOF_TXT_FIELDID);
      FIg_erase    (form_ptr, VD_RLOF_TXT_FMTSTR);
      FIg_erase    (form_ptr, VD_RLOF_TXT_PARLIST);
      FIg_erase    (form_ptr, VD_RLOF_TXT_DTYPE);
      FIg_erase    (form_ptr, VD_RLOF_TXT_DEC);
      FIg_erase    (form_ptr, VD_RLOF_FLD_DTYPE);
      FIg_erase    (form_ptr, VD_RLOF_FLD_EXPATT);
      FIg_erase    (form_ptr, VD_RLOF_FLD_DEC);
      FIg_erase    (form_ptr, VD_RLOF_FLD_EXTYP);
      FIg_erase    (form_ptr, VD_RLOF_FLD_EXNAM);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXTYP);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXNAM);

      FIg_erase    (form_ptr, 26);
      FIg_erase    (form_ptr, 21);
      FIg_display  (form_ptr, 19);

      FIg_display  (form_ptr, VD_RLOF_TXT_DISTXT);
      FIg_display  (form_ptr, VD_RLOF_FLD_TEXT);


      FIg_set_text (form_ptr, VD_RLOF_FLD_TEXT, pFLoc->Ftext);
      break;

    case VD_DRWLO_EN_ATTRIBUTE:
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXPRESS);
      FIg_erase    (form_ptr, VD_RLOF_TXT_DISTXT);
      FIg_erase    (form_ptr, VD_RLOF_TXT_FMTSTR);
      FIg_erase    (form_ptr, VD_RLOF_TXT_PARLIST);
      FIg_erase    (form_ptr, VD_RLOF_FLD_EXTYP);
      FIg_erase    (form_ptr, VD_RLOF_FLD_EXNAM);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXTYP);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXNAM);


      FIg_erase    (form_ptr, 26);
      FIg_erase    (form_ptr, 21);
      FIg_display  (form_ptr, 19);

      FIg_display  (form_ptr, VD_RLOF_TXT_DEFTXT);
      /*
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXPID);
      FIg_display  (form_ptr, VD_RLOF_TXT_ATTRID);
      */
      FIg_display  (form_ptr, VD_RLOF_TXT_FIELDID);
      FIg_display  (form_ptr, VD_RLOF_TXT_DTYPE);

      FIg_display  (form_ptr, VD_RLOF_FLD_DTYPE);
      FIg_display  (form_ptr, VD_RLOF_FLD_EXPATT);
      FIg_display  (form_ptr, VD_RLOF_FLD_TEXT);

      FIg_set_text (form_ptr, VD_RLOF_FLD_EXPATT, pFLoc->id_name);
      FIg_set_text (form_ptr, VD_RLOF_FLD_TEXT, pFLoc->Ftext);

      if (pFLoc->datatype == VD_DRWLO_EN_ASCII)
      {   /*   ascii, remove decimals field  */
        FIg_erase (form_ptr, VD_RLOF_TXT_DEC);
        FIg_erase (form_ptr, VD_RLOF_FLD_DEC);
      }
      else
      {
        FIg_display (form_ptr, VD_RLOF_TXT_DEC);
        FIg_display (form_ptr, VD_RLOF_FLD_DEC);
        FIg_set_value (form_ptr, VD_RLOF_FLD_DEC,(double) pFLoc->f_decimal);
      }
      break;

    case VD_DRWLO_EN_EXPRESSION:
      FIg_erase    (form_ptr, VD_RLOF_TXT_DEFTXT);
      /*
      FIg_erase    (form_ptr, VD_RLOF_TXT_ATTRID);
      FIg_display  (form_ptr, VD_RLOF_TXT_EXPID);
      */
      FIg_erase    (form_ptr, VD_RLOF_TXT_DISTXT);
      FIg_erase    (form_ptr, VD_RLOF_TXT_FMTSTR);
      FIg_erase    (form_ptr, VD_RLOF_TXT_PARLIST);
      FIg_erase    (form_ptr, VD_RLOF_FLD_EXTYP);
      FIg_erase    (form_ptr, VD_RLOF_FLD_EXNAM);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXTYP);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXNAM);

      FIg_erase    (form_ptr, 26);
      FIg_erase    (form_ptr, 21);
      FIg_display  (form_ptr, 19);


      FIg_display  (form_ptr, VD_RLOF_TXT_DTYPE);
      FIg_display  (form_ptr, VD_RLOF_FLD_DTYPE);
      FIg_display  (form_ptr, VD_RLOF_TXT_EXPRESS);
      FIg_display  (form_ptr, VD_RLOF_TXT_FIELDID);

      FIg_display  (form_ptr, VD_RLOF_FLD_EXPATT);
      FIg_display  (form_ptr, VD_RLOF_FLD_TEXT);

      FIg_set_text (form_ptr, VD_RLOF_FLD_EXPATT, pFLoc->id_name);
      FIg_set_text (form_ptr, VD_RLOF_FLD_TEXT, pFLoc->Ftext);

      if (pFLoc->datatype == VD_DRWLO_EN_ASCII)
      {   /*   ascii, remove decimals field  */
        FIg_erase (form_ptr, VD_RLOF_TXT_DEC);
        FIg_erase (form_ptr, VD_RLOF_FLD_DEC);
      }
      else
      {
        FIg_display (form_ptr, VD_RLOF_TXT_DEC);
        FIg_display (form_ptr, VD_RLOF_FLD_DEC);
        FIg_set_value (form_ptr, VD_RLOF_FLD_DEC,(double) pFLoc->f_decimal);
      }
      break;

    case VD_DRWLO_EN_EXPR_TABLE:
      FIg_erase( form_ptr, VD_RLOF_TXT_DEFTXT  );
      /*
      FIg_erase( form_ptr, VD_RLOF_TXT_ATTRID  );
      FIg_display( form_ptr, VD_RLOF_TXT_EXPID );
      */
      FIg_erase( form_ptr, VD_RLOF_TXT_DISTXT  );
      FIg_erase( form_ptr, VD_RLOF_TXT_PARLIST );
      FIg_erase( form_ptr, VD_RLOF_TXT_FMTSTR  );
      FIg_erase( form_ptr, VD_RLOF_TXT_DTYPE   );
      FIg_erase( form_ptr, VD_RLOF_FLD_DTYPE   );

      FIg_erase    (form_ptr, 26);
      FIg_erase    (form_ptr, 21);
      FIg_display  (form_ptr, 19);

      FIg_display( form_ptr, VD_RLOF_TXT_EXPRESS );
      FIg_display( form_ptr, VD_RLOF_TXT_DTYPE   );
      FIg_display( form_ptr, VD_RLOF_FLD_TEXT    );
      FIg_display( form_ptr, VD_RLOF_TXT_FIELDID    );

      FIg_display ( form_ptr, VD_RLOF_FLD_EXTYP );
      FIg_display ( form_ptr, VD_RLOF_TXT_EXTYP );
      FIg_display( form_ptr, VD_RLOF_FLD_EXNAM );
      FIg_display( form_ptr, VD_RLOF_TXT_EXNAM );

      FIg_display( form_ptr, VD_RLOF_FLD_DTYPE   );
      FIg_display( form_ptr, VD_RLOF_FLD_EXPATT  );

      FIg_set_text( form_ptr, VD_RLOF_FLD_EXPATT, pFLoc->id_name );

      strcpy( temp_str, pFLoc->Ftext );
      temp_ptr = strchr( temp_str, ',' );
      if( temp_ptr != NULL )
      {
        *temp_ptr = '\0';
        ++temp_ptr;
        FIg_set_text( form_ptr, VD_RLOF_FLD_EXNAM , temp_ptr  );
        FIg_set_text( form_ptr, VD_RLOF_FLD_EXTYP , temp_str  );

        vd$tblexp_old( msg     = &retmsg,
                       osnum   = me->My_OS,
                       tabnam  = temp_ptr,
                       GRid    = &lGRID );
        status =
        om$send( msg      = message VDCmdDLO.VDDLO_expload(&retmsg,
                                                           form_ptr,
                                                           &lGRID),
                 targetid = my_id );
      }

      if (pFLoc->datatype == VD_DRWLO_EN_ASCII)
      {   /*   ascii, remove decimals field  */
        FIg_erase( form_ptr, VD_RLOF_TXT_DEC );
        FIg_erase( form_ptr, VD_RLOF_FLD_DEC );
      }
      else
      {
        FIg_display( form_ptr, VD_RLOF_TXT_DEC );
        FIg_display( form_ptr, VD_RLOF_FLD_DEC );
        FIg_set_value( form_ptr, VD_RLOF_FLD_DEC, (double)pFLoc->f_decimal );
      }
      break;

    case VD_DRWLO_EN_FORMTEXT:
      FIg_erase    (form_ptr, VD_RLOF_TXT_DEFTXT);
      /*
      FIg_erase    (form_ptr, VD_RLOF_TXT_ATTRID);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXPID);
      */
      FIg_erase    (form_ptr, VD_RLOF_TXT_FIELDID);
      FIg_erase    (form_ptr, VD_RLOF_TXT_DISTXT);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXPRESS);
      FIg_erase    (form_ptr, VD_RLOF_TXT_DTYPE);
      FIg_erase    (form_ptr, VD_RLOF_TXT_DEC);
      FIg_erase    (form_ptr, VD_RLOF_FLD_DTYPE);
      FIg_erase    (form_ptr, VD_RLOF_FLD_DEC);
      FIg_erase    (form_ptr, VD_RLOF_FLD_EXTYP);
      FIg_erase    (form_ptr, VD_RLOF_FLD_EXNAM);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXTYP);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXNAM);

      FIg_erase    (form_ptr, 26);
      FIg_erase    (form_ptr, 21);
      FIg_display  (form_ptr, 19);


      FIg_display  (form_ptr, VD_RLOF_TXT_FMTSTR);
      FIg_display  (form_ptr, VD_RLOF_TXT_PARLIST);

      FIg_display  (form_ptr, VD_RLOF_FLD_EXPATT);
      FIg_display  (form_ptr, VD_RLOF_FLD_TEXT);

      FIg_set_text (form_ptr, VD_RLOF_FLD_EXPATT, pFLoc->id_name);
      FIg_set_text (form_ptr, VD_RLOF_FLD_TEXT, pFLoc->Ftext);
      break;

    case VD_DRWLO_EN_QUANTITY:
      FIg_erase    (form_ptr, VD_RLOF_TXT_DEFTXT);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXPRESS);
      /*
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXPID);
      FIg_erase    (form_ptr, VD_RLOF_TXT_ATTRID);
      */
      FIg_erase    (form_ptr, VD_RLOF_TXT_DISTXT);
      FIg_erase    (form_ptr, VD_RLOF_TXT_FMTSTR);
      FIg_erase    (form_ptr, VD_RLOF_TXT_PARLIST);
      FIg_erase    (form_ptr, VD_RLOF_TXT_DTYPE);
      FIg_erase    (form_ptr, VD_RLOF_FLD_EXTYP);
      FIg_erase    (form_ptr, VD_RLOF_FLD_EXNAM);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXTYP);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXNAM);

      FIg_erase    (form_ptr, 26);
      FIg_erase    (form_ptr, 21);
      FIg_display  (form_ptr, 19);

      FIg_erase    (form_ptr, VD_RLOF_FLD_DTYPE);
      /*
      FIg_erase    (form_ptr, VD_RLOF_FLD_EXPATT);
      */
      FIg_display  (form_ptr, VD_RLOF_TXT_FIELDID);
      FIg_display  (form_ptr, VD_RLOF_FLD_EXPATT);
      FIg_set_text (form_ptr, VD_RLOF_FLD_EXPATT, pFLoc->id_name);
      FIg_erase    (form_ptr, VD_RLOF_FLD_TEXT);

      FIg_display  (form_ptr, VD_RLOF_TXT_DEC);
      FIg_display  (form_ptr, VD_RLOF_FLD_DEC);
      FIg_set_value (form_ptr, VD_RLOF_FLD_DEC,(double) pFLoc->f_decimal);
      break;

case 9:

      FIg_erase    (form_ptr, VD_RLOF_TXT_DEFTXT);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXPRESS);
      /*
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXPID);
      FIg_erase    (form_ptr, VD_RLOF_TXT_ATTRID);
      */
      FIg_erase    (form_ptr, VD_RLOF_TXT_FIELDID);
      FIg_erase    (form_ptr, VD_RLOF_TXT_FMTSTR);
      FIg_erase    (form_ptr, VD_RLOF_TXT_PARLIST);
      FIg_erase    (form_ptr, VD_RLOF_TXT_DTYPE);
      FIg_erase    (form_ptr, VD_RLOF_TXT_DEC);
      FIg_erase    (form_ptr, VD_RLOF_FLD_DTYPE);
      FIg_erase    (form_ptr, VD_RLOF_FLD_EXPATT);
      FIg_erase    (form_ptr, VD_RLOF_FLD_DEC);
      FIg_erase    (form_ptr, VD_RLOF_FLD_EXTYP);
      FIg_erase    (form_ptr, VD_RLOF_FLD_EXNAM);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXTYP);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXNAM);

      FIg_erase  (form_ptr, VD_RLOF_TXT_DISTXT);
      FIg_erase  (form_ptr, VD_RLOF_FLD_TEXT);

      FIg_erase  (form_ptr, 19);

      FIg_display  (form_ptr, 21);
      FIg_display  (form_ptr, 26);
      FIg_display  (form_ptr, 18);

      FIg_display  (form_ptr, 23);


      FIg_set_text (form_ptr, 18, pFLoc->id_Font);
      FIg_set_text (form_ptr, 23, pFLoc->Ftext);
      break;

    case VD_DRWLO_EN_USERDEFINED:
    case VD_DRWLO_EN_OVERFLOW:
    case VD_DRWLO_EN_ITEMNO:
    default:
      FIg_erase    (form_ptr, VD_RLOF_TXT_DEFTXT);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXPRESS);
      /*
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXPID);
      FIg_erase    (form_ptr, VD_RLOF_TXT_ATTRID);
      */
      FIg_erase    (form_ptr, VD_RLOF_TXT_DISTXT);
      FIg_erase    (form_ptr, VD_RLOF_TXT_FMTSTR);
      FIg_erase    (form_ptr, VD_RLOF_TXT_PARLIST);
      FIg_erase    (form_ptr, VD_RLOF_TXT_DTYPE);
      FIg_erase    (form_ptr, VD_RLOF_TXT_DEC);
      FIg_erase    (form_ptr, VD_RLOF_FLD_EXTYP);
      FIg_erase    (form_ptr, VD_RLOF_FLD_EXNAM);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXTYP);
      FIg_erase    (form_ptr, VD_RLOF_TXT_EXNAM);

      FIg_erase    (form_ptr, VD_RLOF_FLD_DTYPE);
      /*
      FIg_erase    (form_ptr, VD_RLOF_FLD_EXPATT);
      */
      FIg_display  (form_ptr, VD_RLOF_TXT_FIELDID);
      FIg_display  (form_ptr, VD_RLOF_FLD_EXPATT);
      FIg_set_text (form_ptr, VD_RLOF_FLD_EXPATT, pFLoc->id_name);
      FIg_erase    (form_ptr, VD_RLOF_FLD_TEXT);
      FIg_erase    (form_ptr, VD_RLOF_FLD_DEC);

      FIg_erase    (form_ptr, 26);
      FIg_erase    (form_ptr, 21);
      FIg_display  (form_ptr, 19);


      break;
  }

  return (status);
}

end implementation VDCmdDLO;

