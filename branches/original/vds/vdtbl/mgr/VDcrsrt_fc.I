
/* $Id: VDcrsrt_fc.I,v 1.2 2001/06/08 19:34:14 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDcrsrt_fc.I
 *
 * Description:
 *
 * Implementation file for sort criteria public function interface
 *    (includes support for reference files)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcrsrt_fc.I,v $
 *      Revision 1.2  2001/06/08 19:34:14  ylong
 *      TR5299
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/29  04:58:08  pinnacle
# Replaced: vdtbl/mgr/VDcrsrt_fc.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/04/12  19:32:22  pinnacle
# Replaced: vdtbl/mgr/VDcrsrt_fc.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/09/08  23:35:22  pinnacle
# Replaced: vdtbl/mgr/VDcrsrt_fc.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/09/07  15:30:02  pinnacle
# Replaced: vdtbl/mgr/VDcrsrt_fc.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/08/25  15:11:58  pinnacle
# Created: vdtbl/mgr/VDcrsrt_fc.I by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      08/24/95          HV            Created from VDcrsrt_fcn.I
 *
 * -------------------------------------------------------------------*/

class implementation VDcrsrt;

#include <ctype.h>
#include <string.h>
#include <stdio.h>

#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "acmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"
#include "exdef.h"
#include "exmacros.h"
#include "msmacros.h"
#include "vdbmacros.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "PDUerror.h"

#include "VDdrwlo.h"
#include "VDdrwlo_db.h"
#include "VDdrwlo_int.h"
#include "VDdrwlo_pr.h"
#include "VDDbDef.h"

#include "v_miscmacros.h"
#include "vdtblmacros.h"

/*
#define   MY_DEBUG
*/

extern GRclassid   OPP_VDcrsrt_class_id;

/*     static buffer (cache index)     */

%safe
static struct VDSSC_index        *pIndex = NULL;
static        IGRint              nIndex = 0;
static        IGRint              nTotix = 0;
static        IGRint              nVdb   = FALSE;
static        IGRshort            nOS    = -1;
%endsafe



IGRint  VDtbl_stc_open (IGRlong      *msg,
                        GRspacenum    cur_os)
{
  IGRint         status;
  IGRchar        pwdName[DI_PATH_MAX];

  extern int VDSverify_login();
  extern int VdsVerifyRisTable();

  status = OM_S_SUCCESS;
  *msg   = MSSUCC;
  pwdName[0] = '\0';

  if (cur_os == 0) cur_os = nOS;

  if (cur_os != nOS)
    VDtbl_stc_close(msg);     /*  need different OS, close old  */
  else
  if ((pIndex != NULL) && (!nVdb))
  {  /*  open index without DB, see if DB has been added */
      if ((VDSverify_login() == PDM_S_SUCCESS) &&
          (VdsVerifyRisTable(VDCRSRT_NAM_TAB) == VDS_DBTABLE_FOUND))
      {  /*  logged in, close index and reopen   */
        VDtbl_stc_close(msg);
      }
  }

  status =
  di$pwd (dirname = pwdName );
  as$status();

 if (pIndex == NULL) 
 { 
    IGRchar      szPathName[DI_PATH_MAX];
    IGRchar      szBasePath[DI_PATH_MAX];
    IGRchar      ppDir[DI_PATH_MAX];
    IGRchar    **DbIO;
    DIint        IDir;
    IGRint       IDB;
    IGRshort     i,j, idsp;
    IGRlong      retmsg;

    struct GRid           dirobj;
    struct VDdrwlo_sstab  lTab;

    *msg   = MSFAIL;
    DbIO   = NULL;
    nOS    = cur_os;

    status =
    di$give_pathname (osnum = nOS, pathname = szPathName );
    as$status();

    strcpy (szBasePath, szPathName);

    strcat (szPathName, ":" );
    strcat (szPathName, VDCRSRT_DB_CACHE);

    /*    find directory for cache   */

    status = di$translate ( objname = szPathName,
                            osnum   = nOS,
                            p_objid = &dirobj.objid,
                            p_osnum = &dirobj.osnum );

    if (status != DIR_S_SUCCESS)
    { /*   make new directory   */
      status = di$mkdir (dirname = szPathName,
                         osnum   = nOS,
                         p_dirid = &dirobj.objid,
                         p_osnum = &dirobj.osnum );
      as$status();
      IDir = 0;

      status = di$cd (dirname = szPathName,
                      osnum   = nOS);
      as$status();
    }
    else
    { /*  or change to the existing one   */
      status = di$cd (dirname = szPathName,
                      osnum   = nOS);
      as$status();

      IDir = 0;

      status = di$start_dump (regexp = "*",
                              options = 0,
                              ptr    = &IDir);
      as$status();
    }

    if (VDSverify_login() == PDM_S_SUCCESS)
    {
      if (VdsVerifyRisTable(VDCRSRT_NAM_TAB) == VDS_DBTABLE_FOUND)
        nVdb = TRUE;
      else
        UI_status (VD_DRWLO_NODB_MSG);
    }

    if (nVdb)
    {
      status=
      vdb$RisSelect (select     = VDCRSRT_SEL_IDX,
                     table_name = VDCRSRT_NAM_TAB,
                     numselect  = VDCRSRT_NUM_IDX,
                     p_numrows  = &IDB,
                     p_buffer   = &DbIO);
    }
    else
      IDB = 0;

    nTotix = IDir + IDB + 1;

    /*   allocate local index   */

    pIndex = _MALLOC (nTotix, struct VDSSC_index);

    if (pIndex == NULL)
    { /*   no memory, abort   */
      status = di$cd (dirname = szBasePath,
                      osnum   = nOS);
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
                     p_objid = &pIndex[i].LocId.objid,
                     p_osnum = &pIndex[i].LocId.osnum);
      as$status();

      status =
      om$send (msg = message VDSSC.VDSSC_gtab (&retmsg, &lTab),
          targetid = pIndex[i].LocId.objid,
          targetos = pIndex[i].LocId.osnum,
          senderid = NULL_OBJID);
      as$status();

      strcpy (pIndex[i].Tabnam, lTab.Tabnam);
      strcpy (pIndex[i].Desc  , lTab.Shdesc);
      pIndex[i].bInDB = FALSE;
    }

    nIndex = IDir;

    for (j=0; j<IDB; j++)
    { /*  add the ones that are only in the DB   */
      idsp = j * VDCRSRT_NUM_IDX;

      for (i=0; i<IDir; i++)
      {
        if (strcmp (pIndex[i].Tabnam, DbIO[idsp]) != 0) continue;

        pIndex[i].bInDB = TRUE;
        goto BYPASS;
      }

      strcpy (pIndex[nIndex].Tabnam, DbIO[idsp]);
      strcpy (pIndex[nIndex].Desc  , DbIO[idsp+1]);
      pIndex[nIndex].bInDB       = TRUE;
      pIndex[nIndex].LocId.objid = NULL_OBJID;
      pIndex[nIndex].LocId.osnum = nOS;

      nIndex++;
      BYPASS:;
    }

    status = di$cd (dirname = szBasePath,
                    osnum   = nOS);
    as$status();
  }

  *msg   = MSSUCC;

  WRAPUP:
  if( pwdName[0] != '\0' ){
        status = di$cd( dirname = pwdName );
        if( status != DIR_S_SUCCESS ){
                printf(" Can't change working directory to : %s\n", pwdName );
        }
  }

  return (status);
}


