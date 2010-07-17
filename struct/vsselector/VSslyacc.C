
# line 2 "VSslyacc.y"
/*
	I/STRUCT
*/
#include <stdio.h>
#include <stdlib.h>
#include "vsslc.h"
#include "vsslcmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsslcproto.h"

#define VSyyparse()	VSslcParse( err, p, aliases )	\
			VSparseErr	*err ;		\
			VS_NODE		**p ;		\
			VSaliasTable	aliases ;

#define VSyyerror( s ) VSyyError( s, err )
/*----------------------------------------------------------------------------*/

# line 23 "VSslyacc.y"
typedef union  {
	VS_TOKEN	tk ;
	VS_NODE		*nd ;
} VSyySTYPE;
# define VS_OUTPUT 257
# define VS_IF 258
# define VS_THEN 259
# define VS_ELSE 260
# define VS_ENDIF 261
# define VS_EQASGN 262
# define VS_IDENT 263
# define VS_ERROR 264
# define VS_OBJECT 265
# define VS_INPUT 266
# define VS_LPAR 267
# define VS_RPAR 268
# define VS_FUNCTION 269
# define VS_INT 270
# define VS_DOUBLE 271
# define VS_STRING 272
# define VS_PATH 273
# define VS_OR 274
# define VS_AND 275
# define VS_NE 276
# define VS_LE 277
# define VS_GE 278
# define VS_LT 279
# define VS_GT 280
# define VS_PLUS 281
# define VS_MINUS 282
# define VS_MULT 283
# define VS_DIV 284
# define VS_NOT 285
# define VS_COMMA 286
# define VS_POW 287
#define VSyyclearin VSyychar = -1
#define VSyyerrok VSyyerrflag = 0
extern int VSyychar;
extern int VSyyerrflag;
#ifndef VSyyMAXDEPTH
#define VSyyMAXDEPTH 150
#endif
VSyySTYPE VSyylval, VSyyval;
typedef int VSyytabelem;
# define VSyyERRCODE 256

# line 223 "VSslyacc.y"

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
VSyyError( s, e ) char *s ; VSparseErr *e ; {

	if( VSyychar == VS_ERROR ) {
		VSslcSetParseErr( VSyylval.tk.type, VSyylval.tk.v.sval, e ) ;
	} else {
		VSslcSetParseErr( VS_SYNTAX_ERROR, "", e ) ;
	}

	VSyywrap() ;

} /* VSyyError */
/*----------------------------------------------------------------------------*/

VSyytabelem VSyyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
	};
# define VSyyNPROD 44
# define VSyyLAST 179
VSyytabelem VSyyact[]={

    37,    38,    39,    40,    41,    42,    61,    42,    68,    12,
    67,    45,    36,    35,    34,    30,    32,    31,    33,    38,
    39,    40,    41,    37,    29,    42,    40,    41,     9,    10,
    42,    70,    69,    47,    46,    36,    35,    34,    30,    32,
    31,    33,    38,    39,    40,    41,    37,     4,    42,     9,
    10,     9,    10,    73,    64,     2,    15,    63,    37,    35,
    34,    30,    32,    31,    33,    38,    39,    40,    41,     3,
    62,    42,    34,    30,    32,    31,    33,    38,    39,    40,
    41,    16,    13,    42,    30,    32,    31,    33,    38,    39,
    40,    41,    22,    23,    42,    20,    18,    27,    19,    24,
    25,    26,    21,     9,    10,     5,     8,     7,     1,    11,
    65,     0,     6,     0,    17,     0,    66,     0,     0,     0,
    14,    28,     0,    71,     0,     0,     0,     0,    43,    44,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
    72,    48,    49,    50,    51,    52,    53,    54,    55,    56,
    57,    58,    59,    60,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,    11,     0,     0,     0,     0,     0,    11 };
