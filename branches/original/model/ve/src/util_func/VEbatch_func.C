
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $
*/

#define CHECK_RETURN_CODES 1

#if defined (__STDC__) /* L_cuserid is not defined in ANSI C. */
#define L_cuserid   9  /* Value obtained from stdio.h if !(__STDC__) section */
#endif

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <time.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "OMprimitives.h"

#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"

#include "exdef.h"
#include "ex.h"
#include "exmacros.h"

#include "igewindef.h"
#include "igewinmacros.h"
#include "igecolordef.h"
#include "igecolmacros.h"

#include "msdef.h"
#include "msmacros.h"

#include "igecolor.h"

#include "bs.h"
#include "bsparameters.h"

#include "gr.h"

#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "grdpbdef.h"

#include "godef.h"
#include "go.h"

#include "vedef.h"
#include "ve.h"
#include "veerr.h"
#include "vemsg.h"

#include "hsmacros.h"

/*#include "cctspec.h"*/

/* prototype files */
#include "VEpr_utilfnc.h"


#include "DPsetinq.h"
#include "DPgetggid.h"

/* prototypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static IGRboolean VEread_line_from_file __((
					FILE        *fp,
					IGRchar     *line ));

#if defined(__cplusplus)
}
#endif

#undef __


/* Global Variables Used By VE */
extern struct VEresults_info VEoutput_data;
extern struct GRmd_env       VEmaster_env;


/*--- VEread_line_from_file --------------------------------------------------------------*/

static IGRboolean VEread_line_from_file( fp, line )

	FILE *fp;
	IGRchar *line;

/*
NAME
	VEread_line_from_file (static)

DESCRIPTION
	This function reads a line from the file 'fp' and stores it in
	'line'.  If a line was successfully read, TRUE is returned.
	Leading white-space is skipped, so lines with only white space
	characters are skipped.

PARAMETERS
	fp (IN) - the file to read from
	line (OUT) - the line that was read as a NULL terminated string

GLOBALS USED
	none

RETURN VALUES
	TRUE - a line was successfully read
	FALSE - otherwise

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRchar    c;
	IGRboolean end_of_file;
	IGRint     count;

	/* read until a non-white space character is found */
	c = getc( fp );
	while ( ! (end_of_file = feof(fp)) )
	   {
	   if ( (c != ' ') && (c != '\t') && (c != '\n') )
	      break;
	   c = getc( fp );
	   }

	if ( ! end_of_file )
	   {
	   /* read until new line or end of file found */
	   line[0] = c;
	   count = 1;
	   c = getc( fp );
	   while ( !feof(fp) )
	      {
	      if ( c == '\n' )
	         break;

	      line[count++] = c;
	      c = getc( fp );
	      }  /* end: while */

	   line[count] = '\0';
	   return( TRUE );
	   }
	else
	   return( FALSE );

	}  /* VEread_line_from_file */


/*--- VEparse_log_file_for_status -------------------------------------------------------*/

void VEparse_log_file_for_status( filename, start_time, num_processing, num_activated, num_completed,
	                          num_minutes, num_seconds )

	IGRchar *filename;
	IGRchar *start_time;
	IGRint  *num_processing, *num_activated, *num_completed, *num_minutes, *num_seconds;

