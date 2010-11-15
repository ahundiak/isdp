/* Do not alter this SPC information: $Revision: 1.2.39.1 $ */
/*
** Copyright 1993, Intergraph Corporation, All Rights Reserved
*/

/*
**	NAME:							rislimit.h
**	AUTHORS:						RIS Development Group
**	CREATION DATE:					3/88
**	ABSTRACT:
**		This file is included in all RIS routines to identify
**		system limits.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/

/*
**	TYPES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/*
**	DEFINES
*/

#ifndef RISLIMITS_H

#define RISLIMITS_H

/* x/open limits */

#if 0
exec sql define RIS_MAX_CHAR_STRING_SIZE		240;
#endif
#define RIS_MAX_CHAR_STRING_SIZE				240

#if 0
exec sql define RIS_MAX_PRECISION           	15;
#endif
#define RIS_MAX_PRECISION     	     			15

#if 0
exec sql define RIS_INTEGER_PRECISION       	10;
#endif
#define RIS_INTEGER_PRECISION       			10

#if 0
exec sql define RIS_SMALLINT_PRECISION      	5;
#endif
#define RIS_SMALLINT_PRECISION      			5

#if 0
exec sql define RIS_REAL_PRECISION          	7;
#endif
#define RIS_REAL_PRECISION          			7

#if 0
exec sql define RIS_DOUBLE_PRECISION        	15;
#endif
#define RIS_DOUBLE_PRECISION        			15

#if 0
exec sql define RIS_DATETIME_PRECISION      	24;
#endif
#define RIS_DATETIME_PRECISION      			24

#if 0
exec sql define RIS_MAX_TABLE_COLUMNS			254;
#endif
#define RIS_MAX_TABLE_COLUMNS					254

#if 0
exec sql define RIS_MAX_ROW_LENGTH				8192;
#endif
#define RIS_MAX_ROW_LENGTH						8192

#if 0
exec sql define RIS_MAX_INDEX_COLUMNS			8;
#endif
#define RIS_MAX_INDEX_COLUMNS					8

#if 0
exec sql define RIS_MAX_INDEX_LENGTH			120;
#endif
#define RIS_MAX_INDEX_LENGTH					120

#if 0
exec sql define RIS_MAX_GROUP_BY_COLUMNS		10;
#endif
#define RIS_MAX_GROUP_BY_COLUMNS				10

#if 0
exec sql define RIS_MAX_GROUP_BY_LENGTH			2008;
#endif
#define RIS_MAX_GROUP_BY_LENGTH					2008

#if 0
exec sql define RIS_MAX_ORDER_BY_COLUMNS		10;
#endif
#define RIS_MAX_ORDER_BY_COLUMNS				10

#if 0
exec sql define RIS_MAX_ORDER_BY_LENGTH			2008;
#endif
#define RIS_MAX_ORDER_BY_LENGTH					2008


#if 0
exec sql define RIS_MAX_ID_SIZE 				32;
#endif
#define RIS_MAX_ID_SIZE 						32

#if 0
exec sql define RIS_PD_KEYS 					6;
#endif
#define RIS_PD_KEYS 							6

	/* max-id-size + pd_keys_size */
#if 0
exec sql define RIS_MAX_PASSWD_SIZE				38;
#endif
#define RIS_MAX_PASSWD_SIZE						38

#if 0
exec sql define RIS_MAX_PATH_SIZE				241;
#endif
#define RIS_MAX_PATH_SIZE						241

#if 0
exec sql define RIS_CPP_MAX_MACRO_LEN			81;
#endif
#define RIS_CPP_MAX_MACRO_LEN					81	

#if 0
exec sql define RIS_MAX_NODE_SIZE				29;
#endif
#define RIS_MAX_NODE_SIZE						29

#if 0
exec sql define RIS_MAX_STRING_SIZE				81;
#endif
#define RIS_MAX_STRING_SIZE						81

#if 0
exec sql define RIS_MAX_HOST_PROGRAM_SIZE		5;
#endif
#define RIS_MAX_HOST_PROGRAM_SIZE 				5

#if 0
exec sql define RIS_MAX_OS400_HOST_PROGRAM_SIZE 22;
#endif
#define RIS_MAX_OS400_HOST_PROGRAM_SIZE       	22

#if 0
exec sql define RIS_MAX_OS400_DIC_DBNAME_SIZE   11;
#endif
#define RIS_MAX_OS400_DIC_DBNAME_SIZE   		11

#if 0
exec sql define RIS_MAX_LU_NAME_SIZE			18;
#endif
#define RIS_MAX_LU_NAME_SIZE 					18

#if 0
exec sql define RIS_MAX_MODE_NAME_SIZE			9;
#endif
#define RIS_MAX_MODE_NAME_SIZE 					9

