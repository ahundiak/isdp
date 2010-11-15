/* Do not alter this SPC information: $Revision: 1.2.56.1 $ */
/*
**  NAME:                           appcnv.c
**  AUTHORS:                        Prasad Challa
**  CREATION DATE:                  12/92
**  ABSTRACT:
**
**  REVISION HISTORY:
**                    Radha 9/30/94
**                        Changed the order in which the ARC_convert is done
**                    in the RISapp_execute_from_net function. 
**                    exec->clear_stmt_count should be converted before being
**                    used.
*/

/*
**  INCLUDES
*/
#include "app.h"
#include "arch.h"
#include "riscom.h"
#include "risapp.h"
#include "risap_cl.h"
#include "riscl_pa.h"
#include "ristypes.h"

/*
**  DEFINES
*/

/*
**  TYPES
*/

/*
**  FUNCTION PROTOTYPES
*/
#define appcnv_c
#include "appcnv.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "arcgnerc.prt"

/*
**  VARIABLES
*/

/*
**  FUNCTIONS
*/

/******************************************************************************/

static void convert_parms_s_to_net(
    arc_s               *arc,
    struct ris_parms_s  *parms)
{
    if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
    {
        ARC_convert(arc, TO_NET, CONVERT_INTEGER, &parms->shm_seg_size, 0);
        ARC_convert(arc, TO_NET, CONVERT_INTEGER, &parms->max_locals, 0);
        ARC_convert(arc, TO_NET, CONVERT_INTEGER, &parms->max_rows, 0);
        ARC_convert(arc, TO_NET, CONVERT_INTEGER, &parms->max_buf_size, 0);
        ARC_convert(arc, TO_NET, CONVERT_INTEGER, &parms->max_static_stmts,0);
        ARC_convert(arc, TO_NET, CONVERT_INTEGER, &parms->max_user_stmts, 0);
        ARC_convert(arc, TO_NET, CONVERT_INTEGER,
            &parms->max_secondary_schemas, 0);
        ARC_convert(arc, TO_NET, CONVERT_INTEGER, &parms->max_transactions,0);
        ARC_convert(arc, TO_NET, CONVERT_INTEGER, &parms->max_tab_in_mem, 0);
    }
}

/******************************************************************************/

static void convert_timestamp_to_net(
    arc_s                       *arc,
    struct ristimestamp *timestamp)
{
    if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
    {
        ARC_convert(arc, TO_NET, CONVERT_INTEGER,
            &timestamp->timestamp_interval, 0);
        ARC_convert(arc, TO_NET, CONVERT_INTEGER,
            &timestamp->initial_timeout, 0);
        ARC_convert(arc, TO_NET, CONVERT_INTEGER,
            &timestamp->timestamp_tolerance, 0);
        ARC_convert(arc, TO_NET, CONVERT_INTEGER,
            &timestamp->buffer_full_size, 0);
        ARC_convert(arc, TO_NET, CONVERT_INTEGER,
            &timestamp->buffer_full_timeout, 0);
        ARC_convert(arc, TO_NET, CONVERT_INTEGER,
            &timestamp->response_interval, 0);
    }
}

/*****************************************************************************/

extern void RISapp_init_to_net(
	arc_s 								*arc,
	struct ris_appcli_buf_client_init	*init)
{

	if (ARC_INTEGER_IS_DIFFERENT (arc->conversion_flags))
    {
        ARC_convert(arc, TO_NET, CONVERT_INTEGER, 
			&init->schfile_parms.lock_file_retry, 0);
        ARC_convert(arc, TO_NET, CONVERT_INTEGER, &init->debug, 0);
    }
    convert_parms_s_to_net(arc, &init->parms);
    convert_timestamp_to_net(arc, &init->timestamp_parms);
}

/*****************************************************************************/

extern void RISapp_debug_to_net(
	arc_s 							*arc,
	struct ris_appcli_buf_debug		*debug)
{
    if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
    {
        ARC_convert(arc, TO_NET, CONVERT_INTEGER, &debug->server_flag, 0);
        ARC_convert(arc, TO_NET, CONVERT_INTEGER, &debug->data, 0);
    }
}
/*****************************************************************************/

extern void RISapp_locate_sch_file_to_net(
	arc_s 									*arc,
	struct ris_appcli_buf_locate_schfile	*locate_schfile)
{
	ARC_CONVERT_INTEGER(arc, TO_NET, &locate_schfile->parms.lock_file_retry);
}
/*****************************************************************************/

