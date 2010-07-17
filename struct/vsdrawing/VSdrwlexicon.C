# include "stdio.h"
# define U(x) x
# define NLSTATE VSyydrwprevious=VSyydrwNEWLINE
# define BEGIN VSyydrwbgin = VSyydrwsvec + 1 +
# define INITIAL 0
# define VSyydrwLERR VSyydrwsvec
# define VSyydrwSTATE (VSyydrwestate-VSyydrwsvec-1)
# define VSyydrwOPTIM 1
# define VSyydrwLMAX 200
# define output(c) putc(c,VSyydrwout)
# define input() (((VSyydrwtchar=VSyydrwsptr>VSyydrwsbuf?U(*--VSyydrwsptr):getc(VSyydrwin))==10?(VSyydrwlineno++,VSyydrwtchar):VSyydrwtchar)==EOF?0:VSyydrwtchar)
# define unput(c) {VSyydrwtchar= (c);if(VSyydrwtchar=='\n')VSyydrwlineno--;*VSyydrwsptr++=VSyydrwtchar;}
# define VSyydrwmore() (VSyydrwmorfg=1)
# define ECHO fprintf(VSyydrwout, "%s",VSyydrwtext)
# define REJECT { nstr = VSyydrwreject(); goto VSyydrwfussy;}
int VSyydrwleng; extern char VSyydrwtext[];
int VSyydrwmorfg;
extern char *VSyydrwsptr, VSyydrwsbuf[];
int VSyydrwtchar;
FILE *VSyydrwin = {stdin}, *VSyydrwout = {stdout};
extern int VSyydrwlineno;
struct VSyydrwsvf { 
	struct VSyydrwwork *VSyydrwstoff;
	struct VSyydrwsvf *VSyydrwother;
	int *VSyydrwstops;};
struct VSyydrwsvf *VSyydrwestate;
extern struct VSyydrwsvf VSyydrwsvec[], *VSyydrwbgin;
/*
	I/STRUCT
*/
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
/*
 * Because OMminimum.h has a structure whose member is called "output".
 */
#undef output
#include "vsdrw.h"
#include "vsdrwmacros.h"
#include "VSdrwgrammar.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
#include "vsstrngproto.h"

#define output(x)

/*
 * Give some arguments to VSyydrwlex().
 * - errFile		: please tell us what goes wrong when it does.
 * - inputs		: the stack of input files.
 */
#define VSyydrwlex()		VSyydrwLex( errFile, inputs )	\
			FILE		*errFile ;	\
			VSdrwInputFiles	*inputs ;

/*
 * Call VSyydrwwrap() with some arguments().
 * - (1) verbose	: TRUE if user has set verbose mode on.
 * - (2) inputs		: the stack of input files.
 */
#define VSyydrwwrap()	VSyydrwWrap( errFile != NULL, inputs )

/*
 * Short cuts.
 */
#define RETOP( token, value ) \
		VSyydrwlval.tokVal._ival = (value) ; \
		return VSyydrwlval.tokVal.type = (token)
