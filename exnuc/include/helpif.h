/*
 * 29 Oct 2010 ah
 * Save a copy here before adding help to the new source directory
 */

/*______________________________________________________________________
 |									|
 |	Unpublished, but if published:					|
 |	Copyright Intergraph Corporation, 1991, including software	|
 |	and its file formats, and audio-visual displays;   this is the	|
 |	property  of  Intergraph  Corporation;   All  Rights  Reserved	|
 |	May only be used pursuant to the applicable  software  license	|
 |	agreement; contains confidential and  proprietary  information	|
 |	of Intergraph and/or other third parties which is protected by	|
 |	copyright,  trade secret  and  trademark law  and  may  not be	|
 |	provided or otherwise  made  available  without  prior written	|
 |	authorization;							|
 |	Restricted Rights Legend:					|
 |	Use, duplication or disclosure by the government is subject to	|
 |	restrictions as set forth in  subdivision (b) (3) (ii)  of the	|
 |	rights  in  technical  data  and  computer software  clause at	|
 |	52.227-7013.							|
 |                                                                      |
 |	Intergraph Corporation	                                        |
 |	One Madison Industrial Park                                     |
 |	Huntsville, Alabama 35807                                       |
 |______________________________________________________________________|
*/

/* Header File for Help Library Calls */
/* 26Mar91afb - Created for Help version 08.00.00.00. */
/* 02Apr91afb - Made library_version and process_version in HP_status_struct
                not be pointers. */
/* 06May91afb - Made x and y in HP_status_struct to be x_origin and y_origin
                so that they would match x_origin and y_origin in
                HP_defaults_struct. */
/* 20May91afb - Added declarations for HP_VERSION_TYPE and
                HP_VERSION_STRING_SIZE.  Made doc_id in
                HP_defaults_struct be a HP_doc_id_struct. */
/* 01Aug91afb - Moved return values for Help library functions to here from
                libDisp.h and changed HDL_ to HP_ in prefixes. */
/* 12Aug91war - Pass through Data Buffer Size define added */
/* 14Aug91war - Removed the following fields from HP_defaults_struct
                struct HP_doc_id_struct doc_id;
                char *display_logical_name;
                char *help_on_help_topic_logical_name;      */
/* 21Aug91war - Removed the following field from HP_defaults_struct
                int timeout;                                */
/* 23Aug91war - Add HP_defaults_struct members              */
/* 23Aug91war - Add HP_defaults_struct as member of HP_status_struct */
/* 23Sep91afb - Moved SUPPRESS_CROSS_REFERENCE_CHECKING, HARD_CR_CONVERSION, and
                RETURN_VERSION_STRING into helpif.h */
/* 25Sep91afb - Removed HP_MESSAGE_LOGICAL_NAME, HP_SEARCH_SUBFORM_LOGICAL_NAME,
                HP_PRINT_ASCII_SUBFORM_LOGICAL_NAME, and
                HP_PRINT_POSTSCRIPT_SUBFORM_LOGICAL_NAME. */
/* 02Oct91afb - Made HP_VERSION_TYPE into a char pointer. */
/* 04Oct91afb - Put HP_SEARCH_SUBFORM_LOGICAL_NAME back in. */
/* 23Oct91afb - Added return values past HP_FAILURE. */
/* 30Oct91war - Add HP_ error messages that were removed from helpCommon.h */
/* 12Nov91afb - Cleaned up comments; changed Help library return numbers. */
/* 14Nov91afb - Added HP_CANNOT_DISPLAY_FORM_WITHOUT_TOPIC_SET. */
/* 20Nov91war - Change HP_defaults_struct member names to match app-defs.*/
/* 20Nov91afb - Added HP_ERROR_INITIALIZING,
                HP_ERROR_OPENING_LOG_FILE_FROM_DEFAULTS, and
                HP_ERROR_SETTING_FORM_LOCATION_FROM_DEFAULTS. */
/* 22Nov91afb - Added HP_ERROR_GETTING_FORM_ORIGIN and
                HP_ERROR_GETTING_FORM_SIZE. */
/* 07Jan92war - Add Help Compiler error defines */
/* 18Nov93afb - Improved HELP library return value descriptions. */

#ifndef HELPIF_H_INCLUDED 
#define HELPIF_H_INCLUDED


/**********************************************************************/
/* return values for Help library functions                           */
/*                                                                    */
/* Positive error values come from the Help displayer; negative error */
/* values come from the Help library.                                 */
/**********************************************************************/