VSyytabelem VSyypact[]={

 -1000, -1000,  -154,  -206, -1000, -1000,  -261, -1000, -1000,  -171,
  -171, -1000,  -238, -1000,  -239, -1000, -1000,  -171,  -171,  -256,
 -1000, -1000, -1000, -1000, -1000, -1000, -1000,  -225,  -239,  -230,
  -171,  -171,  -171,  -171,  -171,  -171,  -171,  -171,  -171,  -171,
  -171,  -171,  -171,  -282,  -262,  -171,  -206, -1000,  -280,  -280,
  -280,  -280,  -193,  -204,  -216,  -193,  -257,  -257,  -282,  -282,
 -1000, -1000,  -258,  -278, -1000,  -239,  -229, -1000,  -171, -1000,
  -206, -1000,  -208, -1000 };
VSyytabelem VSyypgo[]={

     0,   108,   107,    69,   105,   106,    97,   110,    95,    82,
    81,    54,    70,    57,    56,    55,    47 };
VSyytabelem VSyyr1[]={

     0,     1,    15,    15,    16,     3,     3,     4,     4,     5,
     5,     7,     7,     7,     7,     7,     7,     7,     7,     7,
     7,     7,     7,     7,     7,     7,     7,     7,     7,     7,
    11,    12,    12,    13,    13,     6,     2,     9,     8,     8,
     8,    10,    10,    14 };
VSyytabelem VSyyr2[]={

     0,     5,     0,     4,     9,     3,     5,     3,     3,    11,
    15,     3,     3,     7,     7,     7,     7,     7,     7,     7,
     7,     7,     7,     7,     7,     7,     5,     7,     9,     3,
     3,     1,     3,     3,     7,     3,     5,     3,     3,     3,
     3,     3,     3,     3 };
VSyytabelem VSyychk[]={

 -1000,    -1,   -15,    -3,   -16,    -4,   266,    -2,    -5,   257,
   258,    -4,   270,    -9,    -7,   -14,   -10,   285,   267,   269,
    -8,   273,   263,   264,   270,   271,   272,    -6,    -7,   262,
   277,   279,   278,   280,   276,   275,   274,   262,   281,   282,
   283,   284,   287,    -7,    -7,   267,   259,   263,    -7,    -7,
    -7,    -7,    -7,    -7,    -7,    -7,    -7,    -7,    -7,    -7,
    -7,   268,   -12,   -13,   -11,    -7,    -3,   268,   286,   261,
   260,   -11,    -3,   261 };
VSyytabelem VSyydef[]={

     2,    -2,     0,     1,     3,     5,     0,     7,     8,     0,
     0,     6,     0,    36,    37,    11,    12,     0,     0,     0,
    29,    43,    41,    42,    38,    39,    40,     0,    35,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,    26,     0,    31,     0,     4,    13,    14,
    15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
    25,    27,     0,    32,    33,    30,     0,    28,     0,     9,
     0,    34,     0,    10 };
typedef struct { char *t_name; int t_val; } VSyytoktype;
#ifndef VSyyDEBUG
#	define VSyyDEBUG	0	/* don't allow debugging */
#endif

#if VSyyDEBUG

VSyytoktype VSyytoks[] =
{
	"VS_OUTPUT",	257,
	"VS_IF",	258,
	"VS_THEN",	259,
	"VS_ELSE",	260,
	"VS_ENDIF",	261,
	"VS_EQASGN",	262,
	"VS_IDENT",	263,
	"VS_ERROR",	264,
	"VS_OBJECT",	265,
	"VS_INPUT",	266,
	"VS_LPAR",	267,
	"VS_RPAR",	268,
	"VS_FUNCTION",	269,
	"VS_INT",	270,
	"VS_DOUBLE",	271,
	"VS_STRING",	272,
	"VS_PATH",	273,
	"VS_OR",	274,
	"VS_AND",	275,
	"VS_NE",	276,
	"VS_LE",	277,
	"VS_GE",	278,
	"VS_LT",	279,
	"VS_GT",	280,
	"VS_PLUS",	281,
	"VS_MINUS",	282,
	"VS_MULT",	283,
	"VS_DIV",	284,
	"VS_NOT",	285,
	"VS_COMMA",	286,
	"VS_POW",	287,
	"-unknown-",	-1	/* ends search */
};

