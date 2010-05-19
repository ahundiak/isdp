/* $Id: v_drwapi.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	include / v_drwapi.h
 *
 * Description:
 *	VDL api to add functions, types
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: v_drwapi.h,v $
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
 * Revision 1.2  1995/03/31  09:19:02  pinnacle
 * Replace: by tlbriggs for OPE
 *
 *
 * History:
 *	3/31/95	    tlb		Add support for GraType
 *
 *************************************************************************/

#ifndef v_drwapi_include
#	define v_drwapi_include

#ifndef _STRING_H
#	include <string.h>
#endif
#ifndef v_drwproto_include
#	include "v_drw.h"
#endif

#define DECLARE_ISOFTYPE( PFX, _TYPE_ )					\
extern void PFX##_drwISOFTYPE##_TYPE_ __((				\
					unsigned long		query,	\
					VD_drwInputData		*inp,	\
					struct VD_s_drwExecData	*xData )) ;

#define DECLARE_FUNCTION( PFX, _FUNCTION_ )				\
extern VD_xfRC PFX##_drwFUNCTION##_FUNCTION_ __((			\
				const VD_drwInputData	*inp,		\
				VD_drwExecData		*xData,		\
				const char		*function,	\
				const VD_drwArgLst	*arglist,	\
				int			argc,		\
				VD_execRes		*res )) ;

#define DECLARE_OUTPUT( PFX, _OUTPUT_ )					\
extern VD_xfRC PFX##_drwOUTPUT##_OUTPUT_ __((				\
				VD_drwInputData		*inp,		\
				VD_drwExecData		*xData,		\
				const char		*function,	\
				const VD_drwArgLst	*arglist,	\
				int			argc,		\
				VD_drwGraphicGroup	*outpgr  )) ;

#define IMPLEMENT_ISOFTYPE( PFX, _TYPE_ )				\
void PFX##_drwISOFTYPE##_TYPE_( query, inp, xData )			\
unsigned long		query ;						\
VD_drwInputData		*inp ;						\
struct VD_s_drwExecData	*xData ;

#define CALL_ISOFTYPE( PFX, _TYPE_ )				\
	PFX##_drwISOFTYPE##_TYPE_( query, inp, xData );	

/*
 * To override the I/STRUCT functions with dummies. The syntax in I/VDS
 * different form I/STRUCT	PFX##drw -> PFX##_drw
 */

#define IMPLEMENT_VS_ISOFTYPE( PFX, _TYPE_ )				\
void PFX##drwISOFTYPE##_TYPE_( query, inp, xData )			\
unsigned long		query ;						\
VD_drwInputData		*inp ;						\
struct VD_s_drwExecData	*xData ;

#define DECLARE_VS_ISOFTYPE( PFX, _TYPE_ )				\
extern void PFX##drwISOFTYPE##_TYPE_ __((				\
					unsigned long		query,	\
					VD_drwInputData		*inp,	\
					struct VD_s_drwExecData	*xData )) ;
#define CALL_VS_ISOFTYPE( PFX, _TYPE_ )				\
	PFX##drwISOFTYPE##_TYPE_( query, inp, xData );	


#define DRW_wantFilter 		(query & VD_drwQueryFilter)
#define DRW_wantType   		(query & VD_drwQueryType)
#define DRW_wantGraType   	(query & VD_drwQueryGraType)
#define DRW_wantView   		(query & VD_drwQueryView)
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
VD_xfRC PFX##_drwFUNCTION##_FUNCTION_( inp, xData, function, arglist, argc,  \
				     res )				   \
const VD_drwInputData *inp ;	/* IN : Data input to interpreter	*/ \
VD_drwExecData	     *xData ;	/* IN : Data set during execution	*/ \
const char	     *function ;/* IN : Name of function to execute	*/ \
const VD_drwArgLst    *arglist ;	/* IN : Arguments of function		*/ \
int		     argc ;	/* IN : Count of arguments		*/ \
VD_execRes	     *res ; 	/* OUT: Result of function evaluation	*/

#define IMPLEMENT_OUTPUT( PFX, _OUTPUT_ )				\
VD_xfRC PFX##_drwOUTPUT##_OUTPUT_( inp, xData, function, arglist, argc,	\
				outpgr )				\
VD_drwInputData		*inp ;						\
VD_drwExecData		*xData ;					\
const char		*function ;	/* IN : Name of output	*/	\
const VD_drwArgLst    	*arglist ;	/* IN : Args of output	*/	\
int		     	argc ;		/* IN : Count of args	*/ 	\
VD_drwGraphicGroup	*outpgr ;

#define ISOFTYPE_ADDRESS( PFX, _TYPE_     ) PFX##_drwISOFTYPE##_TYPE_
#define FUNCTION_ADDRESS( PFX, _FUNCTION_ ) PFX##_drwFUNCTION##_FUNCTION_
#define OUTPUT_ADDRESS(   PFX, _OUTPUT_   ) PFX##_drwOUTPUT##_OUTPUT_

#define WRONG_OUTPUT \
	if( xData->verbose ) { \
		extern const char* VD_drwOUTPUTnotSupported ; \
		VD_drwPrintf( VD_drwOUTPUTnotSupported, function, \
			     xData->parsedElmDesc  ) ; \
	} \
	return xfINVARG ;

#define XFERR if( xData->verbose ) VD_drwPrintf

#define CHECK_ARGCOUNT( n ) 						\
	if( argc != (n) ) {						\
		extern const char* VD_drwBadArgCount ;			\
		XFERR( VD_drwBadArgCount, function, (n), argc ) ;	\
		return xfARGCOUNT ;					\
	}

#define CHECK_ARGCOUNTS( n1, n2 ) 					\
	if( argc != (n1) && argc != (n2) ) {				\
		extern const char* VD_drwBadArgCounts ;			\
		XFERR( VD_drwBadArgCounts, function,(n1), (n2), argc ) ;	\
		return xfARGCOUNT ;					\
	}

#define CHECK_FOR_OBJ( arg, argno )					\
	if( (arg).type != VD_object ) {					\
		extern const char* VD_drwNotAnElement ;			\
		XFERR( VD_drwNotAnElement, function, (argno) ) ;		\
		return xfINVARG ;					\
	}


#define BAD_ARG_TYPE( argno, wantedType ) {				\
	extern const char* VD_drwBadArgType ;				\
	XFERR( VD_drwBadArgType, function, (argno), (wantedType) ) ;	\
	return xfINVARG ;						\
}

#define BAD_OBJ_TYPE( wantedType ) {					\
	extern const char* VD_drwBadElementType ;			\
	XFERR( VD_drwBadElementType, function, (wantedType) ) ;		\
	return xfINVARG ;						\
}

#define bad_obj_type( wantedType ) {					\
	extern const char* VD_drwBadElementType ;			\
	XFERR( VD_drwBadElementType, function, (wantedType) ) ;		\
	return OM_E_INVARG ;						\
}

	
#define INT_RES( v ) { res->type = VD_int    ; res->_ival = (v) ; }
#define DBL_RES( v ) { res->type = VD_double ; res->_dval = (v) ; }
#define STR_RES( v ) { \
	res->type = VD_string ; \
	strncpy( res->_sval, (v), VD_K_tokMAX_LENG )[VD_K_tokMAX_LENG] = '\0'; \
}

#endif
