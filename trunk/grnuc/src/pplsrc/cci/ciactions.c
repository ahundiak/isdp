#include "pcidef.h"
#include "pci.h"
#include "pcimacros.h"
#include "cichardef.h"
#include "cidef.h"
#include "citypedef.h"
#include "ciy.h"
#include <string.h>
#include <malloc.h>
#define DEBUG 0
/*----------------------------------------------------------------------------*/
extern PCItype	TYPbasic(), *pTYPbasic()	;
extern OPERATOR OPinfo[]			;
extern unsigned VARsizeof(), TYPsizeof()	;
extern void	CTXdefault()			;
/*-MACROS---------------------------------------------------------------------*/
#define MADE( var )	( (var) != EMPTY )
/*----------------------------------------------------------------------------*/
int asg( rc, left, right ) int *rc, left, right ; {

	PCIop assign ; int RC ;

	if( rc == NULL ) rc = &RC ;
       	assign.instr = OPinfo[ assign.code = _ASSIGN].icode ;
       	assign.code = -1 ;
       	return OPasg( rc, left, &assign, right )	    ;
}
/*----------------------------------------------------------------------------*/
int PPLident( ctx, var, ident, action )	PCIcontext	*ctx		;
					int		*var, action	;
					PCIident	ident		; {

/* -- Checks if an encountered identifier exists.
      Variable in "send ... to <ident>" are declared as "GRobj" if they have not
      been, functions  encountered for  the first time  are declared as "int" if
      they do not belong to  the compiler's library. All other cases triggers an
      error message.
      RETURNS: the variable index in case of a variable/function.
   -- */

		int rc, value ; PCIcontext C ; PCInode N ; PCItype T ;

/* -- See if identifier is a user function arg, a user operator operand, an init
      function arg , a local variable, a global variable or an operand.
   -- */
  if( rc =    MADE( *var = UFNisarg( ident ) )
  	   || MADE( *var = TYIisarg( ident ) )
           || MADE( *var = STBfind ( ident, SYM_LVAR_NAM ) )
           || MADE( *var = STBfind ( ident, SYM_GVAR_NAM ) )
  	   || MADE( *var = UOPisarg( ident ) ) ) {
  	PCIusd( *var ).stat = VAR_USED ;

/* -- Enum element identifier : replace it by an integer constant.
   -- */
  } else if( rc = MADE( ENMfindV( ident, &value ) ) ) {
  	*var = mkCSTint( value ) ;
  } else switch( action ) {
  	case	iNORMAL : 
  			  if( IMPfind( ident, &T ) ) {
  			  	C	= *ctx	;
  			  	C.typ	= T	;
  			  	rc = MADE( *var = MKdcl( &C, ident ) ) ;
  			  } else {
			  ERRsyn( "variable not declared", ident ) ;
/* --			  Make it a variable of type `int' to continue parsing.
   -- */
			  T = TYPbasic( CI_INT ) ;
			  CTXdefault( &T, &C ) ;
			  rc = ( *var = MKvar( &C, ident ) ) != EMPTY ;
			  }
  			  break ;
  	case	iFUNCTN : if( rc = MADE( *var = mkSYS( ident ) ) ) {
/* --				Compiler's lib function.
   -- */
  				PCIusd( *var ).stat = TRUE ;
  			  } else {
/* --				Not-yet-declared function.
   -- */
     				C.typ = TYPbasic( CI_INT )	;
     				C.use = cxFUNCT			;
    	 		  	C.sto = PCIopt.externfn ? cxEXTRN : cxSTATC ;
     				goto Dcl ;
     			  }
     			  break ;

/* -- "send ... to <target>" : declare <target> if need be.
   -- */
     	case	iTARGET : C.typ = TYPbasic( CI_GROBJ )	;
	 		  C.use = cxNORML		;
			  C.sto = cxSTATC		;  /* GLC 3/13/92 */
	 		  Dcl : 
    	 		  	C.loc = cxGLOBL ; C.ref = FALSE ;
    	 		  	if( rc = MADE( *var = MKdcl( &C, ident ) ) ) {
  					PCIusd( *var ).stat = VAR_USED ;
  					if( action == iFUNCTN )
  					  if( PCIopt.externfn )
  						PCIsts( *var ) |= CI_XTRN ;
  					  else
  						PCIsts( *var ) |= CI_USER ;
  				}
    	 		  break ;
	default		: 
			  printf( "action %d ident = <%s>\n", action, ident ) ;
			  cibugchk( "PPLident", "unknown identifier type" ) ;

  }

  N.type = OPERAND ; N.info.operand = *var ;
  	
  return rc && mkNOD( &N ) ;

} /* PPLident */
/*----------------------------------------------------------------------------*/
int AOPfun( ret, F, args )	int		*ret	;
				int		F	;
				PCIlist		*args	; {

/* -- Generates a function call ( '...(...)' ) instruction.
      Library functions are overriden by extern or user-defined functions.
      As regards  "mkNOD", a function  without  arguments  is considered  as an
      OPERAND otherwise as a BINARY operator.
      NOTE : `args' is freed in this function.
   -- */

	int rc = FALSE, this = EMPTY ; PCItype RC ; PCInode N ;
#if DEBUG
printf( "AOPfun : ENTER( %s ) extern %d\n",  PCIvar( F ) , isextern(F) ) ;
TYPdump( "-", pPCIdef( F ) ) ;
#endif
 
    RC			= PCIdef( F )	;
    RC.Fpt		= FALSE 	;
    args->elt.Auto[0]	= F		;

    if( *PCIvar( F ) == INIVAR && MADE( rc = TYIfind( &RC ) ) ) {
/* --		`typeinit' function.
   -- */
    		if( rc = MADE( this = TYIcall( rc, args ) ) ) {
     			F = args->elt.Auto[0] ;
     			goto Usr ;
     		}
    } else if( isfcnptr( F ) ) {
/* --	Pointer to function. The order of indirection of the returned value is
	contained in Rpt.
   -- */ 
    	RC.Ptr	= RC.Rpt	;
    	RC.Rpt	= 0		;
    	goto Extern		;
    } else if( !isfunction( F ) ) ERRsyn( "not a function", PCIvar( F ) ) ;
    else if( isextern( F ) ) {
/* -- The final register belongs to the arg list : one assignment saved.
   -- */
      Extern :
      		XFNcall( args ) ;
#if DEBUG
printf( "AOPfun : isvoidfcn(%s) %d\n", PCIvar(F), isvoidfcn(F));
#endif
      		if( !isvoidfcn( F ) && MADE( *ret = mkREG( &RC ) ) ) {
			args->elt.Auto[args->num++] = *ret	;
      		} else {
      			args->elt.Auto[args->num++] = PCIvoid	;
      		}
		rc = genins( BRANCHXTRN, args )	;
    } else if( isuser( F ) ) {
     		Usr :
       		PCIsts( F ) |= CI_USER	;
       		rc = UFNcall( args ) && INSjmp( PCIvar( F ), FN_LAB, jmpFUNC ) ;
    } else if( MADE( F = mkSYS( PCIvar( F ) ) ) ) {
	  		SYScall( args )		;
	 		rc = genins( FCALL, args )	;
    } else rc = cibugchk( "AOPfun", PCIvar( F ) ) ;


#if DEBUG
	printf( "AOPfun : args->num %d\n", args->num ) ;
#endif
  PCIusd( F ).stat = VAR_USED ;
  if( rc ) {
/* -- Assigment of the value returned by the function to a register.
   -- */
     if( PCIcode[PCInins-1].type != BRANCHXTRN ) {
       if( MADE( this ) ) {
       		rc =    MADE( *ret = mkREG( &RC ) )
       	    	     && ( isarray( this ) ? ARRcpy( *ret, this ) 
       	    	                          : asg( (int *)NULL, *ret, this ) ) ;
    		N.info.operator.result      = PCIdef( this )	;
       } else {
#if DEBUG
printf( "AOPfun :isvoid(%s) %d\n", PCIvar(F), isvoid(F));
#endif
       		if( !isvoid( F ) ) {
       		  rc = MADE( *ret = mkREG( &RC ) ) && asg( (int *)NULL, *ret, F ) ;
    		  N.info.operator.result      = PCIdef( F )	;
    		} else *ret = PCIvoid ;
       }
     }
     if( isextern( F ) ) args->num-- ;
     N.type = BINARY ; N.info.operator.symbol.code = '@' ;
     		
     rc = rc && ( args->num > 1 ? mkNOD( &N ) : TRUE ) ;

     if( args != NULL ) {
     	free( (char *) args->elt.Auto ) ;
     	free( (char *) args ) ;
     }
  }

#if DEBUG
	printf( "AOPfun : EXIT( %d )\n", rc ) ;
#endif

  return rc ;

} /* AOPfun */
/*----------------------------------------------------------------------------*/
int cireturn( fun, o, ret )	int	fun, ret	;
				PCIop	*o		; {

/* -- Generates a `return' instruction.
      INPUT  : fun, function "return" lies in.
               o  , pointer to "return" operator.
               ret, value returned by function.
   -- */
   
				int rc = TRUE, external ;

#if DEBUG
  printf( "cireturn : enter fun = %d\n", fun ) ;
#endif
  if( fun == EMPTY ) rc = ERRsyn( "illegal return statement", NULL ) ;
  else {
/* --	There is a value to return.
   -- */
	if( ret != EMPTY ) {
/*  -- 		The purpose of settint .Fpt at 0 is  to prevent  an erroneous
		error message to be output when a "return" instruction occurs
		in a user function  overriden by an extern declaration.
		Since `fun' will be the index of the external function it will
		have its .Fpt  field  set  whereas `ret' will  not, causing an
		error message to be  output by the  assigment routine that the
		type of the function does not match  that of the return value.
    -- */
		if( external = isextern( fun ) ) PCIdef( fun ).Fpt = 0 ;
		if( !asg( (int *)NULL, fun, ret ) )
      		   rc = ERRsyn( "illegal type for returned expression", NULL ) ;
		if( external ) PCIdef( fun ).Fpt = FCNDCL ;
  	}
	rc = rc && gen( o->instr, 0 ) ;
  }
#if DEBUG
  printf( "cireturn : EXIT( %d )\n", rc ) ;
#endif
  return rc ;

} /* cireturn */
/*----------------------------------------------------------------------------*/
int PPLsizeofV( exp, var )	int *exp, var ; {

/* -- Handles `sizeof' operator for variables.
      INPUT  : var, index of variable.
      OUTPUT : exp, index of result.
      RETURNS: TRUE if OK, FALSE if `MK...' failed.
      NOTE   : as regards `mkNOD', "sizeof" is a function with `var' as arg if
               `var' is a variable.
   -- */

		unsigned size, TDFsizeof() ; PCInode N ;

#if DEBUG
  printf( "PPLsizeofV : <%s>\n", PCIvar( var ) ) ;
#endif
  size = PCIdef( var ).Dim	;
  if( size == 0 ) size = 1	;
  size *= VARsizeof( var )	;

/* var est deja dans l'arbre ... --> l'enlever ou le remplacer par cette const? */
  N.type = UNARY ;
  N.info.operator.symbol.code = _MINUS ;
/*  N.info.operator.result      = _MINUS ; */
  return MADE( *exp = mkCSTint( (int) size ) ) && mkNOD( &N ) ;
  
} /* PPLsizeofV */
/*----------------------------------------------------------------------------*/
int PPLsizeofT( exp, typ )	int     *exp ;
			PCItype *typ ; {

/* -- Handles `sizeof' operator for types.
      INPUT  : typ, type descriptor.
      OUTPUT : exp, index of result.
      RETURNS: TRUE if OK, FALSE if `MK...' failed.
      NOTE   : as regards `mkNOD', "sizeof( <type> )" is an operand.
   -- */

			unsigned TYPsizeof() ; PCInode N ;

  N.type = OPERAND ; N.info.operand = *exp ;

  return MADE( *exp = mkCSTint( (int) TYPsizeof( typ ) ) ) && mkNOD( &N ) ;

} /* PPLsizeofT */
/*----------------------------------------------------------------------------*/
int cimessage( p_msg, class, mess, args )

