/* $Id: VSslcdef.h,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/include/VSslcdef.h
 *
 * Description:
 8		Duplication of I/STRUCT file to compile reference code.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSslcdef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
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
 * Revision 1.1  1995/08/16  14:49:56  pinnacle
 * Created: vddraw/include/VSslcdef.h by azuurhou for vds.240
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/13/95	adz		creation date
 *
 ***************************************************************************/

#ifndef VSslrcdef_include
#	define VSslrcdef_include

#ifndef	NULL
#	define NULL 0
#endif
#ifndef TRUE
#	define TRUE 1
#endif
#ifndef FALSE
#	define FALSE 0
#endif

#define VS_K_MAX_INPUT	10
#define VS_K_MAX_OUTPUT	30

#define VS_int		100
#define VS_double	101
#define VS_string	102
#define VS_object	103
#define VS_array	104

#define VS_if		0
#define VS_output	1
#define VS_instr	2
#define VS_cond		3
#define VS_function	4
#define VS_eval		5
#define VS_le		6
#define VS_lt		7
#define VS_ge		8
#define VS_gt		9
#define VS_ne		10
#define VS_not		11
#define VS_and		12
#define VS_or		13
#define VS_eq		14
#define VS_plus		15
#define VS_minus	16
#define VS_mult		17
#define VS_div		18
#define VS_pow		19
#define VS_arg		20

#define VS_BAD_CHAR		0
#define VS_SYNTAX_ERROR		1
#define VS_IDT_TOO_LONG		2
#define VS_STR_TOO_LONG		3
#define VS_ALIAS_REDEF		4
#define VS_ALIAS_MULT_DEF	5
#define VS_INV_INPUT_INDEX	6
#define VS_UNKNOWN_IDENT	7
#define VS_UNKNOWN_FUNCTION	8
#define VS_INVALID_PATH		9
#define VS_BAD_REGEXP		10
#define VS_BAD_ARG_COUNT	11
#define VS_UNDEF_ALIAS		12

#define VS_K_tokMAX_SIZE	512
#define VS_K_tokMAX_LENG	(VS_K_tokMAX_SIZE - 1)	

/*
 * Translation flag: from (to) local (external) language to (from) internal
 * language.
 */
#define VS_K_TO_INTERNAL	0
#define VS_K_TO_EXTERNAL	1

/*
 * Internal form of keywords.
 */
#define VS_K_internalIF		"@IF"
#define VS_K_internalTHEN	"@THEN"
#define VS_K_internalELSE	"@ELSE"
#define VS_K_internalENDIF	"@ENDIF"
#define VS_K_internalNOT	"@NOT"
#define VS_K_internalAND	"@AND"
#define VS_K_internalOR		"@OR"
#define VS_K_internalOUTPUT	"@OUTPUT"
#define VS_K_internalINPUT	"@INPUT"
#define VS_K_internalBEAM	"@BEAM"
#define VS_K_internalPLATE	"@PLATE"
#define VS_K_internalDISTANCE	"@DISTANCE"
#define VS_K_internalDSPREP	"@DSPREP"

#endif
