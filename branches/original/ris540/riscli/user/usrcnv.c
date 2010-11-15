/*
**	NAME:							usrcnv.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					11/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
**      Changed the fieldname 'usr' to 'schowner' in risschema
**      structure - Shiva 11/11/93
**
**      Added a new function to convert ris_sch_intern_info
**		 - Shiva 2/27/94
**		10/24/94 -Radha
**			Added changes for MSSQL data server.
*/
 
/*
**	INCLUDES
*/
#include "riscli.h"
#include "riscl_sr.h"
#include "riscom.h"
#include "ristypes.h"
#include "user.h"
#include "arch.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define usrcnv_c
#include "usrcnv.prt"
#include "arcgnerc.prt"
#include "comdebug.prt"
#include "comjmp.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void convert_parms(
	arc_s	*arc,
	int		mode,
	int		count,		  /* The number of parameters to process */
	internal_sqlvar	*var, /* A pointer to the begining of the array of sqlvars*/
	char	*buf)		  /* A pointer to where the indicator/data pairs are
							 to start */
{
	int             indicator = 0;
	int             sqltype = 0;
	int             sqllen  = 0;
	register int    i;
	register int    j;
	register int    total;
	register char	*pos;
	dtime			*datetime;

	total = count;
	pos = buf;
	RIS_ALIGN(sizeof(double),pos);

	for (i=0; i < total; ++i)
	{
		sqltype = (int)var[i].sqltype;
		sqllen  = (int)var[i].sqllen;

		/*
		** We must always align data based on its data type.
		** Since the 'integer' indicator gets aligned here, the only
		** other data type that needs alignment will be the 'double'.
		*/
		RIS_ALIGN(sizeof(int),pos);

		USR_DBG(("RISUsr_convert_parms: aligned pos to = 0x%x\n",pos));

		/*
		** We NEED the "indicator" value - and will base our processing
		** on its value. Therefore, we must capture its value when
		** it is in our local machines' architecture.
		** SO, if we are on the Sun (we must convert),
		**    and we are sending, get the value before conversion.
		**    and we are receiving, get the value after conversion.
		** If we are on the Clipper , it really doesn't matter, so
		** lets just base it on the "to_net" value (just like
		** we do on the Sun).
		*/

		indicator = *(int *)pos;
		ARC_CONVERT_INTEGER(arc, mode, pos);

		/*
		** properly increment the pointer
		*/
		
		pos += sizeof(int);

        if (sqltype == RIS_DOUBLE || sqltype == RIS_DECIMAL )
        {
            /*
            ** When the data type is a RIS_DOUBLE we need to
            ** align the pointer -pos- so that it is properly
            ** positioned for adding the sqllen at the end of
            ** the loop.
            */
            RIS_ALIGN(sizeof(double),pos);
            USR_DBG(("record_conversion:  double aligned pos <0x%x>\n", pos ));
        }



		if (indicator < 0)
		{
			/*
			** if indicator is negative - 
			** only process the indicator (we just did it)
			*/
            USR_DBG(("DATA=NULL"));
		}
		else
		{

			/*
			** process the indicator (we just did it)
			**
			** and process the data
			*/

			switch (sqltype)
			{
				case RIS_CHARACTER:
					/*
					** Strings do NOT require a null
					** terminator, therefore, use the
					** conversion based on length
					*/
					ARC_CONVERT_DATA(arc, mode, pos, sqllen);
					break;

				case RIS_DECIMAL:
					/*
					** Decimal data type is passed as
					** a null terminated string.
					*/
					ARC_CONVERT_STRING(arc, mode, pos);
					break;

				case RIS_DATETIME:
					/*
					** Loop through the 6 integer
					** fields in the date/time
					** structure.
					*/
					datetime = (dtime *)pos;
					for (j = 0; j < DT_COUNT; j++)
					{
						ARC_CONVERT_INTEGER(arc, mode, &datetime->data[j]);
					}
					break;

				case RIS_DOUBLE:
					RIS_ALIGN(sizeof(double),pos);
					ARC_CONVERT_DOUBLE(arc, mode, pos);
					break;

				case RIS_INTEGER:
					ARC_CONVERT_INTEGER(arc, mode, pos);
					break;

				case RIS_REAL:
					ARC_CONVERT_FLOAT(arc, mode, pos);
					break;

				case RIS_SMALLINT:
					ARC_CONVERT_SHORT(arc, mode, pos);
					break;

                case RIS_BLOB:
                case RIS_TEXT:
                   /* What is in the sqldata is internal_blob */
                   /* 2 char pointers are not converted */
                   ARC_CONVERT_INTEGER(arc, mode, pos+8);/* array_size */
                   ARC_CONVERT_INTEGER(arc, mode, pos+12);/* input_len */
                   ARC_CONVERT_INTEGER(arc, mode, pos+16);/* output_len */
                   ARC_CONVERT_INTEGER(arc, mode, pos+20);/* file_offset */
                   ARC_CONVERT_CHARACTER(arc, mode, pos+24);/* file_used */
                   break;

				default :
					USR_DBG(("RISusr_convert_parms: invalid sqltype:%d",
						sqltype));
					LONGJMP(RIS_E_INTERNAL_ERROR);
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

			pos += RIS_types[RIS_DOUBLE].sqllen;
		}
        else if (sqltype == RIS_TEXT || sqltype == RIS_BLOB)
        {
            /* Special handling for TEXT and BLOB is needed */
            pos += sizeof(ris_blob);
        } else
		{
			pos += sqllen;
		}
		if (sqltype == RIS_CHARACTER)
		{
			pos++;
		}
		else if (sqltype == RIS_DECIMAL)
		{
			pos++;
		}
	}
}

/******************************************************************************/

static void convert_sqlvars(
	arc_s	*arc,
	int		mode,
	int		count,
	internal_sqlvar	*var)
{
	int i;

	if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags)) 
	{
		for (i=0; i < count; ++i)
		{
			ARC_convert(arc, mode, CONVERT_DATA, var[i].sqlname.sqlnamec,
				var[i].sqlname.sqlnamel);
			ARC_convert(arc, mode, CONVERT_DATA, var[i].extern_sqlname.sqlnamec,
				var[i].extern_sqlname.sqlnamel);
		}
	}

	if (ARC_SHORT_IS_DIFFERENT(arc->conversion_flags))
	{
		for (i=0; i < count; ++i)
		{
			ARC_convert(arc, mode, CONVERT_SHORT, &var[i].sqlname.sqlnamel, 0);
			ARC_convert(arc, mode, CONVERT_SHORT, &var[i].extern_sqlname.sqlnamel, 0);
			ARC_convert(arc, mode, CONVERT_SHORT, &var[i].sqltype, 0);
			ARC_convert(arc, mode, CONVERT_SHORT, &var[i].sqlnull, 0);
			ARC_convert(arc, mode, CONVERT_SHORT, &var[i].sqllen, 0);
			ARC_convert(arc, mode, CONVERT_SHORT, &var[i].sqlscale, 0);
			ARC_convert(arc, mode, CONVERT_SHORT, &var[i].dbsqltype, 0);
			ARC_convert(arc, mode, CONVERT_INTEGER, &var[i].dbsqllen, 0);
			ARC_convert(arc, mode, CONVERT_INTEGER, &var[i].max_blob_sqllen, 0);
		}
	}
}

