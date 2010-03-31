class implementation SKmgr;

#include "OMmacros.h"

%safe
static void SKgetsolvepath();
static IGRboolean chkevalequals(), chkpathvalid();
%endsafe
extern int _debug_graph_decompose;

method SKanalyze (long *msg; unsigned short opts;
                  struct SKsolvevars *solvedvars;
                  struct SKsolvevars **undersolved_vars, **oversolved_vars;
                  struct SKsolvepath *solvepath)
{
  int num_constrs;
  long msg_loc, stat_OM;
  struct SKsolvevars *varlist;
  struct SKconstrinfo *constrs;
  void SKgetsolvepath5();
  struct GRid profile;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  msg_loc = OM_S_SUCCESS;
 
  if (undersolved_vars)
    *undersolved_vars = NULL;
  if (oversolved_vars)
    *oversolved_vars = NULL;

  varlist = NULL;
  constrs = NULL;
  solvepath->num_constrs = 0;
  solvepath->constrs = NULL;
  solvepath->action = NULL;

  /*
   * Obtain the list of variables and constraints for this system.
   */

  stat_OM = om$send (msg = message SKmgr.SKgetvarconstrs (&msg_loc,
             NULL, &varlist, &num_constrs, &constrs),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Call the function that will build the graph and output the 
   * solution path along with the underconstrained and overconstrained
   * variables. 
   */

  profile.osnum = OM_Gw_current_OS;
  profile.objid = my_id;

  if (_debug_graph_decompose)
  {
     SKgetsolvepath5 ( &msg_loc, varlist, num_constrs, &constrs, profile,
                       solvepath );

     if (!(msg_loc & 1))
     {
       SKgetsolvepath ( &msg_loc, varlist, num_constrs, &constrs, solvepath);
       EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
       constrs = NULL;
     }
  }
  else
  {
    SKgetsolvepath (&msg_loc, varlist, num_constrs, &constrs, solvepath);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    constrs = NULL;
  }

  *msg = msg_loc;

ret_end:
  if (varlist)
    SKfreevarlist (varlist, MAXINT);
  if (constrs)
    om$dealloc (ptr = constrs);

  EMWRAPUP (*msg, stat_OM, "SKanalyze");
  return (stat_OM);
}




/*
  DESCRIPTION

    This function input the variables and the constraints over those variables
    in a given system and output the solution path. In addition, it returns
    the variables that are under-constrained and the constraints that are
    redundant in the system.

  ALGORITHM

    For now output the solution path such that the ground constraints are
    executed first, then the equal constraints which have one of it's 
    variables as know. The rest of the constraints form a strong component
    which are solved simultaneously. In the case where there are more
    variables than constraints add NULL constraints to balance.

  HISTORY

    SS  :  09/03/90  :  Creation
    01/19/94 : Rajiv Agrawal : Added handling of an overconstrained case.  Make one big
                               strong component.  Removed some unnecessary parameters
                               from the function call.
    02/01/94 : Rajiv Agrawal : Make one big strong component in case we found more constraints
                               to evaluate than what is there in the system.  This could happen
                               due to redundancies.
*/

#define GROUNDS     0
#define EVALEQUALS  1

extern GRclassid OPP_SKequal_class_id;

static void SKgetsolvepath (msg, varlist, num_constrs, constrs, solvepath)
long *msg;
struct SKsolvevars *varlist;
int num_constrs;
struct SKconstrinfo **constrs;
struct SKsolvepath *solvepath;
{
  IGRboolean found;
  unsigned short chkgprops; 
  int i, inx, blksize, num_vars, num_evalconstrs;
  long stat_func;
  GRobjid solvevar;
  struct SKsolvevars *varlist_temp;
  struct SKconstrinfo *p_constrs, temp_constr;

  *msg = EMS_S_Success;
  stat_func = OM_S_SUCCESS;

  solvepath->constrs = NULL;

  p_constrs = *constrs;

