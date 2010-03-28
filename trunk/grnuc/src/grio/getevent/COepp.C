/* #######################    APOGEE COMPILED   ######################## */
/*

 COexpression_preprocessor()

 Abstract:

    This function is a preprocessor for expressions being sent to co$expreval.
    co$expreval knows only about expressions that evaluate to a double 
    precision floating point value.  This preprocessor can weed out expressions
    which, for various reasons, could never be successfuly parsed.  

    The preprocessor takes an expression and performs the following tasks:

      1)  Checks to see all variables are expandable ( have been set by the
          user ); if a variable cannot be expanded, then a return message
          of CO_e_bad_variable_name is returned.

      2)  Expands all variables that are of type GRIO_VAR_STRING.  This is
          because the lexical analyzer in co$expreval returns all strings as
          a single token.  Thus if a variable has the GRIO_VAR_STRING value
          "6.5 feet" it can be received as two ( 2 ) tokens, a DPFP ( 6.5 ) 
          and an IDENTIFIER ( feet ), instead of as a single IDENTIFIER 
          ( 6.5 feet ).

      3)  Leaves variables that are not of type GRIO_VAR_STRING intact.

 Arguments:

   IGRlong        *returnmsg
     
      MSSUCC                    - variables expanded correctly.
      MSFAIL                    - serious problem!
      CO_e_bad_variable_name    - variable could not not found in module
                                  ( this is good cause for a syntax error )
      CO_e_data_truncated       - resulting expression length was less than 
                                  NewStringSize; result is truncated and NULL 
                                  terminated

   IGRchar        *Expression

      expression before string variables are expanded

      
   IGRshort        NewExpressionSize
      
      size of string buffer where results are placed


   IGRchar        *NewExpression

      buffer where results are placed; results are only dependable if
      returnmsg is MSSUCC
      

 Example:

   local_status = COexpression_preprocessor( &Msg,
                                              Expression,
                                              NewExpressionSize,
                                              NewExpression );


   LocalStatus = co$epp( msg     = &LocalMsg, 
                         string  =  Argument,
                         sizebuf =  MAX_ARG_LENGTH,
                         buffer  =  Expression );

 Returns:

   MSSUCC - always

 Notes:

    o The string expression must be NULL terminated;
 
    o The resulting expression ( NewExpression ) will be NULL terminated.

    o It is probably a good idea to be liberal with the size of the 
      NewString buffer to avoid getting truncated results.

    o Example:
      
      if PI  is a GRIO_VAR_VALUE variable,
         STR is a GRIO_VAR_STRING variable with contents "Radians", and 

         then the expression 
         
              "$PI $STR"

         becomes
              
              "$PI Radians"

         .

 Caveats:

   string MUST be NULL terminated!


 History:

    srh  08/23/87    -  Created.

*/


/*  EH - End of header  */

#include   "grimport.h"
#include   "codebug.h"
#include   "OMminimum.h"
#include   "OMDB.h"
#include   "igetypedef.h"
#include   "igrtypedef.h"
#include   "godef.h"
#include   "gr.h"
#include   "igr.h"
#include   "msdef.h"
#include   "exdef.h"
#include   "exmacros.h"
#include   "griodef.h"
#include   "igrdp.h"
#include   "go.h"
#include   "ex.h"
#include   "grio.h"
#include   "griomacros.h"
#include   "griopriv.h"
#include   "igrmacros.h"


IGRlong COexpression_preprocessor( returnmsg,
                                   string,
                                   NewStringSize,
                                   NewString )

   IGRlong   *returnmsg;       /* return code                      */
   IGRchar   *string;          /* input string to be parsed        */
   IGRshort   NewStringSize;   /* size of NewString buffer         */
   IGRchar   *NewString;       /* where resulting string is places */

