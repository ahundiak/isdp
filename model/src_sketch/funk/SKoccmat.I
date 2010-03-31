class implementation SKconstraint;

#define DEBUG 0
#define TRUE  1
#define FALSE 0
#define SK_SINGULAR_MATRIX 1

#include <stdio.h>
#include <limits.h>
#include <sys/types.h>
#include <malloc.h>
#include "OMminimum.h"
#include "msdef.h"
#include "SKinc.h"
#include "EMSmsgdef.h"
#include <alloca.h>
#include "bsequat.h"


struct row_struct
{
  int	beg_ptr;
  int   end_ptr;
  int   prev_row;
  int   rowcnt;
  int   btrack;
};

typedef struct row_struct row;

void SKgetsolvepath5 ( msg, varlist, num_constrs, constrs, profile, solvepath )
long                *msg;
struct SKsolvevars  *varlist;
int                 num_constrs;
struct SKconstrinfo **constrs;
struct GRid         profile;
struct SKsolvepath  *solvepath;
{
  struct SKsolvevars  *pvar;
  struct SKconstrinfo *p_constrs;
  struct BSspars_mat  o_matrix;
  int	*matching;
  int	*blocks;
  int 	*col_nos;
  row	*eqn;
  int	i, j;
  int   num_blocks, num_vars, dof;
  int	*eqlist, *vrlist, *inplist, *eqsolv, *eqn_match;
  int   *varids;
  short *varprops;
  int	n, ieqn, ivar;
  short action;
  long  msg_loc, stat_func;

  void  SKbuild_sparse_occ_matrix(), SKsparse_setup(),
        SKbip_matching(), SKdecompose(), SKadd_solvepath();

  *msg = EMS_S_Success;
  stat_func = OM_S_SUCCESS;

  /* count the number of variables */
  num_vars = 0;
  for (pvar = varlist, num_vars = 0; pvar; pvar = pvar->next, num_vars++);

  p_constrs = *constrs;

#if DEBUG
  printf("Number of variables = %d\n", num_vars);
  printf("Number of constraints = %d\n", num_constrs);
#endif

  /* 
   * Store the varids and varprops in arrays for future use
   */
  varids = (int *) alloca (num_vars*sizeof(int));
  varprops = (short *) alloca (num_vars*sizeof(short));
  
  pvar = varlist;
  for (i = 0; i < num_vars; i++)
  {
     varids[i] = pvar->varobj;
     varprops[i] = pvar->props;
     pvar = pvar->next;
  }

  /*
   * If the profile is OVERCONSTRAINED ... make one big strong component
   */

  if (num_constrs > num_vars)
  {
    /* *msg = EMS_I_Redundant;  we should set this ... but there is a bug in SKcompute*/
    solvepath->constrs = (struct SKconstrinfo *) malloc(num_constrs*sizeof(struct SKconstrinfo));
    solvepath->action = (short *) malloc (num_constrs * sizeof(short));
    EMerr_hndlr (!solvepath->constrs || !solvepath->action, *msg,
                 EMS_E_NoDynamicMemory, ret_end);
    solvepath->num_constrs = 0;
    for (i = 0; i < num_vars; i++)
    {
      solvepath->action[solvepath->num_constrs] = PATH_SIMULCONSTR;
      solvepath->constrs[solvepath->num_constrs] = p_constrs[i];
      solvepath->constrs[solvepath->num_constrs].varsolveid = varids[i];
      solvepath->constrs[solvepath->num_constrs].vprops = varprops[i];
      solvepath->num_constrs++;
    }
    for (i = num_vars; i < num_constrs; i++)
    {
      solvepath->action[solvepath->num_constrs] = PATH_SIMULCONSTR;
      solvepath->constrs[solvepath->num_constrs] = p_constrs[i];
      solvepath->constrs[solvepath->num_constrs].varsolveid = NULL_OBJID;
      solvepath->constrs[solvepath->num_constrs].vprops = NULL;
      solvepath->num_constrs++;
    }
    goto ret_end;
  }

  dof = num_vars - num_constrs;

  /*
   * If the profile is underconstrained, 
   * create NULL objects for the dummy constraints at the end.
   */

