
/* $Id: VDAttrFun.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDAttrFun.I
 *
 * Description:
 *
 * Function to retrieve attributes including codelist aliases
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDAttrFun.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
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
# Revision 1.10  1996/05/31  22:36:34  pinnacle
# Replaced: vdtbl/mgr/VDAttrFun.I for:  by tlbriggs for vds.240
#
# Revision 1.9  1996/04/03  20:41:28  pinnacle
# Replaced: vdtbl/mgr/VDAttrFun.I for:  by hverstee for vds.240
#
# Revision 1.8  1996/02/16  06:04:38  pinnacle
# Replaced: vdtbl/mgr/VDAttrFun.I for:  by rgade for vds.240
#
# Revision 1.7  1996/02/15  23:15:40  pinnacle
# Replaced: ./vdtbl/mgr/VDAttrFun.I for:  by azuurhou for vds.240
#
# Revision 1.6  1995/09/22  17:08:34  pinnacle
# Replaced: vdtbl/mgr/VDAttrFun.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/09/05  20:17:56  pinnacle
# Replaced: vdtbl/mgr/VDAttrFun.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/01  16:06:44  pinnacle
# Replaced: vdtbl/mgr/VDAttrFun.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/06  14:37:06  pinnacle
# Replaced: vdtbl/mgr/VDAttrFun.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  19:28:50  pinnacle
# Replaced: vdtbl/mgr/VDAttrFun.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/05/31  22:28:20  pinnacle
# Replaced: vdtbl/mgr/VDAttrFun.I by hverstee r#
#
# Revision 1.2  1995/05/26  16:21:02  pinnacle
# Replaced: vdtbl/mgr/VDAttrFun.I by hverstee r#
#
# Revision 1.1  1995/05/25  21:47:16  pinnacle
# Created: vdtbl/mgr/VDAttrFun.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      05/24/95          HV            New
 *      05/31/96          tlb           Added flag to VD_Return_Attr 
 *
 * -------------------------------------------------------------------*/

class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include <sys/types.h>

#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "VDmacdef.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "acmacros.h"
#include "asbox.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"
#include "exdef.h"
#include "exmacros.h"
#include "msmacros.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"
#include "cotxmacros.h"

#include "vdbmacros.h"
#include "vdsmacros.h"
#include "vdparmacros.h"
#include "VDDbtbldef.h"

#include "VDdrwlo.h"
#include "VDdrwlo_db.h"
#include "VDdrwlo_pr.h"
#include "VDmem.h"

/*     ROUTE INCLUDES      */

#include "vrdef.h"
#include "VRDbParamDef.h"
#include "VRdbcodlst.h"
#include "VRparamdef.h"

/*
#define     MY_DEBUG	1
*/

struct    local_tab  {
       IGRchar     AtNam[20];
       IGRint      LsNum;
                     };

from     VDSroot    import   VDGetProduct;
from     GRfm       import   GRfm_retdata;
from     GRfm       import   GRfm_get_entries;