/*
NAME
	VEparse_log_file_for_status

DESCRIPTION
	This function parses a background job log file for its status
	information.  The status information that is found is:  start time,
	number of elements to be processed, number of elements activated,
	number of elements completed, number of minutes elapsed and number of
	seconds elapsed.

PARAMETERS
	filename (IN) - the name of the log file to parse
	start_time (OUT) - the start time of the batch job on the server
	num_processing (OUT) - the number of elements being processed
	num_activated (OUT) - the number of elements activated so far
	num_completed (OUT) - the number of elements completed so far
	num_minutes (OUT) - the number of minutes the job has been running
	num_seconds (OUT) - the number of seconds the job has been running

GLOBALS USED
	none

HISTORY
	12/15/89    S.P. Rogers
	   Creation Date
*/

	{
	IGRchar activated_string[100], completed_string[100];
	IGRchar format_string[200];
	IGRchar line[255];
	IGRchar msg_buff[255];
	IGRint  length;
	FILE    *fp;
	
	start_time[0] = '\0';
	*num_processing = *num_activated = *num_completed = *num_minutes = *num_seconds = 0;
	
	fp = fopen( filename, "r" );
	if ( fp == NULL )
	   return;

	/* look for START TIME line */
	length = strlen( "START TIME:" );
	while ( VEread_line_from_file( fp, line ) )
	   {
	   if ( strncmp( line, "START TIME:", length ) == 0 )
	      {
	      /* this line is the START TIME: line */
	      strcpy( start_time, &line[length+1] );
	      break;
	      }
	   }

	if ( strlen( start_time ) == 0 )
	   {
	   /* job hasn't started yet */
	   fclose( fp );
	   return;
	   }

	/* look for "Processing XXX total elements" line */
	ex$message( msgnumb = VE_I_Processing,
	            type    = "%s",
	            var     =`"%d"`,
	            buff    = msg_buff );
	
	while ( VEread_line_from_file( fp, line ) )
	   {
	   if ( sscanf( line, msg_buff, num_processing) == 1 )
	     break;
	   }

	if ( *num_processing == 0 )
	   {
	   /* VE is still sorting the input elements */
	   fclose( fp );
	   return;
	   }

	/* get last line of file */
	while ( VEread_line_from_file( fp, line ) );

	/* get the strings that will be in the file */
	ex$message( msgnumb = VE_I_Activated, buff = activated_string );
	ex$message( msgnumb = VE_I_Completed, buff = completed_string );

	ex$message( msgnumb = VE_I_ElapsedTime,
	            type    = "%s%s",
	            var     = `"%d","%d"`,
	            buff    = msg_buff );

	sprintf( format_string, "%s %s, %s %s   %s\n",
	         "%d", activated_string, "%d", completed_string, msg_buff );

	sscanf( line, format_string, num_activated, num_completed, num_minutes, num_seconds );

	fclose( fp );
	}  /* VEparse_log_file_for_status */


/*--- VEget_directory_names --------------------------------------------------------*/

IGRboolean VEget_directory_names( working_dir, working_dir_size,
	                          support_dir, support_dir_size, 
	                          cur_filename, cur_filename_size )

	IGRchar *working_dir;
	IGRint  working_dir_size;
	IGRchar *support_dir;
	IGRint  support_dir_size;
	IGRchar *cur_filename;
	IGRint  cur_filename_size;

/*
NAME
	VEget_directory_names

DESCRIPTION
	This function gets the directory names required to spawn a batch
	job.

PARAMETERS
	working_dir (OUT) - the directory that the current master file is in
	working_dir_size (IN) - the size of the working dir array
	support_dir (OUT) - the directory where the EMS is located
	                    (i.e, /usr3/ip32)
	support_dir_size (IN) - the size of the support dir array
	cur_filename (OUT) - the name of the current master file
	cur_filename_size (IN) - the size of the cur filename array

GLOBALS USED
	none

RETURN VALUES
	TRUE - if everything was successful
	FALSE - if a failure occurred

HISTORY
	08/24/88    S.P. Rogers
	   Creation Date
	01/31/92    S.P. Rogers
	   Switched from ex$global() to individual macros
*/

	{
	if ( ! ex$filename( name = cur_filename, len = cur_filename_size ) )
	   {
	   return( FALSE );
	   }

	if ( ! ex$get_working_dir( name = working_dir, len = &working_dir_size ) )
	   {
	   return( FALSE );
	   }

	if ( ! ex$get_support_dir( name = support_dir, len = &support_dir_size ) )
	   {
	   return( FALSE );
	   }

	return( TRUE );
	}  /* VEget_directory_names */


/*--- VEgenerate_unique_name --------------------------------------------------------*/

void VEgenerate_unique_name( node_name, unique_name )

	IGRchar *node_name;
	IGRchar *unique_name;
