
/* $Id: VDSSC_fsum.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDSSC_fsum.I
 *
 * Description:
 *
 * Implementation file for summarization form notification
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDSSC_fsum.I,v $
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
# Revision 1.11  1995/11/17  22:27:46  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsum.I for:  by hverstee for vds.240
#
# Revision 1.10  1995/10/12  22:32:28  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsum.I for:  by yzhu for vds.240
#
# Revision 1.9  1995/09/25  23:01:22  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsum.I for:  by sundar for vds.240
#
# Revision 1.8  1995/09/22  14:06:32  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsum.I for:  by hverstee for vds.240
#
# Revision 1.7  1995/09/08  23:30:16  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsum.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/09/05  23:16:32  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsum.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/08/15  23:50:12  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsum.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/11  23:34:32  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsum.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/04  14:39:54  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsum.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/06  16:22:08  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsum.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:21:22  pinnacle
# Created: vdtbl/cmd/* by tdumbach for vds.240
#
# Revision 1.3  1995/05/15  16:16:50  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsum.I by hverstee r#
#
# Revision 1.2  1995/05/11  16:57:58  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fsum.I by hverstee r#
#
# Revision 1.1  1995/04/29  17:02:02  pinnacle
# Created: vdtbl/cmd/VDSSC_fsum.I by hverstee r#
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
#include "vdpardef.h"

#include "VDdrwlo_pr.h"

%safe
#include <math.h>
%endsafe

/*
#define   MY_DEBUG
*/



