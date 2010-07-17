/*
	I/STRUCT
*/

#ifndef vsioproto_include
#	define vsioproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef vscmd_include
#	include "vscmd.h"
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
Function VSdisplaySurfaceNormal

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
VSdisplaySurfaceNormal	__((	long			*msg,
				struct GRobj_env	*surface,
				int			normalReversed,
				struct IGRdisplay	*display,
				enum GRdpmode		mode )) ;

/*+f
Function VSfindDirsInPath

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
VSfindDirsInPath	__((	long			*msg,
				const char		*relPath,
				int			*count,
				char			**absPaths )) ;

/*+f
Function VSfindFileInPath

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
VSfindFileInPath	__((	long			*msg,
				char			*relName,
				char			*absName )) ;

/*+f
Function VSfindFileInPwdOrPath
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
VSfindFileInPwdOrPath	__((	long			*msg,
				char			*relName,
				char			*absName )) ;

/*+f
Function VSfindFileInDirOrProductPaths

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
VSfindFileInDirOrProductPaths
			__((	long		*msg,
				const char	*fileToFind,
				const char	*dirToSearchFirst,
				const char	*dirInProdPathThen,
				char		*absPathName )) ;

/*+f
Function VSls

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
VSls			__((	long	   *msg,
				const char *directory,
				const char *fregexp,
				int	   (*filter)( const char *pathname ),
				int	   *count,
				char	   (**fls)[1+FILENAME_MAX] )) ;

/*+f
Function VSlsRegFiles

Abstract
	Same as function `VSls' but only retains regular files (files which
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
VSlsRegFiles		__((	long		*msg,
				char		*directory,
				char		*fregexp,
				int		*count,
				char		(**fls)[1+FILENAME_MAX] )) ;

/*+f
Function VSisReadableUNIXDir

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
VSisReadableUNIXDir	__((	const char	*dirname )) ;

/*+f
Function VSisRegularFile

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
VSisRegularFile		__((	const char	*pathname )) ;

/*+f
Function VSisASCIIFile

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
VSisASCIIFile		__((	const char	*pathname )) ;

/*+f
Function VSputObjectToQueue

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
VSputObjectToQueue	__((	long			*msg,
				OM_S_OBJID		objid,
				OMuword			osnum,
				struct GRmd_env		*env,
				long			position )) ;

/*+f
Function VScreateFileForm

Abstract
	Creates and displays a form whose purpose is to obtain a file name
	from the user.
Arguments
	IN	int		x	X position of form on screen.
	IN	int		y	Y position of form on screen.
	I/O	VSfileFormInfo	*info	Data exchange buffer.
Returns
	A pointer to the created form or NULL in case of error.
Keywords
	#file#form#
Note
	The `info' buffer contains data to initialize the form and is
	updated as the user interacts with the form. A VSfileFormInfo
	structure must be filled as followed:

	char	*curPATH ; (* Size at least MAXPATHLEN  +1	*)
	char	*curNAME ; (* Size at least FILENAME_MAX+1	*)
	char	*curRGXP ; (* Size at least VS_K_MAX_RGXP	*)

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
	 - VS_K_FILE_ACCEPTED (user hit the Dismiss-Execute button)
	 - VS_K_FILE_CANCELED (user hit the Cancel) button)
	 ( #defined in "vscmddef.h" )

	The first argument `parentForm' of `callBack' if set to the
	filed `parentForm' form of this structure (which may be NULL).

	If `callBack' is NULL then the response VS_K_FILE_ACCEPTED
	or VS_K_FILE_CANCELED will be put on the software input queue.

	char	pathName[1+MAXPATHLEN] ;

	This field contains the full pathname of the file input by the
	when VS_K_FILE_ACCEPTED is returned.
Example
	static char	curPATH[MAXPATHLEN  +1]	= "/usr/ip32/grnuc/ppl/bin",
	static char	curNAME[FILENAME_MAX+1]	= "doit.e",
	static char	curRGXP[VS_K_MAX_RGXP]	= "*.e" ;

	static VSfileInfo	fileInfo ;

	static void callBack( char *form, int exitType ) {
	  switch( exitType ) {
	    case VS_K_FILE_ACCEPTED : printf( "User chose <%s/%d>\n",
	    				      curPATH, curNAME ) ;
	    			      break ;
	    case VS_K_FILE_CANCELED : break ;
	  }
	}

	strcpy( fileInfo.openMode, "r" ) ;
	fileInfo.callBack	= callBack;
	fileInfo.parentForm	= form ;
	fileInfo.curPATH	= curPATH ;
	fileInfo.curNAME	= curNAME ;
	fileInfo.curRGXP	= curRGXP ;
	fileForm = VScreateFileForm( 100, 100, &fileInfo ) ;

-f*/
extern char
*VScreateFileForm	__((	int			x,
				int			y,
				VSfileFormInfo		*info )) ;

extern char
*VSmsgkey2string	__((	long			msgkey )) ;

extern char
*VSdate			__((	void )) ;

extern char
*VStime			__((	void )) ;

extern char
*VSreadASCIIfileToBuffer
			__((	long			*msg,
				const char		*filename,
				int			*isASCII )) ;

/*+f
Function VSopenFile

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
	function `VSgetMsgKey', which can then be used to retrieve the
	ASCII text with ex$message.
-f*/
	
extern FILE
*VSopenFile		__((	long			*msg,
				const char		*filename,
				const char		*mode )) ;

extern void
VSreadLine		__((	FILE			*fp,
				int			max,
				int			*reachedEOF,
				char			*line )) ;

#endif /* vsioproto_include */

