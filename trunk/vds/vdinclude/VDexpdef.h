/* $Id: VDexpdef.h,v 1.2 2001/01/08 19:03:55 art Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdinclude / VDexpdef.h
 *
 * Description:
 *	Internal interface for attribute expression  interpreter
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDexpdef.h,v $
 *	Revision 1.2  2001/01/08 19:03:55  art
 *	ah
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
 * Revision 1.4  1996/06/08  00:04:26  pinnacle
 * Replaced: vdinclude/VDexpdef.h for:  by tlbriggs for vds.240
 *
 * Revision 1.3  1995/10/13  08:53:50  pinnacle
 * Replaced: vdinclude/VDexpdef.h for:  by tlbriggs for vds.240
 *
 * Revision 1.2  1995/07/27  23:29:14  pinnacle
 * Replaced: vdinclude/VDexpdef.h for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1995/07/21  19:58:00  pinnacle
 * Created: vdinclude/VDexpdef.h by tlbriggs for vds.240
 *
 *
 * History:
 *	7/1/95	  tlb	created
 *	7/25/95   tlb	Drop VD_concat
 *	10/12/95  tlb	re-order includes
 *	06/01/96  tlb	Add function table typedefs
 *
 *************************************************************************/

#ifndef v_expdef_include
#	define v_expdef_include
#include <standards.h>
#include "v_drw.h"		/* defines VD_execRes, VD_drwArgList */

/* ----------------------------------------------------------------
 * Global variables
 */ 
typedef struct {
	/*
	 * Parser modes
	 */
	short		reportMode;	/* reporting mode */
	short	 	Xflag;		/* execute flag */
	short	 	statusFlag;	/* return status */
	
	/* 
  	 * Object processing
	 */
	struct GRobj_env   *objList;	/* input list of objects */ 
	short		listMode ;	/* indicates object list processing */
	short		curObjIndex; 	/* index of current object */
	
	/*
	 * Input string
	 */
	char * 		curStr;		/* current input string */
	int		tokPos;		/* current token position */
	int		lexPos;		/* current lex position */
	} global_t;

extern global_t vd_expGlobals;

/* 
 * Global shortcuts
 */
#define MODE		vd_expGlobals.reportMode
#define XFLAG		vd_expGlobals.Xflag
#define STATUS_FLAG	vd_expGlobals.statusFlag
#define LIST_MODE	vd_expGlobals.listMode
#define CUR_INDEX	vd_expGlobals.curObjIndex
#define OBJ_LIST	vd_expGlobals.objList
#define CUR_OBJ		vd_expGlobals.objList[vd_expGlobals.curObjIndex]
#define CUR_INPUT	vd_expGlobals.curStr
#define LEX_POS		vd_expGlobals.lexPos
#define TOK_POS		vd_expGlobals.tokPos


#define VERB		vd_expGlobals.reportMode == VD_EXP_VERBOSE

/*--------------------------------------------------------------------
 * Function table typedefs
 *	no type-checking here - requires union
 *	
 *	type with no args: 
 *		__(( 	struct GRobj_env    obj_env, 
 *			int   pos, 
 *			VD_execRes  *res))
 *	type with args:
 *		__(( const VD_drwArgLst  *list,   
 *			int   pos, 
 *			VD_execRes  *res))
 */
typedef void  (*VD_expFunc_t) ();


/* --------------------------------------------------
 * Include interface defintiion and prototype files
 *	included here at end to use above typedefs
 */
#include "VDexpproto.h"
#include "VDattrexp.h"

/* --------------------------------------------------
 * Little hack for Forte 6
 * For some reason, this gets skipped when using yacc30
 */
#define VDyyexpCONST const

#endif
