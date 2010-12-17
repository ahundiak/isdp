#include "header.h"

# line 2 "view.y"
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#define	DEBUG 1
	extern	char	v_yytext[];
	extern  char	ViewTable[MAX_SVS_PARAMS][MAX_SVS_COND][MAX_SVS_COND_LEN];
	extern	int	NoParams, NoRows, i, j, NoTables;
	extern	char	ViewParamList[MAX_SVS_PARAMS][SVS_NAME_LEN], TableColList[MAX_SVS_PARAMS][SVS_NAME_LEN*2];

	int	i, j, row = 0, col = 0, no_table_cols, no_view_cols;
 	char	temp[32], arith_oper[4], expression[132], smpl_cnd[132];
 	short	table_cols;
# define _create 257
# define _view 258
# define _view_table_name 259
# define _as 260
# define _select 261
# define _column_name 262
# define _from 263
# define _where 264
# define _inside_and 265
# define _greater 266
# define _greater_equal 267
# define _less 268
# define _less_equal 269
# define _equal 270
# define _un_equal 271
# define _not_equal 272
# define _not 273
# define _between 274
# define _in 275
# define _like 276
# define _multiply 277
# define _divide 278
# define _add 279
# define _subtract 280
# define _open 281
# define _close 282
# define _inside_open 283
# define _inside_close 284
# define _is 285
# define _null 286
# define _string 287
# define _int_value 288
# define _real_value 289
# define _comma 290
# define _outside_or 291
# define _inside_or 292
# define _outside_and 293
#define v_yyclearin v_yychar = -1
#define v_yyerrok v_yyerrflag = 0
extern int v_yychar;
extern int v_yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
#ifndef YYSTYPE
#define YYSTYPE int
#endif
YYSTYPE v_yylval, v_yyval;
typedef int v_yytabelem;
# define YYERRCODE 256

# line 291 "view.y"

v_yyerror(str)
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
		}
}
v_yytabelem v_yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
-1, 64,
	276, 52,
	-2, 43,
-1, 66,
	286, 50,
	-2, 47,
-1, 80,
	0, 66,
	265, 66,
	282, 66,
	291, 66,
	292, 66,
	293, 66,
	-2, 65,
	};
# define YYNPROD 88
# define YYLAST 225
v_yytabelem v_yyact[]={

    57,    60,    70,    71,    72,    73,    68,    74,    69,    64,
    63,    65,    67,    93,    50,    25,   131,    50,   126,   122,
    39,    66,   127,    60,   127,    20,    55,    58,    56,    53,
    51,    52,   119,    43,   108,   106,   104,   103,     6,    53,
    51,    52,    53,    51,    52,   118,    38,    10,   100,   101,
    99,    22,    23,    31,    82,    11,    29,    30,    27,    28,
   117,    70,    71,    72,    73,    96,    74,    95,   110,    70,
    71,    72,    73,    96,    74,    95,    70,    71,    72,    73,
    96,    74,    95,    15,   102,    14,    40,    35,    13,     9,
     5,     4,     3,    49,    48,    47,   120,    46,    42,    45,
    94,    44,    61,    19,    18,   130,    92,    90,    91,    89,
    88,   113,    84,    87,   115,    86,   125,   112,    83,   114,
    85,   124,    98,   116,    81,    59,    21,    33,    26,    41,
    32,    37,    34,    24,    17,    16,    12,    36,     8,     7,
     2,     1,     0,     0,    54,     0,     0,     0,    62,     0,
     0,     0,     0,    75,     0,     0,     0,    80,    79,    78,
    77,    76,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,    97,     0,     0,
     0,     0,     0,     0,     0,   105,     0,   107,     0,   109,
     0,     0,     0,     0,   111,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,   121,     0,
     0,     0,   123,     0,     0,     0,     0,     0,     0,   121,
   128,     0,   129,     0,   132 };
v_yytabelem v_yypact[]={

 -1000, -1000,  -165,  -167,  -169,  -243, -1000,  -170,  -235, -1000,
 -1000,  -171,  -175, -1000,  -178, -1000,  -237,  -275,  -221, -1000,
 -1000, -1000, -1000, -1000,  -210,  -237, -1000, -1000, -1000, -1000,
 -1000,  -172,  -221,  -237,  -244, -1000, -1000, -1000,  -173,  -248,
 -1000,  -265, -1000, -1000,  -291,  -265, -1000,  -264, -1000, -1000,
 -1000, -1000, -1000, -1000,  -248, -1000, -1000, -1000, -1000,  -245,
  -245,  -245,  -245, -1000,  -220, -1000, -1000, -1000, -1000, -1000,
 -1000, -1000, -1000, -1000, -1000, -1000,  -269,  -265, -1000,  -190,
 -1000,  -245, -1000,  -225,  -228,  -234,  -189,  -249,  -251,  -245,
  -252,  -245,  -253, -1000,  -245, -1000, -1000,  -197,  -245, -1000,
 -1000, -1000, -1000, -1000, -1000,  -190, -1000,  -190, -1000, -1000,
 -1000,  -205,  -238,  -255,  -258,  -267,  -245, -1000, -1000, -1000,
  -266, -1000, -1000,  -190,  -245,  -258, -1000, -1000,  -190,  -268,
  -258, -1000, -1000 };
v_yytabelem v_yypgo[]={

     0,   141,   140,   139,   138,   136,   135,   134,   133,   132,
   131,   129,   104,   128,   127,   103,   126,   102,    98,   125,
   101,    99,    97,    95,   100,   124,   123,   122,   121,   120,
   119,    96,   118,   117,   116,   115,   114,   113,   112,   111,
   110,   109,   108,   107,   106,    94,    93,   105 };
v_yytabelem v_yyr1[]={

     0,     2,     3,     5,     6,     8,     1,    10,    10,     4,
     4,     7,     7,    14,    12,    12,    15,    15,    16,    16,
    13,    13,    13,    13,    11,    11,    19,    18,    18,    20,
    20,    21,    21,    22,    25,    26,    22,    27,    28,    22,
    29,    30,    22,    32,    33,    34,    22,    35,    36,    22,
    37,    22,    38,    39,    22,    40,    22,    41,    22,    42,
    22,    43,    22,    44,    22,    23,    23,    45,    45,    17,
    17,    17,    17,    24,    24,    24,    24,    24,    24,    24,
    47,    31,    31,    46,    46,    46,     9,     9 };
v_yytabelem v_yyr2[]={

     0,     1,     1,     1,     1,     1,    34,     5,     0,     7,
     3,     7,     3,     1,     8,     2,     3,     2,     3,     3,
     3,     3,     3,     3,     6,     2,     1,     8,     2,     6,
     2,     6,     3,     6,     1,     1,    14,     1,     1,    16,
     1,     1,    15,     1,     1,     1,    19,     1,     1,    13,
     1,     9,     1,     1,    13,     1,     9,     1,     8,     1,
     8,     1,     9,     1,     9,     6,     3,     2,     3,     3,
     3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
     1,     8,     3,     3,     3,     3,     7,     3 };
