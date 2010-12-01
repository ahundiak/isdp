/* Do not alter this SPC information: $Revision: 1.4.21.1 $ */
#ifndef RISPATH_H
#define RISPATH_H

#if defined(unix)
# define PATH_CHAR		'/'
# define PATH_CHAR_STR	"/"
#elif defined(vms)
# define PATH_CHAR		'.'
# define PATH_CHAR_STR	"."
#elif defined(WIN32) || defined(DOS)
# define PATH_CHAR		'\\'
# define PATH_CHAR_STR	"\\"
#endif

#if defined(__cpu_c100__)
#define	SYSTEM_NAME	"c100"
#endif

#if defined(__cpu_c400__)
#define	SYSTEM_NAME	"c400"
#endif

#if defined(sunx)
#define	SYSTEM_NAME	"sun"
#endif

#if defined(sco)
#define	SYSTEM_NAME	"sco"
#endif

#if defined(__Sol2__)
#define SYSTEM_NAME	"Sol2"
#endif

#if defined(Soli) || defined(__i386)
#define SYSTEM_NAME	"Soli"
#endif

#if defined(__hpux__)
#define	SYSTEM_NAME	"hpux"
#endif

#if defined(WIN32)
#define	SYSTEM_NAME	"nt"
#endif

#if defined(DOS)
#define	SYSTEM_NAME	"dos"
#endif

#endif
