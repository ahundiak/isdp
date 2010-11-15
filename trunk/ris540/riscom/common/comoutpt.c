/* Do not alter this PINNACLE information: $Revision: 1.2.28.1 $ */
/*
**      NAME:                                                   comoutpt.c
**      AUTHORS:                                                Terry McIntyre
**      CREATION DATE:                                  10/91
**      ABSTRACT:
**              Generic output routines for debug and 'show' commands
**      
**      REVISION HISTORY:
**              changed fieldname 'usr' to 'schowner' in
**              risschema and ris_schema_info structures to
**              reflect correct meaning : Shiva 11/10/93
**
**				11/94:	changed the call from strncpy to RIScom_strncpy for
**						INTERNATIONALIZATION support.
*/
 
/*
**      INCLUDES
*/
#ifdef vms
#include <types.h>
#else
#include <sys/types.h>
#endif
#include <ctype.h>
#include "risasync.h"
#include "riscom.h"
#include "riscl_sr.h"
#include "risdebug.h"
#include "rismem.h"
#include "riscl_pa.h"
#include "ristoken.h"
#include "ristypes.h"
#include "ris_inf.h"
#include "ris.h"
#include "commacro.h"
/*
**      DEFINES
*/
#define STATE_STRING 50
#define MAX_INDENT_SIZE 11
#define LOAD_INDENT_STRING(indent, s) \
{ \
	int i = indent < MAX_INDENT_SIZE ? indent : MAX_INDENT_SIZE; \
	memset(s, '\t', i); \
	s[i] = '\0'; \
}

/*
**      TYPES
*/

/*
**      FUNCTION PROTOTYPES
*/
#define comoutpt_c
#include "comdate.prt"
#include "comgtnme.prt"
#include "comoutpt.prt"
#include "sys.prt"
#include "comuni.prt"
#include "comstrcp.prt"
/*
**      VARIABLES
*/

/*
**      FUNCTIONS
*/

/****************************************************************************/

extern void RIScom_output_acc(
	int             (* output_func)(const char *, ...),
	void    *ptr,
	int             indent)
{
	char            indent_str[MAX_INDENT_SIZE];
	risaccess       *acc = ptr;

	if (acc)
	{
		LOAD_INDENT_STRING(indent, indent_str);

	output_func("%sacc:0x%x\n", indent_str, acc);
		output_func("%ssch:%s  rel:%s  col:%s\n",
			indent_str, acc->schname, acc->relname, acc->colname);
		output_func("%sgrantor:%s  grantee:%s\n",
			indent_str, acc->grantor,acc->grantee);
		output_func("%sauth:<%s> flag:<%c> next:0x%x\n",
			indent_str, acc->auth, acc->flag, acc->next);
	}
}

/****************************************************************************/

extern void RIScom_output_acc_info(
	int             (* output_func)(const char *, ...),
	void    *ptr,
	int             indent)
{
	char                    indent_str[MAX_INDENT_SIZE];
	ris_access_info *acc = ptr;

	if (acc)
	{
		LOAD_INDENT_STRING(indent, indent_str);

	output_func("%sacc:0x%x\n", indent_str, acc);
		output_func("%ssch:%s  rel:%s  col:%s\n",
			indent_str, acc->schname, acc->relname, acc->colname);
		output_func("%sgrantor:%s  grantee:%s\n",
			indent_str, acc->grantor,acc->grantee);
		output_func("%sauth:<%s>\n", indent_str, acc->auth);
	}
}

/****************************************************************************/

extern void RIScom_output_schema(
	int             (* output_func)(const char *, ...),
	void            *ptr,
	int                     indent)
{
	char            indent_str[MAX_INDENT_SIZE];
	risschema       *schema = ptr;
	risgrantee      *grantee;

	if (schema)
	{
		LOAD_INDENT_STRING(indent, indent_str);

		output_func("%sschname:%s  schpass:%s superschema_flag:%d\n",
			indent_str, schema->schname, schema->schpass,
			schema->superschema_flag);
		output_func("%sschowner:%s  passwd:%s\n",
			indent_str, schema->schowner, schema->passwd);
		output_func("%smajor:%02d  feature:%02d\n",
			indent_str, schema->major, schema->feature);

		output_func("%scli_to_srv_buf_size:%d srv_to_cli_buf_size:%d\n",
			indent_str, schema->cli_to_srv_buf_size,
			schema->srv_to_cli_buf_size);

		output_func("%ssrv_pid:%d\n", indent_str, schema->srv_pid);
		output_func("%srisdbs_timestamp:%d risschemas_timestamp:%d\n",
			indent_str, schema->risdbs_timestamp, schema->risschemas_timestamp);

		output_func("%sgrantees:\n", indent_str);
		for (grantee = schema->grantee; grantee; grantee = grantee->next)
			output_func("%s\t%s\n", indent_str, grantee->schname);

		output_func("%sdbid:%hd db:0x%x\n", indent_str, schema->dbid,
			schema->db);
	}
}

