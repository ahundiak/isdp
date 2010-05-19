
/* $Id: VDDLO_edfn.I,v 1.2 2002/04/25 17:59:50 ahundiak Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDDLO_edfn.I
 *
 * Description:
 *
 * Implementation file for main edit form notification
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDLO_edfn.I,v $
 *      Revision 1.2  2002/04/25 17:59:50  ahundiak
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/03/19  18:09:48  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by vgnair for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.20  1995/11/29  13:56:12  pinnacle
# Replaced: ./vdtbl/cmd/VDDLO_edfn.I for:  by ksundar for vds.240
#
# Revision 1.19  1995/11/17  22:28:10  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by hverstee for vds.240
#
# Revision 1.18  1995/11/13  23:18:36  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by hverstee for vds.240
#
# Revision 1.17  1995/11/13  21:25:40  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by hverstee for vds.240
#
# Revision 1.16  1995/11/10  23:21:46  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by hverstee for vds.240
#
# Revision 1.15  1995/11/10  21:22:36  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by hverstee for vds.240
#
# Revision 1.14  1995/09/29  13:24:00  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by yzhu for vds.240
#
# Revision 1.13  1995/09/25  22:57:44  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by sundar for vds.240
#
# Revision 1.12  1995/09/22  14:06:26  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by hverstee for vds.240
#
# Revision 1.11  1995/09/20  22:04:12  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by hverstee for vds.240
#
# Revision 1.10  1995/09/08  19:37:24  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by hverstee for vds.240
#
# Revision 1.9  1995/09/05  23:16:54  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by hverstee for vds.240
#
# Revision 1.8  1995/08/15  23:51:40  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by hverstee for vds.240
#
# Revision 1.7  1995/08/14  22:44:18  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/08/11  23:36:48  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/08/03  21:08:20  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/07/11  21:56:02  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/06  16:03:32  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  20:00:14  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/05/15  16:19:06  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I by hverstee r#
#
# Revision 1.3  1995/05/11  16:56:22  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I by hverstee r#
#
# Revision 1.2  1995/05/08  20:39:00  pinnacle
# Replaced: vdtbl/cmd/VDDLO_edfn.I by hverstee r#
#
# Revision 1.1  1995/04/13  14:04:08  pinnacle
# Created: vdtbl/cmd/VDDLO_edfn.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/20/95          HV            New
 *      09/29/95          YZ            add message "Loading Table Layout..."
 *                                      in case VD_DLOM_FLD_TABNAM 
 * 	03/  /98 	  vini		TR-179800596
 *	04/24/02	ah		Removed the FIproto include
 * -------------------------------------------------------------------*/

class implementation VDCmdDLO;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "gr.h"
#include "FI.h"

%safe
#include <math.h>
/* #include "VX_FIproto.h" */
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
#include "VDmem.h"

#include "VDdrwlo_pr.h"

/*
#define   MY_DEBUG
*/



method   VDDLO_ed_formnot  (int        gadget_label;
                            double     value;
                            char     * form_ptr)
{
  IGRint       status;
  IGRlong      retmsg;
  IGRshort     nNames;
  IGRshort     iTemp;
  IGRchar      szFld[VD_DRWLO_CHR_BUFFER];
  IGRchar      szFl1[VD_DRWLO_CHR_BUFFER];
  IGRshort     nThdtr;
  IGRshort     nLinLoc;
  IGRchar      szmsg[80];
  int          i, idsp;
  IGRshort     iFF;
  IGRshort     nerr;
  IGRint       nVal;
  IGRint       iType;

  IGRint       row1, row2;

  struct   VDdrwlo_tab       Local;

  struct   GRid              lGRID;
  struct   VDdrwlo_ins_htf   LocHTF;
  struct   VDdrwlo_db_col    LocCOL;

  extern IGRboolean   VD_TBL_idquote (IGRchar   *szFld);

  status   = OM_S_SUCCESS;
  szmsg[0] = '\0';
  nVal     = (value > 0) ? (value + 0.001) : (value - 0.001);

  me->My_localret = 0;

  FIfld_get_type (form_ptr, gadget_label, 0, &iType);
  if (iType == FI_ALPHA)
    FIg_get_text (form_ptr, gadget_label, szFld);

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_check
                            (&retmsg, &nerr, me->ppFile, NULL),
      targetid = my_id);

