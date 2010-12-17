#include <stdio.h>
#include <string.h>
#include <ctype.h>
#define	DEBUG 0
#define TRUE	1
#define	FALSE	0
	extern	char	yytext[];
	extern  char	ViewTable[MAX_SVS_PARAMS][MAX_SVS_COND][MAX_SVS_COND_LEN];
	extern	int	NoParams, NoRows, i, j, NoTables;
	extern	char	ViewParamList[MAX_SVS_PARAMS][SVS_NAME_LEN], TableColList[MAX_SVS_PARAMS][SVS_NAME_LEN*2];

	static	int	i, j, row = 0, col = 0, no_table_cols, no_view_cols;
 	static	char	SVStemp[32], arith_oper[4], expression[132], smpl_cnd[132];
 	static	short	table_cols;
	static	int	startRHS, tndx;
	static	char	LHScol[66], RHScol[66], *tbl1, *col1, *tbl2, *col2;
	static	char	tstr[512];
# define _create 257
# define _view 258
# define _view_table_name 259
# define _as 260
# define _select 261
# define _column_name 262
# define _from 263
# define _where 264
# define _inside_and 265
# define _inside_inside_and 266
# define _greater 267
# define _greater_equal 268
# define _less 269
# define _less_equal 270
# define _equal 271
# define _un_equal 272
# define _not_equal 273
# define _not 274
# define _between 275
# define _in 276
# define _like 277
# define _multiply 278
# define _divide 279
# define _add 280
# define _subtract 281
# define _open 282
# define _close 283
# define _inside_open 284
# define _inside_close 285
# define _is 286
# define _null 287
# define _string 288
# define _int_value 289
# define _real_value 290
# define _comma 291
# define _outside_or 292
# define _inside_or 293
# define _outside_and 294
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern int yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
#ifndef YYSTYPE
#define YYSTYPE int
#endif
YYSTYPE yylval, yyval;
typedef int yytabelem;
# define YYERRCODE 256

yyerror(str)
char	*str;
{
	fprintf (stderr, "Error -> %s\n", str);
	return (-2);
} 

ToLower (char *string)
{
	int	lenstr, chcnt;

	lenstr = strlen (string);
	for (chcnt = 0; chcnt < lenstr; chcnt++)
		string[chcnt] = (char) tolower ( (int) string[chcnt] );
}

PrintResult ()
{
if (DEBUG)	{
			printf ("******Successful******\n");
			printf ("No of rows = %d\n", row);
			printf ("No of table cols = %d\n", no_table_cols);
			printf ("No of view cols = %d\n", NoParams);
			for (i = 0; i <= no_table_cols; i++)
				printf ("%d) %s\n", i, TableColList[i]);

			for (i = 0; i <= NoParams; i++)
				printf ("%d) %s\n", i, ViewParamList[i]);

			for (i = 0; i <= row; i++) {
				for (j = 0; j < no_table_cols + 1; j++)
					printf ("%s - ", ViewTable[i][j]);
				printf ("\n");
			}
			printf ("\n\nFinished Printing\n");
		}
}
yytabelem yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
-1, 69,
	277, 56,
	-2, 47,
-1, 71,
	287, 54,
	-2, 51,
-1, 87,
	0, 70,
	265, 70,
	266, 70,
	283, 70,
	285, 70,
	292, 70,
	293, 70,
	294, 70,
	-2, 69,
	};
# define YYNPROD 92
# define YYLAST 241
yytabelem yyact[]={

    60,    75,    76,    77,    78,    73,    79,    74,    69,    68,
    70,    72,    53,   100,    63,    53,   138,    25,    53,   129,
    71,    39,   134,    63,    56,    54,    55,    58,    61,    59,
   133,    20,    43,   110,    47,   126,   134,    47,    56,    54,
    55,    56,    54,    55,    56,    54,    55,    10,    38,   115,
   113,   111,    66,     6,   125,    11,   108,   107,    22,    23,
    29,    30,    27,    28,   106,    89,   109,    66,    15,    31,
   124,    84,    75,    76,    77,    78,   103,    79,   102,   117,
    14,    75,    76,    77,    78,   103,    79,   102,    75,    76,
    77,    78,   103,    79,   102,    40,    35,    13,     9,     5,
     4,     3,    52,    51,    50,   127,    49,    44,    42,    46,
   101,    45,    48,    64,    19,    18,   137,    99,    97,    98,
    96,    95,   120,    91,    94,   122,    93,   132,   119,    90,
   121,    92,   131,   105,   123,    88,    62,    21,    33,    26,
    41,    32,    37,    34,    24,    17,    16,    12,    36,     8,
     7,     2,     1,     0,     0,    57,     0,     0,     0,     0,
    65,    67,     0,     0,     0,     0,    80,     0,     0,     0,
    81,    87,    86,    85,    83,    82,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,   104,     0,     0,     0,     0,     0,     0,
     0,   112,     0,   114,     0,   116,     0,     0,     0,     0,
   118,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,   128,     0,     0,     0,   130,     0,
     0,     0,     0,     0,     0,   128,   135,     0,   136,     0,
   139 };
