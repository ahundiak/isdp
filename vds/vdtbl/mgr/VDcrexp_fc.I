
/* $Id: VDcrexp_fc.I,v 1.4 2002/05/02 18:44:10 ahundiak Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDcrexp_fc.I
 *
 * Description:
 *
 * Implementation file for expression criteria public function interface
 *    (includes support for reference files)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcrexp_fc.I,v $
 *      Revision 1.4  2002/05/02 18:44:10  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/06/08 19:34:12  ylong
 *      TR5299
 *
 *      Revision 1.2  2001/02/25 14:48:08  ad
 *      *** empty log message ***
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/04/16  14:53:08  pinnacle
# Replaced: vdtbl/mgr/VDcrexp_fc.I for:  by mdong for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.10  1998/02/27  16:50:50  pinnacle
# Replaced: vdtbl/mgr/VDcrexp_fc.I for:  by mdong for vds
#
# Revision 1.9  1998/02/27  14:20:42  pinnacle
# Replaced: vdtbl/mgr/VDcrexp_fc.I for:  by mdong for vds
#
# Revision 1.8  1998/02/20  08:21:52  pinnacle
# Replaced: vdtbl/mgr/VDcrexp_fc.I for:  by vgnair for vds
#
# Revision 1.6  1997/12/29  04:56:58  pinnacle
# Replaced: vdtbl/mgr/VDcrexp_fc.I for:  by ksundar for vds
#
# Revision 1.5  1997/11/06  08:30:22  pinnacle
# Replaced: vdtbl/mgr/VDcrexp_fc.I for:  by ksundar for vds
#
# Revision 1.4  1997/11/05  08:54:48  pinnacle
# Replaced: vdtbl/mgr/VDcrexp_fc.I for:  by ksundar for vds
#
# Revision 1.3  1997/10/31  20:22:58  pinnacle
# UnInit warning
#
# Revision 1.2  1997/10/29  08:23:38  pinnacle
# Replaced: vdtbl/mgr/VDcrexp_fc.I for:  by ksundar for vds
#
# Revision 1.1  1997/10/21  04:00:18  pinnacle
# Created: vdtbl/mgr/VDcrexp_fc.I by ksundar for vds
#
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      10/03/97        Sundar		Creation Date
 *	10/30/97	ah		UnInit warning
 *	11/05/97	Ad/Sundar	Added the function VDtbl_exp_exec
 *	02/13/98	vini		TR-179800499
 *      02/27/98        Ming		TR179800761
 * -------------------------------------------------------------------*/

class implementation VDcrexp;

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

// #define vdsDEBUG        1
#include "v_dbgmacros.h"
#include "v_drwproto.h"
#include "VDexpdef.h"

/*
#define   MY_DEBUG
*/

extern GRclassid   OPP_VDcrexp_class_id;

/*     static buffer (cache index)     */

%safe
static struct VDcrexp_index        *pIndex = NULL;
static        IGRint              nIndex = 0;
static        IGRint              nTotix = 0;
static        IGRint              nVdb   = FALSE;
static        IGRshort            nOS    = -1;
%endsafe


