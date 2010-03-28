/*

Name
  exp_simul.I

Description
This file has the new methods and new routines for simultaneous equations.

  Initial revision: Kapil Singh
  
Notes


 */


class implementation expression;

/*  */

#include <tools.h>
#include <stdio.h> 
#include <alloca.h>
#include <string.h> 
#include <OMminimum.h>
#include <OMmacros.h>
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMobjectcomm.h"
#include "OMmetaclass.h"
#include "expression.h"
#include "expmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "OMindex.h"
#include "nddef.h"
#include "asbox.h"
#include "AS_status.h"
#include "gocmacros.h"
#include "exmacros.h"
#include "bsequat.h"
#include "bserr.h"
#include "bsparameters.h"
%safe
#include "math.h"
%endsafe
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "referr.h"
#include "ASmessages.h"
#include "msmacros.h"
#include "drawparam.h"
#include "malloc.h"


#define EQN_I_Conflicting 100
#define EQN_I_Degenerate  200
#define EQN_I_NoSolution  300
#define EQN_I_Undefined   400

#define EQN_PERTURB_FRACTION			1000
#define EQN_MIN_PERTURB			.001

extern void       Error_Text(), Discard();
extern struct GRid    solve_var_grid;
extern  short 	int Compress_ArgList();

/*

Name
  Eqn_compute_strong_component

Abstract

 * This routine computes the variables in the strong component using the iterative
 * N-R solver.


Synopsis
int cyc_count; IN
struct GRid cyc_grid[]; IN
int iterlim; IN
double itertol; IN

Description

Return Value

Notes

Index

Keywords
  equation,strong-component

History
  03/04/93 : Kapil Singh : created

 */
