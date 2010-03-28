/* #######################    APOGEE COMPILED   ######################## */
/*

 COexpreval( ReturnMsg, 
             ScaleFlag,
             Expression, 
             UnitType, 
             Result )
  
 Abstract:  This function takes an expression ( text string ) and a 
            "context" and tries to evaluate the string to produce a
            floating point value in units defined in the "context"
            supplied.  The "context" includes two parts:  
  
              1) a unit type, such as "GRIO_DISTANCE" or "GRIO_ANGLE"
  
              2) primary, secondary and tertiary units of the 
                 type specified in part 1 ( e.g. mile/foot/inch ).
                 These are used for the interpretation of implicit 
                 expressions. For example, if the primary unit 
                 is "miles", the secondary unit is "feet", and the 
                 tertiary unit is "inches", then the expressions 
                 "6 500 6" and "6 miles + 500 feet + 6 inches" are 
                 equivalent.

           If the unit type is "scalable" and the ScaleFlag is
           greater than 0, then a scale factor retrieved form the
           Active Coordinate System is applied to the result.
  
 Argument:
  
  *ReturnMsg      IGRlong      return message code:
                                 MSSUCC - success
                                 MSFAIL - severe error
                                 MSINARG - invalid argument, probably a bad 
					   scale flag
                                 GRw_ev_trunc - data truncated
                                 GRw_no_value - expression is null string
                                 CO_e_syntax - syntax error in expression
                                 CO_e_divide_by_zero - illegal division by 0

   ScaleFlag      IGRlong        A Flag specifying what kind of scaling
                                 ( if any ) should be applied to values
                                 returned in Event->event.value.
                                    GRIO_NO_SCALE (0): no scaling is desired
                                    GRIO_X_SCALE  (1): use X scale of ACS 
                                    GRIO_Y_SCALE  (2): use Y scale of ACS
                                    GRIO_Z_SCALE  (3): use Z scale of ACS
                                    N>3              : use Nth scale of ACS

  *Expression     IGRchar      Expression to be parsed and evaluated.
  
  *UnitType       IGRchar      Type of units being concidered.
  
  *Result         IGRdouble    If the evaluation of the expression is
                               successfull, then the result is loaded
                               into the address specified by this variable
  
  
 Caveats:
  
    o It is assumed that the expression is NULL terminated 

    o The parser used by this routine is generated using lex and yacc.  
      The information pertaining to the parser is stored in an external
      (global) structure used solely for this purpose ( COexpr_info ).
      This structure contains the result of the expresison evaluation,
      the address of the expression being parsed; a pointer in the
      expression used by the lexical alylizer's input and unput macros;
      and a message code containing the return status of the parse.

 History:

    srh  12/01/86 - created.

    srh  07/01/87 - To allow this function to be called from an object
                    space other than the one where the units are defined,
                    the current module's osnum is acquired and stored in
                    the COexpr_info structure's osnum field.

    srh  10/28/87 - This routine was modifying the value of Expression and
                    this cause problems in the routines that invoked it.
                    Now the contents of Expression are copied into a
                    buffer called ParseString, which can then be modified
                    without side effects.

    srh  04/07/89 - Added ScaleFlag argument so "scalable" values can be
                    scaled w.r.t. the Active Coordinate System (ACS) of the 
                    current module.
 */

/* EH */

#include    "grimport.h"
#include    "codebug.h"
#include    "OMprimitives.h"
#include    "igrtypedef.h"
#include    "igr.h"
#include    "msdef.h"
#include    "griodef.h"
#include    "OMminimum.h"
#include    "griopriv.h"
#include    "exmacros.h"
#include    "codef.h"
#include    "csmacros.h"
#include    "griomacros.h"
#include    "igrmacros.h"

extern struct COpriv_expr_info  COexpr_info;   /* structure for expression  */
                                               /*  evaluation support       */

extern IGRchar *COexpr_ident;           /* char buffer for storing explicit */
                                        /*  unit identifier                 */

extern IGRint COexpr_yyparse();         /* yacc produced expression parser  */





IGRlong  COexpreval( ReturnMsg, 
                     ScaleFlag,
                     Expression, 
                     UnitType, 
                     Result ) 

   IGRlong       *ReturnMsg;
   IGRint         ScaleFlag;  /* passed by value !!! */
   IGRchar       *Expression;
   IGRchar       *UnitType;
   IGRdouble     *Result;

