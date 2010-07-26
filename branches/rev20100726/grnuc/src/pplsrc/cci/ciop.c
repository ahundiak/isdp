#include "pcidef.h"
#include "pci.h"
#include "pcimacros.h"
#include "cidef.h"
#include "citypedef.h"
#include "ciy.h"
/*----------------------------------------------------------------------------*/
#define DEBUG 0
/*-EXTERNALS------------------------------------------------------------------*/
extern PCItype	*pTYPbasic()			;
extern void	TYPind(), MKname(), CTXdefault();
extern OPERATOR	OPinfo[]			;
extern unsigned VARsizeof()			;
extern int	TYPsizeof()			;
/*-MACROS---------------------------------------------------------------------*/
#define ARENUMS(i,j) ( isnumvalue( i ) && isnumvalue( j ) )
#define AREINTS(i,j) ( isinteq   ( i ) && isinteq   ( j ) )
#define AREARIS(i,j) ( isbsari   ( i ) && isbsari   ( j ) )
#define AREIPTS(i,j) ( isintvalue( i ) && isintvalue( j ) )
#define AREOBJS(i,j) ( isGRobj   ( i ) && isGRobj   ( j ) )
#define MADE( var )	( (var) != EMPTY )
#define UDEC( result, op, arg )		int *result, arg        ; PCIop *op ;
#define BDEC( result, arg1, op, arg2 )	int *result, arg1, arg2 ; PCIop *op ;

static PCIpointer Dummy1, Dummy2, Nul;

