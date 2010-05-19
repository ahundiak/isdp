
/* $Id: VDDLO_cmdi.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDDLO_cmdi.I
 *
 * Description:
 *
 * Implementation file for VDDLO command object initialization/reset
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDLO_cmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/04/16  14:54:32  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cmdi.I for:  by mdong for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1997/12/11  15:14:46  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cmdi.I for:  by mdong for vds
#
# Revision 1.3  1997/12/02  08:23:00  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cmdi.I for:  by vgnair for vds
#
# Revision 1.2  1997/11/24  14:51:48  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cmdi.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.10  1995/11/10  21:22:54  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.9  1995/09/20  22:03:42  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.8  1995/09/08  19:37:14  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/09/05  23:14:26  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/08/14  22:42:38  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/11  23:35:16  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/06  16:02:16  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  20:00:36  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/05/18  14:12:24  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cmdi.I by hverstee r#
#
# Revision 1.4  1995/05/15  16:20:20  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cmdi.I by hverstee r#
#
# Revision 1.3  1995/05/11  16:59:00  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cmdi.I by hverstee r#
#
# Revision 1.2  1995/05/08  20:35:54  pinnacle
# Replaced: vdtbl/cmd/VDDLO_cmdi.I by hverstee r#
#
# Revision 1.1  1995/04/13  14:02:14  pinnacle
# Created: vdtbl/cmd/VDDLO_cmdi.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/20/95          HV            New
 *	12/02/97	  vini		Added Cells
 *
 * -------------------------------------------------------------------*/

class implementation VDCmdDLO;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "FI.h"
#include "ASmatrix.h"

#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"
#include "grdpbmacros.h"

#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"
#include "cotxmacros.h"

#include "VDdrwlo_pr.h"
#include "VDmem.h"
#include "vdtblmacros.h"
#include "v_dbgmacros.h"
#include "VDCmdSSC.h"

%safe
  static int x1_pos = -1,y1_pos = -1;
  static int x2_pos = -1,y2_pos = -1;
  static int x3_pos = -1,y3_pos = -1;
  static int x4_pos = -1,y4_pos = -1;
%endsafe

/*
#define  MY_DEBUG
#define  MY_TRACE_ON
*/

from VDcrexp            import VDcrexp_gdata;
from VDcrexp            import VDcrexp_gtab;


method save_form_pos ( long * sts;
                       int    form_label;
                       char * form_ptr )
{

  *sts = MSSUCC;
  switch (form_label)
  {
    default:
    case VD_DLO_MAINFORM:
      FIf_get_location(form_ptr,&x1_pos,&y1_pos);
      break;

    case VD_DLO_FILLFORM:
      FIf_get_location(form_ptr,&x2_pos,&y2_pos);
      break;

    case VD_RLO_MAINFORM:
      FIf_get_location(form_ptr,&x3_pos,&y3_pos);
      break;

    case VD_RLO_FILLFORM:
      FIf_get_location(form_ptr,&x4_pos,&y4_pos);
      break;
  }

  return OM_S_SUCCESS;
}

method set_form_pos ( long * sts;
                      int    form_label;
                      char * form_ptr )
{
  *sts = MSSUCC;
  switch (form_label)
  {
    default:
    case VD_DLO_MAINFORM:
      if(x1_pos != -1 && y1_pos != -1)
        FIf_set_location(form_ptr,x1_pos,y1_pos);
      break;

    case VD_DLO_FILLFORM:
      if(x2_pos != -1 && y2_pos != -1)
        FIf_set_location(form_ptr,x2_pos,y2_pos);
      break;

    case VD_RLO_MAINFORM:
      if(x3_pos != -1 && y3_pos != -1)
        FIf_set_location(form_ptr,x3_pos,y3_pos);
      break;

    case VD_RLO_FILLFORM:
      if(x4_pos != -1 && y4_pos != -1)
        FIf_set_location(form_ptr,x4_pos,y4_pos);
      break;
  }

  return OM_S_SUCCESS;
}

