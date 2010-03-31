/*

Name
  SKsimulsolve_jacob

Abstract
  To solve the constraints using the numerical jacobian technique.
  
Synopsis
  long                o   *msg          return code,
  unsigned short      i   opts          Options may be specified to run the solver with
                                        specific characteristics. SK_UPDATE_DONOTPOST - runs through
                                        the solution, but does not post any solution into the
                                        'solvedvars' list. Redundancy/under-constrainedness
                                        may thus be tracked.
  int                 i   num_constrs   number of constraints,
  struct SKconstrinfo i   *constrs      constraints
  GRspacenum          i   constr_os     osnum
  int                 i   iterlim       max. no. of iterations allowed
  double              i   itertol       iteration convergence tolerance
  struct SKsolvevars  o   **solvedvars  solution vector
  struct SKsolvevars  o   **undersolvedvars variables that are underconstrained.
  struct SKsolvevars  o   **oversolvedvars  constraints that cause overconstrained-ness.
  struct SKsolvevars  o   **nosolutionvars  constraints that did not converge.

Description
    This function may be invoked to solve a set of constraints simultaneously
    using the Jacobian technique. It returns the solved variables appended
    to the input solved-var list. It also returns information about the
    variables that were underconstrained.
    
    TO BE DONE:
      Use a constraint list to return constraints that did were redundant/conflicting
      or that did not converge.  Currently we use the SKsolvevars data structure which
      uses up unnecessary memory.

Return Value
    EMS_S_Success
     - The solved variables are in the output list.

    EMS_I_NoSolution
     - The constraints were not satisifed within number of iterations
       specified. No addition to the "solvedvars" list is done.

    EMS_I_Conflicting
     - The system has atleast one conflicting constraint. No addition to the
       "solvedvars" list is done.

    EMS_I_Redundant
     - The system has some redundant constraints and these are being
       returned as output (optionally). 

    EMS_I_UnderConstrained
     - Some variables are underconstrained and these are being returned as
       output (optionally).

    EMS_E_Fail
     - Failure

Notes
  ALGORITHM

   For this solution process to work there must be exactly the same number
   of constraints (that take away a single degree of freedom) as there are
   number of unsolved points. Then each constraint contributes a row to the
   Jacobian matrix. There are as many elements in this row as there are -
   variables (point has 2 - the x and y variables of the unsolved point).
   Each element is the evaluation of the partial-derivative of the
   constraint equation w.r.t to the corresponding variable. The evaluation
   is carried out at current state of the variables (that is, their current
   values). Let this Jacobian matrix be J.
  
   A vector is computed consisting of the values of the constraint functions
   at the current state of the variables. Let this vector be F.

   Now:
                  (J-matrix)  X  (D-vector)  =  -(F-vector)

   The vector D, consists of the deltas or a measure of the amount by which
   the true values of the variables differs from the current one. This
   vector can now be computed by numerical means (essentially inverting J).
   The values of the variables are changed by this delta amount. These
   now become the current values. This process is continued until the biggest
   "delta" (diff between the new improved value of a variable and it's old one)
   is comparable to the input tolerance. A limit on the iteration is also set
   and if that is reached first that marks the termination of this iteration.

   The numerical process will also indicate the variables that are not
   constrained and indicate when a system is redundant.

   Alternately, when the system is under-constrained or when the user has
   explicitly indicated, the solution is found using the least squares
   minimization method. See the file SKlstsqrs.c for an explanation of
   this methodology.
   
   KNOWN BUG
    Due to some weirdness in BSPMATH, we do not detect a redundancy sometimes
    if we do not perform a least-squares solution pass.  Ideally if we are
    already at the solution i.e. all constraints have funcval < itertol, we
    should directly call BSrslsysli4 and get the redundancy info.  Also the
    update of the variables should be skipped since we might change the
    shape of the profile if a recalculate is done.  Waiting for more investigation.
          - Rajiv 10/05/93
    Due to another TR119416705, we found that BSrslsysli4 might give a bad
    solution vector even if we were at the solution.  So now we are skipping
    the update of the variables if we did not use least squares to arrive at
    the solution.

Index

Keywords

History
  08/08/90 : Siki S   : Creation
  03/19/92 : Rajiv A  : Implemented sparse matrix representation of the Jacobian.
  02/11/93 : Rajiv A  : Added one more int when mallocing redund_ptr for the case
                        when there is only one constraint in the strong component
                        and that happens to be redundant i.e. 0 = 0 case.  This
                        was found when 2 grounds are placed on a horizontal line.
  06/02/93 : Jack :   Added code to free "redund_inx" before it gets allocated
                      again in the call to BSrslsysli4().  This will fix a Purify
                      memory leak.
  07/02/93 : Sudha  : Modified for BSprototypes ansification
  08/04/93 : Rajiv Agrawal : Added std. doc header, more debug output and some cleanup.
  09/15/93 : Rajiv Agrawal : Update variables only when maxdeviation > itertol. This
                             will prevent the profile from going to another solution
                             when its severely underconstrained.
  12/10/93 : Rajiv Agrawal : Added code to find better starting point for 
                             unsolved variables based on the solved variables in the system.
                             This fixes a whole bunch of z graph off TRs.
  03/16/95 : Sikandar S    : Removed the check for funcvals being within itertol
                             for convergence. The correct convergence checks are
                             occurring separately for each constraint via the
                             "OutOfBounds" return code. Rationale here is that funcvals
                             are dimensionless and faceless, while a constraint
can
                             do the better job of checking whether it's equation
                             has been satisified. Previously, this work done at
                             the constraint level was at times overridden by
checking 
                             with a magical "itertol" against the faceless - funcval.


 */

