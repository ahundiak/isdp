/*
**	NAME:							sqlmisc.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**		Miscellaneous functions for sql sub-project.
**	
**	REVISION HISTORY:
**		modified RISsql_add_dict_tab_condition() and extended tabinfo
**		for v5 dictionary tables by Jin Jing 12/06/93
**
**		add RISsql_table_alias_id() for OS400 auto corelation id
**		generation by Jin Jing 03/02/94
**
**		add the following functions (5) for sql source cleanup and 
**		consolidation by Jin Jing 03/11/94:
**			RISsql_get_tabid()
**			RISsql_add_tab_qualification()
**			RISsql_add_attr_qualification()
**			RISsql_add_table()
**			RISsql_add_attr()
**		10/24/94 -Radha
**			Added changes for MSSQL data server.
*/
 
/*
**	INCLUDES
*/
#include "riscli.h"
#include "risdict.h"
#include "riscom.h"
#include "rismem.h"
#include "rissql.h"

/*
**	FUNCTION PROTOTYPES
*/
#define sqlmisc_c
#include "comdict.prt"
#include "comdebug.prt"
#include "comalloc.prt"
#include "comjmp.prt"
#include "comrealc.prt"
#include "sqlmisc.prt"
#include "sys.prt"



/*
**	DEFINES
*/

/*
**	VARIABLES
*/
static char *rdb_month_list[] = {
        "",
        "JAN",
        "FEB",
        "MAR",
        "APR",
        "MAY",
        "JUN",
        "JUL",
        "AUG",
        "SEP",
        "OCT",
        "NOV",
        "DEC"
};

/*
**	FUNCTIONS
*/


/******************************************************************************/

extern void RISsql_add_timestamp(
	rissql	*sql,
	dtime	*dtp)
{
	char buf[5];

	switch(sql->schema->db->dtype)
	{
		case 'X':
			CONSTADD("datetime(");
			break;

		case 'O':
			CONSTADD("to_date('");
			break;

		case 'I':
			CONSTADD("date('");
			break;

		case 'D':
		case '4':
		case 'R':
		case 'Y':
		case 'M':
			CONSTADD("'");
			break;
	}

	switch (sql->schema->db->dtype)
	{
		case 'X':	
		case 'D':
		case '4':
			sprintf(buf, "%04d", dtp->data[DT_YEAR]);
			STRADD(buf);
			CONSTADD("-");
			sprintf(buf, "%02d", dtp->data[DT_MONTH]);
			STRADD(buf);
			CONSTADD("-");
			sprintf(buf, "%02d", dtp->data[DT_DAY]);
			STRADD(buf);
			break;

		case 'O':
		case 'I':
		case 'Y':
		case 'M':
			sprintf(buf, "%02d", dtp->data[DT_MONTH]);
			STRADD(buf);
			CONSTADD("/");
			sprintf(buf, "%02d", dtp->data[DT_DAY]);
			STRADD(buf);
			CONSTADD("/");
			sprintf(buf, "%04d", dtp->data[DT_YEAR]);
			STRADD(buf);
			break;

		case 'R':
            sprintf(buf, "%02d", dtp->data[DT_DAY]);
            STRADD(buf);
            CONSTADD("-");
            sprintf(buf, "%3s", rdb_month_list[dtp->data[DT_MONTH]]);
            STRADD(buf);
            CONSTADD("-");
            sprintf(buf, "%04d", dtp->data[DT_YEAR]);
            STRADD(buf);
			break;
	}

	if (sql->schema->db->dtype == 'D' || sql->schema->db->dtype == '4' )
	{
		CONSTADD("-");
		sprintf(buf, "%02d", dtp->data[DT_HOUR]);
		STRADD(buf);
		CONSTADD(".");
		sprintf(buf, "%02d", dtp->data[DT_MINUTE]);
		STRADD(buf);
		CONSTADD(".");
		sprintf(buf, "%02d", dtp->data[DT_SECOND]);
		STRADD(buf);
	}
	else
	{
		CONSTADD(" ");
		sprintf(buf, "%02d", dtp->data[DT_HOUR]);
		STRADD(buf);
		CONSTADD(":");
		sprintf(buf, "%02d", dtp->data[DT_MINUTE]);
		STRADD(buf);
		CONSTADD(":");
		sprintf(buf, "%02d", dtp->data[DT_SECOND]);
		STRADD(buf);
	}

	switch(sql->schema->db->dtype)
	{
		case 'X':
			CONSTADD(") year to second");
			break;

		case 'O':
			CONSTADD("','mm/dd/yyyy hh24:mi:ss')");
			break;

		case 'I':
			CONSTADD("')");
			break;

		case 'D':
		case '4':
		case 'R':
		case 'Y':
		case 'M':
			CONSTADD("'");
			break;
	}
}

