/*
**	NAME:							sqltable.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**		10/24/94 -Radha
**			Added changes for MSSQL data server
*/
 
/*
**	INCLUDES
*/
#include "riscl_sr.h"
#include "riscom.h"
#include "ristoken.h"
#include "ristypes.h"
#include "rissql.h"
#include "riscli.h"

/*
**	FUNCTION PROTOTYPES
*/
#define sqltable_c
#include "sqltable.prt"
#include "sys.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "sqlmisc.prt"
#include "comstrcp.prt"



/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISsql_create_table(
	ristree	*tp,
	rissql	*sql)
{
	SQL_DBG(("RISsql_create_table tp = 0x%x sql = 0x%x\n",tp,sql));

	CONSTADD("create table ");
	tp = tp->rhs;

	strcpy(sql->ris_relname, tp->info.tab->tabname);
	strcpy(sql->ext_relname, tp->info.tab->extern_tabname);

    if (sql->schema->db->dtype == '4' )
    {
		STRADD(sql->schema->db->dbname);
   		CONSTADD("/");
	}
 

	STRADD(tp->info.tab->extern_tabname);

	CONSTADD("(");
	for (tp = tp->rhs; tp; tp = tp->rhs)
	{
		RISsql_add_column(tp->lhs->info.attr, sql->schema->db);
		if (tp->rhs)
		{
			CONSTADD(", ");
		}
	}

	CONSTADD(")");
	if (sql->schema->db->dtype == 'D')
	{
		CONSTADD(" in database ");
		STRADD(sql->schema->db->dbname);
	}
}

/******************************************************************************/

extern void RISsql_alter_table(
	ristree	*tp,
	rissql	*sql)
{

SQL_DBG(("RISsql_alter_table tp = 0x%x sql = 0x%x\n",tp,sql));

	CONSTADD("alter table ");
	STRADD(tp->rhs->info.tab->extern_tabname);
	switch (sql->schema->db->dtype)
	{
		case 'O':
		case 'X':
		case 'I':
			CONSTADD(" add(");
			RISsql_add_column(tp->lhs->rhs->info.attr,sql->schema->db);
			CONSTADD(")");
		break;
		case 'D':
		case '4':
		case 'R':
		case 'Y':
		case 'M':
			CONSTADD(" add ");
			RISsql_add_column(tp->lhs->rhs->info.attr,sql->schema->db);
		break;
		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
		break;
	}
}

/******************************************************************************/

extern void RISsql_drop_table(
	ristree	*tp,
	rissql	*sql)
{

SQL_DBG(("RISsql_drop_table tp = 0x%x sql = 0x%x\n",tp,sql));

	strcpy(sql->ris_relname, tp->rhs->info.tab->tabname);
	strcpy(sql->ext_relname, tp->rhs->info.tab->extern_tabname);
	strcpy(sql->relowner, tp->rhs->info.tab->tabowner);

	CONSTADD("drop table ");
    if (sql->schema->db->dtype == '4' )
    {
		STRADD(tp->rhs->info.tab->tabowner);
   		CONSTADD("/");
	}
	STRADD(tp->rhs->info.tab->extern_tabname);

	if (sql->schema->db->dtype == 'R')
	{
		CONSTADD(" cascade");
	}
}

/******************************************************************************/

