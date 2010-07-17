/* $Id: vscmd.h,v 1.1.1.1 2001/01/04 21:09:42 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	include/vscmd.h	
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vscmd.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:42  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1998/02/03  19:24:16  pinnacle
 * TR179702554
 *
 *
 * History:
 * MM/DD/YY  AUTHOR DESCRIPTION
 * 02/03/98  ah     TR179702554 Problem Compiling under Solaris
 ***************************************************************************/

#ifndef vscmd_include
#	define vscmd_include

#ifndef _SYS_PARAM_H
/* TR179702554 Including this file causes problems when compiling under Solaris
 * sys/time.h yields a broken pipe error
 * So comment out the include then just define MAXPATHLEN
 */
#define	MAXPATHLEN	1024
#define	MAXSYMLINKS	20
#define	MAXNAMELEN	256
//#	include <sys/param.h>		/* For	'MAXPATHLEN'	*/
#endif
#ifndef OM_D_MINIMUM
#	include "OMminimum.h"
#endif
#ifndef igetypedef_include
#	include "igetypedef.h"		/* IGE typedefs GR*		*/
#endif
#ifndef igrtypedef_include
#	include "igrtypedef.h"		/* Typedef IGR*			*/
#endif
#ifndef exdef_include
#	include "exdef.h"		/* Constants for exec (IGE)	*/
#endif
#ifndef ex_include
#	include "ex.h"			/* Structs EX*			*/
#endif
#ifndef didef
#	include "DIdef.h"			/* Structs EX*			*/
#endif
#ifndef igrdef_include
#	include "igrdef.h"		/* Constants IGR*		*/
#endif
#ifndef igr_include
#	include "igr.h"			/* Structs IGR* for geometries	*/
#endif
#ifndef igrdp_include
#	include "igrdp.h"		/* Structs IGR* for display	*/
#endif
#ifndef gr_include
#	include "gr.h"			/* Structs GR* for graphic info	*/
#endif
#ifndef godef_include
#	include "godef.h"		/* Definitions for graphics	*/
#endif
#ifndef go_include
#	include "go.h"			/* Struct GR* for graphics	*/
#endif
#ifndef griodef_include
#	include "griodef.h"		/* Constants for graphic I/O	*/
#endif
#ifndef grio_include
#	include "grio.h"		/* Structs for graphic I/O	*/
#endif
#ifndef growner_include
#	include "growner.h"		/* For `struct GRobj_env'	*/
#endif
#ifndef dp_include
#	include "dp.h"			/* Enums, structs for display	*/
#endif
#ifndef lcdef_include
#	include "lcdef.h"
#endif
#ifndef lc_include
#	include "lc.h"
#endif

#ifndef _STANDARDS_H_
#	include "standards.h"
#endif

struct VS_s_locateArgs {
	struct GRlc_stack	*stack ;
	long			value,
				rejectSts ;
} ;
typedef struct VS_s_locateArgs VSlocateArgs ;

struct VS_s_fenceArgs {
	long	value ;
} ;
typedef struct VS_s_fenceArgs VSfenceArgs ;

#define VS_K_MAX_RGXP	30	/* Max size of a regexp */

struct VS_s_fileFormInfo {
	char	*curPATH,
		*curNAME,
		*curRGXP ;
	/*
	 * The value of 'exitType' is VS_K_FILE_ACCEPTED (user hit the
	 * Dismiss-Execute button) or VS_K_FILE_CANCELED (user hit the
	 * Cancel) button), #defined in "vscmddef.h".
	 * If `callBack' is NULL then the response VS_K_FILE_ACCEPTED
	 * or VS_K_FILE_CANCELEDwill be put on the software input queue.
	 * The first argument `parentForm' of `callBack' if set to the
	 * filed `parentForm' form of this structure (which may be NULL).
	 */
	void	(*callBack) __(( char *parentForm, int exitType )) ;
	char	*parentForm ;
	char	pathName[1+MAXPATHLEN],
		openMode[2] ;
} ;
typedef struct VS_s_fileFormInfo VSfileFormInfo ;

#endif

