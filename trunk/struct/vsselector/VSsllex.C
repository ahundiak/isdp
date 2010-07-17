# include "stdio.h"
# define U(x) x
# define NLSTATE VSyyprevious=VSyyNEWLINE
# define BEGIN VSyybgin = VSyysvec + 1 +
# define INITIAL 0
# define VSyyLERR VSyysvec
# define VSyySTATE (VSyyestate-VSyysvec-1)
# define VSyyOPTIM 1
# define VSyyLMAX 200
# define output(c) putc(c,VSyyout)
# define input() (((VSyytchar=VSyysptr>VSyysbuf?U(*--VSyysptr):getc(VSyyin))==10?(VSyylineno++,VSyytchar):VSyytchar)==EOF?0:VSyytchar)
# define unput(c) {VSyytchar= (c);if(VSyytchar=='\n')VSyylineno--;*VSyysptr++=VSyytchar;}
# define VSyymore() (VSyymorfg=1)
# define ECHO fprintf(VSyyout, "%s",VSyytext)
# define REJECT { nstr = VSyyreject(); goto VSyyfussy;}
int VSyyleng; extern char VSyytext[];
int VSyymorfg;
extern char *VSyysptr, VSyysbuf[];
int VSyytchar;
FILE *VSyyin = {stdin}, *VSyyout = {stdout};
extern int VSyylineno;
struct VSyysvf { 
	struct VSyywork *VSyystoff;
	struct VSyysvf *VSyyother;
	int *VSyystops;};
struct VSyysvf *VSyyestate;
extern struct VSyysvf VSyysvec[], *VSyybgin;
/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
/*
 * Because OMminimum.h has a structure whose member is called "output".
 */
#undef output
#include "vsslc.h"
#include "VSslyacc.h"
#include "vsslcmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"
#include "vsslcproto.h"

#define output(x)

static char	*VS_Gp_LEXstring ;
static int	VS_Gi_CurrentChar ;
/*----------------------------------------------------------------------------*/
void VSslcGetProgCursor( lineno, charno ) int *lineno, *charno ; {

	int	i, n ;

	*lineno	= VSyylineno ;

	for( i = 0, n = 1 ; i < VS_Gi_CurrentChar ; i++ ) {
		switch( VS_Gp_LEXstring[i] ) {
			case '\n'	:
			case '\r'	: n = 1 ; break ;
			default		: n++	; break ;
		}
	}
	*charno = n ;

} /* VSslcGetProgCursor */
/*----------------------------------------------------------------------------*/
void VSslcSetLEXstring( s ) char *s ; {

	VSyylineno		= 1 ;
	VS_Gp_LEXstring		= s ;
	VS_Gi_CurrentChar	= 0 ;

} /* VSslcSetLEXstring */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
static int VSgetc( f ) FILE *f ; {

	int	c = VS_Gp_LEXstring[VS_Gi_CurrentChar] ;

	if( !c ) {
		c = EOF ;
	} else {
		VS_Gi_CurrentChar++ ;
	}
	return c ;
	
} /* VSgetc */
/*----------------------------------------------------------------------------*/
int VSyywrap() {
	VSyysptr = VSyysbuf ;
	return 1 ;

} /* VSyywrap */
/*----------------------------------------------------------------------------*/
#undef input

#define input() ( ( ( VSyytchar = VSyysptr > VSyysbuf \
				? U( *--VSyysptr ) \
				: VSgetc( VSyyin ) \
		     ) == 10 \
			? ( VSyylineno++ , VSyytchar ) \
			: VSyytchar \
		   ) == EOF ? 0 : VSyytchar \
		)

