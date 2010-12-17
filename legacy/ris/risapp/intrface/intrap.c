/* Do not alter this SPC information: $Revision: 1.1.57.1 $ */
/*
**	NAME:							intrap.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					7/92
**	ABSTRACT:
**	
**	REVISION HISTORY:

TDM:11/10/93:   changed 'sqlda' functions to use sqln instead of sqld to
                determine the number of sqlvars to allocate

*/
 
#define RAP_GLOBAL_DEFINE

/*
**	INCLUDES
*/
#include <ctype.h>
#include <time.h>
#include <sys/types.h>
#include "riscom.h"
#include "rismem.h"
#include "ris_inf.h"
#include "intrface.h"
#if defined(WIN32) || defined(DOS)
#include <process.h>
#endif

/*
**	DEFINES
*/
#define ADDRESS(a)	((a) ? 1 : 0)
#define INDICATOR(i) ((i) < 0 ? -1 : 0 )

/*
**	TYPES
*/
typedef struct blob_fetch_s
{
	ris_blob blob;
	char filename[RIS_MAX_PATH_SIZE];
} blob_fetch_s;

/*
**	FUNCTION PROTOTYPES
*/
#define intrap_c
#include "appver.prt"
#include "comalloc.prt"
#include "comdate.prt"
#include "comwrap.prt"
#include "comrap.prt"
#include "intrap.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
static  sqlda		last_output;
static  blob_fetch_s	*blob_fetch = NULL;

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISAPI RISXrap_initialize()
{
	int		valid_rap_file;
	char	*mode;
	time_t	current_time;

	valid_rap_file = RIScom_read_rap_file(&RIS_RAP_options, 1);

	if (valid_rap_file && RIS_RAP_options.filename[0])
	{
		mode = RIS_RAP_options.overwrite_file ? "w" : "a";
		if ((RIS_RAP = RIScom_fopen(RIS_RAP_options.filename, mode)) != NULL)
		{
			/*
			** Get version information and assign global variables
			** Ignore if any errors: RISinitialize() will catch it anyway
			*/
			RISapp_init_version();

			time(&current_time);

			fprintf(RIS_RAP, "RIS VERSION:%s\n", RIS_app_version);
			fprintf(RIS_RAP, "TIMESTAMP:%s", ctime(&current_time));
			fprintf(RIS_RAP,"----------\n");
		}
	}
}

/******************************************************************************/

