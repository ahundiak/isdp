
/* $Id: VDSSC_fsrt.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDSSC_fsrt.I
 *
 * Description:
 *
 * Implementation file for sort form notification
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDSSC_fsrt.I,v $
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
# Revision 1.9  1995/09/25  23:01:06  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsrt.I for:  by sundar for vds.240
#
# Revision 1.8  1995/09/22  14:06:42  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsrt.I for:  by hverstee for vds.240
#
# Revision 1.7  1995/09/08  23:30:32  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsrt.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/09/05  23:16:44  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsrt.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/08/15  23:51:18  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsrt.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/11  23:34:52  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsrt.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/04  14:39:28  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsrt.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/06  16:21:42  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsrt.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:21:22  pinnacle
# Created: vdtbl/cmd/* by tdumbach for vds.240
#
# Revision 1.3  1995/05/24  15:19:40  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsrt.I by hverstee r#
#
# Revision 1.2  1995/05/11  16:57:26  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsrt.I by hverstee r#
#
# Revision 1.1  1995/04/29  17:01:28  pinnacle
# Created: vdtbl/cmd/VDSSC_fsrt.I by hverstee r#
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

%safe
#include <math.h>
%endsafe

/*
#define   MY_DEBUG
*/



method   VDSSC_srt_fn (int        gadget_label;
                       double     value;
                       char     * form_ptr)
{
  IGRint       status;
  IGRlong      retmsg;
  IGRchar      szFld[VD_DRWLO_CHR_DESC];
  IGRchar      szmsg[80];
  IGRshort     nVal;
  int          i;
  IGRchar      szLocC[VD_DRWLO_CHR_IDFLD];
  IGRchar      szLocS[VD_DRWLO_CHR_IDFLD];
  IGRshort     iSet1, iSet2;

  struct   GRid              lGRID;
  struct   VDdrwlo_sstab     Local;

  extern IGRboolean   VD_TBL_idquote (IGRchar   *szFld);

  status  = OM_S_SUCCESS;
  szmsg[0] = '\0';

  me->My_localret = 0;

  nVal     = (value > 0) ? (value + 0.001) : (value - 0.001);

#ifdef MY_DEBUG
  printf (" EDIT formnot, gadget %d\n",gadget_label);

  printf (" codes : CEO, CEO_LOCATE %d %d\n",
            me->response, me->event1.response);
#endif

  switch (gadget_label)
  {

/* ---------------------  HEADER SECTION GADGETS -------------------------- */

    case VD_CRSRT_FLD_TABNAM:
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      if (VD_TBL_idquote(szFld))
      {
        strcpy  (szmsg, VD_SSC_EMSG_QTE);
        break;
      }

      if (me->CUR_tabnam[0] != '\0')
      {
        strcpy (szmsg, VD_CRSRT_EMSG_NACT);
        break;
      }

      status = VD_crsrt_getid (&retmsg, szFld, &lGRID);

      me->My_stored_lo.objid = lGRID.objid;
      me->My_stored_lo.osnum = lGRID.osnum;

      if (lGRID.objid == NULL_OBJID)
      {   /*    does not exist, create new   */
        if (me->My_Type == VD_CMD_SRT_REV) break;

        strcpy (me->CUR_tabnam, szFld);
        strcpy (Local.Tabnam, me->CUR_tabnam);

        strcpy (Local.Shdesc, "");

        Local.Local  = TRUE;

        status =
        om$send (msg = message VDSSC.VDSSC_init (&retmsg, &Local),
            targetid = my_id);

        sprintf (szmsg, VD_CRSRT_EMSG_NSYM, szFld);
        strcat  (szmsg, VD_SSC_EMSG_CRE);
        me->nCurSrt = -1;
        me->nMaxSrt = 0;
      }
      else
      {
        strcpy (me->CUR_tabnam, szFld);

        status =
        om$send (msg = message VDCmdSSC.VDSSC_load (&retmsg, &lGRID),
            targetid = my_id);

        if (retmsg != MSSUCC)
        {
          UI_status (VD_SSC_EMSG_MEM);
          _put_response( resp = TERMINATE);
          goto quit;
        }

        if (me->nMaxSrt > 0)
          me->nCurSrt = 0;
        else
          me->nCurSrt = -1;

        if (me->My_Type == VD_CMD_SRT_REV) break;

        VD_DLO_SetIndx (me->SSid_tab.Userid, me->SSid_tab.Timest,
                         &me->SSid_tab.Local, &me->SSid_tab.LcUnit);
      }
      break;

    case VD_CRSRT_FLD_DESCR:
      if (me->My_Type == VD_CMD_SRT_REV) break;

      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      strcpy (me->SSid_tab.Shdesc, szFld);
      break;

    case VD_CRSRT_FLD_COPY:
      if (me->My_Type == VD_CMD_SRT_REV) break;

      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      if (VD_TBL_idquote(szFld))
      {
        strcpy  (szmsg, VD_SSC_EMSG_QTE);
        break;
      }

      if (me->My_stored_lo.objid != NULL_OBJID)
      {   /*    already one active, save or reset first  */
        sprintf (szmsg, VD_CRSRT_EMSG_NACT);
        break;
      }

      status = VD_crsrt_getid (&retmsg, szFld, &lGRID);

      if (lGRID.objid == NULL_OBJID)
      {
        sprintf (szmsg, VD_CRSRT_EMSG_NSYM, szFld);
        break;
      }

      strcpy (Local.Timest, me->SSid_tab.Timest);
      strcpy (Local.Userid, me->SSid_tab.Userid);

      status =
      om$send (msg = message VDCmdSSC.VDSSC_load (&retmsg, &lGRID),
          targetid = my_id);

      if (retmsg != MSSUCC)
      {
        UI_status (VD_SSC_EMSG_MEM);
        _put_response( resp = TERMINATE);
        goto quit;
      }

      strcpy (me->SSid_tab.Tabnam, me->CUR_tabnam);
      strcpy (me->SSid_tab.Timest, Local.Timest);
      strcpy (me->SSid_tab.Userid, Local.Userid);

      me->My_stored_lo.objid = NULL_OBJID;
      me->My_stored_lo.osnum = lGRID.osnum;

      if (me->nMaxSrt > 0)
        me->nCurSrt = 0;
      else
        me->nCurSrt = -1;

      sprintf (szmsg, VD_CRSRT_EMSG_NCPY, szFld, me->CUR_tabnam);
      break;

/* ------------------------------  DATA GADGETS --------------------------- */

    case VD_CRSRT_BTN_DOWN:
      if (me->My_Type == VD_CMD_SRT_REV)
      {
        if (me->nCurSrt > 0) me->nCurSrt--;
      }
      else
      {
        if (me->nCurSrt >= 0) me->nCurSrt--;
      }
#ifdef MY_DEBUG
        printf (" down Current rec %d\n",me->nCurSrt);
#endif
      break;

    case VD_CRSRT_BTN_UP:
      if (me->nCurSrt < (me->nMaxSrt-1)) me->nCurSrt++;
#ifdef MY_DEBUG
        printf (" up Current rec %d\n",me->nCurSrt);
#endif
      break;

    case VD_CRSRT_FLD_SEQNO:
      if ((nVal <= 0) || (nVal > me->nMaxSrt))
      {
        strcpy (szmsg, VD_SSC_EMSG_PAR);
        break;
      }

      me->nCurSrt = (nVal -1);
      break;

    case VD_CRSRT_BTN_INSERT:
      if (me->My_Type == VD_CMD_SRT_REV) break;

      status =
      om$vla_set_dimension (varray = me->Lsortrec,
                            size   = (me->nMaxSrt+1));

      for (i=(me->nMaxSrt); i>(me->nCurSrt+1); i--)
      {
        me->Lsortrec[i].nsIndex = i+1;
        me->Lsortrec[i].nsSeq   = me->Lsortrec[i-1].nsSeq;
        me->Lsortrec[i].nsTyp   = me->Lsortrec[i-1].nsTyp;
        strcpy (me->Lsortrec[i].szAtt, me->Lsortrec[i-1].szAtt);
#ifdef MY_DEBUG
        printf (" move %d to %d insert sortrec %d %d %s\n",
                     i+1,i,me->Lsortrec[i].nsIndex,
                           me->Lsortrec[i].nsSeq,
                           me->Lsortrec[i].szAtt);
#endif
      }

      (me->nMaxSrt)++;
      (me->nCurSrt)++;
#ifdef MY_DEBUG
      printf (" after insert, max,cur %d %d\n",me->nMaxSrt,me->nCurSrt);
#endif
      me->Lsortrec[me->nCurSrt].nsIndex  = me->nCurSrt+1;
      me->Lsortrec[me->nCurSrt].nsSeq    = VD_DRWLO_EN_DESCEND;
      me->Lsortrec[me->nCurSrt].nsTyp    = VD_DRWLO_EN_ASCII;
      me->Lsortrec[me->nCurSrt].szAtt[0] = '\0';
      break;

    case VD_CRSRT_BTN_DELETE:
      if (me->My_Type == VD_CMD_SRT_REV) break;

      if (me->nCurSrt < 0) break;

      for (i=me->nCurSrt; i<(me->nMaxSrt-1); i++)
      {
#ifdef MY_DEBUG
        printf ("delete, move %d to %d\n",i+1,i);
#endif
        me->Lsortrec[i].nsIndex = i+1;
        me->Lsortrec[i].nsSeq   = me->Lsortrec[i+1].nsSeq;
        me->Lsortrec[i].nsTyp   = me->Lsortrec[i+1].nsTyp;
        strcpy (me->Lsortrec[i].szAtt, me->Lsortrec[i+1].szAtt);
      }

      status =
      om$vla_set_dimension (varray = me->Lsortrec,
                            size   = (me->nMaxSrt-1));

      (me->nMaxSrt)--;
      (me->nCurSrt)--;
      break;

    case VD_CRSRT_FLD_ATTR:
      if (me->My_Type == VD_CMD_SRT_REV) break;

      if (me->nCurSrt < 0) break;

      FIg_get_text (form_ptr, gadget_label,me->Lsortrec[me->nCurSrt].szAtt);
      break;

    case VD_CRSRT_TGG_SEQ:
      if (me->My_Type == VD_CMD_SRT_REV) break;

      if (me->nCurSrt < 0) break;

      me->Lsortrec[me->nCurSrt].nsSeq = 1 - me->Lsortrec[me->nCurSrt].nsSeq;
      break;

    case VD_CRSRT_TGG_TYP:
      if (me->My_Type == VD_CMD_SRT_REV) break;

      if (me->nCurSrt < 0) break;

      me->Lsortrec[me->nCurSrt].nsTyp = 1 - me->Lsortrec[me->nCurSrt].nsTyp;
      break;

/* ------------------------  CONTROL BAR GADGETS --------------------------- */

    case FI_ACCEPT:
    case FI_EXECUTE:
      if (me->My_Type == VD_CMD_SRT_REV) break;

      if (me->CUR_tabnam[0] == '\0')
      {
        strcpy (szmsg, VD_SSC_EMSG_NTAB);
        break;
      }

      status =
      om$send (msg = message VDSSC.VDSSC_check
                                 (&retmsg, &iSet1, szLocC, szLocS, &iSet2),
          targetid = my_id);

      if (retmsg != MSSUCC)
      {
        me->nCurSrt = iSet1;
        strcpy (szmsg, VD_SSC_EMSG_NSV);
        break;
      }

      status = 
      om$send (msg = message VDCmdSSC.VDSSC_Save  (&retmsg),
          targetid = my_id);

      /*   fall through   */

    case FI_CANCEL:
      me->My_localret = gadget_label;
      _put_response( resp = EX_FORM_FINISHED );
      break;

    case FI_RESET:
      status =
      om$send (msg = message VDCmdSSC.VDSSC_Reset (&retmsg),
          targetid = my_id);

      me->My_localret = gadget_label;
      _put_response( resp = EX_FORM_FINISHED );
      break;

    default:
#ifdef MY_DEBUG
      printf (" ERROR edit unknown gadget %d\n", gadget_label);
#endif
      goto quit;
  }

  FIg_set_text (form_ptr, VD_CRSRT_FLD_MSG, szmsg);

  status =
  om$send (msg = message VDCmdSSC.VDSSC_disp (form_ptr),
      targetid = my_id);

  quit:
  return (status);
}

end implementation VDCmdSSC;

