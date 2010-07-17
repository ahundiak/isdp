# include "stdio.h"
# define U(x) x
# define NLSTATE VS_yyprevious=VS_yyNEWLINE
# define BEGIN VS_yybgin = VS_yysvec + 1 +
# define INITIAL 0
# define VS_yyLERR VS_yysvec
# define VS_yySTATE (VS_yyestate-VS_yysvec-1)
# define VS_yyOPTIM 1
# define VS_yyLMAX 200
# define output(c) putc(c,VS_yyout)
# define input() (((VS_yytchar=VS_yysptr>VS_yysbuf?U(*--VS_yysptr):getc(VS_yyin))==10?(VS_yylineno++,VS_yytchar):VS_yytchar)==EOF?0:VS_yytchar)
# define unput(c) {VS_yytchar= (c);if(VS_yytchar=='\n')VS_yylineno--;*VS_yysptr++=VS_yytchar;}
# define VS_yymore() (VS_yymorfg=1)
# define ECHO fprintf(VS_yyout, "%s",VS_yytext)
# define REJECT { nstr = VS_yyreject(); goto VS_yyfussy;}
int VS_yyleng; extern char VS_yytext[];
int VS_yymorfg;
extern char *VS_yysptr, VS_yysbuf[];
int VS_yytchar;
FILE *VS_yyin = {stdin}, *VS_yyout = {stdout};
extern int VS_yylineno;
struct VS_yysvf { 
	struct VS_yywork *VS_yystoff;
	struct VS_yysvf *VS_yyother;
	int *VS_yystops;};
struct VS_yysvf *VS_yyestate;
extern struct VS_yysvf VS_yysvec[], *VS_yybgin;
/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
/*
 * Because OMminimum.h has a structure whose member is called "output".
 */
#undef output
/*
 * We also have a structure field called "input" in vs.h ...
 */
#undef input
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsslc.h"
#include "vsslcmacros.h"
#include "vsdbgmacros.h"
#include "vsmiscmacros.h"
#define output(x)
/*
 * Includes of function prototypes.
 */
#include "vsslcproto.h"

static char	*VS_Gp_LEXTransString ;
static int	VS_Gi_CurChar ;

#define VS_yylex()	VSslcTranslex( toFlag, count, buffer ) \
int	toFlag,	\
	*count ;	\
char	*buffer ;

#define __ECHO( string )	{\
			if( buffer ) strcat( buffer, (string) ) ;\
			else *count += strlen( (string) ) ;\
		}
#define _ECHO	__ECHO( VS_yytext )
/*----------------------------------------------------------------------------*/
static void VS_slcSetLEXstring( s ) char *s ; {

	VS_Gp_LEXTransString	= s ;
	VS_Gi_CurChar		= 0 ;

} /* VS_slcSetLEXstring */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
static int VS_getc( f ) FILE *f ; {
	int	c = VS_Gp_LEXTransString[VS_Gi_CurChar] ;

	if( !c ) {
		c = EOF ;
	} else {
		VS_Gi_CurChar++ ;
	}
	return c ;
	
} /* VS_getc */
/*----------------------------------------------------------------------------*/
static int VS_yywrap() {
	VS_yylineno = 1 ;
	VS_yysptr = VS_yysbuf ;
	return 1 ;

} /* VS_yywrap */
/*----------------------------------------------------------------------------*/

#define input() ( ( ( VS_yytchar = VS_yysptr > VS_yysbuf \
				? U( *--VS_yysptr ) \
				: VS_getc( VS_yyin ) \
		     ) == 10 \
			? ( VS_yylineno++ , VS_yytchar ) \
			: VS_yytchar \
		   ) == EOF ? 0 : VS_yytchar \
		)
