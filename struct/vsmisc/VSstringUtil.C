/*
	I/STRUCT
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsstring.h"
#include "vsmiscmacros.h"

/*----------------------------------------------------------------------------*/
char *VSstrdup( string ) const char *string ; {

/*
Abstract
	Mallocs a buffer and copies input string to it.
Arguments
	const char	*string		string to copy
Returns
	A pointer to the allocated buffer if `string' != NULL (else NULL)
	and successful allocation else NULL.
*/
	register char *dup ;

	if( string ) {
		if( dup = _MALLOC( 1 + strlen( string ), char ) ) {
			strcpy( dup, string ) ;
		}
	} else dup = NULL ;

	return dup ;

} /* VSstrdup */
/*----------------------------------------------------------------------------*/
char *VSstrncpy( toStr, fromStr, nchars, truncated )

char		*toStr ;
const char	*fromStr ;
register int	nchars,
		*truncated ; {

/*
Abstract
	Copies at most 'nchars - 1' characters of `fromStr' to `toStr' and
	terminates `toStr' with a '\0'. If truncation has occurred,
	`*truncated' is set to TRUE else it is set to FALSE.
Arguments
	OUT	char		*toStr		Destination string.
	IN	const char	*fromStr	Origin string.
	IN	int		nchars		Size of `toStr'.
	OUT	int		*truncated	TRUE/FALSE.
Returns
	`toStr'.
Note
	`toStr' must handle at least `nchars' characters (including the space
	for the trailing '\0' ).
*/

	if( !fromStr && nchars ) {
		*toStr = '\0' ;
		truncated = 0 ;
	} else {
		nchars-- ;
		strncpy( toStr, fromStr, nchars )[nchars] = '\0' ;
		*truncated = strlen( fromStr ) > nchars ;
	}

	return toStr ;

} /* VSstrncpy */
/*----------------------------------------------------------------------------*/
void VSdumpString( s ) const char *s ; {
	int i, j ;

	j = strlen( s ) ;
	for( i = 0 ; i < j ; i++ ) {
		if( isprint( s[i] ) ) {
			printf( "%c", s[i] ) ;
		} else {
			printf( "<x%x>", s[i] ) ;
		}
	}
	printf( "\n" ) ;

} /* VSdumpString */
/*----------------------------------------------------------------------------*/
char *VSstripString( s ) register char *s ; {

/*
Abstract
	Removes the leading and trailing blanks ( ' ' ) in a string if any.
Argument
	I/O	char	*s		String to strip.
Returns
	`s'.
*/
	register char	*b,
			*e,
			*p ;

	for( b = s ; *b ; b++ ) {
		if( *b != ' ' ) { break ; }
	}

	for( e = b + strlen( b ) - 1 ; e >= b ; e-- ) {
		if( *e != ' ' ) { break ; }
	}

	for( p = s ; b <= e ; b++ ) {
		*p++ = *b ;
	}

	*p = '\0' ;

	return s ;

} /* VSstripString */
/*----------------------------------------------------------------------------*/
char *VSabbrvString( inString, nchars, outString )

const char	*inString ;
char		*outString ;
int		nchars ; {

/*
Abstract
	Copies `inString' to `outString'. If the length of `inString' is
	> to `nchars', only copies nchars - 3 characters and adds "..."
	at the end.
Arguments
	IN	char	*inString	String to abbreviate.
	IN	int	nchars		Length of `outString'.
	OUT	char	*outString	Abbreviated string.
Returns
	`outString'.
Note
	`outString' is supposed to have at least length `nchars', that is
	at least size nchars + 1.
*/

	int	l = strlen( inString ) ;

	if( nchars < 3 ) 	
		*outString = '\0' ;
	else if( l > nchars ) 
		sprintf( outString, "...%s", inString + l - nchars + 3 ) ;
	else strcpy( outString, inString ) ;

	return outString ;

} /* VSabbrvString */
/*----------------------------------------------------------------------------*/
char *VSdeleteWordAtIndex( string, index, word )

