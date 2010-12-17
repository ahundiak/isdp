#include <stdio.h>
#include <string.h>
#include <malloc.h>

#define	AllocNCat(ptr, string) {					\
	ptr = (char *) realloc (ptr, 					\
	(strlen (ptr) + 1 + strlen (string) + 1) * sizeof (char));	\
									\
	if (ptr == NULL) {						\
		fprintf (stderr, "Unable To Allocate Memory\n");	\
		return (0);						\
	}								\
									\
	strcat (ptr, string);						\
}

	extern	char	yytext[];	/* Becomes DIN_yytext after compilation (see makefile )	*/
	extern  char	*DLexp_cond;	
	extern	int	NoExpressions, DLresult[];

/* 09/Aug/95 - raj. changed to static. Clash with 3.2 MODEL on SPARC
	int	i, j, val, type;
	char	c_temp[32*2], col_nam[32*2], operator[8];
*/
/* 04/Sep/95 - raj. Removed i, j and col_nam. Added PDUPAL_ prefix to the rest. */
	static int	/* i, j, */ PDUPAL_val, PDUPAL_type;
	static char	PDUPAL_c_temp[32*2], /* col_nam[32*2], */ PDUPAL_operator[8];
# define _c_column_name 257
# define _c_greater 258
# define _c_greater_equal 259
# define _c_less 260
# define _c_less_equal 261
# define _c_equal 262
# define _c_not_equal 263
# define _c_not 264
# define _c_multiply 265
# define _c_divide 266
# define _c_add 267
# define _c_subtract 268
# define _c_open 269
# define _c_close 270
# define _c_string 271
# define _c_int_value 272
# define _c_real_value 273
# define _c_outside_or 274
# define _c_outside_and 275
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
	fprintf (stderr, "Error -> %s\n", DLexp_cond);
	return (-2);
} 

yytabelem yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
-1, 3,
	0, 2,
	-2, 4,
-1, 15,
	271, 8,
	-2, 21,
-1, 16,
	271, 10,
	-2, 20,
-1, 23,
	0, 13,
	274, 13,
	275, 13,
	-2, 12,
	};
# define YYNPROD 25
# define YYLAST 39
yytabelem yyact[]={

     7,    12,    13,    30,    29,    17,    18,    19,    20,    28,
    27,     5,    14,     4,    10,     8,     9,    17,    18,    19,
    20,    15,    16,     6,     3,    25,    23,    24,    22,    11,
     2,     1,     0,     0,     0,    26,    21,     0,    31 };
yytabelem yypact[]={

  -257, -1000,  -273, -1000,  -241, -1000, -1000, -1000, -1000, -1000,
 -1000,  -257, -1000, -1000,  -257, -1000, -1000, -1000, -1000, -1000,
 -1000, -1000,  -253, -1000,  -267,  -268,  -257, -1000, -1000, -1000,
 -1000, -1000 };
yytabelem yypgo[]={

     0,    31,    30,    24,    29,    13,    12,    27,    25,    11,
    23 };
yytabelem yyr1[]={

     0,     1,     1,     2,     2,     4,     4,     3,     7,     3,
     8,     3,     5,     5,     9,     9,     6,     6,     6,     6,
     6,     6,    10,    10,    10 };
yytabelem yyr2[]={

     0,     3,     3,     7,     3,     2,     3,     7,     1,     9,
     1,     9,     6,     2,     2,     3,     3,     3,     3,     3,
     3,     3,     3,     3,     3 };
yytabelem yychk[]={

 -1000,    -1,    -2,    -3,    -5,    -9,   -10,   257,   272,   273,
   271,    -4,   274,   275,    -6,   262,   263,   258,   259,   260,
   261,    -3,    -5,    -9,    -7,    -8,    -6,   263,   262,   271,
   271,    -9 };
yytabelem yydef[]={

     0,    -2,     1,    -2,     0,    13,    14,    15,    22,    23,
    24,     0,     5,     6,     0,    -2,    -2,    16,    17,    18,
    19,     3,     7,    -2,     0,     0,     0,    20,    21,     9,
    11,    12 };
typedef struct { char *t_name; int t_val; } yytoktype;
#ifndef YYDEBUG
#	define YYDEBUG	1	/* allow debugging */
#endif

#if YYDEBUG

