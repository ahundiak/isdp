/* $Id: VDdbgFile.C,v 1.1.1.1 2001/01/04 21:08:57 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdmisc/ VDdbgFile.C
 *
 * Description:
 *  	Functions to write vds.dbg file
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdbgFile.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:57  cvs
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
 * Revision 1.2  1996/05/16  21:23:10  pinnacle
 * Replaced: vdmisc/VDdbgFile.C for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1996/05/15  23:14:10  pinnacle
 * Created: vdmisc/VDdbgFile.C by tlbriggs for vds.240
 *
 *
 * History:
 *	05/13/96     tlb	Created from vddb/source/VDSdbdbg.c
 *				Change VDSdebug to variable length
 *	05/16/96     tlb	Fix error formats
 *
 * -------------------------------------------------------------------*/

#include	<stdio.h>
#include	<string.h>

#ifdef ENV5
#include <stdarg.h>
#endif
#ifdef X11
#include <varargs.h>
#include <stdarg.h>
#endif

#include	"OMtypes.h"		/* TRUE, FALSE */
#include  	"SQLmsg.h"
#include  	"MEMerrordef.h"
#include 	"ERR.h"
#include 	"ERRproto.h"
#include  	"VDdbgFile.h" 

/* 
 * Global debug flags
 */
int     VDSdebug_on;		/* debug toggle */
int     VDSsqlDebug_on;		/* SQL debug toggle */


/*---------------------------------------------------------------------*/
/* Private: VDSopenDebugFile
 *	open debug file - caller must close
 *	returns TRUE/FALSE
 */
static 
int VDSopenDebugFile (FILE **dbgfile)
{
	if ( VDSdebug_on) {
		if (( *dbgfile = fopen (VDS_DEBUG_FILE, "a")) == NULL) {
			fprintf (stderr, "Error: cannot open debug file: %s\n",
						VDS_DEBUG_FILE);
			return ( FALSE );
			}
		return (TRUE);
		}
	return (FALSE);
}
/*---------------------------------------------------------------------*/
/* VDSdebug
 *	if VDSdebug_on - write string to VDS_DEBUG_FILE
 *	file opened/closed to conform to NFM debug usage
 *		since VDS_DEBUG_FILE is also used for MEMprint_buffer
 */
void   VDSdebug (va_alist)
		/* 	char *fmt, 	 format string 
	 	 *	     ....args
		 */
va_dcl
{
	va_list	args;
	char	*fmt;
	FILE	*outfile ;

	va_start (args, 0);
		if (VDSopenDebugFile (&outfile)) {
			fmt = va_arg(args, char* );
			vfprintf ( outfile, fmt, args);
			fclose (outfile);
			}
	 va_end( args ) ;
}
/*---------------------------------------------------------------------*/
/* VDSsqlDebug
 *	if VDSsqlDebug_on - write SQL string to VDS_DEBUG_FILE
 *	file opened/closed to conform to NFM debug usage
 *		since VDS_DEBUG_FILE is also used for MEMprint_buffer
 */
void   VDSsqlDebug(char *s)
{
	FILE	*outfile;

	if (VDSopenDebugFile (&outfile)) {
		fputs ("SQL: ", outfile);
		fputs (s, outfile);
		fputc ('\n', outfile);
		fclose (outfile);
		}
}
/*---------------------------------------------------------------------*/
/* VDSprintUsrMsg
 *	print message to user screen and 
 *		if debug is on -  also to the logfile
 */
void VDSprintUsrMsg(	va_alist )
		/* 	char *fmt, 	 format string 
	 	 *	     ....args
		 */
va_dcl
{
	va_list	args;
	char	*fmt;
	FILE	*outfile;

	va_start (args, 0);
		fmt = va_arg(args, char* );
		vprintf ( fmt, args);
		fflush (stdout);
		
		if (VDSopenDebugFile (&outfile)) {
			vfprintf ( outfile, fmt, args);
			fclose (outfile);
			}
	 va_end( args ) ;
}
/*---------------------------------------------------------------------*/
/* VDSprintDbgMsg
 *	if debug is on - print message to screen and logfile
 */
void VDSprintDbgMsg(	va_alist)
		/* 	char *fmt, 	 format string 
	 	 *	     ....args
		 */
va_dcl
{
	va_list	args;
	char	*fmt;
	FILE	*outfile;

	va_start (args, 0);
		if ( VDSdebug_on )  {
			fmt = va_arg(args, char* );
			vprintf ( fmt, args);
			fflush (stdout);
		
			if (VDSopenDebugFile (&outfile)) {
				vfprintf ( outfile, fmt, args);
				fclose (outfile);
				}
			}
	va_end( args ) ;
}

/*---------------------------------------------------------------------*/
/* VDSprintErr
 *	print error message to user screen and 
 *		if debug is on -  also to the logfile
 *	
 *	Screen 	: "<prefix> Error: <msg>"
 *	Logfile : "ERROR: <msg>"
 *
 */
void VDSprintErr(	va_alist )
		/* 	char * prefix,
		 * 	char *fmt, 	 format string 
	 	 *	     ....args
		 */
va_dcl
{
	va_list	args;
	char	*fmt, *prefix;
	FILE	*outfile;

	va_start (args, 0);
		prefix = va_arg(args, char* );
		fmt = va_arg(args, char* );
		printf ( "%sError: ", prefix);
		vprintf ( fmt, args);
		fflush (stdout);
		
		if (VDSopenDebugFile (&outfile)) {
			fprintf ( outfile, "ERROR: ");
			vfprintf ( outfile, fmt, args);
			fclose (outfile);
			}
	 va_end( args ) ;
}
/* --------------------------------------------------------------------------
 * Error report system for SQLstmt routines ....
 *	Improved SQL error descriptions over NFM versions
 */

