/* Do not alter this SPC information: $Revision: 1.5.3.1 $ */
/*
**	NAME:							clicnv.c
**	AUTHORS:						Sunil Murthy
**	CREATION DATE:					11/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

/*
**	INCLUDES
*/
#include "riscom.h"
#include "ristypes.h"
#include "riscli.h"
#include "client.h"
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
#define clicnv_c
#include "clicnv.prt"
#include "arcgnerc.prt"
#include "comdebug.prt"
#include "comjmp.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*****************************************************************************/

static void convert_parms_s_from_net(
	arc_s			*arc,
	struct ris_parms_s	*parms)
{
	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &parms->shm_seg_size, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &parms->max_locals, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &parms->max_rows, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &parms->max_buf_size, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &parms->max_static_stmts,0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &parms->max_user_stmts, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, 
			&parms->max_secondary_schemas, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &parms->max_transactions,0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &parms->max_tab_in_mem, 0);
	}
}

/*****************************************************************************/

static void convert_timestamp_from_net(
	arc_s			*arc,
	struct ristimestamp	*timestamp)
{
	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER,
			&timestamp->timestamp_interval, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER,
			&timestamp->initial_timeout, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER,
			&timestamp->timestamp_tolerance, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER,
			&timestamp->buffer_full_size, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER,
			&timestamp->buffer_full_timeout, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER,
			&timestamp->response_interval, 0);
	}
}

/*****************************************************************************/

extern void RIScli_net_to_init(
	arc_s					*arc,
	struct ris_appcli_buf_client_init 	*init)
{

	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &init->debug, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER,
			&init->schfile_parms.lock_file_retry, 0);
	}
	convert_parms_s_from_net(arc, &init->parms);
	convert_timestamp_from_net(arc, &init->timestamp_parms);
}

/*****************************************************************************/

extern void RIScli_net_to_debug(
	arc_s				*arc,
	struct ris_appcli_buf_debug 	*debug)
{
	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &debug->server_flag, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &debug->data, 0);
	}
}

/*****************************************************************************/

extern void RIScli_net_to_locate_schema_file(
	arc_s					*arc,
	struct ris_appcli_buf_locate_schfile 	*locate_schfile)
{
	ARC_CONVERT_INTEGER(arc, FROM_NET, &locate_schfile->parms.lock_file_retry);
}

/*****************************************************************************/

extern void RIScli_string_to_net(
	arc_s				*arc,
	struct ris_cliapp_buf_string	*string)
{
	ARC_CONVERT_DATA (arc, TO_NET, string->data, string->len);
	ARC_CONVERT_INTEGER(arc, TO_NET, &string->len);
}

/*****************************************************************************/

extern void RIScli_net_to_prepare(
	arc_s				*arc,
	struct ris_appcli_buf_prep 	*prep)
{
	ARC_CONVERT_INTEGER(arc, FROM_NET, &prep->query_len);
	ARC_CONVERT_DATA(arc, FROM_NET, (char *)prep->data, prep->query_len);
}

/*****************************************************************************/

extern void RIScli_prepare_to_net(
	arc_s				*arc,
	struct ris_cliapp_buf_prep	*prep)
{
    /* input sqlvars */
	convert_sqlvars(arc, TO_NET, prep->in_count,
		(sqlvar *)(prep->data + prep->in_sqlvars));

    /* output sqlvars */
	convert_sqlvars(arc, TO_NET, prep->out_count,
		(sqlvar *)(prep->data + prep->out_sqlvars));

	/* table list */
	ARC_CONVERT_DATA(arc, TO_NET, (prep->data + prep->tab_list),
		prep->tab_count * RIS_MAX_ID_SIZE);

	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &prep->in_sqlvars, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &prep->out_sqlvars, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &prep->tab_list, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &prep->in_count, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &prep->out_count, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &prep->tab_count, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &prep->in_len, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &prep->out_len, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &prep->fetch_buf_size, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &prep->write_buf_size, 0);
	}
}

/******************************************************************************/