yytoktype yytoks[] =
{
	"_c_column_name",	257,
	"_c_greater",	258,
	"_c_greater_equal",	259,
	"_c_less",	260,
	"_c_less_equal",	261,
	"_c_equal",	262,
	"_c_not_equal",	263,
	"_c_not",	264,
	"_c_multiply",	265,
	"_c_divide",	266,
	"_c_add",	267,
	"_c_subtract",	268,
	"_c_open",	269,
	"_c_close",	270,
	"_c_string",	271,
	"_c_int_value",	272,
	"_c_real_value",	273,
	"_c_outside_or",	274,
	"_c_outside_and",	275,
	"-unknown-",	-1	/* ends search */
};

char * yyreds[] =
{
	"-no such reduction-",
	"whole_condition : complex_condition",
	"whole_condition : condition",
	"complex_condition : complex_condition conj condition",
	"complex_condition : condition",
	"conj : _c_outside_or",
	"conj : _c_outside_and",
	"condition : expression oper expression",
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
	"oper : _c_not_equal",
	"oper : _c_equal",
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
		
case 1:{ return (1); } break;
case 2:{ return (0) ; } break;
case 3:{ NoExpressions++; } break;
case 4:{ NoExpressions++; } break;
case 6:{ AllocNCat (DLexp_cond, " && "); } break;
case 7:{ AllocNCat (DLexp_cond, "~");
		     DLExpression (PDUPAL_val, PDUPAL_operator, DLexp_cond, &DLresult[NoExpressions]);
		     free ((char *)DLexp_cond);
		     DLexp_cond = NULL;
	           } break;
case 8:{ AllocNCat (DLexp_cond, " = "); } break;
case 9:{ AllocNCat (DLexp_cond, yytext); 
		    AllocNCat (DLexp_cond, "~");
		    strcpy (PDUPAL_operator, "=");
		    DLStringExpression (PDUPAL_operator, DLexp_cond, &DLresult[NoExpressions]);
		     free ((char *)DLexp_cond);
		     DLexp_cond = NULL;
		   } break;
case 10:{ AllocNCat (DLexp_cond, " != "); } break;
case 11:{ AllocNCat (DLexp_cond, yytext); 
		     AllocNCat (DLexp_cond, "~");
		    strcpy (PDUPAL_operator, "!=");
		    DLStringExpression (PDUPAL_operator, DLexp_cond, &DLresult[NoExpressions]);
		     free ((char *)DLexp_cond);
		     DLexp_cond = NULL;
		   } break;
case 15:{ 
		    if (DLexp_cond != NULL)
		    	DLexp_cond = (char *) realloc (DLexp_cond, (strlen (yytext) + 1) * sizeof (char));
		    else
		    	DLexp_cond = (char *) malloc ((strlen (yytext) + 1) * sizeof (char));
		    if (DLexp_cond == NULL) {
			printf ("Unable To Allocate Memory\n");
			return (0);
		    }
		    strcpy (DLexp_cond, yytext); 
		    strcpy (PDUPAL_c_temp, yytext);
		  } break;
case 16:{ AllocNCat (DLexp_cond,  " > "); 
		    PDUPAL_val = 0;
		    strcpy (PDUPAL_operator, ">");
		  } break;
case 17:{ AllocNCat (DLexp_cond,  " >= "); 
		    PDUPAL_val = 1;
		    strcpy (PDUPAL_operator, ">=");
		  } break;
case 18:{ AllocNCat (DLexp_cond,  " < "); 
		    PDUPAL_val = 2;
		    strcpy (PDUPAL_operator, "<");
		  } break;
case 19:{ AllocNCat (DLexp_cond,  " <= "); 
		    PDUPAL_val = 3;
		    strcpy (PDUPAL_operator, "<=");
		  } break;
case 20:{ AllocNCat (DLexp_cond,  " != "); 
		    PDUPAL_val = 5;
		    strcpy (PDUPAL_operator, "!=");
		  } break;
case 21:{ AllocNCat (DLexp_cond,  " = "); 
		    PDUPAL_val = 6;
		    strcpy (PDUPAL_operator, "=");
		  } break;
case 22:{ AllocNCat (DLexp_cond,  yytext);
		    PDUPAL_type = 0;
		  } break;
case 23:{ AllocNCat (DLexp_cond,  yytext); 
		    PDUPAL_type = 0;
		  } break;
case 24:{ AllocNCat (DLexp_cond, yytext);
		    PDUPAL_type = 1;
		  } break;
	}
	goto yystack;		/* reset registers in driver code */
}