int Eqn_compute_strong_component(cyc_count, cyc_grid, iterlim, itertol)
int cyc_count;
struct GRid cyc_grid[];
int iterlim;
double itertol;
{
  struct BSspars_mat *pjacobian;
  double *pfuncval, *pdelta, *poriginal_value;
  int num_unconstr, num_redund, num_confl;
  int *punconstr_inx, *predund_ptr, *predund_inx, *pconfl_inx;
  int itercount, i;
  long status, solve_status;
  IGRboolean more_to_go, init_val_exist = TRUE;
  double maxdeviation, zerotol, current_value;
  IGRchar full_name[DI_PATH_MAX], rel_dir_name[DI_PATH_MAX], name[DI_PATH_MAX];
  int stat;
    
  predund_inx = NULL;
  pjacobian = NULL;
  pfuncval = NULL;
  pdelta = NULL;
  poriginal_value =  NULL;
  punconstr_inx = NULL;
  predund_ptr = NULL;
  predund_inx = NULL;
  pconfl_inx = NULL;
  itercount = 0;
  
if ((iterlim != 30) || (itertol != .0001))
 printf("Args not correct in Eqn_compute_strong comp.\n\n");
 
  status = Eqn_alloc_NR_space(cyc_count, &poriginal_value, &pjacobian,
                       &pfuncval, &pdelta,
                       &punconstr_inx, &predund_ptr, &pconfl_inx);
  as$status(action = GOTO_VALUE, value = wrapup);

  for (i = 0; i < cyc_count; i++)
  {
    pdelta[i] = 0.0;
    status=om$send(msg=message expression.NDgive_value(&poriginal_value[i]),
                   senderid = NULL_OBJID,
              	   targetos = cyc_grid[i].osnum, 
              	   targetid = cyc_grid[i].objid);
    as$status(action = GOTO_VALUE, value = wrapup);
    if (poriginal_value[i] == MAXDOUBLE)
      init_val_exist = FALSE;
  }                       
  if (!init_val_exist)
  {
    char *var_name[MAX_NUM_EQN_VAR];
    double *var_init_value = (double *)alloca(cyc_count * sizeof(double));

    for (i = 0; i < cyc_count; i++)
    {

      stat = EXP_rec_untranslate( cyc_grid[i].objid , cyc_grid[i].osnum, full_name);
      if((stat!=DIR_S_SUCCESS)&&(stat!=DIR_W_NAME_NOT_FOUND))
        di$report_error(sts = stat);
      
      if(full_name[0] != '\0') 
      {
        di$split(pathname = full_name, name = name, dirname = rel_dir_name);
      }
      var_name[i] = (char *)alloca(strlen(name) + 1);
      strcpy(var_name[i], name);
      var_init_value[i] = poriginal_value[i];
    }
    
    if (EXPGiveInitialValues (var_name, cyc_count, var_init_value) == OM_S_SUCCESS)
    {
    
      for (i = 0; i < cyc_count; i++)
      {
        status=om$send(msg=message expression.put_value(var_init_value[i]),
                       senderid = NULL_OBJID,
                  	   targetos = cyc_grid[i].osnum, 
                  	   targetid = cyc_grid[i].objid);
        as$status(action = RET_STATUS);
      }                       
    
    }

  }


  BSEXTRACTPAR ( &solve_status, BSTOLCLOSETOZERO, zerotol );

  do
  {

    status = Eqn_build_NR_mat(cyc_count, cyc_grid, pjacobian,  pfuncval, &solve_status);
    as$status(action = GOTO_VALUE, value = wrapup);
    if (solve_status == EQN_I_Undefined)
      goto wrapup;


    maxdeviation = 0.0;
    for (i = 0; i < cyc_count; i++)
    {
      if (fabs ( pfuncval[i] ) > maxdeviation)
        maxdeviation = fabs ( pfuncval[i] );
      pfuncval[i] = -pfuncval[i];
    }
    if (maxdeviation < itertol)
    {
      solve_status = EXP_S_SUCCESS;
      break;
    }
    BSrslsysli4 ( pjacobian, 1, pfuncval, zerotol, pdelta,
                  &num_unconstr, punconstr_inx, 
                  &num_redund, predund_ptr, &predund_inx, &num_confl, pconfl_inx, 
                  &solve_status);
    if (solve_status == BSNOSTKMEMORY)
    {
      Error_Text ( EXP_MEM_FAIL, (int *)"in NR iterative solution");
      goto wrapup;
    }
    else if (solve_status == BSDGENRAT)
    {
      solve_status = EQN_I_Conflicting;
      break;
    }
    else if (num_redund || num_unconstr)
      solve_status = EQN_I_Degenerate;
  
    /*
     * Update the values of the unsolved_variables with the delta.
     */
  
    for (i = 0; i < cyc_count; i++)
    {
      status=om$send(msg=message expression.NDgive_value(&current_value),
                           senderid = NULL_OBJID,
                	   targetos = cyc_grid[i].osnum, 
                	   targetid = cyc_grid[i].objid);
      as$status(action = GOTO_VALUE, value = wrapup);                	   

      current_value = current_value + pdelta[i];

      status=om$send(msg=message expression.put_value(current_value),
                           senderid = NULL_OBJID,
                	   targetos = cyc_grid[i].osnum, 
                	   targetid = cyc_grid[i].objid);
      as$status(action = GOTO_VALUE, value = wrapup);                	   
    }                       

    itercount++;

    more_to_go = itercount < iterlim  && maxdeviation > itertol;
  } 
  while (more_to_go);

  if (itercount >= iterlim)
  {
    /*
     * No convergence within the iteration limit. Hence perceived as
     * a no-solution case.
     */
    ex$message(msgnumb = AS_E_NoSolIterLim);
    goto wrapup;
  }
  else if (solve_status == EQN_I_Degenerate)
  {
    ex$message(msgnumb = AS_E_DegenerateEqn);    
    goto wrapup;
  }
  else if (solve_status == EQN_I_Conflicting)
  {
    /*
     * An unresolvable situation has occurred before the iterations could
     * finish. This could mean two things. A singularity exists because
     * the variable-vector is at a singularity point or the other
     * possibility is that the system truly has conflicting constraints in
     * it. Assume latter.
     */
    ex$message(msgnumb = AS_E_ConflEqb);    
    goto wrapup;    
  }
  else if (solve_status == EXP_S_SUCCESS)
  {
    Eqn_free_NR_space(poriginal_value, pjacobian, pfuncval, pdelta,
                    punconstr_inx, predund_ptr, pconfl_inx, predund_inx);
    return(EXP_S_SUCCESS);
  }
  else
    goto wrapup;
      
wrapup:

  for (i = 0; i < cyc_count; i++)
  {
    status=om$send(msg=message expression.put_value((double) MAXDOUBLE),
                   senderid = NULL_OBJID,
              	   targetos = cyc_grid[i].osnum, 
              	   targetid = cyc_grid[i].objid);
    as$status(action = RET_STATUS);
  }                       

  Eqn_free_NR_space(poriginal_value, pjacobian, pfuncval, pdelta,
                    punconstr_inx, predund_ptr, pconfl_inx, predund_inx);

  if ((itercount < iterlim) && (solve_status != EQN_I_Degenerate) &&
      (solve_status != EQN_I_Conflicting) &&
      (solve_status != EQN_I_Undefined))
  {
    ex$message(msgnumb = AS_F_IntSolErr);
    fprintf (stderr, "Internal Error in Iterative Newton Raphson Solution");    
  }
  return (EXP_S_SUCCESS);
 
}


