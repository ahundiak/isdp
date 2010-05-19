
/* $Id: VDDLU_disp.I,v 1.2 2001/01/26 22:51:58 ad Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDDLU_disp.I
 *
 * Description:
 *
 * General form display for drwing layout utilities commands
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDLU_disp.I,v $
 *      Revision 1.2  2001/01/26 22:51:58  ad
 *      *** empty log message ***
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/01/27  20:04:10  pinnacle
# Replaced: vdtbl/cmd/VDDLU_disp.I for:  by azuurhou for
#
# Revision 1.2  1997/10/21  04:32:52  pinnacle
# Replaced: vdtbl/cmd/VDDLU_disp.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.7  1996/04/03  23:15:44  pinnacle
# Replaced: vdtbl/cmd/VDDLU_disp.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/11/29  13:56:46  pinnacle
# Replaced: ./vdtbl/cmd/VDDLU_disp.I for:  by ksundar for vds.240
#
# Revision 1.5  1995/09/25  22:59:54  pinnacle
# Replaced: vdtbl/cmd/VDDLU_disp.I for:  by sundar for vds.240
#
# Revision 1.4  1995/09/05  23:14:04  pinnacle
# Replaced: vdtbl/cmd/VDDLU_disp.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/06  16:12:32  pinnacle
# Replaced: vdtbl/cmd/VDDLU_disp.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  20:01:58  pinnacle
# Replaced: vdtbl/cmd/VDDLU_disp.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/05/11  17:02:38  pinnacle
# Replaced: vdtbl/cmd/VDDLU_disp.I by hverstee r#
#
# Revision 1.1  1995/04/29  17:04:16  pinnacle
# Created: vdtbl/cmd/VDDLU_disp.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/20/95          HV            New
 *      10/20/97        Sundar          Modified for expression table
 *      01/19/01        ylong           ETL4898, not assigned TR# yet
 *
 * -------------------------------------------------------------------*/

class implementation VDCmdDLU;

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

// #define vdsDEBUG        1
#include "v_dbgmacros.h"


method   VDDLU_disp (char    * form_ptr)

