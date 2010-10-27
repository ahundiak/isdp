
/* $Id: VDDLO_cofn.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDDLO_cofn.I
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
 *      $Log: VDDLO_cofn.I,v $
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
# Revision 1.6  1995/10/09  22:29:04  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cofn.I for:  by yzhu for vds.240
#
# Revision 1.5  1995/09/25  22:57:12  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cofn.I for:  by sundar for vds.240
#
# Revision 1.4  1995/09/12  16:51:54  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cofn.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/03  21:10:12  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cofn.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/06  16:02:42  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cofn.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:21:22  pinnacle
# Created: vdtbl/cmd/* by tdumbach for vds.240
#
# Revision 1.3  1995/05/11  16:55:34  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cofn.I by hverstee r#
#
# Revision 1.2  1995/05/08  20:37:08  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cofn.I by hverstee r#
#
# Revision 1.1  1995/04/13  14:02:54  pinnacle
# Created: vdtbl/cmd/VDDLO_cofn.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/20/95          HV            New
 *      10/09/95          YZ            add message VDdrwlo.VDdrwlo_set
 *                                      at case VD_DLOC_BTN_C_COLWDT.
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



method   VDDLO_co_formnot  (int        gadget_label;
                            double     value;
                            char     * form_ptr)
{
  IGRint       status;
  IGRlong      retmsg;
  IGRshort     nVal, nCalc;
  IGRdouble    dCalc;
  IGRshort     i;
  IGRchar      szMsg[60];

  struct   VDdrwlo_ins_col    *pLoc;

  status   = OM_S_SUCCESS;
  nVal     = (value > 0) ? (value + 0.001) : (value - 0.001);
  szMsg[0] = '\0';

  me->My_localret = 0;

  if (me->nCur_colrec < 0) goto quit;

  pLoc   = &me->Lcolrec[me->nCur_colrec];

  switch (gadget_label)
  {
    case VD_DLOC_FLD_COLWDT:
      if (value <= 0)
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      dCalc = VD_DLO_M_FWD (pLoc->col_db.col_charwdt,
                            pLoc->col_db.col_charspc,
                            pLoc->col_db.col_chars);
      if (dCalc > value)
        sprintf (szMsg,VD_DLO_CMSG_MCOL,dCalc);

      pLoc->col_db.col_wdt = value;
      goto AL_RESET;

    case VD_DLOC_FLD_COLHGT:
      if (value <= 0)
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      dCalc = VD_DLO_M_FHG (pLoc->col_db.col_charhgt,
                            pLoc->col_db.col_linspc,
                            pLoc->col_lns);
      if (dCalc > value)
        sprintf (szMsg,VD_DLO_CMSG_MROW,dCalc);

      pLoc->col_db.col_hgt = value;

      AL_RESET:
      status =
      om$send (msg = message VDdrwlo.VDdrwlo_set
                                 (&retmsg, VD_DRWLO_EN_ALL, NULL),
          targetid = my_id);
      me->Pv_need_update = TRUE;
      break;

/* ---------------------  COMMON SECTION GADGETS --------------------------- */

    case VD_DLOB_CKL_TL_BR:
      pLoc->col_db.tl_br = 1 - pLoc->col_db.tl_br;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_CKL_BL_TR:
      pLoc->col_db.bl_tr = 1 - pLoc->col_db.bl_tr;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_NLINES:
      if (nVal < 1)
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      nCalc = VD_DLO_M_NLN (pLoc->col_db.col_hgt,
                            pLoc->col_db.col_charhgt,
                            pLoc->col_db.col_linspc);

      if (nCalc < nVal)
        sprintf (szMsg,VD_DLO_CMSG_NLIN,nCalc);

      NL_RESET:

      if (nVal == pLoc->col_lns) break;

      me->Pv_need_update = TRUE;

      if (nVal < pLoc->col_lns)
      {   /*   delete lines   */
        for (i=(nVal + 1); i<= pLoc->col_lns; i++)
        {
          status =
          om$send (msg = message VDdrwlo.VDdrwlo_dfld
                                   (&retmsg, me->nCur_group, me->nCur_colnum,
                                     me->sCur_fieldid, i),
              targetid = my_id);
        }
      }
      else
      {
        struct   VDdrwlo_db_fld    LocFLD;

        VD_drwlo_mfld (&LocFLD, &me->FldCUR);

        LocFLD.hdtr_type = me->nCur_group;
        LocFLD.col_seqno = me->nCur_colnum;
        LocFLD.fieldid[0] = '\0';
        LocFLD.id_name[0] = '\0';
        LocFLD.Ftext[0]   = '\0';

        for (i=(pLoc->col_lns + 1); i<= nVal; i++)
        {
          LocFLD.lin_seqno = i;

          status =
          om$send (msg = message VDdrwlo.VDdrwlo_pfld (&retmsg, 1, &LocFLD),
              targetid = my_id);
        }
      }

      pLoc->col_lns = nVal;
      break;

    case VD_DLOB_FLD_LINSPC:
      if (value <= 0)
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      dCalc = VD_DLO_M_LSP (pLoc->col_db.col_hgt,
                            pLoc->col_db.col_charhgt,
                            pLoc->col_lns);

      if (dCalc < value)
        sprintf (szMsg,VD_DLO_CMSG_LSPC,dCalc);

      pLoc->col_db.col_linspc = value;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_NUMCHR:
      if (nVal <= 0)
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      nCalc = VD_DLO_M_NCH (pLoc->col_db.col_wdt,
                            pLoc->col_db.col_charwdt,
                            pLoc->col_db.col_charspc);
      if (nCalc < nVal)
        sprintf (szMsg,VD_DLO_CMSG_NCHR,nCalc);

      pLoc->col_db.col_chars = nVal;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_CHRHGT:
      if (value <= 0)
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      dCalc = VD_DLO_M_CHG (pLoc->col_db.col_hgt,
                            pLoc->col_db.col_linspc,
                            pLoc->col_lns);
      if (dCalc < value)
        sprintf (szMsg,VD_DLO_CMSG_CHGT,dCalc);

      pLoc->col_db.col_charhgt = value;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_CHRSPC:
      if (value <= 0)
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      dCalc = VD_DLO_M_CSP (pLoc->col_db.col_wdt,
                            pLoc->col_db.col_charwdt,
                            pLoc->col_db.col_chars);
      if (dCalc < value)
        sprintf (szMsg,VD_DLO_CMSG_CSPC,dCalc);

      pLoc->col_db.col_charspc = value;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_CHRWDT:
      if (value <= 0)
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      dCalc = VD_DLO_M_CWD (pLoc->col_db.col_wdt,
                            pLoc->col_db.col_charspc,
                            pLoc->col_db.col_chars);
      if (dCalc < value)
        sprintf (szMsg,VD_DLO_CMSG_CWDT,dCalc);

      pLoc->col_db.col_charwdt = value;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_BLST:
      if ((nVal < -1) || (nVal > 255))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->col_db.ltop_style = nVal;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_BLSB:
      if ((nVal < -1) || (nVal > 255))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->col_db.lbot_style = nVal;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_BLSL:
      if ((nVal < -1) || (nVal > 255))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->col_db.llft_style = nVal;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_BLSR:
      if ((nVal < -1) || (nVal > 255))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->col_db.lrgt_style = nVal;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_BLWT:
      if ((nVal < 0) || (nVal > 31))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->col_db.ltop_wgt = nVal;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_BLWB:
      if ((nVal < 0) || (nVal > 31))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->col_db.lbot_wgt = nVal;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_BLWL:
      if ((nVal < 0) || (nVal > 31))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->col_db.llft_wgt = nVal;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_FLD_BLWR:
      if ((nVal < 0) || (nVal > 31))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      pLoc->col_db.lrgt_wgt = nVal;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_BTN_C_NLIN:
      nVal = VD_DLO_M_NLN (pLoc->col_db.col_hgt,
                           pLoc->col_db.col_charhgt,
                           pLoc->col_db.col_linspc);
      goto NL_RESET;

    case VD_DLOB_BTN_C_NCHR:
      pLoc->col_db.col_chars = VD_DLO_M_NCH (pLoc->col_db.col_wdt,
                                             pLoc->col_db.col_charwdt,
                                             pLoc->col_db.col_charspc);
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_BTN_C_CHRWDT:
       pLoc->col_db.col_charwdt = VD_DLO_M_CWD (pLoc->col_db.col_wdt,
                                                pLoc->col_db.col_charspc,
                                                pLoc->col_db.col_chars);
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_BTN_C_CHRHGT:
      pLoc->col_db.col_charhgt = VD_DLO_M_CHG (pLoc->col_db.col_hgt,
                                               pLoc->col_db.col_linspc,
                                               pLoc->col_lns);
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_BTN_C_CHRSPC:
      pLoc->col_db.col_charspc = VD_DLO_M_CSP (pLoc->col_db.col_wdt,
                                               pLoc->col_db.col_charwdt,
                                               pLoc->col_db.col_chars);
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_BTN_C_LINSPC:
      pLoc->col_db.col_linspc = VD_DLO_M_LSP (pLoc->col_db.col_hgt,
                                              pLoc->col_db.col_charhgt,
                                              pLoc->col_lns);
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_BTN_DEFAULT:
      VD_drwlo_mcol (&me->ColCUR.col_db, &pLoc->col_db);
      me->ColCUR.col_lns = pLoc->col_lns;
#ifdef MY_DEBUG
      printf ("default numlines %d\n",me->ColCUR.col_lns);
#endif
      break;

    case VD_DLOC_BTN_C_COLHGT:
      pLoc->col_db.col_hgt = VD_DLO_M_FHG (pLoc->col_db.col_charhgt,
                                           pLoc->col_db.col_linspc,
                                           pLoc->col_lns);
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOC_BTN_C_COLWDT:
      pLoc->col_db.col_wdt = VD_DLO_M_FWD (pLoc->col_db.col_charwdt,
                                           pLoc->col_db.col_charspc,
                                           pLoc->col_db.col_chars);

   
      /* add message to recalculate column width (TR 17952788) */       
      status =
      om$send (msg = message VDdrwlo.VDdrwlo_set
                                 (&retmsg, VD_DRWLO_EN_ALL, NULL),
          targetid = my_id);
 
      me->Pv_need_update = TRUE;
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

