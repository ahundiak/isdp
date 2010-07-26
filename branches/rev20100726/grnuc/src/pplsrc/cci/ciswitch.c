/* -- Switch implementation.

	switch( <cond> ) {			goto -ST...
		case <v1> :			-SCv1  :
		case <v2> :			-SCv2  :
		...				...
		default	  :			-SD... :
						goto -SE...
	}					-ST... : if( v1 ) goto -SCv1
							 if( v2 ) goto -SCv2
							 ...
							 goto -SD
						-SE...
      Label codes : -ST : Switch/Test section
                    -SC : Switch/Case
                    -SD : Switch/Default
		    -SE : Switch/End
   -- */
/*-INCLUDES-------------------------------------------------------------------*/
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "cidef.h"
#include "citypedef.h"
#include "ciy.h"
#include <ctype.h>
#include <malloc.h>
#include <string.h>
/*-TYPEDEFS-------------------------------------------------------------------*/
typedef struct {	Ushort value ;
			Ushort label ;
} SWlabel ;
/*-CONSTANTS------------------------------------------------------------------*/
#define SWUNDEF		((Ushort) -1)		/* Label undefined	*/
#define SWDEFLT		( SWUNDEF - 1 )		/* Default case		*/
#define SWEMPTY		( sw__cur == sw__table )	/* Switch table empty	*/
#define SWOVFLW		( sw__cur >= sw__table + MAXSWITCH )
#define DEBUG 0
/*-GLOBALS--------------------------------------------------------------------*/
/* -- Table of switch cases and pointer to current one.
   -- */
static SWlabel	sw__table[MAXSWITCH], *sw__cur = sw__table ;
static short	sw__first = MAXSWITCH			;
/*-EXTERNS--------------------------------------------------------------------*/
char *LABname() ;

/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif
/*
static int SWval __((Ushort lab));
static int SWcmp __((SWlabel *l1, SWlabel *l2));  */

#if defined(__cplusplus)
}
#endif
#undef __


/*----------------------------------------------------------------------------*/
int SWbegin( exp, tst, end )	int		*exp		;
				PCIident	tst, end	; {

/* -- Starts a new  switch  statement.
      UPDATE : exp, index of switch variable(assigned to int register if needed)
      OUTPUT : tst, end, names of test and end-switch labels.
      RETURNS: the index of the first case for the previous switch or
      	       EMPTY if overflow.
      NOTE: The returned value, `tst', `end' are to be saved in the yacc stack.
            If the expression of the switch is not a word, it is assigned to an
            integer register.
   -- */

  int			ofirst = EMPTY, reg		;
  PCIop			asg				;
  extern OPERATOR	OPinfo[]			;
  PCItype		*pTYPbasic()			;

#if DEBUG
  printf( "SWbegin : ENTER first %d, current %d\n", sw__first, sw__cur - sw__table ) ;
#endif
  if( SWOVFLW ) ERRovr( "switch table overflow", NULL ) ;
  else {
	if( isbsari( *exp ) ) {
		if( isconst( *exp ) ) 
		     WNGsyn( "constant in conditional context", NULL ) ;
		if( !isword( *exp ) ) {
		  asg.instr = OPinfo[asg.code = _ASSIGN].icode ;
		  if(    ( reg = mkREG( pTYPbasic( CI_INT ) ) ) == EMPTY
		      || !OPasg( exp, reg, &asg, *exp ) ) return EMPTY ;
		}
/* --		Go to Switch/Test label and create empty Switch/End label.
   -- */
		if( INSjmp( LABname( tst ), SW_TST, jmpGOTO ) ) {
		   if( mkLAB( LABname( end ), SW_END, EMPTY ) != EMPTY ) {
				ofirst		= sw__first	    ;
				sw__first	= sw__cur - sw__table ;
/* --				Reserve first label for the `default' case.
   -- */
				sw__cur++->label	= SWDEFLT	    ;
		   }
		}
	} else ERRsyn( "switch expression must be numeric", NULL ) ;
  }

#if DEBUG
  printf( "SWbegin : EXIT 1st %d, cur %d pre %d\n", sw__first, sw__cur - sw__table, ofirst ) ;
#endif

  return ofirst ;

} /* SWbegin */
/*----------------------------------------------------------------------------*/
int SWcase( val )	int val ; {

/* -- Adds case to switch. `val' is the value of the label expression.
      		switch( <exp> ) { case <val> : ... }
   -- */

		int rc = TRUE ;

#if DEBUG
  printf( "SWcase : val <%d>(%u) current %d\n", val, val, sw__cur - sw__table ) ;
#endif
       if( SWEMPTY ) rc = ERRsyn( "case not in switch"   , NULL )	;
  else if( SWOVFLW ) rc = ERRovr( "switch table overflow", NULL )	;
  else if( rc = (int) ( sw__cur->value = mkCSTint( val ) ) != EMPTY ) {
	if( ( rc = mkLAB( LABname( NULL ), SW_CAS, PCInins ) ) != - 1 )
		sw__cur->label = rc	;
	else	rc = FALSE		;
	sw__cur++ ;
  }

 return rc ;

} /* SWcase */
/*----------------------------------------------------------------------------*/
int SWdefc() {

/* -- Adds default case to switch. Puts it as the first label of this switch.
   -- */

			int rc ;

#if DEBUG
  printf( "SWdefc : first %d current %d\n", sw__first, sw__cur - sw__table ) ;
#endif
  if( sw__table[sw__first].label < SWDEFLT )
  	rc = ERRsyn( "duplicate default in switch", NULL ) ;
  else       if( SWEMPTY ) rc = ERRsyn( "default not in switch", NULL )	;
	else if( SWOVFLW ) rc = ERRovr( "switch table overflow", NULL )	;
	else {
/* --		Put first at current place and `default' at first.
   -- */
	  sw__table[sw__first].value = SWDEFLT	;
	  if( ( rc = mkLAB( LABname( NULL ), SW_DFL, PCInins ) ) != EMPTY )
		sw__table[sw__first].label = rc	;
	  else	rc = FALSE ;
	}
  return rc ;

} /* SWdefc */
/*----------------------------------------------------------------------------*/
/*
static int SWval( lab )		Ushort lab ; {

			int val ;

  	switch( PCIdef( lab ).Num ) {
  		case CI_CHAR	: val = PCIchr( lab )	; break ;
  		case CI_INT	: val = PCIint( lab )	; break ;
  		case CI_DOUBLE	: val = PCIdbl( lab )	; break ;
  	}
	return val ;

}*/ /* SWval */
/*----------------------------------------------------------------------------*/
/*
static int SWcmp( l1, l2 )	SWlabel *l1, *l2 ; {
*/
/* -- Compares label values.
   -- */
