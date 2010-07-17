
/* $Id: VCCmdSCi.I,v 1.1.1.1 2001/01/04 21:12:31 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCCmdSCi.I
 *
 * Description:
 *      Command object for set equipment connectible
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdSCi.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.4  1997/05/19  19:52:24  pinnacle
# Replaced: vccmdutil/VCCmdSCi.I for:  by hverstee for cabling
#
# Revision 1.3  1997/05/07  16:17:30  pinnacle
# Replaced: vccmdutil/VCCmdSCi.I for:  by hverstee for cabling
#
# Revision 1.2  1997/03/12  22:27:04  pinnacle
# Replaced: vccmdutil/VCCmdSCi.I for:  by hverstee for cabling
#
# Revision 1.1  1997/01/23  23:58:28  pinnacle
# Created: vccmdutil/VCCmdSCi.I by hverstee for cabling
#
 *
 * History:
 *        01/20/97        hv        Initial
 *
 *************************************************************************/

class implementation VCCmdSC;

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
#include "asbox.h"
#include "AS_status.h"
#include "ACrg_collect.h"
#include "acrepdef.h"
#include "acrepmacros.h"

#include "VCdefine.h"
#include "VCstructs.h"
#include "VCproto.h"
#include "VCCmdDef.h"


#define MY_DEBUG 


extern GRclassid        OPP_VCTerm_class_id;



method init ( int type ; char * str_ptr )
{
  int		  status;

  /*A initialize superclass */

  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VDS_LOCATE.init( type, str_ptr),
                    targetid = my_id);
  as$status( action = RET_STATUS );

  me->MyType = type;

  me->RefId.objid  = NULL_OBJID;
  me->RefId.osnum  = me->ModuleInfo.md_id.osnum;

  return OM_S_SUCCESS;
}

method VCSCgetref ( int * sts )
{
  IGRint     status;

  status = OM_S_SUCCESS;

  me->RefId = me->event1.located_object[0].located_obj;

  *sts = VC_RTC_ALLOK;
  _put_response( resp = *sts);

  quit:
  return OM_S_SUCCESS;
}

method VCSCprocess ( int * sts )
{
  IGRint     status;
  IGRlong    retmsg;
  IGRint     ict;

  ict        = 0;

#ifdef MY_DEBUG
  printf (" PROCESS\n");
#endif

  status =
  VC_termexpand (&retmsg, &ict, &me->RefId, &me->ModuleInfo);

  if (ict > 0)
    printf ("%d terminals externalized\n",ict);

  return OM_S_SUCCESS;
}

method VCSCcleanup ( int * sts )
{
  IGRint      status;
  IGRlong     retmsg;

  /*   Dehighlight  */

  dp$erase_hilite (msg = &retmsg);

  status =
  om$send(  msg = message VDS_LOCATE.delete ( 0 ) ,
           mode = OM_e_wrt_message,
       targetid = my_id);

  return OM_S_SUCCESS;
}

end implementation VCCmdSC;

