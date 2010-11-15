/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							main.c
**	AUTHORS:						
**	CREATION DATE:					
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	DEFINES
*/
#define DEFINE_GLOBALS

/*
**	INCLUDES
*/
#include <stdio.h>
#include "tpg.h"

/*
**	FUNCTION PROTOTYPES
*/
#include "generate.prt"
#include "tests.prt"
#include "data.prt"
#include "msg.prt"
#include "read.prt"
#include "sys.prt"
#include "ums.prt"


/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


extern int main(
	int		argc,
	char	*argv[])
{
	int		return_sts = 0;
	char	*data_filename;

	switch(argc)
	{
		case 2:
			verbose = 0;
			data_filename = argv[1];
			break;

		case 3:
			if (strcmp(argv[1], "-v"))
			{
				fprintf(stderr, "Usage: %s [-v] datafile\n", argv[0]);
				return 1;
			}
			verbose = 1;
			data_filename = argv[2];
			break;

		default:
			fprintf(stderr, "Usage: %s [-v] datafile\n", argv[0]);
			return 1;

	}

	read_data(data_filename);
	read_ums_file();
	read_rules();
	read_err_msg_file();
	read_prod_msg_file();
	read_tok_msg_file();

	unused_prods();

	if (left_recursion())
	{
		return 1;
	}
	if (left_factor())
	{
		return 1;
	}

	generate_code();

	return_sts += write_err_msg_file();
	return_sts += write_prod_msg_file();
	return_sts += write_tok_msg_file();

	return return_sts;
}
