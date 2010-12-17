#include "viewy.h"
# include "stdio.h"
# define U(x) x
# define NLSTATE PDU_v_yyprevious=YYNEWLINE
# define BEGIN PDU_v_yybgin = PDU_v_yysvec + 1 +
# define INITIAL 0
# define YYLERR PDU_v_yysvec
# define YYSTATE (PDU_v_yyestate-PDU_v_yysvec-1)
# define YYOPTIM 1
# define YYLMAX 200
# define output(c) putc(c,PDU_v_yyout)
# define input() (((PDU_v_yytchar=PDU_v_yysptr>PDU_v_yysbuf?U(*--PDU_v_yysptr):getc(PDU_v_yyin))==10?(PDU_v_yylineno++,PDU_v_yytchar):PDU_v_yytchar)==EOF?0:PDU_v_yytchar)
# define unput(c) {PDU_v_yytchar= (c);if(PDU_v_yytchar=='\n')PDU_v_yylineno--;*PDU_v_yysptr++=PDU_v_yytchar;}
# define PDU_v_yymore() (PDU_v_yymorfg=1)


/************ inhibit echo ****************************************************/
#ifdef MYDEBUG
#define ECHO { fprintf (PDU_v_yyout, "ECHO = "); fprintf(PDU_v_yyout, "%s",PDU_v_yytext) } 
#endif

#ifndef MYDEBUG
#define	ECHO
#endif
/******************************************************************************/



# define REJECT { nstr = PDU_v_yyreject(); goto PDU_v_yyfussy;}
int PDU_v_yyleng; extern char PDU_v_yytext[];
int PDU_v_yymorfg;
extern char *PDU_v_yysptr, PDU_v_yysbuf[];
int PDU_v_yytchar;


/************ change 'PDU_v_yyin' so that input is taken from a *********************/
/************ file rather than the 'stdin'	          *********************/

/*FILE *PDU_v_yyin = {stdin}, *PDU_v_yyout = {stdout};*/

FILE *PDU_v_yyout = {stdout};
extern FILE *PDU_v_yyin;

/*****************************************************************************/



extern int PDU_v_yylineno;
struct PDU_v_yysvf { 
	struct PDU_v_yywork *PDU_v_yystoff;
	struct PDU_v_yysvf *PDU_v_yyother;
	int *PDU_v_yystops;};
struct PDU_v_yysvf *PDU_v_yyestate;
extern struct PDU_v_yysvf PDU_v_yysvec[], *PDU_v_yybgin;
# define OUTERPAR 2
# define INNERPAR 4
# define YYNEWLINE 10
PDU_v_yylex(){
int nstr; extern int PDU_v_yyprevious;
while((nstr = PDU_v_yylook()) >= 0)
PDU_v_yyfussy: switch(nstr){
case 0:
if(PDU_v_yywrap()) return(0); break;
case 1:
{
				ECHO;
				return (_create);
			}
break;
case 2:
	{
				ECHO;
				return (_view);
			}
break;
case 3:
		{
				ECHO;
				return (_as);
			}
break;
case 4:
	{
			     	ECHO;
				return (_select);
			}
break;
case 5:
	{
				ECHO;
				return (_column_name);
			}
break;
case 6:
	{
				ECHO;
				return (_from);
			}
break;
case 7:
	{
				ECHO;
				return (_where);
			}
break;
case 8:
	{
				ECHO;
				return (_inside_inside_and);
			}
break;
case 9:
	{
				ECHO;
				return (_inside_and);
			}
break;
case 10:
		{
				ECHO;
				return (_outside_and);
			}
break;
case 11:
		{
				ECHO;
				return (_inside_or);
			}
break;
case 12:
		{
				ECHO;
				return (_outside_or);
			}
break;
case 13:
			{
				ECHO;
				return (_greater_equal);
			}
break;
case 14:
			{
				ECHO;
				return (_greater);
			}
break;
case 15:
			{
				ECHO;
				return (_less_equal);
			}
break;
case 16:
			{
				ECHO;
				return (_less);
			}
break;
case 17:
			{
				ECHO;
				return (_equal);
			}
break;
case 18:
			{
				ECHO;
				return (_un_equal);
			}
break;
case 19:
			{
				ECHO;
				return (_not_equal);
			}
break;
case 20:
		{
				ECHO;
				return (_not);
			}
break;
case 21:
{
				ECHO;
				return (_between);
			}
break;
case 22:
		{
				ECHO;
				return (_in);
			}
break;
case 23:
		{
				ECHO;
				return (_is);
			}
break;
case 24:
	{
				ECHO;
				return (_null);
			}
break;
case 25:
	{
				ECHO;
				return (_like);
			}
break;
case 26:
			{
				ECHO;
				return (_int_value);
			}
break;
case 27:
{
				ECHO;
				return (_real_value);
			}
break;
case 28:
			{
				ECHO;
				return (_multiply);
			}
break;
case 29:
			{
				ECHO;
				return (_divide);
			}
break;
case 30:
			{
				ECHO;
				return (_add);
			}
break;
case 31:
			{
				ECHO;
				return (_subtract);
			}
break;
case 32:
			{
				ECHO;
				return (_comma);
			}
break;
case 33:
			{
				ECHO;
				BEGIN INNERPAR;
				return (_inside_open);
			}
break;
case 34:
			{
				ECHO;
				BEGIN OUTERPAR;
				return (_open);
			}
break;
case 35:
			{
				ECHO;
				BEGIN 0;
				BEGIN OUTERPAR;
				return (_inside_close);
			}
break;
case 36:
			{
				ECHO;
				BEGIN 0;
				return (_close);
			}
break;
case 37:
{
				ECHO;
				return (_string);
			}
break;
case 38:
	{
				ECHO;
				return (_view_table_name);
			}
break;
case -1:
break;
default:
fprintf(PDU_v_yyout,"bad switch PDU_v_yylook %d",nstr);
} return(0); }
/* end of PDU_v_yylex */

