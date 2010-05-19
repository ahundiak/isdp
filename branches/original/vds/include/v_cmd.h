/* $Id: v_cmd.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/v_cmd.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: v_cmd.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.4  1997/11/01  15:31:24  pinnacle
 * Replaced: include/v_cmd.h for:  by v250_int for vds
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	11/01/97	vds		Add pinnacle Header
 ***************************************************************************/

#ifndef v_cmd_include
#	define v_cmd_include

#ifndef _SYS_PARAM_H
#	include <sys/param.h>		/* For	'MAXPATHLEN'	*/
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

#ifdef X11
#include "standards.h"
#endif

struct VD_s_locateArgs {
	struct GRlc_stack	*stack ;
	long			value,
				rejectSts ;
} ;
typedef struct VD_s_locateArgs VD_locateArgs ;

struct VD_s_fenceArgs {
	long	value ;
} ;
typedef struct VD_s_fenceArgs VD_fenceArgs ;

#define VD_K_MAX_RGXP	30	/* Max size of a regexp */

struct VD_s_fileFormInfo {
	char	*curPATH,
		*curNAME,
		*curRGXP ;	/* Output File Name     */
        char    *repNAME,
                *repRGXP ;      /* names of report file */
	char	*repTITLE ;	/* Name of Report Title */

	/*
	 * The value of 'exitType' is VD_K_FILE_ACCEPTED (user hit the
	 * Dismiss-Execute button) or VD_K_FILE_CANCELED (user hit the
	 * Cancel) button), #defined in "v_cmddef.h".
	 * If `callBack' is NULL then the response VD_K_FILE_ACCEPTED
	 * or VD_K_FILE_CANCELEDwill be put on the software input queue.
	 * The first argument `parentForm' of `callBack' if set to the
	 * filed `parentForm' form of this structure (which may be NULL).
	 */
	void	(*callBack) __(( char *parentForm, int exitType )) ;
	char	*parentForm ;
	char	pathName[1+MAXPATHLEN],
		openMode[2] ;
} ;
typedef struct VD_s_fileFormInfo VD_fileFormInfo ;

#endif

