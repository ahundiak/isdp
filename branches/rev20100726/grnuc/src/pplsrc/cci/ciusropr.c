/*-INCLUDES-------------------------------------------------------------------*/
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "cichardef.h"
#include "cidef.h"
#include "citypedef.h"
#include "ciy.h"
#include <malloc.h>
#include <string.h>
#include <ctype.h>
#define DEBUG 0
/*-TYPEDEFS-------------------------------------------------------------------*/
/* -- User operator definition
      - opr : operator code
      - val : index of "this" variable containing the result of the operation
      - oty : operand types
   -- */
typedef struct	{
			PCItype	oty[2]	;
			char	*nam	;
			Ushort	val 	;
			Uchar	opr	,
				ref[2]	;
} Odef ;
/*-STATIC GLOBALS-------------------------------------------------------------*/
/* -- Operator list and size of list.
   -- */

static Odef	**O__list	= NULL		;
static Ushort	O__size		= 0		;
/* -- Indices in the variable table of the operands ( 1 or 2 ) of the currently
      parsed operator. NOTE: if an operator is not being parsed O__oarg[0]
      is EMPTY.
   -- */
static int		O__oarg[2]	= { EMPTY, EMPTY }	;

/* -- Used to store the names of the user-named operators (those beginning with
      "@:", "@+" and "@*". Will always contain the name of the last encountered
      named operator.
   -- */
static PCIident		O__name				;
/*-EXTERNS--------------------------------------------------------------------*/
extern OPERATOR OPinfo[] 			;
extern char	*itoa()	 			;
extern unsigned VARsizeof(), TYPsizeof()	;
extern void	MKname(), CTXdefault(), TYPeq()	;
extern PCItype	pPCIbasic()			;

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

static Uchar UOPcheck_op __((int O, int ari));
/*
static void UOPjustify __((FILE *F, char *s1, char *s2, Uchar ref, int width));
*/
#if defined(__cplusplus)
}
#endif
#undef __



/*-MACROS---------------------------------------------------------------------*/
#define NO_OP	((Uchar) (-1))

/* -- Loop on operators from 0th to one before last.
   -- */