  if (dof > 0) {
     /* printf("Profile has %d degrees of freedom\n", dof);  */
     if (num_constrs)
        *constrs = (struct SKconstrinfo *) om$realloc (
                    ptr = (char *) p_constrs,
                    size = num_vars * sizeof (struct SKconstrinfo));
     else
        *constrs = (struct SKconstrinfo *) om$malloc (size = num_vars *
                    sizeof (struct SKconstrinfo));
     EMerr_hndlr (!constrs, *msg, EMS_E_NoDynamicMemory, ret_end);
     p_constrs = *constrs;

     for (i = num_constrs; i < num_vars; i++) {
        p_constrs[i].constrid = NULL_OBJID;
        p_constrs[i].cprops = NULL;
     }
  }

  /* 
   *  Allocate space for solvepath ... Allocate space for num_vars entries
   *  even though there are only num_constrs.  Extra space required for
   *  dummy constraints
   */
  solvepath->constrs = (struct SKconstrinfo *) malloc(num_vars*sizeof(struct SKconstrinfo));
  solvepath->action = (short *) malloc(num_vars*sizeof(short));
  EMerr_hndlr (!solvepath->constrs || !solvepath->action, *msg,
               EMS_E_NoDynamicMemory, ret_end);

  solvepath->num_constrs = 0;

  /*
   * Check if the profile is UNCONSTRAINED (no constraints) ... 
   * if so just make one strong component
   */
  if (num_constrs == 0) 
  {
    *msg = EMS_I_UnderConstrained;
    for (i = 0; i < num_vars; i++)
    {
      solvepath->action[solvepath->num_constrs] = PATH_SIMULCONSTR;
      solvepath->constrs[solvepath->num_constrs] = p_constrs[i];
      solvepath->constrs[solvepath->num_constrs].varsolveid = varids[i];
      solvepath->constrs[solvepath->num_constrs].vprops = varprops[i];
      solvepath->num_constrs++;
    }    
    goto ret_end;
  }

  /*
   * The profile is UNDERCONSTRAINED or FULLY CONSTRAINED.
   * Build the sparse occurrence matrix.
   */
  SKbuild_sparse_occ_matrix ( &msg_loc, profile, p_constrs, varlist, 
                              num_constrs, num_vars, &o_matrix);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Set up the temporary workspaces.
   */
  vrlist    = (int *) alloca (num_vars*sizeof(int));
  eqlist    = (int *) alloca (num_vars*sizeof(int));
  inplist   = (int *) alloca (num_vars*sizeof(int));
  eqsolv    = (int *) alloca (num_vars*sizeof(int));
  matching  = (int *) alloca (num_vars*sizeof(int));
  eqn_match = (int *) alloca (num_vars*sizeof(int));
  blocks    = (int *) alloca (num_vars*sizeof(int));
  EMerr_hndlr (!vrlist || !eqlist   ||
               !inplist   || !eqsolv || !matching ||
               !eqn_match || !blocks, *msg,
               EMS_E_NoDynamicMemory, ret_end);

  memset(inplist,0,num_vars*sizeof(int));
  memset(eqsolv,0,num_vars*sizeof(int));

  /* 
   * Allocate space for the sparse matrix format of the
   * occurrence matrix.
   */
  eqn = (row *) alloca (num_vars*sizeof(row));
  col_nos = (int *) alloca ( o_matrix.nbcoef * sizeof(int));
  EMerr_hndlr (!eqn || !col_nos, *msg, EMS_E_NoDynamicMemory, ret_end);

  /*
   * Convert the BSsparse matrix format into a local format.  This is really
   * unnecessary ... but all the decomposition code needs to be modified
   * if we have to use the BS format.  
   */
  SKsparse_setup (num_vars, &o_matrix, eqn, col_nos);

  /*
   * Initialize pointers to keep track of sub-matrices
   */
  for (i = 0; i < num_vars; i++)
  {
     vrlist[i] = i;
     eqlist[i] = i;
  }

  /*
   *  Find if there are any solve sets in the current matrix.
   *  This processing will determine the fully determined part of the profile.
   */

  SKbip_matching(&msg_loc, num_vars, col_nos, eqn, matching);
  