/*----------------------------------------------------------------------------*/
void VSdrwLexUnput( character ) int character ; {

	unput( character ) ;

} /* VSdrwLexUnput */
/*----------------------------------------------------------------------------*/
# define VSyydrwNEWLINE 10
VSyydrwlex(){
int nstr; extern int VSyydrwprevious;
while((nstr = VSyydrwlook()) >= 0)
VSyydrwfussy: switch(nstr){
case 0:
if(VSyydrwwrap()) return(0); break;
case 1:
{ /* Keyword			*/
		if( ! vs$drwKeyword(	keyword = VSyydrwtext,
					logfile	= errFile,
					token	= &VSyydrwlval.tokVal ) ) {
			VSyydrwlval.tokVal.type = VS_UNKNOWN_IDENT ;
			return VS_ERROR ;
		}
		return VSyydrwlval.tokVal.type ;
}
break;
case 2:
{ /* Identifier of variable	*/
		int	trunc ;
		VSstrncpy(	VSyydrwlval.tokVal._sval,
				VSyydrwtext,
				VS_K_tokMAX_SIZE,
				&trunc ) ;
		if( trunc && errFile ) {
			VSdrwPrintf(
			"!!! Variable truncated '%s', length must be <= %d\n",
			VSyydrwtext + 1, VS_K_tokMAX_SIZE - 1 ) ;
		}
		return VSyydrwlval.tokVal.type = VARIABLE ;
}
break;
case 3:
{ /* Integer number		*/
		VSyydrwlval.tokVal._ival	= atol( VSyydrwtext ) ;
		VSyydrwlval.tokVal.type	= VS_int ;
		return VS_INT ;
}
break;
case 4:
case 5:
case 6:
		{
	  /* Double-precision floating point number	*/
		VSyydrwlval.tokVal._dval	= atof( VSyydrwtext ) ;
		VSyydrwlval.tokVal.type	= VS_double ;
		return VS_DOUBLE ;
}
break;
case 7:
	{ RETOP( ASSIGN	, -1		) ; }
break;
case 8:
	{ RETOP( ';'	, -1		) ; }
break;
case 9:
	{ RETOP( ':'	, -1		) ; }
break;
case 10:
	{ RETOP( '('	, -1		) ; }
break;
case 11:
	{ RETOP( ')'	, -1		) ; }
break;
case 12:
	{ RETOP( '['	, -1		) ; }
break;
case 13:
	{ RETOP( ']'	, -1		) ; }
break;
case 14:
	{ RETOP( '{'	, -1		) ; }
break;
case 15:
	{ RETOP( '}'	, -1		) ; }
break;
case 16:
	{ RETOP( ','	, -1		) ; }
break;
case 17:
	{ RETOP( '='	, VS_eq		) ; }
break;
case 18:
	{ RETOP( VS_NE	, VS_ne		) ; }
break;
case 19:
	{ RETOP( VS_LT	, VS_lt		) ; }
break;
case 20:
	{ RETOP( VS_GT	, VS_gt		) ; }
break;
case 21:
	{ RETOP( VS_LE	, VS_le		) ; }
break;
case 22:
	{ RETOP( VS_GE	, VS_ge		) ; }
break;
case 23:
	{ RETOP( VS_NOT	, VS_not	) ; }
break;
case 24:
	{ RETOP( VS_AND	, VS_and	) ; }
break;
case 25:
	{ RETOP( VS_OR	, VS_or		) ; }
break;
case 26:
	{ RETOP( VS_POW	, VS_pow	) ; }
break;
case 27:
	{ RETOP( '+'	, VS_plus	) ; }
break;
case 28:
	{ RETOP( '-'	, VS_minus	) ; }
break;
case 29:
	{ RETOP( '*'	, VS_mult	) ; }
break;
case 30:
	{ RETOP( '/'	, VS_div	) ; }
break;
case 31:
	;
break;
case 32:
	{
	/*
	 * Now the string rigmarole.
	 */
	int	returnString ;

#ifdef vsDEBUG
	printf( "****** STRING <%s> <%c>\n", VSyydrwtext, VSyydrwtext[VSyydrwleng-1] ) ;
#endif
	returnString = FALSE ;

	if( VSyydrwtext[VSyydrwleng-1] == '\\' ) {

		int	c ;

		/* Beware of "\\" */

		if( ( c = input() ) == '"' ) {
			returnString = TRUE ;
		} else {
			unput( c )
			VSyydrwmore() ;
		}
	} else {
		returnString = TRUE ;
	}
	if( returnString ) {
		int trunc ;

		/* Eat ending '"' */
		input() ;

		VSstrncpy(	VSyydrwlval.tokVal._sval,
				VSyydrwtext + 1,
				VS_K_tokMAX_SIZE,
				&trunc ) ;
		if( trunc && errFile ) {
			VSdrwPrintf(
			"!!! String truncated '%s', length must be <= %d\n",
			VSyydrwtext + 1, VS_K_tokMAX_SIZE - 1 ) ;
		}
		VSyydrwlval.tokVal.type = VS_string ;
		return VS_STRING ;
	}
}
break;
case 33:
;
break;
case 34:
	{
	if( errFile ) {
		char	c = *VSyydrwtext ;
		if( isprint( c ) ) {
			VSdrwPrintf( "!!! Invalid character '%c'\n", c ) ;
		} else {
			VSdrwPrintf( "!!! Invalid character '\\%o'\n", c ) ;
		}			
	}
	strcpy( VSyydrwlval.tokVal._sval, VSyydrwtext ) ;
	VSyydrwlval.tokVal.type = VS_BAD_CHAR ;
  	return VS_ERROR ;
}
break;
case -1:
break;
default:
fprintf(VSyydrwout,"bad switch VSyydrwlook %d",nstr);
} return(0); }
/* end of VSyydrwlex */
/*----------------------------------------------------------------------------*/
int VSyydrwvstop[] = {
0,

34,
0,

33,
34,
0,

33,
0,

23,
34,
0,

32,
34,
0,

34,
-31,
0,

34,
0,

24,
34,
0,

10,
34,
0,

11,
34,
0,

29,
34,
0,

27,
34,
0,

16,
34,
0,

28,
34,
0,

34,
0,

30,
34,
0,

3,
34,
0,

9,
34,
0,

8,
34,
0,

19,
34,
0,

17,
34,
0,

20,
34,
0,

1,
34,
0,

12,
34,
0,

13,
34,
0,

14,
34,
0,

25,
34,
0,

15,
34,
0,

18,
0,

32,
0,

-31,
0,

31,
0,

2,
0,

26,
0,

5,
0,

4,
0,

3,
0,

7,
0,

21,
0,

22,
0,

1,
0,

4,
5,
0,

6,
0,

5,
0,

4,
0,

4,
5,
0,
0};
# define VSyydrwTYPE char
struct VSyydrwwork { VSyydrwTYPE verify, advance; } VSyydrwcrank[] = {
0,0,	0,0,	1,3,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	1,4,	1,5,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	1,6,	1,7,	
1,8,	1,9,	32,0,	1,10,	
0,0,	1,11,	1,12,	1,13,	
1,14,	1,15,	1,16,	1,17,	
1,18,	1,19,	13,36,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	1,20,	
1,21,	1,22,	1,23,	1,24,	
6,31,	20,41,	1,25,	22,42,	
24,43,	0,0,	1,25,	37,45,	
2,6,	46,52,	2,8,	2,9,	
0,0,	2,10,	0,0,	2,11,	
2,12,	2,13,	0,0,	2,15,	
0,0,	2,17,	2,18,	0,0,	
0,0,	0,0,	0,0,	0,0,	
1,26,	0,0,	1,27,	0,0,	
1,3,	2,20,	2,21,	2,22,	
2,23,	2,24,	7,32,	37,45,	
0,0,	46,52,	0,0,	0,0,	
8,33,	0,0,	7,32,	7,32,	
0,0,	0,0,	0,0,	0,0,	
8,33,	8,34,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
1,28,	1,29,	1,30,	0,0,	
0,0,	0,0,	2,26,	0,0,	
2,27,	0,0,	0,0,	7,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	8,33,	0,0,	0,0,	
7,32,	0,0,	7,32,	0,0,	
0,0,	7,32,	8,33,	0,0,	
8,33,	0,0,	0,0,	8,33,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	2,28,	2,29,	
2,30,	0,0,	7,32,	0,0,	
0,0,	0,0,	7,32,	0,0,	
8,33,	0,0,	0,0,	0,0,	
8,33,	17,37,	17,37,	17,37,	
17,37,	17,37,	17,37,	17,37,	
17,37,	17,37,	17,37,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
7,32,	0,0,	0,0,	0,0,	
0,0,	0,0,	8,33,	9,35,	
9,35,	9,35,	9,35,	9,35,	
9,35,	9,35,	9,35,	9,35,	
9,35,	9,35,	9,35,	9,35,	
9,35,	9,35,	9,35,	9,35,	
9,35,	9,35,	9,35,	9,35,	
9,35,	9,35,	9,35,	9,35,	
9,35,	0,0,	0,0,	0,0,	
0,0,	9,35,	0,0,	9,35,	
9,35,	9,35,	9,35,	9,35,	
9,35,	9,35,	9,35,	9,35,	
9,35,	9,35,	9,35,	9,35,	
9,35,	9,35,	9,35,	9,35,	
9,35,	9,35,	9,35,	9,35,	
9,35,	9,35,	9,35,	9,35,	
9,35,	19,38,	0,0,	19,39,	
19,39,	19,39,	19,39,	19,39,	
19,39,	19,39,	19,39,	19,39,	
19,39,	35,35,	35,35,	35,35,	
35,35,	35,35,	35,35,	35,35,	
35,35,	35,35,	35,35,	0,0,	
19,40,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	40,48,	0,0,	40,48,	
0,0,	25,44,	40,49,	40,49,	
40,49,	40,49,	40,49,	40,49,	
40,49,	40,49,	40,49,	40,49,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
19,40,	25,44,	25,44,	25,44,	
25,44,	25,44,	25,44,	25,44,	
25,44,	25,44,	25,44,	25,44,	
25,44,	25,44,	25,44,	25,44,	
25,44,	25,44,	25,44,	25,44,	
25,44,	25,44,	25,44,	25,44,	
25,44,	25,44,	25,44,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	25,44,	25,44,	25,44,	
25,44,	25,44,	25,44,	25,44,	
25,44,	25,44,	25,44,	25,44,	
25,44,	25,44,	25,44,	25,44,	
25,44,	25,44,	25,44,	25,44,	
25,44,	25,44,	25,44,	25,44,	
25,44,	25,44,	25,44,	38,46,	
38,46,	38,46,	38,46,	38,46,	
38,46,	38,46,	38,46,	38,46,	
38,46,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
45,50,	0,0,	45,50,	0,0,	
38,47,	45,51,	45,51,	45,51,	
45,51,	45,51,	45,51,	45,51,	
45,51,	45,51,	45,51,	47,53,	
0,0,	47,53,	0,0,	0,0,	
47,54,	47,54,	47,54,	47,54,	
47,54,	47,54,	47,54,	47,54,	
47,54,	47,54,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
38,47,	48,49,	48,49,	48,49,	
48,49,	48,49,	48,49,	48,49,	
48,49,	48,49,	48,49,	50,51,	
50,51,	50,51,	50,51,	50,51,	
50,51,	50,51,	50,51,	50,51,	
50,51,	52,55,	0,0,	52,55,	
0,0,	0,0,	52,56,	52,56,	
52,56,	52,56,	52,56,	52,56,	
52,56,	52,56,	52,56,	52,56,	
53,54,	53,54,	53,54,	53,54,	
53,54,	53,54,	53,54,	53,54,	
53,54,	53,54,	55,56,	55,56,	
55,56,	55,56,	55,56,	55,56,	
55,56,	55,56,	55,56,	55,56,	
0,0};
struct VSyydrwsvf VSyydrwsvec[] = {
0,	0,	0,
VSyydrwcrank+-1,	0,		0,	
VSyydrwcrank+-39,	VSyydrwsvec+1,	0,	
VSyydrwcrank+0,	0,		VSyydrwvstop+1,
VSyydrwcrank+0,	0,		VSyydrwvstop+3,
VSyydrwcrank+0,	0,		VSyydrwvstop+6,
VSyydrwcrank+3,	0,		VSyydrwvstop+8,
VSyydrwcrank+-101,	0,		VSyydrwvstop+11,
VSyydrwcrank+-107,	0,		VSyydrwvstop+14,
VSyydrwcrank+138,	0,		VSyydrwvstop+17,
VSyydrwcrank+0,	0,		VSyydrwvstop+19,
VSyydrwcrank+0,	0,		VSyydrwvstop+22,
VSyydrwcrank+0,	0,		VSyydrwvstop+25,
VSyydrwcrank+8,	0,		VSyydrwvstop+28,
VSyydrwcrank+0,	0,		VSyydrwvstop+31,
VSyydrwcrank+0,	0,		VSyydrwvstop+34,
VSyydrwcrank+0,	0,		VSyydrwvstop+37,
VSyydrwcrank+129,	0,		VSyydrwvstop+40,
VSyydrwcrank+0,	0,		VSyydrwvstop+42,
VSyydrwcrank+215,	0,		VSyydrwvstop+45,
VSyydrwcrank+4,	0,		VSyydrwvstop+48,
VSyydrwcrank+0,	0,		VSyydrwvstop+51,
VSyydrwcrank+6,	0,		VSyydrwvstop+54,
VSyydrwcrank+0,	0,		VSyydrwvstop+57,
VSyydrwcrank+7,	0,		VSyydrwvstop+60,
VSyydrwcrank+252,	0,		VSyydrwvstop+63,
VSyydrwcrank+0,	0,		VSyydrwvstop+66,
VSyydrwcrank+0,	0,		VSyydrwvstop+69,
VSyydrwcrank+0,	0,		VSyydrwvstop+72,
VSyydrwcrank+0,	0,		VSyydrwvstop+75,
VSyydrwcrank+0,	0,		VSyydrwvstop+78,
VSyydrwcrank+0,	0,		VSyydrwvstop+81,
VSyydrwcrank+-4,	VSyydrwsvec+7,	VSyydrwvstop+83,
VSyydrwcrank+0,	VSyydrwsvec+8,	VSyydrwvstop+85,
VSyydrwcrank+0,	0,		VSyydrwvstop+87,
VSyydrwcrank+225,	VSyydrwsvec+9,	VSyydrwvstop+89,
VSyydrwcrank+0,	0,		VSyydrwvstop+91,
VSyydrwcrank+2,	VSyydrwsvec+17,	VSyydrwvstop+93,
VSyydrwcrank+327,	0,		VSyydrwvstop+95,
VSyydrwcrank+0,	VSyydrwsvec+19,	VSyydrwvstop+97,
VSyydrwcrank+250,	0,		0,	
VSyydrwcrank+0,	0,		VSyydrwvstop+99,
VSyydrwcrank+0,	0,		VSyydrwvstop+101,
VSyydrwcrank+0,	0,		VSyydrwvstop+103,
VSyydrwcrank+0,	VSyydrwsvec+25,	VSyydrwvstop+105,
VSyydrwcrank+349,	0,		0,	
VSyydrwcrank+4,	VSyydrwsvec+38,	VSyydrwvstop+107,
VSyydrwcrank+364,	0,		0,	
VSyydrwcrank+381,	0,		0,	
VSyydrwcrank+0,	VSyydrwsvec+48,	VSyydrwvstop+110,
VSyydrwcrank+391,	0,		0,	
VSyydrwcrank+0,	VSyydrwsvec+50,	VSyydrwvstop+112,
VSyydrwcrank+406,	0,		0,	
VSyydrwcrank+416,	0,		0,	
VSyydrwcrank+0,	VSyydrwsvec+53,	VSyydrwvstop+114,
VSyydrwcrank+426,	0,		0,	
VSyydrwcrank+0,	VSyydrwsvec+55,	VSyydrwvstop+116,
0,	0,	0};
struct VSyydrwwork *VSyydrwtop = VSyydrwcrank+483;
struct VSyydrwsvf *VSyydrwbgin = VSyydrwsvec+1;
char VSyydrwmatch[] = {
00  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,011 ,012 ,01  ,01  ,011 ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
011 ,01  ,'"' ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,'+' ,01  ,'-' ,01  ,01  ,
'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,
'0' ,'0' ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,'A' ,'A' ,'A' ,'A' ,'E' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,01  ,01  ,01  ,01  ,'_' ,
01  ,'A' ,'A' ,'A' ,'A' ,'E' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,01  ,01  ,01  ,01  ,01  ,
0};
char VSyydrwextra[] = {
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,1,
0,0,0,0,0,0,0,0,
0};
#ident	"@(#)libl:lib/ncform	1.3	1.2 (Intergraph) 3/10/88"
int VSyydrwlineno =1;
# define VSyydrwU(x) x
# define NLSTATE VSyydrwprevious=VSyydrwNEWLINE
char VSyydrwtext[VSyydrwLMAX];
struct VSyydrwsvf *VSyydrwlstate [VSyydrwLMAX], **VSyydrwlsp, **VSyydrwolsp;
char VSyydrwsbuf[VSyydrwLMAX];
char *VSyydrwsptr = VSyydrwsbuf;
int *VSyydrwfnd;
extern struct VSyydrwsvf *VSyydrwestate;
int VSyydrwprevious = VSyydrwNEWLINE;
VSyydrwlook(){
	register struct VSyydrwsvf *VSyydrwstate, **lsp;
	register struct VSyydrwwork *VSyydrwt;
	struct VSyydrwsvf *VSyydrwz;
	int VSyydrwch, VSyydrwfirst;
	struct VSyydrwwork *VSyydrwr;
# ifdef LEXDEBUG
	int debug;
# endif
	char *VSyydrwlastch;
	/* start off machines */
# ifdef LEXDEBUG
	debug = 0;
# endif
	VSyydrwfirst=1;
	if (!VSyydrwmorfg)
		VSyydrwlastch = VSyydrwtext;
	else {
		VSyydrwmorfg=0;
		VSyydrwlastch = VSyydrwtext+VSyydrwleng;
		}
	for(;;){
		lsp = VSyydrwlstate;
		VSyydrwestate = VSyydrwstate = VSyydrwbgin;
		if (VSyydrwprevious==VSyydrwNEWLINE) VSyydrwstate++;
		for (;;){
# ifdef LEXDEBUG
			if(debug)fprintf(VSyydrwout,"state %d\n",VSyydrwstate-VSyydrwsvec-1);
# endif
			VSyydrwt = VSyydrwstate->VSyydrwstoff;
			if(VSyydrwt == VSyydrwcrank && !VSyydrwfirst){  /* may not be any transitions */
				VSyydrwz = VSyydrwstate->VSyydrwother;
				if(VSyydrwz == 0)break;
				if(VSyydrwz->VSyydrwstoff == VSyydrwcrank)break;
				}
			*VSyydrwlastch++ = VSyydrwch = input();
			VSyydrwfirst=0;
		tryagain:
# ifdef LEXDEBUG
			if(debug){
				fprintf(VSyydrwout,"char ");
				allprint(VSyydrwch);
				putchar('\n');
				}
# endif
			VSyydrwr = VSyydrwt;
			if ( (int)VSyydrwt > (int)VSyydrwcrank){
				VSyydrwt = VSyydrwr + VSyydrwch;
				if (VSyydrwt <= VSyydrwtop && VSyydrwt->verify+VSyydrwsvec == VSyydrwstate){
					if(VSyydrwt->advance+VSyydrwsvec == VSyydrwLERR)	/* error transitions */
						{unput(*--VSyydrwlastch);break;}
					*lsp++ = VSyydrwstate = VSyydrwt->advance+VSyydrwsvec;
					goto contin;
					}
				}
# ifdef VSyydrwOPTIM
			else if((int)VSyydrwt < (int)VSyydrwcrank) {		/* r < VSyydrwcrank */
				VSyydrwt = VSyydrwr = VSyydrwcrank+(VSyydrwcrank-VSyydrwt);
# ifdef LEXDEBUG
				if(debug)fprintf(VSyydrwout,"compressed state\n");
# endif
				VSyydrwt = VSyydrwt + VSyydrwch;
				if(VSyydrwt <= VSyydrwtop && VSyydrwt->verify+VSyydrwsvec == VSyydrwstate){
					if(VSyydrwt->advance+VSyydrwsvec == VSyydrwLERR)	/* error transitions */
						{unput(*--VSyydrwlastch);break;}
					*lsp++ = VSyydrwstate = VSyydrwt->advance+VSyydrwsvec;
					goto contin;
					}
				VSyydrwt = VSyydrwr + VSyydrwU(VSyydrwmatch[VSyydrwch]);
# ifdef LEXDEBUG
				if(debug){
					fprintf(VSyydrwout,"try fall back character ");
					allprint(VSyydrwU(VSyydrwmatch[VSyydrwch]));
					putchar('\n');
					}
# endif
				if(VSyydrwt <= VSyydrwtop && VSyydrwt->verify+VSyydrwsvec == VSyydrwstate){
					if(VSyydrwt->advance+VSyydrwsvec == VSyydrwLERR)	/* error transition */
						{unput(*--VSyydrwlastch);break;}
					*lsp++ = VSyydrwstate = VSyydrwt->advance+VSyydrwsvec;
					goto contin;
					}
				}
			if ((VSyydrwstate = VSyydrwstate->VSyydrwother) && (VSyydrwt= VSyydrwstate->VSyydrwstoff) != VSyydrwcrank){
# ifdef LEXDEBUG
				if(debug)fprintf(VSyydrwout,"fall back to state %d\n",VSyydrwstate-VSyydrwsvec-1);
# endif
				goto tryagain;
				}
# endif
			else
				{unput(*--VSyydrwlastch);break;}
		contin:
# ifdef LEXDEBUG
			if(debug){
				fprintf(VSyydrwout,"state %d char ",VSyydrwstate-VSyydrwsvec-1);
				allprint(VSyydrwch);
				putchar('\n');
				}
# endif
			;
			}
# ifdef LEXDEBUG
		if(debug){
			fprintf(VSyydrwout,"stopped at %d with ",*(lsp-1)-VSyydrwsvec-1);
			allprint(VSyydrwch);
			putchar('\n');
			}
# endif
		while (lsp-- > VSyydrwlstate){
			*VSyydrwlastch-- = 0;
			if (*lsp != 0 && (VSyydrwfnd= (*lsp)->VSyydrwstops) && *VSyydrwfnd > 0){
				VSyydrwolsp = lsp;
				if(VSyydrwextra[*VSyydrwfnd]){		/* must backup */
					while(VSyydrwback((*lsp)->VSyydrwstops,-*VSyydrwfnd) != 1 && lsp > VSyydrwlstate){
						lsp--;
						unput(*VSyydrwlastch--);
						}
					}
				VSyydrwprevious = VSyydrwU(*VSyydrwlastch);
				VSyydrwlsp = lsp;
				VSyydrwleng = VSyydrwlastch-VSyydrwtext+1;
				VSyydrwtext[VSyydrwleng] = 0;
# ifdef LEXDEBUG
				if(debug){
					fprintf(VSyydrwout,"\nmatch ");
					sprint(VSyydrwtext);
					fprintf(VSyydrwout," action %d\n",*VSyydrwfnd);
					}
# endif
				return(*VSyydrwfnd++);
				}
			unput(*VSyydrwlastch);
			}
		/* you may or may not be reading from VSyydrwin - we really   */
		/* can't tell at this point. So whenver VSyydrwtext[0] is set */
		/* to 0, this indicates end of file			 */
		if (VSyydrwtext[0] == 0 /* && feof(VSyydrwin) */ )
			{
			VSyydrwsptr=VSyydrwsbuf;
			return(0);
			}
		VSyydrwprevious = VSyydrwtext[0] = input();
		if (VSyydrwprevious>0)
			output(VSyydrwprevious);
		VSyydrwlastch=VSyydrwtext;
# ifdef LEXDEBUG
		if(debug)putchar('\n');
# endif
		}
	}
VSyydrwback(p, m)
	int *p;
{
if (p==0) return(0);
while (*p)
	{
	if (*p++ == m)
		return(1);
	}
return(0);
}
	/* the following are only used in the lex library */
VSyydrwinput(){
	return(input());
	}
VSyydrwoutput(c)
  int c; {
	output(c);
	}
VSyydrwunput(c)
   int c; {
	unput(c);
	}