/****************************************************************************/

extern void RIScom_output_schema_info(
	int             (* output_func)(const char *, ...),
	void    *ptr,
	int             indent)
{
	char			indent_str[MAX_INDENT_SIZE];
	ris_schema_info *schema = ptr;

	if (schema)
	{
		LOAD_INDENT_STRING(indent, indent_str);

		output_func("%sschname        : '%s'\n", indent_str,schema->schname);
		output_func("%sschowner       : '%s'\n", indent_str,schema->schowner);
		output_func("%sschownpass     : '%s'\n", indent_str,schema->schownpass);
		output_func("%sdictowner      : '%s'\n", indent_str,schema->dictowner);
		output_func("%ssecure         : %hd\n", indent_str, schema->secure);
		output_func("%sdbid           : %hd\n", indent_str, schema->dbid);
		output_func("%sserver_version : %hd.%hd\n", indent_str,
			schema->server_version_major, schema->server_version_feature);
	}
}

/****************************************************************************/

extern void RIScom_output_superschema_stmt(
	int             (* output_func)(const char *, ...),
	void    *ptr,
	int             indent)
{
	int                             i;
	char                    indent_str[MAX_INDENT_SIZE];
	char                    string[STATE_STRING];
	risstmtstat             *stmtstat;
	rissuperschema  *sschema = ptr;

	if (sschema)
	{
		LOAD_INDENT_STRING(indent, indent_str);

		output_func("%sschname:'%s' ssid:%d stmt_count:%d\n",
			indent_str, STRING(sschema->schname), sschema->ssid,
			sschema->stmt_count);
		for( i = 0; i < sschema->stmt_count; i++ )
		{
			output_func("%s\tstmtstat_indx:%d ", indent_str, i); 
			if(( stmtstat = sschema->stmtstat[i] ) != NULL )
			{
				output_func("%s\n", indent_str); 
				output_func("%s\tschname:'%s' stmt_id:%d ", 
					indent_str, STRING(stmtstat->schname), stmtstat->stmt_id);
				RIScom_state_string(stmtstat->state, string);
				output_func("state:%s\n",string);
				if( stmtstat->risca )
				{
					RIScom_output_rissqlca(output_func, stmtstat->risca, 
							indent+1);
				}
				if( stmtstat->dbca )
				{
					RIScom_output_rissqlca(output_func, stmtstat->dbca, 
							indent+1);
				}
			}
			else
			{
				output_func("%sNot assigned.\n", indent_str);
			}
		}
	}
}

/****************************************************************************/

extern void RIScom_output_superschema_info(
	int             (* output_func)(const char *, ...),
	void    *ptr,
	int             indent)
{
	char                    indent_str[MAX_INDENT_SIZE];
	risschema               *schema;
	rissuperschema  *sschema = ptr;

	if (sschema)
	{
		LOAD_INDENT_STRING(indent, indent_str);

		output_func("%sschname:'%s' ssid:%d\n",
			indent_str, STRING(sschema->schname), sschema->ssid);
		output_func("%s\tSubschemas::\n", indent_str); 
		for( schema = sschema->sub_schp; schema; schema = schema->sub_schp )
		{
			output_func("%s\tschname:'%s' superschema_flag: %d\n", indent_str, 
				STRING(schema->schname), schema->superschema_flag);
		}
	}
}

/****************************************************************************/

