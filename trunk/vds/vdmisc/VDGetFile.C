/* $Id: VDGetFile.C,v 1.1.1.1 2001/01/04 21:08:57 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        $VDS/vdmisc/VDGetFile.C
 *
 * Description: This is a general VDS Unix directory file search utility.
 *		The user can specify the starting directory, dir and file
 *		searh patterns, and file type filter (user defined routine).
 *
 *		For more information, check subroutine VDGetFile.
 *
 * Dependencies: Form VDGetFile.
 *
 * Revision History:
 *      $Log: VDGetFile.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:57  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.3  1998/04/23  14:34:44  pinnacle
 * ah
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.4  1997/03/05  17:32:48  pinnacle
 * Replaced: vdmisc/VDGetFile.C for:  by yzhu for vds.241
 *
 * Revision 1.3  1997/02/03  17:51:26  pinnacle
 * Replaced: vdmisc/VDGetFile.C for:  by kddinov for vds.241
 *
 *
 * History:
 *  MM/DD/YY  	AUTHOR 	DESCRIPTION
 *  10/01/96	KDD	creation 
 *  02/05/97	YZHU	modify Get_text to VdsGet_text(pdu has a Get_text) 
 *                      TR17970535
 *  04/23/98    ah      Comment out invalid calloc/realloc prototypes
 *                      Added VDtypedef.h to get other files
 * -------------------------------------------------------------------*/

#include        <sys/types.h>
#include        <sys/stat.h>
#include        <sys/param.h>
#include        <dirent.h>
#include        <stdio.h>
#include        <errno.h>
#include        <string.h>
#include "FI.h"

#include "VDtypedef.h"
#include "vdmiscmacros.h"  
#include "griomacros.h"

//  co$getevent macro and dependencies are defined somewhere here 
#if 0
#include        "exdef.h"
#include        "OMminimum.h"
#include        "igetypedef.h"
#include        "igrtypedef.h"
#include        "igr.h"
#include        "griodef.h"
#include        "godef.h"
#include        "gr.h"
#include        "igrdp.h"
#include        "go.h"
#include        "ex.h"
#include        "grio.h"
#include        "exmacros.h"
#include        "griomacros.h"
#include        "msdef.h"
#include        "msmacros.h"
#endif

// ISO files as in $ROUTE/vrppl/isoplot.u 

#define DATAFILE        "isogen.dat"
#define DGNFILE         "isogen.file"


// Gadgets 

#define FI_FILENAME   21	// output file name 
#define FI_DIRNAME    39	// search path     
#define FI_FILELIST   16	// list of files 
#define FI_DIRLIST    15	// list of directories 
#define FI_FILEFILTER 11	// filename filter 
#define FI_DIRFILTER  20	// dirname filter 
#define FI_TITLE      12	// form title 
#define FI_DIRNUMBER  24	// number of dirs in FI_DIRLIST 
#define FI_FILENUMBER 25	// number of files in FI_FILELIST 
#define FI_MESSAGE    10	// message field 

// Externs 

//extern char * calloc();
//extern char * realloc();
extern int FIg_get_text_length();
extern int FIg_get_text();

extern	char	*getenv();

extern	char	*strrchr();

// S_ISDIR(stat_buf.st_mode) is defined in sys/stat.h  

/********* Local routines *********/

void 	VDGetFile_form_notification ( );
void 	VDGetFile_form_error();
int  	VDlist_directory();
int 	is_drawing_file();
int	VDnull_test();
int	VDname_filter();
int	VDGetFile(); 
static int	(*dir_test)(), (*file_test)();
static int    	VdsGet_text ();

/********* Local-Global variables.    *************/

static char	filename[80],
		dirname[80],
		old_dir[80],
		file_filter[80],
		dir_filter[80];

#define DIRECTORY_BIT	0x4000

typedef	  char	UNIX_NAME[16];

/***************************
* driver to call VDGetFile()
***************************/
void ISO_NQS()
{
  char		dirname[80] =".",
		filename[80]="",
		out_file[80];

  int		status;

  status = vd$get_file( directory      = dirname, 
                        filename       = filename, 
                        out_file       = out_file, 
			file_test      = is_drawing_file,
			file_filter    = "*.dat",
                        last_search    = 0);
/*
*/

  printf("full file name=%s\n", out_file);
  printf("selected dir  =%s\n", dirname);
  printf("selected file =%s\n", filename);

return;
}

