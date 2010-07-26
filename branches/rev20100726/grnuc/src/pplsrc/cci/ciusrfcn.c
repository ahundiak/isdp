/* -- This module handles user-defined functions.
      UFN = User FunctioN.
      The formal  arguments  of the currently  parsed function  are kept in
      `U__Alist' ( it  is  in  fact a pointer to  pointer ... ). The  actual
      arguments of a function are kept when  calls are encountered till the
      function  definition  is met; the  arguments  of the  calls are  then
      checked for type compatibility against the formal arguments. The list
      of calls is  discarded and  the list  of formal  arguments kept for a
      next encounter of a call.
      Entry points into this module are:
      	- mkUFN		: reserves space for data structure
      	- UFNaddarg	: adds argument as argument list is parsed
      	- mkUFNarg	: construct args as argument declaration is parsed
      	- UFNbegin	: begins function, pushes arguments.
      	- UFNend	: ends function, clears stack, generates `return'
	- UFN_TYIcmp	: used by TYI module to compare 2 function arg lists
 -- */
/*-INCLUDES-------------------------------------------------------------------*/
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "cichardef.h"
#include "cidef.h"
#include "citypedef.h"
#include <ctype.h>
#include <malloc.h>
#include <limits.h>
#include <string.h>
#define DEBUG 0
/*-TYPEDEFS-------------------------------------------------------------------*/
/* -- Formal argument : name and index in the variable table, flag if argument
      is passed by reference.
   -- */
typedef struct {	Uchar	Refr	;
			int	Indx	;
			char 	*Name	;
} Uformal ;

/* --		  Data Structure For User Defined Functions

U__Flist
  ----    ----------------------------
  |  |--->|  |  |  |  |  |  |  |  |  |
  ----    ----------------------------
                       |
                       V
                     ----    --------------------
	function     |  |--->|       <name>     |
		     ----    --------------------
     {	argc	     |  |
defn {		     ----    ----------------------
     {	argv	     |  |--->|   |   |   |   | ...
		     ----    ----------------------
	calls	     |  |---
		     ----  |
		           V
		         ----
	{	argc	 |  |
	{	         ----    -------------
 actual	{	argv	 |  |--->|   |   | ...
	{	         ----    -------------
	{	next	 |  |---
		         ----  |
			       V
			     ----
	    {	    argc     |  |
	    {		     ----    -------------
     actual {	    argv     |  |--->|   |   | ...
	    {		     ----    -------------
	    {	    next     |  |...
			     ----   
   -- */
/* -- List of ( actual or formal ) arguments : count, arrays of indexes in
      the variable list and flag for passed-by-reference ( formal args only ).
   -- */
typedef struct {	Uchar	argc	;
			Ushort	*argv	;
			Uchar	*refr	;
} Ulist ;

/* -- List of calls ( linked list ) : list of actual arguments, file line  where
      call occurs, pointer  to next call.
   -- */
typedef struct _Ucall {		Ulist		actual	;
				Ushort		line	;
				struct _Ucall	*next	;
} Ucall ;

/* -- Argument check : function name, formal arguments, list of calls PRECEDING
      the function definition.
   -- */
typedef struct {	char	*function	;
			Ulist	defn		;
			Ucall	*calls		;
} Ucheck ;
/*-GLOBALS--------------------------------------------------------------------*/
/* -- List of all user defined functions, occupancy and size.
   -- */
static Ucheck	 	**U__Flist	= NULL	;
static unsigned		U__Fsize		= 0	;
static unsigned		U__nfcns		= 0	;

/* -- List of formal arguments of the currently parsed function.
   -- */
static Uformal		**U__Alist	= NULL	;

/* -- Available space in above list.
   -- */
static unsigned		U__Asize		= 0	;

/* -- Number of arguments of the currently parsed function.
   -- */
static unsigned		U__nargs		= 0	;
/*----------------------------------------------------------------------------*/
extern char	*itoa()			;
extern unsigned VARsizeof()		;
extern void	MKname(), CTXdefault()	;

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