extern void RIScom_output_db(
	int             (* output_func)(const char *, ...),
	void    *ptr,
	int             indent)
{
	int             i;
	char    indent_str[MAX_INDENT_SIZE];
	risdb   *db = ptr;

	if (db)
	{
		LOAD_INDENT_STRING(indent, indent_str);

		output_func("%sdbname:%s\n", indent_str, db->dbname);
		for (i=0; i<RIS_MAX_PROTOCOLS && db->pathways[i].protocol; ++i)
		{
			output_func("%sprotocol:%c  netaddr:%s\n",
				indent_str, db->pathways[i].protocol, db->pathways[i].netaddr);
		}
		output_func("%sdtype:%c dbid:%hu\n", indent_str, db->dtype, db->dbid);
		output_func("%sostype:%c\n", indent_str, db->ostype);
		switch(db->dtype)
		{
			case 'X':
				output_func("%sdir:<%s>\n", indent_str,
					db->parms.ifx.dir);
				output_func("%ssqlexec:<%s>\n", indent_str,
					db->parms.ifx.sqlexec);
				output_func("%sdbtemp:<%s>\n", indent_str,
					db->parms.ifx.dbtemp);
				output_func("%stbconfig:<%s>\n", indent_str,
					db->parms.ifx.tbconfig);
				break;

			case 'O':
				output_func("%sosuser:<%s>\n",indent_str, db->parms.ora.osuser);
				output_func("%sospass:<%s>\n",indent_str, db->parms.ora.ospass);
				output_func("%sdir:<%s>\n", indent_str, db->parms.ora.dir);
				break;

			case 'I':
				output_func("%sdir:<%s>\n", indent_str, db->parms.igs.dir);
				break;

			case 'D':
				output_func("%sosuser:<%s>\n",indent_str, db->parms.db2.osuser);
				output_func("%sospass:<%s>\n",indent_str, db->parms.db2.ospass);
				output_func("%sarch:<%s>\n", indent_str, db->parms.db2.arch);
				output_func("%sos:<%s>\n", indent_str, db->parms.db2.os);
				output_func("%senv:<%s>\n", indent_str, db->parms.db2.env);
				output_func("%snet_protocol:<%s>\n", indent_str,
					db->parms.db2.net_protocol);
				output_func("%shost_program:<%s>\n", indent_str,
					db->parms.db2.host_program);
				output_func("%sris_lu:<%s>\n", indent_str,
					db->parms.db2.ris_lu);
				output_func("%shost_lu:<%s>\n", indent_str,
					db->parms.db2.host_lu);
				output_func("%smode:<%s>\n", indent_str, db->parms.db2.mode);
				output_func("%sgroup:<%s>\n", indent_str, db->parms.db2.group);
				output_func("%snode:<%s>\n", indent_str, db->parms.db2.node);
				output_func("%sport:<%d>\n", indent_str, db->parms.db2.port);
				break;

			case 'R':
				break;

			case 'Y':
				output_func("%sosuser:<%s>\n",indent_str, db->parms.syb.osuser);
				output_func("%sospass:<%s>\n",indent_str, db->parms.syb.ospass);
				output_func("%sdir:<%s>\n", indent_str, db->parms.syb.dir);
				output_func("%sdsquery:<%s>\n", indent_str,
					db->parms.syb.dsquery);
				output_func("%sifile:<%s>\n", indent_str,
					db->parms.syb.sybifile);
				break;

            case 'M':
                output_func("%sosuser:<%s>\n",indent_str, db->parms.mssql.osuser);
                output_func("%sospass:<%s>\n",indent_str, db->parms.mssql.ospass);
                output_func("%sdir:<%s>\n", indent_str, db->parms.mssql.dir);
                output_func("%sdsquery:<%s>\n", indent_str,
                    db->parms.mssql.dsquery);
                output_func("%sifile:<%s>\n", indent_str,
                    db->parms.mssql.mssqlifile);
                break;

		}
	}
}
	
/****************************************************************************/

