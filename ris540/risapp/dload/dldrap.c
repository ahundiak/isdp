/*
**	NAME:							dldrap.c
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					8/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	DEFINES
*/
#if defined(unix) || defined(DOS)
#endif
#if defined(WIN32)
//For NT on currently
#define VERSION_4_ONLY
#endif

/*
**	INCLUDES
*/
#include <stdio.h>
#if defined(unix)
#if defined(VERSION_4_ONLY)
#include "xc/dload.h"
#endif
#endif
#if defined(WIN32)
#include <windows.h>
#endif
#if defined(DOS)
#endif
#include "risapi.h"
#include "risver.h"
#include "dload.h"

/*
**	FUNCTION PROTOTYPES
*/
#define dldrap_c
#if defined(VERSION_4_ONLY)
#include "dldmain.prt"
#include "dlderror.prt"
#include "dldgtdir.prt"
#include "sys.prt"
#else
#include "intrap.prt"
#endif
#if defined(WIN32)
#include "dlddebug.prt"
#endif

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISrap_initialize()
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_rap_initialize)();
#else
	RISXrap_initialize();
#endif
}

/******************************************************************************/

extern void RISrap_print_input_sqlda(
	FILE  *fp,
	sqlda *input)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_rap_print_input_sqlda)(fp,input);
#else
	RISXrap_print_input_sqlda(fp,input);
#endif
}

/******************************************************************************/

extern void RISrap_print_output_sqlda(
	FILE  *fp,
	sqlda *output)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_rap_print_output_sqlda)(fp,output);
#else
	RISXrap_print_output_sqlda(fp,output);
#endif
}

/******************************************************************************/

extern void RISrap_print_describe_sqlda(
	FILE  *fp,
	sqlda *data)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_rap_print_describe_sqlda)(fp,data);
#else
	RISXrap_print_describe_sqlda(fp,data);
#endif
}

/******************************************************************************/

extern void RISrap_print_test_sqlda(
	FILE  *fp,
	sqlda *input)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_rap_print_test_sqlda)(fp,input);
#else
	RISXrap_print_test_sqlda(fp,input);
#endif
}

/******************************************************************************/

extern void RISrap_print_client_parms(
	FILE  		 *fp,
	client_parms *parms)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_rap_print_client_parms)(fp,parms);
#else
	RISXrap_print_client_parms(fp,parms);
#endif
}

/******************************************************************************/

extern void RISrap_print_schema_file_parms(
	FILE  			  *fp,
	schema_file_parms *parms)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_rap_print_schema_file_parms)(fp,parms);
#else
	RISXrap_print_schema_file_parms(fp,parms);
#endif
}

/******************************************************************************/

extern int RISrap_compare_fetch(
	int  	id,
	sqlda 	*output,
	int 	one_row_only)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLD_rap_compare_fetch)(id,output,one_row_only));
#else
	return(RISXrap_compare_fetch(id,output,one_row_only));
#endif
}

/******************************************************************************/