  varlist_temp = varlist;
  num_vars = 0;
  while (varlist_temp)
  {
    num_vars++;
    varlist_temp = varlist_temp->next;
  }

  /*
   * If the profile is OVERCONSTRAINED ... make one big strong component and leave.
   */
  if (num_constrs > num_vars)
  {
    solvepath->constrs = *constrs;
    solvepath->action = (short *) malloc (num_constrs * sizeof(short));
    EMerr_hndlr (!solvepath->constrs || !solvepath->action, *msg,
                 EMS_E_NoDynamicMemory, ret_end);
    solvepath->num_constrs = 0;
    varlist_temp = varlist;
    for (i = 0; i < num_vars; i++)
    {
      solvepath->action[solvepath->num_constrs] = PATH_SIMULCONSTR;
      solvepath->constrs[solvepath->num_constrs].varsolveid = varlist_temp->varobj;
      solvepath->constrs[solvepath->num_constrs].vprops = varlist_temp->props;
      solvepath->num_constrs++;
      varlist_temp = varlist_temp->next;
    }
    for (i = num_vars; i < num_constrs; i++)
    {
      solvepath->action[solvepath->num_constrs] = PATH_SIMULCONSTR;
      solvepath->constrs[solvepath->num_constrs].varsolveid = NULL_OBJID;
      solvepath->constrs[solvepath->num_constrs].vprops = NULL;
      solvepath->num_constrs++;
    }
    goto ret_end;
  }

  /*
   * Extract all grounds and known equalities from the system.
   */
  blksize = sizeof (struct SKconstrinfo);
  chkgprops = CONSTR_PSEUDO_EQN |
              CONSTR_GRND_X | CONSTR_GRND_Y |
              CONSTR_GRND_V;
  num_evalconstrs = 0;
  for (inx=GROUNDS; inx<=EVALEQUALS; inx++)
    do
      {
      for (i=num_evalconstrs; i<num_constrs; i++)
        if (inx == GROUNDS ?
            p_constrs[i].cprops & chkgprops : 
            chkevalequals (p_constrs, i, &solvevar))
        {
          if (inx == EVALEQUALS)
          {
            p_constrs[i].varsolveid = solvevar;
            p_constrs[i].vprops = VAR_PSEUDO_VAL;
          }
          num_evalconstrs++;
        }
        else
          break;

      found = FALSE;
      for (i=num_evalconstrs; i<num_constrs; i++)
        if (inx == GROUNDS ?
            p_constrs[i].cprops & chkgprops :
            chkevalequals (p_constrs, i, &solvevar))
        {
          OM_BLOCK_MOVE (&p_constrs[i], &temp_constr, blksize);
          OM_BLOCK_MOVE (&p_constrs[num_evalconstrs], &p_constrs[i], blksize);
          OM_BLOCK_MOVE (&temp_constr, &p_constrs[num_evalconstrs], blksize);
          if (inx == EVALEQUALS)
          {
            p_constrs[num_evalconstrs].varsolveid = solvevar;
            p_constrs[num_evalconstrs].vprops = VAR_PSEUDO_VAL;
          }
          num_evalconstrs++;
          found = TRUE;
          break;
        }
    }
    while (found);

  /*
   * If the system is underconstrained, then add NULL constraints at the end.
   */
  if (num_vars > num_constrs)
  {
    *msg = EMS_I_UnderConstrained;
    if (num_constrs)
      *constrs = (struct SKconstrinfo *) om$realloc (
                  ptr = (char *) p_constrs,
                  size = num_vars * sizeof (struct SKconstrinfo));
    else
      *constrs = (struct SKconstrinfo *) om$malloc (size = num_vars *
                  sizeof (struct SKconstrinfo));
    EMerr_hndlr (!constrs, *msg, EMS_E_NoDynamicMemory, ret_end);
    p_constrs = *constrs;

    for (i=num_constrs; i<num_vars; i++)
    {
      p_constrs[i].constrid = NULL_OBJID;
      p_constrs[i].cprops = NULL;
    }
  }
    
