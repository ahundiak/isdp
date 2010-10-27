/* $Id: v_lngopproto.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	include/prototypes/ v_lngopproto.h
 *
 * Description:
 *	protypes for parser operations
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: v_lngopproto.h,v $
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
 * Revision 1.2  1995/07/27  23:26:28  pinnacle
 * Replaced: include/prototypes/v_lngopproto.h for:  by tlbriggs for vds.240
 *
 *
 * History:
 *   	07/27/95   tlb		Added verbose flags
 *
 *************************************************************************/

#ifndef v_lngopproto_include
#	define v_lngopproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef v_slc_include
#	include "v_slc.h"
#endif
#ifndef parametric_def
#	include "parametric.h"
#endif

extern int
VD_relOP	__((	long		*msg,
			int			verbose,
			int		opType,
			const VD_execRes	*operand1,
			const VD_execRes	*operand2,
			VD_execRes	*result )) ;

extern int
VD_binOP	__((	long		*msg,
			int			verbose,
			int		opType,
			const VD_execRes	*operand1,
			const VD_execRes	*operand2,
			VD_execRes	*result )) ;

extern int
VD_unrOP	__((	long		*msg,
			int			verbose,
			int		opType,
			const VD_execRes	*operand,
			VD_execRes	*result )) ;

extern int
VD_cvrtVal	__((	long		*msg,
			int			verbose,
			int		typeWanted,
			const VD_execRes	*valueToConvert,
			VD_execRes	*convertedValue )) ;

extern int
VD_fillConst	__((	long			*msg,
			const struct ret_struct	*rs,
			VD_execRes		*constant )) ;

extern int
VD_getObjVal	__((	long			*msg,
			const struct GRobj_env	*object,
			VD_execRes		*value )) ;

extern const VD_execRes
*VD_getAryElm	__((	const VD_execRes *ary,
			int		index )) ;

#endif /* v_lngopproto_include */