IGRint  VDtbl_exp_open (IGRlong      *msg,
                        GRspacenum    cur_os)
{
  IGRint         status;
  IGRchar        pwdName[DI_PATH_MAX];

  extern int VDSverify_login();
  extern int VdsVerifyRisTable();

  SetProc( VDtbl_exp_open ); Begin

  status = OM_S_SUCCESS;
  *msg   = MSSUCC;
  pwdName[0] = '\0';

  if (cur_os == 0) cur_os = nOS;

//  VDtbl_exp_close(msg);

  if (cur_os != nOS)
    VDtbl_exp_close(msg);     /*  need different OS, close old  */
  else
  if ((pIndex != NULL) && (!nVdb))
  {  /*  open index without DB, see if DB has been added */
      if ((VDSverify_login() == PDM_S_SUCCESS) &&
          (VdsVerifyRisTable(VDCREXP_NAM_TAB) == VDS_DBTABLE_FOUND))
      {  /*  logged in, close index and reopen   */
        VDtbl_exp_close(msg);
      }
  }

  status = di$pwd( dirname = pwdName );
  as$status ();

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
    struct VDdrwexp_tab  lTab;
    struct VDdrwexp_data lDTab;

    *msg   = MSFAIL;
    DbIO   = NULL;
    nOS    = cur_os;

    status =
    di$give_pathname (osnum = nOS, pathname = szPathName );
    as$status();

    strcpy (szBasePath, szPathName);

    strcat (szPathName, ":" );
    strcat (szPathName, VDCREXP_DB_CACHE);

    status = di$translate ( objname = szPathName,
                            osnum   = nOS,
                            p_objid = &dirobj.objid,
                            p_osnum = &dirobj.osnum );

    if (status != DIR_S_SUCCESS)
    {
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
    {
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
      if (VdsVerifyRisTable(VDCREXP_NAM_TAB) == VDS_DBTABLE_FOUND)
        nVdb = TRUE;
      else
// TR-179800499        UI_status (VD_DRWLO_NODB_MSG);
        UI_status ("Database does not support EXPRESSION tables");
    }

    if (nVdb)
    {
      status=
      vdb$RisSelect (select     = VDCREXP_SEL_IDX,
                     table_name = VDCREXP_NAM_TAB,
                     numselect  = VDCREXP_NUM_IDX,
                     p_numrows  = &IDB,
                     p_buffer   = &DbIO);
    }
    else
      IDB = 0;


    nTotix = IDir + IDB + 1;

    __DBGpr_int("nTotix", nTotix);

    if( nTotix) pIndex = _MALLOC (nTotix, struct VDcrexp_index);

    if (pIndex == NULL)
    { /*   no memory, abort   */
      status = di$cd (dirname = szBasePath,
                      osnum   = nOS);
      status = OM_E_NODYNMEM;
      goto WRAPUP;
    }

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
      om$send (msg = message VDcrexp.VDcrexp_gtab (&retmsg, &lTab, 
		NULL, NULL),
          targetid = pIndex[i].LocId.objid,
          targetos = pIndex[i].LocId.osnum,
          senderid = NULL_OBJID);
      as$status();


      strcpy (pIndex[i].Tabtyp, lTab.Tabtyp);
      strcpy (pIndex[i].Tabnam, lTab.Tabnam);
      strcpy (pIndex[i].Desc  , lTab.Shdesc);
      pIndex[i].bInDB = FALSE;
    }

    nIndex = IDir;

    for (j=0; j<IDB; j++)
    {
      idsp = j * VDCREXP_NUM_IDX;

      for (i=0; i<IDir; i++)
      {
        if (strcmp (pIndex[i].Tabnam, DbIO[idsp+1]) != 0) continue;

        pIndex[i].bInDB = TRUE;
        goto BYPASS;
      }

      strcpy (pIndex[nIndex].Tabtyp, DbIO[idsp]);
      strcpy (pIndex[nIndex].Tabnam, DbIO[idsp+1]);
      strcpy (pIndex[nIndex].Desc  , DbIO[idsp+2]);
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

  End
  return (status);
}

IGRint  VDtbl_exp_new  (IGRlong      *msg,
                        GRspacenum    cur_os,
                        IGRchar      *Tabnam,
                 struct GRid         *Expid)
{
  IGRint         status;
  IGRchar        szPathName[DI_PATH_MAX];

  struct  VDdrwexp_tab    TLocal;
  struct  VDdrwexp_data   TDLocal;

  /*  not in index, totally new table    */

  SetProc( VDtbl_exp_new); Begin
  if (cur_os == 0) cur_os = nOS;

  status = VDtbl_exp_open (msg, cur_os);
  if (!(status & OM_S_SUCCESS)) return (status);

  Expid->objid = NULL_OBJID;
  Expid->osnum = nOS;

  *msg = MSFAIL;
  if ((Tabnam == NULL) || (Tabnam[0] == '\0')) return (OM_E_INVARG);

  strcpy (TLocal.Tabnam, Tabnam);

  TLocal.Tabtyp[0] = '\0' ;
  TLocal.Shdesc[0]  = '\0';
  TLocal.data_type  = -1;
  TLocal.Local      = TRUE;

  status =
  om$construct (classid = OPP_VDcrexp_class_id,
                p_objid = &Expid->objid,
                osnum   =  Expid->osnum,
                msg    = message VDcrexp.VDcrexp_init (msg,&TLocal,0,NULL));
  as$status ();

  di$give_pathname ( osnum = Expid->osnum,
                  pathname = szPathName );

  strcat (szPathName, ":" );
  strcat (szPathName, VDCREXP_DB_CACHE);
  strcat (szPathName, ":" );
  strcat (szPathName, Tabnam);

  /*  Put the return Pb Id in directories  */
  status=
  om$send (msg = message ACncpx.GRputname( msg, szPathName),
      targetid = Expid->objid,
      targetos = Expid->osnum,
      senderid = NULL_OBJID);
  as$status ();

  /*   need to extend the index, close and let open redefine    */

  status = VDtbl_exp_close (msg);

  End

  return (status);
}

IGRint  VDtbl_exp_close (IGRlong      *msg)

{
  IGRint i;
  SetProc( VDtbl_exp_close ); Begin
  *msg = MSSUCC;

  _FREE (pIndex);

  pIndex = NULL;
  nIndex = 0;
  nTotix = 0;
  nVdb   = FALSE;
  nOS    = -1;

  End
  return (OM_S_SUCCESS);
}


IGRint  VDtbl_exp_del (IGRlong      *msg,
                       GRspacenum    cur_os,
                       IGRchar      *Tabnam)
{
  IGRint         status;
  IGRshort       iLoop;

  /*  make sure system is opened  */

  SetProc( VDtbl_exp_del ); Begin
  if (cur_os == 0) cur_os = nOS;

  status = VDtbl_exp_open (msg, cur_os);
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

      status = VDtbl_exp_close (msg);
    }

    break;
  }

  End
  return (status);
}





