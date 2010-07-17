
/* $Id: VCCmdPPi.I,v 1.1.1.1 2001/01/04 21:12:31 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCCmdPPi.I
 *
 * Description:
 *      Command object for set/unset passthrough
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdPPi.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.4  1997/05/07  16:17:12  pinnacle
# Replaced: vccmdutil/VCCmdPPi.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/12  22:26:54  pinnacle
# Replaced: vccmdutil/VCCmdPPi.I for:  by hverstee for cabling
#
# Revision 1.2  1996/11/12  17:23:04  pinnacle
# Replaced: vccmdutil/VCCmdPPi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/10/15  19:35:02  pinnacle
# Created: vccmdutil/VCCmdPPi.I by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *
 *************************************************************************/

class implementation VCCmdPP;

#include <stdio.h>
#include <float.h>

#include "FI.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMtypes.h"
#include "ODE.h"

#include "igetypedef.h"
#include "igrdef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "grio.h"

#include "ex.h"
#include "exmacros.h"
#include "msdef.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "coimport.h"
#include "COBmacros.h"

#include "asmacros.h"
#include "AS_status.h"
#include "ACrg_collect.h"
#include "acrepdef.h"
#include "acrepmacros.h"

#include "VCdefine.h"
#include "VCstructs.h"
#include "VCproto.h"
#include "VCCmdDef.h"

/*
#define MY_DEBUG 
*/

from  VCCable   import VCCbTerm;
from  VCTerm    import VCTpass;



method init ( int type ; char * str_ptr )
{
  int		  status;

  /*A initialize superclass */

  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VDS_LOCATE.init( type, str_ptr),
                    targetid = my_id);
  as$status( action = RET_STATUS );

  me->MyType = type;
  me->MyRet  = MSSUCC;

  me->RefId.objid  = NULL_OBJID;
  me->CabId1.objid = NULL_OBJID;
  me->CabId2.objid = NULL_OBJID;

  me->RefId.osnum  = me->ModuleInfo.md_id.osnum;
  me->CabId1.osnum = me->ModuleInfo.md_id.osnum;
  me->CabId2.osnum = me->ModuleInfo.md_id.osnum;

  me->Cab1pos.nType = VC_CABLE_TYPE;
  me->Cab2pos.nType = VC_CABLE_TYPE;

  if (me->MyType == 0)
  {
    me->Cab1pos.Conn.Cable.bPass = TRUE;
    me->Cab2pos.Conn.Cable.bPass = TRUE;
  }
  else
  {
    me->Cab1pos.Conn.Cable.bPass = FALSE;
    me->Cab2pos.Conn.Cable.bPass = FALSE;
  }

  me->Cab1pos.Conn.Cable.nCpt  = -1;
  me->Cab2pos.Conn.Cable.nCpt  = -1;

  me->Cab1pos.Conn.Cable.szLeadId[0] = '\0';
  me->Cab2pos.Conn.Cable.szLeadId[0] = '\0';

  return OM_S_SUCCESS;
}

method VCPPcab1 ( int * sts )
{
  IGRint     status;

  status = OM_S_SUCCESS;

  me->CabId1 = me->event1.located_object[0].located_obj;

  *sts = VC_RTC_ALLOK;
  _put_response( resp = *sts);

  quit:
  return OM_S_SUCCESS;
}

method VCPPcab2 ( int * sts )
{
  IGRint      status;
  IGRlong     retmsg;

  struct GRid    C1T0;
  struct GRid    C1T1;
  struct GRid    C2T0;
  struct GRid    C2T1;

  me->CabId2 = me->event1.located_object[0].located_obj;

  status =
  om$send (msg = message VCCable.VCCbTerm (&retmsg, (IGRshort) 0, &C1T0),
      targetid = me->CabId1.objid,
      targetos = me->CabId1.osnum);

  status =
  om$send (msg = message VCCable.VCCbTerm (&retmsg, (IGRshort) 1, &C1T1),
      targetid = me->CabId1.objid,
      targetos = me->CabId1.osnum);

  status =
  om$send (msg = message VCCable.VCCbTerm (&retmsg, (IGRshort) 0, &C2T0),
      targetid = me->CabId2.objid,
      targetos = me->CabId2.osnum);

  status = 
  om$send (msg = message VCCable.VCCbTerm (&retmsg, (IGRshort) 1, &C2T1),
      targetid = me->CabId2.objid,
      targetos = me->CabId2.osnum);

  *sts = VC_RTC_ALLOK;

  if ((C1T0.objid != NULL_OBJID) && (C1T0.objid == C2T0.objid))
  {
    me->Cab1pos.Conn.Cable.nCpt  = 0;
    me->Cab2pos.Conn.Cable.nCpt  = 0;
    me->RefId = C1T0;
  }
  else
  if ((C1T0.objid != NULL_OBJID) && (C1T0.objid == C2T1.objid))
  {
    me->Cab1pos.Conn.Cable.nCpt  = 0;
    me->Cab2pos.Conn.Cable.nCpt  = 1;
    me->RefId = C1T0;
  }
  else
  if ((C1T1.objid != NULL_OBJID) && (C1T1.objid == C2T0.objid))
  {
    me->Cab1pos.Conn.Cable.nCpt  = 1;
    me->Cab2pos.Conn.Cable.nCpt  = 0;
    me->RefId = C1T1;
  }
  else
  if ((C1T1.objid != NULL_OBJID) && (C1T1.objid == C2T1.objid))
  {
    me->Cab1pos.Conn.Cable.nCpt  = 1;
    me->Cab2pos.Conn.Cable.nCpt  = 1;
    me->RefId = C1T1;
  }
  else
  {
    UI_message (" Cables have no terminal in common");

    *sts = VC_RTC_ERROR;
  }

  _put_response( resp = *sts);

  quit:
  return OM_S_SUCCESS;
}

method VCPPProcess ( int * sts )
{
  IGRint     status;
  IGRlong    retmsg;

  status =
  om$send (msg = message VCTerm.VCTpass (&retmsg, &me->CabId1, &me->Cab1pos,
                                                  &me->CabId2, &me->Cab2pos),
      targetid = me->RefId.objid,
      targetos = me->RefId.osnum);

  return OM_S_SUCCESS;
}

method VCPPcleanup ( int * sts )
{
  IGRint      status;
  IGRlong     retmsg;

  /*   Dehighlight trace    */

  dp$erase_hilite (msg = &retmsg);

  status =
  om$send(  msg = message VDS_LOCATE.delete ( 0 ) ,
           mode = OM_e_wrt_message,
       targetid = my_id);

  return OM_S_SUCCESS;
}

end implementation VCCmdPP;

