/*
	I/STRUCT

	This files handles the inputs scanned by Lex. The starting file "setup"
	may include other files (themselves including files) via the

			include "<file name>" ;

	statement. When such a statement is encountered, the new file is opened
	and Lex's input stream is set to the new file, which is put on top of
	a stack. When an end-of-file is met, the file is closed and poped from
	the stack. Lex's input is then set back to the  previous file.

	The maximum nesting depth of include files is VS_K_DRW_MAXINFILES.
*/
#include <string.h>
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "macro.h"		/* For `macro_MAX_CHAR'		*/
/*
 * Includes of function prototypes
 */
#include "vsdrwproto.h"
#include "vsgetmsgkey.h"
#include "vsioproto.h"

extern int	VSyydrwlineno ;
/*----------------------------------------------------------------------------*/
void VSdrwInitStackOfInputFiles( inputs ) VSdrwInputFiles *inputs ; {

	int	i ;

	inputs->iScanned = -1 ;

	for( i = 0 ; i < VS_K_DRW_MAXINFILES ; i++ ) {
		inputs->stream[i]	= NULL ;
		*inputs->name[i]	= '\0' ;
	}

} /* VSdrwInitStackOfInputFiles */
/*----------------------------------------------------------------------------*/
void VSdrwCloseInputFiles( inputs ) VSdrwInputFiles *inputs ; {

	int	i ;

	for( i = 0 ; i < VS_K_DRW_MAXINFILES ; i++ ) {
		if( inputs->stream[i] ) fclose( inputs->stream[i] ) ;
	}

	VSdrwInitStackOfInputFiles( inputs ) ;

} /* VSdrwCloseInputFiles */
/*----------------------------------------------------------------------------*/
int VSdrwPopInputFile( verbose, inputs )

int		verbose ;
VSdrwInputFiles *inputs ; {

	int	stackNotEmpty = FALSE ;

	if( inputs->iScanned > 0 ) {
		/*
		 * Stack not empty: close currently opened file, then
		 * set previous file as Lex input if the currently
		 * opened files was not the last one.
		 */

		if( verbose && inputs->iScanned > 0 ) {
			VSdrwPrintf( "<<< Close %s\n",
					inputs->name[inputs->iScanned] ) ;
		}

		fclose( inputs->stream[inputs->iScanned] ) ;

		/*
		 * Set it to NULL to flag that this file has been closed.
		 */
		inputs->stream[inputs->iScanned] = NULL ;
		inputs->iScanned-- ;

		if( inputs->iScanned >= 0 ) {
			/*
			 * The stack is not empty, set Lex's input to the
			 * new top of stack, with the line number where file
			 * was interrupted.
			 */
			VSsetDrwConfigInput( inputs->stream[inputs->iScanned],
					     inputs->lineno[inputs->iScanned] );
			stackNotEmpty = TRUE ;
		}
	}

	return stackNotEmpty ;

} /* VSdrwPopInputFile */
/*----------------------------------------------------------------------------*/
int VSdrwPushInputFile( infile, verbose, inputs )

const char	*infile ;
int		verbose ;
VSdrwInputFiles *inputs ; {

	long	msg ;
	char	relPathName[MAXPATHLEN],
		absPathName[MAXPATHLEN],
		firstDir   [MAXPATHLEN] ;
	FILE	*newInput ;
	int	i ;

	if( verbose && inputs->iScanned >= 0 ) {
		VSdrwPrintf( ">>> Open %s\n", infile ) ;
	}

	/*
	 * Is the maximum stacking limit exceeded ?
	 */
	if( inputs->iScanned >= VS_K_DRW_MAXINFILES - 1 ) {
		if( verbose ) {
			VSdrwPrintf(
			    "!!! Too many nested include files, maximum: %d\n",
			    VS_K_DRW_MAXINFILES ) ;
		}
		return FALSE ;
	}

	/*
	 * Look for file in current working directory, then in product path.
	 * (Beware that relative path may already have been prepended).
	 */
	if( !strncmp(	infile,
			VS_K_DRW_CONFIG_RELPATH,
			strlen( VS_K_DRW_CONFIG_RELPATH ) ) ) {
		strcpy( relPathName,
			infile + 1 + strlen( VS_K_DRW_CONFIG_RELPATH ) ) ;
	} else {
		strcpy( relPathName, infile ) ;
	}

	/*
	 * When a file B is included by a file A, we start the search for B
	 * in the directory where A was found, A is at 'iScanned'.
	 * If B is the first file (not included by another file), then the
	 * search first begins in ".", the current directory.
	 */
	if( inputs->iScanned >= 0 ) {
		char *prevScanned	= inputs->name[inputs->iScanned] ;
		char *lastSlash		= strrchr( prevScanned, '/' ) ;

		*lastSlash = '\0' ;
		strcpy( firstDir, prevScanned ) ;
		*lastSlash = '/' ;
	} else {
		strcpy( firstDir, "." ) ;
	}
	VSfindFileInDirOrProductPaths(	&msg,
					relPathName,
					firstDir,
					VS_K_DRW_CONFIG_RELPATH,
					absPathName ) ;

	if( !( msg & 1 ) ) {
		if( verbose ) {
			char	err[MS_MAX_MSG_LENGTH] ;
			ex$message(	msgnumb		= VSgetMsgKey( msg ),
					buff		= err ) ;
			VSdrwPrintf( "!!! %s: %s\n", infile, err ) ;
		}
		return FALSE ;
	}

	/*
	 * Check that we are not going to open an already open file, which would
	 * mean that we are recursively including a file in itself.
	 */
	for( i = 0 ; i <= inputs->iScanned ; i++ ) {
		if( !strcmp( absPathName, inputs->name[i] ) ) {
			VSdrwPrintf( "!!! Recursive inclusion of file '%s'\n",
				     absPathName ) ;
			return FALSE ;
		}
	}

	/*
	 * Now open that baby.
	 */
	newInput = VSopenFile( &msg, absPathName, "r" ) ;
	if( !( msg & 1 ) ) {
		if( verbose ) {
			char	err[MS_MAX_MSG_LENGTH] ;
			ex$message(	msgnumb		= VSgetMsgKey( msg ),
					buff		= err ) ;
			VSdrwPrintf( "!!! %s: %s\n", infile, absPathName ) ;
		}
		return FALSE ;
	}

	/*
	 * Save line number of the file being stacked.
	 */
	if( inputs->iScanned >= 0 ) {
		inputs->lineno[inputs->iScanned] = VSyydrwlineno ;
	}

	/*
	 * ... and push it onto the stack.
	 */
	inputs->iScanned++ ;
	strcpy( inputs->name[inputs->iScanned], absPathName ) ;
	inputs->stream[inputs->iScanned] = newInput ;

	/*
	 * Set Lex's input stream, the popping of this file will occur in
	 * `yywrap()' called when Lex encouters an EOF.
	 */
	VSsetDrwConfigInput( newInput, 1 ) ;

	return TRUE ;

} /* VSdrwPushInputFile */
/*----------------------------------------------------------------------------*/

