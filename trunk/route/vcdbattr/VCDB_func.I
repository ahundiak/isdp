
/* $Id: VCDB_func.I,v 1.2 2001/02/20 01:10:33 build Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vcdbattr/VCDB_func.I
 *
 * Description:
 *
 * Implementation file for cabling DB public function interface
 *    (includes support for reference files)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCDB_func.I,v $
 *      Revision 1.2  2001/02/20 01:10:33  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *      Initial import to CVS
 *
# Revision 1.4  1999/02/11  07:58:26  pinnacle
# Replaced: vcdbattr/VCDB_func.I for:  by sbilla for route
#
# Revision 1.3  1999/01/19  08:30:02  pinnacle
# Replaced: vcdbattr/VCDB_func.I for: by aharihar for route
#
# Revision 1.2  1999/01/19  04:18:56  pinnacle
# Replaced: vcdbattr/VCDB_func.I for CR179701619 by aharihar for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/04/20  04:17:30  pinnacle
# Replaced: vcdbattr/VCDB_func.I for:  by kddinov for route
#
# Revision 1.2  1998/02/21  19:59:18  pinnacle
# Replaced: vcdbattr/VCDB_func.I for:  by kddinov for route
#
# Revision 1.7  1997/07/31  20:30:32  pinnacle
# Replaced: vcdbattr/VCDB_func.I for:  by hverstee for cabling
#
# Revision 1.6  1997/07/14  21:43:52  pinnacle
# Replaced: vcdbattr/VCDB_func.I for:  by hverstee for cabling
#
# Revision 1.5  1997/05/19  13:01:56  pinnacle
# Replaced: vcdbattr/VCDB_func.I for:  by hverstee for cabling
#
# Revision 1.4  1997/03/19  15:18:10  pinnacle
# Replaced: vcdbattr/VCDB_func.I for:  by hverstee for cabling
#
# Revision 1.3  1997/01/24  21:24:24  pinnacle
# Replaced: vcdbattr/VCDB_func.I for:  by hverstee for cabling
#
# Revision 1.2  1997/01/23  14:14:08  pinnacle
# Replaced: vcdbattr/VCDB_func.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:52:44  pinnacle
# Created: vcdbattr/VCDB_func.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/13/96          HV            Created from VDcrsrt_fcn.I
 *	Feb/98		KDD		CR179800050 order clause.
 *	19 Jan 1999	Anand		CR179701619  Extended VCDB_setwhich
 *					to include jumpers.
 *      9 Feb  1999     Reddy           TR179802289 - Base directory path
 *					is set correctly .
 * -------------------------------------------------------------------*/

class implementation VCDB;

#include "PDUerror.h"
#include "v_risproto.h"
#include "VCproto.h"
#include "VDmem.h"
#include "VDDbDef.h"

#include "VCchansel.h"
#include "vc_default.h"
#include "VCdbaccess.h"
#include "VCCmdPJ.h"
#include "vrdbgmacros.h"

extern IGRint   VCGetDefaultInfo( IGRint, IGRint, char *);

/*
#define   MY_DEBUG
*/

from   ACncpx  import   GRputname;

extern GRclassid   OPP_VCDBElCab_class_id;
extern GRclassid   OPP_VCDBElTerm_class_id;
extern GRclassid   OPP_VCDBFoCab_class_id;
extern GRclassid   OPP_VCDBFoTerm_class_id;
extern GRclassid   OPP_VCDBGuide_class_id;
extern GRclassid   OPP_VCDBbksh_class_id;
extern GRclassid   OPP_VCDBjumper_class_id; //added for CR179701619

/*     static buffer (cache index)     */

%safe
static VCDB_index      JumperDB   = {NULL, 0, 0}; //added for CR179701619
static VCDB_index      GdDB   = {NULL, 0, 0};
static VCDB_index      BkDB   = {NULL, 0, 0};
static VCDB_index      EtDB   = {NULL, 0, 0};
static VCDB_index      EcDB   = {NULL, 0, 0};
static VCDB_index      FtDB   = {NULL, 0, 0};
static VCDB_index      FcDB   = {NULL, 0, 0};

static IGRboolean      nVdb   = FALSE;
static IGRshort        nOS    = -1;