class implementation SKconstraint;

#include <math.h>
#include <stdio.h>
#include <sys/types.h>

#include "bserr.h"
#include "bsparameters.h"
#include "bsequat.h"
#include "bsrslsysli4.h"
#include "bsmalloc.h"

#include "OMmacros.h"
#include "DIdef.h"
#include "SKdef.h"
#include "SKinc.h"

#define FIRST  0
#define SECOND 1

#define EMomerr_exit(sts, label)  if (EMSerror (sts)) goto label;

extern int _debug_jacobian;
extern int _debug_jacobian_file;

%safe
static int build_sparse_jacobian (long *, ushort, int, int,
            struct SKconstrinfo *, GRspacenum,  
            struct SKsolvevars **, struct SKsolvevars *,
            double *, double, struct BSspars_mat *, double *, IGRboolean *);
static void find_change_in_solvedvars (long *, int, struct SKconstrinfo *,
             GRspacenum, struct SKsolvevars *, struct SKsolvevars *, 
             double *, double *);
static void print_full_jacobian (struct BSspars_mat *, double *, 
             FILE *);
%endsafe

from SKvalvar   import SKgetname;
from SKvariable import SKgetvar;
from SKexplicit import SKgetval, SKgetname;

#define NUM_BYTES_AUTOMATIC  100

