/* $Id: v_drwmacros.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/v_drwmacros.h
 *
 * Description:
 *		Macro definition for drawing process.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: v_drwmacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.3  1997/10/28  15:48:20  pinnacle
 * Replaced: include/v_drwmacros.h for:  by rchennup for vds
 *
 * Revision 1.2  1997/07/08  14:22:44  pinnacle
 * Replaced: include/v_drwmacros.h for:  by yzhu for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.4  1995/06/14  22:28:58  pinnacle
 * Replaced: include/v_drwmacros.h for:  by azuurhou for vds.240
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *					creation date
 *      06/25/97        yzhu            add vd_$dgnExecSymbology
 ***************************************************************************/

#ifndef v_drwmacros_include
#	define v_drwmacros_include

#ifndef v_drwproto_include
#	include "v_drwproto.h"
#endif

/*+M
Macro vd_$drwExecConfig

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
	IN	const char	      *set_name	 Name of set of reference 
						 objects.
	IN	void		      *appData	 Application specific
						 data (optional).
	OUT	VD_drwOutputData      **output	 Linked list of outputs.
Note
	`*drwElemList' is malloc'd, it is up to the caller to free it with
		if( *drwElemList ) free( (char *) *drwElemList ) ;
	The default name for `filename' is "setup" searched for in the current
	directory and then the config/drawing directories of the product path.
	The memory allocated for the output must be released with:
			VD_drwFreeOutputData( outp ) ;
		
-M*/
#omdef vd_$drwExecConfig(	msg,
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
				set_name = NULL,
				appData	 = NULL,
				elm_type = NULL,
				output )
	VD_drwExecConfig(	(msg),
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
				(set_name),
				(appData),
				(elm_type),
				(output) )
#endomdef

#omdef vd_$drwKeyword( keyword, logfile = NULL, token )
	VD_drwKeyword( (keyword), (logfile), (token) )
#endomdef

#omdef vd_$drwInterpretConfigFile( msg, input, xinfo = NULL, output )
	VD_drwParse( (msg), (input), (xinfo), (output) )
#endomdef

/*+M
Macro vd_$drwExecSection

Abstract
	Executes the Drawing Extraction Configuration File for Section.
	Cuts Operations.
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
	OUT	VD_drwOutputData      **output	 Linked list of outputs.
Note
	`*drwElemList' is malloc'd, it is up to the caller to free it with
		if( *drwElemList ) free( (char *) *drwElemList ) ;
	The default name for `filename' is "setup" searched for in the current
	directory and then the config/drawing directories of the product path.
	The memory allocated for the output must be released with:
			VD_drwFreeOutputData( outp ) ;
		
-M*/
#omdef vd_$drwExecSection(	msg,
				elmId,
				elmEnv,
				drwPlane = NULL,
				viewPlane = NULL,
				viewVector = NULL,
				drwEnv,
				drwLbsys = NULL,
				selCount,
				selList,
				filename = NULL,
				appData	 = NULL,
				output )
	VD_drwExecSection(	(msg),
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
/*---------------------------------------------------------------------------

Macro vd_$drwExecSymbology

Abstract
        This is the main driver for an suported interface for the generation
        of Attribute Driven Symbology.
Arguments
        OUT     long                  *msg       Completion code.
        IN      const struct GRid     *elmId     Id of element to be drawn.
        IN      const struct GRmd_env *elmEnv    Mod. env. of element above.
        IN      const struct IGRplane *drwPlane  Plane of drawing sheet.
        IN      const struct IGRplane *viewPlane Plane of drawing view.
        IN      const IGRvector       viewVector For projection onto sheet.
        IN      const struct GRmd_env *drwEnv    Mod. env. of drawing sheet.
        IN      const struct IGRlbsys *drwLbsys  View cube.
        IN      const int             selCount   Count of elements in drawing
                                                 batch (including *elmId).
        IN      const struct GRid     selList[]  List of elements in drawing
                                                 batch (including *elmId).
        IN      const char            *filename  Name of config file to

                                                 execute (optional).
        IN      void                  *appData   Application specific
                                                 data (optional).
        OUT     VD_drwOutputData      **output   Linked list of outputs.
Note
        `*drwElemList' is malloc'd, it is up to the caller to free it with
                if( *drwElemList ) free( (char *) *drwElemList ) ;
        The `filename' will be searched for in the current
        directory and then the config/drawing directories of the product path.
        The memory allocated for the output must be released with:
                        VD_drwFreeOutputData( outp ) ;

--------------------------------------------------------------------------*/

#omdef vd_$drwExecSymbology(      msg,
                                elmId,
                                elmEnv,
                                drwPlane = NULL,
                                viewPlane = NULL,
                                viewVector = NULL,
                                drwEnv = NULL,
                                drwLbsys = NULL,
                                selCount = NULL,
                                selList  = NULL,
                                filename,
                                appData  = NULL,
                                output )
        VD_drwExecSymbology(      (msg),
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

#endif