static void convert_parms(
	arc_s		*arc,
	int		mode,
	int		count,	/* The number of parameters to process */
	internal_sqlvar	*var, 	/* A pointer to the begining of the array of sqlvars*/
	char		*buf)	/* A pointer to where the indicator/data pairs are to start */
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

		CLI_DBG(("convert_parms: aligned pos to = 0x%x\n",pos));

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
		if (indicator < 0)
		{
			/*
			** if indicator is negative - 
			** only process the indicator (we just did it)
			*/

			/*
			** When the data type is a DOUBLE we need to 
			** align the pointer -pos- so that it is properly 
			** positioned for adding the sqllen at the end of
			** the loop.
			*/
			if (sqltype == RIS_DOUBLE)
			{
				RIS_ALIGN(sizeof(double),pos);
			}
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
					RIS_ALIGN(sizeof(double),pos);
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

                case RIS_TEXT:
                case RIS_BLOB:
                    /* What in in the sqldata is internal_blob */
                    /* 2 char pointers are not converted */
                    ARC_CONVERT_INTEGER(arc, mode, pos+8);/* array_size */
                    ARC_CONVERT_INTEGER(arc, mode, pos+12);/* input_len */
                    ARC_CONVERT_INTEGER(arc, mode, pos+16);/* output_len */
                    ARC_CONVERT_INTEGER(arc, mode, pos+20);/* file_offset */
                    ARC_CONVERT_CHARACTER(arc, mode, pos+24);/* file_used */
                    break;


				default :
					CLI_DBG(("convert_parms: invalid sqltype:%d",
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
		}  else if (sqltype == RIS_TEXT || sqltype == RIS_BLOB)
        {
            /* Special handling for TEXT and BLOB is needed */
            pos += sizeof(ris_blob);
        }
		else
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

/*****************************************************************************/

extern void RIScli_net_to_blob_execute(
	arc_s					*arc,
	struct ris_appcli_buf_exec_blob 	*exec_blob)
{
	ARC_NET_TO_SHORT(arc, &exec_blob->blob_col_pos);
	ARC_NET_TO_SHORT(arc, &exec_blob->xfcount);

	ARC_NET_TO_CHARACTER(arc, &exec_blob->more_to_follow);
	ARC_NET_TO_CHARACTER(arc, &exec_blob->file_used);
}

/*****************************************************************************/

extern void RIScli_net_to_fetch_blob(
	arc_s                       *arc,
	struct ris_appcli_fetch_blob    *fetch_blob)
{
	ARC_NET_TO_SHORT(arc, &fetch_blob->blob_col_pos);
	ARC_NET_TO_CHARACTER(arc, &fetch_blob->file_used);
}

/*****************************************************************************/

extern void RIScli_fetch_blob_to_net(
	arc_s                       *arc,
	struct ris_cliapp_fetch_blob    *fetch_blob)
{
	ARC_NET_TO_INTEGER(arc, &fetch_blob->xfercount);
	ARC_NET_TO_CHARACTER(arc, &fetch_blob->more_to_follow);
}

/*****************************************************************************/

extern void RIScli_net_to_fetch(
	arc_s				*arc,
	struct ris_appcli_buf_fetch	*fetch)
{
	int i =0;
	ARC_CONVERT_INTEGER(arc, FROM_NET, &fetch->row_count);
	ARC_CONVERT_INTEGER(arc, FROM_NET, &fetch->out_data);
	ARC_CONVERT_INTEGER(arc, FROM_NET, &fetch->file_names);
	ARC_CONVERT_SHORT(arc, FROM_NET, &fetch->blob_count);

	CLI_DBG(("RIScli_net_to_fetch...\n"));	
	for( i=0; i< fetch->blob_count; ++i)
	{
		ris_blob *blob_field = 0;	
		blob_field=(ris_blob *)(fetch->data+sizeof(ris_blob) * i);
		if (RIScli_debug)
			RIScom_output_debug("i  %d\n", i); 

    	ARC_CONVERT_INTEGER(arc, FROM_NET, &blob_field->array_size); 
		if (RIScli_debug)
			RIScom_output_debug("blob_field->array_size %d\n", blob_field->array_size); 

    	ARC_CONVERT_INTEGER(arc, FROM_NET, &blob_field->input_len); 
		if (RIScli_debug)
			RIScom_output_debug("blob_field->input_len %d\n", blob_field->input_len); 

    	ARC_CONVERT_INTEGER(arc, FROM_NET, &blob_field->output_len); 
		if (RIScli_debug)
			RIScom_output_debug("blob_field->output_len %d\n", blob_field->output_len); 

    	ARC_CONVERT_CHARACTER(arc, FROM_NET, &blob_field->file_used);
		if (RIScli_debug)
			RIScom_output_debug("blob_field->file_used %c\n", blob_field->file_used); 
	}

}
/*****************************************************************************/

extern void RIScli_fetch_to_net(
	arc_s				*arc,
	risstmt				*stmt,
	struct ris_cliapp_buf_fetch	*fetch)
{
	int i;
	int offset;

	for (i = 0, offset = 0;
		 (unsigned )i < fetch->row_count;
		 i++, offset += stmt->row_len)
	{
		convert_parms(arc, TO_NET, stmt->sql->output->sqld,
			stmt->sql->output->sqlvar, (char *)(fetch->data + offset));
	}
	ARC_CONVERT_INTEGER(arc, TO_NET, &fetch->row_count);
	ARC_CONVERT_CHARACTER(arc, TO_NET, &fetch->blob_to_follow);
	ARC_CONVERT_CHARACTER(arc, TO_NET, &fetch->more_to_follow);
}
/*****************************************************************************/

extern void RIScli_net_to_execute(
	arc_s				*arc,
	rissql				*sql,
	struct ris_appcli_buf_exec 	*exec)
{
	/* input data */
	convert_parms (arc, FROM_NET, sql->input->sqld, sql->input->sqlvar,
		exec->data);
}

/*****************************************************************************/

extern void RIScli_execute_to_net(
	arc_s				*arc,
	struct ris_cliapp_buf_exec	*exec)
{
	int i;
	register short *pos;

	/* eot schname list */
	ARC_CONVERT_DATA(arc, TO_NET, (exec->data + exec->eot_schname_list), 
		exec->eot_schname_count * RIS_MAX_ID_SIZE);

	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		/* clear stmt count */
		pos = (short *)(exec->data + exec->clear_stmt_list);
		for (i = 0; i < exec->clear_stmt_count; i++)
		{
			ARC_convert(arc, TO_NET, CONVERT_SHORT, pos, 0);
			pos += sizeof(short);
		}

		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &exec->eot_schname_list, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &exec->clear_stmt_list, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &exec->eot_schname_count, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &exec->clear_stmt_count, 0);
	}
}

