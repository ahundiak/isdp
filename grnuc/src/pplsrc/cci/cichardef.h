#ifndef CICHARDEF_INCLUDE
#	define CICHARDEF_INCLUDE

#	define BLANK		' '
#	define BACKSPACE	'\b'
#	define FORMFEED		'\f'
#	define NEWLINE		'\n'
#	define CR		'\r'
#	define HTAB		'\t'
#	define VTAB		'\v'
#	define BACKSLASH	'\\'
#	define EOSTR		'\0'
#	define XREF		'_'
#	define OPTION		'-'
#	define SLASH		'/'
#	define DOT		'.'
#	define USRFUN		'~'
#	define SYSFUN		'!'
/* -- The following characters will be at the 1st position in the identifiers of
      auxilliary variables, register  variables, constants, arguments, typeinit,
      user operators,  labels, enum members, enum tags, type names, union/struct
      tags, so they may  be entered in the  hash table  without conflicting with
      user declared variables. They must differ from each other.
   -- */
#	define AUXVAR		'@'
#	define REGVAR		'^'
#	define CSTVAR		'#'
#	define ARGVAR		'?'
#	define INIVAR		'='
#	define OPRVAR		'>'

#	define IS_EMPTY( s )	( *(s) == EOSTR )
#endif