  /* 
   * Check for a structural singularity ... if so make one big strong component
   */
  if (msg_loc == SK_SINGULAR_MATRIX)
  {
    *msg = EMS_I_Fail;
    for (i = 0; i < num_vars; i++)
    {
      solvepath->action[solvepath->num_constrs] = PATH_SIMULCONSTR;
      solvepath->constrs[solvepath->num_constrs] = p_constrs[i];
      solvepath->constrs[solvepath->num_constrs].varsolveid = varids[i];
      solvepath->constrs[solvepath->num_constrs].vprops = varprops[i];
      solvepath->num_constrs++;
    }
  }
  else
  {
    SKdecompose(num_vars, col_nos, eqn, matching, &num_blocks, blocks);

    SKadd_solvepath(num_vars, num_vars, eqn, num_blocks, blocks, matching,
                    eqn_match, vrlist, eqlist, 
                    inplist, eqsolv, dof, p_constrs, varids, varprops,
                    solvepath);

    /* 
       If the profile is underconstrained, put the remaining constraints 
       and variables in one big strong component.  The dummy constraints
       (with NULL_OBJID) will automatically go to the end.
    */
    if (num_vars > num_constrs) 
    {
        n = 0;
        for (i = 0; i < num_vars; i++)
           if (inplist[i] == 0)
              vrlist[n++] = i;
        n = 0;
        for (i = 0; i < num_vars; i++)
           if (eqsolv[i] == 0)
              eqlist[n++] = i;
              
        if (solvepath->num_constrs)
     	    action = solvepath->action[solvepath->num_constrs - 1];
        else
            action = PATH_EVALCONSTR;

        action = (action == PATH_SIMULCONSTR ? PATH_OSIMULCONSTR : PATH_SIMULCONSTR);
        for (i = 0; i < n; i++)
        {
           ivar = vrlist[i];
           ieqn = eqlist[i];
           solvepath->action[solvepath->num_constrs] = action;
           solvepath->constrs[solvepath->num_constrs] = p_constrs[ieqn];
           solvepath->constrs[solvepath->num_constrs].varsolveid = varids[ivar];
           solvepath->constrs[solvepath->num_constrs].vprops = varprops[ivar];
           solvepath->num_constrs++;
        }   
    }
  }

  if (num_vars > num_constrs)
    *msg = EMS_I_UnderConstrained;
  else
    *msg = EMS_I_FullyConstrained;

  free (o_matrix.indxrow);
  free (o_matrix.indxcol);

ret_end:
  EMWRAPUP (*msg, stat_func, "SKsolvepath5");
  return;
}

/**************************************************************************
 * This routine builds the occurrence matrix in a sparse format
 * associated with the profile passed as an argument.  It also adds the rows
 * for the dummy constraints (in case of an underconstrained system).  
 **************************************************************************/

void SKbuild_sparse_occ_matrix (msg, profile, constrs, varlist, num_constrs, num_vars,
                                o_matrix)
long   *msg		     /* Return message 		OUT */;
struct GRid         profile  /* The profile 		IN  */;
struct SKconstrinfo *constrs /* The constraints		IN  */;
struct SKsolvevars  *varlist /* The variables		IN  */;
int    num_constrs           /* The number of const.	IN  */;
int    num_vars		     /* number of variables.    IN  */;
struct BSspars_mat *o_matrix /* The occurrence matrix   OUT */;
{
  int                i,j, index;
  long               msg_loc, stat_func;
  struct SKsolvevars *pvar;
  char               filename[20];
  FILE               *datfile;
  
  *msg = EMS_S_Success;
  stat_func = OM_S_SUCCESS;
  
  o_matrix->nbrow = num_constrs;
  o_matrix->nbcol = num_vars;
  o_matrix->nbcoef = 0;
  
  SKgetadjvars ( &msg_loc, NULL, varlist, num_constrs, constrs, profile.osnum );
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  o_matrix->allocm = 0;
  for (i = 0; i < num_constrs; i++)
    o_matrix->allocm += constrs[i].num_adjvars;
    
  /*
   * If the profile is underconstrained, bump-up the num_constrs and increase
   * the space for coefficients (rows of 1's).  This will result in a square
   * occurrence matrix.
   */
  
  if (num_vars > num_constrs)
  {
    o_matrix->allocm += (num_vars - num_constrs) * num_vars;
    o_matrix->nbrow = num_vars;
  }
  
  o_matrix->indxcol = (int *) malloc (o_matrix->allocm * sizeof(int));
  o_matrix->indxrow = (int *) malloc ((o_matrix->nbrow + 1) * sizeof(int));