/*
NAME
	VEgenerate_unique_name

DESCRIPTION
	This function constructs a unique file name that has the
	format: xxxxyyyyyy  where

	   xxxx  - are the unique characters from the machines network address
	           (i.e., 08-00-36-xx-xx-00).  The network address is determined
	           by reading the file corresponding to the machine's node name
	           from the /usr/lib/nodes/owned directory.  If the network
	           address can't be determined from
	           /usr/lib/nodes/owned/node_name, then the last four
	           characters of the node name are used for the unique
	           characters.

	   yyyyyy - are the last six characters of the string that represents
	            the number of seconds that have elapsed since Jan 1, 1970.

PARAMETERS
	node_name (IN) - the node name of the machine
	unique_name (OUT) - the unique name

GLOBALS USED
	none

HISTORY
	08/24/88    S.P. Rogers
	   Creation Date
*/

	{
	IGRchar     ch;
	IGRchar     filename[60];
	IGRchar     string[132];
	IGRchar     *node_string;
	IGRchar     *search_string;
	IGRchar     gmt_string[30];
	IGRboolean  eof_found;
	IGRshort    found;
	IGRint      i;
	IGRint      cnt;
	time_t      gmt;
	FILE        *fp;
	

	/* open the network address file and find the    */
	/* line that contains the network address string */

	search_string = "Address";
	eof_found = FALSE;
	found = FALSE;

	sprintf( filename, "/usr/lib/nodes/owned/%s", node_name );
	fp = fopen( filename, "r" );
	
	if ( fp )
	   {
	   do
	     {
	     /* read to the next new-line character */
	     cnt = 0;
	     ch = getc( fp );
	     while (ch != '\n')
	        {
	        string[cnt++] = ch;
	        ch = getc( fp );
	        if ( feof( fp ) )
	           {
	           eof_found = TRUE;
	           break;
	           }
	        }
	     string[cnt++] = '\0';

	     /* see if the search_string is contained in this line */
	     for ( i = 0; i < cnt - strlen( search_string ); i++ )
	        {
	        if ( strncmp( &string[i], search_string, strlen( search_string ) ) == 0 )
	           {
	           found = TRUE;
	           break;
	           }
	        }
	     }
	   while ( (!found) && (!eof_found) );

	   fclose( fp );
	   }  /* end: if ( fp ) */

	if ( found )
	   {
	   /* the Network Address was found */

	   /* skip the first 3 dashes of the Network Address */
	   node_string = string;
	   for ( i = 0; i < 3; i++ )
	      {
	      node_string = strchr( node_string, '-' );
	      node_string++;
	      }

	   /* copy out the 4 characters that we want */
	   unique_name[0] = node_string[0];
	   unique_name[1] = node_string[1];

	   unique_name[2] = node_string[3];
	   unique_name[3] = node_string[4];
	   }
	else
	   {
	   /* attemp to find network address failed => use last 4 chars of node name instead */
	   strncpy( unique_name, &node_name[strlen(node_name)-4], 4 );
	   }
	
	unique_name[4] = '\0';
	
	/* append elapsed seconds stamp to string */
	gmt = time( NULL );
	sprintf( gmt_string, "%d", gmt );
	strcat( unique_name, &gmt_string[strlen(gmt_string)-6] );

	}  /* VEgenerate_unique_name */


/*--- VEcreate_log_file --------------------------------------------------------*/

FILE *VEcreate_log_file( working_dir, unique_name, node_name, orig_name,
                         view_name, server_name, results_name )

	IGRchar *working_dir;
	IGRchar *unique_name;
	IGRchar *node_name;
	IGRchar *orig_name;
	IGRchar *view_name;
	IGRchar *server_name;
	IGRchar *results_name;

/*
NAME
	VEcreate_log_file

DESCRIPTION
	This function creates the log file used for logging information
	about the batch job.

PARAMETERS
	working_dir (IN) - the directory to put the log file in
	unique_name (IN) - unique name prefix for the log file
	node_name (IN) - the node name of the machine
	orig_name (IN) - the name of the current master file
	view_name (IN) - the name of the window that is submitting the
	                 batch job
	server_name (IN) - the server that will run the batch job
	results_name (IN) - the name of the results file

GLOBALS USED
	none

RETURN VALUES
	A pointer to the open log file descriptor is returned.  This
	pointer is NULL if an error occured.

HISTORY
	08/24/88    S.P. Rogers
	   Creation Date
*/

	{
	IGRchar  fname[100];
	IGRchar  login_name[L_cuserid];
	FILE     *fp;

	/* get the user's login name */
	cuserid( login_name );

	/* create the log file in the same directory the user's design file is in */
	sprintf( fname, "%s%s.log", working_dir, unique_name );
	fp = fopen( fname, "w" );

	if ( fp )
	   {
	   fprintf( fp, "************ EDGE GENERATION BACKGROUND JOB LOG FILE ************\n" );
	   fprintf( fp, "\n" );	
	   fprintf( fp, "Submitter node name:    %s\n", node_name );
	   fprintf( fp, "Submitter login:        %s\n", login_name );
	   fprintf( fp, "Original file name:     %s\n", orig_name );
	   fprintf( fp, "View name:              %s\n", view_name );
	   fprintf( fp, "Server connect string:  %s\n", server_name );
	   fprintf( fp, "Results file name:      %s\n", results_name );

	   fprintf( fp, "\n" );
	   }
	
	return( fp );

	}  /* VEcreate_log_file */


