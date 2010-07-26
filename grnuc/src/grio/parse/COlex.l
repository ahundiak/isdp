/*  < lex comments do not allow lew lines inside them >               */
/*   History:                                                         */
/*      srh   ??/??/86    created                                     */
/*      srh   04/28/89    added scientific notation                   */

/* definitions */
%{


#include   "codebug.h"
#include   "igrtypedef.h"
#ifdef output
#undef output
#endif
#include   "OMprimitives.h"
#include   "OMminimum.h"
#include   "griopriv.h"    /* redefines output */
#include   "igetypedef.h"
#include   "gr.h"
#include   "igr.h"
#include   "griodef.h"
#include   "godef.h"
#include   "igrdp.h"
#include   "go.h"
#include   "ex.h"
#include   "exmacros.h"
#include   "grio.h"
#include   "griomacros.h"
#include   "y.tab.h"      /* produced by yacc-ing COparse.y */
#include   "igrmacros.h"


extern struct COexpr_stacktype yylval;       /* yacc evaluation variable     */
extern IGRchar COexpr_ident[26];             /* to store non-numeric strings */
extern IGRpoint COexpr_data_point;           /* to store data points         */
extern struct COpriv_expr_info COexpr_info;  /* global expr info structure   */
%}

/* Lex Rules */
%%

[ \t] {
      ; /* tabs and blanks are ignored */ 
   }


[0-9]*\.[0-9]+[eE][+-]*[0-9]+|[0-9]+\.[0-9]*[eE][+-]*[0-9]+|[0-9][eE][+-]*[0-9]+ {
      /*
       *  Scienfific notation - note: this precludes a UOM alias from being
       *  named "e" or "E".  04/28/89 srh
       */
      if ( sscanf( yytext, "%le", &yylval.value ) ) 
      {
         yylval.type = EXPR_SCALAR; 
         return GRIO_DPFP; 
      }
      else return GRIO_ERROR;
   }


[0-9]*\.[0-9]+|[0-9]+\.[0-9]* {
      /* simple double precision float */
      sscanf( yytext, "%lf", &yylval.value ); 
      yylval.type = EXPR_SCALAR; 
      return GRIO_DPFP; 
   }


[0-9]+ {
      /* integer */
      sscanf( yytext, "%lf", &yylval.value ); 
      yylval.type = EXPR_SCALAR; 
      return GRIO_INTEGER; 
   }


[_a-zA-Z\'\"]+ {
      /* identifier */
      sscanf( yytext, "%[_a-zA-Z\'\"]", COexpr_ident );
      return GRIO_IDENTIFIER; 
   }


\$[_a-zA-Z0-9]+ {
      /* variables */
      sscanf( yytext, "%[_a-zA-Z0-9\$]", COexpr_ident );

      {
         IGRlong
	    status,
            msg;

         struct GRIOvar_def 
	    var;

         OMuword   
            ModuleOsnum;     /* object space where variable is stored */


         ex$get_cur_mod( osnum = &ModuleOsnum );

         status = co$cvtvar( msg   = &msg,
                             alias = &COexpr_ident[1],
                             osnum =  ModuleOsnum,
                             var   = &var );

         _m_check2( status, msg, 
         {
             return GRIO_ERROR;
             break;
         } );

         switch( var.type )
         {
            case GRIO_VAR_FLOAT:  
               yylval.value = var.contents.fvalue;
               yylval.type  = EXPR_SCALAR; 
               return GRIO_DPFP; 
               break;

            case GRIO_VAR_INT:  
               yylval.value = var.contents.ivalue;
               yylval.type  = EXPR_SCALAR; 
               return GRIO_INTEGER; 
               break;

            case GRIO_VAR_STRING:  
               strncpy( COexpr_ident, var.contents.string, 40 );
               return GRIO_IDENTIFIER; 
               break;

            default:
               return GRIO_ERROR;
               break;
         }
      }
   }


[\177] {
      /* end of expression flag */
      return GRIO_EOL; 
   }


.  { 
      /* wild thing:  returns operators, etc. */
      return yytext[0]; 
   }