/*******************************************************************************
*  This routine determines if the input filename is of Isogen Drawing file
*  format. It checks if the first line contains pattern "ICIOPN".
*
*  RETURN:
*	1 - if Isogen Drawing file
*	0 - otherwise 
*******************************************************************************/
int is_drawing_file( char *name)
{
        int     status = 1;
        char    text[80];
        FILE    *fp;

        fp = fopen( name, "r");
        if ( !fp) { status = 0; goto wrapup; }

        fgets(text, 80, fp);

        if ( !strstr(text,"ICIOPN")) { status = 0; }

        fclose(fp);

wrapup:

return (status);
}

/*****************************************************************************
*
*   File:     VDGetFile.C
*
*   Description:
*        This Function allows the user to select a file from the unix system.
*	 Hidden files ".*" are not displayed. 
*
*   Dependencies:
*       Uses the form "VDGetFile" to get the file & directory information.
*
*   Keywords: unix, ls, pwd, directory, file.
*
*-----------------------------------------------------------------------------
*   Parameters:
*
*  I  form_title- optional title on the form.
*
* I/O d_name  	- search directory. Disregard if last_search = 1.
*                 if "." or "" starts with $PWD environmental variable.
*                 if NULL starts with the last search directory.
*
* I/O f_name	- filename, from the current directory.
* 
*  O  out_file 	- selected file. Full pathname == "dirname/filename".
*
*  I  f_filter 	- file name selection filter.
*
*  I  d_filter	- directory name selection filter.
*
*  I  last_search - 1 search using the last searched directory.
*                   0 start a new search.
*
*  I  d_test   	- FUNCTION to filter out the directories.
*		  Takes one argument (char *) full_dir_name.
*                 Returns 1 if the directory is to be displayed, 0 otherwise.
*
*  I  f_test   	- FUNCTION to filter out the files.
*		  Takes one argument (char *) full_file_name.
*                 Returns 1 if the file is to be displayed, 0 otherwise.
*
*-----------------------------------------------------------------------------
*    EXAMPLE 
*	$VDS/include/vdmiscmacros.h defines macro interface vd$get_file
*
*  char         dirname[80] =".",
*               filename[80]="",
*               out_file[80];
*
*  int          status;
*
*  status = vd$get_file( out_file       = out_file);
*
*  status = vd$get_file( directory      = dirname,
*                        filename       = filename,
*                        out_file       = out_file,
*                        last_search    = 1);
*
*-----------------------------------------------------------------------------
*   Return status:
*       1       - success
*       0       - otherwise
*
*-----------------------------------------------------------------------------
*   History:
*       10/96   KDD     creation
*
*****************************************************************************/
int VDGetFile(  char    *form_title,
                char    *d_name,
                char    *f_name,
                char    *out_file,
                char    *f_filter,
                char    *d_filter,
                int     last_search,
                int     (*d_test)(),
                int     (*f_test)()  ) 
{
        Form    form;
        int     form_id =0;
        char    title[80]="File search";
	char	*dummy_char;

        long    msg, done = 0;
        int     status = 1, response;
        char    response_data[256];
struct GRevent  event;

  if (strlen(old_dir) == 0 ) strcpy(old_dir, getenv("PWD"));

/*****
*  Initialization (protect the input)
*****/
  if (form_title) strcpy(title, form_title); 

  if (d_name) strcpy(dirname, d_name); 
  else        strcpy(dirname, old_dir);

  if (f_name) strcpy(filename, f_name); 
  else        strcpy(filename, "");

  if (f_filter) strcpy(file_filter, f_filter); 
  else          strcpy(file_filter, "");

  if (d_filter) strcpy(dir_filter, d_filter); 
  else          strcpy(dir_filter, "");

  if ( last_search) strcpy(dirname, old_dir);

  if ( !strcmp(dirname, ".") || (strlen(dirname) == 0) ) { 
	strcpy(dirname,getenv("PWD"));
  }

  if ( ! last_search) strcpy(old_dir, dirname);

  dir_test = ( d_test ) ? d_test : VDnull_test;
  file_test =( f_test ) ? f_test : VDnull_test;

/*****
*  Initialize the form.
*****/
  FIf_new(form_id, "VDGetFile", VDGetFile_form_notification, &form);
  if (!form)  {
        VDGetFile_form_error("Fails to open VDGetFile");
        status = 0; 
	goto wrapup; 
  }

  FIg_set_text 	     ( form, FI_TITLE, title);
  FIfld_set_num_rows ( form, FI_FILELIST, 0 );
  FIfld_set_num_rows ( form, FI_DIRLIST, 0 );
  FIfld_set_text     ( form, FI_FILEFILTER, 0, 0, file_filter, 0);
  FIfld_set_text     ( form, FI_DIRFILTER,  0, 0,  dir_filter, 0);
  FIfld_set_text     ( form, FI_FILENAME, 0, 0, filename, 0);
  FIfld_set_text     ( form, FI_DIRNAME, 0, 0,   dirname, 0);
  FIfld_set_default_text ( form, FI_MESSAGE, 0, 0, "", 0);

  status = VDlist_directory(dirname, form);

  FIf_display(form);

/*****
*  Loop until user dismisses the form, or keys in filename 
*****/
  do {

  	done = 0;
	response = 0;

        status = status & 
		 co$getevent ( msg      = &msg,
                        event_mask      = (long) ( EX_RJT_MOVEON | 
						EX_FORM_FINISHED ),
                        prompt          = "Select file",
                        event           = &event,
                        response        = &response,
                        response_data   = response_data);

        if ( (response == EX_RJT_MOVEON) || (response == EX_FORM_FINISHED) ||
             (response == CLEAR_STACK ) || ( response == TERMINATE)  ) {

             done = 1;
	     continue;
        }

        if ( response == EX_STRING  ) {
	   strcpy(dirname, response_data);

/*  Construct dirname and filename out of the input string */

	   if ( (dummy_char = strrchr(dirname,'/')) == NULL ) {
	   	strcpy(filename, dirname);
		strcpy(dirname,getenv("PWD"));
	   }
	   else {
		*dummy_char = '\0';
		strcpy(filename, (dummy_char+1) ); 
	   }

	   done = 1;
	   continue;
	}

        if ( (response == EX_CMD_KEY  ) || ( response == CMD_STRING) ) { 

/*  The form is dismissed and new command is started */

             long len = strlen(response_data)+1;
	     done = 1;

             ex$putque( msg          = &msg,
                        response     = &response,
                        byte         = &len,
                        buffer       = response_data);
	     continue;
        }

  } while ( !done ) ;

/*****
*  Load the output parameters
*****/
  FIf_erase (form);

  strcpy(out_file, "");

  if ( (response == EX_FORM_FINISHED) || (response == EX_STRING) ){
        strcpy(old_dir, dirname);
	if ( (d_name) && ( strlen(d_name) >= strlen(dirname)) ) 
		strcpy(d_name, dirname);

	if ( (f_name) && ( strlen(f_name) >= strlen(filename)) )
		strcpy(f_name, filename);

	if ( strlen(filename) > 0) {
		strcpy(out_file, dirname); 
		strcat(out_file, "/"); 
		strcat(out_file, filename); 
	}
  }

wrapup:

return (status);
}