# define VS_yyNEWLINE 10
VS_yylex(){
int nstr; extern int VS_yyprevious;
while((nstr = VS_yylook()) >= 0)
VS_yyfussy: switch(nstr){
case 0:
if(VS_yywrap()) return(0); break;
case 1:
	{ _ECHO ; }
break;
case 2:
	{ _ECHO ; }
break;
case 3:
case 4:
case 5:
{ _ECHO ; }
break;
case 6:
case 7:
	{

	VStktxt	outKw ;

	if( vs$translateKw(	toFlag	= toFlag,
				inKw	= VS_yytext,
				outKw	= outKw ) ) {
		__ECHO( outKw ) ;
	} else _ECHO ;
}
break;
case 8:
{ _ECHO ; }
break;
case 9:
	{ _ECHO ; }
break;
case 10:
	{
	if( VS_yytext[VS_yyleng-1] == '\\' ) {
		VS_yymore() ;
	} else {
		input() ;
		_ECHO ; __ECHO( "\"" ) ; 
	}
}
break;
case 11:
{ _ECHO ; }
break;
case 12:
	{ if( isascii( *VS_yytext ) ) _ECHO ; }
break;
case -1:
break;
default:
fprintf(VS_yyout,"bad switch VS_yylook %d",nstr);
} return(0); }
/* end of VS_yylex */
/*----------------------------------------------------------------------------*/
int VSslcTranslate( msg, toFlag, inText, outText )

long	*msg ;
int	toFlag ;
char	*inText,
	**outText ; {

	int count ;

	count = 0 ;
	VS_slcSetLEXstring( inText ) ;

	VSslcTranslex( toFlag, &count, (char *) NULL ) ;

	if( ( *outText = _MALLOC( count + 1, char ) ) ) {

		**outText = '\0' ;

		VS_slcSetLEXstring( inText ) ;
		VSslcTranslex( toFlag, (int *) NULL, *outText ) ;

		*msg = MSSUCC ;
	} else	*msg = EMS_E_NoDynamicMemory ;

	return *msg & 1 ;

} /* VSslcTranslate */
/*----------------------------------------------------------------------------*/

