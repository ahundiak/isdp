/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsolid;

#include "EMS.h"
#include "EMSconstruct.h" /* for EMS_S_ONSOLID ...  */
#define INC_FACTOR 0.01

method EMorient_yourself (IGRlong *EMmsg;
                          IGRushort options;
                          struct GRmd_env *env)

/* ***********************************************************************

Description
   This method checks to see if the normals of a solid are oriented
   correctly. Currently, it is assuming that all the normals either
   consistently point outside the solid or into the solid. Should
   the normals be pointing outside the solid they are reversed to point
   inside. 

   Input
     env - module environment of the solid
     options - Currently, should be set to NULL

   Output
     EMmsg: Completions status

Notes
   Upon exit the completion code will be one of the following:
    EMS_S_Success : if successful
    EMS_E_Fail : if there is failure
    EMS_E_InvalidCase : if the solid normals could not be oriented 


History
   12/16/87      : PP : Creation
   07/18/92      : AMD : Added 'surf_range' to remove ANSI compilation
                         error.

*************************************************************************** */

{
 IGRlong status;
 IGRshort i,attempts;
 GRrange  surf_range;
 IGRpoint range[2], new_range[2];
 IGRboolean world = TRUE,oriented;
 IGRulong location;
 
 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 status = om$send (msg = message GRvg.GRgetrang (EMmsg, 
                       &env->md_env.matrix_type, env->md_env.matrix, &world,
                       surf_range),
                   targetid = my_id,
                   targetos = OM_Gw_current_OS);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);

/*
 * Increase the range box to make sure the minimum and maximum points are
 * lying outside the solid
 */

 for (i=0;i<3;i++)
 {
  range[0][i] = surf_range[i];
  range[1][i] = surf_range[3+i];
 }

 for (i=0;i<3;i++)
  new_range[0][i] = range[0][i] - INC_FACTOR * (range[1][i] - range[0][i]);

 for (i=0;i<3;i++)
  new_range[1][i] = range[1][i] + INC_FACTOR *(range[1][i] - range[0][i]);

attempts = 0;
oriented = FALSE;

while (!oriented && (attempts < 2))
{
 status = om$send (msg = message EMSsolid.EMpoint_locate(EMmsg,
                         env, NULL, &new_range[attempts][0], range,
                         &location),
                   targetid = my_id);
 EMerr_hndlr (!status, *EMmsg, EMS_E_Fail, wrapup);

 if (location != EMS_S_UNKNOWN)
  oriented = TRUE;

 ++attempts; 
}
                   
if (location == EMS_S_UNKNOWN)
{
 *EMmsg = EMS_E_InvalidCase;
 goto wrapup;
}

if (location == EMS_S_INSOLID)
{
 status = om$send (msg = message EMSsurface.EMrevorient (EMmsg),
                   targetid = my_id);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
}

wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSsolid:EMorient_yourself error");
 return (status);

}

end implementation EMSsolid;
