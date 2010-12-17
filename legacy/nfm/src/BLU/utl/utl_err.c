#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <stdarg.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "UMS.h"
/*
#include "pums_pub.h"
*/
#include "utl.h"

char utl_err_buf[512];		/* Last error message text */
void (*screen_msg_cb)();
FILE    *err_log_fp = NULL;

char *_strdate( buf )
char *buf;
{
time_t t;
struct tm *tms;

t = time(0);
tms = localtime(&t);
sprintf( buf, "%.2d/%.2d/%.2d", tms->tm_mon+1, tms->tm_mday, tms->tm_year);
return( buf );
} /* end of _strdate() */

char *_strtime( buf )
char *buf;
{
time_t t;
struct tm *tms;

t = time(0);
tms = localtime(&t);
sprintf( buf, "%.2d:%.2d:%.2d", tms->tm_hour, tms->tm_min, tms->tm_sec);
return( buf );
} /* end of _strtime() */

/******************************************************************************
Doc: utl_set_screen_error_callback

	Copyright (c) 1993
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: utl_err.c

Author: Mike Furno

Date: June 15, 1993

SDM Number:

Description: This function sets the callback function to be used to display
        error messages to the screen.

Examples:
            utl_set_screen_error_callback ( scr_err_func );

Return Status: none

History:
******************************************************************************/
void utl_set_screen_error_callback ( callback )
void    (*callback)();      /* i - Function to be called to display error messages */
{
    screen_msg_cb = callback;
} /* end of utl_set_screen_error_callback() */

/******************************************************************************
Doc: utl_open_error_log

	Copyright (c) 1993
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: utl_err.c

Author: Mike Furno

Date: June 15, 1993

SDM Number:

Description: This function opens the file which will be used to write error
        messages.

Examples:
            utl_open_error_log ( err_log )

Return Status:
        0  -  success
        -1 -  failure

History:
******************************************************************************/
utl_open_error_log ( err_log )
char    *err_log;       /* i - Name of the file to open */
{
    long    sts;

    /* Just return if already opened */
    if( err_log_fp )
      return( 0 );

    err_log_fp = fopen ( err_log, "w" );
    if ( ! err_log_fp )
        sts = -1;
    else
        sts = 0;

    return ( sts );
} /* end of utl_open_error_log() */

/******************************************************************************
Doc: utl_close_error_log

	Copyright (c) 1993
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: utl_err.c

Author: Mike Furno

Date: June 15, 1993

SDM Number:

Description: This function closes the error log file.

Examples:
            utl_close_error_log ( );

Return Status: none

History:
******************************************************************************/
void utl_close_error_log ()
{
    if ( err_log_fp )
        fclose ( err_log_fp );

    err_log_fp = 0;
} /* end of utl_close_error_log() */

utl_get_severity ( msg_num )
long    msg_num;
{
    long    end_bits, severity;

    end_bits = msg_num & 7; /* only use last 3 bits */
    switch ( end_bits )
    {
        case 4:
            severity = UTL_FATAL_MSG;
            break;
        case 2:
        case 6:
            severity = UTL_ERROR_MSG;
            break;
        case 0:
            severity = UTL_WARNING_MSG;
            break;
        case 7:
        case 3:
            severity = UTL_WARNING_MSG;
            break;
        case 1:
            severity = UTL_WARNING_MSG;
            break;
    }
    return ( severity );
} /* end of utl_get_severity() */

