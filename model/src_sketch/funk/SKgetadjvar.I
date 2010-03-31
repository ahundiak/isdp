/*
  DESCRIPTION

    This function returns the list of variables that are involved in a
    given constraint. It returns it in the form of an array of pointers
    to the corresponding SKsolvevars node in the input variable linked
    list.

  ASSUMPTION

    A non-compressed list of variables is input. That is one variable
    corresponds to one node in the list.
*/

class implementation SKconstraint;

#include "OMmacros.h"
#include "SKdef.h"
#include "SKinc.h"
#include <alloca.h>

#define EMomerr_exit(sts, label)  if (EMSerror (sts)) goto label;

IGRlong SKgetadjvars (msg, opts, all_vars, num_constrs, constrs, constr_os)
IGRlong *msg;
IGRushort opts;
struct SKsolvevars *all_vars;
IGRint num_constrs;
struct SKconstrinfo *constrs;
GRspacenum constr_os;
{
  IGRushort jacob_opts;
  IGRint i, j, inx, total_num_vars, num_adj_vars, iter_limit;
  IGRlong msg_loc, stat_OM;
  IGRdouble *adjrow, iter_tol;
  struct SKsolvevars *loc_vars;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  total_num_vars = 0;
  loc_vars = all_vars;
  while (loc_vars)
    {
    total_num_vars++;
    loc_vars = loc_vars->next;
    }

  adjrow = (IGRdouble *) alloca (total_num_vars * sizeof (IGRdouble));
  SKgetiterpar ( &iter_limit, &iter_tol );
  for (i=0; i<num_constrs; i++)
    if (!IF_NULL_OBJID (constrs[i].constrid))
      {
      jacob_opts = NULL;
      if (constrs[i].cprops & CONSTR_PSEUDO_VAR)
        jacob_opts |= SK_JACOB_PSEUDO_VAR;
      if (constrs[i].cprops & CONSTR_PSEUDO_EQN)
        jacob_opts |= SK_JACOB_PSEUDO_EQN;
      if (constrs[i].cprops & CONSTR_GRND_Y)
        jacob_opts |= SK_JACOB_GROUND_SECDIM;
      jacob_opts |= SK_JACOB_ADJACENCY;
      
      /* reset the jacobian to a NULL value */
      for (j = 0; j < total_num_vars; j++)
        adjrow [j] = 0.0;

      stat_OM = om$send (msg = message SKconstraint.SKmakejacobian
                 (&msg_loc, jacob_opts, NULL, all_vars, adjrow, NULL),
                 targetid = constrs[i].constrid, targetos = constr_os,
                 senderid = NULL_OBJID);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
       ret_end);

      num_adj_vars = 0;
      for (j = 0; j < total_num_vars; j++)
        if (adjrow [j])
        {
          double fabs ();
          
          /* values smaller than the tolerance are regarded as NULL */
          if (fabs ( adjrow [j] ) < iter_tol)
            adjrow [j] = 0.0;
          else
            num_adj_vars++;
        }

      if (num_adj_vars > CONSTR_STATIC_ADJVARSIZE)
        constrs[i].adjvars = (struct SKsolvevars **) om$malloc (size =
                              num_adj_vars * sizeof (struct SKsolvevars *));
      else
        constrs[i].adjvars = constrs[i].adjvar_store;
      EMerr_hndlr (!constrs[i].adjvars, *msg, EMS_E_NoDynamicMemory, ret_end);

      inx = 0;
      for (j=0; j<total_num_vars; j++)
        if (adjrow[j])
          SKvarlistnode (all_vars, j, &constrs[i].adjvars[inx++]);
      constrs [i].num_adjvars = num_adj_vars;
      }
  
ret_end:
  EMWRAPUP (*msg, stat_OM, "SKgetadjvars");
  return (stat_OM);
}

end implementation SKconstraint;