IGRint   VD_R_Codelist (IGRint     Product,
                        IGRchar   *Attrnam)
{
  IGRint      Listnum;
  IGRshort    i;
  IGRshort    iNmEnt;

  struct  local_tab    *pLoc;

/* ----------------------------------------------------------------------- */
/*      DEFINE CODELISTED ATTRIBUTES WITH THEIR CODELIST NUMBERS           */
/*                                                                         */

#define   VDX_LOC_VD_TABNO    3      /*   no of VDS codelist tab   */
#define   VDX_LOC_SM_TABNO    3      /*   no of struct codelist tab */
#define   VDX_LOC_HV_TABNO    2      /*   no of hvac codelist tab */
#define   VDX_LOC_RW_TABNO    2      /*   no of rway codelist tab */
#define   VDX_LOC_PP_TABNO   15      /*   no of piping codelist tab */

  struct   local_tab  VdTab[VDX_LOC_VD_TABNO] =
  {
    VD_N_MATERIAL_AN           , 125,
    VD_N_APPRV_STAT_AN         , 35,
    VD_N_CONST_STAT_AN         , 50
  };

  struct   local_tab  SmTab[VDX_LOC_SM_TABNO] =
  {
    VD_N_MATERIAL_AN           , 125,
    VD_N_APPRV_STAT_AN         , 35,
    VD_N_CONST_STAT_AN         , 50
  };

  struct   local_tab  HvTab[VDX_LOC_HV_TABNO] =
  {
    VR_N_APPRV_STAT_AN         , VR_P_APP_STS_LSTNUM,
    VR_N_CONSTR_STAT_AN        , VR_P_CONST_STS_LSTNUM
  };

  struct   local_tab  RwTab[VDX_LOC_RW_TABNO] =
  {
    VR_N_APPRV_STAT_AN         , VR_P_APP_STS_LSTNUM,
    VR_N_CONSTR_STAT_AN        , VR_P_CONST_STS_LSTNUM
  };

  struct   local_tab  PpTab[VDX_LOC_PP_TABNO] =
  {
    VD_N_MATERIAL_AN           , 145,
    VR_N_PREPS_G_IN            , VR_P_END_COND_LSTNUM,
    VR_N_RATINGS_G_DB          , VR_P_PRES_CLASS_LSTNUM,
    VR_N_SERVICE_AN            , VR_P_NOZ_SRV_LSTNUM,
    VR_N_THICK_OVER_AN         , VR_P_SCHED_THK_LSTNUM,
    VR_N_END_STD_G_IN          , VR_P_END_STD_LSTNUM,
    VR_N_INSUL_TYPE_AN         , VR_P_INSUL_TYPE_LSTNUM,
    VR_N_TRACING_CODE_AN       , VR_P_TRACE_TYPE_LSTNUM,
    VR_N_APPRV_STAT_AN         , VR_P_APP_STS_LSTNUM,
    VR_N_CONSTR_STAT_AN        , VR_P_CONST_STS_LSTNUM,
    VR_N_FLUID_CODE_AN         , VR_P_FLUID_CODE_LSTNUM,
    VR_N_PREP_G_IN             , VR_P_END_COND_LSTNUM,
    VR_N_PAINT_CODE_AN         , VR_P_PAINT_TYPE_LSTNUM,
    VR_N_WEIGHT_GRP_IN         , VR_P_WEIGHT_GRP_LSTNUM,
    VR_N_CHG_REQ_NUM_IN        , VR_P_CHANGE_NO_LSTNUM
  };
/*                                                                         */
/* ----------------------------------------------------------------------- */

  Listnum = -1;

  switch (Product)
  {
    case VDS:
      pLoc    = VdTab;
      iNmEnt  = VDX_LOC_VD_TABNO;
      break;

    case STRUCT:
      pLoc    = SmTab;
      iNmEnt  = VDX_LOC_SM_TABNO;
      break;

    case PIPING:
      pLoc    = PpTab;
      iNmEnt  = VDX_LOC_PP_TABNO;
      break;

    case HVAC:
      pLoc    = HvTab;
      iNmEnt  = VDX_LOC_HV_TABNO;
      break;

    case CABLING:
      pLoc    = RwTab;
      iNmEnt  = VDX_LOC_RW_TABNO;
      break;

    default:    return (Listnum);
  }


  for (i=0; i<iNmEnt; i++)
  {
    if (strcmp (pLoc[i].AtNam, Attrnam) == 0)
    {
      Listnum = pLoc[i].LsNum;
      break;
    }
  }

  return (Listnum);
}



IGRint   VD_Return_Attr (IGRlong      *msg,
                         IGRint        NumPar,
                  struct GRid         *InGrid,
                  struct ACrg_coll    *Return,
                  struct GRmd_env     *md_env,
		  int		       use_long_text)