extern void RIScom_output_db_info(
	int             (* output_func)(const char *, ...),
	void    *ptr,
	int             indent)
{
	int                     i;
	char            indent_str[MAX_INDENT_SIZE];
	ris_db_info     *db = ptr;

	if (db)
	{
		LOAD_INDENT_STRING(indent, indent_str);

		output_func("%sdbid           : %hu\n", indent_str, db->dbid);
		output_func("%sdtype          : '%c'\n", indent_str, db->dtype);
		output_func("%sdbname         : '%s'\n", indent_str, db->dbname);
		output_func("%sostype         : '%c'\n", indent_str, db->ostype);
		for (i=0; i<RIS_MAX_PROTOCOLS && db->pathways[i].protocol; ++i)
		{
			output_func("%sprotocol[%d]    : '%c'\n", indent_str, i,
				db->pathways[i].protocol);
			output_func("%snetaddr[%d]     : '%s'\n", indent_str, i,
				db->pathways[i].netaddr);
		}
		switch(db->dtype)
		{
			case 'X':
				output_func("%sdir            : '%s'\n", indent_str,
					db->info.ifx.dir);
				output_func("%ssqlexec        : '%s'\n", indent_str,
					db->info.ifx.sqlexec);
				output_func("%sdbtemp         : '%s'\n", indent_str,
					db->info.ifx.dbtemp);
				output_func("%stbconfig       : '%s'\n", indent_str,
					db->info.ifx.tbconfig);
				break;

			case 'O':
				output_func("%sosuser         : '%s'\n", indent_str,
					db->info.ora.osuser);
				output_func("%sospass         : '%s'\n", indent_str,
					db->info.ora.ospass);
				output_func("%sdir            : '%s'\n", indent_str,
					db->info.ora.dir);
				break;

			case 'I':
				output_func("%sdir            : '%s'\n", indent_str,
					db->info.igs.dir);
				break;

			case 'D':
				output_func("%sosuser         : '%s'\n", indent_str,
					db->info.db2.osuser);
				output_func("%sospass         : '%s'\n", indent_str,
					db->info.db2.ospass);
				output_func("%sarch           : '%s'\n", indent_str,
					db->info.db2.arch);
				output_func("%sos             : '%s'\n", indent_str,
					db->info.db2.os);
				output_func("%senv            : '%s'\n", indent_str,
					db->info.db2.env);
				output_func("%snet_protocol   : '%s'\n", indent_str,
					db->info.db2.net_protocol);
				output_func("%shost_program   : '%s'\n", indent_str,
					db->info.db2.host_program);
				output_func("%sris_lu         : '%s'\n", indent_str,
					db->info.db2.ris_lu);
				output_func("%shost_lu        : '%s'\n", indent_str,
					db->info.db2.host_lu);
				output_func("%smode           : '%s'\n", indent_str,
					db->info.db2.mode);
				output_func("%sgroup          : '%s'\n", indent_str,
					db->info.db2.group);
				output_func("%snode           : '%s'\n", indent_str,
					db->info.db2.node);
				output_func("%sport           : '%d'\n", indent_str,
					db->info.db2.port);
				break;

			case 'R':
				break;

			case 'Y':
				output_func("%sosuser         : '%s'\n", indent_str,
					db->info.syb.osuser);
				output_func("%sospass         : '%s'\n", indent_str,
					db->info.syb.ospass);
				output_func("%sdir            : '%s'\n", indent_str,
					db->info.syb.dir);
				output_func("%sdsquery        : '%s'\n", indent_str,
					db->info.syb.dsquery);
				output_func("%sifile          : '%s'\n", indent_str,
					db->info.syb.sybifile);
				break;

            case 'M':
                output_func("%sosuser         : '%s'\n", indent_str,
                    db->info.mssql.osuser);
                output_func("%sospass         : '%s'\n", indent_str,
                    db->info.mssql.ospass);
                output_func("%sdir            : '%s'\n", indent_str,
                    db->info.mssql.dir);
                output_func("%sdsquery        : '%s'\n", indent_str,
                    db->info.mssql.dsquery);
                output_func("%sifile          : '%s'\n", indent_str,
                    db->info.mssql.mssqlifile);
                break;

		}
	}
}

/******************************************************************************/

extern void RIScom_output_table_info(
	int             (* output_func)(const char *, ...),
	void    *ptr,
	int             indent)
{
	char            indent_str[MAX_INDENT_SIZE];
	risattr         *attr;
	risaccess       *acc;
	ristab          *tab = ptr;

	if (tab)
	{
		LOAD_INDENT_STRING(indent, indent_str);

		output_func("%stabname:%s  tabtype:%c\n",
			indent_str, tab->tabname, tab->tabtype ? tab->tabtype:' ');
		output_func("%sschema:0x%x  schname:%s\n",
			indent_str, tab->schema, tab->schema?tab->schema->schname:"");
		if (tab->tab)
		{
			output_func("%saliased table:0x%x\n", indent_str, tab->tab);
			RIScom_output_table(output_func, tab->tab, indent+1);
		}
		for( acc = tab->acc; acc; acc = acc->next )
		{
			RIScom_output_acc(output_func, acc, indent+1);
		}
		for( attr = tab->attr; attr; attr = attr->next )
		{
			output_func("%sattributes\n", indent_str);
			RIScom_output_attr(output_func, attr, indent+1);
			for( acc = attr->acc; acc; acc = acc->next )
			{
				RIScom_output_acc(output_func, acc, indent+2);
			}
		}
	}
}

/******************************************************************************/

extern void RIScom_output_table(
	int             (* output_func)(const char *, ...),
	void    *ptr,
	int             indent)
{
	char    indent_str[MAX_INDENT_SIZE];
	ristab  *tab = ptr;

	if (tab)
	{
		LOAD_INDENT_STRING(indent, indent_str);

		output_func("%stabname:%s  tabtype:%c\n",
			indent_str, tab->tabname, tab->tabtype ? tab->tabtype:' ');
		if (RIStree_debug)
		{
			output_func("%sschema:0x%x  schname:%s\n",
				indent_str, tab->schema, tab->schema?tab->schema->schname:"");
			if (tab->tab)
			{
				output_func("%saliased table:0x%x\n", indent_str, tab->tab);
				RIScom_output_table(output_func, tab->tab, indent+1);
			}
		}
	}
}

/****************************************************************************/

