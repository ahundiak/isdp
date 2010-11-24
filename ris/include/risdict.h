/*
------------------------------------------------------------------------

Name:								risdict.h
Author:								Dan Karier
Creation Date:						08/91
Abstract:

	This file contains definitions of dictionary information and
	structures that must be made available to the client as well
	as the server.  It is primarily dictionary table and column
	information, intended to isolate this to a single location.

	This file is included in RIScommon.h for variable definition
	and things like the EXTERN macro.

	WARNING:  This file should include nothing else.

Revision History:

01-06-1994	Dwayne A. Blumenberg	Added stuff for OS/400, 
                                        restyled definitions to improve readability.

------------------------------------------------------------------------
*/

#ifndef RISDICT_H
#define RISDICT_H

#ifdef RISDICT_GLOBAL_DEFINE
#define RISDICT_EXTERN
#else
#define RISDICT_EXTERN extern
#endif

#include "rislimit.h"
#include "riscl_sr.h"
#include "ris_err.h"
#include "riscom.h"

#define DICTIONARY_TABLE_COUNT  49  /* how many dictionary tables/views  */


/*
 ** Note -- the following are undef'd at the end of this file
 **   because they are intended for use only within this file.
 */

#define DICTIONARY_MAX_COLUMNS  23  /* how many columns in largest table */
#define DICTIONARY_MAX_INDEXES   5  /* most indexes per table */
#define UNIQUE                   1  /* unique index */
#define DUPLICATES               0  /* non-unique index */

/* NULLABLE is modified to allow more RIS dataypes  */
#define NULLABLE | 0x80  /* risattr bit - nullable means set bit */
#define NOT_NULL         /* risattr bit - not null is nothing */

	/*
	** Macros to identify an object as a version 4 or version 5 object.
	*/

# define V4_OBJECT  4
# define V5_OBJECT  5

/**********************************************************************/
/* The IBM AS/400 database (built-in to the Op Sys - OS/400) allows   */
/* only 10 characters for table, view, index, and column names.       */
/*                                                                    */
/* The macros defined below are set to the external name for an       */
/* object or column.  The value depends on the RDBMS.                 */
/*                                                                    */
/* Client has both external and internal names, but the translation	  */	 
/* will be done for OS/400 only. 									  */ 
/* Server uses external names only when dict. objects are being		  */	 
/* created.															  */	
/*                                                                    */
/* Abbreviation convention for deriving external names that are ten   */
/* ten characters or less for OS/400.  Abbreviations for plural       */
/* names is the same as the singular name.                            */
/*                                                                    */
/* 												Dwayne                */	
/*  address             Adr                                           */
/*  char                Chr                                           */
/*  column              Col                                           */
/*  database            Dbs                                           */
/*  date                Dt                                            */
/*  dbms                Dbm                                           */
/*  entered             Ent                                           */
/*  external            Ext                                           */
/*  index               Idx                                           */
/*  length              Len                                           */
/*  long                Lng                                           */
/*  modified            Mod                                           */
/*  name                Nm                                            */
/*  owner               Own                                           */
/*  parameter           Prm                                           */
/*  password            Pwd                                           */
/*  position            Pos                                           */
/*  protocol            Pcl                                           */
/*  privilege           Prv                                           */
/*  schema              Sch                                           */
/*  sequence            Seq                                           */
/*  short               Sht                                           */
/*  string              Str                                           */
/*  table               Tbl                                           */
/*  type                Typ                                           */
/*  upper               Upr                                           */
/*  user                Usr                                           */
/*  views               Vw                                            */
/*                                                                    */
/**********************************************************************/

#if	defined(OS400) || defined (CLI_GLOBAL_DEFINE)
#	define COL_CHAR_MAX_LENGTH		"ChrMaxLen"
#	define COL_COLUMN_NAME			"ColNm"
#	define COL_DATABASE_ID			"DbsId"
#	define COL_DATABASE_NAME		"DbsNm"
#	define COL_DATABASE_TYPE		"DbsTyp"
#	define COL_DATE_ENTERED		"DtEnt"
#	define COL_DATE_MODIFIED		"DtMod"
#	define COL_DBMS_OWNER			"DbmOwn"
#	define COL_DBMS_TYPE_STRING	"DbmTypStr"
#	define COL_DBMS_VIEW_DEF		"DbmVwDef"
#	define COL_DICTIONARY_OWNER	"DctOwn"
#	define COL_EXT_COLUMN_NAME		"ExtColNm"
#	define COL_EXT_INDEX_NAME		"ExtIdxNm"
#	define COL_EXT_TABLE_NAME		"ExtTblNm"
#	define COL_EXT_VIEW_NAME		"ExtVwNm"
#	define COL_FIRST_SCHEMA		"FirstSch"
#	define COL_FEATURE				"Feature"
#	define COL_GRANTEE				"grantee"
#	define COL_GRANTOR				"grantor"
#	define COL_INDEX_NAME			"IdxNm"
#	define COL_INDEX_OWNER			"IdxOwn"
#	define COL_INDEX_TYPE			"IdxTyp"
#	define COL_INT_PAR1			"IntPar1"
#	define COL_INT_PAR2			"IntPar2"
#	define COL_LASTID				"lastId"
#	define COL_LONG_PARAMETER_1	"LngPrm1"
#	define COL_LONG_PARAMETER_2	"LngPrm2"
#	define COL_LONG_PARAMETER_3	"LngPrm3"
#	define COL_MAJOR				"Major"
#	define COL_NET_ADDRESS_1		"NetAdr1"
#	define COL_NET_ADDRESS_2		"NetAdr2"
#	define COL_NET_ADDRESS_3		"NetAdr3"
#	define COL_NET_ADDRESS_4		"NetAdr4"
#	define COL_NULLABLE			"Nullable"
#	define COL_POSITION			"Pos"
#	define COL_PREC				"Prec"
#	define COL_PROTOCOL_1			"Pcl1"
#	define COL_PROTOCOL_2			"Pcl2"
#	define COL_PROTOCOL_3			"Pcl3"
#	define COL_PROTOCOL_4			"Pcl4"
#	define COL_RIS_PRIVILEGES		"risPrv"
#	define COL_RIS_TYPE			"RisTyp"
#	define COL_RIS_TYPE_STRING		"RisTypStr"
#	define COL_RIS_VIEW_DEF		"RisVwDef"
#	define COL_RIS_OBJECT			"RisObj"
#	define COL_SCALE				"Scale"
#	define COL_SCHEMA_NAME			"SchNm"
#	define COL_SCHEMA_OWNER		"SchOwn"
#	define COL_SCHEMA_PASSWORD		"SchPwd"
#	define COL_SCHEMA_TYPE			"SchTyp"
#	define COL_SCHEMA_USER			"SchUsr"
#	define COL_SEQUENCE_ID			"SeqId"
#	define COL_SERVER_PID			"srvPid"
#	define COL_SHORT_PARAMETER_1	"ShtPrm1"
#	define COL_SHORT_PARAMETER_2	"ShtPrm2"
#	define COL_SHORT_PARAMETER_3	"ShtPrm3"
#	define COL_SHORT_PARAMETER_4	"ShtPrm4"
#	define COL_SHORT_PARAMETER_5	"ShtPrm5"
#	define COL_SHORT_PARAMETER_6	"ShtPrm6"
#	define COL_SHORT_PARAMETER_7	"ShtPrm7"
#	define COL_SHORT_PARAMETER_8	"ShtPrm8"
#	define COL_SRVID				"srvId"
#	define COL_STR_PAR1			"StrPar1"
#	define COL_STR_PAR2			"StrPar2"
#	define COL_TABLE_ID			"TabId"
#	define COL_TABLE_NAME			"TblNm"
#	define COL_TABLE_TYPE			"TblTyp"
#	define COL_UPPER_COLUMN_NAME	"UprColNm"
#	define COL_UPPER_INDEX_NAME	"UprIdxNm"
#	define COL_UPPER_TABLE_NAME	"UprTblNm"
#	define COL_UPPER_VIEW_NAME		"UprVwNm"
#	define COL_USER_NAME			"UsrNm"
#	define COL_USER_PRIVILEGE		"UsrPrv"
#	define COL_VIEW_NAME			"VwNm"
#	define IDX_RISXXX_COL			"risxCol"
#	define IDX_RISXXX_GRAN			"risxGran"
#	define IDX_RISXXX_IDXCOLA		"risxIColA"
#	define IDX_RISXXX_IDXCOLB		"risxIColB"
#	define IDX_RISXXX_PRIVA		"risxPrvA"
#	define IDX_RISXXX_PRIVB		"risxPrvB"
#	define IDX_RISXXX_PRIVC		"risxPrvC"
#	define IDX_RISXXX_PRIVD		"risxPrvD"
#	define IDX_RISXXX_PRIVE		"risxPrvE"
#	define IDX_RISXXX_SCHEMAID		"risxSchId"
#	define IDX_RISXXX_SCHUSR		"risxSchsr"
#	define IDX_RISXXX_T11			"risxT11"
#	define IDX_RISXXX_TABA			"risxTabA"
#	define IDX_RISXXX_TABB			"risxTabB"
#	define IDX_RISXXX_TABC			"risxTabC"
#	define IDX_RISXXX_USERS		"risxUsr"
#	define IDX_RISXXX_VIEW			"risxVw"
#	define VIEW_RIS5COLUMNS		"ris5Cols"
#	define VIEW_RIS5COLUMN_PRIVS	"ris5ColPrv"
#	define VIEW_RIS5INDEXES		"ris5Idx"
#	define VIEW_RIS5INDEX_COLUMNS	"ris5IdxCol"
#	define VIEW_RIS5SCHEMAS		"ris5Sch"
#	define VIEW_RIS5TABLES			"ris5Tbl"
#	define VIEW_RIS5TABLE_PRIVS	"ris5TblPrv"
#	define VIEW_RIS5VIEWS			"ris5Vw"
#	define VIEW_RIS5DBMS_INDEXES	"ris5DbmIdx"
#	define VIEW_RIS5DBMS_TABLES	"ris5DbmTbl"
#	define VIEW_RIS5DBMS_VIEWS		"ris5DbmVw"
#	define VIEW_RIS5DBMS_COLUMNS	"ris5DbmCol"
#	define VIEW_RIS5DBMS_USERS		"ris5DbmUsr"
#	define VIEW_RIS5USERS			"ris5Usr"
#	define VIEW_RIS5SCHPRIV		"ris5SchPrv"	
#	define VIEW_RIS5DBS			"ris5Dbs"
#else							/*   ----+----1----+---     <= 10 chars above */
#	define COL_CHAR_MAX_LENGTH		"char_max_length"
#	define COL_COLUMN_NAME			"column_name"
#	define COL_DATABASE_ID			"database_id"
#	define COL_DATABASE_NAME		"database_name"
#	define COL_DATABASE_TYPE		"database_type"
#	define COL_DATE_ENTERED		"date_entered"
#	define COL_DATE_MODIFIED		"date_modified"
#	define COL_DBMS_OWNER			"dbms_owner"
#	define COL_DBMS_TYPE_STRING	"dbms_type_string"
#	define COL_DBMS_VIEW_DEF		"dbms_view_def"
#	define COL_DICTIONARY_OWNER	"dictionary_owner"
#	define COL_EXT_COLUMN_NAME		"ext_column_name"
#	define COL_EXT_INDEX_NAME		"ext_index_name"
#	define COL_EXT_TABLE_NAME		"ext_table_name"
#	define COL_EXT_VIEW_NAME		"ext_view_name"
#	define COL_FIRST_SCHEMA		"first_schema"
#	define COL_FEATURE				"feature"
#	define COL_GRANTEE				"grantee"
#	define COL_GRANTOR				"grantor"
#	define COL_INDEX_NAME			"index_name"
#	define COL_INDEX_OWNER			"index_owner"
#	define COL_INDEX_TYPE			"index_type"
#	define COL_INT_PAR1			"int_par1"
#	define COL_INT_PAR2			"int_par2"
#	define COL_LASTID				"lastid"
#	define COL_LONG_PARAMETER_1	"long_parameter_1"
#	define COL_LONG_PARAMETER_2	"long_parameter_2"
#	define COL_LONG_PARAMETER_3	"long_parameter_3"
#	define COL_MAJOR				"major"
#	define COL_NET_ADDRESS_1		"net_address_1"
#	define COL_NET_ADDRESS_2		"net_address_2"
#	define COL_NET_ADDRESS_3		"net_address_3"
#	define COL_NET_ADDRESS_4		"net_address_4"
#	define COL_NULLABLE			"nullable"
#	define COL_POSITION			"position"
#	define COL_PREC				"prec"
#	define COL_PROTOCOL_1			"protocol_1"
#	define COL_PROTOCOL_2			"protocol_2"
#	define COL_PROTOCOL_3			"protocol_3"
#	define COL_PROTOCOL_4			"protocol_4"
#	define COL_RIS_PRIVILEGES		"ris_privileges"
#	define COL_RIS_TYPE			"ris_type"
#	define COL_RIS_TYPE_STRING		"ris_type_string"
#	define COL_RIS_VIEW_DEF		"ris_view_def"
#	define COL_RIS_OBJECT			"ris_object"
#	define COL_SCALE				"scale"
#	define COL_SCHEMA_NAME			"schema_name"
#	define COL_SCHEMA_OWNER		"schema_owner"
#	define COL_SCHEMA_PASSWORD		"schema_password"
#	define COL_SCHEMA_TYPE			"schema_type"
#	define COL_SCHEMA_USER			"schema_user"
#	define COL_SEQUENCE_ID			"sequence_id"
#	define COL_SERVER_PID			"server_pid"
#	define COL_SHORT_PARAMETER_1	"short_parameter_1"
#	define COL_SHORT_PARAMETER_2	"short_parameter_2"
#	define COL_SHORT_PARAMETER_3	"short_parameter_3"
#	define COL_SHORT_PARAMETER_4	"short_parameter_4"
#	define COL_SHORT_PARAMETER_5	"short_parameter_5"
#	define COL_SHORT_PARAMETER_6	"short_parameter_6"
#	define COL_SHORT_PARAMETER_7	"short_parameter_7"
#	define COL_SHORT_PARAMETER_8	"short_parameter_8"
#	define COL_SRVID				"srvid"
#	define COL_STR_PAR1			"str_par1"
#	define COL_STR_PAR2			"str_par2"
#	define COL_TABLE_ID			"table_id"
#	define COL_TABLE_NAME			"table_name"
#	define COL_TABLE_TYPE			"table_type"
#	define COL_UPPER_COLUMN_NAME	"upper_column_name"
#	define COL_UPPER_INDEX_NAME	"upper_index_name"
#	define COL_UPPER_TABLE_NAME	"upper_table_name"
#	define COL_UPPER_VIEW_NAME		"upper_view_name"
#	define COL_USER_NAME			"user_name"
#	define COL_USER_PRIVILEGE		"user_privilege"
#	define COL_VIEW_NAME			"view_name"
#	define IDX_RISXXX_COL			"risxxx_col"
#	define IDX_RISXXX_GRAN			"risxxx_gran"
#	define IDX_RISXXX_IDXCOLA		"risxxx_idxcola"
#	define IDX_RISXXX_IDXCOLB		"risxxx_idxcolb"
#	define IDX_RISXXX_PRIVA		"risxxx_priva"
#	define IDX_RISXXX_PRIVB		"risxxx_privb"
#	define IDX_RISXXX_PRIVC		"risxxx_privc"
#	define IDX_RISXXX_PRIVD		"risxxx_privd"
#	define IDX_RISXXX_PRIVE		"risxxx_prive"
#	define IDX_RISXXX_SCHEMAID		"risxxx_schemaid"
#	define IDX_RISXXX_SCHUSR		"risxxx_schusr"
#	define IDX_RISXXX_T11			"risxxx_t11"
#	define IDX_RISXXX_TABA			"risxxx_taba"
#	define IDX_RISXXX_TABB			"risxxx_tabb"
#	define IDX_RISXXX_TABC			"risxxx_tabc"
#	define IDX_RISXXX_USERS		"risxxx_users"
#	define IDX_RISXXX_VIEW			"risxxx_view"
#	define VIEW_RIS5COLUMNS		"ris5columns"
#	define VIEW_RIS5COLUMN_PRIVS	"ris5column_privs"
#	define VIEW_RIS5INDEXES		"ris5indexes"
#	define VIEW_RIS5INDEX_COLUMNS	"ris5index_columns"
#	define VIEW_RIS5SCHEMAS		"ris5schemas"
#	define VIEW_RIS5TABLES			"ris5tables"
#	define VIEW_RIS5TABLE_PRIVS	"ris5table_privs"
#	define VIEW_RIS5VIEWS			"ris5views"
#	define VIEW_RIS5DBMS_INDEXES	"ris5dbms_indexes"
#	define VIEW_RIS5DBMS_TABLES	"ris5dbms_tables"
#	define VIEW_RIS5DBMS_VIEWS		"ris5dbms_views"
#	define VIEW_RIS5DBMS_COLUMNS	"ris5dbms_columns"
#	define VIEW_RIS5DBMS_USERS		"ris5dbms_users"
#	define VIEW_RIS5USERS			"ris5users"
#	define VIEW_RIS5SCHPRIV		"ris5schpriv"	
#	define VIEW_RIS5DBS			"ris5dbs"
#endif


