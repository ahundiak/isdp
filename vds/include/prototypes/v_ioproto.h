/*
	I/VDS	Copy
*/

#ifndef v_ioproto_include
#	define v_ioproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef v_cmd_include
#	include "v_cmd.h"
#endif
#ifndef griodef_include
#	include "griodef.h"
#endif
#ifndef UOMdef_included
#	include "UOMdef.h"
#endif
#ifndef UOM_included
#	include "UOM.h"
#endif

/*+f
Function VD_displaySurfaceNormal

Abstract
	Given a surface, displays one of its normal on the screen, to show the
	orientation of the surface.
Arguments
	OUT	long		  *msg		 Completion code.
	IN	struct GRobj_env  *surface	 Input surface.
	IN	int		  normalReversed Reverse normal ? (TRUE/FALSE)
	IN	struct IGRdisplay *diplay	 Symbology for displau.
	IN	enum GRdpmode	  mode		 Display mode.
Keywords
	#display#normal#surface#
-f*/
extern long
VD_displaySurfaceNormal	__((	long			*msg,
				struct GRobj_env	*surface,
				int			normalReversed,
				struct IGRdisplay	*display,
				enum GRdpmode		mode )) ;

/*+f
Function VD_findDirsInPath

Abstract
	Given a relative directory path, finds all the directories which
	correspond to it in the product paths.
Arguments
	OUT	long		*msg		Completion code.
	IN	const char	*relPath	Relative path.
	OUT	int		*count		Number of absolute paths found.
	OUT	char		**absPaths	List of absolute paths.
Keywords
	#path#product#	
Note
	The paths found are null-character separated in `*absPaths':
			"path1\0path2\path3\0"

	The memory for the list of absolute paths must be released with
			free( *absPaths ) ;
Example
	A call with `relPath' being "config/english" would return
	"/usr/ip32/ems/config/english\0/usr/ip32/model/config/english\0..."
-f*/
extern int
VD_findDirsInPath	__((	long			*msg,
				const char		*relPath,
				int			*count,
				char			**absPaths )) ;

/*+f
Function VD_findFileInPath

Abstract
	Given a relative file name, returns the first file found in the
	product paths.
Arguments
	OUT	long		*msg		Completion code.
	IN	const char	*relName	Relative pathname of file.
	OUT	char		*absName	Absolute pathname of file.
Keywords
	#file#product#
Note
	`absName' should be of size at least `1+MAXPATHLEN' (`MAXPATHLEN' is
	#defined in <sys/param.h>).
-f*/
extern int
VD_findFileInPath	__((	long			*msg,
				char			*relName,
				char			*absName )) ;

/*+f
Function VD_findFileInPwdOrPath
Abstract
	Given a relative file name, returns the first file found by 
	first searching the current working directory, then the	product
	paths.
Arguments
	OUT	long		*msg		Completion code.
	IN	const char	*relName	Relative pathname of file.
	OUT	char		*absName	Absolute pathname of file.
Keywords
	#file#product#pwd#
Note
	`absName' should be of size at least `1+MAXPATHLEN' (`MAXPATHLEN' is
	#defined in <sys/param.h>).
-f*/
extern int
VD_findFileInPwdOrPath	__((	long			*msg,
				char			*relName,
				char			*absName )) ;

/*+f
Function VD_findFileInDirOrProductPaths

Abstract
	Given a relative pathname to a file, finds its absolute pathname
	by first trying some specified directory, then in the directories
	of the product paths.

	For instance, if the relative pathname of the file to find is
	"a/b/F", the directory to first try is ".", and the directories
	to try next are "config/d", then the following files will be
	looked for:
		1 "./a/b/F"
		2 "<user-path>/config/d/a/b/F" (if any user path)
	 	3 "<product1>/config/d/a/b/F"
		4 "<product2>/config/d/a/b/F"
		5 etc.
	The search stops at the first successful attempt.
Arguments
	OUT long       *msg		  Completion code.
	IN  const char *fileToFind	  File to find.
	IN  const char *dirToSearchFirst  First directory to search.
	IN  const char *dirInProdPathThen Directories in products to search
					  next.
Note
	If 'fileToFind' contains an absolute pathname then it is not
	looked for in other directories.
-f*/
extern int
VD_findFileInDirOrProductPaths
			__((	long		*msg,
				const char	*fileToFind,
				const char	*dirToSearchFirst,
				const char	*dirInProdPathThen,
				char		*absPathName )) ;

