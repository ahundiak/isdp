
/* $Id: VDdrwlo_fc.I,v 1.3 2001/10/08 16:34:51 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDdrwlo_fc.I
 *
 * Description:
 *
 * Implementation file for table manager public function interface
 *    (includes support for reference files)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwlo_fc.I,v $
 *      Revision 1.3  2001/10/08 16:34:51  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/06/08 19:34:18  ylong
 *      TR5299
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/29  05:00:08  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fc.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/04/12  19:33:04  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fc.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/09/08  23:35:16  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fc.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/09/05  20:15:54  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fc.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/08/25  15:12:56  pinnacle
# Created: vdtbl/mgr/VDdrwlo_fc.I by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      08/21/95          HV            Created from VDdrwlo_fcn.I
 *	10/08/01	ylong		CR5636
 *
 * -------------------------------------------------------------------*/

class implementation VDdrwlo_occ;

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
#include "VDmem.h"

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

extern GRclassid   OPP_VDdrwlo_occ_class_id;

/*     static buffer (cache index)     */

%safe
static struct VDdrwlo_index      *pIndex = NULL;
static        IGRshort            nIndex = 0;
static        IGRshort            nTotix = 0;
static        IGRshort            nVdb   = FALSE;
static        IGRshort            nOS    = -1;
%endsafe


IGRint VDdrwlo_index_cmp( struct VDdrwlo_index *e1, struct VDdrwlo_index *e2 )
{
	return strcmp( e1->Tabnam, e2->Tabnam );
}