v_yytabelem v_yychk[]={

 -1000,    -1,    -2,   257,   258,   259,   281,    -3,    -4,   259,
   282,   290,    -5,   259,   260,   261,    -6,    -7,   -12,   -15,
   262,   -16,   288,   289,    -8,   290,   -13,   279,   280,   277,
   278,   263,   -12,   -14,    -9,   259,   -15,   -10,   290,   264,
   259,   -11,   -18,   281,   -20,   -21,   -22,   -23,   -45,   -46,
   262,   288,   289,   287,   -17,   291,   293,   265,   292,   -19,
   292,   -17,   -24,   274,   273,   275,   285,   276,   270,   272,
   266,   267,   268,   269,   271,   -18,   -20,   -21,   -22,   -23,
   -45,   -25,   274,   -32,   -38,   -29,   -35,   -37,   -40,   -41,
   -43,   -42,   -44,   282,   -24,   272,   270,   -23,   -27,   275,
   276,   283,   273,   286,   287,   -23,   287,   -23,   287,   -45,
   265,   -23,   -33,   -39,   -30,   -36,   -26,   265,   283,   287,
   -31,   -46,   286,   -23,   -28,   -34,   284,   290,   -23,   -31,
   -47,   284,   -46 };
v_yytabelem v_yydef[]={

     1,    -2,     0,     0,     0,     0,     2,     0,     0,    10,
     3,     0,     0,     9,     0,     4,     0,     5,    12,    15,
    16,    17,    18,    19,     0,     0,    13,    20,    21,    22,
    23,     0,    11,     0,     8,    87,    14,     6,     0,     0,
    86,     7,    25,    26,    28,    30,    32,     0,    66,    67,
    68,    83,    84,    85,     0,    69,    70,    71,    72,     0,
     0,     0,     0,    34,    -2,    40,    -2,    55,    57,    59,
    73,    74,    75,    76,    77,    24,     0,    29,    31,    33,
    -2,     0,    37,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,    27,     0,    78,    79,     0,     0,    44,
    53,    41,    48,    51,    56,    58,    62,    60,    64,    65,
    35,     0,     0,     0,     0,     0,     0,    38,    45,    54,
     0,    82,    49,    36,     0,     0,    42,    80,    39,     0,
     0,    46,    81 };
typedef struct { char *t_name; int t_val; } v_yytoktype;
#ifndef YYDEBUG
#	define YYDEBUG	0	/* don't allow debugging */
#endif

#if YYDEBUG

v_yytoktype v_yytoks[] =
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
	"_greater",	266,
	"_greater_equal",	267,
	"_less",	268,
	"_less_equal",	269,
	"_equal",	270,
	"_un_equal",	271,
	"_not_equal",	272,
	"_not",	273,
	"_between",	274,
	"_in",	275,
	"_like",	276,
	"_multiply",	277,
	"_divide",	278,
	"_add",	279,
	"_subtract",	280,
	"_open",	281,
	"_close",	282,
	"_inside_open",	283,
	"_inside_close",	284,
	"_is",	285,
	"_null",	286,
	"_string",	287,
	"_int_value",	288,
	"_real_value",	289,
	"_comma",	290,
	"_outside_or",	291,
	"_inside_or",	292,
	"_outside_and",	293,
	"-unknown-",	-1	/* ends search */
};

char * v_yyreds[] =
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
	"line : line conj condition",
	"line : condition",
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
#define YYERROR		goto v_yyerrlab
#define YYACCEPT	return(0)
#define YYABORT		return(1)
#define YYBACKUP( newtoken, newvalue )\
{\
	if ( v_yychar >= 0 || ( v_yyr2[ v_yytmp ] >> 1 ) != 1 )\
	{\
		v_yyerror( "syntax error - cannot backup" );\
		goto v_yyerrlab;\
	}\
	v_yychar = newtoken;\
	v_yystate = *v_yyps;\
	v_yylval = newvalue;\
	goto v_yynewstate;\
}
#define YYRECOVERING()	(!!v_yyerrflag)
#ifndef YYDEBUG
#	define YYDEBUG	1	/* make debugging available */
#endif

/*
** user known globals
*/
int v_yydebug;			/* set to 1 to get debugging */

/*
** driver internal defines
*/
#define YYFLAG		(-1000)

/*
** global variables used by the parser
*/
YYSTYPE v_yyv[ YYMAXDEPTH ];	/* value stack */
int v_yys[ YYMAXDEPTH ];		/* state stack */

YYSTYPE *v_yypv;			/* top of value stack */
int *v_yyps;			/* top of state stack */

int v_yystate;			/* current state */
int v_yytmp;			/* extra var (lasts between blocks) */

int v_yynerrs;			/* number of errors */
int v_yyerrflag;			/* error recovery flag */
int v_yychar;			/* current input token number */