/*******************************************************************************
*  This routine lists the contents of dir_name on form form.
*  Directories and filenames are separated. 
*******************************************************************************/
int VDlist_directory( 
	char 	*dir_name,
	Form	form)
{
  int		status = 1;	/* default is TRUE == OK */

  struct dirent *dp;
  DIR           *dir_id;
  struct stat	stat_buf; 
  char		text[80];

  UNIX_NAME	*file_list,
		*dir_list;

  int		file_count =0,
		dir_count = 0,
		i;

  if ( (dir_id = opendir(dir_name)) == NULL ) {
	strcpy(text,"Can not open directory: ");
	strcat(text,dir_name);
	VDGetFile_form_error(text);
	status = 0; goto wrapup; 
  }

/*** 	Get the number of entries. Alocate enough memory  ***/

  while ( (dp = readdir ( dir_id )) ) {
        strcpy(text, dir_name);
        strcat(text, "/"); 
        strcat(text, dp->d_name); 
	stat(text,&stat_buf);

	if( (stat_buf.st_mode & DIRECTORY_BIT) ) {
		dir_count++;
	}
	else {
		file_count++;
	}
  }

  rewinddir( dir_id); 

  file_list = (UNIX_NAME *) calloc (file_count, sizeof(UNIX_NAME) );
  dir_list  = (UNIX_NAME *) calloc (dir_count , sizeof(UNIX_NAME) );

  file_count = 0; dir_count = 0; 

/***	Store and sort the file and dir entries ***/ 

  while ( (dp = readdir ( dir_id )) ) {
     if ( dp->d_name[0] == '.' ) continue; /* skip over hidden entries */ 

     strcpy(text, dir_name);
     strcat(text, "/"); 
     strcat(text, dp->d_name); 
     stat(text,&stat_buf);

     if( (stat_buf.st_mode & DIRECTORY_BIT) ) {
	if ( (VDname_filter(dp->d_name, dir_filter) ) && dir_test(text) )
		strcpy(dir_list[dir_count++], dp->d_name);
     }
     else {
        if ( (VDname_filter(dp->d_name,file_filter) ) && file_test(text) )
                strcpy(file_list[file_count++],dp->d_name);
     }
  }

  closedir ( dir_id );

  qsort (dir_list,  (unsigned) dir_count,  sizeof (UNIX_NAME), 
			(int (*) (const void *, const void *) ) strcmp ); 
  qsort (file_list, (unsigned) file_count, sizeof (UNIX_NAME), 
			(int (*) (const void *, const void *) ) strcmp ); 

/***	Load the info into the form ***/

  FIfld_set_num_rows(form, FI_FILELIST, 0 );
  FIfld_set_num_rows(form, FI_FILELIST, file_count );

  FIfld_set_num_rows(form, FI_DIRLIST, 0 );
  FIfld_set_num_rows(form, FI_DIRLIST, dir_count + 2);

  FIfld_set_text(form, FI_DIRLIST, 0, 0, ".", 1);
  FIfld_set_text(form, FI_DIRLIST, 1, 0, "..", 1);

  sprintf(text,"%d", file_count);
  FIfld_set_text(form, FI_FILENUMBER, 0, 0, text, 0);

  sprintf(text,"%d",  dir_count + 2);
  FIfld_set_text(form, FI_DIRNUMBER, 0, 0, text, 0);

  for (i = 0; i < file_count; i++) {
	FIfld_set_text(form, FI_FILELIST, i, 0, file_list[i], 1);
  }

  for (i = 0; i < dir_count; i++) {
	FIfld_set_text(form, FI_DIRLIST, i+2, 0, dir_list[i], 1);
  }

  free (file_list);
  free (dir_list);

wrapup: 

return (status) ;
}

