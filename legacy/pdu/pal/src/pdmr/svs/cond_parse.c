#include "header.h"

# line 2 "cond.y"
	extern	char	c_yytext[];
	extern  char	exp_cond[MAX_SVS_COND_LEN];	
	extern	int	NoExp, result[];

	int	i, j, val, type;
	char	c_temp[32*2], col_nam[32*2], operator[8];
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
#define c_yyclearin c_yychar = -1
#define c_yyerrok c_yyerrflag = 0
extern int c_yychar;
extern int c_yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
#ifndef YYSTYPE
#define YYSTYPE int
#endif
YYSTYPE c_yylval, c_yyval;
typedef int c_yytabelem;
# define YYERRCODE 256

# line 219 "cond.y"

c_yyerror(str)
char	*str;
{
	fprintf (stderr, "Error -> %s\n", exp_cond);
	return (-2);
} 
c_yytabelem c_yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
-1, 3,
	0, 2,
	-2, 4,
-1, 4,
	267, 8,
	-2, 12,
-1, 19,
	277, 26,
	-2, 23,
-1, 21,
	278, 32,
	-2, 46,
-1, 22,
	278, 34,
	-2, 45,
-1, 30,
	0, 37,
	282, 37,
	283, 37,
	-2, 36,
	};
# define YYNPROD 53
# define YYLAST 129
c_yytabelem c_yyact[]={

    23,    24,    25,    26,    43,    27,    42,    59,    23,    24,
    25,    26,    21,    27,    22,    18,    12,    13,    17,    20,
     7,    77,    69,    53,    12,    13,    19,    70,    70,    10,
     8,     9,    52,    51,    66,    50,    65,    35,    46,    47,
    31,    10,     8,     9,    23,    24,    25,    26,    43,    27,
    42,    32,    49,     6,     4,    63,    11,    41,     3,     5,
    74,    40,    14,    39,    38,    48,    37,    60,    36,    29,
    28,    71,    58,    34,    30,    57,    33,    68,    45,    16,
    67,    44,    15,     2,     1,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,    55,
    56,    54,     0,     0,     0,     0,     0,     0,     0,     0,
     0,    64,    61,    62,     0,     0,     0,     0,     0,     0,
     0,     0,    72,    73,     0,    64,     0,    75,    76 };
c_yytabelem c_yypact[]={

  -237, -1000,  -266, -1000,  -250, -1000, -1000, -1000, -1000, -1000,
 -1000,  -237, -1000, -1000,  -237,  -227,  -215, -1000,  -232, -1000,
 -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000, -1000,  -214,
 -1000, -1000, -1000,  -236,  -229, -1000,  -213,  -242,  -245,  -246,
  -255,  -237, -1000, -1000,  -237,  -237, -1000, -1000,  -271, -1000,
 -1000, -1000, -1000, -1000, -1000,  -258,  -258,  -249,  -238, -1000,
  -243, -1000, -1000,  -253, -1000, -1000, -1000,  -237,  -237, -1000,
 -1000,  -249,  -214,  -214,  -249,  -254, -1000, -1000 };
c_yytabelem c_yypgo[]={

     0,    84,    83,    58,    56,    54,    57,    82,    81,    80,
    79,    78,    77,    76,    75,    55,    73,    72,    71,    68,
    67,    66,    65,    64,    63,    61,    59,    53,    60 };
c_yytabelem c_yyr1[]={

     0,     1,     1,     2,     2,     4,     4,     3,     7,     8,
     9,     3,    10,    11,    12,     3,    13,    14,     3,    16,
    17,    18,     3,    19,    20,     3,    21,     3,    22,     3,
    23,     3,    24,     3,    25,     3,     5,     5,    26,    26,
     6,     6,     6,     6,     6,     6,     6,    28,    15,    15,
    27,    27,    27 };
c_yytabelem c_yyr2[]={

     0,     3,     3,     7,     3,     2,     3,     7,     1,     1,
     1,    17,     1,     1,     1,    17,     1,     1,    15,     1,
     1,     1,    19,     1,     1,    13,     1,     9,     1,    11,
     1,     9,     1,     9,     1,     9,     6,     2,     2,     3,
     3,     3,     3,     3,     3,     3,     3,     1,     8,     2,
     3,     3,     3 };
c_yytabelem c_yychk[]={

 -1000,    -1,    -2,    -3,    -5,   -26,   -27,   257,   279,   280,
   278,    -4,   282,   283,    -6,    -7,   -10,   268,   265,   276,
   269,   262,   264,   258,   259,   260,   261,   263,    -3,    -5,
   -26,   267,   266,   -13,   -16,   269,   -19,   -21,   -23,   -24,
   -25,    -6,   264,   262,    -8,   -11,   274,   268,   -22,   265,
   277,   278,   278,   278,   -26,    -5,    -5,   -14,   -17,   278,
   -20,    -4,    -4,   -15,   -27,   274,   277,    -9,   -12,   275,
   281,   -18,    -5,    -5,   -28,   -15,   -27,   275 };
c_yytabelem c_yydef[]={

     0,    -2,     1,    -2,    -2,    37,    38,    39,    50,    51,
    52,     0,     5,     6,     0,     0,     0,    16,    19,    -2,
    30,    -2,    -2,    40,    41,    42,    43,    44,     3,     7,
    -2,     9,    13,     0,     0,    28,     0,     0,     0,     0,
     0,     0,    45,    46,     0,     0,    17,    20,     0,    24,
    27,    31,    33,    35,    36,     0,     0,     0,     0,    29,
     0,    10,    14,     0,    49,    21,    25,     0,     0,    18,
    47,     0,    11,    15,     0,     0,    48,    22 };