/******************************************************************************/

extern void RISsql_search_from_list(
	ristree		*fromp,
	tablelist	**tablistp)
{
	int			i;
	char		*tabowner;
	char		*tabname;
	ristree		*tp;
	tablelist	*temp;

	static	struct	tabinfo_s
	{
		char	*name;
		char	possible_view;
		char	schema_flag;
		int		*global_flagp;
	} tabinfo[] =
	{
   		{  "risdbs",	    	 1,	0, 	&RIS_ris5dbs_flag   },
		{  "risschemas", 	  	 1,	0, 	&RIS_ris5schemas_flag},
   		{  "ris5users",          1, 1, 	&RIS_ris5dict_flag	},
   		{  "ris5tables",		 1, 1, 	&RIS_ris5dict_flag	},
   		{  "ris5views",			 1,	1,	&RIS_ris5dict_flag  },
   		{  "ris5column_privs",	 1,	1,	&RIS_ris5dict_flag	},
   		{  "ris5columns",  		 1,	1,	&RIS_ris5dict_flag 	},
   		{  "ris5index_columns",  1,	1,	&RIS_ris5dict_flag	},
   		{  "ris5indexes",      	 1,	1,	&RIS_ris5dict_flag 	},
   		{  "ris5table_privs", 	 1,	1,	&RIS_ris5dict_flag	},
   		{  "ris5dbs",	    	 1,	0, 	&RIS_ris5dbs_flag   },
		{  "ris5schemas",   	 1,	0, 	&RIS_ris5schemas_flag},
	};
	static	int		tabinfo_cnt = sizeof(tabinfo)/sizeof(struct tabinfo_s);

	SQL_DBG(("RISsql_search_from_list: fromp 0x%x tablistp 0x%x\n",
		fromp, tablistp));

	for (tp = fromp->rhs; tp; tp = tp->rhs)
	{
		if (tp->lhs->info.tab->tabtype == 'A')
		{
			tabname = tp->lhs->info.tab->tab->tabname;
			tabowner = tp->lhs->info.tab->tab->tabowner;
		}
		else
		{
			tabname = tp->lhs->info.tab->tabname;
			tabowner = tp->lhs->info.tab->tabowner;
		}	

		SQL_DBG(("table user:<%s> table name:<%s>\n", tabowner, tabname));

		for (i = 0; i < tabinfo_cnt; i++)
		{
			if (!strcmp(tabname, tabinfo[i].name))
			{
				*(tabinfo[i].global_flagp) = 1;
				temp = ALLOCT(tablelist);
				temp->tab = tp->lhs->info.tab;
				temp->possible_view = tabinfo[i].possible_view;
				temp->schema_flag = tabinfo[i].schema_flag;
				temp->next = 0;
				*tablistp = temp;
				tablistp = &((*tablistp)->next);
				break;
			}
		}
	}
	SQL_DBG(("RISsql_search_from_list: returning\n"));
}

/******************************************************************************/

extern int RISsql_get_tabid(
	risschema	*schema,
	ristab		*tab)
{
	int	tabid;

	SQL_DBG(("RISsql_get_tabid: schema->schname <%s> tab->tabname <%s>\n",
		schema->schname, tab->tabname));

	if (tab->tabtype != 'A')
	{
		tabid = RIScom_get_dict_tabid(tab->tabname);
	}
	else
	{
		tabid = RIScom_get_dict_tabid(tab->tab->tabname);
	}

	if(RIScom_is_v4_dict_tabid(tabid) && schema->db->dtype == '4')
	{
		tabid = -1;
	}
	SQL_DBG(("RISsql_get_tabid: returning: tabid %d\n", tabid));
	return(tabid);
}

/******************************************************************************/