{
  IGRint      status;
  IGRshort    Product;
  IGRint      intPr;
  IGRint      Listnum;
  IGRint      Listcode;
  IGRshort    iPar;

  status =
  vd$review_params (pMsg       = msg,
                    pComponent = InGrid,
                    NbParams   = NumPar,
                    pList      = Return,
                    pMdEnv     = md_env);

  status =
  om$send (msg = message VDSroot.VDGetProduct (&Product, NULL),
      targetid = InGrid->objid,
      targetos = InGrid->osnum,
      senderid = NULL_OBJID);

  intPr = Product;

  /*   try to convert codelisted values    */

  for (iPar = 0; iPar < NumPar; iPar++)
  {
    if (Return[iPar].desc.type == AC_ATTRIB_TEXT) continue;

    Listcode = Return[iPar].desc.value.att_exp + 0.001;

    Listnum  = VD_R_Codelist (Product, Return[iPar].name);

    if (Listnum > 0)
    {
      IGRlong     retmsg;
      IGRchar     LocStr[20];
      IGRchar     ErrStr[200];

      if (use_long_text) 
	      status =
	      vd$get_alias (p_msg   = &retmsg,
	                    product = intPr,
	                    type    = Listnum,
	                    i_code  = Listcode,
	                    o_lname = LocStr,
	                    p_error = ErrStr);
      else 
	      status =
	      vd$get_alias (p_msg   = &retmsg,
	                    product = intPr,
	                    type    = Listnum,
	                    i_code  = Listcode,
	                    o_sname = LocStr,
	                    p_error = ErrStr);

      if (status & OM_S_SUCCESS)
      {
        Return[iPar].desc.type = AC_ATTRIB_TEXT;
        strcpy (Return[iPar].desc.value.att_txt, LocStr);
      }
    }
  }

  return (status);
}


IGRint   VD_DLO_SetIndx (IGRchar      *Userid,
                         IGRchar      *Timest,
                         IGRboolean   *Local,
                         IGRshort     *LcUnit)
{
  IGRint      i, ilen;
  char       *pNam;
  time_t      curtime;
  char       *pTim;

  extern  char * getlogin();
  extern  char * cuserid();

  if (Timest)
  {
    for (i=0; i<VD_DRWLO_CHR_TSTP; i++)
     Timest[i] = '\0';

    time(&curtime);
    pTim = ctime (&curtime);
/*
    ilen = strlen (pTim);
    if (ilen > VD_DRWLO_CHR_TSTP) ilen = VD_DRWLO_CHR_TSTP;
    for (i=0; i<ilen; i++)
      Timest[i] = pTim[i];

    Timest[VD_DRWLO_CHR_TSTP-1] = '\0';
*/

    /*   reformat date / time stamp for nitpickers    */

    Timest[0]  = pTim[4];
    Timest[1]  = pTim[5];
    Timest[2]  = pTim[6];
    Timest[3]  = ' ';
    Timest[4]  = pTim[8];
    Timest[5]  = pTim[9];
    Timest[6]  = ',';
    Timest[7]  = pTim[22];
    Timest[8]  = pTim[23];
    Timest[9]  = '-';
    Timest[10] = pTim[11];
    Timest[11] = pTim[12];
    Timest[12] = pTim[13];
    Timest[13] = pTim[14];
    Timest[14] = pTim[15];
    Timest[15] = '\0';
  }

  if (Userid)
  {
    for (i=0; i<VD_DRWLO_CHR_IDFLD; i++)
     Userid[i] = '\0';

    pNam = getlogin();

    if (pNam == NULL) pNam = cuserid (NULL);

    if (pNam != NULL)
    {
      ilen = strlen (pNam);
      if (ilen > VD_DRWLO_CHR_IDFLD) ilen = VD_DRWLO_CHR_IDFLD;
      for (i=0; i<ilen; i++)
        Userid[i] = pNam[i];

      Userid[VD_DRWLO_CHR_IDFLD-1] = '\0';
    }
    else
      strcpy (Userid, "Xuser");
  }

  if (Local)
    *Local = TRUE;

  /* @@@@@@@ Set units of design file    */

  if (LcUnit)
    *LcUnit = 0;

  return (OM_S_SUCCESS);
}


