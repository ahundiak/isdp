#include "header.h"
#include <stdio.h>
#include <string.h>
#include <ctype.h>
	extern	char	PDU_c_yytext[];
	extern  char	exp_cond[MAX_SVS_COND_LEN];	
	extern	int	NoExp, result[];

	static	int	i, j, val, type;
	static	char	c_temp[32*2], col_nam[32*2], operator[8];
	static	char 	*tbl, *col, tblcol[132], SVSquery[256];
# define _c_column_name 257
# define _c_greater 258
# define _c_greater_equal 259
# define _c_less 260
# define _c_less_equal 261
# define _c_equal 262
# define _c_un_equal 263
# define _c_not_equal 264
# define _c_not 265
# define _c_between 266
# define _c_not_between 267
# define _c_in 268
# define _c_like 269
# define _c_multiply 270
# define _c_divide 271
# define _c_add 272
# define _c_subtract 273
# define _c_open 274
# define _c_close 275
# define _c_is 276
# define _c_null 277
# define _c_string 278
# define _c_int_value 279
# define _c_real_value 280
# define _c_comma 281
# define _c_outside_or 282
# define _c_outside_and 283
# define _c_select 284
# define _c_distinct 285
# define _c_from 286
# define _c_table_name 287
#define PDU_c_yyclearin PDU_c_yychar = -1
#define PDU_c_yyerrok PDU_c_yyerrflag = 0
extern int PDU_c_yychar;
extern int PDU_c_yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
#ifndef YYSTYPE
#define YYSTYPE int
#endif
YYSTYPE PDU_c_yylval, PDU_c_yyval;
typedef int PDU_c_yytabelem;
# define YYERRCODE 256

PDU_c_yyerror(str)
char	*str;
{
	fprintf (stderr, "Error -> %s\n", exp_cond);
	return (-2);
} 
PDU_c_yytabelem PDU_c_yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
-1, 3,
	0, 2,
	-2, 4,
-1, 4,
	267, 8,
	-2, 12,
-1, 5,
	284, 16,
	-2, 23,
-1, 19,
	277, 28,
	-2, 25,
-1, 21,
	278, 34,
	-2, 49,
-1, 22,
	278, 36,
	-2, 48,
-1, 33,
	0, 40,
	282, 40,
	283, 40,
	-2, 39,
	};
# define YYNPROD 56
# define YYLAST 141
PDU_c_yytabelem PDU_c_yyact[]={

    24,    25,    26,    27,    49,    28,    48,    83,    79,    24,
    25,    26,    27,    21,    28,    22,    18,    59,    44,    23,
    20,    13,    14,     8,    13,    14,    66,    19,    84,    60,
    11,     9,    10,    58,    61,    61,    57,    56,    73,    55,
    85,    72,    43,    37,    11,     9,    10,    24,    25,    26,
    27,    49,    28,    48,    52,    34,    35,    54,    68,     4,
     7,    45,    12,     3,     6,    47,    69,    42,    41,    40,
    15,    53,    39,    67,    38,    32,    31,    30,    78,    65,
    33,    36,    74,    29,     5,    77,    51,    17,    76,    50,
    16,    46,     2,     1,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
    63,    64,    62,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,    70,    71,     0,     0,
    75,     0,     0,     0,     0,     0,    80,    81,     0,    46,
    82 };
PDU_c_yytabelem PDU_c_yypact[]={

  -234, -1000,  -261, -1000,  -249, -1000, -1000, -1000, -1000, -1000,
 -1000, -1000,  -234, -1000, -1000,  -234,  -212,  -210,  -226, -1000,
 -1000, -1000, -1000,  -232, -1000, -1000, -1000, -1000, -1000,  -266,
  -248, -1000,  -211, -1000, -1000, -1000,  -214, -1000,  -208,  -238,
  -241,  -242,  -245, -1000,  -268,  -246, -1000,  -234, -1000, -1000,
  -234,  -234, -1000,  -252, -1000, -1000, -1000, -1000, -1000,  -199,
 -1000, -1000, -1000,  -258,  -258,  -233, -1000,  -239, -1000,  -248,
 -1000, -1000, -1000, -1000,  -278, -1000,  -234,  -234,  -248,  -280,
  -211,  -211,  -247,  -235, -1000, -1000 };