extern void RIScom_output_attr(
	int             (* output_func)(const char *, ...),
	void    *ptr,
	int             indent)
{
	char    indent_str[MAX_INDENT_SIZE];
	risattr *attr = ptr;

	if (attr)
	{
		LOAD_INDENT_STRING(indent, indent_str);

		output_func("%sattrname:%s extern_attrname %s tabname:%s extern_tabname %s\n",
			indent_str, STRING(attr->attrname),
			STRING(attr->extern_attrname),
			attr->tab ? STRING(attr->tab->tabname) : "",
			attr->tab ? STRING(attr->tab->extern_tabname) : "");
		output_func("%satype:%s  asize:%u", indent_str,
			RIS_types[ATTR_TYPE(attr->atype)].string, attr->asize.len);
		if (ATTR_TYPE(attr->atype) == RIS_DECIMAL)
		{
			output_func("prec:%u  scale:%u  ", attr->asize.dec.prec,
				attr->asize.dec.scale);
		}
		output_func(" nulls:%s\n",ATTR_FLAG((int)attr->atype) ? "YES" : "NO");
		output_func("%sdbsqltype:%d  dbsqllen:%d\n", 
				indent_str, attr->dbsqltype, attr->dbsqllen);
	}
}

/****************************************************************************/

extern void RIScom_output_attr_info(
	int             (* output_func)(const char *, ...),
	void    *ptr,
	int             indent)
{
	char                    indent_str[MAX_INDENT_SIZE];
	ris_attr_info   *attr = ptr;

	if (attr)
	{
		LOAD_INDENT_STRING(indent, indent_str);

		output_func("%sattrname:%s extern_attrname\n", 
			indent_str, STRING(attr->attrname), STRING(attr->extern_attrname));
		output_func("%satype:%s  asize:%u", indent_str,
			RIS_types[ATTR_TYPE(attr->atype)].string, attr->asize.len);
		if (ATTR_TYPE(attr->atype) == RIS_DECIMAL)
		{
			output_func("prec:%u  scale:%u  ", attr->asize.dec.prec,
				attr->asize.dec.scale);
		}
		output_func(" nulls:%s\n",ATTR_FLAG((int)attr->atype) ? "YES" : "NO");
	}
}

/****************************************************************************/

extern void RIScom_output_sqlvar(
	int             (* output_func)(const char *, ...),
	void    *ptr,
	int             indent)
{
	char    indent_str[MAX_INDENT_SIZE];
	char    sqlnamec[RIS_MAX_ID_SIZE];
	sqlvar  *var = ptr;

	if (var)
	{
		LOAD_INDENT_STRING(indent, indent_str);

		output_func("%ssqltype:%s  sqllen:%d",
			indent_str, RIS_types[var->sqltype].string, var->sqllen);
		if (var->sqltype == RIS_DECIMAL)
			output_func("  sqlscale = %d", var->sqlscale);
		output_func("  sqlnull = %d\n", var->sqlnull);

		RIScom_strncpy(sqlnamec, var->sqlname.sqlnamec, var->sqlname.sqlnamel);
		if (var->sqlname.sqlnamel<RIS_MAX_ID_SIZE-1)
		{
			sqlnamec[var->sqlname.sqlnamel] = '\0';
		}
		else
		{
			sqlnamec[RIS_MAX_ID_SIZE-1] = '\0';
		}
		output_func("%ssqlnamel:%d sqlnamec:<%s>\n",
			indent_str,  var->sqlname.sqlnamel, 
			sqlnamec);
		output_func("%ssqldata:0x%x sqlind:0x%x\n",
			indent_str, var->sqldata, var->sqlind);
	}
}

/******************************************************************************/

extern void RIScom_output_sql_query(
	int             (* output_func)(const char *, ...),
	void    *ptr,
	int             indent)
{
	char    indent_str[MAX_INDENT_SIZE];
	rissql  *sql = ptr;

	if (sql)
	{
		LOAD_INDENT_STRING(indent, indent_str);
		output_func("%squery:<%s>\n", indent_str, sql->query);
	}
}

/******************************************************************************/

extern void RIScom_output_datetime(
	int             (* output_func)(const char *, ...),
	void    *ptr)
{
	char    index,start,stop;
	dtime   *dtp = ptr;

	if (dtp)
	{
		output_func("TIMESTAMP '");

		start = DT_YEAR;
		stop = DT_SECOND;
		for (index = start; index >= stop; index--)
		{
			output_func("%02d",dtp->data[index]);
			if (index > stop)
				output_func("%c",RIScom_dtseparator(index));
		}
		
		output_func("'");
	}
}

/******************************************************************************/