method   VDDLO_init   (IGRlong    *msg)
{
  IGRint       status;
  IGRlong      retmsg;
  IGRint       i, idsp;

  me->ppFile       = NULL;

  me->nSorttb      = 0;
  me->nSummtb      = 0;
  me->pSorttb      = NULL;
  me->pSummtb      = NULL;

  me->pTabNams     = NULL;
  me->pTabLims     = NULL;
  me->pTabTyps     = NULL;
  me->nTabNams     = 0;
  me->nTabLims     = 0;
  me->nTabTyps     = 0;

  me->pFldTab      = NULL;
  me->nFldTab      = 0;
  me->nFldAlloc    = 0;

  me->pFtotTab     = NULL;
  me->nFtotTab     = 0;
  me->nFtotAlloc   = 0;

  me->nAlg_hdtr    = VD_DRWLO_EN_ALL;
  me->nAlg_alloc   = 0;
  me->nAlg_lines   = 0;
  me->nAlg_curact  = 0;
  me->pCur_alg     = NULL;

  me->WinGRid.objid = NULL_OBJID;
  me->OwnGRid.objid = NULL_OBJID;
  me->Gragad.objid  = NULL_OBJID;

  me->bCP_lo        = FALSE;
  me->bCP_fld       = FALSE;

#ifdef MY_TRACE_ON
  me->ppFile        = (FILE *) fopen ("VDdrwlo_tr.log", "w");
  if (me->ppFile == NULL)  me->ppFile = stdout;
#endif

  /*     fill standard lists    */

#ifdef MY_DEBUG
  printf (" start init VDDLO\n");
#endif

  me->pr_groups  = _MALLOC (5 * VD_DRWLO_CHR_IDFLD, IGRchar);
  if (me->pr_groups == NULL) goto quit;

  strcpy (me->pr_groups,"Column data");
  strcpy (&me->pr_groups[VD_DRWLO_CHR_IDFLD],"Header");
  strcpy (&me->pr_groups[VD_DRWLO_CHR_IDFLD*2],"Trailer");
  strcpy (&me->pr_groups[VD_DRWLO_CHR_IDFLD*3],"Breakheader");
  strcpy (&me->pr_groups[VD_DRWLO_CHR_IDFLD*4],"Breaktrailer");

  me->pr_dattyp  = _MALLOC (2 * VD_DRWLO_CHR_IDFLD, IGRchar);
  if (me->pr_dattyp == NULL) goto quit;

  strcpy (me->pr_dattyp, "ASCII");
  strcpy (&me->pr_dattyp[VD_DRWLO_CHR_IDFLD], "Numeric");

//  me->pr_filltyp = _MALLOC (9 * VD_DRWLO_CHR_IDFLD, IGRchar);
  me->pr_filltyp = _MALLOC (10 * VD_DRWLO_CHR_IDFLD, IGRchar);
  if (me->pr_filltyp == NULL) goto quit;

  strcpy (me->pr_filltyp,"Text");
  strcpy (&me->pr_filltyp[VD_DRWLO_CHR_IDFLD],"Attribute");
  strcpy (&me->pr_filltyp[VD_DRWLO_CHR_IDFLD*2],"Expression");
  strcpy (&me->pr_filltyp[VD_DRWLO_CHR_IDFLD*3],"Userdefined");
  strcpy (&me->pr_filltyp[VD_DRWLO_CHR_IDFLD*4],"Overflow");
  strcpy (&me->pr_filltyp[VD_DRWLO_CHR_IDFLD*5],"FormText");
  strcpy (&me->pr_filltyp[VD_DRWLO_CHR_IDFLD*6],"Itemnumber");
  strcpy (&me->pr_filltyp[VD_DRWLO_CHR_IDFLD*7],"Quantity");
  strcpy (&me->pr_filltyp[VD_DRWLO_CHR_IDFLD*8],"Expr. Table");
  strcpy (&me->pr_filltyp[VD_DRWLO_CHR_IDFLD*9],"Cell");

  me->pr_justif  = _MALLOC (3 * VD_DRWLO_CHR_IDFLD, IGRchar);
  if (me->pr_justif == NULL) goto quit;

  strcpy (me->pr_justif,"Left");
  strcpy (&me->pr_justif[VD_DRWLO_CHR_IDFLD],"Center");
  strcpy (&me->pr_justif[VD_DRWLO_CHR_IDFLD*2],"Right");

  /*    fonts list                */

  VD_get_fontlist (&retmsg, &me->nFonts, NULL);

  me->pr_fonts = _MALLOC ((me->nFonts + 1) * FONT_NAME, IGRchar);
  if (me->pr_fonts == NULL) goto quit;


#ifdef MY_DEBUG
  printf (" to fontlist %d lines, addr %d\n",me->nFonts, (int)me->pr_fonts);
#endif

  VD_get_fontlist (&retmsg, &me->nFonts, me->pr_fonts);

#ifdef MY_DEBUG
  printf (" -- fontlist %s \n",me->pr_fonts);
#endif

  /*    sort/summarization indices    */

  vd$tblstc_idx ( msg     = &retmsg,
                  osnum   = me->My_OS,
                  p_count = &me->nSorttb);
  (me->nSorttb)++;

  vd$tblsuc_idx ( msg     = &retmsg,
                  osnum   = me->My_OS,
                  p_count = &me->nSummtb);
  (me->nSummtb)++;

  me->pSorttb = _MALLOC (me->nSorttb * VD_DRWLO_CHR_IDFLD, IGRchar);
  me->pSummtb = _MALLOC (me->nSummtb * VD_DRWLO_CHR_IDFLD, IGRchar);
  if ((me->pSorttb == NULL) || (me->pSummtb == NULL)) goto quit;

  strcpy (me->pSorttb, VD_DLO_DSP_EMPTY);
  strcpy (me->pSummtb, VD_DLO_DSP_EMPTY);

  if (me->nSorttb > 1)
  {
    IGRshort nDD;

    vd$tblstc_idx ( msg     = &retmsg,
                    osnum   = me->My_OS,
                    p_nams  = &(me->pSorttb[VD_DRWLO_CHR_IDFLD]),
                    p_count = &nDD);
  }

  if (me->nSummtb > 1)
  {
    IGRshort nDD;

    vd$tblsuc_idx ( msg     = &retmsg,
                    osnum   = me->My_OS,
                    p_nams  = &(me->pSummtb[VD_DRWLO_CHR_IDFLD]),
                    p_count = &nDD);
  }


  /*    default column record     */

  me->ColCUR.col_lns            = 1;

  me->ColCUR.col_db.col_seqno   = 0;
  me->ColCUR.col_db.col_chars   = 10;
  me->ColCUR.col_db.col_wdt     = 5.0;
  me->ColCUR.col_db.col_hgt     = 0.3;
  me->ColCUR.col_db.col_charwdt = 0.1;
  me->ColCUR.col_db.col_charspc = 1.0;
  me->ColCUR.col_db.col_charhgt = 0.1;
  me->ColCUR.col_db.col_linspc  = 1.0;

  me->ColCUR.col_db.ltop_style = -1;
  me->ColCUR.col_db.lbot_style = 0;
  me->ColCUR.col_db.llft_style = 0;
  me->ColCUR.col_db.lrgt_style = 0;

  me->ColCUR.col_db.ltop_wgt = 0;
  me->ColCUR.col_db.lbot_wgt = 0;
  me->ColCUR.col_db.llft_wgt = 0;
  me->ColCUR.col_db.lrgt_wgt = 0;

  me->ColCUR.col_db.tl_br = FALSE;
  me->ColCUR.col_db.bl_tr = FALSE;

  /*   default HTF record   */

  me->HtfCUR.htf_lns            = 1;

  me->HtfCUR.htf_db.hdtr_type   = VD_DRWLO_EN_ALL;
  me->HtfCUR.htf_db.fieldid[0]  = '\0';
  me->HtfCUR.htf_db.fld_chars   = 10;
  me->HtfCUR.htf_db.fld_charwdt = 0.1;
  me->HtfCUR.htf_db.fld_charspc = 1.0;
  me->HtfCUR.htf_db.fld_charhgt = 0.1;
  me->HtfCUR.htf_db.fld_linspc  = 1.0;

  me->HtfCUR.htf_db.align_lcol  = 1;
  me->HtfCUR.htf_db.align_rcol  = 1;
  me->HtfCUR.htf_db.align_top   = 1;
  me->HtfCUR.htf_db.align_bot   = 1;

  me->HtfCUR.htf_db.ltop_style = 0;
  me->HtfCUR.htf_db.lbot_style = 0;
  me->HtfCUR.htf_db.llft_style = 0;
  me->HtfCUR.htf_db.lrgt_style = 0;

  me->HtfCUR.htf_db.ltop_wgt = 0;
  me->HtfCUR.htf_db.lbot_wgt = 0;
  me->HtfCUR.htf_db.llft_wgt = 0;
  me->HtfCUR.htf_db.lrgt_wgt = 0;

  me->HtfCUR.htf_db.tl_br    = FALSE;
  me->HtfCUR.htf_db.bl_tr    = FALSE;

  /*      default field record     */

  me->FldCUR.hdtr_type       = VD_DRWLO_EN_ALL;
  me->FldCUR.lin_seqno       = 0;
  me->FldCUR.col_seqno       = 0;
  me->FldCUR.fieldid[0]      = '\0';

  me->FldCUR.fieldtype       = 0;
  me->FldCUR.datatype        = 0;
  me->FldCUR.f_decimal       = 0;
  me->FldCUR.justification   = 0;
  me->FldCUR.id_weight       = 0;

  me->FldCUR.id_name[0]      = '\0';
  me->FldCUR.id_Font[0]      = '\0';
  me->FldCUR.Ftext[0]        = '\0';

  
  for (i=0; i<me->nFonts; i++)
  {
    idsp = i * FONT_NAME;

    if (strncmp (&me->pr_fonts[idsp], "Fixed", 5) == 0)
      strcpy (me->FldCUR.id_Font, &me->pr_fonts[idsp]);
  }

  if (me->FldCUR.id_Font[0] == '\0')
  {
    if (me->nFonts == 0)
      strcpy (me->FldCUR.id_Font, "default");
    else
      strcpy (me->FldCUR.id_Font, me->pr_fonts);
  }

  /* let Reset allocate room for types and names lists  */

  status =
  om$send (msg = message VDCmdDLO.VDDLO_Reset (msg),
      targetid = my_id);

  quit:
  if (*msg != MSSUCC)
  {
    UI_status (VD_DLO_EMSG_MEM);
    _put_response( resp = TERMINATE);
  }

  return (OM_S_SUCCESS);
}



