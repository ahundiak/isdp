
/* $Id: VDDLO_start.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDDLO_start.I
 *
 * Description:
 *
 * Implementation file for form startup messages
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDLO_start.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/12/02  08:29:20  pinnacle
# Replaced: vdtbl/cmd/VDDLO_start.I for:  by vgnair for vds
#
# Revision 1.2  1997/11/24  14:53:04  pinnacle
# Replaced: vdtbl/cmd/VDDLO_start.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.12  1995/11/29  13:56:36  pinnacle
# Replaced: ./vdtbl/cmd/VDDLO_start.I for:  by ksundar for vds.240
#
# Revision 1.11  1995/09/25  22:59:26  pinnacle
# Replaced: vdtbl/cmd/VDDLO_start.I for:  by sundar for vds.240
#
# Revision 1.10  1995/09/11  19:11:36  pinnacle
# Replaced: vdtbl/cmd/VDDLO_start.I for:  by hverstee for vds.240
#
# Revision 1.9  1995/09/08  19:37:38  pinnacle
# Replaced: vdtbl/cmd/VDDLO_start.I for:  by hverstee for vds.240
#
# Revision 1.8  1995/09/05  23:17:58  pinnacle
# Replaced: vdtbl/cmd/VDDLO_start.I for:  by hverstee for vds.240
#
# Revision 1.7  1995/08/15  23:53:48  pinnacle
# Replaced: vdtbl/cmd/VDDLO_start.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/08/14  22:45:04  pinnacle
# Replaced: vdtbl/cmd/VDDLO_start.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/08/11  23:35:38  pinnacle
# Replaced: vdtbl/cmd/VDDLO_start.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/03  21:10:38  pinnacle
# Replaced: vdtbl/cmd/VDDLO_start.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/06  16:06:54  pinnacle
# Replaced: vdtbl/cmd/VDDLO_start.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  20:01:26  pinnacle
# Replaced: vdtbl/cmd/VDDLO_start.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/05/11  17:04:38  pinnacle
# Replaced: vdtbl/cmd/VDDLO_start.I by hverstee r#
#
# Revision 1.1  1995/04/13  14:09:54  pinnacle
# Created: vdtbl/cmd/VDDLO_start.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/20/95          HV            New
 * 	12/02/97	  vini		Added cell
 *
 * -------------------------------------------------------------------*/

class implementation VDCmdDLO;

#include <stdio.h>
#include <string.h>

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grgsdef.h"
#include "grmessage.h"
#include "grgsmacros.h"
#include "OMmacros.h"
#include "exdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"
#include "asmacros.h"

#include "exmacros.h"

#include "msdef.h"
#include "msmacros.h"
#include "COBmacros.h"

#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"
#include "cotxmacros.h"

#include "FI.h"
%safe
#include "VX_FIproto.h"
%endsafe
#include "AS_status.h"

#include "VDdrwlo.h"
#include "VDdrwlo_db.h"
#include "VDdrwlo_int.h"

/*
#define MY_DEBUG
*/