extern void RISapp_prepare_to_net(
	arc_s 							*arc,
	struct ris_appcli_buf_prep		*prep)
{
    ARC_CONVERT_INTEGER(arc, TO_NET, &prep->query_len);

    ARC_CONVERT_DATA(arc, TO_NET, (char *)prep->data, prep->query_len);

}
/*****************************************************************************/

static void convert_parms(
    arc_s   *arc,
    int     mode,
    int     count,        /* The number of parameters to process */
    sqlvar  *var, 		  /* A pointer to the begining of the array of sqlvars*/
    char    *buf)         /* A pointer to where the indicator/data pairs are
                             to start */
{
    int             indicator = 0;
    int             sqltype = 0;
    int             sqllen  = 0;
    register int    i;
    register int    j;
    register int    total;
    register char   *pos;
    dtime           *datetime;

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

        APP_DBG(("convert_parms: aligned pos to = 0x%x\n",pos));

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
            APP_DBG(("record_conversion:  double aligned pos <0x%x>\n", pos ));
        }

        if (indicator < 0)
        {
            /*
            ** if indicator is negative -
            ** only process the indicator (we just did it)
            */
            APP_DBG(("DATA=NULL"));
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
    				{
						ris_blob *blob_struct = (ris_blob *)pos;
 
        				ARC_CONVERT_INTEGER(arc, mode, 
									&blob_struct->file_offset);

        				ARC_CONVERT_INTEGER(arc, mode, 
									&blob_struct->array_size);

        				ARC_CONVERT_INTEGER(arc, mode, 
									&blob_struct->input_len);

        				ARC_CONVERT_INTEGER(arc, mode, 
									&blob_struct->output_len);

        				ARC_CONVERT_CHARACTER(arc, mode, &blob_struct->file_used);
    				}
                    break;

                default :
                    APP_DBG(("convert_parms: invalid sqltype:%d",
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
        else if (sqltype == RIS_TEXT || sqltype == RIS_BLOB )
		{
            pos += sizeof(ris_blob);
		}	
		else
        {
            pos += sqllen;
        }
        if (sqltype == RIS_CHARACTER || sqltype == RIS_DECIMAL)
        {
            pos++;
    	}
	}
}

/*****************************************************************************/

extern void RISapp_execute_to_net(
	arc_s 							*arc,
	sqlda							*in_sqlda,
	struct ris_appcli_buf_exec		*exec)
{
    /* input data */
	if(in_sqlda)
	{
    	convert_parms (arc, TO_NET, in_sqlda->sqld, in_sqlda->sqlvar, 
			exec->data);
	}
}

/*****************************************************************************/

extern void RISapp_clear_to_net(
	arc_s 							*arc,
	struct ris_appcli_buf_clear		*clear)
{
    ARC_CONVERT_INTEGER(arc, TO_NET, &clear->set_sqlcode);
}

/*****************************************************************************/
static void convert_sqlvars(
    arc_s   *arc,
    int     mode,
    int     count,
    sqlvar  *var)
{
    int i;

APP_DBG(("\nconvert_sqlvars: arc:0x%x mode:%d count:%d sqlvar:0x%x\n", arc, mode, count, var));

    if (ARC_SHORT_IS_DIFFERENT(arc->conversion_flags))
    {
        for (i=0; i < count; ++i)
        {
            ARC_convert(arc, mode, CONVERT_SHORT, &var[i].sqlname.sqlnamel, 0);
            ARC_convert(arc, mode, CONVERT_SHORT, &var[i].sqltype, 0);
            ARC_convert(arc, mode, CONVERT_SHORT, &var[i].sqlnull, 0);
            ARC_convert(arc, mode, CONVERT_SHORT, &var[i].sqllen, 0);
            ARC_convert(arc, mode, CONVERT_SHORT, &var[i].sqlscale, 0);

            ARC_convert(arc, mode, CONVERT_INTEGER, (int *)&var[i].sqlind, 0);
            ARC_convert(arc, mode, CONVERT_INTEGER, (int *)&var[i].sqldata, 0);
        }
    }

    if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags))
    {
        for (i=0; i < count; ++i)
        {
            ARC_convert(arc, mode, CONVERT_DATA, var[i].sqlname.sqlnamec,
                var[i].sqlname.sqlnamel);
        }
    }
}

/*****************************************************************************/

extern void RISapp_grow_buf_to_net(
	arc_s 							*arc,
	struct ris_appcli_buf_grow_buf	*grow_buf)
{
    ARC_CONVERT_INTEGER(arc, TO_NET, &grow_buf->new_size);
}

