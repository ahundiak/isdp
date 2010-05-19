/* $Id: v_slcdef.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	include / v_slcdef.h
 *
 * Description:
 *	Parser constants - used by visual, attribute expression parsers
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: v_slcdef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
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
 * Revision 1.2  1995/07/27  23:19:52  pinnacle
 * Replaced: include/v_slcdef.h for:  by tlbriggs for vds.240
 *
 *
 * History:
 *	07/23/95   tlb		Added VD_null, VD_bool, VD_concat
 *
 *************************************************************************/

#ifndef v_slrcdef_include
#	define v_slrcdef_include

#ifndef	NULL
#	define NULL 0
#endif
#ifndef TRUE
#	define TRUE 1
#endif
#ifndef FALSE
#	define FALSE 0
#endif

#define VD_K_MAX_INPUT	10
#define VD_K_MAX_OUTPUT	30

#define VD_int		100
#define VD_double	101
#define VD_string	102
#define VD_object	103
#define VD_array	104
#define VD_null		106
#define VD_bool		107

#define VD_if		0
#define VD_output	1
#define VD_instr	2
#define VD_cond		3
#define VD_function	4
#define VD_eval		5
#define VD_le		6
#define VD_lt		7
#define VD_ge		8
#define VD_gt		9
#define VD_ne		10
#define VD_not		11
#define VD_and		12
#define VD_or		13
#define VD_eq		14
#define VD_plus		15
#define VD_minus	16
#define VD_mult		17
#define VD_div		18
#define VD_pow		19
#define VD_arg		20
#define VD_concat	25

#define VD_BAD_CHAR		0
#define VD_SYNTAX_ERROR		1
#define VD_IDT_TOO_LONG		2
#define VD_STR_TOO_LONG		3
#define VD_ALIAS_REDEF		4
#define VD_ALIAS_MULT_DEF	5
#define VD_INV_INPUT_INDEX	6
#define VD_UNKNOWN_IDENT	7
#define VD_UNKNOWN_FUNCTION	8
#define VD_INVALID_PATH		9
#define VD_BAD_REGEXP		10
#define VD_BAD_ARG_COUNT	11
#define VD_UNDEF_ALIAS		12

#define VD_K_tokMAX_SIZE	512
#define VD_K_tokMAX_LENG	(VD_K_tokMAX_SIZE - 1)	


#endif
