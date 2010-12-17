# include "stdio.h"
# define U(x) x
# define NLSTATE yyprevious=YYNEWLINE
# define BEGIN yybgin = yysvec + 1 +
# define INITIAL 0
# define YYLERR yysvec
# define YYSTATE (yyestate-yysvec-1)
# define YYOPTIM 1
# define YYLMAX 200
# define output(c) putc(c,yyout)
# define input() (((yytchar=yysptr>yysbuf?U(*--yysptr):getc(yyin))==10?(yylineno++,yytchar):yytchar)==EOF?0:yytchar)
# define unput(c) {yytchar= (c);if(yytchar=='\n')yylineno--;*yysptr++=yytchar;}
# define yymore() (yymorfg=1)
# define ECHO fprintf(yyout, "%s",yytext)
# define REJECT { nstr = yyreject(); goto yyfussy;}
int yyleng; extern char yytext[];
int yymorfg;
extern char *yysptr, yysbuf[];
int yytchar;
FILE *yyin = {stdin}, *yyout = {stdout};
extern int yylineno;
struct yysvf { 
	struct yywork *yystoff;
	struct yysvf *yyother;
	int *yystops;};
struct yysvf *yyestate;
extern struct yysvf yysvec[], *yybgin;
# define separ 2
# define YYNEWLINE 10
yylex(){
int nstr; extern int yyprevious;
while((nstr = yylook()) >= 0)
yyfussy: switch(nstr){
case 0:
if(yywrap()) return(0); break;
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
fprintf(yyout,"bad switch yylook %d",nstr);
} return(0); }
/* end of yylex */