method  VDDLO_Cleanfill ( long * sts )
{
  *sts = MSSUCC;

  FIf_erase (me->forms[me->My_actv_form].form_ptr);

  if (me->My_actv_form == VD_DLO_FILLFORM)
  {
    me->My_actv_form   = VD_DLO_MAINFORM;

    FIg_enable (me->forms[VD_DLO_MAINFORM].form_ptr, FI_CANCEL);
    FIg_enable (me->forms[VD_DLO_MAINFORM].form_ptr, FI_RESET);
    FIg_enable (me->forms[VD_DLO_MAINFORM].form_ptr, FI_ACCEPT);
    FIg_enable (me->forms[VD_DLO_MAINFORM].form_ptr, FI_EXECUTE);
  }
  else
  {
    me->My_actv_form = VD_RLO_MAINFORM;
    FIg_enable (me->forms[VD_RLO_MAINFORM].form_ptr, FI_CANCEL);
  }

  return (OM_S_SUCCESS);
}

method  VDDLO_Cleanup ( long * sts )
{
  IGRint       status;
  IGRlong      retmsg;

  *sts = MSSUCC;

  if (me->My_Preview_up)
  {
    IGRboolean   bGRonly;

    bGRonly = FALSE;

    status =
    om$send (msg = message VDCmdDLO.VDDLO_pvdel (&retmsg, bGRonly),
        targetid = my_id);
  }

  FIf_erase (me->forms[me->My_actv_form].form_ptr);

  _FREE (me->pTabNams);
  _FREE (me->pTabLims);
  _FREE (me->pTabTyps);
  _FREE (me->pFldTab);
  _FREE (me->pFtotTab);
  _FREE (me->pCur_alg);

  me->WinGRid.objid = NULL_OBJID;
  me->OwnGRid.objid = NULL_OBJID;
  me->Gragad.objid  = NULL_OBJID;

  me->nFldTab      = 0;
  me->nFldAlloc    = 0;
  me->nFtotTab     = 0;
  me->nFtotAlloc   = 0;
  me->nAlg_alloc   = 0;
  me->nAlg_lines   = 0;

  _FREE (me->pSorttb);
  _FREE (me->pSummtb);

  me->nSorttb      = 0;
  me->nSummtb      = 0;

  _FREE (me->pr_groups);
  _FREE (me->pr_dattyp);
  _FREE (me->pr_filltyp);
  _FREE (me->pr_justif);
  _FREE (me->pr_fonts);

  VDtbl_dlo_close (sts);
  VDtbl_suc_close (sts);
  VDtbl_stc_close (sts);

  if ((me->ppFile != NULL) && (me->ppFile != stdout))
    fclose (me->ppFile);

  status =
  om$send (msg = message CEO_LOCATE.delete (0),
          mode = OM_e_wrt_message,
      targetid = my_id);

  return (OM_S_SUCCESS);
}


