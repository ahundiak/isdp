
/* $Id: VDDLO_rvfn.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDDLO_rvfn.I
 *
 * Description:
 *
 * Implementation file for main review form notification
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDLO_rvfn.I,v $
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
# Revision 1.10  1995/11/29  13:56:28  pinnacle
# Replaced: ./vdtbl/cmd/VDDLO_rvfn.I for:  by ksundar for vds.240
#
# Revision 1.9  1995/09/25  22:59:12  pinnacle
# Replaced: vdtbl/cmd/VDDLO_rvfn.I for:  by sundar for vds.240
#
# Revision 1.8  1995/09/05  23:17:36  pinnacle
# Replaced: vdtbl/cmd/VDDLO_rvfn.I for:  by hverstee for vds.240
#
# Revision 1.7  1995/08/15  23:52:02  pinnacle
# Replaced: vdtbl/cmd/VDDLO_rvfn.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/08/14  22:43:04  pinnacle
# Replaced: vdtbl/cmd/VDDLO_rvfn.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/08/11  23:34:08  pinnacle
# Replaced: vdtbl/cmd/VDDLO_rvfn.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/03  21:08:44  pinnacle
# Replaced: vdtbl/cmd/VDDLO_rvfn.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/17  14:43:10  pinnacle
# Replaced: vdtbl/cmd/VDDLO_rvfn.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/06  16:06:30  pinnacle
# Replaced: vdtbl/cmd/VDDLO_rvfn.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:21:22  pinnacle
# Created: vdtbl/cmd/* by tdumbach for vds.240
#
# Revision 1.4  1995/05/15  16:19:40  pinnacle
# Replaced: vdtbl/cmd/VDDLO_rvfn.I by hverstee r#
#
# Revision 1.3  1995/05/11  17:05:16  pinnacle
# Replaced: vdtbl/cmd/VDDLO_rvfn.I by hverstee r#
#
# Revision 1.2  1995/05/08  20:34:08  pinnacle
# Replaced: vdtbl/cmd/VDDLO_rvfn.I by hverstee r#
#
# Revision 1.1  1995/04/13  14:09:14  pinnacle
# Created: vdtbl/cmd/VDDLO_rvfn.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/20/95          HV            New
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



method   VDDLO_rv_formnot  (int        gadget_label;
                            double     value;
                            char     * form_ptr)
{
  IGRint       status;
  IGRlong      retmsg;
  IGRint       nVal;
  IGRshort     nNames;
  IGRchar      szFld[VD_DRWLO_CHR_IDFLD];
  IGRchar      szmsg[80];
  int          i, idsp;

  struct GRid  lGRID;

  status  = OM_S_SUCCESS;

  szmsg[0] = '\0';
  nVal     = (value > 0) ? (value + 0.001) : (value - 0.001);

  me->My_localret = 0;

  FIg_set_text (form_ptr, VD_RLOM_FLD_MSG, szmsg);

  switch (gadget_label)
  {
    case VD_RLOM_FLD_TABTYP:
      me->nCur_group = VD_DRWLO_EN_ALL;
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      szFld[VD_DRWLO_CHR_IDFLD-1] = '\0';

      status = VD_drwlo_getnm (&retmsg, szFld, &nNames, NULL);

      strcpy (me->CUR_tabtyp, szFld);
      strcpy (me->Ltbrec.Tabtyp, me->CUR_tabtyp);

      if (nNames == 0)
      {
        sprintf (szmsg, VD_DLO_EMSG_NTYP, szFld);
        FIg_set_text (form_ptr, VD_RLOM_FLD_MSG, szmsg);
        break;
      }

      status = VD_drwlo_getnm (&retmsg, szFld, &me->nTabLims, me->pTabLims);

      FIfld_set_list_num_rows(form_ptr,VD_RLOM_FLD_TABNAM,0,(int)me->nTabLims);
      if (me->nTabLims > 10)
        FIfld_set_list_scroll (form_ptr, VD_RLOM_FLD_TABNAM, 1, 0);
      else
        FIfld_set_list_scroll (form_ptr, VD_RLOM_FLD_TABNAM, 0, 0);

      for (i=0; i<me->nTabLims; i++)
      {
        idsp = i * VD_DRWLO_CHR_IDFLD;
        VDfld_set_list_text (form_ptr, VD_RLOM_FLD_TABNAM, i, 0, 
                                       &me->pTabLims[idsp], FALSE);
      }
      break;

    case VD_RLOM_FLD_TABNAM:
      me->nCur_group = VD_DRWLO_EN_ALL;
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;
      szFld[VD_DRWLO_CHR_IDFLD-1] = '\0';

      status = VD_drwlo_getid (&retmsg, szFld, me->CUR_tabtyp, &lGRID);

      if (lGRID.objid == NULL_OBJID)
      {
        sprintf (szmsg, VD_DLO_EMSG_NLAY, szFld);
        FIg_set_text (form_ptr, VD_RLOM_FLD_MSG, szmsg);
        break;
      }

      me->My_stored_lo.objid = lGRID.objid;
      me->My_stored_lo.osnum = lGRID.osnum;

      strcpy (me->CUR_tabnam, szFld);

      status =
      om$send (msg = message VDCmdDLO.VDDLO_load (&retmsg, &lGRID),
          targetid = my_id);

      strcpy (me->CUR_tabtyp, me->Ltbrec.Tabtyp);

      /*   set max col number   */

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_gcol
                          (&retmsg, VD_DRWLO_EN_ALL, &me->nMax_colnum, NULL),
          targetid = my_id);
      break;

    case VD_RLOM_BTN_SHOW:  /*   show layout   */
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

    case VD_RLOM_FLD_GREDIT:
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      if (me->CUR_tabnam[0] == '\0')
      {
        sprintf (szmsg,VD_DLO_EMSG_NTAB);
        break;
      }

      me->nCur_group = VD_DRWLO_EN_ALL;
      for (i=0; i<5; i++)
      {
        idsp = i * VD_DRWLO_CHR_IDFLD;
        if (strcmp (szFld, &(me->pr_groups[idsp])) == 0)
        {
          me->nCur_group = i;
          break;
        }
      }

      if (me->nCur_group == VD_DRWLO_EN_ALL)
      {
        strcpy (szmsg, VD_DLO_EMSG_INV);
        break;
      }

      me->FldCUR.hdtr_type = me->nCur_group;

      status =
      om$send (msg = message VDCmdDLO.VDDLO_ld_alg (&retmsg, me->nCur_group),
          targetid = my_id);

      status =
      om$send (msg = message VDCmdDLO.VDDLO_ld_fld (&retmsg, me->nCur_group),
          targetid = my_id);

      me->nCur_colnum = 0;
      me->sCur_fieldid[0] = '\0';

      me->nCur_colrec = -1;
      me->nCur_htfrec = -1;
      break;

    case VD_RLOB_BTN_FILL:
      if (me->nCur_group == VD_DRWLO_EN_ALL) break;

      FIg_disable (form_ptr, FI_CANCEL);

      /*    switch to fill form   */
      me->My_actv_form = VD_RLO_FILLFORM;
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

    case VD_RLOC_FLD_COLNUM:
      if ((nVal <= 0) || (nVal > me->nMax_colnum))
      {
        strcpy (szmsg, VD_DLO_EMSG_PAR);
        break;
      }

      me->nCur_colnum = nVal;
      goto C_PROCESS;

    case VD_RLOC_BTN_COLDN:
      if (me->nCur_colnum > 1) me->nCur_colnum--;
      goto C_PROCESS;

    case VD_RLOC_BTN_COLUP:
      if (me->nCur_colnum < me->nMax_colnum) me->nCur_colnum++;

      C_PROCESS:   /*   display current column values  */
      status =
      om$send (msg = message VDdrwlo.VDdrwlo_xcol
                                 (&retmsg, me->nCur_colnum, &me->nCur_colrec),
          targetid = my_id);
      break;

    case VD_RLOH_FLD_FLDID:
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_xhtf
                          (&retmsg, me->nCur_group, szFld, &me->nCur_htfrec),
          targetid = my_id);

      if (me->nCur_htfrec >= 0)
        strcpy (me->sCur_fieldid, szFld);
      else
        me->sCur_fieldid[0] = '\0';
      break;

    case FI_CANCEL:
      status =
      om$send (msg = message VDCmdDLO.save_form_pos
                            (&retmsg, me->My_actv_form, form_ptr),
          targetid = my_id);

      me->My_localret = gadget_label;
      _put_response( resp = EX_FORM_FINISHED );
      goto quit;

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

    default:
      break;
  }

  FIg_set_text (form_ptr, VD_RLOM_FLD_MSG, szmsg);

  status =
  om$send (msg = message VDCmdDLO.VDDLO_disp (form_ptr),
      targetid = my_id);

  quit:
  return (status);
}

end implementation VDCmdDLO;