/*

Name
  Eqn_alloc_NR_space

Abstract
Allocates heap memeory to execute NR iterative solution.

Synopsis

Description

Return Value

Notes

Index

Keywords
  equation,strong-component

History
  03/04/93 : Kapil Singh : created

 */
int Eqn_alloc_NR_space(cyc_count, pporiginal_value, 
                       ppjacobian, ppfuncval, ppdelta,
                       ppunconstr_inx, ppredund_ptr, ppconfl_inx)
int cyc_count;
struct BSspars_mat **ppjacobian;
double **pporiginal_value, **ppfuncval, **ppdelta;

int **ppunconstr_inx, **ppredund_ptr, **ppconfl_inx;
{
  int matsize;
 
  /*
   * Allocate space for the sparse jacobian matrix.  A conservative estimate 
   * is the number of variables in the strong component times iself.
   */
  
  matsize = cyc_count * cyc_count;
  *ppjacobian            = (struct BSspars_mat *) malloc ( sizeof (struct BSspars_mat) );
  (*ppjacobian)->matrix  = (double *) malloc(matsize*sizeof(double));
  (*ppjacobian)->indxcol = (int *) malloc(matsize*sizeof(int));
  (*ppjacobian)->indxrow = (int *) malloc((cyc_count + 1)*sizeof(int));
  if ( !(*ppjacobian) || !(*ppjacobian)->matrix || !(*ppjacobian)->indxcol ||
                !(*ppjacobian)->indxrow) 
  {
    Error_Text ( EXP_MEM_FAIL, (int *)"in NR iterative solution");
    Eqn_free_NR_space(*pporiginal_value, *ppjacobian, *ppfuncval, *ppdelta,
                      *ppunconstr_inx, *ppredund_ptr, *ppconfl_inx, NULL);

    return(EXP_MEM_FAIL);
  }

  /*
   * Allocate space for other vectors needed for iterative solution
   *
   */
  *pporiginal_value = (double *) malloc (cyc_count * sizeof (double));
  *ppfuncval      = (double *) malloc (cyc_count * sizeof (double));
  *ppdelta        = (double *) malloc (cyc_count * sizeof (double));
  *ppunconstr_inx = (int *) malloc (cyc_count * sizeof (int));
  *ppredund_ptr   = (int *) malloc ((cyc_count+1) * sizeof (int));
  *ppconfl_inx    = (int *) malloc (cyc_count * sizeof (int));
  if ( !(*pporiginal_value) || !(*ppfuncval) || !(*ppdelta) || 
       !(*ppunconstr_inx) || !(*ppredund_ptr) || !(*ppconfl_inx))
  {
    Error_Text ( EXP_MEM_FAIL, (int *)"in NR iterative solution");
    Eqn_free_NR_space(*pporiginal_value, *ppjacobian, *ppfuncval, *ppdelta,
                      *ppunconstr_inx, *ppredund_ptr, *ppconfl_inx, NULL);

    return(EXP_MEM_FAIL);
  }

  (*ppjacobian)->nbrow = cyc_count;
  (*ppjacobian)->nbcol = cyc_count;
  (*ppjacobian)->allocm = matsize;

  return(EXP_S_SUCCESS);

}

