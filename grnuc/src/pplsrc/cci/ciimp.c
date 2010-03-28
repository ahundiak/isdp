/* -- This module handles the 'implicit' stuff.
      IMP = IMPlicit
      An `implicit' declaration has the form :

		implicit <type> "<pattern>" ;

      Where <type> is a data type, and <pattern> is a regular expression made
      of
      		a-z, A-Z, 0-9, _, $, [, ], ., *, +, -

      with the same meaning as in regular expressions for ed(1) or sed(1),
      except for '$' which is taken as an ordinary character, since '$' is
      a valid character in a PPL identifier.
      Thus
      			implicit double "[a-z]$.*" ;

      will tell cci to consider all undeclared variables of which the name
      begin with a$, b$, ..., z$ as of type double.
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
#include <ctype.h>
#define DEBUG 0
/*-TYPEDEF--------------------------------------------------------------------*/
typedef struct {
		char	*regexp;
		PCItype	type	;
} implicit ;

/*-GLOBALS--------------------------------------------------------------------*/
/* -- Imlicit type list.
   -- */
static implicit	*imp__list	= NULL	;

/* -- Number of implicit types in type list.
   -- */
static Ushort	imp__count	= 0	;
/*----------------------------------------------------------------------------*/
extern char *regcmp(), *regex() ;
/*----------------------------------------------------------------------------*/
int REXvalid( rex ) char *rex ; {

/* -- Check that `rex' is a valid regular expression as a pattern for the
      implicit declaration. To be valid, in must consist of the following
      characters:
      			'a' through 'z'
      			'A' through 'Z'
      			'0' through '9'
      			'$', '_', '[', ']', '.', '*', '-', '+'
   -- */

	for(;; rex++ ) {
		if( isalnum( *rex ) ) ;
		else switch( *rex ) {
			case '[' : case ']' : case '+' :
			case '-' : case '*' : case '.' :
			case '$' : case '_' :		 break ;
			case '\0': return TRUE  ;
			default  : return FALSE ;
		}
	}

} /* REXvalid */
/*----------------------------------------------------------------------------*/
int REXcompile( in, compiled ) PCIstring in ; char *compiled ; {

	char	*ptr, pattern[1024]	;
	int	len, u, v, brcnt, rc	;

	brcnt = 0 ;
	len = in.length ;

	for( u = v = 0 ; u < len ; u++ ) {
		switch( in.text[u] ) {
			case '$'	: pattern[v++] = '\\'	; break ;
			case '['	: brcnt++		; break ;
			case ']'	: brcnt--		; break ;
		}
		pattern[v++] = in.text[u] ;
	}
	if( brcnt != 0 ) {
		rc = ERRsyn( "[] imbalance in `implicit' pattern", in.text ) ;
	} else {
		pattern[v] = '\0' ;
		ptr = regcmp( pattern, 0 ) ;
		if( !ptr ) {
		rc = ERRsyn( "bad pattern for `implicit' declaration", in.text ) ;
			rc = FALSE ;
		} else {
			strcpy( compiled, ptr ) ;
			free( ptr ) ;
			rc = TRUE ;
		}
	}
	return rc ;

} /* REXcompile */
/*----------------------------------------------------------------------------*/
int REXmatch( pattern, match ) char *pattern, *match ; {

	char	*next	;

	next = regex( pattern, match ) ;
	return next != NULL && next == match + strlen( match ) ;

} /* REXmatch */
/*----------------------------------------------------------------------------*/
int mkIMP( imprex, type )	PCIstring imprex ; PCItype *type ; {

	char compiled[1024]	;
	int  i, rc = TRUE	;

#if DEBUG
   printf( "mkIMP : <%s>\n", imprex.text ) ;
#endif
  if( REXvalid( imprex.text ) ) {
  	if( REXcompile( imprex, compiled ) ) {
/* --	   Check that the pattern does not already exist.
   -- */
	   for( i = 0 ; i < imp__count ; i++ ) {
		if( !strcmp( imp__list[i].regexp, compiled ) ) {
			rc = ERRsyn( "pattern already used", imprex.text ) ;
			goto END ;
		}
	   }
	   if( ALLOC( imp__list, imp__count + 1, implicit ) ) {
		if( MALLOC( imp__list[imp__count].regexp, 1 + strlen( compiled ), char ) ) {
			strcpy( imp__list[imp__count].regexp, compiled ) ;
			imp__list[imp__count].type = *type ;
			imp__count++ ;
		} else goto ERROR ;
	   } else {
		ERROR : rc = ERRmem( "implicit declaration" ) ;
	   }
	}
   } else ERRsyn( "illegal pattern for `implicit' declaration", imprex.text ) ;

   END :	free( imprex.text ) ;
#if DEBUG
   printf( "mkIMP : EXIT <%d>\n", rc ) ;
#endif
   		return rc ;

} /* mkIMP */
/*----------------------------------------------------------------------------*/
void IMPfree() {
	int i ;

	for( i = 0 ; i < imp__count ; i++ ) {
		FREE( imp__list[i].regexp ) ;
	}
	FREE( imp__list ) ;
	imp__count	= 0	;
	imp__list	= NULL	;

} /* IMPfree */
/*----------------------------------------------------------------------------*/
int IMPfind( match, type ) char *match ; PCItype *type ; {

	int rc = FALSE, i ;

#if DEBUG
   printf( "IMPfind : <%s>\n", match ) ;
#endif
	for( i = 0 ; i < imp__count ; i++ ) {
		if( REXmatch( imp__list[i].regexp, match ) ) {
			*type = imp__list[i].type ;
			rc = TRUE ;
			break ;
		}
	}
	return rc ;

} /* IMPfind */
/*----------------------------------------------------------------------------*/

