%a 5000
%{
/*
 *	input for lexical analyser for the command langage
 *	( lex sources )
 *	Etienne BEEKER	GIF/FRANCE
 *	18 Juin 1986
 */
#include <ctype.h>

/* IEEE floating point check for NAN and INF */

#ifdef CLIX
#define _IEEE	1
#include <nan.h>
#endif
#ifdef IRIX
#define _IEEE	1
#include <nan.h>
#endif
#ifdef SUNOS_2.4
extern int isnan ();
extern int isinf ();
#define IsNANorINF(d) (isnan(d) || isinf(d))
#define strtoul strtol
#elif defined ( SUNOS5 )
extern int isnan ();
extern int finite ();
#define IsNANorINF(d) (isnan(d) || !finite(d))
#endif

#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "cichardef.h"
#include "cidef.h"
#include "ciy.h"
#include <string.h>

/*-DEFINES--------------------------------------------------------------------*/
/* -- Have lex read bigger string into 'yytext' ( for string constants )
      "+ 1" is for leading `"' in `yytext'
   -- */
#undef  YYLMAX
#define YYLMAX ( MAXSTRING + 1 )
/*-EXTERNALS------------------------------------------------------------------*/
extern PCItype	TYPbasic()	;
extern void	UOPsave()	;
/*-GLOBALS--------------------------------------------------------------------*/
/* -- Binds an operator to its corresponding  instruction, arity,  associativity
      and name. For operators defining  several instructions according  to their
      operands' types, the most frequently used is implemented.

      			--- How To Implement A New Operator ---

      	1.- Enter a new %<token> in ciy.y with an index `n'
      		%<token> _NEWOP	n
      	    Define it precedence, add it in the wanted rules.

	2.- Enter it in this list at index `n'
		INSTRUCTION, <number of operands>, LtoR/RtoL, <operator's name>

	3.- Add a lex rule
		"<op>"		{ return OPCODE( _NEWOP ) ; }

	4.- Add it in OPbin() if it is binary, OPunr() if it is unary (ciop.c)
   -- */
OPERATOR OPinfo[] = {
	/*  0 : _PLUS	*/	{ IADDI		, 2, LtoR, "+"	},
	/*  1 : _MINUS	*/	{ IMINI		, 2, LtoR, "-"	},
	/*  2 : _MUL	*/	{ IMULI		, 2, LtoR, "*"	},
	/*  3 : _DIV	*/	{ IDIVI		, 2, LtoR, "/"	},
	/*  4 : _ASSIGN	*/	{ IASSIGNTI	, 2, RtoL, "="	},
	/*  5 : _EQUAL  */	{ IEQ		, 2, LtoR, "=="	},
	/*  6 : _DIFF	*/	{ INE		, 2, LtoR, "!="	},
	/*  7 : _STRSUP	*/	{ IGT		, 2, LtoR, ">"	},
	/*  8 : _SUPEQU	*/	{ IGE		, 2, LtoR, ">="	},
	/*  9 : _STRINF	*/	{ ILT		, 2, LtoR, "<"	},
	/* 10 : _INFEQU	*/	{ ILE		, 2, LtoR, "<="	},
	/* 11 : _NOT	*/	{ INEGBOOL	, 1, RtoL, "!"	},
	/* 12 : _ANDAND	*/	{ IAND		, 2, LtoR, "&&"	},
	/* 13 : _OROR	*/	{ IOR		, 2, LtoR, "||"	},
	/* 14 : _AND	*/	{ BITAND	, 2, LtoR, "&"	},
	/* 15 : _OR	*/	{ BITOR		, 2, LtoR, "|"	},
	/* 16 : _XOR	*/	{ BITEOR	, 2, LtoR, "^"	},
	/* 17 : _MOD	*/	{ IMODI		, 2, LtoR, "%"	},
	/* 18 : _IND	*/	{ CALCINDEX	, 1, RtoL, "*"	},
	/* 19 : _ADDR	*/	{ ASSIGNTADDR	, 1, RtoL, "&"	},
	/* 20 : _COMMA	*/	{ _COMMA	, 2, LtoR, ","	},
	/* 21 : _ARROW	*/	{ STRUCTPTR	, 2, LtoR, "->"	},
	/* 22 : _DOT	*/	{ STRUCTFIELD	, 2, LtoR, "."	},
	/* 23 : _OPP	*/	{ OPPOS		, 1, RtoL, "-"	},
	/* 24 : _CMPL	*/	{ BITNEG	, 1, RtoL, "~"	},
	/* 25 :	_BRA	*/	{ CALCINDEX	, 2, LtoR, "[]"	},
	/* 26 : _KET	*/	{ CALCINDEX	, 2, LtoR, "[]"	},
	/* 27 : _BREAK	*/	{ BREAK		, 0, LtoR, ""	},
	/* 28 : _EXIT	*/	{ EXIT_FILE	, 0, LtoR, ""	},
	/* 29 : _RETURN	*/	{ RETURN	, 1, LtoR, ""	},
	/* 30 : _CONT..	*/	{ CONTINUE	, 0, LtoR, ""	},
	/* 31 : _ATSIGN	*/	{ BRANCHFUNC	, 1, RtoL, "@"	},
	/* 32 : _BCKQUO	*/	{ BRANCHFUNC	, 1, RtoL, "`"	},
	/* 33 : _PSCASG	*/	{ BRANCHFUNC	, 2, RtoL, ":="	},
	/* 34 : _DBLCLN	*/	{ BRANCHFUNC	, 2, LtoR, "::"	},
	/* 35 : _RANGE 	*/	{ BRANCHFUNC	, 2, LtoR, ".."	},
	/* 36 : _DBLCRT	*/	{ BRANCHFUNC	, 2, LtoR, "^^"	},
	/* 37 : _INFSUP	*/	{ BRANCHFUNC	, 2, LtoR, "<>"	},
	/* 38 : _DBLPCT	*/	{ BRANCHFUNC	, 2, LtoR, "%%"	},
	/* 39 : _DBLQMK	*/	{ BRANCHFUNC	, 2, LtoR, "??"	},
	/* 40 : _DBLATS	*/	{ BRANCHFUNC	, 2, LtoR, "@@"	},
	/* 41 : _UNRNAM */	{ BRANCHFUNC	, 1, RtoL, "@:"	},
	/* 42 : _MLTNAM */	{ BRANCHFUNC	, 2, LtoR, "@*"	},
	/* 43 : _PLSNAM */	{ BRANCHFUNC	, 2, LtoR, "@+"	},
	/* 44 : _LSHIFT */	{ LSHIFT	, 2, LtoR, "<<" },
	/* 45 : _RSHIFT */	{ RSHIFT	, 2, LtoR, ">>" }
} ;
/*-MACROS---------------------------------------------------------------------*/
#define OPCODE( c ) ( yylval.opr.instr = OPinfo[c].icode, yylval.opr.code = (c) )
#define INITYP( t ) ( yylval.typ = TYPbasic( t ), BASICTYPE )
/*----------------------------------------------------------------------------*/
int LEXoch( s ) char *s ; {

/* -- Checks if good octal character constant.
      NOTE: the Lex rules imposes that `s' has a length of 6 at most:
		      	"'" + "/" + 3 digits + "/"
   -- */
		char buf[7] ; int len = strlen( s ), i ; emsg e ;

	strncpy( buf + 1, s + 2, len - 1  )[len-3] = 0 ;
	buf[0] = '0' ;
	i = strtoul( buf, (char **) NULL, 0 ) ;
#if DEBUG
  printf( "LEXoch: <%s> i = %d, i < '\\000' ? %d\n", s, i, i < '\000' ) ;
#endif
	if( i < '\000' || i > (unsigned) '\377' ) {
		sprintf( e, "0%o", i ) ;
		ERRsyn( "invalid octal character constant", e ) ;
	}
	return i ;
} /* LEXoch */
/*----------------------------------------------------------------------------*/
double LEXxreal( h ) char *h ; {

/* -- `h' has size sizeof( double ) * 2 + strlen( "0r" ).
   -- */
	double d = 0. ; int len, i ; Uchar buf[sizeof( double )] ;
	char byte[3] ;
#if DEBUG
  printf( "LEXxreal: <%s>\n", h ) ;
#endif
  len = strlen( h + 2 ) ;
  if( len != sizeof( double ) * 2 ) {
	ERRsyn( "real hexa constant has bad length", h ) ;
  } else {
	byte[2] = EOSTR ;
	for( i = 0 ; i < sizeof d ; i++ ) {
		byte[0] = h[2+2*i] ;
		byte[1] = h[3+2*i] ;
		buf[i]  = strtoul( byte, (char **) NULL, 16 ) ;
	}
	d = *(double *) buf ;
	if( IsNANorINF( d ) ) {
		ERRsyn( "real hexa constant has bad IEEE standard value", h ) ;
	}
  }

  return d ;
}
/*----------------------------------------------------------------------------*/
void LEXsharp( pattern, lextext ) char *pattern, *lextext ; {

/* -- Extracts file name and line number from (om)cpp "#" lines.
   -- */

			SysVfname file ; int line ;

  sscanf( lextext, pattern, &line, file ) ;
  PCI_Set_current_line( line - 1 ) ;
  PCI_Set_current_file( file     ) ;

} /* LEXsharp */
/*----------------------------------------------------------------------------*/
static int LEXident( lextext, token )	char	*lextext	;
					YYSTYPE *token	 	; {

				PCItype T ; int rc ;

   if( strlen( lextext ) > MAXIDLEN - 1 ) {
   	ciwarning( "identifier to long, truncated", lextext ) ;
   	strncpy( token->idf, lextext, MAXIDLEN - 1 )[MAXIDLEN - 1] = EOSTR ;
   } else strcpy( token->idf, lextext ) ;

/* -- Is it a type ?
   -- */
   if( TDFfind( token->idf, &T ) ) {
   	token->typ	= T		;
   	rc		= TYPENAME	;
   } else rc = IDENT ;

   return rc ;

} /* LEXident */
/*----------------------------------------------------------------------------*/
int LEXstring( text, p_str )	char		*text	;
				PCIstring	*p_str	; {

/* -- Checks string length, handles backslashes.
   -- */

		int i, j, len, rc ; void *malloc() ; emsg err ;

  len = strlen( text ) ;
  for( i = len - 1, j = 0 ; i >= 0 ; i-- ) if( text[i] == BACKSLASH ) j++ ;
  				           else break ;
  if( j % 2 ) rc = FALSE ;
  else {
    input() ;
    if( len > MAXSTRING - 1 ) {
       	len = MAXSTRING - 1 ;
    	sprintf( err, "string too long, truncated to %d characters", len ) ;
    	WNGsyn( err, NULL ) ;
    }

    if( MALLOC( p_str->text, len + 1, char ) == NULL ) {
	rc = ERRmem( "string constant" ) ;
    } else {
      i = 0 ; p_str->length = 0 ; rc = TRUE ;
      while( i < len ) {
        register char c = text[i] ;

        if( c == NEWLINE ) {
	    WNGsyn( "NEWLINE in string no longer allowed", NULL ) ;
	    rc = FALSE ;
	    break      ;
        } else if( c == BACKSLASH ) {
	  	switch( text[i+1] ) {
	       		case 'b'	: c = BACKSPACE	; i++ ; break ;
	       		case 'f'	: c = FORMFEED 	; i++ ; break ;
	       		case 'n'	: c = NEWLINE 	; i++ ; break ;
	       		case 'r'	: c = CR 	; i++ ; break ;
	       		case 't'	: c = HTAB	; i++ ; break ;
	       		case 'v'	: c = VTAB	; i++ ; break ;
	       		case BACKSLASH	: c = BACKSLASH	; i++ ; break ;
	  	}
        }
        p_str->text[p_str->length++] = c ;
        i++ ;
      } /* while */

      p_str->text[p_str->length]= EOSTR ;
    }
  }
  return rc ;

} /* LEXstring */
/*----------------------------------------------------------------------------*/
static int LEXunknown( c ) int c ; {

				 emsg msg ;

  if( isprint( c ) )	{ msg[0] = c ; msg[1] = EOSTR ; }
  else			sprintf( msg, "hexa 0x%x", c ) ;
  ERRsyn( "invalid character in file", msg ) ;

  return EOF ;

} /* LEXunknown */
/*----------------------------------------------------------------------------*/
void LEXinit()

/* -- This cute little procedure  properly resets lex when  several files are
      compiled at the same time and avoids fictious errors on a file when the
      preceding one had errors.
   -- */

{ extern int yydebug ; yysptr = yysbuf ; yydebug = FALSE ; }
/*----------------------------------------------------------------------------*/
%}
DOTTED_DIGITS			((([0-9]+\.[0-9]+)|([0-9]+\.))|(\.[0-9]+))
EXP				([eE][-+]?[0-9]+)
INT				[0-9]+
STR				\"[^\"]*
BLK				[ \t]+
IDT				[A-Za-z$_][A-Za-z_$0-9]*
OCH				\'\\([0-7]{1,3})\'
%%

	extern double	atof()	;
	extern int	yydebug ;