#define OPRbegin(o) { register Odef **__end = ( (o) = O__list ) + O__size ;\
		      while( (o) < __end ) {
#define OPRend(o)   (o)++ ; } }

/* -- User-named operator ?
   -- */
#define NAMED( op ) ( (op) == _MLTNAM || (op) == _PLSNAM || (op) == _UNRNAM )

static PCIpointer Dummy1, Dummy2, Dummy3;

/*----------------------------------------------------------------------------*/
void UOPsave( name ) char *name ; { strcpy( O__name, name ) ; }
/*----------------------------------------------------------------------------*/
int UOPfind( O, T1, T2 )	PCItype	*T1, *T2	;
				int	O		; {

		register Odef **o ; int O_index = EMPTY ; int rc ;
#if DEBUG
  printf( "UOPfind:\n" ) ; TYPdump( "T1 = ", T1 ) ; TYPdump( "T2 = ", T2 ) ; 
#endif
 OPRbegin( o )
 	if(    (*o)->opr == O
 	    && ( NAMED( O ) ? !strcmp( O__name, (*o)->nam ) : TRUE ) ) {
 		switch( OPinfo[O].arity ) {
 			case 2 : rc =       TYPareeq( T2, (*o)->oty + 1 ) ;
 			case 1 : rc = rc && TYPareeq( T1, (*o)->oty     ) ;
 		}
 		if( rc ) {
 			O_index = o - O__list ;
 			break ;
 		}
 	}
 OPRend( o )

#if DEBUG
  printf( "UOPfind : O_index %d\n", O_index ) ;
#endif
 return O_index ;

} /* UOPfind */
/*----------------------------------------------------------------------------*/
char *UOPid( opid ) PCIident opid ; {

	opid++ ; while( !isidchar( *opid ) ) opid++ ; return opid ;
}
/*----------------------------------------------------------------------------*/
static Uchar UOPcheck_op( O, ari )	int O, ari ; {
	int op = O ;
	if( ari == 1 ) 
		switch( O ) {
			case _MUL	: op = _IND	; break ;
			case _MINUS	: op = _OPP	; break ;
			case _AND	: op = NO_OP	; break ;
		}
	return op ;
}		
/*----------------------------------------------------------------------------*/
int mkUOP( T, O )	PCItype	*T	;
			int	O	; {

/* -- Construct a user-defined operator.
   -- */
  		int rc, This ; PCIident this ; PCIcontext C ; PCItype *eq ;
#if DEBUG
  printf( "mkUOP : enter <%s>, %d\n", OPinfo[O].name, O__size ) ;
#endif
  eq = T ;
  TYPeq( &eq, (PCItype **) NULL ) ;
  if( TYPvoid( eq ) ) {
  	rc = ERRsyn( "void operators not allowed", NULL ) ;
  } else if(     ALLOC( O__list        , O__size + 1, Odef * ) != NULL
              && MALLOC( O__list[O__size], 1         , Odef   ) != NULL ) {
      	CTXdefault( T, &C ) ;
      	if( NAMED( O ) ) {
		Dummy1.Val = O__size;
		Dummy2.Any = O__name;
		Dummy3.Any = "this";
		MKname( OPR, this, Dummy1, Dummy2, Dummy3 );
	} else {
		Dummy1.Val = O__size;
		Dummy2.Any = OPinfo[O].name;
		Dummy3.Any = "this";
		MKname( OPR, this, Dummy1, Dummy2, Dummy3 );
        }
	This = MKdcl( &C, this ) ;
	if( rc = This != EMPTY ) {
		if( NAMED( O ) ) {
		   if( MALLOC( O__list[O__size]->nam, 1 + strlen( O__name ), char ) ) {
			strcpy( O__list[O__size]->nam, O__name ) ;
		   } else rc = EMPTY ;
		} else O__list[O__size]->nam = OPinfo[O].name ;
		O__list[O__size]->opr	= O     	;
		O__list[O__size]->val	= This 		;
		PCIusd( This ).stat	= VAR_NOT_USED	;
		PCIfcn			= This		; /* MONDAY!!! */
	}
  } else rc = ERRmem( "user operator" ) ;
#if DEBUG
  printf( "mkUOP : EXIT(%d)\n", rc ) ;
#endif
  
  return rc ;
  
} /* mkUOP */
/*----------------------------------------------------------------------------*/
int UOPbegin()

/* -- Starts user operator definition: checks that the return type is legal and
      that this operator  does not already exist, then reads operands  from the
      stack.
   -- */

{ register Odef *o = O__list[O__size] ;
  PCIident	fcn			;
  int		rc	, u	, s, ari;
  PCIop		op			;
  PCItype	junk	, *ot1	, *ot2	;

#if DEBUG
  printf( "UOPbegin : enter %d <%s> %d\n", O__oarg[0], OPinfo[o->opr].name, O__oarg[1] ) ;
#endif
  
/* -- Compute arity.
   -- */
  ari = 1 ; ot1 = pPCIdef( O__oarg[0] ) ;
  if( O__oarg[1] != EMPTY ) {
  	ari++ ; ot2 = pPCIdef( O__oarg[1] ) ;
  } else ot2 = ot1 ;

/* -- Get right operator ( e.g. "*" is either multiplication or indirection ).
   -- */
  if( ( o->opr = op.code = UOPcheck_op( (int) o->opr, ari ) ) == NO_OP )
  	rc = ERRsyn( "this operator cannot be overloaded", o->nam ) ;
  else if( TYPmatch( ot1, &op, ot2, &junk ) )
  	rc = ERRsyn( "operator predefined for those types", o->nam ) ;
  else if( UOPfind( (int) op.code, ot1, ot2 ) == EMPTY ) {
/* --	Create label name ":-<number><operator>", e.g. ":-12&&".
   -- */
	Dummy1.Val = O__size;
	Dummy2.Any = o->nam;
	Dummy3.Any = "";
 	MKname( OPR, fcn, Dummy1, Dummy2, Dummy3 );
 	rc = mkLAB( fcn, FN_LAB, PCInins ) != EMPTY ;
   	if( rc ) {
/* -- 		Pull from stack in increasing order.
   -- */
 	   for( u = 0 ; u < OPinfo[op.code].arity ; u++ ) {
 	   	o->oty[u] = PCIdef( O__oarg[u] ) ;
 	   	if( o->ref[u] ) {
 	   		if( !( rc = gen( PULLADR, 1, O__oarg[u] ) ) ) break ;
		} else {
  			s = isarray( O__oarg[u] ) ? sizeof( void * )
  					 	 : VARsizeof( O__oarg[u] ) ;
 			if( !( rc = gen( PULLVAL, 3, O__oarg[u],
 		                 	 s      , GAP( s ) ) ) ) break ;
 		}
 	   }
 		O__size++ ;
 	}
  } else rc = ERRsyn( "operator already declared", o->nam ) ;
#if DEBUG
  printf( "UOPbegin : EXIT(%d)\n", rc ) ;
#endif
  return rc ;

} /* UOPbegin */
/*----------------------------------------------------------------------------*/
int UOPend()	{
/* -- End of operator definition:
	- generate `return' instruction
	- warn about unused operands or "this" variable.
	- resets array of operand indices.
        RETURNS: TRUE if OK and FALSE if troubles with instruction generation.
    -- */
  int u, rc = TRUE ; emsg e ; register Odef *o ; void VARforget() ;
  
  o = O__list[O__size - 1] ;
#if DEBUG
  printf( "UOPend : enter <%s>code %d<%s>\n", o->nam, o->opr, PCIvar( o->val ) ) ;
#endif

  if( ( O__oarg[0] != EMPTY ) + ( O__oarg[1] != EMPTY ) < OPinfo[o->opr].arity )
  	rc = ERRsyn( "not enough operands for", o->nam )  ;
  else {
  	if( PCIusd( o->val ).stat == VAR_NOT_USED ) {
		WNGsyn( "`this' unused in operator", o->nam ) ;
		PCIusd( o->val ).stat = VAR_USED ;
 	}
  	for( u = OPinfo[o->opr].arity - 1 ; u >= 0 ; u-- ) {
    		if( PCIusd( O__oarg[u] ).stat == VAR_NOT_USED ) {
  			sprintf( e, "%.*s in %.*s",
  	            		MAXEMSG / 2 - 3, UOPid( PCIvar( O__oarg[u] ) ),
 		    		MAXEMSG / 2 - 3, o->nam		         ) ;
   			WNGsyn( "operand unused in operator", e ) ;
   			PCIusd( O__oarg[u] ).stat = VAR_USED ;
   		}
 	}
  }

  O__oarg[0] = O__oarg[1] = EMPTY ; VARforget( o->nam ) ;
#if DEBUG
  printf( "UOPend : EXIT\n" ) ;
#endif
  return rc && gen( RETURN, 0 ) ;

} /* UOPend */
/*----------------------------------------------------------------------------*/
int mkUOParg( C, A )	PCIcontext *C ; PCIident A ; {

/* -- Creates a user-operator operand : checks arity and that operand has not
      already been declared.
      RETURNS: operand's index as a variable if OK else EMPTY.
   -- */

  int		rc = TRUE, u = 0 ;
  PCIident	I		;
  register Odef *o		;
  PCItype	*eq		;
  PCIcontext	CC		;
 
  o = O__list[O__size] ;
#if DEBUG
  printf( "mkUOParg : enter <%s>\n", o->nam ) ;
#endif
  Dummy1.Val = O__size;
  Dummy2.Any = o->nam /* RM OPinfo[o->opr].name */;
  Dummy3.Any = A;
  MKname( OPR, I, Dummy1, Dummy2, Dummy3 );

  if( O__oarg[u] != EMPTY ) {
	switch( OPinfo[o->opr].arity ) {
		case 2 : if( O__oarg[u+1] != EMPTY ) {
     		case 1 : 	rc = ERRsyn( "too many operands for operator",
  				      	      o->nam		             );
				break ;
	      		 } else if( !strcmp( PCIvar( O__oarg[u] ), I ) ) 
	      		 	rc = ERRsyn( "operand already declared", A ) ;
	        	 else u++ ;
	        	 break ;
	        default: rc = cibugchk( "mkUOParg", "unknown arity" ) ;
	}
  }
  o->ref[u] = C->ref ;
/* RM if OK ...
  CC = *C ; CC.typ = *UFNtypeq( &C->typ ) ;

  return rc ? O__oarg[u] = MKvar( &CC, I ) : EMPTY ;
  ... end RM if OK */
/*
  CC = *C ; CC.typ = *eq  ;*/
  eq = &C->typ ;
  TYPeq( &eq, (PCItype **) NULL ) ;
  if( TYPvoid( eq ) ) {
  	rc = ERRsyn( "void type for operand", A ) ;
  } else {
	CC = *C ;
	if( eq->Dim ) CC.ref = o->ref[u] = eq->Dim != 0 ;
  }

#if DEBUG
  printf( "mkUOParg : EXIT op #%d, ref ? %d\n", u, o->ref[u] ) ;
#endif
  return rc ? O__oarg[u] = MKvar( &CC, I ) : EMPTY ;

} /* mkUOParg */
/*----------------------------------------------------------------------------*/
int UOPcmp( opid, code, opnam ) PCIident opid, code ; char *opnam ; {

/* -- `opid' is either an operand or "this", `code' is the actual internal
      name corresponding to this latter:
      		<code> = ">"<number><operator><opid>
      This function extracts the name part of `code' and compares it to `opid'.
   -- */
				PCIident tmp ;
	code++ ;

	while( isdigit( *code ) ) code++ ;

	return !strcmp( code, strcat( strcpy( tmp, opnam ), opid ) ) ;
}
/*----------------------------------------------------------------------------*/
int UOPisarg( A ) PCIident A ; {

/* -- Sees if `A' is an argument of the currently parsed user-operator or if it
      is the special variable "this".
      RETURNS: arg/"this" index if found else EMPTY.
   -- */

  int ia ; register Odef *o ;

  if( O__oarg[0] != EMPTY ) {
/* -- An operator is being parsed.
   -- */
	o = O__list[O__size - 1] ;

  	switch( OPinfo[o->opr].arity ) {
  		case 2 : if( UOPcmp( A, PCIvar( ia = O__oarg[1] ), o->nam ) ) break ;
  		case 1 : if( UOPcmp( A, PCIvar( ia = O__oarg[0] ), o->nam ) ) break ;
  		 	 if( UOPcmp( A, PCIvar( ia = o->val    ), o->nam ) ) break ;
  		 	 else ia = EMPTY ;
  		 	 break ;
  		default: cibugchk( "UOPisarg", "unknown arity" ) ;
  		         ia = EMPTY ;
  	}
  } else ia = EMPTY ;
  	
  return ia ;

} /* UOPisarg */
/*----------------------------------------------------------------------------*/
int UOPcall( res, o1, op, o2 ) 	int *res, o1, op, o2 ; {

/* -- Generates call to user-defined operator if this operator exists.
      INPUT  : op, operator code.
             : o1, o2, indices of operands in variable table.
      OUTPUT : res, index of variable bearing result of operation.
      RETURNS: FALSE : operator does not exist
               TRUE  : operator exists, *res != EMPTY : OK,
                       *res == EMPTY : troubles in instruction generation.
   -- */
  int rc, arg[2], sz, O_index, u ; PCIident fcn ; PCIop Asg ; Odef *o ;

#if DEBUG
  printf( "UOPcall : enter <%s>\n", OPinfo[op].name ) ;
#endif
  *res = EMPTY ;
  if( rc = ( O_index = UOPfind( op, pPCIdef( o1 ), pPCIdef( o2 ) ) ) != EMPTY ){
/* --	Push onto stack in decreasing order.
   --   */
   arg[0] = o1 ; arg[1] = o2 ; o = O__list[O_index] ;
   for( u = OPinfo[op].arity - 1 ; u >= 0 ; u-- ) {
   	if( isarray( arg[u] ) || o->ref[u] ) {
   		if( !gen( PUSHADR, 1, arg[u] ) ) break ;

	} else	{
	   sz = VARsizeof( arg[u] ) ;
/* --	   Carefull of char/short/int passed as args of type "numeric" !
	   Get a `register' and assign value to it.
   -- */

	   if(    TYPsizeof( &o->oty[u] ) == sizeof( double )
	       && sz < sizeof( double ) ) {
	    	int reg ;
	    	reg = mkREG( pTYPbasic( CI_DOUBLE ) ) ;
	    	if( reg != EMPTY ) {
	    		if(    !asg( NULL, reg, arg[u] )
	    		    || !gen( PUSHVAL, 3, reg,
	    		             sizeof( double ),
	    		             sizeof( double ) ) ) break ;
  		} else break ;
  	   } else {
 		if( !gen( PUSHVAL, 3, arg[u], sz, GAP( sz ) ) ) break ;
	   }
	}
    }

    Dummy1.Val = O_index;
    Dummy2.Any = o->nam;
    Dummy3.Any = "";
    MKname( OPR, fcn, Dummy1, Dummy2, Dummy3 );
    if( ( *res = mkREG( pPCIdef( o->val ) ) ) != EMPTY ) {
   	    Asg.instr = OPinfo[Asg.code = _ASSIGN].icode ;
   	    if( !(    INSjmp( fcn, FN_LAB, jmpFUNC )
   	           && ( isarray( o->val ) ? ARRcpy( *res, (int) o->val )
   	              			  : OPasg( &u, *res, &Asg, (int) o->val ) )
                 ) 
              ) *res = EMPTY ;
    }
  }
#if DEBUG
  printf( "UOPcall : *res = %d EXIT(%d)\n", *res, rc ) ;
#endif

  return rc ;

} /* UOPcall */
/*----------------------------------------------------------------------------*/
void UOPfree() {

/* -- Frees operator list. Resets global variables.
   -- */
	register Odef **O ;

	if( O__list ) {
		OPRbegin( O )
			if( NAMED( (*O)->opr ) ) free( (*O)->nam ) ;
			free( (char *) *O ) ;
		OPRend( O )
		free( (char *) O__list ) ;
		O__list = NULL	;
		O__size = 0	;
	}

} /* UOPfree */
/*----------------------------------------------------------------------------*/
static void UOPjustify( F, s1, s2, ref, width )	FILE 	*F	;
						char 	*s1, *s2;
						Uchar	ref 	;
						int	width	; {

	int rest ;

 rest = width - ( strlen( s1 ) + 1 ) - ( ref ? 3 : 0 ) ;
 if( rest > strlen( s2 ) )
 	fprintf( F, "%s %-*s%s"   , s1, rest, s2, ref ? "(&)" : "" ) ;
 else	fprintf( F, "%s %.*s...%s", s1, rest, s2, ref ? "(&)" : "" ) ;
}
/*----------------------------------------------------------------------------*/
void UOPdump( F )	FILE *F ; {

/* -- Dumps overloaded opertors. Must be called before `UOPfree' !
   -- */
  register Odef	**o 				;
  char		*s1, *s2, *s3, *s4, *s5, *s6	;
  void		TYPname()			;

#define UorS( p ) ( *(p) == 's' || *(p) == 'u' ? (p) : "" )
  if( O__size ) {
  fprintf( F, "\n\t\t\t\tOVERLOADED OPERATORS\n\t\t\t\t--------------------\n\n" ) ;
  OPRbegin(o)
  	fprintf( F, "%-3d", o - O__list ) ;
  	TYPname( pPCIdef( (*o)->val )	, &s1, &s2 ) ;
  	TYPname( (*o)->oty		, &s3, &s4 ) ;
  	UOPjustify( F, UorS( s1 ), s2, 0, 21 ) ; fprintf( F, " = " ) ;
  	switch( OPinfo[(*o)->opr].arity ) {
  		case 2 : TYPname( (*o)->oty + 1		, &s5, &s6 ) ;
  			 UOPjustify( F, UorS( s3 ), s4, (*o)->ref[0], 21 ) ;
  			 fprintf( F, " %-*s ", 11, (*o)->nam ) ;
  			 UOPjustify( F, UorS( s5 ), s6, (*o)->ref[1], 21 ) ;
  			 break ;
  		case 1 : fprintf( F, "%-*s ", 11, (*o)->nam ) ;
  			 UOPjustify( F, UorS( s3 ), s4, (*o)->ref[0], 21 ) ;
  			 break ;
  	} fprintf( F, "\n" ) ;
  OPRend(o)
  }

} /* UOPdump */
/*----------------------------------------------------------------------------*/