/*     interfunction communications      */
static IGRshort        nWhich;
static VCDB_indexptr   pLOCSW;
static GRclassid       lCLid;

static IGRchar         szTab[30];
static IGRchar         szPathName[DI_PATH_MAX];
static IGRchar         szBasePath[DI_PATH_MAX];
%endsafe




/*     static (reserved) functions      */

static
void  VCDB_setwhich (IGRshort       ElType,
                     IGRshort       Product)
{
  IGRint	status ;


  SetProc( Fn VCDB_setwhich ); Begin 

  __DBGpr_int( " Object Type ", ElType );

  switch (ElType)
  {
    case VC_TERM_TYPE:
/* 4-98 KDD use single point default selection function
*      if (Product == VC_PROD_ELEC)
*      {
*        nWhich = 1;
*        lCLid  = OPP_VCDBElTerm_class_id;
*        strcpy (szTab, VC_DBT_ELTERM);
*        pLOCSW = &EtDB;
*      }
*      else
*      {
*        nWhich = 2;
*        lCLid  = OPP_VCDBFoTerm_class_id;
*        strcpy (szTab, VC_DBT_FOTERM);
*        pLOCSW = &FtDB;
*      }
*/

/* 4-98 KDD VCGetDefaultInfo uses as default electrical components */

      if (Product == VC_PROD_FO) {
        nWhich = 2;
        pLOCSW = &FtDB;
      }
      else {
        nWhich = 1;
        pLOCSW = &EtDB;
      }

      status = VCGetDefaultInfo( (IGRint) Product,
                                 VC_GET_DB_TERM_CLASS_ID, (char *) &lCLid);

      status = VCGetDefaultInfo( (IGRint) Product,
                                 VC_GET_DB_TERM_TABLE, (char *) szTab);

      break;

    case VC_CABLE_TYPE:
/* 4-98 KDD use single point default selection function
*      if (Product == VC_PROD_ELEC)
*      {
*        nWhich = 3;
*        lCLid  = OPP_VCDBElCab_class_id;
*        strcpy (szTab, VC_DBT_ELCAB);
*        pLOCSW = &EcDB;
*      }
*      else
*      {
*        nWhich = 4;
*        lCLid  = OPP_VCDBFoCab_class_id;
*        strcpy (szTab, VC_DBT_FOCAB);
*        pLOCSW = &FcDB;
*      }
*/

/* 4-98 KDD VCGetDefaultInfo uses as default electrical components */

      if (Product == VC_PROD_FO) {
        nWhich = 4;
        pLOCSW = &FcDB;
      }
      else {
        nWhich = 3;
        pLOCSW = &EcDB;
      }

      status = VCGetDefaultInfo( (IGRint) Product,
                                 VC_GET_DB_CABLE_CLASS_ID, (char *) &lCLid);
 
      status = VCGetDefaultInfo( (IGRint) Product,
                                 VC_GET_DB_CABLE_TABLE, (char *) szTab);

      break;

    case VC_GUIDE_TYPE:
      nWhich = 0;
      lCLid  = OPP_VCDBGuide_class_id;
      strcpy (szTab, VC_DBT_GD);
      pLOCSW = &GdDB;
      break;

    case VC_BKSH_TYPE:
      nWhich = 5;
      lCLid  = OPP_VCDBbksh_class_id;
      strcpy (szTab, VC_DBT_BK);
      pLOCSW = &BkDB;
      break;

    /* added by alwin ...for Jumper Implementation CR179701619 */
    case VC_JUMPER_TYPE:
      __DBGpr_com( " Reached Jumper case... " );
      nWhich = 6;
      lCLid  = OPP_VCDBjumper_class_id;
      strcpy (szTab, VC_DBT_JUMPER);
      pLOCSW = &JumperDB;
      break;
    /* added by alwin ...for CR179701619 */

    default:
      __DBGpr_com( " Reached default case ..." );
      break;
  }

#ifdef MY_DEBUG
  printf ("setwhich = %d\n",nWhich);
#endif

  End
  return;
}