  /*
   * for each constraint, we get the variables it is connected to
   */
  for (i = 0; i < num_constrs; i++)
  {
#if DEBUG
    printf ( "%d variables are connected to constraint %d: ", 
             constrs [i].num_adjvars, constrs [i].constrid );
    for (j = 0; j < constrs [i].num_adjvars; j++)
    {
      printf ( "%d", constrs [i].adjvars [j]->varobj );
      if (constrs [i].adjvars [j]->props & VAR_VAL)
        printf ( ".V " );
      else if (constrs [i].adjvars [j]->props & VAR_X)
        printf ( ".X " );
      else if (constrs [i].adjvars [j]->props & VAR_Y)
        printf ( ".Y " );
      else
        printf ( ".? " );
    }
    printf ( "\n" );
#endif

    o_matrix->indxrow[i] = o_matrix->nbcoef;
    
    /* compute the index of each variable */
    for (j = 0; j < constrs [i].num_adjvars; j++)
    {
      for (pvar = varlist, index = 0; pvar; pvar = pvar->next, index++)
        if (constrs [i].adjvars [j] == pvar)
          break;
      if (pvar)
      {
        o_matrix->indxcol[o_matrix->nbcoef] = index;
     	o_matrix->nbcoef++;
      }
      else
        fprintf ( stderr, "FATAL BUGCHECK in file %s at line %d, variable not in the list\n",
                  __FILE__, __LINE__ );
    }
  }

  /*
   * Add any dummy rows of 1s if the profile is underconstrained.
   */
  if (num_vars > num_constrs)
  {
    for (i = num_constrs; i < num_vars; i++)
    {
      o_matrix->indxrow[i] = o_matrix->nbcoef;
      for ( j = 0; j < num_vars; j++)
      {
        o_matrix->indxcol[o_matrix->nbcoef] = j;
        o_matrix->nbcoef++;
      }
    }
  }
  
  /*
   * Store the final number of entries in the last indxrow.
   */
  o_matrix->indxrow[o_matrix->nbrow] = o_matrix->nbcoef;

#if DEBUG
  printf ("File _: ");
  scanf ("%s", filename);
  if (filename[0] == '.')
    datfile = stderr;
  else
    datfile = fopen (filename, "w");
  if (!datfile)
    return;

  datfile = stderr;
  fprintf(datfile, "%d\n", num_vars);
  fprintf(datfile, "%d\n", num_constrs);

  for (i=0; i < o_matrix->nbrow; i++)
  {
    fprintf(datfile, "row %d : begin %d : end %d\n", i, o_matrix->indxrow[i],
            o_matrix->indxrow[i+1]);
    for (j = o_matrix->indxrow[i]; j < o_matrix->indxrow[i+1]; j++)
      fprintf(datfile, "%d ", o_matrix->indxcol[j]);
    fprintf(datfile,"\n");
  }
  if (datfile != stderr) 
    fclose(datfile);
#endif

ret_end:
  EMWRAPUP (*msg, stat_func, "SKbuild_sparse_occ_matrix");
  return;
}
     
/*******************************************************************
 * Convert the BSsparse matrix structure into a local form suitable
 * for decomposition.
 *******************************************************************/

void SKsparse_setup(n, o_matrix, eqn, col_nos)
int 			n 		/* Number of rows  (IN) */;
struct BSspars_mat 	*o_matrix  	/* Sparse matrix (IN) */;
row 			eqn[]  		/* Local format of the sparse matrix (OUT) */;
int 			col_nos[] 	/* Coefficients  (OUT) */;
{
   int  i, j;

   /*
     Convert the sparse matrix to a Row-wise Representation
     Complete and Ordered (RRCO) form
   */

   for (i = 0; i < n; i++)
   {
     eqn[i].beg_ptr = o_matrix->indxrow[i];
     eqn[i].end_ptr = o_matrix->indxrow[i+1] - 1;
   }
	
   for (i = 0; i < o_matrix->nbcoef; i++)
     col_nos[i] = o_matrix->indxcol[i];
}

/**********************************************************************
 * Add the strong components found to the solvepath.
 **********************************************************************/

void SKadd_solvepath(n, num_vars, eqn, num_blocks, blocks, matching, 
                     eqn_match, vrlist, eqlist, 
                     inplist, eqsolv, dof, constrs, varids, varprops,
                     solvepath)