extern void RIScom_output_blob(
	int		(* output_func)(const char *, ...),
	void	*ptr)
{
	char	indent_str[MAX_INDENT_SIZE];
	ris_blob	*blob_field = (ris_blob *) ptr;

	if (blob_field)
	{
		LOAD_INDENT_STRING(2, indent_str);
		output_func("%sblob :\n", indent_str);

		output_func("%sThe address of array: 0x%x\n",indent_str,
													&blob_field->array);
		output_func("%sarray_size: %d\n",indent_str, blob_field->array_size);
		output_func("%soutput_len: %d\n",indent_str, blob_field->output_len);
		output_func("%sinput_len: %d\n",indent_str, blob_field->input_len);
		output_func("%sfile_offset: %d\n",indent_str, blob_field->file_offset);
		output_func("%sfile_used: %d\n",indent_str, blob_field->file_used);
	}
}
/******************************************************************************/

static void output_tree(
	int             (* output_func)(const char *, ...),
	void    *ptr,
	int             indent,
	char    side)
{
	char            indent_str[MAX_INDENT_SIZE];
	risaccess       *acc;
	ristree         *tp = (ristree *)ptr;

	if (!tp) return;

	if (tp->tok == RIS_TOK_LIST)
	{
		output_tree(output_func, tp->lhs,indent,'l');
		output_tree(output_func, tp->rhs,indent,'r');
	}
	else
	{
		LOAD_INDENT_STRING(indent, indent_str);
		if (indent)
		{
			output_func("%d%c%s", indent, side, indent_str);
		}

		if (RIStree_debug) output_func("tp:0x%x  ", tp);
		output_func("tok:%s  ", RIScom_get_token_name(tp->tok));
		output_func("pos:%d  ", tp->pos);
		switch(tp->tok)
		{
			case RIS_TOK_GRANT:
			case RIS_TOK_REVOKE:
				output_func("\n");
				for (acc = tp->info.access; acc; acc = acc->next)
				{
					output_func("%saccess:", indent_str);
					if (RIStree_debug)
						output_func("0x%x\n", acc);
					else
						output_func("\n");
					RIScom_output_acc(output_func, acc, indent + 1);
				}
				break;

			case RIS_TOK_CREATE_SCHEMA:
			case RIS_TOK_DROP_SCHEMA:
				output_func("\n%sschema:", indent_str);
				if (RIStree_debug)
					output_func("0x%x\n", tp->info.schema);
				else
					output_func("\n");
				if (tp->info.schema)
				{
					RIScom_output_schema(output_func, tp->info.schema,
						indent + 1);

					output_func("%s\tdb:", indent_str);
					if (RIStree_debug)
						output_func("0x%x\n", tp->info.schema->db);
					else
						output_func("\n");
					RIScom_output_db(output_func, tp->info.schema->db,
						indent + 2);
				}
				break;
			
			case RIS_TOK_TABLE:
				output_func("\n%stable:", indent_str);
				if (RIStree_debug)
					output_func("0x%x\n", tp->info.tab);
				else
					output_func("\n");
				RIScom_output_table(output_func, tp->info.tab, indent + 1);
				if (RIStree_debug)
				{
					for (acc = tp->info.tab->acc; acc; acc = acc->next)
					{
						output_func("%s\taccess:0x%x\n", indent_str, acc);
						RIScom_output_acc(output_func, acc, indent + 2);
					}
				}
				break;

			case RIS_TOK_ATTR:
				output_func("\n%sattr:", indent_str);
				if (RIStree_debug)
					output_func("0x%x\n", tp->info.attr);
				else
					output_func("\n");
				RIScom_output_attr(output_func, tp->info.attr, indent + 1);
				if (RIStree_debug)
				{
					for (acc = tp->info.attr->acc; acc; acc = acc->next)
					{
						output_func("%s\taccess:0x%x\n", indent_str, acc);
						RIScom_output_acc(output_func, acc, indent + 2);
					}
				}
				break;

			case RIS_TOK_PARAMETER:
				output_func("\n%ssqlvar:", indent_str);
				if (RIStree_debug)
					output_func("0x%x\n", tp->info.data);
				else
					output_func("\n");
				RIScom_output_sqlvar(output_func, tp->info.data, indent + 1);
				break;

			case RIS_TOK_PLUS:
			case RIS_TOK_SUB:
			case RIS_TOK_MUL:
			case RIS_TOK_DIV:
			case RIS_TOK_UNARYMINUS:
			case RIS_TOK_COUNT:
			case RIS_TOK_AVG:
			case RIS_TOK_SUM:
			case RIS_TOK_MAX:
			case RIS_TOK_MIN:
				output_func("\n%sattr:", indent_str);
				if (RIStree_debug)
					output_func("0x%x\n", tp->info.attr);
				else
					output_func("\n");
				RIScom_output_attr(output_func, tp->info.attr, indent + 1);
				if (RIStree_debug)
				{
					for (acc = tp->info.attr->acc; acc; acc = acc->next)
					{
						output_func("%s\taccess:0x%x\n", indent_str, acc);
						RIScom_output_acc(output_func, acc, indent + 2);
					}
				}
				break;

			case RIS_TOK_TIMESTAMP_LIT:
				if (tp->info.val)
				{
					output_func("val: ");
					if (isprint(*tp->info.val))
						output_func(tp->info.val);
					else
						RIScom_output_datetime(output_func,
							(dtime *)tp->info.val);
				}
				output_func("\n");
				break;

			default:
				if (tp->info.val)
					output_func("val: %s\n",tp->info.val);
				else
					output_func("\n");
				break;
		}

		if (tp->tok != RIS_TOK_TABLE || RIStree_debug)
		{
			output_tree(output_func, tp->lhs, indent + 1, 'l');
			output_tree(output_func, tp->rhs, indent + 1, 'r');
		}
	}
}