/******************************************************************************/

static void convert_access(
	arc_s			*arc,
	int				mode,
	ris_access_info	*access)
{
	if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags)) 
	{
		ARC_convert(arc, mode, CONVERT_STRING, access->schname, 0);
		ARC_convert(arc, mode, CONVERT_STRING, access->relowner, 0);
		ARC_convert(arc, mode, CONVERT_STRING, access->relname, 0);
		/*
		** TR#249407262
		** access->relid is NOT a character; therefore it was not
		** getting converted - needs conversion on Solaris. moved after
		** if branch.
		*/
		/*ARC_convert(arc, mode, CONVERT_INTEGER, &access->relid, 0);*/
		ARC_convert(arc, mode, CONVERT_STRING, access->colname, 0);
		ARC_convert(arc, mode, CONVERT_STRING, access->grantor, 0);
		ARC_convert(arc, mode, CONVERT_STRING, access->grantee, 0);
		ARC_convert(arc, mode, CONVERT_STRING, access->auth, 0);
	}
	ARC_CONVERT_INTEGER(arc, mode, &access->relid);
}

/******************************************************************************/

static void convert_schema_info(
	arc_s			*arc,
	int				mode,
	ris_schema_info	*schema)
{
	ARC_CONVERT_SHORT(arc, mode, &schema->dbid);
	ARC_CONVERT_SHORT(arc, mode, &schema->secure);
	ARC_CONVERT_SHORT(arc, mode, &schema->server_version_major);
	ARC_CONVERT_SHORT(arc, mode, &schema->server_version_feature);

	if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags)) 
	{
		ARC_convert(arc, mode, CONVERT_STRING, schema->schname, 0);
		ARC_convert(arc, mode, CONVERT_STRING, schema->schowner, 0);
		ARC_convert(arc, mode, CONVERT_DATA, schema->schownpass,
			RIS_MAX_PASSWD_SIZE);
		ARC_convert(arc, mode, CONVERT_STRING, schema->dictowner, 0);
	}
}
/******************************************************************************/
static void convert_sch_intern_info(
	arc_s			*arc,
	int				mode,
	ris_sch_intern_info	*sch_intern)
{
	ARC_CONVERT_SHORT(arc, mode, &sch_intern->dbid);

	if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags)) 
	{
		ARC_convert(arc, mode, CONVERT_STRING, sch_intern->schname, 0);
		ARC_convert(arc, mode, CONVERT_STRING, sch_intern->dictowner, 0);
		ARC_convert(arc, mode, CONVERT_STRING, sch_intern->schowner, 0);
		ARC_convert(arc, mode, CONVERT_STRING, sch_intern->login, 0);
		ARC_convert(arc, mode, CONVERT_DATA, sch_intern->passwd,
			RIS_MAX_PASSWD_SIZE);
	}

	ARC_CONVERT_SHORT(arc, mode, &sch_intern->schtype);
	ARC_CONVERT_SHORT(arc, mode, &sch_intern->major);
	ARC_CONVERT_SHORT(arc, mode, &sch_intern->feature);
	USR_DBG(("convert_sch_intern_info: sch_intern->schtype= %d\n",sch_intern->schtype));
}

