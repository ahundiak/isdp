/* Do not alter this SPC information: $Revision: 1.5.5.1 $ */
/*
**	NAME:							cppmisc.c
**	AUTHORS:						David Michal
**	CREATION DATE:					6/88
**	ABSTRACT:
**	The misc functions
**		
**	
**	REVISION HISTORY:
**			August, 93 Added branding stuff for DOS - SK.
**			October, 93 Added concurrency lic. stuff for DOS - SK.
*/
 
/*
**	INCLUDES
*/
#if defined(DOS)
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <io.h>
#endif
#if defined(WIN32)
#include <windows.h>
#endif
#if defined(WIN32) || defined(DOS)
#include <brand.h>
#endif
#include <ctype.h>
#include "ris_err.h"
#include "riscom.h"
#include "rislicns.h"
#include "rismem.h"
#include "cpp.h"
#include "commacro.h"

/*
**	DEFINES
*/
#define BRANDING_STRING_1	"RISDPBRANDING"
#define BRANDING_STRING_2	"LICENSED TO INTERGRAPH CORPORATION"
#define BRANDING_STRING_3	"123456781234567"
#define APPNAME			 	"riscpp.exe"
#if defined(WIN32)
#define PRODINDEX		 	"000336"
#define APP_NOGRACE			"CL000027_NOLICENSEGRACE"
#define GENERIC_NOGRACE		"CL_NOLICENSEGRACE"
#endif
#if defined(DOS)
#define PRODINDEX		 	"000026"
#define APP_NOGRACE			"CL000026_NOLICENSEGRACE"
#define GENERIC_NOGRACE		"CL_NOLICENSEGRACE"
#endif

/*
**	VARIABLES
*/
#if defined(WIN32) || defined(DOS)
char user[64] = "No User";
char company[64] = "No Company";
char serial[16] = "No Serial";
#endif
#if defined(WIN32)
BrandInfo brand_info;		/* for concurrent licenseing */
#endif
#if defined(DOS)
BrandInfo brand_info;		/* for concurrent licenseing */
#endif

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define cppmisc_c
#include "comalloc.prt"
#include "comdebug.prt"
#if defined(WIN32)
#include "comgtver.prt"
#endif
#include "comjmp.prt"
#include "comisfn.prt"
#include "comstcmi.prt"
#include "comwrap.prt"
#if defined(WIN32) || defined(DOS)
#include "comumsg.prt"
#endif
#include "cppmisc.prt"
#include "comuni.prt"
#include "sys.prt"


/******************************************************************************/

extern void RIScpp_push_scope()
{
	scope_stack_node * temp;

CPP_DBG(("\nRIScpp_push_scope\n"));

	temp = ALLOCTP(scope_stack_node);
	temp->var_list = 0;
	temp->next = RIScpp_scope_stack;
	RIScpp_scope_stack = temp;
}

/******************************************************************************/

extern void RIScpp_pop_scope()
{

CPP_DBG(("\nRIScpp_pop_scope\n"));

	if (RIScpp_scope_stack)
	{
		RIScpp_scope_stack = RIScpp_scope_stack->next;
	}
	else
	{
		CPP_ERR_RETURN(RIS_E_SCOPE_STACK_UNDERFLOW,0);
		exit(1);
	}
}

/******************************************************************************/

extern void RIScpp_copy_temp_to_out()
{
	int count;
	int write_count;

CPP_DBG(("\nRIScpp_copy_temp_to_out\n"));

	rewind(RIScpp_temp_file);
#if defined(WIN32) || defined(DOS)
/*
**	THIS CODE ALSO BE USED FOR OTHER PLATFORMS
*/
	while ( !feof(RIScpp_temp_file) )
	{
		count = 
			RIScom_fread(RIScpp_query_buf,1,
				RIScpp_query_buf_size,RIScpp_temp_file);
CPP_DBG(("\nRIScpp_copy_temp_to_out: read count = %d\n", count));
		write_count = 
			RIScom_fwrite(RIScpp_query_buf,1,count,RIScpp_out_file);
CPP_DBG(("\nRIScpp_copy_temp_to_out: wrote count = %d\n", write_count));
	}
#else
	do
	{
		count = 
			RIScom_fread(RIScpp_query_buf,1,
				RIScpp_query_buf_size,RIScpp_temp_file);
CPP_DBG(("\nRIScpp_copy_temp_to_out: read count = %d\n", count));
		write_count = 
			RIScom_fwrite(RIScpp_query_buf,1,count,RIScpp_out_file);
CPP_DBG(("\nRIScpp_copy_temp_to_out: wrote count = %d\n", write_count));
	}
	while (count == RIScpp_query_buf_size);
#endif
}

