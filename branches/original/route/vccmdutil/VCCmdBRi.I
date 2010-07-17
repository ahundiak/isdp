
/* $Id: VCCmdBRi.I,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCCmdBRi.I
 *
 * Description:
 *      Command object for modify bend radius
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdBRi.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.5  1997/07/22  15:23:32  pinnacle
# Replaced: vccmdutil/VCCmdBRi.I for:  by hverstee for cabling
#
# Revision 1.4  1997/05/07  16:18:24  pinnacle
# Replaced: vccmdutil/VCCmdBRi.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/12  22:26:48  pinnacle
# Replaced: vccmdutil/VCCmdBRi.I for:  by hverstee for cabling
#
# Revision 1.2  1996/11/26  16:53:16  pinnacle
# Replaced: vccmdutil/VCCmdBRi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/11/12  17:20:40  pinnacle
# Created: vccmdutil/VCCmdBRi.I by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *
 *************************************************************************/

class implementation VCCmdBR;

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

#include "bsvalues.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"

#include "asmacros.h"
#include "AS_status.h"
#include "ACrg_collect.h"
#include "acrepdef.h"
#include "acrepmacros.h"

#include "parametric.h"

#include "VCdefine.h"
#include "VCstructs.h"
#include "VCCmdDef.h"
#include "VCparameters.h"
#include "VCproto.h"

/*
#define MY_DEBUG 
*/

from  IGEgragad import DPinrot;

from  VCCable   import VCCbBendrPut;
from  VCCable   import VCCbBendrClr;
from  VCCable   import VCCbFind;



method init ( int type ; char * str_ptr )
{
  int		  status;

  /*A initialize superclass */

  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VDS_LOCATE.init( type, str_ptr),
                    targetid = my_id);
  as$status( action = RET_STATUS );

  me->MyType = type;

  me->RefId.objid = NULL_OBJID;
  me->RefId.osnum = me->ModuleInfo.md_id.osnum;

  me->SectNo      = -1;
  me->VtxNo       = -1;

  me->dBrad       = 0.0;

  return OM_S_SUCCESS;
}

method VCBget ( long * sts )
{
  me->dBrad       = me->event1.event.value;;

  return OM_S_SUCCESS;
}

method VCBclr ( long * sts )
{
  int          status;
  IGRlong      retmsg;

  me->RefId = me->event1.located_object[0].located_obj;

  /*   clear bendrad table   */

  status =
  om$send (msg = message VCCable.VCCbBendrClr (&retmsg),
      targetid = me->RefId.objid,
      targetos = me->RefId.osnum);
  as$status();

  return OM_S_SUCCESS;
}


method VCBset ( long * sts )
{
  int          status;
  IGRlong      retmsg;
  IGRdouble    d3pt[3];
  IGRdouble    dDyn[9];
  IGRint       EP;
  IGRint       Adj;
  IGRint       i;
  IGRint       IXloc;
  IGRmatrix    win_matrix;

  IXloc = -1;

  status =
  om$send (msg = message IGEgragad.DPinrot( &retmsg, win_matrix ),
      senderid = NULL_OBJID,
      targetid = me->event1.event.button.objid,
      targetos = me->event1.event.button.osnum);
  as$status();

  for (i=0; i<3; i++)
    if ((win_matrix[i+8] > 0.99) ||
        (win_matrix[i+8] < -0.99))    IXloc = i;

  d3pt[0] = me->event1.event.button.x;
  d3pt[1] = me->event1.event.button.y;
  d3pt[2] = me->event1.event.button.z;

  me->RefId = me->event1.located_object[0].located_obj;
  me->MdEnv = me->event1.located_object[0].module_info;

  /*  find section/vertex   */
  status =
  om$send (msg = message VCCable.VCCbFind
                      (&retmsg, VCCB_MOV_VERTEX, &Adj, &me->SectNo, &me->VtxNo,
                       d3pt, IXloc, dDyn, &EP, &me->MdEnv),
      targetid = me->RefId.objid,
      targetos = me->RefId.osnum);
  as$status();

#ifdef MY_DEBUG
  printf (" set brad %d %d to %f\n",me->VtxNo, me->SectNo, me->dBrad);
#endif

  /*   set new bendrad         */

  status = 
  om$send (msg = message VCCable.VCCbBendrPut
                           (&retmsg, me->VtxNo, me->SectNo, me->dBrad),
      targetid = me->RefId.objid,
      targetos = me->RefId.osnum);
  as$status();

  if (retmsg == MSFAIL)
    UI_status ("Bend radius too small");

  return OM_S_SUCCESS;
}

end implementation VCCmdBR;