method  VDDLO_Report ( long * sts )
{
  IGRshort    i;
  IGRshort    ncount;

  *sts = OM_S_SUCCESS;

  ncount = om$dimension_of( varray = me->Lalgrec);

  printf ("\nAlignment table\n");

  for (i=0; i<ncount; i++)
    printf ("ALGREC %d - %d %d %f\n",i,me->Lalgrec[i].hdtr_type,
                                       me->Lalgrec[i].aligncode,
                                       me->Lalgrec[i].value);

  ncount = om$dimension_of( varray = me->Lcolrec);

  printf ("\nColumns table\n");

  for (i=0; i<ncount; i++)
    printf ("COLREC %d - <%d> %d lines\n",i,me->Lcolrec[i].col_db.col_seqno,
                                  me->Lcolrec[i].col_lns);

  ncount = om$dimension_of( varray = me->Lhtfrec);

  printf ("\nHTF table\n");

  for (i=0; i<ncount; i++)
  {
    me->Lhtfrec[i].htf_db.fieldid[VD_DRWLO_CHR_IDFLD-1] = '\0';
    printf ("HTFREC %d - <%d %s> %d lines\n",i,me->Lhtfrec[i].htf_db.hdtr_type,
                                       me->Lhtfrec[i].htf_db.fieldid,
                                       me->Lhtfrec[i].htf_lns);
  }

  ncount = om$dimension_of( varray = me->Lfldrec);

  printf ("\nField table\n");

  for (i=0; i<ncount; i++)
  {
    me->Lfldrec[i].fieldid[VD_DRWLO_CHR_IDFLD-1] = '\0';
    me->Lfldrec[i].id_name[VD_DRWLO_CHR_IDFLD-1] = '\0';

    printf ("FLDREC %d - <%d %d %s> line %d %s\n",i,me->Lfldrec[i].hdtr_type,
                                       me->Lfldrec[i].col_seqno,
                                       me->Lfldrec[i].fieldid,
                                       me->Lfldrec[i].lin_seqno,
                                        me->Lfldrec[i].id_name);
  }

  return (OM_S_SUCCESS);
}



