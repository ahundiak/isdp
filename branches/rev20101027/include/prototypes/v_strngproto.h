/*
	I/VDS	Copy.
*/

#ifndef v_strngproto_include
#	define v_strngproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

/*+f
Function VD_strdup

Abstract
	Mallocs a buffer and copies the input string to it.
Arguments
	const char	*string		String to copy.
Returns
	A pointer to the allocated buffer if `string' != NULL (else NULL)
	and successful allocation else NULL.
Keywords
	#duplicate#memory#string
-f*/
extern char
*VD_strdup		__((	const char	*string	)) ;

/*+f
Function VD_strncpy

Abstract
	Copies at most 'size - 1' characters of `fromStr' to `toStr' and
	terminates `toStr' with a '\0'. If truncation has occurred,
	`*truncated' is set to TRUE else it is set to FALSE.
Arguments
	OUT	char		*toStr		Destination string.
	IN	const char	*fromStr	Origin string.
	IN	int		size		Size of `toStr'.
	OUT	int		*truncated	TRUE/FALSE.
Returns
	`toStr'.
Keywords
	#copy#string#
Note
	`toStr' must handle at least `size' characters (including the space
	for the trailing '\0' ).
-f*/
extern char
*VD_strncpy		__((	char		*toStr,
				const char	*frStr,
				int		nchars,
				int		*truncated )) ;

/*+f
Function VD_strncat

Abstract
	Concatenates at most 'len - strlen(toStr) - 1' characters of 
	'fromStr' onto the end of 'toStr' and terminates `toStr' with a '\0'. 
	If truncation has occurred, `*truncated' is set to TRUE else it is 
	set to FALSE.
Arguments
	OUT	char		*toStr		Destination string.
	IN	const char	*fromStr	Origin string.
	IN	int		len		Size of `toStr'.
	OUT	int		*truncated	TRUE/FALSE.
Returns
	`toStr'.
Note
	`toStr' must handle at least `len' characters (including the space
	for the trailing '\0' ).
-f*/
extern char *
VD_strncat		__(( 	char 		*toStr, 
				const char 	*fromStr, 
				int	len, 
				int 	*truncated ));
/*+f
Function VD_stripString

Abstract
	Removes the leading and trailing blanks ( ' ' ) in a string if any.
Argument
	I/O	char	*string		String to strip.
Returns
	`string'.
Keywords
	#blank#string#strip#
-f*/
extern char
*VD_stripString		__((	char		*string	)) ;

/*+f
Function VD_abbrvString

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
Keywords
	#abbreviate#string#
Note
	`outString' is supposed to have at least length `nchars', that is
	at least size nchars + 1.
-f*/
extern char
*VD_abbrvString		__((	const char	*inString,
				int		nchars,
				char		*outString )) ;
/*+f
Function VD_deleteWordAtIndex

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
Keywords
	#delete#string#word#
Note
	If `word' != NULL, `*word' will point to a dynamically allocated buffer
	containing the deleted word. It is up to the caller to free it with :
			if( *word ) free( *word ) ;
-f*/
extern char
*VD_deleteWordAtIndex	__((	char		*string,
				int		index,
				char		**word )) ;

/*+f
Function VD_toLOWER_Str

Abstract
	Translates a string into lowercase.
Arguments
	OUT	char		*toStr		Destination string.
	IN	const char	*fromStr	Origin string.
Returns
	`toStr'.
Keywords
	#lowercase#string#
Note
	`toStr' must have at least the size of `fromStr'
-f*/
extern char
*VD_toLOWER_Str		__((	char		*toStr,
				const char	*frStr )) ;

/*+f
Function VD_toLowerStr

Abstract
	Translates `string' to lowercase into a dynamically allocated character
	string.
Arguments
	IN	char	*string	String to convert to lowercase.
Returns
	The pointer to the allocated memory or NULL if allocation failed.
Keywords
	#lowercase#memory#string#
Note
	The memory allocated must be released by the caller with `free'.
-f*/
extern char
*VD_toLowerStr		__((	const char	*string )) ;

/*+f
Function VD_getword

Abstract
	Returns the n-th word in a string.  A word is a space ( blank, tab,
	newline )-delimited sequence of characters.
Arguments
	IN	const char	*string	 String to get word from.
	IN	int		wordno	 Position of word to get, from 0 up.
	IN	int		wordsize Size of buffer for word.
	OUT	char		*word	 Word # `wordno'
Note
	If `wordno' is negative or greater than the number of words in `string',
	an empty string ("") is returned. `wordsize' must at least be 1.
Returns
	`word'.
Keywords
	#extract#string#word#
Example
	const char	*string = "Somewhere over the rainbow" ;
	char		word[10] ;
	VD_getword( string, 2, word, 10 ) ;  (* returns "over" *)
-f*/
extern char
*VD_getword		__((	const char	*string,
				int		wordno,
				int		wordsize,
				char		*word )) ;

/*+f
Function VD_substring

Abstract
	Returns a part of a string between a start position and an end position.
Arguments
	IN	const char	*instr	String to get sub-string from.
	IN	int		frPos	Start position (0 and up)
	IN	int		toPos	End position.
	IN	int		outsize	Size of output sub-string.
	OUT	char		*outstr	Sub-string.
Returns
	`outstr'.
Keywords
	#string#sub-string#extract#
Notes
	If `frPos' is negative then `frPos = 0' is assumed, if `frPos' is
	greater than the length of `instr' then `toPos' is assumed to be the
	position of the last character in `instr'. If `frPos' > `toPos' then an
	empty then an empty string ("") is returned.
-f*/
extern char
*VD_substring		__((	const char	*instr,
				int		frPos,
				int		toPos,
				int		outsize,
				char		*outstr )) ;

