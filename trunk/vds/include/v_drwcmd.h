/* $Id: v_drwcmd.h,v 1.1 2001/01/08 18:48:06 art Exp $ */

/*************************************************************************
 * I/VDS
 *
 * File:	include / v_drwcmd.h
 *
 * Description:
 *	Data structures for drawing process and parser
 *
 * Dependencies:
 *	v_drwdef.h
 *
 * History:
 * 01/03/01  ah  Creation
 *************************************************************************/

/* -----------------------------------------------
 * The Forte 6.0 compilier has a problem with the FILE
 * pointer when the original v_drw.h was included in a spec file.
 * Not clear why except that Forte 6.0 does use a __FILE structure
 * while proworks does not.  The om preprocessor get confused.
 *
 * In any event, the spec file only need the VD_drw_s_MacInfo structre to work
 * so this structure was moved to it's own file and the problem goes away
 */
#ifndef v_drwcmd_include
#define v_drwcmd_include

struct VD_drw_s_AttrList {
	char			*attrName ;
	struct VD_drw_s_AttrList	*next ;
} ;
typedef struct VD_drw_s_AttrList VD_drwAttrList ;

struct VD_drw_s_MacInfo {
	
	/*
	 * May be a regular expression.
	 */
	char			*macDefName ;

	/*
	 * Name of macro which will represent the above on the drawing sheet.
	 */
	char			*drwMacName ;

	/*
	 * Attributes to report from model to drawing for macro.
	 */
	VD_drwAttrList		*attrList ;

	struct VD_drw_s_MacInfo	*next ;
} ;

typedef struct VD_drw_s_MacInfo VD_drwMacInfo ;

#endif