#ifdef MY_DEBUG
  printf (" EDIT formnot, gadget %d\n",gadget_label);
#endif

  FIg_set_text (form_ptr, VD_DLOM_FLD_MSG, szmsg);

  switch (gadget_label)
  {

/* ---------------------  HEADER SECTION GADGETS -------------------------- */

    case VD_DLOM_FLD_TABTYP:
      if (szFld[0] == '\0') break;
      szFld[VD_DRWLO_CHR_IDFLD-1] = '\0';

      if (VD_TBL_idquote(szFld))
      {
        strcpy  (szmsg, VD_DLO_EMSG_QTE);
        break;
      }

      status = VD_drwlo_getnm (&retmsg, szFld, &nNames, NULL);

      strcpy (me->CUR_tabtyp, szFld);
      strcpy (me->Ltbrec.Tabtyp, me->CUR_tabtyp);

      if (nNames == 0)  break;   /*   no limited list available   */

      status = VD_drwlo_getnm (&retmsg, szFld, &me->nTabLims, me->pTabLims);

      FIfld_set_list_num_rows(form_ptr,VD_DLOM_FLD_TABNAM,0,(int)me->nTabLims);
      if (me->nTabLims > 10)
        FIfld_set_list_scroll (form_ptr, VD_DLOM_FLD_TABNAM, 1, 0);
      else
        FIfld_set_list_scroll (form_ptr, VD_DLOM_FLD_TABNAM, 0, 0);

      for (i=0; i<me->nTabLims; i++)
      {
        idsp = i * VD_DRWLO_CHR_IDFLD;
        VDfld_set_list_text (form_ptr, VD_DLOM_FLD_TABNAM, i, 0, 
                                       &me->pTabLims[idsp], FALSE);
      }
      break;

    case VD_DLOM_FLD_TABNAM:
      if (szFld[0] == '\0') break;
      FIg_set_text (form_ptr, VD_DLOM_FLD_MSG, "Loading Table Layout...");
      szFld[VD_DRWLO_CHR_IDFLD-1] = '\0';

      if (VD_TBL_idquote(szFld))
      {
        strcpy  (szmsg, VD_DLO_EMSG_QTE);
        break;
      }

      if (me->CUR_tabnam[0] != '\0')
      {   /*   one already active, give warning    */
        sprintf (szmsg, VD_DLO_EMSG_NACT, me->CUR_tabnam);
        break;
      }

#ifdef MY_DEBUG
      printf (" To getid %s\n",szFld);
#endif

      status = VD_drwlo_getid (&retmsg, szFld, me->CUR_tabtyp, &lGRID);

#ifdef MY_DEBUG
      printf (" from getid %d %d\n",lGRID.objid, lGRID.osnum);
#endif

      strcpy (me->CUR_tabnam, szFld);

      me->My_stored_lo.objid = lGRID.objid;
      me->My_stored_lo.osnum = lGRID.osnum;

      if (lGRID.objid == NULL_OBJID)
      {   /*    does not exist, create new   */
        strcpy (Local.Tabnam, me->CUR_tabnam);
        strcpy (Local.Tabtyp, me->CUR_tabtyp);

        strcpy (Local.Shdesc, "");
        strcpy (Local.SumFil, "");
        strcpy (Local.SortFil, "");

        Local.direct = VD_DRWLO_EN_DESCEND;
        Local.Local  = TRUE;

        status =
        om$send (msg = message VDdrwlo.VDdrwlo_init (&retmsg, &Local),
            targetid = my_id);

        sprintf (szmsg, VD_DLO_EMSG_NLAY, szFld);
        strcat  (szmsg, VD_DLO_EMSG_CRE);
      }
      else
      {
        status =
        om$send (msg = message VDCmdDLO.VDDLO_load (&retmsg, &lGRID),
            targetid = my_id);

        strcpy (me->CUR_tabtyp, me->Ltbrec.Tabtyp);

        VD_DLO_SetIndx (me->Ltbrec.Userid, me->Ltbrec.Timest,
                         &me->Ltbrec.Local, &me->Ltbrec.LcUnit);
      }

      me->nCur_colrec = -1;
      me->nCur_htfrec = -1;
      me->nCur_fldrec = -1;

      /*   set max col number   */

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_gcol
                          (&retmsg, VD_DRWLO_EN_ALL, &me->nMax_colnum, NULL),
          targetid = my_id);

      FIg_set_text (form_ptr, VD_DLOM_FLD_MSG, "");

      break;

    case VD_DLOM_FLD_SUMM:
/*    if (szFld[0] == '\0') break;  */
      szFld[VD_DRWLO_CHR_IDFLD-1] = '\0';

      if (VD_TBL_idquote(szFld))
      {
        strcpy  (szmsg, VD_DLO_EMSG_QTE);
        break;
      }

      if (strcmp (szFld, VD_DLO_DSP_EMPTY) == 0)
        szFld[0] = '\0';

      strcpy (me->Ltbrec.SumFil, szFld);
      FIg_set_text (form_ptr, gadget_label,me->Ltbrec.SumFil);
      break;

    case VD_DLOM_FLD_SORT:
/*    if (szFld[0] == '\0') break;  */
      szFld[VD_DRWLO_CHR_IDFLD-1] = '\0';

      if (VD_TBL_idquote(szFld))
      {
        strcpy  (szmsg, VD_DLO_EMSG_QTE);
        break;
      }

      if (strcmp (szFld, VD_DLO_DSP_EMPTY) == 0)
        szFld[0] = '\0';

      strcpy (me->Ltbrec.SortFil, szFld);
      FIg_set_text (form_ptr, gadget_label,me->Ltbrec.SortFil);
      break;

    case VD_DLOM_FLD_DESCR:
/*    if (szFld[0] == '\0') break;  */
      szFld[VD_DRWLO_CHR_DESC-1] = '\0';

      strcpy (me->Ltbrec.Shdesc, szFld);
      FIg_set_text (form_ptr, gadget_label,me->Ltbrec.Shdesc);
      break;

    case VD_DLOM_TGG_DISPSEQ:
      me->Ltbrec.direct = 1 - me->Ltbrec.direct;
      FIg_set_value (form_ptr, gadget_label, (double) me->Ltbrec.direct);
      break;

    case VD_DLOM_BTN_COPY:
      me->bCP_lo  = !me->bCP_lo;
      me->bCP_fld = FALSE;
      goto OSET_BYPASS;           /*   bypass reset for one cycle   */

    case VD_DLOM_FLD_COPY:
      if (szFld[0] == '\0') break;
      szFld[VD_DRWLO_CHR_IDFLD-1] = '\0';

      if (VD_TBL_idquote(szFld))
      {
        strcpy  (szmsg, VD_DLO_EMSG_QTE);
        break;
      }

      if (me->My_stored_lo.objid != NULL_OBJID)
      {   /*    already one active, save or reset first  */
        FIg_set_text (form_ptr, VD_DLOM_FLD_MSG,
                      "Layout active, save or reset first");
        break;
      }

      status = VD_drwlo_getid (&retmsg, szFld, me->CUR_tabtyp, &lGRID);

      if (lGRID.objid == NULL_OBJID)
      {
        sprintf (szmsg, VD_DLO_EMSG_NLAY, szFld);
        break;
      }

      strcpy (Local.Timest, me->Ltbrec.Timest);
      strcpy (Local.Userid, me->Ltbrec.Userid);

      status =
      om$send (msg = message VDCmdDLO.VDDLO_load (&retmsg, &lGRID),
          targetid = my_id);

      strcpy (me->Ltbrec.Tabtyp, me->CUR_tabtyp);
      strcpy (me->Ltbrec.Tabnam, me->CUR_tabnam);
      strcpy (me->Ltbrec.Timest, Local.Timest);
      strcpy (me->Ltbrec.Userid, Local.Userid);

      me->My_stored_lo.objid = NULL_OBJID;
      me->My_stored_lo.osnum = lGRID.osnum;

      me->nCur_colrec = -1;
      me->nCur_htfrec = -1;
      me->nCur_fldrec = -1;

      /*   set max col number   */

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_gcol
                          (&retmsg, VD_DRWLO_EN_ALL, &me->nMax_colnum, NULL),
          targetid = my_id);

      sprintf (szmsg, VD_DLO_EMSG_LCPY, szFld, me->CUR_tabnam);
      break;

    case VD_DLOM_BTN_SHOW:  /*   show layout   */
      if (me->My_Preview_up)
      {
        IGRboolean    bGRonly;

        bGRonly = FALSE;

        status =
        om$send (msg = message VDCmdDLO.VDDLO_pvdel (&retmsg, bGRonly),
            targetid = my_id);
      }
      else
      {
        IGRboolean   bFit;

        bFit = TRUE;

        status =
        om$send (msg = message VDCmdDLO.VDDLO_pvwin (&retmsg),
            targetid = my_id);

        status =
        om$send (msg = message VDCmdDLO.VDDLO_pvdsp (&retmsg, bFit),
            targetid = my_id);
      }
      goto quit;      /*   no redisplay necessary   */

    case VD_DLOM_FLD_GREDIT:
      if (szFld[0] == '\0') break;
      szFld[VD_DRWLO_CHR_IDFLD-1] = '\0';

      if (me->CUR_tabnam[0] == '\0')
      {
        strcpy (szmsg, VD_DLO_EMSG_NTAB);
        break;
      }

      me->nCur_group = VD_DRWLO_EN_ALL;
      for (i=0; i<5; i++)
      {
        idsp = i * VD_DRWLO_CHR_IDFLD;
        if (strcmp (szFld, &(me->pr_groups[idsp])) == 0)
        {
          me->nCur_group = i;
	  /* added if-else statement for TR-179800596 --vini */
	  if( me->nCur_group != 0 ) 
		strcpy (&me->pr_filltyp[VD_DRWLO_CHR_IDFLD*9],"Cell");
	  else strcpy (&me->pr_filltyp[VD_DRWLO_CHR_IDFLD*9],"");
          break;
        }
      }

      if (me->nCur_group == VD_DRWLO_EN_ALL)
      {
        strcpy (szmsg, VD_DLO_EMSG_INV);
        break;
      }

      if ((me->nCur_group != VD_DRWLO_EN_DATA) &&
          (me->nMax_colnum <= 0))
      {
        strcpy (szmsg, VD_DLO_EMSG_NCOL);
        me->nCur_group = VD_DRWLO_EN_ALL;
        break;
      }

      me->FldCUR.hdtr_type = me->nCur_group;

      if (me->nCur_group != VD_DRWLO_EN_DATA)
      {
        FIg_reset (form_ptr, VD_DLOH_FLD_OFFSET);

        status =
        om$send (msg = message VDCmdDLO.VDDLO_ld_alg (&retmsg, me->nCur_group),
            targetid = my_id);

#ifdef MY_DEBUG
      printf (" after ld_alg %d lines\n",me->nAlg_lines);
#endif
      }

      status =
      om$send (msg = message VDCmdDLO.VDDLO_ld_fld (&retmsg, me->nCur_group),
          targetid = my_id);

      me->nCur_colnum = 0;
      me->sCur_fieldid[0] = '\0';

      me->nCur_colrec = -1;
      me->nCur_htfrec = -1;
      me->Pv_need_update = TRUE;
      break;

    case VD_DLOB_BTN_FILL:
      if (me->nCur_group == VD_DRWLO_EN_ALL) break;

      FIg_disable (form_ptr, FI_RESET);
      FIg_disable (form_ptr, FI_ACCEPT);
      FIg_disable (form_ptr, FI_EXECUTE);
      FIg_disable (form_ptr, FI_CANCEL);

      /*    switch to fill form   */
      me->My_actv_form = VD_DLO_FILLFORM;
      me->My_localret  = VD_DLO_RETC_SUB;
      me->nCur_linenum = 0;
      me->nCur_fldrec  = -1;

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

      _put_response( resp = EX_DATA );
      goto quit;     /* switch form, no redisplay of old... */