#define	ERRTYPE( t, s ) case t: errStr = s ; break ;

char * 
VDSgetSqlErrStr( int sts )
{
  char	*errStr ;
   static char buf[100];

  switch( sts ){

    ERRTYPE( SQL_E_CLEAR	,"Error in clearing dynamic statement" )
    ERRTYPE( SQL_E_CLOSE       	,"Error in closing a cursor" )
    ERRTYPE( SQL_E_CURSOR      	,"Error in opening a cursor" )
    ERRTYPE( SQL_E_DATA_TYPE   	,"Unknown data type" )
    ERRTYPE( SQL_E_DECLARE     	,"Error in declaring the datatype" )
    ERRTYPE( SQL_E_DESCRIBE    	,"Error in describing the output variables" )
    ERRTYPE( SQL_E_DUPLICATE_VALUE  
				,"Duplicate value in the unique index column" )
    ERRTYPE( SQL_E_DUP_ATTR_NAME
				,"Duplicate columns in the query" )
    ERRTYPE( SQL_E_EXECUTE 	,"Error in executing the query" )
    ERRTYPE( SQL_E_FETCH       	,"Error in fetching the answer" )
    ERRTYPE( SQL_E_FORMAT_MISMATCH  
				,"Format Mismatched in the query" )
    ERRTYPE( SQL_E_INVALID_LOCK_TABLES
			,"Lock table should be first statement in transaction" )
    ERRTYPE( SQL_E_MALLOC    	
			,"Could not allocate memory during SQL operation" )
    ERRTYPE( SQL_E_MEM         	,"Error occurred while attempting to process a memory structure during an SQL operation" )

/*
    ERRTYPE( SQL_E_MESSAGE     	,"Error in message translation: try to update statistics on Informix database" )
*/

    ERRTYPE( SQL_E_NOT_QUERY   	,"Not a valid SQL query" )
    ERRTYPE( SQL_E_NOT_STMT     ,"Not a valid SQL statement" )
    ERRTYPE( SQL_E_NO_FORMAT_MISMATCH 
				,"Format Mismatched in the query" )
    ERRTYPE( SQL_E_OPEN         ,"Error while opening the RIS schema " )
    ERRTYPE( SQL_E_PREPARE      ,"Error in preparing the SQL statement" )
    ERRTYPE( SQL_E_TABLE_EXISTS ,"Table already exists" )
    ERRTYPE( SQL_E_UNKNOWN_COLUMN   
				,"Unknown column in the query" )

    ERRTYPE( SQL_E_UNKNOWN_RELATION 
			,"Referenced table unknown or no access to operation" )
    ERRTYPE( SQL_E_INVALID_DATE	,"Invalid Date in the query" )

    ERRTYPE( SQL_I_NO_ROWS_FOUND
			,"No rows found which satisfy the given condition" )
    ERRTYPE( SQL_I_NO_MORE_DATA ,"No more data can be returned" )
    ERRTYPE( SQL_S_SUCCESS      ,"Successful completion" )

    case  SQL_E_MESSAGE: 
			ERRget_specific_message(SQL, buf);
			errStr=buf;
			break;
    default :		
		sprintf (buf, "Unknown SQL error: 0x%x", sts);
		errStr = buf;
    }
    return errStr;
}
/*------------------------------------------------------------------------*/
/* MEM subsystem error messages
 *	NFM does not provide descriptions of MEM errors
 */ 
char * 
VDSgetMemErrStr( int sts )
{
  char	*errStr ;
   static char buf[100];

  switch( sts ){
    ERRTYPE( MEM_E_BAD_BUFFER_NO,	"invalid buffer number")
    ERRTYPE( MEM_E_BAD_DATA_WRITTEN,    "invalid data written in buffer")
    ERRTYPE( MEM_E_BAD_STRING,          "non-printable characters are not allowed in data")
    ERRTYPE( MEM_E_CORRUPTED_BUFFER,	"corrupted buffer")
    ERRTYPE( MEM_E_DATA_TYPE,		"invalid data type")
    ERRTYPE( MEM_E_DATA_WRITTEN,	"error while writing data")
    ERRTYPE( MEM_E_EXTRA_DATA,          "extra data")
    ERRTYPE( MEM_E_INVALID_SIZE,	"invalid size")
    ERRTYPE( MEM_E_LESS_DATA,           "less data")
    ERRTYPE( MEM_E_MALLOC,              "error while allocating memory")
    ERRTYPE( MEM_E_NULL_BUFFER,         "null buffer")
    ERRTYPE( MEM_E_NULL_COLUMNS,        "null columns")
    ERRTYPE( MEM_E_NULL_LIST,           "null list")
    ERRTYPE( MEM_E_NULL_ROWS,           "null rows")
    ERRTYPE( MEM_E_NULL_SRC_BUFFER,     "null source buffer")
    ERRTYPE( MEM_E_NULL_SRC_LIST,	"null source list") 
    ERRTYPE( MEM_E_UNIX,		"UNIX call failed during operation")

    ERRTYPE( MEM_S_SUCCESS,		"Successful completion")
    default :		
		sprintf (buf, "Unknown MEM error: 0x%x", sts);
		errStr = buf;
    }
    return errStr;
}