{
    IGRlong
       LocalMsg = MSSUCC,      /* Return message code from functions called */
       ReturnStatus = MSSUCC;  /* Status code returned                      */
   
    IGRshort 
       StringIndex,       /* index into NewStringArray */
       NewStringIndex;    /* index into NewStringArray */

    IGRchar 
       VariableName[GRIO_MAX_ALIAS_SIZE],   /* buffer to store variable name */
       VariablePrefix = '$';                /* will be configuraable someday */

    struct  GRIOvar_def 
       Variable;        /* for strorage of retrieved variable contents */


    /* 
     * -------------------------------------------------------------------
     *  -------------  EV - End of variable declarations ----------------
     * -------------------------------------------------------------------
     */

    _m_debug_str( "> co$epp" );

    NewStringIndex = 0;
    StringIndex = 0;
    *returnmsg = MSSUCC;

    /*
     * IF string contains a variable (indicated by presence of the prefix )
     * THEN
     *    Examine string character by character copying each char into 
     *     NewString until a variable is encountered.  
     *    IF it is a STRING variable
     *    THEN
     *       copy the contents of the variable into NewString.  
     *    ELSE
     *       copy the variable ( not its contents ) into NewString.
     * ELSE
     *   Copy string into NewString, verbatim.
     */
    if ( ( strchr( string, VariablePrefix ) != NULL ) ) 
    {
       do    /* while( string[StringIndex] != NULL ) */
       {
          if ( StringIndex >= NewStringSize )  /* result too big for buffer */
          {
             NewString[( NewStringSize - 1 )] = NULL;
             *returnmsg = CO_e_data_truncated;
             break;
          }
          else
          {
             if ( string[StringIndex] == VariablePrefix )
             {
                IGRshort 
                   VarIndex;
   
                OMuword 
		   ModuleOsnum;  /* object space where variable is stored */
                /*
                 *  Found variable name;  extract it from string.  If it is of
                 *  type GRIO_VAR_STRING, then copy the contents into NewString.
                 *  Else, Copy the variable name to string ( including the 
                 *  variable prefix )
                 *
                 * copy variable name into VariableName 
                 */
                VariableName[0] = string[StringIndex++];
   
                /* VariableName begins at VariableName[1]  */
                for( VarIndex = 1; 
                     ( ( isvar( string[StringIndex]) ) );
                     VariableName[VarIndex++] = string[StringIndex++] );
   
                VariableName[VarIndex] = NULL;
   
                ex$get_cur_mod( osnum = &ModuleOsnum );
                co$cvtvar( msg   = &LocalMsg,
                           alias = &VariableName[1],
                           osnum =  ModuleOsnum,
                           var   = &Variable );  
   
                if ( LocalMsg & 1  ) 
                {
                   switch( Variable.type)
                   {

                      case GRIO_VAR_STRING:
                         strncpy(&NewString[NewStringIndex],
                                  Variable.contents.string,
                                  GRIO_MAX_ALIAS_SIZE );
                         NewStringIndex += strlen( Variable.contents.string );
                         break;
   
         
                     case GRIO_VAR_FLOAT:
                     case GRIO_VAR_INT:
                     case GRIO_VAR_POINT:

                        strncpy( &NewString[NewStringIndex],
				  VariableName,
				  GRIO_MAX_ALIAS_SIZE );

			NewStringIndex += strlen( VariableName );

                        break;
   
                   }
                }
                else
                {
                   *returnmsg = CO_e_bad_variable_name;
                }
             }
             else
             {  
                /* verbatim copy */
                NewString[NewStringIndex++] = string[StringIndex++]; 
             }
          }

       } while( string[StringIndex] != NULL );
       
       NewString[ NewStringIndex ] = '\0';  /* Null terminate NewString */

    }
    else
    {
       strncpy( NewString, string, NewStringSize );
       NewString[( NewStringSize - 1 )] = '\0';  /* Null terminate NewString */
    }


    _m_debug_str( "< co$epp" );

    return( ReturnStatus );

}  /* end COexpression_preprocessor  */