{

   IGRlong status = MSSUCC;
   IGRint  ExprLen;                     /* expression lenght w/o terminal NULL*/
   IGRchar ParseString[MAX_ARG_LENGTH]; /* buffer for parsed string */
   extern  FILE * COexpr_yyin;

   /* EV  -  End of local variables */


   _m_debug_str( "> COexpreval()" );
   *ReturnMsg  = MSSUCC; 
   *Result = 0.0;
   
   /* KLUDGE - 'lex' in version 06.00.00.xx of COMPILSUP expects 
    * COexpr_yyin to  be NULL when reading from a string ; NULLing
    * out COexpr_yyin causes it to test for end-of-file correctly -
    * but this is a work around to a bug in lex; srh; 
    * UPDATE:  Version 06.00.01.00 of COMPILSUP fixes the lex eof-test
    * bug.  Next statement commented out in response. srh. 10/14/91
    */

    /* COexpr_yyin = NULL; */ 

   /*
    * since we have to add a termination marker to the string, and we don't
    * want to corrupt the original expression passed to us, we copy the 
    * expression into the buffer ParseString and modify ParseString;
    */
   strncpy( ParseString, Expression, MAX_ARG_LENGTH );

   /*
    * Put the EOL character, followed by a NULL, at the end of the expression
    */ 
   ExprLen = strlen( ParseString );
   _m_debug( printf( "COexpreval(): ParseString length = %d", ExprLen) );

   ParseString[ExprLen] = COexpr_EOL_char;
   ParseString[ExprLen+1] = NULL;

   /*
    *  Initialize global Expression information before calling parser
    */
   COexpr_info.msg = MSSUCC;
   COexpr_info.result = 0.0;
   COexpr_info.p_expr = ParseString;
   COexpr_info.p_current_char = ParseString;
   COexpr_info.p_unit_type = UnitType;

   _m_debug_str( "COexpreval: calling ex$get_cur_mod" ); 
   ex$get_cur_mod( osnum = &COexpr_info.osnum );

   _m_debug( 
      printf( "COexpreval:  ParseString = \"%s\\0\"\n", COexpr_info.p_expr ) );

   /*
    *  Invoke the parser
    */
   _m_debug_str( "COexpreval:  calling COexpr_yyparse()" );
   COexpr_yyparse();

   /*
    * COexpreval() returns the msg that COexpr_yyparse() sets in the global
    * sturcture field COexpr_info.msg
    */
   *ReturnMsg = COexpr_info.msg;

   _m_check(  COexpr_info.msg, status = MSFAIL );
   _m_checkp( COexpr_info.msg, "COexpreval:  COexpr_yyparse() failed" );
   _m_checkq( COexpr_info.msg );

   *Result = COexpr_info.result; 

   /*
    *  'Result' now has the unscaled result of the expression evaluation;
    *  We will scale the result iff:
    *    1) the ScaleFlag is a positive integer,  AND
    *    2) the unit_type specified is "scalable", AND
    *    3) we can successfully retrieve a scale factor from the ACS
    *
    *    KLUDGE - we don't allow more than 3 scale factors in a CS object
    */
   if ( ScaleFlag >= 0 && ScaleFlag < 3 )
   {
      IGRboolean  is_scalable;

      status = co$is_unit_scalable( msg         =  ReturnMsg,
                                    unit_type   =  UnitType,
                                    osnum       =  COexpr_info.osnum,
                                    is_scalable = &is_scalable );

      if ( is_scalable )
      {
         IGRdouble    Scales[3]; /* KLUDGE - we can have more than 3 scales */

         /*
          *  - Get scale factors from ACS
          *  - Scale Result ( scale factor = Scales[ScaleFlag] )
          */
         status = cs$get_scale( msg   = ReturnMsg,
                                cs_os = COexpr_info.osnum,
                                scale = Scales );

         _m_check2q( status, *ReturnMsg );

         *Result *= Scales[ScaleFlag]; 
      }
   }
   else
   {
      /* Range checking for value of ScaleFlag */
      if ( ScaleFlag != GRIO_NO_SCALE )  *ReturnMsg = MSINARG;
   }

quit:

   _m_debug_str( "< COexpreval()" );
   return ( status );

}  /* end COexpreval  */