IGRint  VDtbl_exp_getid (IGRlong      *msg,
                         GRspacenum    cur_os,
                         IGRchar      *Tabnam,
                  struct GRid         *Expid)
{
  IGRint         status;
  IGRshort       iLoop;

  SetProc( VDtbl_exp_getid ); Begin
  if (cur_os == 0) cur_os = nOS;

  status = VDtbl_exp_open (msg, cur_os);
  if (!(status & OM_S_SUCCESS)) return (status);

  *msg = MSFAIL;

  Expid->objid = NULL_OBJID;
  Expid->osnum = nOS;

  for (iLoop=0; iLoop < nIndex; iLoop++)
  {
    if (strcmp (pIndex[iLoop].Tabnam, Tabnam) != 0)  continue;

    if (pIndex[iLoop].LocId.objid == NULL_OBJID)
    {  /* not loaded, get from DB   */
      IGRchar                  szPathName[DI_PATH_MAX];
      struct  VDdrwexp_tab    TLocal;
      struct  VDdrwexp_data   TDLocal;

      pIndex[iLoop].LocId.osnum = Expid->osnum;

      di$give_pathname ( osnum = Expid->osnum,
                      pathname = szPathName );

      strcat (szPathName, ":" );
      strcat (szPathName, VDCREXP_DB_CACHE);
      strcat (szPathName, ":" );
      strcat (szPathName, Tabnam);

      strcpy (TLocal.Tabtyp, pIndex[iLoop].Tabtyp); /* added for TR179800761 */
      strcpy (TLocal.Tabnam, Tabnam);
      TLocal.Shdesc[0] = '\0';
      TLocal.Local     = FALSE;

      status =
      om$construct (classid = OPP_VDcrexp_class_id,
                    p_objid = &pIndex[iLoop].LocId.objid,
                    osnum   =  pIndex[iLoop].LocId.osnum,
                     msg    = message VDcrexp.VDcrexp_init(msg,&TLocal,
			0,NULL));
      as$status ();

      /*    load from DB    */
      status =
      om$send (msg = message VDcrexp.VDcrexp_fill (msg),
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

    Expid->objid = pIndex[iLoop].LocId.objid;
    Expid->osnum = pIndex[iLoop].LocId.osnum;
    *msg = MSSUCC;
    break;
  }

  End
  return (status);
}
IGRint  VDtbl_exp_getx (IGRlong      *msg,
                        GRspacenum    cur_os,
                        IGRboolean    bLocal,
                        IGRboolean    bDB,
                        IGRshort     *nCount,
                        IGRchar      *Tabtyp,
                        IGRchar      *Tabnam,
                        IGRchar      *Tabdes)
{
  IGRint         status;
  IGRshort       iLoop;
  IGRchar       *pTLoc;
  IGRchar       *pNLoc;
  IGRchar       *pDLoc;
 
  SetProc( VDtbl_exp_getx ); Begin
  pTLoc    = Tabtyp;
  pNLoc    = Tabnam;
  pDLoc    = Tabdes;
  *nCount  = 0;
 
  if (cur_os == 0) cur_os = nOS;
 
  status = VDtbl_exp_open (msg, cur_os);
  if (!(status & OM_S_SUCCESS)) return (status);
 
  for (iLoop=0; iLoop < nIndex; iLoop++)
  {
 
 
       if (((bLocal) && (pIndex[iLoop].LocId.objid != NULL_OBJID)) ||
          ((bDB)    && (pIndex[iLoop].bInDB)))
       {
	  if (Tabtyp != NULL)
          {
            strcpy (pTLoc, pIndex[iLoop].Tabtyp);
            pTLoc += VD_CREXP_CHR_TYPE;
          }
 

          if (Tabnam != NULL)
          {
            strcpy (pNLoc, pIndex[iLoop].Tabnam);
            pNLoc += VD_CREXP_CHR_NAME;
          }
 
          if (Tabdes != NULL)
          {
            strcpy (pDLoc, pIndex[iLoop].Desc);
            pDLoc += VD_CREXP_CHR_DESC;
          }
 
          (*nCount)++;
       }
  }
  End
  return (status);
}

IGRint  VDtbl_exp_getnd (IGRlong      *msg,
                        GRspacenum    cur_os,
                        IGRboolean    bLocal,
                        IGRboolean    bDB,
                        IGRchar      *p_type,
                        IGRshort     *nCount,
                        IGRchar      *Tabnam,
                        IGRchar      *Tabdes)
{
  IGRint         status;
  IGRshort       iLoop;
  IGRchar       *pNLoc;
  IGRchar       *pDLoc;

  SetProc( VDtbl_exp_getnd ); Begin
  pNLoc    = Tabnam;
  pDLoc    = Tabdes;
  *nCount  = 0;

  if (cur_os == 0) cur_os = nOS;

  status = VDtbl_exp_open (msg, cur_os);
  if (!(status & OM_S_SUCCESS)) return (status);

  for (iLoop=0; iLoop < nIndex; iLoop++)
  {


    if ( strcmp(pIndex[iLoop].Tabtyp , p_type ) == 0) 
    {
       if (((bLocal) && (pIndex[iLoop].LocId.objid != NULL_OBJID)) ||
          ((bDB)    && (pIndex[iLoop].bInDB)))
       {
          if (Tabnam != NULL)
          {
            strcpy (pNLoc, pIndex[iLoop].Tabnam);
            pNLoc += VD_CREXP_CHR_NAME;
          }

          if (Tabdes != NULL)
          {
            strcpy (pDLoc, pIndex[iLoop].Desc);
            pDLoc += VD_CREXP_CHR_DESC;
          }

          (*nCount)++;
       }
    }
  }
  End
  return (status);
}

IGRint  VDtbl_exp_gett (IGRlong      *msg,
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
 
  status = VDtbl_exp_open (msg, cur_os);
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
        pTLoc += VD_CREXP_CHR_TYPE;
      }
 
      (*nCount)++;
    }
    BYPASS:;
  }
 
  return (status);
}


