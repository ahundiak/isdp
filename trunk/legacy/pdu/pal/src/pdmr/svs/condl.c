#include "condy.h"
# include "stdio.h"
# define U(x) x
# define NLSTATE PDU_c_yyprevious=YYNEWLINE
# define BEGIN PDU_c_yybgin = PDU_c_yysvec + 1 +
# define INITIAL 0
# define YYLERR PDU_c_yysvec
# define YYSTATE (PDU_c_yyestate-PDU_c_yysvec-1)
# define YYOPTIM 1
# define YYLMAX 200
# define output(c) putc(c,PDU_c_yyout)
# define input() (((PDU_c_yytchar=PDU_c_yysptr>PDU_c_yysbuf?U(*--PDU_c_yysptr):getc(PDU_c_yyin))==10?(PDU_c_yylineno++,PDU_c_yytchar):PDU_c_yytchar)==EOF?0:PDU_c_yytchar)
# define unput(c) {PDU_c_yytchar= (c);if(PDU_c_yytchar=='\n')PDU_c_yylineno--;*PDU_c_yysptr++=PDU_c_yytchar;}
# define PDU_c_yymore() (PDU_c_yymorfg=1)

/************ inhibit echo ****************************************************/
#ifdef MYDEBUG
#define ECHO fprintf(PDU_c_yyout, "%s",PDU_c_yytext)
#endif

#ifndef MYDEBUG
#define	ECHO
#endif
/******************************************************************************/


# define REJECT { nstr = PDU_c_yyreject(); goto PDU_c_yyfussy;}
int PDU_c_yyleng; extern char PDU_c_yytext[];
int PDU_c_yymorfg;
extern char *PDU_c_yysptr, PDU_c_yysbuf[];
int PDU_c_yytchar;

/************ change 'PDU_c_yyin' so that input is taken from a *********************/
/************ file rather than the 'stdin'	          *********************/

/*FILE *PDU_c_yyin = {stdin}, *PDU_c_yyout = {stdout};*/

FILE *PDU_c_yyout = {stdout};
extern FILE *PDU_c_yyin;

/*****************************************************************************/


extern int PDU_c_yylineno;
struct PDU_c_yysvf { 
	struct PDU_c_yywork *PDU_c_yystoff;
	struct PDU_c_yysvf *PDU_c_yyother;
	int *PDU_c_yystops;};
struct PDU_c_yysvf *PDU_c_yyestate;
extern struct PDU_c_yysvf PDU_c_yysvec[], *PDU_c_yybgin;
# define separ 2
# define YYNEWLINE 10
PDU_c_yylex(){
int nstr; extern int PDU_c_yyprevious;
while((nstr = PDU_c_yylook()) >= 0)
PDU_c_yyfussy: switch(nstr){
case 0:
if(PDU_c_yywrap()) return(0); break;
case 1:
{
			     	ECHO;
				return (_c_select);
			}
break;
case 2:
{
				ECHO;
				return (_c_distinct);
			}
break;
case 3:
	{
				ECHO;
				return (_c_column_name);
			}
break;
case 4:
	{
				ECHO;
				return (_c_from);
			}
break;
case 5:
		{
				ECHO;
				return (_c_outside_and);
			}
break;
case 6:
		{
				ECHO;
				return (_c_outside_or);
			}
break;
case 7:
			{
				ECHO;
				return (_c_greater_equal);
			}
break;
case 8:
			{
				ECHO;
				return (_c_greater);
			}
break;
case 9:
			{
				ECHO;
				return (_c_less_equal);
			}
break;
case 10:
			{
				ECHO;
				return (_c_less);
			}
break;
case 11:
			{
				ECHO;
				return (_c_equal);
			}
break;
case 12:
			{
				ECHO;
				return (_c_un_equal);
			}
break;
case 13:
			{
				ECHO;
				return (_c_not_equal);
			}
break;
case 14:
{
				ECHO;
				return (_c_between);
			}
break;
case 15:
		{
				ECHO;
				return (_c_in);
			}
break;
case 16:
		{
				ECHO;
				return (_c_is);
			}
break;
case 17:
	{
				ECHO;
				return (_c_null);
			}
break;
case 18:
	{
				ECHO;
				return (_c_like);
			}
break;
case 19:
		{
				ECHO;
				return (_c_not);
			}
break;
case 20:
{
				ECHO;
				return (_c_not_between);
			}
break;
case 21:
			{
				ECHO;
				return (_c_int_value);
			}
break;
case 22:
{
				ECHO;
				return (_c_real_value);
			}
break;
case 23:
			{
				ECHO;
				return (_c_multiply);
			}
break;
case 24:
			{
				ECHO;
				return (_c_divide);
			}
break;
case 25:
			{
				ECHO;
				return (_c_add);
			}
break;
case 26:
			{
				ECHO;
				return (_c_subtract);
			}
break;
case 27:
			{
				ECHO;
				return (_c_comma);
			}
break;
case 28:
			{
				ECHO;
				BEGIN separ;
				return (_c_open);
			}
break;
case 29:
			{
				ECHO;
				BEGIN 0;
				return (_c_close);
			}
break;
case 30:
		{
				ECHO;
				return (_c_string);
			}
break;
case 31:
	{
				ECHO;
				return (_c_table_name);
			}
break;
case -1:
break;
default:
fprintf(PDU_c_yyout,"bad switch PDU_c_yylook %d",nstr);
} return(0); }
/* end of PDU_c_yylex */