{
  int          i, idsp, index;
  IGRchar     *pLoc;
  IGRchar     *pLtp;
  IGRshort     nLoc;
  IGRshort     nLtp;

  SetProc( VDCmdDLU.VDDLU_disp ); Begin
  if (me->My_Type == VD_DLU_CMD_POST)
  {
      pLoc = me->pNamLoc;
      nLoc = me->nNamLoc;
      pLtp = me->pTypLoc;
      nLtp = me->nTypLoc;
  }
  else
  switch (me->My_Delopt)
  {
    case VD_DLU_DST_NONE:
    default:
      FIg_set_text (form_ptr, VD_DLU_FLD_DELOPT , " ");
      pLoc = NULL;
      nLoc = 0;
      pLtp = NULL;
      nLtp = 0;
      break;

    case VD_DLU_DST_LOCAL:
      FIg_set_text (form_ptr, VD_DLU_FLD_DELOPT , VD_DLU_DO_FILE);
      pLoc = me->pNamLoc;
      nLoc = me->nNamLoc;
      pLtp = me->pTypLoc;
      nLtp = me->nTypLoc;
      break;

    case VD_DLU_DST_DB:
      FIg_set_text (form_ptr, VD_DLU_FLD_DELOPT , VD_DLU_DO_DB);
      pLoc = me->pNamDB;
      nLoc = me->nNamDB;
      pLtp = me->pTypDB;
      nLtp = me->nTypDB;
      break;

    case VD_DLU_DST_BOTH:
      FIg_set_text (form_ptr, VD_DLU_FLD_DELOPT , VD_DLU_DO_BOTH);
      pLoc = me->pNamBoth;
      nLoc = me->nNamBoth;
      pLtp = me->pTypBoth;
      nLtp = me->nTypBoth;
      break;
  }

  if ((me->My_ParTyp == VD_DLU_PAR_DLO) ||
      (me->My_ParTyp == VD_DLU_PAR_TYP) ||
      (me->My_ParTyp == VD_DLU_PAR_EXP) ||
      (me->My_ParTyp == VD_DLU_PAR_EXP_TYP))
  {
      FIg_display  (form_ptr, VD_DLU_FLD_TABTYP);
      FIg_display  (form_ptr, VD_DLU_TXT_TABTYP);
      FIg_set_text (form_ptr, VD_DLU_FLD_TABTYP, me->CUR_tabtyp);
  }
  else
  {
      FIg_erase    (form_ptr, VD_DLU_FLD_TABTYP);
      FIg_erase    (form_ptr, VD_DLU_TXT_TABTYP);
      pLtp = NULL;
      nLtp = 0;
  }

  /*    names and types lists     */

  FIfld_set_list_num_rows (form_ptr,VD_DLU_FLD_TABNAM, 0, nLoc);

  if (nLoc > 5)
    FIfld_set_list_scroll (form_ptr, VD_DLU_FLD_TABNAM, 1, 0);
  else
    FIfld_set_list_scroll (form_ptr, VD_DLU_FLD_TABNAM, 0, 0);

  for (i=0; i<nLoc; i++)
  {
    idsp = i * VD_DRWLO_CHR_IDFLD;
    VDfld_set_list_text (form_ptr, VD_DLU_FLD_TABNAM, i, 0,
                                       &pLoc[idsp], FALSE);
  }

  FIfld_set_list_num_rows (form_ptr,VD_DLU_FLD_TABTYP, 0, nLtp);

  if (nLtp > 5)
    FIfld_set_list_scroll (form_ptr, VD_DLU_FLD_TABTYP, 1, 0);
  else
    FIfld_set_list_scroll (form_ptr, VD_DLU_FLD_TABTYP, 0, 0);

  for (i=0; i<nLtp; i++)
  {
    idsp = i * VD_DRWLO_CHR_IDFLD;
    VDfld_set_list_text (form_ptr, VD_DLU_FLD_TABTYP, i, 0,
                                       &pLtp[idsp], FALSE);
  }

  FIg_set_text (form_ptr, VD_DLU_FLD_USERID,  me->CUR_userid);
  FIg_set_text (form_ptr, VD_DLU_FLD_DBOWNER, me->CUR_dbowner);

  /*    title info      */

  switch (me->My_ParTyp)
  {
    case VD_DLU_PAR_NONE:
      FIg_set_text (form_ptr, VD_DLU_FLD_PARAM , " ");
      FIg_set_text (form_ptr, VD_DLU_FLD_TABNAM, " ");
      FIg_set_text (form_ptr, VD_DLU_FLD_DESCR , " ");
      FIg_set_text (form_ptr, VD_DLU_FLD_TIMEST, " ");
      FIg_set_text (form_ptr, VD_DLU_FLD_LOCAL , " ");
      break;

    case VD_DLU_PAR_DLO:
    case VD_DLU_PAR_TYP:
      index =  me->My_ParTyp ;    /*   NOTE- ----  */
      FIg_set_text (form_ptr, VD_DLU_FLD_PARAM ,
                              &me->pPARNams[VD_DLU_PAR_LENGTH * index]);
      FIg_set_text (form_ptr, VD_DLU_FLD_TABNAM, me->CUR_tabnam);
      FIg_set_text (form_ptr, VD_DLU_FLD_DESCR , me->Ltbrec.Shdesc);
      FIg_set_text (form_ptr, VD_DLU_FLD_TIMEST, me->Ltbrec.Timest);

      if (me->Ltbrec.Local)
        FIg_set_text (form_ptr, VD_DLU_FLD_LOCAL, "X");
      else
        FIg_set_text (form_ptr, VD_DLU_FLD_LOCAL, " ");
      break;

    case VD_DLU_PAR_SRT:
    case VD_DLU_PAR_SUM:
    case VD_DLU_PAR_ADS:

      index =  me->My_ParTyp - 1 ;    /*   NOTE- ----  */


      FIg_set_text (form_ptr, VD_DLU_FLD_PARAM ,
                              &me->pPARNams[VD_DLU_PAR_LENGTH * index]);
      FIg_set_text (form_ptr, VD_DLU_FLD_TABNAM, me->SSid_tab.Tabnam);
      FIg_set_text (form_ptr, VD_DLU_FLD_DESCR , me->SSid_tab.Shdesc);
      FIg_set_text (form_ptr, VD_DLU_FLD_TIMEST, me->SSid_tab.Timest);

      if (me->SSid_tab.Local)
        FIg_set_text (form_ptr, VD_DLU_FLD_LOCAL, "X");
      else
        FIg_set_text (form_ptr, VD_DLU_FLD_LOCAL, " ");

      break;
	/* Begin added for expression table -- sundar */
    case VD_DLU_PAR_EXP:
    case VD_DLU_PAR_EXP_TYP:
 
      index =  5; /*me->My_ParTyp - 2;*/    /*   NOTE- ----  */
 
 
      FIg_set_text (form_ptr, VD_DLU_FLD_PARAM ,
                              &me->pPARNams[VD_DLU_PAR_LENGTH * index]);
      FIg_set_text (form_ptr, VD_DLU_FLD_TABNAM, me->Expid_tab.Tabnam);
      FIg_set_text (form_ptr, VD_DLU_FLD_DESCR , me->Expid_tab.Shdesc);
      FIg_set_text (form_ptr, VD_DLU_FLD_TIMEST, me->Expid_tab.Timest);
 
      if (me->Expid_tab.Local)
        FIg_set_text (form_ptr, VD_DLU_FLD_LOCAL, "X");
      else
        FIg_set_text (form_ptr, VD_DLU_FLD_LOCAL, " ");
      break;
	/* End added for expression table -- sundar */

  }

  End
  return (OM_S_SUCCESS);
}

end implementation VDCmdDLU;