  /*
   * Check the validity of the solve-path returned above. If the direct
   * solve sequence has some problems, resort to brute force, viz, one
   * big strong component.
   */

  if (chkpathvalid (num_constrs, p_constrs, varlist, num_evalconstrs))
  {
    inx = num_evalconstrs;
    varlist_temp = varlist;
    while (varlist_temp)
    {
      found = FALSE;
      for (i=0; i<num_constrs; i++)
        if (varlist_temp->varobj == p_constrs[i].varsolveid &&
            (varlist_temp->props & VAR_VAR) == (p_constrs[i].vprops & VAR_VAR))
        {
          found = TRUE;
          break;
        }
      if (!found)
      {
        p_constrs[inx].varsolveid = varlist_temp->varobj;
        p_constrs[inx].vprops = varlist_temp->props;
        inx++;
      }
      varlist_temp = varlist_temp->next;
    }
  }
  else
  {
    varlist_temp = varlist;
    for (i=0; i<num_vars; i++)
    {
      p_constrs[i].varsolveid = varlist_temp->varobj;
      p_constrs[i].vprops = varlist_temp->props;
      varlist_temp = varlist_temp->next;
    }
    num_evalconstrs = 0;
  }

  solvepath->num_constrs = num_vars;
  solvepath->constrs = p_constrs;
  solvepath->action = (short *) om$malloc (size = num_vars * sizeof (short));
  EMerr_hndlr (!solvepath->action, *msg, EMS_E_NoDynamicMemory, ret_end);

  for (i=0; i<num_evalconstrs; i++)
    solvepath->action[i] = PATH_EVALCONSTR;
  for (i=num_evalconstrs; i<num_vars; i++)
    solvepath->action[i] = PATH_SIMULCONSTR;

ret_end:
  EMWRAPUP (*msg, stat_func, "SKgetsolvepath");
  return;
}


static IGRboolean chkevalequals (constrs, inx, solvevar)
struct SKconstrinfo *constrs;
int inx;
GRobjid *solvevar;
{
  IGRboolean funcval;
  IGRuint count;
  int i;
  GRobjid var1, var2;
  OM_S_CHANSELECT chan_to_vars;
  OM_S_OBJECT_LINKAGE objlist[2];

  funcval = FALSE;

  if (constrs[inx].cprops & CONSTR_EQUAL_EQN)
    {
    om$make_chanselect (channame = "SKconstraint.to_variables",
     p_chanselect = &chan_to_vars);

    om$get_channel_objects (objid = constrs[inx].constrid,
     p_chanselect = &chan_to_vars, list = objlist, size = 2, count = &count);
    if (count == 2)
      {
      var1 = objlist[0].S_objid;
      var2 = objlist[1].S_objid;

      for (i=0; i<inx; i++)
        if (constrs[i].cprops & CONSTR_PSEUDO_EQN &&
            (constrs[i].constrid == var1 || constrs[i].constrid == var2))
          {
          funcval = TRUE;
          *solvevar = constrs[i].constrid == var1 ? var2 : var1;
          break;
          }
      }
    }
  return (funcval);
}


static IGRboolean chkpathvalid (num_constrs, constrs, varlist, num_evalconstrs)
IGRint num_constrs;
struct SKconstrinfo *constrs;
struct SKsolvevars *varlist;
IGRint num_evalconstrs;
{
  IGRboolean found;
  IGRint i, inx, num_vars;
  struct SKsolvevars *varlist_temp;

  inx = num_evalconstrs;
  num_vars = 0;
  varlist_temp = varlist;
  while (varlist_temp)
  {
    found = FALSE;
    for (i=0; i<num_constrs; i++)
      if (varlist_temp->varobj == constrs[i].varsolveid &&
          (varlist_temp->props & VAR_VAR) == (constrs[i].vprops & VAR_VAR))
      {
        found = TRUE;
        break;
      }

    if (!found)
      inx++;

    num_vars++;
    varlist_temp = varlist_temp->next;
  }

  return (inx == num_vars);
}

end implementation SKmgr;

