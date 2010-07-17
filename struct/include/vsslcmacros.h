/*
	I/STRUCT
*/
#ifndef vsslcmacro_include
#	define vsslcmacro_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef vsslc_include
#	include "vsslc.h"
#endif

extern int
VSslcCompile			__((	VSparseErr	*err,
					char		*string,
					VS_NODE		**executable,
					VSaliasTable	aliases )) ;

#omdef vs$compile( error, program, executable, aliases )
	VSslcCompile( (error), (program), (executable), (aliases) )
#endomdef

extern int
VSslcParse			__((	VSparseErr	*err,
					VS_NODE		**executable,
					VSaliasTable	aliases )) ;

#omdef vs$parse( error, executable, aliases )
	VSslcParse( (error), (executable), (aliases) )
#endomdef

extern int
VSslcCheckSyntax		__((	VSparseErr	*err,
					char		*string,
					VSaliasTable	aliases,
					int		*count )) ;

#omdef vs$checkSyntax( error, program, aliases = NULL, count = NULL )
	VSslcCheckSyntax( (error), (program), (aliases), (count) )
#endomdef

extern int
VSslcSearchKeyword		__((	char		*keyword,
					VS_TOKEN	*token )) ;

#omdef vs$searchKeyword( keyword, token )
	VSslcSearchKeyword( keyword, token )
#endomdef

extern int
VSslcAddAlias			__((	VSparseErr	*err,
					int		index,
					char		*alias,
					VSaliasTable	aliases )) ;

#omdef vs$addAlias( error, index, alias, table )
	VSslcAddAlias( (error), (index), (alias), (table) )
#endomdef

extern int
VSslcSearchAlias		__((	VSaliasTable	aliases,
					char		*alias )) ;

#omdef vs$searchAlias( table, alias )
	VSslcSearchAlias( (table), (alias) )
#endomdef

extern int
VSslcExecProg			__((	long		*msg,
					VSexecIN	*inParms,
					VS_NODE 	*executable,
					VSexecOUT	*outParms )) ;

#omdef vs$execProgram( msg, input, executable, output )
	VSslcExecProg( (msg), (input), (executable), (output) )
#endomdef

extern int
VSslcTransKeyword		__((	int		toOrFrom,
					char		*inKeyword,
					char		*outKeyword )) ;

#omdef vs$translateKw( toFlag, inKw, outKw )
	VSslcTransKeyword( (toFlag), (inKw), (outKw) )
#endomdef

extern int
VSslcTranslate			__((	long		*msg,
					int		toFlag,
					char		*inText,
					char		**outText )) ;

#omdef vs$transToInternal( msg, extProgram, p_intProgram )
	VSslcTranslate( (msg), VS_K_TO_INTERNAL, (extProgram), (p_intProgram) )
#endomdef

#omdef vs$transToExternal( msg, intProgram, p_extProgram )
	VSslcTranslate( (msg), VS_K_TO_EXTERNAL, (intProgram), (p_extProgram) )
#endomdef

#endif