/***************************
***************************/
int VDnull_test( ) { return 1; } 

/*******************************************************************************
*
* NAME: VDname_filter
*
* DESCRIPTION:
*       This program filters out "name" if it doesn't match the "filter".
*       The program takes several filter patterns separated by "," or " ".
*
* PARAMETERS:
*
*  char *in_name        - input name to be fitered
*  char *filter         - the filter
*
* RETURN STATUS:
*       1       - if the name passes the filter test
*       0       - otherwise
*-------------------------------------------------------------------------------
*
* Keyword: filter, VDS, unix, select, name, utility.
*
* Example (patterns): "*dat" "dat" "dat*" "*dat, *sh,*txt VD*"
*
* ALGORITHM:
*    1. First we split recursively the filter. Separators: "," or " " or "/".
*    2. Then we check in_name, agains each "sub" filter.
*    2.1. The first "*" is recognized to distinguish between "dat" and "*dat".
*
* HISTORY:
*  10/96        KDD     - initial creation
*******************************************************************************/
int VDname_filter( char *in_name, char *in_filter)
{
  int status = 1;                       /* default == accept */

  char  name[80],
        filter[80],
        *p_name,
        *p1, *p2, *p3,
        *star_before = NULL;

  int   len = 0;

/*******
*  Input check and initialization (protect the input).
*******/

  if ( (!in_name) || (!in_filter) ) goto wrapup;
  if ( strlen(in_filter) == 0 ) goto wrapup;

  strcpy(name, in_name);
  strcpy(filter, in_filter);

  p_name = name;
  p1 = filter;

/*******
*  This cycle recursively breaks a complex filter into separate parts
*******/

  while ( (p3 = strchr(p1, ',')) ||
          (p3 = strchr(p1, ' ')) ||
          (p3 = strchr(p1, '/')) ) {    /* those are the separators */

        *p3 = '\0';
        if ( ! VDname_filter(name, p1) ) { status = 0; goto wrapup;}

        p1 = p1 + strlen(p1) + 1;       /* the last 1 comes from ',' or ' ' */
  }

/*******
*  This cycle searches <p_name> for a single pattern <p1>.
*******/

  while ( (p2 = strchr(p1, '*')) ) {
        *p2 = '\0';
        len = strlen(p1);

        if (len > 0 ) {
            if ( !(p3 = strstr(p_name, p1)) ) { status = 0; goto wrapup; }
            if ( !star_before && (p3 != p_name) ) { status = 0; goto wrapup; }
            p_name = p3 + len;
        }

        p1 = p1 + len + 1;      /* the last 1 comes from "*" */

        star_before = p2;       /* star_after == p2 */
  }

/*******
* There will be no star_after in the filter here.
*******/

  if ( strlen(p_name) < strlen(p1) ) {status=0; goto wrapup;}
  if ( strlen(p1) == 0 ) goto wrapup;

  if ( ! (p3 = strstr(p_name, p1) ) ) {status = 0; goto wrapup; }
  while ( (p2 = strstr(p3+1, p1)) ) 
	p3 = p2;        		/* get the last occurence */

  if ( strlen(p3) != strlen(p1) ) {status = 0; goto wrapup; }

  if ( !star_before && (p3 != p_name) ) { status = 0; goto wrapup; }

wrapup:

  return (status);
}

