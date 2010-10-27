
/* $Id: VDDLO_htfn.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDDLO_htfn.I
 *
 * Description:
 *
 * Implementation file for main edit form notification
 *   NOTE:  This method processes the gadgets for data column edit
 *          only, and is invoked from the VDDLO_edfn default case
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDLO_htfn.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/04/02  02:55:34  pinnacle
# Replaced: vdtbl/cmd/VDDLO_htfn.I for:  by mdong for vds
#
# Revision 1.3  1998/03/24  17:47:08  pinnacle
# Replaced: vdtbl/cmd/VDDLO_htfn.I for:  by mdong for vds
#
# Revision 1.2  1998/03/06  18:10:36  pinnacle
# TR179800691
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1995/11/13  21:26:04  pinnacle
# Replaced: vdtbl/cmd/VDDLO_htfn.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/09/25  22:58:14  pinnacle
# Replaced: vdtbl/cmd/VDDLO_htfn.I for:  by sundar for vds.240
#
# Revision 1.3  1995/08/03  21:09:48  pinnacle
# Replaced: vdtbl/cmd/VDDLO_htfn.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/06  16:04:22  pinnacle
# Replaced: vdtbl/cmd/VDDLO_htfn.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:21:22  pinnacle
# Created: vdtbl/cmd/* by tdumbach for vds.240
#
# Revision 1.4  1995/05/11  15:50:30  pinnacle
# Replaced: vdtbl/cmd/VDDLO_htfn.I by hverstee r#
#
# Revision 1.3  1995/05/08  20:36:30  pinnacle
# Replaced: vdtbl/cmd/VDDLO_htfn.I by hverstee r#
#
# Revision 1.2  1995/04/29  16:57:34  pinnacle
# Replaced: vdtbl/cmd/VDDLO_htfn.I by hverstee r#
#
# Revision 1.1  1995/04/13  14:05:24  pinnacle
# Created: vdtbl/cmd/VDDLO_htfn.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/20/95          HV            New
 *	03/04/98	  vini 		TR-179800691 cell angle included 
 *      03/24/98          Ming	 	TR179800826
 *      04/01/98          Ming          TR179800877
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

#include "VDdrwlo_pr.h"

/*
#define  MY_DEBUG
*/