/*----------------------------------------------------------------------------*/
int OPusr( e, a1, o, a2 ) 		BDEC( e, a1, o, a2 ) {

				int rc = TRUE ;

  if( UOPcall( e, a1, o->code, a2 ) ) rc = *e != EMPTY ;
  else {
	ERRsyn( "operand of wrong type for this operator",
                 OPinfo[o->code].name ) ;
	*e = PCIvoid ;
  }
  return rc ;
}
/*----------------------------------------------------------------------------*/
int cicast( e, cast, a )	int	*e, a ;
				PCItype *cast ; {

/* -- Generates a type conversion instruction.
      NOTE : this operator is entered as a _MINUS operator in the tree.
   -- */

		int rc, _void ; PCIop asg ; PCInode N ;
/*
  if( ( cast->Def == STRUC || cast->Def == UNION ) && !cast->Ptr || cast->Dim )
       rc = ERRsyn( "invalid cast type", NULL ) ;
  else */if( isstruct( a ) )
	rc = ERRsyn( "operand of cast cannot be a union/struct", NULL ) ;
  else if( isvoidfcn( a ) || isvoid( a ) )
  	rc = ERRsyn( "operand of cast is of type void", NULL ) ;
  else {
  	if( rc = TYPcast( cast, pPCIdef( a ), &asg, &_void ) ) {
  		if( _void ) {
  			*e = PCIvoid ;
  		} else if( cast->Dim ) {
/* --			Cast of an array.
   -- */
  			PCItype *t = pTYPbasic( CI_CHAR ) ;
  			t->Ptr = 1 ;
  			rc =	MADE( *e = mkREG( t ) )
  			     && gen( asg.instr, 2, *e, a ) ;
  			a = *e			;
  			asg.instr = IASSIGNTI	;
  			cast->Dim = 0		;
  			goto CAST		;
  		} else {
  			CAST:
  			rc = rc && MADE( *e = mkREG( cast ) )
             	        	&& gen( asg.instr, 2, *e, a ) ;
  		}
  		N.type				= UNARY  ;
  		N.info.operator.symbol.code	= _MINUS ; /* arbitrary ! */
  		N.info.operator.result		= *cast	 ;
  		rc = rc && mkNOD( &N ) 	;
       }
  	
  }
     
  return rc ;

} /* cicast */
/*----------------------------------------------------------------------------*/
int OPbin( e, a1, o, a2 )		BDEC( e, a1, o, a2 )	{

		int rc = FALSE ; void FAOreset() ; PCInode bop ;

#if DEBUG
  printf( "OPbin : " ) ; VARdebug( a1 ) ; VARdebug( a2 ) ;
#endif
  switch( o->code ) {
	case _ASSIGN	: rc = OPasg( e, a1, o, a2 ) ; break ;
	case _PLUS	:
	case _MINUS	: rc = OPadd( e, a1, o, a2 ) ; break ;
	case _MUL	: 
	case _DIV	: rc = OPmul( e, a1, o, a2 ) ; break ;
	case _MOD	: rc = OPmod( e, a1, o, a2 ) ; break ;
	case _AND	:
	case _OR	:
	case _XOR 	: rc = OPbit( e, a1, o, a2 ) ; break ;
	case _CMPL	:
	case _EQUAL	:
	case _DIFF	:
	case _SUPEQU	:
	case _INFEQU	:
	case _STRSUP	:
	case _STRINF	: rc = OPrel( e, a1, o, a2 ) ; break ;
	case _ANDAND	:
	case _OROR	: rc = OPlog( e, a1, o, a2 ) ; break ;
	case _LSHIFT	:
	case _RSHIFT	: rc = OPshf( e, a1, o, a2 ) ; break ;
	case _ATSIGN	:
	case _BCKQUO	:
	case _PSCASG	:
	case _DBLCLN	:
	case _RANGE	:
	case _DBLCRT	:
	case _INFSUP	:
	case _DBLQMK	:
	case _DBLPCT	:
	case _DBLATS	:
	case _PLSNAM	:
	case _MLTNAM	: rc = OPusr( e, a1, o, a2 ) ; break ;
	default		: cibugchk( "OPbin", "unknown binary operator" ) ;
  }

  FAOreset() ;

  bop.type			= BINARY 	;
  bop.info.operator.symbol	= *o	 	;
  bop.info.operator.result	= PCIdef( *e )	;

  return rc && mkNOD( &bop ) ;
	
} /* OPbin */
/*----------------------------------------------------------------------------*/
int OPunr( e, o, a )			UDEC( e, o, a ) {

		int rc = FALSE ; void FAOreset() ; PCInode uop ;

  switch( o->code ) {
	case _NOT   	: rc = OPlogneg( e, o, a )	; break ;
	case _MINUS 	: o->instr = OPinfo[o->code=_OPP].icode;
			  rc = OPuminus( e, o, a )	; break ;
	case _CMPL  	: rc = OPbitneg( e, o, a )	; break ;
	case _MUL   	: o->instr = OPinfo[o->code=_IND].icode ;
			  rc = OPind( e, o, a )		; break ;
	case _AND   	: o->instr = OPinfo[o->code=_ADDR].icode;
			  rc = OPadr( e, o, a )		; break ;
	case _BCKQUO	:
	case _ATSIGN	:
	case _UNRNAM	: rc = OPusr( e, a, o, EMPTY )	; break ;
	default		: rc = cibugchk( "OPunr", "unknown unary operator" ) ;
  }

  FAOreset() ;
  uop.type			= UNARY		;
  uop.info.operator.symbol	= *o	 	;
  uop.info.operator.result	= PCIdef( *e )	;

  return rc && mkNOD( &uop ) ;
	
} /* OPunr */
/*----------------------------------------------------------------------------*/
int OPadd( e, a1, o, a2 )		BDEC( e, a1, o, a2 ) {

/* -- Generates a sum ( '+' or '-' ) instruction. See `TYPadd' to  find out what
      is really going on. For pointer arithmetics, the size of the corresponding
      type must be be included in the instruction.
   -- */

  PCItype	sum		;
  int		rc, a		;

#if DEBUG
  printf( "OPadd : " ) ; VARdebug( a1 ) ; VARdebug( a2 ) ;
#endif
  if( !TYPmatch( pPCIdef( a1 ), o, pPCIdef( a2 ), &sum ) )
  	rc = OPusr( e, a1, o, a2 ) ;
  else {
     if( sum.Dim /* ==> means : swap args */ ) {
  	a = a1 ; a1 = a2 ; a2 = a ; sum.Dim = 0 ; }
     if( rc = MADE( *e = mkREG( &sum ) ) ) {
  	if( sum.Ptr ) {
  		sum.Ptr-- ;
                rc = gen( o->instr, 4, *e, a1, a2, (short) TYPsizeof( &sum ) ) ;
        } else if( o->instr == PDELTA ) {
        	sum = PCIdef( a1 ) ; sum.Ptr-- ;
  		rc = gen( o->instr, 4, *e, a1, a2, (short) TYPsizeof( &sum ) ) ;
        } else 	rc = gen( o->instr, 3, *e, a1, a2 ) ;
     }
  }
  return rc ;

} /* OPadd */
/*----------------------------------------------------------------------------*/
int OPmul( e, a1, o, a2 )		BDEC( e, a1, o, a2 ) {

/* -- Generates a product ( o = '*', '/' or '%' ) instruction.
      Only (char/short/int/double) by (char/short/int/double) authorized.
   -- */
 
  int     rc		;
  PCItype t1, t2, prod	;

  t1 = PCIdef( a1 ) ;
  t2 = PCIdef( a2 ) ;
/* --   Find instruction to perform and type of result.
   -- */
  if( rc = TYPmatch( &t1, o, &t2, &prod ) ) {
        rc = MADE( *e = mkREG( &prod ) ) && gen( o->instr, 3, *e, a1, a2 ) ;
  } else rc = OPusr( e, a1, o, a2 ) ;

  return rc ;

} /* OPmul */
/*----------------------------------------------------------------------------*/
int OPmod( e, a1, o, a2 )		BDEC( e, a1, o, a2 ) {

/* -- Generates a modulus ( o = '%' ) instruction.
   -- */

					int rc ;

  if( AREINTS( a1, a2 ) ) {
      rc =    MADE( *e = mkREG( pTYPbasic( CI_INT ) ) )
           && gen( isint( a1 ) && isint( a2 ) ? o->instr : IMOD, 3, *e, a1, a2 ) ;
  } else rc = OPusr( e, a1, o, a2 ) ;

  return rc ;

} /* OPmod */
/*----------------------------------------------------------------------------*/
int OPrel( e, a1, o, a2 )		BDEC( e, a1, o, a2 ) {

/* -- Generates a comparison ( '<=', '<' , '>', '>=' , '!=', '==') instruction.
      Only '!=' and '==' allowed with object ids.
   -- */

			int rc ; PCItype t, *t1, *t2 ;
  
/* -- Handle the case "ptr <op rel> 0".
   -- */
  t1 = pPCIdef( a1 ) ;
  t2 = pPCIdef( a2 ) ;
       if( ispointer( a1 ) && isnull( a2 ) )	t2 = t1 ;
  else if( ispointer( a2 ) && isnull( a1 ) ) 	t1 = t2 ;
  if( rc = TYPmatch( t1, o, t2, &t ) ) {
     	if( isconst( a1 ) && isconst( a2 ) )
     		WNGsyn( "constant in conditional context", NULL ) ;
    		rc =    MADE( *e = mkREG( pTYPbasic( CI_INT ) ) )
          	     && gen( o->instr, 4, *e, a1, a2, TYPsizeof( t1 ) ) ;
  } else rc = OPusr( e, a1, o, a2 ) ;

  return rc ;

} /* OPrel */
/*----------------------------------------------------------------------------*/
int OPuminus( e, o, a )			UDEC( e, o, a ) {

/* -- Generates a unitary minus instruction.
      INPUT  : a, index of argument to operator.
               o, address of operator.
      OUTPUT : e, address of resulting variable.
      RETURNS: TRUE if OK else FALSE.
      NOTE   : if the argument is a constant, a constant of the opposite sign is
               build.
   -- */

	int rc ; PCIpointer P ; double D ; int I ; PCItype T ;

  if( isnumvalue( a ) ) {
     if( isconst( a ) ) {
     	T = PCIdef( a ) ;
  	switch( PCIdef( a ).Num ) {
  	   case CI_CHAR   : T.Num = CI_INT ;
  	   case CI_INT    : I = - PCIint( a ) ; P.Int = &I ; break ;
  	   case CI_DOUBLE : D = - PCIdbl( a ) ; P.Dbl = &D ; break ;
  	}
        rc = MADE( *e = mkCST( &T, P ) ) ;
     } else rc =    MADE( *e = mkREG( pPCIdef( a ) ) )
                 && gen( o->instr, 2, *e, a ) ;
  } else rc = OPusr( e, a, o, EMPTY ) ;

  return rc ;

} /* OPuminus */
/*----------------------------------------------------------------------------*/
int OPlogneg( e, o, a )			UDEC( e, o, a ) {

/* -- Generates a logical negation ( o = '!' ) instruction.
   -- */

				int rc ; PCItype T ;
 
  if( TYPmatch( pPCIdef( a ), o, pPCIdef( a ), &T ) ) {
     if( isconst( a ) ) WNGsyn( "constant in conditional context", NULL ) ;
     rc =    MADE( *e = mkREG( pTYPbasic( CI_INT ) ) )
          && gen( o->instr, 2, *e, a ) ;
  } else rc = OPusr( e, a, o, EMPTY ) ;

  return rc ;

} /* OPlogneg */
/*----------------------------------------------------------------------------*/
int OPbitneg( e, o, a )			UDEC( e, o, a ) {

/* -- Generates a  bitwise ( o = '~' ) negation  instruction. Allowed  on chars,
      shorts and ints only.
   -- */

					int rc ;
  
  if( isinteq( a ) )
     rc =    MADE( *e = mkREG( pTYPbasic( CI_INT ) ) )
          && gen( o->instr, 2, *e, a ) ;
  else rc = OPusr( e, a, o, EMPTY ) ;

  return rc ;

} /* OPbitneg */
/*----------------------------------------------------------------------------*/
int OPlog( e, a1, o, a2 )		BDEC( e, a1, o, a2 ) {

/* -- Generates a logical binary operation ( o = '&&' or '||' ) instruction.
   -- */

				int rc ; PCItype T ;
  
  if( TYPmatch( pPCIdef( a1 ), o, pPCIdef( a2 ), &T ) ) {
    if(    isconst( a1 )
        || isconst( a2 ) ) WNGsyn( "constant in conditional context", NULL ) ;
    rc =    MADE( *e = mkREG( pTYPbasic( CI_INT ) ) )
         && gen( o->instr, 3, *e, a1, a2 ) ;
  } else rc = OPusr( e, a1, o, a2 ) ;

  return rc ;

} /* OPlog */
/*----------------------------------------------------------------------------*/
int OPbit( e, a1, o, a2 )		BDEC( e, a1, o, a2 ) {

/* -- Generates a bitwise binary operation ( o = '&' or '|' ) instruction.
   -- */

				int rc ;
  
  if( AREINTS( a2, a1 ) )
      rc =    MADE( *e = mkREG( pTYPbasic( CI_INT ) ) )
           && gen( o->instr, 3, *e, a1, a2 ) ;
  else rc = OPusr( e, a1, o, a2 ) ;

  return rc ;

} /* OPbit */
/*----------------------------------------------------------------------------*/
int OPshf( e, a1, o, a2 )		BDEC( e, a1, o, a2 ) {

/* -- Generates a shift operation ( o = '<<' or '>>' ) instruction.
      Onlu numeric type allowed. If operands are not ints, their values are
      first assigned to integer `registers'.
   -- */

	int ireg1, ireg2, rc ;

  if( ARENUMS( a2, a1 ) ) {
	rc = TRUE ;
	if( !isint( a1 ) ) {
		rc =    MADE( ireg1 = mkREG( pTYPbasic( CI_INT ) ) )
		         && asg( NULL, ireg1, a1 );
	} else ireg1 = a1 ;
	if( !isint( a2 ) ) {
		rc = rc && MADE( ireg2 = mkREG( pTYPbasic( CI_INT ) ) )
		        && asg( NULL, ireg2, a2 ) ;
	} else ireg2 = a2 ;

	if( rc ) rc =      MADE( *e = mkREG( pTYPbasic( CI_INT ) ) )
			&& gen( o->instr, 3, *e, ireg1, ireg2 ) ;

 } else rc = OPusr( e, a1, o, a2 ) ;

 return rc ;

} /* OPshf */
/*----------------------------------------------------------------------------*/
int OPadr( e, o, a )			UDEC( e, o, a ) {

/* -- Generates an address operation ( o = '&' ) instruction. Handle the case
      when the address of a struct which itself is a struct field is wanted.
   -- */

		int rc = TRUE ; PCIident var ; PCIcontext C ;

#if DEBUG
  printf( "OPadr : " ) ; VARdebug( a ) ;
#endif
     CTXdefault( pPCIdef( a ), &C ) ;
     Dummy1.Any = PCIvar( a );
     Nul.Any = NULL;
     MKname( VAR | PTR, var, Dummy1, Nul, Nul ) ;

/* -- Takes the address of the addressee.
   -- */
     C.typ.Ptr++ ; C.typ.Dim = 0 ;
     rc = rc && MADE( *e = MKdcl( &C, var ) ) && gen( o->instr, 2, *e, a ) ;
 
#if DEBUG
  printf( "OPadr : EXIT( %d )\n", rc ) ;
#endif
  return rc ;

} /* OPadr */
/*----------------------------------------------------------------------------*/
int OPind( e, o, a )			UDEC( e, o, a ) {

/* -- Generates an indirection ( o = '*' ) operation instruction :
			e = *a 
   -- */

		int zero, rc ; PCIident var ; PCIcontext C ;

  if( isconst( a ) ) 
  	rc = ERRsyn( "cannot make an indirection with a constant", NULL ) ;
  else if( !isptreq( a ) )
  	if( isvar( a ) ) rc = OPusr( e, a, o, EMPTY ) ;
  	else             rc = ERRsyn( "illegal indirection", NULL ) ;
  else if( isfcnptr( a ) )
  	rc = ERRsyn( "cannot make an indirection with a function pointer", NULL ) ;
  else if( isvoidptr( a ) )
  	rc = ERRsyn( "cannot make an indirection with a pointer to void", NULL ) ;
  else {
  	if( rc = MADE( zero = mkCSTint( 0 ) ) ) {
/* -- 	  Construction of a variable of the same type as 'a',
   -- */
	  Dummy1.Any = PCIvar( a );
	  Nul.Any = NULL;
    	  MKname( VAR | IND, var, Dummy1, Nul, Nul ) ;
    	  CTXdefault( (PCItype *) NULL, &C )	;
    	  TYPind( pPCIdef( a ), &C.typ )	;

/* --     Generates an instruction that will put in the new variable
   --     the value of a pointer calculated with `a' and 'zero'.
   -- */
  	  rc =     MADE( *e = MKdcl( &C, var ) )
  	  	&& gen( o->instr, 4, *e, a, zero, (int) VARsizeof( *e ) ) ;
	}
  }

  return rc ;

} /* OPind */
/*----------------------------------------------------------------------------*/
int AOPbrk( E, A, o, I )		BDEC( E, A, o, I ) {

/* -- Generates an array element reference ( '['...']' ) instruction.
      INPUT  : A, index of array variable
               I, index of index variable
               o, address of bracket operator
      OUTPUT : E, pointer to index of array element variable 
   -- */

 PCIcontext ectx ; int rc ; PCIident var ; PCInode brk ;

#if DEBUG
	VARdebug( A ) ;
#endif
  brk.type			= BINARY	;
  brk.info.operator.symbol	= *o		;

   if( isptreq( A ) && !isfcnptr( A ) && !isvoidptr( A ) && isbsari( I ) ) {
  	  CTXdefault( (PCItype *) NULL, &ectx )	;
  	  TYPind( pPCIdef( A ), &ectx.typ )	;
/* --     Construction of a variable of the same type as 'array'.
   -- */
	  Dummy1.Any = PCIvar( A );
	  Dummy2.Any = PCIvar( I );
	  Nul.Any = NULL;
          MKname( VAR | ARR, var, Dummy1, Dummy2, Nul ) ;

/* --     Generates an instruction that will put in the new variable
   --     the value of a pointer calculated with 'array' and 'index'.
   -- */
   	  brk.info.operator.result	= ectx.typ	;
	  rc =    MADE( *E = MKdcl( &ectx, var ) )
	       && gen( o->instr, 4, *E, A, I, (int) VARsizeof( *E ) )
	       && mkNOD( &brk ) ;
  } else {
   	  brk.info.operator.result	= PCIdef( *E )	;
	  rc = OPusr( E, A, o, I ) && mkNOD( &brk )	;
  }
#if DEBUG
	VARdebug( *E ) ;
#endif
  return rc ;

} /* AOPbrk */
/*----------------------------------------------------------------------------*/
int OPasg( e, l, o, r )			BDEC( e, l, o, r ) {

/* -- Generates an assigment ( o = '=' ) instruction.
      NOTE: by default `o' contains an integer assignment instruction.
   -- */

			int rc, silent ; PCItype t, *right ;

#if DEBUG
  printf( "OPasg : " ) ; VARdebug( l ) ; VARdebug( r ) ;
#endif

/* -- Handle the case "<ptr> = 0".
   -- */
  right = ispointer( l ) && isnull( r ) ? pPCIdef( l ) : pPCIdef( r ) ;

  if( silent = o->code == -1 ) o->code = _ASSIGN ;

/* --	char, short, int, double = char, short, int, double. Choose instruction.
   -- */
/* --	GRobj = GRobj or <type *> = <type *>, <array of type>
   -- */
  if( TYPmatch( pPCIdef( l ), o, right, &t ) ) {
    if( rc = gen( o->instr, 3, l, r, (int) TYPsizeof( pPCIdef( l ) ) ) ) *e = l;
  } else {
  	if( silent )
/* --		Assignment done during message structure construction. Do not
   --           issue error message.
   -- */
        	rc = FALSE	;

/* --		User assignment.
   -- */
        else rc = OPusr( e, l, o, r ) ;
  }
  if( silent ) o->code = -1 ;

  return rc ;

} /* OPasg */
/*----------------------------------------------------------------------------*/