/*****************************************************************************/

/*
** From client to app architecture conversion.
*/

/*****************************************************************************/

extern void RISapp_grow_buf_from_net(
	arc_s 							*arc,
	struct ris_appcli_buf_grow_buf	*grow_buf)
{
    ARC_CONVERT_INTEGER(arc, FROM_NET, &grow_buf->new_size);
}

/*****************************************************************************/

extern void RISapp_prepare_from_net(
    arc_s                       *arc,
    struct ris_cliapp_buf_prep  *prep)
{

APP_DBG(("\nRISapp_prepare_from_net: arc:0x%x prep:0x%x\n", arc, prep));

    if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
    {
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &prep->in_sqlvars, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &prep->out_sqlvars, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &prep->tab_list, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &prep->in_count, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &prep->out_count, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &prep->tab_count, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &prep->in_len, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &prep->out_len, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &prep->fetch_buf_size, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &prep->write_buf_size, 0);
    }

    /* input sqlvars */
    convert_sqlvars(arc, FROM_NET, prep->in_count,
        (sqlvar *)(prep->data + prep->in_sqlvars));

    /* output sqlvars */
    convert_sqlvars(arc, FROM_NET, prep->out_count,
        (sqlvar *)(prep->data + prep->out_sqlvars));

    /* table list */
    ARC_CONVERT_DATA(arc, FROM_NET, (prep->data + prep->tab_list),
        prep->tab_count * RIS_MAX_ID_SIZE);

}
/*****************************************************************************/

extern void RISapp_execute_from_net(
    arc_s                       *arc,
    struct ris_cliapp_buf_exec  *exec)
{
    int i;
	register short *pos;

    if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
    {
        /* clear stmt count */
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &exec->eot_schname_list, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &exec->clear_stmt_list, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &exec->eot_schname_count, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &exec->clear_stmt_count, 0);
        pos = (short *)(exec->data + exec->clear_stmt_list);
        for (i = 0; i < exec->clear_stmt_count; i++)
        {
            ARC_convert(arc, FROM_NET, CONVERT_SHORT, pos, 0);
            pos += sizeof(short);
        }

    }

    /* eot schname list */
    ARC_CONVERT_DATA(arc, FROM_NET, (exec->data+exec->eot_schname_list),
        exec->eot_schname_count*RIS_MAX_ID_SIZE);
}

/*****************************************************************************/
extern void RISapp_fetch_from_net(
    arc_s                       *arc,
    ris_app_stmt		*stmt,
    struct ris_cliapp_buf_fetch *fetch)
{
	int offset;
	unsigned int i;

	ARC_CONVERT_INTEGER(arc, FROM_NET, &fetch->row_count);
	/* 
	**	BLOB 
	*/
	ARC_CONVERT_CHARACTER(arc, FROM_NET, &fetch->more_to_follow);
	ARC_CONVERT_CHARACTER(arc, FROM_NET, &fetch->blob_to_follow);

	for (i=0, offset = 0;
		i < fetch->row_count;
			i++, offset += stmt->output_len)
	{
		convert_parms(arc, FROM_NET, stmt->output->sqld,
		stmt->output->sqlvar, (char *)(fetch->data + offset));
	}
}

/*****************************************************************************/

extern void RISapp_close_from_net(
    arc_s                       *arc,
    struct ris_cliapp_buf_close *close)
{

    ARC_CONVERT_INTEGER(arc, FROM_NET, &close->eot_schname_count);
    ARC_CONVERT_DATA(arc, FROM_NET, close->data, 
		close->eot_schname_count*RIS_MAX_ID_SIZE);
}

/*****************************************************************************/

extern void RISapp_clear_from_net(
    arc_s                       *arc,
    struct ris_cliapp_buf_clear *clear)
{

    ARC_CONVERT_INTEGER(arc, FROM_NET, &clear->eot_schname_count);
    ARC_CONVERT_DATA(arc, FROM_NET, clear->data, 
		clear->eot_schname_count*RIS_MAX_ID_SIZE);
}

/*****************************************************************************/

extern void RISapp_string_from_net(
    arc_s                       *arc,
    struct ris_cliapp_buf_string *string)
{

    ARC_CONVERT_INTEGER(arc, FROM_NET, &string->len);
    ARC_CONVERT_DATA(arc, FROM_NET, string->data, string->len);
}

/*****************************************************************************/