IGRint  VDtbl_dlo_open (IGRlong      *msg,
                        GRspacenum    cur_os)
{
  IGRint         status;
  IGRchar        pwdName[DI_PATH_MAX];

  extern int VDSverify_login();
  extern int VdsVerifyRisTable();

  status = OM_S_SUCCESS;
  *msg   = MSSUCC;

  if (cur_os == 0) cur_os = nOS;

  if (cur_os != nOS) 
    VDtbl_dlo_close(msg);     /*  need different OS, close old  */
  else
  if ((pIndex != NULL) && (!nVdb))
  {  /*  open index without DB, see if DB has been added */
      if ((VDSverify_login() == PDM_S_SUCCESS) &&
          (VdsVerifyRisTable(VDDRWLO_NAM_TAB) == VDS_DBTABLE_FOUND))
      {  /*  logged in, close index and reopen   */
        VDtbl_dlo_close(msg);
      }
  }

  pwdName[0] ='\0';
  status = di$pwd( dirname = pwdName );
  as$status();

  if (pIndex == NULL)
  { /*  actual open, create cache   */
    IGRchar      szPathName[DI_PATH_MAX];
    IGRchar      szBasePath[DI_PATH_MAX];
    IGRchar      ppDir[DI_PATH_MAX];
    IGRchar    **DbIO;
    DIint        IDir;
    IGRint       IDB;
    IGRshort     i,j, idsp;
    IGRlong      retmsg;

    struct GRid           dirobj;
    struct VDdrwlo_tab    lTab;

    *msg   = MSFAIL;
    DbIO   = NULL;
    nOS    = cur_os;

    status =
    di$give_pathname (osnum = nOS, pathname = szPathName );
    as$status();

#ifdef MY_DEBUG
    printf ("OSnum, path %d %s\n",nOS, szPathName);
#endif

    strcpy (szBasePath, szPathName);

    strcat (szPathName, ":" );
    strcat (szPathName, VDDRWLO_DB_CACHE);

    status = di$translate ( objname = szPathName,
                            osnum   = nOS,
                            p_objid = &dirobj.objid,
                            p_osnum = &dirobj.osnum );

    if (status != DIR_S_SUCCESS)
    { /*   create directory   */
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
    { /*  move to existing directory  */
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
      if (VdsVerifyRisTable(VDDRWLO_NAM_TAB) == VDS_DBTABLE_FOUND)
        nVdb = TRUE;
      else
        UI_status (VD_DRWLO_NODB_MSG);
    }

    if (nVdb)
    { /*  retrieve DB records   */
      status=
      vdb$RisSelect (select     = VDDRWLO_SEL_IDX,
                     table_name = VDDRWLO_NAM_TAB,
                     numselect  = VDDRWLO_NUM_IDX,
                     p_numrows  = &IDB,
                     p_buffer   = &DbIO);
      as$status();
    }
    else
      IDB = 0;

    nTotix = IDir + IDB + 1;

    pIndex = _MALLOC (nTotix, struct VDdrwlo_index);
    if (pIndex == NULL)
    { /*   no memory, abort   */
      status = di$cd (dirname = szBasePath,
                      osnum   = nOS);
      status = OM_E_NODYNMEM;
      goto WRAPUP;
    }

    /*   put loaded objects in cache   */
    for (i=0; i<IDir; i++)
    {
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
      om$send (msg = message VDdrwlo.VDdrwlo_gtab (&retmsg, &lTab),
          targetid = pIndex[i].LocId.objid,
          targetos = pIndex[i].LocId.osnum,
          senderid = NULL_OBJID);
      as$status();

      strcpy (pIndex[i].Tabnam, lTab.Tabnam);
      strcpy (pIndex[i].Tabtyp, lTab.Tabtyp);
      strcpy (pIndex[i].Desc  , lTab.Shdesc);
      pIndex[i].bInDB = FALSE;
    }

    nIndex = IDir;

    /*   add DB objects to cache if not yet there   */
    for (j=0; j<IDB; j++)
    {
      idsp = j * VDDRWLO_NUM_IDX;

      for (i=0; i<IDir; i++)
      {
        if (strcmp (pIndex[i].Tabnam, DbIO[idsp]) != 0) continue;

        pIndex[i].bInDB = TRUE;
        goto BYPASS;
      }

      strcpy (pIndex[nIndex].Tabnam, DbIO[idsp]);
      strcpy (pIndex[nIndex].Tabtyp, DbIO[idsp+1]);
      strcpy (pIndex[nIndex].Desc  , DbIO[idsp+2]);
      pIndex[nIndex].bInDB       = TRUE;
      pIndex[nIndex].LocId.objid = NULL_OBJID;
      pIndex[nIndex].LocId.osnum = nOS;

      nIndex++;
      BYPASS:;
    }

    qsort((char*)pIndex, nIndex, sizeof(struct VDdrwlo_index), 
				(int(*)())VDdrwlo_index_cmp);

    status = di$cd (dirname = szBasePath,
                    osnum   = nOS);
    as$status();

    VdsRisFreeBuffer (DbIO, IDB);
  }

  *msg   = MSSUCC;

  WRAPUP:
  if( pwdName[0] != '\0' ){
        status = di$cd( dirname = pwdName );
        if( status != DIR_S_SUCCESS ){
                printf(" Can't change working directory to : %s\n", pwdName );
        }
  }
#ifdef MY_DEBUG
  printf ("DLO_OPEN %d entries\n",nIndex);
#endif
  return (status);
}

IGRint  VDtbl_dlo_new  (IGRlong      *msg,
                        GRspacenum    cur_os,
                        IGRchar      *Tabnam,
                        IGRchar      *Tabtyp,
                 struct GRid         *DRWloid)
{
  IGRint         status;
  IGRchar        szPathName[DI_PATH_MAX];

  struct  VDdrwlo_tab      TLocal;

  if (cur_os == 0) cur_os = nOS;

  /*  not in index, totally new table    */

  status = VDtbl_dlo_open (msg, nOS);
  if (!(status & OM_S_SUCCESS)) return (status);

  DRWloid->objid = NULL_OBJID;
  DRWloid->osnum = nOS;

  *msg = MSFAIL;
  if ((Tabnam == NULL) || (Tabnam[0] == '\0')) return (OM_E_INVARG);

  strcpy (TLocal.Tabnam, Tabnam);
  if (Tabtyp != NULL)
    strcpy (TLocal.Tabtyp, Tabtyp);
  else
    TLocal.Tabtyp[0] = '\0';

  TLocal.Shdesc[0]  = '\0';
  TLocal.SumFil[0]  = '\0';
  TLocal.SortFil[0] = '\0';
  TLocal.Local      = TRUE;
  TLocal.direct     = VD_DRWLO_EN_DESCEND;

  status =
  om$construct (classid = OPP_VDdrwlo_occ_class_id,
                p_objid = &DRWloid->objid,
                osnum   =  DRWloid->osnum,
                 msg    = message VDdrwlo.VDdrwlo_init (msg, &TLocal));
  as$status ();

  di$give_pathname ( osnum = DRWloid->osnum,
                  pathname = szPathName );

  strcat (szPathName, ":" );
  strcat (szPathName, VDDRWLO_DB_CACHE);
  strcat (szPathName, ":" );
  strcat (szPathName, Tabnam);

  /*  Put the return Pb Id in directories  */

  status=
  om$send (msg = message ACncpx.GRputname( msg, szPathName),
      targetid = DRWloid->objid,
      targetos = DRWloid->osnum,
      senderid = NULL_OBJID);
  as$status ();

  /*   extend the index, close and let open redefine    */

  status = VDtbl_dlo_close (msg);

  return (status);
}

IGRint  VDtbl_dlo_close (IGRlong      *msg)

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


IGRint  VDtbl_dlo_del (IGRlong      *msg,
                       GRspacenum    cur_os,
                       IGRchar      *Tabnam,
                       IGRchar      *Tabtyp)
{
  IGRint         status;
  IGRshort       iLoop;

  /*  make sure system is opened  */

  if (cur_os == 0) cur_os = nOS;

  status = VDtbl_dlo_open (msg, cur_os);
  if (!(status & OM_S_SUCCESS)) return (status);

  for (iLoop=0; iLoop < nIndex; iLoop++)
  {
    if (strcmp (pIndex[iLoop].Tabnam, Tabnam) != 0)  continue;

    if ((Tabtyp != NULL) &&
        (strcmp (pIndex[iLoop].Tabtyp, Tabtyp) != 0)) continue;

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

      status = VDtbl_dlo_close (msg);
    }

    break;
  }

  return (status);
}



