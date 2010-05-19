/*
	I/VDS	Copy.

	Global variables containing message numbers.
	If a message number id #defined in VDmsg.h as

			VD_X_<...>	(where X = S,I,W,E,F)

	then the corresponding variable is

			VD_gX_<...>	

	File dependency: VDmsg.h and SMmsg.h,
			 only if VD_DECLARE_EXTERNS is #defined.
*/
#ifndef v_globalmsg_include
#	define v_globalmsg_include

#	ifdef VD_DECLARE_EXTERNS
#		define EXTRNLONG	long
#		define DCLASG( x )	= (x)
#	else
#		define EXTRNLONG	extern long
#		define DCLASG( x )
#	endif

EXTRNLONG