int    n, num_vars;
row    eqn[];
int    num_blocks;
int    blocks[];
int    matching[];
int    eqn_match[];
int    vrlist[];
int    eqlist[];
int    inplist[];
int    eqsolv[];
int    dof;
struct SKconstrinfo *constrs;
int    varids[];
short  varprops[];
struct SKsolvepath  *solvepath;
{
   int b1, b2;
   int i,j;
   int action, ieqn, ivar;

   /* Convert column matching into row matching */
   memset(eqn_match, -1, num_vars*sizeof(int));
   for(i=0; i<n; i++)
      eqn_match[eqlist[matching[i]]] = vrlist[i];

#if DEBUG
   /* print out the decomposition */
   printf("%d strong component(s) found\n",num_blocks);
#endif

   /* determine the last action */
   if (solvepath->num_constrs)
      action = solvepath->action[solvepath->num_constrs - 1];
   else
      action = PATH_EVALCONSTR;

   for(i = 0; i < num_blocks; i++)
   {
      b1 = blocks[i];
      /*
        If the matrix was underconstrained, junk the last block
      */
      if (i == num_blocks-1)
         if (dof > 0) 
            break;
         else
            b2 = n;
      else
         b2 = blocks[i+1];

#if DEBUG
      printf("Block %d has %d equation(s)\n",i,(b2-b1));
#endif

      if ( (b2-b1) == 1)
         /* single equation */
         action = PATH_EVALCONSTR;
      else 
         /* toggle the action if the next one is simultaneous set */
         action = (action == PATH_SIMULCONSTR ? PATH_OSIMULCONSTR : PATH_SIMULCONSTR);

      for(j = b1; j < b2; j++) 
      {
         /* the actual equation number is stored in eqn.rowcnt field */
         ieqn = eqlist[eqn[j].rowcnt];
         ivar = eqn_match[ieqn];
         eqsolv[ieqn] = 1;
         inplist[ivar] = -1;

#if DEBUG
  	 printf("\tEquation %d  Variable %d\n", ieqn, ivar);
#endif

         solvepath->action[solvepath->num_constrs] = action;
         solvepath->constrs[solvepath->num_constrs] = constrs[ieqn];
         solvepath->constrs[solvepath->num_constrs].varsolveid = varids[ivar];
         solvepath->constrs[solvepath->num_constrs].vprops = varprops[ivar];
         solvepath->num_constrs++;
      }
#if DEBUG
      printf("\n");
#endif
   }
}

/*****************************************************************
 * This routine performs the BIPARTITE matching 
 *****************************************************************/