static
void  VCDB_godir   ()
{
  IGRint     status;

  SetProc( Fn VCDB_godir ); Begin 

  __DBGpr_str( " Directory Name ", szPathName );

  status = di$cd (dirname = szPathName,
                  osnum   = nOS);
  End
  return;
}

static
void  VCDB_rsdir   ()
{
  IGRint     status;

  SetProc( Fn VCDB_rsdir ); Begin 
  __DBGpr_str( " Base Dir. path ", szBasePath );
  status = di$cd (dirname = szBasePath,
                  osnum   = nOS);
  End
  return;
}


static
void  VCDB_chkdir   ()
{
  IGRint         status;

  struct GRid    dirobj;

  SetProc( Fn VCDB_chkdir ); Begin 

  __DBGpr_int( " Product Type ", nWhich );

#ifdef MY_DEBUG
  printf ("chkdir nOS = %d\n",nOS);
#endif

  status =
  di$give_pathname (osnum = nOS, pathname = szPathName );
  as$status();
  __DBGpr_str( " szPathName",szPathName);

  strcpy (szBasePath, szPathName);

  strcat (szBasePath,":usr");  // Added for 179802289
 
  strcat (szPathName, ":" );
  strcat (szPathName, VC_DIR_MAIN);

  __DBGpr_str( " Pathname ", szPathName );

  status = di$translate ( objname = szPathName,
                          osnum   = nOS,
                          p_objid = &dirobj.objid,
                          p_osnum = &dirobj.osnum );

  if (status != DIR_S_SUCCESS)
  { /*   make new directory   */
#ifdef MY_DEBUG
    printf ("makedir %s\n",szPathName);
#endif

    status = di$mkdir (dirname = szPathName,
                       osnum   = nOS,
                       p_dirid = &dirobj.objid,
                       p_osnum = &dirobj.osnum );
    as$status();
  }

  VCDB_godir();

  if (nWhich == 0)
  {
    strcat (szPathName, ":" );
    strcat (szPathName, VC_DIR_GD);

    status = di$translate ( objname = szPathName,
                            osnum   = nOS,
                            p_objid = &dirobj.objid,
                            p_osnum = &dirobj.osnum );

    if (status != DIR_S_SUCCESS)
    { /*   make new directory   */
#ifdef MY_DEBUG
      printf ("makedir %s\n",szPathName);
#endif

      status = di$mkdir (dirname = szPathName,
                         osnum   = nOS,
                         p_dirid = &dirobj.objid,
                         p_osnum = &dirobj.osnum );
      as$status();
    }
  }
  else
  if (nWhich == 5)
  {
    strcat (szPathName, ":" );
    strcat (szPathName, VC_DIR_BK);

    status = di$translate ( objname = szPathName,
                            osnum   = nOS,
                            p_objid = &dirobj.objid,
                            p_osnum = &dirobj.osnum );

    if (status != DIR_S_SUCCESS)
    { /*   make new directory   */
#ifdef MY_DEBUG
      printf ("makedir %s\n",szPathName);
#endif

      status = di$mkdir (dirname = szPathName,
                         osnum   = nOS,
                         p_dirid = &dirobj.objid,
                         p_osnum = &dirobj.osnum );
      as$status();
    }
  }
  else
  /* case added for Jumpers */
  if (nWhich == 6)
  {
    strcat (szPathName, ":" );
    strcat (szPathName, VC_DIR_JUMPER);

    __DBGpr_str( " Jumper Directory ", szPathName );
    status = di$translate ( objname = szPathName,
                            osnum   = nOS,
                            p_objid = &dirobj.objid,
                            p_osnum = &dirobj.osnum );

    __DBGpr_obj( " Jumper Directory Id ", dirobj );
    if (status != DIR_S_SUCCESS)
    { /*   make new directory   */
      status = di$mkdir (dirname = szPathName,
                         osnum   = nOS,
                         p_dirid = &dirobj.objid,
                         p_osnum = &dirobj.osnum );
      as$status();

      __DBGpr_obj( " Jumper Directory Number ", dirobj );
    } /*   make new directory   */
  }
  /* case added for Jumpers */
  else
  {
    strcat (szPathName, ":" );
    if ((nWhich == 1) || (nWhich == 2))
      strcat (szPathName, VC_DIR_TERM);
    else
      strcat (szPathName, VC_DIR_CAB);

    status = di$translate ( objname = szPathName,
                            osnum   = nOS,
                            p_objid = &dirobj.objid,
                            p_osnum = &dirobj.osnum );

    if (status != DIR_S_SUCCESS)
    { /*   make new directory   */
#ifdef MY_DEBUG
      printf ("makedir %s\n",szPathName);
#endif
      status = di$mkdir (dirname = szPathName,
                         osnum   = nOS,
                         p_dirid = &dirobj.objid,
                         p_osnum = &dirobj.osnum );
      as$status();
    }

    VCDB_godir();

    strcat (szPathName, ":" );
    if ((nWhich == 1) || (nWhich == 3))
      strcat (szPathName, VC_DIR_ELEC);
    else
      strcat (szPathName, VC_DIR_FO);

    status = di$translate ( objname = szPathName,
                            osnum   = nOS,
                            p_objid = &dirobj.objid,
                            p_osnum = &dirobj.osnum );

    if (status != DIR_S_SUCCESS)
    { /*   make new directory   */
#ifdef MY_DEBUG
      printf ("makedir %s\n",szPathName);
#endif
      status = di$mkdir (dirname = szPathName,
                         osnum   = nOS,
                         p_dirid = &dirobj.objid,
                         p_osnum = &dirobj.osnum );
      as$status();
    }
  }

  VCDB_rsdir();

  End
  return;
}



