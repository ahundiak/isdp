#include <stdio.h>
#include <limits.h>
#include "alloca.h"
#include "float.h"
#include "math.h"
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            Macros Definitions                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define TRUE 1
#define FALSE 0
#define UNKN_INDEX     -1       /* Unknown index                              */
#define EQUA_TOLERANCE 1.e-12   /* Tolerance to define test's equality        */
#define TEST_TOLERANCE 1.e-10   /* Tolerance to define test's equality        */

#define TEST_ZERO(value) \
                   (fabs(value) < TEST_TOLERANCE)

#define TEST_EQUAL(value1, value2) \
                   (fabs((value1)-(value2)) < TEST_TOLERANCE)

#define REAL_EQUAL(value1, value2) \
                   (fabs((value1)-(value2)) < EQUA_TOLERANCE)

#define REAL_ZERO(value) \
                   (fabs(value) < EQUA_TOLERANCE)

#define REAL_EQUIV(value1, value2) \
                   (value1 == value2)

#define VALID_INDEX(index) \
                   (index != UNKN_INDEX)


#define SUCCESS         0x0001  /* A solution is found                        */
#define NO_MEMORY       0x0002  /* No dynamic memory available                */
#define NO_SOLUTION     0x0004  /* The system has no solutions                */
#define LOOP_PB         0x0008  /* The function loops                         */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function Simplex                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRsimplex_old(nb_unkn, nb_constr, matrix, vector)

  /*
  Description : Maximize a linear equation under linear constraints using the
                basic simplex method. The method has 2 phases:
                1) Reduction to a canonical form using
                   - The canonical coefficient method,
                   - The canonical constant method.
                2) Optimisation of this solution using the simplex method

  Constraint  : The constraints can't be strict inequations, they can be: >=,
                <= or ==.
  Note:         If the system to solve doesn't have a solution, returns 
                the status: NO_SOLUTION.
  */
  int       nb_unkn;            /* IN     Number of unknowns to solve         */
  int       nb_constr;          /* IN     Number of constraints               */
  double    *matrix;            /* IN     matrix containing base and constr.  */
                                /* OUT    Solution vector                     */
  double    *vector;            /* IN     Boudaries values and inequalities   */
  /*
  Comments:  

  matrix: If the base matrix is a NxM matrix, Matrix will be (N+1)xM; at 
              the last row,  you have the constraint to MAXIMIZE.

          The result will be in this matrix (M first values).

  vector: The vector is dimension 2xN
          The first N values are the Bi terms of the general system Ax = B
          the other values correspond to the inequalities. The convention is:
          -1 --> Less or Equal
          0 --> Equal
          1 --> Greater or Equal

  For example if you have:

  minimize  (0)         x1 + 2*x2 subject to

            (1)        3*x1 + 4*x2 >= 12
            (2)        5*x1 - 6*x2 <= 2
            (3)        7*x1 - 8*x2 == 22

            x1 >=0, x2>=0 

 Then you give for the arguments:

  nb_unkn   = 2      <-- {x1, x2}
  nb_constr = 3      <-- equations {1, 2, 3}

  matrix = { 3, 4,   <-- coeff of equation (1)
             5, 6,   <-- coeff of equation (2)
             7, 8,   <-- coeff of equation (3)
            -1,-2}   <-- coeff of equation (0) (but equation to MAXIMIZE)

  vector = { 12,     <-- value of equation (1)
              2,     <-- value of equation (2)
             22,     <-- value of equation (3)
              1,     <-- sign  of equation (1)
             -1,     <-- sign  of equation (2)
              0}     <-- sign  of equation (3)

  The solution will be in the matrix

  matrix = { v1,     <-- value of x1
             v2}     <-- value of x2
  */
  {
  double    fabs();             /* Function to get the absolute value         */
  int       index0;             /* Index for a loop                           */
  int       index1;             /* Index for a loop                           */
  int       cur_ind;            /* Current index to fill the matrix           */
  int       ind_slack;          /* Index for a slack variable                 */
  int       nb_var;             /* Number of variables                        */
  int       nb_column;          /* Number of column of the array              */
  int       row_pivot;          /* Row index for pivotation                   */
  int       col_pivot;          /* Column index for pivotation                */
  double    ratio;              /* Temporary ratio                            */
  double    *array = NULL;      /* Simplex array                              */
  double    *p_row;             /* Temporary pointer to a row                 */
  double    *p_temp;            /* Temporary pointer to a row                 */
  int       status = SUCCESS;   /* Returned status of the function            */
  char      *l_pivot = NULL;    /* list of the pivoted columns                */
  int       *l_elig = NULL;     /* List of eligible columns to pivote         */
  int       loop_test;          /* value to test loops (temporary)            */

  /*| ---------------------- */
  /*| Array's initialization */
  /*| ---------------------- */
  
  /*| Get the number of slack variables */

  p_temp = &vector[nb_constr];
  for(index0=0, nb_var=0; index0 < nb_constr; index0++)
    if(!TEST_ZERO(p_temp[index0])) nb_var++;

  /*| Allocate the simplex array */

  nb_column = nb_unkn + nb_var + 1;
  array = (double *)alloca((nb_constr+1)*nb_column* sizeof(double));
  if(!array) {status=NO_MEMORY; goto exception;}
  nb_var = nb_column - 1;

  loop_test = nb_constr*nb_unkn;

  /*| Initialize the simplex array */

  /* ----------------- */
  /* Load INEQUALITIES */
  /* ----------------- */

  for(index0=0, ind_slack=0, cur_ind=0; index0 < nb_constr; index0++)
    {
    /* Init the slack part of the array */

    p_row  = &array[index0 * nb_column];
    p_temp = &matrix[index0 * nb_unkn];

    for(index1 = nb_unkn; index1 < nb_var; index1++)
      p_row[index1] = 0.;

    if(TEST_EQUAL(vector[index0+nb_constr], -1.))
      {
      p_row = &array[cur_ind *nb_column];

      /*| Load the inequation (LESS THAN) */

      for(index1 =0; index1 < nb_unkn; index1++)
        p_row[index1] = p_temp[index1];

      /*| Load the slack variable and constant vector */

      p_row[nb_unkn + ind_slack++] = 1.;
      p_row[nb_var] = vector[index0];
      cur_ind++;
      }
    else if(TEST_EQUAL(vector[index0+nb_constr], 1.))
      {
      p_row = &array[cur_ind *nb_column];

      /*| Change the sign of the inequation (GREATER THAN) */

      for(index1 =0; index1 < nb_unkn; index1++)
        p_row[index1] = -p_temp[index1];

      /*| Load the slack variable and constant vector */

      p_row[nb_unkn + ind_slack++] = 1.;
      p_row[nb_var] = -vector[index0];
      cur_ind++;
    }/* end if(TEST_EQUAL)*/
  }/* end for(index0)*/

  /* --------------- */
  /* Load EQUALITIES */
  /* --------------- */

  for(index0=0; index0 < nb_constr; index0++)
    {
    if(TEST_ZERO(vector[index0+nb_constr]))
      {
      p_row = &array[cur_ind * nb_column];
      p_temp = &matrix[index0 * nb_unkn];

      /*| Load the EQUATION */

      if(vector[index0] > 0)
        {
        /*| Load a negative equation to pivote (during first phase)*/

        for(index1 =0; index1 < nb_unkn; index1++)
          p_row[index1] = -p_temp[index1];
        p_row[nb_var] = -vector[index0];
        }
      else
        {
        for(index1 =0; index1 < nb_unkn; index1++)
          p_row[index1] = p_temp[index1];
        if(REAL_ZERO(vector[index0]))
          p_row[nb_var] = -EQUA_TOLERANCE;
        else
          p_row[nb_var] = vector[index0];
      }/* if(vector)*/
      cur_ind++;
    }/* end if(TEST_EQUAL)*/
  }/* end for(index0)*/

  /*| Load the constraint to maximize */

  p_row  = &array[nb_constr * nb_column];
  p_temp = &matrix[nb_constr * nb_unkn];

  for(index1=0; index1 < nb_unkn; index1++)
    p_row[index1] = -p_temp[index1];

  for(index1 = nb_unkn; index1 < nb_column; index1++)
    p_row[index1] = 0.;

  /*| Init the pivot list */

  l_pivot = (char *)alloca(nb_var);
  if(!l_pivot) {status=NO_MEMORY; goto exception;}
  for(index1 = 0; index1 < nb_var; index1++) l_pivot[index1] = FALSE;

  l_elig = (int *)alloca((nb_column+nb_constr)*sizeof(int));
  if(!l_elig) {status=NO_MEMORY; goto exception;}

  /* --------------------- */
  /* Create the first base */
  /* --------------------- */

  /* work only on equalities */

  for(row_pivot=ind_slack; row_pivot < nb_constr; row_pivot++)
    {
    col_pivot =UNKN_INDEX;

    /* find the column available for first phase */

    status = find_col(array,nb_constr,nb_column,row_pivot,l_elig,&col_pivot);

    if(!VALID_INDEX(col_pivot))
      {
      /* if not found, take the first not Null parameter */
      p_row = &array[row_pivot * nb_column];
      for(index1 = 0, col_pivot =UNKN_INDEX; index1 < nb_unkn; index1++)
        if(!TEST_ZERO(p_row[index1]))
          {
          col_pivot = index1;
          break;
        }/* end if */
      /* end for(index1)*/
    }/* end if*/

    if(VALID_INDEX(row_pivot)&& VALID_INDEX(col_pivot))
      {
      pivot(array, nb_constr, nb_column, row_pivot, col_pivot);
      l_pivot[col_pivot] = TRUE;
      loop_test--;
      }
    else
      {
      status=NO_SOLUTION;
      goto exception;
    }/* end if(VALID_INDEX)*/
  }/* end for(row_pivot)*/
/*
for(index0=0; index0 < (nb_constr+1); index0++)
  {
  for(index1=0; index1 < nb_column; index1++)
    printf("%4.2f|",array[index0*nb_column+index1]);
  printf("\n");
}
*/
  /*| ------- */
  /*| Solving */
  /*| ------- */

  do
    {
    for(index0=0, col_pivot=row_pivot=UNKN_INDEX; index0 < nb_constr; index0++)
      {
      if(array[(index0+1)*nb_column-1] < 0.)
        {
        /*| Case (bi < 0), (minimum value < 0 of the negative row) */

        status = find_col(array,nb_constr,nb_column,index0,l_elig,&col_pivot);
        row_pivot =index0;

        if(VALID_INDEX(col_pivot))
          break;
        else
          {
          /*| Inequality not verified */

          status=NO_SOLUTION;
          goto checking;
        }/* end if(status)*/
      }/* end if(array)*/
    }/* end for(index0)*/

    if(!VALID_INDEX(col_pivot))
      {
      /*| Find the column's pivot (minimum value < 0 of the objective row) */

      status = find_col(array,nb_constr,nb_column,nb_constr,l_elig,&col_pivot);
    }/* end if(!VALID_INDEX)*/
     
    if(VALID_INDEX(col_pivot))
      {
      /*| Find the row's pivot */

      if(!VALID_INDEX(row_pivot))
        status = find_row(array,nb_constr,nb_column,col_pivot,&l_elig[nb_column],&row_pivot);

      if(VALID_INDEX(row_pivot))
        {
        /*| Do the pivotation */

        pivot(array, nb_constr, nb_column, row_pivot, col_pivot);
        l_pivot[col_pivot] = TRUE;
        loop_test--;

/*
printf("phase1.2 pivot row %d col %d\n",row_pivot, col_pivot);
for(index0=0; index0 < (nb_constr+1); index0++)
  {
  for(index1=0; index1 < nb_column; index1++)
    printf("%4.2f|",array[index0*nb_column+index1]);
  printf("\n");
}
*/
      }/* end if(VALID_INDEX)*/
    }/* end if(!VALID_INDEX)*/
  }while(VALID_INDEX(col_pivot)&&VALID_INDEX(row_pivot)&&loop_test);

  /*| ------------------- */
  /*| Extract the results */
  /*| ------------------- */

checking:

  /* loop on variables */
  for(index1=0; index1 < nb_unkn; index1++)
    {
    if(l_pivot[index1])
      {
      /* loop on lines to find the one defining this variable */
      for(index0=0,ind_slack=0,row_pivot=UNKN_INDEX; index0 < nb_constr; index0++)
        {
        p_row = &array[index0*nb_column];
        if(TEST_EQUAL(p_row[index1],1.))
          row_pivot = index0; /* points to the constraint which defines the unkn index1 */
        else
          {
          if(TEST_ZERO(p_row[index1])) ind_slack++;
          else break;
        }/* end if */
      }/* end for(index0)*/

      if(VALID_INDEX(row_pivot)&&(ind_slack==(nb_constr-1)))
        {
        array[index1] = array[(row_pivot+1)*nb_column-1];

        /* Test equalities (canonical base) */
        if(!TEST_ZERO(vector[row_pivot])&& !TEST_ZERO(array[nb_constr*nb_column+index1]))
          {
          array[index1] = 0.0;
          status = NO_SOLUTION;
        }
        }
      else
        {
        array[index1] = 0.0;
        status = NO_SOLUTION;
      }/* end if(VALID_INDEX)*/
      }
    else
      {
      /*| this column has not been pivoted */
      array[index1] = 0.0;
      status = NO_SOLUTION;
    }/* endif(l_pivot)*/
  }/* end for(index1)*/

  /*| ------------------- */
  /*| Checking equalities */
  /*| ------------------- */

  if(status == NO_SOLUTION)
    {
    for(index0=0, status = SUCCESS; index0 < nb_constr; index0++)
      {
      if(TEST_ZERO(vector[index0+nb_constr]))
        {
        /*| Check the equality */

        p_temp = &matrix[index0*nb_unkn];
        for(index1=1, ratio=p_temp[0]*array[0]; index1 < nb_unkn; index1++)
          ratio += p_temp[index1]*array[index1];

        if(!TEST_EQUAL(ratio,vector[index0]))
          {
          /*| Equality is not verified */

          status = NO_SOLUTION;
          goto exception;
        }/* end if(TEST_EQUAL)*/
      }/* end if(TEST_EQUAL)*/
    }/* end for(index0)*/
  }/* end if(status)*/

  /*| ---------------- */
  /*| Load the results */
  /*| ---------------- */

  for(index0=0; index0 < nb_unkn; index0++) matrix[index0] = array[index0];

/* printf("MAX OPTIMUM = %lf\n",array[nb_constr*nb_column+nb_column-1]); */
exception:
  if(!loop_test) status = LOOP_PB;
  return(status);
}/* end simplex */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        INTERNAL function Find_col                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