/******************************************************************************/

static void convert_db_info(
	arc_s		*arc,
	int			mode,
	ris_db_info	*db)
{
	int i;
	unsigned char dtype = db->dtype;
	

	ARC_CONVERT_SHORT(arc, mode, &db->dbid);

	if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags)) 
	{
		ARC_convert(arc, mode, CONVERT_CHARACTER, &db->dtype, 0);
		ARC_convert(arc, mode, CONVERT_STRING, db->dbname, 0);
		for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
		{
			ARC_convert(arc, mode, CONVERT_CHARACTER,
				&db->pathways[i].protocol, 0);
			ARC_convert(arc, mode, CONVERT_STRING,
				db->pathways[i].netaddr, 0);
		}
		switch(dtype)
		{
			case 'X':
				ARC_convert(arc,mode,CONVERT_STRING, db->info.ifx.dir, 0);
				ARC_convert(arc,mode,CONVERT_STRING, db->info.ifx.sqlexec, 0);
				ARC_convert(arc,mode,CONVERT_STRING, db->info.ifx.dbtemp, 0);
				ARC_convert(arc,mode,CONVERT_STRING, db->info.ifx.tbconfig, 0);
				break;
	
            case 'Y':
				ARC_convert(arc, mode, CONVERT_STRING, db->info.syb.osuser, 0);
				ARC_convert(arc, mode, CONVERT_DATA, db->info.syb.ospass,
					RIS_MAX_PASSWD_SIZE);
                ARC_convert(arc,mode,CONVERT_STRING, db->info.syb.dir, 0);
                ARC_convert(arc,mode,CONVERT_STRING, db->info.syb.dsquery, 0);
                ARC_convert(arc,mode,CONVERT_STRING, db->info.syb.sybifile, 0);
                break;

            case 'M':
				ARC_convert(arc, mode, CONVERT_STRING, db->info.mssql.osuser, 0);
				ARC_convert(arc, mode, CONVERT_DATA, db->info.mssql.ospass,
					RIS_MAX_PASSWD_SIZE);
                ARC_convert(arc,mode,CONVERT_STRING, db->info.mssql.dir, 0);
                ARC_convert(arc,mode,CONVERT_STRING, db->info.mssql.dsquery, 0);
                ARC_convert(arc,mode,CONVERT_STRING, db->info.mssql.mssqlifile, 0);
                break;

			case 'I':
				ARC_convert(arc, mode, CONVERT_STRING, db->info.igs.dir, 0);
				break;
	
			case 'O':
				ARC_convert(arc, mode, CONVERT_STRING, db->info.ora.dir, 0);
				ARC_convert(arc, mode, CONVERT_STRING, db->info.ora.osuser, 0);
				ARC_convert(arc, mode, CONVERT_DATA, db->info.ora.ospass,
					RIS_MAX_PASSWD_SIZE);
				break;
	
			case 'D':
				ARC_convert(arc, mode, CONVERT_STRING, db->info.db2.osuser, 0);
				ARC_convert(arc, mode, CONVERT_DATA, db->info.db2.ospass,
					RIS_MAX_PASSWD_SIZE);
				ARC_convert(arc,mode, CONVERT_STRING, db->info.db2.arch, 0);
				ARC_convert(arc,mode, CONVERT_STRING, db->info.db2.os, 0);
				ARC_convert(arc,mode, CONVERT_STRING, db->info.db2.env, 0);
				ARC_convert(arc,mode, CONVERT_STRING,
					db->info.db2.net_protocol, 0);
				ARC_convert(arc,mode, CONVERT_STRING,
					db->info.db2.host_program, 0);
				ARC_convert(arc,mode, CONVERT_STRING, db->info.db2.ris_lu, 0);
				ARC_convert(arc,mode, CONVERT_STRING, db->info.db2.host_lu, 0);
				ARC_convert(arc,mode, CONVERT_STRING, db->info.db2.mode, 0);
				ARC_convert(arc,mode, CONVERT_STRING, db->info.db2.group, 0);
				ARC_convert(arc,mode, CONVERT_STRING, db->info.db2.node, 0);
				ARC_convert(arc,mode, CONVERT_SHORT, &db->info.db2.port, 0);
				break;
	
			case '4':
				ARC_convert(arc, mode, CONVERT_STRING, db->info.os400.osuser, 0);
				ARC_convert(arc, mode, CONVERT_DATA, db->info.os400.ospass,
					RIS_MAX_PASSWD_SIZE);
				ARC_convert(arc,mode, CONVERT_STRING,
					db->info.os400.net_protocol, 0);
				ARC_convert(arc,mode, CONVERT_STRING,
					db->info.os400.host_program, 0);
				ARC_convert(arc,mode, CONVERT_STRING, db->info.os400.ris_lu, 0);
				ARC_convert(arc,mode, CONVERT_STRING, 
								db->info.os400.ris_dict_dbname, 0);
				ARC_convert(arc,mode, CONVERT_STRING, db->info.os400.host_lu, 0);
				ARC_convert(arc,mode, CONVERT_STRING, db->info.os400.mode, 0);
				ARC_convert(arc,mode, CONVERT_STRING, db->info.os400.group, 0);
				ARC_convert(arc,mode, CONVERT_STRING, db->info.os400.node, 0);
				ARC_convert(arc,mode, CONVERT_SHORT, &db->info.os400.port, 0);
				break;

			case 'R':
				break;
		}
	}
}