/* -------------------  DATA COLUMN SECTION GADGETS ------------------------ */

    case VD_DLOC_FLD_COLNUM:
      if ((nVal <= 0) || (nVal > me->nMax_colnum))
      {
        strcpy (szmsg, VD_DLO_EMSG_PAR);
        break;
      }

      me->nCur_colnum = nVal;
      goto C_PROCESS;

    case VD_DLOC_BTN_COLDN:
      if (me->nCur_colnum > 0) me->nCur_colnum--;
      goto C_PROCESS;

    case VD_DLOC_BTN_COLUP:
      if (me->nCur_colnum < me->nMax_colnum) me->nCur_colnum++;

      C_PROCESS:   /*   display current column values  */
      status =
      om$send (msg = message VDdrwlo.VDdrwlo_xcol
                                 (&retmsg, me->nCur_colnum, &me->nCur_colrec),
          targetid = my_id);

#ifdef MY_DEBUG
	      printf (" column %d from %f to %f\n",me->nCur_colnum,
                        me->Lcolrec[me->nCur_colrec].col_x1,
                        me->Lcolrec[me->nCur_colrec].col_x2);
#endif
      break;

    case VD_DLOC_BTN_INSCOL:
      VD_drwlo_mcol (&LocCOL, &me->ColCUR.col_db);
      LocCOL.col_seqno = me->nCur_colnum + 1;

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_icol (&retmsg, &LocCOL),
          targetid = my_id);

      /*   reset max col number   */

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_gcol
                          (&retmsg, VD_DRWLO_EN_ALL, &me->nMax_colnum, NULL),
          targetid = my_id);

      /*   move to new column   */

      (me->nCur_colnum)++;
      status =
      om$send (msg = message VDdrwlo.VDdrwlo_xcol
                                 (&retmsg, me->nCur_colnum, &me->nCur_colrec),
          targetid = my_id);