/*
	return SWval( l1->value ) - SWval( l2->value ) ;
}
*/
/*----------------------------------------------------------------------------*/
int SWend( exp, pre, tst, end )		int		exp, pre ;
					PCIident	tst, end ; {

/* -- Ends switch the cases of which begin at index `sw__first'.
      INPUT  : pre, index of first case of previous switch.
               exp, expression to test.
               tst, end, names of test and end-switch labels.
   -- */

  int			rc		;
  register SWlabel	*begin, *Case	;
  void			qsort()		;
#if DEBUG
  printf( "SWend : first %d current %d pre %d\n", sw__first, sw__cur - sw__table, pre ) ;
#endif
  begin = sw__table + sw__first + 1 ;

/* -- Go to to Switch/End label and create Switch/Test label.
   -- */
  if( rc =    INSjmp( end, SW_END, jmpGOTO )
  	   && mkLAB( tst, SW_TST, PCInins ) != EMPTY ) {

/* --	Make sure that no two Switch/Case labels are identical.
   --
	qsort( (char *) begin		, (unsigned) (sw__cur - begin),
		sizeof( SWlabel )	, SWcmp				) ;

 	for( Case = begin + 1 ; Case < sw__cur ; Case++ ) {
 	 	if( SWval( Case->value ) == SWval( (Case - 1)->value ) ) {
 	 		rc = ERRsyn( "duplicate case in switch", NULL ) ;
 	 		break ;
 	 	}
 	}
   --	Generate branches to Switch/Case labels.
   -- */
 	for( Case = begin ; Case < sw__cur ; Case++ )
 		if( !( rc = gen( BRANCHSW, 3, Case->label, exp, Case->value ) ) ) break ;
  }
/* -- Go to Switch/Default label if any, generate initialize Switch/End label.
   -- */
  if( rc ) {
#if DEBUG
  printf( "SWend : sw__table[sw__first].label >= SWUNDEF ? %d\n",
  		sw__table[sw__first].label >= SWUNDEF ) ;
  printf( "SWend : BRANCH to %d LINE %d\n", sw__table[sw__first].label,
          (int) PCI_Get_current_line() ) ;
#endif
  	if( sw__table[sw__first].label < SWDEFLT ) {
  		rc = gen( BRANCH, 1, sw__table[sw__first].label ) ;
  	}
  	rc = rc && mkLAB( end, SW_END, PCInins ) != EMPTY ;
  }

  sw__cur	= sw__table + sw__first	;
  sw__first	= pre			;
#if DEBUG
  printf( "SWend : EXIT first %d current %d\n", sw__first, sw__cur - sw__table ) ;
#endif
  return rc ;

} /* SWend */
/*----------------------------------------------------------------------------*/
void SWfree() {
	sw__cur		= sw__table	;
	sw__first	= MAXSWITCH	;
}
/*----------------------------------------------------------------------------*/