/******************************************************************************/

static void convert_attr(
	arc_s			*arc,
	int				mode,
	ris_attr_info	*attr)

{
	ARC_CONVERT_STRING(arc, mode, attr->attrname);

	/*
	** When the attr->atype == RIS_DECIMAL,
	** the length field is really a 'scale'
	** and 'precision'.
	** If the architecture is different for
	** a short, then we will still do the 
	** 'swap_bytes' function because it seems
	** to work out for the best.
	*/
	/*  BLOB
		asize.len is now an unsigned int
	*/
	ARC_CONVERT_INTEGER(arc, mode, &attr->asize.len);
	ARC_CONVERT_SHORT(arc, mode, &attr->dbsqltype);
	ARC_CONVERT_INTEGER(arc, mode, &attr->dbsqllen);
}

/******************************************************************************/

extern void RISusr_pddo_to_net(
	arc_s						*arc,
	rissql						*sql,
	struct ris_clisrv_buf_pddo	*pddo)

{
	/* input data */
	convert_parms(arc, TO_NET, sql->input->sqld, sql->input->sqlvar,
		(pddo->data + pddo->in_data));

	/* input sqlvars */
	convert_sqlvars(arc, TO_NET, pddo->in_count,
		(internal_sqlvar *)(pddo->data + pddo->in_sqlvar));