IGRint  VCDB_open (IGRlong       *msg,
                   IGRshort       ElType,
                   IGRshort       Product,
                   GRspacenum     cur_os)
{
  IGRint         status;

  SetProc( Md VCDB_open ); Begin 

  status = OM_S_SUCCESS;
  *msg   = MSSUCC;

#ifdef MY_DEBUG
  printf ("OPEN DB eltype, prod, os %d %d %d\n",ElType,Product,cur_os);
#endif

  VCDB_setwhich (ElType, Product);

#ifdef DB_MULTI_OS
  if (nOS != -1)   cur_os = nOS;
  if (cur_os == 0) cur_os = nOS;

  if (cur_os != nOS)
    VCDB_close(msg);     /*  need different OS, close old  */
  else
#else
  if (nOS == -1) nOS = VC_GLB_writable_os;
#endif

  if ((pLOCSW->Ent != NULL) && (!nVdb))
  {  /*  open index without DB, see if DB has been added */
      if ((VDSverify_login() == PDM_S_SUCCESS) &&
          (VdsVerifyRisTable(szTab) == VDS_DBTABLE_FOUND))
      {  /*  logged in, close index and reopen   */
        VCDB_close(msg);
      }
  }

#ifndef DB_MULTI_OS
  nOS = VC_GLB_writable_os;
#endif

  VCDB_setwhich (ElType, Product);

  VCDB_chkdir();

  if (pLOCSW->Ent == NULL)
  {
    IGRchar      ppDir[DI_PATH_MAX];
    IGRchar    **DbIO;
    DIint        IDir;
    IGRint       IDB;
    IGRshort     i,j, idsp;
    IGRlong      retmsg;

    struct VCdbmain       lTab;

    *msg   = MSFAIL;
    DbIO   = NULL;

#ifdef DB_MULTI_OS
    nOS    = cur_os;
#else
    nOS    = cur_os = VC_GLB_writable_os;
#endif

#ifdef MY_DEBUG
    printf (" actual open OS = %d\n",nOS);
#endif

    VCDB_godir();

    IDir = 0;

    __DBGpr_com( " Calling di$start_dump " );
    status = di$start_dump (regexp = "*",
                           options = 0,
                               ptr = &IDir);

    if (VDSverify_login() == PDM_S_SUCCESS)
    {
      if (VdsVerifyRisTable(szTab) == VDS_DBTABLE_FOUND)
        nVdb = TRUE;
      else
        UI_status ("Table not in DB");
    }

    /* Feb 98 KDD, CR 179800050 check with VCdbaccess.h to chech that 
    /* VC_DBS_INDEX contains comp_code as an attribute. 
    /*-------------*/
    if (nVdb)
    {
      __DBGpr_com( " Querying the DB ..." );
      status=
      vdb$RisSelect (select     = VC_DBS_INDEX,
                     table_name = szTab,
		     where      = "comp_code IS NOT NULL",
		     order      = "comp_code", 
                     numselect  = VC_DBN_INDEX,
                     p_numrows  = &IDB,
                     p_buffer   = &DbIO);

    }
    else
      IDB = 0;

    pLOCSW->nTotix = IDir + IDB + 1;

    /*   allocate local index   */

    pLOCSW->Ent = _MALLOC (pLOCSW->nTotix, struct  VCDB_index_ent);

    if (pLOCSW->Ent == NULL)
    { /*   no memory, abort   */
      VCDB_rsdir();
      status = OM_E_NODYNMEM;
      goto WRAPUP;
    }

    for (i=0; i<IDir; i++)
    { /*   fill with local names   */
      status =
      di$fetch_dump (line  = ppDir,
                     index = i);

      status =
      di$translate ( objname = ppDir,
                     osnum   = nOS,
                     p_objid = &pLOCSW->Ent[i].LocId.objid,
                     p_osnum = &pLOCSW->Ent[i].LocId.osnum);
      as$status();

      status =
      om$send (msg = message VCDB.VCDB_ghdr (&retmsg, &lTab),
          targetid = pLOCSW->Ent[i].LocId.objid,
          targetos = pLOCSW->Ent[i].LocId.osnum,
          senderid = NULL_OBJID);
      as$status();

      strcpy (pLOCSW->Ent[i].Tabnam, lTab.Compcode);
      strcpy (pLOCSW->Ent[i].Desc  , lTab.Short_desc);
      pLOCSW->Ent[i].bInDB = FALSE;
    }

    pLOCSW->nIndex = IDir;

    for (j=0; j<IDB; j++)
    { /*  add the ones that are only in the DB   */
      idsp = j * VC_DBN_INDEX;

      for (i=0; i<IDir; i++)
      {
        if (strcmp (pLOCSW->Ent[i].Tabnam, DbIO[idsp]) != 0) continue;

        pLOCSW->Ent[i].bInDB = TRUE;
        goto BYPASS;
      }

      strcpy (pLOCSW->Ent[pLOCSW->nIndex].Tabnam, DbIO[idsp]);
      strcpy (pLOCSW->Ent[pLOCSW->nIndex].Desc  , DbIO[idsp+1]);
      pLOCSW->Ent[pLOCSW->nIndex].bInDB       = TRUE;
      pLOCSW->Ent[pLOCSW->nIndex].LocId.objid = NULL_OBJID;
      pLOCSW->Ent[pLOCSW->nIndex].LocId.osnum = nOS;

      pLOCSW->nIndex++;
      BYPASS:;
    }

    VCDB_rsdir();
  }

  *msg   = MSSUCC;

  WRAPUP:
  End
  return (status);
}