/*

Name
  Eqn_free_NR_space

Abstract

 * This routine free the memory which was allocated for NR matrix data


Synopsis

Description

Return Value

Notes

Index

Keywords
  equation,strong-component

History
  03/04/93 : Kapil Singh : created

 */
int Eqn_free_NR_space(poriginal_value, pjacobian, pfuncval, pdelta,
                       punconstr_inx, predund_ptr, pconfl_inx, predund_inx)
struct BSspars_mat *pjacobian;
double *poriginal_value, *pfuncval, *pdelta;
int *punconstr_inx, *predund_ptr, *pconfl_inx, *predund_inx;
{
  if (poriginal_value)
    free (poriginal_value);
    
  if (pjacobian)
  {
    if (pjacobian->matrix)
      free(pjacobian->matrix);
    if (pjacobian->indxrow)
      free(pjacobian->indxrow);
    if (pjacobian->indxcol)
      free(pjacobian->indxcol);
    free(pjacobian);
  }

  if (pfuncval)
    free (pfuncval);
  if (pdelta)
    free (pdelta);
  if (punconstr_inx)
    free (punconstr_inx);
  if (predund_ptr)
    free (predund_ptr);
  if (predund_inx)
    free (predund_inx);
  if (pconfl_inx)
    free (pconfl_inx);

  return(EXP_S_SUCCESS);
}


/*

Name
  Eqn_build_NR_mat

Abstract

 *  This routine builds the jacobian in a sparse matrix format for the
 *  Variables in the strong component. 

Synopsis

Description

Return Value

Notes

Index

Keywords
 equations, strong component
 
History
  03/04/93 : Kapil Singh : created

 */
int Eqn_build_NR_mat(cyc_count, cyc_grid, pjacobian, pfuncval, psolve_status)
int cyc_count;
struct GRid cyc_grid[];
struct BSspars_mat *pjacobian;
double *pfuncval;
long *psolve_status;
{
  int i;
  long status;

  pjacobian->nbcoef = 0;

  for (i=0; i < cyc_count; i++)
  {
    pjacobian->indxrow[i] = pjacobian->nbcoef;
    
    status = om$send(msg = message expression.build_jacob_row
                          (psolve_status, i, cyc_count, cyc_grid, pjacobian, pfuncval), 
                          senderid = NULL_OBJID,
                          targetos = cyc_grid[i].osnum,
                          targetid = cyc_grid[i].objid );
                          as$status(action = RET_STATUS);
    as$status(action = RET_STATUS);
    if (!((*psolve_status) & 1))
      return (EXP_S_SUCCESS);
  }
  pjacobian->indxrow[cyc_count] = pjacobian->nbcoef;
  return (EXP_S_SUCCESS);
}

/*

Name
  build_jacob_row

Abstract

 *  The following method builds one row of the jacobian and also computes
 *  the value of the funcval for that row.

Synopsis

Description

Return Value

Notes

Index

Keywords
  equation,strong-component

History
  03/04/93 : Kapil Singh : created

 */
method build_jacob_row(long *pmsg_loc; int row_num; int cyc_count; struct GRid cyc_grid[];
                       struct BSspars_mat *pjacobian; double *pfuncval) 
{
  int j;
  int num_var;
  struct GRid var_grid[MAX_NUM_EQN_VAR];
  long status;
  double perturb_value, current_value, new_value, new_funcval, partial_deriv;
  struct data_struct parser_value;
  
