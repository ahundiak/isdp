/*

Name
  SKcalculate_profile

Abstract
  Update the profile by recomputing it.  
  
Synopsis

Description
  Update a profile by sending it a SKcompute message.  If any errors result,
  restore the profile to its original shape.  Display any conflicts if they
  exist.
  
Return Value

Notes
  
Index

Keywords

History
  09/15/93 : Rajiv Agrawal : created

 */
class implementation SKmgr;

#include "OMmacros.h"
#include "EMSopt.h"
#include "msmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ECmsg.h"

#define BLOCK_SIZE	5

from SKconstraint import SKgetmajconstrs, SKgetprops;

int SKcalculate_profile (long *msg, IGRushort opts, struct GRmd_env *md_env,
                         struct GRid *mgrid)
{
  IGRboolean            update_error = FALSE;
  int                   i, stat_OM;
  long                  solve_msg, msg_loc;
  int                   num_maj_cnstr;
  struct SKsolvevars    *oversolved_vars, *varlist;
  struct SKsolvevars    *nosolution_vars;
  GRobjid               *maj_cnstr, maj_cnstr_mem[BLOCK_SIZE], degenid;
  enum GRdpmode         dpmode;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
    
  stat_OM = om$send (msg = message SKmgr.SKcompute (&solve_msg, opts,
                           md_env, &nosolution_vars, NULL, &oversolved_vars, &degenid),
                     targetid = mgrid->objid, 
                     targetos = mgrid->osnum,
                     senderid = NULL_OBJID);

  if (solve_msg == EMS_I_NoSolution ||
      solve_msg == EMS_I_Redundant || 
      solve_msg == EMS_I_Conflicting ||
      solve_msg == EMS_I_NoStackMemory || 
      solve_msg == EMS_I_Degenerate )
  {
    /*
     * If no solution can be found or some conflicts are detected, 
     * put back the old values of the expressions that were driving this sketch.
     */
    stat_OM = om$send (msg = message SKmgr.SKundo_dimval (&msg_loc, SK_UPDATE_NOSAVESTATE),
                       targetid = mgrid->objid, 
                       targetos = mgrid->osnum,
                       senderid = NULL_OBJID);

    stat_OM = om$send (msg = message SKmgr.SKmgrprops (&msg_loc, EMS_O_OFF,
                             SK_MGR_OUTOFDATE, NULL),
                       targetid = mgrid->objid, targetos = mgrid->osnum,
                       senderid = NULL_OBJID);

    varlist = NULL;
    if (solve_msg == EMS_I_NoSolution)
    {
      ex$message ( msgnumb = EMS_S_SolutionNotFound);
      varlist = nosolution_vars;
    }
    else if (solve_msg == EMS_I_Redundant || solve_msg == EMS_I_Conflicting)
    {
      ex$message ( msgnumb = EMS_S_ConflictingConstraints);
      varlist = oversolved_vars;
    }
    else if (solve_msg == EMS_I_NoStackMemory)
    {
      ex$message ( msgnumb = EMS_S_InsufficientMemory);
    }
    else if (solve_msg == EMS_I_Degenerate)
    {
      ex$message ( msgnumb = EMS_S_DegenerateGeometry );
      dpmode = GRhd;
      stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                               &md_env->md_env.matrix_type, md_env->md_env.matrix, 
                               &dpmode, &md_env->md_id), 
                         targetid = degenid,
                         targetos = mgrid->osnum,
                         senderid = NULL_OBJID);
    }
    
    /*
     * If the constraints corresponding to the varlist need to be displayed.
     * these could be conflicting or the ones that didn't converge.
     */
    if (varlist)
    {
      dpmode = GRhd;
      while (varlist)
      {
        num_maj_cnstr = 0;
        maj_cnstr = maj_cnstr_mem;
        stat_OM = om$send (msg = message SKconstraint.SKgetmajconstrs (&msg_loc,
                                 NULL, BLOCK_SIZE, &num_maj_cnstr, &maj_cnstr),
                           targetid = varlist->constrid1,
                           targetos = mgrid->osnum,
                           senderid = NULL_OBJID);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, EMS_E_Fail, ret_end);
  
        for (i=0; i<num_maj_cnstr; i++)
        {
          IGRushort props=NULL;
          
          om$send (msg = message SKconstraint.SKgetprops (&msg_loc, &props),
           targetid = maj_cnstr[i], targetos = mgrid->osnum,
           senderid = NULL_OBJID);
          if (props & SK_SELFCNSTR || props & SK_INVISIBLEHNDL)
          {
            IGRint num_ptvars=0;
            GRobjid geomid=NULL_OBJID, *ptvars=NULL;
  
            SKgetcnptvars (&msg_loc, maj_cnstr[i], mgrid->osnum,
             &num_ptvars, &ptvars);

            SKgetcommgeom (num_ptvars, ptvars, mgrid->osnum, &geomid);
            if (!IF_NULL_OBJID (geomid))
            {
              om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
               &md_env->md_env.matrix_type, md_env->md_env.matrix, &dpmode,
               &md_env->md_id), targetid = geomid, 
               targetos = mgrid->osnum, senderid = NULL_OBJID);
            }
            
            if (ptvars)
              free (ptvars);
          }
          else
          {
            om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
             &md_env->md_env.matrix_type, md_env->md_env.matrix, &dpmode,
             &md_env->md_id), targetid = maj_cnstr[i], 
             targetos = mgrid->osnum, senderid = NULL_OBJID);
          }
        }
  
        if (maj_cnstr && maj_cnstr != maj_cnstr_mem)
        {
          om$dealloc (ptr = maj_cnstr);
          maj_cnstr = NULL;
        }
        varlist = varlist->next;
      }
    }
  }
  else if (EMSerror (solve_msg))
  {
    ex$message ( msgnumb = EMS_S_ErrorEncountered);
    update_error = TRUE;
  }

ret_end:
  if (oversolved_vars)
    SKfreevarlist (oversolved_vars, MAXINT);
  
  if (nosolution_vars)
    SKfreevarlist (nosolution_vars, MAXINT);

  *msg = solve_msg;
  return stat_OM;
}

end implementation SKmgr;
