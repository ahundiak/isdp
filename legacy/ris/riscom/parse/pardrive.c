/* Do not alter this SPC information: $Revision: 1.3.51.1 $ */
/*
**	NAME:							pardrive.c
**	AUTHORS:						David Michal 
**	CREATION DATE:					3/88
**	ABSTRACT:
**		This file contains the routine that drives the parser.
**	
**	REVISION HISTORY:
*/
 
#define PARSE_GLOBAL_DEFINE

/*
**	INCLUDES
*/
#include "parser.h"
#if defined(WIN32)
#include "commacro.h"
#endif

/*
**	FUNCTION PROTOTYPES
*/
#define pardrive_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comoutpt.prt"
#include "pardrive.prt"
#include "parstack.prt"
#include "partree.prt"
#include "parse.prt"
#include "sys.prt"
#if defined(WIN32)
#include "comuni.prt"
#endif


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

extern ristree *RISpar_driver(
	char			*query,
	char			*old_sch_name,
	char			*new_sch_name,
	macro_list_node *macro_list,
	risschema		*schemap)
{
	int		query_len;
	ristree	*tp;
#if defined(WIN32)
        int widechars, shortchars; /*used for wide-char test */
#endif

	PAR_DBG(("PARdriver(query:<%s> old_sch_name:<%s> new_sch_name:<%s> "
	"macro_list:0x%x schemap:0x%x\n", STRING(query), STRING(old_sch_name),
	STRING(new_sch_name), macro_list, schemap));

	if(old_sch_name)
	{
		RISpar_old_sch = old_sch_name;
	}
	else
	{
		RISpar_old_sch = (char *)0;
	}

	if(new_sch_name)
	{
		RISpar_new_sch = new_sch_name;
	}
	else
	{
		RISpar_new_sch = (char *)0;
	}

	RISpar_dot_flag = 0;
	RISpar_lex_flag = 0;
	RISpar_host_ident_flag = 0;
	RISpar_no_parms = 0;
	RISpar_macro_list = macro_list;
	RISpar_schema = schemap;

	query_len = strlen(query);

	if ((query_len + 2) > RIS_MAX_STMT_LEN )
	{
		RISpar_ERR_RETURN(RIS_E_QUERY_TOO_LONG,0);
	}

#if defined(WIN32)
	RIScom_numchars(query,&widechars, &shortchars,0);

	query_len = (widechars + shortchars) * sizeof(wchar_t);

	RISpar_head_bufp = (wchar_t *)ALLOCB(query_len+(sizeof(wchar_t) * 2));
   	RIScom_mbstowcs(RISpar_head_bufp, query,query_len );
	RISpar_cur_bufp = RISpar_head_bufp;
	RISpar_end_bufp = RISpar_head_bufp + widechars + shortchars + 1;
	*(RISpar_end_bufp-1) = WIDECHAR(';');
	*RISpar_end_bufp = WIDECHAR('\0');

#else /*the old stuff for everything but japaneese....*/

	RISpar_head_bufp = ALLOCB(query_len+2);
	memcpy(RISpar_head_bufp,query,query_len);
	RISpar_cur_bufp = RISpar_head_bufp;
	RISpar_end_bufp = RISpar_head_bufp + query_len + 1;
	*(RISpar_end_bufp-1) = ';';
	*RISpar_end_bufp = '\0';

#endif

	RISpar_create_stack();
	RISpar_parse();
	tp = RISpar_top();

	if (RISpar_debug)
	{
		RIScom_output_tree(RIScom_output_debug,tp);
		RISpar_draw_tree(tp);
		RIScom_output_debug("RISpar_driver: returning tp:0x%x\n", tp);
	}
	return tp;
}
