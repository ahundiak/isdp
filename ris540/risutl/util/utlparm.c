/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utlparm.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**		Routines for dealing with parameters.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include "util.h"

/*
**	FUNCTION PROTOTYPES
*/
#define utlparm_c
#include "comdebug.prt"
#include "comisfn.prt"
#include "comjmp.prt"
#include "ris.prt"
#include "utlid.prt"
#include "utlparm.prt"
#include "utlmisc.prt"
#include "utlprint.prt"
#include "sys.prt"


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

extern void RISutl_parm(
	char *parm_line)
{
	int		pos,count;
	char	*cp;
	char	*err;
	char	temp[80];
	sqlda	*input;
	sqlvar	*parm = NULL;

/* The assign command can be issued in two ways :
**	<as> <number> <value>	in one line OR
**	<as>					which will cause prompting for values
*/

	UTL_DBG(("RISutl_parm(parm_line:0x%x)\n", parm));

	if (RISutl_get_stmt_id())
	{
		UTL_DBG(("RISutl_parm:returning\n"));
		return;
	}

	input = &RISutl_stmts[RISutl_stmt_id].input;
	if (!input->sqld)
	{
		RISutl_printf("There are no parameters for this statement\n");
		UTL_DBG(("RISutl_parm:returning\n"));
		return;
	}

/* Strip off the first word which will be "as" */

	for (cp=parm_line;RIScom_isalpha(*cp);++cp);

	if (!*cp)
	{
		RISutl_printf("Enter parameter number (zero-based position): ");
			
		RISutl_fgets(temp, sizeof(temp), RISutl_file_tos->file);
		if (INTERRUPTED())
		{
			return;
		}
		count = sscanf(temp, "%d", &pos);
		if (!count)
		{
			RISutl_printf("Invalid parameter number\n");
			UTL_DBG(("RISutl_parm:returning\n"));
			return;
		}
		if (pos < 0 || pos >= input->sqld)
		{
			RISutl_printf("The specified parameter number %d does not exist\n",pos);
			UTL_DBG(("RISutl_parm:returning\n"));
			return;
		}

		count = 0;
		parm = &input->sqlvar[pos];
		RISutl_printf("Enter parameter value ");
		switch(parm->sqltype)
		{
			case RIS_INTEGER:
				RISutl_printf("(INTEGER): ");
				RISutl_fgets(temp, sizeof(temp), RISutl_file_tos->file);
				if (INTERRUPTED())
				{
					return;
				}
				count = sscanf(temp,"%d",(int *)parm->sqldata);
			break;
			case RIS_SMALLINT:
				RISutl_printf("(SMALLINT): ");
				RISutl_fgets(temp, sizeof(temp), RISutl_file_tos->file);
				if (INTERRUPTED())
				{
					return;
				}
				count = sscanf(temp,"%d",(short *)parm->sqldata);
			break;
			case RIS_DOUBLE:
				RISutl_printf("(DOUBLE): ");
				RISutl_fgets(temp, sizeof(temp), RISutl_file_tos->file);
				if (INTERRUPTED())
				{
					return;
				}
				count = sscanf(temp,"%lg",(double *)parm->sqldata);
			break;
			case RIS_REAL:
				RISutl_printf("(REAL): ");
				RISutl_fgets(temp, sizeof(temp), RISutl_file_tos->file);
				if (INTERRUPTED())
				{
					return;
				}
				count = sscanf(temp,"%g",(float *)parm->sqldata);
			break;
			case RIS_CHARACTER:
			case RIS_DECIMAL:
				{
					if (parm->sqltype == RIS_CHARACTER)
					{
						RISutl_printf("(CHAR(%d)): ",parm->sqllen);
					}
					else
					{
						RISutl_printf("(DECIMAL(%d,",parm->sqllen - 3);
						if (parm->sqlscale == RIS_ANY_SCALE)
							RISutl_printf("*)): ");
						else
							RISutl_printf("%d)): ",parm->sqlscale);
					}
					RISutl_fgets(parm->sqldata, parm->sqllen + 1,
						RISutl_file_tos->file);
					if (INTERRUPTED())
					{
						return;
					}
					count = strlen(parm->sqldata);
				}
				break;
			case RIS_DATETIME:
				RISutl_printf("TIMESTAMP(yyyy-mm-dd:hh24:mm:ss):");
				RISutl_fgets(temp, sizeof(temp), RISutl_file_tos->file);
				if (INTERRUPTED())
				{
					return;
				}
				err = RISascii_to_datetime((datetime *)parm->sqldata, temp,
					"yyyy-mm-dd:hh24:nn:ss");
				if (err)
				{
					RISutl_printf("Invalid timestamp syntax:%s\n", err);
					UTL_DBG(("RISutl_parm:returning\n"));
					return;
				}
				count = 1;
				break;
			case RIS_UNKNOWN_TYPE:
				RISutl_printf("(UNKNOWN_TYPE): ");
				RISutl_fgets(temp, sizeof(temp), RISutl_file_tos->file);
				if (INTERRUPTED())
				{
					return;
				}
				count = sscanf(temp,"%s",parm->sqldata);
				break;

			default:
				LONGJMP(RISUTL_E_INVALID_SQLTYPE);

			break;
		}
	}
	else
	{
		while (RIScom_isspace(*cp)) ++cp;
		if (!*cp)
		{
			RISutl_printf("parameter number (position) missing\n");

			UTL_DBG(("RISutl_parm:returning\n"));
			return;
		}
		count = sscanf(cp,"%d",&pos);
		if (!count)
		{
			RISutl_printf("Invalid parameter number\n");
			UTL_DBG(("RISutl_parm:returning\n"));
			return;
		}
		if (pos < 0 || pos >= input->sqld)
		{
			RISutl_printf("The specified parameter number %d does not exist\n",pos);
			UTL_DBG(("RISutl_parm:returning\n"));
			return;
		}

		while (RIScom_isdigit(*cp)) ++cp;

		count = 0;
		parm = &input->sqlvar[pos];
		switch(parm->sqltype)
		{
			case RIS_INTEGER:
				count = sscanf(cp,"%d",(int *)parm->sqldata);
			break;
			case RIS_SMALLINT:
				count = sscanf(cp,"%d",(short *)parm->sqldata);
			break;
			case RIS_DOUBLE:
				count = sscanf(cp,"%lg",(double *)parm->sqldata);
			break;
			case RIS_REAL:
				count = sscanf(cp,"%g",(float *)parm->sqldata);
			break;
			case RIS_CHARACTER:
			case RIS_DECIMAL:
			case RIS_UNKNOWN_TYPE:
				while (RIScom_isspace(*cp)) ++cp;
				strncpy(parm->sqldata,cp,parm->sqllen);
				if (parm->sqldata[0]) count = 1;
				break;
			case RIS_DATETIME:
				err = RISascii_to_datetime((datetime *)parm->sqldata, cp,
					"yyyy-mm-dd:hh24:nn:ss");
				if (err)
				{
					RISutl_printf("Invalid timestamp syntax:%s\n", err);
					UTL_DBG(("RISutl_parm:returning\n"));
					return;
				}
				count = 1;
				break;
			default:
				LONGJMP(RISUTL_E_INVALID_SQLTYPE);

			break;
		}
	}
	if (!count)
	{
		RISutl_printf("no value entered or value given is incompatible with parameter type\n");
	}
	else
	{
		*parm->sqlind = 0;
	}
	UTL_DBG(("RISutl_parm:returning\n"));
}

