/*
  DESCRIPTION

    This function is the least-squares minimizer. It is used in the solution
    for a single iteration of the Newton-Raphson-like method, which 
    minimizes the sum of the square of the error function.

                     J  X Jt X  lambdaV  =  -F      and,
                                deltaV   =  Jt X lambdaV

    The input Jacobian matrix (J) could be a non-square matrix, the size of
    which is determined by the number of variables and the number of
    constraints in the system. The vector (F) consisting of the
    function values (functions of the form f(V) = 0) determined
    at the current state of the variables is also input. This function
    returns the deltas by which the variables must be modified to move
    towards the solution. The transpose of the Jacobian (Jt) and the
    Langrangian multiplier (lambdaV) is computed herein.

  ARGUMENTS

    msg		- Output: Return code. EMS_S_Success if all went

  HISTORY
	
	Sudha	07/02/93	Modified for BSprototype ansification

*/

#include "bsparameters.h"
#include "bserr.h"
#include "bsequat.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include <math.h>
#include "bsrslsysli4.h"

#define FACTOR_MAX_NON_ZEROS 0.25
#define NUM_BYTES_AUTOMATIC  100

void SKleast_squares (msg, num_vars, num_eqns,
                      jacobian, funcval, zerotol,
                      deltas)
long *msg;
int num_vars, num_eqns;
struct BSspars_mat *jacobian;
IGRdouble *funcval;
IGRdouble zerotol;
IGRdouble *deltas;
{
  int num_unconstr, num_redund, num_confl;
  int *unconstr_inx, *confl_inx;
  long msg_loc, stat_func;
  double *lambda;
  int    *redund_inx;
  struct BSspars_mat *jacobian_jacobian_t;
  void   SKsparse_mult(), SKsparse_vecmul();

  *msg = EMS_S_Success;
  stat_func = TRUE;

  lambda = NULL;
  unconstr_inx = NULL;
  confl_inx = NULL;

  /*
   * Obtain J X Jt in a sparse format.
   */

  jacobian_jacobian_t = (struct BSspars_mat *) malloc (sizeof(struct BSspars_mat));
  
  SKsparse_mult (&msg_loc, jacobian, jacobian_jacobian_t, zerotol);

  /*
   * Obtain the Lagrange multipliers
   */
  lambda = (double *) malloc (num_eqns * sizeof (double));
  unconstr_inx = (int *) malloc (num_eqns * sizeof (int));
  confl_inx = (int *) malloc (num_eqns * sizeof (int));
  EMerr_hndlr (!lambda || !unconstr_inx || !confl_inx, *msg,
               EMS_E_NoDynamicMemory, ret_end );
  
  BSrslsysli4 (jacobian_jacobian_t, 1, funcval, zerotol, lambda,
               &num_unconstr, unconstr_inx, 
               &num_redund, NULL, &redund_inx, &num_confl, confl_inx, &msg_loc );
  EMerr_hndlr (msg_loc != BSSUCC && msg_loc != BSDGENRAT, *msg, EMS_E_Fail,
   ret_end);
  EMerr_hndlr (msg_loc == BSDGENRAT, *msg, EMS_I_Degenerate, ret_end);

  /*
   * Obtain the deltas = Jt X lambda
   */

  SKsparse_vecmul (&msg_loc, jacobian, lambda, deltas);
  
ret_end:
  if (lambda)
    free (lambda);
  if (unconstr_inx)
    free (unconstr_inx);
  if (confl_inx)
    free (confl_inx);

  if (jacobian_jacobian_t->matrix)
    free(jacobian_jacobian_t->matrix);
  if (jacobian_jacobian_t->indxrow)
    free(jacobian_jacobian_t->indxrow);
  if (jacobian_jacobian_t->indxcol)
    free(jacobian_jacobian_t->indxcol);
  if (jacobian_jacobian_t)
    free(jacobian_jacobian_t);
    
  return;
}