IGRint   VCDB_new  (IGRlong       *msg,
                    IGRshort       ElType,
                    IGRshort       Product,
                    GRspacenum     cur_os,
                    IGRchar       *Tabnam,
             struct GRid          *ModelId)
{
  IGRint         status;
  IGRchar        Lpath[DI_PATH_MAX];

  struct  VCdbmain       TLocal;

  SetProc( Fn VCDB_new ); Begin 

  /*  not in index, totally new table    */

#ifdef DB_MULTI_OS
  if (nOS != -1)   cur_os = nOS;
  if (cur_os == 0) cur_os = nOS;
#endif

  status = VCDB_open (msg, ElType, Product, cur_os);
  if (!(status & OM_S_SUCCESS)) return (status);

  ModelId->objid = NULL_OBJID;
  ModelId->osnum = nOS;

  *msg = MSFAIL;
  if (VC_EMPTYSTR(Tabnam)) 
  {
     End
     return (OM_E_INVARG);
  }

  strcpy (TLocal.Compcode, Tabnam);

  VC_INITSTR(TLocal.Short_desc);
  TLocal.Local          = TRUE;

  status =
  om$construct (classid = lCLid,
                p_objid = &ModelId->objid,
                osnum   =  ModelId->osnum,
                 msg    = message VCDB.VCDB_init (msg, &TLocal));
  as$status ();