/******************************************************************************/

extern int RIScpp_find_non_white(
	char * str)
{
#ifdef WIN32
	wchar_t	*tmp_data;
	RIScom_multiwide(&RISwide_ptr, &str, &RISwide_size, MULTITOWIDE, 0 );
	tmp_data = RISwide_ptr;
#else
	char	*tmp_data;
	tmp_data = str;
#endif

	for(;*tmp_data != WIDECHAR('\0');tmp_data++)
	{
		if (!ISSPACE(*tmp_data))
		{
			return(1);
		}
	}
	return(0);
}

/******************************************************************************/

extern void RIScpp_fix_string(
	char * str)
{
	int i;
	int j = 0;
	int eat_space = 1;
	int preserve = 0;

#ifdef WIN32
	/* 
	** INTERNATIONALIZATION change
	*/
	wchar_t *tmp_str;
	RIScom_multiwide(&RISwide_ptr, &str, &RISwide_size, MULTITOWIDE, 0);
	tmp_str = RISwide_ptr;
	CPP_DBG(("\nRIScpp_fix_string str = <%S>\n", tmp_str));
#else
	char *tmp_str = str;
	CPP_DBG(("\nRIScpp_fix_string str = %s\n", STRING(str)));	
#endif

	for(i=0; tmp_str[i] != WIDECHAR('\0'); i++)
	{
		switch(tmp_str[i])
		{
			case WIDECHAR(' '):
			case WIDECHAR('\t'):
			case WIDECHAR('\n'):
				if (preserve)
				{
					tmp_str[j++] = tmp_str[i];
				}
				else if (!eat_space)
				{
					eat_space = 1;
					tmp_str[j++] = WIDECHAR(' ');
				}
			break;
			case WIDECHAR('\\'):
				if (tmp_str[i+1] == WIDECHAR('\n') )
				{
					tmp_str[i+1] = WIDECHAR(' ');
				}
				else
				{
					eat_space = 0;
					tmp_str[j++] = tmp_str[i];
				}
			break;
			case WIDECHAR('\''):
			case WIDECHAR('\"'):
				preserve = !preserve;
				eat_space = 0;
				tmp_str[j++] = tmp_str[i];
			break;
			default:
				eat_space = 0;
				tmp_str[j++] = tmp_str[i];
			break;
		}
	}
	tmp_str[j] = WIDECHAR('\0');

#ifdef WIN32
	RIScom_wcstombs( str, tmp_str, strlen(str));
#endif
	CPP_DBG(("RIScpp_fix_string: string fixed: <%s>\n", str ));
}

/******************************************************************************/

extern void RIScpp_print_stmt_id_var_decls()
{
	int i;

CPP_DBG(("\nRIScpp_print_stmt_id_var_decls\n"));

	for (i=0;i < RIScpp_stmt_index;i++)
	{
		fprintf(RIScpp_out_file,"static short RIScpp_stmt_id%d = -1;\n",i);
	}
}

/******************************************************************************/

/*------------------------------------------------------------------------------
 *  Leaving alone for i18n.  We are looking for the keywords "exec" "sql".  the
 *  only valid values before "exec" and after "sql" are white spaces.  Do
 *  not need to convert due to this.  Paula  1/23/95
------------------------------------------------------------------------------*/
extern int RIScpp_find_exec_sql(
	char * str)
{
	int i;
	int len1 = sizeof("exec") - 1;
	int len2 = sizeof("sql") - 1;
	char *match_str1 = "exec";
	char *match_str2 = "sql";

	CPP_DBG(("\nRIScpp_find_exec_sql str = <%s>\n", STRING(str)));

	if (!RIScpp_ignore_special)
	{
		for(i=0;RIScom_isspace(str[i]);i++);

		if (RIScom_strncmp_ic(str + i, match_str1, len1)) /*itbokic 3/30 */
		{
			return(0);
		}

		i += len1;
		for(;RIScom_isspace(str[i]);i++);

		if (RIScom_strncmp_ic(str + i, match_str2, len2)) /*itbokic 3/30 */
		{
			return(0);
		}

		i += len2;

		if (RIScom_isspace(str[i]) || str[i] == '\0')
		{
			return(i+1);
		}
	}
	return(0);
}

/******************************************************************************/