IGRint  VDtbl_dlo_getid (IGRlong      *msg,
                         GRspacenum    cur_os,
                         IGRchar      *Tabnam,
                         IGRchar      *Tabtyp,
                  struct GRid         *DRWloid)
{
  IGRint         status;
  IGRshort       iLoop;

  if (cur_os == 0) cur_os = nOS;

  status = VDtbl_dlo_open (msg, cur_os);
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
      struct  VDdrwlo_tab      TLocal;

      pIndex[iLoop].LocId.osnum = DRWloid->osnum;

      di$give_pathname ( osnum = DRWloid->osnum,
                      pathname = szPathName );

      strcat (szPathName, ":" );
      strcat (szPathName, VDDRWLO_DB_CACHE);
      strcat (szPathName, ":" );
      strcat (szPathName, Tabnam);

      strcpy (TLocal.Tabnam, Tabnam);
      if (Tabtyp != NULL)
        strcpy (TLocal.Tabtyp, Tabtyp);
      else
        TLocal.Tabtyp[0] = '\0';

      TLocal.Local = FALSE;

      status =
      om$construct (classid = OPP_VDdrwlo_occ_class_id,
                    p_objid = &pIndex[iLoop].LocId.objid,
                    osnum   =  pIndex[iLoop].LocId.osnum,
                     msg    = message VDdrwlo.VDdrwlo_init (msg, &TLocal));
      as$status ();

      /*    load from DB    */
      status =
      om$send (msg = message VDdrwlo.VDdrwlo_fill (msg),
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



IGRint  VDtbl_dlo_getx (IGRlong      *msg,
                        GRspacenum    cur_os,
                        IGRboolean    bLocal,
                        IGRboolean    bDB,
                        IGRchar      *TTin,
                        IGRshort     *nCount,
                        IGRchar      *Tabnam,
                        IGRchar      *Tabtyp,
                        IGRchar      *Tabdes)
{
  IGRint         status;
  IGRshort       iLoop;
  IGRchar       *pNLoc;
  IGRchar       *pTLoc;
  IGRchar       *pDLoc;

  pNLoc    = Tabnam;
  pTLoc    = Tabtyp;
  pDLoc    = Tabdes;
  *nCount  = 0;

  if (cur_os == 0) cur_os = nOS;

  status = VDtbl_dlo_open (msg, cur_os);
  if (!(status & OM_S_SUCCESS)) return (status);

#ifdef MY_DEBUG
      printf ("IDX %d entries %d %d\n",nIndex,bLocal,bDB);
#endif

  for (iLoop=0; iLoop < nIndex; iLoop++)
  {
    if (((bLocal) && (pIndex[iLoop].LocId.objid != NULL_OBJID)) ||
        ((bDB)    && (pIndex[iLoop].bInDB)))
    {

      if ((TTin == NULL)   ||
          (strcmp (pIndex[iLoop].Tabtyp, TTin) == 0))
      {
        if (Tabnam != NULL)
        {
          strcpy (pNLoc, pIndex[iLoop].Tabnam);
          pNLoc += VD_DRWLO_CHR_IDFLD;
        }

        if (Tabtyp != NULL)
        {
          strcpy (pTLoc, pIndex[iLoop].Tabtyp);
          pTLoc += VD_DRWLO_CHR_IDFLD;
        }

        if (Tabdes != NULL)
        {
          strcpy (pDLoc, pIndex[iLoop].Desc);
          pDLoc += VD_DRWLO_CHR_DESC;
        }

        (*nCount)++;
      }
    }
  }

  return (status);
}

IGRint  VDtbl_dlo_gett (IGRlong      *msg,
                        GRspacenum    cur_os,
                        IGRboolean    bLocal,
                        IGRboolean    bDB,
                        IGRshort     *nCount,
                        IGRchar      *Tabtyp)
{
  IGRint         status;
  IGRshort       iLoop;
  IGRshort       iChk;
  IGRchar       *pTLoc;

  pTLoc    = Tabtyp;
  *nCount  = 0;

  if (cur_os == 0) cur_os = nOS;

  status = VDtbl_dlo_open (msg, cur_os);
  if (!(status & OM_S_SUCCESS)) return (status);

  for (iLoop=0; iLoop < nIndex; iLoop++)
  { /*   get unique list of types   */
    if (((bLocal) && (pIndex[iLoop].LocId.objid != NULL_OBJID)) ||
        ((bDB)    && (pIndex[iLoop].bInDB)))
    {

      for (iChk=0; iChk<iLoop; iChk++)
      {
        if (((bLocal) && (pIndex[iChk].LocId.objid != NULL_OBJID)) ||
            ((bDB)    && (pIndex[iChk].bInDB)))
          if (strcmp (pIndex[iLoop].Tabtyp,pIndex[iChk].Tabtyp) == 0)
                                  goto BYPASS;
      }

      if (pTLoc != NULL)
      {
        strcpy (pTLoc, pIndex[iLoop].Tabtyp);
        pTLoc += VD_DRWLO_CHR_IDFLD;
      }

      (*nCount)++;
    }
    BYPASS:;
  }

  return (status);
}

end implementation VDdrwlo_occ;

