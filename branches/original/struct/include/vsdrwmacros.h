/*
	I/STRUCT
*/
#ifndef vsdrwmacros_include
#	define vsdrwmacros_include

#ifndef vsdrwproto_include
#	include "vsdrwproto.h"
#endif

/*+M
Macro vs$drwExecConfig

Abstract
	Executes the Drawing Extraction Configuration File.
Arguments
	OUT	long		      *msg	 Completion code.
	IN	const struct GRid     *elmId	 Id of element to be drawn.
	IN	const struct GRmd_env *elmEnv	 Mod. env. of element above.
	IN	const struct IGRplane *drwPlane	 Plane of drawing sheet.
	IN	const struct IGRplane *viewPlane Plane of drawing view.
	IN	const IGRvector	      viewVector For projection onto sheet.
	IN	const struct GRmd_env *drwEnv	 Mod. env. of drawing sheet.
	IN	const struct IGRlbsys *drwLbsys	 View cube.
	IN	const int	      selCount	 Count of elements in drawing
						 batch (including *elmId).
	IN	const struct GRid     selList[]	 List of elements in drawing
						 batch (including *elmId).
	IN	const char	      *filename	 Name of config file to
						 execute (optional).
	IN	void		      *appData	 Application specific
						 data (optional).
	OUT	VSdrwOutputData	      **output	 Linked list of outputs.
Note
	`*drwElemList' is malloc'd, it is up to the caller to free it with
		if( *drwElemList ) free( (char *) *drwElemList ) ;
	The default name for `filename' is "setup" searched for in the current
	directory and then the config/drawing directories of the product path.
	The memory allocated for the output must be released with:
			VSdrwFreeOutputData( outp ) ;
		
-M*/
#omdef vs$drwExecConfig(	msg,
				elmId,
				elmEnv,
				drwPlane,
				viewPlane,
				viewVector,
				drwEnv,
				drwLbsys,
				selCount,
				selList,
				filename = NULL,
				appData	 = NULL,
				output )
	VSdrwExecConfig(	(msg),
				(elmId),
				(elmEnv),
				(drwPlane),
				(viewPlane),
				(viewVector),
				(drwEnv),
				(drwLbsys),
				(selCount),
				(selList),
				(filename),
				(appData),
				(output) )
#endomdef

#omdef vs$drwKeyword( keyword, logfile = NULL, token )
	VSdrwKeyword( (keyword), (logfile), (token) )
#endomdef

#omdef vs$drwInterpretConfigFile( msg, input, xinfo = NULL, output )
	VSdrwParse( (msg), (input), (xinfo), (output) )
#endomdef


#endif