extern void RIScpp_sqlerror_notfound_check()
{

CPP_DBG(("\nRIScpp_sqlerror_notfound_check\n"));

    if (RIScpp_notfound_targ)
    {
        fprintf(RIScpp_temp_file,
         "if (RISget_sqlcode() == END_OF_DATA) goto %s;",RIScpp_notfound_targ);
        if (RIScpp_sqlerror_targ)
        {
            fprintf(RIScpp_temp_file,
             "\nelse if (RISget_sqlcode() != RIS_SUCCESS) goto %s;",
			 RIScpp_sqlerror_targ);
        }
    }
    else if (RIScpp_sqlerror_targ)
    {
        fprintf(RIScpp_temp_file,
		 "if (RISget_sqlcode() != RIS_SUCCESS && RISget_sqlcode() != END_OF_DATA) goto %s;"
		 ,RIScpp_sqlerror_targ);
    }
}

/******************************************************************************/

extern void RIScpp_sqlerror_check()
{

CPP_DBG(("\nRIScpp_sqlerror_check\n"));

    if (RIScpp_sqlerror_targ)
    {
        fprintf(RIScpp_temp_file,"if (RISget_sqlcode() != RIS_SUCCESS) goto %s;",
         RIScpp_sqlerror_targ);
    }
}

/******************************************************************************/

extern void RIScpp_expand_buf(
	char ** buf,
	int * buf_size,
	int grow_size)
{
	char * temp;

CPP_DBG(("\nRIScpp_expand_buf buf = 0x%x buf_size = %d grow_size = %d\n",
 *buf,*buf_size,grow_size));

	if (grow_size % RIScpp_QUERY_CHUNK_SIZE)
	{
		grow_size = (grow_size/RIScpp_QUERY_CHUNK_SIZE+1)*RIScpp_QUERY_CHUNK_SIZE;
	}
	temp = ALLOCBP(*buf_size + grow_size);
	memcpy(temp ,*buf,*buf_size );
	*buf = temp;
	*buf_size += grow_size;
}

/******************************************************************************/

#if defined(WIN32)
extern void RIScpp_verify_license()
{
	char	*c;
	char	*lic_user;
	char	*lic_company;
	char	*lic_serial;
	int		unregistered = 1; /* default is unregistered */
	int		cl_result; /* concurrent licensing */

	CPP_DBG(("RIScpp_verify_license()\n"));

	/* 
	** During setup, riscpp is branded with user, company and serial #
	** This values are also XOR with 0xA5.
	** Check for BRANDING_STRING_1 macro in user for total unbranded. 
	** Then check for BRANDING_STRING_2 macro in user for partial unbranded.
	*/

	/* USER */
	if( !RIS_development )
	{
		lic_user = RIScom_get_license(APPNAME, LIC_USER);
		if (lic_user)
		{
			if( !strncmp(lic_user, BRANDING_STRING_1,  /*itbokic 3/30 */
						strlen(BRANDING_STRING_1)) )
			{
				/* To check for total unbranded app we need un-XORed string */
				unregistered = 1;
			}
			else
			{
				strcpy(user,lic_user);
				for(c = user; *c; c++)
				{
					*c ^= 0xA5;
				}
				if( !lstrcmpi(user, BRANDING_STRING_2) )
				{
					/* Partially branded by MFG; skip serial# verification */
					unregistered = 0;
				}
				unregistered = 0;
			}
			CPP_DBG(("RIScpp_verify_license:user:<%s>\n", user));
		}
		else
		{
			unregistered = 1;
		}

		/* COMPANY */
		lic_company = RIScom_get_license(APPNAME, LIC_COMPANY);
		if (lic_company)
		{
			if( !strncmp(lic_user, BRANDING_STRING_1,  /*itbokic 3/30 */
						strlen(BRANDING_STRING_1)) )
			{
				/* To check for total unbranded app we need un-XORed string */
				unregistered = 1;
			}
			else
			{
				strcpy(company,lic_company);
				for(c = company; *c; c++)
				{
					*c ^= 0xA5;
				}
				if( !lstrcmpi(company, BRANDING_STRING_2) )
				{
					/* Partially branded by MFG; skip serial# verification */
					unregistered = 0;
				}
				unregistered = 0;
			}
		}
		else
		{
			unregistered = 1;
		}
		CPP_DBG(("RIScpp_verify_license:company:<%s>\n", company));
	
		/* SERIAL */
		lic_serial = RIScom_get_license(APPNAME, LIC_SERIAL);
		if (lic_serial)
		{
			if( !strncmp(lic_serial, BRANDING_STRING_3,  /*itbokic 3/30 */
						strlen(BRANDING_STRING_3)) )
			{
				/* To check for total unbranded app we need un-XORed string */
				unregistered = 1;
			}
			else
			{
				strcpy(serial,lic_serial);
				for(c = serial; *c; c++)
				{
					*c ^= 0xA5;
				}
				unregistered = 0; /* Found serial# other than default */
			}
			CPP_DBG(("RIScpp_verify_license:serial:<%s>\n", serial));
		}
		else
		{
			unregistered = 1;
		}

       	/* CONCURRENT LICENSING STUFF */
       	cl_result = dl_serialaudit_start(PRODINDEX, APPNAME, &brand_info);

       	if( cl_result == NO_POOLFILE_VARIABLE )
       	{
       		CPP_DBG(("RIScpp_verify_license: NO_POOLFILE_VARIABLE\n"));
       		/* 
       		** Concurrent Licensing is DISABLED. If "unregistered" set
       		** by version stuff indicate to user about it.
       		*/
       		if( unregistered )
       		{
       			/* Indicate that this product is unregistered and quit */
       			LONGJMP(RIS_E_PROD_NO_REG_QUIT);
       		}
       	}
       	else if( cl_result == SERIAL_NUMBER_VALID )
       	{
       		/* 
       		** Concurrent Licensing is ENABLED and a valid license was
       		** obtained. Therefore, riscpp is registered.
       		*/
       		CPP_DBG(("RIScpp_verify_license: SERIAL_NUMBER_VALID\n"));
       		unregistered = 0;

       		/* registration info is in UN, UO and SN fields */
       		lstrcpy(user, brand_info.theUN);
       		lstrcpy(company, brand_info.theUO);
       		lstrcpy(serial, brand_info.theSN);
       		CPP_DBG(("UN:%s UO:%s SN:%s\n", brand_info.theUN,
       			brand_info.theUO, brand_info.theSN));
       	}
       	else
       	{
       		/* 
       		** Concurrent Licensing is ENABLED but no valid license was
       		** obtained. Therefore, examine environment variables to continue
       		** or not.
       		*/
       		CPP_DBG(("RIScpp_verify_license: cl_result=%d\n", cl_result));
       		if( getenv(APP_NOGRACE) )
       		{
       			LONGJMP(RIS_E_PROD_NO_VALID_LIC_QUIT);
       		}
       		else if( getenv(GENERIC_NOGRACE) )
       		{
       			LONGJMP(RIS_E_PROD_NO_VALID_LIC_QUIT);
       		}
       		else
       		{
       			/* Indicate that this product is unregistered and continue */
       			fprintf(STDERR, RIScom_umsg(RIS_E_PROD_NO_REG_CONTINUE));
       		}
       	}
	}
	CPP_DBG(("RIScpp_verify_license:complete.\n"));
}
#endif