/*
** v_yyparse - return 0 if worked, 1 if syntax error not recovered from
*/
int
v_yyparse()
{
	register YYSTYPE *v_yypvt;	/* top of value stack for $vars */

	/*
	** Initialize externals - v_yyparse may be called more than once
	*/
	v_yypv = &v_yyv[-1];
	v_yyps = &v_yys[-1];
	v_yystate = 0;
	v_yytmp = 0;
	v_yynerrs = 0;
	v_yyerrflag = 0;
	v_yychar = -1;

	goto v_yystack;
	{
		register YYSTYPE *v_yy_pv;	/* top of value stack */
		register int *v_yy_ps;		/* top of state stack */
		register int v_yy_state;		/* current state */
		register int  v_yy_n;		/* internal state number info */

		/*
		** get globals into registers.
		** branch to here only if YYBACKUP was called.
		*/
	v_yynewstate:
		v_yy_pv = v_yypv;
		v_yy_ps = v_yyps;
		v_yy_state = v_yystate;
		goto v_yy_newstate;

		/*
		** get globals into registers.
		** either we just started, or we just finished a reduction
		*/
	v_yystack:
		v_yy_pv = v_yypv;
		v_yy_ps = v_yyps;
		v_yy_state = v_yystate;

		/*
		** top of for (;;) loop while no reductions done
		*/
	v_yy_stack:
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
		if ( v_yydebug )
		{
			register int v_yy_i;

			printf( "State %d, token ", v_yy_state );
			if ( v_yychar == 0 )
				printf( "end-of-file\n" );
			else if ( v_yychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( v_yy_i = 0; v_yytoks[v_yy_i].t_val >= 0;
					v_yy_i++ )
				{
					if ( v_yytoks[v_yy_i].t_val == v_yychar )
						break;
				}
				printf( "%s\n", v_yytoks[v_yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ++v_yy_ps >= &v_yys[ YYMAXDEPTH ] )	/* room on stack? */
		{
			v_yyerror( "yacc stack overflow" );
			YYABORT;
		}
		*v_yy_ps = v_yy_state;
		*++v_yy_pv = v_yyval;

		/*
		** we have a new state - find out what to do
		*/
	v_yy_newstate:
		if ( ( v_yy_n = v_yypact[ v_yy_state ] ) <= YYFLAG )
			goto v_yydefault;		/* simple state */
#if YYDEBUG
		/*
		** if debugging, need to mark whether new token grabbed
		*/
		v_yytmp = v_yychar < 0;
#endif
		if ( ( v_yychar < 0 ) && ( ( v_yychar = v_yylex() ) < 0 ) )
			v_yychar = 0;		/* reached EOF */
#if YYDEBUG
		if ( v_yydebug && v_yytmp )
		{
			register int v_yy_i;

			printf( "Received token " );
			if ( v_yychar == 0 )
				printf( "end-of-file\n" );
			else if ( v_yychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( v_yy_i = 0; v_yytoks[v_yy_i].t_val >= 0;
					v_yy_i++ )
				{
					if ( v_yytoks[v_yy_i].t_val == v_yychar )
						break;
				}
				printf( "%s\n", v_yytoks[v_yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ( ( v_yy_n += v_yychar ) < 0 ) || ( v_yy_n >= YYLAST ) )
			goto v_yydefault;
		if ( v_yychk[ v_yy_n = v_yyact[ v_yy_n ] ] == v_yychar )	/*valid shift*/
		{
			v_yychar = -1;
			v_yyval = v_yylval;
			v_yy_state = v_yy_n;
			if ( v_yyerrflag > 0 )
				v_yyerrflag--;
			goto v_yy_stack;
		}

	v_yydefault:
		if ( ( v_yy_n = v_yydef[ v_yy_state ] ) == -2 )
		{
#if YYDEBUG
			v_yytmp = v_yychar < 0;
#endif
			if ( ( v_yychar < 0 ) && ( ( v_yychar = v_yylex() ) < 0 ) )
				v_yychar = 0;		/* reached EOF */
#if YYDEBUG
			if ( v_yydebug && v_yytmp )
			{
				register int v_yy_i;

				printf( "Received token " );
				if ( v_yychar == 0 )
					printf( "end-of-file\n" );
				else if ( v_yychar < 0 )
					printf( "-none-\n" );
				else
				{
					for ( v_yy_i = 0;
						v_yytoks[v_yy_i].t_val >= 0;
						v_yy_i++ )
					{
						if ( v_yytoks[v_yy_i].t_val
							== v_yychar )
						{
							break;
						}
					}
					printf( "%s\n", v_yytoks[v_yy_i].t_name );
				}
			}
#endif /* YYDEBUG */
			/*
			** look through exception table
			*/
			{
				register int *v_yyxi = v_yyexca;

				while ( ( *v_yyxi != -1 ) ||
					( v_yyxi[1] != v_yy_state ) )
				{
					v_yyxi += 2;
				}
				while ( ( *(v_yyxi += 2) >= 0 ) &&
					( *v_yyxi != v_yychar ) )
					;
				if ( ( v_yy_n = v_yyxi[1] ) < 0 )
					YYACCEPT;
			}
		}

		/*
		** check for syntax error
		*/
		if ( v_yy_n == 0 )	/* have an error */
		{
			/* no worry about speed here! */
			switch ( v_yyerrflag )
			{
			case 0:		/* new error */
				v_yyerror( "syntax error" );
				goto skip_init;
			v_yyerrlab:
				/*
				** get globals into registers.
				** we have a user generated syntax type error
				*/
				v_yy_pv = v_yypv;
				v_yy_ps = v_yyps;
				v_yy_state = v_yystate;
				v_yynerrs++;
			skip_init:
			case 1:
			case 2:		/* incompletely recovered error */
					/* try again... */
				v_yyerrflag = 3;
				/*
				** find state where "error" is a legal
				** shift action
				*/
				while ( v_yy_ps >= v_yys )
				{
					v_yy_n = v_yypact[ *v_yy_ps ] + YYERRCODE;
					if ( v_yy_n >= 0 && v_yy_n < YYLAST &&
						v_yychk[v_yyact[v_yy_n]] == YYERRCODE)					{
						/*
						** simulate shift of "error"
						*/
						v_yy_state = v_yyact[ v_yy_n ];
						goto v_yy_stack;
					}
					/*
					** current state has no shift on
					** "error", pop stack
					*/
#if YYDEBUG
#	define _POP_ "Error recovery pops state %d, uncovers state %d\n"
					if ( v_yydebug )
						printf( _POP_, *v_yy_ps,
							v_yy_ps[-1] );
#	undef _POP_
#endif
					v_yy_ps--;
					v_yy_pv--;
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
				if ( v_yydebug )
				{
					register int v_yy_i;

					printf( "Error recovery discards " );
					if ( v_yychar == 0 )
						printf( "token end-of-file\n" );
					else if ( v_yychar < 0 )
						printf( "token -none-\n" );
					else
					{
						for ( v_yy_i = 0;
							v_yytoks[v_yy_i].t_val >= 0;
							v_yy_i++ )
						{
							if ( v_yytoks[v_yy_i].t_val
								== v_yychar )
							{
								break;
							}
						}
						printf( "token %s\n",
							v_yytoks[v_yy_i].t_name );
					}
				}
#endif /* YYDEBUG */
				if ( v_yychar == 0 )	/* reached EOF. quit */
					YYABORT;
				v_yychar = -1;
				goto v_yy_newstate;
			}
		}/* end if ( v_yy_n == 0 ) */
		/*
		** reduction by production v_yy_n
		** put stack tops, etc. so things right after switch
		*/
#if YYDEBUG
		/*
		** if debugging, print the string that is the user's
		** specification of the reduction which is just about
		** to be done.
		*/
		if ( v_yydebug )
			printf( "Reduce by (%d) \"%s\"\n",
				v_yy_n, v_yyreds[ v_yy_n ] );
#endif
		v_yytmp = v_yy_n;			/* value to switch over */
		v_yypvt = v_yy_pv;			/* $vars top of value stack */
		/*
		** Look in goto table for next state
		** Sorry about using v_yy_state here as temporary
		** register variable, but why not, if it works...
		** If v_yyr2[ v_yy_n ] doesn't have the low order bit
		** set, then there is no action to be done for
		** this reduction.  So, no saving & unsaving of
		** registers done.  The only difference between the
		** code just after the if and the body of the if is
		** the goto v_yy_stack in the body.  This way the test
		** can be made before the choice of what to do is needed.
		*/
		{
			/* length of production doubled with extra bit */
			register int v_yy_len = v_yyr2[ v_yy_n ];

			if ( !( v_yy_len & 01 ) )
			{
				v_yy_len >>= 1;
				v_yyval = ( v_yy_pv -= v_yy_len )[1];	/* $$ = $1 */
				v_yy_state = v_yypgo[ v_yy_n = v_yyr1[ v_yy_n ] ] +
					*( v_yy_ps -= v_yy_len ) + 1;
				if ( v_yy_state >= YYLAST ||
					v_yychk[ v_yy_state =
					v_yyact[ v_yy_state ] ] != -v_yy_n )
				{
					v_yy_state = v_yyact[ v_yypgo[ v_yy_n ] ];
				}
				goto v_yy_stack;
			}
			v_yy_len >>= 1;
			v_yyval = ( v_yy_pv -= v_yy_len )[1];	/* $$ = $1 */
			v_yy_state = v_yypgo[ v_yy_n = v_yyr1[ v_yy_n ] ] +
				*( v_yy_ps -= v_yy_len ) + 1;
			if ( v_yy_state >= YYLAST ||
				v_yychk[ v_yy_state = v_yyact[ v_yy_state ] ] != -v_yy_n )
			{
				v_yy_state = v_yyact[ v_yypgo[ v_yy_n ] ];
			}
		}
					/* save until reenter driver code */
		v_yystate = v_yy_state;
		v_yyps = v_yy_ps;
		v_yypv = v_yy_pv;
	}
	/*
	** code supplied by user is placed in this switch
	*/
	switch( v_yytmp )
	{
		
case 1:
# line 25 "view.y"
{ 
		   row = 0;
		   NoTables = 0;
		   for (i = 0; i < MAX_SVS_PARAMS; i++)
			TableColList[i][0] = '\0';
		  } break;
case 2:
# line 33 "view.y"
{ i = 0; } break;
case 3:
# line 35 "view.y"
{ NoParams = i; } break;
case 4:
# line 37 "view.y"
{ i = 0 ; } break;
case 5:
# line 39 "view.y"
{ no_table_cols = i; } break;
case 7:
# line 46 "view.y"
{
			NoRows = row;
			PrintResult ();
		  } break;
case 9:
# line 53 "view.y"
{ 
			ToLower (v_yytext);
			strcpy (ViewParamList[i++], v_yytext); 
		  } break;
case 10:
# line 59 "view.y"
{ 
			ToLower (v_yytext);
			strcpy (ViewParamList[i++], v_yytext); 
		  } break;
case 11:
# line 65 "view.y"
{ i++; } break;
case 12:
# line 68 "view.y"
{ i++; } break;
case 13:
# line 70 "view.y"
{ strcat (TableColList[i], arith_oper); } break;
case 16:
# line 76 "view.y"
{ 
		    ToLower (v_yytext);
		    strcat (TableColList[i], v_yytext); 
		  } break;
case 18:
# line 84 "view.y"
{ strcat (TableColList[i],  v_yytext);} break;
case 19:
# line 87 "view.y"
{ strcat (TableColList[i],  v_yytext); } break;
case 20:
# line 90 "view.y"
{ 
			strcpy (arith_oper, " + "); 
		  } break;
case 21:
# line 95 "view.y"
{ 
			strcpy (arith_oper, " - "); 
		  } break;
case 22:
# line 100 "view.y"
{ 
			strcpy (arith_oper, " * "); 
		  } break;
case 23:
# line 105 "view.y"
{ 
			strcpy (arith_oper, " / "); 
		  } break;
case 26:
# line 114 "view.y"
{ row ++ ; } break;
case 32:
# line 127 "view.y"
{ col++; } break;
case 34:
# line 132 "view.y"
{ strcat (ViewTable[row][col], " between "); } break;
case 35:
# line 134 "view.y"
{ strcat (ViewTable[row][col], " and "); } break;
case 37:
# line 138 "view.y"
{ strcat (ViewTable[row][col], " not between "); } break;
case 38:
# line 140 "view.y"
{ strcat (ViewTable[row][col], " and "); } break;
case 40:
# line 144 "view.y"
{ strcat (ViewTable[row][col], " in "); } break;
case 41:
# line 146 "view.y"
{ strcat (ViewTable[row][col], " ( "); } break;
case 42:
# line 148 "view.y"
{ strcat (ViewTable[row][col], " ) "); } break;
case 43:
# line 151 "view.y"
{ strcat (ViewTable[row][col], " not "); } break;
case 44:
# line 153 "view.y"
{ strcat (ViewTable[row][col], " in "); } break;
case 45:
# line 155 "view.y"
{ strcat (ViewTable[row][col], " ( "); } break;
case 46:
# line 157 "view.y"
{ strcat (ViewTable[row][col], " ) "); } break;
case 47:
# line 160 "view.y"
{ strcat (ViewTable[row][col], " is "); } break;
case 48:
# line 162 "view.y"
{ strcat (ViewTable[row][col], " not "); } break;
case 49:
# line 164 "view.y"
{ strcat (ViewTable[row][col], " null "); } break;
case 50:
# line 167 "view.y"
{ strcat (ViewTable[row][col], " is "); } break;
case 51:
# line 169 "view.y"
{ strcat (ViewTable[row][col], " null "); } break;
case 52:
# line 172 "view.y"
{ strcat (ViewTable[row][col], " not "); } break;
case 53:
# line 174 "view.y"
{ strcat (ViewTable[row][col], " like "); } break;
case 54:
# line 176 "view.y"
{ strcat (ViewTable[row][col], v_yytext); } break;
case 55:
# line 180 "view.y"
{ strcat (ViewTable[row][col], " like "); } break;
case 56:
# line 182 "view.y"
{ strcat (ViewTable[row][col], v_yytext); } break;
case 57:
# line 185 "view.y"
{ strcat (ViewTable[row][col], " = "); } break;
case 59:
# line 189 "view.y"
{ strcat (ViewTable[row][col], " != "); } break;
case 61:
# line 193 "view.y"
{ strcat (ViewTable[row][col], " = "); } break;
case 62:
# line 195 "view.y"
{ strcat (ViewTable[row][col], v_yytext); } break;
case 63:
# line 198 "view.y"
{ strcat (ViewTable[row][col], " != "); } break;
case 64:
# line 200 "view.y"
{ strcat (ViewTable[row][col], v_yytext); } break;
case 66:
# line 205 "view.y"
{
		  } break;
case 68:
# line 210 "view.y"
{ 
		    ToLower (v_yytext);
		    for (i = 0; i < no_table_cols; i++){
			if (!strcmp (TableColList[i], v_yytext)){
				col = i;
				break;
			}
		    }
		    if (!strcmp(ViewTable[row][col], "")){
			    strcpy (ViewTable[row][col], v_yytext); 
			    strcpy (temp, v_yytext);
		    }
		    else {
			    strcat (ViewTable[row][col], " and ");
			    strcat (ViewTable[row][col], v_yytext); 
			    strcpy (temp, v_yytext);
		    }
		  } break;
case 69:
# line 230 "view.y"
{ strcpy (ViewTable[row][no_table_cols],  " or "); } break;
case 70:
# line 233 "view.y"
{ strcpy (ViewTable[row][no_table_cols],  " and "); } break;
case 71:
# line 236 "view.y"
{
		  } break;
case 72:
# line 240 "view.y"
{ 
		    strcpy (ViewTable[row][no_table_cols],  " or ");
		    row ++ ;
		  } break;
case 73:
# line 245 "view.y"
{ strcat (ViewTable[row][col],  " > "); } break;
case 74:
# line 248 "view.y"
{ strcat (ViewTable[row][col],  " >= "); } break;
case 75:
# line 251 "view.y"
{ strcat (ViewTable[row][col],  " < "); } break;
case 76:
# line 254 "view.y"
{ strcat (ViewTable[row][col],  " <= "); } break;
case 77:
# line 257 "view.y"
{ strcat (ViewTable[row][col],  " <> "); } break;
case 78:
# line 260 "view.y"
{ strcat (ViewTable[row][col],  " != "); } break;
case 79:
# line 263 "view.y"
{ strcat (ViewTable[row][col],  " = "); } break;
case 80:
# line 266 "view.y"
{strcat (ViewTable[row][col], ","); } break;
case 82:
# line 270 "view.y"
{
		  } break;
case 83:
# line 274 "view.y"
{ strcat (ViewTable[row][col],  v_yytext);} break;
case 84:
# line 277 "view.y"
{ strcat (ViewTable[row][col],  v_yytext); } break;
case 85:
# line 280 "view.y"
{ strcat (ViewTable[row][col],  v_yytext); } break;
case 86:
# line 283 "view.y"
{
			NoTables++;
		  } break;
case 87:
# line 288 "view.y"
{
			NoTables++;
		  } break;
	}
	goto v_yystack;		/* reset registers in driver code */
}
# include "stdio.h"
# define U(x) x
# define NLSTATE v_yyprevious=YYNEWLINE
# define BEGIN v_yybgin = v_yysvec + 1 +
# define INITIAL 0
# define YYLERR v_yysvec
# define YYSTATE (v_yyestate-v_yysvec-1)
# define YYOPTIM 1
# define YYLMAX 200
# define output(c) putc(c,v_yyout)
# define input() (((v_yytchar=v_yysptr>v_yysbuf?U(*--v_yysptr):getc(v_yyin))==10?(v_yylineno++,v_yytchar):v_yytchar)==EOF?0:v_yytchar)
# define unput(c) {v_yytchar= (c);if(v_yytchar=='\n')v_yylineno--;*v_yysptr++=v_yytchar;}
# define v_yymore() (v_yymorfg=1)


/************ inhibit echo ****************************************************/
#ifdef MYDEBUG
#define ECHO fprintf(v_yyout, "%s",v_yytext)
#endif

#ifndef MYDEBUG
#define	ECHO
#endif
/******************************************************************************/



# define REJECT { nstr = v_yyreject(); goto v_yyfussy;}
int v_yyleng; extern char v_yytext[];
int v_yymorfg;
extern char *v_yysptr, v_yysbuf[];
int v_yytchar;


/************ change 'v_yyin' so that input is taken from a *********************/
/************ file rather than the 'stdin'	          *********************/

/*FILE *v_yyin = {stdin}, *v_yyout = {stdout};*/

FILE *v_yyout = {stdout};
extern FILE *v_yyin;

/*****************************************************************************/



extern int v_yylineno;
struct v_yysvf { 
	struct v_yywork *v_yystoff;
	struct v_yysvf *v_yyother;
	int *v_yystops;};
struct v_yysvf *v_yyestate;
extern struct v_yysvf v_yysvec[], *v_yybgin;
# define OUTERPAR 2
# define INNERPAR 4
# define YYNEWLINE 10
v_yylex(){
int nstr; extern int v_yyprevious;
while((nstr = v_yylook()) >= 0)
v_yyfussy: switch(nstr){
case 0:
if(v_yywrap()) return(0); break;
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
				return (_inside_and);
			}
break;
case 9:
		{
				ECHO;
				return (_outside_and);
			}
break;
case 10:
		{
				ECHO;
				return (_inside_or);
			}
break;
case 11:
		{
				ECHO;
				return (_outside_or);
			}
break;
case 12:
			{
				ECHO;
				return (_greater_equal);
			}
break;
case 13:
			{
				ECHO;
				return (_greater);
			}
break;
case 14:
			{
				ECHO;
				return (_less_equal);
			}
break;
case 15:
			{
				ECHO;
				return (_less);
			}
break;
case 16:
			{
				ECHO;
				return (_equal);
			}
break;
case 17:
			{
				ECHO;
				return (_un_equal);
			}
break;
case 18:
			{
				ECHO;
				return (_not_equal);
			}
break;
case 19:
		{
				ECHO;
				return (_not);
			}
break;
case 20:
{
				ECHO;
				return (_between);
			}
break;
case 21:
		{
				ECHO;
				return (_in);
			}
break;
case 22:
		{
				ECHO;
				return (_is);
			}
break;
case 23:
	{
				ECHO;
				return (_null);
			}
break;
case 24:
	{
				ECHO;
				return (_like);
			}
break;
case 25:
			{
				ECHO;
				return (_int_value);
			}
break;
case 26:
{
				ECHO;
				return (_real_value);
			}
break;
case 27:
			{
				ECHO;
				return (_multiply);
			}
break;
case 28:
			{
				ECHO;
				return (_divide);
			}
break;
case 29:
			{
				ECHO;
				return (_add);
			}
break;
case 30:
			{
				ECHO;
				return (_subtract);
			}
break;
case 31:
			{
				ECHO;
				return (_comma);
			}
break;
case 32:
			{
				ECHO;
				BEGIN INNERPAR;
				return (_inside_open);
			}
break;
case 33:
			{
				ECHO;
				BEGIN OUTERPAR;
				return (_open);
			}
break;
case 34:
			{
				ECHO;
				BEGIN 0;
				BEGIN OUTERPAR;
				return (_inside_close);
			}
break;
case 35:
			{
				ECHO;
				BEGIN 0;
				return (_close);
			}
break;
case 36:
{
				ECHO;
				return (_string);
			}
break;
case 37:
	{
				ECHO;
				return (_view_table_name);
			}
break;
case -1:
break;
default:
fprintf(v_yyout,"bad switch v_yylook %d",nstr);
} return(0); }
/* end of v_yylex */

v_yywrap ()
{
	printf ("%s\n", v_yytext);
	return (1);
}
int v_yyvstop[] = {
0,

33,
0,

35,
0,

27,
0,

29,
0,

31,
0,

30,
0,

28,
0,

25,
0,

15,
0,

16,
0,

13,
0,

37,
0,

37,
0,

37,
0,

37,
0,

37,
0,

37,
0,

37,
0,

37,
0,

37,
0,

37,
0,

37,
0,

37,
0,

32,
33,
0,

37,
0,

37,
0,

34,
35,
0,

18,
0,

36,
0,

14,
0,

17,
0,

12,
0,

37,
0,

3,
37,
0,

37,
0,

37,
0,

37,
0,

21,
37,
0,

22,
37,
0,

37,
0,

37,
0,

37,
0,

11,
37,
0,

37,
0,

37,
0,

37,
0,

37,
0,

10,
11,
37,
0,

26,
0,

5,
0,

9,
37,
0,

37,
0,

37,
0,

37,
0,

37,
0,

19,
37,
0,

37,
0,

37,
0,

37,
0,

37,
0,

8,
9,
37,
0,

37,
0,

37,
0,

6,
37,
0,

24,
37,
0,

23,
37,
0,

37,
0,

2,
37,
0,

37,
0,

37,
0,

37,
0,

37,
0,

7,
37,
0,

37,
0,

1,
37,
0,

4,
37,
0,

20,
37,
0,
0};
# define YYTYPE char
struct v_yywork { YYTYPE verify, advance; } v_yycrank[] = {
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
1,12,	1,13,	1,14,	5,35,	
1,15,	1,16,	1,16,	1,16,	
1,16,	1,16,	1,16,	1,16,	
1,16,	1,16,	1,16,	6,35,	
0,0,	1,17,	1,18,	1,19,	
7,36,	0,0,	1,20,	1,21,	
1,22,	1,23,	1,23,	1,24,	
1,23,	1,23,	1,25,	1,23,	
1,23,	1,26,	1,23,	1,27,	
1,28,	1,23,	1,23,	1,23,	
1,29,	1,23,	1,23,	1,30,	
1,31,	1,23,	1,23,	1,23,	
17,39,	17,40,	19,41,	33,57,	
0,0,	0,0,	1,20,	1,21,	
1,22,	1,23,	1,23,	1,24,	
1,23,	1,23,	1,25,	1,23,	
1,23,	1,26,	1,23,	1,27,	
1,28,	1,23,	1,23,	1,23,	
1,29,	1,23,	1,23,	1,30,	
1,31,	1,23,	1,23,	1,23,	
3,32,	4,32,	16,38,	33,57,	
16,16,	16,16,	16,16,	16,16,	
16,16,	16,16,	16,16,	16,16,	
16,16,	16,16,	22,23,	21,45,	
23,23,	25,48,	22,46,	22,23,	
0,0,	23,23,	25,49,	0,0,	
21,23,	3,33,	4,33,	0,0,	
0,0,	21,23,	0,0,	44,23,	
0,0,	0,0,	0,0,	0,0,	
44,23,	0,0,	0,0,	3,34,	
4,34,	0,0,	0,0,	0,0,	
0,0,	0,0,	22,23,	21,45,	
23,23,	25,48,	22,46,	22,23,	
0,0,	23,23,	25,49,	0,0,	
21,23,	3,33,	4,33,	0,0,	
8,8,	21,23,	0,0,	44,23,	
8,8,	8,8,	0,0,	8,37,	
44,23,	0,0,	0,0,	3,34,	
4,34,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	24,23,	
0,0,	0,0,	0,0,	24,47,	
24,23,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	24,23,	
0,0,	0,0,	0,0,	24,47,	
24,23,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	8,8,	
8,8,	8,8,	8,8,	20,42,	
0,0,	20,23,	20,23,	20,23,	
20,23,	20,23,	20,23,	20,23,	
20,23,	20,23,	20,23,	0,0,	
47,23,	47,64,	0,0,	0,0,	
0,0,	47,23,	20,23,	20,23,	
20,23,	20,23,	20,23,	20,23,	
20,23,	20,23,	20,23,	20,23,	
20,23,	20,23,	20,23,	20,43,	
20,23,	20,23,	20,23,	20,23,	
20,44,	20,23,	20,23,	20,23,	
20,23,	20,23,	20,23,	20,23,	
47,23,	47,64,	0,0,	0,0,	
20,23,	47,23,	20,23,	20,23,	
20,23,	20,23,	20,23,	20,23,	
20,23,	20,23,	20,23,	20,23,	
20,23,	20,23,	20,23,	20,43,	
20,23,	20,23,	20,23,	20,23,	
20,44,	20,23,	20,23,	20,23,	
20,23,	20,23,	20,23,	20,23,	
26,50,	27,23,	27,51,	0,0,	
29,54,	26,23,	27,23,	28,23,	
27,52,	30,55,	26,23,	28,53,	
28,23,	29,23,	30,23,	31,56,	
0,0,	45,23,	29,23,	30,23,	
34,23,	31,23,	45,23,	45,62,	
34,58,	34,23,	31,23,	0,0,	
0,0,	0,0,	0,0,	0,0,	
26,50,	27,23,	27,51,	0,0,	
29,54,	26,23,	27,23,	28,23,	
27,52,	30,55,	26,23,	28,53,	
28,23,	29,23,	30,23,	31,56,	
0,0,	45,23,	29,23,	30,23,	
34,23,	31,23,	45,23,	45,62,	
34,58,	34,23,	31,23,	38,59,	
38,59,	38,59,	38,59,	38,59,	
38,59,	38,59,	38,59,	38,59,	
38,59,	42,60,	42,60,	42,60,	
42,60,	42,60,	42,60,	42,60,	
42,60,	42,60,	42,60,	42,60,	
42,60,	42,60,	42,60,	42,60,	
42,60,	42,60,	42,60,	42,60,	
42,60,	42,60,	42,60,	42,60,	
42,60,	42,60,	42,60,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	42,60,	42,60,	42,60,	
42,60,	42,60,	42,60,	42,60,	
42,60,	42,60,	42,60,	42,60,	
42,60,	42,60,	42,60,	42,60,	
42,60,	42,60,	42,60,	42,60,	
42,60,	42,60,	42,60,	42,60,	
42,60,	42,60,	42,60,	43,61,	
48,23,	46,63,	49,23,	50,65,	
0,0,	48,23,	50,23,	49,23,	
53,23,	43,23,	46,23,	50,23,	
51,23,	53,23,	43,23,	46,23,	
55,69,	51,23,	51,66,	52,67,	
54,68,	52,23,	54,23,	0,0,	
0,0,	55,23,	52,23,	54,23,	
0,0,	0,0,	55,23,	43,61,	
48,23,	46,63,	49,23,	50,65,	
0,0,	48,23,	50,23,	49,23,	
53,23,	43,23,	46,23,	50,23,	
51,23,	53,23,	43,23,	46,23,	
55,69,	51,23,	51,66,	52,67,	
54,68,	52,23,	54,23,	56,70,	
57,71,	55,23,	52,23,	54,23,	
58,23,	0,0,	55,23,	61,23,	
56,23,	58,23,	57,23,	0,0,	
61,23,	56,23,	0,0,	57,23,	
60,60,	60,60,	60,60,	60,60,	
60,60,	60,60,	60,60,	60,60,	
60,60,	60,60,	0,0,	0,0,	
62,23,	0,0,	63,73,	56,70,	
57,71,	62,23,	0,0,	0,0,	
58,23,	62,72,	0,0,	61,23,	
56,23,	58,23,	57,23,	63,23,	
61,23,	56,23,	66,23,	57,23,	
63,23,	64,74,	64,23,	66,23,	
65,75,	0,0,	0,0,	64,23,	
0,0,	67,76,	68,77,	67,23,	
62,23,	65,23,	63,73,	60,60,	
67,23,	62,23,	65,23,	68,23,	
69,23,	62,72,	0,0,	71,23,	
68,23,	69,23,	0,0,	63,23,	
71,23,	69,78,	66,23,	0,0,	
63,23,	64,74,	64,23,	66,23,	
65,75,	0,0,	0,0,	64,23,	
0,0,	67,76,	68,77,	67,23,	
0,0,	65,23,	0,0,	0,0,	
67,23,	70,23,	65,23,	68,23,	
69,23,	70,79,	70,23,	71,23,	
68,23,	69,23,	72,80,	73,23,	
71,23,	69,78,	77,82,	74,23,	
73,23,	73,81,	75,23,	72,23,	
74,23,	76,23,	78,23,	75,23,	
72,23,	77,23,	76,23,	78,23,	
0,0,	0,0,	77,23,	79,83,	
0,0,	70,23,	83,23,	0,0,	
0,0,	70,79,	70,23,	83,23,	
79,23,	0,0,	72,80,	73,23,	
0,0,	79,23,	77,82,	74,23,	
73,23,	73,81,	75,23,	72,23,	
74,23,	76,23,	78,23,	75,23,	
72,23,	77,23,	76,23,	78,23,	
80,84,	81,85,	77,23,	79,83,	
0,0,	0,0,	83,23,	0,0,	
0,0,	80,23,	81,23,	83,23,	
79,23,	82,23,	80,23,	81,23,	
84,87,	79,23,	82,23,	82,86,	
85,23,	84,23,	86,23,	87,23,	
0,0,	85,23,	0,0,	86,23,	
87,23,	0,0,	0,0,	0,0,	
80,84,	81,85,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	80,23,	81,23,	0,0,	
0,0,	82,23,	80,23,	81,23,	
84,87,	0,0,	82,23,	82,86,	
85,23,	84,23,	86,23,	87,23,	
0,0,	85,23,	0,0,	86,23,	
87,23,	0,0,	0,0,	0,0,	
0,0};
struct v_yysvf v_yysvec[] = {
0,	0,	0,
v_yycrank+1,	0,		0,	
v_yycrank+0,	v_yysvec+1,	0,	
v_yycrank+84,	v_yysvec+1,	0,	
v_yycrank+85,	v_yysvec+1,	0,	
v_yycrank+6,	v_yysvec+1,	0,	
v_yycrank+18,	v_yysvec+1,	0,	
v_yycrank+3,	0,		0,	
v_yycrank+152,	0,		0,	
v_yycrank+0,	0,		v_yyvstop+1,
v_yycrank+0,	0,		v_yyvstop+3,
v_yycrank+0,	0,		v_yyvstop+5,
v_yycrank+0,	0,		v_yyvstop+7,
v_yycrank+0,	0,		v_yyvstop+9,
v_yycrank+0,	0,		v_yyvstop+11,
v_yycrank+0,	0,		v_yyvstop+13,
v_yycrank+80,	0,		v_yyvstop+15,
v_yycrank+31,	0,		v_yyvstop+17,
v_yycrank+0,	0,		v_yyvstop+19,
v_yycrank+33,	0,		v_yyvstop+21,
v_yycrank+229,	0,		v_yyvstop+23,
v_yycrank+70,	v_yysvec+20,	v_yyvstop+25,
v_yycrank+60,	v_yysvec+20,	v_yyvstop+27,
v_yycrank+62,	v_yysvec+20,	v_yyvstop+29,
v_yycrank+133,	v_yysvec+20,	v_yyvstop+31,
v_yycrank+63,	v_yysvec+20,	v_yyvstop+33,
v_yycrank+279,	v_yysvec+20,	v_yyvstop+35,
v_yycrank+275,	v_yysvec+20,	v_yyvstop+37,
v_yycrank+281,	v_yysvec+20,	v_yyvstop+39,
v_yycrank+287,	v_yysvec+20,	v_yyvstop+41,
v_yycrank+288,	v_yysvec+20,	v_yyvstop+43,
v_yycrank+295,	v_yysvec+20,	v_yyvstop+45,
v_yycrank+0,	0,		v_yyvstop+47,
v_yycrank+17,	v_yysvec+20,	v_yyvstop+50,
v_yycrank+294,	v_yysvec+20,	v_yyvstop+52,
v_yycrank+0,	0,		v_yyvstop+54,
v_yycrank+0,	0,		v_yyvstop+57,
v_yycrank+0,	0,		v_yyvstop+59,
v_yycrank+363,	0,		0,	
v_yycrank+0,	0,		v_yyvstop+61,
v_yycrank+0,	0,		v_yyvstop+63,
v_yycrank+0,	0,		v_yyvstop+65,
v_yycrank+356,	0,		0,	
v_yycrank+411,	v_yysvec+20,	v_yyvstop+67,
v_yycrank+77,	v_yysvec+20,	v_yyvstop+69,
v_yycrank+291,	v_yysvec+20,	v_yyvstop+72,
v_yycrank+412,	v_yysvec+20,	v_yyvstop+74,
v_yycrank+210,	v_yysvec+20,	v_yyvstop+76,
v_yycrank+402,	v_yysvec+20,	v_yyvstop+78,
v_yycrank+404,	v_yysvec+20,	v_yyvstop+81,
v_yycrank+408,	v_yysvec+20,	v_yyvstop+84,
v_yycrank+414,	v_yysvec+20,	v_yyvstop+86,
v_yycrank+423,	v_yysvec+20,	v_yyvstop+88,
v_yycrank+410,	v_yysvec+20,	v_yyvstop+90,
v_yycrank+424,	v_yysvec+20,	v_yyvstop+93,
v_yycrank+427,	v_yysvec+20,	v_yyvstop+95,
v_yycrank+466,	v_yysvec+20,	v_yyvstop+97,
v_yycrank+468,	v_yysvec+20,	v_yyvstop+99,
v_yycrank+462,	v_yysvec+20,	v_yyvstop+101,
v_yycrank+0,	v_yysvec+38,	v_yyvstop+105,
v_yycrank+504,	v_yysvec+42,	v_yyvstop+107,
v_yycrank+465,	v_yysvec+20,	v_yyvstop+109,
v_yycrank+486,	v_yysvec+20,	v_yyvstop+112,
v_yycrank+501,	v_yysvec+20,	v_yyvstop+114,
v_yycrank+508,	v_yysvec+20,	v_yyvstop+116,
v_yycrank+519,	v_yysvec+20,	v_yyvstop+118,
v_yycrank+504,	v_yysvec+20,	v_yyvstop+120,
v_yycrank+517,	v_yysvec+20,	v_yyvstop+123,
v_yycrank+525,	v_yysvec+20,	v_yyvstop+125,
v_yycrank+526,	v_yysvec+20,	v_yyvstop+127,
v_yycrank+555,	v_yysvec+20,	v_yyvstop+129,
v_yycrank+529,	v_yysvec+20,	v_yyvstop+131,
v_yycrank+573,	v_yysvec+20,	v_yyvstop+135,
v_yycrank+565,	v_yysvec+20,	v_yyvstop+137,
v_yycrank+569,	v_yysvec+20,	v_yyvstop+139,
v_yycrank+572,	v_yysvec+20,	v_yyvstop+142,
v_yycrank+575,	v_yysvec+20,	v_yyvstop+145,
v_yycrank+579,	v_yysvec+20,	v_yyvstop+148,
v_yycrank+576,	v_yysvec+20,	v_yyvstop+150,
v_yycrank+594,	v_yysvec+20,	v_yyvstop+153,
v_yycrank+623,	v_yysvec+20,	v_yyvstop+155,
v_yycrank+624,	v_yysvec+20,	v_yyvstop+157,
v_yycrank+627,	v_yysvec+20,	v_yyvstop+159,
v_yycrank+588,	v_yysvec+20,	v_yyvstop+161,
v_yycrank+630,	v_yysvec+20,	v_yyvstop+164,
v_yycrank+634,	v_yysvec+20,	v_yyvstop+166,
v_yycrank+636,	v_yysvec+20,	v_yyvstop+169,
v_yycrank+637,	v_yysvec+20,	v_yyvstop+172,
0,	0,	0};
struct v_yywork *v_yytop = v_yycrank+752;
struct v_yysvf *v_yybgin = v_yysvec+1;
char v_yymatch[] = {
00  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
040 ,01  ,01  ,01  ,040 ,040 ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,040 ,040 ,040 ,
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
char v_yyextra[] = {
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0};
#ident	"@(#)libl:lib/ncform	1.3	1.2 (Intergraph) 3/10/88"
int v_yylineno =1;
# define YYU(x) x
# define NLSTATE v_yyprevious=YYNEWLINE
char v_yytext[YYLMAX];
struct v_yysvf *v_yylstate [YYLMAX], **v_yylsp, **v_yyolsp;
char v_yysbuf[YYLMAX];
char *v_yysptr = v_yysbuf;
int *v_yyfnd;
extern struct v_yysvf *v_yyestate;
int v_yyprevious = YYNEWLINE;
v_yylook(){
	register struct v_yysvf *v_yystate, **lsp;
	register struct v_yywork *v_yyt;
	struct v_yysvf *v_yyz;
	int v_yych, v_yyfirst;
	struct v_yywork *v_yyr;
# ifdef LEXDEBUG
	int debug;
# endif
	char *v_yylastch;
	/* start off machines */
# ifdef LEXDEBUG
	debug = 0;
# endif
	v_yyfirst=1;
	if (!v_yymorfg)
		v_yylastch = v_yytext;
	else {
		v_yymorfg=0;
		v_yylastch = v_yytext+v_yyleng;
		}
	for(;;){
		lsp = v_yylstate;
		v_yyestate = v_yystate = v_yybgin;
		if (v_yyprevious==YYNEWLINE) v_yystate++;
		for (;;){
# ifdef LEXDEBUG
			if(debug)fprintf(v_yyout,"state %d\n",v_yystate-v_yysvec-1);
# endif
			v_yyt = v_yystate->v_yystoff;
			if(v_yyt == v_yycrank && !v_yyfirst){  /* may not be any transitions */
				v_yyz = v_yystate->v_yyother;
				if(v_yyz == 0)break;
				if(v_yyz->v_yystoff == v_yycrank)break;
				}
			*v_yylastch++ = v_yych = input();
			v_yyfirst=0;
		tryagain:
# ifdef LEXDEBUG
			if(debug){
				fprintf(v_yyout,"char ");
				allprint(v_yych);
				putchar('\n');
				}
# endif
			v_yyr = v_yyt;
			if ( (int)v_yyt > (int)v_yycrank){
				v_yyt = v_yyr + v_yych;
				if (v_yyt <= v_yytop && v_yyt->verify+v_yysvec == v_yystate){
					if(v_yyt->advance+v_yysvec == YYLERR)	/* error transitions */
						{unput(*--v_yylastch);break;}
					*lsp++ = v_yystate = v_yyt->advance+v_yysvec;
					goto contin;
					}
				}
# ifdef YYOPTIM
			else if((int)v_yyt < (int)v_yycrank) {		/* r < v_yycrank */
				v_yyt = v_yyr = v_yycrank+(v_yycrank-v_yyt);
# ifdef LEXDEBUG
				if(debug)fprintf(v_yyout,"compressed state\n");
# endif
				v_yyt = v_yyt + v_yych;
				if(v_yyt <= v_yytop && v_yyt->verify+v_yysvec == v_yystate){
					if(v_yyt->advance+v_yysvec == YYLERR)	/* error transitions */
						{unput(*--v_yylastch);break;}
					*lsp++ = v_yystate = v_yyt->advance+v_yysvec;
					goto contin;
					}
				v_yyt = v_yyr + YYU(v_yymatch[v_yych]);
# ifdef LEXDEBUG
				if(debug){
					fprintf(v_yyout,"try fall back character ");
					allprint(YYU(v_yymatch[v_yych]));
					putchar('\n');
					}
# endif
				if(v_yyt <= v_yytop && v_yyt->verify+v_yysvec == v_yystate){
					if(v_yyt->advance+v_yysvec == YYLERR)	/* error transition */
						{unput(*--v_yylastch);break;}
					*lsp++ = v_yystate = v_yyt->advance+v_yysvec;
					goto contin;
					}
				}
			if ((v_yystate = v_yystate->v_yyother) && (v_yyt= v_yystate->v_yystoff) != v_yycrank){
# ifdef LEXDEBUG
				if(debug)fprintf(v_yyout,"fall back to state %d\n",v_yystate-v_yysvec-1);
# endif
				goto tryagain;
				}
# endif
			else
				{unput(*--v_yylastch);break;}
		contin:
# ifdef LEXDEBUG
			if(debug){
				fprintf(v_yyout,"state %d char ",v_yystate-v_yysvec-1);
				allprint(v_yych);
				putchar('\n');
				}
# endif
			;
			}
# ifdef LEXDEBUG
		if(debug){
			fprintf(v_yyout,"stopped at %d with ",*(lsp-1)-v_yysvec-1);
			allprint(v_yych);
			putchar('\n');
			}
# endif
		while (lsp-- > v_yylstate){
			*v_yylastch-- = 0;
			if (*lsp != 0 && (v_yyfnd= (*lsp)->v_yystops) && *v_yyfnd > 0){
				v_yyolsp = lsp;
				if(v_yyextra[*v_yyfnd]){		/* must backup */
					while(v_yyback((*lsp)->v_yystops,-*v_yyfnd) != 1 && lsp > v_yylstate){
						lsp--;
						unput(*v_yylastch--);
						}
					}
				v_yyprevious = YYU(*v_yylastch);
				v_yylsp = lsp;
				v_yyleng = v_yylastch-v_yytext+1;
				v_yytext[v_yyleng] = 0;
# ifdef LEXDEBUG
				if(debug){
					fprintf(v_yyout,"\nmatch ");
					sprint(v_yytext);
					fprintf(v_yyout," action %d\n",*v_yyfnd);
					}
# endif
				return(*v_yyfnd++);
				}
			unput(*v_yylastch);
			}
		/* you may or may not be reading from v_yyin - we really   */
		/* can't tell at this point. So whenver v_yytext[0] is set */
		/* to 0, this indicates end of file			 */
		if (v_yytext[0] == 0 /* && feof(v_yyin) */ )
			{
			v_yysptr=v_yysbuf;
			return(0);
			}
		v_yyprevious = v_yytext[0] = input();
		if (v_yyprevious>0)
			output(v_yyprevious);
		v_yylastch=v_yytext;
# ifdef LEXDEBUG
		if(debug)putchar('\n');
# endif
		}
	}
v_yyback(p, m)
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
v_yyinput(){
	return(input());
	}
v_yyoutput(c)
  int c; {
	output(c);
	}
v_yyunput(c)
   int c; {
	unput(c);
	}