yywrap ()
{
	return (1);
}
int yyvstop[] = {
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
struct yywork { YYTYPE verify, advance; } yycrank[] = {
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
struct yysvf yysvec[] = {
0,	0,	0,
yycrank+1,	0,		0,	
yycrank+0,	yysvec+1,	0,	
yycrank+0,	yysvec+1,	0,	
yycrank+0,	yysvec+1,	0,	
yycrank+76,	0,		0,	
yycrank+0,	0,		yyvstop+1,
yycrank+0,	0,		yyvstop+3,
yycrank+0,	0,		yyvstop+5,
yycrank+0,	0,		yyvstop+7,
yycrank+0,	0,		yyvstop+9,
yycrank+134,	0,		0,	
yycrank+0,	0,		yyvstop+11,
yycrank+168,	0,		yyvstop+13,
yycrank+178,	0,		yyvstop+15,
yycrank+13,	yysvec+14,	yyvstop+17,
yycrank+20,	yysvec+5,	0,	
yycrank+15,	0,		0,	
yycrank+13,	0,		0,	
yycrank+131,	0,		0,	
yycrank+232,	0,		0,	
yycrank+26,	0,		0,	
yycrank+14,	0,		0,	
yycrank+254,	0,		0,	
yycrank+13,	yysvec+14,	yyvstop+19,
yycrank+0,	0,		yyvstop+21,
yycrank+66,	0,		0,	
yycrank+14,	0,		0,	
yycrank+15,	0,		0,	
yycrank+16,	0,		0,	
yycrank+17,	0,		0,	
yycrank+18,	0,		0,	
yycrank+19,	0,		0,	
yycrank+89,	0,		0,	
yycrank+0,	yysvec+23,	yyvstop+23,
yycrank+0,	yysvec+14,	yyvstop+25,
yycrank+90,	0,		0,	
yycrank+0,	0,		yyvstop+28,
yycrank+0,	0,		yyvstop+30,
yycrank+0,	0,		yyvstop+32,
yycrank+0,	0,		yyvstop+34,
yycrank+0,	0,		yyvstop+36,
yycrank+0,	0,		yyvstop+38,
yycrank+0,	0,		yyvstop+40,
yycrank+0,	0,		yyvstop+42,
0,	0,	0};
struct yywork *yytop = yycrank+316;
struct yysvf *yybgin = yysvec+1;
char yymatch[] = {
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
char yyextra[] = {
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0};
#ident	"@(#)libl:lib/ncform	1.3	1.2 (Intergraph) 3/10/88"
int yylineno =1;
# define YYU(x) x
# define NLSTATE yyprevious=YYNEWLINE
char yytext[YYLMAX];
struct yysvf *yylstate [YYLMAX], **yylsp, **yyolsp;
char yysbuf[YYLMAX];
char *yysptr = yysbuf;
int *yyfnd;
extern struct yysvf *yyestate;
int yyprevious = YYNEWLINE;
yylook(){
	register struct yysvf *yystate, **lsp;
	register struct yywork *yyt;
	struct yysvf *yyz;
	int yych, yyfirst;
	struct yywork *yyr;
# ifdef LEXDEBUG
	int debug;
# endif
	char *yylastch;
	/* start off machines */
# ifdef LEXDEBUG
	debug = 0;
# endif
	yyfirst=1;
	if (!yymorfg)
		yylastch = yytext;
	else {
		yymorfg=0;
		yylastch = yytext+yyleng;
		}
	for(;;){
		lsp = yylstate;
		yyestate = yystate = yybgin;
		if (yyprevious==YYNEWLINE) yystate++;
		for (;;){
# ifdef LEXDEBUG
			if(debug)fprintf(yyout,"state %d\n",yystate-yysvec-1);
# endif
			yyt = yystate->yystoff;
			if(yyt == yycrank && !yyfirst){  /* may not be any transitions */
				yyz = yystate->yyother;
				if(yyz == 0)break;
				if(yyz->yystoff == yycrank)break;
				}
			*yylastch++ = yych = input();
			yyfirst=0;
		tryagain:
# ifdef LEXDEBUG
			if(debug){
				fprintf(yyout,"char ");
				allprint(yych);
				putchar('\n');
				}
# endif
			yyr = yyt;
			if ( (int)yyt > (int)yycrank){
				yyt = yyr + yych;
				if (yyt <= yytop && yyt->verify+yysvec == yystate){
					if(yyt->advance+yysvec == YYLERR)	/* error transitions */
						{unput(*--yylastch);break;}
					*lsp++ = yystate = yyt->advance+yysvec;
					goto contin;
					}
				}
# ifdef YYOPTIM
			else if((int)yyt < (int)yycrank) {		/* r < yycrank */
				yyt = yyr = yycrank+(yycrank-yyt);
# ifdef LEXDEBUG
				if(debug)fprintf(yyout,"compressed state\n");
# endif
				yyt = yyt + yych;
				if(yyt <= yytop && yyt->verify+yysvec == yystate){
					if(yyt->advance+yysvec == YYLERR)	/* error transitions */
						{unput(*--yylastch);break;}
					*lsp++ = yystate = yyt->advance+yysvec;
					goto contin;
					}
				yyt = yyr + YYU(yymatch[yych]);
# ifdef LEXDEBUG
				if(debug){
					fprintf(yyout,"try fall back character ");
					allprint(YYU(yymatch[yych]));
					putchar('\n');
					}
# endif
				if(yyt <= yytop && yyt->verify+yysvec == yystate){
					if(yyt->advance+yysvec == YYLERR)	/* error transition */
						{unput(*--yylastch);break;}
					*lsp++ = yystate = yyt->advance+yysvec;
					goto contin;
					}
				}
			if ((yystate = yystate->yyother) && (yyt= yystate->yystoff) != yycrank){
# ifdef LEXDEBUG
				if(debug)fprintf(yyout,"fall back to state %d\n",yystate-yysvec-1);
# endif
				goto tryagain;
				}
# endif
			else
				{unput(*--yylastch);break;}
		contin:
# ifdef LEXDEBUG
			if(debug){
				fprintf(yyout,"state %d char ",yystate-yysvec-1);
				allprint(yych);
				putchar('\n');
				}
# endif
			;
			}
# ifdef LEXDEBUG
		if(debug){
			fprintf(yyout,"stopped at %d with ",*(lsp-1)-yysvec-1);
			allprint(yych);
			putchar('\n');
			}
# endif
		while (lsp-- > yylstate){
			*yylastch-- = 0;
			if (*lsp != 0 && (yyfnd= (*lsp)->yystops) && *yyfnd > 0){
				yyolsp = lsp;
				if(yyextra[*yyfnd]){		/* must backup */
					while(yyback((*lsp)->yystops,-*yyfnd) != 1 && lsp > yylstate){
						lsp--;
						unput(*yylastch--);
						}
					}
				yyprevious = YYU(*yylastch);
				yylsp = lsp;
				yyleng = yylastch-yytext+1;
				yytext[yyleng] = 0;
# ifdef LEXDEBUG
				if(debug){
					fprintf(yyout,"\nmatch ");
					sprint(yytext);
					fprintf(yyout," action %d\n",*yyfnd);
					}
# endif
				return(*yyfnd++);
				}
			unput(*yylastch);
			}
		/* you may or may not be reading from yyin - we really   */
		/* can't tell at this point. So whenver yytext[0] is set */
		/* to 0, this indicates end of file			 */
		if (yytext[0] == 0 /* && feof(yyin) */ )
			{
			yysptr=yysbuf;
			return(0);
			}
		yyprevious = yytext[0] = input();
		if (yyprevious>0)
			output(yyprevious);
		yylastch=yytext;
# ifdef LEXDEBUG
		if(debug)putchar('\n');
# endif
		}
	}
yyback(p, m)
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
yyinput(){
	return(input());
	}
yyoutput(c)
  int c; {
	output(c);
	}
yyunput(c)
   int c; {
	unput(c);
	}
