/* Do not alter this SPC information: $Revision: 1.2.30.1 $ */
/*
**	NAME:							arcgnerc.c
**	AUTHORS:						John Gwyer
**	CREATION DATE:					7/91
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**  AUTHORS:                        Sreedhar Barakam
**  REVISION DATE:                  2/92
**  ABSTRACT:          				All ARCH_functions to take three parameters,
**                                  just to make it uniform.
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <stdarg.h>
#include "arch.h"


/*
**	DEFINES
*/
#define INTARG 100
#define CHARARG 101

/*
**	FUNCTION PROTOTYPES
*/
#define arcgnerc_c
#include "arcgnerc.prt"
#include "arcerrcd.prt"
#include "sys.prt"
#if defined (sun) || defined(__Sol2__) || defined(__hpux__)
#include "arcswap.prt"
#endif

#ifdef vms
# include "arcdcxvx.prt"
# include "arcfcxvx.prt"
# include "arcdvxcx.prt"
# include "arcfvxcx.prt"
#endif

/*
**	VARIABLES
*/
#if defined(__clipper__)

	/*
	** Since the network is always expected to contain 'clipper'
	** data types, then, when we are already on the clipper, there
	** will be nothing to transform.
	*/

	/*
	** first array is for receiving from the network
	** second array is for sending to the network
	*/

static int (*ARCH_funcs [2] [MAX_CONVERSION_TYPES])( arc_s *, void *, int) =
{
	{ 0, 							/* UNKNOWN TYPE					*/
	  0, 							/* CONVERT_CHARACTER			*/
	  0, 							/* CONVERT_DATA					*/
	  0, 							/* CONVERT_STRING				*/
	  0, 							/* CONVERT_INTEGER				*/
	  0, 							/* CONVERT_SMALLINT				*/
	  0, 							/* CONVERT_FLOAT				*/
	  0,							/* CONVERT_DOUBLE				*/
	},
	{ 0, 							/* UNKNOWN TYPE					*/
	  0, 							/* CONVERT_CHARACTER			*/
	  0, 							/* CONVERT_DATA					*/
	  0, 							/* CONVERT_STRING				*/
	  0,							/* CONVERT_INTEGER				*/
	  0,							/* CONVERT_SMALLINT				*/
	  0,							/* CONVERT_FLOAT				*/
	  0,							/* CONVERT_DOUBLE				*/
	}
};
#endif /* __clipper__ */
 
#if defined(__Sol2__) || defined(sun) || defined(__hpux__)
	/*
	** first array is for receiving from the network
	** second array is for sending to the network
	*/

static int (*ARCH_funcs [2] [MAX_CONVERSION_TYPES])(arc_s *, void *, int) =
{
	{ 0, 							/* UNKNOWN TYPE					*/
	  0, 							/* CONVERT_CHARACTER			*/
	  0, 							/* CONVERT_DATA					*/
	  0, 							/* CONVERT_STRING				*/
	  (int (*)())ARC_int_swap_bytes,			/* CONVERT_INTEGER				*/
	  (int (*)())ARC_short_swap_bytes,			/* CONVERT_SMALLINT				*/
	  (int (*)())ARC_float_swap_bytes,			/* CONVERT_REAL					*/
	  (int (*)())ARC_double_swap_bytes,		/* CONVERT_DOUBLE				*/
	},
	{ 0, 							/* UNKNOWN TYPE					*/
	  0, 							/* CONVERT_CHARACTER			*/
	  0, 							/* CONVERT_DATA					*/
	  0, 							/* CONVERT_STRING				*/
	  (int (*)())ARC_int_swap_bytes,			/* CONVERT_INTEGER				*/
	  (int (*)())ARC_short_swap_bytes,			/* CONVERT_SMALLINT				*/
	  (int (*)())ARC_float_swap_bytes,			/* CONVERT_REAL					*/
	  (int (*)())ARC_double_swap_bytes,		/* CONVERT_DOUBLE				*/
	}
};
#endif /* Sun, Solaris SPARC and HP-UX */

#if defined(vms)

	/*
	** first array is for receiving from the network
	** second array is for sending to the network
	*/

