/*

Name
  ECvg_report_conflict

Abstract
  Routine to display error status and conflicting constraints.
  
Synopsis

Description
  This routine is called from all the other constraint placement command
  objects which need to report conflicting constraints and other solution
  error codes.
  
Return Value

Notes
  ECparam_report_conflict routine is similar to ECvg_report_conflict.  The
  difference is in the conflicting constraints objects or GRids.  Also in
  case of vg, the conflicting array is deallocated by the routine.
  
Index

Keywords

History
  06/08/93 : Rajiv Agrawal : created
  09/01/93 : Rajiv Agrawal : Call split profile after constraint deletion.
  12/09/93 : G M K         : EMS_S_DegenerateGeometry message display
 */
class implementation EC1elecnstr;

#include "msmacros.h"
#include "ECmsg.h"

from GRgraphics   import GRdisplay, GRdelete;
from SKconstraint import SKgetmgr;

ECvg_report_conflict(msg, msg_code, env, cnstr_grid, num_conflict_cnstr, conflict_cnstr_objs)
long 		*msg;
long 		msg_code;
struct GRmd_env	*env;
struct GRid 	cnstr_grid;
int		num_conflict_cnstr;
GRobjid		*conflict_cnstr_objs;
{
  int 		i;
  long 		stat_OM, msg_loc;
  enum GRdpmode dpmode;
  struct GRid   mgr;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  /*
   * Highlight the conflicting constraints.
   */
  dpmode = GRhd;
  for (i=0; i<num_conflict_cnstr; i++)
  {
    stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                             &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
                             &env->md_id), 
                       targetid = conflict_cnstr_objs[i], 
                       targetos = cnstr_grid.osnum,
                       senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
  }

  if (conflict_cnstr_objs)
    om$dealloc (ptr = conflict_cnstr_objs);

  /*
   * Erase and delete the constraint.
   */
  dpmode = GRbehe;
  stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                           &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
                           &env->md_id), 
                     targetid = cnstr_grid.objid, 
                     targetos = cnstr_grid.osnum,
                     senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

  mgr.osnum = cnstr_grid.osnum;
  stat_OM = om$send (msg = message SKconstraint.SKgetmgr ( &msg_loc, &mgr.objid ), 
                     targetid = cnstr_grid.objid, 
                     targetos = cnstr_grid.osnum,
                     senderid = NULL_OBJID);

  stat_OM = om$send (msg = message GRgraphics.GRdelete (&msg_loc, env),
                     targetid = cnstr_grid.objid, 
                     targetos = cnstr_grid.osnum,
                     senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

  /*
   * Check if the profile split due to the above constraint deletion.
   */
  SKsplit_profile ( &msg_loc, &mgr );

  /*
   * Give out the correct status message.
   */
  if (msg_code == EMS_I_NoSolution)
  {
    ex$message (msgnumb = EMS_S_SolutionNotFound)
  }
  else if (msg_code == EMS_I_Cycle)
  {
    ex$message (msgnumb = EMS_S_CyclicDependency)
  }
  else if (msg_code == EMS_I_NoStackMemory)
  {
    ex$message ( msgnumb = EMS_S_InsufficientMemory)
  }
  else if (msg_code == EMS_I_Degenerate)
  {
    ex$message (msgnumb = EMS_S_DegenerateGeometry);
  }
  else 
  {
    ex$message (msgnumb = EMS_S_ConflictingConstraints)
  }

ret_end:
  return stat_OM;
}

ECparam_report_conflict(msg, msg_code, env, cnstr_grid, num_conflict_cnstr, conflict_cnstrid)
long 		*msg;
long 		msg_code;
struct GRmd_env	*env;
struct GRid 	cnstr_grid;
int		num_conflict_cnstr;
struct GRid	*conflict_cnstrid;
{
  int 		i;
  long 		stat_OM, msg_loc;
  enum GRdpmode dpmode;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (msg_code == EMS_I_NoSolution)
  {
    ex$message (msgnumb = EMS_S_SolutionNotFound);
  }
  else if (msg_code == EMS_I_Cycle)
  {
    ex$message (msgnumb = EMS_S_CyclicDependency);
  }
  else if (msg_code == EMS_I_Degenerate)
  {
    ex$message (msgnumb = EMS_S_DegenerateGeometry);
  }
  else
  {
    ex$message (msgnumb = EMS_S_ConflictingConstraints);
  }

  dpmode = GRhd;
  for (i=0; i<num_conflict_cnstr; i++)
    if (conflict_cnstrid[i].objid != cnstr_grid.objid ||
        conflict_cnstrid[i].osnum != cnstr_grid.osnum)
    {
      stat_OM = om$send (msg = message GRgraphics.GRdisplay ( &msg_loc,
                               &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
                               &env->md_id), 
                         targetid = conflict_cnstrid[i].objid,
                         targetos = conflict_cnstrid[i].osnum,
                         senderid = NULL_OBJID);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
    }

  dpmode = GRbehe;
  om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                 &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
                 &env->md_id), 
           targetid = cnstr_grid.objid,
           targetos = cnstr_grid.osnum,
           senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

  stat_OM = om$send (msg = message GRgraphics.GRdelete (&msg_loc, env), 
                     targetid = cnstr_grid.objid,
                     targetos = cnstr_grid.osnum,
                     senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

ret_end:
  return stat_OM;
}

end implementation EC1elecnstr;