register char	*string ;
int		index ;
char		**word ; {

/*
Abstract
	Deletes a word in in a string at a specified index.
	A word is a set of non-space characters surrounded by spaces.
	Behaviour:
		- If index points to beginning of word, remove word.
		- If index points to a space, remove that space and the
		  following spaces till a word is encountered, then remove word.
		- If index points inside a word, deletes characters up to end
		  of word.
Arguments
	I/O	char	*string		String in which word must be deleted.
	IN	int	index		Index where deletion must start.
	OUT	char	**word		The deleted word (optional).
Returns
	`string'.
Note
	If `word' != NULL, `*word' will point to a dynamically allocated buffer
	containing the deleted word. It is up to the caller to free it with :
			if( *word ) free( *word ) ;
*/

	register char	*s,
			*begDel,
			*endDel ;
	char		*begWord ;

	if( index >= strlen( string ) ) goto wrapup ;

	begDel = s = string + index ;

	/*
	 * Pass through leading spaces.
	 */
	while( *s ) if( isspace( *s ) )	s++ ; else break ;
	begWord = begDel ;

	/*
	 * Now at beginning of word.
	 */
	while( *s ) if( !isspace( *s ) ) s++ ; else break ;

	endDel = s ;

	if( word ) {
		int	len = endDel - begWord ;

		if( *word = _MALLOC( len + 1, char ) ) {
			strncpy( *word, begWord, len )[len] = '\0' ;
		}
	}

	for( s = endDel ; *s ; s++ ) {
		*begDel++  = *s ;
	}
	*begDel = '\0' ;

	wrapup :
		return string ;

} /* VSdeleteWordAtIndex */
/*----------------------------------------------------------------------------*/
char *VStoLOWER_Str( sto, sfrom ) char *sto ; const char *sfrom ; {

/*
Abstract
	Translates a string into lowercase.
Arguments
	OUT	char		*sto	Destination string.
	IN	const char	*sfrom	Origin string.
Returns
	`sto'.
Note
	`sto' must have at least the size of `sfrom'
*/

	while( *sfrom ) { *sto = tolower( *sfrom ) ; sto++ ; sfrom++ ; }
	*sto = '\0' ;
	return sto ;

} /* VStoLOWER_Str */
/*----------------------------------------------------------------------------*/
char *VStoLowerStr( s ) const char *s ; {

/*
Abstract
	Translates `s' to lowercase into a dynamiccaly allocated character
	string.
Arguments
	IN	char	*s	String to convert to lowercase.
Returns
	The pointer to the allocated memory or NULL if allocation failed.
*/
	register char *dup ;

	if( dup = VSstrdup( s ) ) {
		register char *S = dup ;
		while( *S ) { *S = tolower( *S ) ; S++ ; }
	}
	return dup ;

} /* VStoLowerStr */
/*----------------------------------------------------------------------------*/
int VSstrcmpLOWER( s1, s2 ) const char *s1, *s2 ; {

/*
Abstract
	 Same as `strcmp (3C)' but not case-sensitive, i.e. both input strings
	 are converted to lowercase before comparison.
Arguments
	IN	const char	*s1	First string for comparison.
	IN	const char	*s2	Second string for comparison
Returns
	The same values as `strcmp (3C)'.
*/
	register char	*S1, *S2 ;
	int		rc ;

	rc = strcmp( S1 = VStoLowerStr( s1 ), S2 = VStoLowerStr( s2 ) ) ;
	_FREE( S1 ) ; _FREE( S2 ) ;

	return rc ; 

} /* VSstrcmpLOWER */
/*----------------------------------------------------------------------------*/
int VSfind_string_in_list( name, list, size, p_index )

const char	*name ;
const char	**list ;
int		size,
		*p_index ; {

/*
Abstract
	Finds a string into a list of strings.
Arguments
	IN	char	*string		String to find.
	IN	char	**list		List of strings.
	IN	int	size		Number of strings in `list'.
	OUT	int	*p_index	Index of found string in list or -1
					if `string' was not in list.
Returns
	`*p_index'.
*/
	int i ;

	*p_index = -1 ;
	for( i = 0 ; i < size ; i++ ) {
		if( !strcmp( name, list[i] ) ) { *p_index = i ; break ; }
	}
	return *p_index ;

} /* VSfind_string_in_list */
/*----------------------------------------------------------------------------*/
int VSstrcmpByPtrs( A, B )