/******************************************************************************/

extern void RISutl_show_input_parms(
	void)
{
	int		i;
	char	temp[80];
	sqlda	*input;

	UTL_DBG(("RISutl_show_input_parms()\n"));

	if (RISutl_get_stmt_id())
	{
		UTL_DBG(("RISutl_show_input_parms:returning\n"));
		return;
	}
	RISutl_printf("\tParameters for current statement\n");
	RISutl_printf("\tPARAM NUMBER\t\tVALUE\n");
	RISutl_printf("\t------------\t\t-----\n");
	RISutl_printf("\n");

	input = &RISutl_stmts[RISutl_stmt_id].input;
	for (i=0;i < input->sqld;++i)
	{
		RISutl_printf("\t%-12d\t\t",i);
		if (*input->sqlvar[i].sqlind >= 0)
		{
			switch (input->sqlvar[i].sqltype)
			{
				case RIS_CHARACTER:
				case RIS_UNKNOWN_TYPE:
					RISutl_printf("'%s'\n",input->sqlvar[i].sqldata);
				break;
				case RIS_INTEGER:
					RISutl_printf("%d\n",*(int*)input->sqlvar[i].sqldata);
				break;
				case RIS_DOUBLE:
					RISutl_printf("%.15lg\n",*(double*)input->sqlvar[i].sqldata);
				break;
				case RIS_SMALLINT:
					RISutl_printf("%d\n",*(short*)input->sqlvar[i].sqldata);
				break;
				case RIS_REAL:
					RISutl_printf("%.7g\n",*(float*)input->sqlvar[i].sqldata);
				break;
				case RIS_DECIMAL:
					RISutl_printf("%s\n",input->sqlvar[i].sqldata);
				break;
				case RIS_DATETIME:
					RISdatetime_to_ascii((datetime*)input->sqlvar[i].sqldata,
						temp, "yyyy-mm-dd:hh24:nn:ss");
					RISutl_printf("%s\n", temp);
					break;
				default:
					RISutl_printf("unknown type: %d\n", input->sqlvar[i].sqltype);
				break;
			}
		}
		else
		{
			RISutl_printf("null\n");
		}
	}

	UTL_DBG(("RISutl_show_input_parms:returning\n"));
}

/******************************************************************************/