void SKbip_matching(msg, n, col_nos, eqn, matching)
long    *msg		/* Return message  				OUT */;
int	n		/* Number of rows/columns 			IN */;
int     col_nos[]	/* Column positions in a sparse form  		IN */;
row	eqn[]		/* Structure to keep track of beg/end of rows  	IN */;
int	matching[]	/* Matching of the rows and columns   		OUT  */;
{
        long    stat_func;
	int	i,j,k,j1,curr_row,column,irow;
	int	cheap, singular, chain_extended;
	int	*column_visited;
	int     match_num;

        *msg = EMS_S_Success;
        stat_func = OM_S_SUCCESS;

	/* initializations */
        column_visited = (int *) alloca (n*sizeof(int));
        EMerr_hndlr (!column_visited, *msg, EMS_E_NoDynamicMemory, ret_end);

	match_num = 0;

	for(i=0; i<n; i++)
	{
	   matching[i] = -1;
	   eqn[i].rowcnt = eqn[i].end_ptr - eqn[i].beg_ptr;
	   column_visited[i] = -1;
        }

	/*
         * Main assignment loop ... works one row at a time
         */
	for (k = 0; k < n; k++)
	{
	   cheap = FALSE;
           singular = FALSE;
	   curr_row = k;
	   eqn[curr_row].prev_row = -1;
	   /* 
            * assignment extension loop ... preserves the (k-1)
            * matchings and adds one.
	    */
	   for (i = 0; i <= k; i++)
	   {
              if (cheap || singular) break;
	      /*
               * look for a cheap assignment. find an unassigned
               * non-zero column in the current row.
               */
	      for (j = eqn[curr_row].end_ptr - eqn[curr_row].rowcnt;
	           j <= eqn[curr_row].end_ptr; j++) 
	      {
                 column = col_nos[j];
	         if (matching[column] == -1)
	         {
		    /*
 		     * cheap assignement found ... store it
                     */
		    /* printf("cheap ass found for %d\n", curr_row); */
	            cheap = TRUE;
		    match_num++;
	            matching[column] = curr_row;     /* column matching */
	            /*
	             * reset the look ahead pointer to the first
	             * unexplored node in that row.
	             */
		    eqn[curr_row].rowcnt = eqn[curr_row].end_ptr - j - 1;
	            /* 
	             * if this match was done by an assignment chain,
	             * then reset the previous matchings
	             */
	            while (eqn[curr_row].prev_row != -1) 
	            {
	               curr_row = eqn[curr_row].prev_row;
                       matching[col_nos[eqn[curr_row].end_ptr - eqn[curr_row].btrack - 1]] = curr_row;
		    }
		    /* 
                     * skip the internal loop and go for next assignment
                     */
		    break;
                 }
              }
              /* 
               * cheap assignment was not found ... have to build a chain.
               */
	      if (!cheap) 
	      {
                 /* printf("no cheap ass found for %d\n", curr_row); */
	      	 eqn[curr_row].rowcnt = -1;
                 /* 
  		  * Initialize the counter for unscanned columns in the row.
                  */
	      	 eqn[curr_row].btrack = eqn[curr_row].end_ptr - eqn[curr_row].beg_ptr;
	      	 for (irow=0; irow < k; irow++) 
	      	 {
	            /*
	             * scan along the row to get a link
	             */
		    chain_extended = FALSE;
	      	    for (j = eqn[curr_row].end_ptr - eqn[curr_row].btrack;
	      	         j <= eqn[curr_row].end_ptr; j++) 
	      	    {
	      	    	column = col_nos[j];
	      	    	/*
	      	    	 * if the column has not been accessed ... add it
	      	    	 * to the chain.  
	      	    	 */
	      	    	if (column_visited[column] != k) 
	      	    	{
		           eqn[curr_row].btrack = eqn[curr_row].end_ptr - j - 1;
	      	    	   j1 = curr_row;
	      	    	   curr_row = matching[column];
	      	    	   column_visited[column] = k;
	      	    	   eqn[curr_row].prev_row = j1;
			   chain_extended = TRUE;
	      	    	   break;
	      	        }
	      	    }
		    if (chain_extended) 
   		       /* 
                        * If a new extension was found .. go back to look
                        * for any cheap assignment in that row
                        */
                        break;
	      	    else 
	      	    {
                       /*
	      	        * no extension found ... have to backtrack 
	      	        */
		       /* printf("dead end ... backtracking\n"); */
	      	       curr_row = eqn[curr_row].prev_row;
	      	       if (curr_row == -1) 
	      	       {
                          /* no room to backtrack ... singular matrix */
                          singular = TRUE;
                          break;
                       } 
                    }
	      	 }
              }
           }  
        }

	/* 
         * If the matrix is structurally singular, then complete
         * the match
         */
        if (match_num < n) 
        {
           *msg = SK_SINGULAR_MATRIX;
	   /* printf("matrix is structurally singular\n");  */
	   for (i=0; i<n; i++)
		eqn[i].rowcnt = -1;
	   /*
	    * Find the columns that are still unmatched
	    */
	   k = -1;
	   for (i=0; i<n; i++) 
	   {
	      if (matching[i] == -1) 
	      {
		 /* printf("x[%d] is still unmatched\n",i);  */
	      	 k++;
	      	 eqn[k].btrack = i;
	      } 
	      else 
	      {
	      	 j = matching[i];
	      	 eqn[j].rowcnt = i;
	      }
	   }
	   /* 
	    * Assign the unmatched rows to unmatched columns
	    */
	   k = -1;
	   for (i=0; i < n; i++) 
	   {
	      if (eqn[i].rowcnt == -1) 
	      {
		 /* printf("f[%d] is still unmatched\n",i);  */
	      	 k++;
	      	 matching[eqn[k].btrack] = i;
	      }
	   }
        }

ret_end:
  EMWRAPUP (*msg, stat_func, "SKbip_matching");
  return;
}

/*********************************************************************
 *
 * This routine determines the strong components in a matrix that has
 * been matched (i.e. has a zero-free diagonal form).
 * 
 *********************************************************************/

