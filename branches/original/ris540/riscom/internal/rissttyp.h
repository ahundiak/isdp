/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							rissttyp.h
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
#ifndef RIS_STTYP_H
#define RIS_STTYP_H

#ifndef COM_EXTERN
# ifdef COM_GLOBAL_DEFINE
#  define COM_EXTERN
# else
#  define COM_EXTERN extern
# endif
#endif

#ifndef COM_INITIAL
# ifdef COM_GLOBAL_DEFINE
#  define COM_INITIAL(value) = value
# else
#  define COM_INITIAL(value)
# endif
#endif
 
/*
**	INCLUDES
*/


/*
**	DEFINES
*/
#define RIS_UNUSED_STMT						0
#define	RIS_ALTER_SCHEMA_STMT				1
#define	RIS_ALTER_TABLE_STMT				2
#define	RIS_CLOSE_SCHEMA_STMT				3
#define	RIS_COMMIT_STMT						4
#define	RIS_CREATE_INDEX_STMT				5
#define	RIS_CREATE_SCHEMA_STMT				6
#define	RIS_CREATE_TABLE_STMT				7
#define	RIS_CREATE_VIEW_STMT				8
#define	RIS_DECLARE_SUPERSCHEMA_STMT		9
#define	RIS_DECLARE_TABLE_STMT				10
#define	RIS_DECLARE_VIEW_STMT				11
#define	RIS_DEFAULT_SCHEMA_STMT				12
#define	RIS_DELETE_STMT						13
#define	RIS_DROP_INDEX_STMT					14
#define	RIS_DROP_SCHEMA_STMT				15
#define	RIS_DROP_TABLE_STMT					16
#define	RIS_DROP_VIEW_STMT					17
#define	RIS_EXEC_STMT						18
#define RIS_GRANT_ON_TABLE_STMT             19
#define	RIS_INSERT_STMT						20
#define	RIS_LOCK_TABLES_STMT				21
#define	RIS_OPEN_SCHEMA_STMT				22
#define	RIS_REDECLARE_SUPERSCHEMA_STMT		23
#define RIS_REVOKE_ON_TABLE_STMT			24
#define	RIS_ROLLBACK_STMT					25
#define	RIS_SELECT_STMT						26
#define	RIS_SET_STMT						27
#define	RIS_UNDECLARE_SUPERSCHEMA_STMT		28
#define	RIS_UNDECLARE_TABLE_STMT			29
#define	RIS_UNDECLARE_VIEW_STMT				30
#define	RIS_UPDATE_STMT						31
#define	RIS_DECLARE_SCHEMA_STMT				32
#define	RIS_UNDECLARE_SCHEMA_STMT			33
#define	RIS_GRANT_STMT						34
#define RIS_GRANT_SCHEMA_STMT				36
#define RIS_GRANT_CONNECT_STMT				37
#define RIS_GRANT_RESOURCE_STMT				38
#define	RIS_REVOKE_STMT						39
#define RIS_REVOKE_SCHEMA_STMT				40
#define RIS_REVOKE_CONNECT_STMT				41
#define RIS_REVOKE_RESOURCE_STMT			42
#define RIS_LAST_STMT						43

/*
**	TYPES
*/

/*
**	VARIABLES
*/

/*	RIS statement types (NOT TO BE CHANGED BY MERE MORTALS) */

COM_EXTERN  char *RIS_stmt_type_names[RIS_LAST_STMT]
#ifdef COM_GLOBAL_DEFINE
= {
	"UNUSED",
	"ALTER_SCHEMA",
	"ALTER_TABLE",
	"CLOSE_SCHEMA",
	"COMMIT",
	"CREATE_INDEX",
	"CREATE_SCHEMA",
	"CREATE_TABLE",
	"CREATE_VIEW",
	"DECLARE_SUPERSCHEMA",
	"DECLARE_TABLE",
	"DECLARE_VIEW",
	"DEFAULT_SCHEMA",
	"DELETE",
	"DROP_INDEX",
	"DROP_SCHEMA",
	"DROP_TABLE",
	"DROP_VIEW",
	"EXEC",
	"GRANT",
	"INSERT",
	"LOCK_TABLES",
	"OPEN_SCHEMA",
	"REDECLARE_SUPERSCHEMA",
	"REVOKE",
	"ROLLBACK",
	"SELECT",
	"SET",
	"UNDECLARE_SUPERSCHEMA",
	"UNDECLARE_TABLE",
	"UNDECLARE_VIEW",
	"UPDATE",
	"DECLARE_SCHEMA",
	"UNDECLARE_SCHEMA",
	"GRANT_ON_TABLE",
	"GRANT_SCHEMA",
	"GRANT_CONNECT",
	"GRANT_RESOURCE",
	"REVOKE_ON_TABLE",
	"REVOKE_SCHEMA",
	"REVOKE_CONNECT",
	"REVOKE_RESOURCE",
}
#endif
;

#endif