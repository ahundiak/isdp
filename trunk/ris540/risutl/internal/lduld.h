/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**  NAME:                           lduld.h
**  AUTHORS:                        Hitesh Patel
**  CREATION DATE:                  5/91
**  ABSTRACT:
**      It contains common constants.
**
**  REVISION HISTORY:
*/

#ifndef LDULD_H
#define LDULD_H
 
/*
**	INCLUDES
*/
#include "risutl.h"
#include "utl_err.h"
#include "utl_inf.h"
#include "rislduld.h"

/*
**	DEFINES
*/

#define	TRUE 					1			/* COMMON */
#define	FALSE					0			/* COMMON */
			
#define	SUCCESS					0			/* COMMON */
#define	FAILURE					-1			/* COMMON */

#define YES						1			/* COMMON */
#define NO						0			/* COMMON */
	
#define ALL 					'a'			/* COMMON */
#define SOME					's'			/* COMMON */
#define NONE					'n'			/* COMMON */

#define ENTERED					's'			/* UNLOAD 's' implies it is SOME */
#define PROMPTED				'p'			/* COMMON */

#define BOTH					1			/* COMMON */
#define ONLY					0			/* COMMON */

#define SAME   					0			/* UNLOAD */
#define DIFFERENT     			1			/* UNLOAD */

#define FIXED   				0			/* UNLOAD */
#define VARIABLE     			1			/* UNLOAD */

#define RIS_IGNORE 					1			/* LOAD */
#define DO_NOT_IGNORE 			0			/* LOAD */

#define RETN					1			/* UNLOAD */

#define	START 					0			/* COMMON */
#define	STOP					1			/* COMMON */

#define INTERACT				'I'			/* COMMON */
#define BATCH					'B'			/* COMMON */
#define EMBED					'E'			/* COMMON */

#define LOAD					1			/* LOAD */
#define DUMP					0			/* LOAD */

#if defined(WIN32S)
#define DEFAULT 				'\0'		/* COMMON */
#else
#define DEFAULT 				'\n'		/* COMMON */
#endif

#define COL_NAME				1
#define CREATE_INDEX			2
#define CREATE_SCHEMA			3
#define CREATE_TABLE			4
#define CREATE_VIEW				5
#define DEFAULT_SCHEMA			6
#define GRANT					7
#define INDEX					8
#define INSERT					9
#define PASSWORD				10
#define SCHEMA					11
#define TABLE					12
#define VIEW					13
#define WHERE					14
#define USER					15
#define CREATE_SECURE_SCHEMA	16
#define OSUSER					17

#define BAD_FILE				301			/* LOAD */
#define CLEAR					302			/* LOAD */
#define COMMENT					303			/* LOAD */
#define COMMIT_INTERVAL			304			/* LOAD */
#define DATA					305			/* COMMON */
#define DEBUG_FLAG				306			/* COMMON */
#define DELIMITOR				307			/* LOAD */
#define DFILE					308			/* UNLOAD */	
#define ENABLE_DB				309			/* LOAD */
#define END_OF_FIELD_DEF		310			/* LOAD */
#define END_OF_MAIN_FILE		311			/* LOAD */
#define END_OF_SCHEMA			312			/* LOAD */
#define END_OF_SPEC_FILE		313			/* COMMON */
#define END_OF_TABLE			314			/* LOAD */
#define END_POSITION			315			/* LOAD */
#define EVERY_THING				316			/* COMMON */		
#define EXISTING_TABLE			317			/* LOAD */

#define FILE_MODE				318			/* COMMON */
#define FORM_COL_PRIV			319			/* UNLOAD */
#define FORM_GRANT_CLAUSE		320			/* UNLOAD */
#define FORM_INDEX_COL			321			/* UNLOAD */
#define FORM_INDEX_CLAUSE		322			/* UNLOAD */
#define FORM_ON_TO_CLAUSE		323			/* UNLOAD */
#define FORM_TAB_PRIV			324			/* UNLOAD */

#define INPUT_FILE				325			/* LOAD */
#define	JOIN 					326			/* UNLOAD */
#define	KEYWORD 				327			/* LOAD */
#define LOG_FILE				328			/* LOAD */
#define MAIN_FILE				329			/* COMMON */
#define NEW						330			/* LOAD */
#define NO_MORE_SPEC			331			/* COMMON */
#define NON_ANSI_MODE			332			/* LOAD */
#define OVERLAP					333			/* LOAD */
#define RELATION_NAME			334			/* COMMON */
#define RENAME					335			/* COMMON */
#define SPACE					336			/* LOAD */
#define SPEC_FILE				337			/* COMMON */
#define START_POSITION			338			/* LOAD */
#define UNKNOWN_STATEMENT		339			/* LOAD */
#define VAR 					340			/* UNLOAD */	
#define WHERE_OPTION 			341			/* UNLOAD */	
#define WITH					342			/* COMMON */
#define PRESERVE_BLANKS			343		/* COMMON */
#define RENAME_USER				344		/* LOAD */

#define	ACC_LIST_LEN			33		/* LOAD */
#define EOS_STR_LEN				34		/* LOAD */
#define EOT_STR_LEN				33		/* LOAD */
#define	DEFAULT_COMMIT_INTERVAL 25			/* LOAD */
#define	DOUBLE_LEN				23		/* UNLOAD */
#define FIX_CHAR				2		/* LOAD */
#define INT_LEN 				11		/* UNLOAD */

#define LOD_BAD_BUFFER_LEN 		300			/* LOAD */ 
#define LOD_LOG_BUFFER_LEN 		200			/* LOAD */ 
#define LOD_DBMS_NAME_LEN 		18			/* LOAD */ 
#define	MAX_INTEGER				2147483647	/* LOAD */
#define MAX_NUM_PWD				3			/* LOAD */
#define	MAX_SMALLINT			32767		/* LOAD */
#define	MIN_INTEGER				-2147483648	/* LOAD */
#define	MIN_SMALLINT			-32768		/* LOAD */
#define PATTERN_SIZE			10			/* LOAD */
#define	REAL_LEN				14			/* UNLOAD */
#define SMALLINT_LEN			6			/* UNLOAD */
#define TIMESTAMP_LEN			19			/* UNLOAD */


/* THIS is 2 more than RIS_MAX_STMT_LEN */
exec sql define SQL_MAX_STMT_LEN		32767;		/* COMMON */
exec sql define STRING_MAX_LEN			80;			/* COMMON */
exec sql define SQL_SMALL_STMT_LEN		512;		/* COMMON */

#define CHECK_ID_SIZE_OK(ACTUAL,MAX_ID) \
		( (ACTUAL) < (MAX_ID) ? TRUE : FALSE )

/*
**	TYPES
*/

/*
**	VARIABLES
*/

#endif