method  VDDLO_Reset ( long * sts )
{
  IGRint      status;
  IGRlong     retmsg;

  *sts = MSFAIL;

  me->My_localret   = 0;

  me->CUR_tabnam[0] = me->Ltbrec.Tabnam[0] = '\0';
  me->CUR_tabtyp[0] = me->Ltbrec.Tabtyp[0] = '\0';

  me->Ltbrec.SumFil[0]  = '\0';
  me->Ltbrec.SortFil[0] = '\0';
  me->Ltbrec.Shdesc[0]  = '\0';

  me->Ltbrec.direct = VD_DRWLO_EN_DESCEND;
  me->Ltbrec.Local  = TRUE;

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_init (&retmsg, &me->Ltbrec),
      targetid = my_id);
  as$status();

  me->My_stored_lo.objid = NULL_OBJID;

  me->nCur_group    = VD_DRWLO_EN_ALL;
  me->nCur_colnum   = 0;
  me->nCur_linenum  = 0;

  me->sCur_fieldid[0] = '\0';

  if (me->My_Preview_up)
  {
    IGRboolean   bGRonly;

    bGRonly = FALSE;

    status =
    om$send (msg = message VDCmdDLO.VDDLO_pvdel (&retmsg, bGRonly),
        targetid = my_id);
  }

  VDtbl_dlo_close (sts);

  /*    free up lists ... */

  _FREE (me->pTabNams);
  _FREE (me->pTabLims);
  _FREE (me->pTabTyps);
  _FREE (me->pFldTab);
  _FREE (me->pFtotTab);
  _FREE (me->pCur_alg);

  me->WinGRid.objid = NULL_OBJID;
  me->OwnGRid.objid = NULL_OBJID;
  me->Gragad.objid  = NULL_OBJID;

  me->nFldTab      = 0;
  me->nFldAlloc    = 0;
  me->nFtotTab     = 0;
  me->nFtotAlloc   = 0;
  me->nAlg_alloc   = 0;
  me->nAlg_lines   = 0;

  /* allocate room for types and names lists  */

  vd$tbldlo_idt ( msg     = &retmsg,
                  osnum   = me->My_OS,
                  p_count = &me->nTabTyps);

  vd$tbldlo_idx ( msg     = &retmsg,
                  osnum   = me->My_OS,
                  p_count = &me->nTabNams);

  /*  add 1 for malloc of empty lists...  */

  me->pTabTyps = _MALLOC ((me->nTabTyps + 1) * VD_DRWLO_CHR_IDFLD, IGRchar);
  me->pTabNams = _MALLOC ((me->nTabNams + 1) * VD_DRWLO_CHR_IDFLD, IGRchar);
  me->pTabLims = _MALLOC ((me->nTabNams + 1) * VD_DRWLO_CHR_IDFLD, IGRchar);

  if ((me->pTabTyps != NULL) &&
      (me->pTabNams != NULL) &&
      (me->pTabLims != NULL))
  { /*  get the complete lists  */
    vd$tbldlo_idt ( msg     = &retmsg,
                    osnum   = me->My_OS,
                    p_typs  = me->pTabTyps,
                    p_count = &me->nTabTyps);

    vd$tbldlo_idx ( msg     = &retmsg,
                    osnum   = me->My_OS,
                    p_nams  = me->pTabNams,
                    p_count = &me->nTabNams);
#ifdef MY_DEBUG
    printf (" dirlists %d %d\n",me->nTabNams, me->nTabTyps);
#endif

    *sts = MSSUCC;
  }

  return (OM_S_SUCCESS);
}