/********************************************************************
**
**  To create, drop, build indexes on, and load dictionary information 
**   (ristables, riscolumns, risindex_columns, risprivs, ...)
**   about RIS dictionary tables/views we need the following:
**
**      table/view name
**      column information
**      index information 
**
**  We store this information in one immense structure with three
**  different structure types.
**
**  The first is a dictionary table-definition structure (dict_tabdef).
**  This is the primary structure; RIScom_dict_tables is an array of
**  these, one for each table (and one terminator).  Everything concerned
**  with a table is in this or attached to it.
**
**  Column information is stored in an array of risattrs, stored within
**  a dict_tabdef.  The risattr is used because it contains all required
**  information and because it is a standard structure within the
**  client.  We do not have to worry about conversion
**  to other structures.
**
**  Index information is held in a dictionary index structure (dict_idxdef).
**  There is an array of these that is a part of each dict_tabdef.
**
**  Notes:
**
**    Each dict_tabdef has an array of risattrs and dict_idxdefs, and
**    most of the arrays are mostly empty.  This wastes a bit of space
**    but not without reason.  The purpose of having everything here in
**    the first place is to avoid inconsistencies.  We used to have 
**    multiple create table statements, multiple create index statements,
**    privileges loaded out of yet another array, etc.
**    It was very easy to have inconsistent dictionary data (column name X in
**    riscolumns and column name Y in risprivs) and very difficult and
**    time consuming to detect.
**
**    In order to avoid that, I couple everything together as tightly as
**    possible.  I could have had dict_tabdef defined to have pointers
**    to non-wasteful arrays of dict_idxdefs and risattrs (and in fact I
**    tried it that way), but it is truly easiest to maintain if
**    the table definition, index definition, and column definition 
**    information for a table is all together.
**
*/

/********************************************************************
**
** RIS_ATTR_INFO (column_information)
**
**	char   attrname[RIS_MAX_ID_SIZE];
**	uchar  atype;			            (1 character, 4 int, 5 smallint)
**                                      (atype | 0x10 means nulls allowed )
**  uchar  pad[1]
**	short   dbsqltype;	(set up based on atype)
**	uint	dbsqllen;	(same as asize.len)
**	union  asize
**	{
**		ushort			len;			(length)
**      (decimal part of union not used)
**	} asize;
**	short				pad2;
*/

/***************************************************************************
**
** DICT_IDXDEF (index information)
**
**  There are a few tables that have none because we expect them to
**   have so few records in them.
**
**	  iname (index name)
**    unique (1 if unique, 0 if duplicates allowed)
**    columns (# of columns in the index)
**    failure (RIS error to return if index creation fails)
**    cnames  (array of pointers to the column names)
**
**  The order in which the names appear in cnames determines the order
**   of the columns in the index.
**
**  The dictionary does not have indexes of more than four
**  columns, so we are set up to store only four column names.
**  Index creation code in DDSdict.c also assumes this.
*/


	typedef struct dict_idxdef {
		char	*iname;			/* index name, without the number-tag  */
		char	*ext_iname;		/* external index name				*/
		int		tag;			/* number to tag onto index name */
		short	unique;			/* true if unique; false if duplicates */
		short	columns;		/* how many columns in this index */
		int		failure;		/* error to report if creation fails */
		char	*cnames[RIS_MAX_INDEX_COLUMNS];
	} dict_idxdef;


/***************************************************************************
**
** DICT_TABDEF
**
**   NAME is the name of the table or view;
**   TABTYPE is T (table) or V (view);
**        Added by JP for version 5 onwards.
**   TABID  object id hardcoded for internal dictionary objects.
**   VERSION indicates whether the object is a V4 or V5 object.
**   LOAD  is Y or N. Starting V5 onwards we decided not to load the 
**     dictionary with information about the dictionary tables itself.
**	   We would only load information about dictionary views and for 
**     interoperability reasons we stiil need to load the dictionary
**     with information about version 4 tables and views.  So this flag 
**     indicates whether or not a dictionary object's information is to 
**     be loaded or not.
**   COMPRESSION is the number of initial characters 
**      that a tablename has in common with the next tablename 
**      in the array.
**   ID_BIT: each dictionary object has a bit that uniquely
**      identifies it, so we can mark that a table has been
**      created by setting a particular bit of a word; it does not
**      matter what the value is as long as it is a single bit
**      of a word and is different from the other table id_bits.
**      We have about 40 + objects now. 32 bits is not enough to represent all
**      So this is UNIQUE between all V5 objects and V4 objects.
**   FAILURE_ERROR is the error to return when 
**	    something goes wrong trying to create the object;
**   MISSING_ERROR is the error to return when we expect
**      the object to be there 
**   MODIFY_ERROR is the error to return when there is an error trying
**		to modify the object (as in alter table modify to btree)
**   COLUMN_COUNT is the number of columns in the table
**   ATTR is an array of ris_attr_info with
**      fixed column information for the dictionary columns.
**   INDEX_COUNT is the number of indexes created on the table
**   IDX is an array of index definition structures holding
**      information about the indexes 
**   VIEWTEXT points to the create view statement if the object is a view
*/

	typedef struct dict_tabdef {
		char			*name;
		char			*ext_name;		/* for renaming functionality */
		char			tabtype;
		int				tabid;
		char			version;
		char			load_object;
		int				compression;
		unsigned int	id_bit;
		unsigned int			failure_error;
		unsigned int			missing_error;
		unsigned int			modify_error;
		int				column_count;
		ris_attr_info	attr[DICTIONARY_MAX_COLUMNS];
		int				index_count;
		dict_idxdef		idx[DICTIONARY_MAX_INDEXES];
		char			*viewtext;
	} dict_tabdef;


/*******************************************************************
**
**  We need views that show the names of 
**		tables not known to ris			(risdbms_tables)
**		views not known to ris			(risdbms_views)
**		indexes not known to ris		(risdbms_indexes)
**  Beware:  make sure there are no tabs in these strings 
**  or the dbms may complain.
**  This can be an outer join or a subquery, depending on what
**  is supported and what is fast.  This is the only database-specific
**  element of the dictionary.
*/
# ifdef INFORMIX

#   define DBMS_TABLES \
"create view risdbms_tables(table_name) as \
select tabname from informix.systables where owner = user \
and tabtype = 'T' and tabname not in \
(select ext_table_name from ri05_t02 where table_type = 'T' and \
schema_name = '%s') and tabname not in ('ri05_t01','ri05_t02','ri05_t03',\
'ri05_t04','ri05_t05','ri05_t06','ri05_t07','ri05_t08','ri05_t09','ri05_t10',\
'ri05_t11','ri05_t12','ri05_t13')"

#   define DBMS_VIEWS \
"create view risdbms_views(view_name) as \
select tabname from informix.systables where owner = user \
and tabtype = 'V' and tabname not in \
(select ext_table_name from ri05_t02 where table_type = 'V')"

#   define DBMS_INDEXES \
"create view risdbms_indexes(table_name,index_name) as \
select t.tabname,i.idxname from informix.sysindexes i, informix.systables t \
where i.owner = user and i.tabid = t.tabid \
and i.idxname not in \
(select x.ext_index_name from ri05_t04 x, ri05_t02 y where  \
  x.table_id = y.table_id and y.schema_name = '%s') \
and t.tabname not in ('ri05_t01','ri05_t02','ri05_t03',\
'ri05_t04','ri05_t05','ri05_t06','ri05_t07','ri05_t08','ri05_t09','ri05_t10',\
'ri05_t11','ri05_t12','ri05_t13')"

# endif

#ifdef SYBASE
# define DBMS_TABLES \
" create view risdbms_tables(table_name) as \
 select name from sysobjects where type = 'U' \
 and uid = user_id() and name not in \
('RI05_T01','RI05_T02', 'RI05_T03','RI05_T04', \
'RI05_T05','RI05_T06','RI05_T07','RI05_T08', 'RI05_T09','RI05_T10', \
'RI05_T11','RI05_T12','RI05_T13') \
 and name not in (select ext_table_name from ri05_t02 where \
 table_type = 'T' and schema_name = '%s') "

#   define DBMS_VIEWS \
 " create view risdbms_views(view_name) as \
 select name from sysobjects where type = 'V' \
 and uid = user_id() and name not in \
(select ext_table_name from ri05_t02 where table_type = 'V')"

#   define DBMS_INDEXES \
 " create view risdbms_indexes(table_name,index_name) as \
 select b.name, a.name from sysindexes a,sysobjects b\
 where b.type = 'U' and b.uid = user_id() and a.indid not in(0,255) \
 and  b.id = a.id  and b.name not in \
('RI05_T01','RI05_T02', 'RI05_T03','RI05_T04', \
'RI05_T05','RI05_T06','RI05_T07','RI05_T08', 'RI05_T09','RI05_T10', \
'RI05_T11','RI05_T12','RI05_T13') and \
 a.name not in (select y.ext_index_name from ri05_t04 y, ri05_t02 z \
 where y.table_id = z.table_id and z.schema_name='%s') "
# endif

#ifdef MSSQL

# define DBMS_TABLES \
" create view risdbms_tables(table_name) as \
 select name from sysobjects where type = 'U' \
 and uid = user_id() and name not in \
('RI05_T01','RI05_T02', 'RI05_T03','RI05_T04', \
'RI05_T05','RI05_T06','RI05_T07','RI05_T08', 'RI05_T09','RI05_T10', \
'RI05_T11','RI05_T12','RI05_T13') \
 and name not in (select ext_table_name from ri05_t02 where \
 table_type = 'T' and schema_name = '%s') "

#   define DBMS_VIEWS \
 " create view risdbms_views(view_name) as \
 select name from sysobjects where type = 'V' \
 and uid = user_id() and name not in \
(select ext_table_name from ri05_t02 where table_type = 'V')"

#   define DBMS_INDEXES \
 " create view risdbms_indexes(table_name,index_name) as \
 select b.name, a.name from sysindexes a,sysobjects b\
 where b.type = 'U' and b.uid = user_id() and a.indid not in(0,255) \
 and  b.id = a.id  and b.name not in \
('RI05_T01','RI05_T02', 'RI05_T03','RI05_T04', \
'RI05_T05','RI05_T06','RI05_T07','RI05_T08', 'RI05_T09','RI05_T10', \
'RI05_T11','RI05_T12','RI05_T13') and \
 a.name not in (select y.ext_index_name from ri05_t04 y, ri05_t02 z \
 where y.table_id = z.table_id and z.schema_name='%s') "
# endif

# ifdef ORACLE
/*
**
**  For oracle, an outer join and a subquery are both possible;
**  the outer join holds a performance edge.
**
**	With V5, went with subquery to get the job done.  Perhaps
**	we can optimize these queries when we get time?
**
*/
# define DBMS_TABLES \
"create view risdbms_tables(table_name) as \
select table_name from user_tables x \
where x.table_name not in \
(select ext_table_name from ri05_t02 where table_type = 'T' \
and schema_name = '%s') \
and x.table_name not in ('RI05_T01','RI05_T02', 'RI05_T03','RI05_T04', \
'RI05_T05','RI05_T06','RI05_T07','RI05_T08', 'RI05_T09','RI05_T10', \
'RI05_T11','RI05_T12','RI05_T13')"

# define DBMS_VIEWS \
"create view risdbms_views(view_name) as \
select view_name from user_views x \
where x.view_name not in \
(select ext_table_name from ri05_t02 where table_type = 'V')"

# define DBMS_INDEXES \
"create view risdbms_indexes(table_name,index_name) as \
select x.table_name, x.index_name from user_indexes x \
where x.index_name not in \
(select upper(y.ext_index_name) from ri05_t04 y, ri05_t02 z \
where y.table_id=z.table_id and z.schema_name='%s') \
and x.table_name not in ('RI05_T01', 'RI05_T02', 'RI05_T03', 'RI05_T04', \
'RI05_T05', 'RI05_T06', 'RI05_T07', 'RI05_T08', 'RI05_T09', 'RI05_T10', \
'RI05_T11', 'RI05_T12', 'RI05_T13')"
# endif 

# ifdef RDB

#   define DBMS_TABLES  \
"create view risdbms_tables(table_name) as \
select ext_table_name from ri05_t02 where 1 = 2"

#   define DBMS_VIEWS  \
"create view risdbms_views(view_name) as \
select ext_table_name from ri05_t02 where 1 = 2"

#   define DBMS_INDEXES	 \
"create view risdbms_indexes(table_name,index_name) as \
select 'ext_table_name', 'ext_index_name' from ri05_t04 where 1 = 2"
# endif

# ifdef DB2
#   define DBMS_TABLES  \
"create view risdbms_tables(table_name) as \
select name from sysibm.systables \
where creator = user and type = 'T' and name not in \
(select ext_table_name from ri05_t02 where table_type = 'T' \
and schema_name = '%s') \
and name not in ('RI05_T01','RI05_T02', 'RI05_T03','RI05_T04', \
'RI05_T05','RI05_T06','RI05_T07','RI05_T08', 'RI05_T09','RI05_T10', \
'RI05_T11','RI05_T12','RI05_T13')"

#   define DBMS_VIEWS  \
"create view risdbms_views(view_name) as \
select name from sysibm.systables \
where creator = user and type = 'V' and name not in \
(select ext_table_name from ri05_t02 where table_type = 'V')"

#   define DBMS_INDEXES	\
"create view risdbms_indexes(table_name,index_name) as \
select tbname,name from sysibm.sysindexes \
where creator = user and name not in \
 (select y.ext_index_name from ri05_t04 y, ri05_t02 z \
where y.table_id=z.table_id and z.schema_name='%s') \
and name not in ('RI05_T01', 'RI05_T02', 'RI05_T03', 'RI05_T04', \
'RI05_T05', 'RI05_T06', 'RI05_T07', 'RI05_T08', 'RI05_T09', 'RI05_T10', \
'RI05_T11', 'RI05_T12', 'RI05_T13')"
# endif

# ifdef INGRES

#   define DBMS_TABLES  \
"create view risdbms_tables(table_name) as \
select table_name from iitables \
where table_owner = user and table_type = 'T' and table_name not in  \
(select ext_table_name from ri05_t02 where table_type = 'T' \
and schema_name = '%s') \
and table_name not in ('ri05_t01','ri05_t02', 'ri05_t03','ri05_t04', \
'ri05_t05','ri05_t06','ri05_t07','ri05_t08', 'ri05_t09','ri05_t10', \
'ri05_t11','ri05_t12','ri05_t13')"

#   define DBMS_VIEWS  \
"create view risdbms_views(view_name) as \
select table_name from iitables \
where table_owner = user and table_type = 'V' and table_name not in  \
(select ext_table_name from ri05_t02 where table_type = 'V')"

#   define DBMS_INDEXES	\
"create view risdbms_indexes(table_name, index_name) as \
select base_name, index_name from iiindexes \
where index_owner = user and index_name not in  \
(select y.ext_index_name from ri05_t04 y, ri05_t02 z \
where y.table_id=z.table_id and z.schema_name='%s') \
and base_name not in ('ri05_t01', 'ri05_t02', 'ri05_t03', 'ri05_t04', \
'ri05_t05', 'ri05_t06', 'ri05_t07', 'ri05_t08', 'ri05_t09', 'ri05_t10', \
'ri05_t11', 'ri05_t12', 'ri05_t13')"

# endif

#ifdef OS400
#	define DBMS_TABLES \
		"DBMS_TABLES not supported in OS/400"
#	define DBMS_VIEWS \
		"DBMS_VIEWS not supported in OS/400"
#	define DBMS_INDEXES \
		"DBMS_INDEXES not supported in OS/400"
#endif	/* OS400 */


