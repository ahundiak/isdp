/*
	I/STRUCT
*/
#ifndef vsgraphicenv_include
#	define	vsgraphicenv_include

#if defined(X11)
#	include <X11/Xlib.h>
#endif


#if defined(ENV5)
	typedef int	VSgrEnvEvent ;
	typedef int	VSgrEnvWindow ;
#elif defined(X11)
	typedef XEvent	VSgrEnvEvent ;
	typedef Window	VSgrEnvWindow ;
#else
#	omerror "Windowing system switches must be set!"
#endif

#endif