IGRint  VDtbl_stc_new  (IGRlong      *msg,
                        GRspacenum    cur_os,
                        IGRchar      *Tabnam,
                 struct GRid         *DRWloid)
{
  IGRint         status;
  IGRchar        szPathName[DI_PATH_MAX];

  struct  VDdrwlo_sstab    TLocal;

  /*  not in index, totally new table    */

  if (cur_os == 0) cur_os = nOS;

  status = VDtbl_stc_open (msg, cur_os);
  if (!(status & OM_S_SUCCESS)) return (status);

  DRWloid->objid = NULL_OBJID;
  DRWloid->osnum = nOS;

  *msg = MSFAIL;
  if ((Tabnam == NULL) || (Tabnam[0] == '\0')) return (OM_E_INVARG);

  strcpy (TLocal.Tabnam, Tabnam);

  TLocal.Shdesc[0]  = '\0';
  TLocal.Local      = TRUE;

  status =
  om$construct (classid = OPP_VDcrsrt_class_id,
                p_objid = &DRWloid->objid,
                osnum   =  DRWloid->osnum,
                 msg    = message VDSSC.VDSSC_init (msg, &TLocal));
  as$status ();

  di$give_pathname ( osnum = DRWloid->osnum,
                  pathname = szPathName );

  strcat (szPathName, ":" );
  strcat (szPathName, VDCRSRT_DB_CACHE);
  strcat (szPathName, ":" );
  strcat (szPathName, Tabnam);

  /*  Put the return Pb Id in directories  */

  status=
  om$send (msg = message ACncpx.GRputname( msg, szPathName),
      targetid = DRWloid->objid,
      targetos = DRWloid->osnum,
      senderid = NULL_OBJID);
  as$status ();

  /*   need to extend the index, close and let open redefine    */

  status = VDtbl_stc_close (msg);

  return (status);
}

IGRint  VDtbl_stc_close (IGRlong      *msg)

{
  *msg = MSSUCC;

  _FREE (pIndex);

  pIndex = NULL;
  nIndex = 0;
  nTotix = 0;
  nVdb   = FALSE;
  nOS    = -1;

  return (OM_S_SUCCESS);
}


