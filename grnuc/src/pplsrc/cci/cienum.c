/* -- This module handles the 'enum' stuff.
      ENM = ENuM
   -- */
/*-INCLUDES-------------------------------------------------------------------*/
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "cichardef.h"
#include "cidef.h"
#include "citypedef.h"
#include <malloc.h>
#include <limits.h>
#include <string.h>
#define DEBUG 0
/*-TYPEDEFS-------------------------------------------------------------------*/
typedef struct _enumelt {
		char		*Nam	;
		int		Val	;
		struct _enumelt	*Nxt	;
} enumelt ;

typedef struct {
		char	*Tag ;
		enumelt	*Lst ;
} enumrep ;

static enumrep	**enm__list	= NULL	;
static int	enm__count	= 0	;

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

static int ENMalloc __((enumrep **e, unsigned l));
static int ENMallocV __((enumelt **el, unsigned l));
static int ENMenter __((PCIident tag, int ie));
static int ENMenterV __((enumelt *el, int ie, PCIident name));
static void ENMfreeV __((enumrep *e));

#if defined(__cplusplus)
}
#endif
#undef __


/*-MACROS---------------------------------------------------------------------*/
#define UNTAGGED "(untagged)"

/* -- Loop on elements of enum at index 'ie'.
   -- */
#define ELTbegin( ie, e ) for( (e) = enm__list[(ie)]->Lst ; (e) != NULL ; ) {
#define ELTend( e )       (e) = (e)->Nxt ; }
/*----------------------------------------------------------------------------*/
static int ENMalloc( e, l )	enumrep  **e ;
				unsigned l   ; {

/* -- Gets space for an enumerated data type.
   -- */

				int rc = TRUE ;
#if DEBUG
  printf( "ENMalloc : l = %d\n", l ) ;
#endif
  l += 1 ; /* 1 for trailing '\0' */
  if(    MALLOC( *e		, 1, enumrep	) != NULL
      && MALLOC( (*e)->Tag	, l, char	) != NULL ) {
      	(*e)->Lst = NULL ;
  } else rc = ERRmem( "enum" ) ;

#if DEBUG
  printf( "ENMalloc : EXIT(%d)\n", rc ) ;
#endif

   return rc ;

} /* ENMalloc */
/*----------------------------------------------------------------------------*/
static int ENMallocV( el, l )	enumelt		**el	;
				unsigned	l	; {

/* -- Allocates memory for a enum element.
      INPUT  : el, address of pointer to malloc.
               l, element name length.
      RETURNS: TRUE if OK, FALSE if allocation failed.
   -- */

				int rc = TRUE ;
#if DEBUG
  printf( "ENMallocV : l = %d\n", l ) ;
#endif
  l += 2 ;
  if( rc =    MALLOC( *el	, 1, enumelt	) != NULL
           && MALLOC( (*el)->Nam, l, char	) != NULL )
      (*el)->Nxt = NULL ;
#if DEBUG
  printf( "ENMallocV : EXIT(%d)\n", rc ) ;
#endif
  
  return rc ; 

} /* ENMallocV */
/*----------------------------------------------------------------------------*/
static int ENMenter( tag, ie )	PCIident	tag	;
				int		ie	; {

  if( strcmp( strcpy( enm__list[ie]->Tag, tag ), UNTAGGED ) )
  	ie = STBenter( enm__list[ie]->Tag, ie, SYM_ENUM_TAG ) ;
  else ie = TRUE ;
  return ie ;
}
/*----------------------------------------------------------------------------*/
static int ENMenterV( el, ie, name )	enumelt		*el	;
					int		ie	;
					PCIident	name	; {
  return STBenter( strcpy( el->Nam, name ), ie, SYM_ENUM_MMB ) ;
}
/*----------------------------------------------------------------------------*/
int ENMfind( tag, type )	PCIident tag	;
				PCItype  *type	; {

/* -- Retrieves an enum in the hash table.
      INPUT   : tag, structure name.
      OUTPUT  : type, address of structure type.
      RETURNS : TRUE if struct/union was found else FALSE
   -- */

			int ie ;

  if( tag != NULL ) {
  	if( ( ie = STBfind( tag, SYM_ENUM_TAG ) ) != EMPTY ) {
  		if( type != NULL ) {
  			type->Dim = 0 ;
  			type->Ptr = FALSE ;
  			type->Rpt = FALSE ;
  			type->Fpt = FALSE ;
  			type->Def = ENUMT ;
  			type->Num = ie ;
  		}
  		ie = TRUE ;
  	} else ie = FALSE ;
  } else ie = FALSE ;

  return ie ;
  
} /* ENMfind */
/*----------------------------------------------------------------------------*/
static void ENMfreeV( e )	enumrep *e ; {

/* -- Frees the element list of an enum representation.
   -- */

			register enumelt *el1, *el2 ;

  el1 = e->Lst ;
  while( el1 != NULL ) {
  	el2 = el1->Nxt ; free( el1->Nam ) ; free( (char *) el1 ) ; el1 = el2 ;
  }

} /* ENMfreeV */
/*----------------------------------------------------------------------------*/
void ENMfree() {

/* -- Frees the enum list. Re-initializes `enm__count' and `enm__list'.
   -- */

				int i ;

	for( i = 0 ; i < enm__count ; i++ ) {
  		ENMfreeV( enm__list[i] )		;
  		free( enm__list[i]->Tag )	;
  		free( (char *) enm__list[i] )	;
	}
	enm__count = 0 ; FREE( enm__list ) ; enm__list = NULL ;

} /* ENMfree */
/*----------------------------------------------------------------------------*/
int ENMfindV( name, value )	PCIident	name	;
				int		*value	; {

/* -- Retrieves an enum identifier.
      INPUT  : name , identifier's name
      OUTPUT : value, associated to identifier ( can be a NULL  pointer if  not
              desired ).
      RETURNS: the enum index to which the identifier belongs or EMPTY if
               not found.
   -- */

			enumelt *e ; int ie ;

  if( ( ie = STBfind( name, SYM_ENUM_MMB ) ) != EMPTY ) {
#if DEBUG
  printf( "ENMfindV : found <%s> at %d\n", name, ie ) ;
#endif
  	if( value != NULL ) {
  		ELTbegin( ie, e )
  			if( strcmp( name, e->Nam ) == 0 ) {
  				 *value = e->Val	;
  				 break			;
  			}
  		ELTend( e )
  	}
  }
#if DEBUG
  printf( "ENMfindV : <%s> value = %d\n", name, value ? *value : 0 ) ;
#endif
  return ie ;

} /* ENMfindV */  
/*----------------------------------------------------------------------------*/
int mkENM( tag )	PCIident tag ; {

/* -- Builds an enumerated data type. Reserves space in the enum list. Increases
      enum counter.
      INPUT  : tag, enum's tag.
      RETURNS: enum's index in list or EMPTY if function failed.
   -- */

				int E_index = EMPTY, i ;
#if DEBUG
   printf( "mkENM : tag = %s\n", tag ) ;
#endif
 if( ENMfind( tag, (PCItype *) NULL ) ) ERRsyn( "enum already declared", tag ) ;
 else {
   	i = enm__count++	;
   	if( tag == NULL ) tag = UNTAGGED ;
   	if( ALLOC( enm__list, enm__count, enumrep * ) != NULL ) {
   	if(    ENMalloc( &enm__list[i], (unsigned) strlen( tag ) )
   	    && ENMenter( tag, i )                                ) E_index = i ;
   	} else ERRmem( "enum list" ) ;
 }

#if DEBUG
   printf( "mkENM : EXIT index %d\n", E_index ) ;
#endif
   return E_index ;

} /* mkENM */
/*----------------------------------------------------------------------------*/
int mkENMval( name, value )	PCIident	name	;
				int		*value	; {

/* -- Creates an element in the current enum.
      INPUT  : name , element name.
               value, pointer to init value ( NULL if not set ).
      RETURNS: FALSE if identifier already declared or memory problem else TRUE.
   -- */

	int E_index = enm__count - 1, rc ; enumelt *curr, *newe, *last ;

#if DEBUG
  printf( "mkENMval : name <%s>\n", name ) ;
#endif
/* -- Check that this identifier does not already exist.
   -- */
  if( IDfind( name ) ) rc = ERRsyn( "redeclaration of", name ) ;
  else if( ENMallocV( &newe, (unsigned) strlen( name ) ) ) {
  	last = NULL ;
  	ELTbegin( E_index, curr )
  		last = curr ;
  	ELTend( curr )
  	if( last == NULL ) {
  		newe->Val = value != NULL ? *value : 0	;
  		enm__list[E_index]->Lst = newe		;
  	} else {
  		newe->Val = value != NULL ? *value : last->Val + 1	;
  		last->Nxt = newe					;
  	}
  	rc = ENMenterV( newe, E_index, name ) ;
  } else rc = ERRmem( "enum value" ) ;

#if DEBUG
  printf( "mkENMval : EXIT(%d)\n", rc ) ;
#endif
  return rc ;

} /* mkENMval */
/*----------------------------------------------------------------------------*/
PCItype ENMend() {
				 PCItype T ;

	T.Def = ENUMT	; T.Dim = 0	; T.Ptr = FALSE		;
	T.Rpt = FALSE	; T.Fpt = FALSE	; T.Num = enm__count - 1 ; return T ;
}
/*----------------------------------------------------------------------------*/
void ENMdump( F )	FILE *F ; {

				int i ; enumelt *el ;
 
  if( enm__count ) {
    fprintf( F, "\n\t\t\t\tENUMERATED DATA TYPES\n\t\t\t\t---------------------\n\n" ) ;
    for( i = 0 ; i < enm__count ; i++ ) {
  	fprintf( F, "%d\tenum %s = {", i, enm__list[i]->Tag ) ;
  	ELTbegin( i, el )
  		fprintf( F, " %s (%d), ", el->Nam, el->Val ) ;
  	ELTend( el )
  	fprintf( F, "}\n\n" ) ;
    }
  }

} /* ENMdump */
/*----------------------------------------------------------------------------*/
char *ENMname( ie ) int ie ; {
	static char buf[30] ;
	if( !strcmp( enm__list[ie]->Tag, UNTAGGED ) ) {
 		sprintf( buf, "(untagged #%d)", ie ) ;
 		return buf ;
	} else return enm__list[ie]->Tag ;
}
/*----------------------------------------------------------------------------*/

