/* -- This module handles the 'typeinit' stuff.
      TIN = TypeINit
   -- */
/*-INCLUDES-------------------------------------------------------------------*/
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "cidef.h"
#include "cichardef.h"
#include "citypedef.h"
#include <malloc.h>
#include <limits.h>
#include <string.h>
#define DEBUG 0
/*----------------------------------------------------------------------------*/
extern  char *TDFname(), *BSCname()	;
extern	void CTXdefault(), TYPeq()	;


/*-TYPEDEF--------------------------------------------------------------------*/
typedef struct _Ifcn {
				int		this	;
				struct _Ifcn	*next	;
} Ifcn ;

/* -- Linked list of initialization functions for one type.
   -- */
typedef struct {
				short		Tindex	,
						Deftyp	,
						Numfcn	;
				Ifcn		*Fcnlst	;
} Ilst ;

/* DATA STRUCTURE
	       -----    ----------------------------
	I__list |   |--->|   |   |   |   |   |   | ...
	       -----    ----------------------------
	                          |
	                          V
	                        -----
	                Tindex  |   |
	                        -----
	                Numfcn  |   |
	                        -----   ------     ------
	                Fcnlst  |   |-->|this|  -->|this|  --> ...
	                        -----   ------  |  ------  |
	                                |next|---  |next|---
	                                ------     ------
*/
/*-STATIC GLOBALS-------------------------------------------------------------*/
/* -- Array of function lists and size of list.
   -- */
static Ilst	**I__list	= NULL	;
static Ushort	I__size		= 0	;

/* -- Index in `I__list' of currently parsed typeinit declaration
      (EMPTY if none).
   -- */
static short	I__parsed	= EMPTY	;

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

static char *__TYIname __((int Def, int Num));
static char *TYIname __((Ilst *i));
static int TYIunique __((int it));

#if defined(__cplusplus)
}
#endif
#undef __


/*-MACROS---------------------------------------------------------------------*/
/* -- Loop on types for which an initalization function exists.
   -- */