#ifdef MY_DEBUG
      printf ("from default numlines %d\n",me->ColCUR.col_lns);
#endif
      me->Lcolrec[me->nCur_colrec].col_lns = me->ColCUR.col_lns;

      if (me->ColCUR.col_lns > 0)
      {  /*   insert field records   */
        int      iii;
        struct   VDdrwlo_db_fld    LocFLD;

        VD_drwlo_mfld (&LocFLD, &me->FldCUR);

        LocFLD.hdtr_type = me->nCur_group;
        LocFLD.col_seqno = me->nCur_colnum;

#ifdef MY_DEBUG
        printf ("to loop numlines %d\n",me->ColCUR.col_lns);
#endif
        for (iii=1; iii<=me->ColCUR.col_lns; iii++)
        {
          LocFLD.lin_seqno = iii;

#ifdef MY_DEBUG
          printf ("New field for column %d\n",iii);
#endif
          status =
          om$send (msg = message VDdrwlo.VDdrwlo_pfld (&retmsg, 1, &LocFLD),
              targetid = my_id);
        }
      }

      me->Pv_need_update = TRUE;
      break;

    case VD_DLOC_BTN_DELCOL:
      if (me->nCur_colnum > 0)
      {
        status =
        om$send (msg = message VDdrwlo.VDdrwlo_dcol (&retmsg, me->nCur_colnum),
            targetid = my_id);

        if (me->nCur_colnum == me->nMax_colnum) me->nCur_colnum--;
        me->nMax_colnum--;

        status =
        om$send (msg = message VDdrwlo.VDdrwlo_xcol
                                 (&retmsg, me->nCur_colnum, &me->nCur_colrec),
            targetid = my_id);

        me->Pv_need_update = TRUE;
      }
      break;

/* -----------------------  HTF SECTION GADGETS ---------------------------- */

    case VD_DLOH_FLD_FLDID:
      if (szFld[0] == '\0') break;
      szFld[VD_DRWLO_CHR_IDFLD-1] = '\0';

      if (VD_TBL_idquote(szFld))
      {
        strcpy  (szmsg, VD_DLO_EMSG_QTE);
        break;
      }

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_xhtf
                          (&retmsg, me->nCur_group, szFld, &me->nCur_htfrec),
          targetid = my_id);

      strcpy (me->sCur_fieldid, szFld);

      if (me->nCur_htfrec < 0)
      {  /*   new field declaration, create    */
        VD_drwlo_mhtf (&LocHTF.htf_db, &me->HtfCUR.htf_db);

        strcpy (LocHTF.htf_db.fieldid, szFld);
        LocHTF.htf_db.hdtr_type = me->nCur_group;

        status =
        om$send (msg = message VDdrwlo.VDdrwlo_phtf
                                        (&retmsg, 1, &LocHTF.htf_db),
            targetid = my_id);

        status =
        om$send (msg = message VDCmdDLO.VDDLO_ld_fld (&retmsg, me->nCur_group),
            targetid = my_id);

        status =
        om$send (msg = message VDdrwlo.VDdrwlo_xhtf
                          (&retmsg, me->nCur_group, szFld, &me->nCur_htfrec),
            targetid = my_id);

#ifdef MY_DEBUG
      printf ("from default numlines %d\n",me->HtfCUR.htf_lns);
#endif
        me->Lhtfrec[me->nCur_htfrec].htf_lns = me->HtfCUR.htf_lns;

        if (me->HtfCUR.htf_lns > 0)
        {  /*   insert field records   */
          struct   VDdrwlo_db_fld    LocFLD;

          VD_drwlo_mfld (&LocFLD, &me->FldCUR);

          LocFLD.hdtr_type = me->nCur_group;
          LocFLD.col_seqno = VD_DRWLO_EN_ALL;

          strcpy (LocFLD.fieldid, szFld);

          for (i=1; i<=me->HtfCUR.htf_lns; i++)
          {
            LocFLD.lin_seqno = i;

#ifdef MY_DEBUG
            printf ("New field for htf %d\n",i);
#endif
            status =
            om$send (msg = message VDdrwlo.VDdrwlo_pfld (&retmsg, 1, &LocFLD),
                targetid = my_id);
          }
        }
      }