const void	*A,
		*B ; {

	char	**a	= (char **) A,
		**b	= (char **) B ;
	/*
	 * Support comparison function for `VSremove_dups_in_list'.
	 */
	return strcmp( *a, *b ) ;
}
/*----------------------------------------------------------------------------*/
int VSremove_dups_in_list( msg, oldsize, oldlist, newsize, newlist )

long		*msg ;
int		oldsize,
		*newsize ;
char		**oldlist ;
char	 	***newlist ; {

/*
Abstract
	Removes the duplicate entries in a list of strings.
Arguments
	OUT	long	*msg		Completion code.
	IN	int	oldsize		Number of strings in `oldlist'.
	IN	char	**oldlist	List of strings from which dups are to
					be removed.
	OUT	int	*newsize	Size of list of strings without dups.
	OUT	char	***newlist	List of strings without dups.
Note
	- The elements `(*newlist)[i]' (0 <= i < *newsize) point to elements
	  in `oldlist', therefore a `(*newlist)[i]' points to the same memory
	  as some `oldlist[j]'.

	- `*newlist' is malloc'ed and must be freed by the caller with:
			free( *newlist ) ;

	- The order of the strings in `*newlist' may be different from that of
	  the strings in `oldlist'.

	- `*msg' will be even in case of success and odd in case of memory
	   allocation failure (in this latter case `*newsize' will be 0 and
	   `*newlist' will be NULL ).
*/
	char		**sortedList ;

	*newlist = NULL ; *newsize = 0 ;

	if( ( sortedList = _MALLOC( oldsize, char * ) ) ) {
		int	i ;

		for( i = 0 ; i < oldsize ; i++ ) {
			sortedList[i] = oldlist[i] ;
		}
		qsort( sortedList, oldsize, sizeof *sortedList, VSstrcmpByPtrs);

		if( ( *newlist = _MALLOC( oldsize, char * ) ) ) {
			char	*previous ;

			previous = "" ;

			for( i = 0 ; i < oldsize ; i++ ) {
				if( strcmp( previous, sortedList[i] ) ) {
					(*newlist)[(*newsize)++] = sortedList[i] ;
					previous = sortedList[i] ;
				}
			}
			*msg = MSSUCC ;
		} else {
			_FREE( sortedList ) ;
			*msg = EMS_E_NoDynamicMemory ;
		}
	} else {
		*msg = EMS_E_NoDynamicMemory ;
	}
	_FREE( sortedList ) ;

	return *msg & 1 ;

} /* VSremove_dups_in_list */
/*----------------------------------------------------------------------------*/
int VSfind_item_in_array( item, array, size, p_index )

int	item,
	*array,
	size,
	*p_index ; {
		
/*
Abstract
	Finds an integer in an array of integers.
Arguments
	IN	int	item		Integer to find.
	IN	int	array[]		Array of integer where `item' is to be
					looked for.
	IN	int	size		Size of array.
	OUT	int	*p_index	Index of `item' in array.
Returns
	`*p_index'.
Note
	`*p_index' is set to -1 if `item' is not found.
*/ 
	int	i ;

	*p_index = -1 ;
	for( i = 0 ; i < size ; i++ ) {
		if( item == array[i] ) { *p_index = i ; break ; }
	}
	return *p_index ;

} /* VSfind_item_in_array */
/*----------------------------------------------------------------------------*/
char **VSallocList( nbStrings, stringSize )