/*****************************************************************************/

extern void RIScli_net_to_fetch_4(
	arc_s				*arc,
	struct ris_appcli_buf_fetch_4	*fetch_4)
{
	ARC_CONVERT_INTEGER(arc, FROM_NET, &fetch_4->row_count);
}


/*****************************************************************************/

extern void RIScli_close_to_net(
	arc_s				*arc,
	struct ris_cliapp_buf_close	*close)
{
	/* eot schname list */
	ARC_CONVERT_DATA(arc, TO_NET, close->data,
		close->eot_schname_count*RIS_MAX_ID_SIZE);

	ARC_CONVERT_INTEGER(arc, TO_NET, &close->eot_schname_count);
}

/*****************************************************************************/

extern void RIScli_net_to_clear(
	arc_s				*arc,
	struct ris_appcli_buf_clear	*clear)
{
	ARC_CONVERT_INTEGER(arc, FROM_NET, &clear->set_sqlcode);
}

/*****************************************************************************/

extern void RIScli_clear_to_net(
	arc_s				*arc,
	struct ris_cliapp_buf_clear	*clear)
{
	/* eot schname list */
	ARC_CONVERT_DATA(arc, TO_NET, clear->data,
		clear->eot_schname_count*RIS_MAX_ID_SIZE);

	ARC_CONVERT_INTEGER(arc, TO_NET, &clear->eot_schname_count);
}

/*****************************************************************************/

extern void RIScli_get_flags_to_net(
	arc_s				*arc,
	struct ris_cliapp_buf_get_flags	*get_flags)
{
/*
        Added convert for autorename to fix TR# 439503016 -- Sreedhar. 8/1/96
*/
	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &get_flags->ansi_mode, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &get_flags->enable_dbms, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &get_flags->verify_mode, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER,&get_flags->blankstrip_mode,0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &get_flags->autocommit, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &get_flags->autorename, 0);
	}
}

