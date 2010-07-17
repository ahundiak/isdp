
/* $Id: VCCmdVXi.I,v 1.1.1.1 2001/01/04 21:12:31 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCCmdVXi.I
 *
 * Description:
 *      Command object for insert/move/delete cable vertex
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdVXi.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *        Initial import to CVS
 *
# Revision 1.2  2000/03/15  21:56:30  pinnacle
# Replaced: vccmdutil/VCCmdVXi.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.8  1997/07/26  14:00:42  pinnacle
# Replaced: vccmdutil/VCCmdVXi.I for:  by hverstee for cabling
#
# Revision 1.7  1997/07/22  15:24:24  pinnacle
# Replaced: vccmdutil/VCCmdVXi.I for:  by hverstee for cabling
#
# Revision 1.6  1997/05/19  19:52:36  pinnacle
# Replaced: vccmdutil/VCCmdVXi.I for:  by hverstee for cabling
#
# Revision 1.5  1997/05/12  17:06:24  pinnacle
# Replaced: vccmdutil/VCCmdVXi.I for:  by hverstee for cabling
#
# Revision 1.4  1997/05/07  16:18:40  pinnacle
# Replaced: vccmdutil/VCCmdVXi.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/12  22:27:20  pinnacle
# Replaced: vccmdutil/VCCmdVXi.I for:  by hverstee for cabling
#
# Revision 1.2  1996/12/16  17:39:26  pinnacle
# Replaced: vccmdutil/VCCmdVXi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:03:30  pinnacle
# Created: vccmdutil/VCCmdVXi.I by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *   03/15/00   law   Adding move vertex for guides
 *
 *************************************************************************/

class implementation VCCmdVX;

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
#include "grmacros.h"

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
#include "bsdistptpt.h"

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
#include "VCsys.h"

/*
#define MY_DEBUG 
*/

from  IGEgragad import DPinrot;
/* for cr179901086 add calls to possible methods to move guide vertexes */
from  VCCable   import VCCbModify;
from  VCCable   import VCCbInsBrk;
from  VCCable   import VCCbFind;
from  VCGuide   import VCGdModify;
from  VCGuide   import VCGdFind;



method init ( int type ; char * str_ptr )
{
  int		  status;

  /*A initialize superclass */

  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VDS_LOCATE.init( type, str_ptr),
                    targetid = my_id);
  as$status( action = RET_STATUS );

#ifdef MY_DEBUG
  printf (" cable mod init %d\n",type);
#endif

  me->MyType = type;
  switch (me->MyType)
  {
    case 0:     me->SendType  = VCCB_INS_VERTEX;
                break;
    case 1:     me->SendType  = VCCB_MOV_VERTEX;
                break;
    case 2:     me->SendType  = VCCB_DEL_VERTEX;
                break;
    case 3:     me->SendType  = VCCB_ORT_VERTEX;
                break;
    case 4:     me->SendType  = VCCB_MOV_SEGMENT;
                break;
    case 5:     me->SendType  = VCCB_INS_VERTEX;
                break;
    default:    me->SendType = -1;
                break;
  }

  me->RefId.objid = NULL_OBJID;
  me->RefId.osnum = me->ModuleInfo.md_id.osnum;
  me->SectNo      = -1;
  me->VtxNo       = -1;

  return OM_S_SUCCESS;
}