/*+f
Function VD_ls

Abstract
	Lists the files in a directory which optionally match a regular
	expression and pass a filter.
Arguments
	OUT long       *msg		Completion code.
	IN  const char *directory	Directory to list.
	IN  const char *fregexp		Regular expression (optional: may
					be NULL).
	IN  int	   	(*filter)( const char *pathname )
					Filter function (optional: may be
					NULL)
	OUT char	(**fls)[1+FILENAME_MAX]
					List of files.
Keywords
	#directory#file#list#
Note
	Hidden files (whose name begin with '.') are ignored.

	The function `filter' is given the absolute pathname of each file
	in the directory and must return TRUE if the file is accepted,
	otherwise FALSE.

	The memory allocated for the list of files must be released with:
			free( *fls ) ;
-f*/
extern int
VD_ls			__((	long	   *msg,
				const char *directory,
				const char *fregexp,
				int	   (*filter)( const char *pathname ),
				int	   *count,
				char	   (**fls)[1+FILENAME_MAX] )) ;

/*+f
Function VD_lsRegFiles

Abstract
	Same as function `VD_ls' but only retains regular files (files which
	are neither directories, named pipes or devices).
Arguments
	OUT long       *msg			Completion code.
	IN  const char *directory		Directory to list.
	IN  const char *fregexp			Regular expression
						(optional: may be NULL).
	OUT char       (**fls)[1+FILENAME_MAX]	List of files.
Keywords
	#directory#file#list#regular#
Note
	Hidden files (whose name begin with '.') are ignored.

	The memory allocated for the list of files must be released with:
			free( *fls ) ;
-f*/
extern int
VD_lsRegFiles		__((	long		*msg,
				char		*directory,
				char		*fregexp,
				int		*count,
				char		(**fls)[1+FILENAME_MAX] )) ;

/*+f
Function VD_isReadableUNIXDir

Abstract
	Checks if a file is a readable directory.
Arguments
	IN	const char	*dirname	File to check.
Returns
	TRUE/FALSE
Keywords
	#directory#readable#
-f*/
extern int
VD_isReadableUNIXDir	__((	const char	*dirname )) ;

/*+f
Function VD_isRegularFile

Abstract
	Checks if a file is regular (files which are neither directories,
	named pipes or devices).
Arguments
	IN	const char	*pathname	File to check.
Returns
	TRUE/FALSE
Keywords
	#file#regular#
-f*/
extern int
VD_isRegularFile		__((	const char	*pathname )) ;

/*+f
Function VD_isASCIIFile

Abstract
	Checks if a file is ASCII.
Arguments
	IN	const char	*pathname	File to check.
Returns
	TRUE/FALSE
Keywords
	#ascii#file#
-f*/
extern int
VD_isASCIIFile		__((	const char	*pathname )) ;

/*+f
Function VD_putObjectToQueue

Abstract
	Puts an object on the software input queue.
Arguments
	OUT long            *msg	Completion code.
	IN  OM_S_OBJID      objid	Id of object to put.
	IN  OMuword         osnum	Object space number of object to put.
	IN  struct GRmd_env *env	Module env. of object to put.
	IN  int		    position	Position on queue (BACK/FRONT).
-f*/
extern int
VD_putObjectToQueue	__((	long			*msg,
				OM_S_OBJID		objid,
				OMuword			osnum,
				struct GRmd_env		*env,
				long			position )) ;