typedef struct { char *t_name; int t_val; } c_yytoktype;
#ifndef YYDEBUG
#	define YYDEBUG	0	/* don't allow debugging */
#endif

#if YYDEBUG

c_yytoktype c_yytoks[] =
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
	"-unknown-",	-1	/* ends search */
};

char * c_yyreds[] =
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
	"condition : expression _c_in",
	"condition : expression _c_in _c_open",
	"condition : expression _c_in _c_open value_list _c_close",
	"condition : expression _c_not",
	"condition : expression _c_not _c_in",
	"condition : expression _c_not _c_in _c_open",
	"condition : expression _c_not _c_in _c_open value_list _c_close",
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
#define YYERROR		goto c_yyerrlab
#define YYACCEPT	return(0)
#define YYABORT		return(1)
#define YYBACKUP( newtoken, newvalue )\
{\
	if ( c_yychar >= 0 || ( c_yyr2[ c_yytmp ] >> 1 ) != 1 )\
	{\
		c_yyerror( "syntax error - cannot backup" );\
		goto c_yyerrlab;\
	}\
	c_yychar = newtoken;\
	c_yystate = *c_yyps;\
	c_yylval = newvalue;\
	goto c_yynewstate;\
}
#define YYRECOVERING()	(!!c_yyerrflag)
#ifndef YYDEBUG
#	define YYDEBUG	1	/* make debugging available */
#endif

/*
** user known globals
*/
int c_yydebug;			/* set to 1 to get debugging */

/*
** driver internal defines
*/
#define YYFLAG		(-1000)

/*
** global variables used by the parser
*/
YYSTYPE c_yyv[ YYMAXDEPTH ];	/* value stack */
int c_yys[ YYMAXDEPTH ];		/* state stack */

YYSTYPE *c_yypv;			/* top of value stack */
int *c_yyps;			/* top of state stack */

int c_yystate;			/* current state */
int c_yytmp;			/* extra var (lasts between blocks) */

int c_yynerrs;			/* number of errors */
int c_yyerrflag;			/* error recovery flag */
int c_yychar;			/* current input token number */