  /*  Put the return Pb Id in directories  */
  strcpy (Lpath, szPathName);
  strcat (Lpath,":");
  strcat (Lpath, Tabnam);

  status=
  om$send (msg = message ACncpx.GRputname( msg, Lpath),
      targetid = ModelId->objid,
      targetos = ModelId->osnum,
      senderid = NULL_OBJID);
  as$status ();

  /*   need to extend the index, close and let open redefine    */

  status = VCDB_close (msg);

  End
  return (status);
}

IGRint  VCDB_close (IGRlong      *msg)

{
  SetProc( Fn VCDB_close ); Begin 

  *msg = MSSUCC;

#ifdef MY_DEBUG
  printf (" DBcache close\n");
#endif

  _FREE (JumperDB.Ent); //added to clear jumper cache
  _FREE (GdDB.Ent);
  _FREE (BkDB.Ent);
  _FREE (EtDB.Ent);
  _FREE (EcDB.Ent);
  _FREE (FtDB.Ent);
  _FREE (FcDB.Ent);

  JumperDB.nIndex = JumperDB.nTotix = 0; //added to clear jumper cache
  GdDB.nIndex = GdDB.nTotix = 0;
  BkDB.nIndex = BkDB.nTotix = 0;
  EtDB.nIndex = EtDB.nTotix = 0;
  EcDB.nIndex = EcDB.nTotix = 0;
  FtDB.nIndex = FtDB.nTotix = 0;
  FcDB.nIndex = FcDB.nTotix = 0;

  nVdb   = FALSE;
  nOS    = -1;

  End
  return (OM_S_SUCCESS);
}

IGRint  VCDB_clear (IGRlong      *msg,
                    GRspacenum    cur_os)
{
  IGRint         status;

  SetProc( Fn VCDB_clear ); Begin 

  status = VCDB_clprd (msg,(IGRshort)VC_TERM_TYPE,
                           (IGRshort)VC_PROD_ELEC, cur_os);
  status = VCDB_clprd (msg,(IGRshort)VC_TERM_TYPE,
                           (IGRshort)VC_PROD_FO, cur_os);
  status = VCDB_clprd (msg,(IGRshort)VC_CABLE_TYPE,
                           (IGRshort)VC_PROD_ELEC, cur_os);
  status = VCDB_clprd (msg,(IGRshort)VC_CABLE_TYPE,
                           (IGRshort)VC_PROD_FO, cur_os);
  status = VCDB_clprd (msg,(IGRshort)VC_GUIDE_TYPE,
                           (IGRshort)VC_PROD_NONE, cur_os);
  status = VCDB_clprd (msg,(IGRshort)VC_BKSH_TYPE,
                           (IGRshort)VC_PROD_NONE, cur_os);

  End
  return (OM_S_SUCCESS);
}


IGRint  VCDB_clprd (IGRlong      *msg,
                    IGRshort      ElType,
                    IGRshort      Product,
                    GRspacenum    cur_os)
{
  IGRint         status;
  IGRshort       iLoop;

  SetProc( Fn VCDB_clprd ); Begin 

  /*  make sure system is opened  */

#ifdef DB_MULTI_OS
  if (nOS != -1)   cur_os = nOS;
  if (cur_os == 0) cur_os = nOS;
#endif

  status = VCDB_open (msg, ElType, Product, cur_os);
  if (!(status & OM_S_SUCCESS)) return (status);

  for (iLoop=0; iLoop < pLOCSW->nIndex; iLoop++)
  {
    if (pLOCSW->Ent[iLoop].LocId.objid != NULL_OBJID)
    {
      di$rm_objid (objid = pLOCSW->Ent[iLoop].LocId.objid,
                   osnum = pLOCSW->Ent[iLoop].LocId.osnum);

      status =
      om$send (msg = message Root.delete (0),
          senderid = NULL_OBJID,
          targetid = pLOCSW->Ent[iLoop].LocId.objid,
          targetos = pLOCSW->Ent[iLoop].LocId.osnum);
      as$status ();

      pLOCSW->Ent[iLoop].LocId.objid = NULL_OBJID;

    }
  }

  status = VCDB_close (msg);

  End
  return (status);
}