method  VDDLO_Save ( long * sts )
{
  IGRint       status;
  IGRshort     nCount;
  IGRlong      retmsg;
  IGRshort     i;

  struct VDdrwlo_db_col    *pCol;
  struct VDdrwlo_db_htf    *pHtf;

  *sts = MSFAIL;

  if (me->My_stored_lo.objid == NULL_OBJID)
  {
    vd$tbldlo_new (msg    = &retmsg,
                   osnum  = me->My_OS,
                   tabnam = me->CUR_tabnam,
                   tabtyp = me->CUR_tabtyp,
                   GRid   = &me->My_stored_lo);
  }

#ifdef MY_DEBUG
  printf ("save %s %s, objid <%d %d>\n",me->CUR_tabnam, me->CUR_tabtyp,
                       me->My_stored_lo.objid, me->My_stored_lo.osnum);
#endif

  if (me->My_stored_lo.objid == NULL_OBJID) goto quit;

  /*    (re) initialize table header     */

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_init (&retmsg, &me->Ltbrec),
      targetid = me->My_stored_lo.objid,
      targetos = me->My_stored_lo.osnum);
  as$status();

  /*    isolate and store alignment records   */

  nCount = om$dimension_of (varray = me->Lalgrec);

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_salign (&retmsg, nCount, me->Lalgrec),
      targetid = me->My_stored_lo.objid,
      targetos = me->My_stored_lo.osnum);
  as$status();

  /*    isolate and store column records   */

  nCount = om$dimension_of (varray = me->Lcolrec);

  if (nCount > 0)
  {
    pCol = _MALLOC (nCount, struct VDdrwlo_db_col);
    if (pCol == NULL) goto quit;

    for (i=0; i<nCount; i++)
      VD_drwlo_mcol (&(pCol[i]), &(me->Lcolrec[i].col_db));

    status =
    om$send (msg = message VDdrwlo.VDdrwlo_scol (&retmsg, nCount, pCol),
        targetid = me->My_stored_lo.objid,
        targetos = me->My_stored_lo.osnum);
    as$status();

    _FREE (pCol);
  }

  /*    isolate and store htf records   */

  nCount = om$dimension_of (varray = me->Lhtfrec);

  if (nCount > 0)
  {
    pHtf = _MALLOC (nCount, struct VDdrwlo_db_htf);
    if (pHtf == NULL) goto quit;

    for (i=0; i<nCount; i++)
      VD_drwlo_mhtf (&(pHtf[i]), &(me->Lhtfrec[i].htf_db));

    status =
    om$send (msg = message VDdrwlo.VDdrwlo_shtf (&retmsg, nCount, pHtf),
        targetid = me->My_stored_lo.objid,
        targetos = me->My_stored_lo.osnum);
    as$status();

    _FREE (pHtf);
  }

  /*    isolate and store field records   */

  nCount = om$dimension_of (varray = me->Lfldrec);

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_sfld (&retmsg, nCount, me->Lfldrec),
      targetid = me->My_stored_lo.objid,
      targetos = me->My_stored_lo.osnum);
  as$status();

  /*    check and recalculate resulting object   */

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_set (&retmsg, VD_DRWLO_EN_ALL, NULL),
      targetid = me->My_stored_lo.objid,
      targetos = me->My_stored_lo.osnum);
  as$status();

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_check
                             (&retmsg, &nCount, me->ppFile, NULL),
      targetid = me->My_stored_lo.objid,
      targetos = me->My_stored_lo.osnum);
  as$status();

  *sts = MSSUCC;

  quit:
  return (OM_S_SUCCESS);
}

