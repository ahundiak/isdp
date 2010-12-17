#include "conditiony.h"
# include "stdio.h"
# define U(x) x
# define NLSTATE CID_yyprevious=YYNEWLINE
# define BEGIN CID_yybgin = CID_yysvec + 1 +
# define INITIAL 0
# define YYLERR CID_yysvec
# define YYSTATE (CID_yyestate-CID_yysvec-1)
# define YYOPTIM 1
# define YYLMAX 200
# define output(c) putc(c,CID_yyout)
# define input() (((CID_yytchar=CID_yysptr>CID_yysbuf?U(*--CID_yysptr):getc(CID_yyin))==10?(CID_yylineno++,CID_yytchar):CID_yytchar)==EOF?0:CID_yytchar)
# define unput(c) {CID_yytchar= (c);if(CID_yytchar=='\n')CID_yylineno--;*CID_yysptr++=CID_yytchar;}
# define CID_yymore() (CID_yymorfg=1)

/************ inhibit echo ****************************************************/
#ifdef MYDEBUG
#define ECHO fprintf(CID_yyout, "%s",CID_yytext)
#endif

#ifndef MYDEBUG
#define	ECHO
#endif
/******************************************************************************/


# define REJECT { nstr = CID_yyreject(); goto CID_yyfussy;}
int CID_yyleng; extern char CID_yytext[];
int CID_yymorfg;
extern char *CID_yysptr, CID_yysbuf[];
int CID_yytchar;

/************ change 'CID_yyin' so that input is taken from a *********************/
/************ file rather than the 'stdin'	          *********************/

/*FILE *CID_yyin = {stdin}, *CID_yyout = {stdout};*/

FILE *CID_yyout = {stdout};
extern FILE *CID_yyin;

/*****************************************************************************/


extern int CID_yylineno;
struct CID_yysvf { 
	struct CID_yywork *CID_yystoff;
	struct CID_yysvf *CID_yyother;
	int *CID_yystops;};
struct CID_yysvf *CID_yyestate;
extern struct CID_yysvf CID_yysvec[], *CID_yybgin;
# define separ 2
# define YYNEWLINE 10
CID_yylex(){
int nstr; extern int CID_yyprevious;
while((nstr = CID_yylook()) >= 0)
CID_yyfussy: switch(nstr){
case 0:
if(CID_yywrap()) return(0); break;
case 1:
	{
				ECHO;
				return (_c_column_name);
			}
break;
case 2:
		{
				ECHO;
				return (_c_outside_and);
			}
break;
case 3:
		{
				ECHO;
				return (_c_outside_or);
			}
break;
case 4:
			{
				ECHO;
				return (_c_greater_equal);
			}
break;
case 5:
			{
				ECHO;
				return (_c_greater);
			}
break;
case 6:
			{
				ECHO;
				return (_c_less_equal);
			}
break;
case 7:
			{
				ECHO;
				return (_c_less);
			}
break;
case 8:
			{
				ECHO;
				return (_c_equal);
			}
break;
case 9:
			{
				ECHO;
				return (_c_not_equal);
			}
break;
case 10:
		{
				ECHO;
				return (_c_not);
			}
break;
case 11:
			{
				ECHO;
				return (_c_int_value);
			}
break;
case 12:
{
				ECHO;
				return (_c_real_value);
			}
break;
case 13:
			{
				ECHO;
				return (_c_multiply);
			}
break;
case 14:
			{
				ECHO;
				return (_c_divide);
			}
break;
case 15:
			{
				ECHO;
				return (_c_add);
			}
break;
case 16:
			{
				ECHO;
				return (_c_subtract);
			}
break;
case 17:
			{
				ECHO;
				BEGIN separ;
				return (_c_open);
			}
break;
case 18:
			{
				ECHO;
				BEGIN 0;
				return (_c_close);
			}
break;
case 19:
		{
				ECHO;
				return (_c_string);
			}
break;
case -1:
break;
default:
fprintf(CID_yyout,"bad switch CID_yylook %d",nstr);
} return(0); }
/* end of CID_yylex */