#define TINbegin(t)	{ register Ilst **__end = ( (t) = I__list ) + I__size ;\
			  while( (t) < __end ) {
#define TINend(t)	(t)++ ; } }
/*----------------------------------------------------------------------------*/
extern void MKname() ;

PCIpointer Dummy1, Dummy2, Dummy3;
/*----------------------------------------------------------------------------*/
static char *__TYIname( Def, Num )	int Def, Num ; {

	char *n ;
	switch( Def ) {
	  case TYPDF : n = TDFname( Num ) ; break ;
	  case BASIC : n = BSCname( Num ) ; break ;
	  default    : cibugchk( "__TYIname", "unknown type" ) ;
	}
	return n ;
}
/*----------------------------------------------------------------------------*/
static char *TYIname( i )	Ilst	*i ; {
	return __TYIname( (int) i->Deftyp, (int) i->Tindex ) ;
}
/*----------------------------------------------------------------------------*/
int TYIfind( T )	PCItype *T ;	{

/* -- Retrieves the initialization for type `T'.
      INPUT  : T, pointer type.
      RETURNS: the index of the functions for this type, or EMPTY if
               there is no function yet.
   -- */

  	int index = EMPTY ; register Ilst **i ;
  
#if DEBUG
  printf( "TYIfind: enter <%s>\n", __TYIname( T->Def, T->Num ) ) ;
#endif
	TINbegin(i)
  		if(	(*i)->Tindex == (int) T->Num
  		    &&	(*i)->Deftyp == (int) T->Def ) {
  			index = i - I__list	;
  			break			;
  		}
  	TINend(i)

#if DEBUG
  printf( "TYIfind: EXIT index %d\n", index ) ;
#endif
	return index ;

} /* TYIfind */
/*----------------------------------------------------------------------------*/
static int TYIunique( it ) int it ; {

/* -- Checks that this init function does not already exist: i.e. that its
      argument list is not compatible with those of formerly declared
      typeinit for that type ( the comparison between formal and actual
      arguments in user functions is used to that purpose ).
   -- */
	int i, rc = TRUE ; PCIident f1, f2 ; Ifcn *f ; Ilst *t ;

   t = I__list[it] ;
   Dummy1.Val = it;
   Dummy2.Val = 1;
   Dummy3.Any = "";
   MKname( INI, f1, Dummy1, Dummy2, Dummy3);
#if DEBUG
	printf( "TYIunique: f1 %s Numfcn %d\n", f1, t->Numfcn ) ; fflush( stdout ) ;
#endif
   for( i = 1, f = t->Fcnlst->next ; i < t->Numfcn ; i++ ) {
	Dummy1.Val = it;
	Dummy2.Val = i + 1;
	Dummy3.Any = "";
	MKname( INI, f2, Dummy1, Dummy2, Dummy3);
   	if( UFN_TYIcmp( f1, f2 ) ) {
   		rc = FALSE ;
   		break ;
   	} else f = f->next ;
   }
   return rc ;

} /* TYIunique */
/*----------------------------------------------------------------------------*/
int TYIfindthis( T )	PCItype *T ; {

/* -- It is assumed that `T' has init functions...
      RETURNS: the index of the "this" variable of the latest `typeinit'.
   -- */
				int i = EMPTY ;

  if( T->Def == BASIC || T->Def == TYPDF ) {
     if( ( i = TYIfind( T ) ) != EMPTY ) i = I__list[i]->Fcnlst->this ;
     else ERRsyn( "no typeinit for", __TYIname( (int) T->Def, (int) T->Num ) ) ;
  } else ERRsyn( "typeinit call not allowed for this type", NULL ) ;
#if DEBUG
  printf( "TYIfind: EXIT this %d\n", i ) ;
#endif
	
	return i ;
}
/*----------------------------------------------------------------------------*/
int mkTYI( T )	PCItype *T ;	{

/* -- Constructs an initialization function for type `T'.
   -- */

	int		rc, l	;
	PCIident	this	;
	PCIcontext	C	;
	Ifcn		*F	;
	Ilst		*cur	;
	PCItype		*eq	;
#if DEBUG
  printf( "mkTYI : enter <%s>, size %d\n", __TYIname( T->Def, T->Num ), I__size ) ;
#endif
  if( T->Def == TYPDF || T->Def == BASIC ) {
    switch( l = TYIfind( T ) ) {
/* --	First `typeinit' for this type. Get space in array.
   -- */
  	case EMPTY	: 
/* --		Check the type is not `void'.
   -- */
   		eq = T ;
   		TYPeq( &eq, (PCItype **) NULL ) ;
   		if( TYPvoid( eq ) ) {
   			rc = ERRsyn( "typeinit not allowed for `void'", NULL ) ;
			break ;
		}
  		if(     ALLOC( I__list, I__size + 1, Ilst * ) 	!= NULL
  	    	    && MALLOC( I__list[I__size], 1, Ilst ) 	!= NULL ) {
		   	l				= I__size	;
			I__list[I__size  ]->Tindex	= T->Num	;
			I__list[I__size  ]->Deftyp	= T->Def	;
			I__list[I__size  ]->Fcnlst	= NULL		;
			I__list[I__size++]->Numfcn	= 0		;
		} else {	rc = ERRmem( "typeinit declaration" ) ;	
				break ;
		}
#if DEBUG
  printf( "mkTYI: I__size %d Tindex %d\n", I__size-1, I__list[I__size  ]->Tindex ) ;
#endif

/* --	Another `typeinit' for this type. Get space for function.
   -- */
	default		:
		if( MALLOC( F, 1, Ifcn ) != NULL ) {
		   CTXdefault( T, &C ) ;	
		   cur = I__list[l] ;
		   cur->Numfcn++   ;
		   Dummy1.Val = l;
		   Dummy2.Val = cur->Numfcn;
		   Dummy3.Any = "this";
		   MKname( INI, this, Dummy1, Dummy2, Dummy3 );
#if DEBUG
  printf( "mkTYI: this <%s>\n", this ) ;
#endif
		   F->this = MKdcl( &C, this ) ;
		   if( rc = F->this != EMPTY ) {
			  I__parsed		= l		;
			  F->next		= cur->Fcnlst	;
			  cur->Fcnlst		= F		;
			  PCIusd( F->this ).stat= VAR_NOT_USED	;
		   }
		} else rc = ERRmem( "typeinit declaration" ) ;
		break ;
    }
  } else rc = ERRsyn( "`typeinit' only for basic or defined types", NULL ) ;
  return rc ;

} /* mkTYI */
/*----------------------------------------------------------------------------*/
int TYIbegin() {

  PCIident fcn ; PCItype TYPbasic() ;
	
/* -- Create function name "=T<number>.<number>", e.g. "=T12.1".
   -- */
#if DEBUG
  printf( "TYIbegin: ENTER <%d>\n", I__parsed ) ;
#endif
   Dummy1.Val = I__parsed;
   Dummy2.Val = I__list[I__parsed]->Numfcn;
   Dummy3.Any = "";
   MKname( INI, fcn, Dummy1, Dummy2, Dummy3 );
   return    ( PCIfcn = mkUFN( TYPbasic( CI_INT ), fcn ) ) != EMPTY
          && UFNbegin() ;
}
/*----------------------------------------------------------------------------*/
int TYIend() {
	char *n ; int rc ;

#if DEBUG
  printf( "TYIend: ENTER <%d>, index %d\n", I__parsed, I__list[I__parsed]->Tindex ) ;
#endif
	n = TYIname( I__list[I__parsed] ) ;
	if( PCIusd( I__list[I__parsed]->Fcnlst->this ).stat == VAR_NOT_USED )
		WNGsyn( "`this' unused in typeinit", n ) ;
	if( rc = UFNend( n ) ) {
	   if( !TYIunique( I__parsed ) )
		rc = ERRsyn( "init already exists with this arg list for", n ) ;
	}
	I__parsed = EMPTY ;
	return rc ;
			
} /* TYIend */
/*----------------------------------------------------------------------------*/
int mkTYIarg( C, A )	PCIcontext *C ; PCIident A ; {

/* -- Creates an operand for a `typinit' function : checks that operand has not
      already been declared.
      RETURNS: operand's index as a variable if OK else EMPTY.
   -- */

  return UFNaddarg( A ) ? mkUFNarg( C, A ) : EMPTY ;
}
/*----------------------------------------------------------------------------*/
int TYIisarg( A )	PCIident A ; {

/* -- Sees if `A' is the `this' variable of the currently parsed `typeinit'
      function (the formal args are checked with a call to `UFNisarg' ).
      RETURNS: its index in the variable table if found else EMPTY.
   -- */

  return I__parsed != EMPTY ? 
			!strcmp( A, "this" ) 	? I__list[I__parsed]->Fcnlst->this
						: EMPTY
			: EMPTY ;
} /* TYIisarg */
/*----------------------------------------------------------------------------*/
int TYIcall( t, argv ) int t ; PCIlist *argv ; {

  register Ifcn	*f ; PCIident I ; int num, this = EMPTY ;
#if DEBUG
  printf( "TYIcall : index %d <%s>\n", t, TYIname( I__list[t] ) ) ;
#endif
  f = I__list[t]->Fcnlst ;

  num = I__list[t]->Numfcn ;
  while( f != NULL ) {
	Dummy1.Val = t;
	Dummy2.Val = num;
	Dummy3.Any = "";
  	MKname( INI, I, Dummy1, Dummy2, Dummy3 );
  	argv->elt.Auto[0] = STBfind( I, SYM_GVAR_NAM ) ;
  	if( UFNcheck( argv ) ) {
  		this = f->this ;
#if DEBUG
  printf( "TYIcall : f->this <%s>\n", PCIvar( f->this ) ) ;
#endif
  		break ;
  	}
  	f = f->next	;
  	num--		;
  }
  if( this == EMPTY )
  	ERRsyn( "no typeinit with this arg list for", TYIname( I__list[t] ) ) ;
#if DEBUG
  else printf( "TYIcall : index %d this = <%s>\n", t, PCIvar( this ) ) ;
#endif
  
  return this ;

} /* TYIcall */
/*----------------------------------------------------------------------------*/
void TYIfree() {

/* -- Frees `typeinit' data. Must be called at the end of parsing.
   -- */
	register Ilst **i 	;
	register Ifcn *f, *g	;
	
	if( I__size ) {
		TINbegin(i)
			f = (*i)->Fcnlst ;
			while( f != NULL ) {
				g = f->next	 	;
				free( (char *) f )	;
				f = g			;
			}
			free( (char *) *i ) ;
		TINend(i)
		free( (char *) I__list ) ;
		I__list		= NULL	;
		I__size		= 0	;
		I__parsed	= EMPTY	;
	}

} /* TYIfree */
/*----------------------------------------------------------------------------*/
void TYIdump( F ) 	FILE *F ; {

/* -- Dumps `typeinit' declaration onto file. Must be called before `TYIfree'.
   -- */
  register Ilst **tyi	;
  register Ifcn *fcn	;
  PCIident	name	;
  void	   UFNprtargs() ;
  int	   i, j		;

  if( I__size ) {
  fprintf( F, "\n\t\t\t\tTYPE INITIALIZATIONS\n\t\t\t\t--------------------\n\n" ) ;
  i = 0 ;
  TINbegin(tyi)
  	fcn = (*tyi)->Fcnlst ;
  	j = 1 ;
  	while( fcn != NULL ) {
  	   fprintf( F, "%d.%d\t%s(", i, j, TYIname( (*tyi) ) ) ;
	   *(strrchr( strcpy( name, PCIvar( fcn->this ) ), '.' ) + 1 ) = EOSTR ;
  	   UFNprtargs( F, UFNfind( name ) ) ;
  	   fprintf( F, " )\n\n" )	;
  	   fcn = fcn->next		;
  	   j++				;
  	}
  	i++ ;
  TINend(tyi)
  }

} /* TYIdump */
/*----------------------------------------------------------------------------*/