/*****************************************************************************/

extern void RIScli_report_ss_error_to_net(
	arc_s					*arc,
	struct ris_cliapp_buf_report_ss_error 	*ss_error)
{
	int i;

	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &ss_error->risca.sqlabc, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &ss_error->risca.sqlcode, 0);
		for (i=0; i<8; i++)
		{
			ARC_convert(arc, TO_NET, CONVERT_INTEGER, 
				&ss_error->risca.sqlerrd[i], 0);
		}
	}
	if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, TO_NET, CONVERT_DATA, ss_error->risca.sqlcaid,8);
		ARC_convert(arc, TO_NET, CONVERT_DATA, ss_error->risca.sqlerrp,8);
		ARC_convert(arc, TO_NET, CONVERT_DATA, ss_error->risca.sqlwarn,8);
		ARC_convert(arc, TO_NET, CONVERT_DATA, ss_error->risca.sqlext,8);
		ARC_convert(arc, TO_NET, CONVERT_DATA, ss_error->risca.sqlerrm.sqlerrmc,
			ss_error->risca.sqlerrm.sqlerrml);
	}

	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &ss_error->dbca.sqlabc, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &ss_error->dbca.sqlcode, 0);
		for (i=0; i<8; i++)
		{
			ARC_convert(arc, TO_NET, CONVERT_INTEGER, 
				&ss_error->dbca.sqlerrd[i], 0);
		}
	}
	if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, TO_NET, CONVERT_DATA, ss_error->dbca.sqlcaid,8);
		ARC_convert(arc, TO_NET, CONVERT_DATA, ss_error->dbca.sqlerrp,8);
		ARC_convert(arc, TO_NET, CONVERT_DATA, ss_error->dbca.sqlwarn,8);
		ARC_convert(arc, TO_NET, CONVERT_DATA, ss_error->dbca.sqlext,8);
		ARC_convert(arc, TO_NET, CONVERT_DATA, ss_error->dbca.sqlerrm.sqlerrmc,
			ss_error->dbca.sqlerrm.sqlerrml);
	}

	if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags))
	{
		/* risstmt */
		ARC_convert(arc, TO_NET, CONVERT_DATA,
			(ss_error->data + ss_error->risstmt), ss_error->risstmt_len);

		/* dbstmt */
		ARC_convert(arc, TO_NET, CONVERT_DATA,
			(ss_error->data + ss_error->dbstmt), ss_error->dbstmt_len);

	}
	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &ss_error->risstmt, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &ss_error->dbstmt, 0);

		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &ss_error->risstmt_len, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &ss_error->dbstmt_len, 0);
	}
}

/*****************************************************************************/

extern void RIScli_get_ss_names_to_net(
	arc_s					*arc,
	struct ris_cliapp_buf_get_ss_names 	*ss_names)
{

	ARC_CONVERT_DATA(arc, TO_NET, ss_names->data,
		ss_names->ss_count * RIS_MAX_ID_SIZE);
	ARC_CONVERT_INTEGER(arc, TO_NET, &ss_names->ss_count);
}

/*****************************************************************************/

extern void RIScli_get_ss_def_to_net(
	arc_s					*arc,
	struct ris_cliapp_buf_get_ss_def 	*ss_def)
{

	ARC_CONVERT_DATA(arc, TO_NET, ss_def->data,
		ss_def->ss_count * RIS_MAX_ID_SIZE);
	ARC_CONVERT_INTEGER(arc, TO_NET, &ss_def->ss_count);
}

/*****************************************************************************/

extern void RIScli_get_sch_in_trans_to_net(
	arc_s					*arc,
	struct ris_cliapp_buf_get_sch_in_trans 	*sch_names)
{

	ARC_CONVERT_DATA(arc, TO_NET, sch_names->data,
		sch_names->sch_count * RIS_MAX_ID_SIZE);
	ARC_CONVERT_INTEGER(arc, TO_NET, &sch_names->sch_count);
}

/*****************************************************************************/

