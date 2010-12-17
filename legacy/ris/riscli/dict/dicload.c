/*
**	NAME:							dicload.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					3/88
**	ABSTRACT:
**			For an RIS dictionary table,we can store the column 
**			information in some fixed place an load it off this 
**			structure, whenever needed, instead of sending an
**			opcode to the server, and the server returning the
**			information back to the client. 
**			We load the information for an RIS dictinary table
**			from an array of dict_tabdef structures, to make the
**			the first reference to an RIS dictionary table faster
**	
**	REVISION HISTORY:
**			 Modified for the security schema stuff by Jin Jing 6/93
**
**           Fixed a core dump by assigning tabid correctly Shiva 1/94
**     
**		     Table  user  is no longer used after renaming feature is
**			 implemented.									James
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "risdict.h"
#include "rismem.h"
#include "ristoken.h"
#include "ristypes.h"
#include "dict.h"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define dicload_c
#include "dicload.prt"
#include "sys.prt"
#include "comjmp.prt"
#include "comdebug.prt"
#include "comdict.prt"
#include "comoutpt.prt"
#include "comstrng.prt"
#include "ccostmgr.prt"
#include "dictrans.prt"
#include "dicacc.prt"
#include "dicadd.prt"
#include "usrmisc.prt"
#include "usrsndrc.prt"



/******************************************************************************/

extern void RISdic_load_rel(
	risschema *schema,
	char *usr,
	char *relname,
	int commit_flag)
{
	ristab			*tab;
	risattr			*attr;
	risattr			**attrp;
	ris_attr_info	*attr_buf;
	int				attr_cnt = 0;
	int				index = -1;
	int				count;

	DIC_DBG(("RISdic_load_rel(schema:0x%x relname:<%s> commit_flag:%d)\n"
		"RISdic_load_rel: get_table <%s.%s>\n", schema, relname, commit_flag,
		usr, relname));

	/*
	**	If the table under consideration is a RIS dictionary table, then load
	**	the column information(name, type, size ) off the dictionary structure.
	**	Otherwise send an opcode to the server to get column info.
	*/

	index = RIScom_get_dict_tabid(relname);
/*
	if(index != -1 
        && RIScom_dict_tables[index].version == 4 && 
		RIS_default->sql->schema->db->dtype == '4')
    {
   		index = -1;
	}
*/
	if (index != -1 )
	{
		DIC_DBG(("RISdic_load_rel: table is a RIS dictionary table\n")); 

		attr_cnt = RIScom_dict_tables[index].column_count;
		attr_buf = RIScom_dict_tables[index].attr;
	}
	else 
	{
    	RIS_sdp->schema = schema;
		
		RIS_sdp->query = relname;

		DIC_DBG(("RISdic_load_rel: get table <%s>\n", RIS_sdp->query));

		if (RIS_verify_mode)
		{
   			attr_cnt = RISusr_send_rec(RIS_GET_TAB_CODE,RIS_sdp, 
				SYNC_MODE);
		}
		else
		{
   			attr_cnt = RISusr_send_rec(RIS_GET_TAB_NOVERIFY_CODE,
				RIS_sdp, SYNC_MODE);
		}
   		attr_buf = (ris_attr_info*)RIS_sdp->query;
	}

	if (!attr_cnt)
	{
		LONGJMP(RIS_E_UNKNOWN_RELATION);
	}

	tab = RIScco_alloc_ristab(schema->schid);
	tab->schema = schema;
	strcpy(tab->tabname, relname);

	/* 
	** set the tabtype; 
	**    unknown if we went to the database;  
	**    known if ris dictionary object;
	**
	** set the user;
	**    user if ris user object;
	**	  dict_user if ris dictionary object;
	*/
	if (index != -1)
	{
		DIC_DBG(("RISdic_load_rel: schema->dict_dbusr <%s>\n",
			schema->dict_dbusr)); 
		tab->tabtype = RIScom_dict_tables[index].tabtype;
		tab->tabid = RIScom_dict_tables[index].tabid;
        strcpy(tab->extern_tabname, RIScom_dict_tables[index].ext_name);
        strcpy(tab->tabowner, schema->dict_dbusr);
	}
	else
	{
		tab->tabtype = '\0';		/* unknown */
		tab->tabid = (int)RIS_sdp->input_len;
		strcpy(tab->extern_tabname, RIS_sdp->ext_relname);
		strcpy(tab->tabowner, RIS_sdp->relowner);
	}

	DIC_DBG(("RISdic_load_rel: tabid <%d>\n", tab->tabid));

	/*
	**	make one pass to create the table/attr tree
	*/
    for(attrp = &tab->attr, count = attr_cnt;
		count;
		attrp = &((*attrp)->next), count--, attr_buf++)
	{
		*attrp = RIScco_alloc_risattr(schema->schid);
		RISusr_attr_info_to_attr(attr_buf, *attrp);
		(*attrp)->tab = tab;
	}
	*attrp = NULL;

	/*
	**	get access for default schema
	*/
	RISdic_get_access(tab, RIS_default->schname);

	/*
	**	if no access is found for the default then get public access
	*/
	if (!tab->acc)
	{
		RISdic_get_access(tab,"PUBLIC");
	}
	
	/*
	** add this table to the hash table
	*/
	RISdic_add_hash(RIS_TOK_TABLE, tab);

	if (RISdic_debug)
	{
		RIScom_output_debug("table: 0x%x\n", tab);
		RIScom_output_table(RIScom_output_debug, tab, 1);
    	for(attr = tab->attr; attr; attr = attr->next)
		{
			RIScom_output_debug("\n\tattr: 0x%x\n", attr);
			RIScom_output_attr(RIScom_output_debug, attr, 2);
		}
	}

	if (commit_flag)
	{
		RISdic_commit_hash();
	}

	DIC_DBG(("RISdic_load_rel done...\n"));
}