/*+f
Function VD_allocList

Abstract
	Allocates memory for a list of strings.
Arguments
	IN	int	nbStrings	Number of strings wanted.
	IN	int	stringSize	Size for each string.
Returns
	A pointer to the allocated list of strings or NULL in case of memory
	allocation failure.
Keywords
	#list#memory#string#
Note
	The returned pointer `char **p' must be freed by the caller with:
			VD_freeList( nbStrings, p ) ;
-f*/
extern char
**VD_allocList		__((	int		nbStrings,
				int		stringSize )) ;

/*+f
Function VD_copyList

Abstract
	Copies a list of strings.
Arguments
	OUT	long	*msg		Completion code.
	IN	char	**inList	List of strings to copy.
	IN	int	size		Number of strings in `inList'.
	OUT	char	***outList	Copied list of strings.
Returns
	`*outList'.
Keywords
	#copy#list#string#
Note
	- `*outList' must be freed by the caller with :
			VD_freeList( size, outList * ) ;
	- `*outList' is NULL, and `*msg' is even in case of memory allocation
	  failure.
-f*/
extern char
**VD_copyList		__((	long		*msg,
				char		**inList,
				int		size,
				char		***outList )) ;

/*+f
Function VD_wordcount

Abstract
	Counts the words in a string. A word is a space ( blank, tab,
	newline )-delimited sequence of characters.
Arguments
	IN	const char	*string		Input string.
Returns
	The word count in `string'.
Keywords
	#count#string#word#
-f*/
extern int
VD_wordcount		__((	const char	*string )) ;

/*+f
Function VD_strcmpLOWER

Abstract
	 Same as `strcmp (3C)' but not case-sensitive, i.e. both input strings
	 are converted to lowercase before comparison.
Arguments
	IN	const char	*s1	First string for comparison.
	IN	const char	*s2	Second string for comparison
Returns
	The same values as `strcmp (3C)'.
Keywords
	#comparison#lowercase#string#
-f*/
extern int
VD_strcmpLOWER		__((	const char	*s1,
				const char	*s2 )) ;

extern int
VD_strcmpByPtrs		__((	const void	*pp_char1,
				const void	*pp_char2 )) ;

/*+f
Function VD_find_string_in_list

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
Keywords
	#list#search#string#
-f*/
extern int
VD_find_string_in_list	__((	const char	*string,
				char		**list,
				int		size,
				int		*p_index )) ;

/*+f
Function VD_remove_dups_in_list

Abstract
	Removes the duplicate entries in a list of strings.
Arguments
	OUT	long	*msg		Completion code.
	IN	int	oldsize		Number of strings in `oldlist'.
	IN	char	**oldlist	List of strings from which dups are to
					be removed.
	OUT	int	*newsize	Size of list of strings without dups.
	OUT	char	***newlist	List of strings without dups.
Keywords
	#list#delete#string#duplicate#
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
-f*/
extern int
VD_remove_dups_in_list	__((	long		*msg,
				int		oldsize,
				char		**oldlist,
				int		*newsize,
				char		***newlist )) ;

extern int
VD_checkRE		__((	const char	*edRegexp,
				char		*kshRegexp )) ;

extern int
VD_matchREGEXP		__((	const char	*edRegexp,
				const char	*subject )) ;

/*+f
Function VD_matchRE

Abstract
	Checks if a string matches a regular expression.
	See whether input subject `sub' matches pattern `pat'. If `sub' is
	NULL, just checks that `pat' is a valid pattern.
Arguments
	IN	const char	*kshRegexp	Regular expression.
	IN	const char	*subject	String to test.
Returns
	TRUE or FALSE.
Keywords
	#regular expression#match#string#
Note
	The syntax for regular expressions is that of the UNIX shell.
	If `subject' is NULL, then the function only checks that the regular
	expression has a valid syntax.
-f*/
extern int
VD_matchRE		__((	const char	*kshRegexp,
				const char	*subject )) ;

/*+f
Function VD_substituteString

Abstract
	Replaces a sub-string in a string by another sub-string.
Arguments
	IN	const char	*instr	String where to substitute.
	IN	const char	*torep	Sub-string to replace.
	IN	const char	*bystr	Replacement sub-string.
	IN	int		times	# of substitutions wanted.
	IN	int		outsz	Size allocated for `outstr'.
	OUT	char		*outstr	Output string.
Returns
	The number of substitutions actually performed, this number may be less
	than the number requested if the output buffer was not large enough.
Keywords
	#string#substitute#
Note
	To replace all occurrences of `torep' by `bystr' set `times' to some big
	number such as MAXINT.
-f*/
extern int
VD_substituteString	__((	const char	*instr,
				const char	*torep,
				const char	*bystr,
				int		times,
				int		outsz,
				char		*outstr )) ;

extern void
VD_dumpString		__((	const char	*string	)) ;

/*+f
Function VD_freeList

Abstract
	Releases the memory allocated for a list of strings.
Arguments
	IN	int	size	Number of strings in list.
	IN	char	**list	List of strings
Keywords
	#list#memory#release#string#
Note
	Some of the 'list[i]', 0 <= i <= size-1, may be NULL.
-f*/
extern void
VD_freeList		__((	int		size,
				char		**list )) ;

/*+f
Function VD_memdup

Abstract
	Mallocs a buffer and copies the input buffer to it.
Arguments
	void		*buffer		Buffer to copy
	unsigned	nbytes		Size in bytes of input buffer.
Returns
	A pointer to the allocated buffer if success else NULL.
Keywords
	#duplicate#memory#
-f*/
extern void
*VD_memdup		__((	void		*buffer,
				unsigned	nbytes	)) ;


#endif /* v_strngproto_include */