PDU_c_yytabelem PDU_c_yypgo[]={

     0,    93,    92,    63,    62,    59,    65,    90,    89,    88,
    87,    86,    85,    84,    83,    82,    81,    79,    78,    61,
    77,    74,    73,    72,    71,    69,    68,    67,    64,    60,
    66 };
PDU_c_yytabelem PDU_c_yyr1[]={

     0,     1,     1,     2,     2,     4,     4,     3,     7,     8,
     9,     3,    10,    11,    12,     3,    14,    15,     3,    16,
    17,    18,     3,    20,     3,    21,    22,     3,    23,     3,
    24,     3,    25,     3,    26,     3,    27,     3,    13,     5,
     5,    28,    28,     6,     6,     6,     6,     6,     6,     6,
    30,    19,    19,    29,    29,    29 };
PDU_c_yytabelem PDU_c_yyr2[]={

     0,     3,     3,     7,     3,     2,     3,     7,     1,     1,
     1,    17,     1,     1,     1,    17,     1,     1,    18,     1,
     1,     1,    19,     1,     9,     1,     1,    13,     1,     9,
     1,    11,     1,     9,     1,     9,     1,     9,     6,     6,
     2,     2,     3,     3,     3,     3,     3,     3,     3,     3,
     1,     8,     2,     3,     3,     3 };
PDU_c_yytabelem PDU_c_yychk[]={

 -1000,    -1,    -2,    -3,    -5,   -13,   -28,   -29,   257,   279,
   280,   278,    -4,   282,   283,    -6,    -7,   -10,   265,   276,
   269,   262,   264,   268,   258,   259,   260,   261,   263,   -14,
   -20,    -3,    -5,   -28,   267,   266,   -16,   269,   -21,   -23,
   -25,   -26,   -27,   274,   284,   -19,   -29,    -6,   264,   262,
    -8,   -11,   268,   -24,   265,   277,   278,   278,   278,   285,
   275,   281,   -28,    -5,    -5,   -17,   278,   -22,   257,   -30,
    -4,    -4,   274,   277,   -15,   -29,    -9,   -12,   -18,   286,
    -5,    -5,   -19,   287,   275,   275 };
PDU_c_yytabelem PDU_c_yydef[]={

     0,    -2,     1,    -2,    -2,    -2,    40,    41,    42,    53,
    54,    55,     0,     5,     6,     0,     0,     0,    19,    -2,
    32,    -2,    -2,     0,    43,    44,    45,    46,    47,     0,
     0,     3,     7,    -2,     9,    13,     0,    30,     0,     0,
     0,     0,     0,    38,     0,     0,    52,     0,    48,    49,
     0,     0,    20,     0,    26,    29,    33,    35,    37,     0,
    24,    50,    39,     0,     0,     0,    31,     0,    17,     0,
    10,    14,    21,    27,     0,    51,     0,     0,     0,     0,
    11,    15,     0,     0,    22,    18 };
typedef struct { char *t_name; int t_val; } PDU_c_yytoktype;
#ifndef YYDEBUG
#	define YYDEBUG	1	/* allow debugging */
#endif

#if YYDEBUG

PDU_c_yytoktype PDU_c_yytoks[] =
{
	"_c_column_name",	257,
	"_c_greater",	258,
	"_c_greater_equal",	259,
	"_c_less",	260,
	"_c_less_equal",	261,
	"_c_equal",	262,
	"_c_un_equal",	263,
	"_c_not_equal",	264,
	"_c_not",	265,
	"_c_between",	266,
	"_c_not_between",	267,
	"_c_in",	268,
	"_c_like",	269,
	"_c_multiply",	270,
	"_c_divide",	271,
	"_c_add",	272,
	"_c_subtract",	273,
	"_c_open",	274,
	"_c_close",	275,
	"_c_is",	276,
	"_c_null",	277,
	"_c_string",	278,
	"_c_int_value",	279,
	"_c_real_value",	280,
	"_c_comma",	281,
	"_c_outside_or",	282,
	"_c_outside_and",	283,
	"_c_select",	284,
	"_c_distinct",	285,
	"_c_from",	286,
	"_c_table_name",	287,
	"-unknown-",	-1	/* ends search */
};