/******************************************************************************/

extern void RISdic_load_declared_rel(
	ristree * tp)
{
	int		attr_count;
	ristab	*tab;
	risattr	**attrp;
	ristree	*list;


	DIC_DBG(("RISdic_load_declared_rel tp = 0x%x\n",tp));

	/*
	**	copy the table struct to permanent memory
	*/
	tab = RIScco_alloc_ristab(tp->info.tab->schema->schid);
	memcpy(tab, tp->info.tab, sizeof(ristab));

	/*
	**	Find out how many attrs --> Why do u need this attr count?? -- Hitesh
	*/
	for(attr_count = 0, list = tp->rhs; list; attr_count++, list = list->rhs);

	/*
	**	copy the attr structs to permanent memory
	*/
	for(attrp = &tab->attr, list = tp->rhs;
		list;
		attrp = &((*attrp)->next), list = list->rhs)
	{
		*attrp = RIScco_alloc_risattr(tp->info.tab->schema->schid);
		memcpy(*attrp, list->lhs->info.attr, sizeof(risattr));
		/* For no verify.   James */
		if(*((*attrp)->extern_attrname) == '\0')
			strcpy((*attrp)->extern_attrname, (*attrp)->attrname);

		(*attrp)->tab = tab;
	}
	*attrp = NULL;

	/*
	**	get access for default schema
	*/
	RISdic_get_access(tab, RIS_default->schname);

	/*
	**	add this table to the hash table
	*/
	RISdic_add_hash(RIS_TOK_TABLE, tab);

	RISdic_commit_hash();
}

/******************************************************************************/