/***************************
***************************/
void VDGetFile_form_error(char *error_message)
{
        FI_message_box ( FI_CURRENT_SCREEN, -1, -1, "Fatal Error",
                         FI_RED, "swiss742b", 25.0,
                         error_message, FI_BLACK, "swiss742b", 25.0,
                         FI_LEFT_JUSTIFIED, 60);
	return;
}

/***************************
***************************/
static int VdsGet_text ( fp, g_label, text, text_size )
       Form    fp;            /* Pointer to the form     */
       int     g_label;       /* The label of the gadget */
       char  * text;          /* The text contained in the field */
       int   * text_size;     /* The space allocated for the text */
{
    int status = FI_SUCCESS;
    int text_len;
    int field_type;
    int select_flag;
    int row = 0;
    int col = 0;
    int pos = 0;
    char	dummy[80];

    if ( ! text ) {
	return ( FI_NO_MEMORY );
    }

    FIg_get_type ( fp, g_label, &field_type );

    if ( field_type == FI_MULTI_COL )
    {
        FImcf_get_active_col ( fp, g_label, &col, &pos );
    }

    /* Get the row for the field or MCF */

    FIfld_get_active_row ( fp, g_label, &row, &pos );
    FIfld_get_text_length ( fp, g_label, row, col, &text_len );

    text_len++;			/* NULL terminator */

    if ( *text_size < text_len )
    {
	sprintf(dummy,"Text in gadget %d longer than %d",g_label, *text_size);
	VDGetFile_form_error(dummy);
	return (FI_NO_MEMORY);
    }

    status = FIfld_get_text ( fp, g_label, row, col, * text_size,
                              text, &select_flag, &pos );
    return ( status );
}