char * PDU_c_yyreds[] =
{
	"-no such reduction-",
	"whole_condition : complex_condition",
	"whole_condition : condition",
	"complex_condition : complex_condition conj condition",
	"complex_condition : condition",
	"conj : _c_outside_or",
	"conj : _c_outside_and",
	"condition : expression oper expression",
	"condition : expression",
	"condition : expression _c_not_between",
	"condition : expression _c_not_between expression conj",
	"condition : expression _c_not_between expression conj expression",
	"condition : expression",
	"condition : expression _c_between",
	"condition : expression _c_between expression conj",
	"condition : expression _c_between expression conj expression",
	"condition : expression_in_paranth",
	"condition : expression_in_paranth _c_select _c_distinct _c_column_name",
	"condition : expression_in_paranth _c_select _c_distinct _c_column_name _c_from _c_table_name _c_close",
	"condition : expression _c_not",
	"condition : expression _c_not _c_in",
	"condition : expression _c_not _c_in _c_open",
	"condition : expression _c_not _c_in _c_open value_list _c_close",
	"condition : expression_in_paranth",
	"condition : expression_in_paranth value_list _c_close",
	"condition : expression _c_is",
	"condition : expression _c_is _c_not",
	"condition : expression _c_is _c_not _c_null",
	"condition : expression _c_is",
	"condition : expression _c_is _c_null",
	"condition : expression _c_not _c_like",
	"condition : expression _c_not _c_like _c_string",
	"condition : expression _c_like",
	"condition : expression _c_like _c_string",
	"condition : expression _c_equal",
	"condition : expression _c_equal _c_string",
	"condition : expression _c_not_equal",
	"condition : expression _c_not_equal _c_string",
	"expression_in_paranth : expression _c_in _c_open",
	"expression : expression oper operand",
	"expression : operand",
	"operand : value",
	"operand : _c_column_name",
	"oper : _c_greater",
	"oper : _c_greater_equal",
	"oper : _c_less",
	"oper : _c_less_equal",
	"oper : _c_un_equal",
	"oper : _c_not_equal",
	"oper : _c_equal",
	"value_list : value_list _c_comma",
	"value_list : value_list _c_comma value",
	"value_list : value",
	"value : _c_int_value",
	"value : _c_real_value",
	"value : _c_string",
};
#endif /* YYDEBUG */
/* #ident	"@(#)yacc:yaccpar	1.10	1.3 (Intergraph) 3/10/88" */

/*
** Skeleton parser driver for yacc output
*/

/*
** yacc user known macros and defines
*/
#define YYERROR		goto PDU_c_yyerrlab
#define YYACCEPT	return(0)
#define YYABORT		return(1)
#define YYBACKUP( newtoken, newvalue )\
{\
	if ( PDU_c_yychar >= 0 || ( PDU_c_yyr2[ PDU_c_yytmp ] >> 1 ) != 1 )\
	{\
		PDU_c_yyerror( "syntax error - cannot backup" );\
		goto PDU_c_yyerrlab;\
	}\
	PDU_c_yychar = newtoken;\
	PDU_c_yystate = *PDU_c_yyps;\
	PDU_c_yylval = newvalue;\
	goto PDU_c_yynewstate;\
}
#define YYRECOVERING()	(!!PDU_c_yyerrflag)
#ifndef YYDEBUG
#	define YYDEBUG	1	/* make debugging available */
#endif

/*
** user known globals
*/
int PDU_c_yydebug;			/* set to 1 to get debugging */

/*
** driver internal defines
*/
#define YYFLAG		(-1000)

/*
** global variables used by the parser
*/
YYSTYPE PDU_c_yyv[ YYMAXDEPTH ];	/* value stack */
int PDU_c_yys[ YYMAXDEPTH ];		/* state stack */

YYSTYPE *PDU_c_yypv;			/* top of value stack */
int *PDU_c_yyps;			/* top of state stack */

int PDU_c_yystate;			/* current state */
int PDU_c_yytmp;			/* extra var (lasts between blocks) */

int PDU_c_yynerrs;			/* number of errors */
int PDU_c_yyerrflag;			/* error recovery flag */
int PDU_c_yychar;			/* current input token number */