#ifdef MY_DEBUG
      printf (" field x.. %f %f\n", me->Lhtfrec[me->nCur_htfrec].htf_x1,
                                    me->Lhtfrec[me->nCur_htfrec].htf_x2);
#endif
      break;

    case VD_DLOH_BTN_COPY:
      me->bCP_fld = !me->bCP_fld;
      me->bCP_lo  = FALSE;
      goto OSET_BYPASS;           /*   bypass reset for one cycle   */

    case VD_DLOH_FLD_COPY:
      if (szFld[0] == '\0') break;
      szFld[VD_DRWLO_CHR_IDFLD-1] = '\0';

      if (VD_TBL_idquote(szFld))
      {
        strcpy  (szmsg, VD_DLO_EMSG_QTE);
        break;
      }

      if (me->nCur_htfrec < 0) break;

      /*    find the HTF spec to copy   */

      if (szFld[1] == ':')
      {
        szFl1[0] = szFld[0];
        szFl1[1] = '\0';
        nThdtr   = atoi (szFl1);
        strcpy (szFl1, &szFld[2]);
      }
      else
      {
        nThdtr   = VD_DRWLO_EN_ALL;
        strcpy (szFl1, szFld);
      }

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_xhtf
                          (&retmsg, nThdtr, szFl1, &iTemp),
          targetid = my_id);

      if (iTemp < 0)
      {
        sprintf (szmsg, VD_DLO_EMSG_NFLD, szFld);
        break;
      }

      nThdtr = me->Lhtfrec[iTemp].htf_db.hdtr_type;

      /*    see how many line records it has   */

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_gfld
                        (&retmsg, nThdtr, VD_DRWLO_EN_ALL, szFl1, 
                          VD_DRWLO_EN_ALL, &nLinLoc, NULL),
          targetid = my_id);

      /*    delete the current ones (if any)  */

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_dfld
                        (&retmsg, me->nCur_group, VD_DRWLO_EN_ALL, 
                          me->sCur_fieldid, VD_DRWLO_EN_ALL),
          targetid = my_id);

#ifdef MY_DEBUG
      printf (" copy %d %s to %d %s\n", nThdtr, szFl1, me->nCur_group,
                      me->sCur_fieldid);
#endif

      /*    create or modify the HTF record   */

      VD_drwlo_mhtf (&LocHTF.htf_db, &me->Lhtfrec[iTemp].htf_db);

      LocHTF.htf_db.hdtr_type = me->nCur_group;
      strcpy (LocHTF.htf_db.fieldid, me->sCur_fieldid);

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_phtf
                                 (&retmsg, 1, &LocHTF.htf_db),
          targetid = my_id);

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_xhtf
                             (&retmsg, me->nCur_group, me->sCur_fieldid,
                              &me->nCur_htfrec),
          targetid = my_id);

#ifdef MY_DEBUG
      printf (" copy %d fieldlines\n",nLinLoc);