yytabelem yypact[]={

 -1000, -1000,  -156,  -158,  -160,  -229, -1000,  -161,  -236, -1000,
 -1000,  -162,  -180, -1000,  -193, -1000,  -231,  -274,  -218, -1000,
 -1000, -1000, -1000, -1000,  -194,  -231, -1000, -1000, -1000, -1000,
 -1000,  -163,  -218,  -231,  -243, -1000, -1000, -1000,  -164,  -250,
 -1000,  -265, -1000, -1000,  -279,  -265, -1000,  -244,  -199, -1000,
  -266, -1000, -1000, -1000, -1000, -1000, -1000,  -250, -1000, -1000,
 -1000, -1000,  -247,  -247,  -247,  -214,  -244,  -244, -1000,  -210,
 -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000,
 -1000,  -270,  -265, -1000, -1000, -1000,  -179, -1000,  -244, -1000,
  -212,  -220,  -228,  -208,  -254,  -237,  -244,  -238,  -244,  -239,
 -1000,  -244, -1000, -1000,  -186,  -244, -1000, -1000, -1000, -1000,
 -1000, -1000,  -179, -1000,  -179, -1000, -1000, -1000,  -195,  -230,
  -253,  -264,  -268,  -244, -1000, -1000, -1000,  -255, -1000, -1000,
  -179,  -244,  -264, -1000, -1000,  -179,  -269,  -264, -1000, -1000 };
yytabelem yypgo[]={

     0,   152,   151,   150,   149,   147,   146,   145,   144,   143,
   142,   140,   115,   139,   138,   114,   137,   113,   108,   136,
   107,   111,   109,   112,   106,   104,   110,   135,   134,   133,
   132,   131,   130,   105,   129,   128,   127,   126,   125,   124,
   123,   122,   121,   120,   119,   118,   117,   103,   102,   116 };
yytabelem yyr1[]={

     0,     2,     3,     5,     6,     8,     1,    10,    10,     4,
     4,     7,     7,    14,    12,    12,    15,    15,    16,    16,
    13,    13,    13,    13,    11,    11,    19,    18,    18,    20,
    20,    21,    21,    22,    22,    23,    23,    24,    27,    28,
    24,    29,    30,    24,    31,    32,    24,    34,    35,    36,
    24,    37,    38,    24,    39,    24,    40,    41,    24,    42,
    24,    43,    24,    44,    24,    45,    24,    46,    24,    25,
    25,    47,    47,    17,    17,    17,    17,    26,    26,    26,
    26,    26,    26,    26,    49,    33,    33,    48,    48,    48,
     9,     9 };
yytabelem yyr2[]={

     0,     1,     1,     1,     1,     1,    34,     5,     0,     7,
     3,     7,     3,     1,     8,     2,     3,     2,     3,     3,
     3,     3,     3,     3,     6,     2,     1,     8,     2,     6,
     2,     6,     3,     6,     2,     6,     2,     6,     1,     1,
    14,     1,     1,    16,     1,     1,    15,     1,     1,     1,
    19,     1,     1,    13,     1,     9,     1,     1,    13,     1,
     9,     1,     9,     1,     8,     1,     9,     1,     9,     6,
     3,     2,     3,     3,     3,     3,     3,     3,     3,     3,
     3,     3,     3,     3,     1,     8,     3,     3,     3,     3,
     7,     3 };