int		nbStrings,
		stringSize ; {

/*
Abstract
	Allocates memory for a list of strings.
Arguments
	IN	int	nbStrings	Number of strings wanted.
	IN	int	stringSize	Size for each string.
Returns
	A pointer to the allocated list of strings or NULL in case of memory
	allocation failure.
Note
	The returned pointer `char **p' must be freed by the caller with:
			VSfreeList( nbStrings, p ) ;
*/
	int		i,
			nomem = 0 ;
	register char	**list ;

	list = _CALLOC( nbStrings, char * ) ;
	if( list ) {

		for( i = 0 ; i < nbStrings ; i++ )  list[i] = NULL ;
		for( i = 0 ; i < nbStrings ; i++ ) {
			list[i] = _MALLOC( stringSize, char ) ;
			if( !list[i] ) {
				nomem = 1 ;
				break ;
			}
		}
	} else nomem = 1 ;

	if( nomem ) {
		if( list ) {
			for( i = 0 ; i < nbStrings ; i++ ) _FREE( list[i] ) ;
			_FREE( list ) ;
			list = NULL ;
		}
	}

	return list ;

} /* VSallocList */
/*----------------------------------------------------------------------------*/
void VSfreeList( size, list ) 

int	size ;
char	**list ; {

	if( list && size ) {
		int i ;
		for( i = 0 ; i < size ; i++ ) {
			_FREE( list[i] ) ;
		}
		_FREE( list ) ;
	}

} /* VSfreeList */
/*----------------------------------------------------------------------------*/
char **VScopyList( msg, inList, size, outList )

long		*msg ;
const char	**inList ;
int		size ;
char		***outList ; {

/*
Abstract
	Copies a list of strings.
Arguments
	OUT	long	*msg		Completion code.
	IN	char	**inList	List of strings to copy.
	IN	int	size		Number of strings in `inList'.
	OUT	char	***outList	Copied list of strings.
Returns
	`*outList'.
Note
	- `*outList' must be freed by the caller with :
			VSfreeList( size, outList * ) ;
	- `*outList' is NULL, and `*msg' is even in case of memory allocation
	  failure.
*/
	*msg = MSSUCC ;
	if( *outList = _CALLOC( size, char * ) ) {
		int i ;
		for( i = 0 ; i < size ; i++ ) (*outList)[i] = NULL ;
		for( i = 0 ; i < size ; i++ ) {
			if( !( (*outList)[i] = VSstrdup( inList[i] ) ) ) {
				*msg = EMS_E_NoDynamicMemory ;
				break ;
			}
		}
	} else *msg = EMS_E_NoDynamicMemory ;

	if( !( *msg & 1 ) ) {
		VSfreeList( size, *outList ) ;
		*outList = NULL ;
	}
	return *outList ;

} /* VScopyList */ 
/*----------------------------------------------------------------------------*/
int VSwordcount( string ) const char *string ; {

	/*
	 * Count words in `string'. A word is a space (blank,tab,
	 * newline)-delimited sequence of characters.
	 * Returns: the word count in `string'.
	 */
	enum {
		SPACE,
		NONSPACE
	}	previous = SPACE ;
	int	wc = 0 ;

	while( *string ) {

		if( isspace( *string ) ) {
			previous = SPACE ;
		} else {
			if( previous == SPACE ) {
				wc++ ;
				previous = NONSPACE ;
			}
		}
		
		string++ ;
	}

	return wc ;

} /* VSwordcount */
/*----------------------------------------------------------------------------*/
char *VSgetword( string, wordno, wordsize, word )