extern void RISdic_declare_verify_option(
	risstmt	*stmt,
	int exec_mode)
{
	risschema		*schemap;
	ristree			*tabtp;
	risattr			*attr;
	ris_attr_info	*attr_buf;
	int				attr_cnt = 0, attrindx;
	char			*relname;

	DIC_DBG(("RISdic_declare_verify_option(stmt:0x%x exec_mode:%d)\n",
	 stmt,exec_mode));

	schemap = stmt->tree->rhs->info.tab->schema;
	tabtp = stmt->tree->rhs;
	relname = tabtp->info.tab->tabname;


	DIC_DBG(("get table <%s>\n", relname));

	RIS_sdp->query = relname;
    RIS_sdp->schema = schemap;
	if( stmt->tree->lhs->tok == RIS_TOK_PARTIAL )
	{
		/* Partial verify */
   		attr_cnt = RISusr_send_rec(RIS_GET_TAB_NOVERIFY_CODE,RIS_sdp,
									(unsigned short)exec_mode);

	}
	else if( stmt->tree->lhs->tok == RIS_TOK_VERIFY )
	{
		/* Full verify */
   		attr_cnt = RISusr_send_rec(RIS_GET_TAB_CODE,RIS_sdp,
									(unsigned short)exec_mode);
	}

	if (exec_mode & FINISH_MODE)
	{
		if( RISdic_debug )
		{
			RIScom_output_debug("\nDeclared ext table_name: <%s>\n",
							tabtp->info.tab->extern_tabname);
			RIScom_output_debug("Returned ext table_name : <%s>\n",
							RIS_sdp->ext_relname);
		}

    /* table owner returned from server */
		if( RISdic_debug )
		{
			RIScom_output_debug("Declared owner name  <%s>\n",
							tabtp->info.tab->tabowner);
			RIScom_output_debug("Returned owner name : <%s>\n",
							RIS_sdp->relowner);
		}
       	if(strcmp(RIS_sdp->relowner,tabtp->info.tab->tabowner))
      		LONGJMP(RIS_E_MISMATCH_IN_TAB_OWNER_NAME);

    /* external table name returned from server */

       	if(strcmp(RIS_sdp->ext_relname,tabtp->info.tab->extern_tabname))
       		LONGJMP(RIS_E_MISMATCH_IN_EXT_TAB_NAME);

/* Previously defined attr definitions returned from server */
		attr_buf = (ris_attr_info *)RIS_sdp->query;
		if (!attr_cnt)
		{
			LONGJMP(RIS_E_UNKNOWN_RELATION);
		}
		
	/* Compare with current declare definitions */
		for (tabtp = tabtp->rhs,attrindx = 0;
				attrindx < attr_cnt;
					tabtp = tabtp->rhs,attrindx++)
		{
			if( !tabtp )
			{
				LONGJMP(RIS_E_LESS_ATTRS_DECLARED);
			}
			attr = tabtp->lhs->info.attr;
			if( RISdic_debug )
			{
				RIScom_output_debug("Declared Defn>> attrname: <%s>\t",attr->attrname);
				RIScom_output_debug("Declared Defn>> extern attrname: <%s>\t",attr->extern_attrname);
				RIScom_output_debug("atype: <%s>\t",RIS_types[ATTR_TYPE(attr->atype)].string);
				RIScom_output_debug("asize.len: <%u>\n",attr->asize.len);

				RIScom_output_debug("Previous Defn>> attrname: <%s>\t",attr_buf[attrindx].attrname);
				RIScom_output_debug("Previous Defn>> extern_attrname: <%s>\t",attr_buf[attrindx].extern_attrname);
				RIScom_output_debug("atype: <%s>\t",RIS_types[ATTR_TYPE(attr_buf[attrindx].atype)].string);
				RIScom_output_debug("asize.len: <%u>\n",attr_buf[attrindx].asize.len);
			}
			if( strcmp(attr->attrname,attr_buf[attrindx].attrname) )
				LONGJMP(RIS_E_MISMATCH_IN_ATTR_NAME);

			/* James. Renaming stuff */
			if(*attr->extern_attrname == '\0')
			{
				/* No external attr name supplied in declare stmt,
					internal name is used */
				strcpy(attr->extern_attrname,attr->attrname);

			}

			if( RIS_default->db->dtype == '4' ||
				RIS_default->db->dtype == 'O' ||
				RIS_default->db->dtype == 'R' ||
				RIS_default->db->dtype == 'D' )
			{
				RIScom_uppercase(strlen(attr->extern_attrname),
						(unsigned char *)attr->extern_attrname ); 
			}	

			RIScom_output_debug("Decalred extern_attrname: <%s>\t",attr->extern_attrname);
			RIScom_output_debug("Returned ext_attrname: <%s>\t",attr_buf[attrindx].extern_attrname);

			if( strcmp(attr->extern_attrname, 
					attr_buf[attrindx].extern_attrname) )
				LONGJMP(RIS_E_MISMATCH_IN_EXT_ATTR_NAME);
			
			if( attr->atype != attr_buf[attrindx].atype )
				LONGJMP(RIS_E_MISMATCH_IN_ATTR_TYPE);
			if( attr->asize.len != attr_buf[attrindx].asize.len )
				LONGJMP(RIS_E_MISMATCH_IN_ATTR_LEN);
		}
		if( tabtp )
			LONGJMP(RIS_E_MORE_ATTRS_DECLARED);
	}
}

/******************************************************************************/

extern void RISdic_load_reltype(
	risschema	*schema,
	char		*usr,
	char		*relname,
	ristab		*tab,
	int			commit_flag)
{
	char       *tabtype;

	DIC_DBG(("RISdic_load_reltype(schema:0x%x relname:<%s> tab:0x%x "
		"commit_flag:%d\n", schema, STRING(relname), tab, commit_flag));

	/*
	**	get the table type
	*/
	DIC_DBG(("RISdic_load_reltype:get table type <%s><%s>\n",
		usr, relname));


	RIS_sdp->query = relname;
    RIS_sdp->schema = schema;
    RISusr_send_rec(RIS_GET_TABTYPE_CODE,RIS_sdp,SYNC_MODE);

	tabtype = RIS_sdp->query;

	if (!*tabtype)
	{
		LONGJMP(RIS_E_UNKNOWN_RELATION);
	}

	tab->tabtype = *tabtype;

	if (commit_flag)
	{
		RISdic_commit_hash();
	}

	DIC_DBG(("RISdic_load_reltype:complete\n"));
}
