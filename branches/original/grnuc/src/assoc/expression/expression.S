/*

Name
  expression.S

Description

   This class is an abstract class for object having a value.
   In the following methods, a return code  different from EXP_SUCCESS means
   that the job has not been done.

Notes


 */

/*
   ABSTRACT :
   --------

   This class is an abstract class for object having a value.
   In the following methods, a return code  different from EXP_SUCCESS means
   that the job has not been done.


   HISTORY :
   -------

   01/11/1985 : AF - Design Date
   06/18/1987 : SF - Misc. modifications (sic)
   12/16/1987 : HGB - New node support
*/


class specification expression (0:1) of NDnodein, GRvg;

  instance expression 
  {
    variable char      	pretty_print [1];  /* for screen EQN_display   */
    IGRdouble           value           ;  /* current value        */
  }; 
#ifndef BASE_EMS

  override GRvg;

  override 
	NDcompute_node,   /* standard node message */
	NDparent_deleted, /* to transform the name of a delted parent into its value */
	NDprint, 	/* graph printer message */
	NDplace, 	/* ci message:  place(name, syntax) */
	NDprint_root, 	/* graph printer message */
	NDgive_structure, /* return the structure of the object		  */
        NDdisplay,	/* EQN_display an expression */
	NDmove_to_root,	/* to make a constant of myself */ 
	NDcopy_to_root,	/* to copy to a root one	*/
        ACcopy_to_Groot,/* copy to root expression WITH THE TO_OWNER CHANNEL */
	GRdelete,       /* does a wait batch delete */
	NDmake_source,  /* connection on notify channel across OS */
        ASreturn_go;  

override 
  GRdisyourself,        /* Just do nothing */
  GRaddwrng,            /* Just do nothing */
  GRremwrng,            /* Just do nothing */
  GRlnproject,          /* Just do nothing */
  GRxform,              /* Just do nothing */
  GRdelete,             /* call wait_batch (type = deleted */
  GRcopy,               /* copy to non associative (ie constant) */
  GRgetobjinfo,         /* UI status when located */


/* The following messages are overridden beacuse the instance data for 
   GRvg has been rejected. The following messages will now simply return success
   instead of altering GRvg data(display_attr).
*/
   GRchgcolor,          /* Just do nothing */
   GRchgdp,             /* Just do nothing */
   GRchgstyle,          /* Just do nothing */   
   GRchgweight,         /* Just do nothing */
   GRputsymb,           /* Just do nothing */

/* following message accesses GRvg data. It will now return default
   values.
*/
   GRgetsymb;         


message DMgive_src_geometry (IGRlong *msg;
                             IGRshort *mattyp; IGRmatrix mat;
                             IGRint orig_parent_type;
                             struct DMgeom_info *orig_parent_info;
                             IGRint meas_parent_type;
                             struct DMgeom_info *meas_parent_info);
/*
  DESCRIPTION

    This message is used by an attached dimension to interrogate this
    constraint object about the geometry that it must be dimensioning.
    This way the dimension can be associative on virtual geometry, known
    only to this constraint object.

  HISTORY

    SS  :  04/04/91  :  Creation
*/


message DMgive_plane_matrix (IGRlong *msg;
                             IGRshort *mattyp; IGRmatrix mat;
                             IGRmatrix plane_matrix);
/*
  DESCRIPTION

    This message is used by an attached dimension to interrogate this
    constraint object about the dimension plane. The matrix being returned,
    in fact, constitutes a co-ordinate system, the plane being implied
    is the x-y plane. This way the dimension can be associative on a virtual
    plane, known only to this constraint object.

  HISTORY

    SS  :  04/04/91  :  Creation
*/

  
  message make_orphan();