yytabelem yychk[]={

 -1000,    -1,    -2,   257,   258,   259,   282,    -3,    -4,   259,
   283,   291,    -5,   259,   260,   261,    -6,    -7,   -12,   -15,
   262,   -16,   289,   290,    -8,   291,   -13,   280,   281,   278,
   279,   263,   -12,   -14,    -9,   259,   -15,   -10,   291,   264,
   259,   -11,   -18,   282,   -20,   -21,   -22,   284,   -23,   -24,
   -25,   -47,   -48,   262,   289,   290,   288,   -17,   292,   294,
   265,   293,   -19,   293,   -17,   -23,   266,   -26,   275,   274,
   276,   286,   277,   271,   273,   267,   268,   269,   270,   272,
   -18,   -20,   -21,   -22,   285,   -24,   -25,   -47,   -27,   275,
   -34,   -40,   -31,   -37,   -39,   -42,   -43,   -45,   -44,   -46,
   283,   -26,   273,   271,   -25,   -29,   276,   277,   284,   274,
   287,   288,   -25,   288,   -25,   288,   -47,   265,   -25,   -35,
   -41,   -32,   -38,   -28,   265,   284,   288,   -33,   -48,   287,
   -25,   -30,   -36,   285,   291,   -25,   -33,   -49,   285,   -48 };
yytabelem yydef[]={

     1,    -2,     0,     0,     0,     0,     2,     0,     0,    10,
     3,     0,     0,     9,     0,     4,     0,     5,    12,    15,
    16,    17,    18,    19,     0,     0,    13,    20,    21,    22,
    23,     0,    11,     0,     8,    91,    14,     6,     0,     0,
    90,     7,    25,    26,    28,    30,    32,     0,    34,    36,
     0,    70,    71,    72,    87,    88,    89,     0,    73,    74,
    75,    76,     0,     0,     0,     0,     0,     0,    38,    -2,
    44,    -2,    59,    61,    63,    77,    78,    79,    80,    81,
    24,     0,    29,    31,    33,    35,    37,    -2,     0,    41,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
    27,     0,    82,    83,     0,     0,    48,    57,    45,    52,
    55,    60,    62,    66,    64,    68,    69,    39,     0,     0,
     0,     0,     0,     0,    42,    49,    58,     0,    86,    53,
    40,     0,     0,    46,    84,    43,     0,     0,    50,    85 };
typedef struct { char *t_name; int t_val; } yytoktype;
#ifndef YYDEBUG
#	define YYDEBUG	1	/* allow debugging */
#endif

#if YYDEBUG

yytoktype yytoks[] =
{
	"_create",	257,
	"_view",	258,
	"_view_table_name",	259,
	"_as",	260,
	"_select",	261,
	"_column_name",	262,
	"_from",	263,
	"_where",	264,
	"_inside_and",	265,
	"_inside_inside_and",	266,
	"_greater",	267,
	"_greater_equal",	268,
	"_less",	269,
	"_less_equal",	270,
	"_equal",	271,
	"_un_equal",	272,
	"_not_equal",	273,
	"_not",	274,
	"_between",	275,
	"_in",	276,
	"_like",	277,
	"_multiply",	278,
	"_divide",	279,
	"_add",	280,
	"_subtract",	281,
	"_open",	282,
	"_close",	283,
	"_inside_open",	284,
	"_inside_close",	285,
	"_is",	286,
	"_null",	287,
	"_string",	288,
	"_int_value",	289,
	"_real_value",	290,
	"_comma",	291,
	"_outside_or",	292,
	"_inside_or",	293,
	"_outside_and",	294,
	"-unknown-",	-1	/* ends search */
};