#if 0
exec sql define RIS_MAX_GROUP_SIZE				9;
#endif
#define RIS_MAX_GROUP_SIZE 						9

#if 0
exec sql define RIS_MAX_RACF_PASSWD_SIZE		9;
#endif
#define RIS_MAX_RACF_PASSWD_SIZE 				9

#if 0
exec sql define RIS_ANY_SCALE               	255;
#endif
#define RIS_ANY_SCALE           	        	0xff

#if 0
exec sql define RIS_DEFAULT_DECIMAL_PRECISION	8;
#endif
#define RIS_DEFAULT_DECIMAL_PRECISION			8

#if 0
exec sql define RIS_DEFAULT_DECIMAL_SCALE		0;
#endif
#define RIS_DEFAULT_DECIMAL_SCALE				0

#if 0
exec sql define RIS_MAX_OPEN_SCHEMAS			40;
#endif
#define RIS_MAX_OPEN_SCHEMAS					40

#if 0
exec sql define RIS_MAX_OPEN_SUPERSCHEMAS		10;
#endif
#define RIS_MAX_OPEN_SUPERSCHEMAS				10

#if 0
exec sql define RIS_MAX_SECONDARY_SCHEMAS		9;
#endif
#define RIS_MAX_SECONDARY_SCHEMAS				9	

#if 0
exec sql define RIS_MAX_DICT_STMTS				30;
#endif
#define RIS_MAX_DICT_STMTS						30

#if 0
exec sql define RIS_MAX_STMTS					542;
#endif
#define RIS_MAX_STMTS							542	

#if 0
exec sql define RIS_DEF_ID						1;
#endif
#define RIS_DEF_ID								0x1

#if 0
exec sql define RIS_MAX_ALLOC_MARK				256;
#endif
#define RIS_MAX_ALLOC_MARK					    256	

#if 0
exec sql define RIS_MARK_BLOCK					2;
#endif
#define RIS_MARK_BLOCK							0x2

#if 0
exec sql define RIS_MAX_ERROR_MSG				160;
#endif
#define RIS_MAX_ERROR_MSG						160

#if 0
exec sql define RIS_MAX_ERROR_NAME				40;
#endif
#define RIS_MAX_ERROR_NAME						40

#if 0
exec sql define RIS_MAX_DBPARMS_SIZE			512;
#endif
#define RIS_MAX_DBPARMS_SIZE					512

#if 0
exec sql define ALIGN							8;
#endif
#define ALIGN									8

#if 0
exec sql define RIS_AUTH_SIZE					8;
#endif
#define RIS_AUTH_SIZE							8

	/*
	** Maximum # of input bind variables or fetch items in a dictionary
	** statement.  This cannot exceed the # of bits in the variables used to
	** check upper/lowercase data switching.  These are currently ushorts.
	** See riscase.h and RISsrv_*_to_*case in server.h.
	**
	** NOTE:  This cannot be increased without changing the type of 
	** RISsrv_*_to_*case.  It cannot exceed 32 without rewriting the
	** macros in riscase.h.
	*/

#if 0
exec sql define RIS_MAX_DICT_PARAMS				32;
#endif
#define RIS_MAX_DICT_PARAMS						32

	/* 
	** max # of schemas in a database; currently used in dd by informix
	*/

#if 0
exec sql define RIS_MAX_SCHEMAS_PER_DB			300;
#endif
#define RIS_MAX_SCHEMAS_PER_DB					300

    /*
    ** When loading database information into the risviews table,
    ** this specifies the size of the view-string chunk.
    */
#if 0
exec sql define RIS_MAX_VIEWSTRING_SIZE         65;
#endif
#define RIS_MAX_VIEWSTRING_SIZE                 65

/* CHILD_TIMEOUT is how often local servers check to see is parent is alive */

#if 0
exec sql define CHILD_TIMEOUT					300;
#endif
#define CHILD_TIMEOUT							300

/* following macros are for shared memory and semaphores */

/* RIS_SHM_KEY = 0x52495300 = "RIS" */

#if 0
exec sql define RIS_SHM_KEY						1380537088;
#endif
#define RIS_SHM_KEY								0x52495300

#if 0
exec sql define SHM_SEG_ACCESS					0666;
#endif
#define SHM_SEG_ACCESS							0666

/* RIS_SEM_KEY = 0x52495300 = "RIS" */

#if 0
exec sql define RIS_SEM_KEY						1380537088;
#endif
#define RIS_SEM_KEY								0x52495300

#if 0
exec sql define SEM_SET_ACCESS					0666;
#endif
#define SEM_SET_ACCESS							0666


#if 0
exec sql define RIS_BLOCK_SIZE					1016;
#endif
#define RIS_BLOCK_SIZE							1016