CID_yywrap ()
{
	return (1);
}
int CID_yyvstop[] = {
0,

17,
0,

18,
0,

13,
0,

15,
0,

16,
0,

14,
0,

11,
0,

1,
0,

1,
0,

1,
0,

19,
0,

12,
0,

1,
10,
0,

8,
0,

4,
0,

5,
0,

6,
0,

7,
0,

9,
0,

3,
0,

2,
0,
0};
# define YYTYPE char
struct CID_yywork { YYTYPE verify, advance; } CID_yycrank[] = {
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
1,5,	1,6,	1,7,	1,8,	
1,9,	0,0,	1,10,	1,11,	
1,12,	1,13,	1,13,	1,13,	
1,13,	1,13,	1,13,	1,13,	
1,13,	1,13,	1,13,	16,25,	
27,37,	28,38,	29,39,	30,40,	
31,41,	32,42,	1,14,	1,14,	
1,14,	1,14,	1,14,	1,14,	
1,14,	1,14,	1,14,	1,14,	
1,14,	1,14,	1,14,	1,15,	
1,14,	1,14,	1,14,	1,14,	
1,14,	1,14,	1,14,	1,14,	
1,14,	1,14,	1,14,	1,14,	
15,24,	17,26,	18,27,	21,32,	
22,33,	24,35,	1,14,	1,14,	
1,14,	1,14,	1,14,	1,14,	
1,14,	1,14,	1,14,	1,14,	
1,14,	1,14,	1,14,	1,14,	
1,14,	1,14,	1,14,	1,14,	
1,14,	1,14,	1,14,	1,14,	
1,14,	1,14,	1,14,	1,14,	
5,16,	5,16,	5,16,	5,16,	
5,16,	5,16,	5,16,	5,16,	
5,16,	5,16,	26,36,	33,43,	
36,44,	0,0,	0,0,	0,0,	
0,0,	5,16,	5,16,	5,16,	
5,16,	5,16,	5,16,	5,16,	
5,16,	5,16,	5,16,	5,16,	
5,16,	5,16,	5,16,	5,16,	
5,16,	5,16,	5,16,	5,16,	
5,16,	5,16,	5,16,	5,16,	
5,16,	5,16,	5,16,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	5,16,	5,16,	5,16,	
5,16,	5,16,	5,16,	5,16,	
5,16,	5,16,	5,16,	5,16,	
5,16,	5,16,	5,16,	5,16,	
5,16,	5,16,	5,16,	5,16,	
5,16,	5,16,	5,16,	5,16,	
5,16,	5,16,	5,16,	11,17,	
19,28,	0,0,	0,0,	11,18,	
0,0,	11,19,	0,0,	0,0,	
0,0,	0,0,	11,20,	0,0,	
11,21,	11,22,	13,23,	19,29,	
13,13,	13,13,	13,13,	13,13,	
13,13,	13,13,	13,13,	13,13,	
13,13,	13,13,	14,14,	14,14,	
14,14,	14,14,	14,14,	14,14,	
14,14,	14,14,	14,14,	14,14,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	14,14,	
14,14,	14,14,	14,14,	14,14,	
14,14,	14,14,	14,14,	14,14,	
14,14,	14,14,	14,14,	14,14,	
14,14,	14,14,	14,14,	14,14,	
14,14,	14,14,	14,14,	14,14,	
14,14,	14,14,	14,14,	14,14,	
14,14,	0,0,	0,0,	0,0,	
0,0,	14,14,	0,0,	14,14,	
14,14,	14,14,	14,14,	14,14,	
14,14,	14,14,	14,14,	14,14,	
14,14,	14,14,	14,14,	14,14,	
14,14,	14,14,	14,14,	14,14,	
14,14,	14,14,	14,14,	14,14,	
14,14,	14,14,	14,14,	14,14,	
14,14,	20,30,	23,34,	23,34,	
23,34,	23,34,	23,34,	23,34,	
23,34,	23,34,	23,34,	23,34,	
0,0,	0,0,	0,0,	0,0,	
20,31,	0,0,	0,0,	0,0,	
0,0};
struct CID_yysvf CID_yysvec[] = {
0,	0,	0,
CID_yycrank+1,	0,		0,	
CID_yycrank+0,	CID_yysvec+1,	0,	
CID_yycrank+0,	CID_yysvec+1,	0,	
CID_yycrank+0,	CID_yysvec+1,	0,	
CID_yycrank+76,	0,		0,	
CID_yycrank+0,	0,		CID_yyvstop+1,
CID_yycrank+0,	0,		CID_yyvstop+3,
CID_yycrank+0,	0,		CID_yyvstop+5,
CID_yycrank+0,	0,		CID_yyvstop+7,
CID_yycrank+0,	0,		CID_yyvstop+9,
CID_yycrank+134,	0,		0,	
CID_yycrank+0,	0,		CID_yyvstop+11,
CID_yycrank+168,	0,		CID_yyvstop+13,
CID_yycrank+178,	0,		CID_yyvstop+15,
CID_yycrank+13,	CID_yysvec+14,	CID_yyvstop+17,
CID_yycrank+20,	CID_yysvec+5,	0,	
CID_yycrank+15,	0,		0,	
CID_yycrank+13,	0,		0,	
CID_yycrank+131,	0,		0,	
CID_yycrank+232,	0,		0,	
CID_yycrank+26,	0,		0,	
CID_yycrank+14,	0,		0,	
CID_yycrank+254,	0,		0,	
CID_yycrank+13,	CID_yysvec+14,	CID_yyvstop+19,
CID_yycrank+0,	0,		CID_yyvstop+21,
CID_yycrank+66,	0,		0,	
CID_yycrank+14,	0,		0,	
CID_yycrank+15,	0,		0,	
CID_yycrank+16,	0,		0,	
CID_yycrank+17,	0,		0,	
CID_yycrank+18,	0,		0,	
CID_yycrank+19,	0,		0,	
CID_yycrank+89,	0,		0,	
CID_yycrank+0,	CID_yysvec+23,	CID_yyvstop+23,
CID_yycrank+0,	CID_yysvec+14,	CID_yyvstop+25,
CID_yycrank+90,	0,		0,	
CID_yycrank+0,	0,		CID_yyvstop+28,
CID_yycrank+0,	0,		CID_yyvstop+30,
CID_yycrank+0,	0,		CID_yyvstop+32,
CID_yycrank+0,	0,		CID_yyvstop+34,
CID_yycrank+0,	0,		CID_yyvstop+36,
CID_yycrank+0,	0,		CID_yyvstop+38,
CID_yycrank+0,	0,		CID_yyvstop+40,
CID_yycrank+0,	0,		CID_yyvstop+42,
0,	0,	0};
struct CID_yywork *CID_yytop = CID_yycrank+316;
struct CID_yysvf *CID_yybgin = CID_yysvec+1;
char CID_yymatch[] = {
00  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,'.' ,01  ,
'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,
'0' ,'0' ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,'A' ,'B' ,'B' ,'D' ,'E' ,'B' ,'G' ,
'B' ,'B' ,'B' ,'B' ,'L' ,'B' ,'N' ,'O' ,
'B' ,'Q' ,'R' ,'B' ,'T' ,'B' ,'B' ,'B' ,
'B' ,'B' ,'B' ,01  ,01  ,01  ,01  ,'_' ,
01  ,'B' ,'B' ,'B' ,'B' ,'B' ,'B' ,'B' ,
'B' ,'B' ,'B' ,'B' ,'B' ,'B' ,'B' ,'B' ,
'B' ,'B' ,'B' ,'B' ,'B' ,'B' ,'B' ,'B' ,
'B' ,'B' ,'B' ,01  ,01  ,01  ,01  ,01  ,
0};
char CID_yyextra[] = {
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0};
#ident	"@(#)libl:lib/ncform	1.3	1.2 (Intergraph) 3/10/88"
int CID_yylineno =1;
# define YYU(x) x
# define NLSTATE CID_yyprevious=YYNEWLINE
char CID_yytext[YYLMAX];
struct CID_yysvf *CID_yylstate [YYLMAX], **CID_yylsp, **CID_yyolsp;
char CID_yysbuf[YYLMAX];
char *CID_yysptr = CID_yysbuf;
int *CID_yyfnd;
extern struct CID_yysvf *CID_yyestate;
int CID_yyprevious = YYNEWLINE;
CID_yylook(){
	register struct CID_yysvf *CID_yystate, **lsp;
	register struct CID_yywork *CID_yyt;
	struct CID_yysvf *CID_yyz;
	int CID_yych, CID_yyfirst;
	struct CID_yywork *CID_yyr;
# ifdef LEXDEBUG
	int debug;
# endif
	char *CID_yylastch;
	/* start off machines */
# ifdef LEXDEBUG
	debug = 0;
# endif
	CID_yyfirst=1;
	if (!CID_yymorfg)
		CID_yylastch = CID_yytext;
	else {
		CID_yymorfg=0;
		CID_yylastch = CID_yytext+CID_yyleng;
		}
	for(;;){
		lsp = CID_yylstate;
		CID_yyestate = CID_yystate = CID_yybgin;
		if (CID_yyprevious==YYNEWLINE) CID_yystate++;
		for (;;){
# ifdef LEXDEBUG
			if(debug)fprintf(CID_yyout,"state %d\n",CID_yystate-CID_yysvec-1);
# endif
			CID_yyt = CID_yystate->CID_yystoff;
			if(CID_yyt == CID_yycrank && !CID_yyfirst){  /* may not be any transitions */
				CID_yyz = CID_yystate->CID_yyother;
				if(CID_yyz == 0)break;
				if(CID_yyz->CID_yystoff == CID_yycrank)break;
				}
			*CID_yylastch++ = CID_yych = input();
			CID_yyfirst=0;
		tryagain:
# ifdef LEXDEBUG
			if(debug){
				fprintf(CID_yyout,"char ");
				allprint(CID_yych);
				putchar('\n');
				}
# endif
			CID_yyr = CID_yyt;
			if ( (int)CID_yyt > (int)CID_yycrank){
				CID_yyt = CID_yyr + CID_yych;
				if (CID_yyt <= CID_yytop && CID_yyt->verify+CID_yysvec == CID_yystate){
					if(CID_yyt->advance+CID_yysvec == YYLERR)	/* error transitions */
						{unput(*--CID_yylastch);break;}
					*lsp++ = CID_yystate = CID_yyt->advance+CID_yysvec;
					goto contin;
					}
				}
# ifdef YYOPTIM
			else if((int)CID_yyt < (int)CID_yycrank) {		/* r < CID_yycrank */
				CID_yyt = CID_yyr = CID_yycrank+(CID_yycrank-CID_yyt);
# ifdef LEXDEBUG
				if(debug)fprintf(CID_yyout,"compressed state\n");
# endif
				CID_yyt = CID_yyt + CID_yych;
				if(CID_yyt <= CID_yytop && CID_yyt->verify+CID_yysvec == CID_yystate){
					if(CID_yyt->advance+CID_yysvec == YYLERR)	/* error transitions */
						{unput(*--CID_yylastch);break;}
					*lsp++ = CID_yystate = CID_yyt->advance+CID_yysvec;
					goto contin;
					}
				CID_yyt = CID_yyr + YYU(CID_yymatch[CID_yych]);
# ifdef LEXDEBUG
				if(debug){
					fprintf(CID_yyout,"try fall back character ");
					allprint(YYU(CID_yymatch[CID_yych]));
					putchar('\n');
					}
# endif
				if(CID_yyt <= CID_yytop && CID_yyt->verify+CID_yysvec == CID_yystate){
					if(CID_yyt->advance+CID_yysvec == YYLERR)	/* error transition */
						{unput(*--CID_yylastch);break;}
					*lsp++ = CID_yystate = CID_yyt->advance+CID_yysvec;
					goto contin;
					}
				}
			if ((CID_yystate = CID_yystate->CID_yyother) && (CID_yyt= CID_yystate->CID_yystoff) != CID_yycrank){
# ifdef LEXDEBUG
				if(debug)fprintf(CID_yyout,"fall back to state %d\n",CID_yystate-CID_yysvec-1);
# endif
				goto tryagain;
				}
# endif
			else
				{unput(*--CID_yylastch);break;}
		contin:
# ifdef LEXDEBUG
			if(debug){
				fprintf(CID_yyout,"state %d char ",CID_yystate-CID_yysvec-1);
				allprint(CID_yych);
				putchar('\n');
				}
# endif
			;
			}
# ifdef LEXDEBUG
		if(debug){
			fprintf(CID_yyout,"stopped at %d with ",*(lsp-1)-CID_yysvec-1);
			allprint(CID_yych);
			putchar('\n');
			}
# endif
		while (lsp-- > CID_yylstate){
			*CID_yylastch-- = 0;
			if (*lsp != 0 && (CID_yyfnd= (*lsp)->CID_yystops) && *CID_yyfnd > 0){
				CID_yyolsp = lsp;
				if(CID_yyextra[*CID_yyfnd]){		/* must backup */
					while(CID_yyback((*lsp)->CID_yystops,-*CID_yyfnd) != 1 && lsp > CID_yylstate){
						lsp--;
						unput(*CID_yylastch--);
						}
					}
				CID_yyprevious = YYU(*CID_yylastch);
				CID_yylsp = lsp;
				CID_yyleng = CID_yylastch-CID_yytext+1;
				CID_yytext[CID_yyleng] = 0;
# ifdef LEXDEBUG
				if(debug){
					fprintf(CID_yyout,"\nmatch ");
					sprint(CID_yytext);
					fprintf(CID_yyout," action %d\n",*CID_yyfnd);
					}
# endif
				return(*CID_yyfnd++);
				}
			unput(*CID_yylastch);
			}
		/* you may or may not be reading from CID_yyin - we really   */
		/* can't tell at this point. So whenver CID_yytext[0] is set */
		/* to 0, this indicates end of file			 */
		if (CID_yytext[0] == 0 /* && feof(CID_yyin) */ )
			{
			CID_yysptr=CID_yysbuf;
			return(0);
			}
		CID_yyprevious = CID_yytext[0] = input();
		if (CID_yyprevious>0)
			output(CID_yyprevious);
		CID_yylastch=CID_yytext;
# ifdef LEXDEBUG
		if(debug)putchar('\n');
# endif
		}
	}
CID_yyback(p, m)
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
CID_yyinput(){
	return(input());
	}
CID_yyoutput(c)
  int c; {
	output(c);
	}
CID_yyunput(c)
   int c; {
	unput(c);
	}