/*
   The following messages are PUBLIC.
*/

  message NDgive_value( double *val );
  /* ABSTRACT
          return value of an element. Message understood by expression and
	  pretend. Is a sub message of give_structure.

     ARGUMENT
     OUT val : returned value
  */

  message NDset_value(char *name; double val; struct GRmd_env *md_env;
                      IGRshort *rc);
 /* ABSTRACT
	  set the value of an element. Message understood by expression anda
          pretend.

    ARGUMENTS
    I name   : name of the element : No longer used.
    I val    : value of the element
    I md_env : module environnement.
    O rc     : return code.
*/


  message create( IGRchar *name; IGRchar *expr ; IGRshort *rc );
    /*

       Actually fills the instance data, after checking the validity 
       of the input expression.

       Argument description :
       --------------------

         IGRchar  *name	: The name of the expression to be created.

         IGRchar  *expr	: The syntax of the expression to be created.

         IGRshort *rc	: The returned status

			   EXP_SUCCESS         : expression.has been created
   			   EXP_ALREADY_EXISTS  : expression already exists
			   EXP_UNDEF_RHS       : expression depends upon an 
                                                 undefined var or parm
			   EXP_INV_CHAR        : expression contains an 
                                                 invalid character
			   EXP_SYNTAX_ERROR    : expression is not 
						 syntaxically correct
			   EXP_EVAL_ERROR      : expression cannot be 
 		      			         evaluated
    */


  message modify( IGRchar *name; IGRchar *syntax ; IGRshort *rc );
    /*

       Checks the validity of the new expression before breaking the former  con-  
       nections and making new ones, then runs method recompute.                   
       E.g. to modify  alpha = 3*a - 4 into alpha = 4*a - 4, send the message  to  
       alpha "modify( "alpha"," 4*a - 4", &Rc )"                                   

       Argument description :
       --------------------

         IGRchar  *name	: The name of the expression to be modified.

         IGRchar  *expr	: The syntax of the expression to be modified.

         IGRshort *rc	: The returned status
			   EXP_SUCCESS         : expression.has been modified
			   EXP_INV_CHAR        : expression contains an 
						 invalid character
			   EXP_SYNTAX_ERROR    : expression is not 
						 syntaxically correct
			   EXP_UNDEF_RHS       : expression depends upon an
						 undefined var or parm 
			   EXP_RECUR_DEF       : expression depends upon
						 itself
			   EXP_EVAL_ERROR      : expression cannot be
						 re-evaluated
    */



  message give_formula( IGRchar *formula );
    /*

       Returns the formula of an expression.                                                

       Argument description :
       --------------------

         IGRchar  *formula	: The formula of the expressions,
                                  an array of size EXP_MAX_LEN
    */


  message give_recursive_formula
		        (struct GRid *macro_id; IGRchar *formula; IGRint len );

  message list( IGRchar *formula );
    /*

       Returns the formula of an expression.                                                

       Argument description :
       --------------------

         IGRchar  *formula	: The formula of the expressions,
                                  an array of size EXP_MAX_LEN
    */

  message DIgive_output( char *out_s);

  /* ABSTRACT

  This message is sent with a "make_message to the expression

  ARGUMENTS

  out_s   I  : The name of the expression
          O  : the name of the expression concatenated with its syntax
  */
  
  message DIput_edit_string ( char *string );
  /*
   * The purpose of this method is to support the directory command form
   * as an edit capability. This message will be sent by the form when
   * the user has modified the string returned by DIget_edit_string. In
   * order word, these 2 methods (DIget_... and DIput_...) allows expressions
   * to support syntaxic modification from the form.
   * Note that any class can support these two messages.
   *
   * ARGUMENTS
   * 
   * char *string: the string entered by the user	IN   
   */

   message DIget_edit_string ( char *string );
   /*
    * The purpose of this method is to support the directory command form
    * as an edit capability. This message will be sent by the form when
    * the form wants to give the user an editable string.
    *
    * ARGUMENTS
    *
    * char *string: the string representing my syntax	OUT
    */

    message init_expr_var ();
    /*
     * This method initiallizes the new created expression object.
     * The "pretty_print" is set to NULL, the state is set to 
     * "ND_UNDERCONSTR".
     *
     * ARGUMENTS: None
     *
     */


    message visit_eqn ( struct GRid eqn_list[]; int *peqn_count);

    /*
     * This method marks an expression as visited during traversal
     * to find matching.
     *
     * ARGUMENTS: 
     * eqn_list: list of expressions visited so far
     * peqn_count: count of expressions visited so far
     *
     */


    message is_var_matched (IGRboolean *ptr_is_matched);

    /*
     * If "pretty_print" is of zero length, var is unmatched.
     * 
     *
     * ARGUMENTS: 
     * 
     * *ptr_is_matched: TRUE if var is matched to expression
     *
     */

    message find_match(IGRboolean *pmatch_found; IGRboolean *pcycle_formed;
                       struct GRid eqn_list[]; int *peqn_count;
       	               struct GRid match_list[]; int *pnum_matched);
    /*
     * Recursively traverse variables and expressions in DFS manner to
     * match variables to equations.
     *
     * ARGUMENTS:
     *
     * IGRboolean *pmatch_found - Was a match found for var
     * IGRboolean *pcycle_formed - did a cycle form during matching
     * struct GRid eqn_list[] - list of equations visited so far
     * int *peqn_count - number of eqns visited
     * struct GRid match_list[] - eqns matched so far
     * int *pnum_matched - number of eqns matched so far
     *  
    */

    message match(struct GRid curr_var_grid; int num_parent; 
                  struct GRid parent_grid[]; char *exp_syntax; 
                  IGRboolean from_reset_match;
                  IGRboolean *pcycle_formed;
		  struct GRid match_list[]; int *pnum_matched);

    /*
     * Matches an expression to a variable.
     *
     * ARGUMENTS:
     *
     * struct GRid curr_var_grid - the variable that the eqn is matched to
     * int num_parent - number of parents
     * struct GRid parent_grid[] - the parents of the expression
     * char *exp_syntax - the expression to be matched
     * IGRboolean from_reset_match - Is this routine being called to reset the match
     * IGRboolean *pcycle_formed - did a cycle form
     * struct GRid match_list[] - expressions matched so far
     * int *pnum_matched - number matched so far
     *
     */




  message convert_to_new_syntax ();
  /*
   * This message converts the syntax of the expression from <rhs> to
   * <lhs>=<rhs>. This message is needed for "on demand" conversion
   * after 2.0 and before 3.0.
   */


  message give_syntax (char *exp_syntax);
  /*
   * This message returns the syntax of the expression.
   *
   * ARGUMENTS:
   *
   * char *exp_syntax: The syntax of the expression.
   */


  message put_syntax (char *exp_syntax);
  /*
   * This message EQN_assigns a new syntax to the expression.
   *
   * ARGUMENTS:
   *
   * char *exp_syntax: The syntax of the expression.
   */


  message put_value (double value);
  /*
   * This message EQN_assigns a new value to the variable.
   *
   * ARGUMENTS:
   *
   * double value: The value of the variable
   */


  message build_jacob_row(long *pmsg_loc; int row_num; int cyc_count;
                          struct GRid cyc_grid[]; struct BSspars_mat *pjacobian; 
                          double *pfuncval);

/*
 *  The following method builds one row of the jacobian and also computes
 *  the value of the funcval for that row.
 *
 * ARGUMENTS:
 *
 * long *pmsg_loc: return status of the message
 *
 * int row_num: the row of the jacobian to be built
 *
 * int cyc_count: num of GRid's in the strong component
 *
 * struct GRid cyc_grid[]: the GRid's in the strong component
 *
 * struct BSspars_mat *pjacobian: the sparse jacobian
 *
 * double *pfuncval: The value of the expression at current guesses
 */


reject
  DMgive_src_geometry,
  DMgive_plane_matrix;
  DEdisyourself;
#endif

end specification expression;