/*+f
Function VDcreateFileForm

Abstract
	Creates and displays a form whose purpose is to obtain a file name
	from the user.
Arguments
	IN	int		x	X position of form on screen.
	IN	int		y	Y position of form on screen.
	I/O	VD_fileFormInfo	*info	Data exchange buffer.
Returns
	A pointer to the created form or NULL in case of error.
Keywords
	#file#form#
Note
	The `info' buffer contains data to initialize the form and is
	updated as the user interacts with the form. A VD_fileFormInfo
	structure must be filled as followed:

	char	*curPATH ; (* Size at least MAXPATHLEN  +1	*)
	char	*curNAME ; (* Size at least FILENAME_MAX+1	*)
	char	*curRGXP ; (* Size at least VD_K_MAX_RGXP	*)

	Must point to character arrays initialized to propose default
	values to the user when the form is first displayed.
	`curPATH' is the directory currently displayed in the form (e.g. ".")
	`curNAME' is the file currently displayed in the form (e.g. "")
	`curRGXP' is the regular expression limiting display of the files
		  in the directory (e.g. "*")
	Note that these buffers will be overwritten as the user manipulates
	the form, therefore they must point to static or dynamic memory.

	char openMode[2] ;

	Specifies what kind of operation will be done on the file wanted
	form the user: "r" for read, "w" for write, "a" for append.

	void	(*callBack) __(( char *parentForm, int exitType )) ;
	char	*parentForm ;

	If the form created must interact with another form, one may wish
	the other form to be notified when the form is dismissed. In this
	case `parentForm' must be set to the other form and `callBack'
	must point to a function which will be called with the following
	values of 'exitType':
	 - VD_K_FILE_ACCEPTED (user hit the Dismiss-Execute button)
	 - VD_K_FILE_CANCELED (user hit the Cancel) button)
	 ( #defined in "v_cmddef.h" )

	The first argument `parentForm' of `callBack' if set to the
	filed `parentForm' form of this structure (which may be NULL).

	If `callBack' is NULL then the response VD_K_FILE_ACCEPTED
	or VD_K_FILE_CANCELED will be put on the software input queue.

	char	pathName[1+MAXPATHLEN] ;

	This field contains the full pathname of the file input by the
	when VD_K_FILE_ACCEPTED is returned.
Example
	static char	curPATH[MAXPATHLEN  +1]	= "/usr/ip32/grnuc/ppl/bin",
	static char	curNAME[FILENAME_MAX+1]	= "doit.e",
	static char	curRGXP[VD_K_MAX_RGXP]	= "*.e" ;

	static VD_fileInfo	fileInfo ;

	static void callBack( char *form, int exitType ) {
	  switch( exitType ) {
	    case VD_K_FILE_ACCEPTED : printf( "User chose <%s/%d>\n",
	    				      curPATH, curNAME ) ;
	    			      break ;
	    case VD_K_FILE_CANCELED : break ;
	  }
	}

	strcpy( fileInfo.openMode, "r" ) ;
	fileInfo.callBack	= callBack;
	fileInfo.parentForm	= form ;
	fileInfo.curPATH	= curPATH ;
	fileInfo.curNAME	= curNAME ;
	fileInfo.curRGXP	= curRGXP ;
	fileForm = VDcreateFileForm( 100, 100, &fileInfo ) ;

-f*/
extern char
*VDcreateFileForm	__((	int			x,
				int			y,
				VD_fileFormInfo		*info )) ;

extern char
*VDmsgkey2string	__((	long			msgkey )) ;

extern char
*VD_date			__((	void )) ;

extern char
*VD_time			__((	void )) ;

extern char
*VD_readASCIIfileToBuffer
			__((	long			*msg,
				const char		*filename,
				int			*isASCII )) ;

/*+f
Function VD_openFile

Abstract
	Opens a file in "r"(ead), "w"(rite) or "a"(ppend) mode, returning
	an ad hoc error message in case of error.
Arguments
	OUT long            *msg	Completion code.
	IN  const char	    *filename	Name of file.
	IN  const char	    *mode	Open mode.
Keywords
	#file#open#
Note
	The value of `*msg' can be turned in an error message number with
	function `VD_getMsgKey', which can then be used to retrieve the
	ASCII text with ex$message.
-f*/
	
extern FILE
*VD_openFile		__((	long			*msg,
				const char		*filename,
				const char		*mode )) ;

extern void
VD_readLine		__((	FILE			*fp,
				int			max,
				int			*reachedEOF,
				char			*line )) ;

#endif /* v_ioproto_include */