char * VSyyreds[] =
{
	"-no such reduction-",
	"program : aliases instructions",
	"aliases : /* empty */",
	"aliases : aliases alias",
	"alias : VS_INPUT VS_INT VS_EQASGN VS_IDENT",
	"instructions : statement",
	"instructions : instructions statement",
	"statement : output",
	"statement : ifclause",
	"ifclause : VS_IF condition VS_THEN instructions VS_ENDIF",
	"ifclause : VS_IF condition VS_THEN instructions VS_ELSE instructions VS_ENDIF",
	"expression : path",
	"expression : ident",
	"expression : expression VS_LE expression",
	"expression : expression VS_LT expression",
	"expression : expression VS_GE expression",
	"expression : expression VS_GT expression",
	"expression : expression VS_NE expression",
	"expression : expression VS_AND expression",
	"expression : expression VS_OR expression",
	"expression : expression VS_EQASGN expression",
	"expression : expression VS_PLUS expression",
	"expression : expression VS_MINUS expression",
	"expression : expression VS_MULT expression",
	"expression : expression VS_DIV expression",
	"expression : expression VS_POW expression",
	"expression : VS_NOT expression",
	"expression : VS_LPAR expression VS_RPAR",
	"expression : VS_FUNCTION VS_LPAR oarglist VS_RPAR",
	"expression : constant",
	"arg : expression",
	"oarglist : /* empty */",
	"oarglist : arglist",
	"arglist : arg",
	"arglist : arglist VS_COMMA arg",
	"condition : expression",
	"output : VS_OUTPUT outobj",
	"outobj : expression",
	"constant : VS_INT",
	"constant : VS_DOUBLE",
	"constant : VS_STRING",
	"ident : VS_IDENT",
	"ident : VS_ERROR",
	"path : VS_PATH",
};
#endif /* VSyyDEBUG */
/* #ident	"@(#)yacc:yaccpar	1.10	1.3 (Intergraph) 3/10/88" */

/*
** Skeleton parser driver for yacc output
*/

/*
** yacc user known macros and defines
*/
#define VSyyERROR		goto VSyyerrlab
#define VSyyACCEPT	return(0)
#define VSyyABORT		return(1)
#define VSyyBACKUP( newtoken, newvalue )\
{\
	if ( VSyychar >= 0 || ( VSyyr2[ VSyytmp ] >> 1 ) != 1 )\
	{\
		VSyyerror( "syntax error - cannot backup" );\
		goto VSyyerrlab;\
	}\
	VSyychar = newtoken;\
	VSyystate = *VSyyps;\
	VSyylval = newvalue;\
	goto VSyynewstate;\
}
#define VSyyRECOVERING()	(!!VSyyerrflag)
#ifndef VSyyDEBUG
#	define VSyyDEBUG	1	/* make debugging available */
#endif

/*
** user known globals
*/
int VSyydebug;			/* set to 1 to get debugging */

/*
** driver internal defines
*/
#define VSyyFLAG		(-1000)

/*
** global variables used by the parser
*/
VSyySTYPE VSyyv[ VSyyMAXDEPTH ];	/* value stack */
int VSyys[ VSyyMAXDEPTH ];		/* state stack */

VSyySTYPE *VSyypv;			/* top of value stack */
int *VSyyps;			/* top of state stack */

int VSyystate;			/* current state */
int VSyytmp;			/* extra var (lasts between blocks) */

int VSyynerrs;			/* number of errors */
int VSyyerrflag;			/* error recovery flag */
int VSyychar;			/* current input token number */