IGRint  VCDB_del (IGRlong      *msg,
                  IGRshort      ElType,
                  IGRshort      Product,
                  GRspacenum    cur_os,
                  IGRchar      *Tabnam)
{
  IGRint         status;
  IGRshort       iLoop;

  /*  make sure system is opened  */

#ifdef DB_MULTI_OS
  if (nOS != -1)   cur_os = nOS;
  if (cur_os == 0) cur_os = nOS;
#endif

  status = VCDB_open (msg, ElType, Product, cur_os);
  if (!(status & OM_S_SUCCESS)) return (status);

  for (iLoop=0; iLoop < pLOCSW->nIndex; iLoop++)
  {
    if (strcmp (pLOCSW->Ent[iLoop].Tabnam, Tabnam) != 0)  continue;

    if (pLOCSW->Ent[iLoop].LocId.objid == NULL_OBJID)
    {  /* not loaded, cannot delete   */
      *msg = MSFAIL;
    }
    else
    {
      di$rm_objid (objid = pLOCSW->Ent[iLoop].LocId.objid,
                   osnum = pLOCSW->Ent[iLoop].LocId.osnum);

      status =
      om$send (msg = message Root.delete (0),
          senderid = NULL_OBJID,
          targetid = pLOCSW->Ent[iLoop].LocId.objid,
          targetos = pLOCSW->Ent[iLoop].LocId.osnum);
      as$status ();

      pLOCSW->Ent[iLoop].LocId.objid = NULL_OBJID;

      /*   redefine index, layout may have been only local   */

      status = VCDB_close (msg);
    }

    break;
  }

  return (status);
}





IGRint  VCDB_old  (IGRlong       *msg,
                   IGRshort       ElType,
                   IGRshort       Product,
                   GRspacenum     cur_os,
                   IGRchar       *Tabnam,
            struct GRid          *ModelId)

{
  IGRint         status;
  IGRshort       iLoop;

  SetProc( Fn VCDB_old ); Begin 

#ifdef DB_MULTI_OS
  if (nOS != -1)   cur_os = nOS;
  if (cur_os == 0) cur_os = nOS;
#endif

  status = VCDB_open (msg, ElType, Product, cur_os);
  if (!(status & OM_S_SUCCESS)) 
  {
     __DBGpr_com( " VCDB_open failed " );
     End
     return (status);
  }

  *msg = MSFAIL;

  ModelId->objid = NULL_OBJID;
  ModelId->osnum = nOS;

#ifdef MY_DEBUG
  printf (" find DBcache, type, prod\n", ElType, Product);
#endif