#ifndef DBMS_TABLES
#	define DBMS_TABLES				"This is client side filler"
#	define DBMS_VIEWS				"This is client side filler"
#	define DBMS_INDEXES			"This is client side filler"
#	define V4_RIS_COLUMNS			"This is client side filler"
#	define V4_RIS_INDEX_COLUMNS	"This is client side filler"
#	define V4_RIS_INDEXES			"This is client side filler"
#	define V4_RIS_PRIVS			"This is client side filler"
#	define V4_RIS_SCHEMAID			"This is client side filler"
#	define V4_RIS_SCHUSR			"This is client side filler"
#	define V4_RIS_TABLES			"This is client side filler"
#	define V4_RIS_VIEWS			"This is client side filler"
#	define V4_RISSCHEMAS			"This is client side filler"
#	define V4_RISDBS				"This is client side filler"
#endif

/***************************    VERSION 5 views ************************/
/*  First, some system specific views. */
#ifdef INFORMIX

#define RIS5DBMS_TABLES	\
"create view ris5dbms_tables(table_name,dbms_owner) as \
select tabname,owner from informix.systables where \
tabtype = 'T' and tabname not in ('ri05_t01','ri05_t02','ri05_t03',\
'ri05_t04','ri05_t05','ri05_t06','ri05_t07','ri05_t08','ri05_t09','ri05_t10',\
'ri05_t11','ri05_t12','ri05_t13')"

#define RIS5DBMS_VIEWS	\
"create view ris5dbms_views(view_name,dbms_owner) as \
select tabname,owner from informix.systables where \
tabtype = 'V' and tabname not in \
(select ext_table_name from ri05_t02 where table_id < 1001 )"

#define RIS5DBMS_INDEXES \
"create view ris5dbms_indexes(table_name,dbms_owner,index_name) as \
select t.tabname, i.owner, i.idxname from informix.systables t, \
informix.sysindexes i where t.tabid = i.tabid and \
t.tabname not in ('ri05_t01','ri05_t02','ri05_t03',\
'ri05_t04','ri05_t05','ri05_t06','ri05_t07','ri05_t08','ri05_t09','ri05_t10',\
'ri05_t11','ri05_t12','ri05_t13')"

#define RIS5DBMS_COLUMNS \
"create view ris5dbms_columns(table_name,dbms_owner,column_name, position) as \
select a.tabname,a.owner, b.colname, b.colno from informix.systables a, \
informix.syscolumns b where a.tabid = b.tabid"

#define RIS5DBMS_USERS \
"create view ris5dbms_users(user_name,dbms_owner) as \
select username,username from informix.sysusers"

#endif

#if defined (SYBASE) || defined (MSSQL)
#define RIS5DBMS_TABLES	\
" create view ris5dbms_tables(table_name, dbms_owner) as \
  select sysobjects.name, master..syslogins.name \
  from sysobjects, master..syslogins, sysusers \
  where sysobjects.type = 'U' \
  and sysobjects.name not in ('ri05_t01', 'ri05_t02', 'ri05_t03', \
  'ri05_t04', 'ri05_t05', 'ri05_t06', 'ri05_t07', 'ri05_t08', 'ri05_t09', \
  'ri05_t10', 'ri05_t11', 'ri05_t12', 'ri05_t13') \
  and sysusers.suid = master..syslogins.suid \
  and sysusers.uid = sysobjects.uid" 

#define RIS5DBMS_VIEWS	\
" create view ris5dbms_views(view_name, dbms_owner) as \
  select sysobjects.name, master..syslogins.name \
  from sysobjects, master..syslogins, sysusers \
  where sysobjects.type = 'V' and sysobjects.name not in \
  (select ext_table_name from ri05_t02 where table_id < 1001) \
  and sysusers.suid = master..syslogins.suid \
  and sysusers.uid = sysobjects.uid \
  and sysobjects.name not in ('ris5dbms_users','ris5dbms_tables', \
  'ris5dbms_views','ris5dbms_indexes','ris5dbms_columns')" 

#define RIS5DBMS_INDEXES \
" create view ris5dbms_indexes(table_name, dbms_owner, index_name) as select sysobjects.name, master..syslogins.name, sysindexes.name from sysobjects, master..syslogins, sysusers, sysindexes where sysindexes.indid not in (0,255) and sysobjects.id = sysindexes.id and sysusers.suid = master..syslogins.suid and sysusers.uid = sysobjects.uid and sysobjects.type = 'U' and sysobjects.name not in ('ri05_t01', 'ri05_t02', 'ri05_t03', 'ri05_t04', 'ri05_t05', 'ri05_t06', 'ri05_t07', 'ri05_t08', 'ri05_t09', 'ri05_t10', 'ri05_t11', 'ri05_t12', 'ri05_t13')" 
#define RIS5DBMS_COLUMNS \
" create view ris5dbms_columns(table_name, dbms_owner, column_name, position) as select sysobjects.name, master..syslogins.name, syscolumns.name, syscolumns.colid from sysobjects, master..syslogins, syscolumns, sysusers where sysobjects.type = 'U' and sysobjects.name not in ('ri05_t01', 'ri05_t02', 'ri05_t03', 'ri05_t04', 'ri05_t05', 'ri05_t06', 'ri05_t07', 'ri05_t08', 'ri05_t09', 'ri05_t10', 'ri05_t11', 'ri05_t12', 'ri05_t13') and sysusers.suid = master..syslogins.suid and sysusers.uid = sysobjects.uid and syscolumns.id = sysobjects.id " 
/* user_name is the login and dbms_owner is the actual user name on the db */

#define RIS5DBMS_USERS \
" create view ris5dbms_users(user_name, dbms_owner) as select a.name, b.name from master..syslogins a, sysusers b where b.suid = a.suid" 

# endif

/******** mms - The definitions are the same as SYBASE : ris5dbms_tables was wrong 
#ifdef MSSQL
#define RIS5DBMS_TABLES \
" create view ris5dbms_tables(table_name,dbms_owner) as \
 select x.name,y.name from sysobjects x,sysusers y \
 where x.type = 'U' and x.uid = y.uid \
 and x.name not in ('ri05_t01','ri05_t02','ri05_t03', \
'ri05_t04','ri05_t05','ri05_t06','ri05_t07','ri05_t08','ri05_t09','ri05_t10', \
'ri05_t11','ri05_t12','ri05_t13')"

#define RIS5DBMS_VIEWS  \
 " create view ris5dbms_views(view_name,dbms_owner) as \
 select x.name,y.name from sysobjects x,sysusers y \
 where x.type = 'V' and x.uid = y.uid \
 and x.name not in (select ext_table_name from ri05_t02 \
 where table_id < 1001)"

#define RIS5DBMS_INDEXES \
 " create view ris5dbms_indexes(table_name, dbms_owner, index_name) as \
 select b.name, c.name, a.name from sysindexes a,sysobjects b,sysusers c\
 where b.uid = c.uid and b.type = 'U' and a.id = b.id \
 and b.name not in ('ri05_t01','ri05_t02','ri05_t03', \
'ri05_t04','ri05_t05','ri05_t06','ri05_t07','ri05_t08','ri05_t09','ri05_t10',\
'ri05_t11','ri05_t12','ri05_t13') and a.indid not in(0,255)"

#define RIS5DBMS_COLUMNS \
"create view ris5dbms_columns(table_name,dbms_owner,column_name, position) as \
select 1,2,3,4 from ri05_t12 where 1=2"

/ * user_name is the login and dbms_owner is the actual user name on the db * /
#define RIS5DBMS_USERS \
"create view ris5dbms_users(user_name,dbms_owner) as \
 select a.name,b.name from master..syslogins a, sysusers b \
 where b.suid = a.suid "

# endif
*********************************************************************************/

#ifdef ORACLE

#define RIS5DBMS_TABLES	\
"create view ris5dbms_tables(table_name,dbms_owner) as \
select table_name, owner from all_tables where \
table_name not in ('RI05_T01', 'RI05_T02', 'RI05_T03', 'RI05_T04', \
'RI05_T05', 'RI05_T06', 'RI05_T07', 'RI05_T08', 'RI05_T09', 'RI05_T10', \
'RI05_T11', 'RI05_T12', 'RI05_T13')"

#define RIS5DBMS_VIEWS	\
"create view ris5dbms_views(view_name, dbms_owner) as \
select view_name, owner from all_views \
where view_name not in (select ext_table_name from ri05_t02 \
where table_id < 1001)"

#define RIS5DBMS_INDEXES \
"create view ris5dbms_indexes(table_name, dbms_owner, index_name) as \
select table_name, table_owner, index_name from all_indexes \
where table_name not in ('RI05_T01', 'RI05_T02', 'RI05_T03', 'RI05_T04', \
'RI05_T05', 'RI05_T06', 'RI05_T07', 'RI05_T08', 'RI05_T09', 'RI05_T10', \
'RI05_T11', 'RI05_T12', 'RI05_T13')"

#define RIS5DBMS_COLUMNS \
"create view ris5dbms_columns(table_name,dbms_owner,column_name, position) as \
select table_name, owner, column_name, column_id from all_tab_columns"

#define RIS5DBMS_USERS \
"create view ris5dbms_users(user_name,dbms_owner) as \
select username,username from all_users"

#endif

#ifdef RDB

#define RIS5DBMS_TABLES	\
"create view ris5dbms_tables(table_name,dbms_owner) as \
select rdb$relation_name,'UNKNOWN' from rdb$relations where rdb$flags = 0 \
and rdb$relation_name not in ('RI05_T01', 'RI05_T02', 'RI05_T03', 'RI05_T04', \
'RI05_T05', 'RI05_T06', 'RI05_T07', 'RI05_T08', 'RI05_T09', 'RI05_T10', \
'RI05_T11', 'RI05_T12', 'RI05_T13')"

#define RIS5DBMS_VIEWS	\
"create view ris5dbms_views(view_name, dbms_owner) as \
select rdb$relation_name,'UNKNOWN' from rdb$relations where rdb$flags in \
(1,3,5,7,17,19,21,23) and rdb$relation_name not in ( select upper_table_name \
from ri05_t02 where table_id < 1001 ) and rdb$relation_name not in ( \
'RDBVMS$COLLATIONS','RDBVMS$INTERRELATIONS','RDBVMS$PRIVILEGES', \
'RDBVMS$RELATION_CONSTRAINTS','RDBVMS$RELATION_CONSTRAINT_FLDS', \
'RDBVMS$STORAGE_MAPS','RDBVMS$STORAGE_MAP_AREAS','RDBVMS$TRIGGERS')"

#define RIS5DBMS_INDEXES \
"create view ris5dbms_indexes(table_name, dbms_owner, index_name) as \
select i.rdb$relation_name,'UNKNOWN',i.rdb$index_name from rdb$indices i,\
rdb$relations t where i.rdb$relation_name = t.rdb$relation_name and \
t.rdb$flags = 0 and i.rdb$relation_name not in ('RI05_T01', 'RI05_T02', \
'RI05_T03', 'RI05_T04', 'RI05_T05', 'RI05_T06', 'RI05_T07', 'RI05_T08', \
'RI05_T09', 'RI05_T10', 'RI05_T11', 'RI05_T12', 'RI05_T13')"

#define RIS5DBMS_COLUMNS \
"create view ris5dbms_columns(table_name,dbms_owner,column_name, position) as \
select c.rdb$relation_name, 'UNKNOWN', c.rdb$field_name, c.rdb$field_position \
from rdb$relation_fields c, rdb$relations t where c.rdb$relation_name = \
t.rdb$relation_name and t.rdb$flags <> 10"

#define RIS5DBMS_USERS \
"create view ris5dbms_users(user_name,dbms_owner) as \
select 1,2 from ri05_t12 where 1=2"

#endif

#ifdef DB2

#define RIS5DBMS_TABLES	\
"create view ris5dbms_tables(table_name,dbms_owner) as \
 select name, creator from sysibm.systables where type = 'T' and \
 name not in ('RI05_T01', 'RI05_T02', 'RI05_T03', 'RI05_T04', \
 'RI05_T05', 'RI05_T06', 'RI05_T07', 'RI05_T08', 'RI05_T09', \
 'RI05_T10', 'RI05_T11', 'RI05_T12', 'RI05_T13')"

#define RIS5DBMS_VIEWS	\
"create view ris5dbms_views(view_name, dbms_owner) as \
select name, creator from sysibm.systables \
where type = 'V' \
and name not in (select ext_table_name from ri05_t02 \
where table_id < 1001)"

#define RIS5DBMS_INDEXES \
"create view ris5dbms_indexes(table_name, dbms_owner, index_name) as \
select tbname, creator, name from sysibm.sysindexes where \
tbname not in ('RI05_T01', 'RI05_T02', 'RI05_T03', 'RI05_T04', \
 'RI05_T05', 'RI05_T06', 'RI05_T07', 'RI05_T08', 'RI05_T09', \
 'RI05_T10', 'RI05_T11', 'RI05_T12', 'RI05_T13')"

#define RIS5DBMS_COLUMNS \
"create view ris5dbms_columns(table_name,dbms_owner,column_name, position) as \
select tbname , tbcreator, name, colno from sysibm.syscolumns"

#define RIS5DBMS_USERS \
"create view ris5dbms_users(user_name,dbms_owner) as \
select '1','2' from ri05_t12 where 1=2"

#endif

#ifdef INGRES

#define RIS5DBMS_TABLES	\
"create view ris5dbms_tables(table_name,dbms_owner) as \
select table_name, table_owner from iitables \
where table_type = 'T' and table_name not in \
('ri05_t01','ri05_t02', 'ri05_t03','ri05_t04', \
'ri05_t05','ri05_t06','ri05_t07','ri05_t08', 'ri05_t09','ri05_t10', \
'ri05_t11','ri05_t12','ri05_t13')"

#define RIS5DBMS_VIEWS	\
"create view ris5dbms_views(view_name, dbms_owner) as \
select table_name, table_owner from iitables \
where table_type = 'V' and table_name not in  \
(select ext_table_name from ri05_t02 where table_id < 1001)"

#define RIS5DBMS_INDEXES \
"create view ris5dbms_indexes(table_name, dbms_owner, index_name) as \
select base_name, index_owner, index_name from iiindexes \
where base_name not in ('ri05_t01','ri05_t02', 'ri05_t03','ri05_t04', \
'ri05_t05','ri05_t06','ri05_t07','ri05_t08', 'ri05_t09','ri05_t10', \
'ri05_t11','ri05_t12','ri05_t13')"

#define RIS5DBMS_COLUMNS \
"create view ris5dbms_columns(table_name,dbms_owner,column_name, position) as \
select table_name,table_owner,column_name,column_sequence from iicolumns"

#define RIS5DBMS_USERS \
"create view ris5dbms_users(user_name,dbms_owner) as \
select distinct table_owner, table_owner from iitables"

#endif


#ifdef OS400
#	define RIS5COLUMN_PRIVS											\
		"create "														\
			"view "														\
				"%s/" VIEW_RIS5COLUMN_PRIVS								\
				" ("													\
					COL_SCHEMA_NAME			","							\
					COL_TABLE_NAME			","							\
					COL_UPPER_TABLE_NAME	","							\
					COL_COLUMN_NAME			","							\
					COL_UPPER_COLUMN_NAME	","							\
					COL_GRANTOR				","							\
					COL_GRANTEE				","							\
					COL_RIS_PRIVILEGES		","							\
					COL_RIS_OBJECT										\
				") "													\
				"as "													\
					"select "											\
						"y."	COL_SCHEMA_NAME			","				\
						"y."	COL_TABLE_NAME			","				\
						"y."	COL_UPPER_TABLE_NAME	","				\
						"x."	COL_COLUMN_NAME			","				\
						"x."	COL_UPPER_COLUMN_NAME	","				\
						"x."	COL_GRANTOR				","				\
						"x."	COL_GRANTEE				","				\
						"x."	COL_RIS_PRIVILEGES		","				\
						"y."	COL_RIS_OBJECT			" "				\
					"from "												\
						"%s/ri05_t05 x,"								\
						"%s/ri05_t02 y "								\
					"where "											\
						"x." COL_COLUMN_NAME " is not null "			\
							"and "										\
						"x." COL_TABLE_ID " =  y." COL_TABLE_ID