static void convert_sqlvars(
	arc_s		*arc,
	int		mode,
	int		count,
	sqlvar		*var)
{
	int i;

	if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags)) 
	{
		for (i=0; i < count; ++i)
		{
			ARC_convert(arc, mode, CONVERT_DATA, var[i].sqlname.sqlnamec,
				var[i].sqlname.sqlnamel);
		}
	}

	if (ARC_SHORT_IS_DIFFERENT(arc->conversion_flags))
	{
		for (i=0; i < count; ++i)
		{
			ARC_convert(arc, mode, CONVERT_SHORT, &var[i].sqlname.sqlnamel, 0);
			ARC_convert(arc, mode, CONVERT_SHORT, &var[i].sqltype, 0);
			ARC_convert(arc, mode, CONVERT_SHORT, &var[i].sqlnull, 0);
			ARC_convert(arc, mode, CONVERT_SHORT, &var[i].sqllen, 0);
			ARC_convert(arc, mode, CONVERT_SHORT, &var[i].sqlscale, 0);

			/*
			** We have to convert the sqlind and sqldata pointers because
			** the application uses their integer values to compute offsets
			*/
			ARC_convert(arc, mode, CONVERT_INTEGER, (int *)&var[i].sqlind, 0);
			ARC_convert(arc, mode, CONVERT_INTEGER, (int *)&var[i].sqldata, 0);
		}
	}
}

/*****************************************************************************/

extern void RIScli_error_to_net(
	arc_s				*arc,
	struct ris_cliapp_buf_error	*error)
{
	int i;
	register short	*pos;

	/* risca */
	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &error->risca.sqlabc, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &error->risca.sqlcode, 0);
		for (i=0; i<8; i++)
		{
			ARC_convert(arc, TO_NET, CONVERT_INTEGER, 
				&error->risca.sqlerrd[i], 0);
		}
	}
	if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, TO_NET, CONVERT_DATA, error->risca.sqlcaid,8);
		ARC_convert(arc, TO_NET, CONVERT_DATA, error->risca.sqlerrp,8);
		ARC_convert(arc, TO_NET, CONVERT_DATA, error->risca.sqlwarn,8);
		ARC_convert(arc, TO_NET, CONVERT_DATA, error->risca.sqlext,8);
		ARC_convert(arc, TO_NET, CONVERT_DATA, error->risca.sqlerrm.sqlerrmc,
			error->risca.sqlerrm.sqlerrml);
	}
	
	/* dbca */
	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &error->dbca.sqlabc, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &error->dbca.sqlcode, 0);
		for (i=0; i<8; i++)
		{
			ARC_convert(arc, TO_NET, CONVERT_INTEGER, 
				&error->dbca.sqlerrd[i], 0);
		}
	}
	if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, TO_NET, CONVERT_DATA, error->dbca.sqlcaid,8);
		ARC_convert(arc, TO_NET, CONVERT_DATA, error->dbca.sqlerrp,8);
		ARC_convert(arc, TO_NET, CONVERT_DATA, error->dbca.sqlwarn,8);
		ARC_convert(arc, TO_NET, CONVERT_DATA, error->dbca.sqlext,8);
		ARC_convert(arc, TO_NET, CONVERT_DATA, error->dbca.sqlerrm.sqlerrmc,
			error->dbca.sqlerrm.sqlerrml);
	}

	if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags))
	{
		/* risstmt */
		ARC_convert(arc, TO_NET, CONVERT_DATA,
			(error->data + error->risstmt), error->risstmt_len);

		/* dbstmt */
		ARC_convert(arc, TO_NET, CONVERT_DATA,
			(error->data + error->dbstmt), error->dbstmt_len);

		/* eot schname list */
		ARC_convert(arc, TO_NET, CONVERT_DATA, 
			(error->data+error->eot_schname_list), 
			error->eot_schname_count*RIS_MAX_ID_SIZE);
	}

	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		/* clar stmt count */
		pos = (short *)(error->data + error->clear_stmt_list);
		for (i = 0; i < error->clear_stmt_count; i++)
		{
			ARC_convert(arc, TO_NET, CONVERT_SHORT, pos, 0);
			pos += sizeof(short);
		}

		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &error->risstmt, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &error->dbstmt, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &error->eot_schname_list, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &error->clear_stmt_list, 0);

		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &error->clear_stmt_count, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &error->eot_schname_count, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &error->risstmt_len, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &error->dbstmt_len, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &error->test_completion, 0);
	}
}

/*****************************************************************************/

