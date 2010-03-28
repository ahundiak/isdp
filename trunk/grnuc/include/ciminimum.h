/* -- Minimum include file for CI macros.
   -- */
#ifndef ciminimum_include
#	define ciminimum_include

#	ifndef cieveryone_include

#		include "exdef.h"	/* For IGE response types	*/
#		include	"OMlimits.h"	/*				*/
#		include "OMextern.h"
#		include	"OMminimum.h"	/* Typedefs			*/
#		include	"igetypedef.h"	/* Typedefs			*/
#		include	"igrtypedef.h"	/* Typedefs			*/
#		include	"gr.h"		/* GRid, module environment	*/
#		include "lcdef.h"	/* Constants for locate function*/
#		include "griodef.h"	/* Masks for event functions	*/
#          if defined (sun)
#               include "sunlimits.h"   /* Sets PATH_MAX for Sun users  */
#          endif

#	endif

#ifndef NULL
#	define NULL		0
#endif
#ifndef TRUE
#	define TRUE		1
#endif
#ifndef FALSE
#	define FALSE  		0
#endif

#define CI_NULL		((char *)0)		/* we need it... */

/* miscellaneous	*/
#define	itoa(n)		ntoa(n)
#define	ftoa(n)		ntoa(n)
#define MY_ID		my_id()
#define SENDER_ID	sender_id()

#endif