#if 0
exec sql define RIS_MAX_STMT_LEN        		32765;
#endif
#define RIS_MAX_STMT_LEN        				32765

#if 0
exec sql define RIS_TIMESTAMP_BUFFER_SIZE       512;
#endif
#define RIS_TIMESTAMP_BUFFER_SIZE               512

#if 0
exec sql define RIS_INITIAL_BUFFER_SIZE			66552;
#endif
#define RIS_INITIAL_BUFFER_SIZE					66552

#if 0
exec sql define RIS_MIN_FETCH_BUF_SIZE			66552;
#endif
#define RIS_MIN_FETCH_BUF_SIZE					66552


#if 0
exec sql define RIS_TCP_SERVICE_NUMBER			180;
#endif
#define RIS_TCP_SERVICE_NUMBER					180

/* RIS_MAX_PROTOCOLS = 4 = (XNS, TCP, DNP, ISO) */

#if 0
exec sql define RIS_MAX_PROTOCOLS				4;
#endif
#define RIS_MAX_PROTOCOLS						4

#if 0
exec sql define RIS_MAX_TRANSACTIONS			40;
#endif
#define RIS_MAX_TRANSACTIONS					40

#if 0
exec sql define RIS_MAX_TAB_IN_MEM              1024;
#endif
#define RIS_MAX_TAB_IN_MEM                      1024

#if 0
exec sql define RIS_MAX_KEYWORD_SIZE            18;
#endif
#define RIS_MAX_KEYWORD_SIZE                    18

#if 0
exec sql define RIS_TIMESTAMP_INTERVAL_MIN     	0;
#endif
#define RIS_TIMESTAMP_INTERVAL_MIN        		0

#if 0
exec sql define RIS_TIMESTAMP_INTERVAL_MAX     	100000;
#endif
#define RIS_TIMESTAMP_INTERVAL_MAX        		100000

#if 0
exec sql define RIS_INITIAL_TIMEOUT_MIN        	0;
#endif
#define RIS_INITIAL_TIMEOUT_MIN        			0

#if 0
exec sql define RIS_INITIAL_TIMEOUT_MAX        	100000;
#endif
#define RIS_INITIAL_TIMEOUT_MAX        			100000

#if 0
exec sql define RIS_TIMESTAMP_TOLERANCE_MIN    	0;
#endif
#define RIS_TIMESTAMP_TOLERANCE_MIN        		0

#if 0
exec sql define RIS_TIMESTAMP_TOLERANCE_MAX    	1000;
#endif
#define RIS_TIMESTAMP_TOLERANCE_MAX        		1000

#if 0
exec sql define RIS_BUFFER_FULL_SIZE_MIN       	8;
#endif
#define RIS_BUFFER_FULL_SIZE_MIN        		8

#if 0
exec sql define RIS_BUFFER_FULL_SIZE_MAX       	8000;
#endif
#define RIS_BUFFER_FULL_SIZE_MAX        		8000

#if 0
exec sql define RIS_BUFFER_FULL_TIMEOUT_MIN    	0;
#endif
#define RIS_BUFFER_FULL_TIMEOUT_MIN        		0

#if 0
exec sql define RIS_BUFFER_FULL_TIMEOUT_MAX    	100000;
#endif
#define RIS_BUFFER_FULL_TIMEOUT_MAX        		100000

#if 0
exec sql define RIS_RESPONSE_INTERVAL_MIN    	-100000;
#endif
#define RIS_RESPONSE_INTERVAL_MIN        		-100000

#if 0
exec sql define RIS_RESPONSE_INTERVAL_MAX   	100000;
#endif
#define RIS_RESPONSE_INTERVAL_MAX        		100000

#if 0
exec sql define RIS_MAX_OS400_ID_SIZE              10;
#endif
#define RIS_MAX_OS400_ID_SIZE                      10

#if 0
exec sql define RIS_EXTERN_HASH_SIZE                  4;
#endif
#define RIS_EXTERN_HASH_SIZE                  4

#if 0
exec sql define RIS_MAX_ATTEMPTS                      10;
#endif
#define RIS_MAX_ATTEMPTS                              10

/*
** Define for ris language name size
*/
#if 0
exec sql define RIS_MAX_LANGNAME_SIZE	        32;
#endif
#define RIS_MAX_LANGNAME_SIZE	                32

/*
** Define for directory size { 8(dirname)  + '.' + 3 (ext) }
*/
#if 0
exec sql define RIS_MAX_DIRNAME_SIZE	       	12;
#endif
#define RIS_MAX_DIRNAME_SIZE	                12

/*
** Define for ris type size 
*/
#if 0
exec sql define RIS_MAX_TYPE_STRING_SIZE	       	18;
#endif
#define RIS_MAX_TYPE_STRING_SIZE	                18

#endif