#endif

      if (nLinLoc > 0)
      {
        struct   VDdrwlo_db_fld   *pLOCfld;

        pLOCfld = _MALLOC (nLinLoc, struct VDdrwlo_db_fld);

        if (pLOCfld == NULL)
        {
          UI_status (VD_DLO_EMSG_MEM);
          _put_response( resp = TERMINATE);
          goto quit;
        }

        status =
        om$send (msg = message VDdrwlo.VDdrwlo_gfld
                                 (&retmsg, nThdtr, 0, szFl1, VD_DRWLO_EN_ALL,
                                  &nLinLoc, pLOCfld),
            targetid = my_id);

        for (iFF=0; iFF<nLinLoc; iFF++)
        {
          pLOCfld[iFF].hdtr_type = me->nCur_group;
          pLOCfld[iFF].lin_seqno = iFF+1;
          pLOCfld[iFF].col_seqno = 0;

          strcpy (pLOCfld[iFF].fieldid, me->sCur_fieldid);
        }

        status =
        om$send (msg = message VDdrwlo.VDdrwlo_pfld
                                 (&retmsg, nLinLoc, pLOCfld),
            targetid = my_id);

        _FREE (pLOCfld);
      }

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_set
                                (&retmsg, VD_DRWLO_EN_ALL, NULL),
          targetid = my_id);

      sprintf (szmsg, VD_DLO_EMSG_FCPY, nThdtr, szFl1, me->nCur_group,
                                        me->sCur_fieldid);
      break;

    case VD_DLOH_BTN_DELFLD:
      if (me->nCur_htfrec < 0) break;

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_dhtf
                                 (&retmsg, me->nCur_group, me->sCur_fieldid),
          targetid = my_id);

      me->nCur_htfrec = -1;
      me->sCur_fieldid[0] = '\0';

      status =
      om$send (msg = message VDCmdDLO.VDDLO_ld_fld (&retmsg, me->nCur_group),
          targetid = my_id);

      me->Pv_need_update = TRUE;
      break;

    case VD_DLOH_FLD_ALGMOD:
      if (value <= 0.0) break;

      if ((me->nAlg_curact != 0) && (me->nAlg_curact != me->nAlg_lines))
      {      /*    modify alignment value   */
        struct   VDdrwlo_db_alg     Align;

        VD_drwlo_malg (&Align, &me->pCur_alg[me->nAlg_curact]);

#ifdef  MY_DEBUG
        printf (" modify aligncode %d %d from %f to %f\n",
                    me->nCur_group, Align.aligncode, Align.value, value);
#endif

        Align.value = value;

        status =
        om$send (msg = message VDdrwlo.VDdrwlo_palign (&retmsg, &Align),
            targetid = my_id);

        status =
        om$send (msg = message VDdrwlo.VDdrwlo_qalign (&retmsg, me->nCur_group),
            targetid = my_id);
      }
      else
      {      /*    insert alignment value     */
        IGRshort    nDumm;
        IGRshort    ii;
        IGRdouble   dEPS, dDIF;

        dEPS = value * 0.0000001;

        /*   check first for duplicate    */

        for (ii=0; ii<me->nAlg_lines; ii++)
        {
          dDIF = value - me->pCur_alg[ii].value;
          if (dDIF < 0) dDIF = - dDIF;

          if (dDIF < dEPS) goto DUPLICATE;
        }

        status =
        om$send (msg = message VDdrwlo.VDdrwlo_ialign
                                 (&retmsg, me->nCur_group, value, &nDumm),
            targetid = my_id);
#ifdef  MY_DEBUG
        printf (" insert aligncode %d at %d for %f\n",
                             me->nCur_group, nDumm, value);
#endif
        me->My_Focus = gadget_label;
      }

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_set
                                (&retmsg, VD_DRWLO_EN_ALL, NULL),
          targetid = my_id);

      me->nAlg_hdtr = VD_DRWLO_EN_ALL;    /*    force reload   */

      status =
      om$send (msg = message VDCmdDLO.VDDLO_ld_alg (&retmsg, me->nCur_group),
          targetid = my_id);
#ifdef MY_DEBUG
      printf (" after ld_alg %d lines\n",me->nAlg_lines);
#endif
      me->Pv_need_update = TRUE;

      DUPLICATE: ;
      break;

    case VD_DLOH_BTN_DELALG:
      status =
      om$send (msg = message VDdrwlo.VDdrwlo_dalign
                            (&retmsg, me->nCur_group,
                              me->pCur_alg[me->nAlg_curact].aligncode),
          targetid = my_id);

      me->nAlg_hdtr = VD_DRWLO_EN_ALL;    /*    force reload   */

      status =
      om$send (msg = message VDCmdDLO.VDDLO_ld_alg (&retmsg, me->nCur_group),
          targetid = my_id);
#ifdef MY_DEBUG
      printf (" after ld_alg %d lines\n",me->nAlg_lines);
