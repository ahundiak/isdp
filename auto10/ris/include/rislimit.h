/* Do not alter this SPC information: $Revision: 1.2.39.1 $ */
/*
** Copyright 1993, Intergraph Corporation, All Rights Reserved
*/

/*
**	NAME:          rislimit.h
**	AUTHORS:       RIS Development Group
**	CREATION DATE: 3/88
**	ABSTRACT:
**		This file is included in all RIS routines to identify
**		system limits.
**	
**	REVISION HISTORY:
*/

#ifndef RISLIMITS_H
#define RISLIMITS_H

#define RIS_MAX_CHAR_STRING_SIZE         240
#define RIS_MAX_PRECISION                 15
#define RIS_INTEGER_PRECISION             10
#define RIS_SMALLINT_PRECISION             5
#define RIS_REAL_PRECISION                 7
#define RIS_DOUBLE_PRECISION              15
#define RIS_DATETIME_PRECISION            24
#define RIS_MAX_TABLE_COLUMNS            254
#define RIS_MAX_ROW_LENGTH              8192
#define RIS_MAX_INDEX_COLUMNS              8
#define RIS_MAX_INDEX_LENGTH             120
#define RIS_MAX_GROUP_BY_COLUMNS          10
#define RIS_MAX_GROUP_BY_LENGTH         2008
#define RIS_MAX_ORDER_BY_COLUMNS          10
#define RIS_MAX_ORDER_BY_LENGTH         2008
#define RIS_MAX_ID_SIZE                   32
#define RIS_PD_KEYS                        6
#define RIS_MAX_PASSWD_SIZE               38
#define RIS_MAX_PATH_SIZE                241
#define RIS_CPP_MAX_MACRO_LEN             81
#define RIS_MAX_NODE_SIZE                 29
#define RIS_MAX_STRING_SIZE               81
#define RIS_MAX_HOST_PROGRAM_SIZE          5
#define RIS_MAX_OS400_HOST_PROGRAM_SIZE   22
#define RIS_MAX_OS400_DIC_DBNAME_SIZE     11
#define RIS_MAX_LU_NAME_SIZE              18
#define RIS_MAX_MODE_NAME_SIZE             9
#define RIS_MAX_GROUP_SIZE                 9
#define RIS_MAX_RACF_PASSWD_SIZE           9
#define RIS_ANY_SCALE                   0xff
#define RIS_DEFAULT_DECIMAL_PRECISION      8
#define RIS_DEFAULT_DECIMAL_SCALE          0
#define RIS_MAX_OPEN_SCHEMAS              40
#define RIS_MAX_OPEN_SUPERSCHEMAS         10
#define RIS_MAX_SECONDARY_SCHEMAS          9
#define RIS_MAX_DICT_STMTS                30
#define RIS_MAX_STMTS                    542
#define RIS_DEF_ID                       0x1
#define RIS_MAX_ALLOC_MARK               256
#define RIS_MARK_BLOCK                   0x2
#define RIS_MAX_ERROR_MSG                160
#define RIS_MAX_ERROR_NAME                40
#define RIS_MAX_DBPARMS_SIZE             512
#define ALIGN                              8
#define RIS_AUTH_SIZE                      8
#define RIS_MAX_DICT_PARAMS               32
#define RIS_MAX_SCHEMAS_PER_DB           300
#define RIS_MAX_VIEWSTRING_SIZE           65
#define CHILD_TIMEOUT                    300
#define RIS_SHM_KEY               0x52495300
#define SHM_SEG_ACCESS                  0666
#define RIS_SEM_KEY               0x52495300
#define SEM_SET_ACCESS                  0666
#define RIS_BLOCK_SIZE                  1016
#define RIS_MAX_STMT_LEN               32765
#define RIS_TIMESTAMP_BUFFER_SIZE        512
#define RIS_INITIAL_BUFFER_SIZE        66552
#define RIS_MIN_FETCH_BUF_SIZE         66552
#define RIS_TCP_SERVICE_NUMBER           180
#define RIS_MAX_PROTOCOLS                  4
#define RIS_MAX_TRANSACTIONS              40
#define RIS_MAX_TAB_IN_MEM              1024
#define RIS_MAX_KEYWORD_SIZE              18
#define RIS_TIMESTAMP_INTERVAL_MIN         0
#define RIS_TIMESTAMP_INTERVAL_MAX    100000
#define RIS_INITIAL_TIMEOUT_MIN            0
#define RIS_INITIAL_TIMEOUT_MAX       100000
#define RIS_TIMESTAMP_TOLERANCE_MIN        0
#define RIS_TIMESTAMP_TOLERANCE_MAX     1000
#define RIS_BUFFER_FULL_SIZE_MIN           8
#define RIS_BUFFER_FULL_SIZE_MAX        8000
#define RIS_BUFFER_FULL_TIMEOUT_MIN        0
#define RIS_BUFFER_FULL_TIMEOUT_MAX   100000
#define RIS_RESPONSE_INTERVAL_MIN    -100000
#define RIS_RESPONSE_INTERVAL_MAX     100000
#define RIS_MAX_OS400_ID_SIZE             10
#define RIS_EXTERN_HASH_SIZE               4
#define RIS_MAX_ATTEMPTS                  10
#define RIS_MAX_LANGNAME_SIZE             32
#define RIS_MAX_DIRNAME_SIZE              12
#define RIS_MAX_TYPE_STRING_SIZE          18

#endif