method  VDDLO_EMSt ( long * sts )
{
  int         status;
  int         Selflag;
  int         i, idsp;
  char      * form_ptr;
  char        szFld[6];

  Selflag = FALSE;
  *sts    = MSSUCC;
  form_ptr = me->forms[me->My_actv_form].form_ptr;


  status =
  om$send (msg = message VDCmdDLO.set_form_pos
                            (sts, me->My_actv_form, form_ptr),
      targetid = my_id);

  FIf_display (form_ptr);

  if (me->nTabNams > 5)
  {
    FIfld_set_list_scroll (form_ptr, VD_DLOM_FLD_TABNAM, 1, 0);
    FIfld_set_list_scroll (form_ptr, VD_DLOM_FLD_COPY  , 1, 0);
  }
  else
  {
    FIfld_set_list_scroll (form_ptr, VD_DLOM_FLD_TABNAM, 0, 0);
    FIfld_set_list_scroll (form_ptr, VD_DLOM_FLD_COPY  , 0, 0);
  }

  for (i=0; i<me->nTabNams; i++)
  {
    idsp = i * VD_DRWLO_CHR_IDFLD;
    VDfld_set_list_text (form_ptr, VD_DLOM_FLD_TABNAM, i, 0,
                                   &me->pTabNams[idsp], Selflag);
    VDfld_set_list_text (form_ptr, VD_DLOM_FLD_COPY  , i, 0,
                                   &me->pTabNams[idsp], Selflag);
  }

  if (me->nTabTyps > 5)
    FIfld_set_list_scroll (form_ptr, VD_DLOM_FLD_TABTYP, 1, 0);
  else
    FIfld_set_list_scroll (form_ptr, VD_DLOM_FLD_TABTYP, 0, 0);

  for (i=0; i<me->nTabTyps; i++)
  {
    idsp = i * VD_DRWLO_CHR_IDFLD;
    VDfld_set_list_text (form_ptr, VD_DLOM_FLD_TABTYP, i, 0,
                                   &me->pTabTyps[idsp], Selflag);
  }

  if (me->nSorttb > 5)
    FIfld_set_list_scroll (form_ptr, VD_DLOM_FLD_SORT, 1, 0);
  else
    FIfld_set_list_scroll (form_ptr, VD_DLOM_FLD_SORT, 0, 0);

  for (i=0; i<me->nSorttb; i++)
  {
    idsp = i * VD_DRWLO_CHR_IDFLD;
    VDfld_set_list_text (form_ptr, VD_DLOM_FLD_SORT, i, 0,
                                   &me->pSorttb[idsp], Selflag);
  }

  if (me->nSummtb > 5)
    FIfld_set_list_scroll (form_ptr, VD_DLOM_FLD_SUMM, 1, 0);
  else
    FIfld_set_list_scroll (form_ptr, VD_DLOM_FLD_SUMM, 0, 0);

  for (i=0; i<me->nSummtb; i++)
  {
    idsp = i * VD_DRWLO_CHR_IDFLD;
    VDfld_set_list_text (form_ptr, VD_DLOM_FLD_SUMM, i, 0,
                                   &me->pSummtb[idsp], Selflag);
  }

  FIfld_set_list_scroll (form_ptr, VD_DLOM_FLD_GREDIT, 0, 0);

  for (i=0; i<5; i++)
  {
    idsp = i * VD_DRWLO_CHR_IDFLD;
    VDfld_set_list_text (form_ptr, VD_DLOM_FLD_GREDIT, i, 0,
                                   &me->pr_groups[idsp], Selflag);
  }

  FIfld_set_list_scroll (form_ptr, VD_DLOB_FLD_BLST, 1, 0);
  FIfld_set_list_scroll (form_ptr, VD_DLOB_FLD_BLSB, 1, 0);
  FIfld_set_list_scroll (form_ptr, VD_DLOB_FLD_BLSL, 1, 0);
  FIfld_set_list_scroll (form_ptr, VD_DLOB_FLD_BLSR, 1, 0);

  FIfld_set_list_scroll (form_ptr, VD_DLOB_FLD_BLWT, 1, 0);
  FIfld_set_list_scroll (form_ptr, VD_DLOB_FLD_BLWB, 1, 0);
  FIfld_set_list_scroll (form_ptr, VD_DLOB_FLD_BLWL, 1, 0);
  FIfld_set_list_scroll (form_ptr, VD_DLOB_FLD_BLWR, 1, 0);

  for (i=0; i<257; i++)
  {
    sprintf (szFld,"%4d",(i-1));

    VDfld_set_list_text (form_ptr, VD_DLOB_FLD_BLST, i, 0, szFld, Selflag);
    VDfld_set_list_text (form_ptr, VD_DLOB_FLD_BLSB, i, 0, szFld, Selflag);
    VDfld_set_list_text (form_ptr, VD_DLOB_FLD_BLSL, i, 0, szFld, Selflag);
    VDfld_set_list_text (form_ptr, VD_DLOB_FLD_BLSR, i, 0, szFld, Selflag);
  }

  for (i=0; i<32; i++)
  {
    sprintf (szFld,"%4d",i);

    VDfld_set_list_text (form_ptr, VD_DLOB_FLD_BLWT, i, 0, szFld, Selflag);
    VDfld_set_list_text (form_ptr, VD_DLOB_FLD_BLWB, i, 0, szFld, Selflag);
    VDfld_set_list_text (form_ptr, VD_DLOB_FLD_BLWL, i, 0, szFld, Selflag);
    VDfld_set_list_text (form_ptr, VD_DLOB_FLD_BLWR, i, 0, szFld, Selflag);
  }

  FIfld_set_max_num_chars (form_ptr, VD_DLOM_FLD_DESCR, 0,
                              VD_DRWLO_CHR_DESC);

  status =
  om$send (msg = message VDCmdDLO.VDDLO_disp (form_ptr),
      targetid = my_id);

  return (status);
}