#	define RIS5COLUMNS													\
		"create "														\
			"view "														\
				"%s/" VIEW_RIS5COLUMNS 									\
				" ("													\
					COL_SCHEMA_NAME			","							\
					COL_TABLE_NAME			","							\
					COL_UPPER_TABLE_NAME	","							\
					COL_COLUMN_NAME			","							\
					COL_EXT_COLUMN_NAME		","							\
					COL_UPPER_COLUMN_NAME	","							\
					COL_POSITION			","							\
					COL_RIS_TYPE			","							\
					COL_RIS_TYPE_STRING		","							\
					COL_DBMS_TYPE_STRING	","							\
					COL_CHAR_MAX_LENGTH		","							\
					COL_PREC				","							\
					COL_SCALE				","							\
					COL_NULLABLE			","							\
					COL_RIS_OBJECT										\
				") "													\
				"as "													\
					"select "											\
						"y."	COL_SCHEMA_NAME			","				\
						"y."	COL_TABLE_NAME			","				\
						"y."	COL_UPPER_TABLE_NAME	","				\
						"x."	COL_COLUMN_NAME			","				\
						"x."	COL_EXT_COLUMN_NAME		","				\
						"x."	COL_UPPER_COLUMN_NAME	","				\
						"x."	COL_POSITION			","				\
						"x."	COL_RIS_TYPE			","				\
						"x."	COL_RIS_TYPE_STRING		","				\
						"x."	COL_DBMS_TYPE_STRING	","				\
						"x."	COL_CHAR_MAX_LENGTH		","				\
						"x."	COL_PREC				","				\
						"x."	COL_SCALE				","				\
						"x."	COL_NULLABLE			","				\
						"y."	COL_RIS_OBJECT			" "				\
					"from "												\
						"%s/ri05_t03 x,"								\
						"%s/ri05_t02 y "								\
					"where "											\
						"x." COL_TABLE_ID " = y." COL_TABLE_ID	

#	define RIS5INDEX_COLUMNS											\
		"create "														\
			"view "														\
				"%s/" VIEW_RIS5INDEX_COLUMNS							\
				" ("													\
					COL_SCHEMA_NAME			","							\
					COL_INDEX_NAME			","							\
					COL_UPPER_INDEX_NAME	","							\
					COL_TABLE_NAME			","							\
					COL_UPPER_TABLE_NAME	","							\
					COL_COLUMN_NAME			","							\
					COL_UPPER_COLUMN_NAME	","							\
					COL_POSITION										\
				") "													\
				"as "													\
					"select "											\
						"y."	COL_SCHEMA_NAME			","				\
						"x."	COL_INDEX_NAME			","				\
						"x."	COL_UPPER_INDEX_NAME	","				\
						"y."	COL_TABLE_NAME			","				\
						"y."	COL_UPPER_TABLE_NAME	","				\
						"x."	COL_COLUMN_NAME			","				\
						"x."	COL_UPPER_COLUMN_NAME	","				\
						"x."	COL_POSITION			" "				\
					"from "												\
						"%s/ri05_t04 x, "								\
						"%s/ri05_t02 y "								\
					"where "											\
						"x." COL_TABLE_ID " = y." COL_TABLE_ID

#	define RIS5INDEXES													\
		"create "														\
			"view "														\
				"%s/" VIEW_RIS5INDEXES									\
				" ("													\
					COL_SCHEMA_NAME			","							\
					COL_INDEX_NAME			","							\
					COL_DBMS_OWNER			","							\
					COL_EXT_INDEX_NAME		","							\
					COL_UPPER_INDEX_NAME	","							\
					COL_TABLE_NAME			","							\
					COL_UPPER_TABLE_NAME	","							\
					COL_INDEX_TYPE										\
				") "													\
				"as "													\
					"select "											\
						"y."	COL_SCHEMA_NAME			","				\
						"x."	COL_INDEX_NAME			","				\
						"y."	COL_DBMS_OWNER			","				\
						"x."	COL_EXT_INDEX_NAME		","				\
						"x."	COL_UPPER_INDEX_NAME	","				\
						"y."	COL_TABLE_NAME			","				\
						"y."	COL_UPPER_TABLE_NAME	","				\
						"x."	COL_INDEX_TYPE			" "				\
					"from "												\
						"%s/ri05_t04 x,"								\
						"%s/ri05_t02 y "								\
					"where "											\
						"x." COL_TABLE_ID " = " "y." COL_TABLE_ID " "	\
							"and "										\
						"x." COL_POSITION " = 1 "

#	define RIS5SCHEMAS													\
		"create "														\
			"view "														\
				"%s/" VIEW_RIS5SCHEMAS									\
				" ("													\
					COL_SCHEMA_NAME			","							\
					COL_SCHEMA_OWNER		","							\
					COL_DATABASE_ID			","							\
					COL_SCHEMA_TYPE			","							\
					COL_DICTIONARY_OWNER	","							\
					COL_SRVID											\
				") "													\
				"as "													\
					"select "											\
						COL_SCHEMA_NAME					","				\
						COL_SCHEMA_OWNER				","				\
						COL_DATABASE_ID					","				\
						COL_SCHEMA_TYPE					","				\
						COL_DICTIONARY_OWNER			","				\
						COL_SRVID 						" "				\
					"from "												\
						"%s/ri05_t09"

#	define RIS5TABLE_PRIVS												\
		"create "														\
			"view "														\
				"%s/" VIEW_RIS5TABLE_PRIVS								\
				" ("													\
					COL_SCHEMA_NAME			","							\
					COL_TABLE_NAME			","							\
					COL_UPPER_TABLE_NAME	","							\
					COL_GRANTOR				","							\
					COL_GRANTEE				","							\
					COL_RIS_PRIVILEGES		","							\
					COL_RIS_OBJECT										\
				") "													\
				"as "													\
					"select "											\
						"y."	COL_SCHEMA_NAME			","				\
						"y."	COL_TABLE_NAME			","				\
						"y."	COL_UPPER_TABLE_NAME	","				\
						"x."	COL_GRANTOR				","				\
						"x."	COL_GRANTEE				","				\
						"x."	COL_RIS_PRIVILEGES		","				\
						"y."	COL_RIS_OBJECT			" "				\
					"from "												\
						"%s/ri05_t05 x,"								\
						"%s/ri05_t02 y "								\
					"where "											\
						"x." COL_COLUMN_NAME " is null "				\
							"and "										\
						"x." COL_TABLE_ID " = y." COL_TABLE_ID

#	define RIS5TABLES													\
		"create "														\
			"view "														\
				"%s/" VIEW_RIS5TABLES									\
				" ("													\
					COL_SCHEMA_NAME			","							\
					COL_TABLE_NAME			","							\
					COL_DBMS_OWNER			","							\
					COL_EXT_TABLE_NAME		","							\
					COL_UPPER_TABLE_NAME	","							\
					COL_TABLE_TYPE			","							\
					COL_DATE_ENTERED		","							\
					COL_DATE_MODIFIED		","							\
					COL_RIS_OBJECT										\
				") "													\
				"as "													\
					"select "											\
						COL_SCHEMA_NAME					","				\
						COL_TABLE_NAME					","				\
						COL_DBMS_OWNER					","				\
						COL_EXT_TABLE_NAME				","				\
						COL_UPPER_TABLE_NAME			","				\
						COL_TABLE_TYPE					","				\
						COL_DATE_ENTERED				","				\
						COL_DATE_MODIFIED 				","				\
						COL_RIS_OBJECT					" "				\
					"from "												\
						"%s/ri05_t02 "	

#	define RIS5VIEWS													\
		"create "														\
			"view "														\
				"%s/" VIEW_RIS5VIEWS									\
				" ("													\
					COL_SCHEMA_NAME			","							\
					COL_VIEW_NAME			","							\
					COL_DBMS_OWNER			","							\
					COL_EXT_VIEW_NAME		","							\
					COL_UPPER_VIEW_NAME		","							\
					COL_RIS_VIEW_DEF		","							\
					COL_DBMS_VIEW_DEF		","							\
					COL_SEQUENCE_ID										\
				") "													\
				"as "													\
					"select "											\
						"y."	COL_SCHEMA_NAME			","				\
						"y."	COL_TABLE_NAME			","				\
						"y."	COL_DBMS_OWNER			","				\
						"y."	COL_EXT_TABLE_NAME		","				\
						"y."	COL_UPPER_TABLE_NAME	","				\
						"x."	COL_RIS_VIEW_DEF		","				\
						"x."	COL_DBMS_VIEW_DEF		","				\
						"x."	COL_SEQUENCE_ID			" "				\
					"from "												\
						"%s/ri05_t08 x,"								\
						"%s/ri05_t02 y "								\
					"where "											\
						"x." COL_TABLE_ID " = y." COL_TABLE_ID 

/*  
	No macros here since we're gonna have to remove 'em later. VAX 
	chokes on 'em!
*/
#define RIS5DBS \
"create view %s/ris5Dbs(DbsId,DbsTyp,DbsNm,Pcl1, \
NetAdr1,Pcl2,NetAdr2,Pcl3,NetAdr3,Pcl4, \
NetAdr4,LngPrm1,LngPrm2,LngPrm3, \
ShtPrm1,ShtPrm2,ShtPrm3,ShtPrm4, \
ShtPrm5,ShtPrm6,ShtPrm7,ShtPrm8, \
srvId) as select DbsId,DbsTyp,DbsNm,Pcl1, \
NetAdr1,Pcl2,NetAdr2,Pcl3,NetAdr3,Pcl4, \
NetAdr4,LngPrm1,LngPrm2,LngPrm3, \
ShtPrm1,ShtPrm2,ShtPrm3,ShtPrm4, \
ShtPrm5,ShtPrm6,ShtPrm7,ShtPrm8, \
srvId from %s/ri05_t13"

#define RIS5USERS \
"create view %s/ris5Usr(SchNm, UsrNm, UsrPrv) as \
select SchNm, UsrNm, UsrPrv from %s/ri05_t10"

#define RIS5SCHPRIV \
"create view %s/ris5SchPrv(UsrNm, UsrPrv) as \
select UsrNm, UsrPrv from %s/ri05_t11"

/* Not implemented for OS400 */
#define RIS5DBMS_INDEXES \
"create view %s/ris5DbmIdx(TblNm, DbmOwn, IdxNm) as \
select 1,2,3 from %s/ri05_t12 where 1=2"

#define RIS5DBMS_TABLES	\
"create view %s/ris5DbmTbl(TblNm,DbmOwn) as \
select 1,2 from %s/ri05_t12 where 1=2"

#define RIS5DBMS_VIEWS	\
"create view %s/ris5DbmVw(VwNm, DbmOwn) as \
select 1,2 from %s/ri05_t12 where 1=2"

#define RIS5DBMS_COLUMNS \
"create view %s/ris5DbmCol(TblNm,DbmOwn,ColNm,Pos) as \
select 1,2,3,4 from %s/ri05_t12 where 1=2"

#define RIS5DBMS_USERS \
"create view %s/ris5DbmUsr(UsrNm,DbmOwn) as \
select 1,2 from %s/ri05_t12 where 1=2"

#elif defined(INFORMIX)	|| defined(INGRES)	|| defined(ORACLE) ||	defined(DB2)		|| defined(SYBASE)	|| defined(MSSQL) || defined(RDB)			
#	define RIS5COLUMN_PRIVS		\
		"create view ris5column_privs  ( schema_name, \
table_name, upper_table_name, column_name, upper_column_name, \
grantor, grantee, ris_privileges, ris_object ) as select \
y.schema_name, y.table_name,y.upper_table_name, x.column_name, \
x.upper_column_name, x.grantor, x.grantee, x.ris_privileges, \
y.ris_object from ri05_t05 x, ri05_t02 y where x.column_name is not \
null and x.table_id = y.table_id"


#	define RIS5COLUMNS		\
		"create view ris5columns ( schema_name, \
table_name, upper_table_name, column_name, ext_column_name, \
upper_column_name, position, ris_type, ris_type_string, \
dbms_type_string, char_max_length, prec, scale, nullable, \
ris_object ) as select y.schema_name, y.table_name, \
y.upper_table_name, x.column_name, x.ext_column_name, \
x.upper_column_name, x.position, x.ris_type, \
x.ris_type_string, x.dbms_type_string, x.char_max_length, \
x.prec, x.scale, x.nullable, y.ris_object from ri05_t03 x, \
ri05_t02 y where x.table_id = y.table_id and (y.table_id > 1000 or y.table_id < 30)" 

#	define RIS5INDEX_COLUMNS	\
		"create view ris5index_columns ( schema_name, \
index_name, upper_index_name, table_name, upper_table_name, \
column_name, upper_column_name, position ) as select \
y.schema_name, x.index_name, x.upper_index_name, \
y.table_name, y.upper_table_name, x.column_name, \
x.upper_column_name, x.position from ri05_t04 x, ri05_t02 y where \
x.table_id = y.table_id "

#	define RIS5INDEXES		\
		"create view ris5indexes ( schema_name, \
index_name, dbms_owner, ext_index_name, upper_index_name, \
table_name, upper_table_name, index_type ) as select \
y.schema_name, x.index_name, y.dbms_owner, x.ext_index_name, \
x.upper_index_name, y.table_name, y.upper_table_name, \
x.index_type from ri05_t04 x, ri05_t02 y where \
x.table_id = y.table_id and x.position = 1"

#	define RIS5SCHEMAS	\
		"create view ris5schemas ( schema_name, \
schema_owner, database_id, schema_type, dictionary_owner, \
srvid ) as select schema_name, schema_owner, database_id, \
schema_type, dictionary_owner, srvid from ri05_t09"

#	define RIS5TABLE_PRIVS		\
		"create view ris5table_privs ( schema_name, \
table_name, upper_table_name, grantor, grantee, \
ris_privileges, ris_object ) as select y.schema_name, \
y.table_name, y.upper_table_name, x.grantor, x.grantee, \
x.ris_privileges, y.ris_object from ri05_t05 x, ri05_t02 y where \
x.column_name is null and x.table_id = \
y.table_id and (y.table_id > 1000 or y.table_id < 30)"

#	define RIS5TABLES		\
		"create view ris5tables ( schema_name, \
table_name, dbms_owner, ext_table_name, upper_table_name, \
table_type, date_entered, date_modified, ris_object ) as \
select schema_name, table_name, dbms_owner, ext_table_name, \
upper_table_name, table_type, date_entered, date_modified, \
ris_object from ri05_t02 where (ri05_t02.table_id < 30 or ri05_t02.table_id > 1000) "

#	define RIS5VIEWS		\
		"create view ris5views ( schema_name, view_name, \
dbms_owner, ext_view_name, upper_view_name, ris_view_def, \
dbms_view_def, sequence_id ) as select y.schema_name, y.table_name, \
y.dbms_owner, y.ext_table_name, y.upper_table_name,x.ris_view_def, \
x.dbms_view_def, x.sequence_id from ri05_t08 x, ri05_t02 y where \
x.table_id = y.table_id"

/*  
	No macros here since we're gonna have to remove 'em later. VAX 
	chokes 'em!
*/
#define RIS5DBS \
"create view ris5dbs(database_id,database_type,database_name,protocol_1, \
net_address_1,protocol_2,net_address_2,protocol_3,net_address_3,protocol_4, \
net_address_4,long_parameter_1,long_parameter_2,long_parameter_3, \
short_parameter_1,short_parameter_2,short_parameter_3,short_parameter_4, \
short_parameter_5,short_parameter_6,short_parameter_7,short_parameter_8, \
srvid) as select database_id,database_type,database_name,protocol_1, \
net_address_1,protocol_2,net_address_2,protocol_3,net_address_3,protocol_4, \
net_address_4,long_parameter_1,long_parameter_2,long_parameter_3, \
short_parameter_1,short_parameter_2,short_parameter_3,short_parameter_4, \
short_parameter_5,short_parameter_6,short_parameter_7,short_parameter_8, \
srvid from ri05_t13"

#define RIS5USERS \
"create view ris5users(schema_name, user_name, user_privilege) as \
select schema_name, user_name, user_privilege from ri05_t10"

#define RIS5SCHPRIV \
"create view ris5schpriv(user_name, user_privilege) as \
select user_name, user_privilege from ri05_t11"

#else	/* all other RDBMSs */
#	define RIS5COLUMN_PRIVS			"This is client side filler"
#	define RIS5COLUMNS				"This is client side filler"
#	define RIS5INDEX_COLUMNS		"This is client side filler"
#	define RIS5INDEXES				"This is client side filler"
#	define RIS5SCHEMAS				"This is client side filler"
#	define RIS5TABLE_PRIVS			"This is client side filler"
#	define RIS5TABLES				"This is client side filler"
#	define RIS5VIEWS				"This is client side filler"
#	define RIS5DBMS_INDEXES			"This is client side filler"
#	define RIS5DBMS_TABLES			"This is client side filler"
#	define RIS5DBMS_VIEWS			"This is client side filler"
#	define RIS5DBMS_COLUMNS			"This is client side filler"
#	define RIS5DBMS_USERS			"This is client side filler"
#	define RIS5USERS	 			"This is client side filler"
#	define RIS5SCHPRIV				"This is client side filler"
#	define RIS5DBS 					"This is client side filler"
#endif /* all other RDBMSs */


