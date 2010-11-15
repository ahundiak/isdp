/* Do not alter this SPC information: $Revision: 1.3.27.1 $ */
/*
**	NAME:							filcksum.c
**	AUTHORS:						Sunil Murthy
**	CREATION DATE:					11/92
**	ABSTRACT:
**  	schema file read functions. (originally in FILfile.c)
**		
**	
**	REVISION HISTORY:
**
**	June 05, 1995:
**
**		TR# 439502001
**		-------------
**		When schema file is created by a client of different
**		architecture than the current client, the schema file
**		bytes need to be swapped to compute checksum. BUT, we
**		DO NOT have sufficient information to figure out, how
**		the schema file was created. So this is what we do -
**
**		1. Compute the checksum once. if it does not match -
**		2. Assume different arch. and compute again by forcing
**		   architecture conversion. Error out, if it fails.
**
**		Ashley Burns, Surjit Sahoo
*/

/*
**	DEFINES
*/

#define ACCEPT_VERSION_2_SCHEMA_FILES
#define ACCEPT_VERSION_3_SCHEMA_FILES

/*
**	INCLUDES
*/
#include "arch.h"
#include "file.h"
#include "schfile.h"

/*
**      FUNCTION PROTOTYPES
*/
#define filcksum_c
#include "filcksum.prt"
#include "comdebug.prt"
#include "comwrap.prt"
#include "comjmp.prt"
#include "filwrite.prt"
#include "sys.prt"
#include "arcswap.prt"

/******************************************************************************/

extern void RISfil_get_check_sum(
	char *buffer,
	int  convert)  /* 1 = force conversion, 0 = no conversion */
{
	int i,j;
	int line;
	char *ptr;
	union
	{
		int		word;
		char	byte[4];
	}data;

	FIL_DBG(("RISfil_get_check_sum: convert=>%d buffer=>%s", convert, buffer));

	data.word = 0;
	for (ptr = buffer, i = 0; *ptr; ptr++, i = (i+1) % 4)
	{
		data.byte[i] = *ptr;
		if (i == 3)
		{
			if (convert)
				ARC_int_swap_bytes(0, &data.word, 4);
			RISfil_checksum ^= data.word;
			data.word = 0;
		}
	}

	FIL_DBG(("At the end of 1st loop checksum=<%u>\n", RISfil_checksum));

	line = RISfil_linenum;
	if (convert)
		ARC_int_swap_bytes(0, &line, 4);

	for (ptr = (char *)&line, j = 0; j < 4; ptr++, i = (i+1) % 4, j++)
	{
		data.byte[i] = *ptr;
		if (i == 3)
		{
			if (convert)
				ARC_int_swap_bytes(0, &data.word, 4);
			RISfil_checksum ^= data.word;
			data.word = 0;
		}
	}

	FIL_DBG(("At the end of 2nd loop checksum=<%u>\n", RISfil_checksum));

	if (i > 0)
	{
		if (convert)
			ARC_int_swap_bytes(0, &data.word, 4);
		RISfil_checksum ^= data.word;
		FIL_DBG(("At the end checksum=<%u>\n", RISfil_checksum));
	}

	FIL_DBG(("RISfil_get_check_sum: returning\n"));
}

/******************************************************************************/

extern void RISfil_verify_checksum()
{
	auto	unsigned int	file_checksum;
	auto	char			buffer[LINE_BUFFER_SIZE];

	FIL_DBG(("RISfil_verify_checksum()\n"));

	if (RIScom_fgets(buffer, LINE_BUFFER_SIZE, RISfil_fp) == NULL)
	{
		/*
		**	Empty file, that's o.k.
		*/
		rewind(RISfil_fp);

		FIL_DBG(("RISfil_verify_checksum: Empty file, returning..\n"));
		return;
	}

	if (strncmp(buffer, CHECKSUM, CHECKSUM_SIZE))
	{
		READ_ERROR(RIS_E_READ_NO_CHECKSUM);
	}

	file_checksum = atoi(buffer + CHECKSUM_SIZE);

	RISfil_linenum = 0;
	RISfil_checksum = 0;

	while (1)
	{
		if (RIScom_fgets(buffer, LINE_BUFFER_SIZE, RISfil_fp) == NULL)
			break;
		RISfil_get_check_sum(buffer, 0); /* no conversion */
		RISfil_linenum++;
	}

	FIL_DBG(("\n      file_checksum:%u\n", file_checksum));
	FIL_DBG(("calculated checksum:%u\n", RISfil_checksum));

	if (file_checksum != RISfil_checksum)
	{
		/*
		** Fix for TR #439502001 (see revision history)
		**
		** Assume schema file was created by a client of different arch.
		** So, now force byte swapping and compute checksum again.
		**
		** Ashley Burns, Surjit Sahoo (June 5, 1995)
		*/

		FIL_DBG(("\nRecomputing checksum by forcing arch. conversion\n"));

		/*
		** rewind schema file and read and skip the 1st line
		** i.e. checksum line in the schema file
		*/
		rewind(RISfil_fp);
		RIScom_fgets(buffer, LINE_BUFFER_SIZE, RISfil_fp);

		RISfil_linenum = 0;
		RISfil_checksum = 0;

		while (1)
		{
			if (RIScom_fgets(buffer, LINE_BUFFER_SIZE, RISfil_fp) == NULL)
				break;
			RISfil_get_check_sum(buffer,1); /* force conversion */
			RISfil_linenum++;
		}

		FIL_DBG(("\n      file_checksum:%u\n", file_checksum));
		FIL_DBG(("calculated checksum:%u\n", RISfil_checksum));

		if (file_checksum != RISfil_checksum)
			LONGJMP(RIS_E_BAD_CHECKSUM);
	}

	rewind(RISfil_fp);
	FIL_DBG(("RISfil_verify_checksum: returning\n"));
}

/******************************************************************************/

extern void RISfil_calculate_checksum()
{
	fildb_list			*dbp;
	filsch_list		*schemap;

	FIL_DBG(("RISfil_calculate_checksum()\n"));

	RISfil_linenum = 0;
	RISfil_checksum = 0;
	RISfil_write_flag = 0;

	/*
	**	TIMESTAMP
	*/
	if (RISfil_write_next_line("%s%d\n", TIMESTAMP, RISfil_timestamp) < 0)
	{
		LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
	}

	/*
	**	DBS
	*/
	for (dbp = RISfil_db_list; dbp; dbp = dbp->next)
	{
		/*
		**	Write db to file
		*/
		RISfil_write_db(dbp->dbp);
	}

	/*
	**	SCHEMAS
	*/
	for (schemap = RISfil_schema_list; schemap; schemap = schemap->next)
	{
		/*
		**	Write schema to file
		*/
		RISfil_write_schema(schemap->schemap);
	}
	FIL_DBG(("RISfil_calculate_checksum done...\n"));
}