# define VSyyNEWLINE 10
VSyylex(){
int nstr; extern int VSyyprevious;
while((nstr = VSyylook()) >= 0)
VSyyfussy: switch(nstr){
case 0:
if(VSyywrap()) return(0); break;
case 1:
{

	if( ! vs$searchKeyword(	keyword = VSyytext,
				token	= &VSyylval.tk ) ) {
		VSyylval.tk.type = VS_UNKNOWN_IDENT ;
		return VS_ERROR ;
	}
	return VSyylval.tk.type ;
}
break;
case 2:
	{
	int trunc ;

	/*
	 * It's an identifier.
	 */
	VSstrncpy( VSyylval.tk._sval, VSyytext, VS_K_tokMAX_SIZE, &trunc ) ;

	if( trunc ) {
		VSyylval.tk.type = VS_IDT_TOO_LONG ;
		return VS_ERROR ;
	} else {
		VSyylval.tk.type = VS_IDENT ;
	}
	return VSyylval.tk.type ;
}
break;
case 3:
{

	int trunc ;

	/*
	 * It's a test-complex function.
	 */
	VSstrncpy( VSyylval.tk._sval, VSyytext, VS_K_tokMAX_SIZE, &trunc ) ;

	if( trunc ) {
		VSyylval.tk.type = VS_IDT_TOO_LONG ;
		return VS_ERROR ;
	} else {
		char RE[VS_K_tokMAX_SIZE] ;

		VSslcExtractCpxName( VSyylval.tk._sval, RE ) ;

		if( VSmatchRE( RE, NULL ) ) {
			VSyylval.tk.type = VS_FUNCTION ;
		} else {
			VSyylval.tk.type = VS_BAD_REGEXP ;
			return VS_ERROR ;
		}
	}
	return VSyylval.tk.type ;
}
break;
case 4:
	{
	int trunc ;

	VSstrncpy( VSyylval.tk._sval, VSyytext, VS_K_tokMAX_SIZE, &trunc ) ;

	if( trunc ) {
			VSyylval.tk.type = VS_IDT_TOO_LONG ;
			return VS_ERROR ;
	} else {
			return VSyylval.tk.type = VS_PATH ;
	}
}
break;
case 5:
	{
	VSyylval.tk._ival = atol( VSyytext ) ;
	VSyylval.tk.type = VS_int ;
	return  VS_INT ;
}
break;
case 6:
case 7:
case 8:
		{
	VSyylval.tk._dval = atof( VSyytext ) ;
	VSyylval.tk.type = VS_double ;
	return VS_DOUBLE ;
}
break;
case 9:
	{ return VS_EQASGN	; }
break;
case 10:
	{ return VS_LPAR	; }
break;
case 11:
	{ return VS_RPAR	; }
break;
case 12:
	{ return VS_LT		; }
break;
case 13:
	{ return VS_GT		; }
break;
case 14:
	{ return VS_LE		; }
break;
case 15:
	{ return VS_GE		; }
break;
case 16:
	{ return VS_NE		; }
break;
case 17:
	{ return VS_NOT		; }
break;
case 18:
	{ return VS_AND		; }
break;
case 19:
	{ return VS_OR		; }
break;
case 20:
	{ return VS_POW		; }
break;
case 21:
	{ return VS_PLUS	; }
break;
case 22:
	{ return VS_MINUS	; }
break;
case 23:
	{ return VS_MULT	; }
break;
case 24:
	{ return VS_DIV		; }
break;
case 25:
	{ return VS_COMMA	; }
break;
case 26:
	;
break;
case 27:
	{
	if( VSyytext[VSyyleng-1] == '\\' ) {
		VSyymore() ;
	} else {
		int trunc ;
		input() ;

		VSstrncpy(	VSyylval.tk._sval,
				VSyytext + 1,
				VS_K_tokMAX_SIZE,
				&trunc ) ;
		if( trunc ) {
			VSyylval.tk.type = VS_STR_TOO_LONG ;
			return VS_ERROR ;
		} else {
			VSyylval.tk.type = VS_string ;
			return VS_STRING ;
		}
	}
}
break;
case 28:
;
break;
case 29:
{
		strcpy( VSyylval.tk._sval, VSyytext ) ;
		VSyylval.tk.type = VS_BAD_CHAR ;
	  	return VS_ERROR ;
}
break;
case -1:
break;
default:
fprintf(VSyyout,"bad switch VSyylook %d",nstr);
} return(0); }
/* end of VSyylex */
/*----------------------------------------------------------------------------*/
int VSyyvstop[] = {
0,

29,
0,

28,
29,
0,

28,
0,

17,
29,
0,

27,
29,
0,

29,
-26,
0,

29,
0,

18,
29,
0,

10,
29,
0,

11,
29,
0,

23,
29,
0,

21,
29,
0,

25,
29,
0,

22,
29,
0,

29,
0,

24,
29,
0,

5,
29,
0,

12,
29,
0,

9,
29,
0,

13,
29,
0,

29,
0,

2,
4,
29,
0,

19,
29,
0,

16,
0,

27,
0,

-26,
0,

26,
0,

3,
0,

20,
0,

7,
0,

6,
0,

5,
0,

14,
0,

15,
0,

1,
0,

2,
4,
0,

4,
0,

6,
7,
0,

8,
0,

7,
0,

6,
0,

6,
7,
0,
0};
# define VSyyTYPE char
struct VSyywork { VSyyTYPE verify, advance; } VSyycrank[] = {
0,0,	0,0,	1,3,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	1,4,	1,5,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	1,6,	1,7,	
1,8,	27,0,	1,9,	1,10,	
0,0,	1,11,	1,12,	1,13,	
1,14,	1,15,	1,16,	1,17,	
1,18,	1,19,	13,32,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	1,3,	
0,0,	1,20,	1,21,	1,22,	
1,3,	1,23,	1,24,	6,26,	
20,37,	2,6,	1,24,	2,8,	
22,38,	2,9,	2,10,	0,0,	
2,11,	2,12,	33,42,	7,27,	
2,15,	43,49,	2,17,	2,18,	
0,0,	0,0,	0,0,	7,27,	
7,27,	0,0,	0,0,	0,0,	
1,3,	0,0,	1,3,	0,0,	
2,20,	2,21,	2,22,	2,3,	
2,23,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	8,28,	
0,0,	0,0,	33,42,	0,0,	
7,0,	43,49,	0,0,	8,28,	
8,29,	0,0,	0,0,	0,0,	
7,27,	7,27,	0,0,	7,27,	
0,0,	1,25,	7,27,	2,3,	
0,0,	2,3,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
7,27,	0,0,	0,0,	0,0,	
8,28,	0,0,	0,0,	7,27,	
0,0,	0,0,	0,0,	7,27,	
8,28,	8,28,	0,0,	8,28,	
0,0,	0,0,	8,28,	0,0,	
0,0,	0,0,	0,0,	0,0,	
2,25,	0,0,	0,0,	0,0,	
8,28,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	8,28,	
0,0,	0,0,	0,0,	8,28,	
9,0,	9,0,	9,0,	9,0,	
9,0,	9,0,	9,0,	9,0,	
9,0,	9,0,	9,0,	9,0,	
9,0,	9,0,	9,0,	9,0,	
9,0,	9,0,	9,0,	9,0,	
9,0,	9,0,	9,0,	9,0,	
9,0,	9,0,	9,0,	9,0,	
9,0,	9,0,	9,0,	9,0,	
9,0,	9,0,	9,0,	9,0,	
9,30,	9,0,	9,0,	9,0,	
9,0,	9,31,	9,0,	9,0,	
9,31,	0,0,	9,0,	9,31,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	9,0,	9,0,	9,0,	
9,0,	9,0,	0,0,	9,0,	
9,31,	0,0,	0,0,	0,0,	
9,31,	17,33,	17,33,	17,33,	
17,33,	17,33,	17,33,	17,33,	
17,33,	17,33,	17,33,	19,34,	
0,0,	19,35,	19,35,	19,35,	
19,35,	19,35,	19,35,	19,35,	
19,35,	19,35,	19,35,	9,0,	
0,0,	9,0,	0,0,	9,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	19,36,	0,0,	
0,0,	0,0,	0,0,	0,0,	
34,43,	34,43,	34,43,	34,43,	
34,43,	34,43,	34,43,	34,43,	
34,43,	34,43,	0,0,	0,0,	
0,0,	0,0,	9,0,	9,0,	
9,0,	9,0,	9,0,	0,0,	
0,0,	34,44,	0,0,	0,0,	
0,0,	0,0,	19,36,	23,39,	
23,39,	23,39,	23,39,	23,39,	
23,39,	23,39,	23,39,	23,39,	
23,39,	23,39,	23,39,	23,39,	
23,39,	23,39,	23,39,	23,39,	
23,39,	23,39,	23,39,	23,39,	
23,39,	23,39,	23,39,	23,39,	
23,39,	34,44,	0,0,	0,0,	
0,0,	23,39,	0,0,	23,39,	
23,39,	23,39,	23,39,	23,39,	
23,39,	23,39,	23,39,	23,39,	
23,39,	23,39,	23,39,	23,39,	
23,39,	23,39,	23,39,	23,39,	
23,39,	23,39,	23,39,	23,39,	
23,39,	23,39,	23,39,	23,39,	
23,39,	24,40,	24,40,	24,40,	
24,40,	24,40,	24,40,	24,40,	
24,40,	24,40,	24,40,	24,41,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	24,40,	24,40,	
24,40,	24,40,	24,40,	24,40,	
24,40,	24,40,	24,40,	24,40,	
24,40,	24,40,	24,40,	24,40,	
24,40,	24,40,	24,40,	24,40,	
24,40,	24,40,	24,40,	24,40,	
24,40,	24,40,	24,40,	24,40,	
0,0,	0,0,	0,0,	0,0,	
24,40,	0,0,	24,40,	24,40,	
24,40,	24,40,	24,40,	24,40,	
24,40,	24,40,	24,40,	24,40,	
24,40,	24,40,	24,40,	24,40,	
24,40,	24,40,	24,40,	24,40,	
24,40,	24,40,	24,40,	24,40,	
24,40,	24,40,	24,40,	24,40,	
31,0,	31,0,	31,0,	31,0,	
31,0,	31,0,	31,0,	31,0,	
31,0,	31,0,	31,0,	31,0,	
31,0,	31,0,	31,0,	31,0,	
31,0,	31,0,	31,0,	31,0,	
31,0,	31,0,	31,0,	31,0,	
31,0,	31,0,	31,0,	31,0,	
31,0,	31,0,	31,0,	31,0,	
31,0,	31,0,	31,0,	31,0,	
31,30,	31,0,	31,0,	31,0,	
31,0,	0,0,	31,0,	31,0,	
0,0,	0,0,	31,0,	39,39,	
39,39,	39,39,	39,39,	39,39,	
39,39,	39,39,	39,39,	39,39,	
39,39,	31,0,	31,0,	31,0,	
31,0,	31,0,	36,45,	31,0,	
36,45,	0,0,	0,0,	36,46,	
36,46,	36,46,	36,46,	36,46,	
36,46,	36,46,	36,46,	36,46,	
36,46,	45,46,	45,46,	45,46,	
45,46,	45,46,	45,46,	45,46,	
45,46,	45,46,	45,46,	0,0,	
0,0,	0,0,	0,0,	31,0,	
42,47,	31,0,	42,47,	31,0,	
0,0,	42,48,	42,48,	42,48,	
42,48,	42,48,	42,48,	42,48,	
42,48,	42,48,	42,48,	0,0,	
0,0,	0,0,	41,41,	41,41,	
41,41,	41,41,	41,41,	41,41,	
41,41,	41,41,	41,41,	41,41,	
0,0,	0,0,	31,0,	31,0,	
31,0,	31,0,	31,0,	41,41,	
41,41,	41,41,	41,41,	41,41,	
41,41,	41,41,	41,41,	41,41,	
41,41,	41,41,	41,41,	41,41,	
41,41,	41,41,	41,41,	41,41,	
41,41,	41,41,	41,41,	41,41,	
41,41,	41,41,	41,41,	41,41,	
41,41,	0,0,	0,0,	0,0,	
0,0,	41,41,	0,0,	41,41,	
41,41,	41,41,	41,41,	41,41,	
41,41,	41,41,	41,41,	41,41,	
41,41,	41,41,	41,41,	41,41,	
41,41,	41,41,	41,41,	41,41,	
41,41,	41,41,	41,41,	41,41,	
41,41,	41,41,	41,41,	41,41,	
41,41,	44,50,	0,0,	44,50,	
0,0,	0,0,	44,51,	44,51,	
44,51,	44,51,	44,51,	44,51,	
44,51,	44,51,	44,51,	44,51,	
47,48,	47,48,	47,48,	47,48,	
47,48,	47,48,	47,48,	47,48,	
47,48,	47,48,	49,52,	0,0,	
49,52,	0,0,	0,0,	49,53,	
49,53,	49,53,	49,53,	49,53,	
49,53,	49,53,	49,53,	49,53,	
49,53,	50,51,	50,51,	50,51,	
50,51,	50,51,	50,51,	50,51,	
50,51,	50,51,	50,51,	52,53,	
52,53,	52,53,	52,53,	52,53,	
52,53,	52,53,	52,53,	52,53,	
52,53,	0,0,	0,0,	0,0,	
0,0};
struct VSyysvf VSyysvec[] = {
0,	0,	0,
VSyycrank+-1,	0,		0,	
VSyycrank+-36,	VSyysvec+1,	0,	
VSyycrank+0,	0,		VSyyvstop+1,
VSyycrank+0,	0,		VSyyvstop+3,
VSyycrank+0,	0,		VSyyvstop+6,
VSyycrank+6,	0,		VSyyvstop+8,
VSyycrank+-78,	0,		VSyyvstop+11,
VSyycrank+-106,	0,		VSyyvstop+14,
VSyycrank+-175,	0,		VSyyvstop+17,
VSyycrank+0,	0,		VSyyvstop+19,
VSyycrank+0,	0,		VSyyvstop+22,
VSyycrank+0,	0,		VSyyvstop+25,
VSyycrank+8,	0,		VSyyvstop+28,
VSyycrank+0,	0,		VSyyvstop+31,
VSyycrank+0,	0,		VSyyvstop+34,
VSyycrank+0,	0,		VSyyvstop+37,
VSyycrank+197,	0,		VSyyvstop+40,
VSyycrank+0,	0,		VSyyvstop+42,
VSyycrank+209,	0,		VSyyvstop+45,
VSyycrank+7,	0,		VSyyvstop+48,
VSyycrank+0,	0,		VSyyvstop+51,
VSyycrank+11,	0,		VSyyvstop+54,
VSyycrank+246,	0,		VSyyvstop+57,
VSyycrank+321,	0,		VSyyvstop+59,
VSyycrank+0,	0,		VSyyvstop+63,
VSyycrank+0,	0,		VSyyvstop+66,
VSyycrank+-3,	VSyysvec+7,	VSyyvstop+68,
VSyycrank+0,	VSyysvec+8,	VSyyvstop+70,
VSyycrank+0,	0,		VSyyvstop+72,
VSyycrank+0,	0,		VSyyvstop+74,
VSyycrank+-443,	VSyysvec+9,	0,	
VSyycrank+0,	0,		VSyyvstop+76,
VSyycrank+9,	VSyysvec+17,	VSyyvstop+78,
VSyycrank+236,	0,		VSyyvstop+80,
VSyycrank+0,	VSyysvec+19,	VSyyvstop+82,
VSyycrank+463,	0,		0,	
VSyycrank+0,	0,		VSyyvstop+84,
VSyycrank+0,	0,		VSyyvstop+86,
VSyycrank+443,	VSyysvec+23,	VSyyvstop+88,
VSyycrank+0,	VSyysvec+24,	VSyyvstop+90,
VSyycrank+506,	VSyysvec+24,	VSyyvstop+93,
VSyycrank+493,	0,		0,	
VSyycrank+12,	VSyysvec+34,	VSyyvstop+95,
VSyycrank+586,	0,		0,	
VSyycrank+473,	0,		0,	
VSyycrank+0,	VSyysvec+45,	VSyyvstop+98,
VSyycrank+596,	0,		0,	
VSyycrank+0,	VSyysvec+47,	VSyyvstop+100,
VSyycrank+611,	0,		0,	
VSyycrank+621,	0,		0,	
VSyycrank+0,	VSyysvec+50,	VSyyvstop+102,
VSyycrank+631,	0,		0,	
VSyycrank+0,	VSyysvec+52,	VSyyvstop+104,
0,	0,	0};
struct VSyywork *VSyytop = VSyycrank+688;
struct VSyysvf *VSyybgin = VSyysvec+1;
char VSyymatch[] = {
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
char VSyyextra[] = {
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,1,0,0,0,0,0,
0};
#ident	"@(#)libl:lib/ncform	1.3	1.2 (Intergraph) 3/10/88"
int VSyylineno =1;
# define VSyyU(x) x
# define NLSTATE VSyyprevious=VSyyNEWLINE
char VSyytext[VSyyLMAX];
struct VSyysvf *VSyylstate [VSyyLMAX], **VSyylsp, **VSyyolsp;
char VSyysbuf[VSyyLMAX];
char *VSyysptr = VSyysbuf;
int *VSyyfnd;
extern struct VSyysvf *VSyyestate;
int VSyyprevious = VSyyNEWLINE;
VSyylook(){
	register struct VSyysvf *VSyystate, **lsp;
	register struct VSyywork *VSyyt;
	struct VSyysvf *VSyyz;
	int VSyych, VSyyfirst;
	struct VSyywork *VSyyr;
# ifdef LEXDEBUG
	int debug;
# endif
	char *VSyylastch;
	/* start off machines */
# ifdef LEXDEBUG
	debug = 0;
# endif
	VSyyfirst=1;
	if (!VSyymorfg)
		VSyylastch = VSyytext;
	else {
		VSyymorfg=0;
		VSyylastch = VSyytext+VSyyleng;
		}
	for(;;){
		lsp = VSyylstate;
		VSyyestate = VSyystate = VSyybgin;
		if (VSyyprevious==VSyyNEWLINE) VSyystate++;
		for (;;){
# ifdef LEXDEBUG
			if(debug)fprintf(VSyyout,"state %d\n",VSyystate-VSyysvec-1);
# endif
			VSyyt = VSyystate->VSyystoff;
			if(VSyyt == VSyycrank && !VSyyfirst){  /* may not be any transitions */
				VSyyz = VSyystate->VSyyother;
				if(VSyyz == 0)break;
				if(VSyyz->VSyystoff == VSyycrank)break;
				}
			*VSyylastch++ = VSyych = input();
			VSyyfirst=0;
		tryagain:
# ifdef LEXDEBUG
			if(debug){
				fprintf(VSyyout,"char ");
				allprint(VSyych);
				putchar('\n');
				}
# endif
			VSyyr = VSyyt;
			if ( (int)VSyyt > (int)VSyycrank){
				VSyyt = VSyyr + VSyych;
				if (VSyyt <= VSyytop && VSyyt->verify+VSyysvec == VSyystate){
					if(VSyyt->advance+VSyysvec == VSyyLERR)	/* error transitions */
						{unput(*--VSyylastch);break;}
					*lsp++ = VSyystate = VSyyt->advance+VSyysvec;
					goto contin;
					}
				}
# ifdef VSyyOPTIM
			else if((int)VSyyt < (int)VSyycrank) {		/* r < VSyycrank */
				VSyyt = VSyyr = VSyycrank+(VSyycrank-VSyyt);
# ifdef LEXDEBUG
				if(debug)fprintf(VSyyout,"compressed state\n");
# endif
				VSyyt = VSyyt + VSyych;
				if(VSyyt <= VSyytop && VSyyt->verify+VSyysvec == VSyystate){
					if(VSyyt->advance+VSyysvec == VSyyLERR)	/* error transitions */
						{unput(*--VSyylastch);break;}
					*lsp++ = VSyystate = VSyyt->advance+VSyysvec;
					goto contin;
					}
				VSyyt = VSyyr + VSyyU(VSyymatch[VSyych]);
# ifdef LEXDEBUG
				if(debug){
					fprintf(VSyyout,"try fall back character ");
					allprint(VSyyU(VSyymatch[VSyych]));
					putchar('\n');
					}
# endif
				if(VSyyt <= VSyytop && VSyyt->verify+VSyysvec == VSyystate){
					if(VSyyt->advance+VSyysvec == VSyyLERR)	/* error transition */
						{unput(*--VSyylastch);break;}
					*lsp++ = VSyystate = VSyyt->advance+VSyysvec;
					goto contin;
					}
				}
			if ((VSyystate = VSyystate->VSyyother) && (VSyyt= VSyystate->VSyystoff) != VSyycrank){
# ifdef LEXDEBUG
				if(debug)fprintf(VSyyout,"fall back to state %d\n",VSyystate-VSyysvec-1);
# endif
				goto tryagain;
				}
# endif
			else
				{unput(*--VSyylastch);break;}
		contin:
# ifdef LEXDEBUG
			if(debug){
				fprintf(VSyyout,"state %d char ",VSyystate-VSyysvec-1);
				allprint(VSyych);
				putchar('\n');
				}
# endif
			;
			}
# ifdef LEXDEBUG
		if(debug){
			fprintf(VSyyout,"stopped at %d with ",*(lsp-1)-VSyysvec-1);
			allprint(VSyych);
			putchar('\n');
			}
# endif
		while (lsp-- > VSyylstate){
			*VSyylastch-- = 0;
			if (*lsp != 0 && (VSyyfnd= (*lsp)->VSyystops) && *VSyyfnd > 0){
				VSyyolsp = lsp;
				if(VSyyextra[*VSyyfnd]){		/* must backup */
					while(VSyyback((*lsp)->VSyystops,-*VSyyfnd) != 1 && lsp > VSyylstate){
						lsp--;
						unput(*VSyylastch--);
						}
					}
				VSyyprevious = VSyyU(*VSyylastch);
				VSyylsp = lsp;
				VSyyleng = VSyylastch-VSyytext+1;
				VSyytext[VSyyleng] = 0;
# ifdef LEXDEBUG
				if(debug){
					fprintf(VSyyout,"\nmatch ");
					sprint(VSyytext);
					fprintf(VSyyout," action %d\n",*VSyyfnd);
					}
# endif
				return(*VSyyfnd++);
				}
			unput(*VSyylastch);
			}
		/* you may or may not be reading from VSyyin - we really   */
		/* can't tell at this point. So whenver VSyytext[0] is set */
		/* to 0, this indicates end of file			 */
		if (VSyytext[0] == 0 /* && feof(VSyyin) */ )
			{
			VSyysptr=VSyysbuf;
			return(0);
			}
		VSyyprevious = VSyytext[0] = input();
		if (VSyyprevious>0)
			output(VSyyprevious);
		VSyylastch=VSyytext;
# ifdef LEXDEBUG
		if(debug)putchar('\n');
# endif
		}
	}
VSyyback(p, m)
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
VSyyinput(){
	return(input());
	}
VSyyoutput(c)
  int c; {
	output(c);
	}
VSyyunput(c)
   int c; {
	unput(c);
	}