PCIlist		**p_msg	, *args	;
PCIident	class	, mess	;

/* -- Generates arg struct and generates fields filling instructions.
      For a message as <class>.<mess>( <arg1>, <arg2>, ..., <argn> ), builds a
      structure named
      		       <class>.<mess> { <type1> arg1 ;
                                        <type2> arg2 ;
                                        ...
                                        <typen> argn ;
                       }
      then performs the assignments 
      		<class>.<mess>.arg1 = <arg1> ;
      		<class>.<mess>.arg2 = <arg2> ;
      		...
      		<class>.<mess>.argn = <argn> ;
      NOTE : if a message is used several times in the source file,the arguments
             must have the same types at each  invocation, since their types are
             guessed when the message is encountered for the first time.
             The key to variable names is:
             ARGsn : name of struct ( "<class>.<mess>" )
             ARGst : index in struct table of struct build to contain arguments
	     ARGsv : index of struct variable build to contain arguments
	     ARGsz : index of integer constant containing struct size
	     ARGcx : context variable used for struct declaration.
	     ARGfn : name of field corresponding to an arg ( "<class>.<mess>.arg<n> )
	     ARGfv : index of aux var created to access field to assign it mess arg.
	     ARGty : type of field corresponding to an arg
   -- */

{  int		ARGst	, ARGsv	, ARGfv		, ARGsz		, icl,
		ims	,   rc	, u		, w		 ;
   PCIident	ARGsn	, ARGfn	;
   PCItype	t	, ARGty	, STRend()	, TYPbasic()	, *T ;
   PCIstring	string	;
   PCIpointer   ptr	;
   PCIcontext	ARGcx	;
   PCInode	N	;
   PCIop	dot	, Asg 	;
   char		*itoa()	;
   emsg		tmp	;
   unsigned	STRsizeof()  	;
   void		TYPeq()		;

#if DEBUG
  printf( "cimessage : <%s>.<%s> nb args = %d\n", class, mess, args->num - 1 ) ;
  for( u = 1 ; u < args->num ; u++ )
  printf( "\t%d : <%s>\n", args->elt.Auto[u], PCIvar( args->elt.Auto[u] ) ) ;
#endif

  t = TYPbasic( CI_STRING )			;
  CTXdefault( (PCItype *) NULL, &ARGcx )	;

/* -- The 1st ident is the class name.
   -- */
  ptr.Str = &string ;
  string.length = - ( u = strlen( string.text = class ) ) ;
  if( rc = MADE( icl = mkCST( &t, ptr ) ) ) {
/* --	The 2d ident is the message name.
   -- */
      string.length = - strlen( string.text = mess ) ;
      if( rc = MADE( ims = mkCST( &t, ptr ) ) ) {

	if( args->num > 1 ) {
/* --	  Find or build structure for this message.
   -- */
   	  ARGsn[0] = DOT ;
	  *( strcpy( strcpy( ARGsn + 1, class ) + u + 1, mess ) - 1 ) = DOT ;
	  strcpy( ARGfn, "arg" ) ;
	  if( !STRfind( ARGsn, &ARGcx.typ ) ) {
	     if( rc = MADE( ARGst = mkSTR( ARGsn, STRUC ) ) ) {
		for( u = 1 ; u < args->num && rc ; u++ ) {
		   w = args->elt.Auto[u] ;
		   T = pPCIdef( w ) ;
		   TYPeq( &T, (PCItype **) NULL ) ;
		   ARGty = *T ;
		   if( isarray( w ) ) {
				ARGty.Dim = 0   ;
				ARGty.Ptr++	;
		   }
#if DEBUG
  printf( "cimessage : arg %d is\n", u ) ; VARdebug( w ) ;
  printf( "cimessage : field <%s> has type\n", itoa( ARGfn + 3, u ) - 3 ) ;
  TYPdump( "--> ", &ARGty ) ;
          fflush( stdout ) ;
#endif
		   rc = rc && MADE( mkSTRfield( &ARGty, itoa( ARGfn + 3, u ) - 3 ) ) ;
		} /* for */
		ARGcx.typ = STRend( ARGst ) ;
	     } /* if ARGst */
	  } /* if !STRfind */
/* --	  Find or build variable with structure type.
   -- */
          if( rc =     rc
                   && (    MADE( ARGsv = STBfind( ARGsn, SYM_GVAR_NAM ) )
                        || MADE( ARGsv = MKdcl( &ARGcx, ARGsn ) ) ) ) {
	    dot.instr = OPinfo[dot.code = _DOT].icode ;
	    Asg.instr = OPinfo[_ASSIGN        ].icode ; Asg.code = -1 ;

/* --       Assign each message argument to corresponding structure field.
   -- */

	    if( args->num - 1 != STRfield_count( PCIdef( ARGsv ).Num ) ) {
	    	sprintf( tmp, "wrong argument count for message %s.%s",
	    		 class, mess ) ;
	    	rc = ERRsyn( tmp ) ;
	    } else
	    for( u = 1 ; u < args->num && rc ; u++ ) {
	    	N.type		= OPERAND	;
	    	N.info.operand	= ARGsv		;
		if( rc =    mkNOD( &N )
		         && FAOdot( &ARGfv, ARGsv, &dot, itoa( ARGfn + 3, u ) - 3 )
		         && FAOflush( &ARGfv ) ) {
		  if( !OPasg( &w, ARGfv, &Asg, args->elt.Auto[u] ) ) {
		    w = ( MAXEMSG - 8 ) / 2 ;
		    sprintf( tmp, "%.*s.%.*s(%d)", w, class, w, mess, u ) ;
		    ERRsyn( "message arg (type) used inconsistently", tmp ) ;
		  }
		  N.type			= BINARY ;
		  N.info.operator.symbol.code	= _COMMA ;
		  rc = mkNOD( &N ) ;
		}
	    }
	    rc = rc && MADE( ARGsz = mkCSTint( (int) STRsizeof( (int) ARGcx.typ.Num ) ) ) ;
	  } /* if rc */
	} else {
/* --		Create dummy structure variable to please `CIsend' at arg check
   --		time: it will have a NULL address. 
   -- */
		*( strcpy( ARGfn + 1, "{dummy" ) - 1 ) = AUXVAR ;
		ARGcx.typ = TYPbasic( CI_CHAR )			;
	    	N.type		= OPERAND	;
		if( rc =    MADE( ARGsv = MKdcl( &ARGcx, ARGfn ) )
		         && MADE( N.info.operand = ARGsz = mkCSTint( 0 ) )
		         && mkNOD( &N ) ) {
		     		PCIdef( ARGsv ).Def 		= STRUC  ;
		 }
	}
/* --   Refill argument list with :
   --	     	1 : index of class name
   --	     	2 : index of message name
   --	     	3 : index of argument structure
   --	     	4 : index of size of argument structure
   -- */    
	args->elt.Auto[1]	= icl	; args->elt.Auto[2] = ims	;
	args->elt.Auto[3]	= ARGsv	; args->elt.Auto[4] = ARGsz	;
	args->num		= 5	; *p_msg = args			;
      } /* if ims */
   } /* if icl */

#if DEBUG
  printf( "cimessage : EXIT( %d )\n", rc ) ;
#endif  
  return rc ;

} /* cimessage */
/*----------------------------------------------------------------------------*/
int cisend( send, msg, target )	int	*send, target	;
				PCIlist	*msg		; {

/* -- Generates a message send instruction corresponding to:
		send <message> to <target>
      NOTE : should CIsend have more than 9 args, msg->elt should be real-
             located for more space.
   -- */

	int zero, _one, null, rc = FALSE ; PCIcontext info ; PCInode N ;
  
  if( ( null = STBfind( "~null", SYM_GVAR_NAM ) ) == EMPTY ) {
  	CTXdefault( pTYPbasic( CI_CHAR ), &info ) ;
  	info.typ.Ptr++		 	;
  	null = MKdcl( &info, "~null" )  ;
  }
  if( rc = MADE( null ) ) {
    PCIptr( null ) = NULL ;
    if( rc = MADE( zero = mkCSTint( 0 ) ) && MADE( _one = mkCSTint( -1 ) ) ) {
	if (msg->num > 3)
	  msg->elt.Auto = (short *)realloc (msg->elt.Auto,
					      (msg->num + 7) * sizeof (short));
	msg->elt.Auto[msg->num++] = target ;
	msg->elt.Auto[msg->num++] = _one   ; /* osnum	  	*/
	msg->elt.Auto[msg->num++] = zero   ; /* construct 	*/
	msg->elt.Auto[msg->num++] = zero   ; /* mode	  	*/
	msg->elt.Auto[msg->num++] = null   ; /* channame  	*/
	msg->elt.Auto[msg->num++] = zero   ; /* verbose	  	*/
	msg->elt.Auto[msg->num++] = zero   ; /* p_chanselect	*/

	N.type				= BINARY ;
	N.info.operator.symbol.code	= _COMMA ;

	rc = mkNOD( &N ) && AOPfun( send, mkSYS( "CIsend" ), msg ) ;
    }
  }

  return rc ;

} /* cisend */
/*----------------------------------------------------------------------------*/