const char	*string ;	/* IN : string to get word from.	*/
int		wordno ;	/* IN : pos. of word to get, from 0 up.	*/
int		wordsize ;	/* IN : size of buffer for word.	*/
char		*word ;	{	/* OUT: word # `wordno'.		*/

	/*
	 * A word is a space (blank,tab,newline)-delimited sequence of
	 * characters. If `wordno' is negative or greater than the number of
	 * words, an empty string ("") is returned. `wordsize' must be at
	 * least 1.
	 * Returns: `word'.
	 * Example:
	 *
	 *	char	*string = "Somewhere over the rainbow" ;
	 *	char	word[10] ;
	 *
	 *	VSgetword( string, 2, word, 10 ) ; (* returns "over" *)
	 */

	enum {
		SPACE,
		NONSPACE
	}	previous = SPACE ;
	int	wc = 0 ;

	*word = '\0' ;

	while( *string ) {

		if( isspace( *string ) ) {
			previous = SPACE ;
		} else {
			if( previous == SPACE ) {
				if( wc == wordno ) {
					int	i = 0 ;
					int	wordlen = wordsize - 1 ;

					while(	   *string
						&& !isspace( *string )
						&& i < wordlen ) {
						word[i++] = *string++ ;
					}
					word[i] = '\0' ;
					break ;
				}
				wc++ ;
				previous = NONSPACE ;
			}
		}		
		string++ ;
	}
	return word ;

} /* VSgetword */
/*----------------------------------------------------------------------------*/
char *VSsubstring( instr, from, to, outsize, outstr )

const char	*instr ;	/* IN : string to get substring from.	*/
int		from,		/* IN : starting position.		*/
		to ;		/* IN : ending position.		*/
int		outsize ;	/* IN : size of `outstring'.		*/
char		*outstr ; {	/* OUT: sub-string.			*/

	/*
	 * Returns the sub-string of `instr' from `from' (0 and up) to
	 * `to' included.
	 * If `from' is negative then from = 0 is assumed, if `from' is greater
	 * than the length of `instr' then `to' is assumed to be the position
	 * of the last character in `instr'. If `from' > `to' then an empty
	 * string ("") is returned.
	 * Returns: `outstr'.
	 */

	int	i ;
	int	j ;
	int	outlen = outsize - 1 ;

	*outstr = '\0' ;
	if( from < 0 ) from = 0 ;

	for( i = from, j = 0 ; i <= to && instr[i] && j < outlen ; i++, j++ ) {
		outstr[j] = instr[i] ;
	}
	outstr[j] = '\0' ;

	return outstr ;

} /* VSsubstring */
/*----------------------------------------------------------------------------*/
int VSsubstituteString( instr, torep, bystr, times, outsz, outstr )

const char	*instr ;	/* IN : String where to substitute	*/
const char	*torep ;	/* IN : Sub-string to replace		*/
const char	*bystr ;	/* IN : Replacement sub-string		*/
int		times ;		/* IN : # of substitutions wanted	*/
int		outsz ;		/* IN : Size allocated for `outstr'	*/
char		*outstr ; {	/* OUT: Output string			*/

	/*
	 * To replace all occurrences of `torep' by `bystr' set `times' to
	 * some big number such as MAXINT.
	 * Returns: the number of substitutions actually performed, this number
	 * may be less than the number requested if the output buffer was not
	 * large enough.
	 */
	const char	*p ;
	const char	*q ;
	int		outLen	= outsz - 1 ;
	int		repLen	= strlen( torep ) ;
	int		i	= 0 ;
	int		rc	= 0 ;

	if( rc < 0 ) rc = 0 ;

	while( 1 ) {

		p = rc < times ? p = strstr( instr, torep ) : NULL ;

		if( !p ) {
			p = instr ;
			while( *p && i < outLen ) { outstr[i++] = *p++ ; }
			break ;
		}

		while( instr != p && i < outLen ) { outstr[i++] = *instr++ ; }

		q = bystr ;
		while( *q && i < outLen ) { outstr[i++] = *q++ ; }

		instr += repLen ;

		if( i >= outLen ) break ;

		rc++ ;
	}
	outstr[i] = '\0' ;

	return rc ;

} /* VSsubstituteString */
/*-FAST STRING-SEARCH ROUTINES------------------------------------------------*/
#ifdef USED