extern void RISAPI RISXrap_print_input_sqlda(
	FILE	*fp,
	sqlda	*input)
{
	int i;

	if (!input)
	{
		return;
	}

	fprintf(fp, "n:%d\n", input->sqln);
	fprintf(fp, "d:%d\n", input->sqld);
	fprintf(fp, "var:0x%x\n", input->sqlvar);
	if (input->sqlvar && input->sqln > 0)
	{
		for (i = 0; i < input->sqln; i++)
		{
			fprintf(fp, "null:%d\n", input->sqlvar[i].sqlnull);
			fprintf(fp, "ind:0x%x\n", input->sqlvar[i].sqlind);
			if (input->sqlvar[i].sqlnull && input->sqlvar[i].sqlind)
			{
				fprintf(fp, "*ind:%d\n", *input->sqlvar[i].sqlind);
			}
			if (!input->sqlvar[i].sqlind || *input->sqlvar[i].sqlind >= 0)
			{
				fprintf(fp, "type:%d\n", input->sqlvar[i].sqltype);
				fprintf(fp, "len:%d\n", input->sqlvar[i].sqllen);
				if (input->sqlvar[i].sqltype == RIS_DECIMAL)
				{
					fprintf(fp, "scale:%d\n", input->sqlvar[i].sqlscale);
				}
				fprintf(fp, "data:0x%x\n", input->sqlvar[i].sqldata);
				switch(input->sqlvar[i].sqltype)
				{
					case RIS_CHARACTER:
						fprintf(fp, "start *data:\n%s\nstop *data:\n",
							input->sqlvar[i].sqldata);
						break;

					case RIS_SMALLINT:	
						fprintf(fp, "*data:%d\n",
							*(short*)input->sqlvar[i].sqldata);
						break;

					case RIS_INTEGER:
						fprintf(fp, "*data:%d\n",
							*(int*)input->sqlvar[i].sqldata);
						break;

					case RIS_REAL:
						fprintf(fp, "*data:%.7g\n",
							*(float*)input->sqlvar[i].sqldata);
						break;

					case RIS_DOUBLE:
						fprintf(fp, "*data:%.15lg\n",
							*(double*)input->sqlvar[i].sqldata);
						break;

					case RIS_DECIMAL:
						fprintf(fp, "*data:%s\n", input->sqlvar[i].sqldata);
						break;

					case RIS_DATETIME:
					case RIS_INTERVAL:
					{
						dtime *dtp;
						char	index,start,stop;

						fprintf(fp, "*data:");

						dtp = (dtime *)input->sqlvar[i].sqldata;

						start = DT_YEAR;
						stop = DT_SECOND;
						for (index = start; index >= stop; index--)
						{
							fprintf(fp, "%02d", dtp->data[index]);
							if (index > stop)
								fprintf(fp, "%c", RIScom_dtseparator(index));
						}

						fprintf(fp, "\n");
						break;
					}

					case RIS_BLOB:
					case RIS_TEXT:
					{
						ris_blob *blob = (ris_blob *)input->sqlvar[i].sqldata;

						fprintf(fp, "file_used:%d\n", blob->file_used);
						if (blob->file_used)
						{
							fprintf(fp, "file_offset:%d\n", blob->file_offset);
							fprintf(fp, "filename:0x%x\n",
								blob->filename);
							if (blob->filename)
							{
								fprintf(fp, "*filename:%s\n",
									blob->filename);
							}
						}
						else
						{
							unsigned int j;

							fprintf(fp, "array_size:%d\n", blob->array_size);
							fprintf(fp, "array:0x%x\n", blob->array);
							if (blob->array)
							{
								fprintf(fp, "*array:");
								for (j = 0; j < blob->array_size; j++)
								{
									if (j % 35 == 0)
									{
										fprintf(fp, "\n");
									}
									fprintf(fp, "%02X", blob->array[j]);
								}
								fprintf(fp, "\n");
							}
						}
						break;
					}

					case RIS_UNKNOWN_TYPE:
					default:
					{
						int j;

						fprintf(fp, "start *data:\n");
						for (j=0; j<input->sqlvar[i].sqllen; ++j)
						{
							fprintf(fp, "0x%x\n", input->sqlvar[i].sqldata[j]);
						}
						fprintf(fp, "stop *data:\n");
						break;
					}
				}
			}
		}
	}
}

/******************************************************************************/

extern void RISAPI RISXrap_print_output_sqlda(
	FILE	*fp,
	sqlda	*output)
{
	int i;

	if (!output)
	{
		return;
	}

	fprintf(fp, "n:%d\n", output->sqln);
	fprintf(fp, "d:%d\n", output->sqld);
	fprintf(fp, "var:0x%x\n", output->sqlvar);
	if (output->sqlvar && output->sqln > 0)
	{
		for (i = 0; i < output->sqln; i++)
		{
			fprintf(fp, "null:%d\n", output->sqlvar[i].sqlnull);
			fprintf(fp, "ind:0x%x\n", output->sqlvar[i].sqlind);
			fprintf(fp, "type:%d\n", output->sqlvar[i].sqltype);
			fprintf(fp, "len:%d\n", output->sqlvar[i].sqllen);
			if (output->sqlvar[i].sqltype == RIS_DECIMAL)
			{
				fprintf(fp, "scale:%d\n", output->sqlvar[i].sqlscale);
			}
			fprintf(fp, "data:0x%x\n", output->sqlvar[i].sqldata);
			if (output->sqlvar[i].sqldata)
			{
				if (output->sqlvar[i].sqltype == RIS_BLOB ||
					output->sqlvar[i].sqltype == RIS_TEXT)
				{
					ris_blob *blob = (ris_blob *)output->sqlvar[i].sqldata;

					fprintf(fp, "file_used:%d\n", blob->file_used);
					if (blob->file_used)
					{
						fprintf(fp, "file_offset:%d\n", blob->file_offset);
						fprintf(fp, "filename:0x%x\n", blob->filename);
						if (blob->filename)
						{
							fprintf(fp, "*filename:%s\n",blob->filename);
						}
					}
					else
					{
						fprintf(fp, "array_size:%d\n", blob->array_size);
						fprintf(fp, "array:0x%x\n", blob->array);
					}
				}
			}
		}
	}
}