char * yyreds[] =
{
	"-no such reduction-",
	"view_definition : /* empty */",
	"view_definition : _create _view _view_table_name _open",
	"view_definition : _create _view _view_table_name _open view_col_list _close",
	"view_definition : _create _view _view_table_name _open view_col_list _close _as _select",
	"view_definition : _create _view _view_table_name _open view_col_list _close _as _select table_col_list",
	"view_definition : _create _view _view_table_name _open view_col_list _close _as _select table_col_list _from table_name_list where_part",
	"where_part : _where where_clause",
	"where_part : /* empty */",
	"view_col_list : view_col_list _comma _view_table_name",
	"view_col_list : _view_table_name",
	"table_col_list : table_col_list _comma table_cols",
	"table_col_list : table_cols",
	"table_cols : table_cols arith_oper",
	"table_cols : table_cols arith_oper column_or_value",
	"table_cols : column_or_value",
	"column_or_value : _column_name",
	"column_or_value : values",
	"values : _int_value",
	"values : _real_value",
	"arith_oper : _add",
	"arith_oper : _subtract",
	"arith_oper : _multiply",
	"arith_oper : _divide",
	"where_clause : where_clause conj selection_criteria",
	"where_clause : selection_criteria",
	"selection_criteria : _open",
	"selection_criteria : _open select_lines _close",
	"selection_criteria : select_lines",
	"select_lines : select_lines _inside_or line",
	"select_lines : line",
	"line : line conj thecondition",
	"line : thecondition",
	"thecondition : _inside_open multicondition _inside_close",
	"thecondition : multicondition",
	"multicondition : multicondition _inside_inside_and condition",
	"multicondition : condition",
	"condition : expression oper expression",
	"condition : expression _between",
	"condition : expression _between expression _inside_and",
	"condition : expression _between expression _inside_and expression",
	"condition : expression _not _between",
	"condition : expression _not _between expression _inside_and",
	"condition : expression _not _between expression _inside_and expression",
	"condition : expression _in",
	"condition : expression _in _inside_open",
	"condition : expression _in _inside_open value_list _inside_close",
	"condition : expression _not",
	"condition : expression _not _in",
	"condition : expression _not _in _inside_open",
	"condition : expression _not _in _inside_open value_list _inside_close",
	"condition : expression _is",
	"condition : expression _is _not",
	"condition : expression _is _not _null",
	"condition : expression _is",
	"condition : expression _is _null",
	"condition : expression _not",
	"condition : expression _not _like",
	"condition : expression _not _like _string",
	"condition : expression _like",
	"condition : expression _like _string",
	"condition : expression _equal",
	"condition : expression _equal expression",
	"condition : expression _not_equal",
	"condition : expression _not_equal expression",
	"condition : expression _equal",
	"condition : expression _equal _string",
	"condition : expression _not_equal",
	"condition : expression _not_equal _string",
	"expression : expression oper operand",
	"expression : operand",
	"operand : value",
	"operand : _column_name",
	"conj : _outside_or",
	"conj : _outside_and",
	"conj : _inside_and",
	"conj : _inside_or",
	"oper : _greater",
	"oper : _greater_equal",
	"oper : _less",
	"oper : _less_equal",
	"oper : _un_equal",
	"oper : _not_equal",
	"oper : _equal",
	"value_list : value_list _comma",
	"value_list : value_list _comma value",
	"value_list : value",
	"value : _int_value",
	"value : _real_value",
	"value : _string",
	"table_name_list : table_name_list _comma _view_table_name",
	"table_name_list : _view_table_name",
};
#endif /* YYDEBUG */
/* #ident	"@(#)yacc:yaccpar	1.10	1.3 (Intergraph) 3/10/88" */

/*
** Skeleton parser driver for yacc output
*/

/*
** yacc user known macros and defines
*/
#define YYERROR		goto yyerrlab
#define YYACCEPT	return(0)
#define YYABORT		return(1)
#define YYBACKUP( newtoken, newvalue )\
{\
	if ( yychar >= 0 || ( yyr2[ yytmp ] >> 1 ) != 1 )\
	{\
		yyerror( "syntax error - cannot backup" );\
		goto yyerrlab;\
	}\
	yychar = newtoken;\
	yystate = *yyps;\
	yylval = newvalue;\
	goto yynewstate;\
}
#define YYRECOVERING()	(!!yyerrflag)
#ifndef YYDEBUG
#	define YYDEBUG	1	/* make debugging available */
#endif

/*
** user known globals
*/
int yydebug;			/* set to 1 to get debugging */

/*
** driver internal defines
*/
#define YYFLAG		(-1000)

/*
** global variables used by the parser
*/
YYSTYPE yyv[ YYMAXDEPTH ];	/* value stack */
int yys[ YYMAXDEPTH ];		/* state stack */

YYSTYPE *yypv;			/* top of value stack */
int *yyps;			/* top of state stack */

int yystate;			/* current state */
int yytmp;			/* extra var (lasts between blocks) */