/***************************    VERSION 4  ************************/
		/* The following are version 4 tables, which are now provided as
		** views, for interoperability reasons.
		*/


#if defined(INFORMIX)	|| defined(INGRES)	|| defined(ORACLE) || defined(DB2)		|| defined(SYBASE)	|| defined(MSSQL) || defined(RDB)			
#	define V4_RIS_COLUMNS \
"create view ris_columns (table_name, upper_table_name,\
column_name, upper_column_name,position,ris_type,\
ris_type_string,dbms_type_string, char_max_length,prec,scale,nullable) \
as select y.table_name,y.upper_table_name,x.column_name,\
x.upper_column_name,\
x.position,x.ris_type, x.ris_type_string,x.dbms_type_string,\
x.char_max_length,x.prec,x.scale, x.nullable from ri05_t03 x,ri05_t02 y \
where x.table_id = y.table_id and \
y.schema_name ='%s' and y.dbms_owner='%s'" 

#	define V4_RIS_INDEX_COLUMNS \
"create view ris_index_columns(index_name,upper_index_name,\
table_name, upper_table_name,column_name,upper_column_name,\
position) as select x.index_name, x.upper_index_name,\
y.table_name,y.upper_table_name,x.column_name,\
x.upper_column_name,x.position from ri05_t04 \
x,ri05_t02 y where x.table_id = y.table_id and \
y.schema_name='%s' and y.dbms_owner='%s'" 

#	define V4_RIS_INDEXES \
"create view ris_indexes(index_name,upper_index_name,\
table_name, upper_table_name,index_type) as select \
x.index_name,x.upper_index_name, \
y.table_name,y.upper_table_name,x.index_type from \
ri05_t04 x,ri05_t02 y \
where x.table_id = y.table_id and \
y.schema_name='%s' and y.dbms_owner='%s' and x.position=1" 

#	define V4_RIS_PRIVS \
"create view ris_privs(table_name,upper_table_name,\
column_name, upper_column_name,ris_privileges,\
grantor,grantee) as select y.table_name,\
y.upper_table_name,x.column_name,\
x.upper_column_name,\
x.ris_privileges, x.grantor,x.grantee from ri05_t05 x,ri05_t02 y \
where x.table_id = y.table_id and \
y.schema_name='%s' and y.dbms_owner='%s'" 

#	define V4_RIS_SCHEMAID \
"create view ris_schemaid(schema_name,schema_password) as  \
select schema_name,schema_password from ri05_t01  \
where schema_name='%s'"

#	define V4_RIS_SCHUSR \
"create view ris_schusr(pid) as select server_pid from ri05_t07 \
where schema_name = '%s'"

#	define V4_RIS_TABLES \
"create view ris_tables(table_name, upper_table_name,\
table_type) as  select table_name, upper_table_name,\
table_type from ri05_t02  \
where schema_name ='%s' and dbms_owner='%s'"

#	define V4_RIS_VIEWS \
"create view ris_views(view_name,upper_view_name,ris_view_def,\
dbms_view_def,sequence_id) as select y.table_name,\
y.upper_table_name, x.ris_view_def,x.dbms_view_def,x.sequence_id \
from ri05_t08 x,ri05_t02 y  \
where x.table_id = y.table_id and \
y.schema_name='%s' and y.dbms_owner='%s'" 

#	define V4_RISSCHEMAS \
"create view risschemas(schema_name,schema_owner,database_id,srvid) as \
select schema_name,schema_owner,database_id,srvid from ri05_t09 \
where schema_type = 0" 

#   define V4_RISDBS \
"create view risdbs(database_id,database_type,database_name,protocol_1, \
net_address_1,protocol_2,net_address_2,protocol_3,net_address_3,protocol_4, \
net_address_4,long_parameter_1,long_parameter_2,long_parameter_3, \
short_parameter_1,short_parameter_2,short_parameter_3,short_parameter_4, \
short_parameter_5,short_parameter_6,short_parameter_7,short_parameter_8, \
srvid) as select database_id,database_type,database_name,protocol_1, \
net_address_1,protocol_2,net_address_2,protocol_3,net_address_3,protocol_4, \
net_address_4,long_parameter_1,long_parameter_2,long_parameter_3, \
short_parameter_1,short_parameter_2,short_parameter_3,short_parameter_4, \
short_parameter_5,short_parameter_6,short_parameter_7,short_parameter_8, \
srvid from ri05_t13"
#endif 

#ifdef OS400
#define V4_RIS_COLUMNS         	(char *)0 
#define V4_RIS_INDEX_COLUMNS    (char *)0
#define V4_RIS_INDEXES     		(char *)0 
#define V4_RIS_PRIVS        	(char *)0 
#define V4_RIS_SCHEMAID        	(char *)0 
#define V4_RIS_SCHUSR          	(char *)0 
#define V4_RIS_TABLES          	(char *)0 
#define V4_RIS_VIEWS           	(char *)0 
#define V4_RISSCHEMAS          	(char *)0 
#define V4_RISDBS 				(char *)0 
#endif /* OS400 */

/**************************   END Verision 4 ***********************/
/*
** WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING
**
**     This structure is used for searching.  
**     The table names must be in ASCII order!!!!!!!
**
**     The order of the columns is their order in the table!!!!!
**
**     Any change here really changes the dictionary!!!!!!
**
** WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING
**
**  The create view statements cannot have tabs in them or Informix chokes.
**
** WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING
*/
	/*
	** DEC C compiler can't handle initialization of unions, so the
	** size field of ris_attr_info structures is too much for it;
	** The actual field sizes are set up by a function call.
	*/
#if defined(vms) || defined(__vms__)
#	define DBMS_COLSIZE(x) { 0 }
#	define COLSIZE(x) 
#else	/* reasonable compilers */
#	define DBMS_COLSIZE(x) { x }
#	define COLSIZE(x) { x }
#endif

 
 /*********************************************************************/
 /* RIS Version 5 tables.                                             */
 /*********************************************************************/

RISDICT_EXTERN  dict_tabdef RIScom_dict_tables[] 
#   ifdef RISDICT_GLOBAL_DEFINE
= {
{
	"ri05_t01",										/* name				*/
	"ri05_t01",										/* extname			*/
	'T',											/* tabtype			*/
	1,												/* tabid			*/
	5,												/* version			*/
	'N',											/* load_object		*/
	7,												/* compression		*/
	0x1,											/* id_bit			*/
	RIS_E_INV_CREATE_T01,							/* failure_error	*/
	0,												/* missing_error	*/
	RIS_E_INV_MODIFY_T01,							/* modify_error		*/
	4,												/* column_count		*/
	{
		{											/* attr[0]			*/
			"schema_name",							/* attrname			*/
			COL_SCHEMA_NAME,						/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		},
		{											/* attr[1]			*/
			"schema_password",						/* attrname			*/
			COL_SCHEMA_PASSWORD,					/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_PASSWD_SIZE-1),	/* dbsqllen			*/
			COLSIZE(RIS_MAX_PASSWD_SIZE-1)			/* asize.len		*/
		},
		{											/* attr[2]			*/
			"schema_owner",							/* attrname			*/
			COL_SCHEMA_OWNER,						/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		},
		{											/* attr[3]			*/
			"schema_type",							/* attrname			*/
			COL_SCHEMA_TYPE,						/* extern_attrname	*/
			RIS_INTEGER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(sizeof(int)),				/* dbsqllen			*/
			COLSIZE(sizeof(int))					/* asize.len		*/
		}
	},
	1,												/* index_count		*/
	{
		{											/* idx[0]			*/
			"idx_risxxx_schemaid",					/* iname			*/
			IDX_RISXXX_SCHEMAID,					/* ext_iname		*/
			0,										/* tag				*/
			UNIQUE,									/* unique			*/
			1,										/* columns			*/
			(int)RIS_E_INV_SCHEMAID_INDEX,				/* failure			*/
			{
				COL_SCHEMA_NAME						/* cnames[0]		*/
			}
		}
	},
	(char *)0										/* viewtext			*/
},

{
	"ri05_t02",
	"ri05_t02",
	'T',
	2,
	5,
	'N',
	7,
	0x2,
	RIS_E_INV_CREATE_T02,
	RIS_E_MISSING_T02,
	RIS_E_INV_MODIFY_T02,
	10,
	{
		{
			"schema_name",
			COL_SCHEMA_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"table_id",
			COL_TABLE_ID,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"dbms_owner",
			COL_DBMS_OWNER,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"table_name",
			COL_TABLE_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"ext_table_name",
			COL_EXT_TABLE_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_table_name",
			COL_UPPER_TABLE_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"table_type",
			COL_TABLE_TYPE,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		},
		{
			"ris_object",
			COL_RIS_OBJECT,
			RIS_CHARACTER NOT_NULL,
            {0},
            {0},
            DBMS_COLSIZE(1),
            COLSIZE(1)
		},
		{
			"date_entered",
			COL_DATE_ENTERED,
			RIS_TIMESTAMP NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(dtime)),
			COLSIZE(sizeof(dtime))
		},
		{
			"date_modified",
			COL_DATE_MODIFIED,
			RIS_TIMESTAMP NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(dtime)),
			COLSIZE(sizeof(dtime))
		},
	},
	3,
	{
		{
			"idx_risxxx_taba",
			IDX_RISXXX_TABA,
			0,
			UNIQUE,
			2,
			(int)RIS_E_INV_TABLES_INDEX,
			{
				COL_SCHEMA_NAME,
				COL_TABLE_NAME
			}							/* Should order be reversed? */
		},
		{
			"idx_risxxx_tabb",
			IDX_RISXXX_TABB,
			0,
			UNIQUE,
			2,
			(int)RIS_E_INV_TABLES_INDEX,
			{
				COL_TABLE_ID,
				COL_SCHEMA_NAME
			}
		},
		{
			"idx_risxxx_tabc",
			IDX_RISXXX_TABC,
			0,
			UNIQUE,
			3,
			(int)RIS_E_INV_TABLES_INDEX,
			{
				COL_EXT_TABLE_NAME,
				COL_DBMS_OWNER,
				COL_SCHEMA_NAME
			}
		}
	},
	(char *)0
},

{
	"ri05_t03",
	"ri05_t03",
	'T',
	3,
	5,
	'N',
	7,
	0x4,
	RIS_E_INV_CREATE_T03,
	RIS_E_MISSING_T03,
	RIS_E_INV_MODIFY_T03,
	12,
	{
		{
			"table_id",
			COL_TABLE_ID,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"column_name",
			COL_COLUMN_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"ext_column_name",
			COL_EXT_COLUMN_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_column_name",
			COL_UPPER_COLUMN_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"position",
			COL_POSITION,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"ris_type",
			COL_RIS_TYPE,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"ris_type_string",
			COL_RIS_TYPE_STRING,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(11),
			COLSIZE(11)
		},
		{
			"dbms_type_string",
			COL_DBMS_TYPE_STRING,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"char_max_length",
			COL_CHAR_MAX_LENGTH,
			RIS_INTEGER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"prec",
			COL_PREC,
			RIS_INTEGER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"scale",
			COL_SCALE,
			RIS_INTEGER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"nullable",
			COL_NULLABLE,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof("YES")-1),
			COLSIZE(sizeof("YES")-1)
		}
	},
	1,
	{
		{
			"idx_risxxx_col",
			IDX_RISXXX_COL,
			0,
			UNIQUE,
			2,
			(int)RIS_E_INV_COLUMNS_INDEX,
			{
				COL_TABLE_ID,
				COL_COLUMN_NAME
			}
		}
	},
	(char *)0
},

{
	"ri05_t04",
	"ri05_t04",
	'T',
	4,
	5,
	'N',
	7,
	0x8,
	RIS_E_INV_CREATE_T04,
	RIS_E_MISSING_T04,
	RIS_E_INV_MODIFY_T04,
	9,
	{
		{
			"index_name",
			COL_INDEX_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"ext_index_name",
			COL_EXT_INDEX_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_index_name",
			COL_UPPER_INDEX_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"index_owner",
			COL_INDEX_OWNER,
			RIS_CHARACTER NOT_NULL,
            {0},
			{0},
            DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
            COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"table_id",
			COL_TABLE_ID,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"column_name",
			COL_COLUMN_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_column_name",
			COL_UPPER_COLUMN_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"position",
			COL_POSITION,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"index_type",
			COL_INDEX_TYPE,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		}
	},
	2,
	{
		{
			"idx_risxxx_idxcola",
			IDX_RISXXX_IDXCOLA,
			0,
			UNIQUE,
			3,
			(int)RIS_E_INV_INDEX_COLUMNS_INDEX,
			{
				COL_TABLE_ID,
				COL_INDEX_NAME,
				COL_POSITION
			}
		},
		{
			"idx_risxxx_idxcolb",
			IDX_RISXXX_IDXCOLB,
			0,
			DUPLICATES,
			1,
			(int)RIS_E_INV_INDEX_COLUMNS_INDEX,
			{
				COL_INDEX_NAME
			}
		}
	},
	(char *)0
},

{
	"ri05_t05",
	"ri05_t05",
	'T',
	5,
	5,
	'N',
	7,
	0x10,
	RIS_E_INV_CREATE_T05,
	RIS_E_MISSING_T05,
	RIS_E_INV_MODIFY_T05,
	6,
	{
		{
			"table_id",
			COL_TABLE_ID,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"column_name",
			COL_COLUMN_NAME,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_column_name",
			COL_UPPER_COLUMN_NAME,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"grantor",
			COL_GRANTOR,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"grantee",
			COL_GRANTEE,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"ris_privileges",
			COL_RIS_PRIVILEGES,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_AUTH_SIZE-1),
			COLSIZE(RIS_AUTH_SIZE-1)
		}
	},
	5,
	{
		{
			"idx_risxxx_priva",
			IDX_RISXXX_PRIVA,
			0,
			DUPLICATES,
			1,
			(int)RIS_E_INV_PRIVS_INDEX,
			{
				COL_GRANTEE
			}
		},
		{
			"idx_risxxx_privb",
			IDX_RISXXX_PRIVB,
			0,
			UNIQUE,
			4,
			(int)RIS_E_INV_PRIVS_INDEX,
			{
				COL_TABLE_ID,	
				COL_COLUMN_NAME,
				COL_GRANTOR,
				COL_GRANTEE
			},

			/*
			** NOTE -- We could not have a unique index in the past 
			** because informix-SE 
			** has a limit of 120 characters in an index and complains.
			*/
		},
		{
			"idx_risxxx_privc",
			IDX_RISXXX_PRIVC,
			0,
			DUPLICATES,
			2,
			(int)RIS_E_INV_PRIVS_INDEX,
			{
				COL_TABLE_ID,	
				COL_GRANTEE
			}
		},
		{
			"idx_risxxx_privd",
			IDX_RISXXX_PRIVD,
			0,
			DUPLICATES,
			3,
			(int)RIS_E_INV_PRIVS_INDEX,
			{
				COL_COLUMN_NAME,
				COL_GRANTOR,
				COL_GRANTEE
			},

		},
		{
			"idx_risxxx_prive",
			IDX_RISXXX_PRIVE,
			0,
			DUPLICATES,
			3,
			(int)RIS_E_INV_PRIVS_INDEX,
			{
				COL_TABLE_ID,	
				COL_COLUMN_NAME,
				COL_GRANTOR
			},

		}
	},
	(char *)0
},

{
	"ri05_t06",
	"ri05_t06",
	'T',
	6,
	5,
	'N',
	7,
	0x20,
	RIS_E_INV_CREATE_T06,
	RIS_E_MISSING_T06,
	RIS_E_INV_MODIFY_T06,
	2,
	{
		{
			"schema_name",
			COL_SCHEMA_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"grantee",
			COL_GRANTEE,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		}
	},
	1,
	{
		{
			"idx_risxxx_gran",
			IDX_RISXXX_GRAN,
			0,
			UNIQUE,
			2,
			(int)RIS_E_INV_PRIVS_INDEX,
			{
				COL_GRANTEE,
				COL_SCHEMA_NAME
			}
		}
	},
	(char *)0
},

{
	"ri05_t07",
	"ri05_t07",
	'T',
	7,
	5,
	'N',
	7,
	0x40,
	RIS_E_INV_CREATE_T07,
	RIS_E_MISSING_T07,
	RIS_E_INV_MODIFY_T07,
	3,
	{
		{
			"server_pid",
			COL_SERVER_PID,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"schema_name",
			COL_SCHEMA_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"schema_user",
			COL_SCHEMA_USER,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		}
	},
	1,
	{
		{
			"idx_risxxx_schusr",
			IDX_RISXXX_SCHUSR,
			0,
			UNIQUE,
			1,
			(int)RIS_E_INV_CREATE_SCHUSR,
			{
				COL_SERVER_PID
			}
		}
	},
	(char *)0
},