/*
** c_yyparse - return 0 if worked, 1 if syntax error not recovered from
*/
int
c_yyparse()
{
	register YYSTYPE *c_yypvt;	/* top of value stack for $vars */

	/*
	** Initialize externals - c_yyparse may be called more than once
	*/
	c_yypv = &c_yyv[-1];
	c_yyps = &c_yys[-1];
	c_yystate = 0;
	c_yytmp = 0;
	c_yynerrs = 0;
	c_yyerrflag = 0;
	c_yychar = -1;

	goto c_yystack;
	{
		register YYSTYPE *c_yy_pv;	/* top of value stack */
		register int *c_yy_ps;		/* top of state stack */
		register int c_yy_state;		/* current state */
		register int  c_yy_n;		/* internal state number info */

		/*
		** get globals into registers.
		** branch to here only if YYBACKUP was called.
		*/
	c_yynewstate:
		c_yy_pv = c_yypv;
		c_yy_ps = c_yyps;
		c_yy_state = c_yystate;
		goto c_yy_newstate;

		/*
		** get globals into registers.
		** either we just started, or we just finished a reduction
		*/
	c_yystack:
		c_yy_pv = c_yypv;
		c_yy_ps = c_yyps;
		c_yy_state = c_yystate;

		/*
		** top of for (;;) loop while no reductions done
		*/
	c_yy_stack:
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
		if ( c_yydebug )
		{
			register int c_yy_i;

			printf( "State %d, token ", c_yy_state );
			if ( c_yychar == 0 )
				printf( "end-of-file\n" );
			else if ( c_yychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( c_yy_i = 0; c_yytoks[c_yy_i].t_val >= 0;
					c_yy_i++ )
				{
					if ( c_yytoks[c_yy_i].t_val == c_yychar )
						break;
				}
				printf( "%s\n", c_yytoks[c_yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ++c_yy_ps >= &c_yys[ YYMAXDEPTH ] )	/* room on stack? */
		{
			c_yyerror( "yacc stack overflow" );
			YYABORT;
		}
		*c_yy_ps = c_yy_state;
		*++c_yy_pv = c_yyval;

		/*
		** we have a new state - find out what to do
		*/
	c_yy_newstate:
		if ( ( c_yy_n = c_yypact[ c_yy_state ] ) <= YYFLAG )
			goto c_yydefault;		/* simple state */
#if YYDEBUG
		/*
		** if debugging, need to mark whether new token grabbed
		*/
		c_yytmp = c_yychar < 0;
#endif
		if ( ( c_yychar < 0 ) && ( ( c_yychar = c_yylex() ) < 0 ) )
			c_yychar = 0;		/* reached EOF */
#if YYDEBUG
		if ( c_yydebug && c_yytmp )
		{
			register int c_yy_i;

			printf( "Received token " );
			if ( c_yychar == 0 )
				printf( "end-of-file\n" );
			else if ( c_yychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( c_yy_i = 0; c_yytoks[c_yy_i].t_val >= 0;
					c_yy_i++ )
				{
					if ( c_yytoks[c_yy_i].t_val == c_yychar )
						break;
				}
				printf( "%s\n", c_yytoks[c_yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ( ( c_yy_n += c_yychar ) < 0 ) || ( c_yy_n >= YYLAST ) )
			goto c_yydefault;
		if ( c_yychk[ c_yy_n = c_yyact[ c_yy_n ] ] == c_yychar )	/*valid shift*/
		{
			c_yychar = -1;
			c_yyval = c_yylval;
			c_yy_state = c_yy_n;
			if ( c_yyerrflag > 0 )
				c_yyerrflag--;
			goto c_yy_stack;
		}

	c_yydefault:
		if ( ( c_yy_n = c_yydef[ c_yy_state ] ) == -2 )
		{
#if YYDEBUG
			c_yytmp = c_yychar < 0;
#endif
			if ( ( c_yychar < 0 ) && ( ( c_yychar = c_yylex() ) < 0 ) )
				c_yychar = 0;		/* reached EOF */
#if YYDEBUG
			if ( c_yydebug && c_yytmp )
			{
				register int c_yy_i;

				printf( "Received token " );
				if ( c_yychar == 0 )
					printf( "end-of-file\n" );
				else if ( c_yychar < 0 )
					printf( "-none-\n" );
				else
				{
					for ( c_yy_i = 0;
						c_yytoks[c_yy_i].t_val >= 0;
						c_yy_i++ )
					{
						if ( c_yytoks[c_yy_i].t_val
							== c_yychar )
						{
							break;
						}
					}
					printf( "%s\n", c_yytoks[c_yy_i].t_name );
				}
			}
#endif /* YYDEBUG */
			/*
			** look through exception table
			*/
			{
				register int *c_yyxi = c_yyexca;

				while ( ( *c_yyxi != -1 ) ||
					( c_yyxi[1] != c_yy_state ) )
				{
					c_yyxi += 2;
				}
				while ( ( *(c_yyxi += 2) >= 0 ) &&
					( *c_yyxi != c_yychar ) )
					;
				if ( ( c_yy_n = c_yyxi[1] ) < 0 )
					YYACCEPT;
			}
		}

		/*
		** check for syntax error
		*/
		if ( c_yy_n == 0 )	/* have an error */
		{
			/* no worry about speed here! */
			switch ( c_yyerrflag )
			{
			case 0:		/* new error */
				c_yyerror( "syntax error" );
				goto skip_init;
			c_yyerrlab:
				/*
				** get globals into registers.
				** we have a user generated syntax type error
				*/
				c_yy_pv = c_yypv;
				c_yy_ps = c_yyps;
				c_yy_state = c_yystate;
				c_yynerrs++;
			skip_init:
			case 1:
			case 2:		/* incompletely recovered error */
					/* try again... */
				c_yyerrflag = 3;
				/*
				** find state where "error" is a legal
				** shift action
				*/
				while ( c_yy_ps >= c_yys )
				{
					c_yy_n = c_yypact[ *c_yy_ps ] + YYERRCODE;
					if ( c_yy_n >= 0 && c_yy_n < YYLAST &&
						c_yychk[c_yyact[c_yy_n]] == YYERRCODE)					{
						/*
						** simulate shift of "error"
						*/
						c_yy_state = c_yyact[ c_yy_n ];
						goto c_yy_stack;
					}
					/*
					** current state has no shift on
					** "error", pop stack
					*/
#if YYDEBUG
#	define _POP_ "Error recovery pops state %d, uncovers state %d\n"
					if ( c_yydebug )
						printf( _POP_, *c_yy_ps,
							c_yy_ps[-1] );
#	undef _POP_
#endif
					c_yy_ps--;
					c_yy_pv--;
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
				if ( c_yydebug )
				{
					register int c_yy_i;

					printf( "Error recovery discards " );
					if ( c_yychar == 0 )
						printf( "token end-of-file\n" );
					else if ( c_yychar < 0 )
						printf( "token -none-\n" );
					else
					{
						for ( c_yy_i = 0;
							c_yytoks[c_yy_i].t_val >= 0;
							c_yy_i++ )
						{
							if ( c_yytoks[c_yy_i].t_val
								== c_yychar )
							{
								break;
							}
						}
						printf( "token %s\n",
							c_yytoks[c_yy_i].t_name );
					}
				}
#endif /* YYDEBUG */
				if ( c_yychar == 0 )	/* reached EOF. quit */
					YYABORT;
				c_yychar = -1;
				goto c_yy_newstate;
			}
		}/* end if ( c_yy_n == 0 ) */
		/*
		** reduction by production c_yy_n
		** put stack tops, etc. so things right after switch
		*/
#if YYDEBUG
		/*
		** if debugging, print the string that is the user's
		** specification of the reduction which is just about
		** to be done.
		*/
		if ( c_yydebug )
			printf( "Reduce by (%d) \"%s\"\n",
				c_yy_n, c_yyreds[ c_yy_n ] );
#endif
		c_yytmp = c_yy_n;			/* value to switch over */
		c_yypvt = c_yy_pv;			/* $vars top of value stack */
		/*
		** Look in goto table for next state
		** Sorry about using c_yy_state here as temporary
		** register variable, but why not, if it works...
		** If c_yyr2[ c_yy_n ] doesn't have the low order bit
		** set, then there is no action to be done for
		** this reduction.  So, no saving & unsaving of
		** registers done.  The only difference between the
		** code just after the if and the body of the if is
		** the goto c_yy_stack in the body.  This way the test
		** can be made before the choice of what to do is needed.
		*/
		{
			/* length of production doubled with extra bit */
			register int c_yy_len = c_yyr2[ c_yy_n ];

			if ( !( c_yy_len & 01 ) )
			{
				c_yy_len >>= 1;
				c_yyval = ( c_yy_pv -= c_yy_len )[1];	/* $$ = $1 */
				c_yy_state = c_yypgo[ c_yy_n = c_yyr1[ c_yy_n ] ] +
					*( c_yy_ps -= c_yy_len ) + 1;
				if ( c_yy_state >= YYLAST ||
					c_yychk[ c_yy_state =
					c_yyact[ c_yy_state ] ] != -c_yy_n )
				{
					c_yy_state = c_yyact[ c_yypgo[ c_yy_n ] ];
				}
				goto c_yy_stack;
			}
			c_yy_len >>= 1;
			c_yyval = ( c_yy_pv -= c_yy_len )[1];	/* $$ = $1 */
			c_yy_state = c_yypgo[ c_yy_n = c_yyr1[ c_yy_n ] ] +
				*( c_yy_ps -= c_yy_len ) + 1;
			if ( c_yy_state >= YYLAST ||
				c_yychk[ c_yy_state = c_yyact[ c_yy_state ] ] != -c_yy_n )
			{
				c_yy_state = c_yyact[ c_yypgo[ c_yy_n ] ];
			}
		}
					/* save until reenter driver code */
		c_yystate = c_yy_state;
		c_yyps = c_yy_ps;
		c_yypv = c_yy_pv;
	}
	/*
	** code supplied by user is placed in this switch
	*/
	switch( c_yytmp )
	{
		
case 1:
# line 20 "cond.y"
{ return (1); } break;
case 2:
# line 23 "cond.y"
{ return (0) ; } break;
case 3:
# line 26 "cond.y"
{ NoExp++; } break;
case 4:
# line 29 "cond.y"
{ NoExp++; } break;
case 6:
# line 34 "cond.y"
{ strcat (exp_cond, " && "); } break;
case 7:
# line 37 "cond.y"
{ strcat (exp_cond, "~");
		     result[NoExp] = (Expression (val, operator, exp_cond));
	           } break;
case 8:
# line 42 "cond.y"
{ strcpy (col_nam, c_temp); } break;
case 9:
# line 44 "cond.y"
{ strcat (exp_cond, " <= "); } break;
case 10:
# line 46 "cond.y"
{ strcat (exp_cond, " || ");
		     strcat (exp_cond, col_nam);
		     strcat (exp_cond, " >= ");
	           } break;
case 11:
# line 51 "cond.y"
{ strcat (exp_cond, "~");
		     result[NoExp] = (Between (type, "<=", exp_cond));
		   } break;
case 12:
# line 56 "cond.y"
{ strcpy (col_nam, c_temp); } break;
case 13:
# line 58 "cond.y"
{ strcat (exp_cond, " >= "); } break;
case 14:
# line 60 "cond.y"
{ strcat (exp_cond, " && ");
		     strcat (exp_cond, col_nam);
		     strcat (exp_cond, " <= ");
		   } break;
case 15:
# line 65 "cond.y"
{ 
		     strcat (exp_cond, "~");
    		     result[NoExp] = (Between (type, ">=", exp_cond));
		   } break;
case 16:
# line 71 "cond.y"
{ strcat (exp_cond, " in "); } break;
case 17:
# line 73 "cond.y"
{ strcat (exp_cond, " ( "); } break;
case 18:
# line 75 "cond.y"
{ strcat (exp_cond, " ) ");
		     strcat (exp_cond, "~");
		     result[NoExp] = (InValueList (1, exp_cond));
		   } break;
case 19:
# line 81 "cond.y"
{ strcat (exp_cond, " not "); } break;
case 20:
# line 83 "cond.y"
{ strcat (exp_cond, " in "); } break;
case 21:
# line 85 "cond.y"
{ strcat (exp_cond, " ( "); } break;
case 22:
# line 87 "cond.y"
{ strcat (exp_cond, " ) "); 
		     strcat (exp_cond, "~");
		     result[NoExp] = (InValueList (0, exp_cond));
		   } break;
case 23:
# line 93 "cond.y"
{ strcat (exp_cond, " is "); } break;
case 24:
# line 95 "cond.y"
{ strcat (exp_cond, " not "); } break;
case 25:
# line 97 "cond.y"
{ strcat (exp_cond, " null "); 
		     strcat (exp_cond, "~");
		     result[NoExp] = (IsNull (0, exp_cond));
		   } break;
case 26:
# line 103 "cond.y"
{ strcat (exp_cond, " is "); } break;
case 27:
# line 105 "cond.y"
{ strcat (exp_cond, " null "); 
		     strcat (exp_cond, "~");
		     result[NoExp] = (IsNull (1, exp_cond));
		   } break;
case 28:
# line 111 "cond.y"
{ strcat (exp_cond, " != "); } break;
case 29:
# line 113 "cond.y"
{ strcat (exp_cond, c_yytext); 
		     strcat (exp_cond, "~");
		     result[NoExp] = (LikeString (0, exp_cond));
		   } break;
case 30:
# line 120 "cond.y"
{ strcat (exp_cond, " = "); } break;
case 31:
# line 122 "cond.y"
{ strcat (exp_cond, c_yytext); 
		     strcat (exp_cond, "~");
		     result[NoExp] = (LikeString (1, exp_cond));
		   } break;
case 32:
# line 128 "cond.y"
{ strcat (exp_cond, " = "); } break;
case 33:
# line 130 "cond.y"
{ strcat (exp_cond, c_yytext); 
		    strcat (exp_cond, "~");
		    strcpy (operator, "=");
		    result[NoExp] = (StringExpression (operator, exp_cond));
		   } break;
case 34:
# line 137 "cond.y"
{ strcat (exp_cond, " != "); } break;
case 35:
# line 139 "cond.y"
{ strcat (exp_cond, c_yytext); 
		     strcat (exp_cond, "~");
		    strcpy (operator, "!=");
		    result[NoExp] = (StringExpression (operator, exp_cond));
		   } break;
case 39:
# line 152 "cond.y"
{ 
		    strcpy (exp_cond, c_yytext); 
		    strcpy (c_temp, c_yytext);
		  } break;
case 40:
# line 158 "cond.y"
{ strcat (exp_cond,  " > "); 
		    val = 0;
		    strcpy (operator, ">");
		  } break;
case 41:
# line 164 "cond.y"
{ strcat (exp_cond,  " >= "); 
		    val = 1;
		    strcpy (operator, ">=");
		  } break;
case 42:
# line 170 "cond.y"
{ strcat (exp_cond,  " < "); 
		    val = 2;
		    strcpy (operator, "<");
		  } break;
case 43:
# line 176 "cond.y"
{ strcat (exp_cond,  " <= "); 
		    val = 3;
		    strcpy (operator, "<=");
		  } break;
case 44:
# line 182 "cond.y"
{ strcat (exp_cond,  " <> "); 
		    val =4;
		    strcpy (operator, "<>");
		  } break;
case 45:
# line 188 "cond.y"
{ strcat (exp_cond,  " != "); 
		    val = 5;
		    strcpy (operator, "!=");
		  } break;
case 46:
# line 194 "cond.y"
{ strcat (exp_cond,  " = "); 
		    val = 6;
		    strcpy (operator, "=");
		  } break;
case 47:
# line 200 "cond.y"
{strcat (exp_cond, ","); } break;
case 50:
# line 206 "cond.y"
{ strcat (exp_cond,  c_yytext);
		    type = 0;
		  } break;
case 51:
# line 211 "cond.y"
{ strcat (exp_cond,  c_yytext); 
		    type = 0;
		  } break;
case 52:
# line 216 "cond.y"
{ strcat (exp_cond, c_yytext);
		    type = 1;
		  } break;
	}
	goto c_yystack;		/* reset registers in driver code */
}
# include "stdio.h"
# define U(x) x
# define NLSTATE c_yyprevious=YYNEWLINE
# define BEGIN c_yybgin = c_yysvec + 1 +
# define INITIAL 0
# define YYLERR c_yysvec
# define YYSTATE (c_yyestate-c_yysvec-1)
# define YYOPTIM 1
# define YYLMAX 200
# define output(c) putc(c,c_yyout)
# define input() (((c_yytchar=c_yysptr>c_yysbuf?U(*--c_yysptr):getc(c_yyin))==10?(c_yylineno++,c_yytchar):c_yytchar)==EOF?0:c_yytchar)
# define unput(c) {c_yytchar= (c);if(c_yytchar=='\n')c_yylineno--;*c_yysptr++=c_yytchar;}
# define c_yymore() (c_yymorfg=1)

/************ inhibit echo ****************************************************/
#ifdef MYDEBUG
#define ECHO fprintf(c_yyout, "%s",c_yytext)
#endif

#ifndef MYDEBUG
#define	ECHO
#endif
/******************************************************************************/


# define REJECT { nstr = c_yyreject(); goto c_yyfussy;}
int c_yyleng; extern char c_yytext[];
int c_yymorfg;
extern char *c_yysptr, c_yysbuf[];
int c_yytchar;

/************ change 'c_yyin' so that input is taken from a *********************/
/************ file rather than the 'stdin'	          *********************/

/*FILE *c_yyin = {stdin}, *c_yyout = {stdout};*/

FILE *c_yyout = {stdout};
extern FILE *c_yyin;

/*****************************************************************************/


extern int c_yylineno;
struct c_yysvf { 
	struct c_yywork *c_yystoff;
	struct c_yysvf *c_yyother;
	int *c_yystops;};
struct c_yysvf *c_yyestate;
extern struct c_yysvf c_yysvec[], *c_yybgin;
# define separ 2
# define YYNEWLINE 10
c_yylex(){
int nstr; extern int c_yyprevious;
while((nstr = c_yylook()) >= 0)
c_yyfussy: switch(nstr){
case 0:
if(c_yywrap()) return(0); break;
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
				return (_c_un_equal);
			}
break;
case 10:
			{
				ECHO;
				return (_c_not_equal);
			}
break;
case 11:
{
				ECHO;
				return (_c_between);
			}
break;
case 12:
		{
				ECHO;
				return (_c_in);
			}
break;
case 13:
		{
				ECHO;
				return (_c_is);
			}
break;
case 14:
	{
				ECHO;
				return (_c_null);
			}
break;
case 15:
	{
				ECHO;
				return (_c_like);
			}
break;
case 16:
		{
				ECHO;
				return (_c_not);
			}
break;
case 17:
{
				ECHO;
				return (_c_not_between);
			}
break;
case 18:
			{
				ECHO;
				return (_c_int_value);
			}
break;
case 19:
{
				ECHO;
				return (_c_real_value);
			}
break;
case 20:
			{
				ECHO;
				return (_c_multiply);
			}
break;
case 21:
			{
				ECHO;
				return (_c_divide);
			}
break;
case 22:
			{
				ECHO;
				return (_c_add);
			}
break;
case 23:
			{
				ECHO;
				return (_c_subtract);
			}
break;
case 24:
			{
				ECHO;
				return (_c_comma);
			}
break;
case 25:
			{
				ECHO;
				BEGIN separ;
				return (_c_open);
			}
break;
case 26:
			{
				ECHO;
				BEGIN 0;
				return (_c_close);
			}
break;
case 27:
		{
				ECHO;
				return (_c_string);
			}
break;
case -1:
break;
default:
fprintf(c_yyout,"bad switch c_yylook %d",nstr);
} return(0); }
/* end of c_yylex */

c_yywrap ()
{
	return (1);
}
int c_yyvstop[] = {
0,

25,
0,

26,
0,

20,
0,

22,
0,

24,
0,

23,
0,

21,
0,

18,
0,

7,
0,

8,
0,

5,
0,

10,
0,

6,
0,

9,
0,

4,
0,

12,
0,

13,
0,

3,
0,

27,
0,

19,
0,

1,
0,

2,
0,

16,
0,

15,
0,

14,
0,

11,
0,

17,
0,
0};
# define YYTYPE char
struct c_yywork { YYTYPE verify, advance; } c_yycrank[] = {
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
1,10,	1,11,	1,12,	26,40,	
1,13,	1,14,	1,14,	1,14,	
1,14,	1,14,	1,14,	1,14,	
1,14,	1,14,	1,14,	0,0,	
0,0,	1,15,	1,16,	1,17,	
5,25,	0,0,	1,18,	1,19,	
1,20,	1,20,	1,20,	1,20,	
1,20,	1,20,	1,21,	1,20,	
1,20,	1,22,	1,20,	1,23,	
1,24,	1,20,	1,20,	1,20,	
1,20,	1,20,	1,20,	1,20,	
1,20,	1,20,	1,20,	1,20,	
15,28,	15,29,	17,30,	0,0,	
0,0,	0,0,	1,18,	1,19,	
1,20,	1,20,	1,20,	1,20,	
1,20,	1,20,	1,21,	1,20,	
1,20,	1,22,	1,20,	1,23,	
1,24,	1,20,	1,20,	1,20,	
1,20,	1,20,	1,20,	1,20,	
1,20,	1,20,	1,20,	1,20,	
6,26,	6,26,	6,26,	6,26,	
6,26,	6,26,	6,26,	6,26,	
6,26,	6,26,	0,0,	20,20,	
24,20,	34,20,	35,20,	39,20,	
24,39,	6,26,	6,26,	6,26,	
6,26,	6,26,	6,26,	6,26,	
6,26,	6,26,	6,26,	6,26,	
6,26,	6,26,	6,26,	6,26,	
6,26,	6,26,	6,26,	6,26,	
6,26,	6,26,	6,26,	6,26,	
6,26,	6,26,	6,26,	20,20,	
24,20,	34,20,	35,20,	39,20,	
24,39,	6,26,	6,26,	6,26,	
6,26,	6,26,	6,26,	6,26,	
6,26,	6,26,	6,26,	6,26,	
6,26,	6,26,	6,26,	6,26,	
6,26,	6,26,	6,26,	6,26,	
6,26,	6,26,	6,26,	6,26,	
6,26,	6,26,	6,26,	14,27,	
0,0,	14,14,	14,14,	14,14,	
14,14,	14,14,	14,14,	14,14,	
14,14,	14,14,	14,14,	18,31,	
0,0,	18,20,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,20,	18,20,	0,0,	
21,34,	38,47,	43,20,	38,20,	
0,0,	21,35,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,32,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,20,	
21,34,	38,47,	43,20,	38,20,	
18,20,	21,35,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,32,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,20,	
18,20,	18,20,	18,20,	18,20,	
19,33,	22,36,	33,20,	23,20,	
23,37,	47,51,	22,20,	47,20,	
33,44,	19,20,	23,38,	27,41,	
27,41,	27,41,	27,41,	27,41,	
27,41,	27,41,	27,41,	27,41,	
27,41,	0,0,	42,42,	42,42,	
42,42,	42,42,	42,42,	42,42,	
42,42,	42,42,	42,42,	42,42,	
19,33,	22,36,	33,20,	23,20,	
23,37,	47,51,	22,20,	47,20,	
33,44,	19,20,	23,38,	31,42,	
31,42,	31,42,	31,42,	31,42,	
31,42,	31,42,	31,42,	31,42,	
31,42,	31,42,	31,42,	31,42,	
31,42,	31,42,	31,42,	31,42,	
31,42,	31,42,	31,42,	31,42,	
31,42,	31,42,	31,42,	31,42,	
31,42,	42,42,	36,45,	0,0,	
0,0,	36,20,	0,0,	31,42,	
31,42,	31,42,	31,42,	31,42,	
31,42,	31,42,	31,42,	31,42,	
31,42,	31,42,	31,42,	31,42,	
31,42,	31,42,	31,42,	31,42,	
31,42,	31,42,	31,42,	31,42,	
31,42,	31,42,	31,42,	31,42,	
31,42,	32,43,	36,45,	37,20,	
44,20,	36,20,	45,49,	46,50,	
48,52,	37,46,	49,20,	32,20,	
51,20,	44,48,	50,50,	45,20,	
52,54,	48,20,	53,55,	54,56,	
55,57,	56,20,	57,58,	58,59,	
59,60,	52,20,	60,61,	0,0,	
0,0,	0,0,	46,50,	0,0,	
0,0,	32,43,	0,0,	37,20,	
44,20,	50,50,	45,49,	0,0,	
48,52,	37,46,	49,20,	32,20,	
51,20,	44,48,	0,0,	45,20,	
52,54,	48,20,	53,55,	54,56,	
55,57,	56,20,	57,58,	58,59,	
59,60,	52,20,	60,61,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	50,53,	
0,0,	0,0,	0,0,	0,0,	
46,20,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	50,53,	
0,0,	0,0,	0,0,	0,0,	
46,20,	0,0,	0,0,	0,0,	
0,0};
struct c_yysvf c_yysvec[] = {
0,	0,	0,
c_yycrank+1,	0,		0,	
c_yycrank+0,	c_yysvec+1,	0,	
c_yycrank+0,	c_yysvec+1,	0,	
c_yycrank+0,	c_yysvec+1,	0,	
c_yycrank+3,	0,		0,	
c_yycrank+76,	0,		0,	
c_yycrank+0,	0,		c_yyvstop+1,
c_yycrank+0,	0,		c_yyvstop+3,
c_yycrank+0,	0,		c_yyvstop+5,
c_yycrank+0,	0,		c_yyvstop+7,
c_yycrank+0,	0,		c_yyvstop+9,
c_yycrank+0,	0,		c_yyvstop+11,
c_yycrank+0,	0,		c_yyvstop+13,
c_yycrank+153,	0,		c_yyvstop+15,
c_yycrank+31,	0,		c_yyvstop+17,
c_yycrank+0,	0,		c_yyvstop+19,
c_yycrank+33,	0,		c_yyvstop+21,
c_yycrank+165,	0,		0,	
c_yycrank+219,	c_yysvec+18,	0,	
c_yycrank+57,	c_yysvec+18,	0,	
c_yycrank+146,	c_yysvec+18,	0,	
c_yycrank+216,	c_yysvec+18,	0,	
c_yycrank+213,	c_yysvec+18,	0,	
c_yycrank+58,	c_yysvec+18,	0,	
c_yycrank+0,	0,		c_yyvstop+23,
c_yycrank+8,	c_yysvec+6,	0,	
c_yycrank+251,	0,		0,	
c_yycrank+0,	0,		c_yyvstop+25,
c_yycrank+0,	0,		c_yyvstop+27,
c_yycrank+0,	0,		c_yyvstop+29,
c_yycrank+266,	0,		0,	
c_yycrank+321,	c_yysvec+18,	0,	
c_yycrank+212,	c_yysvec+18,	0,	
c_yycrank+59,	c_yysvec+18,	c_yyvstop+31,
c_yycrank+60,	c_yysvec+18,	c_yyvstop+33,
c_yycrank+283,	c_yysvec+18,	0,	
c_yycrank+313,	c_yysvec+18,	0,	
c_yycrank+149,	c_yysvec+18,	0,	
c_yycrank+61,	c_yysvec+18,	c_yyvstop+35,
c_yycrank+0,	0,		c_yyvstop+37,
c_yycrank+0,	c_yysvec+27,	c_yyvstop+39,
c_yycrank+262,	c_yysvec+31,	c_yyvstop+41,
c_yycrank+148,	c_yysvec+18,	c_yyvstop+43,
c_yycrank+314,	c_yysvec+18,	0,	
c_yycrank+325,	c_yysvec+18,	0,	
c_yycrank+386,	c_yysvec+18,	c_yyvstop+45,
c_yycrank+217,	c_yysvec+18,	0,	
c_yycrank+327,	c_yysvec+18,	0,	
c_yycrank+320,	c_yysvec+18,	c_yyvstop+47,
c_yycrank+393,	0,		0,	
c_yycrank+322,	c_yysvec+18,	c_yyvstop+49,
c_yycrank+335,	c_yysvec+18,	0,	
c_yycrank+337,	0,		0,	
c_yycrank+329,	c_yysvec+18,	0,	
c_yycrank+324,	0,		0,	
c_yycrank+331,	c_yysvec+18,	c_yyvstop+51,
c_yycrank+323,	0,		0,	
c_yycrank+342,	0,		0,	
c_yycrank+343,	0,		0,	
c_yycrank+336,	0,		0,	
c_yycrank+0,	0,		c_yyvstop+53,
0,	0,	0};
struct c_yywork *c_yytop = c_yycrank+496;
struct c_yysvf *c_yybgin = c_yysvec+1;
char c_yymatch[] = {
00  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,011 ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
011 ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,
'0' ,'0' ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,'A' ,'B' ,'C' ,'D' ,'E' ,'C' ,'C' ,
'C' ,'I' ,'C' ,'K' ,'L' ,'C' ,'N' ,'O' ,
'C' ,'C' ,'R' ,'S' ,'T' ,'U' ,'C' ,'W' ,
'C' ,'C' ,'C' ,01  ,01  ,01  ,01  ,'_' ,
01  ,'A' ,'B' ,'C' ,'D' ,'E' ,'C' ,'C' ,
'C' ,'I' ,'C' ,'K' ,'L' ,'C' ,'N' ,'O' ,
'C' ,'C' ,'R' ,'S' ,'T' ,'U' ,'C' ,'W' ,
'C' ,'C' ,'C' ,01  ,01  ,01  ,01  ,01  ,
0};
char c_yyextra[] = {
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0};
#ident	"@(#)libl:lib/ncform	1.3	1.2 (Intergraph) 3/10/88"
int c_yylineno =1;
# define YYU(x) x
# define NLSTATE c_yyprevious=YYNEWLINE
char c_yytext[YYLMAX];
struct c_yysvf *c_yylstate [YYLMAX], **c_yylsp, **c_yyolsp;
char c_yysbuf[YYLMAX];
char *c_yysptr = c_yysbuf;
int *c_yyfnd;
extern struct c_yysvf *c_yyestate;
int c_yyprevious = YYNEWLINE;
c_yylook(){
	register struct c_yysvf *c_yystate, **lsp;
	register struct c_yywork *c_yyt;
	struct c_yysvf *c_yyz;
	int c_yych, c_yyfirst;
	struct c_yywork *c_yyr;
# ifdef LEXDEBUG
	int debug;
# endif
	char *c_yylastch;
	/* start off machines */
# ifdef LEXDEBUG
	debug = 0;
# endif
	c_yyfirst=1;
	if (!c_yymorfg)
		c_yylastch = c_yytext;
	else {
		c_yymorfg=0;
		c_yylastch = c_yytext+c_yyleng;
		}
	for(;;){
		lsp = c_yylstate;
		c_yyestate = c_yystate = c_yybgin;
		if (c_yyprevious==YYNEWLINE) c_yystate++;
		for (;;){
# ifdef LEXDEBUG
			if(debug)fprintf(c_yyout,"state %d\n",c_yystate-c_yysvec-1);
# endif
			c_yyt = c_yystate->c_yystoff;
			if(c_yyt == c_yycrank && !c_yyfirst){  /* may not be any transitions */
				c_yyz = c_yystate->c_yyother;
				if(c_yyz == 0)break;
				if(c_yyz->c_yystoff == c_yycrank)break;
				}
			*c_yylastch++ = c_yych = input();
			c_yyfirst=0;
		tryagain:
# ifdef LEXDEBUG
			if(debug){
				fprintf(c_yyout,"char ");
				allprint(c_yych);
				putchar('\n');
				}
# endif
			c_yyr = c_yyt;
			if ( (int)c_yyt > (int)c_yycrank){
				c_yyt = c_yyr + c_yych;
				if (c_yyt <= c_yytop && c_yyt->verify+c_yysvec == c_yystate){
					if(c_yyt->advance+c_yysvec == YYLERR)	/* error transitions */
						{unput(*--c_yylastch);break;}
					*lsp++ = c_yystate = c_yyt->advance+c_yysvec;
					goto contin;
					}
				}
# ifdef YYOPTIM
			else if((int)c_yyt < (int)c_yycrank) {		/* r < c_yycrank */
				c_yyt = c_yyr = c_yycrank+(c_yycrank-c_yyt);
# ifdef LEXDEBUG
				if(debug)fprintf(c_yyout,"compressed state\n");
# endif
				c_yyt = c_yyt + c_yych;
				if(c_yyt <= c_yytop && c_yyt->verify+c_yysvec == c_yystate){
					if(c_yyt->advance+c_yysvec == YYLERR)	/* error transitions */
						{unput(*--c_yylastch);break;}
					*lsp++ = c_yystate = c_yyt->advance+c_yysvec;
					goto contin;
					}
				c_yyt = c_yyr + YYU(c_yymatch[c_yych]);
# ifdef LEXDEBUG
				if(debug){
					fprintf(c_yyout,"try fall back character ");
					allprint(YYU(c_yymatch[c_yych]));
					putchar('\n');
					}
# endif
				if(c_yyt <= c_yytop && c_yyt->verify+c_yysvec == c_yystate){
					if(c_yyt->advance+c_yysvec == YYLERR)	/* error transition */
						{unput(*--c_yylastch);break;}
					*lsp++ = c_yystate = c_yyt->advance+c_yysvec;
					goto contin;
					}
				}
			if ((c_yystate = c_yystate->c_yyother) && (c_yyt= c_yystate->c_yystoff) != c_yycrank){
# ifdef LEXDEBUG
				if(debug)fprintf(c_yyout,"fall back to state %d\n",c_yystate-c_yysvec-1);
# endif
				goto tryagain;
				}
# endif
			else
				{unput(*--c_yylastch);break;}
		contin:
# ifdef LEXDEBUG
			if(debug){
				fprintf(c_yyout,"state %d char ",c_yystate-c_yysvec-1);
				allprint(c_yych);
				putchar('\n');
				}
# endif
			;
			}
# ifdef LEXDEBUG
		if(debug){
			fprintf(c_yyout,"stopped at %d with ",*(lsp-1)-c_yysvec-1);
			allprint(c_yych);
			putchar('\n');
			}
# endif
		while (lsp-- > c_yylstate){
			*c_yylastch-- = 0;
			if (*lsp != 0 && (c_yyfnd= (*lsp)->c_yystops) && *c_yyfnd > 0){
				c_yyolsp = lsp;
				if(c_yyextra[*c_yyfnd]){		/* must backup */
					while(c_yyback((*lsp)->c_yystops,-*c_yyfnd) != 1 && lsp > c_yylstate){
						lsp--;
						unput(*c_yylastch--);
						}
					}
				c_yyprevious = YYU(*c_yylastch);
				c_yylsp = lsp;
				c_yyleng = c_yylastch-c_yytext+1;
				c_yytext[c_yyleng] = 0;
# ifdef LEXDEBUG
				if(debug){
					fprintf(c_yyout,"\nmatch ");
					sprint(c_yytext);
					fprintf(c_yyout," action %d\n",*c_yyfnd);
					}
# endif
				return(*c_yyfnd++);
				}
			unput(*c_yylastch);
			}
		/* you may or may not be reading from c_yyin - we really   */
		/* can't tell at this point. So whenver c_yytext[0] is set */
		/* to 0, this indicates end of file			 */
		if (c_yytext[0] == 0 /* && feof(c_yyin) */ )
			{
			c_yysptr=c_yysbuf;
			return(0);
			}
		c_yyprevious = c_yytext[0] = input();
		if (c_yyprevious>0)
			output(c_yyprevious);
		c_yylastch=c_yytext;
# ifdef LEXDEBUG
		if(debug)putchar('\n');
# endif
		}
	}
c_yyback(p, m)
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
c_yyinput(){
	return(input());
	}
c_yyoutput(c)
  int c; {
	output(c);
	}
c_yyunput(c)
   int c; {
	unput(c);
	}