#endif

      FIfld_get_active_row (form_ptr, VD_DLOH_FLD_OFFSET,
                               &me->iarow, &me->iapos);

      FIg_reset (form_ptr, VD_DLOH_FLD_OFFSET);

#ifdef MY_DEBUG
      printf (" reset active row %d %d\n",me->iarow, me->iapos);
#endif

      if (me->iarow > 1) me->iarow--;
      if (me->iapos > me->iarow) me->iapos--;

#ifdef MY_DEBUG
      printf (" reset active row %d %d\n",me->iarow, me->iapos);
#endif

      FIfld_set_active_row (form_ptr, VD_DLOH_FLD_OFFSET, me->iarow, me->iapos);

      me->Pv_need_update = TRUE;
      break;

    case VD_DLOH_FLD_OFFSET:
      FIfld_get_active_row (form_ptr, gadget_label, &row1, &row2);
      me->nAlg_curact = row1;
      goto OSET_BYPASS;           /*   bypass reset for one cycle   */

/* ------------------------  CONTROL BAR GADGETS --------------------------- */

    case FI_ACCEPT:
      if (me->CUR_tabnam[0] == '\0')
      {
        strcpy (szmsg, VD_DLO_EMSG_NTAB);
        break;
      }

      status = 
      om$send (msg = message VDCmdDLO.VDDLO_Save  (&retmsg),
          targetid = my_id);

      /*   fall through   */

    case FI_CANCEL:
      status =
      om$send (msg = message VDCmdDLO.save_form_pos
                            (&retmsg, me->My_actv_form, form_ptr),
          targetid = my_id);

      me->My_localret = gadget_label;
      _put_response( resp = EX_FORM_FINISHED );
      break;

    case FI_EXECUTE:
      if (me->CUR_tabnam[0] == '\0')
      {
        strcpy (szmsg, VD_DLO_EMSG_NTAB);
        break;
      }

      status = 
      om$send (msg = message VDCmdDLO.VDDLO_Save  (&retmsg),
          targetid = my_id);

      me->My_localret = gadget_label;
      _put_response( resp = EX_FORM_FINISHED );
      break;

    case FI_RESET:
      status =
      om$send (msg = message VDCmdDLO.VDDLO_Reset (&retmsg),
          targetid = my_id);

      if (retmsg == MSSUCC)
      {
        me->My_localret = gadget_label;
        _put_response( resp = EX_FORM_FINISHED );
      }
      else
      {
        UI_status (VD_DLO_EMSG_MEM);
        _put_response( resp = TERMINATE);
        goto quit;
      }
      break;

/* ---------------------  COMMON SECTION GADGETS --------------------------- */

/*  all cases not yet covered MUST deal with either column data or HTF
    data edits.
    For readability they are covered in a next level method             */

    default:
#ifdef MY_DEBUG
      printf (" next level formnot\n");
#endif
      if (me->nCur_group == VD_DRWLO_EN_DATA)
      {
        status =
        om$send (msg = message VDCmdDLO.VDDLO_co_formnot
                                 (gadget_label, value, form_ptr),
            targetid = my_id);
      }
      else
      if (me->nCur_group != VD_DRWLO_EN_ALL)
      {
        status =
        om$send (msg = message VDCmdDLO.VDDLO_ht_formnot
                                 (gadget_label, value, form_ptr),
            targetid = my_id);
      }
#ifdef MY_DEBUG
      else
        printf (" ERROR edit unknown gadget %d\n", gadget_label);
#endif

      break;
  }

  if (me->nAlg_curact != 0)
    FIfld_set_line_color (form_ptr, VD_DLOH_FLD_OFFSET, (int)me->nAlg_curact,
                        1, -1);
  me->nAlg_curact = 0;   /*   reset active alignment field   */
  me->bCP_lo      = FALSE;  /* reset out of copy mode   */
  me->bCP_fld     = FALSE;  /* reset out of copy mode   */

  OSET_BYPASS:           /*   bypass reset for one cycle   */
  if (szmsg[0] != '\0')
    FIg_set_text (form_ptr, VD_DLOM_FLD_MSG, szmsg);

  status =
  om$send (msg = message VDCmdDLO.VDDLO_disp (form_ptr),
      targetid = my_id);

  quit:
  return (status);
}

end implementation VDCmdDLO;