#if defined(DOS)
extern void RIScpp_verify_license()
{
    char buf[256], *c;
    int unregistered = 1;
    long data_index;
    int bytes_read;
    int fdin;
	char name_buf[64];
	char org_buf[64];
	char ser_buf[16];
	char *env;
	char path[256];
	int		cl_result; /* concurrent licensing */

	CPP_DBG(("RIScpp_verify_licenses\n"));
	if (!RIS_development)
	{
		if ((env = getenv("RISDP")) != NULL)
		{
			sprintf(path, "%s\\bin\\riscpp.exe",env);
			CPP_DBG(("RIScpp_verify_license:path=%s\n",path));
    		if ((fdin = open(path, _O_RDONLY | _O_BINARY)) >= 0)
			{
				if ((data_index = _lseek(fdin, -154L, SEEK_END)) < 0) 
				{
	    			close(fdin);
	    			LONGJMP(RIS_E_INTERNAL_ERROR);
				}
				bytes_read = read(fdin, buf, 154);
	
        		close(fdin);
				if (strncmp(buf, "INGR_DATA", 9) == 0)  /*itbokic 3/30 */
				{
	    			memcpy(name_buf, buf+10, 64);
	    			if (*name_buf)
	    			{
						strcpy(user,name_buf);
	    				for (c = user; *c; c++)
	    				{
							*c ^= 0xA5;
						}
						unregistered = 0;
					}
					else
					{
						unregistered = 1;
					}
					CPP_DBG(("\nRIScpp_verify_license:user=%s\n", user));
	    			if (!strcmp(user, BRANDING_STRING_2))
	    			{
						/* Licensed to MFG; skip serial# verification */
						unregistered = 0;
	    			}
	    			memcpy(org_buf, buf+74, 64);
	    			if (*org_buf)
	    			{
						strcpy(company,org_buf);
	    				for (c = company; *c; c++)
						{
							*c ^= 0xA5;
						}
						unregistered = 0;
					}
					else
					{
						unregistered = 1;
					}
					CPP_DBG(("\nRIScpp_verify_license:company=%s\n", company));
	    			memcpy(ser_buf, buf+138, 16);
	    			if (*ser_buf)
	    			{
						strcpy(serial,ser_buf);
	    				for (c = serial; *c; c++)
	    				{
							*c ^= 0xA5;
						}
						unregistered = 0;
					}
					else
					{
						unregistered = 1;
					}
					CPP_DBG(("\nRIScpp_verify_license:serial=%s\n", serial));
        		}
			}
			else
			{
				LONGJMP(RIS_E_CANT_FIND_ENV_PRODUCT);
			}
		}
		else
		{
			LONGJMP(RIS_E_CANT_FIND_ENV_PRODUCT);
		}

		/* Set szAppPath for evaluation stuff */
		sprintf(szAppPath, "%s\\%s\\%s", RISDP_dir, "bin", APPNAME);

       	/* CONCURRENT LICENSING STUFF */
       	cl_result = dl_serialaudit_start(PRODINDEX, APPNAME, &brand_info);

       	if( cl_result == NO_POOLFILE_VARIABLE )
       	{
       		CPP_DBG(("RIScpp_verify_license: NO_POOLFILE_VARIABLE\n"));
       		/* 
       		** Concurrent Licensing is DISABLED. If "unregistered" set
       		** by version stuff indicate to user about it.
       		*/
       		if( unregistered )
       		{
       			/* Indicate that this product is unregistered and quit */
       			LONGJMP(RIS_E_PROD_NO_REG_QUIT);
       		}
       	}
       	else if( cl_result == SERIAL_NUMBER_VALID )
       	{
       		/* 
       		** Concurrent Licensing is ENABLED and a valid license was
       		** obtained. Therefore, riscpp is registered.
       		*/
       		CPP_DBG(("RIScpp_verify_license: SERIAL_NUMBER_VALID\n"));
       		unregistered = 0;

       		/* registration info is in UN, UO and SN fields */
       		strcpy(user, brand_info.theUN);
       		strcpy(company, brand_info.theUO);
       		strcpy(serial, brand_info.theSN);
       		CPP_DBG(("UN:%s UO:%s SN:%s\n", brand_info.theUN,
       			brand_info.theUO, brand_info.theSN));
       	}
       	else
       	{
       		/* 
       		** Concurrent Licensing is ENABLED but no valid license was
       		** obtained. Therefore, examine environment variables to continue
       		** or not.
       		*/
       		CPP_DBG(("RIScpp_verify_license: cl_result=%d\n", cl_result));
#if defined(DOS)
			if( cl_result == NO_LOCKING_ENFORCED )
			{
/*				fprintf(stdout, "For Concurrent Licensing should run SHARE.EXE in C:\\DOS directory\n");
				fprintf(stdout, "to enforce the lock for the pool file\n");
*/
 				LONGJMP(RIS_E_NO_LOCKING_ENFORCED);
			}
#endif
       		if( getenv(APP_NOGRACE) )
       		{
       			LONGJMP(RIS_E_PROD_NO_VALID_LIC_QUIT);
       		}
       		else if( getenv(GENERIC_NOGRACE) )
       		{
       			LONGJMP(RIS_E_PROD_NO_VALID_LIC_QUIT);
       		}
       		else
       		{
       			/* Indicate that this product is unregistered and continue */
       			fprintf(STDERR, RIScom_umsg(RIS_E_PROD_NO_REG_CONTINUE));
       		}
       	}
	}
	CPP_DBG(("RIScpp_verify_licenses completed.\n"));
}
#endif

/******************************************************************************/

#if defined(WIN32) || defined(DOS)
extern char * RIScpp_get_user()
{
	return(user);
}
#endif

/******************************************************************************/

#if defined(WIN32) || defined(DOS)
extern char * RIScpp_get_company()
{
	return(company);
}
#endif

/******************************************************************************/

#if defined(WIN32) || defined(DOS)
extern char * RIScpp_get_serial()

{
	return(serial);
}
#endif

/******************************************************************************/

extern void RIScpp_serialaudit_end()
{
#if defined(WIN32) || defined(DOS)
	CPP_DBG(("RIScpp_serialaudit_end()\n"));
	if( !RIS_development )
	{
		dl_serialaudit_end(APPNAME, &brand_info);
	}
	CPP_DBG(("RIScpp_serialaudit_end:complete.\n"));
#endif
}

/******************************************************************************/