IGRlong  VDtbl_exp_set (IGRlong      		*msg,
                	GRspacenum		cur_os,
                        IGRchar			*Tabnam,
                  	struct GRid		*Expid,
		  	struct VDdrwexp_tab	*Exptab,
			IGRint			num_exp_data,
		  	struct VDdrwexp_data	*ExpData)
{
  IGRlong         status;
  IGRshort       iLoop;
  struct GRid tab_id;
 
  SetProc( VDtbl_exp_set ); Begin
  if (cur_os == 0) cur_os = nOS;

  // Need to init
  status = OM_E_ABORT;

  if ( (Tabnam == NULL) && (Expid == NULL) )
	goto wrapup;


  if ( Tabnam != NULL){
     vd$tblexp_old (msg    = msg,
                          osnum  = cur_os,
                          tabnam = Tabnam,
                          GRid   = &tab_id);
  }
  if ( Expid != NULL ){
     tab_id.objid = Expid->objid;
     tab_id.osnum = Expid->osnum;
  }
  
  if ( tab_id.objid == NULL_OBJID )
	goto wrapup;

  status = om$send (msg = message VDcrexp.VDcrexp_init
                              (msg, Exptab, num_exp_data, ExpData),
	senderid = NULL_OBJID,
        targetid = tab_id.objid,
	targetos = tab_id.osnum); 
  as$status();

  wrapup :
  End
  return (status); 
}