find_col(matrix, nb_constr, nb_col, row_pivot, l_elig, p_index)

  /*
  Description : Returns the index of the best column to pivote in a row
  Constraint  : Only use for the Simplex function
  */

  double    matrix[];           /* IN     Pointer to the matrix               */
  int       nb_constr;          /* IN     Number of constraints               */
  int       nb_col;             /* IN     Number of columns                   */
  int       row_pivot;          /* IN     Row to find the pivot               */
  int       *l_elig;            /* IN     Array to find the eligible columns  */
  int       *p_index;           /* OUT    Pointer to the returned index       */
  {
  int       status = SUCCESS;   /* Returned status of the function            */
  int       index0;             /* Index for a loop                           */
  int       index1;             /* Index for a loop                           */
  double    ratio;              /* Temporary ratio                            */
  double    max_ratio;          /* Temporary maximum ratio                    */
  double    *p_row;             /* Pointer to the selected row                */
  int       nb_var;             /* Number of variables to scan                */
  int       nb_elig = 0;        /* Number of eligible columns to pivote       */
 
  /*| Find the smallest value < 0 in the row */

  l_elig[0]=UNKN_INDEX;
  nb_var = nb_col-1;
  p_row = &matrix[row_pivot*nb_col];
  for(index0=0, max_ratio= -EQUA_TOLERANCE; index0 < nb_var; index0++)
    {
    if((p_row[index0] < max_ratio))
      {
      nb_elig=1;
      l_elig[0] = index0;
      max_ratio = p_row[index0];
      }
    else if(REAL_EQUIV(p_row[index0],max_ratio)&&(max_ratio < 0))
      {
      l_elig[nb_elig++] = index0;
    }/* end if(p_row)*/
  }/* end for(index0)*/

  if(nb_elig <2)
    (*p_index) = l_elig[0];
  else
    {
    /*| Select the column from the eligible solutions */
    /*  Finding the minimum ratio Bi/Aik > 0          */

    (*p_index) = UNKN_INDEX;
    for(index0=0,max_ratio=DBL_MAX; index0 < nb_elig; index0++)
      {
      status = find_row(matrix,nb_constr,nb_col,l_elig[index0],&l_elig[nb_col],&index1);
      p_row = &matrix[index1*nb_col];
      if(status != SUCCESS) continue;
      if((ratio = p_row[nb_col-1]/p_row[l_elig[index0]]) < max_ratio)
        {
        (*p_index)=l_elig[index0];
        max_ratio = ratio;
      }/* end if */  
    }/* end for */
  }/* end if(nb_elig)*/
  if((*p_index) == UNKN_INDEX) status = NO_SOLUTION;
  return status;
}/* end find_col */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          INTERNAL function find_row                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

