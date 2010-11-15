/* Do not alter this SPC information: $Revision: 1.4.51.1 $ */
/*
**	NAME:							parutil.c
**	AUTHORS:						David Michal
**	CREATION DATE:					5/88
**	ABSTRACT:
**		The support functions for the lexical analyzer.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "parser.h"
#include "commacro.h"
#include "risdebug.h"

/*
**	FUNCTION PROTOTYPES
*/
#define parutil_c
#include "comalloc.prt"
#include "parutil.prt"
#include "comdebug.prt"
#include "sys.prt"




/*
**	DEFINES
*/
#define RISpar_STRING_CHUNK_SIZE RIS_MAX_ID_SIZE-1

/*
**	VARIABLES
*/
static int total_alloced;

/*
**	FUNCTIONS
*/


/******************************************************************************/

extern void RISpar_unput(
#if defined(WIN32)
	wint_t c)
#else
	int c)
#endif
{
	if (c != WIDECHAR('\0'))
	{
		RISpar_cur_bufp--;
	}
}

/******************************************************************************/

#if defined(WIN32)
extern wint_t RISpar_input()
#else
extern int RISpar_input()
#endif
{
	if (RISpar_cur_bufp == RISpar_end_bufp)
	{
		return(0);
	}
	else
	{
		return(*RISpar_cur_bufp++);
	}
}

/******************************************************************************/

extern void RISpar_init_str()
{
#if defined(WIN32)
	RISpar_beg_ptr = (wchar_t *)ALLOCB(((RISpar_STRING_CHUNK_SIZE+1)
				 * sizeof(wchar_t))); 
	total_alloced = RISpar_STRING_CHUNK_SIZE + 1; /*chars not bytes*/

	RISpar_cur_ptr = RISpar_beg_ptr;
	RISpar_end_ptr = RISpar_cur_ptr+total_alloced - 2;
#else
	total_alloced = total_alloced; /* shut up compiler */

	RISpar_beg_ptr = ALLOCB(RISpar_STRING_CHUNK_SIZE+1);
	RISpar_cur_ptr = RISpar_beg_ptr;
	RISpar_end_ptr = RISpar_cur_ptr+RISpar_STRING_CHUNK_SIZE-1;
#endif

}

/******************************************************************************/

extern void RISpar_check_str_size()
{
#if defined(WIN32)
	wchar_t * temp_str;
#else
	char * temp_str;
#endif
	int str_len;


	if (RISpar_cur_ptr == RISpar_end_ptr)
	{
		str_len = RISpar_end_ptr - RISpar_beg_ptr;
#if defined(WIN32)
		temp_str = (wchar_t *)ALLOCB((str_len +RISpar_STRING_CHUNK_SIZE+1)
					* sizeof(wchar_t));
		memcpy(temp_str,RISpar_beg_ptr,str_len * sizeof(wchar_t));

					/*chars not bytes*/
		total_alloced = str_len + RISpar_STRING_CHUNK_SIZE + 1; 

		RISpar_beg_ptr = temp_str;
		RISpar_cur_ptr = RISpar_beg_ptr+str_len;
		RISpar_end_ptr = RISpar_beg_ptr+total_alloced - 2;
#else
		total_alloced = total_alloced; /* shut up compiler */
		temp_str = ALLOCB(str_len+RISpar_STRING_CHUNK_SIZE+1);
		memcpy(temp_str,RISpar_beg_ptr,str_len);
		RISpar_beg_ptr = temp_str;
		RISpar_cur_ptr = RISpar_beg_ptr+str_len;
		RISpar_end_ptr = RISpar_cur_ptr+RISpar_STRING_CHUNK_SIZE-1;
#endif
	}
}

/******************************************************************************/

extern char *RISpar_got_string()
{
	char *return_str;

	if (RISpar_token == RIS_TOK_SEMICOLON &&
		RISpar_cur_bufp == RISpar_end_bufp)
		return_str = "end of statement";
	else
	{
		return_str = ALLOCB(strlen(RISpar_lex.val) + 3);
		sprintf(return_str,"'%s'",RISpar_lex.val);
	}

	return return_str;
}

/******************************************************************************/