#define HP_SUCCESS                                    0
#define HP_BAD_EVENT                                  1
#define HP_CALL_FAILURE                               2
#define HP_FAILURE                                    3
#define HP_ERROR_FINDING_TOPIC_IN_TOC                 4
#define HP_ERROR_FINDING_OR_OPENING_DOCUMENT          5
#define HP_ERROR_GETTING_FORM_DISPLAY_STATUS          6
#define HP_ERROR_CHANGING_FORM_BUTTON_STATUS          7
#define HP_HELP_SET_XDISPLAY_CALLED_MORE_THAN_ONCE    8
#define HP_ERROR_CREATING_INTERNAL_TABLE_OF_CONTENTS  9
#define HP_ERROR_ERASING_FORM                        10
#define HP_ERROR_DISPLAYING_TOPIC                    11
#define HP_CANNOT_DISPLAY_FORM_WITHOUT_TOPIC_SET     12
#define HP_ERROR_INITIALIZING                        13
#define HP_ERROR_OPENING_LOG_FILE_FROM_DEFAULTS      14
#define HP_ERROR_SETTING_FORM_LOCATION_FROM_DEFAULTS 15
#define HP_ERROR_GETTING_FORM_ORIGIN                 16
#define HP_ERROR_GETTING_FORM_SIZE                   17
#define HP_NO_CONNECT    -31 /* HELP library libhlib.a linked with application
                                could not connect to HELP displayer that must
                                be delivered as part of HELPRT product, which
                                is part of the baseline software. */
#define HP_INV_SOCKET    -32 /* AF_UNIX domain socket error. */
#define HP_NO_DISPLAYER  -33 /* HELP displayer procedure lost. */
#define HP_DEF_FILE_ERR  -34 /* Resources file $HOME/.Xdefaults format error. */
#define HP_NO_DEF_FILE   -35 /* Resources file $HOME/.Xdefaults not found. */
#define HP_MALLOC_ERR    -36 /* "malloc" error; call system administrator. */
#define HP_SOCKET_ERROR  -37 /* Accept/connect error. */
#define HP_BIND_ERROR    -38 /* Error binding stream socket. */
#define HP_PASS_SIZE_ERR -39 /* Size 0; invalid pass size. */
#define HP_TRUNCATION    -40 /* Text possibly truncated. */
#define HP_STAT_INIT_ERR -41 /* HP_status_struct already initialized. */
#define HP_STAT_FREE_ERR -42 /* HP_status_struct already freed. */
#define HP_NULL_ARG      -50 /* Help_hc with NULL argument. */
#define HP_NO_X_APP_DEF  -51 /* "lib/X11/app-defaults/Ihelp" not found. */
#define HP_OBJ_NOT_FOUND -52 /* Help_hc.o not found. */


typedef char * HP_VERSION_TYPE;


/**********************************************************************/
/*                          Help_document                             */
/**********************************************************************/

struct HP_doc_id_struct
{
   HP_VERSION_TYPE version;
   char *language;
   char *logical_name;
};


/**********************************************************************/
/*                        Help_defaults                               */
/**********************************************************************/

struct HP_defaults_struct
{
   int x_origin, y_origin;          /* 0xffffffff means not filled in        */
   int width, height;               /* 0xffffffff means not filled in        */
   char *log_file_name;             /* error log file, NULL for unused       */
   int recent_topic_list_quantity;  /* 0xffffffff means not filled in        */
   char **languages;                /* NULL-terminated preference list of    */
                                    /* languages, NULL for unused            */
   char *ascii_command_line;        /* Command to print ASCII file           */
   char *postscript_command_line;   /* Command to print PostScript file      */
   char *print_type;                /* Either "ASCII", "POSTSCRIPT", or NULL */
   int  lines_per_page;             /* ASCII lines per page or 0xffffffff    */
   int  top_page_margin;            /* Top of page margin or 0xffffffff      */
};


/**********************************************************************/
/*                        Help_status                                 */
/**********************************************************************/

#define HP_TABLE_OF_CONTENTS_LOGICAL_NAME        "helpTableOfContents"
#define HP_INDEX_LOGICAL_NAME                    "helpIndex"
#define HP_GLOSSARY_LOGICAL_NAME                 "helpGlossary"
#define HP_SEARCH_SUBFORM_LOGICAL_NAME           "helpSearchSubform"

struct HP_status_struct
{
   HP_VERSION_TYPE library_version; /* version of Help library */
   HP_VERSION_TYPE process_version; /* version of Help process */
   int displayed; /* nonzero if Help form is displayed, 0 otherwise */
   int collapsed; /* nonzero if Help form is displayed and collapsed, 0
                     otherwise */
   int x_origin, y_origin, width, height; /* Help form location, where would be
                                             if not collapsed or undisplayed */
   struct HP_doc_id_struct doc_id; /* NULL if not set */
   char *display_logical_name; /* NULL if not set */
   struct HP_defaults_struct help_defaults;
};


/**********************************************************************/
/*                        Help_hc                                     */
/**********************************************************************/

/* turns off checking for the presence of topic that are cross referenced */
#define SUPPRESS_CROSS_REFERENCE_CHECKING 0x00000001
/* treats newlines in source text as <CR>'s */
#define HARD_CR_CONVERSION                0x00000002
/* causes the first string in messages_ptr to be the version of the compiler */
#define RETURN_VERSION_STRING             0x00000004

#endif 
