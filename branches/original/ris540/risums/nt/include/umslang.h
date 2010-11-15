/* Do not alter this SPC information: $Revision: 1.1.38.1 $ */
/*
**	NAME:							umslang.h
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					5/93
**	ABSTRACT:
**			Macro to define default language.
**	
**	REVISION HISTORY:
*/

#ifndef UMSLANG_H
#define UMSLANG_H

/*
**	DEFINES
*/
/* Default language to be initialized */
#if defined(__clipper__) || defined(sun) || defined(sco) || defined(WIN16)
#define DEFAULT_LANGUAGE "english"
#elif defined(WIN32)
#else
ERROR - NO CODE
#endif

#define CONFIG_FILE_NAME 	"langs"

#define LANGUAGE_ID 		1
#define LANGUAGE_NAME		2
#define LANGUAGE_DIR		3
#define OS_LANGUAGE_ID		4
#define OS_LANGUAGE_NAME	5

#define CONFIG_COMMENT_SYMBOL	'#' /* comment symbol in config file */
#define CONFIG_DELIMITER		'|' /* delimiter symbol in config file */

/*
** Define for language name size
*/
#define MAX_LANG_NAME_SIZE	32

/*
** Define for directory size { 8(dirname)  + '.' + 3 (ext) }
*/
#define MAX_DIR_NAME_SIZE	12

/*
**	TYPES
*/
typedef struct lang_info_s
{
	long				lang_id;		/* our language id */
	char				*lang_name;		/* our language name */
	char				*lang_dir;		/* our language directory */
	long				os_lang_id;		/* os language id */
	char				*os_lang_name;	/* os language name */
	struct lang_info_s	*next;
} lang_info;

/*
**	VARIABLES
*/

#endif
