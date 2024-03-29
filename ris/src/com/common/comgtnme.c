/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							comgtnme.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/87
**	ABSTRACT:
**		Contains the routines that returns the string literal for a token.
**	
**	REVISION HISTORY:
*/
#include <stdio.h>
#include "riscom.h"
#include "ristoken.h"

static  char string[11];

extern char * RIScom_get_token_name(int token)
{
	static struct print_nodes 
	{
		int value;
		char * name;
	}print_treenode_charrep[] =
	{
		{0,"ZERO"},
		{RIS_TOK_ADD,"ADD"},
		{RIS_TOK_ALIAS_NAME,"ALIAS_NAME"},
		{RIS_TOK_ALL,"ALL"},
		{RIS_TOK_ALTER,"ALTER"},
		{RIS_TOK_ALTER_SCHEMA,"ALTER_SCHEMA"},
		{RIS_TOK_ALTER_TABLE,"ALTER_TABLE"},
		{RIS_TOK_AND,"AND"},
		{RIS_TOK_ANSI,"ANSI"},
		{RIS_TOK_ANY,"ANY"},
		{RIS_TOK_APPROX_NUM_LIT,"APPROX_NUM_LIT"},
		{RIS_TOK_ARCH,"ARCH"},
		{RIS_TOK_ARRAY_SPEC_LIST,"ARRAY_SPEC_LIST"},
		{RIS_TOK_AS,"AS"},
		{RIS_TOK_ASC,"ASC"},
		{RIS_TOK_ASGN,"ASGN"},
		{RIS_TOK_ASYNC,"ASYNC"},
		{RIS_TOK_ASYNC_ID,"ASYNC_ID"},
		{RIS_TOK_ASYNC_ID_LIST,"ASYNC_ID_LIST"},
		{RIS_TOK_ATTR,"ATTR"},
		{RIS_TOK_AUTHORIZATION,"AUTHORIZATION"},
		{RIS_TOK_AUTH_ID,"AUTH_ID"},
		{RIS_TOK_AUTO,"AUTO"},
		{RIS_TOK_AUTOCOMMIT,"AUTOCOMMIT"},
		{RIS_TOK_AUTORENAME,"AUTORENAME"},
		{RIS_TOK_AVG,"AVG"},
		{RIS_TOK_BEGIN,"BEGIN"},
		{RIS_TOK_BEGIN_DECLARE,"BEGIN_DECLARE"},
		{RIS_TOK_BETWEEN,"BETWEEN"},
		{RIS_TOK_BETWEEN_AND,"BETWEEN_AND"},
		{RIS_TOK_BLANK,"BLANK"},
		{RIS_TOK_BLANKSTRIP,"BLANK_STRIP"},
		{RIS_TOK_BUFFER,"BUFFER"},
		{RIS_TOK_BUFFER_SIZE,"BUFFER_SIZE"},
		{RIS_TOK_BUFFER_TIMEOUT,"BUFFER_TIMEOUT"},
		{RIS_TOK_BY,"BY"},
		{RIS_TOK_CHAR,"CHAR"},
		{RIS_TOK_CHARACTER,"CHARACTER"},
		{RIS_TOK_CHAR_STR_LIT,"CHAR_STR_LIT"},
		{RIS_TOK_CLEAR,"CLEAR"},
		{RIS_TOK_CLOSE,"CLOSE"},
		{RIS_TOK_CLOSE_SCHEMA,"CLOSE_SCHEMA"},
		{RIS_TOK_COLON,"COLON"},
		{RIS_TOK_COLUMN_DEF,"COLUMN_DEF"},
		{RIS_TOK_COLUMN_DEF_LIST,"COLUMN_DEF_LIST"},
		{RIS_TOK_COLUMN_LIST,"COLUMN_LIST"},
		{RIS_TOK_COL_NAME,"COL_NAME"},
		{RIS_TOK_COMMA,"COMMA"},
		{RIS_TOK_COMMIT,"COMMIT"},
		{RIS_TOK_COMPLETION,"COMPLETION"},
		{RIS_TOK_CONNECT,"CONNECT"},
		{RIS_TOK_CONST,"CONST"},
		{RIS_TOK_CONTINUE,"CONTINUE"},
		{RIS_TOK_COUNT,"COUNT"},
		{RIS_TOK_CREATE,"CREATE"},
		{RIS_TOK_CREATE_INDEX,"CREATE_INDEX"},
		{RIS_TOK_CREATE_SCHEMA,"CREATE_SCHEMA"},
		{RIS_TOK_CREATE_TABLE,"CREATE_TABLE"},
		{RIS_TOK_CREATE_VIEW,"CREATE_VIEW"},
		{RIS_TOK_CURRENT,"CURRENT"},
		{RIS_TOK_CURRENT_TIMESTAMP,"CURRENT_TIMESTAMP"},
		{RIS_TOK_CURSOR,"CURSOR"},
		{RIS_TOK_CURSOR_NAME,"CURSOR_NAME"},
		{RIS_TOK_C_CHAR_STR_LIT,"C_CHAR_STR_LIT"},
		{RIS_TOK_DATABASE,"DATABASE"},
		{RIS_TOK_DATETIME,"DATETIME"},
		{RIS_TOK_DAY,"DAY"},
		{RIS_TOK_DB2,"DB2"},
		{RIS_TOK_DBNAME,"DBNAME"},
		{RIS_TOK_DB_TYPE_LIST,"DB_TYPE_LIST"},
		{RIS_TOK_DEBUG,"DEBUG"},
		{RIS_TOK_DEC,"DEC"},
		{RIS_TOK_DECIMAL,"DECIMAL"},
		{RIS_TOK_DECLARE,"DECLARE"},
		{RIS_TOK_DECLARE_SCHEMA,"DECLARE_SCHEMA"},
		{RIS_TOK_DECLARE_SUPERSCHEMA,"DECLARE_SUPERSCHEMA"},
		{RIS_TOK_DECLARE_TABLE,"DECLARE_TABLE"},
		{RIS_TOK_DECLARE_VIEW,"DECLARE_VIEW"},
		{RIS_TOK_DEFAULT,"DEFAULT"},
		{RIS_TOK_DEFAULT_SCHEMA,"DEFAULT_SCHEMA"},
		{RIS_TOK_DEFINE,"DEFINE"},
		{RIS_TOK_DEFINENAME,"DEFINENAME"},
		{RIS_TOK_DELETE,"DELETE"},
		{RIS_TOK_DESC,"DESC"},
		{RIS_TOK_DESCRIBE,"DESCRIBE"},
		{RIS_TOK_DESCRIBE_INPUT,"DESCRIBE_INPUT"},
		{RIS_TOK_DESCRIBE_OUTPUT,"DESCRIBE_OUTPUT"},
		{RIS_TOK_DESCRIPTOR,"DESCRIPTOR"},
		{RIS_TOK_DESC_NAME,"DESC_NAME"},
		{RIS_TOK_DIR,"DIR"},
		{RIS_TOK_DISTINCT,"DISTINCT"},
		{RIS_TOK_DIV,"DIV"},
		{RIS_TOK_DNP,"DNP"},
		{RIS_TOK_DOT,"DOT"},
		{RIS_TOK_DOUBLE,"DOUBLE"},
		{RIS_TOK_DROP,"DROP"},
		{RIS_TOK_DROP_INDEX,"DROP_INDEX"},
		{RIS_TOK_DROP_SCHEMA,"DROP_SCHEMA"},
		{RIS_TOK_DROP_TABLE,"DROP_TABLE"},
		{RIS_TOK_DROP_VIEW,"DROP_VIEW"},
		{RIS_TOK_ELSE,"ELSE"},
		{RIS_TOK_ENABLE,"ENABLE"},
		{RIS_TOK_END,"END"},
		{RIS_TOK_ENDIF,"ENDIF"},
		{RIS_TOK_END_DECLARE,"END_DECLARE"},
		{RIS_TOK_ENFORCE,"ENFORCE"},
		{RIS_TOK_ENV,"ENV"},
		{RIS_TOK_EQ,"EQ"},
		{RIS_TOK_ERROR,"ERROR"},
		{RIS_TOK_EXACT_NUM_LIT,"EXACT_NUM_LIT"},
		{RIS_TOK_EXCLUDE,"EXCLUDE"},
		{RIS_TOK_EXCLUSIVE,"EXCLUSIVE"},
		{RIS_TOK_EXEC,"EXEC"},
		{RIS_TOK_EXECUTE,"EXECUTE"},
		{RIS_TOK_EXECUTE_IMMEDIATE,"EXECUTE_IMMEDIATE"},
		{RIS_TOK_EXISTS,"EXISTS"},
		{RIS_TOK_EXTERN,"EXTERN"},
		{RIS_TOK_FEATURE,"FEATURE"},
		{RIS_TOK_FETCH,"FETCH"},
		{RIS_TOK_FILENAME,"FILENAME"},
		{RIS_TOK_FLOAT,"FLOAT"},
		{RIS_TOK_FOR,"FOR"},
		{RIS_TOK_FORCE,"FORCE"},
		{RIS_TOK_FOUND,"FOUND"},
		{RIS_TOK_FROM,"FROM"},
		{RIS_TOK_FULL,"FULL"},
		{RIS_TOK_GATEWAY,"GATEWAY"},
		{RIS_TOK_GE,"GE"},
		{RIS_TOK_GO,"GO"},
		{RIS_TOK_GOTO,"GOTO"},
		{RIS_TOK_GRANT,"GRANT"},
		{RIS_TOK_GRANTEE_LIST,"GRANTEE_LIST"},
		{RIS_TOK_GRANT_CONNECT,"GRANT_CONNECT"},
		{RIS_TOK_GRANT_ON_TABLE,"GRANT_ON_TABLE"},
		{RIS_TOK_GRANT_RESOURCE,"GRANT_RESOURCE"},
		{RIS_TOK_GRANT_SCHEMA,"GRANT_SCHEMA"},
		{RIS_TOK_GROUP,"GROUP"},
		{RIS_TOK_GROUP_BY,"GROUP_BY"},
		{RIS_TOK_GT,"GT"},
		{RIS_TOK_HAVING,"HAVING"},
		{RIS_TOK_HOST_IDENT,"HOST_IDENT"},
		{RIS_TOK_HOST_LU,"HOST_LU"},
		{RIS_TOK_HOST_PROGRAM,"HOST_PROGRAM"},
		{RIS_TOK_HOST_TYPE_SPEC_LIST,"HOST_TYPE_SPEC_LIST"},
		{RIS_TOK_HOST_VAR,"HOST_VAR"},
		{RIS_TOK_HOST_VAR_DEF,"HOST_VAR_DEF"},
		{RIS_TOK_HOST_VAR_LIST,"HOST_VAR_LIST"},
		{RIS_TOK_HOUR,"HOUR"},
		{RIS_TOK_IDENT,"IDENT"},
		{RIS_TOK_IFDEF,"IFDEF"},
		{RIS_TOK_IFDEFNAME,"IFDEFNAME"},
		{RIS_TOK_IFNDEF,"IFNDEF"},
		{RIS_TOK_IFNDEFNAME,"IFNDEFNAME"},
		{RIS_TOK_IMMEDIATE,"IMMEDIATE"},
		{RIS_TOK_IN,"IN"},
		{RIS_TOK_INCLUDE,"INCLUDE"},
		{RIS_TOK_INDEX,"INDEX"},
		{RIS_TOK_INDEX_NAME,"INDEX_NAME"},
		{RIS_TOK_INDICATOR,"INDICATOR"},
		{RIS_TOK_INFORMIX,"INFORMIX"},
		{RIS_TOK_INGRES,"INGRES"},
		{RIS_TOK_INITIAL,"INITIAL"},
		{RIS_TOK_INITIAL_TIMEOUT,"INITIAL_TIMEOUT"},
		{RIS_TOK_INPUT,"INPUT"},
		{RIS_TOK_INSERT,"INSERT"},
		{RIS_TOK_INT,"INT"},
		{RIS_TOK_INTEGER,"INTEGER"},
		{RIS_TOK_INTERVAL,"INTERVAL"},
		{RIS_TOK_INTO,"INTO"},
		{RIS_TOK_IS,"IS"},
		{RIS_TOK_LBRACK,"LBRACK"},
		{RIS_TOK_LE,"LE"},
		{RIS_TOK_LIKE,"LIKE"},
		{RIS_TOK_LIST,"LIST"},
		{RIS_TOK_LOCK,"LOCK"},
		{RIS_TOK_LOCK_TABLES,"LOCK_TABLES"},
		{RIS_TOK_LONG,"LONG"},
		{RIS_TOK_LPAREN,"LPAREN"},
		{RIS_TOK_LT,"LT"},
		{RIS_TOK_MAJOR,"MAJOR"},
		{RIS_TOK_MAX,"MAX"},
		{RIS_TOK_MIN,"MIN"},
		{RIS_TOK_MINUTE,"MINUTE"},
		{RIS_TOK_MODE,"MODE"},
		{RIS_TOK_MODIFY,"MODIFY"},
		{RIS_TOK_MONTH,"MONTH"},
		{RIS_TOK_MSSQL,"MSSQL"},
		{RIS_TOK_MUL,"MUL"},
		{RIS_TOK_NE,"NE"},
		{RIS_TOK_NETWORK,"NETWORK"},
		{RIS_TOK_NET_PROTOCOL,"NET_PROTOCOL"},
		{RIS_TOK_NODE,"NODE"},
		{RIS_TOK_NON_ANSI,"NON_ANSI"},
		{RIS_TOK_NOT,"NOT"},
		{RIS_TOK_NOT_FOUND,"NOT_FOUND"},
		{RIS_TOK_NOT_NULL,"NOT_NULL"},
		{RIS_TOK_NO_VERIFY,"NO_VERIFY"},
		{RIS_TOK_NT,"NT"},
		{RIS_TOK_NULL,"NULL"},
		{RIS_TOK_NULL_NODE,"NULL_NODE"},
		{RIS_TOK_OF,"OF"},
		{RIS_TOK_OFF,"OFF"},
		{RIS_TOK_ON,"ON"},
		{RIS_TOK_ONLY,"ONLY"},
		{RIS_TOK_OPEN,"OPEN"},
		{RIS_TOK_OPEN_SCHEMA,"OPEN_SCHEMA"},
		{RIS_TOK_OPTION,"OPTION"},
		{RIS_TOK_OR,"OR"},
		{RIS_TOK_ORACLE,"ORACLE"},
		{RIS_TOK_ORDER,"ORDER"},
		{RIS_TOK_ORDER_BY,"ORDER_BY"},
		{RIS_TOK_OS,"OS"},
		{RIS_TOK_OS400,"OS400"},
		{RIS_TOK_OSTYPE,"OSTYPE"},
		{RIS_TOK_OSUSER,"OSUSER"},
		{RIS_TOK_OUTPUT,"OUTPUT"},
		{RIS_TOK_PARAMETER,"PARAMETER"},
		{RIS_TOK_PARAM_LIST,"PARAM_LIST"},
		{RIS_TOK_PARTIAL,"PARTIAL"},
		{RIS_TOK_PASSWORD,"PASSWORD"},
		{RIS_TOK_PLUS,"PLUS"},
		{RIS_TOK_PORT,"PORT"},
		{RIS_TOK_PRECISION,"PRECISION"},
		{RIS_TOK_PREPARE,"PREPARE"},
		{RIS_TOK_PRIMARY,"PRIMARY"},
		{RIS_TOK_PRIVILEGES,"PRIVILEGES"},
		{RIS_TOK_PRIVILEGE_LIST,"PRIVILEGE_LIST"},
		{RIS_TOK_PUBLIC,"PUBLIC"},
		{RIS_TOK_QUESTION,"QUESTION"},
		{RIS_TOK_RBRACK,"RBRACK"},
		{RIS_TOK_RDB,"RDB"},
		{RIS_TOK_REAL,"REAL"},
		{RIS_TOK_REDECLARE,"REDECLARE"},
		{RIS_TOK_REDECLARE_SUPERSCHEMA,"REDECLARE_SUPERSCHEMA"},
		{RIS_TOK_REGISTER,"REGISTER"},
		{RIS_TOK_REMOTE,"REMOTE"},
		{RIS_TOK_REPLACE,"REPLACE"},
		{RIS_TOK_REPORT,"REPORT"},
		{RIS_TOK_REPORT_ERROR,"REPORT_ERROR"},
		{RIS_TOK_REPORT_SS_ERROR,"REPORT_SS_ERROR"},
		{RIS_TOK_RESOURCE,"RESOURCE"},
		{RIS_TOK_RESPONSE,"RESPONSE"},
		{RIS_TOK_RESPONSE_INTERVAL,"RESPONSE_INTERVAL"},
		{RIS_TOK_REVOKE,"REVOKE"},
		{RIS_TOK_REVOKE_CONNECT,"REVOKE_CONNECT"},
		{RIS_TOK_REVOKE_ON_TABLE,"REVOKE_ON_TABLE"},
		{RIS_TOK_REVOKE_RESOURCE,"REVOKE_RESOURCE"},
		{RIS_TOK_REVOKE_SCHEMA,"REVOKE_SCHEMA"},
		{RIS_TOK_RIS_BLOB,"RIS_BLOB"},
		{RIS_TOK_RIS_DICT_DBNAME,"RIS_DICT_DBNAME"},
		{RIS_TOK_RIS_LU,"RIS_LU"},
		{RIS_TOK_RIS_TEXT,"RIS_TEXT"},
		{RIS_TOK_ROLLBACK,"ROLLBACK"},
		{RIS_TOK_RPAREN,"RPAREN"},
		{RIS_TOK_SCHEMA,"SCHEMA"},
		{RIS_TOK_SCHEMA_LIST,"SCHEMA_LIST"},
		{RIS_TOK_SCHEMA_SPEC_LIST,"SCHEMA_SPEC_LIST"},
		{RIS_TOK_SECOND,"SECOND"},
		{RIS_TOK_SECONDARY,"SECONDARY"},
		{RIS_TOK_SECTION,"SECTION"},
		{RIS_TOK_SECURE,"SECURE"},
		{RIS_TOK_SELECT,"SELECT"},
		{RIS_TOK_SELECT_EXPR,"SELECT_EXPR"},
		{RIS_TOK_SELECT_SELECT,"SELECT_SELECT"},
		{RIS_TOK_SEMICOLON,"SEMICOLON"},
		{RIS_TOK_SERVER,"SERVER"},
		{RIS_TOK_SET,"SET"},
		{RIS_TOK_SET_MODE,"SET_MODE"},
		{RIS_TOK_SET_TRANSACTION,"SET_TRANSACTION"},
		{RIS_TOK_SHARE,"SHARE"},
		{RIS_TOK_SHORT,"SHORT"},
		{RIS_TOK_SIGNED,"SIGNED"},
		{RIS_TOK_SIZE,"SIZE"},
		{RIS_TOK_SMALLINT,"SMALLINT"},
		{RIS_TOK_SOME,"SOME"},
		{RIS_TOK_SQL,"SQL"},
		{RIS_TOK_SQLCODE,"SQLCODE"},
		{RIS_TOK_SQLDA,"SQLDA"},
		{RIS_TOK_SQLDS,"SQLDS"},
		{RIS_TOK_SQLERROR,"SQLERROR"},
		{RIS_TOK_STAR_LIST,"STAR_LIST"},
		{RIS_TOK_STATIC,"STATIC"},
		{RIS_TOK_STMT_ID,"STMT_ID"},
		{RIS_TOK_STRIP,"STRIP"},
		{RIS_TOK_STRUCT,"STRUCT"},
		{RIS_TOK_SUB,"SUB"},
		{RIS_TOK_SUM,"SUM"},
		{RIS_TOK_SUPERSCHEMA,"SUPERSCHEMA"},
		{RIS_TOK_SWAP,"SWAP"},
		{RIS_TOK_SYBASE,"SYBASE"},
		{RIS_TOK_TABLE,"TABLE"},
		{RIS_TOK_TABLES,"TABLES"},
		{RIS_TOK_TABLE_LIST,"TABLE_LIST"},
		{RIS_TOK_TABLE_NAME,"TABLE_NAME"},
		{RIS_TOK_TCP,"TCP"},
		{RIS_TOK_TEST,"TEST"},
		{RIS_TOK_TEST_COND,"TEST_COND"},
		{RIS_TOK_TIMEOUT,"TIMEOUT"},
		{RIS_TOK_TIMESTAMP,"TIMESTAMP"},
		{RIS_TOK_TIMESTAMP_LIT,"TIMESTAMP_LIT"},
		{RIS_TOK_TO,"TO"},
		{RIS_TOK_TOLERANCE,"TOLERANCE"},
		{RIS_TOK_TRANSACTION,"TRANSACTION"},
		{RIS_TOK_UCHAR,"UCHAR"},
		{RIS_TOK_UINT,"UINT"},
		{RIS_TOK_ULONG,"ULONG"},
		{RIS_TOK_UNARYMINUS,"UNARYMINUS"},
		{RIS_TOK_UNDECLARE,"UNDECLARE"},
		{RIS_TOK_UNDECLARE_SCHEMA,"UNDECLARE_SCHEMA"},
		{RIS_TOK_UNDECLARE_SUPERSCHEMA,"UNDECLARE_SUPERSCHEMA"},
		{RIS_TOK_UNDECLARE_TABLE,"UNDECLARE_TABLE"},
		{RIS_TOK_UNDECLARE_VIEW,"UNDECLARE_VIEW"},
		{RIS_TOK_UNDEF,"UNDEF"},
		{RIS_TOK_UNDEFNAME,"UNDEFNAME"},
		{RIS_TOK_UNION,"UNION"},
		{RIS_TOK_UNION_ALL_SELECT,"UNION_ALL_SELECT"},
		{RIS_TOK_UNION_SELECT,"UNION_SELECT"},
		{RIS_TOK_UNIQUE,"UNIQUE"},
		{RIS_TOK_UNIX,"UNIX"},
		{RIS_TOK_UNSIGNED,"UNSIGNED"},
		{RIS_TOK_UNSUPPORTED,"UNSUPPORTED"},
		{RIS_TOK_UPDATE,"UPDATE"},
		{RIS_TOK_USER,"USER"},
		{RIS_TOK_USHORT,"USHORT"},
		{RIS_TOK_USING,"USING"},
		{RIS_TOK_USING_DICT_OWNER,"USING_DICT_OWNER"},
		{RIS_TOK_USR_NAME,"USR_NAME"},
		{RIS_TOK_VALUES,"VALUES"},
		{RIS_TOK_VALUE_EXPR_LIST,"VALUE_EXPR_LIST"},
		{RIS_TOK_VAR,"VAR"},
		{RIS_TOK_VAR_NAME,"VAR_NAME"},
		{RIS_TOK_VERIFICATION,"VERIFICATION"},
		{RIS_TOK_VERIFY,"VERIFY"},
		{RIS_TOK_VERSION,"VERSION"},
		{RIS_TOK_VIEW,"VIEW"},
		{RIS_TOK_VIRTUAL,"VIRTUAL"},
		{RIS_TOK_VMS,"VMS"},
		{RIS_TOK_VOLATILE,"VOLATILE"},
		{RIS_TOK_WAIT,"WAIT"},
		{RIS_TOK_WHENEVER,"WHENEVER"},
		{RIS_TOK_WHERE,"WHERE"},
		{RIS_TOK_WITH,"WITH"},
		{RIS_TOK_WORK,"WORK"},
		{RIS_TOK_XNS,"XNS"},
		{RIS_TOK_YEAR,"YEAR"},
	};

	int num_of_names = (sizeof(print_treenode_charrep) / 
					    sizeof(print_treenode_charrep[0])) - 1;

/*
** if we found a char. rep. of the token_name, return it else return
** the token itself in string form
*/

	if (token <= num_of_names && token == print_treenode_charrep[token].value)
		return(print_treenode_charrep[token].name);
	else
	{
		sprintf(string,"%d",token);
		return(string);
	}
}

/******************************************************************************/