/******************************************************************************/

extern void RISAPI RISXrap_print_describe_sqlda(
	FILE	*fp,
	sqlda	*data)
{
	if (!data)
	{
		return;
	}

	fprintf(fp, "n:%d\n", data->sqln);
	fprintf(fp, "d:%d\n", data->sqld);
	fprintf(fp, "var:0x%x\n", data->sqlvar);
}

/******************************************************************************/

extern void RISAPI RISXrap_print_test_sqlda(
	FILE	*fp,
	sqlda	*input)
{
	int i;

	if (!input)
	{
		return;
	}

	fprintf(fp, "n:%d\n", input->sqln);
	fprintf(fp, "d:%d\n", input->sqld);
	fprintf(fp, "var:0x%x\n", input->sqlvar);
	if (input->sqlvar && input->sqln > 0)
	{
		for (i = 0; i < input->sqln; i++)
		{
			fprintf(fp, "type:%d\n", input->sqlvar[i].sqltype);
			fprintf(fp, "data:0x%x\n", input->sqlvar[i].sqldata);
			if (input->sqlvar[i].sqldata)
			{
				switch(input->sqlvar[i].sqltype)
				{
					case RIS_CHARACTER:
						fprintf(fp, "start *data:\n%s\nstop *data:\n",
							input->sqlvar[i].sqldata);
						break;
		
					case RIS_INTEGER:
						fprintf(fp, "*data:%d\n",
							*(int*)input->sqlvar[i].sqldata);
						break;
				}
			}
		}
	}
}

/******************************************************************************/

extern void RISAPI RISXrap_print_client_parms(
    FILE                *fp,
    client_parms    *parms)
{
    if (!parms)
    {
        return;
    }
    fprintf(fp, "protocol:%c\n", parms->protocol);
    fprintf(fp, "address:%s\n", parms->address);
    fprintf(fp, "username:%s\n", parms->username);
    fprintf(fp, "password:%s\n", parms->password);
}

/******************************************************************************/

extern void RISAPI RISXrap_print_schema_file_parms(
	FILE				*fp,
	schema_file_parms	*parms)
{
	if (!parms)
	{
		return;
	}
	fprintf(fp, "protocol:%c\n", parms->protocol);
	fprintf(fp, "address:%s\n", parms->address);
	fprintf(fp, "username:%s\n", parms->username);
	fprintf(fp, "password:%s\n", parms->password);
	fprintf(fp, "filename:%s\n", parms->filename);
}

/******************************************************************************/

static int compare_blob(
	ris_blob *b1,
	ris_blob *b2)
{
	if (b1->file_used != b2->file_used)
	{
		return 1;
	}

	if (b1->file_used) /* which implies b2->file_used */
	{
		if (ADDRESS(b1->filename) != ADDRESS(b2->filename))
		{
			return 1;
		}
		if (ADDRESS(b1->filename)) /* which implies b2->filename */
		{
			if (strcmp(b1->filename, b2->filename))
			{
				return 1;
			}
		}
		if (b1->file_offset != b2->file_offset)
		{
			return 1;
		}
	}
	else /* array used */
	{
		if (ADDRESS(b1->array) != ADDRESS(b2->array))
		{
			return 1;
		}
		if (b1->array_size != b2->array_size)
		{
			return 1;
		}
	}
	return 0;
}

/******************************************************************************/

static int compare_sqlvar(
	sqlvar *s1,
	sqlvar *s2)
{
	if (s1->sqlnull != s2->sqlnull)
	{
		return 1;
	}

	if (ADDRESS(s1->sqlind) != ADDRESS(s2->sqlind))
	{
		return 1;
	}

	if (s1->sqltype != s2->sqltype)
	{
		return 1;
	}

	if (s1->sqllen != s2->sqllen)
	{
		return 1;
	}

	if (s1->sqltype == RIS_DECIMAL)
	{
		if (s1->sqlscale != s2->sqlscale)
		{
			return 1;
		}
	}

	if (ADDRESS(s1->sqldata) != ADDRESS(s2->sqldata))
	{
		return 1;
	}

	if (ADDRESS(s1->sqldata)) /* which implies ADDRESS(s2->sqldata) */
	{
		if (s1->sqltype == RIS_BLOB ||
			s1->sqltype == RIS_TEXT)
		{
			if (compare_blob((ris_blob *)s1->sqldata, (ris_blob *)s2->sqldata))
			{
				return 1;
			}
		}
	}
	return 0;
}