method  VDDLO_RMSt ( long * sts )
{
  int         status;
  int         Selflag;
  int         i, idsp;
  char      * form_ptr;

  Selflag = FALSE;
  *sts    = MSSUCC;
  form_ptr = me->forms[me->My_actv_form].form_ptr;

  status =
  om$send (msg = message VDCmdDLO.set_form_pos
                            (sts, me->My_actv_form, form_ptr),
      targetid = my_id);

  FIf_display (form_ptr);

  if (me->nTabNams > 5)
    FIfld_set_list_scroll (form_ptr, VD_RLOM_FLD_TABNAM, 1, 0);
  else
    FIfld_set_list_scroll (form_ptr, VD_RLOM_FLD_TABNAM, 0, 0);

  for (i=0; i<me->nTabNams; i++)
  {
    idsp = i * VD_DRWLO_CHR_IDFLD;
    VDfld_set_list_text (form_ptr, VD_RLOM_FLD_TABNAM, i, 0,
                                   &me->pTabNams[idsp], Selflag);
  }

  if (me->nTabTyps > 5)
    FIfld_set_list_scroll (form_ptr, VD_RLOM_FLD_TABTYP, 1, 0);
  else
    FIfld_set_list_scroll (form_ptr, VD_RLOM_FLD_TABTYP, 0, 0);

  for (i=0; i<me->nTabTyps; i++)
  {
    idsp = i * VD_DRWLO_CHR_IDFLD;
    VDfld_set_list_text (form_ptr, VD_RLOM_FLD_TABTYP, i, 0,
                                   &me->pTabTyps[idsp], Selflag);
  }

  FIfld_set_list_scroll (form_ptr, VD_RLOM_FLD_GREDIT, 0, 0);

  for (i=0; i<5; i++)
  {
    idsp = i * VD_DRWLO_CHR_IDFLD;
    VDfld_set_list_text (form_ptr, VD_RLOM_FLD_GREDIT, i, 0,
                                   &me->pr_groups[idsp], Selflag);
  }

  status =
  om$send (msg = message VDCmdDLO.VDDLO_disp (form_ptr),
      targetid = my_id);

  return (status);
}