PDU_v_yywrap ()
{
	printf ("%s\n", PDU_v_yytext);
	return (1);
}
int PDU_v_yyvstop[] = {
0,

34,
0,

36,
0,

28,
0,

30,
0,

32,
0,

31,
0,

29,
0,

26,
0,

16,
0,

17,
0,

14,
0,

38,
0,

38,
0,

38,
0,

38,
0,

38,
0,

38,
0,

38,
0,

38,
0,

38,
0,

38,
0,

38,
0,

38,
0,

33,
34,
0,

38,
0,

38,
0,

35,
36,
0,

38,
0,

19,
0,

37,
0,

15,
0,

18,
0,

13,
0,

38,
0,

3,
38,
0,

38,
0,

38,
0,

38,
0,

22,
38,
0,

23,
38,
0,

38,
0,

38,
0,

38,
0,

12,
38,
0,

38,
0,

38,
0,

38,
0,

38,
0,

11,
12,
38,
0,

38,
0,

27,
0,

5,
0,

10,
38,
0,

38,
0,

38,
0,

38,
0,

38,
0,

20,
38,
0,

38,
0,

38,
0,

38,
0,

38,
0,

9,
10,
38,
0,

8,
10,
38,
0,

38,
0,

38,
0,

6,
38,
0,

25,
38,
0,

24,
38,
0,

38,
0,

2,
38,
0,

38,
0,

38,
0,

38,
0,

38,
0,

7,
38,
0,

38,
0,

1,
38,
0,

4,
38,
0,

21,
38,
0,
0};
# define YYTYPE char
struct PDU_v_yywork { YYTYPE verify, advance; } PDU_v_yycrank[] = {
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	1,7,	0,0,	
0,0,	0,0,	0,0,	0,0,	
1,8,	1,9,	1,10,	1,11,	
1,12,	1,13,	1,14,	0,0,	
1,15,	1,16,	1,16,	1,16,	
1,16,	1,16,	1,16,	1,16,	
1,16,	1,16,	1,16,	16,39,	
0,0,	1,17,	1,18,	1,19,	
7,37,	0,0,	1,20,	1,21,	
1,22,	1,23,	1,23,	1,24,	
1,23,	1,23,	1,25,	1,23,	
1,23,	1,26,	1,23,	1,27,	
1,28,	1,23,	1,23,	1,23,	
1,29,	1,23,	1,23,	1,30,	
1,31,	1,23,	1,23,	1,23,	
17,40,	17,41,	19,42,	0,0,	
0,0,	0,0,	1,20,	1,21,	
1,22,	1,23,	1,23,	1,24,	
1,23,	1,23,	1,25,	1,23,	
1,23,	1,26,	1,23,	1,27,	
1,28,	1,23,	1,23,	1,23,	
1,29,	1,23,	1,23,	1,30,	
1,31,	1,23,	1,23,	1,23,	
3,32,	4,32,	33,58,	5,35,	
6,35,	12,16,	12,16,	12,16,	
12,16,	12,16,	12,16,	12,16,	
12,16,	12,16,	12,16,	22,23,	
36,60,	23,23,	25,49,	22,47,	
22,23,	21,46,	23,23,	25,50,	
0,0,	3,33,	4,33,	5,36,	
6,36,	0,0,	21,23,	0,0,	
45,23,	0,0,	33,58,	21,23,	
0,0,	45,23,	0,0,	3,34,	
4,34,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	22,23,	
36,60,	23,23,	25,49,	22,47,	
22,23,	21,46,	23,23,	25,50,	
0,0,	3,33,	4,33,	5,36,	
6,36,	8,8,	21,23,	0,0,	
45,23,	8,8,	8,8,	21,23,	
8,38,	45,23,	0,0,	3,34,	
4,34,	0,0,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
48,23,	48,66,	0,0,	0,0,	
0,0,	48,23,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
48,23,	48,66,	0,0,	0,0,	
8,8,	48,23,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
20,43,	0,0,	20,23,	20,23,	
20,23,	20,23,	20,23,	20,23,	
20,23,	20,23,	20,23,	20,23,	
0,0,	49,23,	0,0,	0,0,	
0,0,	0,0,	49,23,	20,23,	
20,23,	20,23,	20,23,	20,23,	
20,23,	20,23,	20,23,	20,23,	
20,23,	20,23,	20,23,	20,23,	
20,44,	20,23,	20,23,	20,23,	
20,23,	20,45,	20,23,	20,23,	
20,23,	20,23,	20,23,	20,23,	
20,23,	49,23,	0,0,	0,0,	
0,0,	20,23,	49,23,	20,23,	
20,23,	20,23,	20,23,	20,23,	
20,23,	20,23,	20,23,	20,23,	
20,23,	20,23,	20,23,	20,23,	
20,44,	20,23,	20,23,	20,23,	
20,23,	20,45,	20,23,	20,23,	
20,23,	20,23,	20,23,	20,23,	
20,23,	24,23,	26,51,	27,23,	
27,52,	24,48,	24,23,	26,23,	
27,23,	28,23,	27,53,	29,55,	
26,23,	28,54,	28,23,	0,0,	
30,56,	31,57,	0,0,	0,0,	
29,23,	30,23,	0,0,	31,23,	
46,23,	29,23,	30,23,	34,23,	
31,23,	46,23,	46,64,	34,59,	
34,23,	24,23,	26,51,	27,23,	
27,52,	24,48,	24,23,	26,23,	
27,23,	28,23,	27,53,	29,55,	
26,23,	28,54,	28,23,	0,0,	
30,56,	31,57,	0,0,	0,0,	
29,23,	30,23,	0,0,	31,23,	
46,23,	29,23,	30,23,	34,23,	
31,23,	46,23,	46,64,	34,59,	
34,23,	39,61,	39,61,	39,61,	
39,61,	39,61,	39,61,	39,61,	
39,61,	39,61,	39,61,	43,62,	
43,62,	43,62,	43,62,	43,62,	
43,62,	43,62,	43,62,	43,62,	
43,62,	43,62,	43,62,	43,62,	
43,62,	43,62,	43,62,	43,62,	
43,62,	43,62,	43,62,	43,62,	
43,62,	43,62,	43,62,	43,62,	
43,62,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	43,62,	
43,62,	43,62,	43,62,	43,62,	
43,62,	43,62,	43,62,	43,62,	
43,62,	43,62,	43,62,	43,62,	
43,62,	43,62,	43,62,	43,62,	
43,62,	43,62,	43,62,	43,62,	
43,62,	43,62,	43,62,	43,62,	
43,62,	44,63,	50,23,	47,65,	
52,23,	51,67,	0,0,	50,23,	
51,23,	52,23,	52,68,	44,23,	
47,23,	51,23,	54,23,	56,71,	
44,23,	47,23,	53,69,	54,23,	
53,23,	55,70,	0,0,	55,23,	
56,23,	53,23,	0,0,	0,0,	
55,23,	56,23,	0,0,	0,0,	
0,0,	44,63,	50,23,	47,65,	
52,23,	51,67,	0,0,	50,23,	
51,23,	52,23,	52,68,	44,23,	
47,23,	51,23,	54,23,	56,71,	
44,23,	47,23,	53,69,	54,23,	
53,23,	55,70,	57,72,	55,23,	
56,23,	53,23,	0,0,	58,73,	
55,23,	56,23,	59,23,	57,23,	
0,0,	60,74,	63,23,	59,23,	
57,23,	58,23,	0,0,	63,23,	
66,77,	66,23,	58,23,	60,23,	
0,0,	0,0,	66,23,	0,0,	
60,23,	0,0,	0,0,	0,0,	
0,0,	0,0,	57,72,	0,0,	
0,0,	0,0,	0,0,	58,73,	
0,0,	0,0,	59,23,	57,23,	
0,0,	60,74,	63,23,	59,23,	
57,23,	58,23,	0,0,	63,23,	
66,77,	66,23,	58,23,	60,23,	
0,0,	0,0,	66,23,	0,0,	
60,23,	62,62,	62,62,	62,62,	
62,62,	62,62,	62,62,	62,62,	
62,62,	62,62,	62,62,	65,76,	
64,23,	67,78,	68,23,	0,0,	
0,0,	64,23,	69,79,	68,23,	
69,23,	64,75,	67,23,	70,80,	
65,23,	69,23,	71,23,	67,23,	
73,23,	65,23,	0,0,	71,23,	
70,23,	73,23,	72,23,	71,81,	
74,23,	70,23,	72,82,	72,23,	
0,0,	74,23,	0,0,	65,76,	
64,23,	67,78,	68,23,	0,0,	
62,62,	64,23,	69,79,	68,23,	
69,23,	64,75,	67,23,	70,80,	
65,23,	69,23,	71,23,	67,23,	
73,23,	65,23,	0,0,	71,23,	
70,23,	73,23,	72,23,	71,81,	
74,23,	70,23,	72,82,	72,23,	
75,83,	74,23,	76,23,	0,0,	
80,85,	77,23,	78,23,	76,23,	
76,84,	75,23,	77,23,	78,23,	
79,23,	81,23,	75,23,	80,23,	
82,86,	79,23,	81,23,	83,87,	
80,23,	85,23,	0,0,	0,0,	
86,23,	82,23,	85,23,	85,89,	
83,23,	86,23,	82,23,	0,0,	
75,83,	83,23,	76,23,	0,0,	
80,85,	77,23,	78,23,	76,23,	
76,84,	75,23,	77,23,	78,23,	
79,23,	81,23,	75,23,	80,23,	
82,86,	79,23,	81,23,	83,87,	
80,23,	85,23,	84,88,	0,0,	
86,23,	82,23,	85,23,	85,89,	
83,23,	86,23,	82,23,	84,23,	
87,90,	83,23,	88,23,	89,23,	
84,23,	87,23,	90,23,	88,23,	
89,23,	0,0,	0,0,	90,23,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	84,88,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	84,23,	
87,90,	0,0,	88,23,	89,23,	
84,23,	87,23,	90,23,	88,23,	
89,23,	0,0,	0,0,	90,23,	
0,0};
struct PDU_v_yysvf PDU_v_yysvec[] = {
0,	0,	0,
PDU_v_yycrank+1,	0,		0,	
PDU_v_yycrank+0,	PDU_v_yysvec+1,	0,	
PDU_v_yycrank+84,	PDU_v_yysvec+1,	0,	
PDU_v_yycrank+85,	PDU_v_yysvec+1,	0,	
PDU_v_yycrank+86,	PDU_v_yysvec+1,	0,	
PDU_v_yycrank+87,	PDU_v_yysvec+1,	0,	
PDU_v_yycrank+3,	0,		0,	
PDU_v_yycrank+153,	0,		0,	
PDU_v_yycrank+0,	0,		PDU_v_yyvstop+1,
PDU_v_yycrank+0,	0,		PDU_v_yyvstop+3,
PDU_v_yycrank+0,	0,		PDU_v_yyvstop+5,
PDU_v_yycrank+81,	0,		PDU_v_yyvstop+7,
PDU_v_yycrank+0,	0,		PDU_v_yyvstop+9,
PDU_v_yycrank+0,	PDU_v_yysvec+12,	PDU_v_yyvstop+11,
PDU_v_yycrank+0,	0,		PDU_v_yyvstop+13,
PDU_v_yycrank+13,	PDU_v_yysvec+12,	PDU_v_yyvstop+15,
PDU_v_yycrank+31,	0,		PDU_v_yyvstop+17,
PDU_v_yycrank+0,	0,		PDU_v_yyvstop+19,
PDU_v_yycrank+33,	0,		PDU_v_yyvstop+21,
PDU_v_yycrank+230,	0,		PDU_v_yyvstop+23,
PDU_v_yycrank+76,	PDU_v_yysvec+20,	PDU_v_yyvstop+25,
PDU_v_yycrank+61,	PDU_v_yysvec+20,	PDU_v_yyvstop+27,
PDU_v_yycrank+63,	PDU_v_yysvec+20,	PDU_v_yyvstop+29,
PDU_v_yycrank+275,	PDU_v_yysvec+20,	PDU_v_yyvstop+31,
PDU_v_yycrank+64,	PDU_v_yysvec+20,	PDU_v_yyvstop+33,
PDU_v_yycrank+281,	PDU_v_yysvec+20,	PDU_v_yyvstop+35,
PDU_v_yycrank+277,	PDU_v_yysvec+20,	PDU_v_yyvstop+37,
PDU_v_yycrank+283,	PDU_v_yysvec+20,	PDU_v_yyvstop+39,
PDU_v_yycrank+294,	PDU_v_yysvec+20,	PDU_v_yyvstop+41,
PDU_v_yycrank+295,	PDU_v_yysvec+20,	PDU_v_yyvstop+43,
PDU_v_yycrank+297,	PDU_v_yysvec+20,	PDU_v_yyvstop+45,
PDU_v_yycrank+0,	0,		PDU_v_yyvstop+47,
PDU_v_yycrank+48,	PDU_v_yysvec+20,	PDU_v_yyvstop+50,
PDU_v_yycrank+301,	PDU_v_yysvec+20,	PDU_v_yyvstop+52,
PDU_v_yycrank+0,	0,		PDU_v_yyvstop+54,
PDU_v_yycrank+62,	PDU_v_yysvec+20,	PDU_v_yyvstop+57,
PDU_v_yycrank+0,	0,		PDU_v_yyvstop+59,
PDU_v_yycrank+0,	0,		PDU_v_yyvstop+61,
PDU_v_yycrank+369,	0,		0,	
PDU_v_yycrank+0,	0,		PDU_v_yyvstop+63,
PDU_v_yycrank+0,	0,		PDU_v_yyvstop+65,
PDU_v_yycrank+0,	0,		PDU_v_yyvstop+67,
PDU_v_yycrank+362,	0,		0,	
PDU_v_yycrank+417,	PDU_v_yysvec+20,	PDU_v_yyvstop+69,
PDU_v_yycrank+78,	PDU_v_yysvec+20,	PDU_v_yyvstop+71,
PDU_v_yycrank+298,	PDU_v_yysvec+20,	PDU_v_yyvstop+74,
PDU_v_yycrank+418,	PDU_v_yysvec+20,	PDU_v_yyvstop+76,
PDU_v_yycrank+134,	PDU_v_yysvec+20,	PDU_v_yyvstop+78,
PDU_v_yycrank+211,	PDU_v_yysvec+20,	PDU_v_yyvstop+80,
PDU_v_yycrank+408,	PDU_v_yysvec+20,	PDU_v_yyvstop+83,
PDU_v_yycrank+414,	PDU_v_yysvec+20,	PDU_v_yyvstop+86,
PDU_v_yycrank+410,	PDU_v_yysvec+20,	PDU_v_yyvstop+88,
PDU_v_yycrank+426,	PDU_v_yysvec+20,	PDU_v_yyvstop+90,
PDU_v_yycrank+420,	PDU_v_yysvec+20,	PDU_v_yyvstop+92,
PDU_v_yycrank+429,	PDU_v_yysvec+20,	PDU_v_yyvstop+95,
PDU_v_yycrank+430,	PDU_v_yysvec+20,	PDU_v_yyvstop+97,
PDU_v_yycrank+469,	PDU_v_yysvec+20,	PDU_v_yyvstop+99,
PDU_v_yycrank+475,	PDU_v_yysvec+20,	PDU_v_yyvstop+101,
PDU_v_yycrank+468,	PDU_v_yysvec+20,	PDU_v_yyvstop+103,
PDU_v_yycrank+481,	PDU_v_yysvec+20,	PDU_v_yyvstop+107,
PDU_v_yycrank+0,	PDU_v_yysvec+39,	PDU_v_yyvstop+109,
PDU_v_yycrank+549,	PDU_v_yysvec+43,	PDU_v_yyvstop+111,
PDU_v_yycrank+472,	PDU_v_yysvec+20,	PDU_v_yyvstop+113,
PDU_v_yycrank+530,	PDU_v_yysvec+20,	PDU_v_yyvstop+116,
PDU_v_yycrank+542,	PDU_v_yysvec+20,	PDU_v_yyvstop+118,
PDU_v_yycrank+479,	PDU_v_yysvec+20,	PDU_v_yyvstop+120,
PDU_v_yycrank+540,	PDU_v_yysvec+20,	PDU_v_yyvstop+122,
PDU_v_yycrank+532,	PDU_v_yysvec+20,	PDU_v_yyvstop+124,
PDU_v_yycrank+538,	PDU_v_yysvec+20,	PDU_v_yyvstop+127,
PDU_v_yycrank+550,	PDU_v_yysvec+20,	PDU_v_yyvstop+129,
PDU_v_yycrank+544,	PDU_v_yysvec+20,	PDU_v_yyvstop+131,
PDU_v_yycrank+552,	PDU_v_yysvec+20,	PDU_v_yyvstop+133,
PDU_v_yycrank+546,	PDU_v_yysvec+20,	PDU_v_yyvstop+135,
PDU_v_yycrank+554,	PDU_v_yysvec+20,	PDU_v_yyvstop+139,
PDU_v_yycrank+599,	PDU_v_yysvec+20,	PDU_v_yyvstop+143,
PDU_v_yycrank+592,	PDU_v_yysvec+20,	PDU_v_yyvstop+145,
PDU_v_yycrank+595,	PDU_v_yysvec+20,	PDU_v_yyvstop+147,
PDU_v_yycrank+596,	PDU_v_yysvec+20,	PDU_v_yyvstop+150,
PDU_v_yycrank+602,	PDU_v_yysvec+20,	PDU_v_yyvstop+153,
PDU_v_yycrank+605,	PDU_v_yysvec+20,	PDU_v_yyvstop+156,
PDU_v_yycrank+603,	PDU_v_yysvec+20,	PDU_v_yyvstop+158,
PDU_v_yycrank+615,	PDU_v_yysvec+20,	PDU_v_yyvstop+161,
PDU_v_yycrank+618,	PDU_v_yysvec+20,	PDU_v_yyvstop+163,
PDU_v_yycrank+653,	PDU_v_yysvec+20,	PDU_v_yyvstop+165,
PDU_v_yycrank+611,	PDU_v_yysvec+20,	PDU_v_yyvstop+167,
PDU_v_yycrank+614,	PDU_v_yysvec+20,	PDU_v_yyvstop+169,
PDU_v_yycrank+654,	PDU_v_yysvec+20,	PDU_v_yyvstop+172,
PDU_v_yycrank+656,	PDU_v_yysvec+20,	PDU_v_yyvstop+174,
PDU_v_yycrank+657,	PDU_v_yysvec+20,	PDU_v_yyvstop+177,
PDU_v_yycrank+660,	PDU_v_yysvec+20,	PDU_v_yyvstop+180,
0,	0,	0};
struct PDU_v_yywork *PDU_v_yytop = PDU_v_yycrank+775;
struct PDU_v_yysvf *PDU_v_yybgin = PDU_v_yysvec+1;
char PDU_v_yymatch[] = {
00  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
040 ,01  ,01  ,01  ,040 ,040 ,01  ,01  ,
01  ,01  ,01  ,'+' ,01  ,'-' ,040 ,040 ,
'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,
'0' ,'0' ,040 ,01  ,01  ,01  ,01  ,01  ,
01  ,'A' ,'B' ,'C' ,'D' ,'E' ,'F' ,'G' ,
'H' ,'I' ,'G' ,'K' ,'L' ,'M' ,'N' ,'O' ,
'G' ,'G' ,'R' ,'S' ,'T' ,'U' ,'V' ,'W' ,
'G' ,'G' ,'G' ,01  ,01  ,01  ,01  ,'_' ,
01  ,'A' ,'B' ,'C' ,'D' ,'E' ,'F' ,'G' ,
'H' ,'I' ,'G' ,'K' ,'L' ,'M' ,'N' ,'O' ,
'G' ,'G' ,'R' ,'S' ,'T' ,'U' ,'V' ,'W' ,
'G' ,'G' ,'G' ,01  ,01  ,01  ,01  ,01  ,
0};
char PDU_v_yyextra[] = {
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0};
#ident	"@(#)libl:lib/ncform	1.3	1.2 (Intergraph) 3/10/88"
int PDU_v_yylineno =1;
# define YYU(x) x
# define NLSTATE PDU_v_yyprevious=YYNEWLINE
char PDU_v_yytext[YYLMAX];
struct PDU_v_yysvf *PDU_v_yylstate [YYLMAX], **PDU_v_yylsp, **PDU_v_yyolsp;
char PDU_v_yysbuf[YYLMAX];
char *PDU_v_yysptr = PDU_v_yysbuf;
int *PDU_v_yyfnd;
extern struct PDU_v_yysvf *PDU_v_yyestate;
int PDU_v_yyprevious = YYNEWLINE;
PDU_v_yylook(){
	register struct PDU_v_yysvf *PDU_v_yystate, **lsp;
	register struct PDU_v_yywork *PDU_v_yyt;
	struct PDU_v_yysvf *PDU_v_yyz;
	int PDU_v_yych, PDU_v_yyfirst;
	struct PDU_v_yywork *PDU_v_yyr;
# ifdef LEXDEBUG
	int debug;
# endif
	char *PDU_v_yylastch;
	/* start off machines */
# ifdef LEXDEBUG
	debug = 0;
# endif
	PDU_v_yyfirst=1;
	if (!PDU_v_yymorfg)
		PDU_v_yylastch = PDU_v_yytext;
	else {
		PDU_v_yymorfg=0;
		PDU_v_yylastch = PDU_v_yytext+PDU_v_yyleng;
		}
	for(;;){
		lsp = PDU_v_yylstate;
		PDU_v_yyestate = PDU_v_yystate = PDU_v_yybgin;
		if (PDU_v_yyprevious==YYNEWLINE) PDU_v_yystate++;
		for (;;){
# ifdef LEXDEBUG
			if(debug)fprintf(PDU_v_yyout,"state %d\n",PDU_v_yystate-PDU_v_yysvec-1);
# endif
			PDU_v_yyt = PDU_v_yystate->PDU_v_yystoff;
			if(PDU_v_yyt == PDU_v_yycrank && !PDU_v_yyfirst){  /* may not be any transitions */
				PDU_v_yyz = PDU_v_yystate->PDU_v_yyother;
				if(PDU_v_yyz == 0)break;
				if(PDU_v_yyz->PDU_v_yystoff == PDU_v_yycrank)break;
				}
			*PDU_v_yylastch++ = PDU_v_yych = input();
			PDU_v_yyfirst=0;
		tryagain:
# ifdef LEXDEBUG
			if(debug){
				fprintf(PDU_v_yyout,"char ");
				allprint(PDU_v_yych);
				putchar('\n');
				}
# endif
			PDU_v_yyr = PDU_v_yyt;
			if ( (int)PDU_v_yyt > (int)PDU_v_yycrank){
				PDU_v_yyt = PDU_v_yyr + PDU_v_yych;
				if (PDU_v_yyt <= PDU_v_yytop && PDU_v_yyt->verify+PDU_v_yysvec == PDU_v_yystate){
					if(PDU_v_yyt->advance+PDU_v_yysvec == YYLERR)	/* error transitions */
						{unput(*--PDU_v_yylastch);break;}
					*lsp++ = PDU_v_yystate = PDU_v_yyt->advance+PDU_v_yysvec;
					goto contin;
					}
				}
# ifdef YYOPTIM
			else if((int)PDU_v_yyt < (int)PDU_v_yycrank) {		/* r < PDU_v_yycrank */
				PDU_v_yyt = PDU_v_yyr = PDU_v_yycrank+(PDU_v_yycrank-PDU_v_yyt);
# ifdef LEXDEBUG
				if(debug)fprintf(PDU_v_yyout,"compressed state\n");
# endif
				PDU_v_yyt = PDU_v_yyt + PDU_v_yych;
				if(PDU_v_yyt <= PDU_v_yytop && PDU_v_yyt->verify+PDU_v_yysvec == PDU_v_yystate){
					if(PDU_v_yyt->advance+PDU_v_yysvec == YYLERR)	/* error transitions */
						{unput(*--PDU_v_yylastch);break;}
					*lsp++ = PDU_v_yystate = PDU_v_yyt->advance+PDU_v_yysvec;
					goto contin;
					}
				PDU_v_yyt = PDU_v_yyr + YYU(PDU_v_yymatch[PDU_v_yych]);
# ifdef LEXDEBUG
				if(debug){
					fprintf(PDU_v_yyout,"try fall back character ");
					allprint(YYU(PDU_v_yymatch[PDU_v_yych]));
					putchar('\n');
					}
# endif
				if(PDU_v_yyt <= PDU_v_yytop && PDU_v_yyt->verify+PDU_v_yysvec == PDU_v_yystate){
					if(PDU_v_yyt->advance+PDU_v_yysvec == YYLERR)	/* error transition */
						{unput(*--PDU_v_yylastch);break;}
					*lsp++ = PDU_v_yystate = PDU_v_yyt->advance+PDU_v_yysvec;
					goto contin;
					}
				}
			if ((PDU_v_yystate = PDU_v_yystate->PDU_v_yyother) && (PDU_v_yyt= PDU_v_yystate->PDU_v_yystoff) != PDU_v_yycrank){
# ifdef LEXDEBUG
				if(debug)fprintf(PDU_v_yyout,"fall back to state %d\n",PDU_v_yystate-PDU_v_yysvec-1);
# endif
				goto tryagain;
				}
# endif
			else
				{unput(*--PDU_v_yylastch);break;}
		contin:
# ifdef LEXDEBUG
			if(debug){
				fprintf(PDU_v_yyout,"state %d char ",PDU_v_yystate-PDU_v_yysvec-1);
				allprint(PDU_v_yych);
				putchar('\n');
				}
# endif
			;
			}
# ifdef LEXDEBUG
		if(debug){
			fprintf(PDU_v_yyout,"stopped at %d with ",*(lsp-1)-PDU_v_yysvec-1);
			allprint(PDU_v_yych);
			putchar('\n');
			}
# endif
		while (lsp-- > PDU_v_yylstate){
			*PDU_v_yylastch-- = 0;
			if (*lsp != 0 && (PDU_v_yyfnd= (*lsp)->PDU_v_yystops) && *PDU_v_yyfnd > 0){
				PDU_v_yyolsp = lsp;
				if(PDU_v_yyextra[*PDU_v_yyfnd]){		/* must backup */
					while(PDU_v_yyback((*lsp)->PDU_v_yystops,-*PDU_v_yyfnd) != 1 && lsp > PDU_v_yylstate){
						lsp--;
						unput(*PDU_v_yylastch--);
						}
					}
				PDU_v_yyprevious = YYU(*PDU_v_yylastch);
				PDU_v_yylsp = lsp;
				PDU_v_yyleng = PDU_v_yylastch-PDU_v_yytext+1;
				PDU_v_yytext[PDU_v_yyleng] = 0;
# ifdef LEXDEBUG
				if(debug){
					fprintf(PDU_v_yyout,"\nmatch ");
					sprint(PDU_v_yytext);
					fprintf(PDU_v_yyout," action %d\n",*PDU_v_yyfnd);
					}
# endif
				return(*PDU_v_yyfnd++);
				}
			unput(*PDU_v_yylastch);
			}
		/* you may or may not be reading from PDU_v_yyin - we really   */
		/* can't tell at this point. So whenver PDU_v_yytext[0] is set */
		/* to 0, this indicates end of file			 */
		if (PDU_v_yytext[0] == 0 /* && feof(PDU_v_yyin) */ )
			{
			PDU_v_yysptr=PDU_v_yysbuf;
			return(0);
			}
		PDU_v_yyprevious = PDU_v_yytext[0] = input();
		if (PDU_v_yyprevious>0)
			output(PDU_v_yyprevious);
		PDU_v_yylastch=PDU_v_yytext;
# ifdef LEXDEBUG
		if(debug)putchar('\n');
# endif
		}
	}
PDU_v_yyback(p, m)
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
PDU_v_yyinput(){
	return(input());
	}
PDU_v_yyoutput(c)
  int c; {
	output(c);
	}
PDU_v_yyunput(c)
   int c; {
	unput(c);
	}
