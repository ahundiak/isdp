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

	extern	char	CID_yytext[];	/* Becomes DIN_CID_yytext after compilation (see makefile )	*/
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
#define CID_yyclearin CID_yychar = -1
#define CID_yyerrok CID_yyerrflag = 0
extern int CID_yychar;
extern int CID_yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
#ifndef YYSTYPE
#define YYSTYPE int
#endif
YYSTYPE CID_yylval, CID_yyval;
typedef int CID_yytabelem;
# define YYERRCODE 256

CID_yyerror(str)
char	*str;
{
	fprintf (stderr, "Error -> %s\n", DLexp_cond);
	return (-2);
} 

CID_yytabelem CID_yyexca[] ={
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
CID_yytabelem CID_yyact[]={

     7,    12,    13,    30,    29,    17,    18,    19,    20,    28,
    27,     5,    14,     4,    10,     8,     9,    17,    18,    19,
    20,    15,    16,     6,     3,    25,    23,    24,    22,    11,
     2,     1,     0,     0,     0,    26,    21,     0,    31 };
CID_yytabelem CID_yypact[]={

  -257, -1000,  -273, -1000,  -241, -1000, -1000, -1000, -1000, -1000,
 -1000,  -257, -1000, -1000,  -257, -1000, -1000, -1000, -1000, -1000,
 -1000, -1000,  -253, -1000,  -267,  -268,  -257, -1000, -1000, -1000,
 -1000, -1000 };
CID_yytabelem CID_yypgo[]={

     0,    31,    30,    24,    29,    13,    12,    27,    25,    11,
    23 };
CID_yytabelem CID_yyr1[]={

     0,     1,     1,     2,     2,     4,     4,     3,     7,     3,
     8,     3,     5,     5,     9,     9,     6,     6,     6,     6,
     6,     6,    10,    10,    10 };
CID_yytabelem CID_yyr2[]={

     0,     3,     3,     7,     3,     2,     3,     7,     1,     9,
     1,     9,     6,     2,     2,     3,     3,     3,     3,     3,
     3,     3,     3,     3,     3 };
CID_yytabelem CID_yychk[]={

 -1000,    -1,    -2,    -3,    -5,    -9,   -10,   257,   272,   273,
   271,    -4,   274,   275,    -6,   262,   263,   258,   259,   260,
   261,    -3,    -5,    -9,    -7,    -8,    -6,   263,   262,   271,
   271,    -9 };
CID_yytabelem CID_yydef[]={

     0,    -2,     1,    -2,     0,    13,    14,    15,    22,    23,
    24,     0,     5,     6,     0,    -2,    -2,    16,    17,    18,
    19,     3,     7,    -2,     0,     0,     0,    20,    21,     9,
    11,    12 };
typedef struct { char *t_name; int t_val; } CID_yytoktype;
#ifndef YYDEBUG
#	define YYDEBUG	1	/* allow debugging */
#endif

#if YYDEBUG

CID_yytoktype CID_yytoks[] =
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

char * CID_yyreds[] =
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
#define YYERROR		goto CID_yyerrlab
#define YYACCEPT	return(0)
#define YYABORT		return(1)
#define YYBACKUP( newtoken, newvalue )\
{\
	if ( CID_yychar >= 0 || ( CID_yyr2[ CID_yytmp ] >> 1 ) != 1 )\
	{\
		CID_yyerror( "syntax error - cannot backup" );\
		goto CID_yyerrlab;\
	}\
	CID_yychar = newtoken;\
	CID_yystate = *CID_yyps;\
	CID_yylval = newvalue;\
	goto CID_yynewstate;\
}
#define YYRECOVERING()	(!!CID_yyerrflag)
#ifndef YYDEBUG
#	define YYDEBUG	1	/* make debugging available */
#endif

/*
** user known globals
*/
int CID_yydebug;			/* set to 1 to get debugging */

/*
** driver internal defines
*/
#define YYFLAG		(-1000)

/*
** global variables used by the parser
*/
YYSTYPE CID_yyv[ YYMAXDEPTH ];	/* value stack */
int CID_yys[ YYMAXDEPTH ];		/* state stack */

YYSTYPE *CID_yypv;			/* top of value stack */
int *CID_yyps;			/* top of state stack */

int CID_yystate;			/* current state */
int CID_yytmp;			/* extra var (lasts between blocks) */

int CID_yynerrs;			/* number of errors */
int CID_yyerrflag;			/* error recovery flag */
int CID_yychar;			/* current input token number */



/*
** CID_yyparse - return 0 if worked, 1 if syntax error not recovered from
*/
int
CID_yyparse()
{
	register YYSTYPE *CID_yypvt;	/* top of value stack for $vars */

	/*
	** Initialize externals - CID_yyparse may be called more than once
	*/
	CID_yypv = &CID_yyv[-1];
	CID_yyps = &CID_yys[-1];
	CID_yystate = 0;
	CID_yytmp = 0;
	CID_yynerrs = 0;
	CID_yyerrflag = 0;
	CID_yychar = -1;

	goto CID_yystack;
	{
		register YYSTYPE *CID_yy_pv;	/* top of value stack */
		register int *CID_yy_ps;		/* top of state stack */
		register int CID_yy_state;		/* current state */
		register int  CID_yy_n;		/* internal state number info */

		/*
		** get globals into registers.
		** branch to here only if YYBACKUP was called.
		*/
	CID_yynewstate:
		CID_yy_pv = CID_yypv;
		CID_yy_ps = CID_yyps;
		CID_yy_state = CID_yystate;
		goto CID_yy_newstate;

		/*
		** get globals into registers.
		** either we just started, or we just finished a reduction
		*/
	CID_yystack:
		CID_yy_pv = CID_yypv;
		CID_yy_ps = CID_yyps;
		CID_yy_state = CID_yystate;

		/*
		** top of for (;;) loop while no reductions done
		*/
	CID_yy_stack:
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
		if ( CID_yydebug )
		{
			register int CID_yy_i;

			printf( "State %d, token ", CID_yy_state );
			if ( CID_yychar == 0 )
				printf( "end-of-file\n" );
			else if ( CID_yychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( CID_yy_i = 0; CID_yytoks[CID_yy_i].t_val >= 0;
					CID_yy_i++ )
				{
					if ( CID_yytoks[CID_yy_i].t_val == CID_yychar )
						break;
				}
				printf( "%s\n", CID_yytoks[CID_yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ++CID_yy_ps >= &CID_yys[ YYMAXDEPTH ] )	/* room on stack? */
		{
			CID_yyerror( "yacc stack overflow" );
			YYABORT;
		}
		*CID_yy_ps = CID_yy_state;
		*++CID_yy_pv = CID_yyval;

		/*
		** we have a new state - find out what to do
		*/
	CID_yy_newstate:
		if ( ( CID_yy_n = CID_yypact[ CID_yy_state ] ) <= YYFLAG )
			goto CID_yydefault;		/* simple state */
#if YYDEBUG
		/*
		** if debugging, need to mark whether new token grabbed
		*/
		CID_yytmp = CID_yychar < 0;
#endif
		if ( ( CID_yychar < 0 ) && ( ( CID_yychar = CID_yylex() ) < 0 ) )
			CID_yychar = 0;		/* reached EOF */
#if YYDEBUG
		if ( CID_yydebug && CID_yytmp )
		{
			register int CID_yy_i;

			printf( "Received token " );
			if ( CID_yychar == 0 )
				printf( "end-of-file\n" );
			else if ( CID_yychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( CID_yy_i = 0; CID_yytoks[CID_yy_i].t_val >= 0;
					CID_yy_i++ )
				{
					if ( CID_yytoks[CID_yy_i].t_val == CID_yychar )
						break;
				}
				printf( "%s\n", CID_yytoks[CID_yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ( ( CID_yy_n += CID_yychar ) < 0 ) || ( CID_yy_n >= YYLAST ) )
			goto CID_yydefault;
		if ( CID_yychk[ CID_yy_n = CID_yyact[ CID_yy_n ] ] == CID_yychar )	/*valid shift*/
		{
			CID_yychar = -1;
			CID_yyval = CID_yylval;
			CID_yy_state = CID_yy_n;
			if ( CID_yyerrflag > 0 )
				CID_yyerrflag--;
			goto CID_yy_stack;
		}

	CID_yydefault:
		if ( ( CID_yy_n = CID_yydef[ CID_yy_state ] ) == -2 )
		{
#if YYDEBUG
			CID_yytmp = CID_yychar < 0;
#endif
			if ( ( CID_yychar < 0 ) && ( ( CID_yychar = CID_yylex() ) < 0 ) )
				CID_yychar = 0;		/* reached EOF */
#if YYDEBUG
			if ( CID_yydebug && CID_yytmp )
			{
				register int CID_yy_i;

				printf( "Received token " );
				if ( CID_yychar == 0 )
					printf( "end-of-file\n" );
				else if ( CID_yychar < 0 )
					printf( "-none-\n" );
				else
				{
					for ( CID_yy_i = 0;
						CID_yytoks[CID_yy_i].t_val >= 0;
						CID_yy_i++ )
					{
						if ( CID_yytoks[CID_yy_i].t_val
							== CID_yychar )
						{
							break;
						}
					}
					printf( "%s\n", CID_yytoks[CID_yy_i].t_name );
				}
			}
#endif /* YYDEBUG */
			/*
			** look through exception table
			*/
			{
				register int *CID_yyxi = CID_yyexca;

				while ( ( *CID_yyxi != -1 ) ||
					( CID_yyxi[1] != CID_yy_state ) )
				{
					CID_yyxi += 2;
				}
				while ( ( *(CID_yyxi += 2) >= 0 ) &&
					( *CID_yyxi != CID_yychar ) )
					;
				if ( ( CID_yy_n = CID_yyxi[1] ) < 0 )
					YYACCEPT;
			}
		}

		/*
		** check for syntax error
		*/
		if ( CID_yy_n == 0 )	/* have an error */
		{
			/* no worry about speed here! */
			switch ( CID_yyerrflag )
			{
			case 0:		/* new error */
				CID_yyerror( "syntax error" );
				goto skip_init;
			CID_yyerrlab:
				/*
				** get globals into registers.
				** we have a user generated syntax type error
				*/
				CID_yy_pv = CID_yypv;
				CID_yy_ps = CID_yyps;
				CID_yy_state = CID_yystate;
				CID_yynerrs++;
			skip_init:
			case 1:
			case 2:		/* incompletely recovered error */
					/* try again... */
				CID_yyerrflag = 3;
				/*
				** find state where "error" is a legal
				** shift action
				*/
				while ( CID_yy_ps >= CID_yys )
				{
					CID_yy_n = CID_yypact[ *CID_yy_ps ] + YYERRCODE;
					if ( CID_yy_n >= 0 && CID_yy_n < YYLAST &&
						CID_yychk[CID_yyact[CID_yy_n]] == YYERRCODE)					{
						/*
						** simulate shift of "error"
						*/
						CID_yy_state = CID_yyact[ CID_yy_n ];
						goto CID_yy_stack;
					}
					/*
					** current state has no shift on
					** "error", pop stack
					*/
#if YYDEBUG
#	define _POP_ "Error recovery pops state %d, uncovers state %d\n"
					if ( CID_yydebug )
						printf( _POP_, *CID_yy_ps,
							CID_yy_ps[-1] );
#	undef _POP_
#endif
					CID_yy_ps--;
					CID_yy_pv--;
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
				if ( CID_yydebug )
				{
					register int CID_yy_i;

					printf( "Error recovery discards " );
					if ( CID_yychar == 0 )
						printf( "token end-of-file\n" );
					else if ( CID_yychar < 0 )
						printf( "token -none-\n" );
					else
					{
						for ( CID_yy_i = 0;
							CID_yytoks[CID_yy_i].t_val >= 0;
							CID_yy_i++ )
						{
							if ( CID_yytoks[CID_yy_i].t_val
								== CID_yychar )
							{
								break;
							}
						}
						printf( "token %s\n",
							CID_yytoks[CID_yy_i].t_name );
					}
				}
#endif /* YYDEBUG */
				if ( CID_yychar == 0 )	/* reached EOF. quit */
					YYABORT;
				CID_yychar = -1;
				goto CID_yy_newstate;
			}
		}/* end if ( CID_yy_n == 0 ) */
		/*
		** reduction by production CID_yy_n
		** put stack tops, etc. so things right after switch
		*/
#if YYDEBUG
		/*
		** if debugging, print the string that is the user's
		** specification of the reduction which is just about
		** to be done.
		*/
		if ( CID_yydebug )
			printf( "Reduce by (%d) \"%s\"\n",
				CID_yy_n, CID_yyreds[ CID_yy_n ] );
#endif
		CID_yytmp = CID_yy_n;			/* value to switch over */
		CID_yypvt = CID_yy_pv;			/* $vars top of value stack */
		/*
		** Look in goto table for next state
		** Sorry about using CID_yy_state here as temporary
		** register variable, but why not, if it works...
		** If CID_yyr2[ CID_yy_n ] doesn't have the low order bit
		** set, then there is no action to be done for
		** this reduction.  So, no saving & unsaving of
		** registers done.  The only difference between the
		** code just after the if and the body of the if is
		** the goto CID_yy_stack in the body.  This way the test
		** can be made before the choice of what to do is needed.
		*/
		{
			/* length of production doubled with extra bit */
			register int CID_yy_len = CID_yyr2[ CID_yy_n ];

			if ( !( CID_yy_len & 01 ) )
			{
				CID_yy_len >>= 1;
				CID_yyval = ( CID_yy_pv -= CID_yy_len )[1];	/* $$ = $1 */
				CID_yy_state = CID_yypgo[ CID_yy_n = CID_yyr1[ CID_yy_n ] ] +
					*( CID_yy_ps -= CID_yy_len ) + 1;
				if ( CID_yy_state >= YYLAST ||
					CID_yychk[ CID_yy_state =
					CID_yyact[ CID_yy_state ] ] != -CID_yy_n )
				{
					CID_yy_state = CID_yyact[ CID_yypgo[ CID_yy_n ] ];
				}
				goto CID_yy_stack;
			}
			CID_yy_len >>= 1;
			CID_yyval = ( CID_yy_pv -= CID_yy_len )[1];	/* $$ = $1 */
			CID_yy_state = CID_yypgo[ CID_yy_n = CID_yyr1[ CID_yy_n ] ] +
				*( CID_yy_ps -= CID_yy_len ) + 1;
			if ( CID_yy_state >= YYLAST ||
				CID_yychk[ CID_yy_state = CID_yyact[ CID_yy_state ] ] != -CID_yy_n )
			{
				CID_yy_state = CID_yyact[ CID_yypgo[ CID_yy_n ] ];
			}
		}
					/* save until reenter driver code */
		CID_yystate = CID_yy_state;
		CID_yyps = CID_yy_ps;
		CID_yypv = CID_yy_pv;
	}
	/*
	** code supplied by user is placed in this switch
	*/
	switch( CID_yytmp )
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
case 9:{ AllocNCat (DLexp_cond, CID_yytext); 
		    AllocNCat (DLexp_cond, "~");
		    strcpy (PDUPAL_operator, "=");
		    DLStringExpression (PDUPAL_operator, DLexp_cond, &DLresult[NoExpressions]);
		     free ((char *)DLexp_cond);
		     DLexp_cond = NULL;
		   } break;
case 10:{ AllocNCat (DLexp_cond, " != "); } break;
case 11:{ AllocNCat (DLexp_cond, CID_yytext); 
		     AllocNCat (DLexp_cond, "~");
		    strcpy (PDUPAL_operator, "!=");
		    DLStringExpression (PDUPAL_operator, DLexp_cond, &DLresult[NoExpressions]);
		     free ((char *)DLexp_cond);
		     DLexp_cond = NULL;
		   } break;
case 15:{ 
		    if (DLexp_cond != NULL)
		    	DLexp_cond = (char *) realloc (DLexp_cond, (strlen (CID_yytext) + 1) * sizeof (char));
		    else
		    	DLexp_cond = (char *) malloc ((strlen (CID_yytext) + 1) * sizeof (char));
		    if (DLexp_cond == NULL) {
			printf ("Unable To Allocate Memory\n");
			return (0);
		    }
		    strcpy (DLexp_cond, CID_yytext); 
		    strcpy (PDUPAL_c_temp, CID_yytext);
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
case 22:{ AllocNCat (DLexp_cond,  CID_yytext);
		    PDUPAL_type = 0;
		  } break;
case 23:{ AllocNCat (DLexp_cond,  CID_yytext); 
		    PDUPAL_type = 0;
		  } break;
case 24:{ AllocNCat (DLexp_cond, CID_yytext);
		    PDUPAL_type = 1;
		  } break;
	}
	goto CID_yystack;		/* reset registers in driver code */
}