int yynerrs;			/* number of errors */
int yyerrflag;			/* error recovery flag */
int yychar;			/* current input token number */



/*
** yyparse - return 0 if worked, 1 if syntax error not recovered from
*/
int
yyparse()
{
	register YYSTYPE *yypvt;	/* top of value stack for $vars */

	/*
	** Initialize externals - yyparse may be called more than once
	*/
	yypv = &yyv[-1];
	yyps = &yys[-1];
	yystate = 0;
	yytmp = 0;
	yynerrs = 0;
	yyerrflag = 0;
	yychar = -1;

	goto yystack;
	{
		register YYSTYPE *yy_pv;	/* top of value stack */
		register int *yy_ps;		/* top of state stack */
		register int yy_state;		/* current state */
		register int  yy_n;		/* internal state number info */

		/*
		** get globals into registers.
		** branch to here only if YYBACKUP was called.
		*/
	yynewstate:
		yy_pv = yypv;
		yy_ps = yyps;
		yy_state = yystate;
		goto yy_newstate;

		/*
		** get globals into registers.
		** either we just started, or we just finished a reduction
		*/
	yystack:
		yy_pv = yypv;
		yy_ps = yyps;
		yy_state = yystate;

		/*
		** top of for (;;) loop while no reductions done
		*/
	yy_stack:
		/*
		** put a state and value onto the stacks
		*/
#if YYDEBUG
		/*
		** if debugging, look up token value in list of value vs.
		** name pairs.  0 and negative (-1) are special values.
		** Note: linear search is used since time is not a real
		** consideration while debugging.
		*/
		if ( yydebug )
		{
			register int yy_i;

			printf( "State %d, token ", yy_state );
			if ( yychar == 0 )
				printf( "end-of-file\n" );
			else if ( yychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( yy_i = 0; yytoks[yy_i].t_val >= 0;
					yy_i++ )
				{
					if ( yytoks[yy_i].t_val == yychar )
						break;
				}
				printf( "%s\n", yytoks[yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ++yy_ps >= &yys[ YYMAXDEPTH ] )	/* room on stack? */
		{
			yyerror( "yacc stack overflow" );
			YYABORT;
		}
		*yy_ps = yy_state;
		*++yy_pv = yyval;

		/*
		** we have a new state - find out what to do
		*/
	yy_newstate:
		if ( ( yy_n = yypact[ yy_state ] ) <= YYFLAG )
			goto yydefault;		/* simple state */
#if YYDEBUG
		/*
		** if debugging, need to mark whether new token grabbed
		*/
		yytmp = yychar < 0;
#endif
		if ( ( yychar < 0 ) && ( ( yychar = yylex() ) < 0 ) )
			yychar = 0;		/* reached EOF */
#if YYDEBUG
		if ( yydebug && yytmp )
		{
			register int yy_i;

			printf( "Received token " );
			if ( yychar == 0 )
				printf( "end-of-file\n" );
			else if ( yychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( yy_i = 0; yytoks[yy_i].t_val >= 0;
					yy_i++ )
				{
					if ( yytoks[yy_i].t_val == yychar )
						break;
				}
				printf( "%s\n", yytoks[yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ( ( yy_n += yychar ) < 0 ) || ( yy_n >= YYLAST ) )
			goto yydefault;
		if ( yychk[ yy_n = yyact[ yy_n ] ] == yychar )	/*valid shift*/
		{
			yychar = -1;
			yyval = yylval;
			yy_state = yy_n;
			if ( yyerrflag > 0 )
				yyerrflag--;
			goto yy_stack;
		}

	yydefault:
		if ( ( yy_n = yydef[ yy_state ] ) == -2 )
		{
#if YYDEBUG
			yytmp = yychar < 0;
#endif
			if ( ( yychar < 0 ) && ( ( yychar = yylex() ) < 0 ) )
				yychar = 0;		/* reached EOF */
#if YYDEBUG
			if ( yydebug && yytmp )
			{
				register int yy_i;

				printf( "Received token " );
				if ( yychar == 0 )
					printf( "end-of-file\n" );
				else if ( yychar < 0 )
					printf( "-none-\n" );
				else
				{
					for ( yy_i = 0;
						yytoks[yy_i].t_val >= 0;
						yy_i++ )
					{
						if ( yytoks[yy_i].t_val
							== yychar )
						{
							break;
						}
					}
					printf( "%s\n", yytoks[yy_i].t_name );
				}
			}
#endif /* YYDEBUG */
			/*
			** look through exception table
			*/
			{
				register int *yyxi = yyexca;

				while ( ( *yyxi != -1 ) ||
					( yyxi[1] != yy_state ) )
				{
					yyxi += 2;
				}
				while ( ( *(yyxi += 2) >= 0 ) &&
					( *yyxi != yychar ) )
					;
				if ( ( yy_n = yyxi[1] ) < 0 )
					YYACCEPT;
			}
		}

		/*
		** check for syntax error
		*/
		if ( yy_n == 0 )	/* have an error */
		{
			/* no worry about speed here! */
			switch ( yyerrflag )
			{
			case 0:		/* new error */
				yyerror( "syntax error" );
				goto skip_init;
			yyerrlab:
				/*
				** get globals into registers.
				** we have a user generated syntax type error
				*/
				yy_pv = yypv;
				yy_ps = yyps;
				yy_state = yystate;
				yynerrs++;
			skip_init:
			case 1:
			case 2:		/* incompletely recovered error */
					/* try again... */
				yyerrflag = 3;
				/*
				** find state where "error" is a legal
				** shift action
				*/
				while ( yy_ps >= yys )
				{
					yy_n = yypact[ *yy_ps ] + YYERRCODE;
					if ( yy_n >= 0 && yy_n < YYLAST &&
						yychk[yyact[yy_n]] == YYERRCODE)					{
						/*
						** simulate shift of "error"
						*/
						yy_state = yyact[ yy_n ];
						goto yy_stack;
					}
					/*
					** current state has no shift on
					** "error", pop stack
					*/
#if YYDEBUG
#	define _POP_ "Error recovery pops state %d, uncovers state %d\n"
					if ( yydebug )
						printf( _POP_, *yy_ps,
							yy_ps[-1] );
#	undef _POP_
#endif
					yy_ps--;
					yy_pv--;
				}
				/*
				** there is no state on stack with "error" as
				** a valid shift.  give up.
				*/
				YYABORT;
			case 3:		/* no shift yet; eat a token */
#if YYDEBUG
				/*
				** if debugging, look up token in list of
				** pairs.  0 and negative shouldn't occur,
				** but since timing doesn't matter when
				** debugging, it doesn't hurt to leave the
				** tests here.
				*/
				if ( yydebug )
				{
					register int yy_i;

					printf( "Error recovery discards " );
					if ( yychar == 0 )
						printf( "token end-of-file\n" );
					else if ( yychar < 0 )
						printf( "token -none-\n" );
					else
					{
						for ( yy_i = 0;
							yytoks[yy_i].t_val >= 0;
							yy_i++ )
						{
							if ( yytoks[yy_i].t_val
								== yychar )
							{
								break;
							}
						}
						printf( "token %s\n",
							yytoks[yy_i].t_name );
					}
				}
#endif /* YYDEBUG */
				if ( yychar == 0 )	/* reached EOF. quit */
					YYABORT;
				yychar = -1;
				goto yy_newstate;
			}
		}/* end if ( yy_n == 0 ) */
		/*
		** reduction by production yy_n
		** put stack tops, etc. so things right after switch
		*/
#if YYDEBUG
		/*
		** if debugging, print the string that is the user's
		** specification of the reduction which is just about
		** to be done.
		*/
		if ( yydebug )
			printf( "Reduce by (%d) \"%s\"\n",
				yy_n, yyreds[ yy_n ] );
#endif
		yytmp = yy_n;			/* value to switch over */
		yypvt = yy_pv;			/* $vars top of value stack */
		/*
		** Look in goto table for next state
		** Sorry about using yy_state here as temporary
		** register variable, but why not, if it works...
		** If yyr2[ yy_n ] doesn't have the low order bit
		** set, then there is no action to be done for
		** this reduction.  So, no saving & unsaving of
		** registers done.  The only difference between the
		** code just after the if and the body of the if is
		** the goto yy_stack in the body.  This way the test
		** can be made before the choice of what to do is needed.
		*/
		{
			/* length of production doubled with extra bit */
			register int yy_len = yyr2[ yy_n ];

			if ( !( yy_len & 01 ) )
			{
				yy_len >>= 1;
				yyval = ( yy_pv -= yy_len )[1];	/* $$ = $1 */
				yy_state = yypgo[ yy_n = yyr1[ yy_n ] ] +
					*( yy_ps -= yy_len ) + 1;
				if ( yy_state >= YYLAST ||
					yychk[ yy_state =
					yyact[ yy_state ] ] != -yy_n )
				{
					yy_state = yyact[ yypgo[ yy_n ] ];
				}
				goto yy_stack;
			}
			yy_len >>= 1;
			yyval = ( yy_pv -= yy_len )[1];	/* $$ = $1 */
			yy_state = yypgo[ yy_n = yyr1[ yy_n ] ] +
				*( yy_ps -= yy_len ) + 1;
			if ( yy_state >= YYLAST ||
				yychk[ yy_state = yyact[ yy_state ] ] != -yy_n )
			{
				yy_state = yyact[ yypgo[ yy_n ] ];
			}
		}
					/* save until reenter driver code */
		yystate = yy_state;
		yyps = yy_ps;
		yypv = yy_pv;
	}
	/*
	** code supplied by user is placed in this switch
	*/
	switch( yytmp )
	{
		
case 1:{ 
		   row = 0;
		   NoTables = 0;
		   for (i = 0; i < MAX_SVS_PARAMS; i++)
			TableColList[i][0] = '\0';
		  } break;
case 2:{ i = 0; } break;
case 3:{ NoParams = i; } break;
case 4:{ i = 0 ; } break;
case 5:{ no_table_cols = i; } break;
case 7:{
			NoRows = row;
			PrintResult ();
		  } break;
case 9:{ 
			ToLower (yytext);
			strcpy (ViewParamList[i++], yytext); 
		  } break;
case 10:{ 
			ToLower (yytext);
			strcpy (ViewParamList[i++], yytext); 
		  } break;
case 11:{ i++; } break;
case 12:{ i++; } break;
case 13:{ strcat (TableColList[i], arith_oper); } break;
case 16:{ 
		    ToLower (yytext);
		    strcat (TableColList[i], yytext); 
		  } break;
case 18:{ strcat (TableColList[i],  yytext);} break;
case 19:{ strcat (TableColList[i],  yytext); } break;
case 20:{ 
			strcpy (arith_oper, " + "); 
		  } break;
case 21:{ 
			strcpy (arith_oper, " - "); 
		  } break;
case 22:{ 
			strcpy (arith_oper, " * "); 
		  } break;
case 23:{ 
			strcpy (arith_oper, " / "); 
		  } break;
case 26:{ row ++ ; } break;
case 32:{ col++; } break;
case 38:{ strcat (ViewTable[row][col], " between "); } break;
case 39:{ strcat (ViewTable[row][col], " and "); } break;
case 41:{ strcat (ViewTable[row][col], " not between "); } break;
case 42:{ strcat (ViewTable[row][col], " and "); } break;
case 44:{ strcat (ViewTable[row][col], " in "); } break;
case 45:{ strcat (ViewTable[row][col], " ( "); } break;
case 46:{ strcat (ViewTable[row][col], " ) "); } break;
case 47:{ strcat (ViewTable[row][col], " not "); } break;
case 48:{ strcat (ViewTable[row][col], " in "); } break;
case 49:{ strcat (ViewTable[row][col], " ( "); } break;
case 50:{ strcat (ViewTable[row][col], " ) "); } break;
case 51:{ strcat (ViewTable[row][col], " is "); } break;
case 52:{ strcat (ViewTable[row][col], " not "); } break;
case 53:{ strcat (ViewTable[row][col], " null "); } break;
case 54:{ strcat (ViewTable[row][col], " is "); } break;
case 55:{ strcat (ViewTable[row][col], " null "); } break;
case 56:{ strcat (ViewTable[row][col], " not "); } break;
case 57:{ strcat (ViewTable[row][col], " like "); } break;
case 58:{ strcat (ViewTable[row][col], yytext); } break;
case 59:{ strcat (ViewTable[row][col], " like "); } break;
case 60:{ strcat (ViewTable[row][col], yytext); } break;
case 61:{ startRHS = TRUE; strcat (ViewTable[row][col], " = "); } break;
case 62:{ startRHS = FALSE; } break;
case 63:{ strcat (ViewTable[row][col], " != "); } break;
case 65:{ strcat (ViewTable[row][col], " = "); } break;
case 66:{ strcat (ViewTable[row][col], yytext); } break;
case 67:{ strcat (ViewTable[row][col], " != "); } break;
case 68:{ strcat (ViewTable[row][col], yytext); } break;
case 70:{
		  } break;
case 72:{ 
		    ToLower (yytext);
		    if (startRHS != TRUE)
		    {
			for (i = 0; i < no_table_cols; i++){
				if (!strcmp (TableColList[i], yytext)){
					col = i;
					break;
				}
			}
		    }
		    if (!strcmp(ViewTable[row][col], "")){
			    strcpy (ViewTable[row][col], yytext); 
if (DEBUG)
	printf ("ViewTable[%d][%d] = %s\n", row, col, ViewTable[row][col]);
			    strcpy (SVStemp, yytext);
			    strcpy (LHScol, yytext);
		    }
		    else {
			    if (startRHS == TRUE)
			    {
				/* 'tbl1.col1 = tbl2.col2' format.	*/
				/* Need to convert this to :		*/
				/* 'col1 in (select col2 from tbl2);' */

				/* 'tbl1.col1 = ' is already appended.	*/
				/* Go back to the beginning of this.	*/
				tndx = strlen (ViewTable[row][col]);
				/* Reach for the '.' in 'tbl1.col1'	*/
				while (ViewTable[row][col][--tndx] != '.');
				
				/* Reach for the space before 'tbl1'.	*/
				/* or the beginning.			*/
				while (!isspace(ViewTable[row][col][tndx]))
				{
					--tndx;
					if (tndx == 0)
						break;
				}

				/* If a space is found move to the char after space. */
				if (tndx != 0)
					tndx++;

				/* Append the query from here.	*/
				ViewTable[row][col][tndx] = '\0';
				strcpy (RHScol, yytext);
				strcat (LHScol, "~");
				strcat (RHScol, "~");
				tbl1 = strtok (LHScol, ".");
				col1 = strtok (NULL, "~");
				tbl2 = strtok (RHScol, ".");
				col2 = strtok (NULL, "~");
				sprintf (tstr,
				"%s.%s in ( select DISTINCT %s.%s from %s )",
				tbl1, col1, tbl2, col2, tbl2);
				strcat (ViewTable[row][col], tstr);
if (DEBUG)
	printf ("ViewTable[%d][%d] = %s\n", row, col, ViewTable[row][col]);
				startRHS = FALSE;
			    }
			    else
			    {
				strcat (ViewTable[row][col], " and ");
				strcat (ViewTable[row][col], yytext); 
if (DEBUG)
	printf ("ViewTable[%d][%d] = %s\n", row, col, ViewTable[row][col]);
				strcpy (SVStemp, yytext);
				strcpy (LHScol, yytext);
			    }
		    }
		  } break;
case 73:{ strcpy (ViewTable[row][no_table_cols],  " or "); } break;
case 74:{ strcpy (ViewTable[row][no_table_cols],  " and "); } break;
case 75:{
		  } break;
case 76:{ 
		    strcpy (ViewTable[row][no_table_cols],  " or ");
		    row ++ ;
		  } break;
case 77:{ strcat (ViewTable[row][col],  " > "); } break;
case 78:{ strcat (ViewTable[row][col],  " >= "); } break;
case 79:{ strcat (ViewTable[row][col],  " < "); } break;
case 80:{ strcat (ViewTable[row][col],  " <= "); } break;
case 81:{ strcat (ViewTable[row][col],  " <> "); } break;
case 82:{ strcat (ViewTable[row][col],  " != "); } break;
case 83:{ startRHS = TRUE; strcat (ViewTable[row][col],  " = "); } break;
case 84:{strcat (ViewTable[row][col], ","); } break;
case 86:{
		  } break;
case 87:{ strcat (ViewTable[row][col],  yytext);} break;
case 88:{ strcat (ViewTable[row][col],  yytext); } break;
case 89:{ strcat (ViewTable[row][col],  yytext); } break;
case 90:{
			NoTables++;
		  } break;
case 91:{
			NoTables++;
		  } break;
	}
	goto yystack;		/* reset registers in driver code */
}
