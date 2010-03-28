#ifndef FCIDEF_INCLUDE
#	define FCIDEF_INCLUDE
#	include <unistd.h>

/* -- Arguments to access (2C) function.
   -- */
#	define IS_EXEC( f )	( access( (f), X_OK ) == 0 )
#	define IS_WRIT( f )	( access( (f), W_OK ) == 0 )
#	define IS_READ( f )	( access( (f), R_OK ) == 0 )
#	define IS_HERE( f )	( access( (f), F_OK ) == 0 )

/* -- Extensions for source, compiled code, externals name list, external
      references, and executable files.
   -- */
#	define SRC_EXT		'u'
#	define CMP_EXT		'e'
#	define NML_EXT		'n'
#	define XRF_EXT		'X'
#	define EXC_EXT		'e'

/* -- Default names for source, compiled code, externals name list, external
      references, and executable files.
   -- */
#	define SRC_DEF		"a.in.u"
#	define CMP_DEF		"a.out.E"
#	define NML_DEF		"a.out.n"
#	define XRF_DEF		"a.out.X"
#	define EXC_DEF		"a.out.e"

#	define CHGEXT( f, ext ) *( strchr( (f), EOSTR ) - 1 ) = (ext)

#endif

