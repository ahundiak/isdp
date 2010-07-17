/*
	I/STRUCT
*/
#ifndef vsdrwapi_include
#	define vsdrwapi_include

#ifndef _STRING_H
#	include <string.h>
#endif
#ifndef vsdrwproto_include
#	include "vsdrw.h"
#endif

#define DECLARE_ISOFTYPE( PFX, _TYPE_ )					\
extern void PFX##drwISOFTYPE##_TYPE_ __((				\
					unsigned long		query,	\
					VSdrwInputData		*inp,	\
					struct VS_s_drwExecData	*xData )) ;

#define DECLARE_FUNCTION( PFX, _FUNCTION_ )				\
extern VSxfRC PFX##drwFUNCTION##_FUNCTION_ __((				\
				const VSdrwInputData	*inp,		\
				VSdrwExecData		*xData,		\
				const char		*function,	\
				const VSdrwArgLst	*arglist,	\
				int			argc,		\
				VSexecRes		*res )) ;

#define DECLARE_OUTPUT( PFX, _OUTPUT_ )					\
extern VSxfRC PFX##drwOUTPUT##_OUTPUT_	__((				\
				VSdrwInputData		*inp,		\
				VSdrwExecData		*xData,		\
				const char		*function,	\
				const VSdrwArgLst	*arglist,	\
				int			argc,		\
				VSdrwGraphicGroup	*outpgr  )) ;

#define IMPLEMENT_ISOFTYPE( PFX, _TYPE_ )				\
void PFX##drwISOFTYPE##_TYPE_( query, inp, xData )			\
unsigned long		query ;						\
VSdrwInputData		*inp ;						\
struct VS_s_drwExecData	*xData ;

#define DRW_wantFilter 		(query & VSdrwQueryFilter)
#define DRW_wantType   		(query & VSdrwQueryType)
#define DRW_wantView   		(query & VSdrwQueryView)
#define DRW_elmFilter  		(xData->filter)
#define DRW_elmType    		(xData->parsedElmType)
#define DRW_elmView    		(inp->viewType)
#define DRW_elmId      		(inp->elmId)
#define DRW_elmEnv     		(inp->elmEnv)
#define DRW_viewConeAngle	(xData->overrides.viewConeAngle)
#define DRW_viewVector		(inp->drwInfo.viewVector)
#define DRW_appData		(inp->appData)
#define DRW_elmDesc		(xData->parsedElmDesc)

#define IMPLEMENT_FUNCTION( PFX, _FUNCTION_ ) \
VSxfRC PFX##drwFUNCTION##_FUNCTION_( inp, xData, function, arglist, argc,  \
				     res )				   \
const VSdrwInputData *inp ;	/* IN : Data input to interpreter	*/ \
VSdrwExecData	     *xData ;	/* IN : Data set during execution	*/ \
const char	     *function ;/* IN : Name of function to execute	*/ \
const VSdrwArgLst    *arglist ;	/* IN : Arguments of function		*/ \
int		     argc ;	/* IN : Count of arguments		*/ \
VSexecRes	     *res ; 	/* OUT: Result of function evaluation	*/

#define IMPLEMENT_OUTPUT( PFX, _OUTPUT_ )				\
VSxfRC PFX##drwOUTPUT##_OUTPUT_( inp, xData, function, arglist, argc,	\
				outpgr )				\
VSdrwInputData		*inp ;						\
VSdrwExecData		*xData ;					\
const char		*function ;	/* IN : Name of output	*/	\
const VSdrwArgLst    	*arglist ;	/* IN : Args of output	*/	\
int		     	argc ;		/* IN : Count of args	*/ 	\
VSdrwGraphicGroup	*outpgr ;

#define ISOFTYPE_ADDRESS( PFX, _TYPE_     ) PFX##drwISOFTYPE##_TYPE_
#define FUNCTION_ADDRESS( PFX, _FUNCTION_ ) PFX##drwFUNCTION##_FUNCTION_
#define OUTPUT_ADDRESS(   PFX, _OUTPUT_   ) PFX##drwOUTPUT##_OUTPUT_

#define WRONG_OUTPUT \
	if( xData->verbose ) { \
		extern const char* VSdrwOUTPUTnotSupported ; \
		VSdrwPrintf( VSdrwOUTPUTnotSupported, function, \
			     xData->parsedElmDesc  ) ; \
	} \
	return xfINVARG ;

#define XFERR if( xData->verbose ) VSdrwPrintf

#define CHECK_ARGCOUNT( n ) 						\
	if( argc != (n) ) {						\
		extern const char* VSdrwBadArgCount ;			\
		XFERR( VSdrwBadArgCount, function, (n), argc ) ;	\
		return xfARGCOUNT ;					\
	}

#define CHECK_ARGCOUNTS( n1, n2 ) 					\
	if( argc != (n1) && argc != (n2) ) {				\
		extern const char* VSdrwBadArgCounts ;			\
		XFERR( VSdrwBadArgCounts, function,(n1), (n2), argc ) ;	\
		return xfARGCOUNT ;					\
	}

#define CHECK_FOR_OBJ( arg, argno )					\
	if( (arg).type != VS_object ) {					\
		extern const char* VSdrwNotAnElement ;			\
		XFERR( VSdrwNotAnElement, function, (argno) ) ;		\
		return xfINVARG ;					\
	}


#define BAD_ARG_TYPE( argno, wantedType ) {				\
	extern const char* VSdrwBadArgType ;				\
	XFERR( VSdrwBadArgType, function, (argno), (wantedType) ) ;	\
	return xfINVARG ;						\
}

#define BAD_OBJ_TYPE( wantedType ) {					\
	extern const char* VSdrwBadElementType ;			\
	XFERR( VSdrwBadElementType, function, (wantedType) ) ;		\
	return xfINVARG ;						\
}

#define bad_obj_type( wantedType ) {					\
	extern const char* VSdrwBadElementType ;			\
	XFERR( VSdrwBadElementType, function, (wantedType) ) ;		\
	return OM_E_INVARG ;						\
}

	
#define INT_RES( v ) { res->type = VS_int    ; res->_ival = (v) ; }
#define DBL_RES( v ) { res->type = VS_double ; res->_dval = (v) ; }
#define STR_RES( v ) { \
	res->type = VS_string ; \
	strncpy( res->_sval, (v), VS_K_tokMAX_LENG )[VS_K_tokMAX_LENG] = '\0'; \
}

#endif