%{
		/* -- Comment				-- */
%}
\/\/.*$			  ;
%{
		/* -- Integer constant			-- */
%}
{INT}			|
0[0-7]+			|
0[xX][0-9A-Fa-f]+	  { yylval.ivl = strtoul( yytext, (char **) NULL, 0 ) ;
			    return INTEGER ; }
%{
		/* -- Real constant			-- */
%}
{INT}{EXP}		|
{DOTTED_DIGITS}{EXP}?	  { yylval.dvl = atof    ( yytext ) ; return DOUBLE  ; }
0[rR][0-9A-Fa-f]+	  { yylval.dvl = LEXxreal( yytext ) ; return DOUBLE  ; }
%{
		/* -- Character constant		-- */
%}
\'[^\'\\]\'		  { yylval.cvl = yytext[1]	 ; return CHAR	  ; }
\'\\[\\\']\'		  { yylval.cvl = yytext[2]	 ; return CHAR	  ; }
\'\\n\'			  { yylval.cvl = NEWLINE	 ; return CHAR	  ; }
\'\\t\'			  { yylval.cvl = HTAB 		 ; return CHAR	  ; }
\'\\b\'			  { yylval.cvl = BACKSPACE	 ; return CHAR	  ; }
\'\\f\'			  { yylval.cvl = FORMFEED	 ; return CHAR	  ; }
\'\\r\'			  { yylval.cvl = CR		 ; return CHAR	  ; }
\'\\v\'			  { yylval.cvl = VTAB		 ; return CHAR	  ; }
{OCH}			  { yylval.cvl = LEXoch( yytext ); return CHAR	  ; }
%{
		/* -- String constant			-- */
%}
\"[^\"]*		  { if( LEXstring( &yytext[1], &yylval.str ) )
					return STRING ;
			    else {
					yyleng-- ;
					yymore() ;
			    }
			  }

