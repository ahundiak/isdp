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
# define OUTERPAR 2
# define INNERPAR 4
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
fprintf(yyout,"bad switch yylook %d",nstr);
} return(0); }
/* end of yylex */

yywrap ()
{
	printf ("%s\n", yytext);
	return (1);
}
int yyvstop[] = {
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
struct yywork { YYTYPE verify, advance; } yycrank[] = {
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
struct yysvf yysvec[] = {
0,	0,	0,
yycrank+1,	0,		0,	
yycrank+0,	yysvec+1,	0,	
yycrank+84,	yysvec+1,	0,	
yycrank+85,	yysvec+1,	0,	
yycrank+86,	yysvec+1,	0,	
yycrank+87,	yysvec+1,	0,	
yycrank+3,	0,		0,	
yycrank+153,	0,		0,	
yycrank+0,	0,		yyvstop+1,
yycrank+0,	0,		yyvstop+3,
yycrank+0,	0,		yyvstop+5,
yycrank+81,	0,		yyvstop+7,
yycrank+0,	0,		yyvstop+9,
yycrank+0,	yysvec+12,	yyvstop+11,
yycrank+0,	0,		yyvstop+13,
yycrank+13,	yysvec+12,	yyvstop+15,
yycrank+31,	0,		yyvstop+17,
yycrank+0,	0,		yyvstop+19,
yycrank+33,	0,		yyvstop+21,
yycrank+230,	0,		yyvstop+23,
yycrank+76,	yysvec+20,	yyvstop+25,
yycrank+61,	yysvec+20,	yyvstop+27,
yycrank+63,	yysvec+20,	yyvstop+29,
yycrank+275,	yysvec+20,	yyvstop+31,
yycrank+64,	yysvec+20,	yyvstop+33,
yycrank+281,	yysvec+20,	yyvstop+35,
yycrank+277,	yysvec+20,	yyvstop+37,
yycrank+283,	yysvec+20,	yyvstop+39,
yycrank+294,	yysvec+20,	yyvstop+41,
yycrank+295,	yysvec+20,	yyvstop+43,
yycrank+297,	yysvec+20,	yyvstop+45,
yycrank+0,	0,		yyvstop+47,
yycrank+48,	yysvec+20,	yyvstop+50,
yycrank+301,	yysvec+20,	yyvstop+52,
yycrank+0,	0,		yyvstop+54,
yycrank+62,	yysvec+20,	yyvstop+57,
yycrank+0,	0,		yyvstop+59,
yycrank+0,	0,		yyvstop+61,
yycrank+369,	0,		0,	
yycrank+0,	0,		yyvstop+63,
yycrank+0,	0,		yyvstop+65,
yycrank+0,	0,		yyvstop+67,
yycrank+362,	0,		0,	
yycrank+417,	yysvec+20,	yyvstop+69,
yycrank+78,	yysvec+20,	yyvstop+71,
yycrank+298,	yysvec+20,	yyvstop+74,
yycrank+418,	yysvec+20,	yyvstop+76,
yycrank+134,	yysvec+20,	yyvstop+78,
yycrank+211,	yysvec+20,	yyvstop+80,
yycrank+408,	yysvec+20,	yyvstop+83,
yycrank+414,	yysvec+20,	yyvstop+86,
yycrank+410,	yysvec+20,	yyvstop+88,
yycrank+426,	yysvec+20,	yyvstop+90,
yycrank+420,	yysvec+20,	yyvstop+92,
yycrank+429,	yysvec+20,	yyvstop+95,
yycrank+430,	yysvec+20,	yyvstop+97,
yycrank+469,	yysvec+20,	yyvstop+99,
yycrank+475,	yysvec+20,	yyvstop+101,
yycrank+468,	yysvec+20,	yyvstop+103,
yycrank+481,	yysvec+20,	yyvstop+107,
yycrank+0,	yysvec+39,	yyvstop+109,
yycrank+549,	yysvec+43,	yyvstop+111,
yycrank+472,	yysvec+20,	yyvstop+113,
yycrank+530,	yysvec+20,	yyvstop+116,
yycrank+542,	yysvec+20,	yyvstop+118,
yycrank+479,	yysvec+20,	yyvstop+120,
yycrank+540,	yysvec+20,	yyvstop+122,
yycrank+532,	yysvec+20,	yyvstop+124,
yycrank+538,	yysvec+20,	yyvstop+127,
yycrank+550,	yysvec+20,	yyvstop+129,
yycrank+544,	yysvec+20,	yyvstop+131,
yycrank+552,	yysvec+20,	yyvstop+133,
yycrank+546,	yysvec+20,	yyvstop+135,
yycrank+554,	yysvec+20,	yyvstop+139,
yycrank+599,	yysvec+20,	yyvstop+143,
yycrank+592,	yysvec+20,	yyvstop+145,
yycrank+595,	yysvec+20,	yyvstop+147,
yycrank+596,	yysvec+20,	yyvstop+150,
yycrank+602,	yysvec+20,	yyvstop+153,
yycrank+605,	yysvec+20,	yyvstop+156,
yycrank+603,	yysvec+20,	yyvstop+158,
yycrank+615,	yysvec+20,	yyvstop+161,
yycrank+618,	yysvec+20,	yyvstop+163,
yycrank+653,	yysvec+20,	yyvstop+165,
yycrank+611,	yysvec+20,	yyvstop+167,
yycrank+614,	yysvec+20,	yyvstop+169,
yycrank+654,	yysvec+20,	yyvstop+172,
yycrank+656,	yysvec+20,	yyvstop+174,
yycrank+657,	yysvec+20,	yyvstop+177,
yycrank+660,	yysvec+20,	yyvstop+180,
0,	0,	0};
struct yywork *yytop = yycrank+775;
struct yysvf *yybgin = yysvec+1;
char yymatch[] = {
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
char yyextra[] = {
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
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