static Uformal *UFNgetarg __((PCIident A));
static Ucheck *UFNgetfcn __((PCIident F));
static void UFNfreeA __((void));
static void UFNcallfree __((Ucall *C));
static int UFNargcheck __((Ucheck *f, int nactual, Ushort *actual, int line));
static int UFNrefcheck __((Ucheck *f, int line));
static Ucheck *UFNinitF __((PCIident F));

#if defined(__cplusplus)
}
#endif
#undef __


/*-DEFINES--------------------------------------------------------------------*/
/* -- Quantum size of `U__Alist' and `U__Flist'.
   -- */
#define UBUNCH		32
#define UNDECLARED	( (Uchar) -1 )
/*----------------------------------------------------------------------------*/
/* -- Loop on arguments of currently parsed function.
   -- */
#define ARGbegin(a) { register Uformal **__end = ( (a) = U__Alist ) + U__nargs ;\
		      while( (a) < __end ) {
#define ARGend(a)   (a)++ ; } }

/* -- Loop on user-defined functions.
   -- */
#define FCNbegin(f) { register Ucheck **__end = ( (f) = U__Flist ) + U__nfcns ; \
		    while( (f) < __end ) {
#define FCNend(f)   (f)++ ; } }
/*----------------------------------------------------------------------------*/
int UFNfind( N )	PCIident N ; {

/* -- Retrieves function in function table `U__Flist'.
      INPUT  : F, identifier of function.
      RETURNS: function index in table if found else EMPTY.
   -- */
	register Ucheck **f ; int i = EMPTY ;

	FCNbegin(f)
		if( !strcmp( N, (*f)->function ) ) {
			i = f - U__Flist ;
			break ;
		}
	FCNend(f)
	
	return i ;
}
/*----------------------------------------------------------------------------*/
int UFNisarg( A )	PCIident A ; {

/* -- Sees if `A' is a formal argument of the currently parsed function.
      RETURNS: its index in the variable table if found else EMPTY.
   -- */

	register Uformal **f ; int ia = EMPTY ;

  	ARGbegin( f )
  		if( !strcmp( A, (*f)->Name ) ) { ia = (*f)->Indx ; break ; }
  	ARGend( f )

  	return ia ;

} /* UFNisarg */
/*----------------------------------------------------------------------------*/
static Uformal *UFNgetarg( A )	PCIident A ; {

/* -- Gets argument `A''s address in argument list.
      RETURNS: NULL if not found, else address of argument struct.
   -- */

	register Uformal **f, *addr = NULL ;

  	ARGbegin( f )
  		if( !strcmp( A, (*f)->Name ) ) { addr = *f ; break ; }
  	ARGend( f )

  	return addr ;

} /* UFNgetarg */
/*----------------------------------------------------------------------------*/
static Ucheck *UFNgetfcn( F )	PCIident F ; {

/* -- Gets argument `F''s address in function list.
      RETURNS: NULL if not found, else address of function struct.
   -- */

	register Ucheck **f, *addr = NULL ;

  	FCNbegin( f )
  		if( !strcmp( F, (*f)->function ) ) { addr = *f ; break ; }
  	FCNend( f )
#if DEBUG
  printf( "UFNgetfcn: <%s> %u\n", F, addr ) ;
#endif
  	return addr ;

} /* UFNgetfcn */
/*----------------------------------------------------------------------------*/
int UFNaddarg( A )	PCIident A ; {

/* -- Adds formal argument `A' to the argument list of the currently parsed
      function.
      RETURNS : TRUE if OK and FALSE in case of memory allocation failure or
                argument already in list.
      NOTE : <function> ( <arg1>, <arg2>, ..., <argn> ) is being parsed: the
      types of the arguments are not known yet.
   -- */


  int rc ; Uformal *arg ;

#if DEBUG
  printf( "UFNaddarg : %d : <%s>\n", U__nargs, A ) ; fflush( stdout ) ;
#endif
/* -- Check that this argument is not already in the list.
   -- */
  if( UFNgetarg( A ) != NULL ) rc = ERRsyn( "redeclaration of argument", A ) ;
  else {
/* -- Get some more space if need be.
   -- */
    if( U__nargs >= U__Asize ) {
	U__Asize += UBUNCH ;
	if( ALLOC( U__Alist, U__Asize, Uformal * ) == NULL )
		rc = ERRmem( "argument list" ) ;
    }
    if( rc ) {
    	if( MALLOC( arg, 1, Uformal ) != NULL ) {
      	   U__Alist[U__nargs++] = arg ;
    	
/* --	   Copy name in list, set index at EMPTY. Since the type is not known
	   yet, the symbol is not entered in the symbol table.
   -- */
      	   if( MALLOC( arg->Name, 1 + strlen( A ), char ) != NULL ) {
      		strcpy( arg->Name, A )	;
      		arg->Indx = EMPTY	;
      	   } else rc = ERRmem( "argument name" ) ;
      	} else rc = ERRmem( "argument" ) ;
    }
  }
  return rc ;

} /* UFNaddarg */
/*----------------------------------------------------------------------------*/
static void UFNfreeA()	{

/* -- Frees the current formal  argument list. Must be called AFTER the function
      has been completely parsed.
   -- */

	register Uformal **cur ;

#if DEBUG
  printf( "UFNfreeA : ENTER\n" ) ;
#endif
  	if( U__nargs != 0 ) {
  		ARGbegin( cur )
  			free( (*cur)->Name )	;
  			free( (char *) *cur )	;
  		ARGend( cur )
  		free( (char *) U__Alist ) ;
  
  		U__Alist = NULL	;
  		U__nargs = 0	;
  		U__Asize = 0	;
  	}
#if DEBUG
  printf( "UFNfreeA : EXIT\n" ) ;
#endif
  
} /* UFNfreeA */
/*----------------------------------------------------------------------------*/
static void UFNcallfree( C ) register Ucall *C ; {

/* -- Frees a list of calls. Does nothing if C is NULL.
   -- */

 register Ucall *p ;

  while( C ) {	p = C->next		; FREE( C->actual.argv )	;
  		free( (char *) C )	; C = p				; }

} /* UFNcallfree */
/*----------------------------------------------------------------------------*/
void UFNfree() {

/* -- Frees all functions. Called after parsing.
   -- */

	register Ucheck **curr, **last, *check ;

	last = ( curr = U__Flist ) + U__nfcns ;
	while( curr < last ) {
  		check = *curr++			;
  		FREE( check->defn.argv )	;
  		FREE( check->defn.refr )	;
  		UFNcallfree( check->calls )	;
  		free( (char *) check )		;
  	}
  	U__Flist	= NULL	;
  	U__Fsize	= 0	;
  	U__nfcns	= 0	;
  	U__nargs = 0	; /* Reset again in case an error occured	*/
  	U__Alist = NULL	; /* while parsing a function, not to confuse	*/
  	U__Asize = 0	; /* the next file to be parsed if any ...	*/

} /* UFNfree */
/*----------------------------------------------------------------------------*/
int UFNtypeq( T, Eq )	PCItype *T, *Eq ; {

/* -- Gets type equivalent to `T' for a function arguments (i.e. takes care of
      the equivalence array <-> pointer ).
      RETURNS: FALSE if type is `void' else TRUE.
   -- */

	PCItype *eq = T ; void TYPeq() ; int dim, rc ;

#if DEBUG
  TYPdump( "UFNtypeq : ENTER ", T ) ;
  printf( "\n" ) ;
#endif
	TYPeq( &eq, (PCItype **) NULL ) ;
	if( TYPvoid( eq ) ) {
		rc = FALSE ;
	} else {
		dim = eq->Dim ;
  		if( eq->Dim ) {
  			eq->Ptr++	;
  			eq->Dim = 0	;
 		 }
#if DEBUG
  TYPdump( "UFNtypeq : EXIT ", eq ) ;
  printf( "\n" ) ;
#endif
		*Eq = *eq ;
		rc = TRUE ;
	}
 	return rc ;

} /* UFNtypeq */

static PCIpointer Dummy1, Dummy2, Dummy3;
/*----------------------------------------------------------------------------*/
int mkUFNarg( C, A )	PCIcontext 	*C	;
			PCIident	A	; {

/* -- Type declaration for formal argument.
      INPUT  : C, argument context.
               A, argument name.
      RETURNS: index in variable table if OK else EMPTY if `A' is not in
               argument list or variable could not be declared.
      NOTE: this function is called when the arguments are being declared.
   -- */

	int ia = EMPTY ; PCIident V ; Uformal *a ; PCIcontext CC ;

#if DEBUG
  printf( "mkUFNarg : declaring %s ref ? %d\n", A, C->ref ) ; TYPdump( "", &C->typ ) ;
  printf( "\n" ) ;
#endif
/* -- ( PCInvar + 1 ) will ensure that this variable will be unique.
   -- and several functions can have args sharing the same name.
   -- */
  if( ( a = UFNgetarg( A ) ) == NULL ) ERRsyn( "not a parameter", A ) ;
  else {
/* -- 	Change type of an argument declared as an `array of <type>' into a 
      	`pointer to <type>' ( i.e. <type> <arg>[<dim>] ---> <type> *<arg> ).
   -- */
     	CC = *C ;
  	if( !UFNtypeq( &C->typ, &CC.typ ) ) {
  		ERRsyn( "void type for argument", A ) ;
  	} else {
		Dummy1.Val = PCInvar;
		Dummy2.Any = A;
		Dummy3.Any = NULL;
  		MKname( ARG, V, Dummy1, Dummy2, Dummy3 );
  		if( ( a->Indx = ia = MKvar( &CC, V ) ) != EMPTY ) {
  			a->Refr = CC.ref		;
#if DEBUG
  printf( "mkUFNarg : <%s> ref ? %d\n", A, a->Refr ) ;
#endif
  			PCIusd( ia ).stat = VAR_NOT_USED;
  		}
  	}
  }

  return ia ;

} /* mkUFNarg */
/*----------------------------------------------------------------------------*/
int UFNdefault() {

/* -- Declares the undeclared formal arguments as "int"'s.
      RETURNS : FALSE if it could not create variables else TRUE.
   -- */

  register Uformal	**a	; PCIcontext	info	;
  PCIident		V	; int		rc	; PCItype *pTYPbasic() ;

/* -- Construct default context.
   -- */
 CTXdefault( pTYPbasic( CI_INT ), &info ) ;
 rc = TRUE ;

/* -- Loop on arguments: those with an EMPTY index have not been declared.
   -- */
 ARGbegin( a )
   if( (*a)->Indx == EMPTY ) {
     (*a)->Indx = MKvar( &info, strcat( itoa( V, PCInvar + 1 ), (*a)->Name ) ) ;
#if DEBUG
  printf( "UFNdefault : declaring %s\n", (*a)->Name ) ;
#endif
     if( (*a)->Indx == EMPTY ) {
     		rc = FALSE	;
      		break		;
     } else {
     		(*a)->Refr = FALSE ;
  		PCIusd( (*a)->Indx ).stat = VAR_NOT_USED;
     }
   }
 ARGend( a )
  
 return rc ;

} /* UFNdefault */
/*----------------------------------------------------------------------------*/
static int UFNargcheck( f, nactual, actual, line )
						Ucheck	*f	;
						int	nactual ;
						Ushort	*actual ;
						int	line	; {

/* -- Checks function argument types.
      RETURNS: TRUE if OK else FALSE.
      NOTE   : does not issue an error message if `line' is EMPTY.
   -- */

		int rc = TRUE ; Ushort *formal ; emsg tmp ;
#if DEBUG
  printf( "UFNargcheck : <%s> nf %d na %d\n", f->function, f->defn.argc, nactual ) ;
#endif

 if( PCIopt.noargchk ) rc = TRUE ;
 else if( f->defn.argc != nactual )
   if( line != EMPTY ) rc = ERRsyn( "wrong argument count", f->function );
   else                rc = FALSE ;
 else {
   formal = f->defn.argv ;
   while( nactual-- ) {
#if DEBUG
     printf( "--> %s : checking %s against %s\n", f->function,
        	PCIvar( *actual ), PCIvar( *formal ) ) ;
#endif

     if( !TYPfuncall( pPCIdef( *formal ),
                         isnull   ( *actual )
  	              && ispointer( *formal ) ? pPCIdef( *formal )
  	                                      : pPCIdef( *actual ),
  	              USRFUN ) ) {
  	if( line != EMPTY ) {
  	  rc = ( formal - f->defn.argv ) + 1 ;
          sprintf( tmp, "%.*s(%d)", MAXEMSG - 6, f->function, rc ) ;
  	  rc = ERRsynL( "argument type mismatch for function", tmp, line ) ;
	} else rc = FALSE ;
     }
     formal++ ; actual++ ;
   }
 }
#if DEBUG
  printf( "UFNargcheck : EXIT(%d)\n", rc ) ;
#endif
 return rc ;
	
} /* UFNargcheck */
/*----------------------------------------------------------------------------*/
static int UFNrefcheck( f, line )	Ucheck	*f	;
					int	line	; {

/* -- Checks  whether  arguments are passed  by reference. If so  issue an error
      message since a call to the function being encountered before the function
      declaration  has to a  "pass-argument-by-value" instruction  to be wrongly
      generated.
      RETURNS: TRUE if OK else FALSE.
   -- */
	int rc = TRUE, nformal ; Uchar *formal ; emsg tmp ;

   formal  = f->defn.refr ;
   nformal = f->defn.argc ;
   while( nformal-- ) {
   	if( *formal ) {
  	  rc = ( formal - f->defn.refr ) + 1 ;
  	  sprintf( tmp, "arg %d passed by reference, declare function before call", rc ) ;
  	  rc = ERRsynL( tmp, f->function, line ) ;
  	}
  	formal++ ;
   }
   return rc ;

} /* UFNrefcheck */
/*----------------------------------------------------------------------------*/
static Ucheck *UFNinitF( F )	PCIident F ; {

/* -- Initializes a function structure.
      INPUT  : F, function name ( must point to a global or static buffer! )
      RETURNS: f, pointer to newly created function structure (NULL if trouble).
   -- */

  register Ucheck *f = NULL ;

  if( U__nfcns >= U__Fsize ) {
	U__Fsize += UBUNCH ;
	if( ALLOC( U__Flist, U__Fsize, Ucheck * ) == NULL ) {
		ERRmem( "function list" ) ;
		goto End ;
	}
  }
  if( MALLOC( f, 1, Ucheck ) != NULL ) {
	U__Flist[U__nfcns++]	= f		;
	f->function		= F		;
	f->defn.argc		= UNDECLARED	;
	f->defn.argv		= NULL	  	;
	f->defn.refr		= NULL	  	;
	f->calls		= NULL		;
  } else ERRmem( "function entry" ) ;

  End : return f ;

} /* UFNinitF */
/*----------------------------------------------------------------------------*/
int UFNbegin()	{

/* -- Start of function definition:
	- default type for undeclared arguments
	- read argument values from the stack
	- store formal arguments indices for checks of calls
      RETURNS: TRUE if OK and FALSE if troubles with instruction generation.
   -- */

  int rc, s ; register Uformal **a ; Ucheck *f ; Ucall *c ;

#if DEBUG
  printf( "UFNbegin : <%s> U__nargs %d\n", PCIvar( PCIfcn ), U__nargs ) ;
#endif
  if( rc = UFNdefault() ) {
    ARGbegin( a )
       if( (*a)->Refr ) {
       		if( !( rc = gen( PULLADR, 1, (*a)->Indx ) ) ) return FALSE ;
       } else {
       		s = VARsizeof( (*a)->Indx ) ;
       		if( !gen( PULLVAL, 3, (*a)->Indx, s, GAP( s ) ) ) return FALSE ;
       }
    ARGend( a )

    if(    ( f = UFNgetfcn( PCIvar( PCIfcn ) ) ) != NULL
        || ( f = UFNinitF ( PCIvar( PCIfcn ) ) ) != NULL ) {
      f->defn.argc = U__nargs ;
      if(    MALLOC( f->defn.argv, U__nargs, Ushort ) != NULL
          && MALLOC( f->defn.refr, U__nargs, Uchar  ) != NULL ) {
      	s = 0 ;

/* --	Fill function structure with data collected form parsing the formal
        arguments.
   -- */
      	ARGbegin( a )
      		f->defn.refr[s  ] = (*a)->Refr ;
      		f->defn.argv[s++] = (*a)->Indx ;
      	ARGend( a )
       	if( f->calls != NULL ) {
/* --	   Calls to this function already exist: check arguments.
   -- */
           c = f->calls ;
      	   while( c ) {
      	      rc = rc && UFNargcheck( f		    , (int) c->actual.argc,
      	    			      c->actual.argv, (int) c->line )
		      && UFNrefcheck( f, (int) c->line ) ;
      	      c = c->next ;
      	   }
/* --	   Get rid of past calls now that function is defined.
   -- */
      	   UFNcallfree( f->calls ) ; f->calls = NULL ;
      	}
      } else rc = ERRmem( "formal arguments" ) ;
    }
  }
  
#if DEBUG
  printf( "UFNbegin : <%s> EXIT(%d)%d\n", PCIvar( PCIfcn ), rc ) ;
#endif
  return rc ;

} /* UNFbegin */
/*----------------------------------------------------------------------------*/
int UFNend( F )	PCIident F ; {

/* -- End of function definition:
	- generates `return' instruction
	- warns about unused arguments
      RETURNS: TRUE if OK and FALSE if troubles with instruction generation.
    -- */

  register Uformal **a ; int rc ; emsg e ; void VARforget() ;

#if DEBUG
  printf( "UFNend: ENTER <%s> %d args\n", F, U__nargs ) ; fflush( stdout ) ;
#endif
  ARGbegin( a )
  	if( PCIusd( (*a)->Indx ).stat == VAR_NOT_USED ) {
  		sprintf( e, "%.*s in %.*s", MAXEMSG / 2 - 3, (*a)->Name,
  		                            MAXEMSG / 2 - 3, F		) ;
  		WNGsyn( "function argument unused", e ) ;
  	}
  ARGend( a )

  rc = gen( RETURN, 0 ) ; VARforget( F ) ; PCIfcn = EMPTY ;
  UFNfreeA() ;
#if DEBUG
  printf( "UFNend: EXIT(%d)\n", rc ) ;
#endif
  return rc ;

} /* UFNend */
/*----------------------------------------------------------------------------*/
int UFNmkcall( a, call )	Ucall	**a 	;
				PCIlist	*call	; {

/* -- Allocates space for a `call' structure and fills it ( argument count and
      list ).
      INPUT  : call, function index (0) + arg indices (1,2,...)
      OUTPUT : a   , call to fill.
      RETURNS: FALSE if memory allocation trouble else TRUE.
   -- */

  int i, rc = TRUE, num ;

  num = call->num - 1 ;
  if( MALLOC( *a, 1, Ucall ) != NULL ) {
  	(*a)->actual.argc	= num				;
  	(*a)->line		= PCI_Get_current_line()	;
  	(*a)->next		= NULL				;
  	if( MALLOC( (*a)->actual.argv, num, Ushort ) != NULL ) {
	    		for( i = 0 ; i < num ; i++ ) {
	    			(*a)->actual.argv[i] = call->elt.Auto[i+1] ;
	    		}
	    		rc = TRUE ;
	} else rc = ERRmem( "actual arguments" ) ;
  } else rc = ERRmem( "function call" ) ;

  return rc ;

} /* UFNmkcall */
/*----------------------------------------------------------------------------*/
int UFNaddcall( fcn, call )	Ucheck	*fcn	;
				PCIlist	*call	; {

/* -- Adds a call in a not-yet-declared function call list.
      INPUT  : fcn , address of function in list (NULL if non-existent).
               call, list of indices of actual arguments.
      RETURNS: FALSE if memory allocation failure else TRUE.
   -- */

	int rc = FALSE ; Ucall *L ;

/* -- Function encountered for the 1st time ( fcn == NULL ) => init.
   -- */
  if( fcn != NULL || ( fcn = UFNinitF( PCIvar( call->elt.Auto[0] ) ) ) != NULL ) {
/* -- Add this call.
   -- */
      if( UFNmkcall( &L, call ) ) {
   		L->next		= fcn->calls	;
   		fcn->calls	= L		; rc = TRUE ;
      }
   }
   return rc ;

} /* UFNaddcall */
/*----------------------------------------------------------------------------*/
int UFNcheck( call )	PCIlist *call ; {

/* -- If the called function has been defined, checks argument types else stores
      actual parameters for a later check when that function becomes defined.
   -- */

			Ucheck *f ; int rc ;

  f = UFNgetfcn( PCIvar( call->elt.Auto[0] ) ) ;
#if DEBUG
  printf( "UFNcheck: %s %u\n", call->elt.Auto[0], f ) ;
#endif
  if( f != NULL ) {
  	if( f->defn.argc != UNDECLARED ) {
 	   rc = UFNargcheck( f, (int)call->num - 1, (Ushort *)call->elt.Auto+1,
  		                *f->function != '=' ? PCI_Get_current_line()
  		                  		      : EMPTY  ) ; 
	} else rc = UFNaddcall( f, call ) ;
  } else rc = UFNaddcall( (Ucheck *) NULL, call ) ;

  return rc ;

} /* UFNcheck */
/*----------------------------------------------------------------------------*/
int UFNcall( call )	PCIlist *call ; {

/* -- User-defined function call:
	- checks actual/formal arg types
	- pushes actual parameters onto the stack
      RETURNS: TRUE if OK and FALSE if troubles with instruction generation.
   -- */

	int rc, i, size ; register int e ; Uchar *refr ; Ucheck *f ;
#if DEBUG
  printf( "UFNcall : <%s>\n", PCIvar( call->elt.Auto[0] ) ) ;
#endif
 if( rc = UFNcheck( call ) ) {
   f = UFNgetfcn( PCIvar( call->elt.Auto[0] ) ) ;
   refr = f->defn.refr != NULL ? f->defn.refr + call->num - 2 : NULL ;

   for( i = call->num - 1 ; i > 0 ; i-- ) {
      e = call->elt.Auto[i] ;
      if( isarray( e ) || ( refr ? *refr-- : FALSE ) ) {
#if DEBUG
  printf( "UFNcall :  PUSHADR <%s> refr ? %d\n", PCIvar( e ),
    refr ? *(refr+1): FALSE  ) ;
#endif
      	if( !( rc = gen( PUSHADR, 1, e ) ) ) break ;
      } else {
      	size = VARsizeof( e ) ;
#if DEBUG
  printf( "UFNcall :  PUSHVAL <%s>\n", PCIvar( e ) ) ;
#endif
      	if( !( rc = gen( PUSHVAL, 3, e, size, GAP( size ) ) ) ) break ;
     }
   }
 }
 return rc ;

} /* UFNcall */  	
/*----------------------------------------------------------------------------*/
int mkUFN( type, name )		PCItype		type ;
				PCIident	name ; {

/* -- Creates a user function.
      INPUT  : type, name : function's type and name.
      RETURNS: index of associated variable if OK else EMPTY.
   -- */

	int fun = EMPTY ; PCIcontext C ;

#if DEBUG
  printf( "mkUFN: ENTER <%s>\n", name ) ;
#endif
  if( PCInufn >= MAXFUNC )
  	ERRovr( "too many user-defined functions", NULL ) ;
  else {
/* -- Generation of a label for branching on call.
   -- */
   if( mkLAB( name, FN_LAB, PCInins ) != EMPTY )

/* -- Redundant but used, function entries.
   -- */
     if( create_f_ent( PCIdata, name, PCInins ) ) {

/* --    Generation of a variable of same type as the function.
   -- */
       C.typ = type	; C.loc = cxGLOBL ; C.ref = FALSE ;
       C.sto = cxSTATC	; C.use = cxFUNCT ;
       if( ( fun = MKdcl( &C, name ) ) != EMPTY ) {
#if DEBUG
  printf( "mkUFN: %s extern ? <%d>\n", name, isextern( fun ) ) ;
#endif
         if( !isfunction( fun ) ) {
	    ERRsyn( "identifier already used", name ) ;
	    fun = EMPTY ;
         } else if( isextern( fun ) ) {
#if DEBUG
  printf( "mkUFN: overidden <%s>\n", name ) ;
#endif
	    WNGsyn( "user function overriden by `extern' declaration", name ) ;
         } else { int u ;
         	for( u = PCIdata->nbf_entries - 1 ; u >= 0 ; u-- ) {
         	     	if(    !strcmp( name, PCIdata->f_entries[u]->name )
         	     	    && PCIdata->f_entries[u]->no_instr != PCInins  ) {
         	     		ERRsyn( "user function already declared", name ) ;
         	     		break ;
         	     	}
         	}
         	PCIsts( fun ) |= CI_USER ;
        }
           
/* --	Warn user of unused functions.
   --   */
         if(    PCIopt.unusedfn
             && strcmp( name, "main" ) ) PCIusd( fun ).stat = VAR_NOT_USED ;
         PCIusd( fun ).func = (unsigned)EMPTY ;
      }
    } else ERRmem( "function construction" ) ;
  }

  return fun ;

} /* mkUFN */
/*----------------------------------------------------------------------------*/
int UFN_TYIcmp( f1, f2 )	PCIident f1, f2 ; {
	int if1, if2 ;

	if1 = UFNfind( f1 ) ; if2 = UFNfind( f2 ) ;
	
	return UFNargcheck(	U__Flist[if1]		,
			   (int)U__Flist[if2]->defn.argc	,
			  	U__Flist[if2]->defn.argv	,
			  	EMPTY			) ; 
} /* UFN_TYIcmp */
/*----------------------------------------------------------------------------*/
void UFNprtargs( F, fcn ) FILE *F ; int fcn ; {

#define UorS( p ) ( *(p) == 's' || *(p) == 'u' ? (p) : "" )

  	int	i, argc		;
  	Ushort	*argv		;
  	Uchar   *refr		;
  	char	*s1, *s2, *s3	;
  	void	TYPname()	;

	argc = U__Flist[fcn]->defn.argc ;
  	argv = U__Flist[fcn]->defn.argv ;
  	refr = U__Flist[fcn]->defn.refr ;
  	for( i = 0 ; i < argc ; i++ ) {
  	  	TYPname( pPCIdef( argv[i] ), &s1, &s2 )		;
  	  	s3 = PCIvar( argv[i] ) + 1			;
  	  	while( isdigit( *s3 ) ) s3++			;
  	  	fprintf( F, " %s %s %s%s", UorS( s1 ), s2,
  	  		 refr[i] ? "&" : "", s3 )		;
		if( i < argc - 1 ) fprintf( F, "," ) 		;
	}

} /* UFNprtargs */
/*----------------------------------------------------------------------------*/
void UFNdump( F )	FILE *F ; {

  register Ucheck	**f		;
  char			*s1, *s2	;
  void			TYPname()	;

  if( U__nfcns ) {
     fprintf( F, "\n\t\t\t\tUSER DEFINED FUNCTIONS\n\t\t\t\t----------------------\n\n" ) ;
     FCNbegin( f )
/* --	Do not list functions defined for internal use...
   -- */
  	if( isidchar( (*f)->function[0] ) ) {
  		TYPname( pPCIdef( STBfind( (*f)->function, SYM_GVAR_NAM ) ),
  			 &s1, &s2 ) ;
  	  	fprintf( F, "%s %s %s(", UorS( s1 ), s2, (*f)->function ) ;
	  	UFNprtargs( F, f - U__Flist )	;
	  	fprintf( F, " )\n\n" )		;
	}
     FCNend( f )
  }

} /* UFNdump */
/*----------------------------------------------------------------------------*/
