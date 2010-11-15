/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utlread.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					5/87
**	ABSTRACT:
**		Reads in commands from a file.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdlib.h>
#include "util.h"

/*
**	FUNCTION PROTOTYPES
*/
#define utlread_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "comumsg.prt"
#include "comisfn.prt"
#include "utlread.prt"
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


/*****************************************************************************/

extern void RISutl_read(
	char *filename)
{
	RISutl_file_stack *fsp;
	FILE *fp;

	UTL_DBG(("RISutl_read(filename:<%s>)\n",STRING(filename)));

	/*
	**	Skip leading white space
	*/
	while (RIScom_isspace(*filename)) ++filename;

	/*
	**	check for env vars
	*/
	if (*filename == '$')
	{
		strcpy(filename, getenv(filename + 1));
	}

	if (!*filename)
	{
		LONGJMP(RISUTL_E_NO_READ_FILE);
	}

	/*
	**	open the file
	*/
	if ((fp = fopen(filename, "r")) == NULL)
	{
		LONGJMP(RISUTL_E_OPEN_READ_FILE);
	}

	/*
	**	alloc stack node to save old file
	*/
	fsp = (struct RISutl_file_stack *)malloc(sizeof(struct RISutl_file_stack));
	if (fsp == NULL)
	{
		LONGJMP(RISUTL_E_MALLOC);
	}

	fsp->file = fp;
	fsp->next = RISutl_file_tos;
	RISutl_file_tos = fsp;

	UTL_DBG(("RISutl_read:returning\n"));
}

/*****************************************************************************/

extern void RISutl_stop_read(
	int comment)
{
	struct RISutl_file_stack *fsp;

	UTL_DBG(("RISutl_stop_read(comment:%d)\n", comment));

	if (RISutl_file_tos->next == NULL)
	{
		LONGJMP(RISUTL_E_INTERNAL);
	}

	fclose(RISutl_file_tos->file);

	fsp = RISutl_file_tos;
	RISutl_file_tos = RISutl_file_tos->next;
	free(fsp);

	/* clear out buffer */
	*RISutl_buffer = '\0';

    /* print out why we stopped reading from the file */
	switch(comment)
	{
		case STOP_READ_EOF:
			RISutl_printf(MSG(RISUTL_I_STOP_READ_EOF));
			break;
		case STOP_READ_EOS:
			RISutl_printf(MSG(RISUTL_I_STOP_READ_EOS));
			break;
		case STOP_READ_ERROR:
			RISutl_printf(MSG(RISUTL_I_STOP_READ_ERROR));
			break;
	}

	UTL_DBG(("RISutl_stop_read:returning\n"));
}

/*****************************************************************************/
