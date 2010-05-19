/* $Id: VDdrwinfiles.C,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw / VDdrwinfiles.C
 *
 * Description:
 *	This file handles the inputs scanned by Lex. The starting file "setup"
 *	may include other files (themselves including files) via the
 *
 *			include "<file name>" ;
 *
 *	statement. When such a statement is encountered, the new file is opened
 *	and Lex's input stream is set to the new file, which is put on top of
 *	a stack. When an end-of-file is met, the file is closed and poped from
 *	the stack. Lex's input is then set back to the  previous file.
 *
 *	The maximum nesting depth of include files is VD_K_DRW_MAXINFILES.
 *
 * Dependencies:
 *
 * History:
 *	3/15/95		tlb	Modify VD_drwPushInputFile - 
 *					   print error if setup file not found
 *	3/20/95		tlb	Use error print routines 
 *				Add variable CurrentFile for error functions
 *      6/25/97         yzhu    Add VD_dgnPushInputFile
 *************************************************************************/

#include <string.h>
#include "v_drwdef.h"
#include "v_drw.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "macro.h"		/* For `macro_MAX_CHAR'		*/
#include "v_dbgmacros.h"
#include "vddgndef.h"
/*
 * Includes of function prototypes
 */
#include "v_drwproto.h"
#include "v_ioproto.h"

#ifdef	NOT_USED
#include "v_getmsgkey.h"
#endif

/* current line number set in  parser */
extern int	VDyydrwlineno ;

/* 
 * Keep current file name for use in error routines 
 */
static char 	CurrentFile [MAXPATHLEN] ;

/*----------------------------------------------------------------------------*/
/* return current file name */

char * VD_drwGetInputFileName () { return &(CurrentFile[0]); }