long SKsimulsolve_jacob ( long                    *msg,
                          unsigned short          opts,
                          int                     num_constrs,
                          struct SKconstrinfo     *constrs,
                          GRspacenum              constr_os,
                          int                     iterlim,
                          double                  itertol,
                          struct SKsolvevars      **solvedvars,
                          struct SKsolvevars      **undersolvedvars,
                          struct SKsolvevars      **oversolvedvars,
                          struct SKsolvevars      **nosolutionvars
                        )
{
  FILE                  *fet=NULL;
  char                  varname [DI_PATH_MAX];
  ushort                varprops, solve_opts = NULL, jacob_opts = NULL;
  IGRboolean            stat_func, converged;
  int                   i, j, inx, tryinx, itercount;
  int                   matsize;
  int                   num_zerorows, num_unconstr, num_redund, num_confl, num_zerovars;
  int                   *unconstr_inx, *redund_ptr, *redund_inx, *confl_inx;
  int                   num_vars;
  long                  msg_loc, solve_msg_loc, stat_OM;
  double                var[3], maxdeviation, zerotol;
  double                *jacob_row;
  double                *funcval, *delta;
  double                deltax, deltay;
  GRobjid               loc_objid;
  struct BSspars_mat    *jacobian;
  struct SKsolvevars    *unsolvedvars, *ptlist, *varnode;
  extern void           SKaddvarlist(), SKfreevarlist();
  extern IGRboolean     SKvarlistinx();
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Currently the system passed to this routine is square. It should actually
   * be num_constrs x num_vars.  But zero constraints are added at the end to
   * make it square in case it is underconstrained.  Null vars are added if it
   * is overconstrained.  So first the actual counts.
  */
  
  num_vars = num_constrs;
  num_zerorows = 0;
  num_zerovars = 0;
  for (i = 0; i < num_constrs; i++)
  {
    if (IF_NULL_OBJID ( constrs [i].constrid ))
      num_zerorows++;
    if (IF_NULL_OBJID ( constrs[i].varsolveid))
      num_zerovars++;
  }

  num_constrs = num_constrs - num_zerorows;
  num_vars = num_vars - num_zerovars;
   
  unsolvedvars = NULL;
  jacobian = NULL;
  jacob_row = NULL;
  funcval = NULL;
  delta = NULL;
  unconstr_inx = NULL;
  redund_inx = NULL;
  redund_ptr = NULL;
  confl_inx = NULL;

  if (_debug_jacobian)
  {
    if (_debug_jacobian_file)
      fet = (FILE *) fopen ( "/usr/tmp/SKsolve.out", "w" );
    else
      fet = (FILE *) stderr;
  }

  /* 
   * Create the list of unsolved variables.  The variable-ids are extracted from the
   * constraint array.  It is important that the NULL constraints at the end have a proper
   * varsolveid.  We should actually (eventually) have a better way of getting this
   * information and avoid NULL constraints altogether.
   */

  for (i = 0; i < num_vars; i++)
  {
    varprops = constrs[i].vprops;
    varname[0] = NULL;

    if (varprops & VAR_PSEUDO_VAL)
    {
      stat_OM = om$send ( msg = message SKexplicit.SKgetval ( &msg_loc, var ),
                          targetid = constrs[i].varsolveid, 
                          targetos = constr_os,
                          senderid = NULL_OBJID );
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      stat_OM = om$send ( msg = message SKexplicit.SKgetname 
                                ( &msg_loc, SK_GETVR_EQNVARNAME | SK_GETVR_SIGNIFNAME,
                                 varname ),
                          targetid = constrs[i].varsolveid, 
                          targetos = constr_os,
                          senderid = NULL_OBJID );
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    else
    {
      stat_OM = om$send (msg = message SKvariable.SKgetvar 
                                ( &msg_loc, NULL, NULL, NULL, var ),
                         targetid = constrs[i].varsolveid, 
                         targetos = constr_os,
                         senderid = NULL_OBJID );
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);


      if (varprops & VAR_VAL)
      {
        stat_OM = om$send ( msg = message SKvalvar.SKgetname 
                                  ( &msg_loc, SK_GETVR_EQNVARNAME | SK_GETVR_SIGNIFNAME,
                                  varname),
                            targetid = constrs[i].varsolveid, 
                            targetos = constr_os,
                            senderid = NULL_OBJID );
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    }
  
    SKaddvarlist ( &msg_loc, NULL, &unsolvedvars, varprops,
                   constrs[i].varsolveid, constrs[i].constrid, constrs[i].constrid,
                   varprops & VAR_FIRSTDIM ? var : &var[SECOND], varname );
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  }

  /*
   * Find the amount of (x,y) movement of the solvedvars that affect
   * this simultaneous set of equations.
   */
  find_change_in_solvedvars(&msg_loc, num_constrs, constrs, constr_os,  
                              *solvedvars, unsolvedvars, &deltax, &deltay);
  if (_debug_jacobian)
  {
    fprintf (fet, "delta-x = %lf, delta-y = %lf\n", deltax, deltay);
  }

  /*
   * Apply the global changes to define a better guess at the solution.
   */
  for (ptlist = unsolvedvars; ptlist; ptlist = ptlist->next) 
  {
    if (ptlist->props & VAR_X)
      ptlist->var[X] += deltax;
    else if (ptlist->props & VAR_Y)
      ptlist->var[Y] += deltay;
  }
  
  if (_debug_jacobian)
  {
    fprintf(fet, "\nSolved variables :\n");
    SKdbgvars(*solvedvars, fet);
    fprintf(fet, "\nUnsolved variables :\n");
    SKdbgvars(unsolvedvars, fet);
  }
  
  /* 
   * Check for a profile with no constraints.
   */

  if (!num_constrs)
  {
    /*
     * The system is fully under-constrained. If the caller requested the
     * list of variables that were underconstrained, return all the variables.
     */
    if (undersolvedvars) 
    {
        num_unconstr = num_vars;
        for (i = 0; i < num_unconstr; i++)
        {
          stat_func = SKvarlistinx ( unsolvedvars, constrs[i].varsolveid,
                                     constrs[i].vprops, &varnode, &inx );
          if (!stat_func)
            continue;

          SKaddvarlist ( &msg_loc, NULL, undersolvedvars, varnode->props,
                         varnode->varobj, NULL, NULL,
                         varnode->props & VAR_FIRSTDIM ? varnode->var : &varnode->var[1],
                         NULL);
          EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
       }
     }
     *msg = EMS_I_UnderConstrained;

     /*
      * Return the current values of unsolved vars as solved vars and return.
      */
     goto update_var; 
  }

  /*
   * Allocate space for the sparse jacobian matrix.  A conservative estimate of 8
   * times the number of constraints is taken.  This is based on the fact that the
   * max no. of elements per row will not exceed 8 (case of an angle constraint).
   */
  
  matsize = 8*num_constrs;
  jacobian          = (struct BSspars_mat *) malloc ( sizeof (struct BSspars_mat) );
  jacobian->matrix  = (double *) malloc(matsize*sizeof(double));
  jacobian->indxcol = (int *) malloc(matsize*sizeof(int));
  jacobian->indxrow = (int *) malloc((num_constrs+1)*sizeof(int));
  jacob_row         = (double *) malloc(num_vars*sizeof(double));
  EMerr_hndlr ( !jacobian || !jacobian->matrix || !jacobian->indxcol ||
                !jacobian->indxrow || !jacob_row, 
                *msg, EMS_E_NoDynamicMemory, ret_end );

  /*
   * Allocate space for other vectors.
   */
  
  funcval      = (double *) malloc (num_constrs * sizeof (double));
  delta        = (double *) malloc (num_vars * sizeof (double));
  unconstr_inx = (int *) malloc (num_vars * sizeof (int));
  redund_ptr   = (int *) malloc ((num_constrs+1) * sizeof (int));
  confl_inx    = (int *) malloc (num_constrs * sizeof (int));
  EMerr_hndlr ( !funcval || !delta || !unconstr_inx || !redund_ptr || !confl_inx,
                *msg, EMS_E_NoDynamicMemory, ret_end );

  /*
   * Perform the iterations towards the solution. The Jacobian is formed
   * at every iteration based on the current best values of the variables.
   * Redundancy, under-constrainedness is being tracked. When under-constrained
   * or when explicitly requested by the caller, use the least-squares
   * method. If the least squares method is used, the final iterations
   * are performed by the Newton-Raphson technique, since this provides
   * the information on the redundancies, under-constrainedness, etc.
   */

  BSEXTRACTPAR ( &solve_msg_loc, BSTOLCLOSETOZERO, zerotol );

  if (num_zerorows)
    solve_opts |= SK_JACOB_LEASTSQUARES;
  
  jacobian->nbrow = num_constrs;
  jacobian->nbcol = num_vars;
  jacobian->allocm = matsize;
  
  for (tryinx = FIRST; tryinx <= SECOND; tryinx++)
  {
    num_unconstr = 0;
    num_redund = 0;
    num_confl = 0;

    for ( itercount = 0; itercount <= iterlim; itercount++)
    {
      /*
       * Build the sparse jacobian matrix to solve.  The routine also
       * returns if all the constraints are withing the required accuracy.
       * IF so, then skip the least squares stage of the solution.  The
       * caller most probably wants the find the redundancies/conflicts/under-
       * constrained variables.
       */
      if (tryinx == FIRST && itercount == 0)
        jacob_opts = SK_JACOB_UPDATE_GUESS;

      stat_OM = build_sparse_jacobian (&msg_loc, jacob_opts,
                                         num_constrs, num_vars, constrs, constr_os, 
                                         solvedvars, unsolvedvars, jacob_row, zerotol,
                                         jacobian, funcval, &converged);
      EMerr_hndlr ( EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end );

      if (jacob_opts & SK_JACOB_UPDATE_GUESS && _debug_jacobian)
      {
        fprintf(fet, "\nUpdated unsolved variables :\n");
        SKdbgvars(unsolvedvars, fet);
      }

      if (jacob_opts & SK_JACOB_UPDATE_GUESS)
      {
        jacob_opts = NULL;
        stat_OM = build_sparse_jacobian (&msg_loc, jacob_opts,
                                           num_constrs, num_vars, constrs, constr_os, 
                                           solvedvars, unsolvedvars, jacob_row, zerotol,
                                           jacobian, funcval, &converged);
        EMerr_hndlr ( EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end );
      }

      if (_debug_jacobian)
      {
        fprintf (fet, "Jacobian iter %d:\n", itercount);
        print_full_jacobian(jacobian, funcval, fet);
        maxdeviation = 0.0;
        for (i = 0; i < num_constrs; i++)
        {
          if (fabs ( funcval[i] ) > maxdeviation)
            maxdeviation = fabs ( funcval[i] );
        }
        fprintf (fet, "%d) Max Deviation: %+20.16E\n", itercount, maxdeviation);
      }

#if BSPMATH_BUG_GETS_FIXED
      if (converged)
        solve_opts &= ~SK_JACOB_LEASTSQUARES;
#endif

      if (solve_opts & SK_JACOB_LEASTSQUARES)
      {
        SKleast_squares (&solve_msg_loc, num_vars, num_constrs,
                         jacobian, funcval, zerotol, delta);
        EMerr_hndlr (solve_msg_loc == EMS_E_NoDynamicMemory, *msg, solve_msg_loc, ret_end);
  
        if (EMSerror (solve_msg_loc) || solve_msg_loc == EMS_I_Degenerate)
        {
          solve_msg_loc = EMS_S_Success;
          break;
        }
      }
      else
      {
        if( redund_inx )
        { 
          BSdealloc((char *)redund_inx );
          redund_inx = NULL;
        }
         
        BSrslsysli4 ( jacobian, 1, funcval, zerotol, delta,
                      &num_unconstr, unconstr_inx, 
                      &num_redund, redund_ptr, &redund_inx, &num_confl, confl_inx, 
                      &solve_msg_loc );
        EMerr_hndlr (solve_msg_loc == BSNOSTKMEMORY, *msg, EMS_E_NoDynamicMemory, ret_end);

        if (solve_msg_loc == BSDGENRAT || num_confl)
        {
          solve_msg_loc = EMS_I_Conflicting;
          break;
        }
        else if (num_redund || num_unconstr)
          solve_msg_loc = EMS_I_Degenerate;
      }

      if (_debug_jacobian)
      {
        fprintf (fet, "\nSolution vector (deltas) :\n");
        prtmat (fet, num_vars, 1, delta);
      }

      /*
       * Update the values of the unsolved_variables with the delta.
       * If we were already at the solution and we reached it thru least
       * squares, then update the values.  If BSPMATH bug gets fixed, then
       * this might not be required.  If we reached a solution thru direct
       * call to BSrslsysli4, then skip if we are already converged since
       * the routine sometimes will will return bad delta even if we were
       * at the solution.
       */

      if (converged && !(solve_opts & SK_JACOB_LEASTSQUARES))
        break;

      ptlist = unsolvedvars;
      for (i = 0; i < num_vars; i++)
      {
        if (ptlist->props & VAR_FIRSTDIM)
          ptlist->var [FIRST] += delta [i];
        else
          ptlist->var [SECOND] += delta [i];
        ptlist = ptlist->next;
      }
      
      if (converged)
        break;
      
    } /* end of itercount iteration */

    /*
     * If the least squares method was used in the first pass to reach the solution,
     * then we need to make a second solution pass to obtain the rest of the information
     * (redundancies, conflicts, underconstrained variables).
     * If we used the non-least squares in the first pass itself, skip the
     * second pass.
     */
    if (solve_opts & SK_JACOB_LEASTSQUARES)
      solve_opts &= ~SK_JACOB_LEASTSQUARES;
    else
      tryinx = SECOND;

    /*
     * Check the return codes for 3 possible outcomes of the solution process
     * 1- No solution occurred.
     * 2- Degeneracy was detected.
     * 3- Conflict was detected.
     * Case 2 and 3 can occur only when non-least-squares method is used.
     */
    if (itercount >= iterlim)
    {
      /*
       * No convergence within the iteration limit. Hence perceived as
       * a no-solution case.  Add the constraints that didn't converge
       * to the nosolutionvars list.
       */
      *msg = EMS_I_NoSolution;
      if (_debug_jacobian)
        fprintf( fet, "Iteration limit exceeded - No solution\n");
      if (nosolutionvars)
      {
        for (i = 0; i < num_constrs; i++)
        {
          if (fabs(funcval[i]) > itertol) 
          {
            loc_objid = constrs [i].constrid;
            SKaddvarlist ( &msg_loc, NULL, nosolutionvars, NULL, NULL_OBJID,
                           loc_objid, loc_objid, NULL, NULL);
          }
        }
      }
      goto ret_end;
    }
    else if (solve_msg_loc == EMS_I_Degenerate || solve_msg_loc == EMS_I_Conflicting)
    {
      /*
       * There was convergence, but the jacobian matrix had "degeneracies". 
       * There are 3 possiblities -
       * 1. System is truly underconstrained (num_constr > 0)
       * 2. System has true redundancies or conflicts (num_redund > 0)
       * 3. The jacobian became singular while passing thru a solution.
       * Since there is no solution for the third case, we treat it 
       * to be same as the second one.
       */

      if (num_redund) 
      {
        /*
         * The system truly has conflicting/redundant constraints in it.  Return
         * the constraint ids thru the oversolved variables list.
         */
        if (_debug_jacobian)
          fprintf( fet, "Jacobian singular : %d redundancy sets found\n", num_redund);
        if (oversolvedvars) 
        {
          for (i = 0; i < num_redund; i++)
          {
            if (_debug_jacobian)
              fprintf ( fet, " Redundant constraint-set %d\n", i);
            for (j = redund_ptr[i]; j < redund_ptr[i+1]; j++)
            {
              loc_objid = constrs [redund_inx [j]].constrid;
              SKaddvarlist ( &msg_loc, NULL, oversolvedvars, NULL, NULL_OBJID,
                             loc_objid, loc_objid, NULL, NULL);
              EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
              if (_debug_jacobian)
                fprintf ( fet, " Redundant constraint-id %d\n", loc_objid);
            }
          }
        }

        if (solve_msg_loc == EMS_I_Degenerate) 
        {
          *msg = EMS_I_Redundant; 
        }
        else 
        {
          *msg = EMS_I_Conflicting;
          opts |= SK_UPDATE_DONOTPOST;
        }
      }
      else if (num_confl)
      {
        /*
         * KNOWN BUG: Need to return the conflicting constraints back to the
         * caller.
         */
        *msg = EMS_I_Conflicting;
        opts |= SK_UPDATE_DONOTPOST;
      }
      else if (num_unconstr)
      {
        if (num_unconstr == num_zerorows)
        {
          /*
           * The system is under-constrained. If the caller requested the
           * list of variables that were underconstrained, return this list
           * based on the indices of the jacobian matrix-columns being returned
           */
  
          if (undersolvedvars) 
          {
            for (i = 0; i < num_unconstr; i++)
            {
              stat_func = SKvarlistinx ( unsolvedvars,
                                         constrs[unconstr_inx[i]].varsolveid,
                                         constrs[unconstr_inx[i]].vprops, &varnode, &inx );
              if (!stat_func)
                continue;
              SKaddvarlist ( &msg_loc, NULL, undersolvedvars, varnode->props,
                             varnode->varobj, NULL, NULL,
                             varnode->props & VAR_FIRSTDIM ? varnode->var : &varnode->var[1],
                             NULL);
              EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
            }
          }
          *msg = EMS_I_UnderConstrained;
        }
        else  /* something strange occurred */
        {
          *msg = EMS_I_Fail;
          goto ret_end;
        }
      }
    }
  } /* end of tryinx iteration */

  /* 
   * Values for the unsolved variables have been obtained within tolerance. 
   * Post these values into the solved-variables list (unless this has been 
   * inhibited by options). 
   */
update_var:
  if (!(opts & SK_UPDATE_DONOTPOST))
  {
    ptlist = *solvedvars;
    if (ptlist)
    {
      while (ptlist->next)
        ptlist = ptlist->next;
      ptlist->next = unsolvedvars;
    }
    else
      *solvedvars = unsolvedvars;

    if (_debug_jacobian) 
    {
      fprintf(fet, "\nAfter the solution process :\n");
      SKdbgvars(unsolvedvars, fet);
    }
    unsolvedvars = NULL;
  }
 
ret_end:
  if (_debug_jacobian && _debug_jacobian_file) 
    fclose ( fet );

  if (unsolvedvars)
    SKfreevarlist ( unsolvedvars, MAXINT );

  if (jacobian)
  {
    if (jacobian->matrix)
      free(jacobian->matrix);
    if (jacobian->indxrow)
      free(jacobian->indxrow);
    if (jacobian->indxcol)
      free(jacobian->indxcol);
    free(jacobian);
  }

  if (jacob_row)
    free (jacob_row);
  if (funcval)
    free (funcval);
  if (delta)
    free (delta);
  if (unconstr_inx)
    free (unconstr_inx);
  if (redund_ptr)
    free (redund_ptr);
  if (redund_inx)
    BSdealloc((char *)redund_inx );
  if (confl_inx)
    free (confl_inx);

  EMWRAPUP ( *msg, stat_OM, "SKsimulsolve_jacob" );
  return (stat_OM);
}


int SKjacobmem (int num_vars, int num_constrs)
{
  int num_bytes;

  num_bytes = 8 * num_constrs * sizeof (double) + 	/* J.matrix  */
              8 * num_constrs * sizeof (int)    +       /* J.indxcol */
              (num_constrs + 1) * sizeof (int)  +       /* J.indxrow */
              num_vars * sizeof (double) +		/* jacob_row */
              num_constrs * sizeof (double) +		/* Funcval */
              num_vars * sizeof (double) +		/* Delta */
              num_vars * sizeof (int) +			/* Uncnstr-inx */
              num_constrs * sizeof (int) +		/* Redund-ptr */
              num_constrs * sizeof (int) +		/* Redund-inx */
              num_constrs * sizeof (int) +		/* Confl-inx */
              SKlstsqrsmem (num_vars, num_constrs);
  return (num_bytes + NUM_BYTES_AUTOMATIC);
}          

static int build_sparse_jacobian ( long                *msg,
                              ushort		  opts,
                              int                 num_constrs, 
                              int                 num_vars,
                              struct SKconstrinfo *constrs,
                              GRspacenum          constr_os,
                              struct SKsolvevars  **solvedvars,
                              struct SKsolvevars  *unsolvedvars,
                              double              *jacob_row,
                              double              zerotol,
                              struct BSspars_mat  *jacobian,
                              double              *funcval,
                              IGRboolean          *converged
                            )
{
  int    i, j;
  ushort jacob_opts;
  long   msg_loc, stat_OM;
  double *newjacm;
  int    *newjaci;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  for (i = 0; i < num_constrs; i++)
    funcval [i] = 0.0;

  *converged = TRUE;
  jacobian->nbcoef = 0;
  for (i = 0; i < num_constrs; i++)
  {
    jacobian->indxrow[i] = jacobian->nbcoef;
    jacob_opts = NULL;
    if (constrs[i].cprops & CONSTR_PSEUDO_VAR)
      jacob_opts |= SK_JACOB_PSEUDO_VAR;
    if (constrs[i].cprops & CONSTR_PSEUDO_EQN)
      jacob_opts |= SK_JACOB_PSEUDO_EQN;
    if (constrs[i].cprops & CONSTR_GRND_Y)
      jacob_opts |= SK_JACOB_GROUND_SECDIM;

    if (opts & SK_JACOB_UPDATE_GUESS) 
    {
      jacob_opts |= opts;
      stat_OM = om$send ( msg = message SKconstraint.SKmakejacobian
                                ( &msg_loc, jacob_opts, *solvedvars, unsolvedvars,
                                  NULL, NULL ),
                          targetid = constrs[i].constrid, 
                          targetos = constr_os,
                          senderid = NULL_OBJID );
      EMerr_hndlr ( EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end );
    }
    else 
    {
      jacob_opts |= SK_JACOB_ACCURACY;
      /* Get the jacobian row for this constraint */
      for (j = 0; j < num_vars; j++)
        jacob_row[j] = 0.0;
      
      stat_OM = om$send ( msg = message SKconstraint.SKmakejacobian
                                ( &msg_loc, jacob_opts, *solvedvars, unsolvedvars,
                                  jacob_row, &funcval[i] ),
                          targetid = constrs[i].constrid, 
                          targetos = constr_os,
                          senderid = NULL_OBJID );
      EMerr_hndlr ( EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end );
  
      if (msg_loc == EMS_I_OutOfBounds)
        *converged = FALSE;
                  
      /* Convert the jacob_row into the sparse format and add it */
      for (j = 0; j < num_vars; j++)
      {
         if (fabs(jacob_row[j]) > zerotol) 
         {
            if (jacobian->nbcoef == jacobian->allocm)
            {
                /* Sparse matrix space exhausted .... reallocate 10% more space */
                jacobian->allocm *= 1.1;
                newjacm = (double *) realloc( jacobian->matrix,
                           jacobian->allocm * sizeof(double));
                EMerr_hndlr ( !newjacm, *msg, EMS_E_NoDynamicMemory, ret_end );
                jacobian->matrix = newjacm;
  
                newjaci = (int *) realloc( jacobian->indxcol, 
                          jacobian->allocm * sizeof(int));
                EMerr_hndlr ( !newjacm, *msg, EMS_E_NoDynamicMemory, ret_end );
                jacobian->indxcol = newjaci;
            }
            jacobian->matrix[jacobian->nbcoef] = jacob_row[j];
            jacobian->indxcol[jacobian->nbcoef] = j;
            jacobian->nbcoef++;
         }
      }
    }
  }
  jacobian->indxrow[num_constrs] = jacobian->nbcoef;

ret_end:
  EMWRAPUP ( *msg, stat_OM, "build_sparse_jacobian" );
  return (stat_OM);
}


static void find_change_in_solvedvars(long *msg,
                            int num_constrs,
                            struct SKconstrinfo *constrs,
                            GRspacenum osnum, 
                            struct SKsolvevars *solvedvars,
                            struct SKsolvevars *unsolvedvars, 
                            double *deltax, 
                            double *deltay)
{
  IGRboolean		first_timex, first_timey;
  int 			i, j, inx;
  long 			msg_loc;
  double 		xchange, ychange, old_xchange, old_ychange, point[3];
  struct SKsolvevars 	*varnode, *loc_solvedvars, *ptlist;
  extern IGRboolean 	SKvarlistinx();
  extern void           SKaddvarlist(), SKfreevarlist();
  extern long		SKgetadjvars();
  
  *msg = EMS_S_Success;
  loc_solvedvars = NULL;

  *deltax = *deltay = 0.0;

  /*
   * If nothing has been solved, then no point continuing.
   */  
  if (!solvedvars)
    goto ret_end;
  
  /*
   * Append the unsolvedvars list to solvedvars to get the adjacency information.
   */
  ptlist = solvedvars;
  while (ptlist->next)
    ptlist = ptlist->next;
  ptlist->next = unsolvedvars;

  SKgetadjvars ( &msg_loc, NULL, solvedvars, num_constrs, constrs, osnum );
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Unlink the unsolvedvars from the ptlist to restore state back to
   * how it was.
   */
  ptlist = solvedvars;
  while (ptlist->next != unsolvedvars)
    ptlist = ptlist->next;
  ptlist->next = NULL;
  
  /*
   * Determine the list of solved variables that are part of this
   * strong component by going thru the list of adjacency variables for
   * each constraint.
   */
  for (i=0; i<num_constrs; i++)
  {
    for (j=0; j<constrs[i].num_adjvars; j++)
    {
      if (SKvarlistinx(solvedvars, constrs[i].adjvars[j]->varobj, 
                       constrs[i].adjvars[j]->props, &varnode, &inx))
      {
        SKaddvarlist(&msg_loc, NULL, &loc_solvedvars, constrs[i].adjvars[j]->props, 
                     varnode->varobj, NULL, NULL,
                     varnode->props & VAR_FIRSTDIM ? varnode->var : &varnode->var[1],
                     NULL);
      }
    }
  }
  
  /*
   * Go thru the list of solvedvars and see if everyone has undergone the same change.
   * If so, return this.  If the changes are varying, just return 0.0.
   */
  first_timex = first_timey = TRUE;
  old_xchange = old_ychange = 0.0;
  for (varnode = loc_solvedvars; varnode; varnode = varnode->next)
  {
    if (varnode->props & VAR_PT)
    {
      om$send ( msg = message SKvariable.SKgetvar
                      (&msg_loc, NULL, NULL, NULL, point),
                targetid = varnode->varobj,
                targetos = osnum,
                senderid = NULL_OBJID );
      if (varnode->props & VAR_X)
      {
        xchange = varnode->var[X] - point[X];
        if (first_timex) 
        {
          old_xchange = xchange;
          first_timex = FALSE;
        }
        else
          if (fabs(xchange - old_xchange) > 1e-3) 
            break;
      }
      if (varnode->props & VAR_Y)
      {
        ychange = varnode->var[Y] - point[Y];
        if (first_timey) 
        {
          old_ychange = ychange;
          first_timey = FALSE;
        }
        else
          if (fabs(ychange - old_ychange) > 1e-3) 
            break;
      }
    }
  }
  
  *deltax = old_xchange;
  *deltay = old_ychange;
  
ret_end:
  if (loc_solvedvars)
    SKfreevarlist(loc_solvedvars, MAXINT);
  return;
}

static void print_full_jacobian( struct BSspars_mat *jacobian,
                            double             *funcval,
                            FILE               *fp)
{
  int i, j;
  long msg_loc;
  double *jacob_row;
  double zerotol;
  
  BSEXTRACTPAR ( &msg_loc, BSTOLCLOSETOZERO, zerotol );
  jacob_row = (double *) malloc (jacobian->nbcol * sizeof(double));
  
  if (!fp)
    fp = (FILE *) fopen("jacques_li2.dat", "w");
  fprintf(fp,"%d %d %d\n", jacobian->nbrow, jacobian->nbcol, 1);
  fprintf(fp,"\n");
  for (i=0; i < jacobian->nbrow; i++)
  {
    for (j=0; j<jacobian->nbcol; j++)
      jacob_row[j] = 0.0;
      
    for (j=jacobian->indxrow[i]; j < jacobian->indxrow[i+1]; j++)
    {
      jacob_row[jacobian->indxcol[j]] = jacobian->matrix[j];
    }
    
    for (j=0; j < jacobian->nbcol; j++)
      fprintf(fp, "%+20.16E\n", jacob_row[j]);
    
    fprintf(fp, "\n");
  }

  for (i=0; i < jacobian->nbrow; i++)
    fprintf(fp,"%+20.16E\n", funcval[i]);
  fprintf(fp,"\n");

  fprintf(fp,"%+20.16E\n",zerotol);

  free(jacob_row);
}

end implementation SKconstraint;

#if WE_NEED_TO_GENERATE_DATA_FOR_BSPMATH_TESTING
/*
 * This routine was written for Jacques Gavois to generate a data file
 * for his driver function to test the BSrslsysli4 routine.  
 */
void SKprint_sparse_jacobian(jacobian, funcval, zerotol)
struct BSspars_mat *jacobian;
double *funcval, zerotol;
{
  FILE *fp;
  int i;
  
  fp = fopen("jacques_li3.dat", "w");
  fprintf(fp,"%d %d %d %d\n", jacobian->nbrow, jacobian->nbcol, jacobian->nbcoef, 1);
  fprintf(fp,"\n");
  for (i=0; i < jacobian->nbcoef; i++)
    fprintf(fp,"%lf\n", jacobian->matrix[i]);
  fprintf(fp,"\n");
  for (i=0; i < jacobian->nbcoef; i++)
    fprintf(fp,"%d\n", jacobian->indxcol[i]);
  fprintf(fp,"\n");
  for (i=0; i <= jacobian->nbrow; i++)
    fprintf(fp,"%d\n", jacobian->indxrow[i]);
  fprintf(fp,"\n");
  for (i=0; i < jacobian->nbrow; i++)
    fprintf(fp,"%e\n", funcval[i]);
  fprintf(fp,"\n");
  fprintf(fp,"%e\n",zerotol);
  fclose(fp);  
}
#endif