static void RISsql_add_column(
	risattr	*attr,
	risdb	*db)
{
	char	size_buf[10];

SQL_DBG(("RISsql_add_column attr = 0x%x db = 0x%x\n",attr,db));
	if(*attr->extern_attrname=='\0')
	{
		if (strlen(attr->attrname) > 10 && db->dtype == '4')
		{
			LONGJMP(RIS_E_NAME_TOO_LONG); 
		}	
		else
		{	
			RIScom_strcpy(attr->extern_attrname,attr->attrname);	
		}	
	}

    STRADD(attr->extern_attrname);
	CONSTADD(" ");
	switch (db->dtype)
	{
		case 'O':
			STRADD(RIS_types[ATTR_TYPE(attr->atype)].ora_string);
		break;
		case 'X':
			if (ATTR_TYPE(attr->atype) == RIS_DATETIME)
			{
				CONSTADD("datetime year to second");
			}
			else
			{
				STRADD(RIS_types[ATTR_TYPE(attr->atype)].ifx_string);
			}
		break;
		case 'I':
			STRADD(RIS_types[ATTR_TYPE(attr->atype)].igs_string);
		break;
		case 'D':
			STRADD(RIS_types[ATTR_TYPE(attr->atype)].db2_string);
		break;
		case '4':
			STRADD(RIS_types[ATTR_TYPE(attr->atype)].os400_string);
		break;
		case 'R':
			STRADD(RIS_types[ATTR_TYPE(attr->atype)].rdb_string);
		break;
		case 'Y':
			STRADD(RIS_types[ATTR_TYPE(attr->atype)].syb_string);
		break;
		case 'M':
			STRADD(RIS_types[ATTR_TYPE(attr->atype)].mssql_string);
		break;
		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
		break;
	}
	if (ATTR_TYPE(attr->atype) == RIS_CHARACTER)
	{
		CONSTADD("(");

		sprintf(size_buf, "%d", attr->asize.len);
		STRADD(size_buf);

		CONSTADD(")");
	}
    else if  (ATTR_TYPE(attr->atype) == RIS_TEXT    ||
                ATTR_TYPE(attr->atype) == RIS_BLOB  )
    {

        if (db->dtype != 'O' && db->dtype != 'X' )
        {
            /*
                blob/text are treated as char for all dbms except
                informix & oracle
            */

            CONSTADD("(");

            sprintf(size_buf, "%d", attr->asize.len);
            STRADD(size_buf);

            CONSTADD(")");
		}

        if (db->dtype == 'D' || db->dtype == '4' || db->dtype == 'Y' 
				|| db->dtype == 'M' )
        {
			/* DB2 needs to specify FOR BIT DATA for blob data 
			sprintf(size_buf, " FOR BIT DATA ");
			STRADD(size_buf);
			RIS is not supportting BLOB/TEXT for V. 5 release.
			 
			*/
			LONGJMP(RIS_E_UNSUPPORTED_DATATYPE);
		}
	}
	else if (ATTR_TYPE(attr->atype) == RIS_DECIMAL)
	{
		/*
		** Don't add a size specification for INGRES and SYBASE
		*/
		if (db->dtype != 'I'/* && db->dtype != 'Y'*/ && db->dtype != 'M')
		{
			CONSTADD("(");

			sprintf(size_buf, "%d", attr->asize.dec.prec);
			STRADD(size_buf);

			CONSTADD(",");

			sprintf(size_buf, "%d", attr->asize.dec.scale);
			STRADD(size_buf);

			CONSTADD(")");
		}
	}
	if (!NULLS_ALLOWED(attr->atype))
	{
		if (db->dtype != 'Y' && db->dtype != 'M')
		{
			CONSTADD(" not null");
		}
		if (db->dtype == 'D')
		{
			CONSTADD(" with default");
		}
	}
	else
	{
		if (db->dtype == 'Y' || db->dtype == 'M')
		{
			CONSTADD(" null");
		}
	}
}

/******************************************************************************/

extern void RISsql_lock_table(
	ristree *tp,
	rissql *sql)
{
	ristree *modep;
	ristree *tablep;

SQL_DBG(("RISsql_lock_table tp = 0x%x sql = 0x%x\n",tp,sql));

	for (modep = tp->rhs; modep; modep = modep->rhs)
	{
		switch(modep->lhs->tok)
		{
			case RIS_TOK_SHARE:
				CONSTADD(" 1");
			break;

			case RIS_TOK_EXCLUSIVE:
				CONSTADD(" 2");
			break;

			case RIS_TOK_DEFAULT:
				CONSTADD(" 3");
			break;

			default:
				LONGJMP(RIS_E_INTERNAL_ERROR);
			break;
		}

		for (tablep = modep->lhs->rhs; tablep; tablep = tablep->rhs)
		{
			CONSTADD(" ");
			STRADD(tablep->lhs->info.tab->extern_tabname);
		}
	}
}

/******************************************************************************/