/*--- VEcopy_color_table_info --------------------------------------------------*/

void VEcopy_color_table_info( invis_module )

	struct GRid *invis_module;

/*
NAME
	VEcopy_color_table_info

DESCRIPTION
	This function copies the color table information from the current
	module to the invisible module so the colors will appear the same
	if the invisible module is brought up by itself.

PARAMETERS
	invis_module (IN) - the GRid of the module in the invisible object
	                    space

GLOBALS USED
	none

HISTORY
	8/22/88    S.P. Rogers
	   Creation date
	03/14/92   S.P. Rogers
	   Changed vlt_size from IGRint to IGRshort to match macro parameter
*/

	{
	IGRshort       colors, shades;
	IGRshort       num_colors, num_shades;
	IGRshort       vlt_size;
	struct IGEvlt  vlt[512], background, foreground, hilite;


	/* copy the VLT to the new module */
	vlt_size = 512;
	ige$read_color_table( num_colors = &vlt_size,
	                      colors     = (IGRchar *)vlt,
                              flags      = (STRUCTURE_COLORS | IGE_READ_BACKGROUND | IGE_READ_HIGHLIGHT) );

	ige$change_color_table( num_colors = vlt_size,
	                        colors     = (IGRchar *)vlt,
                                flags      = (STRUCTURE_COLORS | IGE_READ_BACKGROUND | IGE_READ_HIGHLIGHT),
	                        mod_id     = invis_module->objid,
	                        mod_osnum  = invis_module->osnum );
	
	/* copy the device color information for a GS board machine */
/*	hs$read_device_colors( num_planes = 5,*/
/*	                       num_colors = &colors,*/
/*	                       num_shades = &shades );*/
/**/
/*	hs$change_device_colors( num_planes = 5,*/
/*	                         num_colors = colors,*/
/*	                         num_shades = shades,*/
/*	                         mod_id     = invis_module->objid,*/
/*	                         mod_osnum  = invis_module->osnum );*/
/**/
	/* copy the device color information for a GX/GZ board machine */
/*	hs$read_device_colors( num_planes = 9,*/
/*	                       num_colors = &colors,*/
/*	                       num_shades = &shades );*/
/**/
/*	hs$change_device_colors( num_planes = 9,*/
/*	                         num_colors = colors,*/
/*	                         num_shades = shades,*/
/*	                         mod_id     = invis_module->objid,*/
/*	                         mod_osnum  = invis_module->osnum );*/

	/* copy the device color information for a GT board machine */
/*	hs$read_device_colors( num_planes = 8,*/
/*	                       num_colors = &colors,*/
/*	                       num_shades = &shades );*/
/**/
/*	hs$change_device_colors( num_planes = 8,*/
/*	                         num_colors = colors,*/
/*	                         num_shades = shades,*/
/*	                         mod_id     = invis_module->objid,*/
/*	                         mod_osnum  = invis_module->osnum );*/

	/* copy the user colors */
/*	hs$read_user_colors( num_colors = &num_colors,*/
/*	                     num_shades = &num_shades );*/
/**/
/*	hs$change_user_colors( num_colors = num_colors,*/
/*	                       num_shades = num_shades,*/
/*	                       mod_id     = invis_module->objid,*/
/*	                       mod_osnum  = invis_module->osnum );*/

	/* copy the reserved colors */
/*	ige$read_reserved_colors( bgcolor      = (IGRchar *)&background,*/
/*	                          hilite_color = (IGRchar *)&hilite,*/
/*	                          fgcolor      = (IGRchar *)&foreground );*/
/**/
/*	ige$change_reserved_colors( bgcolor      = (IGRchar *)&background,*/
/*	                            hilite_color = (IGRchar *)&hilite,*/
/*	                            fgcolor      = (IGRchar *)&foreground,*/
/*	                            mod_id       = invis_module->objid,*/
/*	                            mod_osnum    = invis_module->osnum );*/
/**/
	/* copy the HSdpb2 data, too. */
	hs$copy_dpb_data_to_other_os( osnum = invis_module->osnum );

	}  /* VEcopy_color_table_info */