{
	"ri05_t08",
	"ri05_t08",
	'T',
	8,
	5,
	'N',
	7,
	0x80,
	RIS_E_INV_CREATE_T08,
	RIS_E_MISSING_T08,
	RIS_E_INV_MODIFY_T08,
	4,
	{
		{
			"table_id",
			COL_TABLE_ID,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"ris_view_def",
			COL_RIS_VIEW_DEF,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_VIEWSTRING_SIZE-1),
			COLSIZE(RIS_MAX_VIEWSTRING_SIZE-1)
		},
		{
			"dbms_view_def",
			COL_DBMS_VIEW_DEF,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_VIEWSTRING_SIZE-1),
			COLSIZE(RIS_MAX_VIEWSTRING_SIZE-1)
		},
		{
			"sequence_id",
			COL_SEQUENCE_ID,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		}
	},
	1,
	{
		{
			"idx_risxxx_view",
			IDX_RISXXX_VIEW,
			0,
			UNIQUE,
			2,
			(int)RIS_E_INV_VIEWS_INDEX,
			{
				COL_TABLE_ID,
				COL_SEQUENCE_ID
			}
		}
	},
	(char *)0
},

{
	"ri05_t09",
	"ri05_t09",
	'T',
	9,
	5,
	'N',
	6,
	0x100,
	RIS_E_INV_CREATE_T09,
	RIS_E_MISSING_T09,
	RIS_E_INV_MODIFY_T09,
	8,
	{
		{
			"schema_name",
			COL_SCHEMA_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"schema_owner",
			COL_SCHEMA_OWNER,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"database_id",
			COL_DATABASE_ID,
			RIS_SMALLINT NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(short)),
			COLSIZE(sizeof(short))
		},
		{
			"schema_type",
			COL_SCHEMA_TYPE,
			RIS_SMALLINT NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(short)),
			COLSIZE(sizeof(short))
		},
		{
			"dictionary_owner",
			COL_DICTIONARY_OWNER,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"srvid",
			COL_SRVID,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"major",   
			COL_MAJOR,
			RIS_SMALLINT   NOT_NULL, 
			{0}, 
			{0},
			DBMS_COLSIZE(sizeof(short)), 
			COLSIZE(sizeof(short)) 
		},
		{	
			"feature",
			COL_FEATURE,
			RIS_SMALLINT   NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(short)),
			COLSIZE(sizeof(short)) 
		}

	},
	0,
	{ 
		{0} 
	},
	(char *)0
},

{
	"ri05_t10",
	"ri05_t10",
	'T',
	10,
	5,
	'N',
	7,
	0x200,
	RIS_E_INV_CREATE_T10,
	RIS_E_MISSING_T10,
	RIS_E_INV_MODIFY_T10,
	3,
	{
		{
			"schema_name",
			COL_SCHEMA_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"user_name",
			COL_USER_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"user_privilege",
			COL_USER_PRIVILEGE,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		}
	},
	1,
	{
		{
			"idx_risxxx_users",
			IDX_RISXXX_USERS,
			0,
			UNIQUE,
			2,
			(int)RIS_E_INV_RISUSERS_INDEX,
			{
				COL_USER_NAME,
				COL_SCHEMA_NAME
			}
		}
	},
	(char *)0
},

{
	"ri05_t11",
	"ri05_t11",
	'T',
	11,
	5,
	'N',
	7,
	0x400,
	RIS_E_INV_CREATE_T11,
	RIS_E_MISSING_T11,
	RIS_E_INV_MODIFY_T11,
	2,
	{
		{
			"user_name",
			COL_USER_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"user_privilege",
			COL_USER_PRIVILEGE,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		}
	},
	1,
	{
		{
			"idx_risxxx_t11",
			IDX_RISXXX_T11,
			0,
			UNIQUE,
			1,
			(int)RIS_E_INV_RI05_T11_INDEX,
			{
				COL_USER_NAME
			}
		}
	},
	
	(char *)0
},

{
	"ri05_t12",
	"ri05_t12",
	'T',
	12,
	5,
	'N',
	7,
	0x800,
	RIS_E_INV_CREATE_T12,
	RIS_E_MISSING_T12,
	RIS_E_INV_MODIFY_T12,
	7,
	{
		{
			"lastid",
			COL_LASTID,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"dictionary_owner",
			COL_DICTIONARY_OWNER,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"first_schema",
			COL_FIRST_SCHEMA,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"int_par1",
			COL_INT_PAR1,
			RIS_INTEGER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"int_par2",
			COL_INT_PAR2,
			RIS_INTEGER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"str_par1",
			COL_STR_PAR1,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"str_par2",
			COL_STR_PAR2,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		}
	},
	0,
	{
		{0}
	},
	(char *)0
},

{
	"ri05_t13",
	"ri05_t13",
	'T',
	13,
	5,
	'N',
	2,
	0x1000,
	RIS_E_INV_CREATE_T13,
	RIS_E_MISSING_T13,
	RIS_E_INV_MODIFY_T13,
	23,
	{
		{
			"database_id",
			COL_DATABASE_ID,
			RIS_SMALLINT NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(short)),
			COLSIZE(sizeof(short))
		},
		{
			"database_type",
			COL_DATABASE_TYPE,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		},
		{
			"database_name",
			COL_DATABASE_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_CHAR_STRING_SIZE),
			COLSIZE(RIS_MAX_CHAR_STRING_SIZE)
		},
		{
			"protocol_1",
			COL_PROTOCOL_1,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		},
		{
			"net_address_1",
			COL_NET_ADDRESS_1,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(28),
			COLSIZE(28)
		},
		{
			"protocol_2",
			COL_PROTOCOL_2,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		},
		{
			"net_address_2",
			COL_NET_ADDRESS_2,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(28),
			COLSIZE(28)
		},
		{
			"protocol_3",
			COL_PROTOCOL_3,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		},
		{
			"net_address_3",
			COL_NET_ADDRESS_3,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(28),
			COLSIZE(28)
		},
		{
			"protocol_4",
			COL_PROTOCOL_4,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		},
		{
			"net_address_4",
			COL_NET_ADDRESS_4,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(28),
			COLSIZE(28)
		},
		{
			"long_parameter_1",
			COL_LONG_PARAMETER_1,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_CHAR_STRING_SIZE),
			COLSIZE(RIS_MAX_CHAR_STRING_SIZE)
		},
		{
			"long_parameter_2",
			COL_LONG_PARAMETER_2,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_CHAR_STRING_SIZE),
			COLSIZE(RIS_MAX_CHAR_STRING_SIZE)
		},
		{
			"long_parameter_3",
			COL_LONG_PARAMETER_3,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_CHAR_STRING_SIZE),
			COLSIZE(RIS_MAX_CHAR_STRING_SIZE)
		},
		{
			"short_parameter_1",
			COL_SHORT_PARAMETER_1,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_2",
			COL_SHORT_PARAMETER_2,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_3",
			COL_SHORT_PARAMETER_3,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_4",
			COL_SHORT_PARAMETER_4,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_5",
			COL_SHORT_PARAMETER_5,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_6",
			COL_SHORT_PARAMETER_6,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_7",
			COL_SHORT_PARAMETER_7,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_8",
			COL_SHORT_PARAMETER_8,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"srvid",
			COL_SRVID,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		}
	},
	0,
	{ 
		{0} 
	},
	(char *)0
},

 /*********************************************************************/
 /* RIS Version 5 views.                                              */
 /*********************************************************************/

{	
	"ris5column_privs",
	VIEW_RIS5COLUMN_PRIVS,
	'V',
	14,
	5,
	'Y',
	10,
	0x2000,
	RIS_E_INV_CREATE_X5COLUMN_PRIVS,
    RIS_E_MISSING_X5COLUMN_PRIVS,
    RIS_E_INV_MODIFY_X5COLUMN_PRIVS,
	9,
	{
		{
			"schema_name",
			COL_SCHEMA_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"table_name",
			COL_TABLE_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_table_name",
			COL_UPPER_TABLE_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"column_name",
			COL_COLUMN_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_column_name",
			COL_UPPER_COLUMN_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"grantor",
			COL_GRANTOR,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"grantee",
			COL_GRANTEE,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"ris_privileges",
			COL_RIS_PRIVILEGES,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_AUTH_SIZE-1),
			COLSIZE(RIS_AUTH_SIZE-1)
		},
		{
			"ris_object",
			COL_RIS_OBJECT,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		}
	},
	0,
	{
		{0}
	},
	RIS5COLUMN_PRIVS
},

{
	"ris5columns",
	VIEW_RIS5COLUMNS,
	'V',
	15,
	5,
	'Y',
	4,
	0x4000,
	RIS_E_INV_CREATE_X5COLUMNS,
    RIS_E_MISSING_X5COLUMNS,
    RIS_E_INV_MODIFY_X5COLUMNS,
	15,
	{
		{
			"schema_name",
			COL_SCHEMA_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"table_name",
			COL_TABLE_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_table_name",
			COL_UPPER_TABLE_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"column_name",
			COL_COLUMN_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"ext_column_name",
			COL_EXT_COLUMN_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_column_name",
			COL_UPPER_COLUMN_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"position",
			COL_POSITION,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"ris_type",
			COL_RIS_TYPE,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"ris_type_string",
			COL_RIS_TYPE_STRING,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(11),
			COLSIZE(11)
		},
		{
			"dbms_type_string",
			COL_DBMS_TYPE_STRING,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"char_max_length",
			COL_CHAR_MAX_LENGTH,
			RIS_INTEGER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"prec",
			COL_PREC,
			RIS_INTEGER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"scale",
			COL_SCALE,
			RIS_INTEGER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"nullable",
			COL_NULLABLE,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof("YES")-1),
			COLSIZE(sizeof("YES")-1)
		},
		{
			"ris_object",
			COL_RIS_OBJECT,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		}
	},
	0,
	{
		{0}
	},
	RIS5COLUMNS
},

{
	"ris5dbms_columns",								/* name				*/
	VIEW_RIS5DBMS_COLUMNS,							/* extname			*/
	'V',											/* tabtype			*/
	16,												/* tabid			*/
	5,												/* version			*/
	'Y',											/* load_object		*/
	9,												/* compression		*/
	0x8000,											/* id_bit			*/
	RIS_E_INV_CREATE_X5DBMSCOLUMNS,					/* failure_error	*/
	RIS_E_MISSING_X5DBMSCOLUMNS,					/* missing_error	*/
	RIS_E_INV_MODIFY_X5DBMSCOLUMNS,					/* modify_error		*/
	4,												/* column_count		*/
	{
		{											/* attr[0]			*/
			"table_name",							/* attrname			*/
			COL_TABLE_NAME,							/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		},

		{
			"dbms_owner",							/* attrname			*/
			COL_DBMS_OWNER,							/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		},

		{
			"column_name",							/* attrname			*/
			COL_COLUMN_NAME,						/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		},
		{
			"position",
			COL_POSITION,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		}
	},
	0,
	{
		{0}
	},
	RIS5DBMS_COLUMNS								/* viewtext			*/
},

{
	"ris5dbms_indexes",								/* name				*/
	VIEW_RIS5DBMS_INDEXES,							/* extname			*/
	'V',											/* tabtype			*/
	17,												/* tabid			*/
	5,												/* version			*/
	'Y',											/* load_object		*/
	9,												/* compression		*/
	0x10000,										/* id_bit			*/
	RIS_E_INV_CREATE_X5DBMS_IDXS,					/* failure_error	*/
	RIS_E_MISSING_X5DBMS_IDXS,					/* missing_error	*/
	RIS_E_INV_MODIFY_X5DBMS_IDXS,					/* modify_error		*/
	3,												/* column_count		*/
	{
		{											/* attr[0]			*/
			"table_name",							/* attrname			*/
			COL_TABLE_NAME,							/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		},

		{
			"dbms_owner",							/* attrname			*/
			COL_DBMS_OWNER,							/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		},

		{
			"index_name",							/* attrname			*/
			COL_INDEX_NAME,							/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		},
	},
	0,
	{
		{0}
	},
	RIS5DBMS_INDEXES								/* viewtext			*/
},

{
	"ris5dbms_tables",								/* name				*/
	VIEW_RIS5DBMS_TABLES,							/* extname			*/
	'V',											/* tabtype			*/
	18,												/* tabid			*/
	5,												/* version			*/
	'Y',											/* load_object		*/
	9,												/* compression		*/
	0x20000,										/* id_bit			*/
	RIS_E_INV_CREATE_X5DBMSTABS,					/* failure_error	*/
	RIS_E_MISSING_X5DBMSTABS,					/* missing_error	*/
	RIS_E_INV_MODIFY_X5DBMSTABS,					/* modify_error		*/
	2,												/* column_count		*/
	{
		{											/* attr[0]			*/
			"table_name",							/* attrname			*/
			COL_TABLE_NAME,							/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		},
		{											/* attr[0]			*/
			"dbms_owner",							/* attrname			*/
			COL_DBMS_OWNER,							/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		},
	},
	0,
	{
		{0}
	},
	RIS5DBMS_TABLES									/* viewtext			*/
},

{
	"ris5dbms_users",								/* name				*/
	VIEW_RIS5DBMS_USERS,							/* extname			*/
	'V',											/* tabtype			*/
	19,												/* tabid			*/
	5,												/* version			*/
	'Y',											/* load_object		*/
	9,												/* compression		*/
	0x40000,										/* id_bit			*/
	RIS_E_INV_CREATE_X5DBMSUSERS,					/* failure_error	*/
	RIS_E_MISSING_X5DBMSUSERS,						/* missing_error	*/
	RIS_E_INV_MODIFY_X5DBMSUSERS,					/* modify_error		*/
	2,												/* column_count		*/
	{
		{											/* attr[0]			*/
			"user_name",							/* attrname			*/
			COL_USER_NAME,							/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		},
		{											/* attr[0]			*/
			"dbms_owner",							/* attrname			*/
			COL_DBMS_OWNER,							/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		}
	},
	0,
	{
		{0}
	},
	RIS5DBMS_USERS									/* viewtext			*/
},

{
	"ris5dbms_views",								/* name				*/
	VIEW_RIS5DBMS_VIEWS,							/* extname			*/
	'V',											/* tabtype			*/
	20,												/* tabid			*/
	5,												/* version			*/
	'Y',											/* load_object		*/
	6,												/* compression		*/
	0x80000,										/* id_bit			*/
	RIS_E_INV_CREATE_X5DBMSVIEWS,					/* failure_error	*/
	RIS_E_MISSING_X5DBMSVIEWS,						/* missing_error	*/
	RIS_E_INV_MODIFY_X5DBMSVIEWS,					/* modify_error		*/
	2,												/* column_count		*/
	{
		{											/* attr[0]			*/
			"view_name",							/* attrname			*/
			COL_VIEW_NAME,							/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		},
		{											/* attr[0]			*/
			"dbms_owner",							/* attrname			*/
			COL_DBMS_OWNER,							/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		},
	},
	0,
	{
		{0}
	},
	RIS5DBMS_VIEWS									/* viewtext			*/
},

{
	"ris5dbs",
	VIEW_RIS5DBS,
	'V',
	21,
	5,
	'Y',
	4,
	0x100000,										/* id_bit			*/
	RIS_E_INV_CREATE_X5DBS,                   
    RIS_E_MISSING_X5DBS,                      
    RIS_E_INV_MODIFY_X5DBS,
	23,
	{
		{
			"database_id",
			COL_DATABASE_ID,
			RIS_SMALLINT NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(short)),
			COLSIZE(sizeof(short))
		},
		{
			"database_type",
			COL_DATABASE_TYPE,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		},
		{
			"database_name",
			COL_DATABASE_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_CHAR_STRING_SIZE),
			COLSIZE(RIS_MAX_CHAR_STRING_SIZE)
		},
		{
			"protocol_1",
			COL_PROTOCOL_1,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		},
		{
			"net_address_1",
			COL_NET_ADDRESS_1,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(28),
			COLSIZE(28)
		},
		{
			"protocol_2",
			COL_PROTOCOL_2,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		},
		{
			"net_address_2",
			COL_NET_ADDRESS_2,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(28),
			COLSIZE(28)
		},
		{
			"protocol_3",
			COL_PROTOCOL_3,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		},
		{
			"net_address_3",
			COL_NET_ADDRESS_3,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(28),
			COLSIZE(28)
		},
		{
			"protocol_4",
			COL_PROTOCOL_4,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		},
		{
			"net_address_4",
			COL_NET_ADDRESS_4,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(28),
			COLSIZE(28)
		},
		{
			"long_parameter_1",
			COL_LONG_PARAMETER_1,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_CHAR_STRING_SIZE),
			COLSIZE(RIS_MAX_CHAR_STRING_SIZE)
		},
		{
			"long_parameter_2",
			COL_LONG_PARAMETER_2,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_CHAR_STRING_SIZE),
			COLSIZE(RIS_MAX_CHAR_STRING_SIZE)
		},
		{
			"long_parameter_3",
			COL_LONG_PARAMETER_3,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_CHAR_STRING_SIZE),
			COLSIZE(RIS_MAX_CHAR_STRING_SIZE)
		},
		{
			"short_parameter_1",
			COL_SHORT_PARAMETER_1,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_2",
			COL_SHORT_PARAMETER_2,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_3",
			COL_SHORT_PARAMETER_3,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_4",
			COL_SHORT_PARAMETER_4,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_5",
			COL_SHORT_PARAMETER_5,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_6",
			COL_SHORT_PARAMETER_6,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_7",
			COL_SHORT_PARAMETER_7,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_8",
			COL_SHORT_PARAMETER_8,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"srvid",
			COL_SRVID,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		}
	},
	0,
	{
		{0}
	},
	RIS5DBS	
},
 