method  VDDLO_exptyp( IGRlong *msg;
		      char    *form_ptr )
/*
**  The method to retrieve all expression types and display them
*/
{
  IGRint	status;
  IGRshort	nExprTyps;
  IGRchar	*pExprTyps;
  int		i, idsp;
  int           Selflag;


  SetProc( VDCmdDLO.VDDLO_exptyp ); Begin 

  *msg 		= MSSUCC;
  Selflag       = FALSE;
  pExprTyps     = NULL;
  nExprTyps     = 0;

  vd$tblexp_idt( msg     = msg,
                 osnum   = me->My_OS,
                 p_count = &nExprTyps );

  if( nExprTyps != 0 )
  {
    pExprTyps = _MALLOC( (nExprTyps + 1) * VD_CREXP_CHR_TYPE, IGRchar );
    if( pExprTyps == NULL )
    {
      UI_status( VD_SSC_EMSG_MEM );
      _put_response( resp = TERMINATE );
      goto quit;
    }

    vd$tblexp_idt( msg     = msg,
                   osnum   = me->My_OS,
                   p_count = &nExprTyps,
                   p_typs  = pExprTyps );

    FIfld_set_list_num_rows( form_ptr,
                             VD_DLOF_FLD_EXTYP,
                             0,
                             (int)nExprTyps );
    if( nExprTyps > 5 )
    {
      FIfld_set_list_scroll( form_ptr,
                             VD_DLOF_FLD_EXTYP,
                             1,
                             0 );
    }
    else
    {
      FIfld_set_list_scroll( form_ptr,
                             VD_DLOF_FLD_EXTYP,
                             0,
                             0 );
    }
    for( i = 0 ; i < nExprTyps ; i++ )
    {
      idsp = i * VD_CREXP_CHR_TYPE;
      VDfld_set_list_text( form_ptr,
                           VD_DLOF_FLD_EXTYP,
                           i,
                           0,
                           &pExprTyps[idsp],
                           Selflag );
    }
  }


  quit:
  _FREE( pExprTyps );
  End
  return( OM_S_SUCCESS );
}

method  VDDLO_expnam( IGRlong *msg;
                      char    *form_ptr;
		      IGRchar *exptyp )