/*
	To build a fast-search structure for a small list of strings, do the 
	following :

	1) Declare a static array of type "VSstr2index", either with a "static"
	declaration or by allocating the memory. You can use automatic memory
	but the init procedure will have to be run everytime.

	2) Initialize the array by specifying the string and an index for it,
	avoid "-1" as an index. The last entry must be NULL for the string :

		static VSstr2index array[] {
			{ "string1",  0 },
			{ "string2", 12	},
			{ "string3",  9 },
			...
			{ NULL	   ,  0 }	<-- Ending NULL
		} ;

	3) Invoke "VSinitStrLink" which will return a fast-search structure
	pointer pointing to memory allocated by "VSinitStrLink", NULL will
	be returned in case of memory allocation failure :

		VSstrLink **ptr ;

		ptr = VSinitStrLink( array ) ;
		if( !ptr ) {
			(* Allocation failed *)
		}

	4) Search strings with "VSstrLinkLookUp", which will return the
	associated index if string has been found and "-1" if the string
	was not found.

		if( VSstrLinkLookUp( "string2", ptr ) != -1 ) {
			(* Found string *)
		}

	5) When the fast-search structure is no longer needed, deallocate the
	memory with "VSstrLinkFree" :

		VSstrLinkFree( ptr ) ;

	6) Sample usage

	int yourFunction( string ) char *string ; {

		static VSstr2index array[] {
			{ "string1",  0 },
			{ "string2", 12	},
			{ "string3",  9 },
			...
			{ NULL	   ,  0 }
		} ;
		static VSstrLink **ptr = NULL ;
		int index ;
	
		if( !ptr ) {
			ptr = VSinitStrLink( array ) ;
			if( !ptr ) {
				printf( "Memory allocation failure\n" ) ;
				return 0 ;
			}
		}
		index = VSstrLinkLookUp( string, ptr ) ;

		switch( index ) {
			case -1 : <action for string not found>
			case  0 : <action for "string3">
			case 12 : <action for "string2">
			case  9 : <action for "string3">
			...
		}
		return 1 ;

	} (* END yourFunction *)

	Note that in the above example, "ptr" is not freed : it is supposed
	that it will be used for the duration of the program.

	7) Statistics
	Here is a comparison of the performances of this method compared with
	a linear search, a binary search and a hash-table search for 20 strings,
	the time of the linear search has been normalized to 100.

	Linear		100
	Hash-table	 87
	Binary		 99
	This method	 37

	For large quantity of strings, binary and hash-table search are most
	preferable.
*/
#define VS_K_MAX_ASCII_CHARS	128

VSstrLink **VSinitStrLink( list ) VSstr2index *list ; {

	register VSstrLink	**lkArray ;
	VSstrLink		*c,
				*next,
				*new ;
	register VSstr2index	*l ;
	register char		first ;

	if( !( lkArray = (VSstrLink **) calloc( VS_K_MAX_ASCII_CHARS,
						sizeof *lkArray ) ) )
			return NULL ;

	for( l = list ; ( first = *l->string ) ; l++ ) {
		if( !( new = (VSstrLink *) malloc( sizeof *new ) ) ) {
		}
		new->entry = l ;
		if( c = lkArray[first] ) {
			next		= c->next ;
			c->next		= new ;
			new->next	= next ;
		} else {
			new->next	= NULL ;
			lkArray[first]	= new ;
		}
	}
	return lkArray ;

} /* VSinitStrLink */
/*----------------------------------------------------------------------------*/
int VSstrLinkLookUp( list, s ) register VSstrLink **list ; register char *s ; {

	register VSstrLink *c ;

	c = list[*s] ;
	while( c ) {
		if( !strcmp( s, c->entry->string ) ) {
			return c->entry->index ;
		}
		c = c->next ;
	}
	return -1 ;

} /* VSstrLinkLookUp */
/*----------------------------------------------------------------------------*/
void VSstrLinkFree( list ) register VSstrLink **list ; {

	register int		i ;
	register VSstrLink	*p,
				*n ;
	if( list ) {
		for( i = 0 ; i < VS_K_MAX_ASCII_CHARS ; i++ ) {
			p = list[i] ;
			while( p ) {
				n	= p->next ;
				_FREE( p ) ;
				p	= n ;
			}
		}
		_FREE( list ) ;
	}
	
} /* VSstrLinkFree */
/*----------------------------------------------------------------------------*/
#endif /* USED */