void SKdecompose(n, col_nos, eqn, matching, num_blocks, block_pos)
int	n;
int	col_nos[];
row	eqn[];
int	matching[];
int	*num_blocks;
int	block_pos[];
{
	int	i,j,k;
	int	n2m1;
	int	node, irow, curr_row, next_row;
	int	block_loc, stack_ptr, rows_assigned;
	int	done, new_node;

	int *stack_pos = (int *) alloca(n*sizeof(int));
	memset(stack_pos, -1, n*sizeof(int));

	n2m1 = n+n-1;
	rows_assigned = 0;
	*num_blocks = 0;

	for (i = 0; i < n; i++)
	   eqn[i].rowcnt = eqn[i].end_ptr - eqn[i].beg_ptr;

	/* 
         * Main loop .. works one row at a time ... same as node
         * by node.
         */
        done = FALSE;
        for (node=0; node < n; node++)
        {
	   irow = matching[node];
           if (done)
              break;
	   /* 
            * Check if the current node is already on the stack
            * or has been assigned
	    */
           if (stack_pos[irow] == -1) 
           {
	      /* printf("row %d added to the stack\n", irow);  */
              curr_row = irow;
              stack_ptr = 0;
              stack_pos[curr_row] = 0;
	      eqn[curr_row].btrack = 0;  /* lowlink pointer */
	      block_pos[n-1] = curr_row;  /* works from the other end */

	      /* 
	       * Try to add another entry to the stack or backtrack
	       */
	      for (j = 0; j < n2m1; j++)
              { 
                 new_node = FALSE;
  	         for (k = eqn[curr_row].end_ptr - eqn[curr_row].rowcnt;
                      k <= eqn[curr_row].end_ptr; k++)
                 {
		    next_row = matching[col_nos[k]];
		    /*
		     * Is this a new row ... never been on the stack?
		     */
		    if (stack_pos[next_row] == -1) 
		    {
	      		/* printf("row %d added to the stack\n", next_row); */
			eqn[curr_row].rowcnt = eqn[curr_row].end_ptr - k - 1;
			eqn[next_row].prev_row = curr_row;
			curr_row = next_row;
			stack_ptr++;
			stack_pos[curr_row] = stack_ptr;
			eqn[curr_row].btrack = stack_ptr;
			block_pos[n-1-stack_ptr] = curr_row;
			new_node = TRUE;
			break;
		    }
		    else
		    {
		       /* 
		        * Update the lowlink pointer if necessary
		        */
		       if (eqn[next_row].btrack < eqn[curr_row].btrack)
		           eqn[curr_row].btrack = eqn[next_row].btrack;
		    }
		 }
		 if (!new_node) 
		 {
		    /*
		     * the stack was not extended
		     */
		    eqn[curr_row].rowcnt = -1;
		    
		    /*
		     * check if the curr_row is the start
		     * of a strong component (block)
		     */
		    if (eqn[curr_row].btrack == stack_pos[curr_row])
		    {
			/* printf("block %d found\n",*num_blocks); */
			block_loc = rows_assigned;
			/* 
			 * Peel off the block from the top of the stack
			 * starting at the top to the start
			 */
			for (k = n-1-stack_ptr; k < n; k++)
			{
			   next_row = block_pos[k];
			   /* printf("row %d belongs to this block\n",next_row); */
			   eqn[next_row].btrack = n+1;
			   /* 
			     store the row permutation
			   */
			   stack_pos[next_row] = rows_assigned;
			   rows_assigned++;
			   if (next_row == curr_row) 
			      break;
			}
			/* 
			 record the correct position of the block
			*/
			block_pos[*num_blocks] = block_loc;
		    	(*num_blocks)++;
		        stack_ptr = n - 2 - k;

			/* all rows assigned ? */
			if (rows_assigned == n) 
		        {
		           done = TRUE;
			   break;
		        }
		     }
		     /* is the stack empty ?  */
		     if (stack_ptr == -1)
		        break;
		     
		     /* backtrack to a previous row */ 
		     next_row = curr_row;
		     curr_row = eqn[curr_row].prev_row;
		     if (eqn[next_row].btrack < eqn[curr_row].btrack)
		        eqn[curr_row].btrack = eqn[next_row].btrack;
		}
	      }
           }
	}

	/* Return the row permutation giving the new location of the rows */
	for (i=0; i<n; i++)
	   eqn[stack_pos[i]].rowcnt = i;

}

end implementation SKconstraint;