method  VDDLO_EFSt ( long * sts )
{
  int         status;
  int         i, idsp;
  int         Selflag;
  char      * form_ptr;
  char        szFld[8];

  Selflag = FALSE;
  *sts    = MSSUCC;
  form_ptr = me->forms[me->My_actv_form].form_ptr;

  status =
  om$send (msg = message VDCmdDLO.set_form_pos
                            (sts, me->My_actv_form, form_ptr),
      targetid = my_id);

  FIf_display (form_ptr);

  FIfld_set_list_scroll (form_ptr, VD_DLOF_FLD_FILL, 0, 0);

/* for the cell */
//  for (i=0; i<9; i++)
  for (i=0; i<10; i++)
  {
    idsp = i * VD_DRWLO_CHR_IDFLD;
    VDfld_set_list_text (form_ptr, VD_DLOF_FLD_FILL, i, 0,
                                   &me->pr_filltyp[idsp], Selflag);
  }

  FIfld_set_list_scroll (form_ptr, VD_DLOF_FLD_DTYPE, 0, 0);

  VDfld_set_list_text (form_ptr, VD_DLOF_FLD_DTYPE, 0, 0,
                                 &me->pr_dattyp[0], Selflag);
  VDfld_set_list_text (form_ptr, VD_DLOF_FLD_DTYPE, 1, 0,
                                 &me->pr_dattyp[VD_DRWLO_CHR_IDFLD], Selflag);

  FIfld_set_list_scroll (form_ptr, VD_DLOF_FLD_JUST, 0, 0);

  VDfld_set_list_text (form_ptr, VD_DLOF_FLD_JUST, 0, 0,
                                 &me->pr_justif[0], Selflag);
  VDfld_set_list_text (form_ptr, VD_DLOF_FLD_JUST, 1, 0,
                                 &me->pr_justif[VD_DRWLO_CHR_IDFLD], Selflag);
  VDfld_set_list_text (form_ptr, VD_DLOF_FLD_JUST, 2, 0,
                                 &me->pr_justif[VD_DRWLO_CHR_IDFLD*2], Selflag);

  FIfld_set_list_scroll (form_ptr, VD_DLOF_FLD_WEIGHT, 1, 0);

  for (i=0; i<32; i++)
  {
    sprintf (szFld,"%4d",i);

    VDfld_set_list_text (form_ptr, VD_DLOF_FLD_WEIGHT, i, 0, szFld, Selflag);
  }

#ifdef MY_DEBUG
  printf ("set list %d fonts\n",me->nFonts);
#endif

  if (me->nFonts > 5)
    FIfld_set_list_scroll (form_ptr, VD_DLOF_FLD_FONT, 1, 0);
  else
    FIfld_set_list_scroll (form_ptr, VD_DLOF_FLD_FONT, 0, 0);

  for (i=0; i<me->nFonts; i++)
  {
    idsp = i * FONT_NAME;
#ifdef MY_DEBUG
    printf ("set list %d fonts %s\n",i,&me->pr_fonts[idsp]);
#endif

    VDfld_set_list_text (form_ptr, VD_DLOF_FLD_FONT, i, 0,
                                &me->pr_fonts[idsp], Selflag);
  }

  FIfld_set_max_num_chars (form_ptr, VD_DLOF_FLD_TEXT, 0,
                              VD_DRWLO_CHR_TEXT);
  FIfld_set_max_num_chars (form_ptr, VD_DLOF_FLD_EXPATT, 0,
                              VD_DRWLO_CHR_DESC);
  FIfld_set_max_num_chars (form_ptr, VD_DLOF_FLD_FONT, 0,
                              VD_DRWLO_CHR_IDFLD);

  status =
  om$send (msg = message VDCmdDLO.VDDLO_disp (form_ptr),
      targetid = my_id);

  return (status);
}

method  VDDLO_RFSt ( long * sts )
{
  int         status;
  int         Selflag;
  char      * form_ptr;

  Selflag = FALSE;
  *sts    = MSSUCC;
  form_ptr = me->forms[me->My_actv_form].form_ptr;

  status =
  om$send (msg = message VDCmdDLO.set_form_pos
                            (sts, me->My_actv_form, form_ptr),
      targetid = my_id);

  FIf_display (form_ptr);

  /*   no lists, maybe something else   */

  status =
  om$send (msg = message VDCmdDLO.VDDLO_disp (form_ptr),
      targetid = my_id);

  return (status);
}

end implementation VDCmdDLO;