/*--- VEcopy_seed_file -------------------------------------------------------*/

IGRboolean VEcopy_seed_file( fname )

	IGRchar *fname;

/*
NAME
	VEcopy_seed_file

DESCRIPTION
	This function copies the seed file from its config directory
	to the name 'fname'.

PARAMETES
	fname (IN) - the name to copy the seed file to

GLOBALS USED
	none

RETURN VALUES
	TRUE - if the seed file was successfully copied
	FALSE - otherwise

HISTORY
	8/22/88    S.P. Rogers
	   Creation Date
*/

	{
	IGRboolean sts;
	IGRint     ii;
	IGRchar    config_path[128];
	IGRchar    seed_fname[OM_K_MAXOSNAME_LEN];
	FILE       *fp;

	/* find the ve batch seed file and copy it to a unique name */
	for ( sts = 1,ii = 0; (sts == 1); ii++ )
	   {
	   sts = (IGRboolean) ex$get_path( index = ii, path = config_path, len = sizeof( config_path ) );
	   if ( sts )
	      {
	      sprintf( seed_fname, "%sconfig/seed_file", config_path );
	      if ( fp = fopen( seed_fname, "r" ) )
	         {
	         fclose( fp );
	         sts = (IGRboolean) EX_cp( seed_fname, fname );
	         break;
	         }
	      }
	   }  /* end: for */

	return( sts );
	}  /* VEcopy_seed_file */


/*--- VEturn_windows_off -------------------------------------------------------*/

void VEturn_windows_off( ve_id )

	OM_S_OBJID ve_id;

/*
NAME
	VEturn_windows_off

DESCRIPTION
	This function turns off all the windows in the current file
	except the one that is being used to run VE.  It is intended
	to be used in batch mode, so the only window the user sees
	after running batch mode is the window that was processed.

PARAMETERS
	ve_id (IN) - the object id of the window that is running the
	             batch job (this is the window that isn't turned off)

GLOBALS USED
	none

HISTORY
	12/12/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong             msg;
	IGRint              ii;
	IGRint              num_id;
	IGRlong             total_found;
	IGRlong             ret_bytes;
	IGRint              which_error;
	IGRint              number_on_channel;
	IGRint              flags[2];
	struct GRid         win_ids[40];
	struct var_list     gg_var_list[2], win_var_list[2];
	OM_S_OBJECT_LINKAGE vw_list[1];
	OM_S_CHANSELECT     parent_chandef;

	om$make_chanselect( channame     = "IGEgadget.to_parent",
	                    p_chanselect = &parent_chandef );

	gg_var_list[0].var            = GRAGAD_FLAGS;
	gg_var_list[0].var_ptr        = (IGRchar *) flags;
	gg_var_list[0].num_bytes      = sizeof( IGRint ) * 2;
	gg_var_list[0].bytes_returned = &ret_bytes;
	gg_var_list[1].var            = END_PARAM;

	win_var_list[0].var            = WINDOW_FLAGS;
	win_var_list[0].var_ptr        = (IGRchar *) flags;
	win_var_list[0].num_bytes      = sizeof( IGRint ) * 2;
	win_var_list[0].bytes_returned = &ret_bytes;
	win_var_list[1].var            = END_PARAM;

	/* get all the gragad's in the file */
	dp$get_gragad_id( msg         = &msg,
	                  name        = "*",
                          array_size  = 40,
                          total_num   = (IGRint *)&total_found,
	                  numberofids = &num_id,
	                  found_GRids = win_ids,
	                  type_gragad = ALL_TYPES,
	                  mod_GRid    = &VEmaster_env.md_id );

	   MSG_ERRCHK( msg, "VEturn_windows_off  dp$get_gragad_id failed" );

	for ( ii = 0; ii < num_id; ii++ )
	   {
	   if ( win_ids[ii].objid != ve_id )
	      {
	      /* clear the window on and active bits in the gragad */
	      flags[0] = IS_WIN_ON | IS_ACTIVE;
	      flags[1] = 0;

	      dp$inq_set_gragad( msg          = &msg,
	                         inq0_set1    = 1,
	                         osnum        = win_ids[ii].osnum,
	                         gragad_objid = win_ids[ii].objid,
	                         which_error  = (IGRlong *)&which_error,
	                         var_list     = gg_var_list );

	      /* get the parent window of the gragad and clear its on */
	      /* and active bits                                      */
	      om$get_channel_objects( objid        = win_ids[ii].objid,
	                              osnum        = win_ids[ii].osnum,
	                              p_chanselect = &parent_chandef,
	                              list         = vw_list,
	                              size         = 1,
	                              count        = (OMuint *)&number_on_channel );

	      flags[0] = WIN_IS_ON | WIN_IS_ACTIVE;
	      flags[1] = 0;

	      ige$inq_set_window( msg          = &msg,
	                          inq0_set1    = 1,
	                          osnum        = vw_list[0].osnum,
	                          window_objid = vw_list[0].S_objid,
	                          which_error  = (IGRlong *)&which_error,
	                          var_list     = (struct win_var_list *)win_var_list );
	      }

	   }  /* end: for */

	}  /* VEturn_windows_off */