method   VDSSC_sum_fn (int        gadget_label;
                       double     value;
                       char     * form_ptr)
{
  IGRint       status;
  IGRlong      retmsg;
  IGRshort     nDumm;
  IGRchar      szFld[VD_DRWLO_CHR_DESC];
  IGRchar      szmsg[80];
  IGRshort     nVal;
  int          i, ibeg;
  int          idsp;
  IGRchar      szLocC[VD_DRWLO_CHR_IDFLD];
  IGRchar      szLocS[VD_DRWLO_CHR_IDFLD];
  IGRshort     iSet1, iSet2;

  struct   GRid              lGRID;
  struct   VDdrwlo_sstab     Local;

  extern IGRboolean   VD_TBL_idquote (IGRchar   *szFld);

  status   = OM_S_SUCCESS;
  szmsg[0] = '\0';

  me->My_localret = 0;

  nVal     = (value > 0) ? (value + 0.001) : (value - 0.001);

#ifdef MY_DEBUG
  printf (" EDIT formnot, gadget %d\n",gadget_label);
#endif

  switch (gadget_label)
  {

/* ---------------------  HEADER SECTION GADGETS -------------------------- */

    case VD_CRSUM_FLD_TABNAM:
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      if (VD_TBL_idquote(szFld))
      {
        strcpy  (szmsg, VD_SSC_EMSG_QTE);
        break;
      }

      if (me->CUR_tabnam[0] != '\0')
      {
        strcpy (szmsg, VD_CRSUM_EMSG_NACT);
        break;
      }

      status = VD_crsum_getid (&retmsg, szFld, &lGRID);

      me->My_stored_lo.objid = lGRID.objid;
      me->My_stored_lo.osnum = lGRID.osnum;

      if (lGRID.objid == NULL_OBJID)
      {   /*    does not exist, create new   */
        if (me->My_Type == VD_CMD_SUM_REV) break;

        strcpy (me->CUR_tabnam, szFld);
        strcpy (Local.Tabnam, me->CUR_tabnam);

        strcpy (Local.Shdesc, "");

        Local.Local  = TRUE;

        status =
        om$send (msg = message VDSSC.VDSSC_init (&retmsg, &Local),
            targetid = my_id);

        sprintf (szmsg, VD_CRSUM_EMSG_NSYM, szFld);
        strcat  (szmsg, VD_SSC_EMSG_CRE);

        me->nMaxQty =  0;
        me->nMaxMtc =  0;
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

        me->nMaxQty = om$dimension_of (varray = me->Lsqtyrec);
        me->nMaxMtc = om$dimension_of (varray = me->Lsmtcrec);

        if (me->My_Type != VD_CMD_SUM_REV)
          VD_DLO_SetIndx (me->SSid_tab.Userid, me->SSid_tab.Timest,
                           &me->SSid_tab.Local, &me->SSid_tab.LcUnit);
      }

      me->CUR_catnam[0] = '\0';
      me->CUR_subcat[0] = '\0';
      me->nCurQty = -1;
      me->nCurMtc = -1;
      me->nBegMtc = -1;
      me->nEndMtc = -1;
      break;

    case VD_CRSUM_FLD_DESCR:
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      if (me->My_Type == VD_CMD_SUM_REV) break;

      strcpy (me->SSid_tab.Shdesc, szFld);
      break;

    case VD_CRSUM_FLD_COPY:
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      if (VD_TBL_idquote(szFld))
      {
        strcpy  (szmsg, VD_SSC_EMSG_QTE);
        break;
      }

      if (me->My_Type == VD_CMD_SUM_REV) break;

      if (me->My_stored_lo.objid != NULL_OBJID)
      {   /*    already one active, save or reset first  */
        strcpy (szmsg, VD_CRSUM_EMSG_NACT);
        break;
      }

      status = VD_crsum_getid (&retmsg, szFld, &lGRID);

      if (lGRID.objid == NULL_OBJID)
      {
        sprintf (szmsg, VD_CRSUM_EMSG_NSYM, szFld);
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

      me->nMaxQty = om$dimension_of (varray = me->Lsqtyrec);
      me->nMaxMtc = om$dimension_of (varray = me->Lsmtcrec);

      me->CUR_catnam[0] = '\0';
      me->CUR_subcat[0] = '\0';
      me->nCurQty = -1;
      me->nCurMtc = -1;
      me->nBegMtc = -1;
      me->nEndMtc = -1;

      sprintf (szmsg, VD_CRSUM_EMSG_NCPY, szFld, me->CUR_tabnam);
      break;

/* ------------------------------  DATA GADGETS --------------------------- */

    case VD_CRSUM_FLD_CAT:
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      for (i=0; i<me->nNumCat; i++)
      {
        idsp = i*VD_CRSUM_STL_CAT;
        if (strcmp (szFld, &me->pCat[idsp]) == 0) goto CATFND;
      }
      sprintf (szmsg, VD_SSC_EMSG_CAT,szFld);
      break;

      CATFND:
      strcpy (me->CUR_catnam, szFld);
      me->CUR_subcat[0] = '\0';

      status =
      om$send (msg = message VDCmdSSC.VDSSC_ld_sub (&retmsg),
          targetid = my_id);

      if (retmsg != MSSUCC)
      {
        UI_status (VD_SSC_EMSG_MEM);
        _put_response( resp = TERMINATE);
        goto quit;
      }
      break;

    case VD_CRSUM_FLD_SUBCAT:
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      if (me->CUR_catnam[0] == '\0')
      {
        strcpy (szmsg, VD_SSC_EMSG_SUB);
        break;
      }

      strcpy (me->CUR_subcat, szFld);

      status =
      om$send (msg = message VDSSC.VDSSC_giqty
                       (&retmsg, me->CUR_catnam, me->CUR_subcat, &nDumm),
          targetid = my_id);

      if ((nDumm < 0) && (me->My_Type == VD_CMD_SUM_REV)) break;

      me->nCurQty = nDumm;

      if (me->nCurQty < 0)
      {   /*   NEW cat/subcat, create......  */
        me->nCurQty = me->nMaxQty;
        me->nMaxQty++;

        status =
        om$vla_set_dimension (varray = me->Lsqtyrec,
                              size   = me->nMaxQty);

        strcpy (me->Lsqtyrec[me->nCurQty].szCat, me->CUR_catnam);
        strcpy (me->Lsqtyrec[me->nCurQty].szSub, me->CUR_subcat);

        me->Lsqtyrec[me->nCurQty].nSflag = 0;
        me->Lsqtyrec[me->nCurQty].szExp[0] = '\0';

        me->nBegMtc = me->nEndMtc = me->nCurMtc = me->nMaxMtc;
        me->nMaxMtc++;

        status =
        om$vla_set_dimension (varray = me->Lsmtcrec,
                              size   = me->nMaxMtc);

        strcpy (me->Lsmtcrec[me->nCurMtc].szCat, me->CUR_catnam);
        strcpy (me->Lsmtcrec[me->nCurMtc].szSub, me->CUR_subcat);

        me->Lsmtcrec[me->nCurMtc].nsIndex  = 1;
        me->Lsmtcrec[me->nCurMtc].szAtt[0] = '\0';
        me->Lsmtcrec[me->nCurMtc].szExp[0] = '\0';
        me->Lsmtcrec[me->nCurMtc].nnREL    = 0;       /* ????? */
        me->Lsmtcrec[me->nCurMtc].nDattyp  = VD_DRWLO_EN_ASCII;
#ifdef MY_DEBUG
        printf (" new cat/subcat ptrs %d %d\n",me->nCurQty,me->nCurMtc);
#endif

        status =
        om$send (msg = message VDCmdSSC.VDSSC_ld_sub (&retmsg),
            targetid = my_id);

        if (retmsg != MSSUCC)
        {
          UI_status (VD_SSC_EMSG_MEM);
          _put_response( resp = TERMINATE);
          goto quit;
        }
      }
      else
      {
        status =
        om$send (msg = message VDSSC.VDSSC_gimtc
                       (&retmsg, me->CUR_catnam, me->CUR_subcat,
                        &me->nBegMtc, &me->nEndMtc),
            targetid = my_id);

#ifdef MY_DEBUG
        printf (" old cat/subcat match ptrs %d %d\n",me->nBegMtc,me->nEndMtc);
#endif

        me->nCurMtc = me->nBegMtc;
      }
      break;

    case VD_CRSUM_TGG_QTYP:
      if (me->My_Type == VD_CMD_SUM_REV) break;

      if (me->nCurQty < 0) break;

      me->Lsqtyrec[me->nCurQty].nSflag = 1 - me->Lsqtyrec[me->nCurQty].nSflag;
      break;

    case VD_CRSUM_TGG_ATYP:
      if (me->My_Type == VD_CMD_SUM_REV) break;

      if (me->nCurMtc < 0) break;

      me->Lsmtcrec[me->nCurMtc].nDattyp = 1 - me->Lsmtcrec[me->nCurMtc].nDattyp;
      break;

    case VD_CRSUM_FLD_QEXP:
      if (me->My_Type == VD_CMD_SUM_REV) break;

      if (me->nCurQty < 0) break;

      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      strcpy (me->Lsqtyrec[me->nCurQty].szExp, szFld);
      break;

    case VD_CRSUM_FLD_MATT:
      if (me->My_Type == VD_CMD_SUM_REV) break;

      if (me->nCurMtc < 0) break;

      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      strcpy (me->Lsmtcrec[me->nCurMtc].szAtt, szFld);
      break;

    case VD_CRSUM_FLD_MEXP:
      if (me->My_Type == VD_CMD_SUM_REV) break;

      if (me->nCurMtc < 0) break;

      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      strcpy (me->Lsmtcrec[me->nCurMtc].szExp, szFld);
      break;

    case VD_CRSUM_FLD_MREL:
      if (me->My_Type == VD_CMD_SUM_REV) break;

      if (me->nCurMtc < 0) break;

      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      iSet1 = -1;

      for (i=0; i<me->nNumComp; i++)
      {
        idsp = i * VD_CRSUM_STL_COMPAR;
        if (strcmp (&me->pCompar[idsp], szFld) == 0)
        {
          iSet1 = i;
          break;
        }
      }

      if (iSet1 < 0)
        strcpy (szmsg, VD_SSC_EMSG_INV);
      else
      {
        me->Lsmtcrec[me->nCurMtc].nnREL = iSet1;

        if (iSet1 == VD_cnt_qry_NONE)
        {
/*          me->Lsmtcrec[me->nCurMtc].szAtt[0] = '\0'; */
          me->Lsmtcrec[me->nCurMtc].szExp[0] = '\0';
        }
      }
      break;

    case VD_CRSUM_BTN_UP:
      if (me->CUR_subcat[0] == '\0') break;

      if (me->nCurMtc < 0) me->nCurMtc = me->nBegMtc;
      else
      if (me->nCurMtc < me->nEndMtc) me->nCurMtc++;
      break;

    case VD_CRSUM_BTN_DOWN:
      if (me->CUR_subcat[0] == '\0') break;

      if (me->nCurMtc > me->nBegMtc)       me->nCurMtc--;
      else
      if (me->My_Type == VD_CMD_SUM_EDIT)  me->nCurMtc = -1;
      break;

    case VD_CRSUM_FLD_MSEQ:
      nDumm = -1;
      for (i=me->nBegMtc; i<=me->nEndMtc; i++)
      {
        if (nVal == me->Lsmtcrec[i].nsIndex)
        {
          nDumm = i;
          break;
        }
      }

      if (nDumm < 0)
        strcpy (szmsg, VD_SSC_EMSG_PAR);
      else
        me->nCurMtc = nDumm;
      break;

    case VD_CRSUM_BTN_INSERT:
      if (me->My_Type == VD_CMD_SUM_REV) break;

      if (me->CUR_subcat[0] == '\0') break;

      me->nMaxMtc++;

      status =
      om$vla_set_dimension (varray = me->Lsmtcrec,
                            size   = me->nMaxMtc);

      if (me->nCurMtc < 0)
        ibeg = me->nBegMtc;
      else
        ibeg = me->nCurMtc + 1;

#ifdef MY_DEBUG
      printf (" insert, start loop %d %d\n",(me->nMaxMtc-2), ibeg);
#endif

      for (i=(me->nMaxMtc-2); i>=ibeg; i--)
      {
#ifdef MY_DEBUG
        printf ("move %d to %d\n",i,i+1);
#endif
        strcpy (me->Lsmtcrec[i+1].szCat, me->Lsmtcrec[i].szCat);
        strcpy (me->Lsmtcrec[i+1].szSub, me->Lsmtcrec[i].szSub);
        strcpy (me->Lsmtcrec[i+1].szAtt, me->Lsmtcrec[i].szAtt);
        strcpy (me->Lsmtcrec[i+1].szExp, me->Lsmtcrec[i].szExp);

        me->Lsmtcrec[i+1].nsIndex = me->Lsmtcrec[i].nsIndex;
        if (i <= me->nEndMtc)
        {
          me->Lsmtcrec[i+1].nsIndex++;
#ifdef MY_DEBUG
          printf ("increment nsindex at %d to %d\n",i+1,
                                 me->Lsmtcrec[i+1].nsIndex);
#endif
        }

        me->Lsmtcrec[i+1].nnREL   = me->Lsmtcrec[i].nnREL;
        me->Lsmtcrec[i+1].nDattyp = me->Lsmtcrec[i].nDattyp;
      }

      me->nEndMtc++;
      if (me->nCurMtc < 0)
        me->nCurMtc = me->nBegMtc;
      else
        me->nCurMtc++;

#ifdef MY_DEBUG
        printf ("Newent %d at %d\n",me->nCurMtc - me->nBegMtc + 1,
                                    me->nCurMtc);
#endif
      strcpy (me->Lsmtcrec[me->nCurMtc].szCat, me->CUR_catnam);
      strcpy (me->Lsmtcrec[me->nCurMtc].szSub, me->CUR_subcat);

      me->Lsmtcrec[me->nCurMtc].nsIndex  = me->nCurMtc - me->nBegMtc + 1;
      me->Lsmtcrec[me->nCurMtc].szAtt[0] = '\0';
      me->Lsmtcrec[me->nCurMtc].szExp[0] = '\0';
      me->Lsmtcrec[me->nCurMtc].nnREL    = 0;       /* ????? */
      me->Lsmtcrec[me->nCurMtc].nDattyp  = VD_DRWLO_EN_ASCII;

#ifdef MY_DEBUG
      printf (" begmtc,endmtc %d %d\n",me->nBegMtc,me->nEndMtc);

      for (i=0; i<me->nMaxMtc; i++)
        printf (" insert result %s %s %d %d\n",me->Lsmtcrec[i].szCat,
                            me->Lsmtcrec[i].szSub, me->Lsmtcrec[i].nsIndex,
                             me->Lsmtcrec[i].nnREL);
#endif
      break;

    case VD_CRSUM_BTN_DELETE:
      if (me->My_Type == VD_CMD_SUM_REV) break;

      if (me->CUR_subcat[0] == '\0') break;
      if (me->nCurMtc < 0) break;

      if (me->nBegMtc == me->nEndMtc)
      {
        strcpy (szmsg, VD_CRSUM_EMSG_NDEL);
        break;
      }

      for (i=me->nCurMtc; i<(me->nMaxMtc-1); i++)
      {
#ifdef MY_DEBUG
        printf ("delete, move %d to %d\n",i+1,i);
#endif
        strcpy (me->Lsmtcrec[i].szCat, me->Lsmtcrec[i+1].szCat);
        strcpy (me->Lsmtcrec[i].szSub, me->Lsmtcrec[i+1].szSub);
        strcpy (me->Lsmtcrec[i].szAtt, me->Lsmtcrec[i+1].szAtt);
        strcpy (me->Lsmtcrec[i].szExp, me->Lsmtcrec[i+1].szExp);

        me->Lsmtcrec[i].nsIndex = me->Lsmtcrec[i+1].nsIndex;
        if (i < me->nEndMtc) 
          me->Lsmtcrec[i].nsIndex--;

        me->Lsmtcrec[i].nnREL   = me->Lsmtcrec[i+1].nnREL;
        me->Lsmtcrec[i].nDattyp = me->Lsmtcrec[i+1].nDattyp;
      }

      me->nMaxMtc--;
      me->nEndMtc--;
      me->nCurMtc--;
      if (me->nCurMtc < me->nBegMtc) me->nCurMtc = me->nBegMtc;

#ifdef MY_DEBUG
      printf (" begmtc,endmtc %d %d\n",me->nBegMtc,me->nEndMtc);

      for (i=0; i<me->nMaxMtc; i++)
        printf (" delete result %s %s %d %d\n",me->Lsmtcrec[i].szCat,
                      me->Lsmtcrec[i].szSub, me->Lsmtcrec[i].nsIndex,
                       me->Lsmtcrec[i].nnREL);
#endif
      status =
      om$vla_set_dimension (varray = me->Lsmtcrec,
                            size   = me->nMaxMtc);
      break;

    case VD_CRSUM_BTN_DELCAT:
      if (me->My_Type == VD_CMD_SUM_REV) break;

      if (me->CUR_subcat[0] == '\0') break;
      if (me->nEndMtc < 0)           break;
      if (me->nCurQty < 0)           break;

      /*    remove one quantity record    */

      for (i=me->nCurQty; i< (me->nMaxQty-1); i++)
      {
        strcpy (me->Lsqtyrec[i].szCat, me->Lsqtyrec[i+1].szCat);
        strcpy (me->Lsqtyrec[i].szSub, me->Lsqtyrec[i+1].szSub);
        strcpy (me->Lsqtyrec[i].szExp, me->Lsqtyrec[i+1].szExp);
        me->Lsqtyrec[i].nSflag = me->Lsqtyrec[i+1].nSflag;
#ifdef MY_DEBUG
        printf ("move qty %d to %d subcat %s\n", i+1, i, 
                                me->Lsqtyrec[i].szSub);
#endif
      }

      me->nCurQty = -1;
      me->nMaxQty--;

      status =
      om$vla_set_dimension (varray = me->Lsqtyrec,
                            size   = me->nMaxQty);

      ibeg = me->nBegMtc;

      /*    remove all pertinent match records   */

      for (i=(me->nEndMtc+1); i< me->nMaxMtc; i++)
      {
        strcpy (me->Lsmtcrec[ibeg].szCat, me->Lsmtcrec[i].szCat);
        strcpy (me->Lsmtcrec[ibeg].szSub, me->Lsmtcrec[i].szSub);

        strcpy (me->Lsmtcrec[ibeg].szAtt, me->Lsmtcrec[i].szAtt);
        strcpy (me->Lsmtcrec[ibeg].szExp, me->Lsmtcrec[i].szExp);

        me->Lsmtcrec[ibeg].nsIndex = me->Lsmtcrec[i].nsIndex;
        me->Lsmtcrec[ibeg].nnREL   = me->Lsmtcrec[i].nnREL;
        me->Lsmtcrec[ibeg].nDattyp = me->Lsmtcrec[i].nDattyp;

#ifdef MY_DEBUG
        printf ("move match %d to %d subcat %s\n",i,ibeg,
                              me->Lsmtcrec[ibeg].szSub);
#endif
        ibeg++;
      }

      me->nMaxMtc = ibeg;
      me->nCurMtc = me->nBegMtc = me->nEndMtc = -1;

      status =
      om$vla_set_dimension (varray = me->Lsmtcrec,
                            size   = me->nMaxMtc);

      me->CUR_subcat[0] = '\0';

      status =
      om$send (msg = message VDCmdSSC.VDSSC_ld_sub (&retmsg),
          targetid = my_id);

      if (retmsg != MSSUCC)
      {
        UI_status (VD_SSC_EMSG_MEM);
        _put_response( resp = TERMINATE);
        goto quit;
      }
      break;

/* ------------------------  CONTROL BAR GADGETS --------------------------- */

    case FI_ACCEPT:
    case FI_EXECUTE:
      if (me->My_Type == VD_CMD_SUM_REV) break;

      if (me->CUR_tabnam[0] == '\0')
      {
        strcpy (szmsg, VD_SSC_EMSG_NTAB);
        break;
      }

      szLocC[0] = '\0';
      szLocS[0] = '\0';

      status =
      om$send (msg = message VDSSC.VDSSC_check
                                 (&retmsg, &iSet1, szLocC, szLocS, &iSet2),
          targetid = my_id);

      if (retmsg != MSSUCC)
      {
        strcpy (me->CUR_catnam, szLocC);
        strcpy (me->CUR_subcat, szLocS);

        if (iSet1 < 0)
        {   /* qty records ok, set real to correspond with mtc... */ 
          status =
          om$send (msg = message VDSSC.VDSSC_giqty
                      (&retmsg, me->CUR_catnam, me->CUR_subcat, &me->nCurQty),
              targetid = my_id);
        }
        else
          me->nCurQty = iSet1;

        status =
        om$send (msg = message VDSSC.VDSSC_gimtc
                       (&retmsg, me->CUR_catnam, me->CUR_subcat,
                        &me->nBegMtc, &me->nEndMtc),
            targetid = my_id);

        me->nCurMtc = iSet2;

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

  FIg_set_text (form_ptr, VD_CRSUM_FLD_MSG, szmsg);

  status =
  om$send (msg = message VDCmdSSC.VDSSC_disp (form_ptr),
      targetid = my_id);

  quit:
  return (status);
}

end implementation VDCmdSSC;