%{
		/* -- Omcpp or cpp generated line #	-- */
%}
^#line{BLK}{INT}{BLK}{STR}\"	LEXsharp( "#line %d \"%[^\"]", yytext ) ;
^#{BLK}{INT}{BLK}{STR}\"	LEXsharp( "# %d \"%[^\"]"    , yytext ) ;


DEBUG				yydebug = TRUE	;
UNDEBUG				yydebug = FALSE	;


%{
		/* -- In-line directives	-- */
%}
"-"^[oe]{BLK}.*$		PCIsetopt( yytext + 2 ) ;
%{
		/* -- Reserved keywords			-- */
%}
implicit			return _IMPLICIT		;
goto				return _GOTO			;
while				return _WHILE			;
do				return _DO			;
for				return _FOR			;
docmd				return _DOCMD			;
dokey				return _DOKEY			;
if				return _IF			;
else				return _ELSE			;
break				return OPCODE( _BREAK	  )	;
continue			return OPCODE( _CONTINUE  )	;
exit				return OPCODE( _EXIT	  )	;
return				return OPCODE( _RETURN	  )	;
sizeof				{ PCIgen = FALSE;return _SIZEOF;}
to				return _TO			;
send				return _SEND			;
push				return _PUSH			;
message				{ strcpy( yylval.idf, "message" )	;
				  return _MESSAGE			;
				}