find_row(matrix, nb_constr, nb_col, col_pivot, l_elig, p_index)

  /*
  Description : Returns the index of the best row to pivote in a column
  Constraint  : Only use for the Simplex function
  */

  double    matrix[];           /* IN     Pointer to the matrix               */
  int       nb_constr;          /* IN     Number of constraints               */
  int       nb_col;             /* IN     Number of columns                   */
  int       col_pivot;          /* IN     Column to begin the research        */
  int       *l_elig;            /* IN     Array to find the eligible Rows     */
  int       *p_index;           /* OUT    Pointer to the returned index       */
  {
  int       index0;             /* Index for a loop                           */
  int       index1;             /* Index for a loop                           */
  double    ratio;              /* Temporary ratio                            */
  double    max_ratio;          /* Temporary maximum ratio                    */
  int       nb_elig = 0;        /* Number of eligible columns to pivote       */
  int       multiple;           /* Flag = TRUE if multiple solution           */
  double    *p_row;             /* Temporary row to test                      */
  int       status = SUCCESS;   /* Returned status of the function            */

  /*| Find the minimum ratio Bi/Aik > 0  */

  l_elig[0]=UNKN_INDEX;
  for(index0=0,max_ratio=DBL_MAX; index0<nb_constr; index0++)
    {
    p_row = &matrix[index0*nb_col];
    if(!TEST_ZERO(p_row[col_pivot]))
      {
      ratio = p_row[nb_col-1]/p_row[col_pivot];
      if(ratio > 0.)
        {
        if(ratio < max_ratio)
          {
          max_ratio = ratio;
          nb_elig=1;
          l_elig[0] = index0;
          }
        else if(REAL_EQUIV(ratio,max_ratio))
          {
          l_elig[nb_elig++] = index0;
        }/* end if(ratio)*/
      }/* end if(ratio)*/
    }/* end if(!TEST_EQUAL)*/
  }/* end for(index0)*/

  if(nb_elig <2)
    (*p_index) = l_elig[0];
  else
    {
    /*| Select the row from the eligible solutions */
    /*  Minimum ratio Ai,j/Ai,col j=1,..n          */
    for(index0=nb_col-3,multiple = TRUE; index0 >= 0; index0--)
      {
      for(index1=0,max_ratio=DBL_MAX; index1 < nb_elig; index1++)
        {
        p_row = &matrix[l_elig[index1]*nb_col];
        if((ratio = p_row[index0]/p_row[col_pivot])< max_ratio)
          {
          max_ratio = ratio;
          (*p_index) = l_elig[index1];
          multiple = FALSE;
          }
        else if(REAL_EQUAL(ratio, max_ratio))
          {
          multiple = TRUE;
          break;
        }/* end if */
      }/* end for(index1)*/
      if(!multiple) break;
    }/* end for(index0) */

    if(multiple)
      {
      /*| Random process */

      (*p_index) = l_elig[find_random(nb_elig)];
    }/* end if(multiple)*/
  }/* end if(nb_elig)*/

  if(!nb_elig) status = NO_SOLUTION;
  return status;
}/* end find_row */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          INTERNAL function find_random                     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