/******************************************************************************/

extern void RIScom_output_tree(
	int             (* output_func)(const char *, ...),
	void    *ptr)
{
	ristree *tp = ptr;

	output_func("\n");
	output_tree(output_func, tp, 0, 'h');
}

/******************************************************************************/

extern void RIScom_output_alloc_info(
	int             (* output_func)(const char *, ...),
	void    *ptr,
	int             indent)
{
	char                    indent_str[MAX_INDENT_SIZE];
	ris_alloc_info  *info = ptr;

	if (info)
	{
		LOAD_INDENT_STRING(indent, indent_str);

		output_func("%sblk:0x%x end:0x%x\n", indent_str, info->blk, info->end);
		output_func("%spos:0x%x avail:%d \n",
			indent_str, info->pos, info->avail);
	}
}

/******************************************************************************/

extern void RIScom_output_block_info(
	int             (* output_func)(const char *, ...),
	void    *ptr,
	int             indent)
{
	char                    indent_str[MAX_INDENT_SIZE];
	ris_block_info  *info = ptr;

	if (info)
	{
		LOAD_INDENT_STRING(indent, indent_str);

		output_func("%smalloc_flag:%d mark:%d count:%d\n", indent_str,
			info->malloc_flag, info->mark, info->count);
		output_func("%snext:0x%x", indent_str, info->next);
		if ((char *)info + RIS_BLOCK_SIZE + sizeof(ris_block_info) ==
			(char *)info->next)
		{
			output_func(" -- contiguous\n");
		}
		else
		{
			output_func("\n");
		}
	}
}

/******************************************************************************/

extern void RIScom_output_data(
	int             (* output_func)(const char *, ...),
	int             count,
	void    *ptr,
	char    *data,
	int             indent)
{
	int             i;
	int             sqllen  = 0;
	int             sqltype = 0;
	int             indicator = 0;
	char    indent_str[MAX_INDENT_SIZE];
	sqlvar  *var = ptr;

	LOAD_INDENT_STRING(indent, indent_str);

	RIS_ALIGN(sizeof(double),data);

	for (i = 0; i < count; ++i)
	{
		sqltype = (int)var[i].sqltype;
		sqllen  = (int)var[i].sqllen;

		/*
		** We must always align data based on its data type.
		** Since the 'integer' indicator gets aligned here, the only
		** other data type that needs alignment will be the 'double'.
		*/
		RIS_ALIGN(sizeof(int),data);

		indicator = *(int *)data;
		output_func("%scol %d: indicator:%d data:", indent_str, i, indicator);

		/*
		** properly increment the pointer
		*/
		data += sizeof(int);
		if (indicator < 0)
		{
			output_func("NULL\n");
			/*
			** When the data type is a DOUBLE we need to 
			** align the pointer -data- so that it is properly 
			** data for adding the sqllen at the end of
			** the loop.
			*/
			if (sqltype == RIS_DOUBLE)
			{
				RIS_ALIGN(sizeof(double),data);
			}
		}
		else
		{
			switch (sqltype)
			{
				case RIS_CHARACTER:
					output_func("CHARACTER:<%s>\n", data);
					break;

				case RIS_DECIMAL:
					output_func("DECIMAL:<%s>\n", data);
					break;

				case RIS_DATETIME:
					RIScom_output_datetime(output_func, (dtime *)data);
					output_func("\n");
					break;

				case RIS_DOUBLE:
					RIS_ALIGN(sizeof(double),data);
					output_func("DOUBLE:%f\n", *(double *)data);
					break;

				case RIS_INTEGER:
					output_func("INTEGER:%d\n", *(int *)data);
					break;

				case RIS_REAL:
					output_func("REAL:%f\n", *(float *)data);
					break;

				case RIS_SMALLINT:
					output_func("SMALLINT:%d\n", *(short *)data);
					break;

                case RIS_TEXT:
                case RIS_BLOB:
                    RIScom_output_blob( output_func, data);
                    break;

				default:
					output_func("UNKNOWN DATA TYPE:%d", sqltype);
					break;
			}
		}

		/*
		** properly increment the pointer
		** we have some special rules here...
		*/
		if (sqltype == RIS_DECIMAL && sqllen < RIS_types[RIS_DOUBLE].sqllen)
		{
			/*
			**  INGRES always needs room for a double so do it here for
			**  all databases.
			*/
			data += RIS_types[RIS_DOUBLE].sqllen;
		}
		else
		{
			data += sqllen;
		}
		if (sqltype == RIS_CHARACTER || sqltype == RIS_DECIMAL)
		{
			data++;	/* move pointer passed the null byte */
		}
	}
}