	/* output sqlvars */
	convert_sqlvars(arc, TO_NET, pddo->out_count,
		(internal_sqlvar *)(pddo->data + pddo->out_sqlvar));

	/* the query */
	ARC_CONVERT_DATA(arc, TO_NET, (pddo->data + pddo->query), pddo->query_len);

	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &pddo->in_data, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &pddo->in_sqlvar, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &pddo->out_sqlvar, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &pddo->query, 0);
	
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &pddo->in_count, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &pddo->out_count, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &pddo->query_len, 0);
	}
}

/******************************************************************************/

extern void RISusr_pe_to_net(
	arc_s						*arc,
	rissql						*sql,
	struct ris_clisrv_buf_pe	*pe)

{
	/* input data */
	convert_parms(arc, TO_NET, sql->input->sqld, sql->input->sqlvar,
		(pe->data + pe->in_data));

	/* input sqlvars */
	convert_sqlvars(arc, TO_NET, pe->in_count,
		(internal_sqlvar *)(pe->data + pe->in_sqlvar));

	/* the query */
	ARC_CONVERT_DATA(arc, TO_NET, (pe->data + pe->query), pe->query_len);

	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &pe->in_data, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &pe->in_sqlvar, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &pe->query, 0);
	
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &pe->in_count, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &pe->query_len, 0);
	}
}

/******************************************************************************/

extern void RISusr_open_to_net(
	arc_s						*arc,
	rissql						*sql,
	struct ris_clisrv_buf_open	*open)

{
	/* input data */
	convert_parms(arc, TO_NET, sql->input->sqld, sql->input->sqlvar,
		(open->data + open->in_data));

	ARC_CONVERT_INTEGER(arc, TO_NET, &open->in_data);
	ARC_CONVERT_SHORT(arc, TO_NET, &open->old_stmt_id);
}

/******************************************************************************/

extern void RISusr_exec_to_net(
	arc_s						*arc,
	rissql						*sql,
	struct ris_clisrv_buf_exec	*exec)

{
	/* input data */
	convert_parms(arc, TO_NET, sql->input->sqld, sql->input->sqlvar,
		(exec->data + exec->in_data));

	ARC_CONVERT_INTEGER(arc, TO_NET, &exec->in_data);
	ARC_CONVERT_SHORT(arc, TO_NET, &exec->old_stmt_id);
}

/******************************************************************************/

extern void RISusr_get_access_to_net(
	arc_s								*arc,
	struct ris_clisrv_buf_get_access	*get_access)

{
	convert_access(arc, TO_NET, &get_access->data);
}

/******************************************************************************/

extern void RISusr_create_table_to_net(
	arc_s								*arc,
	struct ris_clisrv_buf_create_table	*create_table)

{
	/* input sqlvars */
	convert_sqlvars(arc, TO_NET, create_table->col_count,
		(internal_sqlvar *)(create_table->data + create_table->col_sqlvar));

	/* the def_string */
	ARC_CONVERT_STRING(arc, TO_NET,
		(create_table->data + create_table->def_string));

	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &create_table->col_sqlvar, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &create_table->def_string, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &create_table->col_count, 0);
	}
}

/******************************************************************************/

extern void RISusr_create_view_to_net(
	arc_s								*arc,
	struct ris_clisrv_buf_create_view	*create_view)

{
	/* input sqlvars */
	convert_sqlvars(arc, TO_NET, create_view->col_count,
		(internal_sqlvar *)(create_view->data + create_view->col_sqlvar));