find_random(max_value)
 
  int       max_value;          /* IN     Maximum value for the number        */
  /*
  Description : Returns a random number between 0 and max value. This is a 
                uniform distribution.
  Constraint  : Only use for the Simplex function
  */
  {
  static unsigned int random = 10; /* Random number                           */

  random += (24298 * random + 99991) % 199017;
  return(random % max_value);
}/* end find_random */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            INTERNAL function pivot                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

pivot(array, nb_constr, nb_column, row_pivot, col_pivot)

  double    array[];            /* IN/OUT Pointer to the matrix               */
  int       nb_constr;          /* IN     Number of constraints               */
  int       nb_column;          /* IN     Number of columns                   */
  int       row_pivot;          /* IN     Row to pivot                        */
  int       col_pivot;          /* IN     Column to pivot                     */
  /*
  Description : make the pivotation of the matrix relatively to the selected
                pivot.
  Constraint  : Only use for the Simplex function
  */
  {
  int       index0;             /* Index for a loop                           */
  int       index1;             /* Index for a loop                           */
  double    *p_row1;            /* Row used for pivotation                    */
  double    *p_row2;            /* Row to pivote                              */
  double    ratio;              /* Temporary ratio                            */

  /* Divide the row by the pivot */

  p_row1 = &array[row_pivot*nb_column];
  ratio = p_row1[col_pivot];
  for(index0 = 0; index0 < nb_column; index0++)
    p_row1[index0]/=ratio;
  p_row1[col_pivot]=1.0;

  /* Pivote the other rows */

  for(index0 = 0; index0 <= nb_constr; index0++)
    {
    if(index0 != row_pivot)
      {
      p_row2 = &array[index0*nb_column];
      ratio = p_row2[col_pivot];
      if(!REAL_ZERO(ratio))
        for(index1 = 0; index1 < nb_column; index1++)
          if(!REAL_ZERO(p_row1[index1]))
            p_row2[index1] -= p_row1[index1]*ratio;
      /* end if(!REAL_ZERO)*/
      p_row2[col_pivot]=0.;
    }/* end if(index0)*/
  }/* end for(index0)*/
  return SUCCESS;
}/* end pivot */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