PDU_c_yywrap ()
{
	return (1);
}
int PDU_c_yyvstop[] = {
0,

28,
0,

29,
0,

23,
0,

25,
0,

27,
0,

26,
0,

24,
0,

21,
0,

10,
0,

11,
0,

8,
0,

31,
0,

31,
0,

31,
0,

31,
0,

31,
0,

31,
0,

31,
0,

31,
0,

31,
0,

31,
0,

13,
0,

9,
0,

12,
0,

7,
0,

31,
0,

31,
0,

31,
0,

31,
0,

15,
31,
0,

16,
31,
0,

31,
0,

31,
0,

31,
0,

6,
31,
0,

31,
0,

30,
0,

22,
0,

3,
0,

5,
31,
0,

31,
0,

31,
0,

31,
0,

31,
0,

19,
31,
0,

31,
0,

31,
0,

31,
0,

31,
0,

4,
31,
0,

18,
31,
0,

17,
31,
0,

31,
0,

31,
0,

31,
0,

31,
0,

31,
0,

31,
0,

1,
31,
0,

14,
31,
0,

31,
0,

2,
31,
0,

20,
0,
0};
# define YYTYPE char
struct PDU_c_yywork { YYTYPE verify, advance; } PDU_c_yycrank[] = {
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	1,5,	0,0,	
0,0,	0,0,	0,0,	0,0,	
1,6,	1,7,	1,8,	1,9,	
1,10,	1,11,	1,12,	29,46,	
1,13,	1,14,	1,14,	1,14,	
1,14,	1,14,	1,14,	1,14,	
1,14,	1,14,	1,14,	14,30,	
0,0,	1,15,	1,16,	1,17,	
5,28,	0,0,	1,18,	1,19,	
1,20,	1,21,	1,20,	1,22,	
1,20,	1,20,	1,23,	1,20,	
1,20,	1,24,	1,20,	1,25,	
1,26,	1,20,	1,20,	1,20,	
1,27,	1,20,	1,20,	1,20,	
1,20,	1,20,	1,20,	1,20,	
15,31,	15,32,	17,33,	0,0,	
0,0,	0,0,	1,18,	1,19,	
1,20,	1,21,	1,20,	1,22,	
1,20,	1,20,	1,23,	1,20,	
1,20,	1,24,	1,20,	1,25,	
1,26,	1,20,	1,20,	1,20,	
1,27,	1,20,	1,20,	1,20,	
1,20,	1,20,	1,20,	1,20,	
6,29,	6,29,	6,29,	6,29,	
6,29,	6,29,	6,29,	6,29,	
6,29,	6,29,	0,0,	20,20,	
22,20,	38,20,	38,52,	39,20,	
22,38,	6,29,	6,29,	6,29,	
6,29,	6,29,	6,29,	6,29,	
6,29,	6,29,	6,29,	6,29,	
6,29,	6,29,	6,29,	6,29,	
6,29,	6,29,	6,29,	6,29,	
6,29,	6,29,	6,29,	6,29,	
6,29,	6,29,	6,29,	20,20,	
22,20,	38,20,	38,52,	39,20,	
22,38,	6,29,	6,29,	6,29,	
6,29,	6,29,	6,29,	6,29,	
6,29,	6,29,	6,29,	6,29,	
6,29,	6,29,	6,29,	6,29,	
6,29,	6,29,	6,29,	6,29,	
6,29,	6,29,	6,29,	6,29,	
6,29,	6,29,	6,29,	10,14,	
10,14,	10,14,	10,14,	10,14,	
10,14,	10,14,	10,14,	10,14,	
10,14,	18,34,	0,0,	18,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	0,0,	21,37,	40,20,	
44,20,	49,20,	0,0,	21,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,35,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,20,	21,37,	40,20,	
44,20,	49,20,	18,20,	21,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,35,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,20,	19,36,	23,39,	
24,41,	25,20,	25,42,	27,45,	
23,40,	24,20,	26,20,	19,20,	
25,43,	43,55,	26,44,	43,20,	
27,20,	30,47,	30,47,	30,47,	
30,47,	30,47,	30,47,	30,47,	
30,47,	30,47,	30,47,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	19,36,	23,39,	
24,41,	25,20,	25,42,	27,45,	
23,40,	24,20,	26,20,	19,20,	
25,43,	43,55,	26,44,	43,20,	
27,20,	34,48,	34,48,	34,48,	
34,48,	34,48,	34,48,	34,48,	
34,48,	34,48,	34,48,	34,48,	
34,48,	34,48,	34,48,	34,48,	
34,48,	34,48,	34,48,	34,48,	
34,48,	34,48,	34,48,	34,48,	
34,48,	34,48,	34,48,	0,0,	
0,0,	41,53,	0,0,	59,20,	
41,20,	34,48,	34,48,	34,48,	
34,48,	34,48,	34,48,	34,48,	
34,48,	34,48,	34,48,	34,48,	
34,48,	34,48,	34,48,	34,48,	
34,48,	34,48,	34,48,	34,48,	
34,48,	34,48,	34,48,	34,48,	
34,48,	34,48,	34,48,	35,49,	
36,20,	41,53,	37,20,	59,20,	
41,20,	42,20,	36,50,	37,51,	
45,56,	35,20,	45,20,	42,54,	
48,48,	48,48,	48,48,	48,48,	
48,48,	48,48,	48,48,	48,48,	
48,48,	48,48,	51,20,	54,61,	
50,20,	52,59,	52,20,	0,0,	
51,58,	0,0,	0,0,	35,49,	
36,20,	50,57,	37,20,	53,60,	
60,20,	42,20,	36,50,	37,51,	
45,56,	35,20,	45,20,	42,54,	
53,20,	55,62,	54,61,	55,20,	
61,61,	62,20,	58,65,	65,69,	
56,63,	57,64,	51,20,	58,20,	
50,20,	52,59,	52,20,	48,48,	
51,58,	56,20,	57,20,	63,67,	
66,70,	50,57,	64,68,	53,60,	
60,20,	68,72,	70,74,	61,61,	
67,20,	0,0,	63,20,	64,20,	
53,20,	55,62,	67,71,	55,20,	
69,73,	62,20,	58,65,	65,69,	
56,63,	57,64,	71,20,	58,20,	
72,20,	74,76,	75,20,	69,20,	
54,20,	56,20,	57,20,	63,67,	
66,70,	73,20,	64,68,	76,77,	
77,78,	68,72,	70,74,	73,75,	
67,20,	61,66,	63,20,	64,20,	
78,79,	0,0,	67,71,	0,0,	
69,73,	0,0,	0,0,	0,0,	
0,0,	0,0,	71,20,	0,0,	
72,20,	74,76,	75,20,	69,20,	
54,20,	0,0,	0,0,	0,0,	
0,0,	73,20,	0,0,	76,77,	
77,78,	0,0,	0,0,	73,75,	
0,0,	61,66,	0,0,	0,0,	
78,79,	0,0,	0,0,	0,0,	
0,0};
struct PDU_c_yysvf PDU_c_yysvec[] = {
0,	0,	0,
PDU_c_yycrank+1,	0,		0,	
PDU_c_yycrank+0,	PDU_c_yysvec+1,	0,	
PDU_c_yycrank+0,	PDU_c_yysvec+1,	0,	
PDU_c_yycrank+0,	PDU_c_yysvec+1,	0,	
PDU_c_yycrank+3,	0,		0,	
PDU_c_yycrank+76,	0,		0,	
PDU_c_yycrank+0,	0,		PDU_c_yyvstop+1,
PDU_c_yycrank+0,	0,		PDU_c_yyvstop+3,
PDU_c_yycrank+0,	0,		PDU_c_yyvstop+5,
PDU_c_yycrank+151,	0,		PDU_c_yyvstop+7,
PDU_c_yycrank+0,	0,		PDU_c_yyvstop+9,
PDU_c_yycrank+0,	PDU_c_yysvec+10,	PDU_c_yyvstop+11,
PDU_c_yycrank+0,	0,		PDU_c_yyvstop+13,
PDU_c_yycrank+13,	PDU_c_yysvec+10,	PDU_c_yyvstop+15,
PDU_c_yycrank+31,	0,		PDU_c_yyvstop+17,
PDU_c_yycrank+0,	0,		PDU_c_yyvstop+19,
PDU_c_yycrank+33,	0,		PDU_c_yyvstop+21,
PDU_c_yycrank+163,	0,		PDU_c_yyvstop+23,
PDU_c_yycrank+217,	PDU_c_yysvec+18,	PDU_c_yyvstop+25,
PDU_c_yycrank+57,	PDU_c_yysvec+18,	PDU_c_yyvstop+27,
PDU_c_yycrank+149,	PDU_c_yysvec+18,	PDU_c_yyvstop+29,
PDU_c_yycrank+58,	PDU_c_yysvec+18,	PDU_c_yyvstop+31,
PDU_c_yycrank+209,	PDU_c_yysvec+18,	PDU_c_yyvstop+33,
PDU_c_yycrank+215,	PDU_c_yysvec+18,	PDU_c_yyvstop+35,
PDU_c_yycrank+211,	PDU_c_yysvec+18,	PDU_c_yyvstop+37,
PDU_c_yycrank+216,	PDU_c_yysvec+18,	PDU_c_yyvstop+39,
PDU_c_yycrank+222,	PDU_c_yysvec+18,	PDU_c_yyvstop+41,
PDU_c_yycrank+0,	0,		PDU_c_yyvstop+43,
PDU_c_yycrank+8,	PDU_c_yysvec+6,	0,	
PDU_c_yycrank+253,	0,		0,	
PDU_c_yycrank+0,	0,		PDU_c_yyvstop+45,
PDU_c_yycrank+0,	0,		PDU_c_yyvstop+47,
PDU_c_yycrank+0,	0,		PDU_c_yyvstop+49,
PDU_c_yycrank+268,	0,		0,	
PDU_c_yycrank+323,	PDU_c_yysvec+18,	PDU_c_yyvstop+51,
PDU_c_yycrank+314,	PDU_c_yysvec+18,	PDU_c_yyvstop+53,
PDU_c_yycrank+316,	PDU_c_yysvec+18,	PDU_c_yyvstop+55,
PDU_c_yycrank+59,	PDU_c_yysvec+18,	PDU_c_yyvstop+57,
PDU_c_yycrank+61,	PDU_c_yysvec+18,	PDU_c_yyvstop+59,
PDU_c_yycrank+145,	PDU_c_yysvec+18,	PDU_c_yyvstop+62,
PDU_c_yycrank+286,	PDU_c_yysvec+18,	PDU_c_yyvstop+65,
PDU_c_yycrank+319,	PDU_c_yysvec+18,	PDU_c_yyvstop+67,
PDU_c_yycrank+221,	PDU_c_yysvec+18,	PDU_c_yyvstop+69,
PDU_c_yycrank+146,	PDU_c_yysvec+18,	PDU_c_yyvstop+71,
PDU_c_yycrank+324,	PDU_c_yysvec+18,	PDU_c_yyvstop+74,
PDU_c_yycrank+0,	0,		PDU_c_yyvstop+76,
PDU_c_yycrank+0,	PDU_c_yysvec+30,	PDU_c_yyvstop+78,
PDU_c_yycrank+356,	PDU_c_yysvec+34,	PDU_c_yyvstop+80,
PDU_c_yycrank+147,	PDU_c_yysvec+18,	PDU_c_yyvstop+82,
PDU_c_yycrank+338,	PDU_c_yysvec+18,	PDU_c_yyvstop+85,
PDU_c_yycrank+336,	PDU_c_yysvec+18,	PDU_c_yyvstop+87,
PDU_c_yycrank+340,	PDU_c_yysvec+18,	PDU_c_yyvstop+89,
PDU_c_yycrank+358,	PDU_c_yysvec+18,	PDU_c_yyvstop+91,
PDU_c_yycrank+406,	PDU_c_yysvec+18,	PDU_c_yyvstop+93,
PDU_c_yycrank+361,	PDU_c_yysvec+18,	PDU_c_yyvstop+96,
PDU_c_yycrank+375,	PDU_c_yysvec+18,	PDU_c_yyvstop+98,
PDU_c_yycrank+376,	PDU_c_yysvec+18,	PDU_c_yyvstop+100,
PDU_c_yycrank+369,	PDU_c_yysvec+18,	PDU_c_yyvstop+102,
PDU_c_yycrank+285,	PDU_c_yysvec+18,	PDU_c_yyvstop+104,
PDU_c_yycrank+350,	PDU_c_yysvec+18,	PDU_c_yyvstop+107,
PDU_c_yycrank+431,	0,		0,	
PDU_c_yycrank+363,	PDU_c_yysvec+18,	PDU_c_yyvstop+110,
PDU_c_yycrank+388,	PDU_c_yysvec+18,	PDU_c_yyvstop+113,
PDU_c_yycrank+389,	PDU_c_yysvec+18,	PDU_c_yyvstop+115,
PDU_c_yycrank+365,	PDU_c_yysvec+18,	PDU_c_yyvstop+117,
PDU_c_yycrank+387,	0,		0,	
PDU_c_yycrank+386,	PDU_c_yysvec+18,	PDU_c_yyvstop+119,
PDU_c_yycrank+383,	PDU_c_yysvec+18,	PDU_c_yyvstop+121,
PDU_c_yycrank+405,	PDU_c_yysvec+18,	PDU_c_yyvstop+123,
PDU_c_yycrank+378,	0,		0,	
PDU_c_yycrank+400,	PDU_c_yysvec+18,	PDU_c_yyvstop+125,
PDU_c_yycrank+402,	PDU_c_yysvec+18,	PDU_c_yyvstop+128,
PDU_c_yycrank+411,	PDU_c_yysvec+18,	PDU_c_yyvstop+131,
PDU_c_yycrank+394,	0,		0,	
PDU_c_yycrank+404,	PDU_c_yysvec+18,	PDU_c_yyvstop+133,
PDU_c_yycrank+422,	0,		0,	
PDU_c_yycrank+423,	0,		0,	
PDU_c_yycrank+422,	0,		0,	
PDU_c_yycrank+0,	0,		PDU_c_yyvstop+136,
0,	0,	0};
struct PDU_c_yywork *PDU_c_yytop = PDU_c_yycrank+532;
struct PDU_c_yysvf *PDU_c_yybgin = PDU_c_yysvec+1;
char PDU_c_yymatch[] = {
00  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,011 ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
011 ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,'+' ,01  ,'+' ,01  ,01  ,
'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,
'0' ,'0' ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,'A' ,'B' ,'C' ,'D' ,'E' ,'F' ,'G' ,
'G' ,'I' ,'G' ,'K' ,'L' ,'M' ,'N' ,'O' ,
'G' ,'G' ,'R' ,'S' ,'T' ,'U' ,'G' ,'W' ,
'G' ,'G' ,'G' ,01  ,01  ,01  ,01  ,'_' ,
01  ,'A' ,'B' ,'C' ,'D' ,'E' ,'F' ,'G' ,
'G' ,'I' ,'G' ,'K' ,'L' ,'M' ,'N' ,'O' ,
'G' ,'G' ,'R' ,'S' ,'T' ,'U' ,'G' ,'W' ,
'G' ,'G' ,'G' ,01  ,01  ,01  ,01  ,01  ,
0};
char PDU_c_yyextra[] = {
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0};
#ident	"@(#)libl:lib/ncform	1.3	1.2 (Intergraph) 3/10/88"
int PDU_c_yylineno =1;
# define YYU(x) x
# define NLSTATE PDU_c_yyprevious=YYNEWLINE
char PDU_c_yytext[YYLMAX];
struct PDU_c_yysvf *PDU_c_yylstate [YYLMAX], **PDU_c_yylsp, **PDU_c_yyolsp;
char PDU_c_yysbuf[YYLMAX];
char *PDU_c_yysptr = PDU_c_yysbuf;
int *PDU_c_yyfnd;
extern struct PDU_c_yysvf *PDU_c_yyestate;
int PDU_c_yyprevious = YYNEWLINE;
PDU_c_yylook(){
	register struct PDU_c_yysvf *PDU_c_yystate, **lsp;
	register struct PDU_c_yywork *PDU_c_yyt;
	struct PDU_c_yysvf *PDU_c_yyz;
	int PDU_c_yych, PDU_c_yyfirst;
	struct PDU_c_yywork *PDU_c_yyr;
# ifdef LEXDEBUG
	int debug;
# endif
	char *PDU_c_yylastch;
	/* start off machines */
# ifdef LEXDEBUG
	debug = 0;
# endif
	PDU_c_yyfirst=1;
	if (!PDU_c_yymorfg)
		PDU_c_yylastch = PDU_c_yytext;
	else {
		PDU_c_yymorfg=0;
		PDU_c_yylastch = PDU_c_yytext+PDU_c_yyleng;
		}
	for(;;){
		lsp = PDU_c_yylstate;
		PDU_c_yyestate = PDU_c_yystate = PDU_c_yybgin;
		if (PDU_c_yyprevious==YYNEWLINE) PDU_c_yystate++;
		for (;;){
# ifdef LEXDEBUG
			if(debug)fprintf(PDU_c_yyout,"state %d\n",PDU_c_yystate-PDU_c_yysvec-1);
# endif
			PDU_c_yyt = PDU_c_yystate->PDU_c_yystoff;
			if(PDU_c_yyt == PDU_c_yycrank && !PDU_c_yyfirst){  /* may not be any transitions */
				PDU_c_yyz = PDU_c_yystate->PDU_c_yyother;
				if(PDU_c_yyz == 0)break;
				if(PDU_c_yyz->PDU_c_yystoff == PDU_c_yycrank)break;
				}
			*PDU_c_yylastch++ = PDU_c_yych = input();
			PDU_c_yyfirst=0;
		tryagain:
# ifdef LEXDEBUG
			if(debug){
				fprintf(PDU_c_yyout,"char ");
				allprint(PDU_c_yych);
				putchar('\n');
				}
# endif
			PDU_c_yyr = PDU_c_yyt;
			if ( (int)PDU_c_yyt > (int)PDU_c_yycrank){
				PDU_c_yyt = PDU_c_yyr + PDU_c_yych;
				if (PDU_c_yyt <= PDU_c_yytop && PDU_c_yyt->verify+PDU_c_yysvec == PDU_c_yystate){
					if(PDU_c_yyt->advance+PDU_c_yysvec == YYLERR)	/* error transitions */
						{unput(*--PDU_c_yylastch);break;}
					*lsp++ = PDU_c_yystate = PDU_c_yyt->advance+PDU_c_yysvec;
					goto contin;
					}
				}
# ifdef YYOPTIM
			else if((int)PDU_c_yyt < (int)PDU_c_yycrank) {		/* r < PDU_c_yycrank */
				PDU_c_yyt = PDU_c_yyr = PDU_c_yycrank+(PDU_c_yycrank-PDU_c_yyt);
# ifdef LEXDEBUG
				if(debug)fprintf(PDU_c_yyout,"compressed state\n");
# endif
				PDU_c_yyt = PDU_c_yyt + PDU_c_yych;
				if(PDU_c_yyt <= PDU_c_yytop && PDU_c_yyt->verify+PDU_c_yysvec == PDU_c_yystate){
					if(PDU_c_yyt->advance+PDU_c_yysvec == YYLERR)	/* error transitions */
						{unput(*--PDU_c_yylastch);break;}
					*lsp++ = PDU_c_yystate = PDU_c_yyt->advance+PDU_c_yysvec;
					goto contin;
					}
				PDU_c_yyt = PDU_c_yyr + YYU(PDU_c_yymatch[PDU_c_yych]);
# ifdef LEXDEBUG
				if(debug){
					fprintf(PDU_c_yyout,"try fall back character ");
					allprint(YYU(PDU_c_yymatch[PDU_c_yych]));
					putchar('\n');
					}
# endif
				if(PDU_c_yyt <= PDU_c_yytop && PDU_c_yyt->verify+PDU_c_yysvec == PDU_c_yystate){
					if(PDU_c_yyt->advance+PDU_c_yysvec == YYLERR)	/* error transition */
						{unput(*--PDU_c_yylastch);break;}
					*lsp++ = PDU_c_yystate = PDU_c_yyt->advance+PDU_c_yysvec;
					goto contin;
					}
				}
			if ((PDU_c_yystate = PDU_c_yystate->PDU_c_yyother) && (PDU_c_yyt= PDU_c_yystate->PDU_c_yystoff) != PDU_c_yycrank){
# ifdef LEXDEBUG
				if(debug)fprintf(PDU_c_yyout,"fall back to state %d\n",PDU_c_yystate-PDU_c_yysvec-1);
# endif
				goto tryagain;
				}
# endif
			else
				{unput(*--PDU_c_yylastch);break;}
		contin:
# ifdef LEXDEBUG
			if(debug){
				fprintf(PDU_c_yyout,"state %d char ",PDU_c_yystate-PDU_c_yysvec-1);
				allprint(PDU_c_yych);
				putchar('\n');
				}
# endif
			;
			}
# ifdef LEXDEBUG
		if(debug){
			fprintf(PDU_c_yyout,"stopped at %d with ",*(lsp-1)-PDU_c_yysvec-1);
			allprint(PDU_c_yych);
			putchar('\n');
			}
# endif
		while (lsp-- > PDU_c_yylstate){
			*PDU_c_yylastch-- = 0;
			if (*lsp != 0 && (PDU_c_yyfnd= (*lsp)->PDU_c_yystops) && *PDU_c_yyfnd > 0){
				PDU_c_yyolsp = lsp;
				if(PDU_c_yyextra[*PDU_c_yyfnd]){		/* must backup */
					while(PDU_c_yyback((*lsp)->PDU_c_yystops,-*PDU_c_yyfnd) != 1 && lsp > PDU_c_yylstate){
						lsp--;
						unput(*PDU_c_yylastch--);
						}
					}
				PDU_c_yyprevious = YYU(*PDU_c_yylastch);
				PDU_c_yylsp = lsp;
				PDU_c_yyleng = PDU_c_yylastch-PDU_c_yytext+1;
				PDU_c_yytext[PDU_c_yyleng] = 0;
# ifdef LEXDEBUG
				if(debug){
					fprintf(PDU_c_yyout,"\nmatch ");
					sprint(PDU_c_yytext);
					fprintf(PDU_c_yyout," action %d\n",*PDU_c_yyfnd);
					}
# endif
				return(*PDU_c_yyfnd++);
				}
			unput(*PDU_c_yylastch);
			}
		/* you may or may not be reading from PDU_c_yyin - we really   */
		/* can't tell at this point. So whenver PDU_c_yytext[0] is set */
		/* to 0, this indicates end of file			 */
		if (PDU_c_yytext[0] == 0 /* && feof(PDU_c_yyin) */ )
			{
			PDU_c_yysptr=PDU_c_yysbuf;
			return(0);
			}
		PDU_c_yyprevious = PDU_c_yytext[0] = input();
		if (PDU_c_yyprevious>0)
			output(PDU_c_yyprevious);
		PDU_c_yylastch=PDU_c_yytext;
# ifdef LEXDEBUG
		if(debug)putchar('\n');
# endif
		}
	}
PDU_c_yyback(p, m)
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
PDU_c_yyinput(){
	return(input());
	}
PDU_c_yyoutput(c)
  int c; {
	output(c);
	}
PDU_c_yyunput(c)
   int c; {
	unput(c);
	}
