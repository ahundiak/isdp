/*
	I/STRUCT
*/

#ifndef vsophstproto_include
#	define vsophstproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef vs_include
#	include "vs.h"
#endif

extern void
VSfreeOpHistory		__((	VSopHistory	*history )) ;

extern int
VSgetOperatorType	__((	struct GRid	*header,
				struct GRid	*graphic )) ;

extern long
VSgetOperatorTypeMsgKey	__((	int		optype	)) ;

extern long
VSgetOperandTypeMsgKey	__((	int		optype	)) ;

#endif /* vsophstproto_include */