IGRint  VD_Find_DBowner (IGRchar      *DBTabnam,
                         IGRchar      *DBTabkey,
                         IGRchar      *DBowner)
{
  IGRint        status;
  IGRchar       szWhere[100];
  IGRchar     **DbIO;
  IGRint        NbRow;

  DBowner[0] = '\0';

  /*   construct key   */

  strcpy (szWhere, VDDRWLO_DB_KEY);
  strcat (szWhere, "=\'");
  strcat (szWhere, DBTabkey);
  strcat (szWhere, "\'");

  /*   it is assumed that we are logged into the DB   */
  status=
  vdb$RisSelect (select     = "userid_0",
                 table_name = DBTabnam,
                 where      = szWhere,
                 numselect  = 1,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (status & OM_S_SUCCESS)
  {
    if (NbRow >= 1)
    {
      strcpy (DBowner,  DbIO[0]);
    }
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  return (status);
}


IGRboolean  VD_Allow_DBdel (IGRchar      *DBTabnam,
                            IGRchar      *DBTabkey)
{
  IGRint        status;
  IGRchar       luser[VD_DRWLO_CHR_IDFLD+4];
  IGRchar       dbowner[VD_DRWLO_CHR_IDFLD+4];
  IGRboolean    retval;

  status = VD_DLO_SetIndx (luser, NULL, NULL, NULL);

  status = VD_Find_DBowner (DBTabnam, DBTabkey, dbowner);

  if (strlen(dbowner) > 0)
    retval = (strcmp (luser, dbowner) == 0);
  else        /* not found, write OK, delete not necessary but allowed   */
    retval = TRUE;

  return (retval);
}


IGRint    VD_get_fontlist (IGRlong      *msg,
                           IGRshort     *numfont,
                           IGRchar      *Fonts)
{
  IGRint                 status;
  IGRlong                retmsg;
  IGRshort               nFnos[MAXFONT];
  IGRshort               ii;
  IGRint                 jpt;
  IGRchar              * cp;

  struct GRid            MMod;
  struct GRid            Fmgr;
  struct vfont_entry     Fts;

  *msg = MSSUCC;

  cp = (IGRchar *) &Fts.vfontname[0];

  ex$get_cur_mod (osnum = &MMod.osnum);

  MMod.objid = NULL_OBJID;
  Fmgr.objid = NULL_OBJID;
  Fmgr.osnum = MMod.osnum;

  ex$get_super(mod_id       = MMod.objid,
                mod_osnum   = MMod.osnum,
                super_name  = FONTMGR_NO_NAME,
                create      = TRUE,
                super_class = "GRfm",
                super_id    = &Fmgr.objid,
                super_osnum = &Fmgr.osnum);

#ifdef MY_DEBUG
  printf ("fontmanager <%d %d>\n",Fmgr.objid, Fmgr.osnum);
#endif

  if (Fmgr.objid == NULL_OBJID) goto GEN_DEF;

  status =
  om$send (msg = message GRfm.GRfm_get_entries (&retmsg, numfont, nFnos),
      senderid = NULL_OBJID,
      targetid = Fmgr.objid,
      targetos = Fmgr.osnum);

#ifdef MY_DEBUG
  printf ("from fontmanager %d entries\n",*numfont);
#endif

  if (*numfont == 0) goto GEN_DEF;

  if (Fonts)
  {
    for (ii=0; ii< (*numfont); ii++)
    {

      jpt = ii * FONT_NAME;

      status =
      om$send (msg = message GRfm.GRfm_retdata (&retmsg, &nFnos[ii], &Fts),
          senderid = NULL_OBJID,
          targetid = Fmgr.objid,
          targetos = Fmgr.osnum);

#ifdef MY_DEBUG
  printf ("from fontmanager %s named font\n",cp);
#endif

      strcpy (&Fonts[jpt], cp);
    }
  }

  return (OM_S_SUCCESS);

  GEN_DEF:
  *numfont = 1;
  if (Fonts)
    strcpy (Fonts, "default");
  return (OM_S_SUCCESS);
}

IGRint VD_font_nam_to_num (IGRchar   *szFont)

{
  IGRint     iRet = -1;
  IGRchar   *FList;
  IGRshort   nFonts, i, jpt;
  IGRlong    retmsg;

  FList = NULL;

  VD_get_fontlist (&retmsg, &nFonts, NULL);

  FList = _MALLOC ((nFonts + 1) * FONT_NAME, IGRchar);
  if (FList != NULL)
  {
    VD_get_fontlist (&retmsg, &nFonts, FList);

    for (i=0; i<nFonts; i++)
    {
      jpt = i * FONT_NAME;

      if (strcmp (szFont, &FList[jpt]) == 0)
      {
        iRet = i;
        break;
      }
    }

    _FREE (FList);
  }

  return (iRet);
}

end implementation Root;

