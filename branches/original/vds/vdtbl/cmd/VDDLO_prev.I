
/* $Id: VDDLO_prev.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDDLO_prev.I
 *
 * Description:
 *
 * Implementation file for table preview option
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDLO_prev.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
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
# Revision 1.6  1995/10/25  17:27:20  pinnacle
# Replaced: vdtbl/cmd/VDDLO_prev.I for:  by tlbriggs for vds.240
#
# Revision 1.5  1995/09/28  21:20:50  pinnacle
# Replaced: vdtbl/cmd/VDDLO_prev.I for:  by yzhu for vds.240
#
# Revision 1.4  1995/09/05  23:15:56  pinnacle
# Replaced: vdtbl/cmd/VDDLO_prev.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/06  16:05:40  pinnacle
# Replaced: vdtbl/cmd/VDDLO_prev.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  20:03:42  pinnacle
# Replaced: vdtbl/cmd/VDDLO_prev.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/05/08  20:34:46  pinnacle
# Replaced: vdtbl/cmd/VDDLO_prev.I by hverstee r#
#
# Revision 1.1  1995/04/13  14:07:56  pinnacle
# Created: vdtbl/cmd/VDDLO_prev.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/20/95          HV            New
 *      09/28/95          YZ            change preview window y and height
 *	10/25/95	  tlb		EMS 3.2: changed cs.h to grcoordsys.h
 * -------------------------------------------------------------------*/

class implementation VDCmdDLO;

#include <stdio.h>
#include <ctype.h>
#include <string.h>

#include "igewindef.h"
#include "igewinmacros.h"

#include "EMSmsgdef.h"
#include "exmacros.h"
#include "emsdef.h"
#include "EMSutlmacros.h"

#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grgsdef.h"
#include "grmessage.h"
#include "grgsmacros.h"
#include "grmacros.h"
#include "OMmacros.h"
#include "exdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"
#include "asmacros.h"

#include "exmacros.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "csmacros.h"

#include "vdsmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "msdef.h"
#include "msmacros.h"
#include "COBmacros.h"

#include "FI.h"
#include "AS_status.h"

#include "VDdrwlo.h"
#include "VDdrwlo_db.h"
#include "VDdrwlo_int.h"
#include "VDdrwlo_pr.h"
#include "VDdrwPrTb_pr.h"
#include "VDmem.h"

/*
#define MY_DEBUG
*/

from   GRwindow      import    DPupdate;
from   GRgraphics    import    GRdelete;


#ifdef OLD_PREVIEW
method   VDDLO_show         (IGRlong     * msg;
                             IGRchar     * form_ptr)
{
  IGRlong         retmsg;
  IGRint          status;

  IGRint          dis_type;
  IGRint          win_type;
  IGRint          xmin, ymin;
  IGRint          width,height;
  IGRint          screen;

  struct GRid     mGRid;

  *msg   = MSSUCC;
  status = OM_S_SUCCESS;

  /*    stub for show preview   */

/*     original preview

  dis_type = me->nCur_group;

  if (me->nCur_group == VD_DRWLO_EN_DATA)
    dis_type = VD_DRWLO_EN_ALL;

  win_type = BORDER;
  xmin     = 450;
  ymin     = 450;
  width    = 700;
  height   = 400;
  screen   = CURRENT_SCREEN;

  mGRid.objid = my_id;
  mGRid.osnum = OM_Gw_current_OS;

  status =
  VD_drwlo_preview( &retmsg, &me->WinGRid, mGRid, dis_type, win_type,
                    xmin, ymin, width, height, screen ,&me->OwnGRid);

*/

  return (OM_S_SUCCESS);
}


method   VDDLO_remove       (IGRlong     * msg;
                             IGRchar     * form_ptr)
{
  IGRlong         retmsg;
  IGRint          status;
  IGRint          size;
  struct GRmd_env MDenv;
  IGRboolean      bGRonly;

  *msg   = MSSUCC;
  status = OM_S_SUCCESS;
  bGRonly = FALSE;

  /*    remove preview   */

/*   old remove

  size   = sizeof (struct GRmd_env);
  gr$get_module_env (msg    = &retmsg,
                     sizbuf = &size,
                     buffer = &MDenv,
                     nret   = &size);

  status =
  om$send (msg = message GRgraphics.GRdelete (&retmsg, &MDenv),
      targetid = me->OwnGRid.objid,
      targetos = me->OwnGRid.osnum);

  status =
  om$send (msg = message Root.delete (0),
      targetid = me->WinGRid.objid,
      targetos = me->WinGRid.osnum);

  me->My_Preview_up = FALSE;
  me->OwnGRid.objid = NULL_OBJID;
  me->WinGRid.objid = NULL_OBJID;

*/

  return (OM_S_SUCCESS);
}
#endif