method VCGdProcess ( long * sts )
{
/*cr179901086  may not be needed */
  quit:
  return OM_S_SUCCESS;
}
method VCGetItem ( long * sts )
{
  int		  status;

  IGRlong      retmsg;
  IGRdouble    d3pt[3];
  IGRint       i;
  IGRint       EP;
  IGRint       IXloc;
  IGRmatrix    win_matrix;
  IGRint gdskip;

#ifdef MY_DEBUG
  printf (" getitem\n");
#endif

  IXloc = -1;
  gdskip = 0;

  status =
  om$send (msg = message IGEgragad.DPinrot( &retmsg, win_matrix ),
      senderid = NULL_OBJID,
      targetid = me->event1.event.button.objid,
      targetos = me->event1.event.button.osnum);
  as$status();

  for (i=0; i<3; i++)
    if ((win_matrix[i+8] > 0.99) ||
        (win_matrix[i+8] < -0.99))    IXloc = i;

  me->IX = -1;

  d3pt[0] = me->event1.event.button.x;
  d3pt[1] = me->event1.event.button.y;
  d3pt[2] = me->event1.event.button.z;

  me->RefId = me->event1.located_object[0].located_obj;
  me->MdEnv = me->event1.located_object[0].module_info;
  if(gdskip) /* CR179901086 */
  {
    IGRchar *fndattr;
  status =
  om$send (msg = message VCGuide.VCGdFind
                          (&retmsg, me->SendType, &me->AdjType,
                           &me->SectNo, &me->VtxNo, d3pt,
                           IXloc, me->dDyn, &EP, &me->MdEnv, fndattr),
      targetid = me->RefId.objid,
      targetos = me->RefId.osnum);
  as$status();

  }

  status =
  om$send (msg = message VCCable.VCCbFind
                          (&retmsg, me->SendType, &me->AdjType,
                           &me->SectNo, &me->VtxNo, d3pt,
                           IXloc, me->dDyn, &EP, &me->MdEnv),
      targetid = me->RefId.objid,
      targetos = me->RefId.osnum);
  as$status();

  status =
  dp$erase_hilite (msg = &retmsg);

  if ((me->SendType == VCCB_INS_VERTEX) ||
      (me->SendType == VCCB_MOV_VERTEX))
  {
    status =
    om$send (msg = message VCCmdVX.VCVXcorners (&me->dDyn[0], &me->dDyn[6]),
        targetid = my_id);
  }
  else
    me->Detent.NumCorners = -1;

  if (!(VCSYSGLB_preserve)) goto quit;

#ifdef MY_DEBUG
  printf (" get preservation coordinate\n");
#endif

  if (me->SendType == VCCB_MOV_VERTEX)
  {   /*  find ortho plane that contains all three vertices   */
    for (i=0; i<3; i++)
    {
#ifdef MY_DEBUG
  printf (" for move... %d %f %f %f\n",i,me->dDyn[i],me->dDyn[i+3],
            me->dDyn[i+6]);
#endif
      if ((me->dDyn[i] == me->dDyn[i+3]) && (me->dDyn[i] == me->dDyn[i+6]))
      {
         me->IX = i;
      }
    }

    if (me->IX < 0) me->IX = IXloc;
  }
  else
  if (me->SendType == VCCB_INS_VERTEX)
  {   /*  find plane from window definition   */
    me->IX = IXloc;
  }

#ifdef MY_DEBUG
  printf (" preserve %d\n",me->IX);
#endif

  quit:
  return OM_S_SUCCESS;
}

method VCProcess ( long * sts )
{
  int		  status;

  IGRlong      retmsg;
  IGRdouble    dpt[3];
  IGRdouble    d3pt[3];
  IGRint gdskip;

  gdskip = 0;
 
  dpt[0] = me->event1.event.button.x;
  dpt[1] = me->event1.event.button.y;
  dpt[2] = me->event1.event.button.z;

  status = VC_detent (dpt, &me->Detent, d3pt);

  if (VCSYSGLB_preserve)
  {
#ifdef MY_DEBUG
    printf (" preserve %d coordinate\n",me->IX);
#endif
    d3pt[me->IX] = me->dDyn[me->IX+3];
  }

#ifdef MY_DEBUG
  printf (" process %f %f %f\n",d3pt[0],d3pt[1],d3pt[2]);
#endif

  status =
  gr$display_object( object_id = &me->RefId,
                     mode      = GRbe);
  if(gdskip) /* cr179901086 */
  {
  if (me->MyType == 5)
  {
    printf("No breaks available for Guides\n");
  }
  else
  {
    IGRchar *modattr;
    status =
    om$send (msg = message VCGuide.VCGdModify
                          (&retmsg, me->SendType, me->AdjType, me->SectNo,
                            me->VtxNo, d3pt, &me->MdEnv, modattr),
        targetid = me->RefId.objid,
        targetos = me->RefId.osnum);
  }

  }
  if (me->MyType == 5)
  {
    status = 
    om$send (msg = message VCCable.VCCbInsBrk
                          (&retmsg, me->SectNo, me->VtxNo, d3pt, &me->MdEnv),
        targetid = me->RefId.objid,
        targetos = me->RefId.osnum);
  }
  else
  {
    status = 
    om$send (msg = message VCCable.VCCbModify
                          (&retmsg, me->SendType, me->AdjType, me->SectNo,
                            me->VtxNo, d3pt, &me->MdEnv),
        targetid = me->RefId.objid,
        targetos = me->RefId.osnum);
  }

  /*   set up for next   */
  me->RefId.objid = NULL_OBJID;
  me->RefId.osnum = me->ModuleInfo.md_id.osnum;
  me->SectNo      = -1;
  me->VtxNo       = -1;

  return OM_S_SUCCESS;
}