/*
**  The method to retrieve all expression names for given expression 
**  type and display them
*/
{
  IGRint        status;
  int           Selflag;
  int           i, idsp;
  IGRchar	*pExprNams;
  IGRshort	nExprNams;


  SetProc( VDCmdDLO.VDDLO_expnam ); Begin

  Selflag       = FALSE;
  *msg          = MSSUCC;
  pExprNams     = NULL;
  nExprNams     = 0;

/*
**      Search for all expression names for a special type
*/
  vd$tblexp_idnd( msg     = msg,
                  osnum   = me->My_OS,
                  p_type  = exptyp,
                  p_count = &nExprNams );

  if( nExprNams == 0 )
  {
    *msg = MSFAIL;
    goto quit;
  }

  pExprNams = _MALLOC( (nExprNams + 1) * VD_CREXP_CHR_NAME, IGRchar );
  if( pExprNams == NULL )
  {
    UI_status( VD_SSC_EMSG_MEM );
    _put_response( resp = TERMINATE );
    goto quit;
  }

  vd$tblexp_idnd( msg     = msg,
                  osnum   = me->My_OS,
                  p_type  = exptyp,
                  p_count = &nExprNams,
                  p_nams  = pExprNams );

  FIfld_set_list_num_rows( form_ptr,
                           VD_DLOF_FLD_EXNAM,
                           0,
                           (int)nExprNams );

  if( nExprNams > 5 )
  {
    FIfld_set_list_scroll( form_ptr, VD_DLOF_FLD_EXNAM, 1, 0 );
  }
  else
  {
    FIfld_set_list_scroll( form_ptr, VD_DLOF_FLD_EXNAM, 0, 0 );
  }

  for( i=0 ; i < nExprNams ; i++ )
  {
    idsp = i * VD_CREXP_CHR_NAME;
    VDfld_set_list_text( form_ptr,
                         VD_DLOF_FLD_EXNAM,
                         i,
                         0,
                         &pExprNams[idsp],
                         Selflag );
  }

  quit:
  _FREE( pExprNams );
  End
  return( OM_S_SUCCESS );
}

method  VDDLO_expload( IGRlong        *msg;
                       char           *form_ptr;
                       struct GRid    *lGrid )
/*
**  The method to retrieve all expression data
*/
{
  IGRint                status;
  IGRint                i, j, NbExpDat;
  struct VDdrwexp_tab   SSID_exp;
  struct VDdrwexp_data  *expdata;
  IGRint		nExprData;
  IGRchar               *expinfo;


  SetProc( VDCmdDLO.VDDLO_expload ); Begin

  NbExpDat  = 0;
  nExprData = 0;
  expinfo   = NULL;
  expdata   = NULL;

  status =
  om$send( msg      = message VDcrexp.VDcrexp_gtab(msg,
                                                   &SSID_exp,
                                                   &NbExpDat,
                                                   NULL),
           targetid = lGrid->objid,
           targetos = lGrid->osnum );

  if( me->nCur_fldrec >= 0 )
  {
    if( SSID_exp.data_type == VD_DRWEXP_EN_ASCII )
    {
      me->Lfldrec[me->nCur_fldrec].datatype = VD_DRWLO_EN_ASCII;
    }
    else
    {
      me->Lfldrec[me->nCur_fldrec].datatype = VD_DRWLO_EN_NUMERIC;
    }

    status =
    om$send( msg = message VDcrexp.VDcrexp_gdata(msg,
                                                 &nExprData,
                                                 &expdata),
             targetid = lGrid->objid,
             targetos = lGrid->osnum );

  /*
  ** Display data in the command form
  */
    expinfo = _MALLOC( nExprData * VD_CREXP_CHR_INFO, IGRchar );
    expinfo[0] = '\0';

    for( i = 0 ; i < nExprData ; i++ )
    {
      for( j = 0 ; j < nExprData ; j++ )
      {
        if( expdata[j].Datsegn == i )
        {
          strcat( expinfo, expdata[j].Datinfo );
          break;
        }
      }
    }

    switch( me->My_actv_form )
    {
      case VD_DLO_FILLFORM:
      default:

        FIg_set_text( form_ptr, VD_DLOF_FLD_EXTYP, SSID_exp.Tabtyp );
        FIg_set_text( form_ptr, VD_DLOF_FLD_EXPRESS, expinfo );
     
        break;
 
     case VD_RLO_FILLFORM:

        FIg_set_text( form_ptr, VD_RLOF_FLD_EXTYP, SSID_exp.Tabtyp );
        FIg_set_text( form_ptr, VD_RLOF_FLD_TEXT, expinfo );
      
        break;
    }
  }

  _FREE( expdata );
  _FREE( expinfo );
  End
  return( OM_S_SUCCESS );
}
end implementation VDCmdDLO;

