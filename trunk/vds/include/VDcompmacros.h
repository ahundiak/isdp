/* $Id: VDcompmacros.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	include / VDcompmacros.h
 *
 * Description:
 *	Functions and macros for component name
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDcompmacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1995/06/22  00:34:22  pinnacle
 * Replaced: include/VDcompmacros.h for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1995/05/05  07:54:28  pinnacle
 * Created: include/VDcompmacros.h by tlbriggs r#
 *
 *
 * History:
 *	4/28/95	  tlb		Created
 *	6/20/95   tlb		Added VD_compGetCompFromMacro, 
 *					VD_compGetMacroFromComp
 *
 *************************************************************************/

#ifndef VDcompmacros_include
#define VDcompmacros_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

/* ---------------------------------------------------------------------*/
/* VD_compGetCompNames
 *	Get list of component names
 *	 	Returns a char array:	 list[num][len]
 *		Names truncated to len-1 to allow room for null char.
 *
 *	Notes:	Caller must free list after use.
 *
 *	Returns: MSSUCC/MSFAIL
 *		MSFAIL		Could not allocate memory
 */
extern int
VD_compGetCompNames 	  __((
	int	len,		/* I: maximum name length */
	int	*num,		/* O: number of names */
	char	**list		/* O: component name list */
			));
			

/*---------------------------------------------------------------------*/
/* VD_compGetCompFromMacro 
 *	Get the component name for a given macro name
 *
 *	Returns: TRUE/FALSE 
 *		Status indicating whether component name was found
 * 
 *	Notes:
 *		User must allocate a buffer for component of 
 *		at least size buf_size
 */
extern IGRboolean
VD_compGetCompFromMacro   __((
	char	*macro,		/* I: macro name  - user allocated buffer */
	int	buf_size,	/* I: length of macro, comp buffers */ 	
        char    **comp      	/* O: component name  - ptr to user buffer */
			));

/*---------------------------------------------------------------------*/
/* VD_compGetMacroFromComp 
 *	Get the macro name or pattern for a given component
 *		Some components may return patterns, e.g. VS*beam
 *
 *	Returns: TRUE/FALSE 
 *		Status indicating whether macro name was found
 *
 *	Notes: 	
 *		User must allocate a buffer for macro name of 
 *		at least size buf_size
 */
extern IGRboolean
VD_compGetMacroFromComp   __((
        char    *comp,      	/* I: component name  - ptr to user buffer */
	int	buf_size,	/* I: length of macro, comp buffers */ 	
	char	**macro		/* O: macro name  - user allocated buffer */
			));

#endif