method dynamics ( int dynamics ; int * sts )
{
  int		  status;

  struct  VCmlmoddyn_info  info;
  struct  IGRpolyline      line;
  struct  IGRdisplay       loc_dis;
  IGRdouble                d9points[9];
  IGRint                   i;

  extern IGRint VCmlmoddyn();

#ifdef MY_DEBUG
  printf (" dynamics %d\n",dynamics);
#endif

  if (dynamics == VC_MLDYN_MVTX)
  {
#ifdef MY_DEBUG
    printf (" dynamics VTX\n");
#endif

    loc_dis = me->ActiveDisplay;
    loc_dis.weight = 1;
    loc_dis.style  = 0;
    loc_dis.color  = 6;

    info.dynamics = dynamics;

    info.Detent    = me->Detent;

    if (VCSYSGLB_preserve)
    {
      info.dy_index = me->IX;
      info.dy_value = me->dDyn[me->IX];
    }
    else
    {
      info.dy_index = -1;
    }

    for (i=0; i<9; i++)
      d9points[i] = me->dDyn[i];

    line.num_points = 3;
    line.points     = d9points;

    /*A Build buffers */

#ifdef MY_DEBUG
    printf (" ML dynamics setup,dy_index,dy_value %d %f\n",info.dy_index,
                                                     info.dy_value);
#endif

    status =
    dp$build_dis_buffer(buffer      = &info.dpele_buff,
                        type        = IGRPY,
                        geometry    = &line,
                        display_att = &loc_dis);

    status =
    dp$dynamics(dyn_fun     = VCmlmoddyn,
                information = &info);
  }
  else
  {
    status = om$send(msg = message CEO.dynamics( dynamics, sts ),
                    mode = OM_e_wrt_message,
                targetid = my_id );
    as$status();
  }

  return OM_S_SUCCESS;
}

method  VCVXcorners (IGRdouble    *pT1;
                     IGRdouble    *pT2)
{
  IGRint    i;
  BSrc      rc;

  for (i=0; i<18; i++)
    me->Detent.dCorners[i] = 0.0;

  me->Detent.nDigit = VC_digit (pT1, pT2);

  switch (me->Detent.nDigit)
  {
    case 1:
    case 2:
    case 3:
      me->Detent.NumCorners = 0;

      me->Detent.dCorners[0] = pT1[0];
      me->Detent.dCorners[1] = pT1[1];
      me->Detent.dCorners[2] = pT1[2];

      me->Detent.dCorners[3] = pT2[0];
      me->Detent.dCorners[4] = pT2[1];
      me->Detent.dCorners[5] = pT2[2];

      me->Detent.dDist =  BSdistptpt(&rc, pT1, pT2) / 10.0;
      break;

    case 4:     /*    xy, two corners   */
      me->Detent.NumCorners = 2;

      me->Detent.dCorners[0] = pT2[0];
      me->Detent.dCorners[1] = pT1[1];
      me->Detent.dCorners[2] = pT1[2];

      me->Detent.dCorners[3] = pT1[0];
      me->Detent.dCorners[4] = pT2[1];
      me->Detent.dCorners[5] = pT2[2];

      me->Detent.dDist =  BSdistptpt(&rc, pT1, pT2) / 10.0;
      break;

    case 5:     /*    xz, two corners   */
      me->Detent.NumCorners = 2;

      me->Detent.dCorners[0] = pT2[0];
      me->Detent.dCorners[1] = pT1[1];
      me->Detent.dCorners[2] = pT1[2];

      me->Detent.dCorners[3] = pT1[0];
      me->Detent.dCorners[4] = pT2[1];
      me->Detent.dCorners[5] = pT2[2];

      me->Detent.dDist =  BSdistptpt(&rc, pT1, pT2) / 10.0;
      break;

    case 6:     /*    yz, two corners   */
      me->Detent.NumCorners = 2;

      me->Detent.dCorners[0] = pT1[0];
      me->Detent.dCorners[1] = pT2[1];
      me->Detent.dCorners[2] = pT1[2];

      me->Detent.dCorners[3] = pT2[0];
      me->Detent.dCorners[4] = pT1[1];
      me->Detent.dCorners[5] = pT2[2];

      me->Detent.dDist =  BSdistptpt(&rc, pT1, pT2) / 10.0;
      break;

    case 7:
    case 8:     /*   xyz, six corners    */
      me->Detent.NumCorners = 6;

      me->Detent.dCorners[0] = pT2[0];
      me->Detent.dCorners[1] = pT1[1];
      me->Detent.dCorners[2] = pT1[2];

      me->Detent.dCorners[3] = pT1[0];
      me->Detent.dCorners[4] = pT2[1];
      me->Detent.dCorners[5] = pT2[2];

      me->Detent.dCorners[6] = pT1[0];
      me->Detent.dCorners[7] = pT2[1];
      me->Detent.dCorners[8] = pT1[2];

      me->Detent.dCorners[9]  = pT2[0];
      me->Detent.dCorners[10] = pT1[1];
      me->Detent.dCorners[11] = pT2[2];

      me->Detent.dCorners[12] = pT1[0];
      me->Detent.dCorners[13] = pT1[1];
      me->Detent.dCorners[14] = pT2[2];

      me->Detent.dCorners[15] = pT2[0];
      me->Detent.dCorners[16] = pT2[1];
      me->Detent.dCorners[17] = pT1[2];

      me->Detent.dDist =  BSdistptpt(&rc, pT1, pT2) / 10.0;
      break;

    default:
      me->Detent.NumCorners = -1;
      break;
  }

#ifdef MY_DEBUG
  printf ("setup detent %d %d\n",me->Detent.nDigit, me->Detent.NumCorners);
#endif

  return (OM_S_SUCCESS);
}


end implementation VCCmdVX;

