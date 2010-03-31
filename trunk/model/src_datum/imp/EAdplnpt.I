class implementation EMAdatpln;

/*
  HISTORY

        Sudha   23-june-93      modified for BSprototype ansification
*/

#include <stdio.h>
#include "OMmacros.h"
#include "bserr.h"
#include "bscrossp.h"

from EMSparamgm import EMgetgeom;

method EMassoc_autodimparam (IGRlong *msg; 
                             IGRushort options;
                             IGRshort *mattyp; IGRmatrix mat;
                             GRobjid paramobj; 
                             struct IGRplane *dim_plane;
                             IGRdouble *dim_plane_xaxis;
                             struct EMSgeomdata *dim_geom;
                             IGRint *dim_type)
/* **********************************************************************
Description
 This method has been overriden to return the geometry of the parameter
 point.

 Upon exit the completion code will be one of the following:
 EMS_S_Success : everything OK.
 EMS_E_Fail: otherwise.

History
   06/03/92: Prasad : Creation
 ************************************************************************* */
{
 IGRlong status;
 IGRlong msg_loc;
 struct EMSgeomdata dim_data;
 struct GRmd_env md_env;
  
 *msg = MSSUCC;
 status = OM_S_SUCCESS;

 status = om$send (msg = message EMSparamgm.EMgetgeom(&msg_loc,
                         NULL, mattyp,mat,&dim_data),
                   targetid = paramobj,
                   targetos = OM_Gw_current_OS);
 EMerr_hndlr(!(1&status&msg_loc), *msg, EMS_E_Fail, wrapup);

 if (dim_plane_xaxis)
 {
  OM_BLOCK_MOVE(me->x_dir,dim_plane_xaxis,sizeof (IGRvector));
 }

 if (dim_plane)
 {
  BSrc rc;
  IGRboolean bsts;

  bsts = BScrossp(&rc,me->x_dir,me->y_dir,dim_plane->normal);

  OM_BLOCK_MOVE(me->origin,dim_plane->point,sizeof (IGRvector));
 } 

 if (dim_geom) *dim_geom = dim_data;

wrapup:
 return (status);
}
end implementation EMAdatpln;