{
	"ris5index_columns",
	VIEW_RIS5INDEX_COLUMNS,
	'V',
	22,
	5,
	'Y',
	9,
	0x200000,
	RIS_E_INV_CREATE_X5IDX_COLS,
    RIS_E_MISSING_X5IDX_COLS,
    RIS_E_INV_MODIFY_X5IDX_COLS,
	8,
	{
		{
			"schema_name",
			COL_SCHEMA_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"index_name",
			COL_INDEX_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_index_name",
			COL_UPPER_INDEX_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"table_name",
			COL_TABLE_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_table_name",
			COL_UPPER_TABLE_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"column_name",
			COL_COLUMN_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_column_name",
			COL_UPPER_COLUMN_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"position",
			COL_POSITION,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		}
	},
	0,
	{
		{0}
	},
	RIS5INDEX_COLUMNS
},

{
	"ris5indexes",
	VIEW_RIS5INDEXES,
	'V',
	23,
	5,
	'Y',
	4,
	0x400000,
	RIS_E_INV_CREATE_X5INDEXES,
    RIS_E_MISSING_X5INDEXES,
    RIS_E_INV_MODIFY_X5INDEXES,
	8,
	{
		{
			"schema_name",
			COL_SCHEMA_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"index_name",
			COL_INDEX_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"dbms_owner",
			COL_DBMS_OWNER,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"ext_index_name",
			COL_EXT_INDEX_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_index_name",
			COL_UPPER_INDEX_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"table_name",
			COL_TABLE_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_table_name",
			COL_UPPER_TABLE_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"index_type",
			COL_INDEX_TYPE,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		}
	},
	0,
	{
		{0}
	},
	RIS5INDEXES
},

{
	"ris5schemas",
	VIEW_RIS5SCHEMAS,
	'V',
	24,
	5,
	'Y',
	7,
	0x800000,
	RIS_E_INV_CREATE_X5SCHEMAS,
    RIS_E_MISSING_X5SCHEMAS,
    RIS_E_INV_MODIFY_X5SCHEMAS,
	6,
	{
		{
			"schema_name",
			COL_SCHEMA_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"schema_owner",
			COL_SCHEMA_OWNER,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"database_id",
			COL_DATABASE_ID,
			RIS_SMALLINT NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(short)),
			COLSIZE(sizeof(short))
		},
		{
			"schema_type",
			COL_SCHEMA_TYPE,
			RIS_SMALLINT NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(short)),
			COLSIZE(sizeof(short))
		},
		{
			"dictionary_owner",
			COL_DICTIONARY_OWNER,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"srvid",
			COL_SRVID,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		}
	},
	0,
	{
		{0}
	},
	RIS5SCHEMAS
},

{
	"ris5schpriv",									/* name				*/
	VIEW_RIS5SCHPRIV,								/* extname			*/
	'V',											/* tabtype			*/
	25,												/* tabid			*/
	5,												/* version			*/
	'Y',											/* load_object		*/
	4,												/* compression		*/
	0x1000000,										/* id_bit			*/
	RIS_E_INV_CREATE_X5SCHPRIV,						/* failure_error	*/
	RIS_E_MISSING_X5SCHPRIV,						/* missing_error	*/
	RIS_E_INV_MODIFY_X5SCHPRIV,						/* modify_error		*/
	2,												/* column_count		*/
	{
		{											/* attr[0]			*/
			"user_name",							/* attrname			*/
			COL_USER_NAME,							/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		},
		{											/* attr[0]			*/
			"user_privilege",						/* attrname			*/
			COL_USER_PRIVILEGE,						/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		},
	},
	0,
	{
		{0}
	},
	RIS5SCHPRIV										/* viewtext			*/
},

{
	"ris5table_privs",
	VIEW_RIS5TABLE_PRIVS,
	'V',
	26,
	5,
	'Y',
	9,
	0x2000000,										/* id_bit			*/
	RIS_E_INV_CREATE_X5TABPRIV,                     
    RIS_E_MISSING_X5TABPRIV,                        
    RIS_E_INV_MODIFY_X5TABPRIV,
	7,
	{
		{
			"schema_name",
			COL_SCHEMA_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"table_name",
			COL_TABLE_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_table_name",
			COL_UPPER_TABLE_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"grantor",
			COL_GRANTOR,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"grantee",
			COL_GRANTEE,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"ris_privileges",
			COL_RIS_PRIVILEGES,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_AUTH_SIZE-1),
			COLSIZE(RIS_AUTH_SIZE-1)
		},
		{
			"ris_object",
			COL_RIS_OBJECT,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		}
	},
	0,
	{
		{0}
	},
	RIS5TABLE_PRIVS
},

{
	"ris5tables",
	VIEW_RIS5TABLES,
	'V',
	27,
	5,
	'Y',
	4,
	0x4000000,										/* id_bit			*/
	RIS_E_INV_CREATE_X5TABLES,                     
    RIS_E_MISSING_X5TABLES,                        
    RIS_E_INV_MODIFY_X5TABLES,
	9,
	{
		{
			"schema_name",
			COL_SCHEMA_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"table_name",
			COL_TABLE_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"dbms_owner",
			COL_DBMS_OWNER,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"ext_table_name",
			COL_EXT_TABLE_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_table_name",
			COL_UPPER_TABLE_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"table_type",
			COL_TABLE_TYPE,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		},
		{
			"date_entered",
			COL_DATE_ENTERED,
			RIS_TIMESTAMP NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(dtime)),
			COLSIZE(sizeof(dtime))
		},
		{
			"date_modified",
			COL_DATE_MODIFIED,
			RIS_TIMESTAMP NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(dtime)),
			COLSIZE(sizeof(dtime))
		},
		{
			"ris_object",
			COL_RIS_OBJECT,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		}
	},
	0,
	{
		{0}
	},
	RIS5TABLES
},

{
	"ris5users",									/* name				*/
	VIEW_RIS5USERS,									/* extname			*/
	'V',											/* tabtype			*/
	28,												/* tabid			*/
	5,												/* version			*/
	'Y',											/* load_object		*/
	4,												/* compression		*/
	0x8000000,										/* id_bit			*/
	RIS_E_INV_CREATE_X5USERS,						/* failure_error	*/
	RIS_E_MISSING_X5USERS,							/* missing_error	*/
	RIS_E_INV_MODIFY_X5USERS,						/* modify_error		*/
	3,												/* column_count		*/
	{
		{											/* attr[0]			*/
			"schema_name",							/* attrname			*/
			COL_SCHEMA_NAME,						/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		},
		{
			"user_name",							/* attrname			*/
			COL_USER_NAME,							/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		},
		{
			"user_privilege",							/* attrname			*/
			COL_USER_PRIVILEGE,							/* extern_attrname	*/
			RIS_CHARACTER NOT_NULL,					/* atype			*/
			{0},									/* pad				*/
			{0},									/* dbsqltype		*/
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),		/* dbsqllen			*/
			COLSIZE(RIS_MAX_ID_SIZE-1)				/* asize.len		*/
		},
	},
	0,
	{
		{0}
	},
	RIS5USERS										/* viewtext			*/
},

{
	"ris5views",
	VIEW_RIS5VIEWS,
	'V',
	29,
	5,
	'Y',
	3,
	0x10000000,										/* id_bit			*/
	RIS_E_INV_CREATE_X5VIEWS,                       
    RIS_E_MISSING_X5VIEWS,                          
    RIS_E_INV_MODIFY_X5VIEWS,
	8,
	{
		{
			"schema_name",
			COL_SCHEMA_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"view_name",
			COL_VIEW_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"dbms_owner",
			COL_DBMS_OWNER,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"ext_view_name",
			COL_EXT_VIEW_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_view_name",
			COL_UPPER_VIEW_NAME,
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"ris_view_def",
			COL_RIS_VIEW_DEF,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_VIEWSTRING_SIZE-1),
			COLSIZE(RIS_MAX_VIEWSTRING_SIZE-1)
		},
		{
			"dbms_view_def",
			COL_DBMS_VIEW_DEF,
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_VIEWSTRING_SIZE-1),
			COLSIZE(RIS_MAX_VIEWSTRING_SIZE-1)
		},
		{
			"sequence_id",
			COL_SEQUENCE_ID,
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		}
	},
	0,
	{
		{0}
	},
	RIS5VIEWS
},

 /*********************************************************************/
 /* RIS Version 4 tables, as views in version 5.                      */
 /* These will not be created for OS/400 schemas.                     */
 /*********************************************************************/

{
	"ris_columns",
	"ris_columns",
	'V',
	30,
	4,
	'Y',
	4,
	0x1,
	RIS_E_INV_CREATE_XCOLUMNS,
	RIS_E_MISSING_XCOLUMNS,
	RIS_E_INV_MODIFY_COLUMNS,
	12,
	{
		{
			"table_name",
			"table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_table_name",
			"upper_table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"column_name",
			"column_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_column_name",
			"upper_column_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"position",
			"position",
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"ris_type",
			"ris_type",
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"ris_type_string",
			"ris_type_string",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(11),
			COLSIZE(11)
		},
		{
			"dbms_type_string",
			"dbms_type_string",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"char_max_length",
			"char_max_length",
			RIS_INTEGER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"prec",
			"prec",
			RIS_INTEGER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"scale",
			"scale",
			RIS_INTEGER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"nullable",
			"nullable",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof("YES")-1),
			COLSIZE(sizeof("YES")-1)
		}
	},
	0,
	{
		{0}
	},
	V4_RIS_COLUMNS
},

{
	"ris_index_columns",
	"ris_index_columns",
	'V',
	31,
	4,
	'Y',
	9,
	0x2,
	RIS_E_INV_CREATE_XINDEX_COLUMNS,
	RIS_E_MISSING_XINDEX_COLUMNS,
	RIS_E_INV_MODIFY_INDEX_COLUMNS,
	7,
	{
		{
			"index_name",
			"index_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_index_name",
			"upper_index_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"table_name",
			"table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_table_name",
			"upper_table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"column_name",
			"column_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_column_name",
			"upper_column_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"position",
			"position",
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		}
	},
	0,
	{
		{0}
	},
	V4_RIS_INDEX_COLUMNS
},

{
	"ris_indexes",
	"ris_indexes",
	'V',
	32,
	4,
	'Y',
	4,
	0x4,
	RIS_E_INV_CREATE_XINDEXES,
	RIS_E_MISSING_XINDEXES,
	RIS_E_INV_MODIFY_INDEXES,
	5,
	{
		{
			"index_name",
			"index_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_index_name",
			"upper_index_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"table_name",
			"table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_table_name",
			"upper_table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"index_type",
			"index_type",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		}
	},
	0,
	{
		{0}
	},
	V4_RIS_INDEXES
},

{
	"ris_privs",
	"ris_privs",
	'V',
	33,
	4,
	'Y',
	4,
	0x8,
	RIS_E_INV_CREATE_PRIVS,
	RIS_E_MISSING_PRIVS,
	RIS_E_INV_MODIFY_PRIVS,
	7,
	{
		{
			"table_name",
			"table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_table_name",
			"upper_table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"column_name",
			"column_name",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_column_name",
			"upper_column_name",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"grantor",
			"grantor",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"grantee",
			"grantee",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"ris_privileges",
			"ris_privileges",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_AUTH_SIZE-1),
			COLSIZE(RIS_AUTH_SIZE-1)
		}
	},
	0,
	{
		{0}
	},
	V4_RIS_PRIVS
},

{
	"ris_schemaid",
	"ris_schemaid",
	'V',
	34,
	4,
	'Y',
	7,
	0x10,
	RIS_E_INV_CREATE_SCHEMAID,
	0,
	RIS_E_INV_MODIFY_SCHEMAID,
	2,
	{
		{
			"schema_name",
			"schema_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"schema_password",
			"schema_password",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_PASSWD_SIZE-1),
			COLSIZE(RIS_MAX_PASSWD_SIZE-1)
		},
	},
	0,
	{
		{0}
	},
	V4_RIS_SCHEMAID
},

{
	"ris_schusr",
	"ris_schusr",
	'V',
	35,
	4,
	'Y',
	4,
	0x20,
	RIS_E_INV_CREATE_SCHUSR,
	RIS_E_MISSING_SCHUSR,
	RIS_E_INV_MODIFY_SCHUSR,
	1,
	{
		{
			"pid",
			"pid",
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		}
	},
	0,
	{
		{0}
	},
	V4_RIS_SCHUSR
},

{
	"ris_tables",
	"ris_tables",
	'V',
	36,
	4,
	'Y',
	4,
	0x40,
	RIS_E_INV_CREATE_XTABLES,
	RIS_E_MISSING_XTABLES,
	RIS_E_INV_MODIFY_TABLES,
	3,
	{
		{
			"table_name",
			"table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_table_name",
			"upper_table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"table_type",
			"table_type",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		}
	},
	0,
	{
		{0}
	},
	V4_RIS_TABLES
},

{
	"ris_views",
	"ris_views",
	'V',
	37,
	4,
	'Y',
	3,
	0x80,
	RIS_E_INV_CREATE_XVIEWS,
	RIS_E_MISSING_XVIEWS,
	RIS_E_INV_MODIFY_VIEWS,
	5,
	{
		{
			"view_name",
			"view_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_view_name",
			"upper_view_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"ris_view_def",
			"ris_view_def",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_VIEWSTRING_SIZE-1),
			COLSIZE(RIS_MAX_VIEWSTRING_SIZE-1)
		},
		{
			"dbms_view_def",
			"dbms_view_def",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_VIEWSTRING_SIZE-1),
			COLSIZE(RIS_MAX_VIEWSTRING_SIZE-1)
		},
		{
			"sequence_id",
			"sequence_id",
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		}
	},
	0,
	{
		{0}
	},
	V4_RIS_VIEWS
},

 /*********************************************************************/
 /* RIS Version 4 views.                                              */
 /* These will not be created for OS/400 schemas.                     */
 /*********************************************************************/

{
	"riscolumn_privs",
	"riscolumn_privs",
	'V',
	38,
	4,
	'Y',
	9,
	0x100,
	RIS_E_INV_CREATE_COLUMN_PRIVS,
	RIS_E_MISSING_COLUMN_PRIVS,
	0,
	7,
	{
		{
			"table_name",
			"table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_table_name",
			"upper_table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"column_name",
			"column_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_column_name",
			"upper_column_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"grantor",
			"grantor",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"grantee",
			"grantee",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"ris_privileges",
			"ris_privileges",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_AUTH_SIZE-1),
			COLSIZE(RIS_AUTH_SIZE-1)
		}
	},
	0,
	{
		{0}
	},
	"create view riscolumn_privs (table_name,  upper_table_name,\
grantor, grantee, ris_privileges, column_name,  \
upper_column_name) as \
select y.table_name,y.upper_table_name,x.grantor,x.grantee,\
x.ris_privileges, x.column_name,x.upper_column_name \
from ri05_t05 x,ri05_t02 y \
where x.column_name is not null and x.table_id = y.table_id and \
x.table_id > 1000 and y.schema_name='%s' and y.dbms_owner = '%s'"
},

