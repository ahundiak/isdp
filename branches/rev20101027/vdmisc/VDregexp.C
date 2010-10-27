/*
	I/VDS	Copy
*/
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <pw.h>		/* For regcmp() and regex()	*/
#define TRUE	1
#define FALSE	0

/*
 * This global defined in libPW.a and documented in UNIX's regcmp(3) is not
 * in any include file of /usr/include ...
 */
extern char	*__loc1 ;
/*----------------------------------------------------------------------------*/
int VD_checkRE( in, out ) const char *in ; char *out ; {

	/*
	 * Checks that the input regular expression pattern is made of
	 * alphanum characters as well as -, [, ], *, ?, \.
	 * At the same time, translate '?' to '.' and '*' to '.*' so that
	 * the REs follow the shell's RE convention for files.
	 */

	while( *in ) {
		switch( *in ) {
			case '*'	: *out++ = '.' ; *out++ = '*' ; break ;
			case '?'	: *out++ = '.' ; break ;
			case '['	:
			case ']'	:
			case '-'	:
			case '\\'	: *out++ = *in ; break ;
			case '_'	: *out++ = *in ; break ;
			default		: if( isprint( *in ) ) {
						*out++ = *in ; break ;
					} else {
						/*
						 * Invalid character.
						 */
						return FALSE ;
					}
		}
		in++ ;
	}
	*out = '\0' ;

	return TRUE ;

} /* VD_checkRE */
/*----------------------------------------------------------------------------*/
int VD_matchREGEXP( pat, sub ) const char *pat, *sub ; {

	char	*re,
		*last ;
	int	rc = FALSE ;

	re = regcmp( pat, NULL ) ;
	if( re ) {
		if( sub ) {
			last = regex( re, sub, NULL ) ;
			if( last && !*last && __loc1 == sub ) {
				rc = TRUE ;
			} /* Else : no match or partial match */
		} else {
			/*
			 * Just want checking, not matching.
			 */
			rc = TRUE ;
		}
		free( re ) ;

	} /* Else : bad regular expression */

	return rc ;

} /*  VD_matchREGEXP */
/*----------------------------------------------------------------------------*/
int VD_matchRE( pat, sub ) const char *pat, *sub ; {

	/*
	 * See whether input subject `sub' matches pattern `pat'. If `sub' is
	 * NULL, just checks that `pat' is a valid pattern.
	 */

	char	*PAT ;
	int	rc ;

	rc = FALSE ;

	if( PAT = malloc( 2 * strlen( pat ) + 1 ) ) {

		if( VD_checkRE( pat, PAT ) )  {
			rc = VD_matchREGEXP( PAT, sub ) ;
		} else {
			/*
			 * Unallowed character in regular expression.
			 */
			rc = FALSE ;
		}
		free( PAT ) ;
	}
	return rc ;

} /* VD_matchRE */
/*----------------------------------------------------------------------------*/