void utl_process_error_var ( long msg_num, short output_flag, char *file, 
			long line_no, char *fmt, ... )
{
	va_list	vars;
	char	*err_buf=utl_err_buf, code[50], buf[10], buf1[10];
	short	sts;

        va_start ( vars, fmt );

	/*  Read ums message into buffer */
        sts = UMSGetByNumVar ( err_buf, msg_num, fmt, vars );

	/* Just copy message from format if message number is 0 */
	if( msg_num == 0 )
	    strcpy( err_buf, fmt );

	code[0] = 0;
        if ( err_log_fp && output_flag & UTL_LOG_MSG )
        {
	    if( msg_num )
	      UMSMsgCode ( code, msg_num, 0, NULL, NULL, NULL );
	    fprintf ( err_log_fp, 
	        "\n\n**************************************************************\n"
		 );
	    fprintf ( err_log_fp, "%s  %s\n", code, err_buf );
	    fprintf ( err_log_fp, "Source File = %s   Line number = %d  Date:  %s %s\n", 
		file, line_no, _strdate(buf), _strtime(buf1) );
	    fprintf ( err_log_fp, 
	        "**************************************************************\n\n"
		);
            fflush ( err_log_fp );
        }
	if ( (output_flag & UTL_SCREEN_MSG) && screen_msg_cb )
	{
		/*  Display the message on the screen */
		if( msg_num == 0 ) msg_num = 2;
		screen_msg_cb ( err_buf, utl_get_severity(msg_num) );
	}

        va_end ( vars );
} /* end of utl_process_error_var() */

void utl_process_error ( long msg_num, short output_flag, char *file, 
			long line_no, char *fmt, va_list vars )
{
	char	*err_buf=utl_err_buf, code[50], buf[10], buf1[10];
	short	sts;


	/*  Read ums message into buffer */
        sts = UMSGetByNumVar ( err_buf, msg_num, fmt, vars );

	/* Just copy message from format if message number is 0 */
	if( msg_num == 0 )
	    strcpy( err_buf, fmt );

	code[0] = 0;
        if ( err_log_fp && output_flag & UTL_LOG_MSG )
        {
	    if( msg_num )
	      UMSMsgCode ( code, msg_num, 0, NULL, NULL, NULL );
	    fprintf ( err_log_fp, 
	        "\n\n**************************************************************\n"
		 );
	    fprintf ( err_log_fp, "%s  %s\n", code, err_buf );
	    fprintf ( err_log_fp, "Source File = %s   Line number = %d  Date:  %s %s\n", 
		file, line_no, _strdate(buf), _strtime(buf1) );
	    fprintf ( err_log_fp, 
	        "**************************************************************\n\n"
		);
            fflush ( err_log_fp );
        }
	if ( (output_flag & UTL_SCREEN_MSG) && screen_msg_cb )
	{
		/*  Display the message on the screen */
		if( msg_num == 0 ) msg_num = 2;
		screen_msg_cb ( err_buf, utl_get_severity(msg_num) );
	}
} /* end of utl_process_error() */

void utl_error_stack ( src_file, line_num )
char    *src_file;
long    line_num;
{
    char    buf[10], buf1[10];
    
	    if(!err_log_fp) return;

	    fprintf ( err_log_fp, 
	        "**************************************************************\n"
		 );
	    fprintf ( err_log_fp, "ERROR TRACE\n"  );
	    fprintf ( err_log_fp, "Source File = %s   Line number = %d  Date:  %s %s\n", 
		src_file, line_num, _strdate(buf), _strtime(buf1) );
	    fprintf ( err_log_fp, 
	        "**************************************************************\n\n"
                );
            fflush ( err_log_fp );
} /* end of utl_error_stack() */

utl_get_tmp_path ( path_name )
char    *path_name;
{
    static  char    tmp_path[257];
    char    *path_ptr;
    long    sts = 0;
    
    if ( ! tmp_path[0] )
    {
#ifdef winNT
        path_ptr = getenv ( "TEMP" );
        if ( ! path_ptr )
        {
            path_ptr = getenv ("DMVIEW");
            if ( ! path_ptr )
                sts = -1;
	    else
		strcpy ( tmp_path, path_ptr );
        }
        else
            strcpy ( tmp_path, path_ptr );
#else
	struct stat sb;

	path_ptr = getenv ( "TMPDIR" );

	if ( ! path_ptr )
		path_ptr = "/usr/tmp";

	/* If path does not exist, default to /usr/tmp */
	if( stat( path_ptr, &sb ) )
		path_ptr = "/usr/tmp";
	else
	{
		/* If it's not a directory, default to /usr/tmp */
		if( ! (sb.st_mode & 040000) )
		{
			path_ptr = "/usr/tmp";
		}
	}

	strcpy ( tmp_path, path_ptr );
#endif
    }

    if ( ! sts )
        strcpy ( path_name, tmp_path );

    return ( sts );
} /* end of utl_get_tmp_path() */
