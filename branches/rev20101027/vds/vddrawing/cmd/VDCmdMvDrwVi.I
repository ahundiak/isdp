
/* $Id: VDCmdMvDrwVi.I,v 1.1.1.1 2001/01/04 21:08:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vddrawing/cmd /VDCmdMvDrwVi.I
 *
 * Description:
 *      This file contains the implementation for the Move Drawing View
 *      commands.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdMvDrwVi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:41  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/03/19  20:21:02  pinnacle
# Replaced: vddrawing/cmd/VDCmdMvDrwVi.I for:  by yzhu for vds
#
# Revision 1.2  1997/12/09  21:47:58  pinnacle
# Replaced: vddrawing/cmd/VDCmdMvDrwVi.I for:  by impd for vds
#
# Revision 1.1  1997/08/29  15:48:04  pinnacle
# Created: vddrawing/cmd/VDCmdMvDrwVi.I by yzhu for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      08/28/97        YZHU            Create
 * -------------------------------------------------------------------*/



class implementation VDCmdMvDrwV;



#include "stdio.h"
#include "msdef.h"
#include "lc.h"
#include "dpmacros.h"
#include "comndef.h"
#include "comn.h"
#include "comnindex.h"
#include "comnmacros.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "grmessage.h"
#include "v_dbgmacros.h"

extern IGRboolean      VDS_K_RecomputeDrawingM;


method VDsetDrwRecomputeOff ()
{
  int		  status = OM_S_SUCCESS;
  SetProc( VDsetDrwRecomputeOff ); Begin
  me->ret = MSSUCC;
  VDS_K_RecomputeDrawingM = 1; 
  __DBGpr_int (" VDS_K_RecomputeDrawingM ", VDS_K_RecomputeDrawingM);
  End
quit:
  return OM_S_SUCCESS;
}

method VDsetDrwRecomputeOn ()
{
  int             status = OM_S_SUCCESS;
  SetProc( VDsetDrwRecomputeOff ); Begin
  me->ret = MSSUCC;
  VDS_K_RecomputeDrawingM = 0;
  __DBGpr_int (" VDS_K_RecomputeDrawingM ", VDS_K_RecomputeDrawingM);

  End
quit:
  return OM_S_SUCCESS;
}

end implementation VDCmdMvDrwV;
