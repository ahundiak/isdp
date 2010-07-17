/*
	I/STRUCT
*/

#ifndef vsslcproto_include
#	define vsslcproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef vsslc_include
#	include "vsslc.h"
#endif

extern int
VSslcCountFcnArgs		__((	VS_NODE *arglist )) ;

extern int
VSslcCheckFunction		__((	VSparseErr	*err,
					VS_TOKEN	*function,
					VS_NODE		*arglist,
					VSaliasTable	aliases )) ;

extern int
VSslcSplitPath			__((	VSparseErr	*err,
					VSaliasTable	table,
					VS_TOKEN	*path,
					VS_TOKEN	*complex,
					VS_TOKEN	*foot )) ;


extern int
VSslcExecNode			__((	long		*msg,
					VSexecIN	*inParms,
					VS_NODE 	*node,
					VSexecOUT	*outParms,
					VSexecRes	*result )) ;

extern int
VSslcExecArgs			__((	long		*msg,
					VSexecIN	*inParms,
					VS_NODE 	*arglist,
					VSexecOUT	*outParms,
					int		*argc,
					VSexecRes	**argv )) ;
extern int

VSslcFunction			__((	long		*msg,
					VSexecRes	*function,
					int		argc,
					VSexecRes	argv[],
					VSexecRes	*result )) ;

extern void
VSslcGetProgCursor		__((	int		*lineno,
					int		*charno )) ;

extern void
VSslcSetParseErr		__((	long		msg,
					char		*string,
					VSparseErr 	*e )) ;

extern void
VSslcOutputParsingError		__((	VSparseErr 	*e,
					char		*text )) ;

extern void
VSslcExtractCpxName		__((	char		*function,
					char		*name )) ;

extern void
VSfreeProg			__((	VS_NODE		*p )) ;

extern VS_NODE
*VSallocNode			__((	void )) ;

extern VS_NODE
*VSaddConst			__((	VS_TOKEN	*constant )) ;

extern VS_NODE
*VSaddIdent			__((	VS_TOKEN	*identifier )) ;

extern VS_NODE
*VSaddNode			__((	int		type,
					VS_NODE		*arg1,
					VS_NODE		*arg2,
					VS_NODE		*arg3 )) ;

#endif /* vsslcproto_include */