extern void RISapp_get_flags_from_net(
    arc_s                           *arc,
    struct ris_cliapp_buf_get_flags *get_flags)
{

    if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &get_flags->ansi_mode, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &get_flags->enable_dbms, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &get_flags->verify_mode, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, 
			&get_flags->blankstrip_mode, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &get_flags->autocommit, 0);
		ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &get_flags->autorename, 0);
	}
}

/*****************************************************************************/

extern void RISapp_report_ss_error_from_net(
    arc_s                       *arc,
    struct ris_cliapp_buf_report_ss_error *error)
{

	int i;

    if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
    {
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->risca.sqlabc, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->risca.sqlcode, 0);
        for (i=0; i<8; i++)
        {
            ARC_convert(arc, FROM_NET, CONVERT_INTEGER,
                &error->risca.sqlerrd[i], 0);
        }
    }
    if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags))
    {
        ARC_convert(arc, FROM_NET, CONVERT_DATA, error->risca.sqlcaid,8);
        ARC_convert(arc, FROM_NET, CONVERT_DATA, error->risca.sqlerrp,8);
        ARC_convert(arc, FROM_NET, CONVERT_DATA, error->risca.sqlwarn,8);
        ARC_convert(arc, FROM_NET, CONVERT_DATA, error->risca.sqlext,8);
        ARC_convert(arc, FROM_NET, CONVERT_DATA, error->risca.sqlerrm.sqlerrmc,
            error->risca.sqlerrm.sqlerrml);
    }

    if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
    {
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
    }

    if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
    {
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->risstmt, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->dbstmt, 0);

        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->risstmt_len, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->dbstmt_len, 0);
    }

    if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags))
    {
        /* risstmt */
        ARC_convert(arc, FROM_NET, CONVERT_DATA,
            (error->data + error->risstmt), error->risstmt_len);

        /* dbstmt */
        ARC_convert(arc, FROM_NET, CONVERT_DATA,
            (error->data + error->dbstmt), error->dbstmt_len);

    }
}
/*****************************************************************************/

extern void RISapp_get_ss_names_from_net(
    arc_s               		        *arc,
    struct ris_cliapp_buf_get_ss_names 	*get_ss_names)
{
	ARC_CONVERT_INTEGER(arc, FROM_NET, &get_ss_names->ss_count);
    ARC_CONVERT_DATA(arc, FROM_NET, get_ss_names->data,
        get_ss_names->ss_count * RIS_MAX_ID_SIZE);
}

/*****************************************************************************/

extern void RISapp_get_ss_def_from_net(
    arc_s          		             *arc,
    struct ris_cliapp_buf_get_ss_def *get_ss_def)
{
	ARC_CONVERT_INTEGER(arc, FROM_NET, &get_ss_def->ss_count);
    ARC_CONVERT_DATA(arc, FROM_NET, get_ss_def->data, 
		get_ss_def->ss_count * RIS_MAX_ID_SIZE);

}
/*****************************************************************************/

extern void RISapp_get_sch_in_trans_from_net(
	arc_s					*arc,
	struct ris_cliapp_buf_get_sch_in_trans	*get_sch_in_trans)
{
	ARC_CONVERT_INTEGER(arc, FROM_NET, &get_sch_in_trans->sch_count);
	ARC_CONVERT_DATA(arc, FROM_NET, get_sch_in_trans->data, 
		get_sch_in_trans->sch_count * RIS_MAX_ID_SIZE);
}

/*****************************************************************************/
extern void RISapp_error_from_net(
    arc_s                       *arc,
    struct ris_cliapp_buf_error *error)
{
    int i;
    register short  *pos;