static int (*ARCH_funcs [2] [MAX_CONVERSION_TYPES])(arc_s *, void *, int) =
{
	{ 0, 							/* UNKNOWN TYPE					*/
	  0, 							/* CONVERT_CHARACTER			*/
	  0, 							/* CONVERT_DATA					*/
	  0, 							/* CONVERT_STRING				*/
	  0,							/* CONVERT_INTEGER				*/
	  0,							/* CONVERT_SMALLINT				*/
	  ARC_clip_to_vax_float,		/* CONVERT_REAL					*/
	  ARC_clip_to_vax_double,		/* CONVERT_DOUBLE				*/
	},
	{ 0, 							/* UNKNOWN TYPE					*/
	  0, 							/* CONVERT_CHARACTER			*/
	  0, 							/* CONVERT_DATA					*/
	  0, 							/* CONVERT_STRING				*/
	  0,							/* CONVERT_INTEGER				*/
	  0,							/* CONVERT_SMALLINT				*/
	  ARC_vax_to_clip_float,		/* CONVERT_REAL					*/
	  ARC_vax_to_clip_double,	/* CONVERT_DOUBLE				*/
	}
};
#endif /* vms */

#if defined(WIN32) || defined(Soli)

	/*
	** Since the network is always expected to contain 'clipper'
	** data types and there is no difference between Intel x86 and clipper,
	** there will be nothing to transform.
	*/

	/*
	** first array is for receiving from the network
	** second array is for sending to the network
	*/

static int (*ARCH_funcs [2] [MAX_CONVERSION_TYPES])( arc_s *, void *, int) =
{
	{ 0, 							/* UNKNOWN TYPE					*/
	  0, 							/* CONVERT_CHARACTER			*/
	  0, 							/* CONVERT_DATA					*/
	  0, 							/* CONVERT_STRING				*/
	  0, 							/* CONVERT_INTEGER				*/
	  0, 							/* CONVERT_SMALLINT				*/
	  0, 							/* CONVERT_FLOAT				*/
	  0,							/* CONVERT_DOUBLE				*/
	},
	{ 0, 							/* UNKNOWN TYPE					*/
	  0, 							/* CONVERT_CHARACTER			*/
	  0, 							/* CONVERT_DATA					*/
	  0, 							/* CONVERT_STRING				*/
	  0,							/* CONVERT_INTEGER				*/
	  0,							/* CONVERT_SMALLINT				*/
	  0,							/* CONVERT_FLOAT				*/
	  0,							/* CONVERT_DOUBLE				*/
	}
};
#endif /* WIN32 */

#if defined(DOS)

	/*
	** Since the network is always expected to contain 'clipper'
	** data types and there is no difference between Intel x86 and clipper,
	** there will be nothing to transform.
	*/

	/*
	** first array is for receiving from the network
	** second array is for sending to the network
	*/

static int (*ARCH_funcs [2] [MAX_CONVERSION_TYPES])( arc_s *, void *, int) =
{
	{ 0, 							/* UNKNOWN TYPE					*/
	  0, 							/* CONVERT_CHARACTER			*/
	  0, 							/* CONVERT_DATA					*/
	  0, 							/* CONVERT_STRING				*/
	  0, 							/* CONVERT_INTEGER				*/
	  0, 							/* CONVERT_SMALLINT				*/
	  0, 							/* CONVERT_FLOAT				*/
	  0,							/* CONVERT_DOUBLE				*/
	},
	{ 0, 							/* UNKNOWN TYPE					*/
	  0, 							/* CONVERT_CHARACTER			*/
	  0, 							/* CONVERT_DATA					*/
	  0, 							/* CONVERT_STRING				*/
	  0,							/* CONVERT_INTEGER				*/
	  0,							/* CONVERT_SMALLINT				*/
	  0,							/* CONVERT_FLOAT				*/
	  0,							/* CONVERT_DOUBLE				*/
	}
};
#endif /* DOS */

#if defined(sco)

	/*
	** Since the network is always expected to contain 'clipper'
	** data types and there is no difference between intel x86 and clipper,
	** there will be nothing to transform.
	*/

	/*
	** first array is for receiving from the network
	** second array is for sending to the network
	*/