/*----------------------------------------------------------------------------*/
void VD_drwInitStackOfInputFiles( inputs ) VD_drwInputFiles *inputs ; {

	int	i ;

        SetProc( VD_drwInitStackOfInputFiles ); Begin

	inputs->iScanned = -1 ;
	CurrentFile[0] = '\0';

	for( i = 0 ; i < VD_K_DRW_MAXINFILES ; i++ ) {
		inputs->stream[i]	= NULL ;
		*inputs->name[i]	= '\0' ;
	}
	
	for( i = 0 ; i < VD_K_DRW_MAXSTORAGE ; i++ ) {
		*inputs->files[i]	= '\0' ;
	}
	inputs->nFiles	 = 0 ;
	inputs->storage = FALSE ;
	

} /* VD_drwInitStackOfInputFiles */
/*----------------------------------------------------------------------------*/
void VD_drwCloseInputFiles( inputs ) VD_drwInputFiles *inputs ; {

	int	i ;

        SetProc( VD_drwCloseInputFiles ); Begin

	for( i = 0 ; i < VD_K_DRW_MAXINFILES ; i++ ) {
		if( inputs->stream[i] ) fclose( inputs->stream[i] ) ;
	}

	VD_drwInitStackOfInputFiles( inputs ) ;
	End

} /* VD_drwCloseInputFiles */
/*----------------------------------------------------------------------------*/
int VD_drwPopInputFile( verbose, inputs )
	int		verbose ;
	VD_drwInputFiles *inputs ; 
{
	int	stackNotEmpty = FALSE ;

        SetProc( VD_drwPopInputFile ); Begin

	if( inputs->iScanned > 0 ) {
		/*
		 * Stack not empty: close currently opened file, then
		 * set previous file as Lex input if the currently
		 * opened files was not the last one.
		 */

		if( verbose && inputs->iScanned > 0 ) {
			VD_drwPrintf( "<<< Close %s\n",
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
			strcpy(CurrentFile, inputs->name[inputs->iScanned]);
			VD_setDrwConfigInput( inputs->stream[inputs->iScanned],
					     inputs->lineno[inputs->iScanned] );
			stackNotEmpty = TRUE ;
		}
	}

	End
	return stackNotEmpty ;

} /* VD_drwPopInputFile */
/*----------------------------------------------------------------------------*/
int VD_drwPushInputFile( infile, verbose, inputs )
	const char		*infile ;
	int			verbose ;
	VD_drwInputFiles 	*inputs ; 
{

	long	msg ;
	char	relPathName[MAXPATHLEN],
		absPathName[MAXPATHLEN],
		firstDir   [MAXPATHLEN] ;
	FILE	*newInput ;
	int	i ;

        SetProc( VD_drwPushInputFiles ); Begin

	if( verbose && inputs->iScanned >= 0 ) { 
		VD_drwPrintf( ">>> Open %s\n", infile ) ;
	}

	/*
	 * Is the maximum stacking limit exceeded ?
	 */
	if( inputs->iScanned >= VD_K_DRW_MAXINFILES - 1 ) {
		VD_drwParserError (verbose,
		       "Too many levels of nested include files, maximum: %d\n",
			    				VD_K_DRW_MAXINFILES ) ;
		goto error;
		}

	/*
	 * Look for file in current working directory, then in product path.
	 * (Beware that relative path may already have been prepended).
	 */
	if( !strncmp(	infile,
			VD_K_DRW_CONFIG_RELPATH,
			strlen( VD_K_DRW_CONFIG_RELPATH ) ) ) {
		strcpy( relPathName,
			infile + 1 + strlen( VD_K_DRW_CONFIG_RELPATH ) ) ;
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
	VD_findFileInDirOrProductPaths(	&msg,
					relPathName,
					firstDir,
					VD_K_DRW_CONFIG_RELPATH,
					absPathName ) ;

	if( !( msg & 1 ) ) {

		/* 
		 * initial setup file  - 
		 *	no logfile, write directly to stderr
		 */
		if (inputs->iScanned < 0) {
/*			fprintf (stderr, "\nSetup file not found1: %s\n",
								relPathName);
*/             
        /* tr179603559 */ 
	fprintf (stderr, "\n Visualization setup file for this view is  %s\n", 
		relPathName);
	fprintf (stderr, " Rename setup file or delete existing drawings and reprocess drawing.\n");
		}
		/* included setup file */
		else 
			VD_drwParserError (verbose, 
						"Include file not found: %s\n",
						relPathName);
		goto error;
		}

	/*
	 * Check that we are not going to open an already open file, which would
	 * mean that we are recursively including a file in itself.
	 */
	for( i = 0 ; i <= inputs->iScanned ; i++ ) {
		if( !strcmp( absPathName, inputs->name[i] ) ) {
			VD_drwParserError (verbose, 
					"Recursive inclusion of file '%s'\n",
				     			absPathName ) ;
			goto error;
			}
	}

	/*
	 * Now open that baby.
	 */
	newInput = VD_openFile( &msg, absPathName, "r" ) ;
	if( !( msg & 1 ) ) {
		VD_drwParserError (verbose, "Cannot open file %s: %s\n", 
							infile, absPathName ) ;
		goto error;
		}

	/*
	 * Save line number of the file being stacked.
	 */
	if( inputs->iScanned >= 0 ) {
		inputs->lineno[inputs->iScanned] = VDyydrwlineno ;
	}

	/*
	 * ... and push it onto the stack.
	 */
	inputs->iScanned++ ;
	strcpy( inputs->name[inputs->iScanned], absPathName ) ;
	strcpy( CurrentFile, absPathName ) ;
	inputs->stream[inputs->iScanned] = newInput ;

	/*
	 * Set Lex's input stream, the popping of this file will occur in
	 * `yywrap()' called when Lex encouters an EOF.
	 */
	VD_setDrwConfigInput( newInput, 1 ) ;

	/*
	 * Check if the total storage flag is activated.
	 * When this is the case we store the 'absPathName' of the file.
	 */
	if( inputs->storage ){

	  if( absPathName[0] == '.' ){
		/*
		 * File is found in local directory.
		 */
		IGRchar		*getenv();
		IGRchar		*curPwd = getenv( "PWD" );
		IGRchar		tmpPathName[MAXPATHLEN] ;

		sprintf( tmpPathName, "%s%s", curPwd, &(absPathName[1]) );
		strcpy( absPathName, tmpPathName );
	  }

	  __DBGpr_str(" absPathName ", absPathName );
		
	  for( i=0 ; i<inputs->nFiles && i<VD_K_DRW_MAXSTORAGE ; i++ ){
	    if( ! strcmp( absPathName, inputs->files[i] )) break ;
	  }
	  if( i==inputs->nFiles ){
	    strncpy( inputs->files[inputs->nFiles], absPathName, 
						    VD_K_DRW_MAXFILESTR -1 );
	    __DBGpr_str(" Storage ", inputs->files[inputs->nFiles] );
	    inputs->nFiles++ ;
	  }
	}

	End
	return TRUE ;

error:
	End
	return FALSE ;

} /* VD_drwPushInputFile */
/*----------------------------------------------------------------------------*/
int VD_dgnPushInputFile( infile, verbose, inputs )
        const char              *infile ;
        int                     verbose ;
        VD_drwInputFiles        *inputs ;
{

        long    msg ;
        char    relPathName[MAXPATHLEN],
                absPathName[MAXPATHLEN],
                firstDir   [MAXPATHLEN] ;
        FILE    *newInput ;
        int     i ;

        SetProc( VD_dgnPushInputFiles ); Begin

        if( verbose && inputs->iScanned >= 0 ) {
                VD_drwPrintf( ">>> Open %s\n", infile ) ;
        }

        /*
         * Is the maximum stacking limit exceeded ?
         */
        if( inputs->iScanned >= VD_K_DRW_MAXINFILES - 1 ) {
                VD_drwParserError (verbose,
                       "Too many levels of nested include files, maximum: %d\n",
                                                        VD_K_DRW_MAXINFILES ) ;
                goto error;
                }

        /*
         * Look for file in current working directory, then in product path.
         * (Beware that relative path may already have been prepended).
         */
        if( !strncmp(   infile,
                        VD_K_DGN_CONFIG_RELPATH,
                        strlen( VD_K_DGN_CONFIG_RELPATH ) ) ) {
                strcpy( relPathName,
                        infile + 1 + strlen( VD_K_DGN_CONFIG_RELPATH ) ) ;
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
                char *prevScanned       = inputs->name[inputs->iScanned] ;
                char *lastSlash         = strrchr( prevScanned, '/' ) ;

                *lastSlash = '\0' ;
                strcpy( firstDir, prevScanned ) ;
                *lastSlash = '/' ;
        } else {
                strcpy( firstDir, "." ) ;
        }
        VD_findFileInDirOrProductPaths( &msg,
                                        relPathName,
                                        firstDir,
                                        VD_K_DGN_CONFIG_RELPATH,
                                        absPathName ) ;

        if( !( msg & 1 ) ) {

                /*
                 * initial setup file  -
                 *      no logfile, write directly to stderr
                 */
                if (inputs->iScanned < 0) {
                      fprintf (stderr, "\nSetup file not found1: %s\n",
                                                                relPathName);
                }
                /* included setup file */
                else
                        VD_drwParserError (verbose,
                                                "Include file not found: %s\n",
                                                relPathName);
                goto error;
                }

        /*
         * Check that we are not going to open an already open file, which would
         * mean that we are recursively including a file in itself.
         */
        for( i = 0 ; i <= inputs->iScanned ; i++ ) {
                if( !strcmp( absPathName, inputs->name[i] ) ) {
                        VD_drwParserError (verbose,
                                        "Recursive inclusion of file '%s'\n",
                                                        absPathName ) ;
                        goto error;
                        }
        }

        /*
         * Now open that baby.
         */
        newInput = VD_openFile( &msg, absPathName, "r" ) ;
        if( !( msg & 1 ) ) {
                VD_drwParserError (verbose, "Cannot open file %s: %s\n",
                                                        infile, absPathName ) ;
                goto error;
                }

        /*
         * Save line number of the file being stacked.
         */
        if( inputs->iScanned >= 0 ) {
                inputs->lineno[inputs->iScanned] = VDyydrwlineno ;
        }

        /*
         * ... and push it onto the stack.
         */
        inputs->iScanned++ ;
        strcpy( inputs->name[inputs->iScanned], absPathName ) ;
        strcpy( CurrentFile, absPathName ) ;
        inputs->stream[inputs->iScanned] = newInput ;

        /*
         * Set Lex's input stream, the popping of this file will occur in
         * `yywrap()' called when Lex encouters an EOF.
         */
        VD_setDrwConfigInput( newInput, 1 ) ;

        /*
         * Check if the total storage flag is activated.
         * When this is the case we store the 'absPathName' of the file.
         */
        if( inputs->storage ){
          if( absPathName[0] == '.' ){
                /*
                 * File is found in local directory.
                 */
                IGRchar         *getenv();
                IGRchar         *curPwd = getenv( "PWD" );
                IGRchar         tmpPathName[MAXPATHLEN] ;

                sprintf( tmpPathName, "%s%s", curPwd, &(absPathName[1]) );
                strcpy( absPathName, tmpPathName );
          }

          __DBGpr_str(" absPathName ", absPathName );

          for( i=0 ; i<inputs->nFiles && i<VD_K_DRW_MAXSTORAGE ; i++ ){
            if( ! strcmp( absPathName, inputs->files[i] )) break ;
          }
          if( i==inputs->nFiles ){
            strncpy( inputs->files[inputs->nFiles], absPathName,
                                                    VD_K_DRW_MAXFILESTR -1 );
            __DBGpr_str(" Storage ", inputs->files[inputs->nFiles] );
            inputs->nFiles++ ;
          }
        }

        End
        return TRUE ;

error:
        End
        return FALSE ;

} /* VD_dgnPushInputFile */


