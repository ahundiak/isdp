#include <ctype.h>
#include <malloc.h>
#define FALSE 0
#define NULL  0
#define TRUE  1

/* regular expression stuff copied from Alain */

int AScheckRE( in, out ) register char *in, *out ; {

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
			case '|'	: 
			case '['	:
			case ']'	:
			case '-'	:
			case '_'	:
			case '\\'	: *out++ = *in ; break ;
			default		: if( isalnum( *in ) ) {
						*out++ = *in ; break ;
					} else {
						return FALSE ;
					}
		}
		in++ ;
	}
	*out = '\0' ;

	return TRUE ;

} /* AScheckRE */
/*----------------------------------------------------------------------------*/
/* NB ASmatchREGEXP modify pat .....					      */


int ASmatchREGEXP( pat, sub ) char *pat, *sub ; {

	char	*re,
		*last ;
	int	rc = FALSE ;
	extern char *__loc1;
	char *regcmp(),*regex(),*strchr();
        char    *or,*b;

         
   while(1)
     {
        or = strchr(pat,'|');
	if(or != NULL) *or = '\0';

	/* remove leading blank */
	while(*pat == ' ') pat++;

	/* remove trailing blank */
	b= pat + strlen(pat) -1;
	while(*b == ' ') {*b = '\0';b--;}

	re = regcmp( pat, NULL ) ;
	if( re )
	 {
	  if( sub )
	   {
	    last = regex( re, sub, NULL ) ;
	    if( last && !*last && __loc1 == sub ) rc = TRUE ;
	    free( re ) ;
	    if(rc) break;
	   } 
	  else
	   {
	    /* Just want checking, not matching.  */
	    rc = TRUE ;
	    free( re ) ;
	   }
	 }
	else
         {
	  /* bad regular expression */
	  rc = FALSE;
	  break;
         }

	if(or) 
	 {
	  pat = or+1;
	 }
	else break;
     }

     return rc ;

} /*  ASmatchREGEXP */
/*----------------------------------------------------------------------------*/
int ASmatchRE( pat, sub ) char *pat, *sub ; {

	/*
	 * See whether input subject `sub' matches pattern `pat'. If `sub' is
	 * NULL, just checks that `pat' is a valid pattern.
	 */

	char	*PAT ;
	int	rc ;

	rc = FALSE ;

	if( PAT = malloc( 2 * strlen( pat ) + 1 ) ) {

		if( AScheckRE( pat, PAT ) )  {
			rc = ASmatchREGEXP( PAT, sub ) ;
		} else {
			/*
			 * Unallowed character in regular expression.
			 */
			rc = FALSE ;
		}
	        free( PAT ) ;
	}
	return rc ;

} /* ASmatchRE */
/*----------------------------------------------------------------------------*/