method   VDDLO_ht_formnot  (int        gadget_label;
                            double     value;
                            char     * form_ptr)
{
  IGRint       status;
  IGRlong      retmsg;
  IGRshort     nVal, nCalc;
  IGRdouble    dCalc;
  IGRshort     i;
  IGRdouble    dFldHgt;
  IGRdouble    dFldWdt;
  IGRchar      szMsg[60];

  struct   VDdrwlo_ins_htf    *pLoc;

  status   = OM_S_SUCCESS;
  nVal     = (value > 0) ? (value + 0.001) : (value - 0.001);
  szMsg[0] = '\0';

  me->My_localret = 0;

  if (me->nCur_htfrec < 0) goto quit;

  pLoc   = &me->Lhtfrec[me->nCur_htfrec];

  dFldHgt = pLoc->htf_y2 - pLoc->htf_y1;
  dFldWdt = pLoc->htf_x2 - pLoc->htf_x1;

  switch (gadget_label)
  {
/* -------------------- HEADER SECTION DEDICATED --------------------------- */

    case VD_DLOH_FLD_ALGT:
      if (nVal == 0) break;
      if ((nVal < 0) || (nVal > me->nAlg_lines))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->htf_db.align_top = nVal;
      if ((pLoc->htf_db.align_bot == 0) ||
          (pLoc->htf_db.align_bot > pLoc->htf_db.align_top))
        pLoc->htf_db.align_bot = nVal - 1;
      goto AL_RESET;

    case VD_DLOH_FLD_ALGB:
      if (nVal == 0) break;
      if ((nVal < 0) || (nVal > me->nAlg_lines))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->htf_db.align_bot = nVal;
      if ((pLoc->htf_db.align_top == 0) ||
          (pLoc->htf_db.align_top < pLoc->htf_db.align_bot))
      {
        if (nVal < me->nAlg_lines)
          pLoc->htf_db.align_top = nVal + 1;
      }
      goto AL_RESET;

    case VD_DLOH_FLD_ALGL:
      if (nVal == 0) break;
      if ((nVal < 0) || (nVal > me->nMax_colnum))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->htf_db.align_lcol = nVal;
      if ((pLoc->htf_db.align_rcol == 0) ||
          (pLoc->htf_db.align_rcol < pLoc->htf_db.align_lcol))
        pLoc->htf_db.align_rcol = nVal;
      goto AL_RESET;

    case VD_DLOH_FLD_ALGR:
      if (nVal == 0) break;
      if ((nVal < 0) || (nVal > me->nMax_colnum))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->htf_db.align_rcol = nVal;
      if ((pLoc->htf_db.align_lcol == 0) ||
          (pLoc->htf_db.align_lcol > pLoc->htf_db.align_rcol))
        pLoc->htf_db.align_lcol = nVal;

    AL_RESET:
      status =
      om$send (msg = message VDdrwlo.VDdrwlo_set
                                 (&retmsg, me->nCur_group, pLoc),
          targetid = my_id);
      me->Pv_need_update = TRUE;
      break;

/* ---------------------  COMMON SECTION GADGETS --------------------------- */

    case VD_DLOB_CKL_TL_BR:
      pLoc->htf_db.tl_br = 1 - pLoc->htf_db.tl_br;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_CKL_BL_TR:
      pLoc->htf_db.bl_tr = 1 - pLoc->htf_db.bl_tr;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_NLINES:
      if (nVal < 1)
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      nCalc = VD_DLO_M_NLN (dFldHgt,
                            pLoc->htf_db.fld_charhgt,
                            pLoc->htf_db.fld_linspc);

      if (nCalc < nVal)
        sprintf (szMsg,VD_DLO_CMSG_NLIN ,nCalc);

      NL_RESET:

      if (nVal == pLoc->htf_lns) break;

      me->Pv_need_update = TRUE;

      if (nVal < pLoc->htf_lns)
      {   /*   delete lines   */
        for (i=(nVal + 1); i<= pLoc->htf_lns; i++)
        {
          status =
          om$send (msg = message VDdrwlo.VDdrwlo_dfld
                                   (&retmsg, me->nCur_group, VD_DRWLO_EN_ALL,
                                     me->sCur_fieldid, i),
              targetid = my_id);
        }
      }
      else
      {
        struct   VDdrwlo_db_fld    LocFLD;

        VD_drwlo_mfld (&LocFLD, &me->FldCUR);

        LocFLD.hdtr_type = me->nCur_group;
        LocFLD.col_seqno = VD_DRWLO_EN_ALL;

        strcpy (LocFLD.fieldid, me->sCur_fieldid);

        for (i=(pLoc->htf_lns + 1); i<= nVal; i++)
        {
          LocFLD.lin_seqno = i;

          status =
          om$send (msg = message VDdrwlo.VDdrwlo_pfld (&retmsg, 1, &LocFLD),
              targetid = my_id);
        }
      }

      pLoc->htf_lns = nVal;
      break;

    case VD_DLOB_FLD_LINSPC:
      if (value <= 0)
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      dCalc = VD_DLO_M_LSP (dFldHgt,
                            pLoc->htf_db.fld_charhgt,
                            pLoc->htf_lns);

      if (dCalc < value)
        sprintf (szMsg,VD_DLO_CMSG_LSPC,dCalc);

      pLoc->htf_db.fld_linspc = value;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_NUMCHR:
      if (nVal <= 0)
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      nCalc = VD_DLO_M_NCH (dFldWdt,
                            pLoc->htf_db.fld_charwdt,
                            pLoc->htf_db.fld_charspc);
      if (nCalc < nVal)
        sprintf (szMsg,VD_DLO_CMSG_NCHR,nCalc);

      pLoc->htf_db.fld_chars = nVal;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_CHRHGT:
      if (value <= 0)
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      dCalc = VD_DLO_M_CHG (dFldHgt,
                            pLoc->htf_db.fld_linspc,
                            pLoc->htf_lns);
      if (dCalc < value)
      { 
	sprintf (szMsg,VD_DLO_CMSG_CHGT,dCalc);
      }

      pLoc->htf_db.fld_charhgt = value;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_CHRSPC:
      if (value <= 0)
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      dCalc = VD_DLO_M_CSP (dFldWdt,
                            pLoc->htf_db.fld_charwdt,
                            pLoc->htf_db.fld_chars);
      if (dCalc < value)
        sprintf (szMsg,VD_DLO_CMSG_CSPC,dCalc);

      pLoc->htf_db.fld_charspc = value;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_CHRWDT:

/** added for TR-179800691 totake care of cell angle **/
      status =
      om$send (msg = message VDdrwlo.VDdrwlo_gfld
                          (&retmsg, me->nCur_group, me->nCur_colnum,
                            me->sCur_fieldid, VD_DRWLO_EN_ALL,
                           &me->nMax_linenum, NULL),
          targetid = my_id);

      if (me->nMax_linenum > 0)
      {
        me->nCur_linenum = 1;
        status =
        om$send (msg = message VDdrwlo.VDdrwlo_xfld
                            (&retmsg, me->nCur_group, me->nCur_colnum,
                              me->sCur_fieldid, me->nCur_linenum,
                             &me->nCur_fldrec),
            targetid = my_id);
      }

      if( me->Lfldrec[me->nCur_fldrec].fieldtype != VD_DRWLO_EN_CELL)
      {
        if (value <= 0)
        {
          strcpy (szMsg, VD_DLO_EMSG_PAR);
          break;
        }
      }
      else
      {
        if (value < 0)
        {
          strcpy (szMsg, VD_DLO_EMSG_PAR);
          break;
        }
      }

      if( me->Lfldrec[me->nCur_fldrec].fieldtype != VD_DRWLO_EN_CELL){
       dCalc = VD_DLO_M_CWD (dFldWdt,
                            pLoc->htf_db.fld_charspc,
                            pLoc->htf_db.fld_chars);
       if (dCalc < value)
        sprintf (szMsg,VD_DLO_CMSG_CWDT,dCalc);

       pLoc->htf_db.fld_charwdt = value;
      }
      else  pLoc->htf_db.fld_charwdt = value;

      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_BLST:
      if ((nVal < -1) || (nVal > 255))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->htf_db.ltop_style = nVal;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_BLSB:
      if ((nVal < -1) || (nVal > 255))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->htf_db.lbot_style = nVal;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_BLSL:
      if ((nVal < -1) || (nVal > 255))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->htf_db.llft_style = nVal;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_BLSR:
      if ((nVal < -1) || (nVal > 255))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->htf_db.lrgt_style = nVal;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_BLWT:
      if ((nVal < 0) || (nVal > 31))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->htf_db.ltop_wgt = nVal;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_BLWB:
      if ((nVal < 0) || (nVal > 31))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->htf_db.lbot_wgt = nVal;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_BLWL:
      if ((nVal < 0) || (nVal > 31))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->htf_db.llft_wgt = nVal;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_BLWR:
      if ((nVal < 0) || (nVal > 31))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->htf_db.lrgt_wgt = nVal;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_BTN_C_NLIN:
      nVal = VD_DLO_M_NLN (dFldHgt,
                           pLoc->htf_db.fld_charhgt,
                           pLoc->htf_db.fld_linspc);
      if (nVal == 0) nVal = 1;
      me->Pv_need_update = TRUE;
      goto NL_RESET;

    case VD_DLOB_BTN_C_NCHR:
      pLoc->htf_db.fld_chars = VD_DLO_M_NCH (dFldWdt,
                                             pLoc->htf_db.fld_charwdt,
                                             pLoc->htf_db.fld_charspc);
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_BTN_C_CHRWDT:
      pLoc->htf_db.fld_charwdt = VD_DLO_M_CWD (dFldWdt,
                                               pLoc->htf_db.fld_charspc,
                                               pLoc->htf_db.fld_chars);
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_BTN_C_CHRHGT:
      pLoc->htf_db.fld_charhgt = VD_DLO_M_CHG (dFldHgt,
                                               pLoc->htf_db.fld_linspc,
                                               pLoc->htf_lns);
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_BTN_C_CHRSPC:
      pLoc->htf_db.fld_charspc = VD_DLO_M_CSP (dFldWdt,
                                               pLoc->htf_db.fld_charwdt,
                                               pLoc->htf_db.fld_chars);
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_BTN_C_LINSPC:
      pLoc->htf_db.fld_linspc = VD_DLO_M_LSP (dFldHgt,
                                              pLoc->htf_db.fld_charhgt,
                                              pLoc->htf_lns);
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_BTN_DEFAULT:
      VD_drwlo_mhtf (&me->HtfCUR.htf_db, &pLoc->htf_db);
      me->HtfCUR.htf_lns  = pLoc->htf_lns;
#ifdef MY_DEBUG
      printf ("default numlines %d\n",me->HtfCUR.htf_lns);
#endif
      break;

    default:
#ifdef MY_DEBUG
      sprintf (szMsg," ERROR ------- unknown gadget %d\n", gadget_label);
#endif
      break;
  }

  FIg_set_text (form_ptr, VD_DLOM_FLD_MSG, szMsg);

  quit:
  return (status);
}

end implementation VDCmdDLO;