/***************************
***************************/
void VDGetFile_form_notification ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
IGRdouble value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  char		*text1;
  char		text[80], text_buf[80];
  int    	text_size = 80;
  int           status;

  long    	msg;
  int     	response;


  switch ( g_label )
  {
    case FI_FILENAME:     
         status = VdsGet_text ( fp, g_label, filename, & text_size );
         break;

    case FI_CANCEL:  
	 strcpy(filename, "");

	 response = EX_RJT_MOVEON; 
         ex$putque( msg          = &msg,
                    response     = &response);

         break;

    case FI_EXECUTE: 
         status = VdsGet_text ( fp, FI_DIRNAME,        dirname, & text_size );
         status = VdsGet_text ( fp, FI_FILEFILTER, file_filter, & text_size );
         status = VdsGet_text ( fp, FI_DIRFILTER,   dir_filter, & text_size );
	 
	 strcpy(filename, "");
         FIfld_set_text(fp, FI_FILENAME, 0, 0, filename, 0);

	 status = VDlist_directory(dirname, fp);
	 break;

    case FI_RESET: 
	 strcpy(filename, "");
         FIfld_set_text(fp, FI_FILENAME, 0, 0, filename, 0);

	 strcpy(file_filter, "");
	 strcpy(dir_filter, "");
         FIfld_set_text(fp, FI_FILEFILTER, 0, 0, file_filter, 0);
         FIfld_set_text(fp, FI_DIRFILTER,  0, 0,  dir_filter, 0);

	 strcpy(dirname, old_dir);
         FIfld_set_text(fp, FI_DIRNAME, 0, 0, dirname, 0);

         status = VDlist_directory(dirname, fp);

	 break;
	 
    case FI_ACCEPT: 
         status = VdsGet_text ( fp, FI_DIRNAME,   dirname, & text_size );
         status = VdsGet_text ( fp, FI_FILENAME, filename, & text_size );

         response = EX_FORM_FINISHED;
         ex$putque( msg          = &msg,
                    response     = &response);

         break;

    case FI_FILELIST: 
         status = VdsGet_text ( fp, g_label, filename, & text_size );

	 FIfld_set_text(fp, FI_FILENAME, 0, 0, filename, 0);

         break;

    case FI_DIRLIST: 
         status = VdsGet_text ( fp, g_label, text, & text_size );

         if ( status != FI_SUCCESS ) { break; }

	 if ( ! strcmp(text, ".") ) { *text = '\0'; }
	         
         if ( ! strcmp(text, "..") ) {
	    *text = '\0'; 
	    text1 = strrchr(dirname, '/');
	    if ( text1 ) *text1 = '\0';
	    else strcpy(dirname, ""); 
         }

	 if ( strlen(dirname) == 0 ) strcpy(dirname, "/"); 

	 strcpy(text_buf, dirname); 
	 if ( strlen(text) && (text_buf[ strlen(text_buf) - 1] != '/' ) )  {
	 	strcat(text_buf,"/");
	 }
	 strcat(text_buf, text); 

	 if ( VDlist_directory(text_buf, fp) ) { 
	    strcpy( dirname, text_buf); 
	    FIfld_set_text(fp, FI_DIRNAME, 0, 0, dirname, 0);

	    strcpy(filename, ""); 
	    FIfld_set_text(fp, FI_FILENAME, 0, 0, filename, 0);
	 }

         break;

    case FI_DIRNAME:   
         status = VdsGet_text ( fp, g_label, text, & text_size );

         if ( VDlist_directory(text, fp) ) { 
            strcpy( dirname, text); 
	 }

         break;

    case FI_DIRFILTER:
         status = VdsGet_text ( fp, g_label, text, & text_size );

         if ( status != FI_SUCCESS ) { break; }

         strcpy( dir_filter, text);
         strcpy(filename, "");
         FIfld_set_text(fp, FI_FILENAME, 0, 0, filename, 0);

         status = VDlist_directory(dirname, fp);

         break;

    case FI_FILEFILTER:
         status = VdsGet_text ( fp, g_label, text, & text_size );

         if ( status != FI_SUCCESS ) { break; }

         strcpy( file_filter, text);
	 strcpy(filename, "");
	 FIfld_set_text(fp, FI_FILENAME, 0, 0, filename, 0);

         status = VDlist_directory(dirname, fp);

         break;

    default: 
         break;

  } /* END switch ( g_label ) */

} /* END notification_routine() */