{
	"riscolumns",
	"riscolumns",
	'V',
	39,
	4,
	'Y',
	3,
	0x200,
	RIS_E_INV_CREATE_COLUMNS,
	RIS_E_MISSING_COLUMNS,
	0,
	12,
	{
		{
			"table_name",
			"table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_table_name",
			"upper_table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"column_name",
			"column_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_column_name",
			"upper_column_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"position",
			"position",
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"ris_type",
			"ris_type",
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"ris_type_string",
			"ris_type_string",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(11),
			COLSIZE(11)
		},
		{
			"dbms_type_string",
			"dbms_type_string",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"char_max_length",
			"char_max_length",
			RIS_INTEGER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"prec",
			"prec",
			RIS_INTEGER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"scale",
			"scale",
			RIS_INTEGER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		},
		{
			"nullable",
			"nullable",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof("YES")-1),
			COLSIZE(sizeof("YES")-1)
		}
	},
	0,
	{
		{0}
	},
	"create view riscolumns (table_name, upper_table_name,\
column_name,upper_column_name,position,ris_type, \
ris_type_string,dbms_type_string,char_max_length,prec,scale,nullable) \
as \
select y.table_name, y.upper_table_name,x.column_name, \
x.upper_column_name,\
x.position,x.ris_type,x.ris_type_string, x.dbms_type_string,x.char_max_length,\
x.prec,x.scale,x.nullable \
from ri05_t03 x,ri05_t02 y \
where x.table_id > 1000 and x.table_id = y.table_id and \
y.schema_name = '%s' and y.dbms_owner = '%s'"
},

{
	"risdbms_indexes",
	"risdbms_indexes",
	'V',
	40,
	4,
	'Y',
	8,
	0x400,
	RIS_E_INV_CREATE_DBMS_INDEXES,
	RIS_E_MISSING_DBMS_INDEXES,
	0,
	2,
	{
		{
			"table_name",
			"table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"index_name",
			"index_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		}
	},
	0,
	{
		{0}
	},
	DBMS_INDEXES
},

{
	"risdbms_tables",
	"risdbms_tables",
	'V',
	41,
	4,
	'Y',
	8,
	0x800,
	RIS_E_INV_CREATE_DBMS_TABLES,
	RIS_E_MISSING_DBMS_TABLES,
	0,
	1,
	{
		{
			"table_name",
			"table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		}
	},
	0,
	{
		{0}
	},
	DBMS_TABLES
},

{
	"risdbms_views",
	"risdbms_views",
	'V',
	42,
	4,
	'Y',
	5,
	0x1000,
	RIS_E_INV_CREATE_DBMS_VIEWS,
	RIS_E_MISSING_DBMS_VIEWS,
	0,
	1,
	{
		{
			"view_name",
			"view_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		}
	},
	0,
	{
		{0}
	},
	DBMS_VIEWS
},

{
	"risdbs",
	"risdbs",
	'V',
	43,
	4,
	'Y',
	3,
	0x2000,
	0,
	0,
	0,
	23,
	{
		{
			"database_id",
			"database_id",
			RIS_SMALLINT NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(short)),
			COLSIZE(sizeof(short))
		},
		{
			"database_type",
			"database_type",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		},
		{
			"database_name",
			"database_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_CHAR_STRING_SIZE),
			COLSIZE(RIS_MAX_CHAR_STRING_SIZE)
		},
		{
			"protocol_1",
			"protocol_1",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		},
		{
			"net_address_1",
			"net_address_1",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(28),
			COLSIZE(28)
		},
		{
			"protocol_2",
			"protocol_2",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		},
		{
			"net_address_2",
			"net_address_2",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(28),
			COLSIZE(28)
		},
		{
			"protocol_3",
			"protocol_3",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		},
		{
			"net_address_3",
			"net_address_3",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(28),
			COLSIZE(28)
		},
		{
			"protocol_4",
			"protocol_4",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		},
		{
			"net_address_4",
			"net_address_4",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(28),
			COLSIZE(28)
		},
		{
			"long_parameter_1",
			"long_parameter_1",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_CHAR_STRING_SIZE),
			COLSIZE(RIS_MAX_CHAR_STRING_SIZE)
		},
		{
			"long_parameter_2",
			"long_parameter_2",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_CHAR_STRING_SIZE),
			COLSIZE(RIS_MAX_CHAR_STRING_SIZE)
		},
		{
			"long_parameter_3",
			"long_parameter_3",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_CHAR_STRING_SIZE),
			COLSIZE(RIS_MAX_CHAR_STRING_SIZE)
		},
		{
			"short_parameter_1",
			"short_parameter_1",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_2",
			"short_parameter_2",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_3",
			"short_parameter_3",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_4",
			"short_parameter_4",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_5",
			"short_parameter_5",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_6",
			"short_parameter_6",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_7",
			"short_parameter_7",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"short_parameter_8",
			"short_parameter_8",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"srvid",
			"srvid",
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		}
	},
	0,
	{
		{0}
	},
	V4_RISDBS	
},

{
	"risindex_columns",
	"risindex_columns",
	'V',
	44,
	4,
	'Y',
	8,
	0x4000,
	RIS_E_INV_CREATE_INDEX_COLUMNS,
	RIS_E_MISSING_INDEX_COLUMNS,
	0,
	7,
	{
		{
			"index_name",
			"index_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_index_name",
			"upper_index_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"table_name",
			"table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_table_name",
			"upper_table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"column_name",
			"column_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_column_name",
			"upper_column_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"position",
			"position",
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		}
	},
	0,
	{
		{0}
	},
     "create view risindex_columns(index_name,upper_index_name, \
table_name,upper_table_name,column_name, \
upper_column_name,position) as \
select x.index_name,x.upper_index_name,y.table_name, \
y.upper_table_name,x.column_name, \
x.upper_column_name,x.position \
from ri05_t04 x,ri05_t02 y where \
x.table_id > 1000 and x.table_id = y.table_id and \
y.schema_name = '%s' and y.dbms_owner = '%s'"
},

{
	"risindexes",
	"risindexes",
	'V',
	45,
	4,
	'Y',
	3,
	0x8000,
	RIS_E_INV_CREATE_INDEXES,
	RIS_E_MISSING_INDEXES,
	0,
	5,
	{
		{
			"index_name",
			"index_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_index_name",
			"upper_index_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"table_name",
			"table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_table_name",
			"upper_table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"index_type",
			"index_type",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		}
	},
	0,
	{
		{0}
	},
	"create view risindexes(index_name,upper_index_name, \
table_name,upper_table_name,index_type) \
as \
select x.index_name,x.upper_index_name,y.table_name, \
y.upper_table_name,x.index_type \
from ri05_t04 x,ri05_t02 y where \
x.table_id > 1000 and x.table_id = y.table_id and \
y.schema_name = '%s' and y.dbms_owner = '%s' \
and x.position = 1"
},

/*************************** Version 4 *******************************/
{
	"risschemas",
	"risschemas",
	'V',
	46,
	4,
	'Y',
	3,
	0x10000,
	RIS_E_INV_CREATE_SCHEMAS,
	RIS_E_MISSING_SCHEMAS,
	RIS_E_INV_MODIFY_SCHEMAS,
	4,
	{
		{
			"schema_name",
			"schema_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"schema_owner",
			"schema_owner",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"database_id",
			"database_id",
			RIS_SMALLINT NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(short)),
			COLSIZE(sizeof(short))
		},
		{
			"srvid",
			"srvid",
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		}
	},
	0,
	{
		{0}
	},
	V4_RISSCHEMAS
},

{
	"ristable_privs",
	"ristable_privs",
	'V',
	47,
	4,
	'Y',
	8,
	0x20000,
	RIS_E_INV_CREATE_TABLE_PRIVS,
	RIS_E_MISSING_TABLE_PRIVS,
	0,
	5,
	{
		{
			"table_name",
			"table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_table_name",
			"upper_table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"grantor",
			"grantor",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"grantee",
			"grantee",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"ris_privileges",
			"ris_privileges",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_AUTH_SIZE-1),
			COLSIZE(RIS_AUTH_SIZE-1)
		}
	},
	0,
	{
		{0}
	},
	 "create view ristable_privs (table_name, upper_table_name,\
grantor, grantee, ris_privileges) as \
select y.table_name, y.upper_table_name, x.grantor, x.grantee, \
x.ris_privileges \
from ri05_t05 x,ri05_t02 y where \
x.column_name is null and x.table_id > 1000 and x.table_id = y.table_id and \
y.schema_name = '%s' and y.dbms_owner = '%s'"
},

{
	"ristables",
	"ristables",
	'V',
	48,
	4,
	'Y',
	3,
	0x40000,
	RIS_E_INV_CREATE_TABLES,
	RIS_E_MISSING_TABLES,
	0,
	3,
	{
		{
			"table_name",
			"table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_table_name",
			"upper_table_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"table_type",
			"table_type",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(1),
			COLSIZE(1)
		},
	},
	0,
	{
		{0}
	},
	"create view ristables(table_name,upper_table_name,\
table_type) as \
select table_name,upper_table_name,table_type from ri05_t02 where \
table_id > 1000 and schema_name = '%s' and dbms_owner = '%s'"
},

{
	"risviews",
	"risviews",
	'V',
	49,
	4,
	'Y',
	0,
	0x80000,
	RIS_E_INV_CREATE_VIEWS,
	RIS_E_MISSING_VIEWS,
	0,
	5,
	{
		{
			"view_name",
			"view_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"upper_view_name",
			"upper_view_name",
			RIS_CHARACTER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_ID_SIZE-1),
			COLSIZE(RIS_MAX_ID_SIZE-1)
		},
		{
			"ris_view_def",
			"ris_view_def",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_VIEWSTRING_SIZE-1),
			COLSIZE(RIS_MAX_VIEWSTRING_SIZE-1)
		},
		{
			"dbms_view_def",
			"dbms_view_def",
			RIS_CHARACTER NULLABLE,
			{0},
			{0},
			DBMS_COLSIZE(RIS_MAX_VIEWSTRING_SIZE-1),
			COLSIZE(RIS_MAX_VIEWSTRING_SIZE-1)
		},
		{
			"sequence_id",
			"sequence_id",
			RIS_INTEGER NOT_NULL,
			{0},
			{0},
			DBMS_COLSIZE(sizeof(int)),
			COLSIZE(sizeof(int))
		}
	},
	0,
	{
		{0}
	},
	"create view risviews(view_name,upper_view_name,ris_view_def,\
dbms_view_def,sequence_id) as \
select y.table_name,y.upper_table_name,\
x.ris_view_def,x.dbms_view_def,x.sequence_id from ri05_t08 x,ri05_t02 y \
where x.table_id > 1000 and x.table_id = y.table_id and \
y.schema_name = '%s' and y.dbms_owner = '%s'"
},

{ "",					0 }
}

/*************** End of RIS Vserion 4 compatibility views *******************/

#endif	/* RISDICT_GLOBAL_DEFINE */
;


#ifdef vms
			/*
			** The one time that the server will use the ris_attr_info 
			** information in the global RIS dictionary structure
			** is when it is creating a schema and has to load the
			** dictionary information.  Due to the stupidity of
			** the DEC compiler, which is incapable of initializing
			** unions, the length field of all the ris_attr_infos in the
			** global structure has not been initialized.  
			** This array is just the lengths of all of the columns
			** of the dictionary, in order.
			*/

RISDICT_EXTERN  unsigned char kludge_attr_lengths[] 
#   ifdef RISDICT_GLOBAL_DEFINE
= {
/* ri05_t01 */
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_PASSWD_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        sizeof(int),
/* ri05_t02 */
        RIS_MAX_ID_SIZE-1,
        sizeof(int),
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        1,
        1,
        sizeof(dtime),
        sizeof(dtime),
/* ri05_t03 */
        sizeof(int),
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        sizeof(int),
        sizeof(int),
        11,
        RIS_MAX_ID_SIZE-1,
        sizeof(int),
        sizeof(int),
        sizeof(int),
        sizeof("YES")-1,
/* ri05_t04 */
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        sizeof(int),
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        sizeof(int),
        1,
/* ri05_t05 */
        sizeof(int),
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        RIS_AUTH_SIZE-1,
/* ri05_t06 */
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
/* ri05_t07 */
        sizeof(int),
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
/* ri05_t08 */
        sizeof(int),
        RIS_MAX_VIEWSTRING_SIZE-1,
        RIS_MAX_VIEWSTRING_SIZE-1,
        sizeof(int),
/* ri05_t09 */
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        sizeof(short),
        sizeof(short),
        RIS_MAX_ID_SIZE-1,
        sizeof(int),
        sizeof(short),
        sizeof(short),
/* ri05_t10 */
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        1,
/* ri05_t11 */
        RIS_MAX_ID_SIZE-1,
        1,
/* ri05_t12 */
        sizeof(int),
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        sizeof(int),
		sizeof(int),
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
/* ri05_t013 */
        sizeof(short),
        1,
        RIS_MAX_CHAR_STRING_SIZE,
        1,
        28,
        1,
        28,
        1,
        28,
        1,
        28,
        RIS_MAX_CHAR_STRING_SIZE,
        RIS_MAX_CHAR_STRING_SIZE,
        RIS_MAX_CHAR_STRING_SIZE,
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        RIS_MAX_ID_SIZE-1,
        sizeof(int),
/* ris5column_privs */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_AUTH_SIZE-1,
	1,
/* ris5columns */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	sizeof(int),
	sizeof(int),
	11,
	RIS_MAX_ID_SIZE-1,
	sizeof(int),
	sizeof(int),
	sizeof(int),
	sizeof("YES")-1,
	1,
/* ris5dbms_columns */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	sizeof(int),
/* ris5dbms_indexes */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
/* ris5dbms_tables */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
/* ris5dbms_users */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
/* ris5dbms_views */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
/* ris5dbs */
	sizeof(short),
	1,
	RIS_MAX_CHAR_STRING_SIZE,
	1,
	28,
	1,
	28,
	1,
	28,
	1,
	28,
	RIS_MAX_CHAR_STRING_SIZE,
	RIS_MAX_CHAR_STRING_SIZE,
	RIS_MAX_CHAR_STRING_SIZE,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	sizeof(int),
/* ris5index_columns */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	sizeof(int),
/* ris5indexes */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	1,
/* ris5schemas */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	sizeof(short),
	sizeof(short),
	RIS_MAX_ID_SIZE-1,
	sizeof(int),
/* ris5schprivs */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
/* ris5table_privs */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_AUTH_SIZE-1,
	1,
/* ris5tables */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	1,
	sizeof(dtime),
	sizeof(dtime),
	1,
/* ris5users */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
/* ris5views */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_VIEWSTRING_SIZE-1,
	RIS_MAX_VIEWSTRING_SIZE-1,
	sizeof(int),
/* ris_columns */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	sizeof(int),
	sizeof(int),
	11,
	RIS_MAX_ID_SIZE-1,
	sizeof(int),
	sizeof(int),
	sizeof(int),
	sizeof("YES")-1,
/* ris_index_columns */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	sizeof(int),
/* ris_indexes */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	1,
/* ris_privs */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_AUTH_SIZE-1,
/* ris_schemaid */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_PASSWD_SIZE-1,
/* ris_schusr */
	sizeof(int),
/* ris_tables */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	1,
/* ris_Views */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_VIEWSTRING_SIZE-1,
	RIS_MAX_VIEWSTRING_SIZE-1,
	sizeof(int),
/* riscolumn_privs */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_AUTH_SIZE-1,
/* riscolumns */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	sizeof(int),
	sizeof(int),
	11,
	RIS_MAX_ID_SIZE-1,
	sizeof(int),
	sizeof(int),
	sizeof(int),
	sizeof("YES")-1,
/* risdbms_indexes */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
/* risdbms_tables */
	RIS_MAX_ID_SIZE-1,
/* risdbms_views */
	RIS_MAX_ID_SIZE-1,
/* risdbs */
	sizeof(short),
	1,
	RIS_MAX_CHAR_STRING_SIZE,
	1,
	28,
	1,
	28,
	1,
	28,
	1,
	28,
	RIS_MAX_CHAR_STRING_SIZE,
	RIS_MAX_CHAR_STRING_SIZE,
	RIS_MAX_CHAR_STRING_SIZE,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	sizeof(int),
/* risindex_columns */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	sizeof(int),
/* risindexes */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	1,
/* risschemas */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	sizeof(short),
	sizeof(int),
/* ristable_privs */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_AUTH_SIZE-1,
/* ristables */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	1,
/* risviews */
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_ID_SIZE-1,
	RIS_MAX_VIEWSTRING_SIZE-1,
	RIS_MAX_VIEWSTRING_SIZE-1,
	sizeof(int)
	}
#   endif /* RISDICT_GLOBAL_DEFINE */
	;

#endif /* vms */

# undef DICTIONARY_MAX_COLUMNS
# undef DICTIONARY_MAX_INDEXES
# undef UNIQUE
# undef DUPLICATES
# undef NULLABLE 
# undef NOT_NULL

#endif /* RISDICT_H */