/******************************************************************************/

static int compare_sqlda(
	sqlda *s1,
	sqlda *s2)
{
	int i;

	if (ADDRESS(s1) != ADDRESS(s2))
	{
		return 1;
	}

	if (ADDRESS(s1)) /* which implies ADDRESS(s2) */
	{
		if (s1->sqln != s2->sqln)
		{
			return 1;
		}

		if (s1->sqld != s2->sqld)
		{
			return 1;
		}

		if (ADDRESS(s1->sqlvar) != ADDRESS(s2->sqlvar))
		{
			return 1;
		}

		if (ADDRESS(s1->sqlvar)) /* which implies ADDRESS(s2->sqlvar) */
		{
			for (i = 0; i < s1->sqln; i++)
			{
				if (compare_sqlvar(&(s1->sqlvar[i]), &(s2->sqlvar[i])))
				{
					return 1;
				}
			}
		}
	}
	return 0;
}

/******************************************************************************/

extern int RISAPI RISXrap_compare_fetch(
	int		id,
	sqlda	*output,
	int		one_row_only)
{
	int					i;
	int					blob_count = 0;
	int					return_sts = 0;
	static  int			last_id = 0;
	static  int			last_one_row_only = 0;
	static  int			max_sqln = 0;
	static  int			blob_fetch_count = 0;

	if (id != last_id)
	{
		return_sts = 1;
	}
	else if (one_row_only != last_one_row_only)
	{
		return_sts = 1;
	}
	else if (compare_sqlda(output, &last_output))
	{
		return_sts = 1;
	}

	if (return_sts == 1)
	{
		if (output->sqln > (short)max_sqln)
		{
			if (max_sqln)
			{
				max_sqln = output->sqln;
				last_output.sqlvar =
					(sqlvar *)SYS_REALLOC((char *)last_output.sqlvar,
					max_sqln * sizeof(sqlvar));
			}
			else
			{
				max_sqln = output->sqln;
				last_output.sqlvar = (sqlvar *)SYS_MALLOC(max_sqln*sizeof(sqlvar));
			}
		}

		last_id = id;
		last_one_row_only = one_row_only;
		last_output.sqln = output->sqln;
		last_output.sqld = output->sqld;
		for (i = 0; i < output->sqln; i++)
		{
			memcpy(&last_output.sqlvar[i], &output->sqlvar[i], sizeof(sqlvar));
			if (output->sqlvar[i].sqltype == RIS_BLOB ||
				output->sqlvar[i].sqltype == RIS_TEXT)
			{
				blob_count++;
			}
		}

		if (blob_count > blob_fetch_count)
		{
			blob_fetch_count = blob_count;
			if (blob_fetch)
			{
				blob_fetch = (blob_fetch_s *)
					SYS_REALLOC((char *)blob_fetch,
						blob_fetch_count * sizeof(blob_fetch_s));
			}
			else
			{
				blob_fetch = (blob_fetch_s *) SYS_MALLOC(blob_fetch_count * sizeof(blob_fetch_s));
			}
		}

		blob_count = 0;
		for (i = 0; i < output->sqln; i++)
		{
			if (output->sqlvar[i].sqltype == RIS_BLOB ||
				output->sqlvar[i].sqltype == RIS_TEXT)
			{
				memcpy(&blob_fetch[blob_count].blob, output->sqlvar[i].sqldata,
					sizeof(ris_blob));
				strcpy(blob_fetch[blob_count].filename,
					((ris_blob *)output->sqlvar[i].sqldata)->filename);
				blob_fetch[blob_count].blob.filename = 
					blob_fetch[blob_count].filename;
				last_output.sqlvar[i].sqldata = (char *)&blob_fetch[blob_count];
				blob_count++;
			}
		}
	}

	return return_sts;
}

/******************************************************************************/
extern void intrap_free(
	)
{
	if (last_output.sqlvar)
		RIScom_sys_free((char *)last_output.sqlvar);
	if (blob_fetch)
		RIScom_sys_free((char *)blob_fetch);

}