  *pmsg_loc = EXP_S_SUCCESS;

  /* get the parents of the variable for the row */

  status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,var_grid,MAX_NUM_EQN_VAR,
                                                     NULL, 0, MAX_NUM_EQN_VAR - 1,
 						       &num_var),
		                                   targetid = cyc_grid[row_num].objid,
		                                   targetos = cyc_grid[row_num].osnum);
  as$status(action = GOTO_VALUE, value = wrapup);
  
  if (num_var > MAX_NUM_EQN_VAR)
  {
    Error_Text( EXP_MEM_FAIL, (int *) "in matching." ) ;
    status = EXP_MEM_FAIL;
    goto wrapup;
  }

  solve_var_grid.osnum = OM_Gw_current_OS;  
  solve_var_grid.objid = my_id;
  
  status = compute_Parse(num_var, var_grid, me->pretty_print, &parser_value); 
  as$status(action = GOTO_VALUE, value = wrapup);                             
  
  if (parser_value.data.real == MAXDOUBLE)
  {
    for (j = 0; j < cyc_count; j++)
    {
      status=om$send(msg=message expression.put_value((double)MAXDOUBLE),
                	   targetos = cyc_grid[j].osnum, 
                	   targetid = cyc_grid[j].objid);
      as$status(action = GOTO_VALUE, value = wrapup);
    }                	   
    *pmsg_loc = EQN_I_Undefined;
    return (EXP_S_SUCCESS);      
  }
  pfuncval[row_num] = parser_value.data.real;

  for (j = 0; j < cyc_count; j++)
  {
    if (is_in_set (cyc_grid[j], num_var, var_grid) || (j == row_num)) 
    {
      status=om$send(msg=message expression.NDgive_value(&current_value),
                	   targetos = cyc_grid[j].osnum, 
                	   targetid = cyc_grid[j].objid);
      as$status(action = GOTO_VALUE, value = wrapup);                	   

      perturb_value = current_value / EQN_PERTURB_FRACTION;

      if (perturb_value  < EQN_MIN_PERTURB)
        perturb_value  = EQN_MIN_PERTURB;
        
      new_value = current_value + perturb_value;

      status=om$send(msg=message expression.put_value(new_value),
                	   targetos = cyc_grid[j].osnum, 
                	   targetid = cyc_grid[j].objid);
      as$status(action = GOTO_VALUE, value = wrapup);                	   
    
      status = compute_Parse(num_var, var_grid, me->pretty_print, &parser_value);
      as$status(action = GOTO_VALUE, value = wrapup);

      new_funcval = parser_value.data.real;
  
      status=om$send(msg=message expression.put_value(current_value),
                	   targetos = cyc_grid[j].osnum, 
                	   targetid = cyc_grid[j].objid);
      as$status(action = GOTO_VALUE, value = wrapup);                	   
      
      partial_deriv = (new_funcval - pfuncval[row_num]) / perturb_value;

      pjacobian->matrix[pjacobian->nbcoef] = partial_deriv;
      pjacobian->indxcol[pjacobian->nbcoef] = j;
      pjacobian->nbcoef++;
      
    }
  }


  return (EXP_S_SUCCESS);

wrapup:
  *pmsg_loc = ND_COMP_FAIL;
  return(status);

}

/*

Name
  is_in_set

Abstract

 *  The following routine determines if one grid is in fact a member
 *  of a set of grids.

Synopsis

Description

Return Value

Notes

Index

Keywords
  equation

History
  03/04/93 : Kapil Singh : created

 */
int is_in_set (mem_grid, num_var, var_grid)
struct GRid mem_grid;
int num_var;
struct GRid var_grid[];
{
  int i;
  
  for (i = 0; i < num_var; i++)
    if ((var_grid[i].objid == mem_grid.objid) && (var_grid[i].osnum == mem_grid.osnum))
      return(TRUE);
      
  return (FALSE);
}
end implementation expression ;