/*
** VSyyparse - return 0 if worked, 1 if syntax error not recovered from
*/
int
VSyyparse()
{
	register VSyySTYPE *VSyypvt;	/* top of value stack for $vars */

	/*
	** Initialize externals - VSyyparse may be called more than once
	*/
	VSyypv = &VSyyv[-1];
	VSyyps = &VSyys[-1];
	VSyystate = 0;
	VSyytmp = 0;
	VSyynerrs = 0;
	VSyyerrflag = 0;
	VSyychar = -1;

	goto VSyystack;
	{
		register VSyySTYPE *VSyy_pv;	/* top of value stack */
		register int *VSyy_ps;		/* top of state stack */
		register int VSyy_state;		/* current state */
		register int  VSyy_n;		/* internal state number info */

		/*
		** get globals into registers.
		** branch to here only if VSyyBACKUP was called.
		*/
	VSyynewstate:
		VSyy_pv = VSyypv;
		VSyy_ps = VSyyps;
		VSyy_state = VSyystate;
		goto VSyy_newstate;

		/*
		** get globals into registers.
		** either we just started, or we just finished a reduction
		*/
	VSyystack:
		VSyy_pv = VSyypv;
		VSyy_ps = VSyyps;
		VSyy_state = VSyystate;

		/*
		** top of for (;;) loop while no reductions done
		*/
	VSyy_stack:
		/*
		** put a state and value onto the stacks
		*/
#if VSyyDEBUG
		/*
		** if debugging, look up token value in list of value vs.
		** name pairs.  0 and negative (-1) are special values.
		** Note: linear search is used since time is not a real
		** consideration while debugging.
		*/
		if ( VSyydebug )
		{
			register int VSyy_i;

			printf( "State %d, token ", VSyy_state );
			if ( VSyychar == 0 )
				printf( "end-of-file\n" );
			else if ( VSyychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( VSyy_i = 0; VSyytoks[VSyy_i].t_val >= 0;
					VSyy_i++ )
				{
					if ( VSyytoks[VSyy_i].t_val == VSyychar )
						break;
				}
				printf( "%s\n", VSyytoks[VSyy_i].t_name );
			}
		}
#endif /* VSyyDEBUG */
		if ( ++VSyy_ps >= &VSyys[ VSyyMAXDEPTH ] )	/* room on stack? */
		{
			VSyyerror( "yacc stack overflow" );
			VSyyABORT;
		}
		*VSyy_ps = VSyy_state;
		*++VSyy_pv = VSyyval;

		/*
		** we have a new state - find out what to do
		*/
	VSyy_newstate:
		if ( ( VSyy_n = VSyypact[ VSyy_state ] ) <= VSyyFLAG )
			goto VSyydefault;		/* simple state */
#if VSyyDEBUG
		/*
		** if debugging, need to mark whether new token grabbed
		*/
		VSyytmp = VSyychar < 0;
#endif
		if ( ( VSyychar < 0 ) && ( ( VSyychar = VSyylex() ) < 0 ) )
			VSyychar = 0;		/* reached EOF */
#if VSyyDEBUG
		if ( VSyydebug && VSyytmp )
		{
			register int VSyy_i;

			printf( "Received token " );
			if ( VSyychar == 0 )
				printf( "end-of-file\n" );
			else if ( VSyychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( VSyy_i = 0; VSyytoks[VSyy_i].t_val >= 0;
					VSyy_i++ )
				{
					if ( VSyytoks[VSyy_i].t_val == VSyychar )
						break;
				}
				printf( "%s\n", VSyytoks[VSyy_i].t_name );
			}
		}
#endif /* VSyyDEBUG */
		if ( ( ( VSyy_n += VSyychar ) < 0 ) || ( VSyy_n >= VSyyLAST ) )
			goto VSyydefault;
		if ( VSyychk[ VSyy_n = VSyyact[ VSyy_n ] ] == VSyychar )	/*valid shift*/
		{
			VSyychar = -1;
			VSyyval = VSyylval;
			VSyy_state = VSyy_n;
			if ( VSyyerrflag > 0 )
				VSyyerrflag--;
			goto VSyy_stack;
		}

	VSyydefault:
		if ( ( VSyy_n = VSyydef[ VSyy_state ] ) == -2 )
		{
#if VSyyDEBUG
			VSyytmp = VSyychar < 0;
#endif
			if ( ( VSyychar < 0 ) && ( ( VSyychar = VSyylex() ) < 0 ) )
				VSyychar = 0;		/* reached EOF */
#if VSyyDEBUG
			if ( VSyydebug && VSyytmp )
			{
				register int VSyy_i;

				printf( "Received token " );
				if ( VSyychar == 0 )
					printf( "end-of-file\n" );
				else if ( VSyychar < 0 )
					printf( "-none-\n" );
				else
				{
					for ( VSyy_i = 0;
						VSyytoks[VSyy_i].t_val >= 0;
						VSyy_i++ )
					{
						if ( VSyytoks[VSyy_i].t_val
							== VSyychar )
						{
							break;
						}
					}
					printf( "%s\n", VSyytoks[VSyy_i].t_name );
				}
			}
#endif /* VSyyDEBUG */
			/*
			** look through exception table
			*/
			{
				register int *VSyyxi = VSyyexca;

				while ( ( *VSyyxi != -1 ) ||
					( VSyyxi[1] != VSyy_state ) )
				{
					VSyyxi += 2;
				}
				while ( ( *(VSyyxi += 2) >= 0 ) &&
					( *VSyyxi != VSyychar ) )
					;
				if ( ( VSyy_n = VSyyxi[1] ) < 0 )
					VSyyACCEPT;
			}
		}

		/*
		** check for syntax error
		*/
		if ( VSyy_n == 0 )	/* have an error */
		{
			/* no worry about speed here! */
			switch ( VSyyerrflag )
			{
			case 0:		/* new error */
				VSyyerror( "syntax error" );
				goto skip_init;
			VSyyerrlab:
				/*
				** get globals into registers.
				** we have a user generated syntax type error
				*/
				VSyy_pv = VSyypv;
				VSyy_ps = VSyyps;
				VSyy_state = VSyystate;
				VSyynerrs++;
			skip_init:
			case 1:
			case 2:		/* incompletely recovered error */
					/* try again... */
				VSyyerrflag = 3;
				/*
				** find state where "error" is a legal
				** shift action
				*/
				while ( VSyy_ps >= VSyys )
				{
					VSyy_n = VSyypact[ *VSyy_ps ] + VSyyERRCODE;
					if ( VSyy_n >= 0 && VSyy_n < VSyyLAST &&
						VSyychk[VSyyact[VSyy_n]] == VSyyERRCODE)					{
						/*
						** simulate shift of "error"
						*/
						VSyy_state = VSyyact[ VSyy_n ];
						goto VSyy_stack;
					}
					/*
					** current state has no shift on
					** "error", pop stack
					*/
#if VSyyDEBUG
#	define _POP_ "Error recovery pops state %d, uncovers state %d\n"
					if ( VSyydebug )
						printf( _POP_, *VSyy_ps,
							VSyy_ps[-1] );
#	undef _POP_
#endif
					VSyy_ps--;
					VSyy_pv--;
				}
				/*
				** there is no state on stack with "error" as
				** a valid shift.  give up.
				*/
				VSyyABORT;
			case 3:		/* no shift yet; eat a token */
#if VSyyDEBUG
				/*
				** if debugging, look up token in list of
				** pairs.  0 and negative shouldn't occur,
				** but since timing doesn't matter when
				** debugging, it doesn't hurt to leave the
				** tests here.
				*/
				if ( VSyydebug )
				{
					register int VSyy_i;

					printf( "Error recovery discards " );
					if ( VSyychar == 0 )
						printf( "token end-of-file\n" );
					else if ( VSyychar < 0 )
						printf( "token -none-\n" );
					else
					{
						for ( VSyy_i = 0;
							VSyytoks[VSyy_i].t_val >= 0;
							VSyy_i++ )
						{
							if ( VSyytoks[VSyy_i].t_val
								== VSyychar )
							{
								break;
							}
						}
						printf( "token %s\n",
							VSyytoks[VSyy_i].t_name );
					}
				}
#endif /* VSyyDEBUG */
				if ( VSyychar == 0 )	/* reached EOF. quit */
					VSyyABORT;
				VSyychar = -1;
				goto VSyy_newstate;
			}
		}/* end if ( VSyy_n == 0 ) */
		/*
		** reduction by production VSyy_n
		** put stack tops, etc. so things right after switch
		*/
#if VSyyDEBUG
		/*
		** if debugging, print the string that is the user's
		** specification of the reduction which is just about
		** to be done.
		*/
		if ( VSyydebug )
			printf( "Reduce by (%d) \"%s\"\n",
				VSyy_n, VSyyreds[ VSyy_n ] );
#endif
		VSyytmp = VSyy_n;			/* value to switch over */
		VSyypvt = VSyy_pv;			/* $vars top of value stack */
		/*
		** Look in goto table for next state
		** Sorry about using VSyy_state here as temporary
		** register variable, but why not, if it works...
		** If VSyyr2[ VSyy_n ] doesn't have the low order bit
		** set, then there is no action to be done for
		** this reduction.  So, no saving & unsaving of
		** registers done.  The only difference between the
		** code just after the if and the body of the if is
		** the goto VSyy_stack in the body.  This way the test
		** can be made before the choice of what to do is needed.
		*/
		{
			/* length of production doubled with extra bit */
			register int VSyy_len = VSyyr2[ VSyy_n ];

			if ( !( VSyy_len & 01 ) )
			{
				VSyy_len >>= 1;
				VSyyval = ( VSyy_pv -= VSyy_len )[1];	/* $$ = $1 */
				VSyy_state = VSyypgo[ VSyy_n = VSyyr1[ VSyy_n ] ] +
					*( VSyy_ps -= VSyy_len ) + 1;
				if ( VSyy_state >= VSyyLAST ||
					VSyychk[ VSyy_state =
					VSyyact[ VSyy_state ] ] != -VSyy_n )
				{
					VSyy_state = VSyyact[ VSyypgo[ VSyy_n ] ];
				}
				goto VSyy_stack;
			}
			VSyy_len >>= 1;
			VSyyval = ( VSyy_pv -= VSyy_len )[1];	/* $$ = $1 */
			VSyy_state = VSyypgo[ VSyy_n = VSyyr1[ VSyy_n ] ] +
				*( VSyy_ps -= VSyy_len ) + 1;
			if ( VSyy_state >= VSyyLAST ||
				VSyychk[ VSyy_state = VSyyact[ VSyy_state ] ] != -VSyy_n )
			{
				VSyy_state = VSyyact[ VSyypgo[ VSyy_n ] ];
			}
		}
					/* save until reenter driver code */
		VSyystate = VSyy_state;
		VSyyps = VSyy_ps;
		VSyypv = VSyy_pv;
	}
	/*
	** code supplied by user is placed in this switch
	*/
	switch( VSyytmp )
	{
		
case 1:
# line 43 "VSslyacc.y"
{ *p = VSyyval.nd = VSyypvt[-0].nd ; } break;
case 4:
# line 50 "VSslyacc.y"
{
			if( !vs$addAlias(	error	= err,
						index	= VSyypvt[-2].tk._ival,
						alias	= VSyypvt[-0].tk._sval,
						table	= aliases ) ) {
				VSyyABORT ;
			}
		} break;
case 5:
# line 60 "VSslyacc.y"
{
			VSyyval.nd = VSyypvt[-0].nd ;
		} break;
case 6:
# line 63 "VSslyacc.y"
{
			VSyyval.nd = VSaddNode( VS_instr, VSyypvt[-1].nd, VSyypvt[-0].nd, NULL ) ;
		} break;
case 7:
# line 68 "VSslyacc.y"
{ VSyyval.nd = VSyypvt[-0].nd ; } break;
case 8:
# line 69 "VSslyacc.y"
{ VSyyval.nd = VSyypvt[-0].nd ; } break;
case 9:
# line 74 "VSslyacc.y"
{
		  	VSyyval.nd = VSaddNode( VS_if, VSyypvt[-3].nd, VSyypvt[-1].nd, NULL ) ;
		} break;
case 10:
# line 81 "VSslyacc.y"
{
		  	VSyyval.nd = VSaddNode( VS_if, VSyypvt[-5].nd, VSyypvt[-3].nd, VSyypvt[-1].nd ) ;
		} break;
case 11:
# line 86 "VSslyacc.y"
{ VSyyval.nd = VSyypvt[-0].nd ; } break;
case 12:
# line 87 "VSslyacc.y"
{
			VSyyval.nd = VSaddNode( VS_eval, VSyypvt[-0].nd, NULL, NULL ) ;
		} break;
case 13:
# line 90 "VSslyacc.y"
{
			VSyyval.nd = VSaddNode( VS_le, VSyypvt[-2].nd, VSyypvt[-0].nd, NULL ) ;
		} break;
case 14:
# line 93 "VSslyacc.y"
{
			VSyyval.nd = VSaddNode( VS_lt, VSyypvt[-2].nd, VSyypvt[-0].nd, NULL ) ;
		} break;
case 15:
# line 96 "VSslyacc.y"
{
			VSyyval.nd = VSaddNode( VS_ge, VSyypvt[-2].nd, VSyypvt[-0].nd, NULL ) ;
		} break;
case 16:
# line 99 "VSslyacc.y"
{
			VSyyval.nd = VSaddNode( VS_gt, VSyypvt[-2].nd, VSyypvt[-0].nd, NULL ) ;
		} break;
case 17:
# line 102 "VSslyacc.y"
{
			VSyyval.nd = VSaddNode( VS_ne, VSyypvt[-2].nd, VSyypvt[-0].nd, NULL ) ;
		} break;
case 18:
# line 105 "VSslyacc.y"
{
			VSyyval.nd = VSaddNode( VS_and, VSyypvt[-2].nd, VSyypvt[-0].nd, NULL ) ;
		} break;
case 19:
# line 108 "VSslyacc.y"
{
			VSyyval.nd = VSaddNode( VS_or, VSyypvt[-2].nd, VSyypvt[-0].nd, NULL ) ;
		} break;
case 20:
# line 111 "VSslyacc.y"
{
			VSyyval.nd = VSaddNode( VS_eq, VSyypvt[-2].nd, VSyypvt[-0].nd, NULL ) ;
		} break;
case 21:
# line 114 "VSslyacc.y"
{
			VSyyval.nd = VSaddNode( VS_plus, VSyypvt[-2].nd, VSyypvt[-0].nd, NULL ) ;
		} break;
case 22:
# line 117 "VSslyacc.y"
{
			VSyyval.nd = VSaddNode( VS_minus, VSyypvt[-2].nd, VSyypvt[-0].nd, NULL ) ;
		} break;
case 23:
# line 120 "VSslyacc.y"
{
			VSyyval.nd = VSaddNode( VS_mult, VSyypvt[-2].nd, VSyypvt[-0].nd, NULL ) ;
		} break;
case 24:
# line 123 "VSslyacc.y"
{
			VSyyval.nd = VSaddNode( VS_div, VSyypvt[-2].nd, VSyypvt[-0].nd, NULL ) ;
		} break;
case 25:
# line 126 "VSslyacc.y"
{
			VSyyval.nd = VSaddNode( VS_pow, VSyypvt[-2].nd, VSyypvt[-0].nd, NULL ) ;
		} break;
case 26:
# line 129 "VSslyacc.y"
{
			VSyyval.nd = VSaddNode( VS_not, VSyypvt[-0].nd, NULL, NULL ) ; 
		} break;
case 27:
# line 132 "VSslyacc.y"
{
			VSyyval.nd = VSyypvt[-1].nd ;
		} break;
case 28:
# line 135 "VSslyacc.y"
{
			/*
			 * Check that function exist and its arity is respected.
			 */
			if( VSslcCheckFunction( err, &VSyypvt[-3].tk, VSyypvt[-1].nd, aliases ) ) {
				VS_NODE	*fc ;
				fc = VSaddIdent( &VSyypvt[-3].tk ) ;
				VSyyval.nd = VSaddNode( VS_function, fc, VSyypvt[-1].nd, NULL ) ;
			} else {
				VSyyABORT ;
			}
		} break;
case 29:
# line 147 "VSslyacc.y"
{ VSyyval.nd = VSyypvt[-0].nd ; } break;
case 30:
# line 150 "VSslyacc.y"
{ VSyyval.nd = VSyypvt[-0].nd ; } break;
case 31:
# line 153 "VSslyacc.y"
{ VSyyval.nd = NULL ; } break;
case 32:
# line 154 "VSslyacc.y"
{ VSyyval.nd = VSyypvt[-0].nd ; } break;
case 33:
# line 157 "VSslyacc.y"
{
			VSyyval.nd = VSaddNode( VS_arg, VSyypvt[-0].nd, NULL, NULL ) ;
		} break;
case 34:
# line 160 "VSslyacc.y"
{
			VS_NODE	*n ;

			n = VSyypvt[-2].nd ;
			while( n ) {
				if( !n->a2 ) break ;
				n = n->a2 ;
			}
			n->a2 = VSaddNode( VS_arg, VSyypvt[-0].nd, NULL, NULL ) ;
			VSyyval.nd = VSyypvt[-2].nd ;
		} break;
case 35:
# line 173 "VSslyacc.y"
{ VSyyval.nd = VSyypvt[-0].nd ; } break;
case 36:
# line 176 "VSslyacc.y"
{ VSyyval.nd = VSyypvt[-0].nd ; } break;
case 37:
# line 179 "VSslyacc.y"
{
			VSyyval.nd = VSaddNode( VS_output, VSyypvt[-0].nd, NULL, NULL ) ;	
		} break;
case 38:
# line 184 "VSslyacc.y"
{ VSyyval.nd = VSaddConst( &VSyypvt[-0].tk ) ; } break;
case 39:
# line 185 "VSslyacc.y"
{ VSyyval.nd = VSaddConst( &VSyypvt[-0].tk ) ; } break;
case 40:
# line 186 "VSslyacc.y"
{ VSyyval.nd = VSaddConst( &VSyypvt[-0].tk ) ; } break;
case 41:
# line 189 "VSslyacc.y"
{
			if( vs$searchAlias(	alias	= VSyypvt[-0].tk._sval,
						table	= aliases ) == -1 ) {
				VSslcSetParseErr( VS_UNDEF_ALIAS, VSyypvt[-0].tk._sval, err ) ;
				VSyyABORT ;
			}
			VSyyval.nd = VSaddIdent( &VSyypvt[-0].tk ) ;
		} break;
case 42:
# line 197 "VSslyacc.y"
{

			VSslcSetParseErr( VSyypvt[-0].tk.type, VSyypvt[-0].tk._sval, err ) ;
			VSyyABORT ;
		} break;
case 43:
# line 204 "VSslyacc.y"
{
			VS_NODE		*cx,
					*ft ;
			VS_TOKEN	first,
					rest ;

			if( VSslcSplitPath(	err,
						aliases,
						&VSyypvt[-0].tk,
						&first,
						&rest ) ) {
				cx = VSaddIdent( &first ) ;
				ft = VSaddConst( &rest  ) ;
				VSyyval.nd = VSaddNode( VS_eval, cx, ft, NULL ) ;
			} else {
				VSyyABORT ;
			}	
		} break;
	}
	goto VSyystack;		/* reset registers in driver code */
}