/*
** PDU_c_yyparse - return 0 if worked, 1 if syntax error not recovered from
*/
int
PDU_c_yyparse()
{
	register YYSTYPE *PDU_c_yypvt;	/* top of value stack for $vars */

	/*
	** Initialize externals - PDU_c_yyparse may be called more than once
	*/
	PDU_c_yypv = &PDU_c_yyv[-1];
	PDU_c_yyps = &PDU_c_yys[-1];
	PDU_c_yystate = 0;
	PDU_c_yytmp = 0;
	PDU_c_yynerrs = 0;
	PDU_c_yyerrflag = 0;
	PDU_c_yychar = -1;

	goto PDU_c_yystack;
	{
		register YYSTYPE *PDU_c_yy_pv;	/* top of value stack */
		register int *PDU_c_yy_ps;		/* top of state stack */
		register int PDU_c_yy_state;		/* current state */
		register int  PDU_c_yy_n;		/* internal state number info */

		/*
		** get globals into registers.
		** branch to here only if YYBACKUP was called.
		*/
	PDU_c_yynewstate:
		PDU_c_yy_pv = PDU_c_yypv;
		PDU_c_yy_ps = PDU_c_yyps;
		PDU_c_yy_state = PDU_c_yystate;
		goto PDU_c_yy_newstate;

		/*
		** get globals into registers.
		** either we just started, or we just finished a reduction
		*/
	PDU_c_yystack:
		PDU_c_yy_pv = PDU_c_yypv;
		PDU_c_yy_ps = PDU_c_yyps;
		PDU_c_yy_state = PDU_c_yystate;

		/*
		** top of for (;;) loop while no reductions done
		*/
	PDU_c_yy_stack:
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
		if ( PDU_c_yydebug )
		{
			register int PDU_c_yy_i;

			printf( "State %d, token ", PDU_c_yy_state );
			if ( PDU_c_yychar == 0 )
				printf( "end-of-file\n" );
			else if ( PDU_c_yychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( PDU_c_yy_i = 0; PDU_c_yytoks[PDU_c_yy_i].t_val >= 0;
					PDU_c_yy_i++ )
				{
					if ( PDU_c_yytoks[PDU_c_yy_i].t_val == PDU_c_yychar )
						break;
				}
				printf( "%s\n", PDU_c_yytoks[PDU_c_yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ++PDU_c_yy_ps >= &PDU_c_yys[ YYMAXDEPTH ] )	/* room on stack? */
		{
			PDU_c_yyerror( "yacc stack overflow" );
			YYABORT;
		}
		*PDU_c_yy_ps = PDU_c_yy_state;
		*++PDU_c_yy_pv = PDU_c_yyval;

		/*
		** we have a new state - find out what to do
		*/
	PDU_c_yy_newstate:
		if ( ( PDU_c_yy_n = PDU_c_yypact[ PDU_c_yy_state ] ) <= YYFLAG )
			goto PDU_c_yydefault;		/* simple state */
#if YYDEBUG
		/*
		** if debugging, need to mark whether new token grabbed
		*/
		PDU_c_yytmp = PDU_c_yychar < 0;
#endif
		if ( ( PDU_c_yychar < 0 ) && ( ( PDU_c_yychar = PDU_c_yylex() ) < 0 ) )
			PDU_c_yychar = 0;		/* reached EOF */
#if YYDEBUG
		if ( PDU_c_yydebug && PDU_c_yytmp )
		{
			register int PDU_c_yy_i;

			printf( "Received token " );
			if ( PDU_c_yychar == 0 )
				printf( "end-of-file\n" );
			else if ( PDU_c_yychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( PDU_c_yy_i = 0; PDU_c_yytoks[PDU_c_yy_i].t_val >= 0;
					PDU_c_yy_i++ )
				{
					if ( PDU_c_yytoks[PDU_c_yy_i].t_val == PDU_c_yychar )
						break;
				}
				printf( "%s\n", PDU_c_yytoks[PDU_c_yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ( ( PDU_c_yy_n += PDU_c_yychar ) < 0 ) || ( PDU_c_yy_n >= YYLAST ) )
			goto PDU_c_yydefault;
		if ( PDU_c_yychk[ PDU_c_yy_n = PDU_c_yyact[ PDU_c_yy_n ] ] == PDU_c_yychar )	/*valid shift*/
		{
			PDU_c_yychar = -1;
			PDU_c_yyval = PDU_c_yylval;
			PDU_c_yy_state = PDU_c_yy_n;
			if ( PDU_c_yyerrflag > 0 )
				PDU_c_yyerrflag--;
			goto PDU_c_yy_stack;
		}

	PDU_c_yydefault:
		if ( ( PDU_c_yy_n = PDU_c_yydef[ PDU_c_yy_state ] ) == -2 )
		{
#if YYDEBUG
			PDU_c_yytmp = PDU_c_yychar < 0;
#endif
			if ( ( PDU_c_yychar < 0 ) && ( ( PDU_c_yychar = PDU_c_yylex() ) < 0 ) )
				PDU_c_yychar = 0;		/* reached EOF */
#if YYDEBUG
			if ( PDU_c_yydebug && PDU_c_yytmp )
			{
				register int PDU_c_yy_i;

				printf( "Received token " );
				if ( PDU_c_yychar == 0 )
					printf( "end-of-file\n" );
				else if ( PDU_c_yychar < 0 )
					printf( "-none-\n" );
				else
				{
					for ( PDU_c_yy_i = 0;
						PDU_c_yytoks[PDU_c_yy_i].t_val >= 0;
						PDU_c_yy_i++ )
					{
						if ( PDU_c_yytoks[PDU_c_yy_i].t_val
							== PDU_c_yychar )
						{
							break;
						}
					}
					printf( "%s\n", PDU_c_yytoks[PDU_c_yy_i].t_name );
				}
			}
#endif /* YYDEBUG */
			/*
			** look through exception table
			*/
			{
				register int *PDU_c_yyxi = PDU_c_yyexca;

				while ( ( *PDU_c_yyxi != -1 ) ||
					( PDU_c_yyxi[1] != PDU_c_yy_state ) )
				{
					PDU_c_yyxi += 2;
				}
				while ( ( *(PDU_c_yyxi += 2) >= 0 ) &&
					( *PDU_c_yyxi != PDU_c_yychar ) )
					;
				if ( ( PDU_c_yy_n = PDU_c_yyxi[1] ) < 0 )
					YYACCEPT;
			}
		}

		/*
		** check for syntax error
		*/
		if ( PDU_c_yy_n == 0 )	/* have an error */
		{
			/* no worry about speed here! */
			switch ( PDU_c_yyerrflag )
			{
			case 0:		/* new error */
				PDU_c_yyerror( "syntax error" );
				goto skip_init;
			PDU_c_yyerrlab:
				/*
				** get globals into registers.
				** we have a user generated syntax type error
				*/
				PDU_c_yy_pv = PDU_c_yypv;
				PDU_c_yy_ps = PDU_c_yyps;
				PDU_c_yy_state = PDU_c_yystate;
				PDU_c_yynerrs++;
			skip_init:
			case 1:
			case 2:		/* incompletely recovered error */
					/* try again... */
				PDU_c_yyerrflag = 3;
				/*
				** find state where "error" is a legal
				** shift action
				*/
				while ( PDU_c_yy_ps >= PDU_c_yys )
				{
					PDU_c_yy_n = PDU_c_yypact[ *PDU_c_yy_ps ] + YYERRCODE;
					if ( PDU_c_yy_n >= 0 && PDU_c_yy_n < YYLAST &&
						PDU_c_yychk[PDU_c_yyact[PDU_c_yy_n]] == YYERRCODE)					{
						/*
						** simulate shift of "error"
						*/
						PDU_c_yy_state = PDU_c_yyact[ PDU_c_yy_n ];
						goto PDU_c_yy_stack;
					}
					/*
					** current state has no shift on
					** "error", pop stack
					*/
#if YYDEBUG
#	define _POP_ "Error recovery pops state %d, uncovers state %d\n"
					if ( PDU_c_yydebug )
						printf( _POP_, *PDU_c_yy_ps,
							PDU_c_yy_ps[-1] );
#	undef _POP_
#endif
					PDU_c_yy_ps--;
					PDU_c_yy_pv--;
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
				if ( PDU_c_yydebug )
				{
					register int PDU_c_yy_i;

					printf( "Error recovery discards " );
					if ( PDU_c_yychar == 0 )
						printf( "token end-of-file\n" );
					else if ( PDU_c_yychar < 0 )
						printf( "token -none-\n" );
					else
					{
						for ( PDU_c_yy_i = 0;
							PDU_c_yytoks[PDU_c_yy_i].t_val >= 0;
							PDU_c_yy_i++ )
						{
							if ( PDU_c_yytoks[PDU_c_yy_i].t_val
								== PDU_c_yychar )
							{
								break;
							}
						}
						printf( "token %s\n",
							PDU_c_yytoks[PDU_c_yy_i].t_name );
					}
				}
#endif /* YYDEBUG */
				if ( PDU_c_yychar == 0 )	/* reached EOF. quit */
					YYABORT;
				PDU_c_yychar = -1;
				goto PDU_c_yy_newstate;
			}
		}/* end if ( PDU_c_yy_n == 0 ) */
		/*
		** reduction by production PDU_c_yy_n
		** put stack tops, etc. so things right after switch
		*/
#if YYDEBUG
		/*
		** if debugging, print the string that is the user's
		** specification of the reduction which is just about
		** to be done.
		*/
		if ( PDU_c_yydebug )
			printf( "Reduce by (%d) \"%s\"\n",
				PDU_c_yy_n, PDU_c_yyreds[ PDU_c_yy_n ] );
#endif
		PDU_c_yytmp = PDU_c_yy_n;			/* value to switch over */
		PDU_c_yypvt = PDU_c_yy_pv;			/* $vars top of value stack */
		/*
		** Look in goto table for next state
		** Sorry about using PDU_c_yy_state here as temporary
		** register variable, but why not, if it works...
		** If PDU_c_yyr2[ PDU_c_yy_n ] doesn't have the low order bit
		** set, then there is no action to be done for
		** this reduction.  So, no saving & unsaving of
		** registers done.  The only difference between the
		** code just after the if and the body of the if is
		** the goto PDU_c_yy_stack in the body.  This way the test
		** can be made before the choice of what to do is needed.
		*/
		{
			/* length of production doubled with extra bit */
			register int PDU_c_yy_len = PDU_c_yyr2[ PDU_c_yy_n ];

			if ( !( PDU_c_yy_len & 01 ) )
			{
				PDU_c_yy_len >>= 1;
				PDU_c_yyval = ( PDU_c_yy_pv -= PDU_c_yy_len )[1];	/* $$ = $1 */
				PDU_c_yy_state = PDU_c_yypgo[ PDU_c_yy_n = PDU_c_yyr1[ PDU_c_yy_n ] ] +
					*( PDU_c_yy_ps -= PDU_c_yy_len ) + 1;
				if ( PDU_c_yy_state >= YYLAST ||
					PDU_c_yychk[ PDU_c_yy_state =
					PDU_c_yyact[ PDU_c_yy_state ] ] != -PDU_c_yy_n )
				{
					PDU_c_yy_state = PDU_c_yyact[ PDU_c_yypgo[ PDU_c_yy_n ] ];
				}
				goto PDU_c_yy_stack;
			}
			PDU_c_yy_len >>= 1;
			PDU_c_yyval = ( PDU_c_yy_pv -= PDU_c_yy_len )[1];	/* $$ = $1 */
			PDU_c_yy_state = PDU_c_yypgo[ PDU_c_yy_n = PDU_c_yyr1[ PDU_c_yy_n ] ] +
				*( PDU_c_yy_ps -= PDU_c_yy_len ) + 1;
			if ( PDU_c_yy_state >= YYLAST ||
				PDU_c_yychk[ PDU_c_yy_state = PDU_c_yyact[ PDU_c_yy_state ] ] != -PDU_c_yy_n )
			{
				PDU_c_yy_state = PDU_c_yyact[ PDU_c_yypgo[ PDU_c_yy_n ] ];
			}
		}
					/* save until reenter driver code */
		PDU_c_yystate = PDU_c_yy_state;
		PDU_c_yyps = PDU_c_yy_ps;
		PDU_c_yypv = PDU_c_yy_pv;
	}
	/*
	** code supplied by user is placed in this switch
	*/
	switch( PDU_c_yytmp )
	{
		
case 1:{ return (1); } break;
case 2:{ return (0) ; } break;
case 3:{ NoExp++; } break;
case 4:{ NoExp++; } break;
case 6:{ strcat (exp_cond, " && "); } break;
case 7:{ strcat (exp_cond, "~");
		     result[NoExp] = (Expression (val, operator, exp_cond));
	           } break;
case 8:{ strcpy (col_nam, c_temp); } break;
case 9:{ strcat (exp_cond, " <= "); } break;
case 10:{ strcat (exp_cond, " || ");
		     strcat (exp_cond, col_nam);
		     strcat (exp_cond, " >= ");
	           } break;
case 11:{ strcat (exp_cond, "~");
		     result[NoExp] = (Between (type, "<=", exp_cond));
		   } break;
case 12:{ strcpy (col_nam, c_temp); } break;
case 13:{ strcat (exp_cond, " >= "); } break;
case 14:{ strcat (exp_cond, " && ");
		     strcat (exp_cond, col_nam);
		     strcat (exp_cond, " <= ");
		   } break;
case 15:{ 
		     strcat (exp_cond, "~");
    		     result[NoExp] = (Between (type, ">=", exp_cond));
		   } break;
case 16:{
		     strcpy (col_nam, c_temp);
		   } break;
case 17:{
		     strcpy (tblcol, PDU_c_yytext);
		     strcat (tblcol, "~");
		     tbl = strtok (tblcol, ".");
		     col = strtok (NULL, "~");
		     sprintf (SVSquery,
		     "select DISTINCT %s.%s from %s where %s.%s = ",
		     tbl, col, tbl, tbl, col);
		     result[NoExp] = IsValueInTable (SVSquery, col_nam); 
		   } break;
case 19:{ strcat (exp_cond, " not "); } break;
case 20:{ strcat (exp_cond, " in "); } break;
case 21:{ strcat (exp_cond, " ( "); } break;
case 22:{ strcat (exp_cond, " ) "); 
		     strcat (exp_cond, "~");
		     result[NoExp] = (InValueList (0, exp_cond));
		   } break;
case 23:{
		     strcat (exp_cond, " in ");
		     strcat (exp_cond, " ( ");
		   } break;
case 24:{ strcat (exp_cond, " ) ");
		     strcat (exp_cond, "~");
		     result[NoExp] = (InValueList (1, exp_cond));
		   } break;
case 25:{ strcat (exp_cond, " is "); } break;
case 26:{ strcat (exp_cond, " not "); } break;
case 27:{ strcat (exp_cond, " null "); 
		     strcat (exp_cond, "~");
		     result[NoExp] = (IsNull (0, exp_cond));
		   } break;
case 28:{ strcat (exp_cond, " is "); } break;
case 29:{ strcat (exp_cond, " null "); 
		     strcat (exp_cond, "~");
		     result[NoExp] = (IsNull (1, exp_cond));
		   } break;
case 30:{ strcat (exp_cond, " != "); } break;
case 31:{ strcat (exp_cond, PDU_c_yytext); 
		     strcat (exp_cond, "~");
		     result[NoExp] = (LikeString (0, exp_cond));
		   } break;
case 32:{ strcat (exp_cond, " = "); } break;
case 33:{ strcat (exp_cond, PDU_c_yytext); 
		     strcat (exp_cond, "~");
		     result[NoExp] = (LikeString (1, exp_cond));
		   } break;
case 34:{ strcat (exp_cond, " = "); } break;
case 35:{ strcat (exp_cond, PDU_c_yytext); 
		    strcat (exp_cond, "~");
		    strcpy (operator, "=");
		    result[NoExp] = (StringExpression (operator, exp_cond));
		   } break;
case 36:{ strcat (exp_cond, " != "); } break;
case 37:{ strcat (exp_cond, PDU_c_yytext); 
		     strcat (exp_cond, "~");
		    strcpy (operator, "!=");
		    result[NoExp] = (StringExpression (operator, exp_cond));
		   } break;
case 42:{ 
		    strcpy (exp_cond, PDU_c_yytext); 
		    strcpy (c_temp, PDU_c_yytext);
		  } break;
case 43:{ strcat (exp_cond,  " > "); 
		    val = 0;
		    strcpy (operator, ">");
		  } break;
case 44:{ strcat (exp_cond,  " >= "); 
		    val = 1;
		    strcpy (operator, ">=");
		  } break;
case 45:{ strcat (exp_cond,  " < "); 
		    val = 2;
		    strcpy (operator, "<");
		  } break;
case 46:{ strcat (exp_cond,  " <= "); 
		    val = 3;
		    strcpy (operator, "<=");
		  } break;
case 47:{ strcat (exp_cond,  " <> "); 
		    val =4;
		    strcpy (operator, "<>");
		  } break;
case 48:{ strcat (exp_cond,  " != "); 
		    val = 5;
		    strcpy (operator, "!=");
		  } break;
case 49:{ strcat (exp_cond,  " = "); 
		    val = 6;
		    strcpy (operator, "=");
		  } break;
case 50:{strcat (exp_cond, ","); } break;
case 53:{ strcat (exp_cond,  PDU_c_yytext);
		    type = 0;
		  } break;
case 54:{ strcat (exp_cond,  PDU_c_yytext); 
		    type = 0;
		  } break;
case 55:{ strcat (exp_cond, PDU_c_yytext);
		    type = 1;
		  } break;
	}
	goto PDU_c_yystack;		/* reset registers in driver code */
}