/******************************************************************************/

extern void RIScom_output_server(
	int             (* output_func)(const char *, ...),
	void    *ptr,
	int             indent)
{
	char            indent_str[MAX_INDENT_SIZE];
	risschema       *schema = ptr;

	if (schema)
	{
		LOAD_INDENT_STRING(indent, indent_str);

		output_func("%sschname:<%s> schpass:<%s> schema dbid:%d sschflag:%d\n",
			indent_str, schema->schname, schema->schpass, schema->dbid,
			schema->superschema_flag);

		output_func("%sschowner:<%s> passwd:<%s>\n", indent_str, schema->schowner,
			schema->passwd);

		output_func("%sdbname:<%s> dtype:<%c> dbid:%d\n",  indent_str,
			schema->db->dbname,schema->db->dtype, schema->db->dbid);

		output_func("%snetaddr:<%s> protocol:<%c>\n", indent_str,
			schema->db->pathways[0].netaddr, schema->db->pathways[0].protocol);

		switch(schema->net->protocol)
		{
			case SHMEM:
				output_func("%spid:%d  semnum:%d\n", indent_str,
					schema->net->id.shmem.pid, schema->net->id.shmem.semnum);
				break;

			case LU62:
				output_func("%slcbp->lu62cvid: %d\n", indent_str,
					*(short*)schema->net->id.lu62.lcbp);
				break;

			case DNP:
				output_func("%slogical link: %d\n", indent_str,
					schema->net->id.dnp.logical_link);
				break;

			case XNS:
				output_func("%ssni_d:%d\n", indent_str,
					schema->net->id.xns.sni_d);
				break;

			case TCP:
				output_func("%ssocket:%d\n", indent_str,
					schema->net->id.tcp.user.socket);
				break;

			default:
				output_func("%sUnknown net protocol:%d\n", indent_str,
					schema->net->protocol);
				break;
		}
	}
}

/******************************************************************************/

extern void RIScom_output_rissqlca(
	int             (* output_func)(const char *, ...),
	void    *ptr,
	int             indent)
{
	char            indent_str[MAX_INDENT_SIZE];
	rissqlca        *sqlca = ptr;

	if (sqlca)
	{
		LOAD_INDENT_STRING(indent, indent_str);
		output_func("%ssqlcode:%d\n", indent_str, sqlca->sqlcode);
		output_func("%ssqlerrml:%d\n", indent_str, sqlca->sqlerrm.sqlerrml);
		output_func("%ssqlerrmc:<%s>\n", indent_str,
			STRING(sqlca->sqlerrm.sqlerrmc));
		output_func("%ssqlstmt:<%s>\n", indent_str, STRING(sqlca->sqlstmt));
	}
}

/******************************************************************************/

static void RIScom_state_string(
	short state,
	char  *string)
{
	switch(state)
	{
		case SELECT_INTO_STATE:
			strcpy(string,"SELECT_INTO_STATE");
		break;
		case EXECUTE_IMM_STATE:
			strcpy(string,"EXECUTE_IMM_STATE");
		break;
		case EXECUTE_STATE:
			strcpy(string,"EXECUTE_STATE");
		break;
		case FETCH_STATE:
			strcpy(string,"FETCH_STATE");
		break;
		case CLOSE_STATE:
			strcpy(string,"CLOSE_STATE");
		break;
		case CLEAR_STATE:
			strcpy(string,"CLEAR_STATE");
		break;
		case COMPLETE_ERROR_STATE:
			strcpy(string,"COMPLETE_ERROR_STATE");
		break;
		case COMPLETE_EOD_STATE:
			strcpy(string,"COMPLETE_EOD_STATE");
		break;
		case COMPLETE_SUCCESS_STATE:
			strcpy(string,"COMPLETE_SUCCESS_STATE");
		break;
		default:
			strcpy(string,"UNKNOWN STATE");
		break;
	}
}

/******************************************************************************/