  __DBGpr_int( " DB Object Index ", pLOCSW->nIndex );
  __DBGpr_str( " Attr. name ", Tabnam );
  for (iLoop=0; iLoop < pLOCSW->nIndex; iLoop++)
  {
    __DBGpr_str( " Attr. name from DB object ", pLOCSW->Ent[iLoop].Tabnam );
    if (strcmp (pLOCSW->Ent[iLoop].Tabnam, Tabnam) != 0)  continue;

    if (pLOCSW->Ent[iLoop].LocId.objid == NULL_OBJID)
    {  /* not loaded, get from DB   */
      IGRchar                Lpath[DI_PATH_MAX];
      struct  VCdbmain       TLocal;

      VCDB_setwhich (ElType, Product); //added by alwin 
      VCDB_godir ();

      __DBGpr_com( " Load from DB...");

      pLOCSW->Ent[iLoop].LocId.osnum = ModelId->osnum;

      __DBGpr_str( " Compcode ", Tabnam );
      strcpy (TLocal.Compcode, Tabnam);
      VC_INITSTR(TLocal.Short_desc);

      TLocal.Local     = FALSE;

      __DBGpr_com( " Constructing the DB object and intializing... " );
      status =
      om$construct (classid = lCLid,
                    p_objid = &pLOCSW->Ent[iLoop].LocId.objid,
                    osnum   =  pLOCSW->Ent[iLoop].LocId.osnum,
                     msg    = message VCDB.VCDB_init (msg, &TLocal));
      as$status ();
      __DBGpr_obj( " ModelId ", pLOCSW->Ent[iLoop].LocId );

      /*    load from DB    */
      __DBGpr_com( " Loading the data from the DB..." );
      status =
      om$send (msg = message VCDB.VCDB_fill (msg),
          targetid = pLOCSW->Ent[iLoop].LocId.objid,
          targetos = pLOCSW->Ent[iLoop].LocId.osnum,
          senderid = NULL_OBJID);
      as$status ();

      /*  Put the return Pb Id in directories  */
      strcpy (Lpath, szPathName);
      strcat (Lpath,":");
      strcat (Lpath, Tabnam);

      status=
      om$send (msg = message ACncpx.GRputname( msg, Lpath),
          targetid = pLOCSW->Ent[iLoop].LocId.objid,
          targetos = pLOCSW->Ent[iLoop].LocId.osnum,
          senderid = NULL_OBJID);
      as$status ();
#ifdef MY_DEBUG
      printf (" putname, %s in <%d %d>\n",Lpath,
                                 pLOCSW->Ent[iLoop].LocId.objid,
                                 pLOCSW->Ent[iLoop].LocId.osnum);
#endif

      VCDB_rsdir ();
    }  /* end load from DB   */

    ModelId->objid = pLOCSW->Ent[iLoop].LocId.objid;
    ModelId->osnum = pLOCSW->Ent[iLoop].LocId.osnum;
    __DBGpr_obj( " ModelId ", *ModelId );
    *msg = MSSUCC;
    break;
  }

  End
  return (status);
}

IGRint  VCDB_list (IGRlong      *msg,
                   IGRshort      ElType,
                   IGRshort      Product,
                   GRspacenum    cur_os,
                   IGRboolean    bLocal,
                   IGRboolean    bDB,
                   IGRshort     *nCount,
                   IGRchar      *Tabnam,
                   IGRchar      *Tabdes)
{
  IGRint         status;
  IGRshort       iLoop;
  IGRchar       *pNLoc;
  IGRchar       *pDLoc;

  SetProc( Fn VCDB_list ); Begin 

  pNLoc    = Tabnam;
  pDLoc    = Tabdes;
  *nCount  = 0;

#ifdef DB_MULTI_OS
  if (nOS != -1)   cur_os = nOS;
  if (cur_os == 0) cur_os = nOS;
#endif

  status = VCDB_open (msg, ElType, Product, cur_os);
  if (!(status & OM_S_SUCCESS)) return (status);


  for (iLoop=0; iLoop < pLOCSW->nIndex; iLoop++)
  {
    if (((bLocal) && (pLOCSW->Ent[iLoop].LocId.objid != NULL_OBJID)) ||
        ((bDB)    && (pLOCSW->Ent[iLoop].bInDB)))
    {
      if (Tabnam != NULL)
      {
        strcpy (pNLoc, pLOCSW->Ent[iLoop].Tabnam);
        pNLoc += VC_MAX_CCODE;
      }

      if (Tabdes != NULL)
      {
        strcpy (pDLoc, pLOCSW->Ent[iLoop].Desc);
        pDLoc += VC_MAX_SDESC;
      }

      (*nCount)++;
    }
  }

  End
  return (status);
}

/*                 service decoder functions                 */

void   VCDBstr  (IGRchar     *Cout,
                 IGRchar     *Cin)
{
  SetProc( Fn VCDBstr ); Begin 

  if (VC_EMPTYSTR(Cin)) VC_INITSTR(Cout);
  else
  if (Cin[0] == ' ')    VC_INITSTR(Cout);
  else
                        strcpy (Cout, Cin);
  End
  return;
}

IGRint   VCDBint  (IGRchar     *Cin)
{
  IGRint    iret;

  extern  IGRint    atoi();

  iret = 0;

  if (Cin != NULL) iret = atoi (Cin);

  return (iret);
}

IGRdouble   VCDBdbl  (IGRchar     *Cin)
{
  IGRdouble    dret;

  extern  IGRdouble    atof();

  dret = 0;

  if (Cin != NULL) dret = atof (Cin);

  return (dret);
}

end implementation VCDB;