	/* the dbms_string */
	ARC_CONVERT_STRING(arc, TO_NET,
		(create_view->data + create_view->dbms_string));

	/* the ris_string */
	ARC_CONVERT_STRING(arc, TO_NET,
		(create_view->data + create_view->ris_string));

	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &create_view->col_sqlvar, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &create_view->dbms_string, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &create_view->ris_string, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &create_view->col_count, 0);
	}
}

/******************************************************************************/

extern void RISusr_alter_table_to_net(
	arc_s								*arc,
	struct ris_clisrv_buf_alter_table	*alter_table)

{
	/* input sqlvars */
	convert_sqlvars(arc, TO_NET, 1, &alter_table->col_sqlvar);

	/* the def_string */
	ARC_CONVERT_STRING(arc, TO_NET,
		(alter_table->data + alter_table->def_string));

	ARC_CONVERT_INTEGER(arc, TO_NET, &alter_table->def_string);
}

/******************************************************************************/

extern void RISusr_create_schema_to_net(
	arc_s								*arc,
	struct ris_clisrv_buf_create_schema	*create_schema)
{
	ARC_CONVERT_INTEGER(arc, TO_NET, &create_schema->max_rows);
	ARC_CONVERT_INTEGER(arc, TO_NET, &create_schema->max_buf_size);
	ARC_CONVERT_INTEGER(arc, TO_NET, &create_schema->debug);
	convert_sch_intern_info(arc, TO_NET, &create_schema->schema);
	convert_db_info(arc, TO_NET, &create_schema->db);
	ARC_CONVERT_DATA(arc, TO_NET, create_schema->schpass, RIS_MAX_PASSWD_SIZE);
}

/******************************************************************************/

extern void RISusr_schema_db_to_net(
	arc_s							*arc,
	struct ris_clisrv_buf_schema_db	*schema_db)
{
	ARC_CONVERT_INTEGER(arc, TO_NET, &schema_db->max_rows);
	ARC_CONVERT_INTEGER(arc, TO_NET, &schema_db->max_buf_size);
	ARC_CONVERT_INTEGER(arc, TO_NET, &schema_db->debug);
	convert_sch_intern_info(arc, TO_NET, &schema_db->schema);
	convert_db_info(arc, TO_NET, &schema_db->db);
	ARC_CONVERT_DATA(arc, TO_NET, schema_db->schpass, RIS_MAX_PASSWD_SIZE);
}

/******************************************************************************/

extern void RISusr_upd_access_to_net(
	arc_s								*arc,
	struct ris_clisrv_buf_upd_access	*upd_access)
{
	unsigned int i;
	int offset = upd_access->acc;

	for (i = 0; i < upd_access->count; i++)
	{
		convert_access(arc,TO_NET,(ris_access_info *)(upd_access->data+offset));
		offset += sizeof(ris_access_info);
	}

	ARC_CONVERT_INTEGER(arc, TO_NET, &upd_access->acc);
	ARC_CONVERT_INTEGER(arc, TO_NET, &upd_access->count);
}

/******************************************************************************/

extern void RISusr_load_risdbs_to_net(
	arc_s								*arc,
	struct ris_clisrv_buf_load_risdbs	*load_risdbs)
{
	unsigned int i;
	int offset = load_risdbs->dbs;

	for (i = 0; i < load_risdbs->db_count; i++)
	{
		convert_db_info(arc,TO_NET,(ris_db_info *)(load_risdbs->data + offset));
		offset += sizeof(ris_db_info);
	}

	ARC_CONVERT_INTEGER(arc, TO_NET, &load_risdbs->dbs);
	ARC_CONVERT_INTEGER(arc, TO_NET, &load_risdbs->db_count);
}

/******************************************************************************/

extern void RISusr_load_risschemas_to_net(
	arc_s									*arc,
	struct ris_clisrv_buf_load_risschemas	*load_risschemas)
{
	unsigned int i;
	int offset = load_risschemas->schemas;

