
/*
 *  griopriv.h - private include file for grio package
 *  
 *   Dependencies:  
 *      igrtypedef.h
 *      OMminimum.h
 */

#ifndef griopriv_include
#  define griopriv_include

#   define _command_line_arg( mask )                                          \
       ( mask & ( GRm_VALUE | GRm_TEXT_VALUE | GRm_STRING | GRm_DATA ) )

#   define _not_command_line_arg( mask )  ( ! _command_line_arg( mask ) )

    /*  -----------------------------------------------------------------------
     *
     *  IGRboolean isvar( c )
     *
     *     IGRchar c;
     *
     *  Returns: 
     *
     *     Positive TRUE if c is a letter found in a variable 
     *     name ( [0-9,A-Z,a-z,_] ); else, returns FALSE
     *
     *  -----------------------------------------------------------------------
     */
   
    #define isvar(c) (   ( ( c >= 'A' ) && ( c <= 'Z' ) )                     \
                      || ( ( c >= 'a' ) && ( c <= 'z' ) )                     \
                      || ( ( c >= '0' ) && ( c <= '9' ) )                     \
                      || ( c == '_' )                      )
   
   
   
    /* ---------------------------------------------------------------------
     *          End of C macros for COgetevent's VSD manipulations
     * ---------------------------------------------------------------------
     */

#   define MAX_ARG_LENGTH   ( 256 )  /* max length of arglist in the VSD */

    /* 
     * end of line character for numeric/unit expressions ( co$expreval ) 
     */
#   define COexpr_EOL_char     '\177'   /* ascii del char */

    typedef IGRlong ( *COexpr_p_FUNCPTR)();

    struct COpriv_expr_info   /*  information interface for  co$expreval    */
    {
       IGRlong    msg;              /* return code for expression evaluation */
       IGRdouble  result;           /* result of expression evaluation       */
       IGRchar   *p_expr;           /* points to first char in expression    */
       IGRchar   *p_current_char;   /* points to current input char (lex)    */
       IGRchar   *p_unit_type;      /* type of unit being evaluated          */
       OMuword    osnum;            /* OS where unit conversions occurs      */
    };

    enum COexpr_value_type
    {
       /*
        * These value are array indeces so it is important that their
        * values be sequential from 0
        */
       EXPR_SCALAR   = 0,     /* scalar ( non-unit) value   */
       EXPR_IMPLICIT = 1,     /* implicit unit value        */
       EXPR_EXPLICIT = 2      /* explicit unit value        */
    };

    struct COexpr_stacktype
    {
       enum COexpr_value_type   type;
       IGRdouble                value;
    };

    /*
     *  OpMask bits: used by co$expreval() rule checker
     *
     *  It is important that these are sequential powers of 2.
     *
     *  Note that unary plus and minus are not included since they require 
     *  no special rule checking.
     */
#    define PLUS      ( 0x01 )
#    define MINUS     ( 0x02 )
#    define MUL       ( 0x04 )
#    define DIV       ( 0x08 )
#    define POW       ( 0x10 )

     /*
      *  syntax masks for operations between different types or values 
      */
#    define SCL_SCL   ( PLUS | MINUS | MUL | DIV | POW )
#    define SCL_IMP   ( PLUS | MINUS | MUL             )
#    define SCL_EXP   ( PLUS | MINUS | MUL             )
#    define IMP_SCL   ( PLUS | MINUS | MUL | DIV       )
#    define IMP_IMP   ( PLUS | MINUS                   )
#    define IMP_EXP   ( PLUS | MINUS                   )
#    define EXP_SCL   ( PLUS | MINUS | MUL | DIV       )
#    define EXP_IMP   ( PLUS | MINUS                   )
#    define EXP_EXP   ( PLUS | MINUS                   )


    /*
     *  lex I/O macros input() and unput(c) redefined for the lexical anylizer 
     *  COexpr_yylex used in co$expreval
     */
#   ifdef input
#   undef input
#   endif

#   define input() COexpr_input()

#   ifdef unput
#   undef unput
#   endif

#   define unput(c) COexpr_unput(c)


#   ifdef output
#   undef output
#   endif

/*
 *  KLUDGE - OMminimum.h has bit field 'output' so we have to undefine and 
 *  redefine this macro to make things work right; this definition is the
 *  same as found in y.tab.c produced by lex.
 */
#   define output(c) putc(c,yyout)

#endif
