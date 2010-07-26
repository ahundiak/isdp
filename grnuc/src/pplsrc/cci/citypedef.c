/* -- This module handles the 'typedef' stuff.
      TDF = TypeDeF
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
/*-TYPEDEF--------------------------------------------------------------------*/
/* -- typedef representation :
      The type's name and its associated type's description ( `attributes' ).
   -- */
typedef struct { char 		*Name	;
		 PCItype	Attr	;
} deftype ;
/*-GLOBALS--------------------------------------------------------------------*/
/* -- Type list.
   -- */
static deftype	**tdf__list	= NULL	;

/* -- Number of types in type list.
   -- */
static Ushort tdf__count = 0	;

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

static int TDFenter __((PCIident tag, int it));
static int TDFalloc __((deftype **t, unsigned l));

#if defined(__cplusplus)
}
#endif
#undef __


/*----------------------------------------------------------------------------*/
static int TDFenter( tag, it )	PCIident	tag	;
				int		it	; {

  return STBenter( strcpy( tdf__list[it]->Name, tag ), it, SYM_TYPE_NAM ) ;
}
/*----------------------------------------------------------------------------*/
int TDFfind( tag, type )	PCIident tag	;
				PCItype  *type	; {

/* -- Retrieves a type in the hash table.
      INPUT   : tag, type name.
      OUTPUT  : type, type attributes.
      RETURNS : TRUE if the type was found else FALSE
   -- */

			int it ;

  if( ( it = STBfind( tag, SYM_TYPE_NAM ) ) != EMPTY ) {
  	if( type != NULL ) {
  		type->Def = TYPDF	;
  		type->Dim = 0		;
		type->Ptr = FALSE	;
		type->Fpt = FALSE	;
		type->Rpt = FALSE	;
		type->Spc = NULL	;
		type->Num = it		;
	}
  	it = TRUE ;
  } else it = FALSE ;

  return it ;
  
} /* TDFfind */
/*----------------------------------------------------------------------------*/
static int TDFalloc( t, l )	deftype 	**t	;
				unsigned	l	; {

/* -- Allocates space for a type definition.
      NOTE : alignment  and size  are intialized  with USI_MAX ( this  will flag
             that they have not been calculated ).
   -- */

				int rc = TRUE ;

 l += 1 ; /* one for trailing '\0' */
#if DEBUG
  printf( "TDFalloc : l = %d\n", l ) ;
#endif
 if( ! (    MALLOC( *t		, 1, deftype	) != NULL
         && MALLOC( (*t)->Name	, l, char	) != NULL ) )
 	rc = ERRmem( "typedef" ) ;

#if DEBUG
  printf( "TDFalloc : EXIT(%d)\n", rc ) ;
#endif
 return rc ;

} /* TDFalloc */ 
/*----------------------------------------------------------------------------*/
void TDFfree() {

/* -- Frees the typedef list. Re-initializes `tdf__count', `tdf__list'.
   -- */

				int i ;

  for( i = 0 ; i < tdf__count ; i++ ) {
  	free( tdf__list[i]->Name )	;
  	free( (char *) tdf__list[i] )	;
  }
  tdf__count = 0 ; FREE( tdf__list ) ; tdf__list = NULL ;

} /* TDFfree */
/*----------------------------------------------------------------------------*/
PCItype *TDFeq( it )	int it ; {

/* -- Finds type equivalent to type of index `it'. E.g.
	typedef char 	byte		;
	typedef byte 	*string		;
	typedef string	text[24] 	;
	typedef	text	page		;
      `page' is equivalent to `array[24] of char *'.
      RETURNS: a pointer to a static buffer containing the equivalent type.
      NOTE   : gives the equivalent type of the typedef not that of the type.
      i.e. for having the equivalent of type T, a sample invocation would be:
      if( T.Def == TYPDF ) {
      		PCItype *eq = TDFeq( (int) T.Num ) ;
      		eq->Ptr += T.Ptr ;
      		if( !eq->Dim ) eq->Dim = T.Dim ; (* because arrays of arrays
      		                                    do not exist             *)
      }
   -- */

				static PCItype eq ; extern int yydebug ;
  
#if DEBUG
  printf( "TDFeq : it = %d\n", it ) ;
#endif
  eq.Dim = 0 ; eq.Rpt = eq.Ptr = eq.Fpt = FALSE ;

  do {
  	eq.Ptr += tdf__list[it]->Attr.Ptr		;
  	eq.Def  = tdf__list[it]->Attr.Def		;
  	if( !eq.Rpt ) eq.Rpt = tdf__list[it]->Attr.Rpt	;
  	if( !eq.Fpt ) eq.Fpt = tdf__list[it]->Attr.Fpt	;
  	if( !eq.Dim ) eq.Dim = tdf__list[it]->Attr.Dim	; /* OK since arrays of */
  	it	= eq.Num = tdf__list[it]->Attr.Num	; /* arrays not allowed */
  } while( eq.Def == TYPDF ) ;

#if DEBUG
  printf( "TDFeq : .Def %d .Num %d .Dim %d .Ptr %d\n", eq.Def, eq.Num,
          eq.Dim, eq.Ptr ) ;
#endif
  return &eq ;

} /* TDFeq */
/*----------------------------------------------------------------------------*/
unsigned TDFalign( it ) int it ; {

			unsigned TYPalign() ;

	return TYPalign( &tdf__list[it]->Attr ) ;
}
/*----------------------------------------------------------------------------*/
unsigned TDFsizeof( it )	int it ; {

	unsigned dim = tdf__list[it]->Attr.Dim, TYPsizeof() ;

	if( !dim ) dim = 1 ;
	return dim * TYPsizeof( &tdf__list[it]->Attr ) ;
}
/*----------------------------------------------------------------------------*/
char *TDFname( it ) int it ; { return tdf__list[it]->Name ; }
/*----------------------------------------------------------------------------*/
int TDFmultidim( it ) int it ; {

				int rc = TRUE, old ;

  do {
  	if( tdf__list[it]->Attr.Dim )
  		rc = ERRsyn( "multi-dimensional arrays are illegal", NULL ) ;
  	old	= it ;
	it	= tdf__list[it]->Attr.Num ;
  } while( tdf__list[old]->Attr.Def == TYPDF ) ;
  return rc ;

} /* TDFmultidim */
/*----------------------------------------------------------------------------*/
int mkTDF( T, N )	PCItype  *T	;
			PCIident N	; {

/* -- Builds a type, reserves space in the type list. Increases typedef counter.
      INPUT  : T, type definition ( attributes ).
               N, type name.
      RETURNS: type's index in list or EMPTY if function failed.
   -- */

			int T_index = EMPTY, i, rc = TRUE ;

#if DEBUG
  printf( "mkTDF : <%s> .Def %d .Num %d .Dim %d .Ptr %d\n", N, T->Def, T->Num,
          T->Dim, T->Ptr ) ;
#endif
 if( TDFfind( N, (PCItype *) NULL ) ) ERRsyn( "redeclaration of type", N ) ;
 else if( T->Dim && T->Def == TYPDF ) {
/* -- Beware of arrays of arrays since they are not implemented !
   -- */
  	i = T->Num ;
   	do {
   		if( tdf__list[i]->Attr.Dim )
   			rc = ERRsyn( "multi-dimensional arrays are illegal", N ) ;
		i = tdf__list[i]->Attr.Num ;
   	} while( tdf__list[i]->Attr.Def == TYPDF ) ;
 }
 if( rc ) {
	i = tdf__count++ ;
	if( ALLOC( tdf__list, tdf__count, deftype * ) != NULL ) {
   		if( TDFalloc( &tdf__list[i], (unsigned) strlen( N ) ) ) {
   			if( TDFenter( N, i ) ) {
   				tdf__list[i]->Attr = *T	;
   				T_index = i ;
   			}
   		}
	} else ERRmem( "typedef list" ) ;
 }
   		
#if DEBUG
    printf( "MKdcl : EXIT(%d)\n", T_index ) ;
#endif
   return T_index ;

} /* mkTDF */
/*----------------------------------------------------------------------------*/
void TDFdump( f )	FILE *f ; {

		int i ; deftype *t ; char *s1, *s2 ; void TYPname() ;

  if( tdf__count ) {
    fprintf( f, "\t\t\t\tTYPEDEF LIST\n\t\t\t\t------------\n\n" ) ;
    for( i = 0 ; i < tdf__count ; i++ ) {
  	t = tdf__list[i] ;
  	TYPname( &t->Attr, &s1, &s2 ) ;
  	fprintf( f, " ptr %2d dim %4d %-8.8s %-24.24s %-24.24s\n", t->Attr.Ptr,
  		    t->Attr.Dim, s1, s2, t->Name   	      ) ;
    }
  }

} /* TDFdump */
/*----------------------------------------------------------------------------*/
