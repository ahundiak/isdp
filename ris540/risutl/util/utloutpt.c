/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utloutpt.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					1/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "util.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define utloutpt_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "utloutpt.prt"
#include "ris.prt"
#include "utlprint.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISutl_output_ris_error(
	char *ris_error)
{
	UTL_DBG(("RISutl_output_ris_error(ris_error:0x%x)\n", ris_error));

	RISutl_printf("%s\n", ris_error);

	UTL_DBG(("RISutl_output_ris_error:returning\n"));
}

/******************************************************************************/

static void output_schema_error_info(
	ris_schema_error_info	*schema_error)
{
	RISutl_printf("\n");
	RISutl_printf(MSG(RISUTL_I_OUTPUT_SCH_ERR_INFO_1), schema_error->schname);
	RISutl_printf(MSG(RISUTL_I_OUTPUT_SCH_ERR_INFO_2), schema_error->schrisca.sqlcode);
	RISutl_printf(MSG(RISUTL_I_OUTPUT_SCH_ERR_INFO_3),
		schema_error->schrisca.sqlerrm.sqlerrml);
	if (schema_error->schrisca.sqlerrm.sqlerrml)
	{
		RISutl_printf(MSG(RISUTL_I_OUTPUT_SCH_ERR_INFO_4),
			schema_error->schrisca.sqlerrm.sqlerrmc);
	}
	if (schema_error->schrisca.sqlstmt)
	{
		RISutl_printf(MSG(RISUTL_I_OUTPUT_SCH_ERR_INFO_5),
			schema_error->schrisca.sqlstmt);
	}

	RISutl_printf(MSG(RISUTL_I_OUTPUT_SCH_ERR_INFO_6), schema_error->schdbca.sqlcode);
	RISutl_printf(MSG(RISUTL_I_OUTPUT_SCH_ERR_INFO_7),
		schema_error->schdbca.sqlerrm.sqlerrml);
	if (schema_error->schdbca.sqlerrm.sqlerrml)
	{
		RISutl_printf(MSG(RISUTL_I_OUTPUT_SCH_ERR_INFO_8),
			schema_error->schdbca.sqlerrm.sqlerrmc);
	}
	if (schema_error->schdbca.sqlstmt)
	{
		RISutl_printf(MSG(RISUTL_I_OUTPUT_SCH_ERR_INFO_9), schema_error->schdbca.sqlstmt);
	}
	RISutl_printf("\n");
}

/******************************************************************************/

extern void	RISutl_output_ss_error(
	ris_superschema_error_info	*ss_error)
{
	int ss_cnt;

	UTL_DBG(("RISutl_output_ss_error(ss_error:0x%x)\n", ss_error));

	RISutl_printf(MSG(RISUTL_I_OUTPUT_SS_ERROR_1));
	output_schema_error_info(&ss_error->primary);

	for (ss_cnt = 0; ss_error->secondary[ss_cnt].schname[0]; ss_cnt++)
	{
		RISutl_printf(MSG(RISUTL_I_OUTPUT_SS_ERROR_1));
		output_schema_error_info(&ss_error->secondary[ss_cnt]);
	}

	UTL_DBG(("RISutl_output_ss_error:returning\n"));
}

/*****************************************************************************/

extern void RISutl_output_data(
	sqlda *data)
{
	int		i,j;
	int		max_sqlnamel;
	char	temp[80];

	UTL_DBG(("RISutl_output_data(data:0x%x)\n", data));

	RISutl_printf("\n");

	if (RISutl_testbed_output)
	{
		max_sqlnamel = RIS_MAX_ID_SIZE - 1;
	}
	else
	{
		for (i = 0, max_sqlnamel = 0; i < data->sqld; i++)
		{
			if (data->sqlvar[i].sqlname.sqlnamel > max_sqlnamel)
			{
				max_sqlnamel = data->sqlvar[i].sqlname.sqlnamel;
			}
		}
		max_sqlnamel++;
	}

	for (i = 0; i < data->sqld; i++)
	{
		for (j = 0; j < data->sqlvar[i].sqlname.sqlnamel; j++)
		{
			RISutl_printf("%c", data->sqlvar[i].sqlname.sqlnamec[j]);
		}
		for (;j < max_sqlnamel; j++)
		{
			RISutl_printf(" ");
		}
		RISutl_printf(": ");

		/* Check if value is NULL */

		if (*data->sqlvar[i].sqlind < 0)
		{
			RISutl_printf ("NULL\n");
			continue;
		}

		switch(data->sqlvar[i].sqltype)
		{
			case RIS_UNKNOWN_TYPE:
				RISutl_printf(MSG(RISUTL_I_UNKNOWN_TYPE));
				for (j = 0; j < data->sqlvar[i].sqllen; ++j)
				{
					RISutl_printf("0x%x ", data->sqlvar[i].sqldata[j]);
				}
				break;
			case RIS_CHARACTER:
				RISutl_printf("'%s'", data->sqlvar[i].sqldata);
				break;
			case RIS_SMALLINT:	
				RISutl_printf("%d", *(short*)data->sqlvar[i].sqldata);
				break;
			case RIS_INTEGER:
				RISutl_printf("%d", *(int*)data->sqlvar[i].sqldata);
				break;
			case RIS_REAL:
				RISutl_printf("%.7g", *(float*)data->sqlvar[i].sqldata);
				break;
			case RIS_DOUBLE:
				RISutl_printf("%.15lg", *(double*)data->sqlvar[i].sqldata);
				break;
			case RIS_DECIMAL:
				RISutl_printf("%s", data->sqlvar[i].sqldata);
				break;
			case RIS_DATETIME:
				if (RISdatetime_to_ascii((datetime*)data->sqlvar[i].sqldata,
					temp, "yyyy-mm-dd:hh24:nn:ss"))
				{
					RISutl_printf(MSG(RISUTL_I_INV_TIMESTAMP));
				}
				else
				{
					RISutl_printf("%s", temp);
				}
				break;
			default:
				break;
		}
		RISutl_printf("\n");
	}

	UTL_DBG(("RISutl_output_data:returning\n"));
}

/******************************************************************************/