	/* risca */
    if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
    {
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->risca.sqlabc, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->risca.sqlcode, 0);
        for (i=0; i<8; i++)
        {
            ARC_convert(arc, FROM_NET, CONVERT_INTEGER,
                &error->risca.sqlerrd[i], 0);
        }
    }
    if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags))
    {
        ARC_convert(arc, FROM_NET, CONVERT_DATA, error->risca.sqlcaid,8);
        ARC_convert(arc, FROM_NET, CONVERT_DATA, error->risca.sqlerrp,8);
        ARC_convert(arc, FROM_NET, CONVERT_DATA, error->risca.sqlwarn,8);
        ARC_convert(arc, FROM_NET, CONVERT_DATA, error->risca.sqlext,8);
        ARC_convert(arc, FROM_NET, CONVERT_DATA, error->risca.sqlerrm.sqlerrmc,
            error->risca.sqlerrm.sqlerrml);
    }

	/* dbca */
    if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
    {
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
    }

    if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
    {
        /* clear stmt count */
        pos = (short *)(error->data + error->clear_stmt_list);
        for (i = 0; i < error->clear_stmt_count; i++)
        {
            ARC_convert(arc, FROM_NET, CONVERT_SHORT, pos, 0);
            pos += sizeof(short);
        }

        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->risstmt, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->dbstmt, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->eot_schname_list, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->clear_stmt_list, 0);

        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->clear_stmt_count, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->eot_schname_count, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->risstmt_len, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->dbstmt_len, 0);
        ARC_convert(arc, FROM_NET, CONVERT_INTEGER, &error->test_completion, 0);
    }

    if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags))
    {
        /* risstmt */
        ARC_convert(arc, FROM_NET, CONVERT_DATA,
            (error->data + error->risstmt), error->risstmt_len);

        /* dbstmt */
        ARC_convert(arc, FROM_NET, CONVERT_DATA,
            (error->data + error->dbstmt), error->dbstmt_len);

        /* eot schname list */
        ARC_convert(arc, FROM_NET, CONVERT_DATA,
            (error->data+error->eot_schname_list),
            error->eot_schname_count*RIS_MAX_ID_SIZE);
    }
}
/*****************************************************************************/
/********************************** BLOB *************************************/
/*****************************************************************************/

extern void RISapp_execute_blob_to_net(
	arc_s					*arc,
	struct ris_appcli_buf_exec_blob		*exec_blob)
{
	ARC_CONVERT_CHARACTER(arc, TO_NET, &exec_blob->more_to_follow);
	ARC_CONVERT_CHARACTER(arc, TO_NET, &exec_blob->file_used);

	if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags))
	{
		ARC_convert(arc, TO_NET, CONVERT_SHORT, &exec_blob->blob_col_pos, 0);
		ARC_convert(arc, TO_NET, CONVERT_INTEGER, &exec_blob->xfcount, 0);
	}
}

/*****************************************************************************/

extern void RISapp_fetch_blob_to_net(
	arc_s                           *arc,
	struct ris_appcli_fetch_blob        *fetch_blob)
{
	ARC_SHORT_TO_NET(arc, &fetch_blob->blob_col_pos);
	ARC_CHARACTER_TO_NET(arc, &fetch_blob->file_used);
}

/*****************************************************************************/

extern void RISapp_net_to_fetch_blob(
	arc_s                           *arc,
	struct ris_cliapp_fetch_blob        *fetch_blob)
{
	ARC_NET_TO_INTEGER(arc, &fetch_blob->xfercount);
	ARC_NET_TO_CHARACTER(arc, &fetch_blob->more_to_follow);
}

/*****************************************************************************/

extern void RISapp_blob_struct_to_net(
	arc_s					*arc,
	ris_blob				*blob_struct)
{
	ARC_CONVERT_INTEGER(arc, TO_NET, &blob_struct->file_offset);
	ARC_CONVERT_INTEGER(arc, TO_NET, &blob_struct->array_size);
	ARC_CONVERT_INTEGER(arc, TO_NET, &blob_struct->input_len);
	ARC_CONVERT_INTEGER(arc, TO_NET, &blob_struct->output_len);
	ARC_CONVERT_CHARACTER(arc, TO_NET, &blob_struct->file_used);
}
/*****************************************************************************/
extern void RISapp_execute_deferred_to_net(
	arc_s 					*arc,
	sqlda					*in_sqlda,
	struct ris_appcli_buf_exec		*exec_deferred)
{
	/* input data */
	if(in_sqlda)
	{
		convert_parms (arc, TO_NET, in_sqlda->sqld, in_sqlda->sqlvar, 
			exec_deferred->data);
	}
}

/*****************************************************************************/
extern void RISapp_fetch_buf_to_net(
	arc_s 					*arc,
	struct ris_appcli_buf_fetch		*fetch)
{
	ARC_CONVERT_INTEGER(arc, TO_NET, &fetch->row_count);
	ARC_CONVERT_INTEGER(arc, TO_NET, &fetch->out_data);
	ARC_CONVERT_SHORT(arc, TO_NET, &fetch->blob_count);
	ARC_CONVERT_INTEGER(arc, TO_NET, &fetch->file_names);

	/*
	** The actual blob data should be converted
	** before it is put on network buffer
	*/
}

/*****************************************************************************/

