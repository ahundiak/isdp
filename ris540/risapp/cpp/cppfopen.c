/* Do not alter this SPC information: $Revision: 1.2.55.1 $ */
/*
**	NAME:							cppfopen.c
**	AUTHORS:						Prasad Challa
**	CREATION DATE:					7/91
**	ABSTRACT:
**    This function opens -I files.
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "cpp.h"
#include "commacro.h"

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
#define cppfopen_c
#include "comdebug.prt"
#include "comwrap.prt"
#include "comuni.prt"
#include "cppfopen.prt"
#include "sys.prt"



extern FILE * RIScpp_fopen(
	include_dir_list_node * list,
	char * filename)
{
	include_dir_list_node * temp=NULL;
	FILE * fop;
	char name[RIS_MAX_PATH_SIZE];

#ifdef WIN32
	/*
	** INTERNATIONALIZATION change. filename(mb) -->> tmp_filename(wide)
	*/
	wchar_t *tmp_filename;
	RIScom_multiwide(&RISwide_ptr,
			 &filename,
			 &RISwide_size,
			 MULTITOWIDE,
			 0);
			 
	tmp_filename = RISwide_ptr;

#else
	char *tmp_filename = filename;
#endif

	CPP_DBG(("\nRIScpp_fopen list=%x filename=%s\n", list, filename));

	fop = RIScom_fopen(filename, "r");
	if (fop)
	{
		return(fop);
	}
	else if(tmp_filename[0] == WIDECHAR('/') )
	{
		fop = RIScom_fopen(filename, "r");
		return(fop);
	}
	else
	{
		for(temp=list; temp; temp=temp->next)
		{
				name[0] = '\0'; 
				strcpy(name,temp->include_dir);
				CPP_DBG(("\nRIScpp_fopen: include_path:<%s>\n", name));
				strcat(name,PATH_CHAR_STR);
				strcat(name,filename);
				fop = RIScom_fopen(name, "r");
				if(fop)
				{
					return(fop);
				}
		}
	}
	return((FILE *) 0);
}
/****************************************************************************/
