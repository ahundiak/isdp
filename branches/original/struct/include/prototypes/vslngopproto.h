/*
	I/STRUCT
*/

#ifndef vslngopproto_include
#	define vslngopproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef vsslc_include
#	include "vsslc.h"
#endif
#ifndef parametric_def
#	include "parametric.h"
#endif

extern int
VSrelOP		__((	long		*msg,
			int		opType,
			const VSexecRes	*operand1,
			const VSexecRes	*operand2,
			VSexecRes	*result )) ;

extern int
VSbinOP		__((	long		*msg,
			int		opType,
			const VSexecRes	*operand1,
			const VSexecRes	*operand2,
			VSexecRes	*result )) ;

extern int
VSunrOP		__((	long		*msg,
			int		opType,
			const VSexecRes	*operand,
			VSexecRes	*result )) ;

extern int
VScvrtVal	__((	long		*msg,
			int		typeWanted,
			const VSexecRes	*valueToConvert,
			VSexecRes	*convertedValue )) ;

extern int
VSfillConst	__((	long			*msg,
			const struct ret_struct	*rs,
			VSexecRes		*constant )) ;

extern int
VSgetObjVal	__((	long			*msg,
			const struct GRobj_env	*object,
			VSexecRes		*value )) ;

extern const VSexecRes
*VSgetAryElm	__((	const VSexecRes *ary,
			int		index )) ;

#endif /* vslngopproto_include */

