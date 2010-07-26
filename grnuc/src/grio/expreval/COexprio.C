/* #######################    APOGEE COMPILED   ######################## */

/*
 * ---------------------------------------------------------------------
 *  lex I/O fuctions and called by input() and unput() macros
 * ---------------------------------------------------------------------
 *
 *   IGRint COexpr_unput()
 *
 *   Arguments: none
 *
 *   Abstract:  This function performs the task of lex's yyunput macro
 *              which has been redefined to access the expression 
 *              indicated by the COexpr_info structure.
 *
 *              This routine simply decrements the COexpr_info.p_current_char 
 *              pointer if that pointer is not already pointing at the first 
 *              character of the expression (COexpr_info.p_expr).
 *
 *              lex's lexical anylizer, yylex, expects yyunput to always 
 *              return a 1, so COexpr_unput always returns 1.
 *
 *
 *   IGRint COexpr_unput(c)
 *
 *   Arguments: 
 *
 *     c     IGRchar   last character input which is unput
 *
 *
 *
 *   Abstract:  This function performs the task of lex's yyunput macro
 *              which has been redefined to access the expression 
 *              indicated by the COexpr_info structure.
 *
 *              This routine simply decrements the COexpr_info.p_current_char 
 *              pointer if that pointer is not already pointing at the first 
 *              character of the expression (COexpr_info.p_expr).
 *
 *              lex's lexical anylizer, yylex, expects yyunput to always 
 *              return a 1, so COexpr_unput always returns 1.
 *              
 *
 *   History:   srh  2/2/87   created
 *              scw 07/14/92  ansi conversion
 *
 *   Caveats:
 *      
 *      o The default lex I/O routines update a bunch of internal variables
 *         that this application does not use ( such as keeping up with 
 *         line numbers, etc. ).  If this information needs to be accessed
 *         in the future, then these I/O routines need to be rewritten!  In
 *         the mean time they do just what they need to do.
 *
 * ---------------------------------------------------------------------
 */

/*  EH  */

#include    "grimport.h"
#include    "codebug.h"
#include    <stdio.h>
#include    "igrtypedef.h"
#include    "igr.h"
#include    "OMminimum.h"
#include    "griopriv.h"
#include    "igrmacros.h"


extern struct COpriv_expr_info  COexpr_info;

IGRint COexpr_input()
{
   IGRchar c;

   c = *COexpr_info.p_current_char++;

   _m_debug(printf( "COexpr_input: character retrieved is octal \\%o\n", c ); );

   return( (IGRint) c );

}


IGRint COexpr_unput(c)
  IGRchar c;
{


   if ( COexpr_info.p_current_char > COexpr_info.p_expr ) 
   {
        c = *(--COexpr_info.p_current_char);

        _m_debug(
           printf("COexpr_unput: c is \\%o\n", c); );
        _m_debug(
           printf("COexpr_unput: unput \\%o\n", *COexpr_info.p_current_char); );
   }
   return( 1 );  /* always return TRUE */
}