	for (i = 0; i < load_risschemas->schema_count; i++)
	{
		convert_schema_info(arc, TO_NET,
			(ris_schema_info *)(load_risschemas->data + offset));
		offset += sizeof(ris_schema_info);
	}

	ARC_CONVERT_INTEGER(arc, TO_NET, &load_risschemas->schemas);
	ARC_CONVERT_INTEGER(arc, TO_NET, &load_risschemas->schema_count);
}

/******************************************************************************/

extern void RISusr_net_to_fetch_buf(
	arc_s						*arc,
	risstmt						*stmt,
	struct ris_srvcli_buf_fetch	*fetch)
{
	unsigned int i;
	int offset;

	ARC_CONVERT_INTEGER(arc, FROM_NET, &fetch->row_count);
    ARC_CONVERT_CHARACTER(arc, FROM_NET, &fetch->more_to_follow);
    ARC_CONVERT_CHARACTER(arc, FROM_NET, &fetch->blob_to_follow);

	for (i = 0, offset = 0;
		 i < fetch->row_count;
		 i++, offset += stmt->row_len)
	{
		convert_parms(arc, FROM_NET, stmt->sql->output->sqld,
			stmt->sql->output->sqlvar, (char *)(fetch->data + offset));
	}
}

/******************************************************************************/

extern void RISusr_net_to_get_tab(
	arc_s							*arc,
	struct ris_srvcli_buf_get_tab	*get_tab)
{
	unsigned int i;
	int offset;

	ARC_CONVERT_INTEGER(arc, FROM_NET, &get_tab->count);
	ARC_CONVERT_INTEGER(arc, FROM_NET, &get_tab->tabid);

	for (i = 0, offset = 0;
		 i < get_tab->count;
		 i++, offset += sizeof(ris_attr_info))
	{
		convert_attr(arc, FROM_NET, (ris_attr_info *)(get_tab->data + offset));
	}
}

/******************************************************************************/

extern void RISusr_net_to_get_access(
	arc_s								*arc,
	struct ris_srvcli_buf_get_access	*get_access)
{
	unsigned int i;
	int offset;

	ARC_CONVERT_INTEGER(arc, FROM_NET, &get_access->count);

	for (i = 0, offset = 0;
		 i < get_access->count;
		 i++, offset += sizeof(ris_access_info))
	{
		convert_access(arc, FROM_NET,
			(ris_access_info *)(get_access->data+offset));
	}
}

/******************************************************************************/

extern void RISusr_net_to_get_grantees(
	arc_s								*arc,
	struct ris_srvcli_buf_get_grantees	*get_grantees)
{
	unsigned int i;
	int offset;

	ARC_CONVERT_INTEGER(arc, FROM_NET, &get_grantees->count);

	if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags)) 
	{
		for (i = 0, offset = 0;
		 	i < get_grantees->count;
		 	i++, offset += RIS_MAX_ID_SIZE)
		{
			ARC_convert(arc, FROM_NET, CONVERT_STRING,
				get_grantees->data + offset, 0);
		}
	}
}

/******************************************************************************/


/* Same as RISusr_net_to_get_grantees except for :
** struct ris_srvcli_buf_create_schema *get_grantees
*/

extern void RISusr_net_to_cre_sch_get_grantees(
	arc_s								*arc,
	struct ris_srvcli_buf_create_schema	*get_grantees)
{
	unsigned int i;
	int offset;

	ARC_CONVERT_INTEGER(arc, FROM_NET, &get_grantees->count);

	if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags)) 
	{
		for (i = 0, offset = 0;
		 	i < get_grantees->count;
		 	i++, offset += RIS_MAX_ID_SIZE)
		{
			ARC_convert(arc, FROM_NET, CONVERT_STRING,
				get_grantees->data + offset, 0);
		}
	}
}
/******************************************************************************/