int VS_yyvstop[] = {
0,

12,
0,

11,
12,
0,

11,
0,

10,
12,
0,

12,
-1,
0,

12,
0,

12,
0,

2,
12,
0,

12,
0,

7,
9,
12,
0,

10,
0,

-1,
0,

1,
0,

8,
0,

4,
0,

3,
0,

2,
0,

6,
0,

7,
9,
0,

9,
0,

3,
4,
0,

5,
0,

4,
0,

3,
0,

3,
4,
0,
0};
# define VS_yyTYPE char
struct VS_yywork { VS_yyTYPE verify, advance; } VS_yycrank[] = {
0,0,	0,0,	1,3,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	1,4,	1,5,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
6,13,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
6,13,	6,13,	0,0,	0,0,	
0,0,	0,0,	0,0,	1,6,	
1,7,	0,0,	1,8,	2,7,	
0,0,	2,8,	0,0,	1,3,	
1,3,	0,0,	1,3,	1,9,	
7,14,	1,10,	2,9,	0,0,	
0,0,	6,0,	0,0,	0,0,	
7,14,	7,15,	0,0,	1,3,	
0,0,	6,13,	6,13,	0,0,	
6,13,	1,11,	1,12,	6,13,	
2,11,	13,0,	1,12,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	6,13,	0,0,	0,0,	
0,0,	7,14,	0,0,	0,0,	
6,13,	0,0,	0,0,	0,0,	
6,13,	7,14,	7,14,	0,0,	
7,14,	0,0,	0,0,	7,14,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	7,14,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
7,14,	0,0,	0,0,	0,0,	
7,14,	8,0,	8,0,	8,0,	
8,0,	8,0,	8,0,	8,0,	
8,0,	8,0,	8,0,	8,0,	
8,0,	8,0,	8,0,	8,0,	
8,0,	8,0,	8,0,	8,0,	
8,0,	8,0,	8,0,	8,0,	
8,0,	8,0,	8,0,	8,0,	
8,0,	8,0,	8,0,	8,0,	
8,0,	8,0,	8,0,	8,0,	
8,0,	8,16,	8,0,	8,0,	
8,0,	8,0,	8,17,	8,0,	
8,0,	8,17,	0,0,	8,0,	
8,17,	18,25,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	8,0,	8,0,	
8,0,	8,0,	8,0,	26,32,	
8,0,	8,17,	0,0,	0,0,	
0,0,	8,17,	9,18,	9,18,	
9,18,	9,18,	9,18,	9,18,	
9,18,	9,18,	9,18,	9,18,	
10,19,	18,25,	10,20,	10,20,	
10,20,	10,20,	10,20,	10,20,	
10,20,	10,20,	10,20,	10,20,	
8,0,	0,0,	8,0,	26,32,	
8,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	10,21,	
0,0,	0,0,	0,0,	0,0,	
0,0,	19,26,	19,26,	19,26,	
19,26,	19,26,	19,26,	19,26,	
19,26,	19,26,	19,26,	0,0,	
0,0,	0,0,	0,0,	8,0,	
8,0,	8,0,	8,0,	8,0,	
0,0,	0,0,	19,27,	0,0,	
0,0,	0,0,	0,0,	10,21,	
11,22,	11,22,	11,22,	11,22,	
11,22,	11,22,	11,22,	11,22,	
11,22,	11,22,	11,22,	11,22,	
11,22,	11,22,	11,22,	11,22,	
11,22,	11,22,	11,22,	11,22,	
11,22,	11,22,	11,22,	11,22,	
11,22,	11,22,	19,27,	0,0,	
0,0,	0,0,	11,22,	0,0,	
11,22,	11,22,	11,22,	11,22,	
11,22,	11,22,	11,22,	11,22,	
11,22,	11,22,	11,22,	11,22,	
11,22,	11,22,	11,22,	11,22,	
11,22,	11,22,	11,22,	11,22,	
11,22,	11,22,	11,22,	11,22,	
11,22,	11,22,	12,23,	12,23,	
12,23,	12,23,	12,23,	12,23,	
12,23,	12,23,	12,23,	12,23,	
12,24,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	12,23,	
12,23,	12,23,	12,23,	12,23,	
12,23,	12,23,	12,23,	12,23,	
12,23,	12,23,	12,23,	12,23,	
12,23,	12,23,	12,23,	12,23,	
12,23,	12,23,	12,23,	12,23,	
12,23,	12,23,	12,23,	12,23,	
12,23,	0,0,	0,0,	0,0,	
0,0,	12,23,	0,0,	12,23,	
12,23,	12,23,	12,23,	12,23,	
12,23,	12,23,	12,23,	12,23,	
12,23,	12,23,	12,23,	12,23,	
12,23,	12,23,	12,23,	12,23,	
12,23,	12,23,	12,23,	12,23,	
12,23,	12,23,	12,23,	12,23,	
12,23,	17,0,	17,0,	17,0,	
17,0,	17,0,	17,0,	17,0,	
17,0,	17,0,	17,0,	17,0,	
17,0,	17,0,	17,0,	17,0,	
17,0,	17,0,	17,0,	17,0,	
17,0,	17,0,	17,0,	17,0,	
17,0,	17,0,	17,0,	17,0,	
17,0,	17,0,	17,0,	17,0,	
17,0,	17,0,	17,0,	17,0,	
17,0,	17,16,	17,0,	17,0,	
17,0,	17,0,	0,0,	17,0,	
17,0,	0,0,	0,0,	17,0,	
22,22,	22,22,	22,22,	22,22,	
22,22,	22,22,	22,22,	22,22,	
22,22,	22,22,	17,0,	17,0,	
17,0,	17,0,	17,0,	21,28,	
17,0,	21,28,	0,0,	0,0,	
21,29,	21,29,	21,29,	21,29,	
21,29,	21,29,	21,29,	21,29,	
21,29,	21,29,	28,29,	28,29,	
28,29,	28,29,	28,29,	28,29,	
28,29,	28,29,	28,29,	28,29,	
0,0,	0,0,	0,0,	0,0,	
17,0,	25,30,	17,0,	25,30,	
17,0,	0,0,	25,31,	25,31,	
25,31,	25,31,	25,31,	25,31,	
25,31,	25,31,	25,31,	25,31,	
0,0,	0,0,	0,0,	24,24,	
24,24,	24,24,	24,24,	24,24,	
24,24,	24,24,	24,24,	24,24,	
24,24,	0,0,	0,0,	17,0,	
17,0,	17,0,	17,0,	17,0,	
24,24,	24,24,	24,24,	24,24,	
24,24,	24,24,	24,24,	24,24,	
24,24,	24,24,	24,24,	24,24,	
24,24,	24,24,	24,24,	24,24,	
24,24,	24,24,	24,24,	24,24,	
24,24,	24,24,	24,24,	24,24,	
24,24,	24,24,	0,0,	0,0,	
0,0,	0,0,	24,24,	0,0,	
24,24,	24,24,	24,24,	24,24,	
24,24,	24,24,	24,24,	24,24,	
24,24,	24,24,	24,24,	24,24,	
24,24,	24,24,	24,24,	24,24,	
24,24,	24,24,	24,24,	24,24,	
24,24,	24,24,	24,24,	24,24,	
24,24,	24,24,	27,33,	0,0,	
27,33,	0,0,	0,0,	27,34,	
27,34,	27,34,	27,34,	27,34,	
27,34,	27,34,	27,34,	27,34,	
27,34,	30,31,	30,31,	30,31,	
30,31,	30,31,	30,31,	30,31,	
30,31,	30,31,	30,31,	32,35,	
0,0,	32,35,	0,0,	0,0,	
32,36,	32,36,	32,36,	32,36,	
32,36,	32,36,	32,36,	32,36,	
32,36,	32,36,	33,34,	33,34,	
33,34,	33,34,	33,34,	33,34,	
33,34,	33,34,	33,34,	33,34,	
35,36,	35,36,	35,36,	35,36,	
35,36,	35,36,	35,36,	35,36,	
35,36,	35,36,	0,0,	0,0,	
0,0};
struct VS_yysvf VS_yysvec[] = {
0,	0,	0,
VS_yycrank+-1,	0,		0,	
VS_yycrank+-4,	VS_yysvec+1,	0,	
VS_yycrank+0,	0,		VS_yyvstop+1,
VS_yycrank+0,	0,		VS_yyvstop+3,
VS_yycrank+0,	0,		VS_yyvstop+6,
VS_yycrank+-19,	0,		VS_yyvstop+8,
VS_yycrank+-47,	0,		VS_yyvstop+11,
VS_yycrank+-116,	0,		VS_yyvstop+14,
VS_yycrank+138,	0,		VS_yyvstop+16,
VS_yycrank+150,	0,		VS_yyvstop+18,
VS_yycrank+187,	0,		VS_yyvstop+21,
VS_yycrank+262,	0,		VS_yyvstop+23,
VS_yycrank+-35,	VS_yysvec+6,	VS_yyvstop+27,
VS_yycrank+0,	VS_yysvec+7,	VS_yyvstop+29,
VS_yycrank+0,	0,		VS_yyvstop+31,
VS_yycrank+0,	0,		VS_yyvstop+33,
VS_yycrank+-384,	VS_yysvec+8,	0,	
VS_yycrank+96,	VS_yysvec+9,	VS_yyvstop+35,
VS_yycrank+177,	0,		VS_yyvstop+37,
VS_yycrank+0,	VS_yysvec+10,	VS_yyvstop+39,
VS_yycrank+404,	0,		0,	
VS_yycrank+384,	VS_yysvec+11,	VS_yyvstop+41,
VS_yycrank+0,	VS_yysvec+12,	VS_yyvstop+43,
VS_yycrank+447,	VS_yysvec+12,	VS_yyvstop+46,
VS_yycrank+434,	0,		0,	
VS_yycrank+110,	VS_yysvec+19,	VS_yyvstop+48,
VS_yycrank+527,	0,		0,	
VS_yycrank+414,	0,		0,	
VS_yycrank+0,	VS_yysvec+28,	VS_yyvstop+51,
VS_yycrank+537,	0,		0,	
VS_yycrank+0,	VS_yysvec+30,	VS_yyvstop+53,
VS_yycrank+552,	0,		0,	
VS_yycrank+562,	0,		0,	
VS_yycrank+0,	VS_yysvec+33,	VS_yyvstop+55,
VS_yycrank+572,	0,		0,	
VS_yycrank+0,	VS_yysvec+35,	VS_yyvstop+57,
0,	0,	0};
struct VS_yywork *VS_yytop = VS_yycrank+629;
struct VS_yysvf *VS_yybgin = VS_yysvec+1;
char VS_yymatch[] = {
00  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,011 ,012 ,01  ,01  ,011 ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
011 ,01  ,'"' ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,'*' ,'+' ,01  ,'-' ,'*' ,01  ,
'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,
'0' ,'0' ,':' ,01  ,01  ,01  ,01  ,'*' ,
01  ,'A' ,'A' ,'A' ,'A' ,'E' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'*' ,01  ,'*' ,01  ,'A' ,
01  ,'A' ,'A' ,'A' ,'A' ,'E' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,01  ,01  ,01  ,01  ,01  ,
0};
char VS_yyextra[] = {
0,1,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0};
#ident	"@(#)libl:lib/ncform	1.3	1.2 (Intergraph) 3/10/88"
int VS_yylineno =1;
# define VS_yyU(x) x
# define NLSTATE VS_yyprevious=VS_yyNEWLINE
char VS_yytext[VS_yyLMAX];
struct VS_yysvf *VS_yylstate [VS_yyLMAX], **VS_yylsp, **VS_yyolsp;
char VS_yysbuf[VS_yyLMAX];
char *VS_yysptr = VS_yysbuf;
int *VS_yyfnd;
extern struct VS_yysvf *VS_yyestate;
int VS_yyprevious = VS_yyNEWLINE;
VS_yylook(){
	register struct VS_yysvf *VS_yystate, **lsp;
	register struct VS_yywork *VS_yyt;
	struct VS_yysvf *VS_yyz;
	int VS_yych, VS_yyfirst;
	struct VS_yywork *VS_yyr;
# ifdef LEXDEBUG
	int debug;
# endif
	char *VS_yylastch;
	/* start off machines */
# ifdef LEXDEBUG
	debug = 0;
# endif
	VS_yyfirst=1;
	if (!VS_yymorfg)
		VS_yylastch = VS_yytext;
	else {
		VS_yymorfg=0;
		VS_yylastch = VS_yytext+VS_yyleng;
		}
	for(;;){
		lsp = VS_yylstate;
		VS_yyestate = VS_yystate = VS_yybgin;
		if (VS_yyprevious==VS_yyNEWLINE) VS_yystate++;
		for (;;){
# ifdef LEXDEBUG
			if(debug)fprintf(VS_yyout,"state %d\n",VS_yystate-VS_yysvec-1);
# endif
			VS_yyt = VS_yystate->VS_yystoff;
			if(VS_yyt == VS_yycrank && !VS_yyfirst){  /* may not be any transitions */
				VS_yyz = VS_yystate->VS_yyother;
				if(VS_yyz == 0)break;
				if(VS_yyz->VS_yystoff == VS_yycrank)break;
				}
			*VS_yylastch++ = VS_yych = input();
			VS_yyfirst=0;
		tryagain:
# ifdef LEXDEBUG
			if(debug){
				fprintf(VS_yyout,"char ");
				allprint(VS_yych);
				putchar('\n');
				}
# endif
			VS_yyr = VS_yyt;
			if ( (int)VS_yyt > (int)VS_yycrank){
				VS_yyt = VS_yyr + VS_yych;
				if (VS_yyt <= VS_yytop && VS_yyt->verify+VS_yysvec == VS_yystate){
					if(VS_yyt->advance+VS_yysvec == VS_yyLERR)	/* error transitions */
						{unput(*--VS_yylastch);break;}
					*lsp++ = VS_yystate = VS_yyt->advance+VS_yysvec;
					goto contin;
					}
				}
# ifdef VS_yyOPTIM
			else if((int)VS_yyt < (int)VS_yycrank) {		/* r < VS_yycrank */
				VS_yyt = VS_yyr = VS_yycrank+(VS_yycrank-VS_yyt);
# ifdef LEXDEBUG
				if(debug)fprintf(VS_yyout,"compressed state\n");
# endif
				VS_yyt = VS_yyt + VS_yych;
				if(VS_yyt <= VS_yytop && VS_yyt->verify+VS_yysvec == VS_yystate){
					if(VS_yyt->advance+VS_yysvec == VS_yyLERR)	/* error transitions */
						{unput(*--VS_yylastch);break;}
					*lsp++ = VS_yystate = VS_yyt->advance+VS_yysvec;
					goto contin;
					}
				VS_yyt = VS_yyr + VS_yyU(VS_yymatch[VS_yych]);
# ifdef LEXDEBUG
				if(debug){
					fprintf(VS_yyout,"try fall back character ");
					allprint(VS_yyU(VS_yymatch[VS_yych]));
					putchar('\n');
					}
# endif
				if(VS_yyt <= VS_yytop && VS_yyt->verify+VS_yysvec == VS_yystate){
					if(VS_yyt->advance+VS_yysvec == VS_yyLERR)	/* error transition */
						{unput(*--VS_yylastch);break;}
					*lsp++ = VS_yystate = VS_yyt->advance+VS_yysvec;
					goto contin;
					}
				}
			if ((VS_yystate = VS_yystate->VS_yyother) && (VS_yyt= VS_yystate->VS_yystoff) != VS_yycrank){
# ifdef LEXDEBUG
				if(debug)fprintf(VS_yyout,"fall back to state %d\n",VS_yystate-VS_yysvec-1);
# endif
				goto tryagain;
				}
# endif
			else
				{unput(*--VS_yylastch);break;}
		contin:
# ifdef LEXDEBUG
			if(debug){
				fprintf(VS_yyout,"state %d char ",VS_yystate-VS_yysvec-1);
				allprint(VS_yych);
				putchar('\n');
				}
# endif
			;
			}
# ifdef LEXDEBUG
		if(debug){
			fprintf(VS_yyout,"stopped at %d with ",*(lsp-1)-VS_yysvec-1);
			allprint(VS_yych);
			putchar('\n');
			}
# endif
		while (lsp-- > VS_yylstate){
			*VS_yylastch-- = 0;
			if (*lsp != 0 && (VS_yyfnd= (*lsp)->VS_yystops) && *VS_yyfnd > 0){
				VS_yyolsp = lsp;
				if(VS_yyextra[*VS_yyfnd]){		/* must backup */
					while(VS_yyback((*lsp)->VS_yystops,-*VS_yyfnd) != 1 && lsp > VS_yylstate){
						lsp--;
						unput(*VS_yylastch--);
						}
					}
				VS_yyprevious = VS_yyU(*VS_yylastch);
				VS_yylsp = lsp;
				VS_yyleng = VS_yylastch-VS_yytext+1;
				VS_yytext[VS_yyleng] = 0;
# ifdef LEXDEBUG
				if(debug){
					fprintf(VS_yyout,"\nmatch ");
					sprint(VS_yytext);
					fprintf(VS_yyout," action %d\n",*VS_yyfnd);
					}
# endif
				return(*VS_yyfnd++);
				}
			unput(*VS_yylastch);
			}
		/* you may or may not be reading from VS_yyin - we really   */
		/* can't tell at this point. So whenver VS_yytext[0] is set */
		/* to 0, this indicates end of file			 */
		if (VS_yytext[0] == 0 /* && feof(VS_yyin) */ )
			{
			VS_yysptr=VS_yysbuf;
			return(0);
			}
		VS_yyprevious = VS_yytext[0] = input();
		if (VS_yyprevious>0)
			output(VS_yyprevious);
		VS_yylastch=VS_yytext;
# ifdef LEXDEBUG
		if(debug)putchar('\n');
# endif
		}
	}
VS_yyback(p, m)
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
VS_yyinput(){
	return(input());
	}
VS_yyoutput(c)
  int c; {
	output(c);
	}
VS_yyunput(c)
   int c; {
	unput(c);
	}