method   VDDLO_pvwin    (IGRlong  *msg)
{
  IGRint        status;
  IGRint        xloc, yloc;
  IGRint        width, height;
  IGRint        win_type;
  IGRint        screen;

  *msg     = MSSUCC;
  win_type = BORDER;
  xloc     =  5;
  yloc     = 548;
  width    = 950;
  height   = 330;
  screen   = CURRENT_SCREEN;

  status =
  VDcreate_window (me->My_OS, &me->WinGRid, win_type, &me->Gragad,
                   screen, xloc, yloc, width, height);

  me->My_Preview_up = TRUE;

#ifdef MY_DEBUG
  printf ("create prev window <%d %d>\n",me->WinGRid.objid, me->WinGRid.osnum);
#endif

  return (OM_S_SUCCESS);
}


method  VDDLO_pvdsp     (IGRlong   *msg;
                         IGRboolean bFit)

{
  IGRint        status;
  IGRlong       retmsg;
  IGRint        nbgraphId1;
  IGRint        dis_type;
  IGRint        Msize;

  struct GRid     *graphId1;
  struct GRid      Dloid;
  struct GRid      csId;
  struct GRmd_env  MDenv;

  *msg     = MSSUCC;
  dis_type = me->nCur_group;
  if (dis_type == VD_DRWLO_EN_DATA)
    dis_type = VD_DRWLO_EN_ALL;

#ifdef MY_DEBUG
  printf ("display preview, type %d\n",dis_type);
#endif

  graphId1 = NULL;
  nbgraphId1 = 0;
  Dloid.objid = my_id;
  Dloid.osnum = OM_Gw_current_OS;

  Msize   = sizeof (struct GRmd_env);
  gr$get_module_env (msg    = &retmsg,
                     sizbuf = &Msize,
                     buffer = &MDenv,
                     nret   = &Msize);

/*    this is klutzy, could be done faster.....  */

#ifdef MY_DEBUG
  printf ("gotenv , to VD_drwtb_CrtPreTbl\n");
#endif

  status =
  VD_drwtb_CrtPreTbl (&me->WinGRid, Dloid, dis_type, &me->OwnGRid,
                      &MDenv, &csId, &graphId1, &nbgraphId1);

/*    and why the coordinate system ??   */

#ifdef MY_DEBUG
  printf ("go delete coordinatesys\n");
#endif

  status =
  om$send (msg = message GRgraphics.GRdelete(&retmsg, &MDenv),
      senderid = NULL_OBJID,
      targetos = csId.osnum,
      targetid = csId.objid);
  as$status();

  if (bFit && (nbgraphId1 > 0))      /* Fit window (optional) */
  {
#ifdef MY_DEBUG
    printf ("go fit, owngrid <%d %d>\n",me->OwnGRid.objid,me->OwnGRid.osnum);
#endif

    status =
    vd$vw_fit_object (object    = &me->OwnGRid,
                      factor    = 1.0 ,
                      md_env    = &MDenv ,
                      ggid      = &me->Gragad,
                      num_ggid  = 1 );
    as$status();
  }

  _FREE( graphId1);

#ifdef MY_DEBUG
  printf ("display preview  <%d %d>\n",me->OwnGRid.objid, me->OwnGRid.osnum);
#endif

  return (OM_S_SUCCESS);
}

method   VDDLO_pvdel     (IGRlong    *msg;
                          IGRboolean  bGRonly)
{
  IGRint        status;
  IGRlong       retmsg;

  *msg = MSSUCC;

#ifdef MY_DEBUG
  printf ("delete preview  <%d %d>\n",me->OwnGRid.objid, me->OwnGRid.osnum);
#endif

  if (me->OwnGRid.objid != NULL_OBJID)
  {
    IGRint          Msize;
    struct GRmd_env MDenv;

    gr$get_module_env (msg    = &retmsg,
                       sizbuf = &Msize,
                       buffer = &MDenv,
                       nret   = &Msize);
    status =
    om$send (msg = message GRgraphics.GRdelete (&retmsg, &MDenv),
        targetid = me->OwnGRid.objid,
        targetos = me->OwnGRid.osnum);

    status =
    dp$gen_update (msg       = &retmsg,
                   objid     = me->Gragad.objid,
                   osnum     = me->Gragad.osnum);

  }

#ifdef MY_DEBUG
  printf ("delete preview  owner done\n");
#endif

  me->OwnGRid.objid = NULL_OBJID;

  if (!(bGRonly))
  {
#ifdef MY_DEBUG
    printf ("delete preview window  <%d %d>\n",me->WinGRid.objid,
                                               me->WinGRid.osnum);
#endif

    if ((!(bGRonly)) && (me->WinGRid.objid != NULL_OBJID))
    {
      status =
      om$send (msg = message Root.delete (0),
          senderid = NULL_OBJID,
          targetid = me->WinGRid.objid,
          targetos = me->WinGRid.osnum);

      me->My_Preview_up = FALSE;
      me->WinGRid.objid = NULL_OBJID;
    }
  }

  return (OM_S_SUCCESS);
}

end implementation VDCmdDLO;