extern void RISusr_net_to_error(
	arc_s						*arc, 
	struct ris_srvcli_buf_error *error)
{
	int i;

	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags)) 
	{
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->dbstmt_len, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->dbca.sqlabc, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->dbca.sqlcode, 0);
		for (i=0; i<8; i++)
		{
			ARC_convert(arc, FROM_NET, CONVERT_INTEGER,
				&error->dbca.sqlerrd[i], 0);
		}
	}

	if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags)) 
	{
		ARC_convert(arc, FROM_NET, CONVERT_DATA, error->dbca.sqlcaid,8);
		ARC_convert(arc, FROM_NET, CONVERT_DATA, error->dbca.sqlerrp,8);
		ARC_convert(arc, FROM_NET, CONVERT_DATA, error->dbca.sqlwarn,8);
		ARC_convert(arc, FROM_NET, CONVERT_DATA, error->dbca.sqlext,8);
		ARC_convert(arc, FROM_NET, CONVERT_DATA, error->dbca.sqlerrm.sqlerrmc,
			error->dbca.sqlerrm.sqlerrml);
	
		ARC_convert(arc, FROM_NET, CONVERT_DATA, (char *)error->data,
			error->dbstmt_len);
	}
}

/***************  BLOB       *************/
extern void RISusr_fetch_blob_to_net(
	arc_s                       *arc,
	struct ris_clisrv_fetch_blob    *fetch_blob)
{
	ARC_SHORT_TO_NET(arc, &fetch_blob->blob_col_pos);
	ARC_CHARACTER_TO_NET(arc, &fetch_blob->file_used);
}

/***************  BLOB       *************/
extern void RISusr_net_to_fetch_blob(
	arc_s                       *arc,
	struct ris_srvcli_fetch_blob    *fetch_blob)
{
	ARC_NET_TO_INTEGER(arc, &fetch_blob->xfercount);
	ARC_NET_TO_CHARACTER(arc, &fetch_blob->more_to_follow);
}

/***************  BLOB       *************/
extern void RISusr_fetch_to_net(
	arc_s						*arc,
	struct ris_clisrv_buf_fetch	*fetch)
{
	ris_blob *blob_field =0;
	char * file_name_list = 0;
	int i=0;

	file_name_list = fetch->data + fetch->out_data; 
    /* dbms doesn't need to be converted */

    ARC_SHORT_TO_NET(arc, &RIS_srv_write->buf.fetch.old_stmt_id);



	for (i=0; i<fetch->blob_count; ++i)
	{
		/* Convert blob data */
		blob_field = (ris_blob *) (fetch->data + sizeof(ris_blob) * i);

#ifdef CONVERT_FILENAME
		if (blob_field->file_used && 
				ARC_CHAR_IS_DIFFERENT(arc->conversion_flags) )
		{
			/* The file name size is in the array_size */
			ARC_convert(arc, TO_NET, CONVERT_DATA,
							file_name_list, blob_field->array_size);

			file_name_list += blob_field->array_size;
		}
#endif
      	ARC_CONVERT_CHARACTER(arc, TO_NET, &blob_field->file_used);
		ARC_INTEGER_TO_NET(arc, &blob_field->array_size);
	}

	ARC_INTEGER_TO_NET(arc, &fetch->out_data);
	ARC_INTEGER_TO_NET(arc, &fetch->row_count);
	ARC_INTEGER_TO_NET(arc, &fetch->file_names);
	ARC_SHORT_TO_NET(arc, &fetch->blob_count);
	
}
/******************************************************************************/

extern void RISusr_eb_to_net(
	arc_s						*arc,
	struct ris_clisrv_buf_exec_blob	*exec_blob)
{
	ARC_SHORT_TO_NET(arc, &exec_blob->blob_col_pos);
	ARC_SHORT_TO_NET(arc, &exec_blob->xfcount);

	ARC_CHARACTER_TO_NET(arc, &exec_blob->more_to_follow);
	ARC_CHARACTER_TO_NET(arc, &exec_blob->file_used);
}

/******************************************************************************/


extern void RISusr_execde_to_net(
	arc_s						*arc,
	rissql						*sql,
	struct ris_clisrv_buf_exec	*exec_de)

{
	/* input data */
	convert_parms(arc, TO_NET, sql->input->sqld, sql->input->sqlvar,
		(exec_de->data + exec_de->in_data));

	ARC_CONVERT_INTEGER(arc, TO_NET, &exec_de->in_data);
	ARC_CONVERT_SHORT(arc, TO_NET, &exec_de->old_stmt_id);
}

/******************************************************************************/
