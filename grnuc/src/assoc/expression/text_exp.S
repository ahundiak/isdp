/*

   ABSTRACT :
   --------

   A text expression is an expression (see expression.S) that has a string
   value.

   HISTORY :
   -------

   09/01/1987 : SF - Creation
   12/18/1987 : HGB - 1.1 Conversion
   04/19/1988 : HGB - Override move/copy to root
*/

class specification text_exp (0:1) of expression;

instance text_exp 
  {
  }; 

override GRvg;


override 
	create, 	  /* create an expression 			*/
	NDplace, 	  /* create an expression			*/
	modify,		  /* Modify an existing expression		*/
	give_formula,	  /* return the formula 			*/
	list,		  /* return the formula				*/
	NDgive_structure, /* return the structure			*/
	NDcompute_node,   /* do nothing					*/
	NDprint_root,     /* Graph printer message			*/
        NDmove_to_root,   /* do nothing (already a root one)		*/
        NDcopy_to_root,   /* copy the expression			*/
        DIgive_output,    /* Give the full formula                      */
        DIget_edit_string,/* Give the full formula                      */
        DIput_edit_string,/* Put the text  formula                      */
        convert_to_new_syntax, /* convert an expr to an equation        */
        ACcopy_to_Groot;  /* copy to root expression WITH THE TO_OWNER CHANNEL*/

end specification text_exp;