extern void RISsql_add_tab_qualification(
	risschema	*schema,
	ristab		*tab,
	int			tabid)
{
	SQL_DBG(("RISsql_add_tab_qualification: schema 0x%x ristab 0x%x tabid %d\n",
		schema, tab, tabid));

	if (schema->db->dtype == 'R')
	{
		SQL_DBG(("RISsql_add_tab_qualification: returning\n"));
		return;
	}
	
	if (tabid != -1)
	{
		if (schema->db->dtype == '4')
		{
			strcpy(tab->tabowner, schema->db->parms.os400.ris_dict_dbname);
		}
		else
		{
			strcpy(tab->tabowner, schema->dict_dbusr);
		}
	}

	if (schema->db->dtype == 'X')
	{
		CONSTADD("\"");
		STRADD(tab->tabowner);
		CONSTADD("\"");
	}
	else
	{
		STRADD(tab->tabowner);
	}

	if (schema->db->dtype == '4' ) 
	{
		CONSTADD("/");
	}
	else
	{
		CONSTADD(".");
	}
	SQL_DBG(("RISsql_add_tab_qualification: returning\n"));
}

/******************************************************************************/

extern void RISsql_add_attr_qualification(
	risschema	*schema,
	ristab		*tab,
	int			tabid)
{
	SQL_DBG(("RISsql_add_attr_qualification: schema 0x%x tab 0x%x tabid %d\n",
		schema, tab, tabid));

	if (schema->db->dtype != '4') 
	{
	    if (tab->tabtype != 'A')
        {
			if (schema->db->dtype != 'I') 
			{
				RISsql_add_tab_qualification(schema, tab, tabid);
			}
			RISsql_add_table(schema, tab, tabid);
        }
		else /* alias */
		{
			STRADD(tab->tabname);
		}
		CONSTADD(".");
	}
	else
	{
		if (tab->tabtype != 'A')
		{
			RISsql_add_alias_id(tab->tabowner, tab->extern_tabname);
		}
		else
		{
			RISsql_add_alias_id(tab->tabowner, tab->tabname);
		}
		CONSTADD(".");
	}
	SQL_DBG(("RISsql_add_attr_qualification: returning\n"));
}

/******************************************************************************/

extern void RISsql_add_table(
	risschema	*schema,
	ristab		*tab,
	int			tabid)
{
	SQL_DBG(("RISsql_add_table: schema 0x%x ristab 0x%x tabid %d\n",
		schema, tab, tabid));

	if (tabid != -1 && schema->db->dtype != '4') 
	{
		if (tab->tabtype != 'A')
		{
			STRADD(tab->tabname);
		}
		else
		{
			STRADD(tab->tab->tabname);
		}
	}
	else
	{
		if (tab->tabtype != 'A')
		{
			STRADD(tab->extern_tabname);
		}
		else
		{
			STRADD(tab->tab->extern_tabname);
		}
	}
	SQL_DBG(("RISsql_add_table: returning\n"));
}

/******************************************************************************/

extern void RISsql_add_attr(
	risschema	*schema,
	risattr		*attr,
	int			tabid)
{
	SQL_DBG(("RISsql_add_attr: schema 0x%x attr 0x%x tabid %d\n",
		schema, attr, tabid));

	if (tabid != -1 && schema->db->dtype != '4' ) 
	{
		STRADD(attr->attrname);
	}
	else
	{
		STRADD(attr->extern_attrname);
	}
	SQL_DBG(("RISsql_add_attr: returning\n"));
}

/******************************************************************************/

extern void RISsql_add_dict_tab_condition(
	rissql		*sql,
	tablelist	*tablist)
{
	int			condition_count = 0;
	char 		srvid_str[16];

	for (; tablist; tablist = tablist->next)
	{
		if (condition_count)
			CONSTADD(" and ");

		CONSTADD("(");
		RISsql_add_attr_qualification(sql->schema, tablist->tab, 1);
		if (tablist->schema_flag)
		{
			if (sql->schema->db->dtype != '4')
			{
				CONSTADD("schema_name = '");
			}
			else
			{
				CONSTADD("SchNm = '");
			}
			STRADD(sql->schema->schname);
			CONSTADD("'");
		}
		else
		{
			if (sql->schema->db->dtype != '4')
			{
				CONSTADD("srvid = ");
			}
			else
			{
				CONSTADD("srvId = ");
			}
			sprintf(srvid_str, "%d", sql->schema->srv_pid);
			STRADD(srvid_str);

			if (tablist->possible_view)
			{
				CONSTADD(" or ");

				RISsql_add_attr_qualification(sql->schema, tablist->tab, 1);
				if (sql->schema->db->dtype != '4')
				{
					CONSTADD("srvid = ");
				}
				else
				{
					CONSTADD("srvId = ");
				}
				sprintf(srvid_str, "%d", 0);
				STRADD(srvid_str);
			}
		}
		CONSTADD(")");
		condition_count++;
	}
}