IGRlong  VDtbl_exp_exec (IGRlong                 *msg,
                        GRspacenum              cur_os,
                        IGRchar                 *Tabnam,
                        struct GRid             *Expid,
                        IGRchar                 *in_buffer,
			IGRshort              	Xflag,
			IGRshort              	mode,
                        IGRint                  num_objs,
			struct GRobj_env   	*objList,
			struct ACrg_coll   	*coll)
{
  IGRlong		status;
  IGRint		i, j, buf_len, num_exp_data;
  struct GRid 		tab_id;
  IGRchar    		*buffer = NULL ;
  struct VDdrwexp_data	*ExpData = NULL ;
  VD_execRes		value;
 
  SetProc( VDtbl_exp_exec ); Begin
 
  status = MSFAIL ;
  if (( coll == NULL ) && (Tabnam == NULL) && (Expid == NULL) && 
	(in_buffer == NULL ))
        goto wrapup;
 
  coll->desc.type == AC_ATTRIB_TYPE_NOT_DEF;
  if ( in_buffer != NULL ){
        status = VD_expParse(in_buffer, Xflag, mode, num_objs, objList, &value);
  } else {

  	if ( Tabnam != NULL){
     		vd$tblexp_old (msg    = msg,
                          osnum  = cur_os,
                          tabnam = Tabnam,
                          GRid   = &tab_id);
  	}
  	if ( Expid != NULL ){
     		tab_id.objid = Expid->objid;
     		tab_id.osnum = Expid->osnum;
  	}
 
  	if ( tab_id.objid == NULL_OBJID )
        	goto wrapup;
 
  	num_exp_data = 0 ;
  	status = om$send (msg = message VDcrexp.VDcrexp_gdata
                              (msg, &num_exp_data, &ExpData),
        	senderid = NULL_OBJID,
        	targetid = tab_id.objid,
        	targetos = tab_id.osnum);
  	if( !(status & *msg & 1 )){ goto wrapup ; }

  	buf_len=0;
  	for (i=0; i<num_exp_data; i++){
		buf_len += strlen(ExpData[i].Datinfo);
  	}
  	__DBGpr_int(" Buffer Length ", buf_len );

  	if( ! buf_len ) { goto wrapup ; };

  	buffer = _MALLOC( buf_len +10, char );
  	buffer[0] = '\0' ;
	for( i = 0 ; i < num_exp_data ; i++ )
        {
          for( j = 0 ; j < num_exp_data ; j++ )
          {
            if( ExpData[j].Datsegn == i )
            {
              strcat( buffer, ExpData[j].Datinfo );
              break;
            }
          }
        }
        /* Commented by Ming
  	for (i=0; i<num_exp_data; i++){
		strcat(buffer,ExpData[i].Datinfo);
  	}
        */

  	status = VD_expParse (buffer, Xflag, mode, num_objs, objList, &value);
  }

#ifdef vdsDEBUG
  VD_drwVerbValType( "\t\t\t\t-> %@", &value );
  printf ("\t%s\n", (status == VD_STATUS_OK) ? "OK" :
			((status == VD_STATUS_WARN ) ? "WARN" : "ERROR"));
#endif
  if( status == VD_STATUS_OK ) status = OM_S_SUCCESS ; 

  __DBGpr_int(" tbl_exp_exec status ", status );
  __DBGpr_int(" tbl_exp_exec valueType ", value.type );
  
  /*
   * Put Result in output collector 
   */

  if ( value.type == VD_double ){ 
	coll->desc.type = AC_ATTRIB_DOUBLE;
	coll->desc.value.att_exp = value._dval;
	__DBGpr_dbl(" value (dbl) ", coll->desc.value.att_exp );
  } else if ( value.type == VD_int ){
	coll->desc.type = AC_ATTRIB_DOUBLE;
        coll->desc.value.att_exp = value._ival;
	__DBGpr_dbl(" value (dbl) ", coll->desc.value.att_exp );
  } else if ( value.type == VD_string){
	coll->desc.type = AC_ATTRIB_TEXT;
	strcpy(coll->desc.value.att_txt, value._sval);
	__DBGpr_str(" value (str) ", coll->desc.value.att_txt );
  } else{
	__DBGpr_com(" RETURN UNKNOWN type ");
	coll->desc.type = AC_ATTRIB_TYPE_NOT_DEF;
  }


  wrapup :
	_FREE(ExpData);
	_FREE(buffer);
  End
  return (status);
}

end implementation VDcrexp;