%{
		/* -- Operators				-- */
%}
"="				{ return OPCODE( _ASSIGN )  ; }

"+"				{ return OPCODE( _PLUS   )  ; }
"-"				{ return OPCODE( _MINUS  )  ; }

"*"				{ return OPCODE( _MUL    )  ; }
"/"				{ return OPCODE( _DIV    )  ; }
"%"				{ return OPCODE( _MOD    )  ; }

"<<"				{ return OPCODE( _LSHIFT )  ; }
">>"				{ return OPCODE( _RSHIFT )  ; }

"&"				{ return OPCODE( _AND    )  ; }
"|"				{ return OPCODE( _OR     )  ; }
"^"				{ return OPCODE( _XOR    )  ; }
"~"				{ return OPCODE( _CMPL   )  ; }

"=="				{ return OPCODE( _EQUAL  )  ; }
"!="				{ return OPCODE( _DIFF   )  ; }
">="				{ return OPCODE( _SUPEQU )  ; }
"<="				{ return OPCODE( _INFEQU )  ; }
">"				{ return OPCODE( _STRSUP )  ; }
"<"				{ return OPCODE( _STRINF )  ; }

"!"				{ return OPCODE( _NOT    )  ; }
"&&"				{ return OPCODE( _ANDAND )  ; }
"||"				{ return OPCODE( _OROR   )  ; }

