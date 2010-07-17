
/* $Id: VC_ATfun.I,v 1.2 2001/02/20 01:10:00 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VC_ATfun.I
 *
 * Description:
 *      Implementation file for command objects that handle attributes
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VC_ATfun.I,v $
 *  Revision 1.2  2001/02/20 01:10:00  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *  Initial import to CVS
 *
# Revision 1.2  1999/02/11  08:00:30  pinnacle
# Replaced: vccmd/VC_ATfun.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/04/28  22:35:52  pinnacle
# Replaced: vccmd/VC_ATfun.I for:  by hverstee for cabling
#
# Revision 1.1  1997/01/03  17:57:04  pinnacle
# Created: vccmd/VC_ATfun.I by hverstee for cabling
#
 *
 * History:
 *  12/20/96      hv      New
 *  02/08/98      Reddy   TR179802289 - Base directory pathis changed to
 *			  :<filename>:usr
 *
 *************************************************************************/

class implementation VCAT;

#include "VDmem.h"
#include "VCcreate.h"
#include "vrdbgmacros.h"

%safe
#include "VX_FIproto.h"
%endsafe

/*
#define  MY_DEBUG
*/

from  ACrg_collect  import  ACset_list_attribute;
from  ACrg_collect  import  AClist_attribute;
from  ACrg_collect  import  ACcreate;
from  ACrg_collect  import  GRchgname;

from  NDnode        import  NDchg_state;

extern GRclassid   OPP_ACrg_collect_class_id;




extern
IGRint  VC_AT_getact (IGRlong     *msg,
                      IGRint       sys_usr,
                      GRspacenum   nOS,
               struct GRid        *ID)
{      
  IGRint             status;
  IGRchar            szPathName[DI_PATH_MAX];
  IGRchar            szBasePath[DI_PATH_MAX];

SetProc(Fn. VC_AT_getact ); Begin 
  *msg = MSFAIL;

  status =
  di$give_pathname (osnum = nOS, pathname = szPathName );
  as$status();

  strcpy (szBasePath, szPathName);
__DBGpr_str( " szBasePath",szBasePath);

  strcat (szPathName, ":" );
  strcat (szPathName, VC_DIR_ATT);

__DBGpr_str( " szPathName",szPathName);

  status = di$cd (dirname = szPathName,
                  osnum   = nOS);

  strcat (szPathName, ":" );

  if (sys_usr == VC_SYSTEM)
    strcat (szPathName, VC_DIR_SYS );
  else
  if (sys_usr == VC_USER)
    strcat (szPathName, VC_DIR_USER );
  else
    return OM_E_ABORT;
__DBGpr_str( " szPathName after sys_usr",szPathName);
  *msg = MSSUCC;

  ID->objid = NULL_OBJID;

  status = di$translate ( objname = szPathName,
                          osnum   = nOS,
                          p_objid = &ID->objid,
                          p_osnum = &ID->osnum );

  strcat(szBasePath,":usr");  // Added for TR179802289
  __DBGpr_str( " szBasePath",szBasePath);
  status = di$cd (dirname = szBasePath,
                  osnum   = nOS);
End
  return OM_S_SUCCESS;
}


extern
IGRint  VC_AT_setact (IGRlong     *msg,
                      IGRint       sys_usr,
                      GRspacenum   nOS,
               struct GRid        *IDold,
               struct GRid        *ID,
               struct GRmd_env    *md_env)
{
  IGRint             status;
  IGRlong            retmsg;
  IGRchar            szPathName[DI_PATH_MAX];
  IGRchar            szBasePath[DI_PATH_MAX];
  struct GRid        LocID;

SetProc(VC_AT_setact ); Begin 
  status =
  di$give_pathname (osnum = nOS, pathname = szPathName );
  as$status();

  strcpy (szBasePath, szPathName);
  strcat (szBasePath,":usr");  // Added for TR179802289

  strcat (szPathName, ":" );
  strcat (szPathName, VC_DIR_ATT);

  status = di$cd (dirname = szPathName,
                  osnum   = nOS);

  strcat (szPathName, ":" );

  if (sys_usr == VC_SYSTEM)
  {
    strcat (szPathName, VC_DIR_SYS );
    UI_status ("Reset Active System Collector");
  }
  else
  if (sys_usr == VC_USER)
  {
    strcat (szPathName, VC_DIR_USER );
    UI_status ("Reset Active User Collector");
  }
  else
    return OM_E_ABORT;

  *msg = MSSUCC;

  if (IDold == NULL)
    status = VC_AT_getact (msg, sys_usr, nOS, &LocID);
  else
    LocID = *IDold;

  if (LocID.objid != NULL_OBJID)
  { /*    unset old active collection   */
    status =
    om$send( msg = message ACrg_collect.GRchgname
                                   ( &retmsg, md_env, "" ),
        senderid = NULL_OBJID,
        targetid = LocID.objid,
        targetos = LocID.osnum);

    status =
    om$send( msg = message NDnode.NDchg_state(
                               ( (IGRchar)  ND_DEL_NO_CH ),
                               ( (IGRchar)  ND_DEL_NO_CH ) ),
        senderid = NULL_OBJID,
        targetid = LocID.objid,
        targetos = LocID.osnum);
  }

  status =
  om$send( msg = message NDnode.NDchg_state(
                               ( (IGRchar)  ND_DEL_NO_CH ),
                               ( (IGRchar) ~ND_DEL_NO_CH ) ),
      senderid = NULL_OBJID,
      targetid = ID->objid,
      targetos = ID->osnum ) ;
  as$status ();

  status =
  om$send( msg = message ACrg_collect.GRchgname
                             (&retmsg, md_env, szPathName),
      senderid = NULL_OBJID,
      targetid = ID->objid,
      targetos = ID->osnum ) ;

End
  return (OM_S_SUCCESS);
}

end implementation VCAT;

