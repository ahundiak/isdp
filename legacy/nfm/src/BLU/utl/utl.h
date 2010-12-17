/******************************************************************************

Doc:	utl.h

	Copyright (c) 1992
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source:	iml.h

Author:	Jeff Silvaggi

Date:	23-NOV-1992

Description:	This header file describes standard macros and structures used
	by the UTL library.

History:
******************************************************************************/
#ifndef _UTL_H
#define _UTL_H

#include <stdarg.h>

/* DM Supported file types */
#define UTL_RASTER	1
#define UTL_IGDS	2
#define UTL_DWG		3
#define UTL_ASCII	4
#define UTL_UNKNOWN	5

#define UTL_INDENT	0
#define UTL_SAMELVL	1
#define UTL_CONTINUE	2
#define UTL_UNINDENT	99

typedef struct
{
  long fp;				/* Debug file pointer */
  long lvls;				/* Level */
} utl_dbg_str;

#define UTL_LOG_MSG 1
#define UTL_SCREEN_MSG  2
#define UTL_BOTH_MSG    3

#define UTL_FATAL_MSG       0
#define UTL_ERROR_MSG       1
#define UTL_WARNING_MSG     2
#define UTL_INFO_MSG        3
#define UTL_SUCCESS_MSG     4

#define UTL_UI_ALL	    0xff
#define UTL_UI_MBAR	    0x01	/* menu bar */
#define UTL_UI_TBAR	    0x02	/* tool bar */
#define UTL_UI_SBAR	    0x03	/* status bar */
#define UTL_UI_TBOX	    0x04	/* tool box */
#define UTL_UI_RIBB	    0x05	/* ribbon */

extern void utl_error_stack ( char *file_name, long line_no );
extern void utl_set_screen_error_callback ( void (*callback)() );
extern int utl_open_error_log ( char *err_log );
extern void utl_close_error_log (void );
extern void utl_process_error_var ( long msg_num, short output_flag, char *file, 
			long line_no, char *fmt, ... );
void utl_process_error ( long msg_num, short output_flag, char *file, 
			long line_no, char *fmt, va_list vars );

#define UTL_ERROR_STACK()  utl_error_stack ( __FILE__, __LINE__ );

#define UTL_ERROR_STACK_STS(sts) if (sts) utl_error_stack ( __FILE__, __LINE__ );

#define UTL_MAX_RESOURCES	32	/* Maximum number of remote drives */
#define UTL_RESRC_KEY	0xabcdef10	/* Mounted resource shared memory key */

typedef struct utl_resources		/* Table of mounted remote file systems */
{
	char	lock;			/* Mount lock: 1=Locked  0=Available */

	struct utl_mpts
	{
	  char	node[16];		/* Node name */
	  char	net_addr[30];		/* Net address */
	  char	r_filsys[16];		/* Remote file system name */
	  char	l_filsys[16];		/* Local file system name */
	} utl_mpts[ UTL_MAX_RESOURCES ];
} utl_resources;

#define utldbg if( utl_dbg ) utl_print_debug
extern long utl_dbg;
extern void utl_command_msg(char *msg);
extern void utl_prompt_msg(char *msg);

#endif