/******************************************************************************/

extern void RISsql_xpnd_buf_ifneed(
	int 	segment_size)
{
	int		inc_buf_size;

	SQL_DBG(("RISsql_xpnd_buf_ifneed(segment_size:%d)\n", segment_size);)

	/* buffer is not large enough for adding the new segment */
	if ((RISsql_query_len + segment_size) > RISsql_query_buf_size)	
	{
		SQL_DBG(("RISsql_xpnd_buf_ifneed: need to expand the sql buffer\n"
			"RISsql_query_len:%d RISsql_query_buf_size:%d\n",
			RISsql_query_len, RISsql_query_buf_size));

		/* 
		**	the size of the buffer after expansion will not exceed
		**	the maximum size allowed for the buffer
		*/
		if (RISsql_query_buf_size + segment_size > MAX_BUF_SIZE)
		{
			LONGJMP(RIS_E_NO_BUFFER_SPACE);
		}

		if (segment_size < INC_BUF_SIZE)
		{
			if (INC_BUF_SIZE <= (MAX_BUF_SIZE - RISsql_query_buf_size))
			{
				inc_buf_size = INC_BUF_SIZE;
			}
			else
			{
				inc_buf_size = (MAX_BUF_SIZE - RISsql_query_buf_size);
			}
		}
		else
		{
			inc_buf_size = segment_size;
		}

		SQL_DBG(("RISsql_xpnd_buf_ifneed:inc_buf_size:%d\n", inc_buf_size);)

		RISsql_query_buf_size += inc_buf_size;
		RISsql_query_buf = (char *)RIScom_realloc(RISsql_query_buf_size,
			0, SQL_PERMANENT_MARK, PERMANENT_MEMORY);
	}
}

/******************************************************************************/

extern void RISsql_add_alias_id(
	char	*tabowner,
	char	*tabname)
{
	sqlalias	*aliasp = 0;
	sqlalias	*last_aliasp = 0;
	sqlalias	*temp_aliasp = 0;
	int			table_alias_size, i;

	SQL_DBG(("RISsql_add_alias(tabowner <%s>, tabname <%s>)\n",
		tabowner, tabname));
	SQL_DBG(("RISsql_add_alias: RISsql_alias_list 0x%x\n",
		RISsql_alias_list));
	/*
	**  Look for declared schema in hash table
	*/
	for (aliasp = RISsql_alias_list; aliasp; aliasp = aliasp->next)
	{
		SQL_DBG(("RISsql_add_alias(aliasp->tabowner <%s>, aliasp->tabname <%s>)\n",
			aliasp->tabowner, aliasp->tabname));
		if (!strcmp(tabowner, aliasp->tabowner) &&
			!strcmp(tabname, aliasp->tabname))
		{
			SQL_DBG(("RISsql_add_alias: returning aliasp <0x%x>\n", 
				aliasp));
			STRADD(aliasp->alias);
			return;
		}
		last_aliasp = aliasp;
	}

	temp_aliasp = ALLOCT(sqlalias);
	temp_aliasp->tabowner = tabowner;
	temp_aliasp->tabname = tabname;
	if (!last_aliasp)
	{	
		strcpy(temp_aliasp->alias, "A0000");
	}
	else
	{
		strcpy(temp_aliasp->alias, last_aliasp->alias);
	}

	table_alias_size = strlen(temp_aliasp->alias);
	for (i = 0; i < table_alias_size; i++)
	{
		if (temp_aliasp->alias[table_alias_size-(i+1)] > 56 ||
			temp_aliasp->alias[table_alias_size-(i+1)] < 48)
		{
			temp_aliasp->alias[table_alias_size-(i+1)] = 48;
		}
		else
		{
			temp_aliasp->alias[table_alias_size-(i+1)] += 1;
			break;
		}
	}
	temp_aliasp->alias[table_alias_size] = '\0';
	temp_aliasp->next = 0;
	if (!last_aliasp)
	{
		RISsql_alias_list = temp_aliasp;
	}
	else
	{
		last_aliasp->next = temp_aliasp;
	}

	SQL_DBG(("RISsql_add_alias: returning temp_aliasp <0x%x>\n", 
		temp_aliasp));
	STRADD(temp_aliasp->alias);
}

/******************************************************************************/