/*--- VEvalidate_server_name -------------------------------------------------------*/

IGRboolean VEvalidate_server_name( server, valid_server )

	IGRchar *server;
	IGRchar *valid_server;

/*
NAME
	VEvalidate_server_name

DESCRIPTION
	This function takes a server name and validates it.  The valid server
	names are node names and internet addresses.  If the server has the
	form of a node name, it is considered valid as is copied to
	valid_server. If the server has the form of an internet address,
	/etc/hosts is searched to get the corresponding node name.  If the
	corresponding node name is found, it is copied to valid_server.  If
	the corrsponding node name is not found, the server is considered
	invalid.

PARAMETERS
	server (IN) - the server name to validate
	valid_server (OUT) - if the server is valid, this is the node name of
	                     the server

GLOBALS USED
	none

RETURN VALUES
	TRUE - if the server is valid
	FALSE - if the server is invalid

HISTORY
	01/24/92    S.P. Rogers
	   Creation Date
*/

	{
	IGRchar line[256];
	IGRchar *temp_ptr;
	IGRint  length;
	FILE    *fp;
	
	valid_server[0] = '\0';

	if ( temp_ptr = strchr( server, '.' ) )
	   {
	   /* server name has a "." in it => treat as internet address */

	   /* see if server name has correct form: xxx.xxx.xxx.xxx */
	   /* by looking for two more periods in the string        */
	   if ( !(temp_ptr = strchr( &temp_ptr[1], '.' )) )
	      return( FALSE );

	   if ( !(temp_ptr = strchr( &temp_ptr[1], '.' )) )
	      return( FALSE );

	   /* look up the node name in the /etc/hosts file */
	   fp = fopen( "/etc/hosts", "r" );
	   if ( fp == NULL )
	      return( FALSE );

	   length = strlen( server );
	   while ( VEread_line_from_file( fp, line ) )
	      {
	      if ( strncmp( line, server, length ) == 0 )
	         {
	         /* internet address matches => extract node name from this line */
	         /* the node name should follow the internet address after some  */
	         /* white space                                                  */
	         temp_ptr = strtok( &line[length], " \t\n" );
	         if ( temp_ptr )
	            strcpy( valid_server, temp_ptr );
	         break;
	         }
	      }  /* end: while */

	   fclose( fp );
	   }
	else if ( isalpha( server[0] ) )
	   {
	   /* node name must start with an alphabetic character */
	   strcpy( valid_server, server );
	   }

	return( (strlen( valid_server ) > 0) );

	}  /* VEvalidate_server_name */