IGRint  VDtbl_stc_del (IGRlong      *msg,
                       GRspacenum    cur_os,
                       IGRchar      *Tabnam)
{
  IGRint         status;
  IGRshort       iLoop;

  /*  make sure system is opened  */

  if (cur_os == 0) cur_os = nOS;

  status = VDtbl_stc_open (msg, cur_os);
  if (!(status & OM_S_SUCCESS)) return (status);

  for (iLoop=0; iLoop < nIndex; iLoop++)
  {
    if (strcmp (pIndex[iLoop].Tabnam, Tabnam) != 0)  continue;

    if (pIndex[iLoop].LocId.objid == NULL_OBJID)
    {  /* not loaded, cannot delete   */
      *msg = MSFAIL;
    }
    else
    {
      di$rm_objid (objid = pIndex[iLoop].LocId.objid,
                   osnum = pIndex[iLoop].LocId.osnum);

      status =
      om$send (msg = message Root.delete (0),
          senderid = NULL_OBJID,
          targetid = pIndex[iLoop].LocId.objid,
          targetos = pIndex[iLoop].LocId.osnum);
      as$status ();

      pIndex[iLoop].LocId.objid = NULL_OBJID;

      /*   redefine index, layout may have been only local   */

      status = VDtbl_stc_close (msg);
    }

    break;
  }

  return (status);
}





IGRint  VDtbl_stc_getid (IGRlong      *msg,
                         GRspacenum    cur_os,
                         IGRchar      *Tabnam,
                  struct GRid         *DRWloid)
{
  IGRint         status;
  IGRshort       iLoop;

  if (cur_os == 0) cur_os = nOS;

  status = VDtbl_stc_open (msg, cur_os);
  if (!(status & OM_S_SUCCESS)) return (status);

  *msg = MSFAIL;

  DRWloid->objid = NULL_OBJID;
  DRWloid->osnum = nOS;

  for (iLoop=0; iLoop < nIndex; iLoop++)
  {
    if (strcmp (pIndex[iLoop].Tabnam, Tabnam) != 0)  continue;

    if (pIndex[iLoop].LocId.objid == NULL_OBJID)
    {  /* not loaded, get from DB   */
      IGRchar                  szPathName[DI_PATH_MAX];
      struct  VDdrwlo_sstab    TLocal;

      pIndex[iLoop].LocId.osnum = DRWloid->osnum;

      di$give_pathname ( osnum = DRWloid->osnum,
                      pathname = szPathName );

      strcat (szPathName, ":" );
      strcat (szPathName, VDCRSRT_DB_CACHE);
      strcat (szPathName, ":" );
      strcat (szPathName, Tabnam);

      strcpy (TLocal.Tabnam, Tabnam);
      TLocal.Shdesc[0] = '\0';
      TLocal.Local     = FALSE;

      status =
      om$construct (classid = OPP_VDcrsrt_class_id,
                    p_objid = &pIndex[iLoop].LocId.objid,
                    osnum   =  pIndex[iLoop].LocId.osnum,
                     msg    = message VDSSC.VDSSC_init (msg, &TLocal));
      as$status ();

      /*    load from DB    */
      status =
      om$send (msg = message VDSSC.VDSSC_fill (msg),
          targetid = pIndex[iLoop].LocId.objid,
          targetos = pIndex[iLoop].LocId.osnum,
          senderid = NULL_OBJID);
      as$status ();

      /*  Put the return Pb Id in directories  */
      status=
      om$send (msg = message ACncpx.GRputname( msg, szPathName),
          targetid = pIndex[iLoop].LocId.objid,
          targetos = pIndex[iLoop].LocId.osnum,
          senderid = NULL_OBJID);
      as$status ();
    }  /* end load from DB   */

    DRWloid->objid = pIndex[iLoop].LocId.objid;
    DRWloid->osnum = pIndex[iLoop].LocId.osnum;
    *msg = MSSUCC;
    break;
  }

  return (status);
}

IGRint  VDtbl_stc_getx (IGRlong      *msg,
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

  pNLoc    = Tabnam;
  pDLoc    = Tabdes;
  *nCount  = 0;

  if (cur_os == 0) cur_os = nOS;

  status = VDtbl_stc_open (msg, cur_os);
  if (!(status & OM_S_SUCCESS)) return (status);

  for (iLoop=0; iLoop < nIndex; iLoop++)
  {
    if (((bLocal) && (pIndex[iLoop].LocId.objid != NULL_OBJID)) ||
        ((bDB)    && (pIndex[iLoop].bInDB)))
    {
      if (Tabnam != NULL)
      {
        strcpy (pNLoc, pIndex[iLoop].Tabnam);
        pNLoc += VD_DRWLO_CHR_IDFLD;
      }

      if (Tabdes != NULL)
      {
        strcpy (pDLoc, pIndex[iLoop].Desc);
        pDLoc += VD_DRWLO_CHR_DESC;
      }

      (*nCount)++;
    }
  }

  return (status);
}

end implementation VDcrsrt;