static int (*ARCH_funcs [2] [MAX_CONVERSION_TYPES])( arc_s *, void *, int) =
{
	{ 0, 							/* UNKNOWN TYPE					*/
	  0, 							/* CONVERT_CHARACTER			*/
	  0, 							/* CONVERT_DATA					*/
	  0, 							/* CONVERT_STRING				*/
	  0, 							/* CONVERT_INTEGER				*/
	  0, 							/* CONVERT_SMALLINT				*/
	  0, 							/* CONVERT_FLOAT				*/
	  0,							/* CONVERT_DOUBLE				*/
	},
	{ 0, 							/* UNKNOWN TYPE					*/
	  0, 							/* CONVERT_CHARACTER			*/
	  0, 							/* CONVERT_DATA					*/
	  0, 							/* CONVERT_STRING				*/
	  0,							/* CONVERT_INTEGER				*/
	  0,							/* CONVERT_SMALLINT				*/
	  0,							/* CONVERT_FLOAT				*/
	  0,							/* CONVERT_DOUBLE				*/
	}
};
#endif /* sco */

/*
**	FUNCTIONS
*/


/******************************************************************************/

/* We wish to set the value of the conversion_flags.  */

extern void ARC_set_conversion_flags(
	arc_s * arc)
{
	arc->conversion_flags = 0;

	ARC_DBG(("ARC_set_conversion_flags arc = %0x%x\n",arc));

	ARC_DBG(("remote_arch = %d local_arch = %d\n",arc->remote_arch,LOCAL_ARCH));

#if defined(__clipper__)
	/*
	** The network should always be sending clipper data types,
	** therefore, there are no differences.
	*/
#elif defined (sun) || defined(__Sol2__) || defined(__hpux__)
	if (arc->remote_arch != LOCAL_ARCH)
	{
		arc->conversion_flags = ARC_SHORT | ARC_INTEGER | ARC_FLOAT | ARC_DOUBLE;
	}
#elif defined(vms)
	if (arc->remote_arch != LOCAL_ARCH)
	{
		arc->conversion_flags = ARC_FLOAT | ARC_DOUBLE;
	}
#elif defined(WIN32) || defined(Soli) || defined(DOS) || defined(sco)
	/*
	** The network should always be sending clipper data types,
	** therefore, there are no differences.
	*/
#else
THIS IS AN ERROR - WHAT TYPE OF HARDWARE ARCHITECTURE DO YOU HAVE !!!
#endif

	ARC_DBG(("conversion_flags = %d\n",arc->conversion_flags));

}

/******************************************************************************/

extern int ARC_convert(
	arc_s	*arc,
	int		mode,
	int		convert,
	void	*data,
	int		len)
{
	ARC_DBG(("ARC_convert(arc:0x%x mode:%d convert:%d data:0x%x len:%d\n",
		arc, mode, convert, data, len));

	ARC_CLEAR_ERROR(arc);

	switch (convert)
	{
		case CONVERT_INTEGER:
		case CONVERT_SHORT:
		case CONVERT_FLOAT:
		case CONVERT_DOUBLE:
		case CONVERT_STRING:
		case CONVERT_CHARACTER:
		case CONVERT_DATA:
			(*ARCH_funcs [mode][convert])(arc, data, len);
			break;

		default:
			ARC_DBG(("ARC_convert unknown conversion type\n"));
			arc->error_code = ARC_NO_CONVERSION;
			strcpy(arc->error_string, ARC_error_msg(arc->error_code));
		break;
	}

	if (arc->error_code)
	{
		if ((int)(arc->error_handler)) (*arc->error_handler)(arc);
		return(arc->error_code);
	}

	ARC_DBG(("ARC_convert: successful conversion\n"));
	return(arc->error_code);
}

/******************************************************************************/

extern void ARC_cpy(
	int len,
	char *src,
	char *dst)
{
	int i;

	for (i=0; i<len; ++i)
	{
		dst[i] = src[i];
	}
}

/******************************************************************************/

extern void ARC_set_debug_handler(
	int (*debug_handler)(const char *, ...))
{
	ARC_debug_handler = debug_handler;
}

/******************************************************************************/