/*

  DESCRIPTION
    This function multiplies a sparse matrix to its transpose.  The result is
    returned in a sparse format.

*/
void SKsparse_mult ( msg, jac, jjt, zerotol)
long               *msg	    /* The return code					OUT */;
struct BSspars_mat *jac     /* Values of the sparse elements			IN  */;
struct BSspars_mat *jjt	    /* The matrix product of [J]x[Jt]		        OUT */;
IGRdouble             zerotol  /* Zero tolerance                                   IN  */;
{
   int    i, j, m;
   int    ik, jk;
   int    tau;
   double *temp;
   int    no_match;

   *msg = EMS_S_Success;

   m = jjt->nbrow = jac->nbrow;
   jjt->nbcol = m;
   
   /* 
     Determine the no. of nonzero entries in the matrix
     product by doing a symbolic multiplication
   */
   tau = 0;

   for (i = 0; i < m; i++)
   {
      for (j = 0; j < i; j++)
      {
         /* 
            check if Row i and j have any entries in a same column
         */
         ik = jac->indxrow[i];    /* Row i */
         jk = jac->indxrow[j];    /* Row j */
         no_match = TRUE;
         while (no_match && ik < jac->indxrow[i+1])
         { 
           for (; jk < jac->indxrow[j+1]; jk++)              /* Row j */
           {
              if (jac->indxcol[jk] == jac->indxcol[ik])
              {
                 no_match = FALSE;
                 tau++;
                 break;
              }
              else if (jac->indxcol[jk] > jac->indxcol[ik]) 
                 break;
           }
           ik++;    /* check next entry in Row i */
         }
      }
   }

   /* 
    * Since the matrix is symmetric ... double the value of tau
    * and add for the diagonal entries
    */
   tau = tau*2 + m;
   
   jjt->nbcoef = jjt->allocm  = tau;
   jjt->indxrow = (int *) malloc( (m+1) * sizeof(int));
   jjt->indxcol = (int *) malloc( tau * sizeof(int));
   jjt->matrix  = (double *) malloc( tau * sizeof(double));

   temp = (double *) malloc(m*sizeof(double));

   tau = 0;
   
   /* 
     Compute the matrix jac*jacT.  We should actually do only half the number of
     calculations since the matrix is symmetric.  Currently the sparse solver
     requires the full matrix.
   */
   
   for (i = 0; i < m; i++)
   {
      for (j = 0; j < m; j++)
      {
         temp[j] = 0;
         jk = jac->indxrow[j];
         for (ik = jac->indxrow[i]; ik < jac->indxrow[i+1]; ik++)
         {
           for (; jk < jac->indxrow[j+1]; jk++)
           {
              if (jac->indxcol[jk] == jac->indxcol[ik])
              {
                 temp[j] += jac->matrix[ik] * jac->matrix[jk];
                 break;
              }
              else if (jac->indxcol[jk] > jac->indxcol[ik]) 
                 break;
           }
         }
      }
      
      /* compute the diagonal entry */
      temp[i] = 0;
      for (ik = jac->indxrow[i]; ik < jac->indxrow[i+1]; ik++)
          temp[i] += jac->matrix[ik] * jac->matrix[ik];

      /* store the row in the output matrix in sparse format */
      jjt->indxrow[i] = tau;
      for (j = 0; j < m; j++)
         if (fabs(temp[j]) > zerotol) 
         {
            jjt->indxcol[tau] = j;
            jjt->matrix[tau] = temp[j];
            tau++;
         }
   }

   jjt->indxrow[m] = tau;

   free(temp);
}

/*

  DESCRIPTION
    This function multiplies the transpose of a sparse matrix to a vector.

*/

void SKsparse_vecmul ( msg, jac, lambda, deltax)
long      *msg	           /* The return code				OUT */;
struct BSspars_mat *jac    /* Sparse matrix                             IN  */;
IGRdouble    *lambda       /* The vector   			        IN  */,
             *deltax       /* The multiplication result of jacT*lambda	OUT */;
{
   int    i, k;

   *msg = EMS_S_Success;

   for (i = 0; i < jac->nbcol; i++)
     deltax[i] = 0.0;

   /* compute the vector jacT*lambda */
   for (i = 0; i < jac->nbrow; i++)
      for (k = jac->indxrow[i]; k < jac->indxrow[i+1]; k++)
          deltax[jac->indxcol[k]] += jac->matrix[k] * lambda[i];
}


/*
  This function return the approximate size of memory (conservative)
  that it will need to operate successfully
*/

int SKlstsqrsmem (num_vars, num_eqns)
int num_vars, num_eqns;
{
  int num_bytes, approx_non_zeros;

  approx_non_zeros = FACTOR_MAX_NON_ZEROS * num_vars * num_vars;
  num_bytes = approx_non_zeros * sizeof (int) +	     /* column nos */
              num_eqns * sizeof (int) +  	     /* row pointers */
              approx_non_zeros * sizeof (double);    /* jacobian_jacobian_t values    */
  return (num_bytes + NUM_BYTES_AUTOMATIC);
}