"->"				{ return OPCODE( _ARROW  )  ; }
"."				{ return OPCODE( _DOT	 )  ; }
"["				{ return OPCODE( _BRA    )  ; }
"]"				{ return OPCODE( _KET    )  ; }
","				{ return OPCODE( _COMMA  )  ; }
"("				return _LPAR	;
")"				return _RPAR	;

%{
		/* -- Non-predefined operators			-- */
%}
"@"				{ return OPCODE( _ATSIGN  )  ; }
"`"				{ return OPCODE( _BCKQUO  )  ; }
":="				{ return OPCODE( _PSCASG  )  ; }
"::"				{ return OPCODE( _DBLCLN  )  ; }
".."				{ return OPCODE( _RANGE   )  ; }
"^^"				{ return OPCODE( _DBLCRT  )  ; }
"//"				{ return OPCODE( _INFSUP  )  ; }
"%%"				{ return OPCODE( _DBLPCT  )  ; }
"??"				{ return OPCODE( _DBLQMK  )  ; }
"@@"				{ return OPCODE( _DBLATS  )  ; }

%{
		/* -- Punctuation				-- */
%}
":"				return _COLON	;
";"				return _SEMICOL	;
"{"				return _LBRACE	;
"}"				return _RBRACE	;

%{
		/* -- Data types				-- */
%}
char				{ return INITYP( CI_CHAR	) ; }
short				{ return INITYP( CI_SHORT  	) ; }
int				{ return INITYP( CI_INT	  	) ; }
integer				{ return INITYP( CI_INTEGER  	) ; }
unsigned			{ return INITYP( CI_UNSIGNED	) ; }
long				{ return INITYP( CI_LONG	) ; }
float				{ return INITYP( CI_FLOAT	) ; }
void				{ return INITYP( CI_VOID	) ; }
double				{ return INITYP( CI_DOUBLE	) ; }
numeric				{ return INITYP( CI_NUMERIC	) ; }
GRobj				{ return INITYP( CI_GROBJ	) ; }
struct				{ yylval.ivl = STRUC	  ; return _STRUCT ; }
union				{ yylval.ivl = UNION	  ; return _UNION  ; }
extern				return _EXTERN	;
typedef				return _TYPEDEF ;
typeinit			return _TYPEINIT;
enum				return _ENUM	;
switch				return _SWITCH	;
case				return _CASE	;
default				return _DEFAULT ;
operator			return _OPERATOR;
%{
		/* -- Unsupported C features			-- */
%}
static		|
auto		|
register	{ ERRsyn( "unsupported C feature", yytext ) ; return EOF ; }

%{
		/* -- Identifiers				-- */
%}
{IDT}		return LEXident( yytext, &yylval ) ;

"@*"{IDT}	{ UOPsave( yytext ) ; return OPCODE( _MLTNAM  )  ; }
"@+"{IDT}	{ UOPsave( yytext ) ; return OPCODE( _PLSNAM  )  ; }
"@:"{IDT}	{ UOPsave( yytext ) ; return OPCODE( _UNRNAM  )  ; }
%{
		/* -- Ignore tabulations			-- */
%}
[ \t]+				;

%{
		/* -- Count lines				-- */
%}
[\n]				{ PCI_Incr_current_line() ; }
%{
		/* -- Complain about the rest			-- */
%}
.				return LEXunknown( yytext[0] ) ;

%%
